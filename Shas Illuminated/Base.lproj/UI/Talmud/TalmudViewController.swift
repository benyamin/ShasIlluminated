//
//  TalmudViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 23/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

class TalmudViewController: MSBaseViewController, UITableViewDelegate, UITableViewDataSource, CreditDelegate, UISearchBarDelegate, BTSegmentControllerDelegate
{
    private enum TableDisplayType {
        case Masechtot
        case MaggideiShiur
    }   
    
    @IBOutlet weak var topBarView:UIView!
    @IBOutlet weak var currentDateLabel:UILabel?
    @IBOutlet weak var currentPageLabel:UILabel?
    
   
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var dispalyOptionSegmentedController:BTSegmentController?
    @IBOutlet weak var creditsView:CreditsView?
    @IBOutlet weak var loadingView:UIView?
    @IBOutlet weak var loadingGifImageview:UIImageView?
    @IBOutlet weak var searchBar:UISearchBar?
    @IBOutlet weak var searchBarTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var tabelViewConstraintToSearchBar:NSLayoutConstraint?
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var dispalyOptionTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var savedMasechtotButton:UIButton?
    
    @IBOutlet weak var plyerViewPlaceHolder:UIView?

    var plyerView:BTPlayerView? {
        get {
            ShasIlluminatedManager.sharedManager.plyerView
        }
    }
        
    var displayedSdarim:[Seder]{
        get{
            //If search is active
            if self.searchBar?.isFirstResponder ?? false
            {
                if let textLength = self.searchBar?.text?.count
                    ,textLength > 0
                {
                    return self.filterdSdarim
                }
                else{
                    return self.sdarim
                }
            }
            else{
                return self.sdarim
            }
        }
    }
    
    var filterdSdarim = [Seder]()
    
    var sdarim:[Seder]{
        get{
            
            if self.dispalyOptionSegmentedController?.selectedSegmentIndex == 1 //Display sdarim with saved shiurs
            {
                return ShasIlluminatedManager.sharedManager.sdarimWithSavedShiurs ?? [Seder]()
            }
            else{
                return ShasIlluminatedManager.sharedManager.sdarim ?? [Seder]()
            }
        }
    }
    
    var displayedMagidiShiur:[MaggidShiur]{
        get{
            //If search is active
            if self.searchBar?.isFirstResponder ?? false
            {
                if let textLength = self.searchBar?.text?.count
                    ,textLength > 0
                {
                    return self.filterdMagidiShiur
                }
                else{
                    return self.maggidiShiur
                }
            }
            else{
                return self.maggidiShiur
            }
        }
    }
    
    var filterdMagidiShiur = [MaggidShiur]()
    
    var maggidiShiur:[MaggidShiur]{
        get{
            if self.dispalyOptionSegmentedController?.selectedSegmentIndex == 3 //Display maggidi shiur with saved shiurs
            {
                return ShasIlluminatedManager.sharedManager.maggidiShiurWithSavedShiurs ?? [MaggidShiur]()
                
            }
            else{
                return ShasIlluminatedManager.sharedManager.shasMaggideiShiours ?? [MaggidShiur]()
                
            }
        }
    }
    
    private var tableDisplayType:TableDisplayType{
        
        get{
            if let selectedSegment = self.dispalyOptionSegmentedController?.selectedSegmentIndex
            {
                switch selectedSegment {
                case 0,1://Masehtot
                    return .Masechtot
                    
                case 2,3: //Maggidi Shiur
                    return .MaggideiShiur
                    
                default:
                    return .Masechtot
                }
            }
            else{
                return .Masechtot
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let textFieldInsideSearchBar =  self.searchBar?.value(forKey: "searchField") as? UITextField
        {
            textFieldInsideSearchBar.textColor = UIColor.white
        }
        
        self.currentPageLabel?.isHidden = true
        
        self.dispalyOptionSegmentedController?.delegate = self
        
        self.setSearchLayout(active: false, animated: false)
        
        self.currentDateLabel?.text = ShasIlluminatedManager.sharedManager.getCurrentDateDisplay()
                
        self.loadingView?.backgroundColor = UIColor.white
        self.loadingView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        self.loadingView?.layer.borderWidth = 1.0
        self.loadingView?.layer.cornerRadius = 3.0
        
        self.dispalyOptionSegmentedController?.layer.borderWidth = 1.0
        self.dispalyOptionSegmentedController?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        self.dispalyOptionSegmentedController?.layer.cornerRadius = 3.0
                
        self.plyerViewPlaceHolder?.backgroundColor = UIColor.white
        
        self.getTodaysShiurim()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.plyerViewPlaceHolder?.addSubview(self.plyerView!)
        self.plyerView!.addSidedConstraints()
        
        self.dispalyOptionTopConstraint?.constant = 16
        
        self.view.bringSubviewToFront( self.topBarView!)
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
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonClicked(_ sedner:AnyObject)
    {
        self.searchBar?.becomeFirstResponder()
    }
    
    func dispalyMasechtot()
    {
        self.searchBar?.text = ""
        
        if ShasIlluminatedManager.sharedManager.sdarim == nil
        {
            self.getSdarim()
        }
        else{
            self.tableView?.reloadData()
            
            if self.tableView?.numberOfSections ?? 0 > 0
            && self.tableView?.numberOfRows(inSection: 0) != 0
            {
                self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    func dispalyMaggidiShiur()
    {
        self.searchBar?.text = ""
        
        if ShasIlluminatedManager.sharedManager.shasMaggideiShiours != nil
        {
            self.tableView?.reloadData()
            
            if self.tableView?.numberOfRows(inSection: 0) != 0
            {
                self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        else{
            
            self.showLaodingView()
            
            GetAllMagideiShiurProcess().executeWithObject(self, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                self.hideLaodingView()
                
                let maggidShiursSubjects = object as! [String:[MaggidShiur]]
                
                ShasIlluminatedManager.sharedManager.shasMaggideiShiours = maggidShiursSubjects["shas"]
                ShasIlluminatedManager.sharedManager.torahMaggideiShiours = maggidShiursSubjects["torah"]
                
                ShasIlluminatedManager.sharedManager.updateMaggidiShiurWithSavedShiurs()
                
                self.tableView?.reloadData()
                
            },onFaile: { (object, error) -> Void in
                
                self.hideLaodingView()
            })
        }
    }
    
    func getAllMasechtot()
    {
        self.showLaodingView()
        
        GetMasechtotProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.hideLaodingView()
            
            ShasIlluminatedManager.sharedManager.masechtot = object as? [Masechet]
            
            self.currentPageLabel?.text = ShasIlluminatedManager.sharedManager.todaysPageDisplay()
            
            
        },onFaile: { (object, error) -> Void in
            
            self.hideLaodingView()
        })
    }
    
    
    func getSdarim()
    {
        self.showLaodingView()
        
        GetSdarimProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.hideLaodingView()
            
            ShasIlluminatedManager.sharedManager.sdarim = object as? [Seder]
            
            self.tableView?.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
            self.hideLaodingView()
        })
    }
    
    func getShiurimOnMaseceht(_ maseceht:Masechet, dafId:Int)
    {
        var params = [String:Any]()
        params["maseceht"] = maseceht
        params["dafId"] = dafId
        
        GetShiurimOnDafProcess().executeWithObject(params, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    
    func getTodaysShiurim()
    {
        self.showLaodingView()
        
        GetTodaysShiurimProcess().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.hideLaodingView()
            
            if let todaysShiurim = object as? [Shiur]
            {
                ShasIlluminatedManager.sharedManager.todaysShiurim = todaysShiurim
                
                if let defaultShiur = todaysShiurim.first
                {
                    if let masechetName = defaultShiur.masechet?.englishName
                        , let daf = defaultShiur.daf
                    {
                        self.currentPageLabel?.isHidden = false
                        self.currentPageLabel?.text = "\(masechetName) Daf \(daf)"
                    }
                    
                    if self.plyerView?.isPlaying == false {
                        
                         self.setDefaultShiour(defaultShiur)
                    }
                   
                }
            }
            
            self.dispalyMasechtot()
            
            
        },onFaile: { (object, error) -> Void in
            
            self.hideLaodingView()
            
            self.dispalyMasechtot()
        })
    }
    
    func setDefaultShiour(_ defaultShiur:Shiur)
    {
        self.playShiour(defaultShiur, automaticly:false)
    }
    
    func playShiour(_ shiour:Shiur, automaticly:Bool)
    {
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
        var lessonUrl:URL?
        
        if let lessonPath = DownloadManager.sharedManager.pathForShiour(shiour)
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
                
            }, onLessonNotFound: { })
        }
    }
    
    func searchShiurim()
    {
        var params = [String:Any]()
        params["query"] = "Yitzchok"
        params["limit"] = "20"
        
        SearchSahsShiurimProcess().executeWithObject(params, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            
        },onFaile: { (object, error) -> Void in
            
        })
        
    }
    
    // MARK: - UITableView Delegate Methods:
    func numberOfSections(in tableView: UITableView) -> Int
    {
        switch self.tableDisplayType
        {
        case .Masechtot:
            return self.displayedSdarim.count
            
        case .MaggideiShiur:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch self.tableDisplayType
        {
        case .Masechtot:
            return 70
            
        case .MaggideiShiur:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch self.tableDisplayType
        {
        case .Masechtot:
            let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "SederTableHeaderCell") as! SederTableHeaderCell
            
            sectionHeader.creditDelegate = self
            
            let seder = displayedSdarim[section]
            sectionHeader.reloadWithObject(seder)
            
            return sectionHeader
            
        case .MaggideiShiur:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch self.tableDisplayType
        {
        case .Masechtot:
            let seder = displayedSdarim[section]
            
            return seder.masechtot?.count ?? 0
            
        case .MaggideiShiur:
            return self.displayedMagidiShiur.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch self.tableDisplayType
        {
        case .Masechtot:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MasecehtTableCell", for:indexPath) as! MasecehtTableCell
            
            cell.selectionStyle = .none
            
            cell.creditDelegate = self
            
            let seder = displayedSdarim[indexPath.section]
            if let masechet = seder.masechtot?[indexPath.row]
            {
                cell.reloadWithObject(masechet)
            }
            
            return cell
            
        case .MaggideiShiur:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MaggidShiurTableCell", for:indexPath) as! MaggidShiurTableCell
            
            cell.selectionStyle = .none
            
            cell.reloadWithObject( self.displayedMagidiShiur[indexPath.row])
            
            return cell
        }
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
        switch self.tableDisplayType
        {
        case .Masechtot:
            
            let seder = displayedSdarim[indexPath.section]
            
            if let masechet = seder.masechtot?[indexPath.row]
            {
                self.showLessonsOnMasechet(masechet)
            }
            break
            
        case .MaggideiShiur:
            
            let maggidShiour =  self.displayedMagidiShiur[indexPath.row]
            self.showLessonsForMaggidShiur(maggidShiour)
            break
        }
        
    }

     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
          self.dispalyOptionTopConstraint?.constant = -1 * (scrollView.contentOffset.y - 16)
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
        maggidShiurLessonsViewController.shiurimType = .Talmud
        maggidShiurLessonsViewController.filterButton?.isHidden = true
        maggidShiurLessonsViewController.filterButtonLabel?.isHidden = true
        
        self.navigationController?.pushViewController(maggidShiurLessonsViewController, animated: true)
    }
    
    func showLessonsOnMasechet(_ masechet:Masechet)
    {
        if masechet.dafs == nil
        {
            self.showLaodingView()
            
            GetMasechetDetailsProcess().executeWithObject(masechet, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                self.hideLaodingView()
                
                let masecehtDetails = object as! [String:Any]
                masechet.updateWithInfo(masecehtDetails)
                
                if masechet.dafs == nil
                {
                    masechet.dafs = [Daf]()
                }
                
                self.showLessonsOnMasechet(masechet)
                
                
            },onFaile: { (object, error) -> Void in
                
                self.hideLaodingView()
            })
        }
        else{
            let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
            let masechetLessonsViewController =  storyboard.instantiateViewController(withIdentifier: "MasechetLessonsViewController") as! MasechetLessonsViewController
            
            masechetLessonsViewController.reloadWithObject(masechet)
            self.navigationController?.pushViewController(masechetLessonsViewController, animated: true)
        }
    }
    
    //MARK: CreditDelegate Methods
    func onDisplayCredits(sponsers:[Sponser])
    {
        if self.creditsView != nil
        {
            self.creditsView?.reoadWithObject(sponsers)
            let _ = BTPopUpView.show(view: self.creditsView!, onComplete:{ })
        }
    }
        
    //MARK: - SearchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        self.tableView?.reloadData()
        self.setSearchLayout(active: true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if self.tableDisplayType == .Masechtot
        {
            self.filterMasectot()
        }
        else if self.tableDisplayType == .MaggideiShiur
        {
            self.filterMaggideiShiur()
        }
        self.tableView?.reloadData()
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
        
    }
    
    func filterMasectot()
    {
        let searchText = self.searchBar?.text ?? ""
        
        self.filterdSdarim = [Seder]()
        
        for seder in self.sdarim
        {
            if let sederMasectot = seder.masechtot
            {
                for masechet in sederMasectot
                {
                    if (masechet.englishName?.contains(subString: searchText, ignoreCase: true) ?? false)
                        || (masechet.hebrewName?.contains(subString: searchText, ignoreCase: true) ?? false)
                    {
                        //Check if seder is in the filterdSdarim
                        if let seder = self.filterdSdarim.first(where: { $0.id == seder.id }) {
                            seder.masechtot?.append(masechet)
                        }
                        else{
                            let seder = seder.copy() as! Seder
                            seder.masechtot?.removeAll()
                            seder.masechtot?.append(masechet)
                            self.filterdSdarim.append(seder)
                        }
                    }
                }
            }
        }
    }
    
    func filterMaggideiShiur()
    {
        let searchText = self.searchBar?.text ?? ""
        
        self.filterdMagidiShiur = [MaggidShiur]()
        
        for maggidShiur in self.maggidiShiur
        {
            if (maggidShiur.name?.contains(subString: searchText, ignoreCase: true) ?? false)
            {
                self.filterdMagidiShiur.append(maggidShiur)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.setSearchLayout(active: false, animated: true)
        self.searchBar?.resignFirstResponder()
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
        self.tableView?.reloadData()
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
        
        if let selectedSegment = self.dispalyOptionSegmentedController?.selectedSegmentIndex
        {
            switch selectedSegment {
            case 0: //Masehtot
                self.dispalyMasechtot()
                break
                
            case 1: //Masehtot
                ShasIlluminatedManager.sharedManager.updateSdarimWithSavedShiurs()
                self.dispalyMasechtot()
                break
                
            case 2: //Maggidi Shiur
                
                self.dispalyMaggidiShiur()
                break
                
            case 3: //Maggidi Shiur
                
                ShasIlluminatedManager.sharedManager.updateMaggidiShiurWithSavedShiurs()
                self.dispalyMaggidiShiur()
                break
                
            case 4: // Todays Shiour
                
                if let todaysShiurim = ShasIlluminatedManager.sharedManager.todaysShiurim
                    , let defaultShiur = todaysShiurim.first
                {
                    self.setDefaultShiour(defaultShiur)
                }
                
                break
                
            default:
                print ("No selected segment")
            }
        }
    }
}
