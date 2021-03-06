//
//  NSNotifications.swift
//  VKExt
//
//  Created by programmist_NA on 28.05.2020.
//

import Foundation
import UIKit

import Foundation

extension Notification.Name {
    static let onLogin = Notification.Name(rawValue: "VK.Login")
    static let onLogout = Notification.Name(rawValue: "VK.Logout")
    static let onChangeSessionState = Notification.Name(rawValue: "VK.Session.Changed")
    static let onMessagesUpdate = Notification.Name(rawValue: "VK.Messages.Update")
    static let onMessagesReceived = Notification.Name(rawValue: "VK.Messages.Received")
    static let onMessagesEdited = Notification.Name(rawValue: "VK.Messages.Edited")
    static let onSetMessageFlags = Notification.Name(rawValue: "VK.Messages.SetFlag")
    static let onResetMessageFlags = Notification.Name(rawValue: "VK.Messages.ResetFlag")
    static let onInMessagesRead = Notification.Name(rawValue: "VK.Messages.InMessagesRead")
    static let onOutMessagesRead = Notification.Name(rawValue: "VK.Messages.OutMessagesRead")
    static let onFriendOnline = Notification.Name(rawValue: "VK.Friends.Online")
    static let onFriendOffline = Notification.Name(rawValue: "VK.Friends.Offline")
    static let onTyping = Notification.Name(rawValue: "VK.Messages.Typing")
    static let onRemoveConversation = Notification.Name(rawValue: "VK.Messages.Conversation.Remove")
    static let onCounterChanged = Notification.Name(rawValue: "VK.Counter.Changed")
}
extension Notification.Name {
    static let receivedMessage = Notification.Name(rawValue: "VK.Messages.Receive")
    static let receivedImportantMessage = Notification.Name(rawValue: "VK.Messages.Important.Receive")
    static let receivedMessageFromDialog = Notification.Name(rawValue: "VK.Messages.Receive.From.Dialog")
}
extension Notification.Name {
    static let showMessage = Notification.Name(rawValue: "VKExt.ViewController.ShowMessage")
}
extension Notification.Name {
    static let onSuccessPrepareSpace = Notification.Name(rawValue: "VKExt.Services.onSuccessPrepareSpace")
    static let onFailurePrepareSpace = Notification.Name(rawValue: "VKExt.Services.onFailurePrepareSpace")
    static let onSuccessConnectLongPoll = Notification.Name(rawValue: "VKExt.Services.onSuccessConnectLongPoll")
    static let onSuccessSetCounters = Notification.Name(rawValue: "VKExt.Services.onSuccessSetCounters")
    static let onFailureSetCounters = Notification.Name(rawValue: "VKExt.Services.onFailureSetCounters")
}
extension Notification.Name {
    static let onPlayerStart = Notification.Name(rawValue: "VKExt.AudioPlayer.Start")
    static let onPlayerStop = Notification.Name(rawValue: "VKExt.AudioPlayer.Stop")
    static let onPlayerPause = Notification.Name(rawValue: "VKExt.AudioPlayer.Pause")
    static let onPlayerResume = Notification.Name(rawValue: "VKExt.AudioPlayer.Resume")
    static let onPlayerNext = Notification.Name(rawValue: "VKExt.AudioPlayer.Next")
    static let onPlayerPrev = Notification.Name(rawValue: "VKExt.AudioPlayer.Prev")
    static let onPlayerStateChanged = Notification.Name(rawValue: "VKExt.AudioPlayer.State.Changed")
}
extension Notification.Name {
    static let onCaptchaDone = Notification.Name(rawValue: "VKExt.Login.Capthca")
}
