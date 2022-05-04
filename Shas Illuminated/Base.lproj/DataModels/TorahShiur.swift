//
//  TorahShiur.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 23/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class TorahShiur:Shiur
{
    var topic_id:Int?
    var status:Int?
    var note:String?
    var parsha_sorte:Int?
    var is_populare:Bool?
    var popular_sorte:Int?
    var is_recente:Bool?
    var recent_sorte:Int?
    var is_parsha:Bool?
    var topic:Topic?
    
    override init(dictionary: [String : Any]) {
        super.init(dictionary: dictionary)
        
        self.dataDictionary = dictionary
        self.dataDictionary?["type"] = "Torah"
        
        self.id = dictionary["id"] as? Int
        self.topic_id = dictionary["topic_id"] as? Int
        self.lecturer_id = dictionary["speaker_id"] as? Int
        self.status = dictionary["status"] as? Int
        self.recordingDate = dictionary["recorded"] as? String
        self.edited = dictionary["recorded"] as? String
        self.length = dictionary["length"] as? String
        
        self.url_download = dictionary["url_download"] as? String
        if self.url_download != nil {
            if URL(string:self.url_download!) == nil{
                self.url_download = self.url_download?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            }
        }
        
        self.name = dictionary["name"] as? String
        self.position = dictionary["position"] as? Int
        self.dedicated_to = dictionary["dedicated_to"] as? String
        self.notes_file = dictionary["notes_file"] as? Int
        self.note = dictionary["note"] as? String
        self.message = dictionary["message"] as? String
        self.parsha_sorte = dictionary["parsha_sorte"] as? Int
        self.is_populare = dictionary["is_populare"] as? Bool
        self.popular_sorte = dictionary["popular_sorte"] as? Int
        self.is_recente = dictionary["is_recente"] as? Bool
        self.recent_sorte = dictionary["recent_sorte"] as? Int
        self.is_parsha = dictionary["is_parsha"] as? Bool
        
        if let speakerInfo = dictionary["speaker"] as? [String:Any]
        {
            self.maggidShiur = MaggidShiur.init(dictionary: speakerInfo)
        }
        
        if self.maggidShiur == nil
        ,let speakerId = dictionary["speaker_id"] as? Int
        {
            self.maggidShiur = ShasIlluminatedManager.sharedManager.getSpeakerById(speakerId)
        }
        
        if let topicInfo = dictionary["topic"] as? [String:Any]
        {
            self.topic = Topic.init(dictionary: topicInfo)
        }
        else {
            if let topiId = self.topic_id {
                self.topic = ShasIlluminatedManager.sharedManager.getTopicById(topiId)
            }
        }
        
        if self.recordingDate != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            self.shiur_date = dateFormatter.date(from: self.recordingDate!)
        }
    }
    
    override func localFileName() -> String?
    {
        if let shiurId = self.id
            ,let lecturer_id = self.lecturer_id
            ,let topicId = self.topic_id
        {
            let fileNamed = ("id\(shiurId)_lecturer_id\(lecturer_id)_topic_id\(topicId)")
            return fileNamed
        }
        
        return nil
    }
    
    override func isEqualToShiur(_ shiur:Shiur) -> Bool
    {
        if self.id == shiur.id
            && self.lecturer_id == shiur.lecturer_id
            && self.topic_id == (shiur as? TorahShiur)?.topic_id
        {
            return true
        }
        return false
    }
}
