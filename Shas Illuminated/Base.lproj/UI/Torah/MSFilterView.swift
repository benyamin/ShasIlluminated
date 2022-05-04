//
//  MSFilterView.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 10/06/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import UIKit

class MSFilterView: UIView ,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var filterTextField:UITextField?
    @IBOutlet weak var optionsTableView:UITableView?
    @IBOutlet weak var tableViewBottomConstraint:NSLayoutConstraint?
    
    var onDone:(() -> Void)?
    
    var allFilterOptions = [FilterOption]()
    var displayedFilterOptions = [FilterOption]()
    var selectedFilters = [FilterOption]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear(_:)),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillDisappear(_:)),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        let resetButton = UIButton(type: .system)
        resetButton.frame = CGRect(x: 0, y: 0, width: 140, height: 44)
        resetButton.setTitle("Clear Filters".localize(), for: .normal)
        resetButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        tableHeaderView.addSubview(resetButton)
        self.optionsTableView?.tableHeaderView = tableHeaderView


    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        self.selectedFilters = [FilterOption]()
        self.optionsTableView?.reloadData()
    }
    
    func reloadWithOptions(_ filterOptions:[FilterOption]){
        
        self.allFilterOptions = filterOptions
        self.runFilter()
        
        self.filterTextField?.becomeFirstResponder()
    }
   
    func reloadData(){
        
        self.optionsTableView?.reloadData()
    }
    
    func runFilter(){
        
        if let filterText = self.filterTextField?.text
            , filterText.trimmeSpaces().count > 0
        {
            self.displayedFilterOptions = [FilterOption]()
            
            for filterOption in self.allFilterOptions{
                
                if filterOption.optionName.lowercased().range(of: "\\b\(filterText.lowercased())", options: .regularExpression) != nil {
                    
                    self.displayedFilterOptions.append(filterOption)
                }
            }
        }
        else {
            self.displayedFilterOptions = self.allFilterOptions
        }
        
        self.reloadData()
    }
    
    @IBAction func filterTextFieldValueChanged(_ sender:UITextField){
        self.runFilter()
    }
    
    @IBAction func clsoeButtonClicked(_ sender:UIButton){
        
        for filterOption in self.allFilterOptions {
            if self.selectedFilters.count == 0 || self.selectedFilters.contains(filterOption) {
                filterOption.isSelected = true
            }
            else {
                filterOption.isSelected = false
            }
        }
        self.onDone?()
    }
    
    //MARK: TableView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.displayedFilterOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MSFilterOptoinsTableCell", for:indexPath) as! MSFilterOptoinsTableCell
        cell.selectionStyle = .none
        
        let filterOption = self.displayedFilterOptions[indexPath.row]
        cell.reloadWithObject(filterOption)
        
        if self.selectedFilters.contains(filterOption) {
            
            cell.selectionCheckButton?.isSelected = true
            cell.selectionCheckButton?.backgroundColor = .green
        }
        else {
            cell.selectionCheckButton?.isSelected = false
            cell.selectionCheckButton?.backgroundColor = .white
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let filterOption = self.displayedFilterOptions[indexPath.row]
        
        if selectedFilters.contains(filterOption){
            selectedFilters.remove(filterOption)
        }
        else {
             selectedFilters.append(filterOption)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    //MARK: - Keyboard notifications
    @objc func keyboardWillAppear(_ notification: Notification)
       {
           if let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
           {
               self.tableViewBottomConstraint?.constant = keyboardSize.height
               
               UIView.animate(withDuration: 0.3) {
                   self.layoutIfNeeded()
               }
           }
       }
       
    @objc func keyboardWillDisappear(_ notification: Notification)
       {
           self.tableViewBottomConstraint?.constant = 0
           
           UIView.animate(withDuration: 0.3) {
               self.layoutIfNeeded()
           }
       }
    
}
