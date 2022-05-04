//
//  MSBaseTableViewCell.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 07/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MSBaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if ShasIlluminatedManager.sharedManager.selectedLanguage == .Hebrew {
            //self.semanticContentAttributeDrilldown(.forceRightToLeft)
        }
        
        self.setLocalizatoin()
    }

    func reloadWithObject(_ object:Any){
        
    }
    
    func reloadData(){
        
    }
    
    func parentTableView() -> UITableView? {
        var viewOrNil: UIView? = self
        while let view = viewOrNil {
            if let tableView = view as? UITableView {
                return tableView
            }
            viewOrNil = view.superview
        }
        return nil
    }

}
