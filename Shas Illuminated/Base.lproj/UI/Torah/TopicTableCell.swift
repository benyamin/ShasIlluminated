//
//  TopicTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 25/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class TopicTableCell: MSBaseTableViewCell {
    
    var topic:Topic?

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
        self.titleLabel?.text = self.topic?.name
    }
}


