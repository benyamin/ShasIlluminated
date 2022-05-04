//
//  TorahShiurTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 22/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class TorahShiurTableCell: MSBaseTableViewCell {
    
    var shiur:TorahShiur?
    
    var delegate:ShiursDelegate?
    
    weak var navigationController: UINavigationController?
    
    @IBOutlet weak var cardView:UIView?
    
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var englishTitleLabel:UILabel?
    
    @IBOutlet weak var sponserView:UIView?
    @IBOutlet weak var topicTitleLabel:UILabel?
    @IBOutlet weak var topicInfoLabel:UILabel?
    @IBOutlet weak var dateTitleLabel:UILabel?
    @IBOutlet weak var dateInfoLabel:UILabel?
    
    @IBOutlet weak var maggidShiourView:UIView?
    @IBOutlet weak var maggidShiourIconImageView:UIImageView?
    @IBOutlet weak var maggidShiourNameLabel:UILabel?
    @IBOutlet weak var durationLabel:UILabel?
    @IBOutlet weak var playButton:UIButton?
    @IBOutlet weak var playVideoButton:UIButton?
    @IBOutlet weak var playButtonConstrintToDonwload:NSLayoutConstraint?
    @IBOutlet weak var downloadButton:ProgressButton?
    @IBOutlet weak var mareiMekomosButton:UIButton?
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateDownloadStatus(_:)), name: NSNotification.Name(rawValue: "downloadDidProgress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadComplete(_:)), name: NSNotification.Name(rawValue: "downloadComplete"), object: nil)
        
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
        self.maggidShiourIconImageView?.layer.cornerRadius = self.maggidShiourIconImageView!.frame.size.width/2
        
        self.topicTitleLabel?.text = "\("Topic".localize()):"
        self.dateTitleLabel?.text = "\("Date".localize()):"
        
        self.playButton?.layer.cornerRadius = 3.0
        self.downloadButton?.layer.cornerRadius = 3.0
        self.mareiMekomosButton?.layer.cornerRadius = 3.0
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any) {
        
        self.shiur = object as? TorahShiur
        
        self.reloadData()
        
    }
    
    override func reloadData()
    {
        if let englishTitle = self.shiur?.name
        {
            self.englishTitleLabel?.text = englishTitle
        }
        
        self.maggidShiourIconImageView?.image(name: "blank_profile")
        self.maggidShiourIconImageView?.image(name: self.shiur?.maggidShiur?.imagePath ?? "blank_profile")
        
        self.maggidShiourNameLabel?.text = self.shiur?.maggidShiur?.name
        
        if let duration = self.shiur?.length
        {
            self.durationLabel?.text = duration
            self.durationLabel?.isHidden = false
        }
        else{
            self.durationLabel?.isHidden = true
        }
        
        self.dateInfoLabel?.text = self.shiur?.recordingDate
        
        self.topicInfoLabel?.text = self.shiur?.topic?.name//(self.shiur?.topic?.parent?.name ?? "")  + ">" + (self.shiur?.topic?.name ?? "")
        
        self.downloadButton?.isSelected = false
        
        if self.shiur?.url_video_download != nil{
            self.playButtonConstrintToDonwload?.priority = UILayoutPriority(rawValue: 500)
            self.playVideoButton?.isHidden = false
        }
        else{
            
            self.playButtonConstrintToDonwload?.priority = UILayoutPriority(rawValue: 900)
            self.playVideoButton?.isHidden = true
        }
        self.setDownloadLayout()
    }
    
    @objc func didUpdateDownloadStatus(_ notification: Notification)
    {
        self.setDownloadLayout()
    }
    
    @objc func downloadComplete(_ notification: Notification)
    {
        self.downloadButton?.setDefaultLayout()
        self.downloadButton?.isSelected = true
    }
    
    func setDownloadLayout()
    {
        if shiur != nil
        {
            //if shiur is saved localy
            if let _ = DownloadManager.sharedManager.pathForShiour(shiur!)
            {
                self.downloadButton?.isSelected = true
            }
            
            if DownloadManager.sharedManager.isDowloadingShiur(shiur!)
            {
                let downloadProgressPercentage = DownloadManager.sharedManager.downloadProgressPercentageForShiur(shiur!)
                
                self.downloadButton?.setPercentage(downloadProgressPercentage)
            }
            else{
                self.downloadButton?.setDefaultLayout()
            }
        }
        else{
            self.downloadButton?.setDefaultLayout()
        }
    }
    
    
    @IBAction func playButtonClicked(_ sender:UIButton)
    {
        if let navController = self.navigationController
        {
            for viewController in navController.viewControllers
            {
                if viewController is TorahViewController
                {
                    navController.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
        
        if self.shiur != nil
        {
            if self.playButton?.isSelected ?? false{
                self.delegate?.onPauseShiour(shiur!)
            }
            else {
                self.delegate?.onPlayShiour(shiur!, type: .Audio)
            }
        }
    }
    
    
    @IBAction func playVideoButtonClicked(_ sender:UIButton)
    {
        if let navController = self.navigationController
        {
            for viewController in navController.viewControllers
            {
                if viewController is TorahViewController
                {
                    navController.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
        
        if self.shiur != nil
        {
            if self.playButton?.isSelected ?? false {
                
                self.delegate?.onPauseShiour(self.shiur!)
                self.playButton?.isSelected = false
                self.playButton?.isHighlighted = false
            }
            
            self.delegate?.onPlayShiour(shiur!, type: .Video)
        }
    }
        
    @IBAction func downloadButtonnClicked(_ sender:ProgressButton)
    {
        if self.shiur != nil
        {
            if shiur!.isSaved()
            {
                self.removeShiur(shiur!)
            }
            else{
                
                sender.setPercentage(0)
                DownloadManager.sharedManager.downloadShiur(shiur!)
            }
        }
    }
    
    func removeShiur(_ shiur:Shiur)
    {
        let title = "Remove Shiur"
        let msg = "Are you sure you want to remove this shiur"
        let yesButton = "Yes"
        let noButton = "No"
        BTAlertView.show(title: title, message: msg, buttonKeys: [yesButton,noButton], onComplete:{ (dismissButtonKey) in
            
            if dismissButtonKey == yesButton
            {
                DeleteShiurProcess().executeWithObject(shiur, onStart: { () -> Void in
                    
                }, onComplete: { (object) -> Void in
                    
                    self.downloadButton?.isSelected = false
                    self.downloadButton?.setDefaultLayout()
                    
                },onFaile: { (object, error) -> Void in
                    
                })
            }
        })
    }
}

