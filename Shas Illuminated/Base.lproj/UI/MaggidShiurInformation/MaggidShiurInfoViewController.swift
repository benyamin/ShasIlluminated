//
//  MaggidShiurInfoViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 10/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MaggidShiurInfoViewController: MSBaseViewController {

    var maggidShiur:MaggidShiur?
    
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var numberOfLessonsLabel:UILabel?
    @IBOutlet weak var maggidIconImageView:UIImageView?
    @IBOutlet weak var maggidNameLabel:UILabel?
    @IBOutlet weak var maggidInfoTextView:UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.maggidInfoTextView?.text = ""
            
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor

        reloadData()
    }

    override func reloadWithObject(_ object: Any)
    {
        self.maggidShiur = object as? MaggidShiur
        
        self.reloadData()
    }
    
    func reloadData()
    {
        self.maggidIconImageView?.image(name: self.maggidShiur?.imagePath ?? "blank_profile")
        
        self.maggidNameLabel?.text = self.maggidShiur?.name
        self.maggidInfoTextView?.text = self.maggidShiur?.bio?.htmlToString
        
        if let numberOfShiurim = self.maggidShiur?.shiurim_count
        {
            self.numberOfLessonsLabel?.text = "(\(numberOfShiurim) \("shiurim".localize())"
            self.numberOfLessonsLabel?.isHidden = false
        }
        else{
            self.numberOfLessonsLabel?.isHidden = true
        }
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
