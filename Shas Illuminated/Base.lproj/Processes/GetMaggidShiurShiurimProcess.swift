//
//  GetMaggidShiurShiurimProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetMaggidShiurShiurimProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
        /*
         limit    optional    how much results should be retrieved per page.
         page    optional    page number to be retrieved.
         orderBy    optional    order by specific column.
         name    optional    filter results by name.
         masechta    optional    filter results by masechta.
 */
        
        if let maggidShiur = obj as? MaggidShiur
            , let maggidShiurId = maggidShiur.id
        {
            var params = [String:String]()
            
            //Get all Shiuriim
            params["limit"] = "\(5000)"
            
            /*
            let limit = 40
            params["limit"] = "\(limit)"
            
            let page =  maggidShiur.shiurim == nil ? 1 : Int(maggidShiur.shiurim!.count/limit)
            params["page"] = "\(page)"
            */
            //params["masechta"] = "shabbos"
            
            let request = MSRequest()
            request.baseUrl = NetworkingManager.sharedManager.baseUrl
            request.serviceName = "magidei-shiur/\(maggidShiurId)/shiurim"
            request.requiredResponseType = .JSON
            request.httpMethod = GET
            request.params = params
                        
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
                if let shiurimInfo = responseDctinoary["data"] as? [[String:Any]]
                {
                    var shiurim = [Shiur]()
                    for shiurInfo in shiurimInfo
                    {
                        let shiur = Shiur.init(dictionary: shiurInfo)
                        shiurim.append(shiur)
                    }
                    
                    var shiurimData = [String:Any]()
                    shiurimData["shiurim"] = shiurim
                    self.onComplete?(shiurimData)
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

