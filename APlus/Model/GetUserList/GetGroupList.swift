//
//  GetUserList.swift
//
//  Created by MAcBook on 06/07/22
//  Copyright (c) . All rights reserved.
//

import Foundation

// MARK: - GetGroupList
struct GetGroupList: Codable {
    var imagePath: String?
    var groupName: String?
    var latestTime: LatestTime?
    var unreadCount: Int?
    var msgType: String?
    var recentMsg: String?
    var isGroup: Bool?
    var groupId: String?
    var opponentUserId: String?
}

// MARK: - LatestTime
struct LatestTime: Codable {
    var seconds: Int?
    var nanoseconds: Int?
}
//typealias GetGroupList = [GetGroupListElement]
