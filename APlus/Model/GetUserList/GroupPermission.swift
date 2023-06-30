//
//  GroupPermission.swift
//
//  Created by  on 24/01/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct GroupPermission: Codable {
    
    enum CodingKeys: String, CodingKey {
        case permission
        case userId
    }
    
    var permission: Permission?
    var userId: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        permission = try container.decodeIfPresent(Permission.self, forKey: .permission)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
    }
}
