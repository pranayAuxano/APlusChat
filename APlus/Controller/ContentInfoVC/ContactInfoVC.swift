//
//  ContactInfoVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import ProgressHUD
import Photos

public class ContactInfoVC: UIViewController {

    @IBOutlet weak var viewMainContectInfo: UIView!
    @IBOutlet weak var viewContectInfo: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblContectInfo: UILabel!
    @IBOutlet weak var viewProfilePic: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var viewDeleteChat: UIView!
    @IBOutlet weak var viewParticipants: UIView!
    @IBOutlet weak var lblParticipants: UILabel!
    @IBOutlet weak var btnAddMember: UIButton!
    @IBOutlet weak var tblParticipants: UITableView!
    @IBOutlet weak var viewExit: UIView!
    @IBOutlet weak var viewDelete: UIView!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var constraintHeightParticipants: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightViewDelete: NSLayoutConstraint!
    @IBOutlet weak var viewTblAddParticiExitGrp: UIView!
    @IBOutlet weak var constraintHeightViewTblAddParticipants: NSLayoutConstraint!
    @IBOutlet weak var constraintTopViewDelete: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomViewDelete: NSLayoutConstraint!
    @IBOutlet weak var constraintTopToUsernameViewDelete: NSLayoutConstraint!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var constraintHeighttblParticipants: NSLayoutConstraint!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var viewScrollView: UIView!
    @IBOutlet weak var constraintHeightExitGroup: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightDeleteGroup: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomDeleteGroup: NSLayoutConstraint!
    
    //var myUserId : String = ""
    var groupId : String = ""    //  roomId
    var isAdmin : Bool = false
    var isRemoveMember : Bool = false
    var recentChatUser : GetUserList?
    var strProfileImg : String?
    var imagePicker = UIImagePickerController()
    var arrReadCount : [[String: Any]] = []//["unreadCount":0, "userId":""]
    var arrUserIds : [String] = []
    var arrSelectedUser : [[String: Any]] = []
    var strRemovedUserId : String = ""
    var userChatVC: (()->ChatVC)?
    
    var imgFileName : String = ""
    var isCameraOpen : Bool = false
    var mimeType : String = ""
    var isPictureSelect : Bool = false
    
    public init() {
        super.init(nibName: "ContactInfo", bundle: Bundle(for: ContactInfoVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented ContactInfoVC")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        btnUpdate.layer.cornerRadius = 5
        btnProfilePic.layer.cornerRadius = btnProfilePic.frame.height / 2
        
        txtUserName.delegate = self
        viewExit.isHidden = true
        viewDelete.isHidden = true
        viewTblAddParticiExitGrp.isHidden = true
        viewParticipants.isHidden = true
        constraintHeightParticipants.constant = -8
        
        SocketChatManager.sharedInstance.contectInfoVC = {
            return self
        }
        
        txtUserName.isEnabled = false
        btnUpdate.isHidden = true
        btnProfilePic.isHidden = true
        
        if (recentChatUser?.isGroup)! {
            self.imgProfile.image = UIImage(named: "group-placeholder")
            viewExit.isHidden = false
            viewTblAddParticiExitGrp.isHidden = false
            strProfileImg = recentChatUser?.groupImage ?? ""
            
            txtUserName.text = (recentChatUser?.name)!
            txtUserName.isEnabled = false
            lblEmail.text = "\((recentChatUser?.users?.count)!) participants"
            if (recentChatUser?.createdBy)! == SocketChatManager.sharedInstance.myUserId {
                isAdmin = true
                isRemoveMember = true
                
                txtUserName.isEnabled = true
                viewDelete.isHidden = false
                btnUpdate.isHidden = false
                btnProfilePic.isHidden = false
                viewParticipants.isHidden = false
                lblParticipants.text = "\((recentChatUser?.users?.count)!) participants"
                constraintHeightParticipants.constant = 40
                btnDelete.setTitle("Delete Group", for: .normal)
                //constraintTopViewDelete.priority = .defaultHigh
                
            } else {
                if recentChatUser?.groupPermission?[0].permission?.addProfilePicture ?? 0 == 1 {
                    btnProfilePic.isHidden = false
                    btnUpdate.isHidden = false
                }
                if recentChatUser?.groupPermission?[0].permission?.changeGroupName ?? 0 == 1 {
                    txtUserName.isEnabled = true
                    btnUpdate.isHidden = false
                }
                if recentChatUser?.groupPermission?[0].permission?.addMember ?? 0 == 1 {
                    viewParticipants.isHidden = false
                    lblParticipants.text = "\((recentChatUser?.users?.count)!) participants"
                    constraintHeightParticipants.constant = 40
                }
                if recentChatUser?.groupPermission?[0].permission?.removeMember ?? 0 == 1 {
                    isRemoveMember = true
                }
                if recentChatUser?.groupPermission?[0].permission?.exitGroup ?? 0 != 1 {
                    viewExit.isHidden = true
                    constraintHeightExitGroup.constant = 0
                    //constraintHeightExitGroup.constant = 60
                } //else {
                    //constraintHeightExitGroup.constant = 0
                //}
                if recentChatUser?.groupPermission?[0].permission?.deleteChat ?? 0 != 1 {
                    viewDelete.isHidden = true
                    constraintHeightDeleteGroup.constant = 0
                    constraintBottomDeleteGroup.constant = 0
                } else {
                    viewDelete.isHidden = false
                    constraintHeightDeleteGroup.constant = 60
                    constraintBottomDeleteGroup.constant = 8
                }
                //constraintHeightDeleteGroup.constant = 0
                //constraintBottomDeleteGroup.constant = 0
            }
        } else {
            self.imgProfile.image = UIImage(named: "placeholder-profile-img")
            
            viewTblAddParticiExitGrp.isHidden = true
            
            constraintHeighttblParticipants.priority = .defaultLow
            constraintBottomDeleteGroup.priority = .defaultLow
            constraintHeightViewTblAddParticipants.priority = .required
            
            if SocketChatManager.sharedInstance.userRole?.deleteChat ?? 0 == 1 {
                viewDelete.isHidden = false
                btnDelete.setTitle("Delete Chat", for: .normal)
            }
            
            for i in 0 ..< (recentChatUser?.users?.count)! {
                if (recentChatUser?.users?[i].userId)! != SocketChatManager.sharedInstance.myUserId {
                    //lblUserName.text = (recentChatUser?.users?[i].name)!
                    txtUserName.text = (recentChatUser?.users?[i].name)!
                    lblEmail.text = (recentChatUser?.users?[i].mobileEmail)!
                    strProfileImg = recentChatUser?.users?[i].profilePicture ?? ""
                }
            }
            if #available(iOS 15.0, *) {
                tblParticipants.sectionHeaderTopPadding = 0.0
            } else {
                // Fallback on earlier versions
            }
        }
        
        if strProfileImg != "" {
            var imageURL: URL?
            var isFromCatch : Bool = false
            imageURL = URL(string: strProfileImg!)!
            // retrieves image if already available in cache
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgProfile.image = imageFromCache
                isFromCatch = true
            }
            if isFromCatch {
                NetworkManager.sharedInstance.getData(from: imageURL!) { data, response, err in
                    if err == nil {
                        DispatchQueue.main.async {
                            //self.imgProfile.image = UIImage(data: data!)
                            if let imageToCache = UIImage(data: data!) {
                                self.imgProfile.image = imageToCache
                                imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                            }
                        }
                    }
                }
            }
        }
        
        tblParticipants.dataSource = self
        tblParticipants.delegate = self
        
        let bundle = Bundle(for: ContactInfoVC.self)
        tblParticipants.register(UINib(nibName: "ParticipantsTVCell", bundle: bundle), forCellReuseIdentifier: "ParticipantsTVCell")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        viewProfilePic.layer.cornerRadius = viewProfilePic.frame.width / 2
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        
        self.constraintHeighttblParticipants.constant = CGFloat((self.recentChatUser?.users?.count)! * 70)
        self.viewScrollView.layoutIfNeeded()
    }
    
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        userChatVC!().memberRemoveRes(true, updatedRecentChatUser: recentChatUser!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddMemberTap(_ sender: UIButton) {
        arrSelectedUser.removeAll()
        arrUserIds.removeAll()
        for i in 0 ..< (recentChatUser?.users!.count)! {
            arrUserIds.append((recentChatUser?.users![i].userId)!)
            let contectDetail = ["userId" : recentChatUser?.users![i].userId ?? "",
                                 "serverUserId" : recentChatUser?.users![i].serverUserId ?? "",
                                 "profilePicture" : recentChatUser?.users![i].profilePicture ?? "",
                                 "name" : recentChatUser?.users![i].name ?? "",
                                 "mobile_email" : recentChatUser?.users![i].mobileEmail ?? "",
                                 "groups" : recentChatUser?.users![i].groups ?? []] as [String : Any]
            arrSelectedUser.append(contectDetail)
        }
        
        let vc =  GroupContVC()
        vc.arrUserIds = arrUserIds
        vc.arrSelectedUser = arrSelectedUser
        vc.isAddMember = true
        vc.groupId = groupId
        vc.recentChatUser = recentChatUser
        vc.contectInfoVC = { return self }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnExitDeleteTap(_ sender: UIButton) {
        if sender.tag == 0 {
            // 0 for Exit
            if (recentChatUser?.isGroup)! {
                //(groupId, userId)
                let alertController = UIAlertController(title: "Are you sure you want to exit group ?", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    ProgressHUD.show()
                    SocketChatManager.sharedInstance.exitGroup(param: ["userId" : SocketChatManager.sharedInstance.myUserId, "groupId" : self.groupId])
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                }
                alertController.addAction(OKAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else if sender.tag == 1 {
            // 1 for Delete
            if (recentChatUser?.isGroup)! {
                let alertController = UIAlertController(title: "Are you sure you want to delete group ?", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    //Delete group
                    ProgressHUD.show()
                    SocketChatManager.sharedInstance.deleteGroup(param: ["userId" : SocketChatManager.sharedInstance.myUserId, "groupId" : self.groupId], from: false)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                }
                alertController.addAction(OKAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Are you sure you want to delete chat ?", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    //Delete chat
                    ProgressHUD.show()
                    SocketChatManager.sharedInstance.deleteChat(param: ["userId" : SocketChatManager.sharedInstance.myUserId, "groupId" : self.groupId], from: false)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                }
                alertController.addAction(OKAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func responseBack(_ isUpdate : Bool) {
        ProgressHUD.dismiss()
        if isUpdate {
            /*let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc =  sb.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.popToViewController(vc, animated: true)  //  */
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnUpdateTap(_ sender: UIButton) {
        let param = ["groupId" : groupId, "name" : txtUserName.text!, "groupImage" : isPictureSelect ? (imgProfile.image)?.pngData() : "", "fileName" : imgFileName, "contentType" : mimeType] as [String : Any]
        isPictureSelect = false
        
        ProgressHUD.show()
        SocketChatManager.sharedInstance.updateGroup(param: param)
    }
    
    /*@IBAction func btnUpdateTap(_ sender: UIButton) {
        var param = ["groupId" : groupId, "name" : txtUserName.text!, "groupImage" : isPictureSelect ? (imgProfile.image)?.pngData() : "", "fileName" : imgFileName, "contentType" : mimeType] as [String : Any]
        
        if isPictureSelect {
            ProgressHUD.show()
            DispatchQueue.main.async {
                NetworkManager.sharedInstance.uploadMedia(fileName: self.imgFileName, image: ((self.imgProfile.image)?.pngData()!.bytes)!, contentType: self.imgFileName.mimeType()) { url in
                    print(url)
                    if url != "" {
                        let param = ["groupId" : self.groupId, "name" : self.txtUserName.text!, "groupImage" : url, "fileName" : self.imgFileName, "contentType" : self.mimeType] as [String : Any]
                        self.isPictureSelect = false
                        
                        SocketChatManager.sharedInstance.updateGroup(param: param)
                    }
                    else {
                        ProgressHUD.dismiss()
                    }
                }
            }
        } else {
            isPictureSelect = false
            
            ProgressHUD.show()
            SocketChatManager.sharedInstance.updateGroup(param: param)
        }
    }
    /// */
    
    func profileUpdateRes(_ isUpdate : Bool) {
        if isUpdate {
            ProgressHUD.dismiss()
            
            let alertController = UIAlertController(title: "Profile updated successfully.", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                //Update profile.
                //self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func addMemberRes(userList : GetUserList) {
        recentChatUser = userList
        lblEmail.text = "\((recentChatUser?.users?.count)!) participants"
        lblParticipants.text = "\((recentChatUser?.users?.count)!) participants"
        self.tblParticipants.reloadData()
        
        DispatchQueue.main.async {
            self.constraintHeighttblParticipants.constant = self.tblParticipants.contentSize.height
            self.updateViewConstraints()
        }
    }
    
    @IBAction func btnProfilePicTap(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let alert = UIAlertController(title: "", message: "Please select an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { alert in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { alert in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alert in
        }))
        self.present(alert, animated: true) {
        }
    }
}

extension ContactInfoVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            isCameraOpen = false
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertController(title: "", message: "Camera not available.", preferredStyle: .alert)
            alertWarning.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            }))
            self.present(alertWarning, animated: true)
        }
    }
    
    func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true) {
            }
            
            var isImgLoad : Bool = false
            if !isCameraOpen {
                let photo = info[.phAsset] as? PHAsset
                imgFileName = photo?.value(forKey: "filename") as? String ?? ""
                print(imgFileName)
                mimeType = imgFileName.mimeType()
                isImgLoad = true
            } else {
                guard let image = info[.editedImage] as? UIImage else {
                    print("No image found")
                    return
                }
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                //let imageName = "\(Utility.fileName()).JPEG"
                imgFileName = "\(Utility.fileName()).JPEG"
                let fileUrl = documentsDirectory.appendingPathComponent(imgFileName)
                mimeType = fileUrl.mimeType()
                //guard let data = image.jpegData(compressionQuality: 1) else { return }
                guard let data = image.pngData() else { return }
                do {
                    try data.write(to: fileUrl)
                    isImgLoad = true
                } catch let error {
                    print("error saving file with error --", error)
                }
                isCameraOpen = false
            }
            
            if isImgLoad {
                imgProfile.contentMode = .scaleAspectFill
                imgProfile.image = pickedImage
                isPictureSelect = true
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCameraOpen = false
        self.dismiss(animated: true) {
        }
    }
}

extension ContactInfoVC : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
}
