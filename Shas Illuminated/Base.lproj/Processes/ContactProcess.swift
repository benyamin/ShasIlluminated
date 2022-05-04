//
//  ContactProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 26/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

open class ContactProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
    
        let request = MSRequest() 
        request.baseUrl = "https://www.shasilluminated.org/api"
        request.serviceName = "contact"
        request.requiredResponseType = .JSON
        request.httpMethod = POST
        request.params = obj as? [String:Any]
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if error == nil
            {
                let mareiMekomos = MareiMekomos.init(dictionary: responseDctinoary)
                self.onComplete?(mareiMekomos)
            }
            else {
                self.onFaile?(responseDctinoary, error)
            }
            
        },onFaile: { (object, error) in
            
            self.onFaile?(object, error)
        })
    }
}
