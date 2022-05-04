//
//  DeleteShiurProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 18/01/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class DeleteShiurProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        let shiur = obj as! Shiur
        
        self.deleteShiur(shiur)
        
    }
    
    func deleteShiur(_ shiur:Shiur)
    {
        if let localFilePath = shiur.localFileName()
        {
            var shiurPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            shiurPath += ("/\(localFilePath).mp3")
            
            if FileManager.default.fileExists(atPath: shiurPath)
            {
                do{
                    try FileManager.default.removeItem(atPath:shiurPath)
                    self.removeShiurFromSavedShiursFile(shiurToBeRemoved:shiur)
                    
                }catch{
                    print(error)
                }
            }
        }
    }
    
    func removeShiurFromSavedShiursFile(shiurToBeRemoved:Shiur)
    {
        let fileName = "savedShiurs"
        if let savedJsonString = FileManager.readFromFile(fileName, ofType: "json")
            ,let jsonData = savedJsonString.data(using: .utf8)
            ,var savedShiursDictinoary = Serializer.serlizedJsonDictoinryFromData(jsonData)
        {
            if let shiurType = shiurToBeRemoved.dataDictionary?["type"] as? String
            {
                var newSavedShiurs = [[String:Any]]()
                let savedShiurs = savedShiursDictinoary[shiurType] as? [[String:Any]] ??  [[String:Any]]()
                
                for savedShiurInfo in savedShiurs
                {
                    if shiurType == "Torah"
                    {
                        let savedShiur = TorahShiur.init(dictionary: savedShiurInfo)
                        if shiurToBeRemoved.isEqualToShiur(savedShiur) == false {
                            newSavedShiurs.append(savedShiurInfo)
                        }
                        
                    }
                    else{
                        let savedShiur = Shiur.init(dictionary: savedShiurInfo)
                        if shiurToBeRemoved.isEqualToShiur(savedShiur) == false {
                            newSavedShiurs.append(savedShiurInfo)
                        }
                    }
                    
                }
                
                savedShiursDictinoary[shiurType] = newSavedShiurs
                
                if let savedShiursDesiralizedData = savedShiursDictinoary.JsonDispaly()
                {
                    if FileManager.write(text: savedShiursDesiralizedData, to: fileName, ofType: "json")
                    {
                        print ("savedShiurs file did update")
                        self.onComplete?(savedShiursDesiralizedData)
                    }
                }
            }
        }
    }
}
