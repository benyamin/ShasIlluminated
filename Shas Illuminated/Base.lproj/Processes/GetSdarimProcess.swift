//
//  GetSdarimProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 13/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetSdarimProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let request = MSRequest()
        request.baseUrl = NetworkingManager.sharedManager.baseUrl
        
        request.serviceName = "masechtot"
        request.requiredResponseType = .JSON
        request.httpMethod = GET
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if error == nil
            {
                if let sdarimIfno = responseDctinoary["JsonResponse"] as? [[String:Any]]
                {
                    var sdarim = [Seder]()
                    for sederInfo in sdarimIfno
                    {
                        let seder = Seder.init(dictionary: sederInfo)
                        sdarim.append(seder)
                    }
                    self.onComplete?(sdarim)
                }
                else{
                    self.onFaile?(responseDctinoary, nil)
                }
                
            }
            else {
                self.onFaile?(responseDctinoary, error)
            }
            
        },onFaile: { (object, error) in
            
            self.onFaile?(object, error)
        })
    }
}
