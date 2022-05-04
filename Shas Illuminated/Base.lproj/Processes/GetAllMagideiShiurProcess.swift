//
//  GetAllMagideiShiurProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//


import Foundation

open class GetAllMagideiShiurProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let request = MSRequest()
        request.baseUrl = NetworkingManager.sharedManager.baseUrl
        request.serviceName = "magidei-shiur"
        request.requiredResponseType = .JSON
        request.httpMethod = GET
        
        //Google AudioBooks Vs Amazon Audible Which one is Better ?

        
       // request.params = params
        
        self.runWebServiceWithRequest(request)
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if error == nil
            {
                var maggidShiursSubjects = [String:[MaggidShiur]]()
                if let shasMaggidShioursInfo = responseDctinoary["shas"] as? [[String:Any]]
                {
                    maggidShiursSubjects["shas"] = self.getMaggidShioursFromDictionary(shasMaggidShioursInfo)
                }
                if let torahMaggidShioursInfo = responseDctinoary["torah"] as? [[String:Any]]
                {
                  maggidShiursSubjects["torah"] = self.getMaggidShioursFromDictionary(torahMaggidShioursInfo)
                }
               self.onComplete?(maggidShiursSubjects)
                
            }
            else {
                self.onFaile?(responseDctinoary, error!)
            }
            
        },onFaile: { (object, error) in
            
           self.onFaile?(object, error)
        })
    }
    
    func getMaggidShioursFromDictionary(_ maggidShiursInfo:[[String:Any]]) -> [MaggidShiur]
    {
        var maggidShiours = [MaggidShiur]()
        
        for maggidShiurInfo in maggidShiursInfo
        {
            let maggidShiur = MaggidShiur.init(dictionary: maggidShiurInfo)
            maggidShiours.append(maggidShiur)
        }
        
        return maggidShiours
    }
}
