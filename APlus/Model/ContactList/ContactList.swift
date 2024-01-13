//
//  ContactList.swift
//
//  Created by  on 10/08/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct ContactList: Codable
{
    enum CodingKeys: String, CodingKey {
        case isSuccess
        case list
        case count
    }
    
    var isSuccess: Bool?
    var list: [List]?
    var count: Int?
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSuccess = try container.decodeIfPresent(Bool.self, forKey: .isSuccess)
        list = try container.decodeIfPresent([List].self, forKey: .list)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(isSuccess, forKey: .isSuccess)
        try container.encodeIfPresent(list, forKey: .list)
        try container.encodeIfPresent(count, forKey: .count)
    }
}

// MARK: - CreateGroup

struct CreateGroupRes: Codable
{
    var groupId: String?
    var success: Bool?
}
