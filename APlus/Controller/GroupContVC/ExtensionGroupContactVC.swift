//
//  ExtensionGroupContactVC.swift
//  agsChat
//
//  Created by MAcBook on 11/07/22.
//

import Foundation
import UIKit
import CoreAudio

extension GroupContVC : UITableViewDelegate, UITableViewDataSource, SelectContactDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return contactList?.list?.count ?? 0
        return arrContactList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GrpContactTVCell", for: indexPath) as! GrpContactTVCell
        cell.imgContact.layer.cornerRadius = cell.imgContact.frame.height / 2
        cell.lblSeparator.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.5)
        cell.selectContactDelegate = self
        cell.btnSelectContact.tag = indexPath.row
        
        cell.imgContact.image = UIImage(named: "placeholder-profile-img.png", in: self.bundle, compatibleWith: nil)    //UIImage(named: "placeholder-profile-img.png")
        cell.lblName.text = arrContactList?[indexPath.row].name ?? ""
        cell.configure(arrContactList?[indexPath.row].profilePicture ?? "")
        
        cell.btnSelectContact.isSelected = arrContactList?[indexPath.row].isSelected ?? false
        
        let arr = (self.arrSelectedContactList?.filter({ $0.userId == arrContactList?[indexPath.row].userId ?? "" }))!
        if arr.count > 0 {
            arrContactList?[indexPath.row].isSelected = true
            cell.btnSelectContact.isSelected = true
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? GrpContactTVCell else { return }
        
        if cell.btnSelectContact.isSelected {
            for i in 0 ..< (arrSelectedContactList?.count)! {
                if (arrSelectedContactList?[i].userId)! == (arrContactList?[indexPath.row].userId)! {
                    arrContactList?[indexPath.row].isSelected = false
                    arrSelectedContactList?.remove(at: i)
                    cell.btnSelectContact.isSelected = false
                    break
                }
            }
            
            for i in 0 ..< self.addMembersArr.count {
                if self.addMembersArr[i] == (arrContactList?[indexPath.row].userId ?? "") {
                    self.addMembersArr.remove(at: i)
                    break
                }
            }
        } else {
            arrContactList?[indexPath.row].isSelected = true
            arrSelectedContactList?.append((arrContactList?[indexPath.row])!)
            cell.btnSelectContact.isSelected = true
            self.addMembersArr.append("\(arrContactList?[indexPath.row].userId ?? "")")
        }
        
        if (arrSelectedContactList?.count)! > 0 {
            btnNext.backgroundColor = UIColor(red: 15/255.0, green: 101/255.0, blue: 158/255.0, alpha: 1)
            btnNext.isEnabled = true
        } else {
            btnNext.backgroundColor = UIColor(red: 104/255.0, green: 162/255.0, blue: 254/255.0, alpha: 1)
            btnNext.isEnabled = false
        }
    }
    
    func selectContact(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        guard let cell = self.tblContact.cellForRow(at: indexPath) as? GrpContactTVCell else { return }
        
        if cell.btnSelectContact.isSelected {
            for i in 0 ..< (arrSelectedContactList?.count)! {
                if (arrSelectedContactList?[i].userId)! == (arrContactList?[indexPath.row].userId)! {
                    arrSelectedContactList?.remove(at: i)
                    cell.btnSelectContact.isSelected = false
                    break
                }
            }
            
            for i in 0 ..< self.addMembersArr.count {
                if self.addMembersArr[i] == (arrContactList?[indexPath.row].userId ?? "") {
                    self.addMembersArr.remove(at: i)
                    break
                }
            }
        } else {
            arrSelectedContactList?.append((arrContactList?[indexPath.row])!)
            cell.btnSelectContact.isSelected = true
            self.addMembersArr.append("\(arrContactList?[indexPath.row].userId ?? "")")
        }
        
        if (arrSelectedContactList?.count)! > 0 {
            btnNext.backgroundColor = UIColor(red: 15/255.0, green: 101/255.0, blue: 158/255.0, alpha: 1)
            btnNext.isEnabled = true
        } else {
            btnNext.backgroundColor = UIColor(red: 104/255.0, green: 162/255.0, blue: 254/255.0, alpha: 1)
            btnNext.isEnabled = false
        }
    }
}

extension GroupContVC : UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrContactList = self.arrAllContactList?.filter{ ($0.name?.lowercased().prefix(searchText.count))! == searchText.lowercased() }
        //print(searchText)
        self.tblContact.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.arrContactList = self.arrAllContactList
        self.searchBar.text = ""
        self.tblContact.reloadData()
    }
}
