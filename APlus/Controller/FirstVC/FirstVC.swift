//
//  FirstVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import ProgressHUD

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

    var userName : String = "ABC"
    var isNetworkAvailable : Bool = false
    var isGetUserList : Bool = false
    var arrAllRecentChatGroupList : [GetGroupList]? = []
    var arrRecentChatGroupList : [GetGroupList]? = []
    private var imageRequest: Cancellable?
    var profileDetail : ProfileDetail?
    public var hideTopView : Bool = false   //  for hide top bar from chat.
    
    let activityIndicator = UIActivityIndicatorView()
    var isGetChatResponse: Bool = false
    var bundle = Bundle()
    
    public init()
    {
        super.init(nibName: "FirstVC", bundle: Bundle(for: FirstVC.self))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented FirstViewController")
    }
    
    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        do
        {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch
        {
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
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.enablesReturnKeyAutomatically = true
        
        tblChatList.dataSource = self
        tblChatList.delegate = self
        
        bundle = Bundle(for: FirstVC.self)
        self.tblChatList.register(UINib(nibName: "UserDetailTVCell", bundle: bundle), forCellReuseIdentifier: "UserDetailTVCell")
        
        if Network.reachability.isReachable
        {
            isNetworkAvailable = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkConnection), name: .flagsChanged, object: nil)
        
        self.btnNewChat.isHidden = true
        self.btnNewGroupChat.isHidden = true
        
        if self.hideTopView
        {
            self.viewTopChatGrp.isHidden = true
            self.constHeightviewTopChatGrp.constant = 0
        }
        else
        {
            self.viewTopChatGrp.isHidden = false
            self.constHeightviewTopChatGrp.constant = 55
        }
        
        callSocket()
        
        tblChatList.reloadData()
        self.tblChatList.isScrollEnabled = false
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        bundle = Bundle(for: FirstVC.self)
        self.navigationController?.isNavigationBarHidden = true
        
        imgProfilePic.layer.cornerRadius = imgProfilePic.frame.height / 2
        SocketChatManager.sharedInstance.socketDelegate = self
        isGetUserList = false
        
        if (SocketChatManager.sharedInstance.socket?.status == .connected)
        {
            if !hideTopView && (SocketChatManager.sharedInstance.userRole?.updateProfile ?? 0 == 1)
            {
                SocketChatManager.sharedInstance.reqProfileDetails(param: [
                    "secretKey" : SocketChatManager.sharedInstance.secretKey,
                    "userId" : SocketChatManager.sharedInstance.myUserId
                ], from: false)
            }
            
            SocketChatManager.sharedInstance.reqRecentChatList(param: [
                "secretKey" : SocketChatManager.sharedInstance.secretKey,
                "userId" : SocketChatManager.sharedInstance.myUserId
            ])
        }
    }
    
    @objc func checkConnection(_ notification: Notification)
    {
        updateUserInterface()
    }
    
    func updateUserInterface()
    {
        switch Network.reachability.isReachable {
        case true:
            if !self.isNetworkAvailable
            {
                self.isNetworkAvailable = true
                let toastMsg = ToastUtility.Builder(message: "Network available.", controller: self, keyboardActive: false)
                toastMsg.setColor(background: .green, text: .black)
                toastMsg.show()
            }
            print("Network connection available.")
            break
        case false:
            if isNetworkAvailable
            {
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
        let vc = ProfDetailVC()
        vc.profileImgDelegate = self
        vc.profileDetail = self.profileDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNewChatTap(_ sender: UIButton) {
        let vc = ContListVC()
        vc.arrRecentChatGroupList = arrAllRecentChatGroupList
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNewGroupChatTap(_ sender: UIButton) {
        let vc =  GroupContVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getProfileDetail(_ profileDetail : ProfileDetail)
    {
        print("Get response of profile details.")
        self.btnViewUserProfile.isUserInteractionEnabled = true
        self.profileDetail = profileDetail
        
        SocketChatManager.sharedInstance.myUserName = self.profileDetail?.name ?? ""
        
        if profileDetail.profilePicture != nil && profileDetail.profilePicture! != ""
        {
            var imageURL: URL?
            imageURL = URL(string: profileDetail.profilePicture ?? "")!
            //self.imgProfilePic.image = nil
            
            // retrieves image if already available in cache
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage
            {
                self.imgProfilePic.image = imageFromCache
                return
            }
            
            // setup activityIndicator...
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 41, height: 41)
            activityIndicator.color = .darkGray
            activityIndicator.center = self.viewProfileImg.center
            self.imgProfilePic.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: profileDetail.profilePicture!)!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    self.activityIndicator.stopAnimating()
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data)
                    {
                        self.imgProfilePic.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func getUserRole()
    {
        btnNewGroupChat.isHidden = true
        btnNewChat.isHidden = true
        
        if SocketChatManager.sharedInstance.userRole?.createOneToOneChat ?? 0 == 1
        {
            btnNewChat.isHidden = false
        }
        
        if SocketChatManager.sharedInstance.userRole?.createGroup ?? 0 == 1
        {
            btnNewGroupChat.isHidden = false
            constTrailNewGrpChat.priority = SocketChatManager.sharedInstance.userRole?.createOneToOneChat ?? 0 == 1 ? .defaultLow : .required
        }
        
        if !hideTopView && (SocketChatManager.sharedInstance.userRole?.updateProfile ?? 0 == 1)
        {
            SocketChatManager.sharedInstance.reqProfileDetails(param: [
                "secretKey" : SocketChatManager.sharedInstance.secretKey,
                "userId" : SocketChatManager.sharedInstance.myUserId
            ], from: false)
            self.btnViewUserProfile.isUserInteractionEnabled = true
        }
        else
        {
            self.btnViewUserProfile.isUserInteractionEnabled = false
        }
    }
}

extension FirstVC : UITableViewDelegate, UITableViewDataSource
{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isGetChatResponse) ? (self.arrRecentChatGroupList?.count ?? 0) : 10
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailTVCell", for: indexPath) as! UserDetailTVCell
        
        if self.isGetChatResponse
        {
            cell.viewMainBG.stopShimmeringAnimation()
            cell.viewProfileImg.isHidden = false
            cell.viewMsgDetail.isHidden = false
            
            cell.viewMainBG.backgroundColor = .white
            cell.viewMainBG.dropShadow()
            
            //cell.viewMainBG.setBgColor(color: SocketChatManager.sharedInstance.themeColor!)
            //cell.lblLastMsg.setTextColor(color: SocketChatManager.sharedInstance.themeColor!)
            //cell.lblUserName.setTextColor(color: SocketChatManager.sharedInstance.themeColor!)
            //cell.lblMsgDateTime.setTextColor(color: SocketChatManager.sharedInstance.themeColor!)
            //cell.lblRecentPhotoVideoFile.setTextColor(color: SocketChatManager.sharedInstance.themeColor!)
            
            var msgType : String = self.arrRecentChatGroupList![indexPath.row].msgType ?? ""
            
            cell.imgProfile.image = UIImage(named: (self.arrRecentChatGroupList?[indexPath.row].isGroup)! ? "group-placeholder.jpg" : "placeholder-profile-img.png", in: bundle, compatibleWith: nil)
            cell.configure(self.arrRecentChatGroupList?[indexPath.row].groupName ?? "", self.arrRecentChatGroupList?[indexPath.row].imagePath ?? "", msgType, isGroup: (self.arrRecentChatGroupList?[indexPath.row].isGroup)!)
            
            if msgType == "text"
            {
                cell.lblLastMsg.text = (self.arrRecentChatGroupList?[indexPath.row].recentMsg)!
            }
            else if msgType == ""
            {
                cell.lblLastMsg.text = "Start your conversation"
            }
            
            cell.lblMsgDateTime.text = Utility.convertTimestamptoLastMsgDateTimeString(timestamp: "\(self.arrRecentChatGroupList?[indexPath.row].latestTime?.seconds ?? 0)")
            
            cell.lblUnreadMsgCount.isHidden = true
            
            if (self.arrRecentChatGroupList?[indexPath.row].unreadCount ?? 0) != 0
            {
                cell.lblUnreadMsgCount.isHidden = false
                cell.lblUnreadMsgCount.text = "\(self.arrRecentChatGroupList?[indexPath.row].unreadCount ?? 0)"
            }
        }
        else
        {
            //self.tblChatList.startShimmeringAnimation(animationSpeed: 3.0, direction: .leftToRight)
            cell.viewMainBG.backgroundColor = .white
            cell.viewMainBG.startShimmeringAnimation(animationSpeed: 3.0, direction: .leftToRight)
            cell.viewProfileImg.isHidden = true
            cell.viewMsgDetail.isHidden = true
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isGetChatResponse
        {
            if self.arrRecentChatGroupList?[indexPath.row].groupId ?? "" != ""
            {
                SocketChatManager.sharedInstance.socket?.off("get-group-list-res")
                let vc = ChatVC()
                vc.isHideUserDetailView = false
                vc.isDirectToChat = false
                vc.isGroup = self.arrRecentChatGroupList?[indexPath.row].isGroup ?? false
                vc.groupId = self.arrRecentChatGroupList?[indexPath.row].groupId ?? ""
                vc.strDisName = self.arrRecentChatGroupList?[indexPath.row].groupName ?? ""
                vc.strProfileImg = self.arrRecentChatGroupList?[indexPath.row].imagePath ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                let toastMsg = ToastUtility.Builder(message: "Something wrong. Please try later.", controller: self, keyboardActive: true)
                toastMsg.setColor(background: .red, text: .black, alpha: 0.9)
                toastMsg.setScreenTime(duration: 2.0)
                toastMsg.show()
            }
        }
    }
}

extension FirstVC : UISearchBarDelegate, ProfileImgDelegate
{
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.arrRecentChatGroupList = self.arrAllRecentChatGroupList
        if searchText != ""
        {
            self.arrRecentChatGroupList = self.arrRecentChatGroupList?.filter{
                ($0.groupName!.lowercased()).contains(searchText.lowercased())
            }
        }
        self.tblChatList.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        self.arrRecentChatGroupList = self.arrAllRecentChatGroupList
        self.searchBar.text = ""
        self.tblChatList.reloadData()
    }
    
    func setProfileImg(image: UIImage)
    {
        imgProfilePic.contentMode = .scaleAspectFill
        imgProfilePic.image = image
    }
}

extension FirstVC : SocketDelegate
{
    func callSocket()
    {
        if (SocketChatManager.sharedInstance.socket?.status == .connected) && !isGetUserList
        {
            isGetUserList = true
            SocketChatManager.sharedInstance.getUserRole(param: [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "userId": SocketChatManager.sharedInstance.myUserId
            ])
            
            SocketChatManager.sharedInstance.reqRecentChatList(param: [
                "secretKey" : SocketChatManager.sharedInstance.secretKey,
                "userId" : SocketChatManager.sharedInstance.myUserId
            ])
        }
    }
    
    func msgReceived(message: Message)
    {   }
    
    func getPreviousChatMsg(message: String)
    {   }
    
    func recentChatGroupList(groupList: [GetGroupList])
    {
        self.arrAllRecentChatGroupList = groupList
        
        if self.arrAllRecentChatGroupList?.count ?? 0 == 1
        {
            SocketChatManager.sharedInstance.onlineUser(param: [
                "secretKey" : SocketChatManager.sharedInstance.secretKey,
                "userId" : SocketChatManager.sharedInstance.myUserId
            ])
        }
        
        self.arrRecentChatGroupList = self.arrAllRecentChatGroupList
        tblChatList.isScrollEnabled = true
        self.isGetChatResponse = true
        tblChatList.reloadData()
    }
    
    func getRecentUser(message: String)
    {
        callSocket()
    }
}
