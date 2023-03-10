//
//  ReadCount.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct ReadCount: Codable {
    
    enum CodingKeys: String, CodingKey {
        case unreadCount
        case userId
    }
    
    var unreadCount: Int?
    var userId: String?
    
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
    }
    
}
