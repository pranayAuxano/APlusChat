//
//  SocketChatManager.swift
//  agsChat
//
//  Created by MAcBook on 10/06/22.
//

import Foundation
import SocketIO
import Starscream
import UIKit

protocol SocketDelegate {
    func msgReceived(message : ReceiveMessage)
    func getRecentUser(message : String)
    func recentChatUserList(userList : [GetUserList])
    func getPreviousChatMsg(message : String)
    func getUnreadChat(noOfChat: Int)
}

/*extension SocketDelegate {
    func getUnreadChat(noOfChat: Int) {}
}   /// */

public class SocketChatManager {
    
    // MARK: - Properties
    //public var secretKey : String = "U2FsdGVkX18AsTXTniJJwZ9KaiRWQki0Gike3TN%2BQyXws0hyLIdcRN4abTk84a7r"  //-   old
    //public var secretKey : String = "U2FsdGVkX192tCACGjzd4CmNdA3zxj2OEy%2BHEvcLvaFDjpCyLnhjGDV9tt%2Fx2exZ"  //-   new
    public var secretKey : String = "U2FsdGVkX1%2BdKnWn5ngCut4b2pG%2FM2H8%2FdDTxTKWzmz%2FFgcSYyKoeHp83UBOkxYL"    //- GE
    
    //var myUserId : String = ""          //  Pranay
    //var myUserId : String = ""          //  Malay
    //var myUserId : String = ""          //  Kishan D
    
//    var myUserId : String = "63f4adc7574b0212cfd5029b"          //  Demo 001 GE   -   GE
//    var myUserId : String = "63f4adc6574b0212cfd50294"          //  Demo GE   -   GE
    var myUserId : String = "63f4ada8574b0212cfd501de"          //  Test Data   -   GE
    
    
    var myUserName : String = ""
    
    public static let sharedInstance = SocketChatManager()
    public var manager : SocketManager?
    public var socket : SocketIOClient?
    var socketDelegate : SocketDelegate?
    //var serverURL : String = "http://14.99.147.156:5000"  //  Live Test server
    var serverURL : String = "http://3.139.188.226:5000"  //  Live Production server
    //var serverURL : String = "http://192.168.1.94:5000"   //  Local server
    //var serverURL : String = "http://192.168.1.69:5000"   //  Local server
    //var serverURL : String = "https://e20e-14-99-145-222.in.ngrok.io"   //  Local server Vedand
    
    //closer
    var viewController: (()->FirstVC)?
    var userChatVC: (()->ChatVC)?
    var profileDetailVC: (()->ProfDetailVC)?
    var contectInfoVC: (()->ContactInfoVC)?
    var createGroupVC: (()->CreateGrpVC)?
    var contactListVC: (()->ContListVC)?
    var groupContactVC: (()->GroupContVC)?
    
    var userRole: UserRole?
    
    fileprivate var socketHandlerArr = [((()->Void))]()
    typealias ObjBlock = @convention(block) () -> ()
    
    
    // MARK: - Life Cycle
    init() {
        initializeSocket()
        socket?.connect()
        setupSocketEvents()
    }
    
    func stop() {
        socket?.removeAllHandlers()
    }
    
    // MARK: - Socket Setup
    func initializeSocket() {
        manager = SocketManager(socketURL: URL(string: serverURL)!, config: [.log(true), .compress, .reconnects(true), .reconnectWait(10)])
        self.socket = manager?.defaultSocket
    }
    
    func establishConnection() {
        if !(Network.reachability.isReachable) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.establishConnection()
            }
            return
        } else {
            socket?.connect()
        }
    }
    
    func connectSocket(handler:(()->Void)? = nil) {
        if socket == nil {
            self.initializeSocket()
        }
        if self.socket?.status != .connected {
            handler?()
            return
        } else {
            if let handlr = handler {
                if self.socketHandlerArr.contains(where: { (handle) -> Bool in
                    let obj1 = unsafeBitCast(handle as ObjBlock, to: AnyObject.self)
                    let obj2 = unsafeBitCast(handlr as ObjBlock, to: AnyObject.self)
                    return obj1 === obj2
                }) {
                    self.socketHandlerArr.append(handlr)
                }
            }
            
            if self.socket?.status != .connecting {
                self.socket?.connect()
            }
        }
    }
    
    func closeConnection() {
        socket?.disconnect()
    }
    
    func stringArrayToData(stringArray: [Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
    }
    func dataToStringArray(data: Data) -> [Any]? {
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String]
    }
    
    func setupSocketEvents() {
        
        socket?.on(clientEvent: .connect){ (data,ack) in
            print("Hey Socket Connected")
            self.socketDelegate?.getRecentUser(message: "Socket Connected.")
        }
        socket?.on(clientEvent: .disconnect){ (data,ack) in
            print("Socket Disconnect")
        }
        socket?.on(clientEvent: .reconnect){ (data,ack) in
            print("Event: Trying to reconnect \(data)")
        }
        socket?.on(clientEvent: .ping){ (data,ack) in
            print("Event: Socket pinged\(data)")
        }
        socket?.on(clientEvent: .error){ (data,ack) in
            print("Event: Error, ERROR Occured \(data)")
        }
        socket?.on(clientEvent: .reconnectAttempt){ (data,ack) in
            print("Event: Reconnection Attempt Occured \(data)")
        }
        socket?.on(clientEvent: .pong){ (data,ack) in
            print("Event: Socket ponged\(data)")
        }
    }
    
    // MARK: - Get previous, current chat message and leave chat
    
    func getGroupList(event : String) {
        socket?.on("group-list", callback: { (data, ack) in
            print("group-list - \(data)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            do {
                let recentUserList = try JSONDecoder().decode([GetUserList].self, from: responseData)
                print(recentUserList)
                self.socket?.off("get-groups")
                self.socketDelegate?.recentChatUserList(userList: recentUserList)
            } catch let err {
                print(err)
            }
        })
    }
    
    func getGroupDetail(event : String) {
        socket?.on(event, callback: { (data, ack) in
            print("Group Detail - \(data)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            do {
                let groupDetail = try JSONDecoder().decode(GetUserList.self, from: responseData)
                self.socket?.off("get-group")
                self.socket?.off("get-group-res")
                self.userChatVC!().getGroupDetail(groupDetail: groupDetail)
            } catch let err {
                print(err)
            }
        })
    }
    
    func getPreviousChatMsg(event : String) {
        socket?.on("get-previous-chat", callback: { (data, ack) in
            print("Previous chat message - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            do {
                let previousChat = try! JSONDecoder().decode([GetPreviousChat].self, from: responseData)
                self.socket?.off("get-chat")
                self.socket?.off("get-previous-chat")
                self.userChatVC!().getPreviousChat(chat: previousChat)
            } catch let err {
                print(err)
            }
        })
    }
    
    func getCurrentChatMsg(event : String) {
        socket?.on("receive-message", callback: { (data, ack) in
            print("Received message - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : ReceiveMessage = try! JSONDecoder().decode(ReceiveMessage.self, from: responseData)
            self.socketDelegate?.msgReceived(message: receiveMessage)
        })
    }
    
    func getProfileDetails(from isProfile : Bool) {
        socket?.on("profile-res", callback: { (data, ack) in
            print("profile-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : ProfileDetail = try! JSONDecoder().decode(ProfileDetail.self, from: responseData)
            self.socket?.off("get-profile")
            self.socket?.off("profile-res")
            if isProfile {
                //self.profileDetailVC!().getProfileDetail(receiveMessage)
            } else {
                self.viewController!().getProfileDetail(receiveMessage)
            }
        })
    }
    
    func profileUpdated() {
        socket?.on("update-profile-res", callback: { (data, ack) in
            print("update-profile-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("update-profile")
            self.socket?.off("update-profile-res")
            self.profileDetailVC!().profileUpdate(receiveMessage.isSuccess!)
        })
    }
    
    func unreadCountZeroRes() {
        socket?.on("unread-count-res", callback: { (data, ack) in
            print("unread-count-res - \((data.first)!)")
            self.socket?.off("unread-count")
            self.socket?.off("unread-count-res")
        })
    }
    
    func createGroupRes(from createGroup : Bool) {
        socket?.on("create-group-res", callback: { (data, ack) in
            print("create-group-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("create-group")
            self.socket?.off("create-group-res")
            if createGroup {
                self.createGroupVC!().responseBack(receiveMessage.isSuccess!)
            } else {
                self.contactListVC!().responseBack(receiveMessage.isSuccess!)
            }
        })
    }
    
    func updateGroupRes() {
        socket?.on("update-group-res", callback: { (data, ack) in
            print("update-group-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("update-group")
            self.socket?.off("update-group-res")
            self.contectInfoVC!().responseBack(receiveMessage.isSuccess!)
        })
    }
    
    func exitGroupRes() {
        socket?.on("exit-group-res", callback: { (data, ack) in
            print("Received message - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("exit-group")
            self.socket?.off("exit-group-res")
            self.contectInfoVC!().responseBack(receiveMessage.isSuccess!)
        })
    }
    
    func deleteGroupRes(from userChat : Bool) {
        socket?.on("delete-group-res", callback: { (data, ack) in
            print("delete-group-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("delete-group")
            self.socket?.off("delete-group-res")
            if userChat {
                self.userChatVC!().responseBack(receiveMessage.isSuccess!)
            } else {
                self.contectInfoVC!().responseBack(receiveMessage.isSuccess!)
            }
        })
    }
    
    func deleteChatRes(from userChat : Bool) {
        socket?.on("delete-chat-res", callback: { (data, ack) in
            print("delete-chat-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("delete-chat")
            self.socket?.off("delete-chat-res")
            if userChat {
                self.userChatVC!().responseBack(receiveMessage.isSuccess!)
            } else {
                self.contectInfoVC!().responseBack(receiveMessage.isSuccess!)
            }
        })
    }
    
    func clearChatRes() {
        socket?.on("clear-chat-res", callback: { (data, ack) in
            print("clear-chat-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("clear-chat")
            self.socket?.off("clear-chat-res")
            self.userChatVC!().responseBack(receiveMessage.isSuccess!)
        })
    }
    
    func userListRes(from userChat : Bool) {
        socket?.on("user-list-res", callback: { (data, ack) in
            print("user-list-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : ContactList = try! JSONDecoder().decode(ContactList.self, from: responseData)
            self.socket?.off("user-list")
            self.socket?.off("user-list-res")
            if userChat {
                self.contactListVC!().getUserListRes(receiveMessage)
            } else {
                self.groupContactVC!().getUserListRes(receiveMessage)
            }
        })
    }
    
    func addMemberRes() {
        socket?.on("add-member-res", callback: { (data, ack) in
            print("add-member-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("add-member")
            self.socket?.off("add-member-res")
            self.groupContactVC!().addMemberRes(receiveMessage.isSuccess!)
        })
    }
    
    func removeMemberRes() {
        socket?.on("remove-member-res", callback: { (data, ack) in
            print("remove-member-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("remove-member")
            self.socket?.off("remove-member-res")
            self.contectInfoVC!().removeMemberRes(receiveMessage.isSuccess!)
        })
    }
    
    func leaveChat(roomid : String) {
        self.socket?.off("receive-message")
        self.socket?.off("join")
        socket?.emit("leave", roomid, completion: {
            print((self.socket?.status)!)
        })
    }
    
    func typingRes() {
        socket?.on("typing-res", callback: { (data, ack) in
            print("typing-res - \((data.first)!)")
            print("Hello get response.")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            let receiveMessage : TypingResponse = try! JSONDecoder().decode(TypingResponse.self, from: responseData)
            self.userChatVC!().getTypingResponse(typingResponse: receiveMessage)
        })
    }
    
    func getOnlineRes(event : String) {
        socket?.on(event, callback: { (data, ack) in
            print("Received message - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            print(responseData)
            let onlineStatus : OnlineStatus = try! JSONDecoder().decode(OnlineStatus.self, from: responseData)
            self.socket?.off("online")
            self.userChatVC!().getOnlineStatus(onlineStatus: onlineStatus)
        })
    }
    
    func getUserRoleRes(event : String) {
        socket?.on(event, callback: { (data, ack) in
            print("user-role-res - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            self.userRole = try! JSONDecoder().decode(UserRole.self, from: responseData)
            self.socket?.off("user-role")
            self.socket?.off("user-role-res")
            //self.viewController!().getUserRole(userRole: self.userRole!)
            self.viewController!().getUserRole()
        })
    }
    
    func joinChatReferRes(event : String) {
        socket?.on(event, callback: { (data, ack) in
            print("get-groups-call - \((data.first)!)")
            guard let responseData = try? JSONSerialization.data(withJSONObject: data[0], options: []) else { return }
            print(responseData)
            let receiveMessage : reqResponse = try! JSONDecoder().decode(reqResponse.self, from: responseData)
            self.socket?.off("join")
            //self.socket?.off("get-groups-call")
            self.viewController!().getNewChatMsg(isNew: receiveMessage.isUpdate ?? false)
        })
    }
    
    public func getUnreadChatRes(event : String) {
        socket?.on(event, callback: { (data, ack) in
            print("get-groups-call - \((data.first)!)")
            self.socketDelegate?.getUnreadChat(noOfChat: data.first as! Int)
        })
    }
    
    // MARK: -
    
    // MARK: - Socket Emits
    
    public func socketLogin(userId: String, secretKey: String) {
        if secretKey != "" && userId != "" {
            print("User Id: \(userId)")
            print("secretKey : \(secretKey)")
            self.myUserId = userId
            self.secretKey = secretKey
            //SocketChatManager.sharedInstance.online(param: ["userId": myUserId, "secretKey": secretKey])
            //SocketChatManager.sharedInstance.getUserRole(param: ["secretKey": secretKey, "userId": myUserId])
        } else {
            print("User Id & secretKey : Not available while call function...")
        }
    }
    
    public func socketSignUp() {
        print("Signup Function Call")
    }
    
    public func socketLogOut(userId: String, secretKey: String) {
        print("Logout Function Call")
    }
    
    func joinChatRefer(param: String) {
        socket?.emit("join", param)
        socket?.off("join")
        self.joinChatReferRes(event: "get-groups-call")
    }
    
    func joinGroup(param: String) {
        socket?.emit("join", param)
    }
    
    func reqRecentChatList(param: [String : String]) {
        socket?.emit("get-groups", param)
        socket?.off("get-groups")
        self.getGroupList(event: "group-list")
    }
    
    func reqPreviousChatMsg(param: [String : String]) {
        if Network.reachability.isReachable {
            socket?.emit("get-chat", param)
            self.getPreviousChatMsg(event: "get-previous-chat")
            self.getCurrentChatMsg(event: "receive-message")
        }
    }
    
    func unreadCountZero(param: [String : String]) {
        if Network.reachability.isReachable {
            socket?.emit("unread-count", param)
            self.unreadCountZeroRes()
        }
    }
    
    func reqProfileDetails(param : [String : Any], from isProfile : Bool) {
        //["userId" : ""]
        //User's profiles
        if Network.reachability.isReachable {
            socket?.emit("get-profile", param)
            self.socket?.off("get-profile")
            self.getProfileDetails(from: isProfile)
        }
    }
    
    func reqGroupDetail(param: [String : String]) {
        socket?.emit("get-group", param)
        socket?.off("get-group")
        self.getGroupDetail(event: "get-group-res")
    }
    
    func updateProfile(param : [String : Any]) {
        //update-profile = userId, name, profilePicture
        //["userId" : "" , "name": "" , "profilePicture" : "" ]
        if Network.reachability.isReachable {
            socket?.emit("update-profile", param)
            socket?.off("update-profile")
            self.profileUpdated()
        }
    }
    
    func createGroup(param : [String : Any], from createGroup : Bool) {
        //request body (groupId, userId)
        if Network.reachability.isReachable {
            socket?.emit("create-group", param)
            self.createGroupRes(from: createGroup)
        }
    }
    
    func updateGroup(param : [String : Any]) {
        //request body (groupId, userId)
        if Network.reachability.isReachable {
            socket?.emit("update-group", param)
            self.updateGroupRes()
        }
    }
    
    func exitGroup(param : [String : Any]) {
        //request body (groupId, userId)
        if Network.reachability.isReachable {
            socket?.emit("exit-group", param)
            self.exitGroupRes()
        }
    }
    
    func deleteGroup(param : [String : Any], from userChat : Bool) {
        //request body (groupId, userId)
        if Network.reachability.isReachable {
            socket?.emit("delete-group", param)
            self.deleteGroupRes(from: userChat)
        }
    }
    
    func deleteChat(param : [String : Any], from userChat : Bool) {
        //request body (groupId, userId)
        if Network.reachability.isReachable {
            socket?.emit("delete-chat", param)
            self.deleteChatRes(from: userChat)
        }
    }
    
    func clearChat(param : [String : Any]) {
        //request body (groupId, userId)
        if Network.reachability.isReachable {
            socket?.emit("clear-chat", param)
            self.clearChatRes()
        }
    }
    
    func getUserList(param : [String : Any], from userList : Bool) {
        //request body (userId, secretKey)
        if Network.reachability.isReachable {
            socket?.emit("user-list", param)
            self.userListRes(from: userList)
        }
    }
    
    func addMember(param : [String : Any]) {
        //request body (userId, secretKey)
        if Network.reachability.isReachable {
            socket?.emit("add-member", param)
            self.addMemberRes()
        }
    }
    
    func removeMember(param : [String : Any]) {
        //request body (userId, secretKey)
        if Network.reachability.isReachable {
            socket?.emit("remove-member", param)
            self.removeMemberRes()
        }
    }
    
    func sendMsg(message: [String : Any]) {
        //["msg": , "rid": , "type" : , "name" : ]
        if Network.reachability.isReachable {
            socket?.emit("send-message", message)
        }
    }
    
    func userTyping(message: [String : Any]) {
        if Network.reachability.isReachable {
            socket?.emit("typing", message)
            socket?.off("typing")
        }
    }
    
    func online(param: [String : Any]) {
        if Network.reachability.isReachable {
            socket?.emit("online", param)
            socket?.off("online")
            //self.getOnlineRes(event: "online-status")
        }
    }
    
    func getUserRole(param: [String : Any]) {
        if Network.reachability.isReachable {
            socket?.emit("user-role", param)
            socket?.off("user-role")
            self.getUserRoleRes(event: "user-role-res")
        }
    }
    
    public func getUnreadChat(event: String, param: [String : Any]) {
        //user-unread-count
        if Network.reachability.isReachable {
            socket?.emit(event, param)
            socket?.off(event)
            self.getUnreadChatRes(event: "user-unread-count-res")
        }
    }
    
    func connectToServerWithNickname(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket?.emit("connectUser", "abc")
        
        socket?.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
    }   //  */
}
