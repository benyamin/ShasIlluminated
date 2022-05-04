//
//  GetTorahShiurimProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 24/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetTorahShiurimProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let category = obj as! String
        let request = MSRequest()
        request.baseUrl = NetworkingManager.sharedManager.baseUrl
        request.serviceName = "shiurim/torah/\(category)"
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
                if let shiurimIfno = responseDctinoary["data"] as? [[String:Any]]
                {
                    var shiurim = [TorahShiur]()
                    for shiurInfo in shiurimIfno
                    {
                        let shiur = TorahShiur.init(dictionary: shiurInfo)
                        shiurim.append(shiur)
                    }
                    self.onComplete?(shiurim)
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

