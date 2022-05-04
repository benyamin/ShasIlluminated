//
//  MaggidShiur.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class MaggidShiur:DataObject
{
    var id: Int?
    var name:String?
    var urlKey:String?
    var bio:String?
    var shiurim_count: Int?
    var photo_file: Int?
    var position: Int?
    var download_count: Int?
    var preview_count: Int?
    var view_count: Int?
    var rss_link: String?
    var imageData:ImageData?
    
    var masechtot:[Masechet]?
    var talmudShiurim:[Shiur]?
    var savedTalmudShiurs:[Shiur]?
    var torahShiurim:[TorahShiur]?
    var savedTorahShiurs:[TorahShiur]?
    var didGetFullInfo = false
    
    var imagePath:String?
    {
        get{
            if let maggidShiourImageSufix = self.imageData?.name
            {
                if ShasIlluminatedManager.sharedManager.selectedLanguage == .English {
                    return "https://shas-media.s3.amazonaws.com/site-data/\(maggidShiourImageSufix)"
                }
                else{
                    return  "https://hadaf-media.s3.ap-south-1.amazonaws.com/site-data/\(maggidShiourImageSufix)"
                }                
            }
            return nil
        }
    }
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int ?? 0
        self.name = dictionary["name"] as? String ?? ""
        self.urlKey = dictionary["url_key"] as? String
        self.bio = dictionary["bio"] as? String
        self.shiurim_count = dictionary["shiurim_count"] as? Int ?? 0
        self.photo_file = dictionary["photo_file"] as? Int
        self.position = dictionary["position"] as? Int ?? 0
        self.download_count = dictionary["download_count"] as? Int ?? 0
        self.preview_count = dictionary["preview_count"] as? Int ?? 0
        self.view_count = dictionary["view_count"] as? Int ?? 0
        self.rss_link = dictionary["rss_link"] as? String
        
        if let imageInfo = dictionary["image"] as? [String:Any]
        {
            self.imageData = ImageData(dictionary: imageInfo)
        }
        
    }
    
    func updateWithInfo(_ dictionary: [String : Any])
    {
        self.didGetFullInfo = true
        
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
    }
    
    func updateSavedTalmudShiurs()
    {
        self.savedTalmudShiurs = nil
        
        if self.talmudShiurim != nil
        {
            if let savedLessonsPath = DownloadManager.sharedManager.savedLessonsLocalPath()
            {
                var savedShiurs = [Shiur]()
                
                for lessonPath in savedLessonsPath
                {
                    if let maggidShiourId = lessonPath.slice(from: "lecturer_id", to: "_masechta_id")
                        ,maggidShiourId == "\(self.id ?? 0)"
                    {
                        if let shiur_id = lessonPath.slice(from: "id", to: "_lecturer_id")
                        {
                            for shiur in self.talmudShiurim!
                            {
                                if "\(shiur.id ?? 0)" == shiur_id
                                {
                                    savedShiurs.append(shiur)
                                }
                            }
                        }
                    }
                    self.savedTalmudShiurs = savedShiurs
                }
            }
        }
    }
    
    func updateSavedTorahShiurs()
      {
          self.savedTalmudShiurs = nil
          
          if self.talmudShiurim != nil
          {
              if let savedLessonsPath = DownloadManager.sharedManager.savedLessonsLocalPath()
              {
                  var savedShiurs = [Shiur]()
                  
                  for lessonPath in savedLessonsPath
                  {
                      if let maggidShiourId = lessonPath.slice(from: "lecturer_id", to: "_masechta_id")
                          ,maggidShiourId == "\(self.id ?? 0)"
                      {
                          if let shiur_id = lessonPath.slice(from: "id", to: "_lecturer_id")
                          {
                              for shiur in self.talmudShiurim!
                              {
                                  if "\(shiur.id ?? 0)" == shiur_id
                                  {
                                      savedShiurs.append(shiur)
                                  }
                              }
                          }
                      }
                      self.savedTalmudShiurs = savedShiurs
                  }
              }
          }
      }
}
