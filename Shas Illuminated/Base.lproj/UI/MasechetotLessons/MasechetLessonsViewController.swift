//
//  MasechetLessonsViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin on 20 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import UIKit

enum ShiurType {
    case Audio
    case Video
}

protocol ShiursDelegate:class
{
    func onPlayShiour(_ shiour:Shiur, type:ShiurType)
    func onPauseShiour(_ shiour:Shiur)
    func onShowMareiMekomoForshiur(_ shiur:Shiur)
}

class MasechetLessonsViewController: MSBaseViewController, UITableViewDelegate ,UITableViewDataSource, BTSegmentControllerDelegate, UISearchBarDelegate, ShiursDelegate, BTPlayerViewDelegate
{
    var masechet:Masechet?
    var displayedDafs:[Daf] = [Daf]()
    var filterdDafs = [Daf]()
    var maggidiShiurOptions = [FilterOption]()

    var delegate:ShiursDelegate?
    
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var searchBar:UISearchBar?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var dispalyOptionSegmentedController:BTSegmentController?
    @IBOutlet weak var searchBarTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var tabelViewConstraintToSearchBar:NSLayoutConstraint?
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var playerTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var maggidShiursFilterView:MSFilterView?
    @IBOutlet weak var filterButton:UIButton?
    @IBOutlet weak var filterButtonLabel:UILabel?
    
    @IBOutlet weak var plyerViewPlaceHolder:UIView?

       var plyerView:BTPlayerView? {
           get {
               ShasIlluminatedManager.sharedManager.plyerView
           }
       }
    
    func setDisplayedDafs() {
        
        var displayedDafs = [Daf]()
        if self.searchBar?.isFirstResponder ?? false {
            
            displayedDafs = self.filterdDafs
        }
        else {
            if self.dispalyOptionSegmentedController?.selectedSegmentIndex == 1 //Display saved shiurs
            {
                displayedDafs = self.masechet?.dafsWithSavedShiours ?? [Daf]()
            }
            else{
                displayedDafs = self.masechet?.dafs ?? [Daf]()
            }
        }
        
        var filterdDafs = [Daf]()
        
        for daf in displayedDafs {
            
            self.setDisplayedShiurimForDaf(daf)
            if daf.displayedShiurim.count > 0 {
                filterdDafs.append(daf)
            }
        }
        
        displayedDafs = filterdDafs
        
        self.displayedDafs = displayedDafs
    }
    
    func setDisplayedShiurimForDaf(_ daf:Daf)
    {
        var displayedShiurim = [Shiur]()
        for shiur in daf.shiours {
            for maggidShiurOption in self.maggidiShiurOptions{
                if maggidShiurOption.isSelected && shiur.maggidShiur?.name == maggidShiurOption.optionName{
                    
                    displayedShiurim.append(shiur)
                }
            }
        }
        daf.displayedShiurim = displayedShiurim
    }
    
    func updateMaggidiShiurOptions() {
          
        var maggidiShiurNames = [String]()
        
        var filterOptions = [FilterOption]()
        
        if let dafs = self.masechet?.dafs {
            for daf in dafs {
                for shiur in daf.shiours {
                    
                    if let maggidShiurName = shiur.maggidShiur?.name{
                        if maggidiShiurNames.contains(maggidShiurName) == false{
                            let filterOption = FilterOption()
                            filterOption.optionName = maggidShiurName
                            filterOption.isSelected = true
                            maggidiShiurNames.append(maggidShiurName)
                            filterOptions.append(filterOption)
                        }
                    }
                    
                }
            }
        }
        
        self.maggidiShiurOptions = filterOptions
    }
    
        
    override func viewDidLoad() {
        
         super.viewDidLoad()
                
        if let textFieldInsideSearchBar =  self.searchBar?.value(forKey: "searchField") as? UITextField
        {
            textFieldInsideSearchBar.textColor = UIColor.white
        }
        
         self.plyerViewPlaceHolder?.backgroundColor = UIColor.white
        
        self.setSearchLayout(active: false, animated: false)
        
        self.dispalyOptionSegmentedController?.delegate = self
        
        self.dispalyOptionSegmentedController?.layer.borderWidth = 1.0
        self.dispalyOptionSegmentedController?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        self.dispalyOptionSegmentedController?.layer.cornerRadius = 3.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.plyerView?.delegate = self
        
        self.plyerViewPlaceHolder?.addSubview(self.plyerView!)
        self.plyerView!.addSidedConstraints()
        
        self.playerTopConstraint?.constant = 16
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         
         if (self.maggidShiursFilterView?.superview != self.view) {

             let filterViewHeight = self.view.frame.size.height - topBarView!.frame.size.height
             let filterViewOrigenY = -1 * self.maggidShiursFilterView!.frame.size.height
             self.maggidShiursFilterView?.frame = CGRect(x: 0, y: filterViewOrigenY, width: self.view.frame.size.width, height: filterViewHeight)
             self.maggidShiursFilterView?.onDone = {
                 self.filterButton?.isSelected = false
                 self.hideFilterView()
             }
             self.view.addSubview(self.maggidShiursFilterView!)
            self.view.bringSubviewToFront(self.topBarView!)
        }
        self.maggidShiursFilterView?.frame.origin.y = -1 * self.maggidShiursFilterView!.frame.size.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.plyerView?.delegate = nil
    }
    
    override func reloadWithObject(_ object: Any)
    {
        self.masechet = object as? Masechet
        
        self.updateMaggidiShiurOptions()
        
        self.setDisplayedDafs()
        self.tableView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
       {
           self.setSearchLayout(active: false, animated: true)
           self.searchBar?.resignFirstResponder()
        
        self.setDisplayedDafs()
           self.tableView?.reloadData()
       }
    
    func setSearchLayout(active:Bool, animated:Bool)
    {
        if active{
            
            self.searchBarTopConstraint?.constant = 0
            self.tabelViewConstraintToSearchBar?.priority = UILayoutPriority(rawValue: 900)

        }
        else{
            self.searchBarTopConstraint?.constant = -1*(self.searchBar?.frame.size.height ?? 0)
            self.tabelViewConstraintToSearchBar?.priority = UILayoutPriority(rawValue: 700)
        }
        
        if animated
        {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        else{
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func searchButtonClicked(_ sedner:AnyObject)
    {
        self.filterDafs()
        self.searchBar?.becomeFirstResponder()
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func scrollToTopButtonClicked(_ sender: AnyObject) {
           
        self.hideFilterView()
        self.tableView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func filterButtonClicked(_ sender: UIButton)
     {
           self.filterButton?.isSelected = !self.filterButton!.isSelected
           self.filterButton!.isSelected ? self.showFilterView() : self.hideFilterView()
     }
     
     func showFilterView(){
         
         self.maggidShiursFilterView?.reloadWithOptions(self.maggidiShiurOptions)
         self.maggidShiursFilterView?.frame.origin.y =  self.topBarView!.frame.size.height
     }
     func hideFilterView(){
         
         if self.filterButton?.isSelected ?? false {
             self.filterButton?.isSelected = false
         }
         
         self.maggidShiursFilterView?.frame.origin.y = -1 * self.maggidShiursFilterView!.frame.size.height
         self.maggidShiursFilterView?.filterTextField?.resignFirstResponder()
         
         self.setDisplayedDafs()
         self.tableView?.reloadData()
         self.tableView?.setContentOffset(CGPoint.zero, animated: true)
     }
        
    // MARK: - UITableView Delegate Methods:
    
      func numberOfSections(in tableView: UITableView) -> Int {
        return self.displayedDafs.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageLessonsHeaderCell") as! PageLessonsHeaderCell
        
        let daf = self.displayedDafs[section]
        daf.masechet = self.masechet
        
        cell.reloadWithObject(daf)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let daf = self.displayedDafs[section]
        
        return daf.displayedShiurim.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageLessonTableCell", for:indexPath) as! PageLessonTableCell
        
        cell.delegate = self
        
        let daf = self.displayedDafs[indexPath.section]
        let shiur = daf.displayedShiurim[indexPath.row]
        
        let dafInfo = ["daf":daf, "shiur":shiur]
        
        cell.reloadWithObject(dafInfo)
                
        self.setShiurCellLayout(cell)
        
        return cell
    }
    
    func setShiurCellLayout(_ cell:PageLessonTableCell) {
        
        cell.playButton?.setTitle("Play".localize(), for: .normal)
        
        if let playingUrl = self.plyerView?.playerUrl
            ,cell.shiur?.lessonUrl()?.absoluteString == playingUrl.absoluteString {
            
            cell.playButton?.isSelected = false
            
            if self.plyerView?.isPlaying ?? false {
                cell.playButton?.isSelected = true
            }
                
            else if self.plyerView?.isloading ?? false {
                cell.playButton?.setTitle("\("Loading".localize())...", for: .normal)
            }
        }
        else{
            cell.playButton?.isSelected = false
        }
        
        cell.playButton?.backgroundColor =  cell.playButton!.isSelected ? UIColor.init(HexColor: "2A5F87") : UIColor.init(HexColor: "639EDB")
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    //MARK: - BTSegmentController Delegate Methods
    func segmentController(_ segmentController:BTSegmentController, valueChanged index:Int)
    {
        if index == 1 //Saved Shiours
        {
            self.masechet?.updateSavedShiurs()
        }
        
        self.setDisplayedDafs()
        self.tableView?.reloadData()
        
        if self.displayedDafs.count > 0
        {
            self.tableView?.scrollToRow(at:IndexPath(row:0, section: 0), at: .top, animated: true)
        }
    }
    
    //MARK: - SearchBar delegate methods
      func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
      {
            self.setDisplayedDafs()
          self.tableView?.reloadData()
          self.setSearchLayout(active: true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.filterDafs()
        
        self.setDisplayedDafs()
        self.tableView?.reloadData()
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func filterDafs()
      {
        var dafs = [Daf]()
              if self.dispalyOptionSegmentedController?.selectedSegmentIndex == 1 //Display saved shiurs
              {
                  dafs = self.masechet?.dafsWithSavedShiours ?? [Daf]()
              }
              else{
                  dafs = self.masechet?.dafs ?? [Daf]()
              }
        
          let searchText = self.searchBar?.text ?? ""
        
        if searchText == "" {
            self.filterdDafs = dafs
        }
        else {
            self.filterdDafs = [Daf]()
            
            for daf in dafs
            {
                if  let pageIndex = daf.daf
                    ,"\(pageIndex)".contains(subString: searchText, ignoreCase: true)
                {
                    self.filterdDafs.append(daf)
                }
                else if (daf.symbol?.contains(subString: searchText, ignoreCase: true) ?? false)
                {
                    self.filterdDafs.append(daf)
                }
            }
        }
    }
    
    //MARK: - Keyboard notifications
      @objc override func keyboardWillAppear(_ notification: Notification)
      {
          if let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
          {
              self.tableViewBottomConstraint?.constant = keyboardSize.height
              
              UIView.animate(withDuration: 0.3) {
                  self.view.layoutIfNeeded()
              }
          }
      }
      
      @objc override func keyboardWillDisappear(_ notification: Notification)
      {
          self.tableViewBottomConstraint?.constant = 0
          
          UIView.animate(withDuration: 0.3) {
              self.view.layoutIfNeeded()
          }
      }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
           
             self.playerTopConstraint?.constant = -1 * (scrollView.contentOffset.y - 16)
         }
    
    func playShiour(_ shiour:Shiur, automaticly:Bool)
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
         
         var subTitle = ""
         if let massechtName = shiour.masechet?.englishName
             , let daf = shiour.daf
         {
             subTitle += "\(massechtName) Daf \(daf)"
         }
         if let message =  shiour.message
         {
             subTitle += "\n\(message)"
         }
         self.plyerView?.subTitle = subTitle
         
         // If shiour is saved localy
     
        if let lessonUrl = shiour.lessonUrl()
         {
             self.plyerView?.setPlayerUrl(lessonUrl, durration: 0,onReadyToPlay: {
                 
                 if automaticly == true {
                     self.plyerView?.play()
                    
                    self.reloadVisibleShioursCells()
                 }
                 
             }, onLessonNotFound: { })
         }
     }
    
    func reloadVisibleShioursCells() {
        
        if self.tableView != nil {
            for cell in self.tableView!.visibleCells {
                
                if let shiurCell = cell as? PageLessonTableCell {
                    
                   shiurCell.reloadData()
                    self.setShiurCellLayout(shiurCell)
                }
            }
        }
    }
        
    //MARK: ShiursDelegate Methods
     func onPlayShiour(_ shiour:Shiur, type:ShiurType) 
     {
         self.playShiour(shiour, automaticly:true)
     }
    
    func onPauseShiour(_ shiour:Shiur) {
        self.plyerView?.pause()
        self.reloadVisibleShioursCells()
    }
     
     func onShowMareiMekomoForshiur(_ shiur:Shiur)
     {
         if shiur.mareiMekomos != nil
         {
             self.showMareiMekomos(shiur.mareiMekomos!)
         }
         else{
             GetMareiMekomosForShiurProcess().executeWithObject(shiur, onStart: { () -> Void in
                 
             }, onComplete: { (object) -> Void in
                 
                 shiur.mareiMekomos = object as? MareiMekomos
                 self.showMareiMekomos(shiur.mareiMekomos!)
                 
             },onFaile: { (object, error) -> Void in
                 
             })
         }
     }
     
     func showMareiMekomos(_ mareiMekomos:MareiMekomos)
     {
         if let mareiMekomosPath = mareiMekomos.path
         {
             let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
             self.navigationController?.present(webViewController, animated: true, completion: nil)
             webViewController.loadUrl(mareiMekomosPath, title: "Marei Mekomos")
        }
    }
    
    //MARK PlayerView Delegate
    func didPause(player: BTPlayerView) {
         self.reloadVisibleShioursCells()
    }
    
    func didPlay(player: BTPlayerView) {
         self.reloadVisibleShioursCells()
    }
    
    func playerLoadingStatusChanged(player:BTPlayerView, isLoading:Bool) {
        self.reloadVisibleShioursCells()
    }
    
    func playerView(_ player:BTPlayerView, didChangeDuration duration:Int){
        
    }
    
    func didFinishPlaying(_ player:BTPlayerView){
        
    }
    
}

