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
    
    var groupId : String = ""    //  roomId
    var isGroup: Bool = false
    var isAdmin : Bool = false
    var isRemoveMember : Bool = false
    var groupDetail: GroupDetail?
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
    var isImagePickerOpen: Bool = false
    var bundle = Bundle()
    
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
        
        self.txtUserName.isEnabled = false
        self.btnUpdate.isHidden = true
        self.btnProfilePic.isHidden = true
        
        self.txtUserName.layer.cornerRadius = self.txtUserName.frame.height / 2
        self.txtUserName.layer.borderColor = UIColor.black.cgColor
        self.txtUserName.layer.borderWidth = 0
        
        tblParticipants.dataSource = self
        tblParticipants.delegate = self
        
        let bundle = Bundle(for: ContactInfoVC.self)
        tblParticipants.register(UINib(nibName: "ParticipantsTVCell", bundle: bundle), forCellReuseIdentifier: "ParticipantsTVCell")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        bundle = Bundle(for: ContactInfoVC.self)
        
        self.navigationController?.isNavigationBarHidden = true
        viewProfilePic.layer.cornerRadius = viewProfilePic.frame.width / 2
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        
        if !isImagePickerOpen {
            self.groupDetailSocketCall()
        } else {
            self.isImagePickerOpen = false
        }
    }
    
    func groupDetailSocketCall() {
        SocketChatManager.sharedInstance.reqGroupDetail(param: [
            "userId": SocketChatManager.sharedInstance.myUserId,
            "secretKey": SocketChatManager.sharedInstance.secretKey,
            "groupId": groupId
        ])    // Need for detail screen
    }
    
    func getGroupDetail(groupDetail : GroupDetail) {
        self.groupDetail = groupDetail
        groupId = self.groupDetail?.groupId ?? ""
        isGroup = self.groupDetail?.isGroup ?? false
        
        if isGroup {
            self.imgProfile.image = UIImage(named: "group-placeholder.jpg", in: bundle, compatibleWith: nil)
            viewExit.isHidden = false
            viewTblAddParticiExitGrp.isHidden = false
            strProfileImg = self.groupDetail?.groupImage ?? ""
            
            txtUserName.text = (self.groupDetail?.name)!
            txtUserName.isEnabled = false
            lblEmail.text = "\((self.groupDetail?.users?.count)!) participants"
            if (self.groupDetail?.createdBy)! == SocketChatManager.sharedInstance.myUserId {
                isAdmin = true
                isRemoveMember = true
                
                txtUserName.isEnabled = true
                viewDelete.isHidden = false
                //btnUpdate.isHidden = false
                btnProfilePic.isHidden = false
                viewParticipants.isHidden = false
                lblParticipants.text = "\((self.groupDetail?.users?.count)!) participants"
                constraintHeightParticipants.constant = 40
                btnDelete.setTitle("Delete Group", for: .normal)
                //constraintTopViewDelete.priority = .defaultHigh
                //self.constraintHeighttblParticipants.constant = CGFloat((self.groupDetail?.users?.count)! * 70)
                self.viewScrollView.layoutIfNeeded()
            }
            self.constraintHeighttblParticipants.constant = CGFloat((self.groupDetail?.users?.count)! * 70)
            self.setPermissions()
        } else {
            self.imgProfile.image = UIImage(named: "placeholder-profile-img.png", in: bundle, compatibleWith: nil)
            
            viewTblAddParticiExitGrp.isHidden = true
            
            constraintHeighttblParticipants.priority = .defaultLow
            constraintBottomDeleteGroup.priority = .defaultLow
            constraintHeightViewTblAddParticipants.priority = .required
            
            if SocketChatManager.sharedInstance.userRole?.deleteChat ?? 0 == 1 {
                viewDelete.isHidden = false
                btnDelete.setTitle("Delete Chat", for: .normal)
            }
            
            for i in 0 ..< (self.groupDetail?.users?.count)! {
                if (self.groupDetail?.users?[i].userId)! != SocketChatManager.sharedInstance.myUserId {
                    //lblUserName.text = (self.groupDetail?.users?[i].name)!
                    txtUserName.text = (self.groupDetail?.users?[i].name)!
                    lblEmail.text = (self.groupDetail?.users?[i].mobileEmail)!
                    strProfileImg = self.groupDetail?.users?[i].profilePicture ?? ""
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
            //self.imgProfile.image = nil
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
        self.tblParticipants.reloadData()
    }
    
    func setPermissions() {
        if self.groupDetail?.groupPermission?[0].permission?.addProfilePicture ?? 0 == 0 {
            btnProfilePic.isHidden = true
            //btnUpdate.isHidden = true
        }
        
        if self.groupDetail?.groupPermission?[0].permission?.changeGroupName ?? 0 == 0 {
            self.txtUserName.layer.borderWidth = 0.0
            txtUserName.isEnabled = false
            //btnUpdate.isHidden = true
        } else {
            //self.txtUserName.layer.borderWidth = 1.0
        }
        
        if (self.groupDetail?.groupPermission?[0].permission?.addProfilePicture ?? 0 == 1) || (self.groupDetail?.groupPermission?[0].permission?.changeGroupName ?? 0 == 1) {
            btnUpdate.isHidden = false
        }
        
        if self.groupDetail?.groupPermission?[0].permission?.addMember ?? 0 == 1 {
            viewParticipants.isHidden = false
            lblParticipants.text = "\((self.groupDetail?.users?.count)!) participants"
            constraintHeightParticipants.constant = 40
        }
        
        if self.groupDetail?.groupPermission?[0].permission?.removeMember ?? 0 == 1 {
            isRemoveMember = true
        }
        
        if self.groupDetail?.groupPermission?[0].permission?.exitGroup ?? 0 == 0 {
            viewExit.isHidden = true
            constraintHeightExitGroup.constant = 0
            //constraintHeightExitGroup.constant = 60
        }
        
        if self.groupDetail?.groupPermission?[0].permission?.deleteChat ?? 0 == 0 {
            viewDelete.isHidden = true
            constraintHeightDeleteGroup.constant = 0
            constraintBottomDeleteGroup.constant = 0
        } else {
            viewDelete.isHidden = false
            constraintHeightDeleteGroup.constant = 60
            constraintBottomDeleteGroup.constant = 8
        }
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        //userChatVC!().memberRemoveRes(true, updatedRecentChatUser: recentChatUser!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddMemberTap(_ sender: UIButton) {
        arrSelectedUser.removeAll()
        arrUserIds.removeAll()
        for i in 0 ..< (groupDetail?.users!.count)! {
            arrUserIds.append((groupDetail?.users![i].userId)!)
            let contectDetail = ["userId" : self.groupDetail?.users![i].userId ?? "",//self.groupDetail?.users![i].userId ?? "",
                                 "profilePicture" : self.groupDetail?.users![i].profilePicture ?? "",
                                 "name" : self.groupDetail?.users![i].name ?? "",
                                 "mobile_email" : self.groupDetail?.users![i].mobileEmail ?? ""] as [String : Any]
            arrSelectedUser.append(contectDetail)
        }
        
        let vc =  GroupContVC()
        vc.arrUserIds = arrUserIds
        vc.arrSelectedUser = arrSelectedUser
        vc.isAddMember = true
        vc.groupId = groupId
        vc.groupDetail = groupDetail
        vc.contectInfoVC = { return self }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnExitDeleteTap(_ sender: UIButton) {
        if sender.tag == 0 {
            // 0 for Exit
            if (groupDetail?.isGroup)! {
                //(groupId, userId)
                let alertController = UIAlertController(title: "Are you sure you want to exit group ?", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    ProgressHUD.show()
                    SocketChatManager.sharedInstance.exitGroup(param: [
                        "userId" : SocketChatManager.sharedInstance.myUserId,
                        "secretKey": SocketChatManager.sharedInstance.secretKey,
                        "groupId" : self.groupId])
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                }
                alertController.addAction(OKAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else if sender.tag == 1 {
            // 1 for Delete
            if (groupDetail?.isGroup)! {
                let alertController = UIAlertController(title: "Are you sure you want to delete group ?", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                    //Delete group
                    ProgressHUD.show()
                    SocketChatManager.sharedInstance.deleteGroup(param: [
                        "userId" : SocketChatManager.sharedInstance.myUserId,
                        "secretKey": SocketChatManager.sharedInstance.secretKey,
                        "groupId" : self.groupId
                    ], from: false)
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
                    SocketChatManager.sharedInstance.deleteChat(param: [
                        "userId" : SocketChatManager.sharedInstance.myUserId,
                        "secretKey": SocketChatManager.sharedInstance.secretKey,
                        "groupId" : self.groupId
                    ], from: false)
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
            //self.navigationController?.popViewController(animated: true)
        } else {
            ProgressHUD.dismiss()
            let toastMsg = ToastUtility.Builder(message: "Group details not updated.", controller: self, keyboardActive: false)
            toastMsg.setColor(background: .red, text: .black)
            toastMsg.show()
        }
    }
    
    @IBAction func btnUpdateTap(_ sender: UIButton) {
        var param = ["groupId" : groupId,
                     "name" : txtUserName.text!,
                     "groupImage" : self.groupDetail?.groupImage ?? "",
                     "fileName" : imgFileName,
                     "contentType" : mimeType,
                     "secretKey" : SocketChatManager.sharedInstance.secretKey] as [String : Any]
        
        let apiParam = [
            "secretKey": SocketChatManager.sharedInstance.secretKey,
            "userId": SocketChatManager.sharedInstance.myUserId,
            "groupId": "",
            "senderName": "",
            "type": "image",
            "image": imgFileName != "" ? imgFileName : "",
            "isChat": 0,
        ] as [String : Any]
        
        if isPictureSelect {
            ProgressHUD.show()
            DispatchQueue.main.async {
                NetworkManager.sharedInstance.uploadImage(dictiParam: apiParam, image: self.imgProfile.image!, type: "image", contentType: "") { imgUrl in
                    param["groupImage"] = imgUrl
                    self.isPictureSelect = false
                    SocketChatManager.sharedInstance.updateGroup(param: param)
                } errorCompletion: { errMsg in
                    ProgressHUD.dismiss()
                    let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                    toastMsg.setColor(background: .red, text: .black)
                    toastMsg.show()
                }
            }
        } else {
            isPictureSelect = false
            ProgressHUD.show()
            SocketChatManager.sharedInstance.updateGroup(param: param)
        }
    }
    
    @IBAction func btnProfilePicTap(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.openGallary()
        /*let alert = UIAlertController(title: "", message: "Please select an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { alert in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { alert in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { alert in
        }))
        self.present(alert, animated: true) {
        }   //  */
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
            imagePicker.mediaTypes = ["public.image"]
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
                imgFileName = imgFileName == "" ? (URL(string: "\(info[.imageURL]!)")?.lastPathComponent)! : imgFileName
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
                imgFileName = "\(Utility.fileName()).png"
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
