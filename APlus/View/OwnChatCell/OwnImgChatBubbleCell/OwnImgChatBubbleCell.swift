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

    func configure(_ msgType : String,_ image : String,_ data : String,_ showLoader: Bool) {
        if msgType == "video" {
            if showLoader {
                hud.show(in: viewImg)
            } else {
                hud.dismiss()
            }
            imgVideo.isHidden = false
            imgVideo.image = UIImage(named: "Play")
            img.image = UIImage(named: "default")
            img.image = UIImage(contentsOfFile: image)
            /*if data != "" {
                let imageData = try? Data(contentsOf: URL(string: data)!)
                if let imageData = imageData {
                    img.image = UIImage(data: imageData)
                }
            }   //  */
            self.loadImg(image)
        }
        else if msgType == "image" {
            if showLoader {
                hud.show(in: viewImg)
            } else {
                hud.dismiss()
            }
            img.image = UIImage(named: "default")
            img.image = UIImage(contentsOfFile: image)
            self.loadImg(image)
        }
    }
    
    func loadImg(_ image : String) {
        if image != "" {
            var imageURL: URL?
            imageURL = URL(string: image)!
            
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
