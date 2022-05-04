//
//  GetPartnersProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin on 1 Tevet 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetPartnersProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let request = MSRequest()
        request.baseUrl = "https://www.shasilluminated.org/api"
        request.serviceName = "partners/footer"
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
                if let partnersInfo = responseDctinoary["JsonResponse"] as? [[String:Any]]
                {
                    var partners = [Partner]()
                    for partnerInfo in partnersInfo
                    {
                        let partner = Partner.init(dictionary: partnerInfo)
                        partners.append(partner)
                    }
                    self.onComplete?(partners)
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
