//
//  GetTopicShiursProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 25/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetTopicShiursProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        if let topic = obj as? Topic
        , let topicId = topic.id
        {
            let request = MSRequest()
            request.baseUrl = NetworkingManager.sharedManager.baseUrl
            request.serviceName = "topics/\(topicId)/shiurim"
            request.requiredResponseType = .JSON
            request.httpMethod = GET
            
            self.runWebServiceWithRequest(request)
        }
        else{
            self.onFaile?(obj, nil)
        }
     
    }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if error == nil
            {
                if let shiursIfno = responseDctinoary["data"] as? [[String:Any]]
                {
                    var shiurs = [TorahShiur]()
                    for shiurInfo in shiursIfno
                    {
                        let shiur = TorahShiur.init(dictionary: shiurInfo)
                        shiurs.append(shiur)
                    }
                    self.onComplete?(shiurs)
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
