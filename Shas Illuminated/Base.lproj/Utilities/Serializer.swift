//
//  Serializer.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 11/01/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Serializer
{
    class func serlizedJsonDictoinryFromData(_ data:Data?) -> [String:Any]?
     {
         if data == nil
         {
             return nil
         }
         
         if let jsonRespnse = Serializer.serializeData(jsonData:data!)
         {
             var JsonDictinoary:[String:Any]!
             
             if jsonRespnse is [String:Any]
             {
                 JsonDictinoary = jsonRespnse as? [String:Any]
                 return JsonDictinoary
             }
             else if jsonRespnse is NSArray
             {
                 print("The received response is of type NSArray and was converted to a Dictionary in the TGSWebService class")
                 
                 let JsonArray:NSArray = jsonRespnse as! NSArray
                 JsonDictinoary = ["JsonResponse":JsonArray]
                 
                 return JsonDictinoary
             }
         }
         return nil
     }
    
    class func serializeData(jsonData:Data) -> AnyObject?
    {
        do {
            
            let JsonResponse:AnyObject? = try JSONSerialization.jsonObject(with: (jsonData), options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            
            return JsonResponse
            
        } catch {
            
            //Data after changing HTML escape chracters
            if let data = jsonData.dataAfterReplactingEscapeCharacters()
            {
                do {
                    
                    let JsonResponse:AnyObject? = try JSONSerialization.jsonObject(with: (data), options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
                    
                    return JsonResponse
                    
                } catch {
                    
                    let invalidDataString = String(data: jsonData, encoding: String.Encoding.utf8)
                    
                    #if DEBUG
                    print ("Invalid JSON Data:" + invalidDataString!)
                    #endif
                    
                    return nil
                    
                }
            }
            else{
                return nil
            }
            
        }
    }
}
