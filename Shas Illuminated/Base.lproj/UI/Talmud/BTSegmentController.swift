//
//  BTSegmentController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 05/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

protocol BTSegmentControllerDelegate {
    func segmentController(_ segmentController:BTSegmentController, valueChanged index:Int)
}

class BTSegmentController: UIView {

    @IBOutlet var buttonCollectoin:[UIButton]!
    
    var delegate:BTSegmentControllerDelegate?
    
    var selectedSegmentIndex:Int{
        get{
            
            for button in buttonCollectoin
            {
                if button.isSelected
                {
                    return button.tag
                }
            }
            return 0
        }
        set (value){
            for button in buttonCollectoin
            {
                button.isSelected = false
                
                if button.tag == value {
                   button.isSelected = true
                    self.buttonClicked(button)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for button in self.buttonCollectoin
        {
            button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        }
    }
    
    @objc func buttonClicked(_ sender:UIButton)
    {
        for button in self.buttonCollectoin
        {
            button.isSelected = false
        }
        
        sender.isSelected = true
        
        self.delegate?.segmentController(self, valueChanged: sender.tag)

    }
    

}
