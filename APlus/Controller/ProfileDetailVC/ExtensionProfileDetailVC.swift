//
//  ExtensionProfileDetailVC.swift
//  agsChat
//
//  Created by MAcBook on 11/07/22.
//

import Foundation
import UIKit
import Photos

extension ProfDetailVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            isCameraOpen = true
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            isCameraOpen = false
            let alertWarning = UIAlertController(title: "", message: "Camera not available.", preferredStyle: .alert)
            alertWarning.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            }))
            self.present(alertWarning, animated: true)
        }
    }
    
    func openGallary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            self.dismiss(animated: true) {
            }
            
            var isImgLoad : Bool = false
            if !isCameraOpen
            {
                let photo = info[.phAsset] as? PHAsset
                imgFileName = photo?.value(forKey: "filename") as? String ?? ""
                imgFileName = imgFileName == "" ? (URL(string: "\(info[.imageURL]!)")?.lastPathComponent)! : imgFileName
                print(imgFileName)
                mimeType = imgFileName.mimeType()
                isImgLoad = true
            }
            else
            {
                guard let image = info[.editedImage] as? UIImage else {
                    print("No image found")
                    return
                }
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                //let imageName = "\(Utility.fileName()).jpg"
                imgFileName = "\(Utility.fileName()).png"
                let fileUrl = documentsDirectory.appendingPathComponent(imgFileName)
                mimeType = fileUrl.mimeType()
                //guard let data = image.jpegData(compressionQuality: 1) else { return }
                guard let data = image.pngData() else { return }
                
                do {
                    try data.write(to: fileUrl)
                    isImgLoad = true
                }
                catch let error
                {
                    print("error saving file with error --", error)
                }
                
                isCameraOpen = false
            }
            
            if isImgLoad
            {
                imgProfile.contentMode = .scaleAspectFill
                imgProfile.image = pickedImage
                profileImgDelegate?.setProfileImg(image: imgProfile.image!)
                isPictureSelect = true
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        isCameraOpen = false
        self.dismiss(animated: true) {
        }
    }
}

extension ProfDetailVC : UITextFieldDelegate
{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
}
