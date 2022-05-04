//
//  MasecehtTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 17/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MasecehtTableCell: MSBaseTableViewCell {
    
    var masechet:Masechet?
    
    var creditDelegate:CreditDelegate?
    
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var candelButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any) {
        
        self.masechet = object as? Masechet
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        if let englishName = self.masechet?.englishName
        {
            var title = englishName
            
            if let hebrewName = self.masechet?.hebrewName
            {
                title += " (\(hebrewName))"
            }
            
            self.titleLabel?.text = title
        }
        
        if let sponsers = self.masechet?.sponsers
            , sponsers.count > 0
        {
            candelButton?.isHidden  = false
        }
        else{
            candelButton?.isHidden  = true
        }
    }
    
    @IBAction func candelButtonCliked(_ sender:UIButton)
    {
        if let sponsers = self.masechet?.sponsers
        {
            for sponser in sponsers
            {
                sponser.sponserdTitle = self.masechet?.englishName
            }
            
            self.creditDelegate?.onDisplayCredits(sponsers: sponsers)
        }
    }
    
}

