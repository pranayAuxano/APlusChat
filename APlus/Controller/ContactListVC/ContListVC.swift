//
//  ContactListVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import ProgressHUD

public class ContListVC: UIViewController {

    @IBOutlet weak var viewBackContact: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblContactList: UILabel!
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblContact: UITableView!
    
    var contactList : ContactList?
    
    //var myUserId : String = ""
    //var secretKey : String = ""
    var arrAllContactList : [List]?
    var arrContactList : [List]?
    var arrSelectedContact : [List]? = []
    var myContactDetail : List?
    var arrSelectedUser : [[String: Any]] = []
    var arrReadCount : [[String: Any]] = []//["unreadCount":0, "userId":""]
    var arrUserIds : [String] = []
    var arrRecentChatUserList : [GetUserList]? = []
    var bundle = Bundle()
    
    public init() {
        super.init(nibName: "ContactList", bundle: Bundle(for: ContListVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented FirstViewController")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.enablesReturnKeyAutomatically = true
        
        SocketChatManager.sharedInstance.contactListVC = {
            return self
        }
        
        tblContact.delegate = self
        tblContact.dataSource = self
        
        let bundle = Bundle(for: ContListVC.self)
        tblContact.register(UINib(nibName: "ContactTVCell", bundle: bundle), forCellReuseIdentifier: "ContactTVCell")
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        bundle = Bundle(for: ContListVC.self)
        
        ProgressHUD.show()
        //userId, secretKey
        SocketChatManager.sharedInstance.getUserList(param: ["userId" : SocketChatManager.sharedInstance.myUserId, "secretKey" : SocketChatManager.sharedInstance.secretKey], from: true)
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getUserListRes(_ contactList : ContactList) {
        self.contactList = contactList
        self.arrAllContactList = contactList.list
        
        for i in 0 ..< (arrAllContactList!.count) {
            if (arrAllContactList![i].userId)! == SocketChatManager.sharedInstance.myUserId {
                self.myContactDetail = arrAllContactList![i]
                arrAllContactList?.remove(at: i)
                self.contactList?.list?.remove(at: i)
                break
            }
        }
        arrContactList = arrAllContactList
        tblContact.reloadData()
        ProgressHUD.dismiss()
    }
}


extension ContListVC : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return contactList?.list?.count ?? 0
        return arrContactList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTVCell", for: indexPath) as! ContactTVCell
        cell.imgContactImg.layer.cornerRadius = cell.imgContactImg.frame.height / 2
        cell.lblSeparator.backgroundColor = .gray.withAlphaComponent(0.5)
        
        cell.imgContactImg.image = UIImage(named: "placeholder-profile-img", in: self.bundle, compatibleWith: nil)  //UIImage(named: "placeholder-profile-img.png")
        cell.configure(self.arrContactList![indexPath.row].profilePicture ?? "")
        //cell.lblName.text = contactList?.list![indexPath.row].name ?? ""
        cell.lblName.text = self.arrContactList![indexPath.row].name ?? ""
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Same as create group.
        arrSelectedContact?.append((contactList?.list![indexPath.row])!)
        self.createOneToOneChat(selectUserId: contactList?.list![indexPath.row].userId ?? "")
    }
    
    func createOneToOneChat(selectUserId : String) {
        var isPrevious : Bool = false
        for i in 0 ..< (arrRecentChatUserList?.count ?? 0) {
            if !(arrRecentChatUserList?[i].isGroup ?? false) {
                for (_, info) in (arrRecentChatUserList?[i].users)!.enumerated() {
                    if info.userId == selectUserId {
                        let vc = ChatVC()
                        vc.recentChatUser = arrRecentChatUserList?[i]
                        self.navigationController?.pushViewController(vc, animated: true)
                        isPrevious = true
                        break
                    }
                }
            }
            if isPrevious {
                break
            }
        }
        
        if !isPrevious {
            arrSelectedContact?.append(myContactDetail!)
            for i in 0 ..< (arrSelectedContact?.count ?? 0) {
                arrUserIds.append(arrSelectedContact![i].userId ?? "")
                //var readCount = UnreadCount(unreadCount: 0, userId: arrSelectedContact![i].userId ?? "")
                let readCount = ["unreadCount": 0, "userId": arrSelectedContact![i].userId ?? ""] as [String : Any]
                arrReadCount.append(readCount)
                //var : [String]?
                let contectDetail = ["userId" : arrSelectedContact![i].userId ?? "",
                                     "serverUserId" : arrSelectedContact![i].serverUserId ?? "",
                                     "profilePicture" : arrSelectedContact![i].profilePicture ?? "",
                                     "name" : arrSelectedContact![i].name ?? "",
                                     "mobile_email" : arrSelectedContact![i].mobile_email ?? "",
                                     "groups" : arrSelectedContact![i].groups ?? []] as [String : Any]
                arrSelectedUser.append(contectDetail)
            }
            let param = [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "isGroup": false,
                "createdBy": SocketChatManager.sharedInstance.myUserId,
                "groupId": "",
                "groupImage": "",
                "members": arrUserIds,
                "isDeactivateUser": false,
                "modifiedBy": "",
                "name": "",
                "online": [],
                "pinnedGroup": [],
                "readCount": arrReadCount,
                "typing": [],
                "blockUsers": [],
                "viewBy": arrUserIds,
                "recentMessage": [],
                "users": arrSelectedUser] as [String : Any]
            
            SocketChatManager.sharedInstance.createGroup(param: ["groupDetails": param], from: false)
        }
    }
    
    func responseBack(_ isUpdate : Bool) {
        if isUpdate {
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension ContListVC : UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrContactList = self.arrAllContactList
        if searchText != "" {
            self.arrContactList = self.arrAllContactList?.filter{
                ($0.name!.lowercased()).contains(searchText.lowercased())
            }
        }
        print(searchText)
        self.tblContact.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.arrContactList = self.arrAllContactList
        self.searchBar.text = ""
        self.tblContact.reloadData()
    }
}
