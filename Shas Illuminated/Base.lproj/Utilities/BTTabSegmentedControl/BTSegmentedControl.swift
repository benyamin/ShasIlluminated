//
//  BTSegmentedControl.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/02/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class BTSegmentedControl: UIControl {

    @IBOutlet var sgementedButtons:[UIButton]!
    
    var selectedSegmentIndex:Int{
        
        get{
            for button in self.sgementedButtons{
                if button.isSelected{
                    return button.tag
                }
            }
            return 0
        }
        set {
            
            for button in self.sgementedButtons{
                if button.tag == newValue{
                     button.isSelected = true
                }
                else{
                      button.isSelected = false
                }
            }
        }
    }
    
    override func awakeFromNib() {
        
        self.layer.shadowColor = UIColor.black.cgColor
          self.layer.shadowOpacity = 0.6
          self.layer.shadowOffset = CGSize(width: 2, height: 2)
          self.layer.shadowRadius = 5
          self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        
        self.sgementedButtons = sgementedButtons.sorted(by: { $0.frame.origin.x < $1.frame.origin.x })
        
        for index in 0 ..< self.sgementedButtons.count {
            
            let button = self.sgementedButtons[index]
            button.tag = index
            button.addTarget(self, action: #selector(sgementedButtonClicked), for: .touchUpInside)
        }
    }
    
    @IBAction func sgementedButtonClicked(_ sender:UIButton){
        
        for button in self.sgementedButtons{
            if button == sender {
                button.isSelected = true
            }
            else{
                button.isSelected = false
            }
        }
        
        self.sendActions(for: .valueChanged)
    }
}
