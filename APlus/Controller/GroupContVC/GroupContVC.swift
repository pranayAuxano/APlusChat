//
//  GroupContVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import ProgressHUD

public class GroupContVC: UIViewController {

    @IBOutlet weak var viewBackCreatGrp: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblCreatGroup: UILabel!
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblContact: UITableView!
    @IBOutlet weak var btnNext: UIButton!
    
    var contactList : ContactList?
    
    var myContactDetail : List?
    var arrAllContactList : [List]? = []
    var arrContactList : [List]? = []
    var arrSelectedContactList : [List]? = []
    
    var groupId : String? = ""
    var isAddMember : Bool = false
    var arrGroupUserIds : [String] = []
    var arrReadCount : [[String: Any]] = []//["unreadCount":0, "userId":""]
    var arrUserIds : [String] = []
    var arrSelectedUser : [[String: Any]] = []
    var contectInfoVC : (()->ContactInfoVC)?
    var groupDetail : GroupDetail?
    var addMembersArr: [String] = []
    var bundle = Bundle()
    
    public init() {
        super.init(nibName: "GroupContVC", bundle: Bundle(for: GroupContVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented GroupContVC")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if isAddMember {
            lblCreatGroup.text = "Add Member"
            btnNext.setTitle("Add", for: .normal)
        }
        btnNext.layer.cornerRadius = 5.0
        btnNext.isEnabled = false
        btnNext.backgroundColor = UIColor(red: 104/255.0, green: 162/255.0, blue: 254/255.0, alpha: 1)
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.enablesReturnKeyAutomatically = true
        
        SocketChatManager.sharedInstance.groupContactVC = {
            return self
        }
        
        tblContact.dataSource = self
        tblContact.delegate = self
        
        let bundle = Bundle(for: GroupContVC.self)
        tblContact.register(UINib(nibName: "GrpContactTVCell", bundle: bundle), forCellReuseIdentifier: "GrpContactTVCell")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        bundle = Bundle(for: GroupContVC.self)
        
        ProgressHUD.show()
        self.addMembersArr.removeAll()
        SocketChatManager.sharedInstance.getUserList(param: [
            "userId" : SocketChatManager.sharedInstance.myUserId,
            "secretKey" : SocketChatManager.sharedInstance.secretKey
        ], from: false)
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
        
        if isAddMember {
            for i in 0 ..< (arrUserIds.count) {
                for j in 0 ..< (arrAllContactList!.count) {
                    if (arrAllContactList![j].userId)! == arrUserIds[i] {
                        arrAllContactList?.remove(at: j)
                        self.contactList?.list?.remove(at: j)
                        break
                    }
                }
            }
        }
        
        arrContactList = arrAllContactList
        
        tblContact.reloadData()
        ProgressHUD.dismiss()
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNextTap(_ sender: UIButton) {
        if isAddMember {
            for i in 0 ..< (arrSelectedContactList?.count ?? 0) {
                arrUserIds.append(arrSelectedContactList![i].userId ?? "")
                let contectDetail = ["userId" : arrSelectedContactList![i].userId ?? "",
                                     "serverUserId" : arrSelectedContactList![i].serverUserId ?? "",
                                     "profilePicture" : arrSelectedContactList![i].profilePicture ?? "",
                                     "name" : arrSelectedContactList![i].name ?? "",
                                     "mobile_email" : arrSelectedContactList![i].mobile_email ?? "",
                                     "groups" : arrSelectedContactList![i].groups ?? []] as [String : Any]
                arrSelectedUser.append(contectDetail)
            }
            let param = [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "groupId": groupId ?? "",
                "members": arrUserIds,
                "viewBy": arrUserIds,
                "users": arrSelectedUser,
                "addMembersArr": addMembersArr
            ] as [String : Any]
            
            ProgressHUD.show()
            SocketChatManager.sharedInstance.addMember(param: param)
        } else {
            let vc =  CreateGrpVC()
            vc.arrSelectedContactList = self.arrSelectedContactList
            vc.myContactDetail = self.myContactDetail
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addMemberRes(_ isSuccess : Bool) {
        ProgressHUD.dismiss()
        if isSuccess {
            self.navigationController?.popViewController(animated: true)
        } else {
            print("Fail to add member.")
        }
    }
}
