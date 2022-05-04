//
//  BTMenuView.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 17/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

protocol BTMenuViewDelegate:class
{
    func menuView(_ menuView:BTMenuView, didSelectRow row:Int)
}

class BTMenuView: UIView, UITableViewDelegate, UITableViewDataSource
{
    var delegate:BTMenuViewDelegate?
    
    var menuItems:[String]?
    
    @IBOutlet weak var shadowView:UIView?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var tableViewHeightConstriant:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.shadowViewTap(_:)))
        self.shadowView?.addGestureRecognizer(tap)
        
        self.tableView?.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.shadowView?.backgroundColor = UIColor.white

        self.reloadData()
    }
    
    @objc func shadowViewTap(_ sender: UITapGestureRecognizer) {
         
        self.hide(animated: true)
     }
    
    func reloadWithMenuItems(_ menuItems:[String])
    {
        self.menuItems = menuItems
        
        self.reloadData()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.hide(animated: false)

        if let visibleCells = tableView?.visibleCells
        {
            for cell in visibleCells
            {
               if let row = tableView?.indexPath(for: cell)?.row
               {
                    (cell as! BTMenuCell).showAfterDelay((Double(row) * 0.1))
                }
            }
        }
    }
    
    func showOnview(view:UIView)
    {
        view.addSubview(self)
        
        let cellHeight:CGFloat = 52
        self.tableViewHeightConstriant?.constant = CGFloat(self.menuItems?.count ?? 0) * cellHeight
    }
    
    func hide(animated:Bool)
    {
       self.animateTableOut(animated: animated)
    }
    
    func animateTableOut(animated:Bool)
    {
        if let visibleCells = tableView?.visibleCells
        {
            for cell in visibleCells.reversed()
            {
                if animated
                {
                    if let row =  tableView?.indexPath(for: cell)?.row
                    {
                        let delay = (Double(visibleCells.count - row) * 0.1)
                        (cell as! BTMenuCell).hideAfterDelay(delay)
                    }
                }
                else{
                     (cell as! BTMenuCell).hide()
                }
            }
            
            if animated
            {
                self.perform(#selector(self.remove), with: nil, afterDelay: Double(visibleCells.count) * 0.1 + 0.4)
            }
        }
    }
    
    @objc private func remove()
    {
        self.removeFromSuperview()
    }
    
    func reloadData()
    {
        self.tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.menuItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:BTMenuCell! = tableView.dequeueReusableCell(withIdentifier: "BTMenuCell") as? BTMenuCell
        
        if cell == nil
        {
            cell = UIView.loadFromNibNamed("BTMenuCell") as? BTMenuCell
        }
                
        let menuItem = self.menuItems![indexPath.row]
        cell.reloadWithObject(menuItem)
       
        
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
        self.delegate?.menuView(self, didSelectRow: indexPath.row)
    }
}
