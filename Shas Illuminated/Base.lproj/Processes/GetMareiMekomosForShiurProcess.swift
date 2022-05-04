//
//  GetMareiMekomosForShiurProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 13/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

open class GetMareiMekomosForShiurProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        if let shiur = obj as? Shiur
            ,let shiurId = shiur.id
        {
            let request = MSRequest()
            request.baseUrl = NetworkingManager.sharedManager.baseUrl
            request.serviceName = "shiur/\(shiurId)/mm"
            request.requiredResponseType = .JSON
            request.httpMethod = GET
            
            self.runWebServiceWithRequest(request)
        }
        else{
            self.onFaile?(nil,nil)
        }
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
