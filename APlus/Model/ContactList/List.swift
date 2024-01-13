//
//  List.swift
//
//  Created by  on 10/08/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct List: Codable
{
    enum CodingKeys: String, CodingKey {
        case userId
        case serverUserId
        case profilePicture
        case name
        case mobile_email
        case groups
    }
    
    var userId: String?
    var serverUserId: String?
    var profilePicture: String?
    var name: String?
    var mobile_email: String?
    var groups: [String]?
    var isSelected: Bool? = false
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        serverUserId = try container.decodeIfPresent(String.self, forKey: .serverUserId)
        profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        mobile_email = try container.decodeIfPresent(String.self, forKey: .mobile_email)
        groups = try container.decodeIfPresent([String].self, forKey: .groups)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(serverUserId, forKey: .serverUserId)
        try container.encodeIfPresent(profilePicture, forKey: .profilePicture)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(mobile_email, forKey: .mobile_email)
        try container.encodeIfPresent(groups, forKey: .groups)
    }
}
