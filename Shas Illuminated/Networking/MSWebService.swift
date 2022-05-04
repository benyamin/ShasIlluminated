//
//  MSWebService.swift
//  MikvehIsrael
//
//  Created by Binyamin Trachtman on 23/06/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class MSWebService: NSObject ,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var runningTask: URLSessionDataTask!
    
    var runningOperation:WebServiceOperation!
    
    func runRequest(_ request:BaseRequest,onStart:@escaping (() -> Void), onComplete:@escaping (_ dictionary:[String:Any], _ error:NSError?) -> Void , onFaile:@escaping (_ object:NSObject, _ error:NSError) -> Void)
    {
        let webServiceOperation = WebServiceOperation()
        
        webServiceOperation.request = request
        webServiceOperation.onStart = onStart
        webServiceOperation.onComplete = onComplete
        webServiceOperation.onFaile = onFaile
        
        self.runServiceOperation(webServiceOperation)
    }
    
    func runServiceOperation(_ serviceOperation:WebServiceOperation)
    {
        self.runningOperation = serviceOperation
        
        self.runningOperation.onStart!()
        
        print("request:\(serviceOperation.request.url!.absoluteString)")
        
        if serviceOperation.request.timeoutInterval == nil
        {
            serviceOperation.request.timeoutInterval = 35.0
        }
        
        do {
            
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            
            self.runningTask = session.dataTask(with: serviceOperation.request.getUrlRequest()!) {data, response, error in
                
                if data == nil
                {
                    DispatchQueue.main.async {
                        
                        if let cashedResponseDictioanry = self.cashedRequestResponse(request: serviceOperation.request)
                        {
                            self.onComplete(cashedResponseDictioanry, nil)
                        }
                        else{
                            self.task(self.runningTask, didFailWithError: error as NSError?, description:nil)
                        }
                    }
                    return
                }
                
                serviceOperation.request.responseData = String(data: data!, encoding: String.Encoding.utf8)
                
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if httpResponse.statusCode == 200 //success
                        {
                            self.finished(withData: data, error: error)
                        }
                        else{
                            
                            let statusError = NSError(domain: "MSDomain", code: httpResponse.statusCode, userInfo: nil)
                            
                            self.task(self.runningTask, didFailWithError: statusError, description:nil)
                        }
                    }
                    else{
                        
                        self.task(self.runningTask, didFailWithError: error as NSError?, description:nil)
                    }
                }
            }
            
            runningTask.resume()
        } catch {
            
            DispatchQueue.main.async {
                
                self.finished(withData: nil, error: nil)
                
            }
        }
        
    }
    
    func dataForCertPath(cerName:String) -> Data?
    {
        if let localCerfile_der = Bundle.main.path(forResource: cerName, ofType: "cer")
        {
            if let certData = NSData(contentsOfFile: localCerfile_der)
            {
                let certDataRef = certData as CFData
                
                if let cert = SecCertificateCreateWithData(nil, certDataRef)
                {
                    let localData = SecCertificateCopyData(cert)
                    
                    return localData as Data
                }
            }
        }
        
        return nil
    }
    
    func responseData(data:Data?) -> [String:Any]?
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
            }
            else if jsonRespnse is NSArray
            {
                
                print("The received response is of type NSArray and was converted to a Dictionary in the TGSWebService class")
                
                let JsonArray:NSArray = jsonRespnse as! NSArray
                JsonDictinoary = ["JsonResponse":JsonArray]
            }
            
            #if DEBUG
                print("Response: JsonDictinoary:\(JsonDictinoary!)")
            #endif
            
            return JsonDictinoary
        }
        else
        {
            return nil
        }
    }
    
    func  finished(withData data:Data?,  error: Error? )
    {
        if data == nil
        {
            self.task(runningTask, didFailWithError: error as NSError?, description: nil)
            return
        }
        
       // self.runningTask.cancel()
        // Throwing an error on the line below (can't figure out where the error message is)
        
        if self.runningOperation == nil
        {
            return
        }
        
        if self.runningOperation.request.requiredResponseType == .JSON
        {
            if let JsonDictinoary = Serializer.serlizedJsonDictoinryFromData(data)
            {
                DispatchQueue.global().async {
                    
                    #if DEBUG
                        print("Response: JsonDictinoary:\(JsonDictinoary)")
                    #endif
                }
                
                    if let serviceName = runningOperation.request.serviceName
                        , serviceName.count > 0
                    {
                        let responseString = String(data: data!, encoding: .utf8)!
                        let fileName = "\(serviceName.replacingOccurrences(of: "/", with: "_"))_responseString"
                        FileManager.write(text: responseString, to: fileName, ofType: "json")
                    
                    self.onComplete(JsonDictinoary, nil)
                }
                else {
                    
                    self.task(nil, didFailWithError: nil, description: nil)
                }
                
            }
            else{
                self.task(runningTask, didFailWithError: nil, description:nil)
            }
        }
        else if self.runningOperation.request.requiredResponseType == .XML
        {
            do {
                let xmlDoc = try AEXMLDocument(xmlData: data!)
                self.onComplete(["xmlDoc":xmlDoc], nil)
                
            } catch _ {
                self.task(runningTask, didFailWithError: nil, description:nil)
            }
            
            //self.serializeXMLData(data!)
        }
        else if self.runningOperation.request.requiredResponseType == .HTML
        {
            if let string = String(data: data!, encoding: .utf8)
            {
                self.onComplete(["htmlContent":string], nil)
            }
            else{
                self.task(nil, didFailWithError: nil, description: nil)
            }
            
        }
        
    }
    
 
    
    func cashedRequestResponse(request:BaseRequest) -> [String:Any]?
    {
        //Check for chahs response
        if let serviceName = request.serviceName
            , serviceName.count > 0
        {
             let fileName = "\(serviceName.replacingOccurrences(of: "/", with: "_"))_responseString"
            
            if let savedJsonString = FileManager.readFromFile(fileName, ofType: "json")
                ,let jsonData = savedJsonString.data(using: .utf8)
            {
               if let JsonDictinoary = Serializer.serlizedJsonDictoinryFromData(jsonData)
                {
                    return JsonDictinoary
                }
            }
        }
        return nil
    }
    
    func parseError(_ errorCode:Int, actionResult:[String:Any]) -> NSError
    {
        
        let  resultMessage = (actionResult["resultMessage"] as! [String:Any])
        
        var userInfo = [String:Any]()
        userInfo["data"] = resultMessage["data"]
        userInfo["messageId"] = resultMessage["messageId"]
        userInfo["data"] = resultMessage["localizedMessage"]
        userInfo[NSLocalizedDescriptionKey] = resultMessage["localizedMessage"]
        
        let error = NSError(domain: "MSDomain", code: errorCode, userInfo: userInfo)
        
        return error
    }
    

    
  
    
    func task(_ task: URLSessionDataTask?, didFailWithError optinalError: NSError?, description:String?)
    {
        if self.runningOperation != nil
        {
            var composedError:NSError!
            
            if let error = optinalError
            {
                var errorDescription = ("st_error_\(error.code)")//.localize()
                
                if description != nil
                {
                    errorDescription = description!
                }
                //If the error is not localized
                if errorDescription.hasPrefix("st_")
                {
                    errorDescription = "st_default_error_message"//.localize()
                }
                
                var userInfo = error.userInfo
                userInfo["Description"] = errorDescription
                
                composedError = NSError(domain: "MSDomain", code: error.code, userInfo: userInfo)
            }
            else{
                
                let userInfo = ["Description": "st_default_error_message"]
                composedError = NSError(domain: "MSDomain", code: -1, userInfo: userInfo)
                
            }
            
            DispatchQueue.main.async {
                
                if self.runningOperation != nil
                {
                    self.onFaile(self.runningOperation.request, composedError)
                }
                
                self.runningOperation = nil
            }
        }
    }
    
    func cancelRequest(_ request:BaseRequest)
    {
        if  self.runningOperation != nil && runningOperation.request == request
        {
            print ("cancel request:\(request.serviceName)")
            
            self.runningTask.cancel()
            
            self.runningOperation = nil
        }
    }
    
    func onComplete(_ jsonDictionary:[String:Any],_ error:NSError?)
    {
        if self.runningOperation != nil
        {
            self.runningOperation.onComplete!(jsonDictionary, error)
        }
    }
    
    func onFaile(_ object:NSObject, _ error:NSError)
    {
        if self.runningOperation != nil
        {
            self.runningOperation.onFaile!(object, error)
        }
    }
}

