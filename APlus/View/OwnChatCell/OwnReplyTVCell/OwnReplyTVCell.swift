//
//  OwnReplyTVCell.swift
//  agsChat
//
//  Created by MAcBook on 21/02/23.
//

import UIKit

class OwnReplyTVCell: UITableViewCell {

    @IBOutlet weak var viewMsgRply: UIView!
    @IBOutlet weak var viewReplyMsg: UIView!
    @IBOutlet weak var lblReplyUser: UILabel!
    @IBOutlet weak var lblReplyMsg: UILabel!
    @IBOutlet weak var ImgReplyImg: UIImageView!
    @IBOutlet weak var lblReplySideBar: UILabel!
    
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var constraintImgBottom: NSLayoutConstraint!
    private var imageRequest: Cancellable?
    var bundle = Bundle()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bundle = Bundle(for: OwnReplyTVCell.self)
        
        self.viewMsgRply.clipsToBounds = true
        self.viewMsgRply.layer.cornerRadius = 5
        
        self.viewReplyMsg.clipsToBounds = true
        self.viewReplyMsg.layer.cornerRadius = 3
    }

    func configure(_ msgType : String,_ image : String,_ data : String) {
        if msgType == "video" {
            ImgReplyImg.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil) //UIImage(named: "default")
            if data != "" {
                let imageData = try? Data(contentsOf: URL(string: data)!)
                if let imageData = imageData {
                    ImgReplyImg.image = UIImage(data: imageData)
                }
            }
        }
        else if msgType == "image" {
            ImgReplyImg.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil) //UIImage(named: "default")
            ImgReplyImg.image = UIImage(contentsOfFile: image)
            if image != "" {
                var imageURL: URL?
                imageURL = URL(string: image)!
                //self.imgProfile.image = nil
                // retrieves image if already available in cache
                if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                    self.ImgReplyImg.image = imageFromCache
                    return
                }
                imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                    guard let data = data, err == nil else {
                        print("Error in download from url")
                        return
                    }
                    DispatchQueue.main.async {
                        //let dataImg : UIImage = UIImage(data: data)!
                        if let imageToCache = UIImage(data: data) {
                            //if self.imageURL == url {
                                self.ImgReplyImg.image = imageToCache
                            //}
                            imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        // Reset Thumbnail Image View
        ImgReplyImg.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil) //UIImage(named: "default")
        // Cancel Image Request
        imageRequest?.cancel()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
