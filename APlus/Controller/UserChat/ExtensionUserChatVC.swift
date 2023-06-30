//
//  ExtensionUserChatVC.swift
//  agsChat
//
//  Created by MAcBook on 11/07/22.
//

import Foundation
import UIKit
import AVKit
import MobileCoreServices
import AVFoundation
import AVFAudio
import Photos

import JGProgressHUD
import UniformTypeIdentifiers

// MARK: - Textfiled Delegate
extension ChatVC : UITextFieldDelegate {
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.isKeyboardActive = true
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            constMainChatViewBottom.constant = keyboardSize.height - 35
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.isKeyboardActive = false
        constMainChatViewBottom.constant = 0
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 0 {
            timeSeconds = 2
            //Call typing on socket.
            if !isTyping {
                SocketChatManager.sharedInstance.userTyping(message: [
                    "secretKey": SocketChatManager.sharedInstance.secretKey,
                    "groupId": groupId,
                    "userId": SocketChatManager.sharedInstance.myUserId,
                    "name": self.groupDetail?.userName ?? "",
                    "isTyping": "true"
                ])
                //Name for group, isTyping = true
                //typing-res for receive only
                self.isTyping = true
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            }
        } else {
            //Call typing off socket.
            self.timer.invalidate()
            SocketChatManager.sharedInstance.userTyping(message: [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "groupId": groupId,
                "userId": SocketChatManager.sharedInstance.myUserId,
                "name": self.groupDetail?.userName ?? "",
                "isTyping": "false"
            ])
            self.isTyping = false
        }
        return true
    }
    
    // MARK: - UI Methods
    @objc func update() {
        timeSeconds -= 1
        if timeSeconds <= 0 {
            self.timer.invalidate()
            SocketChatManager.sharedInstance.userTyping(message: [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "groupId": groupId,
                "userId": SocketChatManager.sharedInstance.myUserId,
                "name": self.groupDetail?.userName ?? "",
                "isTyping": "false"
            ])
            self.isTyping = false
            lblOnline.text = onlineUser
        } else {
            lblOnline.text = onlineUser
        }
    }
}

// MARK: - Camera, Gallary
extension ChatVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            isCameraClick = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            //self.isDocumentPickerOpen = false
            let alertWarning = UIAlertController(title: "Camera", message: "Camera not working.", preferredStyle: .alert)
            alertWarning.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            }))
            self.present(alertWarning, animated: true)
        }
    }
    
    func fromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            //imagePicker.mediaTypes = ["public.image"]
            isCameraClick = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //also use for camera capture image
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if isCameraClick && (info[.editedImage] is UIImage) {
            self.dismiss(animated: true) {
                guard let image = info[.editedImage] as? UIImage else {
                    print("No image found")
                    return
                }
                
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let imageName = "\(Utility.fileName()).png"
                let fileUrl = documentsDirectory.appendingPathComponent(imageName)
                guard let data = image.jpegData(compressionQuality: 1) else { return }
                do {
                    try data.write(to: fileUrl)
                } catch let error {
                    print("error saving file with error --", error)
                }
                
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    
                    self.imgFileName = fileUrl.lastPathComponent
                    
                    let appImage = UIImage(contentsOfFile: fileUrl.path)
                    
                    self.imgFileName = self.imgFileName != "" ? self.imgFileName : "\(Utility.fileName()).png"
                    
                    let timestamp : Int = Int(NSDate().timeIntervalSince1970)
                    let timeMilliSeconds: [String: Any] = ["nanoseconds": 0,
                                                           "seconds": timestamp]
                    let param: [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
                                                 "senderName" : self.groupDetail?.userName ?? "",
                                                 "timeMilliSeconds" : timeMilliSeconds,
                                                 "type" : "image",
                                                 "msgId" : "",
                                                 "message" : "",
                                                 "contentType" : self.imgFileName.mimeType(),
                                                 "fileName" : self.imgFileName,
                                                 "filePath" : "",
                                                 "thumbnailPath" : "",
                                                 "time" : 0,
                                                 "showLoader": true]
                    let apiParam = [
                        "secretKey": SocketChatManager.sharedInstance.secretKey,
                        "userId": SocketChatManager.sharedInstance.myUserId,
                        "groupId": self.groupId,
                        "senderName": self.groupDetail?.userName ?? "",
                        "type": "image",
                        "image": self.imgFileName,
                        "isChat": 1
                    ] as [String : Any]
                    
                    guard let responseData = try? JSONSerialization.data(withJSONObject: param, options: []) else { return }
                    do {
                        let newMsg = try JSONDecoder().decode(Message.self, from: responseData)
                        print(newMsg)
                        if self.loadChatMsgToArray(msg: newMsg, timestamp: timestamp) {
                            self.tblUserChat.reloadData()
                            self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                        }
                    } catch let err {
                        print(err)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        NetworkManager.sharedInstance.uploadImage(dictiParam: apiParam, image: appImage!, type: "image", contentType: self.imgFileName.mimeType())
                        { imgUrl in
                            print("Uploaded image -> \(imgUrl)")
                        } errorCompletion: { errMsg in
                            let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                            toastMsg.setColor(background: .red, text: .black)
                            toastMsg.show()
                            
                            self.arrSectionMsg![self.arrSectionMsg!.count - 1].removeLast()
                            self.tblUserChat.reloadData()
                        }
                    }
                }
            }
        } else if info[UIImagePickerController.InfoKey.originalImage] is UIImage {
            self.dismiss(animated: true) {
                //let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
                let imageUrl = info[.imageURL] as? URL
                
                let photo = info[.phAsset] as? PHAsset
                self.imgFileName = photo?.value(forKey: "filename") as? String ?? ""
                print(self.imgFileName)
                
                let appImage = UIImage(contentsOfFile: imageUrl!.path)
                
                self.imgFileName = self.imgFileName == "" ? (URL(string: "\(info[.imageURL]!)")?.lastPathComponent)! : self.imgFileName
                self.imgFileName = self.imgFileName != "" ? self.imgFileName : "\(Utility.fileName()).png"
                
                let timestamp : Int = Int(NSDate().timeIntervalSince1970)
                let timeMilliSeconds: [String: Any] = ["nanoseconds": 0,
                                                       "seconds": timestamp]
                let param: [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
                                             "senderName" : self.groupDetail?.userName ?? "",
                                             "timeMilliSeconds" : timeMilliSeconds,
                                             "type" : "image",
                                             "msgId" : "",
                                             "message" : "",
                                             "contentType" : self.imgFileName.mimeType(),
                                             "fileName" : self.imgFileName,
                                             "filePath" : "",
                                             "thumbnailPath" : "",
                                             "time" : 0,
                                             "showLoader": true]
                let apiParam = [
                    "secretKey": SocketChatManager.sharedInstance.secretKey,
                    "userId": SocketChatManager.sharedInstance.myUserId,
                    "groupId": self.groupId,
                    "senderName": self.groupDetail?.userName ?? "",
                    "type": "image",
                    "image": self.imgFileName,
                    "isChat": 1
                ] as [String : Any]
                
                guard let responseData = try? JSONSerialization.data(withJSONObject: param, options: []) else { return }
                do {
                    let newMsg = try JSONDecoder().decode(Message.self, from: responseData)
                    print(newMsg)
                    if self.loadChatMsgToArray(msg: newMsg, timestamp: timestamp) {
                        self.tblUserChat.reloadData()
                        self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                    }
                } catch let err {
                    print(err)
                    return
                }
                
                DispatchQueue.main.async {
                    NetworkManager.sharedInstance.uploadImage(dictiParam: apiParam, image: appImage!, type: "image", contentType: self.imgFileName.mimeType())
                    { imgUrl in
                        print("Uploaded image -> \(imgUrl)")
                    } errorCompletion: { errMsg in
                        let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                        toastMsg.setColor(background: .red, text: .black)
                        toastMsg.show()
                        
                        self.arrSectionMsg![self.arrSectionMsg!.count - 1].removeLast()
                        self.tblUserChat.reloadData()
                    }
                }
            }
        } else {
            let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            print("Video_ URL - \((videoUrl?.path)!)")
            
            self.dismiss(animated: true) {
                
                do {
                    let videoD = try Data(contentsOf: videoUrl!)
                    //let videoD = NSData.dataWithContentsOfMappedFile(videoUrl!.path)
                    //print(videoData)
                    print(videoD)
                    
                    self.imgFileName = (videoUrl?.lastPathComponent)!
                    self.imgFileName = self.imgFileName != "" ? self.imgFileName : "\(Utility.fileName()).MOV"
                    
                    // Get thumbnail image from video.
                    /*let asset = AVURLAsset(url: videoUrl!, options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    var uiImage = UIImage()
                    do {
                        //let cgImage = imgGenerator.copyCGImage(at: CMTime(0,1), actualTime: nil)
                        let cgImage = try imgGenerator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 1), actualTime: nil)
                        uiImage = UIImage(cgImage: cgImage)
                        //let imageView = UIImageView(image: uiImage)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    //let imgData = uiImage.pngData()
                    let imgData = uiImage.jpegData(compressionQuality: 1)?.base64EncodedData()
                    print(imgData!)   //  */
                    
                    let timestamp : Int = Int(NSDate().timeIntervalSince1970)
                    let timeMilliSeconds: [String: Any] = ["nanoseconds": 0,
                                                           "seconds": timestamp]
                    let param: [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
                                                 "senderName" : self.groupDetail?.userName ?? "",
                                                 "timeMilliSeconds" : timeMilliSeconds,
                                                 "type" : "video",
                                                 "msgId" : "",
                                                 "message" : "",
                                                 "contentType" : self.imgFileName.mimeType(),
                                                 "fileName" : self.imgFileName,
                                                 "filePath" : "",
                                                 "thumbnailPath" : "",
                                                 "time" : 0,
                                                 "showLoader": true]
                    let apiParam = [
                        "secretKey": SocketChatManager.sharedInstance.secretKey,
                        "userId": SocketChatManager.sharedInstance.myUserId,
                        "groupId": self.groupId,
                        "senderName": self.groupDetail?.userName ?? "",
                        "type": "video",
                        "image": self.imgFileName,
                        "isChat": 1
                    ] as [String : Any]
                    
                    guard let responseData = try? JSONSerialization.data(withJSONObject: param, options: []) else { return }
                    do {
                        let newMsg = try JSONDecoder().decode(Message.self, from: responseData)
                        print(newMsg)
                        if self.loadChatMsgToArray(msg: newMsg, timestamp: timestamp) {
                            self.tblUserChat.reloadData()
                            self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                        }
                    } catch let err {
                        print(err)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        NetworkManager.sharedInstance.uploadImage(dictiParam: apiParam, image: videoD, type: "video", contentType: self.imgFileName.mimeType())
                        { imgUrl in
                            print("Uploaded image -> \(imgUrl)")
                        } errorCompletion: { errMsg in
                            let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                            toastMsg.setColor(background: .red, text: .black)
                            toastMsg.show()
                            
                            self.arrSectionMsg![self.arrSectionMsg!.count - 1].removeLast()
                            self.tblUserChat.reloadData()
                        }
                    }
                } catch {
                    print("error")
                }
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //self.isDocumentPickerOpen = false
        self.dismiss(animated: true) {
        }
    }
    
}

// MARK: - Select document
extension ChatVC : UIDocumentPickerDelegate, UIDocumentMenuDelegate {
    
    @available(iOS 14.0, *)
    func selectFiles() {
        let supportedTypes: [String] = ["public.rtf", "public.jpeg", "public.png", "com.adobe.pdf", "com.microsoft.excel.xls", "com.microsoft.word.doc", "org.openxmlformats.spreadsheetml.sheet", "org.openxmlformats.wordprocessingml.document"]
        let documentsPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentsPicker.delegate = self
        documentsPicker.allowsMultipleSelection = false
        documentsPicker.modalPresentationStyle = .fullScreen
        self.present(documentsPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        //Check - if selected document is image then check extension and display image.
        let url = urls.first! as URL
        if arrImageExtension.contains((url.pathExtension).lowercased()) {
            //Need to make a new image with the jpeg data to be able to close the security resources!
            guard let image = UIImage(contentsOfFile: url.path), let imageCopy = UIImage(data: image.jpegData(compressionQuality: 1.0)!) else { return }
            
            //let imgData = image.pngData()?.bytes
            //print(imgData!)
            
            self.imgFileName = url.lastPathComponent
            
            let timestamp : Int = Int(NSDate().timeIntervalSince1970)
            let timeMilliSeconds: [String: Any] = ["nanoseconds": 0,
                                                   "seconds": timestamp]
            let param: [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
                                         "senderName" : self.groupDetail?.userName ?? "",
                                         "timeMilliSeconds" : timeMilliSeconds,
                                         "type" : "image",
                                         "msgId" : "",
                                         "message" : "",
                                         "contentType" : self.imgFileName.mimeType(),
                                         "fileName" : self.imgFileName,
                                         "filePath" : "",
                                         "thumbnailPath" : "",
                                         "time" : 0,
                                         "showLoader": true]
            let apiParam = [
                "secretKey": SocketChatManager.sharedInstance.secretKey,
                "userId": SocketChatManager.sharedInstance.myUserId,
                "groupId": self.groupId,
                "senderName": self.groupDetail?.userName ?? "",
                "type": "image",
                "image": self.imgFileName,
                "isChat": 1
            ] as [String : Any]
            
            guard let responseData = try? JSONSerialization.data(withJSONObject: param, options: []) else { return }
            do {
                let newMsg = try JSONDecoder().decode(Message.self, from: responseData)
                print(newMsg)
                if self.loadChatMsgToArray(msg: newMsg, timestamp: timestamp) {
                    self.tblUserChat.reloadData()
                    self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                }
            } catch let err {
                print(err)
                return
            }
            
            DispatchQueue.main.async {
                NetworkManager.sharedInstance.uploadImage(dictiParam: apiParam, image: image, type: "image", contentType: self.imgFileName.mimeType())
                { imgUrl in
                    print("Uploaded image -> \(imgUrl)")
                } errorCompletion: { errMsg in
                    let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                    toastMsg.setColor(background: .red, text: .black)
                    toastMsg.show()
                    
                    self.arrSectionMsg![self.arrSectionMsg!.count - 1].removeLast()
                    self.tblUserChat.reloadData()
                }
            }
        } else if arrDocExtension.contains((url.pathExtension).lowercased()) {
            do {
                //let myData = try Data(contentsOf: url)
                //print(myData)
                
                self.imgFileName = url.lastPathComponent
                
                let timestamp : Int = Int(NSDate().timeIntervalSince1970)
                let timeMilliSeconds: [String: Any] = ["nanoseconds": 0,
                                                       "seconds": timestamp]
                let param: [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
                                             "senderName" : self.groupDetail?.userName ?? "",
                                             "timeMilliSeconds" : timeMilliSeconds,
                                             "type" : "document",
                                             "msgId" : "",
                                             "message" : "",
                                             "contentType" : self.imgFileName.mimeType(),
                                             "fileName" : self.imgFileName,
                                             "filePath" : "",
                                             "thumbnailPath" : "",
                                             "time" : 0,
                                             "showLoader": true]
                let apiParam = [
                    "secretKey": SocketChatManager.sharedInstance.secretKey,
                    "userId": SocketChatManager.sharedInstance.myUserId,
                    "groupId": self.groupId,
                    "senderName": self.groupDetail?.userName ?? "",
                    "type": "document",
                    "image": self.imgFileName,
                    "isChat": 1
                ] as [String : Any]
                
                guard let responseData = try? JSONSerialization.data(withJSONObject: param, options: []) else { return }
                do {
                    let newMsg = try JSONDecoder().decode(Message.self, from: responseData)
                    print(newMsg)
                    if self.loadChatMsgToArray(msg: newMsg, timestamp: timestamp) {
                        self.tblUserChat.reloadData()
                        self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                    }
                } catch let err {
                    print(err)
                    return
                }
                
                DispatchQueue.main.async {
                    NetworkManager.sharedInstance.uploadImage(dictiParam: apiParam, image: url, type: "document", contentType: self.imgFileName.mimeType())
                    { imgUrl in
                        print("Uploaded image -> \(imgUrl)")
                    } errorCompletion: { errMsg in
                        let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                        toastMsg.setColor(background: .red, text: .black)
                        toastMsg.show()
                        
                        self.arrSectionMsg![self.arrSectionMsg!.count - 1].removeLast()
                        self.tblUserChat.reloadData()
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else if arrAudioExtension.contains((url.pathExtension).lowercased()) {
            do {
                //var myData = NSData(contentsOfURL: url)
                let myData = try Data(contentsOf: url)
                print(myData)
                //SocketChatManager.sharedInstance.sendMsg(message: ["audio": myData, "sentBy" : SocketChatManager.sharedInstance.myUserId, "rid": self.groupId, "type" : "audio", "name" : url.lastPathComponent])
                
                // load msg to chat table
                
                //let param : [String : Any] = ["file": myData, "isRead" : false, "type" : "audio", "viewBy" : (self.recentChatUser?.members)!, "readBy" : SocketChatManager.sharedInstance.myUserId, "sentAt" : "", "sentBy" : SocketChatManager.sharedInstance.myUserId, "timeMilliSeconds" : "", "fileName" : imgFileName, "contentType" : "image/png", "replyUser": "", "replyMsg": "", "replyMsgId": ""]
                //let param1 : [String : Any] = ["messageObj" : param, "groupId" : self.groupId, "secretKey" : SocketChatManager.sharedInstance.secretKey, "userId": SocketChatManager.sharedInstance.myUserId, "userName": SocketChatManager.sharedInstance.myUserName]
                
                //if self.sendMessage(param: param1) {
//                    let timestamp : Int = Int(NSDate().timeIntervalSince1970)
//                    let sentAt : [String : Any] = ["seconds" : timestamp]
//                    let msg : [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
//                                                "type" : "audio",
//                                                "sentAt" : sentAt,
//                                                "audio" : urls.first!]
                    
                    /*if self.loadChatMsgToArray(msg: msg, timestamp: timestamp) {
                        self.tblUserChat.reloadData()
                        self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                    }   //  */
                //}
            } catch let error {
                print(error.localizedDescription)
            }
        } else if arrVideoExtension.contains((url.pathExtension).lowercased()) {
            do {
                //let videoD = try Data(contentsOf: videoUrl!)
                let videoD = try Data(contentsOf: url)
                
                self.imgFileName = (url.lastPathComponent)
                self.imgFileName = self.imgFileName != "" ? self.imgFileName : "\(Utility.fileName()).MOV"
                
                // Get thumbnail image from video.
                /*let asset = AVURLAsset(url: videoUrl!, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                var uiImage = UIImage()
                do {
                    //let cgImage = imgGenerator.copyCGImage(at: CMTime(0,1), actualTime: nil)
                    let cgImage = try imgGenerator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 1), actualTime: nil)
                    uiImage = UIImage(cgImage: cgImage)
                    //let imageView = UIImageView(image: uiImage)
                } catch let error {
                    print(error.localizedDescription)
                }
                //let imgData = uiImage.pngData()
                let imgData = uiImage.jpegData(compressionQuality: 1)?.base64EncodedData()
                print(imgData!)   //  */
                
                let timestamp : Int = Int(NSDate().timeIntervalSince1970)
                let timeMilliSeconds: [String: Any] = ["nanoseconds": 0,
                                                       "seconds": timestamp]
                let param: [String : Any] = ["sentBy" : SocketChatManager.sharedInstance.myUserId,
                                             "senderName" : self.groupDetail?.userName ?? "",
                                             "timeMilliSeconds" : timeMilliSeconds,
                                             "type" : "video",
                                             "msgId" : "",
                                             "message" : "",
                                             "contentType" : self.imgFileName.mimeType(),
                                             "fileName" : self.imgFileName,
                                             "filePath" : "",
                                             "thumbnailPath" : "",
                                             "time" : 0,
                                             "showLoader": true]
                let apiParam = [
                    "secretKey": SocketChatManager.sharedInstance.secretKey,
                    "userId": SocketChatManager.sharedInstance.myUserId,
                    "groupId": self.groupId,
                    "senderName": self.groupDetail?.userName ?? "",
                    "type": "video",
                    "image": self.imgFileName,
                    "isChat": 1
                ] as [String : Any]
                
                guard let responseData = try? JSONSerialization.data(withJSONObject: param, options: []) else { return }
                do {
                    let newMsg = try JSONDecoder().decode(Message.self, from: responseData)
                    print(newMsg)
                    if self.loadChatMsgToArray(msg: newMsg, timestamp: timestamp) {
                        self.tblUserChat.reloadData()
                        self.tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![self.arrSectionMsg!.count - 1].count - 1), section: (self.arrSectionMsg!.count - 1)), at: .bottom, animated: true)
                    }
                } catch let err {
                    print(err)
                    return
                }
                
                DispatchQueue.main.async {
                    NetworkManager.sharedInstance.uploadImage(dictiParam: apiParam, image: videoD, type: "video", contentType: self.imgFileName.mimeType())
                    { imgUrl in
                        print("Uploaded image -> \(imgUrl)")
                    } errorCompletion: { errMsg in
                        let toastMsg = ToastUtility.Builder(message: errMsg, controller: self, keyboardActive: false)
                        toastMsg.setColor(background: .red, text: .black)
                        toastMsg.show()
                        
                        self.arrSectionMsg![self.arrSectionMsg!.count - 1].removeLast()
                        self.tblUserChat.reloadData()
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        controller.dismiss(animated: true)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        print("Document picked.")
        //self.isDocumentPickerOpen = false
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker cancel.")
        //self.isDocumentPickerOpen = false
    }
}

// MARK: - Socket Delegate
extension ChatVC : SocketDelegate {
    func getUnreadChat(noOfChat: Int) {
    }
    
    func getUserRole() {
        setData()
    }
    
    func getPreviousChatMsg(message: String) {
        print("Previous chat message.")
    }
    
    func getRecentUser(message: String) {
    }
    
    func recentChatGroupList(groupList: [GetGroupList]) {
    }
    
    func msgReceived(message: Message) {
        let timestamp : Int = Int(NSDate().timeIntervalSince1970)
        
        if message.sentBy != SocketChatManager.sharedInstance.myUserId {
            if self.loadChatMsgToArray(msg: message, timestamp: timestamp) {
                tblUserChat.reloadData()
                tblUserChat.scrollToRow(at: IndexPath(row: (self.arrSectionMsg![arrSectionMsg!.count - 1].count - 1), section: (arrSectionMsg!.count - 1)), at: .bottom, animated: true)
            }
        }
        else if (message.type == "text") {
            for i in 0 ..< self.arrSectionMsg![arrSectionMsg!.count - 1].count {
                if (message.sentBy == SocketChatManager.sharedInstance.myUserId) && (self.arrSectionMsg![arrSectionMsg!.count - 1][i].type ?? "" == "text") && (message.message == self.arrSectionMsg![arrSectionMsg!.count - 1][i].message ?? "") && (self.arrSectionMsg![arrSectionMsg!.count - 1][i].msgId ?? "" == "") {
                    self.arrSectionMsg![arrSectionMsg!.count - 1][i] = message
                    DispatchQueue.main.async {
                        self.tblUserChat.reloadData()
                    }
                    break
                }
            }
        }
        else {
            for i in 0 ..< self.arrSectionMsg![arrSectionMsg!.count - 1].count {
                if (message.sentBy == SocketChatManager.sharedInstance.myUserId) && (self.arrSectionMsg![arrSectionMsg!.count - 1][i].type ?? "" == message.type) && (self.arrSectionMsg![arrSectionMsg!.count - 1][i].showLoader ?? false) {
                    self.arrSectionMsg![arrSectionMsg!.count - 1][i] = message
                    DispatchQueue.main.async {
                        self.tblUserChat.reloadData()
                    }
                    break
                }
            }
        }
    }
}

// MARK: - TableView Delegate
extension ChatVC : UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrDtForSection?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()//UIView(frame: CGRect.zero)
        viewHeader.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45)
        viewHeader.backgroundColor = .clear
        let lblHeaderTitle : UILabel = UILabel()    //(frame: CGRect.zero)
        lblHeaderTitle.frame = CGRect(x: 5, y: 5, width: 115, height: 35)
        lblHeaderTitle.center = viewHeader.center
        lblHeaderTitle.clipsToBounds = true
        lblHeaderTitle.layer.cornerRadius = 7
        lblHeaderTitle.text = self.arrDtForSection![section]
        lblHeaderTitle.font = .boldSystemFont(ofSize: 16)
        lblHeaderTitle.textAlignment = .center
        lblHeaderTitle.textColor = UIColor(red: 84/255, green: 101/255, blue: 111/255, alpha: 1)
        lblHeaderTitle.backgroundColor = .white
        viewHeader.addSubview(lblHeaderTitle)
        return viewHeader
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSectionMsg![section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) && (indexPath.row == 0) && isHasMore && !self.isCallPreChatPage {
            self.startAt = (self.arrSectionMsg![0][0].time ?? 0) - 1
            self.intScroll = 1
            SocketChatManager.sharedInstance.reqPreviousChatMsg(param: [
                "secretKey" : SocketChatManager.sharedInstance.secretKey,
                "groupId" : groupId,
                "userId" : SocketChatManager.sharedInstance.myUserId,
                "startAt": (self.arrSectionMsg![0][0].time ?? 0) - 1
            ] as [String : Any])
            
            self.isCallPreChatPage = true
        }
        
        let msgType : String = (self.arrSectionMsg![indexPath.section][indexPath.row].type)!
        if (self.arrSectionMsg![indexPath.section][indexPath.row].sentBy)! == SocketChatManager.sharedInstance.myUserId
        {
            if msgType == "document"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OwnFileBubbleCell", for: indexPath) as! OwnFileBubbleCell
                cell.viewMsg.backgroundColor = Colors.lightTheme.returnColor()
                
                cell.lblFileName.text = self.arrSectionMsg![indexPath.section][indexPath.row].fileName ?? "Document File"
                cell.configure(msgType, self.arrSectionMsg![indexPath.section][indexPath.row].fileName ?? "", self.arrSectionMsg![indexPath.section][indexPath.row].showLoader ?? false)
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                return cell
            }
            else if msgType == "image"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OwnImgChatBubbleCell", for: indexPath) as! OwnImgChatBubbleCell
                cell.viewImg.backgroundColor = Colors.lightTheme.returnColor()
                cell.configure(msgType, self.arrSectionMsg![indexPath.section][indexPath.row].filePath!, "", self.arrSectionMsg![indexPath.section][indexPath.row].showLoader ?? false)
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                return cell
            }
            else if msgType == "video"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OwnImgChatBubbleCell", for: indexPath) as! OwnImgChatBubbleCell
                cell.viewImg.backgroundColor = Colors.lightTheme.returnColor()
                cell.configure(msgType, self.arrSectionMsg![indexPath.section][indexPath.row].thumbnailPath ?? "", "", self.arrSectionMsg![indexPath.section][indexPath.row].showLoader ?? false)
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                return cell
            }
            else if msgType == "audio"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OwnAudioBubbleCell", for: indexPath) as! OwnAudioBubbleCell
                cell.viewMsg.backgroundColor = Colors.lightTheme.returnColor()
                
                cell.lblFileName.text = self.arrSectionMsg![indexPath.section][indexPath.row].fileName ?? "Audio File"
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                return cell
            }
            else
            {
                if self.arrSectionMsg![indexPath.section][indexPath.row].replyMsgId ?? "" == "" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OwnChatBubbleCell", for: indexPath) as! OwnChatBubbleCell
                    cell.viewMsg.backgroundColor = Colors.lightTheme.returnColor()
                    cell.lblMsg.text = (self.arrSectionMsg![indexPath.section][indexPath.row].message)!
                    cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OwnReplyTVCell", for: indexPath) as! OwnReplyTVCell
                    cell.viewMsg.backgroundColor = Colors.lightTheme.returnColor()
                    //cell.viewMsg.setBgColor(color: SocketChatManager.sharedInstance.themeColor!)
                    
                    var userName : String = self.arrSectionMsg![indexPath.section][indexPath.row].replyUser ?? "" //""
                    var type: String = self.arrSectionMsg![indexPath.section][indexPath.row].replyMsgType ?? ""
                    if self.arrSectionMsg![indexPath.section][indexPath.row].replyUserId ?? "" == SocketChatManager.sharedInstance.myUserId {
                        userName = "You"
                    }
                    cell.lblReplyUser.text = userName
                    
                    cell.lblReplyMsg.isHidden = true
                    cell.ImgReplyImg.isHidden = true
                    if type == "image" {
                        cell.ImgReplyImg.isHidden = false
                        cell.configure("image", self.arrSectionMsg![indexPath.section][indexPath.row].replyMsg ?? "", "")
                        cell.constraintImgBottom.priority = .required
                    } else {
                        cell.lblReplyMsg.isHidden = false
                        cell.lblReplyMsg.text = (self.arrSectionMsg![indexPath.section][indexPath.row].replyMsg)!
                        cell.constraintImgBottom.priority = .defaultLow
                    }
                    cell.lblMsg.text = (self.arrSectionMsg![indexPath.section][indexPath.row].message)!
                    cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                    
                    return cell
                }
            }
        }
        else
        {
            if msgType == "document"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherFileBubbleCell", for: indexPath) as! OtherFileBubbleCell
                cell.viewMsg.backgroundColor = .white
                
                cell.lblFileName.text = self.arrSectionMsg![indexPath.section][indexPath.row].fileName ?? "Document File"
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                if isGroup {
                    cell.lblUserName.isHidden = false
                    cell.lblUserName.text = self.arrSectionMsg![indexPath.section][indexPath.row].senderName ?? ""
                    cell.constTopMsg.priority = .defaultLow
                }
                return cell
            }
            else if msgType == "image"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherImgChatBubbleCell", for: indexPath) as! OtherImgChatBubbleCell
                cell.viewImg.backgroundColor = .white
                cell.configure(msgType, self.arrSectionMsg![indexPath.section][indexPath.row].filePath!, "")
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                if isGroup {
                    cell.lblUserName.isHidden = false
                    cell.lblUserName.text = self.arrSectionMsg![indexPath.section][indexPath.row].senderName ?? ""
                    cell.constTopImg.priority = .defaultLow
                }
                return cell
            }
            else if msgType == "video"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherImgChatBubbleCell", for: indexPath) as! OtherImgChatBubbleCell
                cell.viewImg.backgroundColor = .white
                cell.configure(msgType, self.arrSectionMsg![indexPath.section][indexPath.row].thumbnailPath ?? "", "")
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                if isGroup {
                    cell.lblUserName.isHidden = false
                    cell.lblUserName.text = self.arrSectionMsg![indexPath.section][indexPath.row].senderName ?? ""
                    cell.constTopImg.priority = .defaultLow
                }
                return cell
            }
            else if msgType == "audio"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherAudioBubbleCell", for: indexPath) as! OtherAudioBubbleCell
                cell.viewMsg.backgroundColor = .white
                
                cell.lblFileName.text = self.arrSectionMsg![indexPath.section][indexPath.row].fileName ?? "Audio File"
                cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                if isGroup {
                    cell.lblUserName.isHidden = false
                    cell.lblUserName.text = self.arrSectionMsg![indexPath.section][indexPath.row].senderName ?? ""
                    cell.constTopMsg.priority = .defaultLow
                }
                return cell
            }
            else
            {
                if self.arrSectionMsg![indexPath.section][indexPath.row].replyMsgId ?? "" == "" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OtherChatBubbleCell", for: indexPath) as! OtherChatBubbleCell
                    cell.viewMsg.backgroundColor = .white
                    cell.lblMsg.text = (self.arrSectionMsg![indexPath.section][indexPath.row].message)!
                    cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                    if isGroup {
                        cell.lblUserName.isHidden = false
                        cell.lblUserName.text = self.arrSectionMsg![indexPath.section][indexPath.row].senderName ?? ""
                        cell.constTopMsg.priority = .defaultLow
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OtherReplyTVCell", for: indexPath) as! OtherReplyTVCell
                    
                    var userName : String = self.arrSectionMsg![indexPath.section][indexPath.row].replyUser ?? ""
                    let type: String = self.arrSectionMsg![indexPath.section][indexPath.row].replyMsgType ?? ""
                    if self.arrSectionMsg![indexPath.section][indexPath.row].replyUserId ?? "" == SocketChatManager.sharedInstance.myUserId {
                        userName = "You"
                    }
                    cell.lblReplyUser.text = userName
                    
                    cell.lblReplyMsg.isHidden = true
                    cell.ImgReplyImg.isHidden = true
                    if type == "image" {
                        cell.ImgReplyImg.isHidden = false
                        cell.configure("image", self.arrSectionMsg![indexPath.section][indexPath.row].replyMsg ?? "", "")
                        cell.constraintImgBottom.priority = .required
                    } else {
                        cell.lblReplyMsg.isHidden = false
                        cell.lblReplyMsg.text = (self.arrSectionMsg![indexPath.section][indexPath.row].replyMsg)!
                        cell.constraintImgBottom.priority = .defaultLow
                    }
                    cell.lblMsg.text = (self.arrSectionMsg![indexPath.section][indexPath.row].message)!
                    cell.lblTime.text = Utility.convertTimestamptoTimeString(timestamp: "\((self.arrSectionMsg![indexPath.section][indexPath.row].timeMilliSeconds?.seconds)!)")
                    
                    if isGroup {
                        cell.lblUserName.isHidden = false
                        cell.lblUserName.text = self.arrSectionMsg![indexPath.section][indexPath.row].senderName ?? ""
                        cell.constTopMsg.priority = .defaultLow
                    }
                    return cell
                }
                
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msgType : String = (self.arrSectionMsg![indexPath.section][indexPath.row].type)!
        if msgType == "document" {
            
            guard let url = URL(string: (self.arrSectionMsg![indexPath.section][indexPath.row].filePath)!) else { return }
            UIApplication.shared.open(url)
            
            /*///
            let fileName = "123.doc"    //  get file name from chat array
            do {
            let documentUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileUrl = documentUrl.appendingPathComponent(fileName)
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    print("Open already downloaded file...")
                } else {
                    NetworkManager.sharedInstance.download(url: URL(string: (self.arrSectionMsg![indexPath.section][indexPath.row].document)!)!, fileLocation: fileUrl, obj: self) { result in
                        print(result)
                    }
                }
                print(fileUrl.path)
            } catch let error {
                print(error.localizedDescription)
            }
            ///     */
        } else if msgType == "video" {
            //let player = AVPlayer(url: URL(fileURLWithPath: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"))
            //let player = AVPlayer(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
            
            let player = AVPlayer(url: URL(string: self.arrSectionMsg![indexPath.section][indexPath.row].filePath ?? "")!)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            //self.present(vcPlayer, animated: true, completion: nil)
            self.present(vcPlayer, animated: true) {
                vcPlayer.player?.play()
            }
        } else if msgType == "image" {
            let vc =  ImgViewerVC()
            vc.strImageName = (self.arrSectionMsg![indexPath.section][indexPath.row].filePath)!
            //self.navigationController?.pushViewController(vc, animated: true)
            self.present(vc, animated: true)
        } else if msgType == "audio" {
            //http://freetone.org/ring/stan/iPhone_5-Alarm.mp3
            //https://s3.amazonaws.com/kargopolov/kukushka.mp3
            let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
            
            guard let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3") else { return }
            UIApplication.shared.open(url)
            
            /*///
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            //var fileName : String = (url!.deletingPathExtension()).lastPathComponent
            let fileName : String = url!.lastPathComponent
            //var fileExt : String = url!.pathExtension
            print(fileName)
            
            //let audioName = "\(Utility.fileName()).mp3"
            let fileUrl = documentsDirectory.appendingPathComponent(fileName)
            var isFileExist : Bool = false
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                isFileExist = true
            } else {
                URLSession.shared.downloadTask(with: url!, completionHandler: {
                    location, response, error in
                    do {
                        //try data.write(to: fileUrl)
                        //location.write(to: fileUrl)
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location!, to: fileUrl)
                        print("File moved to documents folder")
                        isFileExist = true
                        self.playAudio(isFileExist: isFileExist, filePath: fileUrl)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
            playAudio(isFileExist: isFileExist, filePath: fileUrl)
            ///     */
        }
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: nil) { [weak self] (action, view, completionHandler) in
            self?.swipeReplyMsg = self?.arrSectionMsg![indexPath.section][indexPath.row]
            self?.replyMsg()
            //self?.handleMarkAsFavourite(section: indexPath.section, index: indexPath.row)
            completionHandler(true)
        }
        
        action.image = UIImage(named: "reply", in: self.bundle, compatibleWith: nil) //UIImage(named: "reply")
        action.backgroundColor = .systemBlue.withAlphaComponent(0.01)
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    /*func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity : CGPoint = gestureRecognizer.location(in: self.tblUserChat)
        if velocity.x < 0 {
            return false
        }
        return abs(Float(velocity.x)) > abs(Float(velocity.y))
    }

    @objc func panGestureCellAction(recognizer: UIPanGestureRecognizer)  {
        let translation = recognizer.translation(in: self.tblUserChat)
        if recognizer.view?.frame.origin.x ?? 0 < 0 {
            return
        }
        recognizer.view?.center = CGPoint(
            x: (recognizer.view?.center.x ?? 0) + translation.x,
            y: (recognizer.view?.center.y ?? 0))
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        if (recognizer.view?.frame.origin.x ?? 0) > UIScreen.main.bounds.size.width * 0.9 {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0, width: recognizer.view?.frame.size.width ?? 0, height: recognizer.view?.frame.size.height ?? 0)
            })
        }
        if recognizer.state == .ended {
            let x = recognizer.view?.frame.origin.x ?? 0
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0, width: recognizer.view?.frame.size.width ?? 0, height: recognizer.view?.frame.size.height ?? 0)
            } completion: { (finished) in
                if x > ((recognizer.view?.frame.size.width ?? 0) / 2) {
                    self.tblUserChat.becomeFirstResponder()
                    print("Swipe to reply...")
                }
            }
        }
    }   //  */
    
    func playAudio(isFileExist : Bool, filePath : URL) {
        if isFileExist {
            DispatchQueue.main.async {
                let vc =  AudioPlayVC()
                vc.filePath = filePath
                self.present(vc, animated: true)
            }
        }
    }
    
    private func replyMsg() {
        if self.isGroup {
            if (self.swipeReplyMsg?.sentBy ?? "") == SocketChatManager.sharedInstance.myUserId {
                self.lblReplyUser.text = "You"
            } else {
                self.lblReplyUser.text = self.swipeReplyMsg?.senderName ?? ""
            }
        } else {
            self.lblReplyUser.text = ""
        }
        
        self.isImg = false
        self.lblReplyMsg.isHidden = true
        self.imgReplyImage.isHidden = true
        if self.swipeReplyMsg?.type == "text" {
            self.lblReplyMsg.isHidden = false
            self.lblReplyMsg.text = self.swipeReplyMsg?.message ?? ""
        } else if self.swipeReplyMsg?.type == "image" {
            self.imgReplyImage.isHidden = false
            self.isImg = true
            //self.imgReplyImage.image = UIImage(named: self.swipeReplyMsg?.image ?? "")
            self.loadImage(self.swipeReplyMsg?.filePath ?? "")
        } else if self.swipeReplyMsg?.type == "document" {
            self.lblReplyMsg.isHidden = false
            self.lblReplyMsg.text = self.swipeReplyMsg?.fileName ?? ""
        } else if self.swipeReplyMsg?.type == "video" {
        } else if self.swipeReplyMsg?.type == "audio" {
        }
        
        viewMainReply.isHidden = false
        constTblBottom.priority = .defaultLow
        self.isSwipe = true
        
    }

    private func handleMarkAsUnread() {
        print("Marked as unread")
    }

    private func handleMoveToTrash() {
        print("Moved to trash")
    }

    private func handleMoveToArchive() {
        print("Moved to archive")
    }
}

// MARK: - Load chat msg to Array
extension ChatVC {
    func loadChatMsgToArray(msg : Message, timestamp : Int) -> Bool {
        let strDate : String = Utility.convertTimestamptoDateString(timestamp: timestamp)
        if (arrDtForSection?.contains(strDate))! {
            for j in 0 ..< arrDtForSection!.count {
                if arrDtForSection![j] == strDate {
                    //arrSectionMsg?[j].append((self.arrGetPreviousChat?[i])!)
                    arrSectionMsg?[j].append(msg)
                }
            }
        } else {
            var tempMsg : [Message] = []
            tempMsg.append(msg)
            arrSectionMsg?.append(tempMsg)
            arrDtForSection?.append(strDate)
        }
        return true
    }
    
    func loadImage(_ image: String) {
        imgReplyImage.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil)
        imgReplyImage.image = UIImage(contentsOfFile: image)
        if image != "" {
            var imageURL: URL?
            imageURL = URL(string: image)!
            
            // retrieves image if already available in cache
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgReplyImage.image = imageFromCache
                return
            }
            imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data) {
                        self.imgReplyImage.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    }
                }
            }
        }
    }
    
    func loadImage1(_ image: String) -> UIImage {
        imgReplyImage.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil)
        imgReplyImage.image = UIImage(contentsOfFile: image)
        if image != "" {
            var imageURL: URL?
            imageURL = URL(string: image)!
            
            // retrieves image if already available in cache
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                //return
                return imageFromCache
            }
            imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data) {
                        self.imgReplyImage.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    }
                }
            }
        }
        return UIImage(named: "default", in: self.bundle, compatibleWith: nil) ?? UIImage()
    }
}
