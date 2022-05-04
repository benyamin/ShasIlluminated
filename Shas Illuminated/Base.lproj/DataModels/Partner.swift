//
//  Partner.swift
//  Shas Illuminated
//
//  Created by Binyamin on 1 Tevet 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Partner: DataObject
{
    var id:Int?
    var name:String?
    var link:String?
    var location:Int?
    var photoFile:Int?
    var imageData:ImageData?
    
    var imagePath:String?
     {
         get{
             if let maggidShiourImageSufix = self.imageData?.name
             {
                 let imagePath = "https://www.shasilluminated.org/storage/uploads/\(maggidShiourImageSufix)"
                 
                 return imagePath
             }
             return nil
         }
     }
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as? String
        self.link = dictionary["link"] as? String
        self.location = dictionary["location"] as? Int
        self.photoFile = dictionary["photoFile"] as? Int
        
        if let imageInfo = dictionary["image"] as? [String:Any]
        {
            self.imageData = ImageData(dictionary: imageInfo)
        }
    }
}
