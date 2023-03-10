//
//  ImgViewerVC.swift
//  ConvertedAGS
//
//  Created by Auxano on 12/10/22.
//

import UIKit

public class ImgViewerVC: UIViewController {

    var strImageName : String?
    var imgSelectedImage : UIImage?
    
    @IBOutlet weak var imgDisplayImg: UIImageView!
    
    public init() {
        super.init(nibName: "ImageViewerVC", bundle: Bundle(for: ImgViewerVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented ImageViewerVC")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if strImageName != "" {
            NetworkManager.sharedInstance.getData(from: URL(string: strImageName!)!) { data, response, err in
                if err == nil {
                    DispatchQueue.main.async {
                        self.imgDisplayImg.image = UIImage(data: data!)
                    }
                }
            }
            imgDisplayImg.image = UIImage(named: strImageName!)
        } else {
            imgDisplayImg.image = imgSelectedImage
        }
        
    }


}
