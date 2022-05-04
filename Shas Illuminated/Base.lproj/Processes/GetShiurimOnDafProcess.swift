//
//  GetShiurimOnDafProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 13/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

open class GetShiurimOnDafProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        if let params = obj as? [String:Any]
            , let masechet = params["maseceht"] as? Masechet
            , let masecehtKey = masechet.urlKey
            , let dafId = params["dafId"] as? Int
        {
            let request = MSRequest()
            request.baseUrl = NetworkingManager.sharedManager.baseUrl
            request.serviceName = "shiur/masechta-\(masecehtKey)/daf-\(dafId)"
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
                if let shiurimInfo = responseDctinoary["shiurim"] as? [[String:Any]]
                {
                     var shiurim = [Shiur]()
                    for shiurInfo in shiurimInfo
                    {
                        let shiur = Shiur.init(dictionary: shiurInfo)
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
