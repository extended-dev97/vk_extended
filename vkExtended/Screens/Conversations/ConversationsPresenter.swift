//
//  ConversationsPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 20.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Alamofire

class ConversationsPresenter: ConversationsPresenterProtocol {

    weak private var view: ConversationsViewProtocol?
    var interactor: ConversationsInteractorProtocol?
    private let router: ConversationsWireframeProtocol

    init(interface: ConversationsViewProtocol, interactor: ConversationsInteractorProtocol?, router: ConversationsWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }
    
    // Действие при событии
    func onEvent(message: String, isError: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view?.event(message: message, isError: isError)
        })
    }

    // Получение переписок
    func getConversations(offset: Int) {
        guard let interactor = interactor else { return }
        interactor.getConversations(offset: offset)
    }
    
    // Остановка рефрешера
    func onFinishRequest() {
        DispatchQueue.main.async {
            self.view?.stopRefreshControl()
        }
    }
    
    // При переходе в профиль
    func onTapPerformProfile(from peerId: Int) {
        router.openProfile(userId: peerId)
    }
    
    // Обработка смены режима уведомлений
    func onChangeSilenceMode(from peerId: Int, sound: Int) {
        guard let interactor = interactor else { return }
        interactor.setSilenceMode(peerId: peerId, sound: sound)
    }
    
    // Oбработка удаления диалога
    func onDeleteConversation(from peerId: Int) {
        guard let interactor = interactor else { return }
        interactor.deleteConversation(peerId: peerId)
    }
    
    // Обработка действия "Прочитать сообщение"
    func onTapReadConversation(from peerId: Int) {
        guard let interactor = interactor else { return }
        interactor.readMessage(peerId: peerId)
    }
    
    // Обработка действия "Отметить сообщение непрочитанным"
    func onTapUnreadConversation(from peerId: Int) {
        guard let interactor = interactor else { return }
        interactor.markAsUnreadConversation(peerId: peerId)
    }
    
    // Обработка действия "Открыть приватные переписки"
    func onOpenPrivateConversations() {
        DispatchQueue.main.async {
            self.router.openPrivateConversations()
        }
    }
    
    // Обработка действия "Удалить несколько переписок"
    func onRemoveMultipleConversations(by peerIds: [Int]) {
        interactor?.removeMultipleConversations(by: peerIds)
    }
}