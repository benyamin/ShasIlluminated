//
//  PartnerCollectionCell.swift
//  Shas Illuminated
//
//  Created by Binyamin on 1 Tevet 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import UIKit

class PartnerCollectionCell: UICollectionViewCell {
    
    var partner:Partner?
    
    @IBOutlet weak var imageView:UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reloadData()
        
        self.imageView?.layer.borderColor = UIColor.white.cgColor
        self.imageView?.layer.borderWidth = 1.0
        self.imageView?.layer.cornerRadius = (self.imageView?.frame.size.width ?? 0)/2
    }
    
    func reloadWithObject(_ object:Any)
    {
        self.partner = object as? Partner
        
        self.reloadData()
    }
    
    func reloadData()
    {
       self.imageView?.image(name: self.partner?.imagePath ?? "")
    }
    
}
