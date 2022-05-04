//
//  BTPlayerRateSpeedView.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 13/10/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

protocol BTPlayerRateSpeedViewDelegate: class {
    
    func rateSpeedView(_ rateSpeedView:BTPlayerRateSpeedView, valueChanged value:Float)
}

class BTPlayerRateSpeedView: UIView
{
    weak var delegate:BTPlayerRateSpeedViewDelegate?
    
    @IBOutlet weak var backGroundView:UIView?
    @IBOutlet weak var rateSpeedTitleLabel:UILabel?
    @IBOutlet weak var rateSpeedSlider:UISlider?
    @IBOutlet weak var rateSpeedSliderValue:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backGroundView?.layer.borderColor = UIColor(HexColor:"FAF2DD").cgColor
         backGroundView?.layer.borderWidth = 2.0
        
        self.backGroundView?.layer.cornerRadius = 5.0
        
        if rateSpeedSlider != nil
        {
            self.rateSpeedTitleLabel?.text = "\("Speed Rate".localize()) x\(String(format: "%.1f", rateSpeedSlider!.value))"
        }
      
        /*
        let snailImage = UIImage(named:"snail_icon.png")
        
        self.rateSpeedSlider?.setThumbImage(snailImage, for: .normal)
        self.rateSpeedSlider?.setThumbImage(snailImage, for: .highlighted)
 */
    }
    
    @IBAction func sliderChanged(_ slider:UISlider)
    {
         self.rateSpeedTitleLabel?.text = "\("Speed Rate".localize()) x\(String(format: "%.1f", slider.value))"
        
        self.delegate?.rateSpeedView(self, valueChanged: slider.value)
    }
}
