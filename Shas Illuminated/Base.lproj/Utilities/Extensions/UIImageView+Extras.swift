//
//  UIImageView+Extras.swift
//
//
//  Created by Binyamin Trachtman on 10/12/15.
//  Copyright © 2015 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

private let cashedImaegsFileName = "cashedImages"

public extension UIImageView
{
    func image(name imageName:String)
    {
        if imageName.hasPrefix("http")
        {
            if let imagePath = URL(string: imageName)
            {
                let imageResource = ImageResource(downloadURL: imagePath, cacheKey: imageName)
                
                self.kf.setImage(with: imageResource, placeholder: self.image, options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
        else{
            self.image = UIImage(named: imageName)
        }
    }
    
    func image(name imageName:String, useCashe cahsed:Bool)
    {
        if imageName.hasPrefix("http")
        {
            if let imageUrl = URL(string: imageName)
            {
                //Check if the image is already saved in the doucuments
                let pathComponents = imageUrl.pathComponents
                if pathComponents.count > 0
                {
                    var imageName = ""
                    for pathComponent in pathComponents
                    {
                        imageName += pathComponent
                    }
                    
                    if cahsed == true, let savedImage = self.savedImageNamed(imageName)
                    {
                        self.image = savedImage
                    }
                    else{
                        self.kf.setImage(with: imageUrl, placeholder: self.image, options: nil, progressBlock: nil) { (image, error, cacheType, imageUrl) in
                            
                            //If cashed, save the image for future use
                            if cahsed
                            {
                                if imageName != ""
                                {
                                    //self.saveImage(self.image!, withName: imageName)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        else{
            self.image = UIImage.imageWithName(imageName)
        }
    }
    
    
    func image(name imageName: String, placeholder: String)
    {
        self.kf.cancelDownloadTask()

        let placeholderImage = UIImage.imageWithName(placeholder)
        
        if imageName.hasPrefix("http")
        {
            let url = URL(string: imageName)
            self.kf.setImage(with: url, placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        else{
            
            self.image = placeholderImage
            
            self.image = UIImage.imageWithName(imageName)
        }
    }
    
    /*
    func saveImage(_ image:UIImage, withName imageName:String)
    {
        let fileManager = FileManager.default
        var pathSufix = "/" + cashedImaegsFileName
        var filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(pathSufix)
       
        //Create cashedImages folder if not exists
        if fileManager.fileExists(atPath: filePath) == false
        {
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Couldn't create document directory")
            }
        }
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            var fileSize = attr[FileAttributeKey.size] as! UInt64
            
            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
            
            //if file size is bigger than 100000 KB clear cashed Images folder
            if fileSize > 100000
            {
               self.removeCashedImages()
            }
        } catch {
            print("Error: \(error)")
        }
        
        //Save the iamge to the cashedImages folder
        pathSufix = pathSufix + "/" + imageName
        filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(pathSufix)
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: filePath as String, contents: imageData, attributes: nil)
    }
    */
    
    func removeCashedImages()
    {
        let fileManager = FileManager.default
        let pathSufix = "/" + cashedImaegsFileName
        let cahsedImagesFolderPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(pathSufix)
        
        do {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(cahsedImagesFolderPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    let filePathName = "\(cahsedImagesFolderPath)/\(fileName)"
                    try fileManager.removeItem(atPath: filePathName)
                }
                
                let files = try fileManager.contentsOfDirectory(atPath: "\(cahsedImagesFolderPath)")
                print("all files in cache after deleting images: \(files)")
            
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func savedImageNamed(_ imageName:String) -> UIImage?
    {
        let fileManager = FileManager.default
        let pathSufix = "/" + cashedImaegsFileName + "/" + imageName
        
        let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let imagePath = directoryPath.appendingPathComponent(pathSufix)
        
        if fileManager.fileExists(atPath: imagePath){
            let savedImage = UIImage(contentsOfFile: imagePath)
            return savedImage
        }else{
            return nil
        }
    }
    
    /*
    func createDir(dirName: String) {
        
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent(dirName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
     try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
     } catch {
     NSLog("Couldn't create document directory")
     }
     }
     NSLog("Document directory is \(filePath)")
     }
     }
     */
    
    
    /*
    func saveImageForUrl(url:URL)
    {
        let pathComponents = url.pathComponents
        if pathComponents.count > 0
        {
            let fileName  = pathComponents.last!
            
            let documentsDirectoryURL = try! FileManager().url(for:
                .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:
                true)
            
            let fileURL = documentsDirectoryURL.appendingPathComponent(fileName)
            
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    if fileName.hasSuffix("png")
                    {
                        try UIImagePNGRepresentation(self.image!)!.write(to: fileURL)
                        print("Image Added Successfully")
                    }
                } catch {
                    print(error)
                }
            } else {
                print("Image Not Added")
            }
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
        
        //let success = saveImage(image: UIImage(named: "image.png")!)
    }
    */
}

