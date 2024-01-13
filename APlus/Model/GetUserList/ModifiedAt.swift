//
//  ModifiedAt.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

struct ModifiedAt: Codable
{
    enum CodingKeys: String, CodingKey {
        case seconds
        case nanoseconds
    }
    
    var seconds: Int?
    var nanoseconds: Int?
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seconds = try container.decodeIfPresent(Int.self, forKey: .seconds)
        nanoseconds = try container.decodeIfPresent(Int.self, forKey: .nanoseconds)
    }
}
