//
//  ChatModel.swift
//  agsChat
//
//  Created by MAcBook on 10/06/22.
//

import Foundation

struct ReceiveMessage: Codable {
    var msg : String?
    var thumbnail : String?
    var sentBy : String?
    var rid : String?
    var type : String?
    var name : String?
    var image : String?
    var document : String?
    var audio : String?
    var video : String?
    
    var fileName : String?
    var msgId : String?
    
    var replyUser: String?
    var replyMsg: String?
    var replyMsgId: String?
    var replyUserId: String?
    var replyMsgType: String?
}

struct ProfileDetail: Codable {
    var mobileEmail: String?
    var name: String?
    var profilePicture: String?
    var userID: String?
    
    enum CodingKeys: String, CodingKey {
        case mobileEmail = "mobile_email"
        case name
        case profilePicture
        case userID = "userId"
    }
}

struct reqResponse: Codable {
    var isSuccess: Bool?
    var msg: String?
    var isUpdate: Bool?
}

struct UnreadCount {
    var unreadCount: Int
    var userId:String
}

// MARK: - TypingResponse
struct TypingResponse: Codable {
    var groupId: String?
    var isTyping: String?
    var name: String?
    var secretKey: String?
    var userId: String?
}

// MARK: - UserRole
struct UserRole: Codable {
    var createGroup: Int?
    var createOneToOneChat: Int?
    var deleteMessage: Int?
    var editMessage: Int?
    var sendMessage: Int?
    var updateProfile: Int?
    var deleteChat: Int?
    var clearChat: Int?
}

// MARK: - OnlineStaus
struct OnlineStatus: Codable {
    let isOnline: Bool?
    let userId: String?
}
