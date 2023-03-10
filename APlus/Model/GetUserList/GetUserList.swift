//
//  GetUserList.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct GetUserList: Codable {
    
    enum CodingKeys: String, CodingKey {
        case createAt
        case users
        case members
        case viewBy
        case modifiedBy
        case groupImage
        case blockUsers
        case online
        case name
        case recentMessage
        case createdBy
        case isDeactivateUser
        case groupId
        case lastUpdatedAt
        case isGroup
        case secretKey
        case pinnedGroup
        case readCount
        case modifiedAt
        case typing
        case groupPermission
    }
    
    var createAt: CreateAt?
    var users: [Users]?
    var members: [String]?
    var viewBy: [String]?
    var modifiedBy: String?
    var groupImage: String?
    var blockUsers: [String]?
    var online: [String]?
    var name: String?
    var recentMessage: RecentMessage?
    var createdBy: String?
    var isDeactivateUser: Bool?
    var groupId: String?
    var lastUpdatedAt: LastUpdatedAt?
    var isGroup: Bool?
    var secretKey: String?
    var pinnedGroup: [String]?
    var readCount: [ReadCount]?
    var modifiedAt: ModifiedAt?
    var typing: [String]?
    var groupPermission: [GroupPermission]?
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createAt = try container.decodeIfPresent(CreateAt.self, forKey: .createAt)
        users = try container.decodeIfPresent([Users].self, forKey: .users)
        members = try container.decodeIfPresent([String].self, forKey: .members)
        viewBy = try container.decodeIfPresent([String].self, forKey: .viewBy)
        modifiedBy = try container.decodeIfPresent(String.self, forKey: .modifiedBy)
        groupImage = try container.decodeIfPresent(String.self, forKey: .groupImage)
        blockUsers = try container.decodeIfPresent([String].self, forKey: .blockUsers)
        online = try container.decodeIfPresent([String].self, forKey: .online)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        recentMessage = try container.decodeIfPresent(RecentMessage.self, forKey: .recentMessage)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        isDeactivateUser = try container.decodeIfPresent(Bool.self, forKey: .isDeactivateUser)
        groupId = try container.decodeIfPresent(String.self, forKey: .groupId)
        lastUpdatedAt = try container.decodeIfPresent(LastUpdatedAt.self, forKey: .lastUpdatedAt)
        isGroup = try container.decodeIfPresent(Bool.self, forKey: .isGroup)
        secretKey = try container.decodeIfPresent(String.self, forKey: .secretKey)
        pinnedGroup = try container.decodeIfPresent([String].self, forKey: .pinnedGroup)
        readCount = try container.decodeIfPresent([ReadCount].self, forKey: .readCount)
        modifiedAt = try container.decodeIfPresent(ModifiedAt.self, forKey: .modifiedAt)
        typing = try container.decodeIfPresent([String].self, forKey: .typing)
        groupPermission = try container.decodeIfPresent([GroupPermission].self, forKey: .groupPermission)
    }
    
    /*func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(createAt, forKey: .createAt)
        try container.encodeIfPresent(users, forKey: .users)
        try container.encodeIfPresent(members, forKey: .members)
        try container.encodeIfPresent(viewBy, forKey: .viewBy)
        try container.encodeIfPresent(modifiedBy, forKey: .modifiedBy)
        try container.encodeIfPresent(groupImage, forKey: .groupImage)
        try container.encodeIfPresent(blockUsers, forKey: .blockUsers)
        try container.encodeIfPresent(online, forKey: .online)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(recentMessage, forKey: .recentMessage)
        try container.encodeIfPresent(createdBy, forKey: .createdBy)
        try container.encodeIfPresent(isDeactivateUser, forKey: .isDeactivateUser)
        try container.encodeIfPresent(groupId, forKey: .groupId)
        try container.encodeIfPresent(lastUpdatedAt, forKey: .lastUpdatedAt)
        try container.encodeIfPresent(isGroup, forKey: .isGroup)
        try container.encodeIfPresent(secretKey, forKey: .secretKey)
        try container.encodeIfPresent(pinnedGroup, forKey: .pinnedGroup)
        try container.encodeIfPresent(readCount, forKey: .readCount)
        try container.encodeIfPresent(modifiedAt, forKey: .modifiedAt)
        try container.encodeIfPresent(typing, forKey: .typing)
    }   //  */
}
