//
//  CreateAt.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct CreateAt: Codable {
    
    enum CodingKeys: String, CodingKey {
        case nanoseconds
        case seconds
    }
    
    var nanoseconds: Int?
    var seconds: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nanoseconds = try container.decodeIfPresent(Int.self, forKey: .nanoseconds)
        seconds = try container.decodeIfPresent(Int.self, forKey: .seconds)
    }
    
}
