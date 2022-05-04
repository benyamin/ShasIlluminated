//
//  TopicHeaderTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 25/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//


import UIKit

protocol TopicHeaderTableCellDelegate:class
{
    func topicHeaderTableCell(toogleValueChanged value:Bool, topic:Topic)
}

class TopicHeaderTableCell: MSBaseTableViewCell {
    
    var delegate:TopicHeaderTableCellDelegate?
    
    var topic:Topic?
    
    @IBOutlet weak var toggleButton:UIButton?
    @IBOutlet weak var titleLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.topic = object as? Topic
        
        self.reloadData()
    }
    
    override func reloadData()
    {
        self.toggleButton?.isSelected = false
        self.toggleButton?.transform = .identity
        
        if topic?.shouldShowChildern == true
        {
            self.toggleButton?.isSelected = true
             self.toggleButton?.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
        self.titleLabel?.text = self.topic?.name
    }
    
    @IBAction func toggleButtonClicked(_ sender:UIButton)
    {
        self.toggleButton?.isSelected = !toggleButton!.isSelected
        
        self.topic?.shouldShowChildern = self.toggleButton?.isSelected ?? false
        
        if self.topic != nil
        {
            self.delegate?.topicHeaderTableCell(toogleValueChanged: sender.isSelected, topic: self.topic!)
        }
    }
}
