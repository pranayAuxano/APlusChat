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
        return (recentChatUser?.users?.count)!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantsTVCell", for: indexPath) as! ParticipantsTVCell
        
        cell.contectInfoVC = {
            return self
        }
        cell.btnRemove.tag = indexPath.row
        cell.strUserId = recentChatUser?.users?[indexPath.row].userId ?? ""
        cell.lblAdmin.isHidden = true
        cell.btnRemove.isHidden = true
        
        if (recentChatUser?.users?[indexPath.row].userId)! == SocketChatManager.sharedInstance.myUserId {
            cell.lblUserName.text = "\((recentChatUser?.users?[indexPath.row].name)!) (You)"
        } else {
            cell.lblUserName.text = (recentChatUser?.users?[indexPath.row].name)!
        }
        
        /*///
        if isAdmin {
            if (recentChatUser?.users?[indexPath.row].userId)! == SocketChatManager.sharedInstance.myUserId {
                cell.lblAdmin.isHidden = false
                cell.btnRemove.isHidden = true
            } else {
                cell.lblAdmin.isHidden = true
                cell.btnRemove.isHidden = false
            }
        }
        /// */
        cell.lblAdmin.isHidden = true
        cell.btnRemove.isHidden = true
        if isAdmin {
            if (recentChatUser?.users?[indexPath.row].userId)! == SocketChatManager.sharedInstance.myUserId {
                cell.lblAdmin.isHidden = false
            }
        }
        if isRemoveMember {
            if (recentChatUser?.users?[indexPath.row].userId)! != SocketChatManager.sharedInstance.myUserId {
                cell.btnRemove.isHidden = false
            }
        }
        cell.configure(recentChatUser?.users?[indexPath.row].profilePicture ?? "")
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension
        return 70
    }
    
    func removeUserTap(_ id: String) {
        arrSelectedUser.removeAll()
        strRemovedUserId = id
        for i in 0 ..< (recentChatUser?.users!.count)! {
            if recentChatUser?.users![i].userId ?? "" != id {
                arrUserIds.append((recentChatUser?.users![i].userId)!)
                let contectDetail = ["userId" : recentChatUser?.users![i].userId ?? "",
                                     "serverUserId" : recentChatUser?.users![i].serverUserId ?? "",
                                     "profilePicture" : recentChatUser?.users![i].profilePicture ?? "",
                                     "name" : recentChatUser?.users![i].name ?? "",
                                     "mobile_email" : recentChatUser?.users![i].mobileEmail ?? "",
                                     "groups" : recentChatUser?.users![i].groups ?? []] as [String : Any]
                arrSelectedUser.append(contectDetail)
            }
        }   //  */
        
        let param = [
            "secretKey": SocketChatManager.sharedInstance.secretKey,
          "groupId": recentChatUser?.groupId ?? "",
          "members": arrUserIds,
          "viewBy": arrUserIds,
          "users": arrSelectedUser] as [String : Any]
        
        //["groupDetails": param]
        SocketChatManager.sharedInstance.removeMember(param: param)
    }
    
    func removeMemberRes(_ isUpdate : Bool) {
        if isUpdate {
            print("Member removed.")
            
            for i in 0 ..< (recentChatUser?.users!.count)! {
                if recentChatUser?.users![i].userId ?? "" == strRemovedUserId {
                    recentChatUser?.users!.remove(at: i)
                    break
                }
            }
            tblParticipants.reloadData()
            
            lblEmail.text = "\((recentChatUser?.users?.count)!) participants"
            lblParticipants.text = "\((recentChatUser?.users?.count)!) participants"
            
            DispatchQueue.main.async {
                self.constraintHeighttblParticipants.constant = CGFloat((self.recentChatUser?.users?.count)! * 70)
                self.updateViewConstraints()
            }
            
            userChatVC!().memberRemoveRes(true, updatedRecentChatUser: recentChatUser!)
        } else {
            let alertController = UIAlertController(title: "Member not removed.", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
