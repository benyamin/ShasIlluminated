//
//  SederTableHeaderCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 17/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

protocol CreditDelegate:class
{
    func onDisplayCredits(sponsers:[Sponser])
}

class SederTableHeaderCell: MSBaseTableViewCell {

    var seder:Seder?
    
    var creditDelegate:CreditDelegate?
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var candelButton:UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func reloadWithObject(_ object: Any) {
        
        self.seder = object as? Seder
    
        if let englishName = self.seder?.englishName
        {
            var title = "Seder: \(englishName)"
            
            if let hebrewName = self.seder?.hebrewName
            {
                title += " (\(hebrewName))"
            }
            
              self.titleLabel?.text = title
        }
         if let sponsers = self.seder?.sponsers
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
        if let sponsers = self.seder?.sponsers
        {
            for sponser in sponsers
            {
                sponser.sponserdTitle = self.seder?.englishName
            }
            self.creditDelegate?.onDisplayCredits(sponsers: sponsers)
        }
    }

}
