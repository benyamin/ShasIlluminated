//
//  Shiur.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Shiur:DataObject
{
    var id:Int?
    var daf:Int?
    var masechta_id:Int?
    var notes_file:Int?
    var message:String?
    var lecturer_id:Int?
    var length:String?
    var url_download:String?
    var url_video_download:String?
    var dedicated_to:String?
    var edited:String?
    var masechet:Masechet?
    var shiur_date:Date?
    var sponsor:Sponser?
    var mareiMekomos:MareiMekomos?
    var name:String?
    var position:Int?
    var recordingDate:String?
    
    lazy var lengthTime:Date! = {
         
            if self.length != nil {
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "HH:mm:ss"
                
                if let date = dateFormatter.date(from: self.length!)
                {
                    return date
                }
                else{
                    dateFormatter.dateFormat = "mm:ss"
                    if let date = dateFormatter.date(from: self.length!)
                    {
                        return date
                    }
                }
            }
            
            return Date()
    }()
    
    var maggidShiur:MaggidShiur?{
        didSet{
            
            if let lecture = self.maggidShiur
                {
                    var lectureInfo = [String:Any]()
                    lectureInfo["id"] = lecture.id
                    lectureInfo["url_key"] = lecture.urlKey
                    lectureInfo["name"] = lecture.name
                    lectureInfo["photo_file"] = lecture.photo_file
                    
                    var imageInfo = [String:Any]()
                    imageInfo["id"] = lecture.imageData?.id
                    imageInfo["name"] = lecture.imageData?.name
                    
                    lectureInfo["image"] = imageInfo
                    
                    self.dataDictionary?["lecturer"] = lectureInfo
                }
        }
    }
    
    var dataDictionary:[String : Any]?
        
    lazy var englishTitle:String = {
        
        var englishTitle = self.masechet?.englishName ?? ""
        
        if let pageIndex = self.daf
        {
            englishTitle += " \(pageIndex)"
        }
        
        return englishTitle
    }()
    
    var mainTitle:String?{
      
        get{
            if self.englishTitle.count > 0
            {
                return englishTitle
            }
            else{
                return self.name ?? ""
            }
        }
    }
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.dataDictionary = dictionary
        self.dataDictionary?["type"] = "Talmud"
        
        self.id = dictionary["id"] as? Int
        self.daf = dictionary["daf"] as? Int
        self.masechta_id = dictionary["masechta_id"] as? Int
        self.notes_file = dictionary["notes_file"] as? Int
        self.message = dictionary["message"] as? String
        self.lecturer_id = dictionary["lecturer_id"] as? Int
        self.length = dictionary["length"] as? String
        
        self.url_download = dictionary["url_download"] as? String
        if self.url_download != nil {
            if URL(string:self.url_download!) == nil{
                self.url_download = self.url_download?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            }
        }
        
        self.url_video_download = dictionary["url_video_download"] as? String
              if self.url_video_download != nil {
                  if URL(string:self.url_download!) == nil{
                      self.url_video_download = self.url_video_download?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                  }
              }
        
       
        
        
        self.edited = dictionary["edited"] as? String
        self.dedicated_to = dictionary["dedicated_to"] as? String
        self.position = dictionary["position"] as? Int
        self.recordingDate = dictionary["recorded"] as? String

        
        if let lecturerInfo = dictionary["lecturer"] as? [String:Any]
        {
            self.maggidShiur = MaggidShiur.init(dictionary: lecturerInfo)
        }
        
        if self.recordingDate != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            self.shiur_date = dateFormatter.date(from: self.recordingDate!)
        }
        
        if let masechtaInfo = dictionary["masechta"] as? [String:Any]
        {
            self.masechet = Masechet.init(dictionary: masechtaInfo)
        }
        if let sponsorInfo = dictionary["sponsor"] as? [String:Any]
        {
            self.sponsor = Sponser.init(dictionary: sponsorInfo)
        }

    }
    
    func localFileName() -> String?
    {
        if let shiurId = self.id
            ,let lecturer_id = self.lecturer_id
            ,let masechta_id = self.masechta_id
            ,let daf = self.daf
        {
            let fileNamed = ("id\(shiurId)_lecturer_id\(lecturer_id)_masechta_id\(masechta_id)_daf\(daf)")
            return fileNamed
        }
        
        return nil
    }
    
    func isSaved() -> Bool
    {
        if let _ =  DownloadManager.sharedManager.pathForShiour(self)
        {
            return true
        }
        return false
    }
    
    func isEqualToShiur(_ shiur:Shiur) -> Bool
    {
        if self.id == shiur.id
        && self.lecturer_id == shiur.lecturer_id
        && self.masechta_id == shiur.masechta_id
            && self.daf == shiur.daf
        {
            return true
        }
        return false
    }
    
    func lessonUrl() -> URL?{
        
        if let lessonPath = DownloadManager.sharedManager.pathForShiour(self)
        {
            return URL(fileURLWithPath: lessonPath)
        }
        else if let url_download = self.url_download
        {
            return URL(string: url_download)
        }
        return nil
    }

}

