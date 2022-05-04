//
//  SavedShiurTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 14/01/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

protocol SavedShiurTableCellDelegate:ShiursDelegate
{
    func savedShiurTableCell(_ cell:SavedShiurTableCell, shuldDeleteShiur shiur:Shiur)
}

class SavedShiurTableCell: MSBaseTableViewCell {

    var delegate:SavedShiurTableCellDelegate?
    
    var shiur:Shiur?
    
    @IBOutlet weak var cardView:UIView?
    
    @IBOutlet weak var englishTitleLabel:UILabel?
    @IBOutlet weak var maggidShiourIconImageView:UIImageView?
    @IBOutlet weak var maggidShiourNameLabel:UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
         self.maggidShiourIconImageView?.layer.cornerRadius = self.maggidShiourIconImageView!.frame.size.width/2
        
        self.reloadData()
    }

    override func reloadWithObject(_ object: Any) {
        
        self.shiur = object as? Shiur
        
        self.reloadData()
        
    }
    
    override func reloadData() {
        
        self.englishTitleLabel?.text = self.shiur?.mainTitle
        self.maggidShiourIconImageView?.image(name: "blank_profile")
             self.maggidShiourIconImageView?.image(name: self.shiur?.maggidShiur?.imagePath ?? "blank_profile")
        self.maggidShiourNameLabel?.text = self.shiur?.maggidShiur?.name
    }
    
    @IBAction func deleteButtonClicked(_ sender:UIButton)
    {
        self.delegate?.savedShiurTableCell(self, shuldDeleteShiur:self.shiur!)
    }
    
    @IBAction func playButtonClicked(_ sender:UIButton)
      {
          if self.shiur != nil
          {
              self.delegate?.onPlayShiour(shiur!, type: .Audio)
          }
      }
}
