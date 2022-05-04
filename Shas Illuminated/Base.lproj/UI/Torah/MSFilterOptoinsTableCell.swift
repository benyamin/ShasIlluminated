//
//  MSFilterOptoinsTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 10/06/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MSFilterOptoinsTableCell: MSBaseTableViewCell {

    var filterOption:FilterOption?
    
    @IBOutlet weak var optionLabel:UILabel?
    @IBOutlet weak var selectionCheckButton:UIButton?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.selectionCheckButton?.layer.cornerRadius = self.selectionCheckButton!.frame.size.width/2
        self.selectionCheckButton?.layer.borderColor = UIColor.black.cgColor
        self.selectionCheckButton?.layer.borderWidth = 1.0
    }
    
    override func reloadWithObject(_ object: Any) {
        
        self.filterOption = object as? FilterOption
        
        self.reloadData()
    }
    
    override func reloadData() {
        
        self.optionLabel?.text = self.filterOption?.optionName
    }
}
