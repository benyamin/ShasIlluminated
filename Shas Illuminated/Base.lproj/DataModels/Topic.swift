//
//  Topic.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 23/12/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation

class Topic:DataObject
{
    var id:Int?
    var name:String?
    var url_key:String?
    var parent_id:Int?
    var parent:Topic?
    var children:[Topic]?
    var shiurs:[TorahShiur]?
    
    var shouldShowChildern = false
    
    override init() {
        super.init()
    }
    
    override init(dictionary: [String : Any]) {
        super.init()
        
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as? String
        self.url_key = dictionary["url_key"] as? String
        self.parent_id = dictionary["parent_id"] as? Int
        
        if let parentInfo =  dictionary["parent"] as? [String:Any]
        {
            self.parent = Topic.init(dictionary: parentInfo)
        }
        
        if let childrensInfo = dictionary["children"] as? [[String:Any]]
        {
            self.children = [Topic]()
            
            for childInfo in childrensInfo
            {
                let child = Topic.init(dictionary: childInfo)
                self.children?.append(child)
            }
        }
    }
    
    override func copy() -> Any
    {
        let topic = Topic()
        
        topic.id = self.id
        topic.name = self.name
        topic.url_key = self.url_key
        topic.parent_id = self.parent_id
        topic.parent = self.parent
        topic.children = self.children
        topic.shiurs = self.shiurs
        
        topic.shouldShowChildern = self.shouldShowChildern
        
        return topic
    }

}
