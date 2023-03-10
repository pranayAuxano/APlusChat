//
//  ProfDetailVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit
import ProgressHUD

protocol ProfileImgDelegate {
    func setProfileImg(image : UIImage)
}

public class ProfDetailVC: UIViewController {

    @IBOutlet weak var viewProfileTop: UIView!
    @IBOutlet weak var viewBackBtn: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var viewProfileImg: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnProfileImg: UIButton!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var imagePicker = UIImagePickerController()
    var profileImgDelegate : ProfileImgDelegate?
    var profileDetail : ProfileDetail?
    var imgFileName : String = ""
    
    var isCameraOpen : Bool = false
    var mimeType : String = ""
    var isPictureSelect : Bool = false
    
    //var myUserId : String = "0"
    private var imageRequest: Cancellable?
    
    public init() {
        super.init(nibName: "ProfileDetail", bundle: Bundle(for: ProfDetailVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented ProfileDetail")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.profileDetail != nil {
            self.getProfileDetail(self.profileDetail!)
        } else {
            
        }
        
        txtUserName.isEnabled = false
        btnProfileImg.isEnabled = false
        btnSave.isEnabled = false
        btnSave.backgroundColor = Colors.disableButton.returnColor()
        
        if SocketChatManager.sharedInstance.userRole?.updateProfile ?? 0 == 1 {
            txtUserName.isEnabled = true
            btnProfileImg.isEnabled = true
            btnSave.isEnabled = true
            btnSave.backgroundColor = Colors.themeBlueBtn.returnColor()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        txtUserName.delegate = self
        btnSave.layer.cornerRadius = 5 //btnSave.frame.height / 4
        
        viewProfileImg.layer.cornerRadius = viewProfileImg.frame.width / 2
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        btnProfileImg.layer.cornerRadius = btnProfileImg.frame.width / 2
        
        SocketChatManager.sharedInstance.profileDetailVC = {
            return self
        }
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnProfileImgTap(_ sender: UIButton) {
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
    
    @IBAction func btnSaveTap(_ sender: UIButton) {
        if !Validations.isValidUserName(userName: txtUserName.text!) {
            let imgData = imgProfile.image?.pngData()
            SocketChatManager.sharedInstance.updateProfile(param: ["userId" : SocketChatManager.sharedInstance.myUserId, "secretKey" : SocketChatManager.sharedInstance.secretKey, "name": txtUserName.text! , "profilePicture" : isPictureSelect ? imgData : "", "fileName" : imgFileName, "contentType" : mimeType])
            isPictureSelect = false
        } else {
            let alertWarning = UIAlertController(title: "", message: "Enter username.", preferredStyle: .alert)
            alertWarning.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            }))
            self.present(alertWarning, animated: true)
        }
    }
    
   /*@IBAction func btnSaveTap(_ sender: UIButton) {
        if !Validations.isValidUserName(userName: txtUserName.text!) {
            // Save data
            //["userId" : "" , "name": "" , "profilePicture" : "" ]
            //let imgData = imgProfile.image?.pngData()
            let imgData = imgProfile.image?.pngData()?.bytes
            
            //let imgData = UIImage.jpegData(imgProfile.image!)
            
            ProgressHUD.show()
            DispatchQueue.main.async {
                NetworkManager.sharedInstance.uploadMedia(fileName: self.imgFileName, image: imgData!, contentType: self.imgFileName.mimeType()) { url in
                    print(url)
                    if url != "" {
                        SocketChatManager.sharedInstance.updateProfile(param: ["userId" : SocketChatManager.sharedInstance.myUserId, "secretKey" : SocketChatManager.sharedInstance.secretKey, "name": self.txtUserName.text! , "profilePicture" : self.isPictureSelect ? url : "", "fileName" : self.imgFileName, "contentType" : self.mimeType])
                        self.isPictureSelect = false
                    }
                    else {
                        ProgressHUD.dismiss()
                    }
                }
            }
            
            //SocketChatManager.sharedInstance.updateProfile(param: ["userId" : SocketChatManager.sharedInstance.myUserId, "secretKey" : SocketChatManager.sharedInstance.secretKey, "name": txtUserName.text! , "profilePicture" : isPictureSelect ? imgData : "", "fileName" : imgFileName, "contentType" : mimeType])
            //isPictureSelect = false
            
        } else {
            let alertWarning = UIAlertController(title: "", message: "Enter username.", preferredStyle: .alert)
            alertWarning.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            }))
            self.present(alertWarning, animated: true)
        }
    }
    /// */
    
    func getProfileDetail(_ profileDetail : ProfileDetail) {
        print("Get response of profile details.")
        txtUserName.text = profileDetail.name ?? ""
        
        imgProfile.image = UIImage(named: "placeholder-profile-img.png")
        if profileDetail.profilePicture! != "" {
            var imageURL: URL?
            imageURL = URL(string: profileDetail.profilePicture!)!
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgProfile.image = imageFromCache
                return
            }
            imageRequest = NetworkManager.sharedInstance.getData(from: imageURL!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data) {
                        self.imgProfile.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    } else {
                        self.imgProfile.image = UIImage(named: "placeholder-profile-img.png")
                    }
                }
            }
        }
    }
    
    func profileUpdate(_ isUpdate : Bool) {
        ProgressHUD.dismiss()
        var msg : String = ""
        if isUpdate {
            msg = "Profile updated successfully."
        } else {
            msg = "Profile not updated."
        }
        let alertWarning = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alertWarning.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            if isUpdate {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alertWarning, animated: true)
    }
}
