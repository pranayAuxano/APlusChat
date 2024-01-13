//
//  Permission.swift
//
//  Created by  on 24/01/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Permission: Codable
{
    enum CodingKeys: String, CodingKey {
        case addProfilePicture
        case deleteChat
        case addMember
        case changeGroupName
        case exitGroup
        case deleteMessage
        case removeMember
        case sendMessage
        case clearChat
    }
    
    var addProfilePicture: Int?
    var deleteChat: Int?
    var addMember: Int?
    var changeGroupName: Int?
    var exitGroup: Int?
    var deleteMessage: Int?
    var removeMember: Int?
    var sendMessage: Int?
    var clearChat: Int?
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        addProfilePicture = try container.decodeIfPresent(Int.self, forKey: .addProfilePicture)
        deleteChat = try container.decodeIfPresent(Int.self, forKey: .deleteChat)
        addMember = try container.decodeIfPresent(Int.self, forKey: .addMember)
        changeGroupName = try container.decodeIfPresent(Int.self, forKey: .changeGroupName)
        exitGroup = try container.decodeIfPresent(Int.self, forKey: .exitGroup)
        deleteMessage = try container.decodeIfPresent(Int.self, forKey: .deleteMessage)
        removeMember = try container.decodeIfPresent(Int.self, forKey: .removeMember)
        sendMessage = try container.decodeIfPresent(Int.self, forKey: .sendMessage)
        clearChat = try container.decodeIfPresent(Int.self, forKey: .clearChat)
    }
}
