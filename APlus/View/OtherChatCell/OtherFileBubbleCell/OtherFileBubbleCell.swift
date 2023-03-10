//
//  OtherFileBubbleCell.swift
//  agsChat
//
//  Created by MAcBook on 08/07/22.
//

import UIKit

class OtherFileBubbleCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var imgDocument: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var constTopMsg: NSLayoutConstraint!
    @IBOutlet weak var constTopMsgToUser: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMsg.layer.cornerRadius = 5
        
        lblUserName.isHidden = true
        constTopMsg.priority = .required
        //constTopMsgToUser.priority = .defaultLow
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
