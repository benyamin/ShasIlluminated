//
//  TopicViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 25/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class TopicViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource,ShiursDelegate, UISearchBarDelegate,BTPlayerViewDelegate
{
    var topic:Topic?
    var delegate:ShiursDelegate?
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var playerTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var searchBar:UISearchBar?
    @IBOutlet weak var searchBarTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var tabelViewConstraintToSearchBar:NSLayoutConstraint?
    @IBOutlet weak var sortSegmentedControl:BTSegmentedControl?
    @IBOutlet weak var sortSegmentedControlTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var filterButton:UIButton?
    @IBOutlet weak var maggidShiursFilterView:MSFilterView?
    
    @IBOutlet weak var plyerViewPlaceHolder:UIView?
       
    var filterdShiurs:[TorahShiur]?
    var maggidiShiurOptions = [FilterOption]()
    
     var plyerView:BTPlayerView? {
         get {
             ShasIlluminatedManager.sharedManager.plyerView
         }
     }
    
    var displayedShiurs:[TorahShiur]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let textFieldInsideSearchBar =  self.searchBar?.value(forKey: "searchField") as? UITextField
        {
            textFieldInsideSearchBar.textColor = UIColor.white
        }
        
        self.sortSegmentedControlTopConstraint?.constant = -1 * (self.sortSegmentedControl!.frame.size.height + 5)

        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.plyerView?.delegate = self
        
        super.viewWillAppear(animated)
        
        self.plyerViewPlaceHolder?.addSubview(self.plyerView!)
        self.plyerView!.addSidedConstraints()
        
        self.playerTopConstraint?.constant = 8
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
         self.plyerView?.delegate = nil
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
    
    override func reloadWithObject(_ object: Any)
    {
        self.topic = object as? Topic
        self.updateMaggidiShiurOptions()

        self.setDisplayedShiurim()
        self.reloadData()
    }
    
    func reloadData()
    {
        self.plyerViewPlaceHolder?.backgroundColor = UIColor.white
        
        self.titleLabel?.text = self.topic?.name
        self.tableView?.reloadData()
    }
    
    func reloadVisibleShioursCells() {
        
        if self.tableView != nil {
            for cell in self.tableView!.visibleCells {
                
                if let shiurCell = cell as? TorahShiurTableCell {
                    
                    shiurCell.reloadData()
                    self.setShiurCellLayout(shiurCell)
                }
            }
        }
    }
    
    func updateMaggidiShiurOptions() {
        
        if self.topic?.shiurs == nil {
            return
        }
        
        var maggidiShiurNames = [String]()
        
        var filterOptions = [FilterOption]()
        for shiur in self.topic!.shiurs!{
            
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
        
        self.maggidiShiurOptions = filterOptions
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonClicked(_ sedner:AnyObject)
     {
         self.hideFilterView()
         self.searchBar?.becomeFirstResponder()
     }
     
     @IBAction func sortButtonClicked(_ sedner:AnyObject)
     {
          self.hideFilterView()
         
         if  self.sortSegmentedControlTopConstraint?.constant == 0 {
             self.hideSortSegmentedControl()
         }
         else{
             self.showSortSegmentedControl()
         }
     }
     
     @IBAction func filterButtonClicked(_ sender: UIButton)
     {
         self.hideSortSegmentedControl()
         self.filterButton?.isSelected = !self.filterButton!.isSelected
         self.filterButton!.isSelected ? self.showFilterView() : self.hideFilterView()
     }
    
    func showFilterView(){
         
         if self.displayedShiurs != nil{
             self.maggidShiursFilterView?.reloadWithOptions(self.maggidiShiurOptions)
             self.maggidShiursFilterView?.frame.origin.y =  self.topBarView!.frame.size.height
         }
     }
     func hideFilterView(){
         
         if self.filterButton?.isSelected ?? false {
              self.filterButton?.isSelected = false
         }
        
         self.maggidShiursFilterView?.frame.origin.y = -1 * self.maggidShiursFilterView!.frame.size.height
         self.maggidShiursFilterView?.filterTextField?.resignFirstResponder()
         
         self.setDisplayedShiurim()
         self.tableView?.reloadData()
         self.tableView?.setContentOffset(CGPoint.zero, animated: true)
     }
     
     func showSortSegmentedControl(){
         self.sortSegmentedControlTopConstraint?.constant = 0
               UIView.animate(withDuration: 0.3) {
                   self.view.layoutIfNeeded()
               }
     }
     
     func hideSortSegmentedControl(){
         self.sortSegmentedControlTopConstraint?.constant = -1 * (self.sortSegmentedControl!.frame.size.height + 5)
         
                 UIView.animate(withDuration: 0.3) {
                     self.view.layoutIfNeeded()
                 }
       }

    func playShiour(_ shiour:Shiur, type:ShiurType)
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
         
      //  self.animateToTop()
         
         // If shiour is saved localy
        if let lessonPath = DownloadManager.sharedManager.pathForShiour(shiour), type != .Video
         {
             let lessonUrl = URL(fileURLWithPath: lessonPath)
             self.plyerView?.setPlayerUrl(lessonUrl, durration: 0, onReadyToPlay: {
                 self.plyerView?.play()
             }, onLessonNotFound: { })
         }
         else{
            if let lessonUrlPath = type == .Audio ? shiour.url_download : shiour.url_video_download
                 ,let lessonUrl = URL(string: lessonUrlPath)
             {
                  self.plyerView?.setPlayerUrl(lessonUrl, durration: 0, onReadyToPlay: {
                                self.plyerView?.play()
                            }, onLessonNotFound: { })
             }
         }
     }
    
    func animateToTop() {
        
        self.playerTopConstraint?.constant = 16
        
        UIView.animate(withDuration: 0.3, delay:0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                self.view.layoutIfNeeded()
                
        }, completion: {_ in
        })
    }
    
    //MARK TableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.displayedShiurs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TorahShiurTableCell", for:indexPath) as! TorahShiurTableCell
        
        cell.selectionStyle = .none
                
        cell.delegate = self

        if let shiur = self.displayedShiurs?[indexPath.row]
        {
            cell.reloadWithObject(shiur)
            
            self.setShiurCellLayout(cell)
           
        }
        
        cell.playButton?.backgroundColor =  cell.playButton!.isSelected ? UIColor.init(HexColor: "2A5F87") : UIColor.init(HexColor: "639EDB")
        
        return cell
        
    }
    
    func setShiurCellLayout(_ cell:TorahShiurTableCell) {
        
        cell.playButton?.setTitle("Play Audio".localize(), for: .normal)
        cell.playButton?.setTitle("Pause".localize(), for: .selected)
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
          self.playerTopConstraint?.constant = -1 * (scrollView.contentOffset.y - 16)
      }
    
   // MARK: shiours Delegate
    func  onPlayShiour(_ shiour:Shiur, type:ShiurType)  {
        
        self.playShiour(shiour, type: type)
        
        self.reloadVisibleShioursCells()
    }
    
    func onPauseShiour(_ shiour: Shiur) {
        self.plyerView?.pause()
        
         self.reloadVisibleShioursCells()
    }
    
    func onShowMareiMekomoForshiur(_ shiur:Shiur){}
    
    //MARK: - SearchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        self.tableView?.reloadData()
        self.setSearchLayout(active: true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.setSearchLayout(active: false, animated: true)
        self.searchBar?.resignFirstResponder()
        self.searchBar?.text = ""
        self.tableView?.reloadData()
    }

    
    func setSearchLayout(active:Bool, animated:Bool)
    {
        self.hideSortSegmentedControl()
        
        if active{
            
            self.searchBarTopConstraint?.constant = 0
            self.tabelViewConstraintToSearchBar?.priority = UILayoutPriority(rawValue: 900)
        }
        else{
            self.searchBarTopConstraint?.constant = -1*(self.searchBar?.frame.size.height ?? 0)
            self.tabelViewConstraintToSearchBar?.priority = UILayoutPriority(rawValue: 500)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.setDisplayedShiurim()
        self.tableView?.reloadData()
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func setDisplayedShiurim()
    {
        var filterdShiurim = [TorahShiur]()
        
        if  self.searchBar?.isFirstResponder ?? false
            ,let searchText = self.searchBar?.text
            ,searchText.trimmeSpaces().count > 0{
            
            if let shiurs = self.topic?.shiurs
            {
                for shiur in shiurs
                {
                    if (shiur.name?.contains(subString: searchText, ignoreCase: true) ?? false)
                        || (shiur.topic?.name?.contains(subString: searchText, ignoreCase: true) ?? false)
                        || (shiur.maggidShiur?.name?.contains(subString: searchText, ignoreCase: true) ?? false)
                    {
                        filterdShiurim.append(shiur)
                    }
                }
            }
        }
        else{
            filterdShiurim = self.topic?.shiurs ?? [TorahShiur]()
        }
        
        self.displayedShiurs = [TorahShiur]()
        
        for shiur in filterdShiurim {
            for maggidShiurOption in self.maggidiShiurOptions{
                if maggidShiurOption.isSelected && shiur.maggidShiur?.name == maggidShiurOption.optionName{
                    
                    self.displayedShiurs?.append(shiur)
                    break
                }
            }
        }
    }
    
    @IBAction func scrollToTopButtonClicked(_ sender: AnyObject) {
        
        self.tableView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func sortSegmentedControlValueChanged(_ sender:BTSegmentedControl){
        
        self.hideSortSegmentedControl()
        
        if self.displayedShiurs == nil{
            return
        }
        
        switch sender.selectedSegmentIndex {
        case 0://Title A-Z
            self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.name ?? "") < ($1.name ?? "")})
            break
            
        case 1://Title Z-A
            self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.name ?? "") > ($1.name ?? "")})
            break
            
        case 3://MagidShiur A-Z
            self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.maggidShiur?.name ?? "") < ($1.maggidShiur?.name ?? "")})
            break
            
        case 2://MagidShiur Z-A
             self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.maggidShiur?.name ?? "") > ($1.maggidShiur?.name ?? "")})

            break
            
        case 4://Date ->
            self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.shiur_date ?? Date()) < ($1.shiur_date ?? Date())})
            break
            
        case 5://Date <-
            self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.shiur_date ?? Date()) > ($1.shiur_date ?? Date())})
            break
            
        case 7://Length ->
            self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.lengthTime) < ($1.lengthTime)})
            break
            
        case 6://Length <-
            self.displayedShiurs = self.displayedShiurs!.sorted(by: { ($0.lengthTime) > ($1.lengthTime)})
            break
            
        default: break
        }
        
        self.reloadData()
        if (self.tableView?.numberOfRows(inSection: 0) ?? 0) > 0 {
            self.tableView?.scrollToRow(at:IndexPath(row:0, section: 0), at: .top, animated: false)
        }
        self.playerTopConstraint?.constant = 16
    }
    
    //MARK PlayerView Delegate
    func didPause(player: BTPlayerView) {
       self.reloadVisibleShioursCells()
    }
    
    func didPlay(player: BTPlayerView) {
         self.reloadVisibleShioursCells()
    }
    
    func playerLoadingStatusChanged(player:BTPlayerView, isLoading:Bool) {
    }
    
    func playerView(_ player: BTPlayerView, didChangeDuration duration: Int) {
    }
    
    func didFinishPlaying(_ player: BTPlayerView) {
    }
}
