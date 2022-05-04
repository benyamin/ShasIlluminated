//
//  GetTodaysShiurimProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 13/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetTodaysShiurimProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let request = MSRequest()
        request.baseUrl = "https://www.shasilluminated.org/api"
        request.serviceName = "shiur/today"
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
                 var shiurim = [Shiur]()
                
                if let shiurimInfo = responseDctinoary["shiurim"] as? [[String:Any]]
                {
                   
                    for shiurInfo in shiurimInfo
                    {
                        let shiur = Shiur.init(dictionary: shiurInfo)
                        shiurim.append(shiur)
                    }
                }
                if let currentInfo = responseDctinoary["current"] as? [String:Any]
                {
                    let dateInfo = DateInfo.init(dictionary: currentInfo)
                }
                
                self.onComplete?(shiurim)
                
            }
            else {
                self.onFaile?(responseDctinoary, error!)
            }
            
        },onFaile: { (object, error) in
            
            self.onFaile?(object, error)
        })
    }
}
