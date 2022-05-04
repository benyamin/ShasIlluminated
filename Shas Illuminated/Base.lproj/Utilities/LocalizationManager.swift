//
//  LocalizationManager.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 27/01/2021.
//  Copyright © 2021 Binyamin Trachtman. All rights reserved.
//

import Foundation

public class  LocalizationManager
{
    static public let sharedManager = LocalizationManager()

    lazy var localizedDictinoary:[String:String] = {
        
        if let path = Bundle.main.path(forResource: "localization_he", ofType: "json")
            ,let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        {
            let JsonResponse =  try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            
            if let localizedDictinoary = JsonResponse as? [String : String]
            {
                return localizedDictinoary
            }
        }
        return [String:String]()
    }()
    
    lazy var enDictionary:[String:String] = {
        
        var localizedDictinoary = [String:String]()
        
        for key in self.localizedDictinoary.keys {
            
            if let value = self.localizedDictinoary[key] {
                localizedDictinoary[value] = key
            }
        }
        
        return localizedDictinoary
    }()
    
    func localize(_ string:String) -> String {
        
        if ShasIlluminatedManager.sharedManager.selectedLanguage == .English {
            if let localizedString = self.enDictionary[string]{
                return localizedString
            }
            else{
                return string;
            }
        }
        else {
            if let localizedString = self.localizedDictinoary[string]{
                return localizedString
            }
            else{
                return string;
            }
        }
    }
}
