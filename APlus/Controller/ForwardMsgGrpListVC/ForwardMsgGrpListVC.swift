//
//  ForwardMsgGrpListVC.swift
//  APlus
//
//  Created by MAcBook on 07/07/23.
//

import UIKit
import ProgressHUD

class ForwardMsgGrpListVC: UIViewController {

    @IBOutlet weak var viewBackForwardToGrp: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblForwardToGrp: UILabel!
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewTblForwardToGrp: UIView!
    @IBOutlet weak var tblForwardToGrp: UITableView!
    @IBOutlet weak var viewBtnSend: UIView!
    @IBOutlet weak var btnSend: UIButton!
    
    var arrRecentChatGroupList : [GetGroupList]? = []
    var arrAllRecentChatGroupList : [GetGroupList]? = []
    var isGetChatResponse: Bool = false
    var arrSelectedGrpList: [String] = []
    var arrSelectedMsg: [Message] = []
    var strUserName: String = ""
    
    var bundle = Bundle()
    
    public init() {
        super.init(nibName: "ForwardMsgGrpListVC", bundle: Bundle(for: ForwardMsgGrpListVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented ForwardMsgGrpListVC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnSend.layer.cornerRadius = 5.0
        btnSend.isEnabled = true
        btnSend.backgroundColor = UIColor(red: 15/255.0, green: 101/255.0, blue: 158/255.0, alpha: 1)
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.enablesReturnKeyAutomatically = true
        
        tblForwardToGrp.delegate = self
        tblForwardToGrp.dataSource = self
        tblForwardToGrp.isScrollEnabled = false
        
        bundle = Bundle(for: ForwardMsgGrpListVC.self)
        tblForwardToGrp.register(UINib(nibName: "GrpContactTVCell", bundle: bundle), forCellReuseIdentifier: "GrpContactTVCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bundle = Bundle(for: ForwardMsgGrpListVC.self)
        SocketChatManager.sharedInstance.socketDelegate = self
        
        SocketChatManager.sharedInstance.reqRecentChatList(param: [
            "secretKey": SocketChatManager.sharedInstance.secretKey,
            "userId": SocketChatManager.sharedInstance.myUserId
        ], fromForward: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SocketChatManager.sharedInstance.socket?.off("get-group-list-res")
        //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        SocketChatManager.sharedInstance.socket?.off("get-group-list-res")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendTap(_ sender: UIButton) {
        if arrSelectedGrpList.count > 0 {
            var arrMsg: [Any] = []
            arrMsg.removeAll()
            for i in 0 ..< arrSelectedMsg.count {
                let msg: [String: Any] = [
                   "contentType": arrSelectedMsg[i].contentType ?? "",
                   "fileName": arrSelectedMsg[i].fileName ?? "",
                   "msgId": arrSelectedMsg[i].msgId ?? "",
                   "path": arrSelectedMsg[i].filePath ?? "",
                   "thumbnailPath": arrSelectedMsg[i].thumbnailPath ?? "",
                   "type": arrSelectedMsg[i].type ?? ""
               ]
                arrMsg.append(msg)
            }
             
            let param: [String: Any] = [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "sentBy": SocketChatManager.sharedInstance.myUserId,
                "fileArr": arrMsg,
                "groupArr": arrSelectedGrpList,
                "senderName": strUserName
            ]
            SocketChatManager.sharedInstance.forwardMsg(event: "forward-file", param: param)
            
            ProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                ProgressHUD.dismiss()
                SocketChatManager.sharedInstance.socket?.off("get-group-list-res")
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            let toastMsg = ToastUtility.Builder(message: "Please select Group to forward.", controller: self, keyboardActive: false)
            toastMsg.setColor(background: .red, text: .black)
            toastMsg.show()
        }
    }
}

extension ForwardMsgGrpListVC: UITableViewDelegate, UITableViewDataSource, SelectContactDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isGetChatResponse) ? (self.arrRecentChatGroupList?.count ?? 0) : 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GrpContactTVCell", for: indexPath) as! GrpContactTVCell
        if self.isGetChatResponse {
            cell.view.stopShimmeringAnimation()
            cell.btnSelectContact.isHidden = false
            cell.imgContact.isHidden = false
            cell.lblName.isHidden = false
            //cell.lblSeparator.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.5)
            cell.lblSeparator.backgroundColor = .clear
            
            cell.selectContactDelegate = self
            cell.btnSelectContact.tag = indexPath.row
            
            cell.lblName.text = self.arrRecentChatGroupList![indexPath.row].groupName ?? ""
            cell.configure(self.arrRecentChatGroupList![indexPath.row].imagePath ?? "", isGroup: self.arrRecentChatGroupList?[indexPath.row].isGroup ?? false)
            cell.btnSelectContact.isSelected = arrRecentChatGroupList?[indexPath.row].isSelected ?? false
        } else {
            cell.view.backgroundColor = .white
            cell.view.startShimmeringAnimation(animationSpeed: 3.0, direction: .leftToRight)
            cell.btnSelectContact.isHidden = true
            cell.imgContact.isHidden = true
            cell.lblName.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? GrpContactTVCell else { return }
        
        if cell.btnSelectContact.isSelected {
            for i in 0 ..< arrSelectedGrpList.count {
                if arrSelectedGrpList[i] == (arrRecentChatGroupList?[indexPath.row].groupId ?? "") {
                    arrRecentChatGroupList?[indexPath.row].isSelected = false
                    arrSelectedGrpList.remove(at: i)
                    cell.btnSelectContact.isSelected = false
                    break
                }
            }
        } else {
            arrRecentChatGroupList?[indexPath.row].isSelected = true
            arrSelectedGrpList.append(arrRecentChatGroupList?[indexPath.row].groupId ?? "")
            cell.btnSelectContact.isSelected = true
        }
    }
    
    func selectContact(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = self.tblForwardToGrp.cellForRow(at: indexPath) as? GrpContactTVCell else { return }

        if cell.btnSelectContact.isSelected {
            for i in 0 ..< arrSelectedGrpList.count {
                if arrSelectedGrpList[i] == (arrRecentChatGroupList?[indexPath.row].groupId ?? "") {
                    arrRecentChatGroupList?[indexPath.row].isSelected = false
                    arrSelectedGrpList.remove(at: i)
                    cell.btnSelectContact.isSelected = false
                    break
                }
            }
        } else {
            arrRecentChatGroupList?[indexPath.row].isSelected = true
            arrSelectedGrpList.append(arrRecentChatGroupList?[indexPath.row].groupId ?? "")
            cell.btnSelectContact.isSelected = true
        }
    }
}

extension ForwardMsgGrpListVC: SocketDelegate {
    func msgReceived(message: Message) {}
    func getRecentUser(message: String) {}
    
    func recentChatGroupList(groupList: [GetGroupList]) {
        self.arrAllRecentChatGroupList = groupList
        self.arrRecentChatGroupList = self.arrAllRecentChatGroupList
        self.tblForwardToGrp.isScrollEnabled = true
        self.isGetChatResponse = true
        self.tblForwardToGrp.reloadData()
    }
    
    func getPreviousChatMsg(message: String) {}
}

extension ForwardMsgGrpListVC : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrRecentChatGroupList = self.arrAllRecentChatGroupList
        if searchText != "" {
            self.arrRecentChatGroupList = self.arrRecentChatGroupList?.filter{
                ($0.groupName!.lowercased()).contains(searchText.lowercased())
            }
        }
        self.tblForwardToGrp.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.arrRecentChatGroupList = self.arrAllRecentChatGroupList
        self.searchBar.text = ""
        self.tblForwardToGrp.reloadData()
    }
}
