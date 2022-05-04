//
//  ImageData.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 13/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class  ImageData:DataObject
{
    var id:Int?
    var orig_name:String?
    var name:String?
    var subdir:String?
    var type:String?
    var size_kb:Float?
    var user_id:Int?
    var used:Int?
    var date_created:String?
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int
        self.orig_name = dictionary["orig_name"] as? String
        self.name = dictionary["name"] as? String
        self.subdir = dictionary["subdir"] as? String
        self.type = dictionary["type"] as? String
        self.size_kb = dictionary["size_kb"] as? Float
        self.user_id = dictionary["user_id"] as? Int
        self.used = dictionary["used"] as? Int
        self.date_created = dictionary["date_created"] as? String
        
        if let imageId = dictionary["imageId"] as? Int
        {
             self.id = imageId
        }
        if let imageName = dictionary["imageName"] as? String
        {
            self.name = imageName
        }
    }
}
