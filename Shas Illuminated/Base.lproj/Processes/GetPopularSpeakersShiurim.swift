//
//  GetPopularSpeakersShiurim.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 25/04/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetPopularSpeakersShiurim: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
                
        if ShasIlluminatedManager.sharedManager.torahMaggideiShiours == nil {
            self.getMaggidiShiur()
        }
        else {
            let popularSpeakers = self.getPopularSpeakers()
             self.onComplete?(popularSpeakers)
        }
       
    }
    
   func getMaggidiShiur()
         {
            GetAllMagideiShiurProcess().executeWithObject(nil, onStart: { () -> Void in
                
            }, onComplete: { (object) -> Void in
                
                
                let maggidShiursSubjects = object as! [String:[MaggidShiur]]
                
                ShasIlluminatedManager.sharedManager.shasMaggideiShiours = maggidShiursSubjects["shas"]
                ShasIlluminatedManager.sharedManager.torahMaggideiShiours = maggidShiursSubjects["torah"]
                
                ShasIlluminatedManager.sharedManager.updateMaggidiShiurWithSavedShiurs()
                
                let popularSpeakers = self.getPopularSpeakers()
                self.onComplete?(popularSpeakers)
                
            },onFaile: { (object, error) -> Void in
                
                let popularSpeakers = self.getPopularSpeakers()
                self.onComplete?(popularSpeakers)
            })
    }
    
    func getPopularSpeakers() -> [MaggidShiur]
    {
        if let path = Bundle.main.path(forResource: "PopularSpeakers", ofType: "json")
            ,let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        {
            let JsonResponse =  try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            
            if let maggidShiursInfo = JsonResponse as? [[String : Any]]
            {
                var popularSpeakers = [MaggidShiur]()
                
                for maggidShiurInfo in maggidShiursInfo
                {
                    let popularSpeaker = MaggidShiur.init(dictionary: maggidShiurInfo)
                  
                    if let torahMaggideiShiours = ShasIlluminatedManager.sharedManager.torahMaggideiShiours
                        ,let maggideiShiour = torahMaggideiShiours.first(where: { $0.id == popularSpeaker.id }) {
                        popularSpeakers.append(maggideiShiour)
                    }
                    else {
                        popularSpeakers.append(popularSpeaker)
                    }
                }
                
                return popularSpeakers
            }
        }
        return [MaggidShiur]()
    }
}
