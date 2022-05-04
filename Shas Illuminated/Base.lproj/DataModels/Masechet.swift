//
//  Masechet.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Masechet:DataObject
{
    var id:Int?
    var seder_id:Int?
    var englishName:String?
    var hebrewName:String?
    var urlKey:String?
    var value: Int?
    var position:Int?
    var rss_link:String?
    var multi_volumes:Int?
    var hebrewbooks_pdf_id:Int?
    var hebrewbooks_id:Int?
    var download_url:String?
    var download_count:Int?
    var preview_count:Int?
    var view_count:Int?
    var sponsers:[Sponser]?
    
    var numberOfPages:Int?
    var firstPageIndex:Int?
    var lastPageSide:String?
    
    var dafs:[Daf]?
    var dafsWithSavedShiours:[Daf]?

    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int
        
        self.englishName = dictionary["name"] as? String
        if  self.englishName == nil
        {
             self.englishName = dictionary["label"] as? String
        }
        
       self.hebrewName = dictionary["name_hebrew"] as? String
        self.urlKey = dictionary["url_key"] as? String
        self.value = dictionary["value"] as? Int
        
        self.position = dictionary["position"] as? Int
        self.rss_link = dictionary["rss_link"] as? String
        self.multi_volumes = dictionary["multi_volumes"] as? Int
        self.hebrewbooks_pdf_id = dictionary["hebrewbooks_pdf_id"] as? Int
        self.hebrewbooks_id = dictionary["hebrewbooks_id"] as? Int
        self.download_url = dictionary["download_url"] as? String
        self.download_count = dictionary["download_count"] as? Int
        self.preview_count = dictionary["preview_count"] as? Int
        self.view_count = dictionary["view_count"] as? Int
        
        self.numberOfPages = dictionary["numberOfPages"] as? Int
        self.firstPageIndex = dictionary["firstPageIndex"] as? Int
        self.lastPageSide = dictionary["lastPageSide"] as? String
        
        if let sponsersInfo = dictionary["masechta_sponsors"] as? [[String:Any]]
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
    
    func updateWithInfo(_ dictionary: [String : Any])
    {
        if let dafsInfo = dictionary["dafs"] as? [String:[[String:Any]]]
        {
            var dafs = [Daf]()
            
            let sortedKeys = dafsInfo.keys.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
            for key in sortedKeys
            {
                if let dafInfo = dafsInfo[key]
                {
                    let daf = Daf.init(dictionary:["shiours":dafInfo])
                    dafs.append(daf)
                }
            }
            
            self.dafs = dafs
        }
    }
    
    func updateSavedShiurs()
    {
        self.dafsWithSavedShiours = [Daf]()
        if let savedLessonsPath = DownloadManager.sharedManager.savedLessonsLocalPath()
        {
            for lessonPath in savedLessonsPath
            {
                if let masechta_id = lessonPath.slice(from: "masechta_id", to: "_daf")
                    ,let daf_id = lessonPath.slice(from: "daf", to: nil)
                {
                    if masechta_id == "\(self.id ?? -1)"
                    {
                        if self.dafs != nil
                        {
                            for daf in self.dafs!
                            {
                                if Int(daf_id) == daf.daf
                                {
                                   self.dafsWithSavedShiours?.append(daf)
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
