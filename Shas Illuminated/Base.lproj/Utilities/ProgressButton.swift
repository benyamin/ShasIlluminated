//
//  ProgressButton.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 30/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ProgressButton: UIButton {

    private var percentageView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    private lazy var percentageLabel:UILabel = {
        
        let label = UILabel(frame: CGRect(x: 8, y: 4, width: self.bounds.width - 8, height: self.bounds.height-4))
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        return label
    }()
    
    override func awakeFromNib() {
        
        self.clipsToBounds = true

        self.addSubview(self.percentageView)
        self.addSubview(self.percentageLabel)
        
        
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected
            {
                self.backgroundColor = UIColor.init(HexColor: "2A5F87")
            }
            else{
                self.backgroundColor = UIColor.init(HexColor: "639EDB")
            }
        }
    }
    
    func setPercentage(_ percentage:CGFloat)
    {
         self.setTitle("", for: .normal)
        
        self.percentageLabel.isHidden = false
        
        if percentage == 0
        {
             self.percentageView.isHidden = true
            self.percentageLabel.text = "Preparing to download".localize()
        }
        else{
             self.percentageView.isHidden = false
            
            self.percentageView.frame = CGRect(x: 0, y: 0, width: (self.frame.size.width/100)*percentage, height: self.bounds.height)
            self.percentageView.backgroundColor =  UIColor.init(HexColor: "2A5F87")
            
            self.percentageLabel.text = "\("Downloading".localize()) \(String(format: "%.2f", percentage))%"
        }
    }
    
    func setDefaultLayout()
    {
        self.setTitle("Download".localize(), for: .normal)
        self.percentageView.isHidden = true
        self.percentageLabel.isHidden = true
    }
}
