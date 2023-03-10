//
//  GetPreviousChat.swift
//
//  Created by  on 08/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

/*struct GetPreviousChat: Codable {
    
    enum CodingKeys: String, CodingKey {
        case video
        case timeMilliSeconds
        case secretKey
        case sentBy
        case type
        case image
        case audio
        case base64Thumbnail
        case msgId
        case viewBy
        case isRead
        case thumbnail
        case sentAt
        case document
        case readBy
        case message
        case isPrevious
        case name
        case fileName
        
        case replyUser
        case replyMsg
        case replyMsgId
        case replyUserId
        case replyMsgType
    }
    
    var video: String?
    var timeMilliSeconds: TimeMilliSeconds?
    var secretKey: String?
    var sentBy: String?
    var type: String?
    var image: String?
    var audio: String?
    var base64Thumbnail: String?
    var msgId: String?
    var viewBy: [String]?
    var isRead: Bool?
    var thumbnail: String?
    var sentAt: SentAt?
    var document: String?
    var readBy: String?
    var message: String?
    
    var isPrevious: Bool? = true
    var name: String?
    var fileName: String?
    var contentType: String?
    
    var replyUser: String?
    var replyMsg: String?
    var replyMsgId: String?
    var replyUserId: String?
    var replyMsgType: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        video = try container.decodeIfPresent(String.self, forKey: .video)
        timeMilliSeconds = try container.decodeIfPresent(TimeMilliSeconds.self, forKey: .timeMilliSeconds)
        secretKey = try container.decodeIfPresent(String.self, forKey: .secretKey)
        sentBy = try container.decodeIfPresent(String.self, forKey: .sentBy)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        audio = try container.decodeIfPresent(String.self, forKey: .audio)
        base64Thumbnail = try container.decodeIfPresent(String.self, forKey: .base64Thumbnail)
        msgId = try container.decodeIfPresent(String.self, forKey: .msgId)
        viewBy = try container.decodeIfPresent([String].self, forKey: .viewBy)
        isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        sentAt = try container.decodeIfPresent(SentAt.self, forKey: .sentAt)
        document = try container.decodeIfPresent(String.self, forKey: .document)
        readBy = try container.decodeIfPresent(String.self, forKey: .readBy)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        isPrevious = try container.decodeIfPresent(Bool.self, forKey: .isPrevious)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        
        replyUser = try container.decodeIfPresent(String.self, forKey: .replyUser)
        replyMsg = try container.decodeIfPresent(String.self, forKey: .replyMsg)
        replyMsgId = try container.decodeIfPresent(String.self, forKey: .replyMsgId)
        replyUserId = try container.decodeIfPresent(String.self, forKey: .replyUserId)
        replyMsgType = try container.decodeIfPresent(String.self, forKey: .replyMsgType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(timeMilliSeconds, forKey: .timeMilliSeconds)
        try container.encodeIfPresent(secretKey, forKey: .secretKey)
        try container.encodeIfPresent(sentBy, forKey: .sentBy)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(audio, forKey: .audio)
        try container.encodeIfPresent(base64Thumbnail, forKey: .base64Thumbnail)
        try container.encodeIfPresent(msgId, forKey: .msgId)
        try container.encodeIfPresent(viewBy, forKey: .viewBy)
        try container.encodeIfPresent(isRead, forKey: .isRead)
        try container.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(sentAt, forKey: .sentAt)
        try container.encodeIfPresent(document, forKey: .document)
        try container.encodeIfPresent(readBy, forKey: .readBy)
        try container.encodeIfPresent(message, forKey: .message)
        
        try container.encodeIfPresent(isPrevious, forKey: .isPrevious)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(fileName, forKey: .fileName)
        
        try container.encodeIfPresent(replyUser, forKey: .replyUser)
        try container.encodeIfPresent(replyMsg, forKey: .replyMsg)
        try container.encodeIfPresent(replyMsgId, forKey: .replyMsgId)
        try container.encodeIfPresent(replyUserId, forKey: .replyUserId)
        try container.encodeIfPresent(replyMsgType, forKey: .replyMsgType)
    }
}   ///  */

struct GetPreviousChat: Codable {
    var video: String?
    var timeMilliSeconds: TimeMilliSeconds?
    var secretKey: String?
    var sentBy: String?
    var type: String?
    var image: String?
    var audio: String?
    var base64Thumbnail: String?
    var msgId: String?
    var viewBy: [String]?
    var isRead: Bool?
    var thumbnail: String?
    var sentAt: SentAt?
    var document: String?
    var readBy: String?
    var message: String?
    
    var isPrevious: Bool? = true
    var name: String?
    var fileName: String?
    var contentType: String?
    
    var replyUser: String?
    var replyMsg: String?
    var replyMsgId: String?
    var replyUserId: String?
    var replyMsgType: String?
    
}
