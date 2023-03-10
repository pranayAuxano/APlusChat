//
//  UserDetailTVCell.swift
//  AgsChat
//
//  Created by MAcBook on 27/05/22.
//

import UIKit

class UserDetailTVCell: UITableViewCell {

    @IBOutlet weak var viewProfileImg: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var viewMsgDetail: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMsgDateTime: UILabel!
    @IBOutlet weak var lblLastMsg: UILabel!
    @IBOutlet weak var lblUnreadMsgCount: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    @IBOutlet weak var viewRecentPhoto: UIView!
    @IBOutlet weak var imgRecentPhoto: UIImageView!
    @IBOutlet weak var lblRecentPhotoVideoFile: UILabel!
    @IBOutlet weak var viewMainBG: UIView!
    
    private var imageRequest: Cancellable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblUnreadMsgCount.clipsToBounds = true
        lblLastMsg.isHidden = true
        viewRecentPhoto.isHidden = true
        
        viewMainBG.layer.cornerRadius = 10
        self.lblSeparator.backgroundColor = .clear
    }
    
    func configure(_ name : String,_ groupImage : String,_ msgType : String, isGroup : Bool) {
        viewProfileImg.layer.cornerRadius = viewProfileImg.frame.height / 2
        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2
        lblUnreadMsgCount.layer.cornerRadius = lblUnreadMsgCount.frame.height / 2
        lblSeparator.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        imgProfile.backgroundColor = .clear
        viewProfileImg.backgroundColor = .clear
        viewMsgDetail.backgroundColor = .clear
        
        lblUserName.text = name
        if msgType == "" {
            lblLastMsg.isHidden = false
        } else if msgType == "text" {
            lblLastMsg.isHidden = false
        } else if msgType == "image" {
            viewRecentPhoto.isHidden = false
            imgRecentPhoto.image = UIImage(named: "image")
            lblRecentPhotoVideoFile.text = "Photo"
        } else if msgType == "audio" {
            viewRecentPhoto.isHidden = false
            imgRecentPhoto.image = UIImage(named: "audio")
            lblRecentPhotoVideoFile.text = "Audio"
        } else if msgType == "video" {
            viewRecentPhoto.isHidden = false
            imgRecentPhoto.image = UIImage(named: "video")
            lblRecentPhotoVideoFile.text = "Video"
        } else if msgType == "document" {
            viewRecentPhoto.isHidden = false
            imgRecentPhoto.image = UIImage(named: "document")
            lblRecentPhotoVideoFile.text = "File"
        }
        
        imgProfile.image = UIImage(named: "placeholder-profile-img.png")
        if groupImage != "" {
            var imageURL: URL?
            imageURL = URL(string: groupImage)!
            //self.imgProfile.image = nil
            // retrieves image if already available in cache
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgProfile.image = imageFromCache
                return
            }
            imageRequest = NetworkManager.sharedInstance.getData(from: imageURL!) { data, resp, err in
                guard let data = data, err == nil else { return }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data) {
                        self.imgProfile.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    } else {
                        self.imgProfile.image = isGroup ? UIImage(named: "group-placeholder.jpg") : UIImage(named: "placeholder-profile-img.png")
                    }
                }
            }
        }   //  */
    }
    
    override func prepareForReuse() {
        lblLastMsg.isHidden = true
        viewRecentPhoto.isHidden = true
        
        // Reset Thumbnail Image View
        imgProfile.image = nil
        
        // Cancel Image Request
        imageRequest?.cancel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
