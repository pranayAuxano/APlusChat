//
//  FirstVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import SocketIO
import ProgressHUD
import JGProgressHUD

let imageCache = NSCache<AnyObject, AnyObject>()

public class FirstVC: UIViewController {
    
    @IBOutlet weak var viewTopChatGrp: UIView!
    @IBOutlet weak var tblChatList: UITableView!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnNewChat: UIButton!
    @IBOutlet weak var btnNewGroupChat: UIButton!
    @IBOutlet weak var btnViewUserProfile: UIButton!
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var constTrailNewChat: NSLayoutConstraint!
    @IBOutlet weak var constTrailNewGrpChat: NSLayoutConstraint!
    @IBOutlet weak var viewProfileImg: UIView!
    @IBOutlet weak var constHeightviewTopChatGrp: NSLayoutConstraint!

    var userName : String = "A"
    var isNetworkAvailable : Bool = false
    var isGetUserList : Bool = false
    var arrAllRecentChatUserList : [GetUserList]? = []
    var arrRecentChatUserList : [GetUserList]? = []
    private var imageRequest: Cancellable?
    var profileDetail : ProfileDetail?
    public var hideTopView : Bool = false   //  for hide top bar from chat.
    
    let activityIndicator = UIActivityIndicatorView()
    var bundle = Bundle()
    
    public init() {
        super.init(nibName: "FirstVC", bundle: Bundle(for: FirstVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented FirstViewController")
    }
    
    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
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
        
        SocketChatManager.sharedInstance.establishConnection()
        SocketChatManager.sharedInstance.viewController = {
            return self
        }
        
        imgProfilePic.image = UIImage(named: "placeholder-profile-img", in: bundle, compatibleWith: nil)    //UIImage(named: "placeholder-profile-img.png")
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.enablesReturnKeyAutomatically = true
        
        tblChatList.dataSource = self
        tblChatList.delegate = self
        
        //let bundle = Bundle(for: FirstVC.self)
        self.tblChatList.register(UINib(nibName: "UserDetailTVCell", bundle: bundle), forCellReuseIdentifier: "UserDetailTVCell")
        
        if Network.reachability.isReachable {
            isNetworkAvailable = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(checkConnection), name: .flagsChanged, object: nil)
        
        self.btnNewChat.isHidden = true
        self.btnNewGroupChat.isHidden = true
        
        if self.hideTopView {
            self.viewTopChatGrp.isHidden = true
            self.constHeightviewTopChatGrp.constant = 0
        } else {
            self.viewTopChatGrp.isHidden = false
            self.constHeightviewTopChatGrp.constant = 55
        }
        callSocket()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        bundle = Bundle(for: FirstVC.self)
        
        self.navigationController?.isNavigationBarHidden = true
        imgProfilePic.layer.cornerRadius = imgProfilePic.frame.height / 2
        SocketChatManager.sharedInstance.socketDelegate = self
        isGetUserList = false
        
        if (SocketChatManager.sharedInstance.socket?.status == .connected) {
            //isGetUserList = true
            SocketChatManager.sharedInstance.reqProfileDetails(param: ["userId" : SocketChatManager.sharedInstance.myUserId], from: false)
            SocketChatManager.sharedInstance.reqRecentChatList(param: ["secretKey" : SocketChatManager.sharedInstance.secretKey, "_id" : SocketChatManager.sharedInstance.myUserId])
            //self.getUserRole()
        }
    }
    
    @objc func checkConnection(_ notification: Notification) {
        updateUserInterface()
    }
    
    func updateUserInterface() {
        switch Network.reachability.isReachable {
        case true:
            if !self.isNetworkAvailable {
                self.isNetworkAvailable = true
                let toastMsg = ToastUtility.Builder(message: "Network available.", controller: self, keyboardActive: false)
                toastMsg.setColor(background: .green, text: .black)
                toastMsg.show()
            }
            print("Network connection available.")
            break
        case false:
            if isNetworkAvailable {
                self.isNetworkAvailable = false
                let toastMsg = ToastUtility.Builder(message: "No Network.", controller: self, keyboardActive: false)
                toastMsg.setColor(background: .red, text: .black)
                toastMsg.show()
            }
            SocketChatManager.sharedInstance.establishConnection()
            break
        }
    }
    
    @IBAction func btnViewUserProfileTap(_ sender: UIButton) {
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let vc =  sb.instantiateViewController(withIdentifier: "ProfileDetailVC") as! ProfileDetailVC
//        vc.profileImgDelegate = self
//        vc.profileDetail = self.profileDetail
//        self.navigationController?.pushViewController(vc, animated: true)
        
//        let vc = ProfDetailVC()
        let vc = ProfDetailVC()
        vc.profileImgDelegate = self
        vc.profileDetail = self.profileDetail
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnNewChatTap(_ sender: UIButton) {
        let vc = ContListVC()
        vc.arrRecentChatUserList = arrAllRecentChatUserList
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNewGroupChatTap(_ sender: UIButton) {
        let vc =  GroupContVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getProfileDetail(_ profileDetail : ProfileDetail) {
        ProgressHUD.dismiss()
        print("Get response of profile details.")
        self.profileDetail = profileDetail
        
        SocketChatManager.sharedInstance.myUserName = self.profileDetail?.name ?? ""
        
        imgProfilePic.image = UIImage(named: "placeholder-profile-img", in: bundle, compatibleWith: nil)    //UIImage(named: "placeholder-profile-img.png")
        if profileDetail.profilePicture! != "" {
            // setup activityIndicator...
            activityIndicator.color = .darkGray
            
            activityIndicator.center = self.viewProfileImg.center
            self.imgProfilePic.addSubview(activityIndicator)
            
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 41, height: 41)
            
            var imageURL: URL?
            imageURL = URL(string: profileDetail.profilePicture!)!
            
            self.imgProfilePic.image = nil
            activityIndicator.startAnimating()
            
            // retrieves image if already available in cache
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgProfilePic.image = imageFromCache
                activityIndicator.stopAnimating()
                return
            }
            
            imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: profileDetail.profilePicture!)!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    self.activityIndicator.stopAnimating()
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data) {
                        self.imgProfilePic.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func getUserRole() {
        btnNewGroupChat.isHidden = true
        btnNewChat.isHidden = true
        
        if SocketChatManager.sharedInstance.userRole?.createOneToOneChat ?? 0 == 1 {
            btnNewChat.isHidden = false
        }
        
        if SocketChatManager.sharedInstance.userRole?.createGroup ?? 0 == 1 {
            btnNewGroupChat.isHidden = false
            constTrailNewGrpChat.priority = SocketChatManager.sharedInstance.userRole?.createOneToOneChat ?? 0 == 1 ? .defaultLow : .required
        }
    }
    
    func getNewChatMsg(isNew: Bool) {
        print("New message arrive == \(isNew)")
        if isNew {
            SocketChatManager.sharedInstance.reqRecentChatList(param: ["secretKey" : SocketChatManager.sharedInstance.secretKey, "_id" : SocketChatManager.sharedInstance.myUserId])  //  ["secretKey" : SocketChatManager.sharedInstance.secretKey, "_id" : SocketChatManager.sharedInstance.myUserId]
        }
    }
}

extension FirstVC : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrRecentChatUserList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailTVCell", for: indexPath) as! UserDetailTVCell
        
        cell.viewMainBG.backgroundColor = .white
        //cell.viewMainBG.layer.shadowColor
        cell.viewMainBG.dropShadow()
        
        var msgType : String = ""
        if (self.arrRecentChatUserList?[indexPath.row].recentMessage?.type != nil) {
            msgType = (self.arrRecentChatUserList?[indexPath.row].recentMessage?.type)!
        }
        
        cell.imgProfile.image = UIImage(named: "placeholder-profile-img", in: bundle, compatibleWith: nil)  //UIImage(named: "placeholder-profile-img")
        if (self.arrRecentChatUserList?[indexPath.row].isGroup)! {
            cell.imgProfile.image = UIImage(named: "group-placeholder", in: bundle, compatibleWith: nil)  //UIImage(named: "group-placeholder")
            cell.configure((self.arrRecentChatUserList?[indexPath.row].name)!, self.arrRecentChatUserList?[indexPath.row].groupImage ?? "", msgType, isGroup: true)
        } else {
            for (_, item) in ((self.arrRecentChatUserList?[indexPath.row].users)!).enumerated() {
                if (item.userId)! != SocketChatManager.sharedInstance.myUserId {
                    cell.configure(item.name ?? "", item.profilePicture ?? "", msgType, isGroup: false)
                }
            }
        }
        
        if msgType == "text" {
            cell.lblLastMsg.text = (self.arrRecentChatUserList?[indexPath.row].recentMessage?.message)!
        } else if msgType == "" {
            cell.lblLastMsg.text = "Start your conversation"
        }
        
        //cell.lblMsgDateTime.text = "\((self.arrRecentChatUserList?[indexPath.row].recentMessage?.sentAt?.seconds)!)"
        if msgType != "" {
            cell.lblMsgDateTime.text = Utility.convertTimestamptoLastMsgDateTimeString(timestamp: "\((self.arrRecentChatUserList?[indexPath.row].recentMessage?.sentAt?.seconds)!)")
        }
        
        cell.lblUnreadMsgCount.isHidden = true
        for (_, item) in ((self.arrRecentChatUserList?[indexPath.row].readCount)!).enumerated() {
            if item.userId == SocketChatManager.sharedInstance.myUserId && item.unreadCount! != 0 {
                cell.lblUnreadMsgCount.isHidden = false
                cell.lblUnreadMsgCount.text = String(describing: item.unreadCount!)
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let vc =  sb.instantiateViewController(withIdentifier: "UserChatVC") as! UserChatVC
//        //vc.myUserId = SocketChatManager.sharedInstance.myUserId
//        vc.recentChatUser = self.arrRecentChatUserList?[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
        
        let vc = ChatVC()
        vc.isHideUserDetailView = false
        vc.isDirectToChat = false
        vc.recentChatUser = self.arrRecentChatUserList?[indexPath.row]
        vc.isGroup = self.arrRecentChatUserList?[indexPath.row].isGroup ?? false
        vc.groupId = self.arrRecentChatUserList?[indexPath.row].groupId ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FirstVC : UISearchBarDelegate, ProfileImgDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrRecentChatUserList = self.arrAllRecentChatUserList
        if searchText.count > 0 {
            self.arrRecentChatUserList?.removeAll()
            for (_, item) in self.arrAllRecentChatUserList!.enumerated() {
                if item.name ?? "" != "" {
                    if item.name!.lowercased().contains(searchText.lowercased()) {
                        self.arrRecentChatUserList?.append(item)
                    }
                } else {
                    for (_, user) in ((item.users)!).enumerated() {
                        if (user.userId)! != SocketChatManager.sharedInstance.myUserId {
                            if user.name!.lowercased().contains(searchText.lowercased()) {
                                self.arrRecentChatUserList?.append(item)
                            }
                        }
                    }
                }
            }
        }
        self.tblChatList.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.arrRecentChatUserList = self.arrAllRecentChatUserList
        self.searchBar.text = ""
        self.tblChatList.reloadData()
    }
    
    func setProfileImg(image: UIImage) {
        imgProfilePic.contentMode = .scaleAspectFill
        imgProfilePic.image = image
    }
}

extension FirstVC : SocketDelegate {
    func callSocket() {
        if (SocketChatManager.sharedInstance.socket?.status == .connected) && !isGetUserList {
            isGetUserList = true
            SocketChatManager.sharedInstance.online(param: ["userId": SocketChatManager.sharedInstance.myUserId, "secretKey": SocketChatManager.sharedInstance.secretKey])
            
            SocketChatManager.sharedInstance.getUserRole(param: ["secretKey": SocketChatManager.sharedInstance.secretKey, "userId": SocketChatManager.sharedInstance.myUserId])
            
            SocketChatManager.sharedInstance.reqProfileDetails(param: ["userId" : SocketChatManager.sharedInstance.myUserId], from: false)
            
            SocketChatManager.sharedInstance.reqRecentChatList(param: ["secretKey" : SocketChatManager.sharedInstance.secretKey, "_id" : SocketChatManager.sharedInstance.myUserId])  //  ["secretKey" : secretKey, "_id" : myUserId]
            
            //Update while new message arrive.
            SocketChatManager.sharedInstance.joinChatRefer(param: SocketChatManager.sharedInstance.myUserId)
            
            //Unread chat count
            SocketChatManager.sharedInstance.getUnreadChat(event: "user-unread-count", param: ["userId": SocketChatManager.sharedInstance.myUserId, "secretKey": SocketChatManager.sharedInstance.secretKey])
        }
    }
    
    func getUnreadChat(noOfChat: Int) {
    }
    
    func msgReceived(message: ReceiveMessage) {
    }
    
    func getPreviousChatMsg(message: String) {
    }
    
    func recentChatUserList(userList: [GetUserList]) {
        self.arrAllRecentChatUserList = userList
        self.arrRecentChatUserList = self.arrAllRecentChatUserList
        tblChatList.reloadData()
        //ProgressHUD.dismiss()
    }
    
    func getRecentUser(message: String) {
        callSocket()
    }
}
