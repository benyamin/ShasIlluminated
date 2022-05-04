//
//  SavedShiursViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 14/01/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class SavedShiursViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, SavedShiurTableCellDelegate
{
    var talmudShiurs:[Shiur]?
    var torahShiurs:[Shiur]?
    
    @IBOutlet weak var shiursTableView:UITableView?
    @IBOutlet weak var playerTopConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var plyerViewPlaceHolder:UIView?

      var plyerView:BTPlayerView? {
          get {
              ShasIlluminatedManager.sharedManager.plyerView
          }
      }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.plyerViewPlaceHolder?.addSubview(self.plyerView!)
        self.plyerView!.addSidedConstraints()
        
        self.getSavedShiurs()
    }
    
    func getSavedShiurs()
    {
        GetSavedShiursProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.reloadWithObject(object)
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    override func reloadWithObject(_ object: Any) {
        
        if let savedShiurs = object as? [String:[Shiur]]
        {
            self.talmudShiurs = savedShiurs["Talmud"]
            self.torahShiurs = savedShiurs["Torah"]
            
            if (self.talmudShiurs?.count ?? 0) + (self.torahShiurs?.count ?? 0) == 0 {
                
                self.playerTopConstraint?.constant = -1 * (self.shiursTableView?.frame.origin.y ?? -16)
            }
            else{
                 self.playerTopConstraint?.constant = 16
            }
            
            self.reloadData()
        }
    }
    
    func reloadData(){
        
        self.shiursTableView?.reloadData()
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func removeShiur(_ shiur:Shiur)
    {
        DeleteShiurProcess().executeWithObject(shiur, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.getSavedShiurs()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    func playShiour(_ shiour:Shiur)
    {
        if let playingUrl = self.plyerView?.playerUrl
            ,shiour.lessonUrl()?.absoluteString == playingUrl.absoluteString {
            
            if self.plyerView?.isPaused ?? false {
                self.plyerView?.play()
                
                return
            }
        }
        
        self.plyerView?.iconImageView?.image(name: shiour.maggidShiur?.imagePath ?? "blank_profile")
        
        self.plyerView?.title = shiour.maggidShiur?.name ?? ""
      
        self.plyerView?.subTitle = shiour.name ?? ""
        
        self.playerTopConstraint?.constant = 16
        
        // If shiour is saved localy
        if let lessonPath = DownloadManager.sharedManager.pathForShiour(shiour)
        {
            let lessonUrl = URL(fileURLWithPath: lessonPath)
             self.plyerView?.setPlayerUrl(lessonUrl, durration: 0, onReadyToPlay: {
                           self.plyerView?.play()
                       }, onLessonNotFound: { })
        }
        else{
            if let lessonUrlPath = shiour.url_download
                ,let lessonUrl = URL(string: lessonUrlPath)
            {
                 self.plyerView?.setPlayerUrl(lessonUrl, durration: 0, onReadyToPlay: {
                               self.plyerView?.play()
                           }, onLessonNotFound: { })
            }
        }
        
        self.playerTopConstraint?.constant = 16
        
        UIView.animate(withDuration: 0.3, delay:0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
      
    
    // MARK: - UITableView Delegate Methods:
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
         return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "SavedShiurHeaderTableCell") as! SavedShiurHeaderTableCell
        
        switch section {
        case 0:
            sectionHeader.titleLabel?.text = "Talmud".localize()
            break
            
        case 1:
            sectionHeader.titleLabel?.text = "Torah"
            break
            
        default:
            break
        }
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case 0:
            return self.talmudShiurs?.count ?? 0
            
        case 1:
            return self.torahShiurs?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedShiurTableCell", for:indexPath) as! SavedShiurTableCell
        cell.selectionStyle = .none
        
        cell.delegate = self
        
        switch indexPath.section {
        case 0:
            if let shiur = self.talmudShiurs?[indexPath.row] {
                cell.reloadWithObject(shiur)
            }
            break
            
        case 1:
            if let shiur = self.torahShiurs?[indexPath.row] {
                cell.reloadWithObject(shiur)
            }
            break
            
        default: break
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            switch indexPath.section {
                  case 0:
                      if let shiur = self.talmudShiurs?[indexPath.row] {
                          self.removeShiur(shiur)
                      }
                      break
                      
                  case 1:
                      if let shiur = self.torahShiurs?[indexPath.row] {
                        self.removeShiur(shiur)
                      }
                      break
                      
                  default: break
                      
                  }
        }
    }
        
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
          self.playerTopConstraint?.constant = -1 * (scrollView.contentOffset.y - 16)
      }
    
    
    //MARK: SavedShiurTableCell delegate methods
    func savedShiurTableCell(_ cell:SavedShiurTableCell, shuldDeleteShiur shiur:Shiur)
    {
        self.removeShiur(shiur)
    }
    
    func onPlayShiour(_ shiour:Shiur, type:ShiurType) 
    {
        self.playShiour(shiour)
    }
    
    func onPauseShiour(_ shiour: Shiur) {
        self.plyerView?.pause()
    }
    
    func onShowMareiMekomoForshiur(_ shiur: Shiur) {}
}
