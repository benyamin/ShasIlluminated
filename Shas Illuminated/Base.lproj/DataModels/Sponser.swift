//
//  Sponser.swift
//  Shas Illuminated
//
//  Created by Binyamin on 15 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//


import Foundation

class Sponser:DataObject
{
    var id:Int?
    var masechta_id:Int?
    var sponserdTitle:String?
    var dedicated_to:String?
    var volume_number:Int?
    var name:String?
    var laravel_through_key:Int?
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.id = dictionary["sponsor_id"] as? Int
        self.masechta_id = dictionary["masechta_id"] as? Int
        self.dedicated_to = dictionary["dedicated_to"] as? String
        self.volume_number = dictionary["volume_number"] as? Int
        
        if let sponsorInfo = dictionary["sponsor"] as? [String:Any]
        {
            self.name = sponsorInfo["name"] as? String
        }
        if self.name == nil
        {
            self.name =  dictionary["name"] as? String
        }
        
        self.laravel_through_key = dictionary["laravel_through_key"] as? Int
    }
}
