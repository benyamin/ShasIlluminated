//
//  Seder.swift
//  Shas Illuminated
//
//  Created by Binyamin on 15 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Seder:DataObject
{
    var jsonData:[String : Any]?
    
    var id:Int?
    var englishName:String?
    var hebrewName:String?
    var url_key:String?
    var position:Int?
    var rss_link:String?
    var masechtot:[Masechet]?
    var sponsers:[Sponser]?
    
    override init() {
        super.init()
    }
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.jsonData = dictionary
        
        self.id = dictionary["id"] as? Int
        self.englishName = dictionary["name"] as? String
        self.hebrewName = dictionary["name_hebrew"] as? String
        self.url_key = dictionary["url_key"] as? String
        self.position = dictionary["position"] as? Int
        self.rss_link = dictionary["rss_link"] as? String
        
        if let masechtotInfo = dictionary["masechtot"] as? [[String:Any]]
        {
            var masechtot = [Masechet]()
            for masechtInfo in masechtotInfo
            {
                let masechet = Masechet.init(dictionary: masechtInfo)
                masechtot.append(masechet)
            }
            self.masechtot = masechtot
        }
        
        if let sponsersInfo = dictionary["seder_sponsors"] as? [[String:Any]]
        {
            var sponsers = [Sponser]()
            
            for sponserInfo in sponsersInfo
            {
                let sponser = Sponser.init(dictionary: sponserInfo)
                sponsers.append(sponser)
            }
            self.sponsers = sponsers
        }
    }
    
    override func copy() -> Any {
        
        if self.jsonData != nil
        {
            let seder = Seder(dictionary: self.jsonData!)
            return seder
        }
        else{
            let seder = Seder()
            
            seder.id = self.id
            seder.englishName = self.englishName
            seder.hebrewName = self.hebrewName
            seder.url_key = self.url_key
            seder.position = self.position
            seder.rss_link = self.rss_link
            seder.masechtot = self.masechtot
            seder.sponsers = self.sponsers
            
            return seder
        }
    }
    
    func getMasechtotWithSavedLessons() -> [Masechet]?
    {
        if self.masechtot != nil
        {
            if let savedLessonsPath = DownloadManager.sharedManager.savedLessonsLocalPath()
            {
                var savedMasechtotIds = [String]()
                for lessonPath in savedLessonsPath
                {
                    if let masechta_id = lessonPath.slice(from: "masechta_id", to: "_daf")
                    {
                        if savedMasechtotIds.contains(masechta_id) == false
                        {
                            savedMasechtotIds.append(masechta_id)
                        }
                    }
                }
                
                var masechtotWithSavedLessons = [Masechet]()
                
                for masechet in self.masechtot!
                {
                    for savedMasechetId in savedMasechtotIds
                    {
                        if let masechetId = masechet.id
                            , savedMasechetId == "\(masechetId)"
                        {
                            masechtotWithSavedLessons.append(masechet)
                        }
                    }
                }
                
                if masechtotWithSavedLessons.count > 0
                {
                    return masechtotWithSavedLessons
                }
            }
        }
        return nil
    }
}
