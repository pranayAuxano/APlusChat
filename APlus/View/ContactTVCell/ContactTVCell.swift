//
//  ContactTVCell.swift
//  AgsChat
//
//  Created by MAcBook on 28/05/22.
//

import UIKit

class ContactTVCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imgContactImg: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    
    private var imageRequest: Cancellable?
    var bundle = Bundle()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bundle = Bundle(for: ContactTVCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(_ image : String)
    {
        imgContactImg.image = UIImage(named: "placeholder-profile-img.png", in: self.bundle, compatibleWith: nil)
        
        if image != ""
        {
            var imageURL: URL?
            imageURL = URL(string: image)!
            
            if let imageFromCache = imageCache.object(forKey: imageURL as AnyObject) as? UIImage
            {
                self.imgContactImg.image = imageFromCache
                return
            }
            
            imageRequest = NetworkManager.sharedInstance.getData(from: URL(string: image)!) { data, resp, err in
                guard let data = data, err == nil else {
                    print("Error in download from url")
                    return
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data)
                    {
                        self.imgContactImg.image = imageToCache
                        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
                    }
                    else
                    {
                        self.imgContactImg.image = UIImage(named: "placeholder-profile-img.png", in: self.bundle, compatibleWith: nil)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        // Reset Thumbnail Image View
        //imgProfile.image = UIImage(named: "default", in: self.bundle, compatibleWith: nil)    //UIImage(named: "default")
        // Cancel Image Request
        imageRequest?.cancel()
    }
}
