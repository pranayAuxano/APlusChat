//
//  ForwardGrpTVCell.swift
//  agsChat
//
//  Created by MAcBook on 05/07/23.
//

import UIKit

protocol SelectGrpToForwardDelegate {
    func selectGrpToForward(sender : UIButton)
}

class ForwardGrpTVCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgGrpIcon: UIImageView!
    @IBOutlet weak var lblGrpName: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    @IBOutlet weak var btnSelectGrp: UIButton!
    
    private var imageRequest: Cancellable?
    var selectGrpToForwardDelegate : SelectGrpToForwardDelegate?
    var isGroup: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgGrpIcon.clipsToBounds = true
        self.imgGrpIcon.layer.cornerRadius = self.imgGrpIcon.frame.height / 2
    }

    func configure(_ image : String, isGroup: Bool) {
        self.isGroup = isGroup
        self.imgGrpIcon.image = UIImage(named: isGroup ? "group-placeholder.jpg" : "placeholder-profile-img.png")
        if image != "" {
            var imageURL: URL?
            imageURL = URL(string: image)!
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgGrpIcon.image = imageFromCache
                return
            }
            imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data) {
                        self.imgGrpIcon.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    } else {
                        self.imgGrpIcon.image = UIImage(named: isGroup ? "group-placeholder.jpg" : "placeholder-profile-img.png")
                    }
                }
            }
        }
    }
    
    @IBAction func btnSelectGrpTap(_ sender: UIButton) {
        self.selectGrpToForwardDelegate?.selectGrpToForward(sender: sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        /// Reset Thumbnail Image View
        self.imgGrpIcon.image = UIImage(named: self.isGroup ? "group-placeholder.jpg" : "placeholder-profile-img.png")
        
        /// Cancel Image Request
        imageRequest?.cancel()
    }
}
