//
//  MSBaseViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin on 20 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

class  MSBaseViewController: UIViewController {
    
    func reloadWithObject(_ object:Any){
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ShasIlluminatedManager.sharedManager.selectedLanguage == .Hebrew {
           // self.view.semanticContentAttributeDrilldown(.forceRightToLeft)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.setLocalizatoin()
        
        NotificationCenter.default.addObserver(self,
                             selector: #selector(keyboardWillAppear(_:)),
                             name: UIWindow.keyboardWillShowNotification,
                             object: nil)
        NotificationCenter.default.addObserver(self,
                             selector: #selector(keyboardWillDisappear(_:)),
                             name: UIWindow.keyboardWillHideNotification,
                             object: nil)
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Keyboard notifications
    @objc func keyboardWillAppear(_ notification: Notification)
    {
        print ("keyboardWillAppear")
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification)
    {
         print ("keyboardWillDisappear")
    }
}
