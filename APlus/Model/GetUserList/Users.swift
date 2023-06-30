//
//  Users.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

// MARK: - User
struct User: Codable {
    var name: String?
    var profilePicture: String?
    var mobileEmail: String?
    var userId: String?

    enum CodingKeys: String, CodingKey {
        case name
        case profilePicture
        case mobileEmail = "mobile_email"
        case userId
    }
}
