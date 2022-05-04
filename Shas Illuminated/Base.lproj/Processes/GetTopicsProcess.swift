//
//  GetTopicsProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 24/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetTopicsProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        if ShasIlluminatedManager.sharedManager.torahMaggideiShiours == nil {
            self.getMaggidiShiur()
        }
        else{
            getTopics()
        }
    }
    
    func getTopics(){
        
        let request = MSRequest()
               request.baseUrl = NetworkingManager.sharedManager.baseUrl
               request.serviceName = "topics"
               request.requiredResponseType = .JSON
               request.httpMethod = GET
               
               self.runWebServiceWithRequest(request)
    }
    
    func getMaggidiShiur()
       {
           GetAllMagideiShiurProcess().executeWithObject(nil, onStart: { () -> Void in
               
           }, onComplete: { (object) -> Void in
               
               
               let maggidShiursSubjects = object as! [String:[MaggidShiur]]
               
               ShasIlluminatedManager.sharedManager.shasMaggideiShiours = maggidShiursSubjects["shas"]
               ShasIlluminatedManager.sharedManager.torahMaggideiShiours = maggidShiursSubjects["torah"]
               
               ShasIlluminatedManager.sharedManager.updateMaggidiShiurWithSavedShiurs()
            
            self.getTopics()
               
           },onFaile: { (object, error) -> Void in
            self.getTopics()
           })
       }
    
    func runWebServiceWithRequest(_ request:BaseRequest)
    {
        NetworkingManager.sharedManager.runRequest(request, onStart: {
            
        },onComplete: { (dictionary, error) in
            
            let responseDctinoary = dictionary as [String:AnyObject]
            
            if error == nil
            {
                if let topicsIfno = responseDctinoary["JsonResponse"] as? [[String:Any]]
                {
                    var topics = [Topic]()
                    for topicInfo in topicsIfno
                    {
                        let topic = Topic.init(dictionary: topicInfo)
                        topics.append(topic)
                    }
                    self.onComplete?(topics)
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
