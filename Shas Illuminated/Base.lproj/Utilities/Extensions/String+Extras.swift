//
//  String+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 10/12/15.
//  Copyright © 2015 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    static let localizedDictionary:[String:[String:String]] =
    {
        var dictionary = [String:[String:String]]()
        if let plistPath = Bundle.main.path(forResource: "localization", ofType: "plist")
       ,let localization = NSArray(contentsOfFile: plistPath) as? [[String:String]]
        {
            for localInfo in localization
            {
                if let key = localInfo["key"]
                {
                    dictionary[key] = localInfo
                }
            }
        }
       return dictionary
    }()
    
    func boolValue() -> Bool? {
        let trueValues = ["true", "yes", "1"]
        let falseValues = ["false", "no", "0"]
        
        let lowerSelf = self.lowercased()
        
        if trueValues.contains(lowerSelf) {
            return true
        } else if falseValues.contains(lowerSelf) {
            return false
        } else {
            return nil
        }
    }
    
    func rangesOfSubString(_ searchString:String, options: String.CompareOptions = [.caseInsensitive], searchRange:Range<Index>? = nil ) -> [Range<Index>]?
    {
        if let range = range(of: searchString, options: options, range:searchRange) {
            
            let nextRange = (range.upperBound ..< self.endIndex)
            return [range] + rangesOfSubString(searchString, searchRange: nextRange)!
        } else {
            return nil
        }
    }
    
    public func addAttribute(_ attribute:[String:Any], ToSubString subString:String, ignoreCase:Bool) -> NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: self)
        
        var subStringRange:NSRange!
        
        if ignoreCase == true
        {
            subStringRange = ( self.lowercased() as NSString).range(of:  subString.lowercased())
            
        }
        else{
            subStringRange = (self as NSString).range(of: subString)
        }
        
        attributedString.addAttribute(NSAttributedString.Key(rawValue: attribute["name"] as! String), value: attribute["value"] as Any, range: subStringRange)
        
        return attributedString
    }
    /*
    public func adStrikethrough() -> NSAttributedString
    {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
 */
    
    public func toDate(fromat:String!) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        dateFormatter.dateFormat = fromat
        let date = dateFormatter.date(from:self)
        
        return date!
    }
    
    public func confirmToRegex(_ regEx:String) -> Bool
    {
        let regexText = NSPredicate(format:"SELF MATCHES %@", regEx)
        let result = regexText.evaluate(with: self)
        
        return result
    }

    public func removeAllCharsExceptDigits() -> String{
        return self.replacingOccurrences(of: "[^0-9]", with: "", options:.regularExpression , range: nil)
        
    }
    public func withReplacedCharacters(_ characters: String, by separator: String) -> String {
        let characterSet = CharacterSet(charactersIn: characters)
        return components(separatedBy: characterSet).joined(separator: separator)
    }
    
    public func stringByReplacingFirstOccurrenceOfString(
        target: String, withString replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
    
    
    func htmlAttributedString() -> NSAttributedString?
    {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
            
            //NSStringEnumerationReverse
        } catch {
            return NSAttributedString()
        }
    }
    
    func htmlAttributedString(textDirection:String, fontSize:Float, color:String) -> NSAttributedString?
    {
        let text = ("<!DOCTYPE html><html dir=\"\(textDirection)\" lang=\"ar\"><head><meta charset=\"utf-8\"><font color=\"\(color)\" size=\"\(fontSize)>\"\(self)</font>")
     
        guard let data = text.data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
            
            //NSStringEnumerationReverse
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func isValidEmail() -> Bool {
        
        return self.confirmToRegex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    }
    
    func isValidPhone() -> Bool  {
        
       return self.confirmToRegex("^\\d{3}-\\d{3}-\\d{4}$")
    }
    
    func slice(from: String, to: String?) -> String? {
        
        if to != nil
        {
            return (range(of: from)?.upperBound).flatMap { substringFrom in
                (range(of: to!, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                    String(self[substringFrom..<substringTo])
                }
            }
        }
        else{
            if let index = self.range(of: from)?.upperBound
            {
                return String(self[index...])
            }

        }
        return nil
    }
    
    func matches(regex: String) -> [String]
    {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    mutating func trimmeLeadingSpaces()
    {
        var trimmed = self
        while trimmed.hasPrefix(" ") {
            trimmed = "" + trimmed.dropFirst()
        }
        self = trimmed
    }
 
    
    mutating func trimmeTrailingSpaces() {
        
        var trimmed = self
        while trimmed.hasSuffix(" ") {
            trimmed = "" + trimmed.dropLast()
        }
        self = trimmed
    }
    
    func trimmeSideSpaces() -> String
    {
        var trimmed = self
       trimmed.trimmeLeadingSpaces()
        trimmed.trimmeTrailingSpaces()
        
        return trimmed
    }
    
    func trimmeSpaces() -> String
    {
        let trimmed = self.replacingOccurrences(of: " ", with: "")
        
        return trimmed
    }
    
    func stringAfterReplacingHtmlEscapeCharacters() -> String
    {
        var htmlEscapeCharacters = [String:String]()
        htmlEscapeCharacters["&quot;"] =    "\""
        htmlEscapeCharacters["&amp;"] =     "&"
        htmlEscapeCharacters["&apos;"] =    "'"
        htmlEscapeCharacters["&lt;"] =      "<"
        htmlEscapeCharacters["&gt;"] =      ">"
        htmlEscapeCharacters["&#39;"] =      "'"
        
        
        var newString = self
        
        for key in htmlEscapeCharacters.keys
        {
            newString = newString.replacingOccurrences(of: key, with: htmlEscapeCharacters[key]!)
        }
        
        return newString
    }
    
    mutating func removeHtmlNodes()
    {
            var res = ""
            var count = 0
            for charecter in self {
                switch charecter {
                    
                case "<": count += 1
                break;
                    
                case ">": count -= 1
                break;
                    
                default:
                    if count == 0 {
                        res += String(charecter)
                    }
                    break;
                }
            }
            self = res
    }
    
    func localize() -> String
    {
        return LocalizationManager.sharedManager.localize(self)
    }
    
    func levenshteinDistanceScore(to string: String, ignoreCase: Bool = true, trimWhiteSpacesAndNewLines: Bool = true) -> Double {
        
        var firstString = self
        var secondString = string
        
        if ignoreCase {
            firstString = firstString.lowercased()
            secondString = secondString.lowercased()
        }
        if trimWhiteSpacesAndNewLines {
            firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
            secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let empty = [Int](repeating:0, count: secondString.count)
        var last = [Int](0...secondString.count)
        
        for (i, tLett) in firstString.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in secondString.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
            }
            last = cur
        }
        
        // maximum string length between the two
        let lowestScore = max(firstString.count, secondString.count)
        
        if let validDistance = last.last {
            return  1 - (Double(validDistance) / Double(lowestScore))
        }
        
        return 0.0
    }
    
    func contains(subString: String, ignoreCase:Bool) -> Bool
    {
        if ignoreCase
        {
            return self.range(of: subString, options: .caseInsensitive) != nil
        }
        else{
            return self.range(of: subString) != nil

        }
    }
    
    func isValidEmail(enteredEmail:String) -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
}

