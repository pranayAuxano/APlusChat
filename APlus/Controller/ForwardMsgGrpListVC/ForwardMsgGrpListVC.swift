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
        tblForwardToGrp.register(UINib(nibName: "ForwardGrpTVCell", bundle: bundle), forCellReuseIdentifier: "ForwardGrpTVCell")
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

extension ForwardMsgGrpListVC: UITableViewDelegate, UITableViewDataSource, SelectGrpToForwardDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isGetChatResponse) ? (self.arrRecentChatGroupList?.count ?? 0) : 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ForwardGrpTVCell", for: indexPath) as! ForwardGrpTVCell
        if self.isGetChatResponse {
            cell.mainView.stopShimmeringAnimation()
            cell.btnSelectGrp.isHidden = false
            cell.imgGrpIcon.isHidden = false
            cell.lblGrpName.isHidden = false
            
            cell.selectGrpToForwardDelegate = self
            cell.btnSelectGrp.tag = indexPath.row
            
            cell.lblGrpName.text = self.arrRecentChatGroupList![indexPath.row].groupName ?? ""
            cell.configure(self.arrRecentChatGroupList![indexPath.row].imagePath ?? "", isGroup: self.arrRecentChatGroupList?[indexPath.row].isGroup ?? false)
            cell.btnSelectGrp.isSelected = arrRecentChatGroupList?[indexPath.row].isSelected ?? false
        } else {
            cell.mainView.backgroundColor = .white
            cell.mainView.startShimmeringAnimation(animationSpeed: 3.0, direction: .leftToRight)
            cell.btnSelectGrp.isHidden = true
            cell.imgGrpIcon.isHidden = true
            cell.lblGrpName.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ForwardGrpTVCell else { return }
        
        if cell.btnSelectGrp.isSelected {
            for i in 0 ..< arrSelectedGrpList.count {
                if arrSelectedGrpList[i] == (arrRecentChatGroupList?[indexPath.row].groupId ?? "") {
                    arrRecentChatGroupList?[indexPath.row].isSelected = false
                    arrSelectedGrpList.remove(at: i)
                    cell.btnSelectGrp.isSelected = false
                    break
                }
            }
        } else {
            arrRecentChatGroupList?[indexPath.row].isSelected = true
            arrSelectedGrpList.append(arrRecentChatGroupList?[indexPath.row].groupId ?? "")
            cell.btnSelectGrp.isSelected = true
        }
    }
    
    func selectGrpToForward(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = self.tblForwardToGrp.cellForRow(at: indexPath) as? ForwardGrpTVCell else { return }

        if cell.btnSelectGrp.isSelected {
            for i in 0 ..< arrSelectedGrpList.count {
                if arrSelectedGrpList[i] == (arrRecentChatGroupList?[indexPath.row].groupId ?? "") {
                    arrRecentChatGroupList?[indexPath.row].isSelected = false
                    arrSelectedGrpList.remove(at: i)
                    cell.btnSelectGrp.isSelected = false
                    break
                }
            }
        } else {
            arrRecentChatGroupList?[indexPath.row].isSelected = true
            arrSelectedGrpList.append(arrRecentChatGroupList?[indexPath.row].groupId ?? "")
            cell.btnSelectGrp.isSelected = true
        }

        /*if arrSelectedGrpList.count > 0 {
            btnSend.backgroundColor = UIColor(red: 15/255.0, green: 101/255.0, blue: 158/255.0, alpha: 1)
            btnSend.isEnabled = true
        } else {
            btnSend.backgroundColor = UIColor(red: 104/255.0, green: 162/255.0, blue: 254/255.0, alpha: 1)
            btnSend.isEnabled = false
        }   //  */
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
