//
//  PopularSpeakersViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 25/04/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class PopularSpeakersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var maggidiShiur = [MaggidShiur]()
    
    @IBOutlet weak var maggidiShiurTableView:UITableView?
    @IBOutlet weak var loadingView:UIView?
    @IBOutlet weak var loadingGifImageview:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getPopularMaggidShiurs()
    }
    
    func getPopularMaggidShiurs() {
        
        GetPopularSpeakersShiurim().executeWithObject(nil, onStart: { () -> Void in
            
        }, onComplete: { (object) -> Void in
            
            self.maggidiShiur = object as! [MaggidShiur]
            
            self.reloadData()
            
        },onFaile: { (object, error) -> Void in
            
        })
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadData() {
        
        self.maggidiShiurTableView?.reloadData()
    }
    
    func showLessonsForMaggidShiur(_ maggidShiur:MaggidShiur)
    {
        if maggidShiur.didGetFullInfo
        {
            self.showMaggidShiurLessonsViewwControllerFor(maggidShiur:maggidShiur)
        }
        else{
                        
            GetMaggidShiurDetailsProcess().executeWithObject(maggidShiur, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                                
                let maggidShiourDetails = object as! [String:Any]
                maggidShiur.updateWithInfo(maggidShiourDetails)
                
                self.showMaggidShiurLessonsViewwControllerFor(maggidShiur:maggidShiur)
                
            },onFaile: { (object, error) -> Void in
                
                self.showMaggidShiurLessonsViewwControllerFor(maggidShiur:maggidShiur)
            })
        }
        
      }

    func showMaggidShiurLessonsViewwControllerFor(maggidShiur:MaggidShiur)
       {
           let storyboard = UIStoryboard(name: "TalmudStoryboard", bundle: nil)
           let maggidShiurLessonsViewController =  storyboard.instantiateViewController(withIdentifier: "MaggidShiurLessonsViewController") as! MaggidShiurLessonsViewController
           
           maggidShiurLessonsViewController.reloadWithObject(maggidShiur)
           maggidShiurLessonsViewController.shiurimType = .Torah
           
           self.navigationController?.pushViewController(maggidShiurLessonsViewController, animated: true)
       }
    
    // MARK: - UITableView Delegate Methods:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return maggidiShiur.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MaggidShiurTableCell", for:indexPath) as! MaggidShiurTableCell
        
        cell.selectionStyle = .none
        
        cell.reloadWithObject( self.maggidiShiur[indexPath.row])
        
        return cell
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
        let maggidShiour =  self.maggidiShiur[indexPath.row]
        self.showLessonsForMaggidShiur(maggidShiour)
        
    }
    
}
