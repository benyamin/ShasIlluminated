//
//  PageLessonsHeaderCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 19/04/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class PageLessonsHeaderCell: MSBaseTableViewCell {

    var daf:Daf?
    
    @IBOutlet weak var englishTitleLabel:UILabel?
    @IBOutlet weak var hebrewhTitleLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func reloadWithObject(_ object: Any) {
        
        self.daf = object as? Daf
        
        self.reloadData()
        
    }
    
    override func reloadData() {
        
        if let englishName = self.daf?.masechet?.englishName
          {
              var englishTitle = englishName
              
              if let pageIndex = self.daf?.daf
              {
                  englishTitle += " - \(pageIndex)"
              }
              self.englishTitleLabel?.text = englishTitle
          }
          
          if let hebrewName = self.daf?.masechet?.hebrewName
          {
              var hebrewTitle = hebrewName
              
              if let pageSymbol = self.daf?.symbol
              {
                  hebrewTitle += " - \(pageSymbol)"
              }
              
              self.hebrewhTitleLabel?.text = hebrewTitle
          }
    }

}
