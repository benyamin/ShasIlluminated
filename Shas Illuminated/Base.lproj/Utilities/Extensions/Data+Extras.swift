//
//  Data+Extras.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 11/01/2020.
//  Copyright © 2020 Binyamin Trachtman. All rights reserved.
//

import Foundation

public extension Data
{
    func dataAfterReplactingEscapeCharacters() -> Data?
    {
        var dataString = String(data: self, encoding: String.Encoding.utf8)
        
        dataString = dataString?.stringAfterReplacingHtmlEscapeCharacters()
        
        let convertedData = dataString?.data(using: String.Encoding.utf8)
        
        return convertedData
    }
}
