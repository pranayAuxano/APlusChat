//
//  GrpContactTVCell.swift
//  AgsChat
//
//  Created by MAcBook on 28/05/22.
//

import UIKit

protocol SelectContactDelegate {
    func selectContact(sender : UIButton)
}

class GrpContactTVCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imgContact: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    @IBOutlet weak var btnSelectContact: UIButton!
    private var imageRequest: Cancellable?
    
    var selectContactDelegate : SelectContactDelegate?
    var bundle = Bundle()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bundle = Bundle(for: GrpContactTVCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(_ image : String, isGroup: Bool = false) {
        imgContact.image = UIImage(named: "placeholder-profile-img.png", in: self.bundle, compatibleWith: nil)
        if image != "" {
            var imageURL: URL?
            imageURL = URL(string: image)!
            print("Image URL - \(image)")
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imgContact.image = imageFromCache
                return
            }
            imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data) {
                        self.imgContact.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    } else {
                        self.imgContact.image = UIImage(named: "placeholder-profile-img.png", in: self.bundle, compatibleWith: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func btnSelectContactTap(_ sender: UIButton) {
        selectContactDelegate?.selectContact(sender: sender)
    }
    
    override func prepareForReuse() {
        // Reset Thumbnail Image View
        //imgProfile.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil)    //UIImage(named: "default")
        // Cancel Image Request
        imageRequest?.cancel()
    }
}
