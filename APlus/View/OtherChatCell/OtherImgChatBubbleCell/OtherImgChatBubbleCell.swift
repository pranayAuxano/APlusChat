//
//  OtherImgChatBubbleCell.swift
//  agsChat
//
//  Created by MAcBook on 28/06/22.
//

import UIKit

class OtherImgChatBubbleCell: UITableViewCell {

    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgVideo: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var constTopImg: NSLayoutConstraint!
    @IBOutlet weak var constTopImgToUser: NSLayoutConstraint!
    
    private var imageRequest: Cancellable?
    var bundle = Bundle()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bundle = Bundle(for: OtherImgChatBubbleCell.self)
        
        self.viewImg.layer.cornerRadius = 5
        imgVideo.isHidden = true
        
        lblUserName.isHidden = true
        constTopImg.priority = .required
        //constTopImgToUser.priority = .defaultLow
    }
    
    func configure(_ msgType : String,_ image : String,_ data : String) {
        if msgType == "video" {
            img.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil) //UIImage(named: "default")
            imgVideo.isHidden = false
            imgVideo.image = UIImage(named: "Play", in: self.bundle, compatibleWith: nil)    //UIImage(named: "Play")
            
            if data != "" {
                let imageData = try? Data(contentsOf: URL(string: data)!)
                if let imageData = imageData {
                    img.image = UIImage(data: imageData)
                }
            }
        }
        else if msgType == "image" {
            img.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil) //UIImage(named: "default")
            img.image = UIImage(contentsOfFile: image)
            if image != "" {
                var imageURL: URL?
                imageURL = URL(string: image)!
                // retrieves image if already available in cache
                if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                    self.img.image = imageFromCache
                    return
                }
                imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                    guard let data = data, err == nil else { return }
                    DispatchQueue.main.async {
                        if let imageToCache = UIImage(data: data) {
                            self.img.image = imageToCache
                            imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                        }
                    }
                }
            }   //  */
        }
    }
    
    override func prepareForReuse() {
        imgVideo.isHidden = true
        // Reset Thumbnail Image View
        img.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil) //UIImage(named: "default")
        
        // Cancel Image Request
        imageRequest?.cancel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
