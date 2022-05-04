//
//  GetMasechetDetailsProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin on 15 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetMasechetDetailsProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        if let maseceht = obj as? Masechet
            , let masecehtKey = maseceht.urlKey
        {
            let request = MSRequest()
            request.baseUrl = NetworkingManager.sharedManager.baseUrl
            request.serviceName = "masechtot/\(masecehtKey)"
            request.requiredResponseType = .JSON
            request.httpMethod = GET
            
            self.runWebServiceWithRequest(request)
        }
        else{
            self.onFaile?(nil, nil)
        }
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if error == nil
            {
                self.onComplete?(responseDctinoary)
                
            }
            else {
                self.onFaile?(responseDctinoary, error!)
            }
            
        },onFaile: { (object, error) in
            
            self.onFaile?(object, error)
        })
    }
}
