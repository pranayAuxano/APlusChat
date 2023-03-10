//
//  OwnFileBubbleCell.swift
//  agsChat
//
//  Created by MAcBook on 08/07/22.
//

import UIKit

class OwnFileBubbleCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var imgDocument: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMsg.layer.cornerRadius = 5
    }

    func configure(_ msgType : String,_ fileName : String) {
        if fileName.contains("firebasestorage") {
            activityIndicatorView.stopAnimating()
        } else {
            activityIndicatorView.frame = CGRect(x: 60, y: 1, width: 40, height: 40)
            activityIndicatorView.color = .white
            viewMsg.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
