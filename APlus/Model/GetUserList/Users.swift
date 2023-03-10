//
//  Users.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct Users: Codable {
    
    enum CodingKeys: String, CodingKey {
        case serverUserId
        case userId
        case groups
        case profilePicture // = "profile_picture"
        case name
        case mobileEmail = "mobile_email"
    }
    
    var serverUserId: String?
    var profilePicture: String?
    var userId: String?
    var groups: [String]?
    var name: String?
    var mobileEmail: String?
    
    /*init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        serverUserId = try container.decodeIfPresent(String.self, forKey: .serverUserId)
        profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        groups = try container.decodeIfPresent([String].self, forKey: .groups)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        mobileEmail = try container.decodeIfPresent(String.self, forKey: .mobileEmail)
    }   //  */
    
}
