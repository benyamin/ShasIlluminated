//
//  LoginView.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 10/09/2021.
//  Copyright © 2021 Binyamin Trachtman. All rights reserved.
//

import UIKit

class LoginView: UIView, UITextFieldDelegate {

    var onLoginUser:((_ user:User) -> Void)?
    
    @IBOutlet weak var userNameTextField:UITextField!
    @IBOutlet weak var userEmailTextField:UITextField!
    @IBOutlet weak var userPhoneTextField:UITextField!
    @IBOutlet weak var loginButton:UIButton!
    @IBOutlet weak var loadingIndicatorBaseView:UIView!
    @IBOutlet weak var loadingIndicator:UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loginButton.isEnabled = false
        self.loginButton.alpha = 0.6
        
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
        self.loadingIndicatorBaseView.layer.cornerRadius = 5.0
        self.loadingIndicatorBaseView.layer.borderWidth = 2.0
        self.loadingIndicatorBaseView.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        
        self.loadingIndicatorBaseView.isHidden = true
    }
        
    @IBAction func loginButtonClicked(_ sender:UIButton){
        
        let user = User()
        user.name = self.userNameTextField.text
        user.email = self.userEmailTextField.text
        user.phone = self.userPhoneTextField.text
        self.onLoginUser?(user)
    }
    
    @IBAction func textFieldValueChanged(_ sender:UITextField){
        
        if let userName = userNameTextField.text
            ,userName.count > 2
            ,let userPhone = userPhoneTextField.text
           ,userPhone.count > 5
           ,let userEmail = userEmailTextField.text
           ,userEmail.isValidEmail() {
            
            self.loginButton.isEnabled = true
            self.loginButton.alpha = 1.0
        }
        else{
            self.loginButton.isEnabled = false
            self.loginButton.alpha = 0.6
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
         return true
    }
}
