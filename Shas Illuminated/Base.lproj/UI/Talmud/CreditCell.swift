//
//  CreditCell.swift
//  Shas Illuminated
//
//  Created by Binyamin on 19 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import UIKit

class CreditCell: MSBaseTableViewCell {

    var sponser:Sponser?
    
    @IBOutlet weak var dedicatedByTitleLabel:UILabel?
    @IBOutlet weak var dedicatedByInfoLabel:UILabel?
    @IBOutlet weak var inMemporyOfTitleLabel:UILabel?
    @IBOutlet weak var inMemporyOfInfoLabel:UILabel?
    
    override func reloadWithObject(_ object: Any) {
        
        self.sponser = object as? Sponser
        
        if let volume_number = self.sponser?.volume_number
        {
            self.dedicatedByTitleLabel?.text = "VOL. \(volume_number) DEDICATED BY:"
        }
        else{
             self.dedicatedByTitleLabel?.text = "DEDICATED BY:"
        }
        
        self.dedicatedByInfoLabel?.text = self.sponser?.name
        
        if let dedicated_to = self.sponser?.dedicated_to
        ,dedicated_to.count > 0
        {
             self.inMemporyOfTitleLabel?.text = "IN MEMORY OF:"
            self.inMemporyOfInfoLabel?.text = dedicated_to
        }
        else{
             self.inMemporyOfTitleLabel?.text = ""
            self.inMemporyOfInfoLabel?.text = ""
        }
       
        
    }

}
