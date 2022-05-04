//
//  DateInfo.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 16/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class  DateInfo:DataObject
{
    var masechet:Masechet?
    var daf:Daf?
    var dateDispaly:String?
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.masechet = Masechet.init(dictionary: dictionary)
        
        if let daf = dictionary["daf"] as? Int
        {
            self.daf = Daf.init(index: daf)
        }
        
        self.dateDispaly =  dictionary["date"] as? String
    }
}


