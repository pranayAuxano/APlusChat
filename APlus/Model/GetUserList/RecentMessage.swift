//
//  RecentMessage.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RecentMessage: Codable
{
    var timeMilliSeconds: CreateAt?         //var timeMilliSeconds: TimeMilliSeconds?
    var fileName: String?
    var replyUserId: String?
    var contentType: String?
    var file: String?
    var message: String?
    var type: String?
    var replyMsgId: String?
    var sendNotificationId: [String]?
    var replyMsg: String?
    var replyMsgType: String?
    var filePath: String?
    var thumbnailPath: String?
    var replyUser: String?
    var msgId: String?
    var sentBy: String?
    var senderName: String?
    
    enum CodingKeys: String, CodingKey {
        case timeMilliSeconds
        case fileName
        case replyUserId
        case contentType
        case file
        case message
        case type
        case replyMsgId
        case sendNotificationId
        case replyMsg
        case replyMsgType
        case filePath
        case thumbnailPath
        case replyUser
        case msgId
        case sentBy
        case senderName
    }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeMilliSeconds = try container.decodeIfPresent(CreateAt.self, forKey: .timeMilliSeconds)
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        replyUserId = try container.decodeIfPresent(String.self, forKey: .replyUserId)
        contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
        file = try container.decodeIfPresent(String.self, forKey: .file)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        replyMsgId = try container.decodeIfPresent(String.self, forKey: .replyMsgId)
        sendNotificationId = try container.decodeIfPresent([String].self, forKey: .sendNotificationId)
        replyMsg = try container.decodeIfPresent(String.self, forKey: .replyMsg)
        replyMsgType = try container.decodeIfPresent(String.self, forKey: .replyMsgType)
        filePath = try container.decodeIfPresent(String.self, forKey: .filePath)
        thumbnailPath = try container.decodeIfPresent(String.self, forKey: .thumbnailPath)
        replyUser = try container.decodeIfPresent(String.self, forKey: .replyUser)
        msgId = try container.decodeIfPresent(String.self, forKey: .msgId)
        sentBy = try container.decodeIfPresent(String.self, forKey: .sentBy)
        senderName = try container.decodeIfPresent(String.self, forKey: .senderName)
    }
}
