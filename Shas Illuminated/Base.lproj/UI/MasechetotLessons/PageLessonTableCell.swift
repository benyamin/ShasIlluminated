//
//  PageLessonTableCell.swift
//  Shas Illuminated
//
//  Created by Binyamin on 20 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import UIKit

class PageLessonTableCell: MSBaseTableViewCell {
    
    var daf:Daf?
    var shiur:Shiur?
    
    var delegate:ShiursDelegate?
        
     @IBOutlet weak var cardView:UIView?
        
    @IBOutlet weak var sponserView:UIView?
    @IBOutlet weak var sponserViewHeightConstriant:NSLayoutConstraint?
    @IBOutlet weak var sponserTitleLabel:UILabel?
    @IBOutlet weak var sponserInfoLabel:UILabel?
    @IBOutlet weak var inMemeoryTitleLabel:UILabel?
    @IBOutlet weak var inMemeoryInfoLabel:UILabel?
    
    @IBOutlet weak var maggidShiourView:UIView?
    @IBOutlet weak var maggidShiourIconImageView:UIImageView?
    @IBOutlet weak var maggidShiourNameLabel:UILabel?
    @IBOutlet weak var durationLabel:UILabel?
    @IBOutlet weak var playButton:UIButton?
    @IBOutlet weak var downloadButton:ProgressButton?
    @IBOutlet weak var mareiMekomosButton:UIButton?
    @IBOutlet weak var mareiMekomosButtonSecondaryTopConstrinat:NSLayoutConstraint?

    
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
        
        self.sponserTitleLabel?.text = "This Daf is Sponsored by:"
        self.inMemeoryTitleLabel?.text = "In memory of:"
        
        self.playButton?.layer.cornerRadius = 3.0
        self.downloadButton?.layer.cornerRadius = 3.0
        self.mareiMekomosButton?.layer.cornerRadius = 3.0
        
        self.reloadData()
    }
    
    override func reloadWithObject(_ object: Any) {
        
        let info = object as! [String:Any]
        self.daf = info["daf"] as? Daf
        self.shiur = info["shiur"] as? Shiur
                
        self.reloadData()
        
    }
    
    override func reloadData()
    {
        if let sponsers = self.daf?.sponsers
            , sponsers.count > 0
        {
            self.sponserInfoLabel?.text = self.daf?.sponsers?.first?.name
            self.inMemeoryInfoLabel?.text = self.daf?.sponsers?.first?.dedicated_to ?? ""
            
            self.sponserViewEnabled(true)
        }
        else{
            self.sponserViewEnabled(false)
        }
        
        self.maggidShiourIconImageView?.image(name: "blank_profile")
        self.maggidShiourIconImageView?.image(name: self.shiur?.maggidShiur?.imagePath ?? "blank_profile")
        
        self.maggidShiourNameLabel?.text = self.shiur?.maggidShiur?.name
        
        if let duration = self.shiur?.length
        {
            self.durationLabel?.text = "lesson duration".localize() + ": \(duration)"
            self.durationLabel?.isHidden = false
        }
        else{
            self.durationLabel?.isHidden = true
        }
        
         //Check url is audio and not file
        if let url_download = shiur?.url_download
            ,(url_download.hasSuffix("docx") || url_download.hasSuffix("pdf")) {
         
                self.playButton?.isHidden = true
                self.downloadButton?.isHidden = true
                self.durationLabel?.isHidden = true
                self.mareiMekomosButtonSecondaryTopConstrinat?.priority = UILayoutPriority(rawValue: 900)
            }
            else {
                self.durationLabel?.isHidden = false
                self.playButton?.isHidden = false
                self.downloadButton?.isHidden = false
                self.mareiMekomosButtonSecondaryTopConstrinat?.priority = UILayoutPriority(rawValue: 500)
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
        
        if self.shiur != nil {
            
            if let _ = DownloadManager.sharedManager.pathForShiour(self.shiur!)
            {
                self.downloadButton?.isSelected = true
            }
            else{
                self.downloadButton?.isSelected = false
            }
        }
    }
    
    func setDownloadLayout()
    {
        if let shiur = self.shiur
        {
            
            //if shiur is saved localy
            if let _ = DownloadManager.sharedManager.pathForShiour(shiur)
            {
                self.downloadButton?.isSelected = true
            }
            
            if DownloadManager.sharedManager.isDowloadingShiur(shiur)
            {
                let downloadProgressPercentage = DownloadManager.sharedManager.downloadProgressPercentageForShiur(shiur)
                
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
    
    func sponserViewEnabled(_ enabled:Bool)
    {
        self.sponserTitleLabel?.isHidden = !enabled
        self.sponserInfoLabel?.isHidden = !enabled
        self.inMemeoryTitleLabel?.isHidden = !enabled
        self.inMemeoryInfoLabel?.isHidden = !enabled
        
        if enabled
        {
            sponserViewHeightConstriant?.priority = UILayoutPriority(rawValue: 500)
        }
        else{
            sponserViewHeightConstriant?.priority = UILayoutPriority(rawValue: 900)
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
    
    @IBAction func downloadButtonnClicked(_ sender:ProgressButton)
    {
        if let shiur = self.shiur
        {
            if shiur.isSaved()
            {
                self.removeShiur(shiur)
            }
            else{
                
                sender.setPercentage(0)
                DownloadManager.sharedManager.downloadShiur(shiur)
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
    
    @IBAction func mareiMekomosButtonClicked(_ sender:UIButton)
    {
        if let shiur = self.shiur
        {
            self.delegate?.onShowMareiMekomoForshiur(shiur)
        }
    }
}
