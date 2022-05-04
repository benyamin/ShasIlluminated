//
//  GetSavedShiursProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 14/01/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetSavedShiursProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let savedShiurs = self.getSavedShiurs()
        self.onComplete?(savedShiurs)
    }
    
    func getSavedShiurs() -> [String:[Shiur]]
    {
        let fileName = "savedShiurs"
        if let savedJsonString = FileManager.readFromFile(fileName, ofType: "json")
            ,let jsonData = savedJsonString.data(using: .utf8)
            ,let savedShiursDictinoary = Serializer.serlizedJsonDictoinryFromData(jsonData)
        {
            var savedShiurs = [String:[Shiur]]()
            
            var talmudSavedShiurs = [Shiur]()
            if let talmudSavedShiursInfo = savedShiursDictinoary["Talmud"] as? [[String:Any]]
            {
                for savedShiurInfo in talmudSavedShiursInfo
                {
                    talmudSavedShiurs.append(Shiur.init(dictionary: savedShiurInfo))
                }
            }
            if let talmudSavedShiursInfo = savedShiursDictinoary["Daf"] as? [[String:Any]]
            {
                for savedShiurInfo in talmudSavedShiursInfo
                {
                    talmudSavedShiurs.append(Shiur.init(dictionary: savedShiurInfo))
                }
            }
            
            var torahSavedShiurs = [TorahShiur]()
            if let torahSavedShiursInfo = savedShiursDictinoary["Torah"] as? [[String:Any]]
            {
                for savedShiurInfo in torahSavedShiursInfo
                {
                    torahSavedShiurs.append(TorahShiur.init(dictionary: savedShiurInfo))
                }
            }
            
            savedShiurs["Talmud"] = talmudSavedShiurs
            savedShiurs["Torah"] = torahSavedShiurs
            
           return savedShiurs
        }
        
        return [String:[Shiur]]()
    }
}

