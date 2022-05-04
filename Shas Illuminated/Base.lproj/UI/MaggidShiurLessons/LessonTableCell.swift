//
//  LessonTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 24/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class  LessonTableCell: MSBaseTableViewCell {
    
    var shiur:Shiur?
    
    var delegate:ShiursDelegate?
    
    weak var navigationController: UINavigationController?
    
    @IBOutlet weak var cardView:UIView?
    
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var englishTitleLabel:UILabel?
    @IBOutlet weak var dateLabel:UILabel?
    @IBOutlet weak var durationLabel:UILabel?
    @IBOutlet weak var messageLabel:UILabel?
    @IBOutlet weak var playButton:UIButton?
    @IBOutlet weak var playVideoButton:UIButton?
    @IBOutlet weak var downloadButton:ProgressButton?
    @IBOutlet weak var mareiMekomosButton:UIButton?
    @IBOutlet weak var dateLabelSecondaryBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var mareiMekomosButtonSecondaryTopConstrinat:NSLayoutConstraint?
    @IBOutlet weak var playButtonConstrintToDonwload:NSLayoutConstraint?
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateDownloadStatus(_:)), name: NSNotification.Name(rawValue: "downloadDidProgress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadComplete(_:)), name: NSNotification.Name(rawValue: "downloadComplete"), object: nil)
        
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "5FAED2").cgColor
        
        self.playButton?.layer.cornerRadius = 3.0
        self.downloadButton?.layer.cornerRadius = 3.0
        self.mareiMekomosButton?.layer.cornerRadius = 3.0
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any) {
        
        self.shiur = object as? Shiur
        
        self.reloadData()
    }
    
    override func reloadData()
    {
        if let title = self.shiur?.englishTitle
        ,title.count > 0
        {
             self.englishTitleLabel?.text = title
        }
        else{
              self.englishTitleLabel?.text = self.shiur?.name ?? ""
        }
        
        if let duration = self.shiur?.length
        {
            self.durationLabel?.text = "\(duration)"
            self.durationLabel?.isHidden = false
        }
        else{
            self.durationLabel?.isHidden = true
        }
        
        if let shiurDate = self.shiur?.edited ?? self.shiur?.recordingDate
        {
            self.dateLabel?.text = shiurDate
             self.dateLabel?.isHidden = false
        }
        else{
            self.dateLabel?.isHidden = true
        }
        
        if let message = self.shiur?.message
        {
            self.messageLabel?.text = message
            self.messageLabel?.isHidden = false
            //dateLabelSecondaryBottomConstraint?.constant = 500
        }
        else{
            self.messageLabel?.isHidden = true
             //dateLabelSecondaryBottomConstraint?.constant = 900
        }
        
        //Check url is audio and not file
        if let url_download = shiur?.url_download
            ,(url_download.hasSuffix("docx") || url_download.hasSuffix("pdf")) {
            
             self.durationLabel?.isHidden = true
            self.playButton?.isHidden = true
            self.downloadButton?.isHidden = true
            self.mareiMekomosButtonSecondaryTopConstrinat?.priority = UILayoutPriority(rawValue: 900)
        }
        else {
             self.durationLabel?.isHidden = false
            self.playButton?.isHidden = false
            self.downloadButton?.isHidden = false
            self.mareiMekomosButtonSecondaryTopConstrinat?.priority = UILayoutPriority(rawValue: 500)
        }
        
        if self.shiur?.url_video_download != nil{
            self.playButtonConstrintToDonwload?.priority = UILayoutPriority(rawValue: 500)
            self.playVideoButton?.isHidden = false
        }
        else{
            
            self.playButtonConstrintToDonwload?.priority = UILayoutPriority(rawValue: 900)
            self.playVideoButton?.isHidden = true
        }
        
        self.downloadButton?.isSelected = false
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
        if self.shiur != nil
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
    
    @IBAction func playVideoButtonClicked(_ sender:UIButton){
        
        if self.shiur != nil
        {
            if self.playButton?.isSelected ?? false{
                 self.delegate?.onPauseShiour(shiur!)
            }
            else {
                self.delegate?.onPlayShiour(shiur!, type: .Video)
            }
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
    
    @IBAction func mareiMekomosButtonClicked(_ sender:UIButton)
    {
        self.delegate?.onShowMareiMekomoForshiur(self.shiur!)
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
    
    func removeMareiMekomosOption() {
        self.mareiMekomosButton?.removeFromSuperview()
    }
}
