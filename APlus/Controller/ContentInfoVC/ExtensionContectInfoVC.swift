//
//  ExtensionContectInfoVC.swift
//  agsChat
//
//  Created by MAcBook on 12/08/22.
//

import Foundation
import UIKit

extension ContactInfoVC : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupDetail?.users?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantsTVCell", for: indexPath) as! ParticipantsTVCell
        
        cell.contectInfoVC = {
            return self
        }
        cell.btnRemove.tag = indexPath.row
        cell.strUserId = self.groupDetail?.users?[indexPath.row].userId ?? ""
        cell.lblAdmin.isHidden = true
        cell.btnRemove.isHidden = true
        
        if (self.groupDetail?.users?[indexPath.row].userId)! == SocketChatManager.sharedInstance.myUserId {
            cell.lblUserName.text = "\((self.groupDetail?.users?[indexPath.row].name)!) (You)"
        } else {
            cell.lblUserName.text = (self.groupDetail?.users?[indexPath.row].name)!
        }
        
        cell.lblAdmin.isHidden = true
        cell.btnRemove.isHidden = true
        if isAdmin {
            if (self.groupDetail?.users?[indexPath.row].userId)! == SocketChatManager.sharedInstance.myUserId {
                cell.lblAdmin.isHidden = false
            }
        } else {
            if (self.groupDetail?.users?[indexPath.row].userId)! == self.groupDetail?.createdBy ?? "" {
                cell.lblAdmin.isHidden = false
            }
        }
        
        if isRemoveMember {
            if (self.groupDetail?.users?[indexPath.row].userId)! != SocketChatManager.sharedInstance.myUserId {
                cell.btnRemove.isHidden = false
            }
        }
        cell.configure(self.groupDetail?.users?[indexPath.row].profilePicture ?? "")
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func removeUserTap(_ id: String) {
        arrSelectedUser.removeAll()
        arrUserIds.removeAll()
        strRemovedUserId = id
        for i in 0 ..< (groupDetail?.users!.count)! {
            if groupDetail?.users![i].userId ?? "" != id {
                arrUserIds.append((groupDetail?.users![i].userId)!)
                let contectDetail = ["userId" : self.groupDetail?.users![i].userId ?? "",
                                     "profilePicture" : self.groupDetail?.users![i].profilePicture ?? "",
                                     "name" : self.groupDetail?.users![i].name ?? "",
                                     "mobile_email" : self.groupDetail?.users![i].mobileEmail ?? ""
                ] as [String : Any]
                arrSelectedUser.append(contectDetail)
            }
        }
        
        let param = [
            "secretKey": SocketChatManager.sharedInstance.secretKey,
            "groupId": groupDetail?.groupId ?? "",
            "members": arrUserIds,
            "viewBy": arrUserIds,
            "users": arrSelectedUser,
            "removeMember": "\(id)"
        ] as [String : Any]
        
        SocketChatManager.sharedInstance.removeMember(param: param)
    }
    
    func removeMemberRes(_ isUpdate : Bool) {
        if isUpdate {
            self.groupDetailSocketCall()
        } else {
            let alertController = UIAlertController(title: "Member not removed.", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
