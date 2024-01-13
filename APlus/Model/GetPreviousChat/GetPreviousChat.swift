//
//  GetPreviousChat.swift
//
//  Created by  on 08/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

// MARK: - PreviousChat

struct PreviousChat: Codable
{
    var groupData: GroupData?
    var hasMore: Bool?
    var messages: [Message]?
}

// MARK: - GroupData

struct GroupData: Codable
{
    var userPermission: UserPermission?
    var userName: String?
    var opponentUserId: String?
    var onlineStatus: Bool?
    var isGroup: Bool?
    var groupName: String?
    var imagePath: String?
}

// MARK: - UserPermission

struct UserPermission: Codable
{
    var permission: Permission?
    var userId: String?
}

// MARK: - Message

struct Message: Codable
{
    var msgId: String?
    var contentType: String?
    var fileName: String?
    var filePath: String?
    var message: String?
    var senderName: String?
    var sentBy: String?
    var thumbnailPath: String?
    var time: Int?
    var timeMilliSeconds: SentAt?
    var type: String?
    
    var replyMsgId: String?
    var replyUserId: String?
    var replyMsg: String?
    var replyMsgType: String?
    var replyUser: String?
    
    ///get-chat -> message
    var name: String?
    
    ///receive message response
    var file: String?
    var sendNotificationId: [String]?
    var sentAt: SentAt?
    var viewBy: [String]?
    
    /// flag for documents
    var showLoader: Bool? = false
    
    /// flag for cell selected or not
    var isSelected: Bool? = false
}
