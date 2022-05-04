//
//  MaggidShiurLessonsViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 24/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

enum ShiurimType {
    case Talmud
    case Torah
}

class MaggidShiurLessonsViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, BTSegmentControllerDelegate, ShiursDelegate, BTPlayerViewDelegate
{
    var maggidShiur:MaggidShiur?
    
    var delegate:ShiursDelegate?
    
    var getMaggidShiurShiurimProcess:MSBaseProcess?
        
    var shiurimType:ShiurimType = .Talmud
    
    var isLoadingVideoLesson = false
    
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var searchBar:UISearchBar?
    @IBOutlet weak var maggidShiurCardView:UIView?
    @IBOutlet weak var cardView:UIView?
    @IBOutlet weak var maggidIconImageView:UIImageView?
    @IBOutlet weak var maggidNameLabel:UILabel?
    @IBOutlet weak var maggidInfoLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var loadingView:UIView?
    @IBOutlet weak var loadingGifImageview:UIImageView?
    @IBOutlet weak var searchBarTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var tabelViewConstraintToSearchBar:NSLayoutConstraint?
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var dispalyOptionSegmentedController:BTSegmentController?
    @IBOutlet weak var playerTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var topicsFilterView:MSFilterView?
    @IBOutlet weak var filterButton:UIButton?
    @IBOutlet weak var filterButtonLabel:UILabel?
    @IBOutlet weak var plyerViewPlaceHolder:UIView?
    @IBOutlet weak var sortSegmentedControl:BTSegmentedControl?
    @IBOutlet weak var sortSegmentedControlTopConstraint:NSLayoutConstraint?
    
    var plyerView:BTPlayerView? {
        get {
            ShasIlluminatedManager.sharedManager.plyerView
        }
    }
    
    var displayedShiurim = [Shiur]()
    
    var topics:[Topic]?
    var filterdTopics:[Topic]?
    
    var maggidiShiurOptions = [FilterOption]()
    
    var shiurim:[Shiur]{
        
        get{
            if self.dispalyOptionSegmentedController?.selectedSegmentIndex == 1 //Display saved shiurs
            {
                switch  shiurimType {
                case .Talmud:
                    return self.maggidShiur?.savedTalmudShiurs ?? [Shiur]()
                    
                case .Torah:
                    return self.maggidShiur?.savedTorahShiurs ?? [Shiur]()
                }
                
            }
            else{
                
                switch  shiurimType {
                case .Talmud:
                    return self.maggidShiur?.talmudShiurim ?? [Shiur]()
                    
                case .Torah:
                    return self.maggidShiur?.torahShiurim ?? [Shiur]()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideLaodingView()
        
        self.sortSegmentedControlTopConstraint?.constant = -1 * (self.sortSegmentedControl!.frame.size.height + 5)
        
        if let textFieldInsideSearchBar = self.searchBar?.value(forKey: "searchField") as? UITextField
        {
            textFieldInsideSearchBar.textColor = .white
        }
        
        self.dispalyOptionSegmentedController?.delegate = self
        
        self.setSearchLayout(active: false, animated: false)
        
        self.cardView?.layer.cornerRadius = 3.0
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
        self.maggidIconImageView?.layer.cornerRadius = self.maggidIconImageView!.frame.size.width/2
        
        self.loadingView?.backgroundColor = UIColor.white
        self.loadingView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        self.loadingView?.layer.borderWidth = 1.0
        self.loadingView?.layer.cornerRadius = 3.0
        
        self.dispalyOptionSegmentedController?.layer.borderWidth = 1.0
        self.dispalyOptionSegmentedController?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        self.dispalyOptionSegmentedController?.layer.cornerRadius = 3.0
        
         self.plyerViewPlaceHolder?.backgroundColor = UIColor.white
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.plyerViewPlaceHolder?.addSubview(self.plyerView!)
        self.plyerView!.addSidedConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         self.plyerView?.delegate = self
        
        if (self.topicsFilterView?.superview != self.view) {

            let filterViewHeight = self.view.frame.size.height - topBarView!.frame.size.height
            let filterViewOrigenY = -1 * self.topicsFilterView!.frame.size.height
            self.topicsFilterView?.frame = CGRect(x: 0, y: filterViewOrigenY, width: self.view.frame.size.width, height: filterViewHeight)
            self.topicsFilterView?.onDone = {
                self.filterButton?.isSelected = false
                self.hideFilterView()
            }
            self.view.addSubview(self.topicsFilterView!)
            self.view.bringSubviewToFront(self.topBarView!)
        }
        
        self.topicsFilterView?.frame.origin.y = -1 * self.topicsFilterView!.frame.size.height
        
        if self.shiurim.count == 0
        {
            self.getShiurim()
        }
        else if self.shiurim.count < self.maggidShiur?.shiurim_count ?? 0
        {
            self.getShiurim()
        }
        else {
            self.updateOptions()
            self.setDisplayedShiurim()
            self.tableView?.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.plyerView?.delegate = nil
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
        self.maggidInfoLabel?.text = self.maggidShiur?.bio?.htmlToString
        
        self.setDisplayedShiurim()
        self.tableView?.reloadData()
    }
    
    func reloadVisibleShioursCells() {
        
        if self.tableView != nil {
            for cell in self.tableView!.visibleCells {
                
                if let shiurCell = cell as? LessonTableCell {
                    
                   shiurCell.reloadData()
                    self.setShiurCellLayout(shiurCell)
                }
            }
        }
    }
    
    func updateOptions() {
        
        var filterOptions = [FilterOption]()
        
        var optionNames = [String]()
        
        if shiurimType == .Talmud {
            
            for shiur in self.shiurim{
                
                if let masecheName = shiur.masechet?.englishName
                {
                    if optionNames.contains(masecheName) == false{
                        let filterOption = FilterOption()
                        filterOption.optionName = masecheName
                        filterOption.isSelected = true
                        optionNames.append(masecheName)
                        filterOptions.append(filterOption)
                    }
                }
            }
            
        }
        else {
            
            for shiur in self.shiurim{
                
                if let torahShiur = shiur as? TorahShiur {
                    if let topic = torahShiur.topic
                        , let topicName = topic.name{
                        
                        if optionNames.contains(topicName) == false{
                            let filterOption = FilterOption()
                            filterOption.optionName = topicName
                            filterOption.isSelected = true
                            optionNames.append(topicName)
                            filterOptions.append(filterOption)
                        }
                    }
                }
            }
        }
        
        self.maggidiShiurOptions = filterOptions
    }

func showLaodingView()
{
        self.loadingGifImageview?.image = UIImage.gifWithName("Spinner")
        self.loadingView?.isHidden = false
    }
    
    func hideLaodingView()
    {
        self.loadingView?.isHidden = true
        self.loadingGifImageview?.image = nil
    }
    
    func getShiurim()
    {
        self.showLaodingView()
        
        if self.maggidShiur == nil
        {
            return
        }
        
        switch  self.shiurimType {
        case .Talmud:
            self.getMaggidShiurShiurimProcess = GetMaggidShiurShiurimProcess()
            break
            
        case .Torah:
            self.getMaggidShiurShiurimProcess = GetMaggidShiurTorahShiurimProcess()
            break
        }
        
        self.getMaggidShiurShiurimProcess?.executeWithObject(self.maggidShiur, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.getMaggidShiurShiurimProcess = nil
            
            let shiurimData = object as![String:Any]
            
            if let shiruim = shiurimData["shiurim"]
            {
                switch  self.shiurimType {
                case .Talmud:
                    
                    if  self.maggidShiur?.talmudShiurim == nil {
                        self.maggidShiur?.talmudShiurim = [Shiur]()
                    }
                    self.maggidShiur?.talmudShiurim?.append(contentsOf: (shiruim as! [Shiur]))
                    break
                    
                case .Torah:
                    if  self.maggidShiur?.torahShiurim == nil {
                        self.maggidShiur?.torahShiurim = [TorahShiur]()
                    }
                    self.maggidShiur?.torahShiurim?.append(contentsOf: (shiruim as! [TorahShiur]))
                    break
                }
            }
            
            self.updateOptions()
            self.sortSegmentedControl?.selectedSegmentIndex = 2 // sort by date
            self.setDisplayedShiurim()
            self.tableView?.reloadData()
            
            self.hideLaodingView()
            
        },onFaile: { (object, error) -> Void in
            
             self.getMaggidShiurShiurimProcess = nil
            
            self.hideLaodingView()
            
        })
    }
    
    @IBAction func scrollToTopButtonClicked(_ sender: AnyObject) {
              
           self.tableView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonClicked(_ sedner:AnyObject)
    {
         self.hideFilterView()
        
        self.searchBar?.becomeFirstResponder()
    }
    
    @IBAction func showMaggidShiourInfoButtonClicked(_ sedner:AnyObject)
    {
        if self.maggidShiur != nil
        {
            let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
            let maggidShiurInfoViewController =  storyboard.instantiateViewController(withIdentifier: "MaggidShiurInfoViewController") as! MaggidShiurInfoViewController
            
            maggidShiurInfoViewController.reloadWithObject(self.maggidShiur!)
            self.navigationController?.pushViewController(maggidShiurInfoViewController, animated: true)
        }
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
        
        self.topicsFilterView?.reloadWithOptions(self.maggidiShiurOptions)
        self.topicsFilterView?.frame.origin.y =  self.topBarView!.frame.size.height
    }
    func hideFilterView(){
        
        if self.filterButton?.isSelected ?? false {
            self.filterButton?.isSelected = false
        }
        
        self.topicsFilterView?.frame.origin.y = -1 * self.topicsFilterView!.frame.size.height
        self.topicsFilterView?.filterTextField?.resignFirstResponder()
        
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
    
    @IBAction func sortSegmentedControlValueChanged(_ sender:BTSegmentedControl){
          
          self.hideSortSegmentedControl()
          
          switch sender.selectedSegmentIndex {
          case 0://Title A-Z
              self.displayedShiurim = self.displayedShiurim.sorted(by: { ($0.name ?? "") < ($1.name ?? "")})
              break
              
          case 1://Title Z-A
              self.displayedShiurim = self.displayedShiurim.sorted(by: { ($0.name ?? "") > ($1.name ?? "")})
              break
              
              
          case 3://Date ->
              self.displayedShiurim = self.displayedShiurim.sorted(by: { ($0.shiur_date ?? Date()) < ($1.shiur_date ?? Date())})
              break
              
          case 2://Date <-
              self.displayedShiurim = self.displayedShiurim.sorted(by: { ($0.shiur_date ?? Date()) > ($1.shiur_date ?? Date())})
              break
              
          case 5://Length ->
              self.displayedShiurim = self.displayedShiurim.sorted(by: { ($0.lengthTime) < ($1.lengthTime)})
              break
              
          case 4://Length <-
              self.displayedShiurim = self.displayedShiurim.sorted(by: { ($0.lengthTime) > ($1.lengthTime)})
              break
              
          default: break
              
          }
          
           self.tableView?.reloadData()
         self.playerTopConstraint?.constant = 16
      }
    
    // MARK: - UITableView Delegate Methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.displayedShiurim.count
        /*
        if let shiurimCount = self.maggidShiur?.shiurim?.count
        {
            //If did dounalod all maggidShiur shiurim
            if shiurimCount == self.maggidShiur?.shiurim_count
            {
                return shiurimCount
            }
            else{
                return shiurimCount + 1
            }
        }
        else{
            return 0
        }
 */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // if last index is the loading cell
        if indexPath.row == self.displayedShiurim.count
        {
             let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingDataTableCell", for:indexPath) as! LoadingDataTableCell
            cell.selectionStyle = .none
            
            return cell            
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableCell", for:indexPath) as! LessonTableCell
            
            cell.delegate = self
            
            let shiur =  self.displayedShiurim[indexPath.row]
            shiur.maggidShiur = self.maggidShiur
            
            cell.reloadWithObject(shiur)
            
            self.setShiurCellLayout(cell)
         
            return cell
        }
    }
    
    func setShiurCellLayout(_ cell:LessonTableCell) {
        
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
        
        if  self.shiurimType == .Torah {
            cell.removeMareiMekomosOption()
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
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        /*
        //If last row
        if let shiurimCount = self.maggidShiur?.shiurim?.count
            , shiurimCount < self.maggidShiur?.shiurim_count ?? 0
           , indexPath.row == shiurimCount-1
            {
                //if is not running this process
                if getMaggidShiurShiurimProcess == nil
                {
                    self.getShiurim()
                }
            }
 */
    }

     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
          self.playerTopConstraint?.constant = -1 * (scrollView.contentOffset.y - 16)
      }
    
    //MARK: - SearchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        self.setDisplayedShiurim()
        self.tableView?.reloadData()
        self.setSearchLayout(active: true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.setDisplayedShiurim()
        self.tableView?.reloadData()
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
    func setDisplayedShiurim()
    {
        let searchText = self.searchBar?.text ?? ""
        
        self.displayedShiurim = self.shiurim
        
        if self.searchBar?.isFirstResponder ?? false
            , let textLength = self.searchBar?.text?.count
            ,textLength > 0
        {
            for shiur in self.shiurim
            {
                if (shiur.englishTitle.contains(subString: searchText, ignoreCase: true) == false)
                    && ((shiur.name ?? "").contains(subString: searchText, ignoreCase: true) == false)
                {
                     self.displayedShiurim.remove(shiur)
                }
            }
        }
        
        var filterdShiurim = [Shiur]()
        
        for shiur in self.displayedShiurim {
            for filterOption in self.maggidiShiurOptions {
                
                if shiurimType == .Talmud
                    ,filterOption.optionName == shiur.masechet?.englishName
                    ,filterOption.isSelected {
                    
                    filterdShiurim.append(shiur)
                }
                    
                else if shiurimType == .Torah
                    ,filterOption.optionName == (shiur as? TorahShiur)?.topic?.name
                    ,filterOption.isSelected {
                                       
                    filterdShiurim.append(shiur)
                }
            }
        }
        
        self.displayedShiurim = filterdShiurim
        
        if self.sortSegmentedControl != nil {
            self.sortSegmentedControlValueChanged(self.sortSegmentedControl!)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.setSearchLayout(active: false, animated: true)
        self.searchBar?.resignFirstResponder()
        
        self.setDisplayedShiurim()
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
    
    func playShiour(_ shiour:Shiur, type:ShiurType, automaticly:Bool)
    {
        self.isLoadingVideoLesson = false

        if type == .Audio {
            if let playingUrl = self.plyerView?.playerUrl
                       ,shiour.lessonUrl()?.absoluteString == playingUrl.absoluteString {
                       
                       if self.plyerView?.isPaused ?? false {
                           self.plyerView?.play()
                           return
                       }
                   }
        }
        else{
            self.plyerView?.pause()
        }
       
        
        self.plyerView?.iconImageView?.image(name: shiour.maggidShiur?.imagePath ?? "blank_profile")
        
        self.plyerView?.title = shiour.maggidShiur?.name ?? ""
        
        self.plyerView?.subTitle = shiour.name ?? ""
        
   //     self.animateToTop()

        // If shiour is saved localy
        var lessonUrl:URL?
        
        if type == .Video
        ,let shiour = shiour.url_video_download
        {
            self.isLoadingVideoLesson = true
            lessonUrl = URL(string: shiour)
        }
        else if let lessonPath = DownloadManager.sharedManager.pathForShiour(shiour)
        {
            lessonUrl = URL(fileURLWithPath: lessonPath)
        }
        else if let shiour = shiour.url_download
        {
            lessonUrl = URL(string: shiour)
        }
        if lessonUrl != nil
        {
            self.plyerView?.setPlayerUrl(lessonUrl!, durration: 0,onReadyToPlay: {
                
                if automaticly == true {
                    self.plyerView?.play()
                }
                self.hideLaodingView()
                
            }, onLessonNotFound: { })
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
    
    //Keyboard Notifications
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
    
    //MARK: - BTSegmentController Delegate Methods
    func segmentController(_ segmentController:BTSegmentController, valueChanged index:Int)
    {
        if index == 1 //Saved Shiours
        {
            switch shiurimType {
            case .Talmud:
                self.maggidShiur?.updateSavedTalmudShiurs()
                break
                
            case .Torah:
                self.maggidShiur?.updateSavedTorahShiurs()
                break
            }
        }
        
         self.setDisplayedShiurim()
        self.tableView?.reloadData()
        
        if self.displayedShiurim .count > 0
        {
            self.tableView?.scrollToRow(at:IndexPath(row:0, section: 0), at: .top, animated: true)
        }
    }
    
    //MARK:  Shiurs Delegate methods
   
    func onPlayShiour(_ shiour:Shiur, type:ShiurType) {
        
        self.playShiour(shiour, type:type, automaticly:true)
        
        self.reloadVisibleShioursCells()

    }
    func onPauseShiour(_ shiour: Shiur) {
        self.plyerView?.pause()
        
         self.reloadVisibleShioursCells()
    }
    
    func onShowMareiMekomoForshiur(_ shiur:Shiur) {
        
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
     
     func playerLoadingStatusChanged(player:BTPlayerView, isLoading:Bool){
          self.reloadVisibleShioursCells()
     }
     
     func playerView(_ player:BTPlayerView, didChangeDuration duration:Int){
         
     }
     
     func didFinishPlaying(_ player:BTPlayerView){
         
     }
    
}
