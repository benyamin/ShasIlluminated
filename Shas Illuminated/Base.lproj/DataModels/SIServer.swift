//
//  SIServer.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/09/2021.
//  Copyright © 2021 Binyamin Trachtman. All rights reserved.
//

import Foundation

class SIServer:NSObject {
    
    var dataTask:URLSessionDataTask?
    
    static let sharedSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration)
    }()
    
    func sendRequestMethod(methodName:String, methodType:String, parameters:[String:Any], timeoutInterval:Double? = nil, success:@escaping ([String : Any]) -> Void, failure:@escaping (NSError) -> Void) {
               
        self.runRequest(methodName: methodName, methodType:methodType, requestParameters: parameters, timeoutInterval:timeoutInterval ?? 180, onSuccess:success, onFailure:failure)
        
    }
    
    private func runRequest(methodName:String, methodType:String, requestParameters:[String:Any], timeoutInterval:Double, onSuccess: @escaping(([String : Any]) -> Void), onFailure: @escaping((NSError) -> Void)) {
      
            let apiPath = "https://shasilluminated.org/api/\(methodName)"
        
            guard let serviceUrl = URL(string: apiPath) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = methodType
                
        request.setValue("Application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestParameters, options: []) else {
                return
            }
        
            request.httpBody = httpBody
            request.timeoutInterval = timeoutInterval
            self.dataTask = SIServer.sharedSession.dataTask(with: request) { (data, response, error) in
                self.dataTask = nil
                if error != nil{
                    DispatchQueue.main.async {
                        onFailure(error! as NSError)
                    }
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        if let dataInfo = json as? [String:Any]{
                            DispatchQueue.main.async {
                                
                              
                                onSuccess(dataInfo)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            let parseError = NSError(domain:"SIServer", code:-1, userInfo:[NSLocalizedDescriptionKey:  "JSONSerializationNotValid"])
                            onFailure(parseError)
                        }
                    }
                }
            }
            self.dataTask?.resume()
    }
    
    func cancel(){
        self.dataTask?.cancel()
    }
}
