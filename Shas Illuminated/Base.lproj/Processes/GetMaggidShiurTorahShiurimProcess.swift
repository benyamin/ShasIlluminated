//
//  GetMaggidShiurTorahShiurimProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 30/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetMaggidShiurTorahShiurimProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        
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
            request.serviceName = "magidei-shiur/torah/\(maggidShiurId)/shiurim"
            request.requiredResponseType = .JSON
            request.httpMethod = GET
            request.params = params
            
            if ShasIlluminatedManager.sharedManager.torahTopis != nil {
                 self.runWebServiceWithRequest(request)
            }
            else {
                self.getTopicsAndrunRequest(request)
            }
        }
        else{
            self.onFaile?(nil, nil)
        }
    }
    
    func getTopicsAndrunRequest(_ request:BaseRequest)
        {
            GetTopicsProcess().executeWithObject(nil, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                ShasIlluminatedManager.sharedManager.torahTopis = object as? [Topic]
                 self.runWebServiceWithRequest(request)
               
            },onFaile: { (object, error) -> Void in
                 self.runWebServiceWithRequest(request)
            })
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
                    var shiurim = [TorahShiur]()
                    
                    for shiurInfo in shiurimInfo
                    {
                        let shiur = TorahShiur.init(dictionary: shiurInfo)
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
