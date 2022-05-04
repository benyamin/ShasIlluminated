//
//  DownloadShiurProcess.swift
//  Shas Illuminated
//
//  Created by Binyamin on 29 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation

class DownloadShiurProcess: MSBaseProcess, URLSessionTaskDelegate, URLSessionDownloadDelegate
{
    var shiur:Shiur!
    var downloadProgress:Float = 0.0
    
    open override func executeWithObj(_ obj:Any?)
    {
        self.shiur = obj as? Shiur
        
        self.saveShiur(self.shiur)
    }
    
    func saveShiur(_ shiur:Shiur)
    {
        if let shiurUrlPath = shiur.url_download
        ,let shiurUrl = URL(string:shiurUrlPath)
        {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            let task = session.downloadTask(with: shiurUrl)
            task.resume()
        }
        else{
            self.onFailWithError(nil)
        }
    }
    
    //MARK: - session delegate methods
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            self.downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            DispatchQueue.main.async(execute: {() -> Void in
                self.onProgress?(self.shiur as Any)
            })
        }
    }
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        debugPrint("Download finished: \(location)")
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                
                let errorCode = (downloadTask.response as? HTTPURLResponse)?.statusCode
                let userInfo = ["Description": "serverError".localize()]
                let error = NSError(domain: "PortalDomain", code: errorCode!, userInfo: userInfo)
                
                self.onFailWithError(error)
                
                return
        }
        
        do {
            
            if let fileNamed = shiur.localFileName()
            {
                let filePath = FileManager.filePathFor(fileNamed: fileNamed, ofType: "mp3")
                
                print ("filePath:\(filePath)")
                // after downloading your file you need to move it to your destination url
                try FileManager.default.moveItem(at: location, to: filePath)
                
                self.writeToSavedShiursFile(shiur:shiur)
                
                DispatchQueue.main.async(execute: {() -> Void in
                    self.onDidSaveShiur(self.shiur)
                })
            }
            else{
                self.onFailWithError(nil)
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            
            self.onFailWithError(error)
            
        }
    }
    
    func writeToSavedShiursFile(shiur:Shiur)
    {
        let fileName = "savedShiurs"
        if let savedJsonString = FileManager.readFromFile(fileName, ofType: "json")
            ,let jsonData = savedJsonString.data(using: .utf8)
            ,var savedShiursDictinoary = Serializer.serlizedJsonDictoinryFromData(jsonData)
        {
            if let shiurType = shiur.dataDictionary?["type"] as? String
            {
                var savedShiurs = savedShiursDictinoary[shiurType] as? [[String:Any]] ??  [[String:Any]]()
                
                savedShiurs.append(shiur.dataDictionary!)
                
                savedShiursDictinoary[shiurType] = savedShiurs
                
                if let savedShiursDesiralizedData = savedShiursDictinoary.JsonDispaly()
                {
                    if FileManager.write(text: savedShiursDesiralizedData, to: fileName, ofType: "json")
                    {
                        print ("savedShiurs file did update")
                    }
                }
            }
        }
        else{
            if let shiurType = shiur.dataDictionary?["type"] as? String
            {
                var savedShiurs = [[String:Any]]()
                
                savedShiurs.append(shiur.dataDictionary!)
                
                var savedShiursDictinoary = [String:Any]()
                
                savedShiursDictinoary[shiurType] = savedShiurs
                
                if let savedShiursDesiralizedData = savedShiursDictinoary.JsonDispaly()
                {
                    if FileManager.write(text: savedShiursDesiralizedData, to: fileName, ofType: "json")
                    {
                        print ("savedShiurs file did update")
                    }
                }
            }
        }
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // debugPrint("Task completed: \(task), error: \(String(describing: error))")
        
        if error != nil
        {
            self.onFailWithError(error)
        }
    }
    
    func onDidSaveShiur(_ shiur:Shiur)
    {
       self.updateSavedInfoWithShiur(shiur)
        
        self.onComplete?(self.shiur as Any)
        
        self.shiur = nil
    }
    
    func updateSavedInfoWithShiur(_ shiur:Shiur)
    {
        var savedSdarimInfo = UserDefaults.standard.object(forKey: "savedSdarimInfo") as? [Int:[String:Any]]
            ??  [Int:[String:Any]]()
        
        if let sederId = shiur.masechet?.seder_id
        {
            var sederInfo = savedSdarimInfo[sederId] ?? [String:Any]()
            var masechetotInfo = sederInfo["masechtot"] as? [[String:Any]] ?? [[String:Any]]()
            var masechetInfo = masechetotInfo.objectBy(key:"id", value:shiur.masechta_id ?? "") as? [String:Any] ?? [String:Any]()
            var dafsInfo = masechetInfo["dafs"] as? [String:[[String:Any]]] ?? [String:[[String:Any]]]()
            
            if let dafs = shiur.masechet?.dafs
                ,let dafId = shiur.daf
            {
                for daf in dafs
                {
                    if dafId == daf.id
                    {
                        if let dafInfo = daf.serializedInfo
                        {
                            dafsInfo["\(dafId)"] = [dafInfo]
                        }
                    }
                }
            }
            masechetInfo["dafs"] = dafsInfo
            masechetotInfo.remove(masechetInfo as AnyObject)
            masechetotInfo.append(masechetInfo)
            sederInfo["masechtot"] = masechetotInfo
            savedSdarimInfo[sederId] = sederInfo
        }
        
        UserDefaults.standard.set(savedSdarimInfo, forKey: "savedSdarimInfo")

    }
    
  
    
    func onFailWithError(_ error:Error?)
    {
        var error = error
        
        if error == nil
        {
            let userInfo = ["Description": "serverError".localize()]
            error = NSError(domain: "PortalDomain", code: -1, userInfo: userInfo)
        }
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.onFaile?(self.shiur, error! as NSError)
        })
    }
}


