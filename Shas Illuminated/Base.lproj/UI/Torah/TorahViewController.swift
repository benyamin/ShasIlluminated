//
//  TorahViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 22/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class TorahViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, ShiursDelegate, BTSegmentControllerDelegate,UISearchBarDelegate, TopicHeaderTableCellDelegate, BTPlayerViewDelegate
{
    private enum TableDisplayType {
        case Shiurs
        case MaggideiShiur
        case Topics
    }
    
    @IBOutlet weak var topBarView:UIView?
    @IBOutlet weak var dispalyOptionTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var dispalyOptionSegmentedController:BTSegmentController?
    @IBOutlet weak var loadingView:UIView?
    @IBOutlet weak var loadingGifImageview:UIImageView?
    @IBOutlet weak var searchBar:UISearchBar?
    @IBOutlet weak var searchBarTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var tabelViewConstraintToSearchBar:NSLayoutConstraint?
    @IBOutlet weak var sortSegmentedControl:BTSegmentedControl?
    @IBOutlet weak var sortSegmentedControlTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var maggidShiursFilterView:MSFilterView?
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var filterButton:UIButton?
    
    @IBOutlet weak var plyerViewPlaceHolder:UIView?
    
    var plyerView:BTPlayerView? {
        get {
            ShasIlluminatedManager.sharedManager.plyerView
        }
    }
    
    var shiurim:[TorahShiur]?
    var filterdShiurim:[TorahShiur]?
    var topics:[Topic]?
    var filterdTopics:[Topic]?
    var maggidiShiur = ShasIlluminatedManager.sharedManager.torahMaggideiShiours ?? [MaggidShiur]()
    var filterdMaggidiShiur:[MaggidShiur]?
    var maggidiShiurOptions = [FilterOption]()
        
    var displayedShiurm = [TorahShiur]()
    
    var isLoadingVideoLesson = false
    
    var displayedMagidiShiur:[MaggidShiur]!{
        
            get{
                    //If search is active
                    if self.searchBar?.isFirstResponder ?? false
                    {
                        if let textLength = self.searchBar?.text?.count
                            ,textLength > 0
                        {
                            return self.filterdMaggidiShiur ?? [MaggidShiur]()
                        }
                    }
                    
                    return self.maggidiShiur
                }
    }
    
    var displayedTopics:[Topic]?{
     
        get{
                 //If search is active
                 if self.searchBar?.isFirstResponder ?? false
                 {
                     if let textLength = self.searchBar?.text?.count
                         ,textLength > 0
                     {
                         return self.filterdTopics
                     }
                 }
                 
                 return self.topics
             }
    }
    
    private var tableDisplayType:TableDisplayType{
        
        get{
            if let selectedSegment = self.dispalyOptionSegmentedController?.selectedSegmentIndex
            {
                switch selectedSegment {
                case 0,1,2://Shiurs
                    return .Shiurs
                    
                case 3: //Maggidi Shiur
                    return .MaggideiShiur
                    
                case 4: //Topics
                    return .Topics
                    
                default:
                    return .Shiurs
                }
            }
            else{
                return .Shiurs
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let textFieldInsideSearchBar =  self.searchBar?.value(forKey: "searchField") as? UITextField
        {
            textFieldInsideSearchBar.textColor = UIColor.white
        }

         self.sortSegmentedControlTopConstraint?.constant = -1 * (self.sortSegmentedControl!.frame.size.height + 5)
        
        self.dispalyOptionSegmentedController?.delegate = self
        
        self.loadingView?.backgroundColor = UIColor.white
        self.loadingView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        self.loadingView?.layer.borderWidth = 1.0
        self.loadingView?.layer.cornerRadius = 3.0
        
        self.plyerViewPlaceHolder?.backgroundColor = UIColor.white
        
        self.getShiurimByCategory("recent")
        
        self.dispalyOptionSegmentedController?.selectedSegmentIndex = 0
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.plyerView?.delegate = self
        
        self.plyerViewPlaceHolder?.addSubview(self.plyerView!)
        self.plyerView!.addSidedConstraints()
        
        self.dispalyOptionTopConstraint?.constant = 16
        
        self.view.bringSubviewToFront(self.topBarView!)
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
    
    func getShiurimByCategory(_ category:String)
    {
        self.showLaodingView()
        
        GetTorahShiurimProcess().executeWithObject(category, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.hideLaodingView()
            
            self.shiurim = object as? [TorahShiur]
            
            self.updateMaggidiShiurOptions()
            
            self.sortSegmentedControl?.selectedSegmentIndex = 6 // sort by date
            
            self.setDisplayedShiurim()
            
            if let firstShiur = self.shiurim?.first
               , self.plyerView?.isPlaying == false
            {
                self.playShiour(firstShiur, type:.Audio, automaticly:false)
            }
            
            self.tableView?.reloadData()
            
            
        },onFaile: { (object, error) -> Void in
            
            self.hideLaodingView()
        })
    }
    
    func updateMaggidiShiurOptions() {
        
        var maggidiShiurNames = [String]()
        
        var filterOptions = [FilterOption]()
        for shiur in self.shiurim!{
            
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
    
    func getTopics()
    {
        self.showLaodingView()
        
        GetTopicsProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.hideLaodingView()
            
            ShasIlluminatedManager.sharedManager.torahTopis = object as? [Topic]
            self.topics = ShasIlluminatedManager.sharedManager.torahTopis
            
           self.tableView?.reloadData()
            
            
        },onFaile: { (object, error) -> Void in
            
            self.hideLaodingView()
        })
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
          
          self.dispalyOptionTopConstraint?.constant = 16
          
          UIView.animate(withDuration: 0.3, delay:0.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
              {
                  self.view.layoutIfNeeded()
                  
          }, completion: {_ in
          })
      }
    
    //MARK TableView Delgate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.tableDisplayType
        {
        case .Topics:
            return self.displayedTopics?.count ?? 0
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch self.tableDisplayType
        {
        case .Topics:
            return 60
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch self.tableDisplayType
        {
        case .Topics:
            let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "TopicHeaderTableCell") as! TopicHeaderTableCell
            
            sectionHeader.delegate = self
            
            if let topic  = self.displayedTopics?[section]
            {
                 sectionHeader.reloadWithObject(topic)
            }
           
            return sectionHeader
            
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch self.tableDisplayType
        {
        case .Shiurs:
            return self.displayedShiurm.count
            
        case .MaggideiShiur:
            return self.displayedMagidiShiur.count
            
        case .Topics:
            if let topic = self.displayedTopics?[section]
                ,  topic.shouldShowChildern == true
            {
                return topic.children?.count ?? 0
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.tableDisplayType
        {
        case .Shiurs:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TorahShiurTableCell", for:indexPath) as! TorahShiurTableCell
            
            cell.selectionStyle = .none
            cell.delegate = self
        
            if  indexPath.row < self.displayedShiurm.count
            {
                let shiur = self.displayedShiurm[indexPath.row]
                cell.reloadWithObject(shiur)
                
                self.setTorahShiurCellLayout(cell)
            }
            
            return cell
            
        case .MaggideiShiur:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MaggidShiurTableCell", for:indexPath) as! MaggidShiurTableCell
            
            cell.selectionStyle = .none
            
            cell.reloadWithObject( self.displayedMagidiShiur[indexPath.row])
            
            return cell
            
        case .Topics:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicTableCell", for:indexPath) as! TopicTableCell
            
            cell.selectionStyle = .none
            
            if let topic = self.displayedTopics?[indexPath.section]
            {
                if let topicChild = topic.children?[indexPath.row]
                {
                    cell.reloadWithObject(topicChild)
                }
            }
            
            return cell
        }
    }
    
    func setTorahShiurCellLayout(_ cell:TorahShiurTableCell) {
        
        cell.playButton?.setTitle("Play Audio".localize(), for: .normal)
        
        if let playingUrl = self.plyerView?.playerUrl
            ,cell.shiur?.lessonUrl()?.absoluteString == playingUrl.absoluteString {
            
            cell.playButton?.isSelected = false
            
            if self.plyerView?.isPlaying ?? false {
                cell.playButton?.isSelected = true
            }
                
            if self.plyerView?.isloading ?? false {
                cell.playButton?.setTitle("\("Loading".localize())...", for: .normal)
            }
        }
        else{
            cell.playButton?.isSelected = false
        }
        cell.playButton?.backgroundColor =  cell.playButton!.isSelected ? UIColor.init(HexColor: "2A5F87") : UIColor.init(HexColor: "639EDB")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch self.tableDisplayType
        {
        case .Shiurs:
            break
            
        case .MaggideiShiur:
            
            let maggidShiour =  self.displayedMagidiShiur[indexPath.row]
            self.showLessonsForMaggidShiur(maggidShiour)
            break
            
        case .Topics:
            
            if let topic = self.displayedTopics?[indexPath.section]
            {
                if let selectedTopic = topic.children?[indexPath.row]
                {
                    self.onSelectTopic(selectedTopic)
                }
            }
            
           break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        self.dispalyOptionTopConstraint?.constant = -1 * (scrollView.contentOffset.y - 16)
    }
    
    
    func onSelectTopic(_ topic:Topic)
    {
        if topic.shiurs != nil
            && topic.shiurs!.count > 0
        {
             self.showTopic(topic)
        }
        else{
            self.showLaodingView()
            
            GetTopicShiursProcess().executeWithObject(topic, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                self.hideLaodingView()
                
                topic.shiurs = object as? [TorahShiur]
                
                self.showTopic(topic)
                
            },onFaile: { (object, error) -> Void in
                
                self.hideLaodingView()
                
                let title = "Error"
                let msg = "Error while downloading topic shiurs\nPlease try again later"
                let cancelButton = "Ok"
                BTAlertView.show(title: title, message: msg, buttonKeys: [cancelButton], onComplete:{ (dismissButtonKey) in
                })
            })
        }
    }
    
    func showTopic(_ topic:Topic)
    {
        let storyboard = UIStoryboard(name: "TorahStoryboard", bundle: nil)
        let topicViewController =  storyboard.instantiateViewController(withIdentifier: "TopicViewController") as! TopicViewController
        
        topicViewController.delegate = self
        
        topicViewController.reloadWithObject(topic)
        self.navigationController?.pushViewController(topicViewController, animated: true)
    }
    
    //MARK: - BTSegmentController Delegate Methods
    func segmentController(_ segmentController:BTSegmentController, valueChanged index:Int)
    {
        self.tableView?.reloadData()
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
        
        if let selectedSegment = self.dispalyOptionSegmentedController?.selectedSegmentIndex
        {
            switch selectedSegment {
            case 0: //Recent Shiurim
                 self.getShiurimByCategory("recent")
                break
                
            case 1: //Parash Shiurim
                self.getShiurimByCategory("parsha")
                break
                
            case 2: //Popular Shiurim
                
               self.getShiurimByCategory("popular")
                break
                
            case 3: //Maggidi Shiur
                
                self.dispalyMaggidiShiur()
                
                break
                
            case 4: // Topics
                
               self.displayTopics()
                
                break
                
            default:
                print ("No selected segment")
            }
        }
    }
    
    func dispalyMaggidiShiur()
    {
       // self.searchBar?.text = ""
        
        if ShasIlluminatedManager.sharedManager.torahMaggideiShiours != nil
        {
            self.tableView?.reloadData()
            
            if self.tableView?.numberOfRows(inSection: 0) != 0
            {
                self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        else{
            
            self.getMaggidiShiur()
        }
    }
    
    func getMaggidiShiur()
    {
         self.showLaodingView()
        
        GetAllMagideiShiurProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.hideLaodingView()
            
            let maggidShiursSubjects = object as! [String:[MaggidShiur]]
            
            ShasIlluminatedManager.sharedManager.shasMaggideiShiours = maggidShiursSubjects["shas"]
            ShasIlluminatedManager.sharedManager.torahMaggideiShiours = maggidShiursSubjects["torah"]
            
            ShasIlluminatedManager.sharedManager.updateMaggidiShiurWithSavedShiurs()
            
            self.maggidiShiur = ShasIlluminatedManager.sharedManager.torahMaggideiShiours ?? [MaggidShiur]()

            self.tableView?.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
            self.hideLaodingView()
        })
    }
    
    func showLessonsForMaggidShiur(_ maggidShiur:MaggidShiur)
     {
         if maggidShiur.didGetFullInfo
         {
            self.showMaggidShiurLessonsViewwControllerFor(maggidShiur:maggidShiur)
         }
         else{
             
             self.showLaodingView()
             
             GetMaggidShiurDetailsProcess().executeWithObject(maggidShiur, onStart: { () -> Void in
                 
             }, onComplete: { (object) -> Void in
                 
                 self.hideLaodingView()
                 
                 let maggidShiourDetails = object as! [String:Any]
                 maggidShiur.updateWithInfo(maggidShiourDetails)
                 
                 self.showMaggidShiurLessonsViewwControllerFor(maggidShiur:maggidShiur)
                 
             },onFaile: { (object, error) -> Void in
                
                self.hideLaodingView()
                self.showMaggidShiurLessonsViewwControllerFor(maggidShiur:maggidShiur)
             })
        }
        
    }
    
    func showMaggidShiurLessonsViewwControllerFor(maggidShiur:MaggidShiur)
    {
        let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
        let maggidShiurLessonsViewController =  storyboard.instantiateViewController(withIdentifier: "MaggidShiurLessonsViewController") as! MaggidShiurLessonsViewController
        
        maggidShiurLessonsViewController.reloadWithObject(maggidShiur)
        maggidShiurLessonsViewController.delegate = self
        maggidShiurLessonsViewController.shiurimType = .Torah
        
        self.navigationController?.pushViewController(maggidShiurLessonsViewController, animated: true)
    }
    
    func displayTopics()
    {
        if self.topics != nil && self.topics!.count > 0
        {
            self.tableView?.reloadData()
        }
        else{
            self.getTopics()
        }
    }
    
    @IBAction func scrollToTopButtonClicked(_ sender: AnyObject) {
        
        self.tableView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject)
    {
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
        
        if self.shiurim != nil{
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
    
    @IBAction func sortSegmentedControlValueChanged(_ sender:BTSegmentedControl){
        
        self.hideSortSegmentedControl()
        
        if self.shiurim == nil{
            return
        }
        
        switch sender.selectedSegmentIndex {
        case 0://Title A-Z
            self.shiurim = self.shiurim!.sorted(by: { ($0.name ?? "") < ($1.name ?? "")})
            self.topics = self.topics?.sorted(by: { ($0.name ?? "") < ($1.name ?? "")})
            break
            
        case 1://Title Z-A
            self.shiurim = self.shiurim!.sorted(by: { ($0.name ?? "") > ($1.name ?? "")})
             self.topics = self.topics?.sorted(by: { ($0.name ?? "") > ($1.name ?? "")})
            break
            
        case 3://MagidShiur A-Z
            self.shiurim = self.shiurim!.sorted(by: { ($0.maggidShiur?.name ?? "") < ($1.maggidShiur?.name ?? "")})
            self.maggidiShiur = self.maggidiShiur.sorted(by: { ($0.name ?? "") < ($1.name ?? "")})
            break
            
        case 2://MagidShiur Z-A
             self.shiurim = self.shiurim!.sorted(by: { ($0.maggidShiur?.name ?? "") > ($1.maggidShiur?.name ?? "")})
             self.maggidiShiur = self.maggidiShiur.sorted(by: { ($0.name ?? "") > ($1.name ?? "")})

            break
            
        case 5://Topic A-Z
            self.shiurim = self.shiurim!.sorted(by: { ($0.topic?.name ?? "") < ($1.topic?.name ?? "")})
             self.topics = self.topics?.sorted(by: { ($0.name ?? "") < ($1.name ?? "")})
            break
            
        case 4://Topic Z-A
            self.shiurim = self.shiurim!.sorted(by: { ($0.topic?.name ?? "") > ($1.topic?.name ?? "")})
             self.topics = self.topics?.sorted(by: { ($0.name ?? "") > ($1.name ?? "")})
            break
            
        case 7://Date ->
            self.shiurim = self.shiurim!.sorted(by: { ($0.shiur_date ?? Date()) < ($1.shiur_date ?? Date())})
            break
            
        case 6://Date <-
            self.shiurim = self.shiurim!.sorted(by: { ($0.shiur_date ?? Date()) > ($1.shiur_date ?? Date())})
            break
            
        case 9://Length ->
            self.shiurim = self.shiurim!.sorted(by: { ($0.lengthTime) < ($1.lengthTime)})
            break
            
        case 8://Length <-
            self.shiurim = self.shiurim!.sorted(by: { ($0.lengthTime) > ($1.lengthTime)})
            break
            
        default: break
            
        }
        
       self.tableView?.reloadData()
        if (self.tableView?.numberOfRows(inSection: 0) ?? 0) > 0 {
            self.tableView?.scrollToRow(at:IndexPath(row:0, section: 0), at: .top, animated: false)
        }
       self.dispalyOptionTopConstraint?.constant = 16
    }
    
    //MARK: ShiursDelegate Methods
    func onPlayShiour(_ shiour:Shiur, type:ShiurType) 
    {
        self.playShiour(shiour, type:type, automaticly:true)
        
        self.reloadVisibleShioursCells()
   
    }
    
    func onPauseShiour(_ shiour: Shiur) {
        self.plyerView?.pause()
        
        self.reloadVisibleShioursCells()
    }
    
    func reloadVisibleShioursCells() {
        
        if self.tableView != nil {
            for cell in self.tableView!.visibleCells {
                
                if let torahShiurCell = cell as? TorahShiurTableCell {
                    
                   torahShiurCell.reloadData()
                    self.setTorahShiurCellLayout(torahShiurCell)
                }
            }
        }
    }
    
    func onShowMareiMekomoForshiur(_ shiur:Shiur)
    {
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        if tableDisplayType == .Topics
            , let topics = self.displayedTopics
        {
            for topic in topics
            {
                topic.shouldShowChildern = false
            }
        }
        
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
    
    
    //MARK TopicTableCell Delegate Methods
    func topicHeaderTableCell(toogleValueChanged value:Bool, topic:Topic)
    {
        self.tableView?.reloadData()
        
    }
    
    //MARK: - SearchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        self.tableView?.reloadData()
        self.setSearchLayout(active: true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if let selectedSegment = self.dispalyOptionSegmentedController?.selectedSegmentIndex
        {
            switch selectedSegment {
            case 0,1,2://Shiurs
                self.setDisplayedShiurim()
                break
                
            case 3: //Maggidi Shiur
                self.filterMaggidiShiur()
                break
                
            case 4: //Topics
                self.filterTopics()
                break
                
            default:
                break
            }
        }
        self.tableView?.reloadData()
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func setDisplayedShiurim()
    {
        var filterdShiurim = [TorahShiur]()
        
        if  self.searchBar?.isFirstResponder ?? false
            ,let searchText = self.searchBar?.text
            ,searchText.trimmeSpaces().count > 0{
            
            if self.shiurim != nil
            {
                for shiur in self.shiurim!
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
            filterdShiurim = self.shiurim ?? [TorahShiur]()
        }
        
        self.displayedShiurm = [TorahShiur]()
        
        for shiur in filterdShiurim {
            for maggidShiurOption in self.maggidiShiurOptions{
                if maggidShiurOption.isSelected && shiur.maggidShiur?.name == maggidShiurOption.optionName{
                    
                    self.displayedShiurm.append(shiur)
                    break
                }
            }
        }
    }
    
    func filterMaggidiShiur(){
        
        let searchText = self.searchBar?.text ?? ""
        
        self.filterdMaggidiShiur = [MaggidShiur]()
        for maggidShiur in self.maggidiShiur
        {
            if (maggidShiur.name?.contains(subString: searchText, ignoreCase: true) ?? false)
            {
                self.filterdMaggidiShiur?.append(maggidShiur)
            }
        }
    }
        
    func filterTopics()
    {
        let searchText = self.searchBar?.text ?? ""
        
        if self.topics != nil
        {
            self.filterdTopics = [Topic]()
            for topic in self.topics!
            {
                topic.shouldShowChildern = false
                
                if (topic.name?.contains(subString: searchText, ignoreCase: true) ?? false)
                {
                    self.filterdTopics?.append(topic)
                }
                else if let topicChildrens = topic.children
                {
                    let topicCopy = topic.copy() as! Topic
                    
                    for subTopic in topicChildrens
                    {
                        if (subTopic.name?.contains(subString: searchText, ignoreCase: true) ?? false)
                        {
                            if  self.filterdTopics!.contains(topicCopy) == false
                            {
                                self.filterdTopics?.append(topicCopy)
                                topicCopy.children = [Topic]()
                                topicCopy.shouldShowChildern = true
                            }
                            topicCopy.children?.append(subTopic)
                        }
                    }
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
    
    //MARK PlayerView Delegate
    func didPause(player: BTPlayerView) {
        self.reloadVisibleShioursCells()
    }
    
    func didPlay(player: BTPlayerView) {
        self.reloadVisibleShioursCells()
        self.hideLaodingView()
    }
    
    func playerLoadingStatusChanged(player:BTPlayerView, isLoading:Bool) {
        
        if self.isLoadingVideoLesson && isLoading{
            self.showLaodingView()
        }
        else{
            self.hideLaodingView()
        }
    }
    
    func playerView(_ player: BTPlayerView, didChangeDuration duration: Int) {
    }
    
    func didFinishPlaying(_ player: BTPlayerView) {
    }
}
