//
//  RegisterUserProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 11/09/2021.
//  Copyright © 2021 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class RegisterUserProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {

        let user = obj as! User
        var paramters = [String:Any]()
        paramters["email"] = user.email
        paramters["fullname"] = user.name
        paramters["phone"] = user.phone
        
        SIServer().sendRequestMethod(methodName: "register", methodType: POST, parameters: paramters, success: { (responseData) in
        
            if let status = responseData["status"] as? Int
               , status == 200 {
                self.onComplete?(responseData)
            }
            else{
                var errorMessage = "Unknown error occurred please try again"
                if let responseError = responseData["error"] as? String {
                    errorMessage = responseError
                }
                let error = NSError(domain:"SI", code:-1, userInfo:[NSLocalizedDescriptionKey:errorMessage])
                self.onFaile?(nil, error)
            }
            
        
        }, failure: { (error) in
            
            self.onFaile?(nil, error)
        })
    }
}
