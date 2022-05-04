//
//  MaggidShiurTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin on 22 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MaggidShiurTableCell: MSBaseTableViewCell {

    var maggidShiur:MaggidShiur?
    
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var iconImageView:UIImageView?
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var numberOfLessonsLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reloadData()
        
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
        self.iconImageView?.layer.cornerRadius = self.iconImageView!.frame.size.width/2
    }
    
    override func reloadWithObject(_ object: Any) {
        
        self.maggidShiur = object as? MaggidShiur
        
        self.reloadData()
    }
    
    override func reloadData() {
       
        self.iconImageView?.image = UIImage(named:"blank_profile.jpg")
        self.iconImageView?.image(name: self.maggidShiur?.imagePath ?? "blank_profile")
        
        self.nameLabel?.text = self.maggidShiur?.name
        
        if let numberOfShiurim = self.maggidShiur?.shiurim_count
        {
            self.numberOfLessonsLabel?.text = "(\(numberOfShiurim) \("shiurim".localize())"
            self.numberOfLessonsLabel?.isHidden = false
        }
        else{
              self.numberOfLessonsLabel?.isHidden = true
        }
       
    }
}
