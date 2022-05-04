//
//  MSRequest.swift
//  PortalHadafHayomi
//
//  Created by Binyamin on 05/12/2017.
//  Copyright © 2017 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

open class MSRequest: BaseRequest
{
    override open func buildUrlPath()
    {
        if (baseUrl != nil)
        {
            var urlPath = "\(baseUrl!)"
            if serviceName != nil && serviceName != ""
            {
                 urlPath += "/\(serviceName!)"
            }
            
            if (params != nil)
            {
                if self.httpMethod == GET
                {
                    urlPath += "?"
                    
                    let keys = [String] (params.keys)
                    
                    for key in keys
                    {
                        var value = String(describing: params[key]!)
                        
                        if value.hasPrefix("Optional(")
                        {
                            value = value.replacingOccurrences(of: "Optional(", with: "")
                            value = String(value.dropLast())
                        }
                        
                        urlPath += ("\(key)=\(value)")
                        
                        if key != keys.last
                        {
                            urlPath += "&"
                        }
                    }
                    
                    urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                }
                else if self.httpMethod == POST
                {
                    let JSONData = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))
                    
                    let JsonSting = NSString(data: JSONData!,encoding: String.Encoding.ascii.rawValue)
                    
                    print ("POST Body:\(JsonSting!)")
                    
                    self.httpBody = JSONData
                }
            }
            
            url = Foundation.URL(string: urlPath)
            
            if url != nil
            {
                _ = self.setHeader()
            }
            else
            {
                print("URL path is invalid:\(urlPath)")
            }
        }
    }
    
    internal func setHeader() -> [String:String]
    {
        var headerFields = [String:String]()
        
        if self.requiredResponseType == .JSON
        {
            headerFields["Content-Type"] = "application/json; charset=utf-8"
            headerFields["Accept-Encoding"] = "gzip, deflate, br"
        }
        
        return headerFields
    }
    
    /*
     Accept: application/json, text/plain,
     Accept-Encoding: gzip, deflate, br
     Accept-Language: en-US,en;q=0.9,he;q=0.8
     Connection: keep-alive
     Content-Length: 60
     Content-Type: application/json;charset=UTF-8
     Cookie: _ga=GA1.2.1819778983.1563048850; __smVID=810ecda18a7866d04dbdcc8df837047f0b0adf7dc6a2de6b6693315685227c4a; __smScrollBoxShown=Sun%20Nov%2024%202019%2000:26:34%20GMT+0200%20(Israel%20Standard%20Time); _gid=GA1.2.599914220.1574708327; XSRF-TOKEN=eyJpdiI6IkhNVTlKeWszTzJHZmhRR1wvNUMxelN3PT0iLCJ2YWx1ZSI6ImxENTdPOUdpbFI4SUdYUTNXamlqQlNPZGk3SStMRTJodDN4dmh0QlBwK2RKUmRENkZ0Wkk0UHJLbG93VENrSDciLCJtYWMiOiJlZGQ1NWQwODdkOGRkZjZmZjlhNGNhMzI5NzU1ZDhjNTVjMGE2YzFkMDAxNzJiNmRjYjcwZDdmMmI2NjgyOTJlIn0%3D; shas_illuminated_session=eyJpdiI6Ik8zQ284TXZQUDFxcFhiUjhMRnZjaVE9PSIsInZhbHVlIjoiMG5jUWhNRXZ1dHNPQ3QzK05aSkQ5dFBBNk1YMmRGQTM5WnFDVmhLWFBmaGJyQjdMbUFcL1g4NElwc2RtQU9SYjMiLCJtYWMiOiJlNjE0NmViZmNlNWVmZTcwYjdkODM5YWMwOWJhOWQ0YmI2NTg1NDA5MGFiNGMzMzI4YTUxMjRjNTc1YWJhZTdkIn0%3D; __smToken=ezaIdY3pBqw8gP11gNnJxGGW; __smListBuilderShown=Tue%20Nov%2026%202019%2019:51:57%20GMT+0200%20(Israel%20Standard%20Time)
     Host: www.shasilluminated.org
     Origin: https://www.shasilluminated.org
     Referer: https://www.shasilluminated.org/contact-us
     Sec-Fetch-Mode: cors
     Sec-Fetch-Site: same-origin
     User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36
     X-CSRF-TOKEN: siZQJwmdpZDvbwMes4tgWbNEaCToLhtDDEdTQDzR
     X-Requested-With: XMLHttpRequest
     X-XSRF-TOKEN: eyJpdiI6IkhNVTlKeWszTzJHZmhRR1wvNUMxelN3PT0iLCJ2YWx1ZSI6ImxENTdPOUdpbFI4SUdYUTNXamlqQlNPZGk3SStMRTJodDN4dmh0QlBwK2RKUmRENkZ0Wkk0UHJLbG93VENrSDciLCJtYWMiOiJlZGQ1NWQwODdkOGRkZjZmZjlhNGNhMzI5NzU1ZDhjNTVjMGE2YzFkMDAxNzJiNmRjYjcwZDdmMmI2NjgyOTJlIn0=
     */
}
