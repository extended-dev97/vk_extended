//
//  PrivateConversationsProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 14.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation
import Alamofire

//MARK: Wireframe -
protocol PrivateConversationsWireframeProtocol: class {
    func openProfile(userId: Int)
    func closePrivateConversations()
}
//MARK: Presenter -
protocol PrivateConversationsPresenterProtocol: class {
    func onEvent(message: String, isError: Bool)
    func onTapPerformProfile(from peerId: Int)
    func onTapReadConversation(from peerId: Int)
    func onTapUnreadConversation(from peerId: Int)
    func onChangeSilenceMode(from peerId: Int, sound: Int)
    func onDeleteConversation(from peerId: Int)
    func onClosePrivateConversations()
}

//MARK: Interactor -
protocol PrivateConversationsInteractorProtocol: class {
    var presenter: PrivateConversationsPresenterProtocol?  { get set }
    func readMessage(peerId: Int)
    func markAsUnreadConversation(peerId: Int)
    func setSilenceMode(peerId: Int, sound: Int)
    func deleteConversation(peerId: Int)
}

//MARK: View -
protocol PrivateConversationsViewProtocol: class {
    var presenter: PrivateConversationsPresenterProtocol?  { get set }
    func event(message: String, isError: Bool)
}
