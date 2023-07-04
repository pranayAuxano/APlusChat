//
//  ChatVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import AVKit
import MobileCoreServices

public class ChatVC: UIViewController {

    @IBOutlet weak var viewMainChat: UIView!
    @IBOutlet weak var viewBackUserName: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewUserInfo: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnUserInfo: UIButton!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var viewTypeMsg: UIView!
    @IBOutlet weak var txtTypeMsg: UITextField!
    @IBOutlet weak var btnAttach: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var viewChat: UIView!
    @IBOutlet weak var imgChatBackground: UIImageView!
    @IBOutlet weak var constMainChatViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tblUserChat: UITableView!
    @IBOutlet weak var lblOnline: UILabel!
    @IBOutlet weak var constViewTypeMsgHeight: NSLayoutConstraint!
    @IBOutlet weak var constViewUserDetailHeight: NSLayoutConstraint!

    @IBOutlet weak var viewMainReply: UIView!
    @IBOutlet weak var viewReply: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblReplySidebar: UILabel!
    @IBOutlet weak var lblReplyUser: UILabel!
    @IBOutlet weak var lblReplyMsg: UILabel!
    @IBOutlet weak var imgReplyImage: UIImageView!
    @IBOutlet weak var constTblBottom: NSLayoutConstraint!
    @IBOutlet weak var imgVideo: UIImageView!
    @IBOutlet weak var constViewMainReplyHeight: NSLayoutConstraint!
    
    var strDisName : String?
    var strProfileImg : String? = ""
    var isNetworkAvailable : Bool = false
    var isKeyboardActive : Bool = false
    var imagePicker = UIImagePickerController()
    var arrImageExtension : [String] = ["jpg", "png", "jpeg", "gif", "svg"]
    var arrDocExtension : [String] = ["doc", "docx", "xls", "xlsx", "pdf", "rtf", "txt", ""]
    var arrAudioExtension : [String] = ["mp3", "aac", "wav", "ogg", "m4a"]
    var arrVideoExtension : [String] = ["mp4", "avi", "mov", "3gp", "3gpp", "mpg", "mpeg", "webm", "flv", "m4v", "wmv", "asx", "asf"]
    var isCameraClick : Bool = false
    
    public var groupId : String = ""    //  roomId
    
    var arrGetPreviousChat : [Message]? = []
    var arrGetPreChatMsg : [Message]? = []
    var arrDtForSection : [String]? = []
    var arrSectionMsg : [[Message]]? = [[]]
    var isReceiveMsgOn : Bool = false
    public var isGroup : Bool = false
    var isClear : Bool = false
    
    var imgFileName : String = ""
    var isDocumentPickerOpen : Bool = false
    var isTyping : Bool = false
    var timer = Timer()
    var timeSeconds = 1
    var onlineUser : String = ""
    
    var swipeReplyMsg: Message?
    var isSwipe: Bool = false
    var imageRequest: Cancellable?
    var isImg: Bool = false
    
    struct AllUser: Codable {
        var userId: String?
        var userName: String?
    }
    var arrUserName : [AllUser]? = []
    public var isHideUserDetailView: Bool = false
    public var isDirectToChat: Bool = false
    var isHasMore: Bool = false
    var isCallPreChatPage: Bool = false
    var startAt: Int = 0
    var groupDetail: GroupData?
    var intScroll: Int? = 0
    var isScroll: Bool = false
    
    var bundle = Bundle()
    
    public init() {
        super.init(nibName: "UserChatVC", bundle: Bundle(for: ChatVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented FirstViewController")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.viewTypeMsg.backgroundColor = .clear
        btnAttach.backgroundColor = .white
        btnAttach.layer.cornerRadius = btnAttach.frame.height / 2
        btnSend.backgroundColor = .white
        btnSend.layer.cornerRadius = btnSend.frame.width / 2
        
        viewMainReply.backgroundColor = .clear
        self.constViewMainReplyHeight.priority = .required
        
        viewReply.clipsToBounds = true
        viewReply.layer.cornerRadius = 7
        btnClose.backgroundColor = .clear
        viewMainReply.isHidden = true
        //lblReplySidebar.clipsToBounds = true
        constTblBottom.priority = .required
        
        btnOption.tintColor = UIColor.black
        self.btnOption.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
        
        self.btnUserInfo.isEnabled = false
        
        bundle = Bundle(for: ChatVC.self)
        lblUserName.text = strDisName
        self.loadProfileImg()
        lblOnline.text = ""
        
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host named:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
        
        if Network.reachability.isReachable {
            isNetworkAvailable = true
        }
        
        if #available(iOS 15.0, *) {
            tblUserChat.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
    
        let bundle = Bundle(for: ChatVC.self)
        NotificationCenter.default.addObserver(self, selector: #selector(checkConnection), name: .flagsChanged, object: nil)
        
        tblUserChat.register(UINib(nibName: "OwnChatBubbleCell", bundle: bundle), forCellReuseIdentifier: "OwnChatBubbleCell")
        tblUserChat.register(UINib(nibName: "OwnImgChatBubbleCell", bundle: bundle), forCellReuseIdentifier: "OwnImgChatBubbleCell")
        tblUserChat.register(UINib(nibName: "OwnFileBubbleCell", bundle: bundle), forCellReuseIdentifier: "OwnFileBubbleCell")
        tblUserChat.register(UINib(nibName: "OwnAudioBubbleCell", bundle: bundle), forCellReuseIdentifier: "OwnAudioBubbleCell")
        tblUserChat.register(UINib(nibName: "OwnReplyTVCell", bundle: bundle), forCellReuseIdentifier: "OwnReplyTVCell")   //  For reply msg.
        
        tblUserChat.register(UINib(nibName: "OtherChatBubbleCell", bundle: bundle), forCellReuseIdentifier: "OtherChatBubbleCell")
        tblUserChat.register(UINib(nibName: "OtherImgChatBubbleCell", bundle: bundle), forCellReuseIdentifier: "OtherImgChatBubbleCell")
        tblUserChat.register(UINib(nibName: "OtherFileBubbleCell", bundle: bundle), forCellReuseIdentifier: "OtherFileBubbleCell")
        tblUserChat.register(UINib(nibName: "OtherAudioBubbleCell", bundle: bundle), forCellReuseIdentifier: "OtherAudioBubbleCell")
        tblUserChat.register(UINib(nibName: "OtherReplyTVCell", bundle: bundle), forCellReuseIdentifier: "OtherReplyTVCell")   //  For reply msg.
        
        if isHideUserDetailView {
            self.viewBackUserName.isHidden = true
            self.constViewUserDetailHeight.constant = 0
        } else {
            self.viewBackUserName.isHidden = false
            self.constViewUserDetailHeight.constant = 55
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        bundle = Bundle(for: ChatVC.self)
        
        self.navigationController?.isNavigationBarHidden = true
        txtTypeMsg.delegate = self
        imgProfilePic.layer.cornerRadius = imgProfilePic.frame.width / 2
        
        if !isDocumentPickerOpen {
            SocketChatManager.sharedInstance.userChatVC = {
                return self
            }
            
            SocketChatManager.sharedInstance.reqPreviousChatMsg(param: [
                "secretKey" : SocketChatManager.sharedInstance.secretKey,
                "groupId" : groupId,
                "userId" : SocketChatManager.sharedInstance.myUserId,
                "startAt": 0
            ] as [String : Any])
            
            if !isGroup {
                SocketChatManager.sharedInstance.getOnlineRes(event: "online-status")
            }
        } else {
            self.isDocumentPickerOpen = false
        }
        
        if #available(iOS 14.0, *) {
            self.loadPopup()
        } else {
            // Fallback on earlier versions
        }
        //Delegate for receive other user message.
        SocketChatManager.sharedInstance.socketDelegate = self
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        if !isDocumentPickerOpen {
            SocketChatManager.sharedInstance.socket?.off("typing-res")
            SocketChatManager.sharedInstance.socket?.off("online-status")
            //SocketChatManager.sharedInstance.leaveChat(roomid: groupId)
            
            SocketChatManager.sharedInstance.leaveChat(param: [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "userId": SocketChatManager.sharedInstance.myUserId,
                "groupId": groupId
            ])
        }
    }
    
    func setData() {
        registerKeyboardNotifications()

        var otherUserId : String = self.groupDetail?.opponentUserId ?? ""
        onlineUser = (self.groupDetail?.onlineStatus ?? false) ? "Online" : ""
        lblOnline.text = onlineUser
        
        viewTypeMsg.isHidden = true
        constViewTypeMsgHeight.constant = 0
        isGroup = self.groupDetail?.isGroup ?? false
        var isSendMsg: Bool = false
        
        if self.isGroup {
            if SocketChatManager.sharedInstance.userGroupRole?.sendMessage ?? 0 == 1 {
                isSendMsg = true
            }
        } else {
            if SocketChatManager.sharedInstance.userRole?.sendMessage ?? 0 == 1 {
                isSendMsg = true
            }
        }
        
        self.lblUserName.text = self.groupDetail?.groupName ?? ""
        self.strProfileImg = self.groupDetail?.imagePath ?? ""
        self.loadProfileImg()
        
        if isSendMsg {
            viewTypeMsg.isHidden = false
            constViewTypeMsgHeight.constant = 55
        }
        
        if #available(iOS 14.0, *) {
            self.loadPopup()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func loadProfileImg() {
        if strProfileImg != "" {
            var imageURL: URL?
            imageURL = URL(string: strProfileImg!)!
            
            // retrieves image if already available in cache
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgProfilePic.image = imageFromCache
                return
            }
            NetworkManager.sharedInstance.getData(from: URL(string: strProfileImg!)!) { data, response, err in
                if err == nil {
                    DispatchQueue.main.async {
                        //self.imgProfilePic.image = UIImage(data: data!)
                        if let imageToCache = UIImage(data: data!) {
                            self.imgProfilePic.image = imageToCache
                            imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                        } else {
                            self.imgProfilePic.image =  UIImage(named: self.isGroup ? "group-placeholder.jpg" : "placeholder-profile-img.png", in: self.bundle, compatibleWith: nil)
                        }
                    }
                }
            }
        } else {
            self.imgProfilePic.image =  UIImage(named: self.isGroup ? "group-placeholder.jpg" : "placeholder-profile-img.png", in: bundle, compatibleWith: nil)
        }
    }
    
    func getPreviousChat(chat : PreviousChat) {
        print(chat)
        self.isHasMore = chat.hasMore!
        
        if startAt == 0 {
            self.groupDetail = chat.groupData
            if self.groupDetail?.userPermission?.userId ?? "" == SocketChatManager.sharedInstance.myUserId {
                SocketChatManager.sharedInstance.userGroupRole = self.groupDetail?.userPermission?.permission
            }
            self.lblUserName.text = self.groupDetail?.groupName ?? ""
            self.btnUserInfo.isEnabled = true
            self.setData()
        }
        if !isCallPreChatPage {
            //Call func for get section.
            self.arrGetPreviousChat = chat.messages!
            self.arrDtForSection?.removeAll()
            self.arrSectionMsg?.removeAll()
            self.getDateMsgforSection()
            //setUserArray()
            DispatchQueue.main.async {
                self.tblUserChat.reloadData()
                if (self.arrDtForSection!.count > 0) && (self.arrSectionMsg!.count > 0) {
                    self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: false)
                }
            }
            SocketChatManager.sharedInstance.typingRes()
        } else {
            self.arrGetPreChatMsg = chat.messages!
            print("Get old chat - \(chat.messages!.count)")
            
            self.getPreDateMsgforSection()
            DispatchQueue.main.async {
                self.tblUserChat.reloadData()
                if (self.arrDtForSection!.count > 0) && (self.arrSectionMsg!.count > 0) {
                    var count: Int = 0
                    var section: Int = 0
                    var row: Int = 0
                    for i in 0 ..< self.arrDtForSection!.count {
                        for j in 0 ..< self.arrSectionMsg![i].count {
                            if count < chat.messages!.count {
                                count += 1
                                section = i
                                row = j
                            } else { break }
                        }
                        if count < chat.messages!.count { } else { break }
                    }
                    self.tblUserChat.scrollToRow(at: IndexPath(row: row, section: section), at: .top, animated: false)
                    //self.tblUserChat.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isCallPreChatPage = false
                    }
                }
            }
        }
    }
    
    func getDateMsgforSection() {
        for i in 0 ..< arrGetPreviousChat!.count {
            let msgDate : String = Utility.convertTimestamptoDateString(timestamp: (self.arrGetPreviousChat?[i].timeMilliSeconds?.seconds)!)
            if (arrDtForSection?.contains(msgDate))! {
                for j in 0 ..< arrDtForSection!.count {
                    if arrDtForSection![j] == msgDate {
                        arrSectionMsg?[j].append((self.arrGetPreviousChat?[i])!)
                    }
                }
            } else {
                arrDtForSection?.append(msgDate)
                var tempMsg : [Message] = []
                tempMsg.append((self.arrGetPreviousChat?[i])!)
                arrSectionMsg?.append(tempMsg)
            }
        }
    }
    
    func getPreDateMsgforSection() {
        arrGetPreChatMsg?.reverse()
        
        for i in 0 ..< self.arrGetPreChatMsg!.count {
            let msgDate : String = Utility.convertTimestamptoDateString(timestamp: (self.arrGetPreChatMsg?[i].timeMilliSeconds?.seconds)!)
            if (arrDtForSection?.contains(msgDate))! {
                for j in 0 ..< arrDtForSection!.count {
                    if arrDtForSection![j] == msgDate {
                        arrSectionMsg?[j].insert((self.arrGetPreChatMsg?[i])!, at: 0)
                    }
                }
            } else {
                arrDtForSection?.insert(msgDate, at: 0)
                var tempMsg : [Message] = []
                tempMsg.append((self.arrGetPreChatMsg?[i])!)
                arrSectionMsg?.insert(tempMsg, at: 0)
            }
        }
    }
    
    func getTypingResponse(typingResponse : TypingResponse) {
        if (typingResponse.groupId == groupId)  {
            if typingResponse.isTyping == "true" {
                onlineUser = self.isGroup ? "\(typingResponse.name ?? "") typing" : "typing..."
            } else if typingResponse.isTyping == "false" {
                onlineUser = self.isGroup ? "" : "Online"
            }
            lblOnline.text = onlineUser
        }
    }
    
    func getOnlineStatus(onlineStatus : OnlineStatus) {
        if self.groupDetail?.opponentUserId ?? "" == onlineStatus.userId ?? "" {
            if onlineStatus.isOnline! {
                onlineUser = "Online"
            } else {
                onlineUser = ""
            }
        }
        lblOnline.text = onlineUser
    }
    
    @objc func checkConnection(_ notification: Notification) {
        updateUserInterface()
    }
    
    func updateUserInterface() {
        switch Network.reachability.isReachable {
        case true:
            if !self.isNetworkAvailable {
                self.isNetworkAvailable = true
                let toastMsg = ToastUtility.Builder(message: "Internet available.", controller: self, keyboardActive: isKeyboardActive)
                toastMsg.setColor(background: .green, text: .black)
                toastMsg.show()
            }
            print("Network connection available.")
            break
        case false:
            if isNetworkAvailable {
                self.isNetworkAvailable = false
                let toastMsg = ToastUtility.Builder(message: "No Internet connection.", controller: self, keyboardActive: isKeyboardActive)
                toastMsg.setColor(background: .red, text: .black)
                toastMsg.show()
            }
            SocketChatManager.sharedInstance.establishConnection()
            break
        }
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        SocketChatManager.sharedInstance.leaveChat(param: [
            "secretKey": SocketChatManager.sharedInstance.secretKey,
            "userId": SocketChatManager.sharedInstance.myUserId,
            "groupId": groupId
        ])
        
        SocketChatManager.sharedInstance.socket?.off("typing-res")
        SocketChatManager.sharedInstance.socket?.off("online-status")
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUserInfoTap(_ sender: UIButton) {
        self.moveToContactInfo()
    }
    
    @available(iOS 14.0, *)
    func loadPopup() {
        let contectInfo = UIAction(title: "\(isGroup ? "Group" : "Contact") Info", image: UIImage(systemName: "")){ action in
            //person.fill - image
            self.moveToContactInfo()
        }
        let deleteChat = UIAction(title: "Delete \(isGroup ? "Group" : "Chat")", image: UIImage(systemName: "")){ action in
            //trash.fill - image
            print("Delete chat")
            self.deleteChat()
        }
        let clearChat = UIAction(title: "Clear Chat", image: UIImage(systemName: "")){ action in
            //ellipses.bubble.fill - image
            self.clearChat()
        }
        
        var menuAction : [UIAction] = []
        menuAction.append(contectInfo)
        
        if isGroup {
            if SocketChatManager.sharedInstance.userGroupRole?.deleteChat ?? 0 == 1 {
                menuAction.append(deleteChat)
            }
            if SocketChatManager.sharedInstance.userGroupRole?.clearChat ?? 0 == 1 {
                menuAction.append(clearChat)
            }
        } else {
            if SocketChatManager.sharedInstance.userRole?.deleteChat ?? 0 == 1 {
                menuAction.append(deleteChat)
            }
            if SocketChatManager.sharedInstance.userRole?.clearChat ?? 0 == 1 {
                menuAction.append(clearChat)
            }
        }
        btnOption.menu = UIMenu(title: "", options: .displayInline, children: menuAction)
    }
    
    func moveToContactInfo() {
        let vc = ContactInfoVC()
        vc.groupId = self.groupId
        vc.userChatVC = { return self }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clearChat() {
        let alertController = UIAlertController(title: "Are you sure you want to clear chat ?", message: "", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            //Delete chat
            self.isClear = true
            SocketChatManager.sharedInstance.clearChat(param: [
                "secretKey" : SocketChatManager.sharedInstance.secretKey,
                "userId" : SocketChatManager.sharedInstance.myUserId,
                "groupId" : self.groupId
            ])
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteChat() {
        let alertController = UIAlertController(title: "Are you sure you want to delete \(isGroup ? "group" : "chat") ?", message: "", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            //Delete chat
            self.isClear = false
            if !self.isGroup {
                SocketChatManager.sharedInstance.deleteChat(param: [
                    "secretKey" : SocketChatManager.sharedInstance.secretKey,
                    "userId" : SocketChatManager.sharedInstance.myUserId,
                    "groupId" : self.groupId
                ], fromChat: true)
            } else {
                SocketChatManager.sharedInstance.deleteGroup(param: [
                    "secretKey" : SocketChatManager.sharedInstance.secretKey,
                    "userId" : SocketChatManager.sharedInstance.myUserId,
                    "groupId" : self.groupId
                ], fromChat: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func responseBack(_ isUpdate : Bool) {
        if isUpdate {
            if isClear {
                self.arrGetPreviousChat?.removeAll()
                self.arrDtForSection?.removeAll()
                self.arrSectionMsg?.removeAll()
                self.tblUserChat.reloadData()
            } else {
                if let viewControllers = navigationController?.viewControllers {
                    for viewController in viewControllers {
                        if viewController is FirstVC {
                            navigationController?.popToViewController(viewController, animated: true)
                            break
                        }
                    }
                }
            }
        }
    }
    
    @available(iOS 14.0, *)
    @IBAction func btnOptionTap(_ sender: UIButton) {
        btnOption.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func btnAttachTap(_ sender: UIButton) {
        self.view.endEditing(true)
        
        self.fromLibrary()
        
        /*let alert = UIAlertController(title: "", message: "Please select an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { alert in
            self.isDocumentPickerOpen = true
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "From library", style: .default, handler: { alert in
            self.isDocumentPickerOpen = true
            self.fromLibrary()
        }))
        /*alert.addAction(UIAlertAction(title: "Document", style: .default, handler: { alert in
            if #available(iOS 14.0, *) {
                self.isDocumentPickerOpen = true
                self.selectFiles()
            } else {
                // Fallback on earlier versions
            }
        })) //  */
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alert in
            self.isDocumentPickerOpen = false
        }))
        self.present(alert, animated: true) {
        }   //  */
    }
    
    @IBAction func btnSendTap(_ sender: UIButton) {
        if txtTypeMsg.text! != "" {
            var replyMsg: String = ""
            if self.isSwipe {
                if self.swipeReplyMsg?.type == "text" {
                    replyMsg = swipeReplyMsg?.message ?? ""
                } else if self.swipeReplyMsg?.type == "image" {
                    replyMsg = swipeReplyMsg?.filePath ?? ""
                } else if self.swipeReplyMsg?.type == "video" {
                    replyMsg = swipeReplyMsg?.thumbnailPath ?? ""
                } else if self.swipeReplyMsg?.type == "document" {
                    replyMsg = swipeReplyMsg?.fileName ?? ""
                } else if self.swipeReplyMsg?.type == "audio" {
                    replyMsg = swipeReplyMsg?.fileName ?? ""
                }
            }
            let param : [String : Any] = ["message": txtTypeMsg.text!,
                                          "type" : "text",
                                          "sentBy" : SocketChatManager.sharedInstance.myUserId,
                                          "senderName": self.groupDetail?.userName ?? "",
                                          "replyUser": self.isSwipe ? self.swipeReplyMsg?.senderName ?? "" : "",
                                          "replyUserId" : self.isSwipe ? self.swipeReplyMsg?.sentBy : "",
                                          ///"replyMsg": self.isSwipe ? (self.isImg ? swipeReplyMsg?.filePath ?? "" : lblReplyMsg.text) : "",
                                          "replyMsg": replyMsg,
                                          "replyMsgType": self.isSwipe ? self.swipeReplyMsg?.type : "",
                                          "replyMsgId": self.isSwipe ? self.swipeReplyMsg?.msgId : ""] as [String : Any]
            let param1 : [String : Any] = ["messageObj" : param, "groupId" : self.groupId, "secretKey" : SocketChatManager.sharedInstance.secretKey, "userId": SocketChatManager.sharedInstance.myUserId, "userName": SocketChatManager.sharedInstance.myUserName]
            
            if self.sendMessage(param: param1) {
                let timestamp : Int = Int(NSDate().timeIntervalSince1970)
                let timeMilliSeconds: [String: Any] = ["nanoseconds": 0,
                                                       "seconds": timestamp]
                let msg: [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
                                           "type" : "text",
                                           "msgId" : "",
                                           "message" : txtTypeMsg.text!,
                                           "contentType" : "",
                                           "fileName" : "",
                                           "filePath" : "",
                                           "senderName" : self.groupDetail?.userName ?? "",
                                           "thumbnailPath" : "",
                                           "time" : 0,
                                           "timeMilliSeconds" : timeMilliSeconds,
                                           "replyUser": self.isSwipe ? self.swipeReplyMsg?.senderName ?? "" : "",
                                           "replyUserId": self.isSwipe ? self.swipeReplyMsg?.sentBy : "",
                                           ///"replyMsg": self.isSwipe ? (self.isImg ? swipeReplyMsg?.filePath ?? "" : lblReplyMsg.text) : "",
                                           "replyMsg": replyMsg,
                                           "replyMsgType": self.isSwipe ? self.swipeReplyMsg?.type : "",
                                           "replyMsgId": self.isSwipe ? self.swipeReplyMsg?.msgId : ""]
                if self.isSwipe {
                    self.btnCloseTap(UIButton())
                }
                txtTypeMsg.text = ""
                
                guard let responseData = try? JSONSerialization.data(withJSONObject: msg, options: []) else { return }
                do {
                    let newMsg = try JSONDecoder().decode(Message.self, from: responseData)
                    print(newMsg)
                    if self.loadChatMsgToArray(msg: newMsg, timestamp: timestamp) {
                        tblUserChat.reloadData()
                        tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![arrSectionMsg!.count - 1].count - 1), section: (arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                        //self.view.endEditing(true)
                    }
                } catch let err {
                    print(err)
                    return
                }
            }
        }
    }
    
    @IBAction func btnCloseTap(_ sender: UIButton) {
        viewMainReply.isHidden = true
        constTblBottom.priority = .required
        self.constViewMainReplyHeight.priority = .required
        self.isSwipe = false
        self.isImg = false
    }
    
    func sendMessage(param : [String : Any]) -> Bool {
        if Network.reachability.isReachable {
            if SocketChatManager.sharedInstance.socket?.status == .connected {
                SocketChatManager.sharedInstance.sendMsg(message: param)
                return true
            } else {
                let toastMsg = ToastUtility.Builder(message: "Server not connected.", controller: self, keyboardActive: isKeyboardActive)
                toastMsg.setColor(background: .red, text: .black)
                toastMsg.show()
                return false
            }
        } else {
            let toastMsg = ToastUtility.Builder(message: "No Internet connection.", controller: self, keyboardActive: isKeyboardActive)
            toastMsg.setColor(background: .red, text: .black)
            toastMsg.show()
            return false
        }
    }
}
