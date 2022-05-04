//
//  Daf.swift
//  Shas Illuminated
//
//  Created by Binyamin on 15 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Daf:DataObject
{
    var serializedInfo:[String : Any]?
        
    var shiours = [Shiur]()
    var displayedShiurim = [Shiur]()
    
    var id:Int?
    var daf:Int?
    var masechet:Masechet?
    var sponsers:[Sponser]?
    
    var dataDictionary:[String : Any]?
    
    var symbol:String?{
        get{
            if daf != nil
            {
                return HebrewUtil.hebrewDisplayFromNumber(self.daf!)
            }
            return nil
        }
    }
    
    init(index:Int){
        super.init()
        
        self.daf = index
    }
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.serializedInfo = dictionary

        self.dataDictionary = dictionary
        self.dataDictionary?["type"] = "Daf"
        
        if let shiursInfo = dictionary["shiours"] as? [[String:Any]] {
            self.shiours = [Shiur]()
            
            for shiorInfo in shiursInfo{
                
                let shiur = Shiur.init(dictionary: shiorInfo)
                self.shiours.append(shiur)
            }
        }
        
        if let firstShiur = self.shiours.first {
            self.id = firstShiur.id
            self.daf = firstShiur.daf
            self.masechet = firstShiur.masechet
        }

        self.sponsers = [Sponser]()
        for shiour in self.shiours{
            
            if let shiurSponsor = shiour.sponsor {
                self.sponsers?.append(shiurSponsor)
            }
        }
    }
}
