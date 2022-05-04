//
//  MareiMekomos.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 13/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class MareiMekomos:DataObject
{
    var note:String?
    var file:String?
    var masechtName:String?
    
    var path:String?{
        
        return file
    }
    
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.note = dictionary["note"] as? String
        self.file = dictionary["file"] as? String
        self.masechtName = dictionary["masechta"] as? String
    }
}
