//
//  OwnAudioBubbleCell.swift
//  agsChat
//
//  Created by MAcBook on 18/07/22.
//

import UIKit

class OwnAudioBubbleCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var imgAudio: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMsg.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
