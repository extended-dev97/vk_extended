//
//  ConversationsInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 20.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import SwiftyJSON
import RealmSwift
import Alamofire

struct LongPollServer {
    let key: String
    let server: String
    let ts: Int
    let pts: Int
}

class ConversationsInteractor: ConversationsInteractorProtocol {

    weak var presenter: ConversationsPresenterProtocol?
    let conversationServiceInstance = ConversationService.instance
    
    // Получить переписки
    func getConversations(offset: Int = 0) {
        try! Api.Messages.getConversations(offset: offset).done { [weak self] conversations in
            guard let self = self else { return }
            self.conversationServiceInstance.updateDb(by: conversations)
            self.presenter?.onFinishRequest()
        }.catch { [weak self] error in
            guard let self = self else { return }
            self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
            self.presenter?.onFinishRequest()
        }
    }
    
    // Удалить несколько переписок
    func removeMultipleConversations(by peerIds: [Int]) {
        let parameters: Alamofire.Parameters = [
            Parameter.code.rawValue: """
var peer_ids = \(peerIds);
var i=0;
while (i<peer_ids.length)
{
API.messages.deleteConversation( {"peer_id":peer_ids[i]});
i=i+1;
};
return;
"""
        ]
        
        Request.dataRequest(method: ApiMethod.method(from: .execute, with: ApiMethod.Execute.execute, hasExecute: true), parameters: parameters, hasEventMethod: true).done { response in
            switch response {
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            default:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        let conversations = peerIds.compactMap({ realm.objects(Conversation.self).filter("peerId == %@", $0).first })
                        try! realm.write {
                            realm.delete(conversations)
                        }
                    }
                }
                self.presenter?.onEvent(message: "Выбранные чаты удалены", isError: false)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.localizedDescription, isError: true)
        }
    }
    
    // Обновить базу данных
    func updateDb(by response: JSON) {
        DispatchQueue.global(qos: .userInteractive).async {
            autoreleasepool {
                let realm = try! Realm()
                let items = response["items"].arrayValue
                
                try! realm.write {
                    for item in items {
                        let id = item["conversation"]["peer"]["id"].intValue
                        let fromId = item["last_message"]["from_id"].intValue

                        let profiles = response["profiles"].arrayValue
                        let groups = response["groups"].arrayValue
                        
                        let senderType = self.configureProfile(for: id > 2000000000 ? fromId : id, profiles: profiles, groups: groups)
                        let conversation: Conversation = Conversation(conversation: item["conversation"], lastMessage: item["last_message"], representable: senderType)
                        realm.add(conversation, update: .modified)
                    }
                }
            }
        }
    }
    
    // Конфигурация профиля
    private func configureProfile(for sourseId: Int, profiles: [JSON], groups: [JSON]) -> JSON {
        let profilesOrGroups: [JSON] = sourseId >= 0 ? profiles : groups
        let normalSourseId = sourseId >= 0 ? sourseId : -sourseId
        let profileRepresenatable = profilesOrGroups.first { (myProfileRepresenatable) -> Bool in
            myProfileRepresenatable["id"].intValue == normalSourseId
        }
        return profileRepresenatable!
    }
    
    // Прочитать сообщение
    func readMessage(peerId: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId]
        Request.dataRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.markAsRead), parameters: parameters, hasEventMethod: true).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            conversation.unreadCount = 0
                            conversation.isMarkedUnread = false
                        }
                    }
                }
                self.presenter?.onEvent(message: "Сообщение прочитано", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
    
    // Пометить непрочитанным
    func markAsUnreadConversation(peerId: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId]
        Request.dataRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.markAsUnread), parameters: parameters, hasEventMethod: true).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            conversation.isMarkedUnread = true
                        }
                    }
                }
                self.presenter?.onEvent(message: "Сообщение непрочитано", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
    
    // Установить режим уведомления для чата
    func setSilenceMode(peerId: Int, sound: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId, Parameter.sound.rawValue: sound, Parameter.time.rawValue: sound == 1 ? 0 : -1]
        Request.dataRequest(method: ApiMethod.method(from: .account, with: ApiMethod.Account.setSilenceMode), parameters: parameters, hasEventMethod: true).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            conversation.disabledForever = sound == 0
                            conversation.noSound = sound == 0
                        }
                    }
                }
                self.presenter?.onEvent(message: "Уведомления \(sound == 1 ? "включены" : "выключены")", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
    
    // Удаление переписки
    func deleteConversation(peerId: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId]
        Request.dataRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.deleteConversation), parameters: parameters).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            realm.delete(conversation)
                        }
                    }
                }
                self.presenter?.onEvent(message: "Чат удалён", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
}
