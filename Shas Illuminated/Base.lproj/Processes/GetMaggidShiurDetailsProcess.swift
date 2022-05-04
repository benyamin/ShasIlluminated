//
//  GetMaggidShiurDetailsProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetMaggidShiurDetailsProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        if let maggidShiur = obj as? MaggidShiur
            , let maggidShiurKey = maggidShiur.urlKey
        {
            let request = MSRequest()
            request.baseUrl = NetworkingManager.sharedManager.baseUrl
            request.serviceName = "magidei-shiur/\(maggidShiurKey)"
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
