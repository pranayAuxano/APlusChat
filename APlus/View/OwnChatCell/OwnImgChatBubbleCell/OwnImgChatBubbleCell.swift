//
//  OwnImgChatBubbleCell.swift
//  agsChat
//
//  Created by MAcBook on 28/06/22.
//

import UIKit
import ProgressHUD
import JGProgressHUD

class OwnImgChatBubbleCell: UITableViewCell {

    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgVideo: UIImageView!
    
    private var imageRequest: Cancellable?
    let hud = JGProgressHUD()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewImg.layer.cornerRadius = 5
        imgVideo.isHidden = true
    }

    func configure(_ msgType : String,_ image : String,_ data : String) {
        if msgType == "video" {
            img.image = UIImage(named: "default")
            imgVideo.isHidden = false
            imgVideo.image = UIImage(named: "Play")
            if data != "" {
                let imageData = try? Data(contentsOf: URL(string: data)!)
                if let imageData = imageData {
                    img.image = UIImage(data: imageData)
                }
            }
        }
        else if msgType == "image" {
            if image.contains("firebasestorage") {
                hud.dismiss()
            } else {
                hud.show(in: viewImg)
            }
            img.image = UIImage(named: "default")
            img.image = UIImage(contentsOfFile: image)
            if image != "" {
                var imageURL: URL?
                imageURL = URL(string: image)!
                //self.imgProfile.image = nil
                // retrieves image if already available in cache
                if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                    self.img.image = imageFromCache
                    return
                }
                imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                    guard let data = data, err == nil else {
                        print("Error in download from url")
                        return
                    }
                    DispatchQueue.main.async {
                        if let imageToCache = UIImage(data: data) {
                            self.img.image = imageToCache
                            imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        imgVideo.isHidden = true
        // Reset Thumbnail Image View
        img.image = UIImage(named: "default")
        // Cancel Image Request
        imageRequest?.cancel()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
