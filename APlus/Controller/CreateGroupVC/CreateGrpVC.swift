//
//  CreateGrpVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import Photos
import ProgressHUD

public class CreateGrpVC: UIViewController {

    @IBOutlet weak var viewBackCreateGrup: UIView!
    @IBOutlet weak var lblCreateGroup: UILabel!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewGroupImg: UIView!
    @IBOutlet weak var imgGroup: UIImageView!
    @IBOutlet weak var btnGroupImg: UIButton!
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var btnCreateGroup: UIButton!
    
    var imagePicker = UIImagePickerController()
    var myContactDetail : List?
    var arrSelectedContactList : [List]?
    var arrContactList : [[String: Any]] = []
    var arrReadCount : [[String: Any]] = []//["unreadCount":0, "userId":""]
    var arrUserIds : [String] = []
    
    var imgFileName : String = ""
    var isCameraOpen : Bool = false
    var mimeType : String = ""
    var isPictureSelect : Bool = false
    
    public init() {
        super.init(nibName: "CreateGrpVC", bundle: Bundle(for: CreateGrpVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented ImageViewerVC")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        txtGroupName.delegate = self
        
        SocketChatManager.sharedInstance.createGroupVC = {
            return self
        }
        
        btnCreateGroup.layer.cornerRadius = 5.0
        btnCreateGroup.isEnabled = true
        btnCreateGroup.backgroundColor = UIColor(red: 15/255.0, green: 101/255.0, blue: 158/255.0, alpha: 1)
        
        viewGroupImg.layer.cornerRadius = viewGroupImg.frame.width / 2
        imgGroup.layer.cornerRadius = imgGroup.frame.width / 2
        btnGroupImg.layer.cornerRadius = btnGroupImg.frame.width / 2
        
        arrSelectedContactList?.append(myContactDetail!)
        
        for i in 0 ..< (arrSelectedContactList?.count ?? 0) {
            arrUserIds.append(arrSelectedContactList![i].userId ?? "")
            //var readCount = UnreadCount(unreadCount: 0, userId: arrSelectedContactList![i].userId ?? "")
            let readCount = ["unreadCount": 0, "userId": arrSelectedContactList![i].userId ?? ""] as [String : Any]
            arrReadCount.append(readCount)
            //var : [String]?
            let contectDetail = ["userId" : arrSelectedContactList![i].userId ?? "",
                                 "serverUserId" : arrSelectedContactList![i].serverUserId ?? "",
                                 "profilePicture" : arrSelectedContactList![i].profilePicture ?? "",
                                 "name" : arrSelectedContactList![i].name ?? "",
                                 "mobile_email" : arrSelectedContactList![i].mobile_email ?? "",
                                 "groups" : arrSelectedContactList![i].groups ?? []] as [String : Any]
            arrContactList.append(contectDetail)
        }
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGroupImgTap(_ sender: UIButton) {
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
    
    @IBAction func btnCreateGroupTap(_ sender: UIButton) {
        if !Validations.isEmpty(str: txtGroupName.text!) {
            let param = [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "isGroup": true,
                "userId": SocketChatManager.sharedInstance.myUserId,
                "groupImage": "",
                "members": self.arrUserIds,
                "name": self.txtGroupName.text!
            ] as [String : Any]
            
            let dictiParam = [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "userId": SocketChatManager.sharedInstance.myUserId,
                "groupId": "",
                "senderName": "",
                "type": "image",
                "image": imgFileName,
                "isChat": 0
            ] as [String : Any]
            
            ProgressHUD.show()
            if isPictureSelect {
                NetworkManager.sharedInstance.uploadImage(dictiParam: dictiParam, image: imgGroup.image!, type: "image", contentType: "")
                { strDisPic in
                    self.createGroup(param: param, strDisPic: strDisPic)
                } errorCompletion: { errMsg in
                    ProgressHUD.dismiss()
                    let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                    toastMsg.setColor(background: .red, text: .black)
                    toastMsg.show()
                }
            } else {
                self.createGroup(param: param, strDisPic: "")
            }
        } else {
            let alertWarning = UIAlertController(title: "", message: "Please enter group name.", preferredStyle: .alert)
            alertWarning.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            }))
            self.present(alertWarning, animated: true)
        }
    }
    
    func createGroup(param: [String : Any], strDisPic: String) {
        var param1 = param
        param1["groupImage"] = strDisPic
        NetworkManager.sharedInstance.createGroup(param: param1) { strId in
            ProgressHUD.dismiss()
            DispatchQueue.main.async {
                // Assuming you have a reference to the navigation controller
                if let viewControllers = self.navigationController?.viewControllers {
                    for viewController in viewControllers {
                        if viewController is FirstVC {
                            self.navigationController?.popToViewController(viewController, animated: true)
                            break
                        }
                    }
                }
            }
        } errorCompletion: { errMsg in
            ProgressHUD.dismiss()
            let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
            toastMsg.setColor(background: .red, text: .black)
            toastMsg.show()
        }
    }
}

extension CreateGrpVC : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
}


extension CreateGrpVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            isCameraOpen = false
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertController(title: "", message: "You don't have camera", preferredStyle: .alert)
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
                imgGroup.contentMode = .scaleAspectFill
                imgGroup.image = pickedImage
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
