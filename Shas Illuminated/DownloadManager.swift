//
//  DownloadManager.swift
//  Shas Illuminated
//
//  Created by Binyamin on 29 Heshvan 5780.
//  Copyright © 5780 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

public class DownloadManager
{
    static public let sharedManager =  DownloadManager()
    
    private var downlaodQ = [Shiur]()
    private var downloadShiurProcess:DownloadShiurProcess?
    private var shiurInProgress:Shiur?
    
    
    func downloadShiur(_ shiur:Shiur)
    {
        if self.isDowloadingShiur(shiur)
        {
            return
        }
        
        //If downlodProcess is in porgress
        if downloadShiurProcess != nil
        {
            downlaodQ.append(shiur)
            return
        }
        
        self.shiurInProgress = shiur
        
        self.downloadShiurProcess = DownloadShiurProcess()
        
        self.downloadShiurProcess?.executeWithObject(shiur,onStart: { () -> Void in
            
        }, onProgress: { (object) -> Void in
            
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadDidProgress"), object: nil)            
            
        }, onComplete: { (object) -> Void in
            
            self.downloadShiurProcess = nil
            
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadComplete"), object: nil)
            
           self.checkDownloadQ()
            
        },onFaile: { (object, error) -> Void in
            
            self.downloadShiurProcess = nil
            
            self.checkDownloadQ()
            
        })
    }
    
    func checkDownloadQ()
    {
        if self.downlaodQ.count > 0
        {
            if let shiur = self.downlaodQ.first
            {
                self.downlaodQ.removeFirst()
                self.downloadShiur(shiur)
            }
        }
    }
    
    func pathForShiour(_ shiur:Shiur) -> String?
    {
        if let localFilePath = shiur.localFileName()
        {
            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            path += ("/\(localFilePath).mp3")
            
            if (FileManager.default.fileExists(atPath: path))
            {
                return path
            }
        }
        return nil
    }
    
    func isDowloadingShiur(_ shiur:Shiur) -> Bool
    {
        if shiurInProgress?.isEqualToShiur(shiur) ?? false
        {
            return true
        }
        else{
            for aShiur in self.downlaodQ
            {
                if aShiur.isEqualToShiur(shiur)
                {
                    return true
                }
            }
        }
        return false
    }
    
    func downloadProgressPercentageForShiur(_ shiur:Shiur) -> CGFloat
    {
        if shiurInProgress?.isEqualToShiur(shiur) ?? false
        {
            return CGFloat(self.downloadShiurProcess?.downloadProgress ?? 0.0)*100
        }
        else{
            return 0
        }
    }
    
    func savedLessonsLocalPath() -> [String]?
    {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
            print("mp3 urls:",mp3Files)
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            print("mp3 list:", mp3FileNames)
            return mp3FileNames
            
        } catch {
            print(error)
        }
        
        return nil
    }

}
