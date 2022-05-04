//
//  Dictionary+Extras.swift
//  LMTCoreKit
//
//  Created by Binyamin Trachtman on 5/23/16.
//  Copyright © 2016 Binyamin Trachtman. All rights reserved.
//

import Foundation

public extension Dictionary
{
    func stringForKey(_ key:String) -> String?
    {
        for (Key, Value) in self
        {
            if key == Key as? String
            {
                if Value is String
                {
                    return Value as? String
                }
                
                else
                {
                    return nil;
                }
            }
        }
        
        return "";
    }
    
    static func += <K, V> ( left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left.updateValue(v, forKey: k)
        }
    }
    
    mutating func addEntriesFromDictionary(_ dictionary:Dictionary)
    {
        for (key,value) in dictionary {
            self.updateValue(value, forKey:key)
        }
    }
    
    func JsonDispaly() -> String?
    {
        if let JSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            let JSONText = String(data: JSONData,
                                     encoding: .utf8)
            
            return JSONText

        }
        
        return nil
    }
}
