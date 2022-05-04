//
//  ContactUsViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 26/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {
    
    @IBOutlet  weak var contactInfoTextView:UITextView?
    @IBOutlet  weak var emailTextField:UITextField?
    @IBOutlet  weak var nameTextField:UITextField?
    @IBOutlet  weak var messageTextView:UITextView?
    @IBOutlet  weak var sendButton:UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contactInfoTextView?.textContainerInset = UIEdgeInsets.zero
        
        let name = "Shas Illuminated"
        let address = "25 Olympia Lane\nWaterbury, Connectiutct 06704"
        let phone = "203-312-SHAS"
        let email = "info@shasilluminated.org"
        self.contactInfoTextView?.text = "\(name)\n\n\(address)\n\nPhone: \(phone)\nEmail: \(email)"
        
        let borderColor = UIColor.init(HexColor: "5FAED2").cgColor
        self.messageTextView?.layer.borderColor = borderColor
        self.messageTextView?.layer.borderWidth = 1.0
        
        self.emailTextField?.layer.borderColor = borderColor
        self.emailTextField?.layer.borderWidth = 1.0
        
        self.nameTextField?.layer.borderColor = borderColor
        self.nameTextField?.layer.borderWidth = 1.0
        
        self.sendButton?.layer.cornerRadius = 3.0
    }
    
    @IBAction func sendButtonClicked(_ sender:UIButton)
    {
        if let name = self.nameTextField?.text
        , name.count > 0
        , let email = self.emailTextField?.text
        , email.confirmToRegex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        {
            if let message = self.messageTextView?.text
            , message.count > 3
            {
                var params = [String:Any]()
                params["email"] = email
                params["name"] = name
                params["message"] = message
                
                ContactProcess().executeWithObject(params, onStart: { () -> Void in
                    
                }, onComplete: { (object) -> Void in
                    
                  
                },onFaile: { (object, error) -> Void in
                    
                })
               
            }
            else{
                let title = "Missing Data"
                let msg = "Please edit your message"
                let cancelButton = "Ok"
                BTAlertView.show(title: title, message: msg, buttonKeys: [cancelButton], onComplete:{ (dismissButtonKey) in
                })
            }
        }
        else{
            let title = "Missing Data"
            let msg = "Your name or Email are not valid"
            let cancelButton = "Ok"
            BTAlertView.show(title: title, message: msg, buttonKeys: [cancelButton], onComplete:{ (dismissButtonKey) in
            })
        }
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
       self.dismiss(animated: true, completion:nil)
    }
}
