//
//  RecentMessage.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RecentMessage: Codable {
    
    enum CodingKeys: String, CodingKey {
        case msgId
        case type
        case isRead
        case sentBy
        case message
        case readBy
        case timeMilliSeconds
        case viewBy
        case sentAt
        case image
    }
    
    var msgId: String?
    var type: String?
    var isRead: Bool?
    var sentBy: String?
    var message: String?
    var readBy: String?
    var timeMilliSeconds: TimeMilliSeconds?
    var viewBy: [String]?
    var sentAt: SentAt?
    var image: String?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msgId = try container.decodeIfPresent(String.self, forKey: .msgId)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead)
        sentBy = try container.decodeIfPresent(String.self, forKey: .sentBy)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        readBy = try container.decodeIfPresent(String.self, forKey: .readBy)
        timeMilliSeconds = try container.decodeIfPresent(TimeMilliSeconds.self, forKey: .timeMilliSeconds)
        viewBy = try container.decodeIfPresent([String].self, forKey: .viewBy)
        sentAt = try container.decodeIfPresent(SentAt.self, forKey: .sentAt)
        image = try container.decodeIfPresent(String.self, forKey: .image)
    }
    
}
