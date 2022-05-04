//
//  HomeViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit
import MessageUI

class HomeViewController: MSBaseViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BTMenuViewDelegate, MFMailComposeViewControllerDelegate
{
    var partners:[Partner]?
 
     weak var menuView:BTMenuView?
    
    lazy var menuItems:[String]! = {
           
           return (["MY LIBRARY", "TORAH RESOURCES", "ABOUT SHAS ILLUMINATED", "APPROBATIONS", "DONATE"])
       }()
    
    @IBOutlet weak var topBarView:UIView!
    @IBOutlet weak var backGroundView:UIView?
    @IBOutlet weak var talmudButton:UIButton?
    @IBOutlet weak var torahButton:UIButton?
    @IBOutlet weak var popularSpeakersButtonButton:UIButton?
    @IBOutlet weak var partnersCollectionView:UICollectionView?
    @IBOutlet weak var langaugeSegmentedControl:UISegmentedControl!
    @IBOutlet weak var loginView:LoginView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backGroundView?.layer.cornerRadius = 3.0
        
        self.talmudButton?.layer.borderColor = UIColor.white.cgColor
        self.talmudButton?.layer.borderWidth = 1.0
        self.talmudButton?.layer.cornerRadius = 3.0
        
        self.torahButton?.layer.borderColor = UIColor.white.cgColor
        self.torahButton?.layer.borderWidth = 1.0
        self.torahButton?.layer.cornerRadius = 3.0
        
        self.popularSpeakersButtonButton?.layer.borderColor = UIColor.white.cgColor
        self.popularSpeakersButtonButton?.layer.borderWidth = 1.0
        self.popularSpeakersButtonButton?.layer.cornerRadius = 3.0
        
        self.getPartners()
        
        if ShasIlluminatedManager.sharedManager.selectedLanguage == .English {
            self.langaugeSegmentedControl.selectedSegmentIndex = 0
        }
        else {
            self.langaugeSegmentedControl.selectedSegmentIndex = 1
        }
        
        if UserDefaults.standard.value(forKey: "logedInUserToken") != nil{
            self.loginView?.removeFromSuperview()
        }
        else{
            self.showLoginView()
        }
    }
    
    func showLoginView() {
        
        self.backGroundView?.isUserInteractionEnabled = false
        self.backGroundView?.alpha = 0.4
        self.loginView?.isHidden = false
        self.loginView?.userNameTextField.becomeFirstResponder()
        
        self.loginView?.onLoginUser = {(user) in
            
            self.didFinishLoginFlow(userInfo: ["token":""])
            
            self.loginView?.isUserInteractionEnabled = false
            self.loginView?.removeFromSuperview()

            self.backGroundView?.isUserInteractionEnabled = true
            self.backGroundView?.alpha = 1.0
            
            RegisterUserProcess().executeWithObject(user, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
               
                if let userInfo = object as? [String:Any] {
                    self.didFinishLoginFlow(userInfo: userInfo)
                }
                
            },onFaile: { (object, error) -> Void in
                
                LoginUserProcess().executeWithObject(user, onStart: { () -> Void in
                    
                }, onComplete: { (object) -> Void in
                    
                    if let userInfo = object as? [String:Any] {
                        self.didFinishLoginFlow(userInfo: userInfo)
                    }
                    
                },onFaile: { (object, error) -> Void in
                    
                    self.loginView?.loadingIndicatorBaseView.isHidden = true
                    self.loginView?.loadingIndicator.stopAnimating()
                })
            })
        }
    }
    
    func didFinishLoginFlow(userInfo:[String:Any]){
        
        let token = userInfo["token"] as? String ?? ""
        UserDefaults.standard.setValue(token, forKey: "logedInUserToken")
        UserDefaults.standard.synchronize()
    }
    
    func getPartners()
    {
        GetPartnersProcess().executeWithObject(nil, onStart: { () -> Void in
                   
               }, onComplete: { (object) -> Void in
                   
                self.reloadPartners(object as! [Partner])
                   
               },onFaile: { (object, error) -> Void in
                   
               })
    }
    
    func reloadPartners(_ partners:[Partner])
    {
        self.partners = partners
        
        self.partnersCollectionView?.reloadData()
    }
    
    @IBAction func langaugeSegmentedControlValueChanged(_ sender:UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            ShasIlluminatedManager.sharedManager.selectedLanguage = .English
        }
        else {
            ShasIlluminatedManager.sharedManager.selectedLanguage = .Hebrew
        }
        
        self.view.setLocalizatoin()
    }
    
    @IBAction func talmudButtonClicked(_ sender:UIButton)
    {
        let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
        let talmudViewController =  storyboard.instantiateViewController(withIdentifier: "TalmudViewController")
       
        self.navigationController?.pushViewController(talmudViewController, animated: true)
    }
    
    @IBAction func torahButtonClicked(_ sender:UIButton)
    {
        let storyboard = UIStoryboard(name: "TorahStoryboard", bundle: nil)
        let torahViewController =  storyboard.instantiateViewController(withIdentifier: "TorahViewController")
        
        self.navigationController?.pushViewController(torahViewController, animated: true)
    }
    
    @IBAction func popularSpeakersButtonClicked(_ sender:UIButton)
     {
        if let popularSpeakersViewController =  self.storyboard?.instantiateViewController(withIdentifier: "PopularSpeakersViewController") {
            self.navigationController?.pushViewController(popularSpeakersViewController, animated: true)
        }
     }
    
    
    
    @IBAction func menuButtonClicked(_ sedner:AnyObject)
    {
        if self.menuView?.superview == self.view
        {
            self.menuView?.hide(animated: true)
        }
        else{
            
            self.menuView = UIView.viewWithNib("BTMenuView") as? BTMenuView
            self.menuView?.delegate = self
            
            let width = self.view.bounds.width
            let height = self.view.bounds.height - topBarView.frame.size.height
            self.menuView?.frame = CGRect(x: 0, y: topBarView.frame.size.height, width: width, height: height)
            self.menuView?.reloadWithMenuItems(self.menuItems)
            
            self.menuView?.showOnview(view: self.view)
        }
        
    }
    
    @IBAction func donateButtonClicked(_ sedner:AnyObject)
    {
        self.donate()
    }
    
    func donate()
    {
        if  let url = URL(string: "https://www.causematch.com/en/projects/shas-illuminated/")
             {
                 UIApplication.shared.open(url, options: [:], completionHandler: nil)
             }
             /*
              let webViewController = BTWebViewController(nibName: "BTWebViewController", bundle: nil)
              self.navigationController?.present(webViewController, animated: true, completion: nil)
              webViewController.loadUrl("https://siyum.shasilluminated.org", title: "Donation")
              */
    }
    
    @IBAction func cotactUsButtonClicked(_ sedner:AnyObject)
    {
        /*
        let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
        let contactUsViewController =  storyboard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
        
         self.navigationController?.present(contactUsViewController, animated: true, completion: nil)
         */
        let url = URL(string: "https://www.shasilluminated.org/contact-us")!
        //http://itunes.apple.com/app/idyourID
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        
    }
    
    @IBAction func rateUsButtonClicked(_ sender: Any)
    {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1491244203")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func feedbackButtonClicked(_ sender: Any)
    {
        if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.setToRecipients(["info@shasilluminated.org"])
            mail.setSubject("Feedback from Shas illuminated IOS application")

                present(mail, animated: true)
        }

    }
        
    // MARK: UICollectionView delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.partners?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PartnerCollectionCell", for: indexPath) as! PartnerCollectionCell
        cell.reloadWithObject(self.partners![indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let partner = self.partners?[indexPath.row]
            , let path = partner.link
            ,let url = URL(string:path)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
        return CGSize(width: 92, height: 100)
      }
    
    //MARK - BTMenuViewDelegate Methods
     func menuView(_ menuView:BTMenuView, didSelectRow row:Int)
     {
        let selectedMenuItem = self.menuItems[row]
        
        if selectedMenuItem == "MY LIBRARY"
        {
            self.displaySavedShiurs()
        }
        
        if selectedMenuItem == "DONATE"
        {
            self.donate()
            return
        }
        
         var urlPath:String?
                 
        if selectedMenuItem == "TORAH RESOURCES"
        {
            urlPath = "https://www.shasilluminated.org/daf-resources"
        }
        else  if selectedMenuItem == "ABOUT SHAS ILLUMINATED"
        {
            urlPath = "https://www.shasilluminated.org/about-shas-illuminated"
        }
            
        else  if selectedMenuItem == "APPROBATIONS"
        {
            urlPath = "https://www.shasilluminated.org/haskamos"
        }
        
        if urlPath != nil
        {
            if  let url = URL(string: urlPath!)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func displaySavedShiurs()
    {
        let storyboard = UIStoryboard(name: "HomeStoryboard", bundle: nil)
        let savedShiursViewController =  storyboard.instantiateViewController(withIdentifier: "SavedShiursViewController") as! SavedShiursViewController
        
        self.navigationController?.pushViewController(savedShiursViewController, animated: true)
        
    }    
}
