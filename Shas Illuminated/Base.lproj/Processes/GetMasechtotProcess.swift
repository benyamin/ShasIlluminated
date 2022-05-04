//
//  GetMasechtotProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin on 15 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetMasechtotProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        if let path = Bundle.main.path(forResource: "masechtot", ofType: "json")
            ,let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        {
            let JsonResponse =  try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            
            if let masechtotInfo = JsonResponse as? [[String : Any]]
            {
                var masechtot = [Masechet]()
                
                for masechetInfo in masechtotInfo
                {
                    let masechet = Masechet.init(dictionary: masechetInfo)
                    masechtot.append(masechet)
                }
                self.onComplete?(masechtot)
            }
        }
    }
}

