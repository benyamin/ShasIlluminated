//
//  BTMenuCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 17/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class BTMenuCell: MSBaseTableViewCell {

    var title:String?
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var iconImageView:UIImageView?
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var cardViewLedingConstraint:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.cardView?.backgroundColor = UIColor.white
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
        self.cardViewLedingConstraint?.constant = -1 * (self.cardView?.frame.size.width ?? 0)
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.title = object as? String
        
        self.reloadData()
    }
    
    override func reloadData()
    {
        self.titleLabel?.text = self.title?.localize()
    }
    
    func showAfterDelay(_ delay:Double)
    {
        self.cardViewLedingConstraint?.constant = 4.0

        UIView.animate(withDuration: 0.4, delay:delay, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func hideAfterDelay(_ delay:Double)
    {
        self.hide()
        
        UIView.animate(withDuration: 0.4, delay:delay, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    func hide()
    {
        self.cardViewLedingConstraint?.constant = -1 * ((self.cardView?.frame.size.width ?? 0) + 20)
    }
}
