//
//  SearchSahsShiurimProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin on 15 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class SearchSahsShiurimProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        if let params = obj as? [String:Any]
            ,let query = params["query"]
            ,let limit = params["limit"]
        {
            let request = MSRequest()
            request.baseUrl = NetworkingManager.sharedManager.baseUrl
            request.serviceName = "search/shasShiurim/\(query)/0/\(limit)"
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
                self.onFaile?(responseDctinoary, error)
            }
            
        },onFaile: { (object, error) in
            
            self.onFaile?(object, error)
        })
    }
}
