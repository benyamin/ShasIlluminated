//
//  CreditsView.swift
//  Shas Illuminated
//
//  Created by Binyamin on 19 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import UIKit

class CreditsView: UIView, UITableViewDelegate, UITableViewDataSource
{
    var sponsers:[Sponser]?
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var creditsTableView:UITableView?
    
    func reoadWithObject(_ object:Any)
    {
        self.sponsers = object as? [Sponser]
        
        self.titleLabel?.text = self.sponsers?.first?.sponserdTitle
        
        self.creditsTableView?.reloadData()
        self.creditsTableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

       
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        
        self.creditsTableView?.allowsSelection = false
    }
    
    // MARK: - UITableView Delegate Methods:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.sponsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCell", for:indexPath) as! MSBaseTableViewCell
        
        if let sponser = self.sponsers?[indexPath.row]
        {
            cell.reloadWithObject(sponser)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
