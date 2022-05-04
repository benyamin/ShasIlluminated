//
//  ShasIlluminatedManager.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 12/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import Foundation
import UIKit

public enum Language:String {
    case English = "English"
    case Hebrew = "Hebrew"
}

public class ShasIlluminatedManager
{
    static public let sharedManager =  ShasIlluminatedManager()
    
    var shasMaggideiShiours:[MaggidShiur]?
    var torahMaggideiShiours:[MaggidShiur]?
    var torahTopis:[Topic]?
    
    var selectedLanguage:Language! {
        get{
            if let savedSelectedLanguage = UserDefaults.standard.object(forKey: "savedSelectedLanguage") as? String {
                return Language(rawValue: savedSelectedLanguage)
            }
            else{
                return .English
            }
        }
        set (language){
            UserDefaults.standard.setValue(language.rawValue, forKey: "savedSelectedLanguage")
            UserDefaults.standard.synchronize()
        }
    }
    
    lazy var plyerView:BTPlayerView? = {
        
        let plyerView =  UIView.viewWithNib("SIPlayerView") as? BTPlayerView
        return plyerView
    }()
    
    var sdarim:[Seder]?{
        didSet
        {
            self.masechtot = [Masechet]()
            
            if self.sdarim != nil
            {
                for seder in self.sdarim!
                {
                    if let sederMasechtot = seder.masechtot
                    {
                        self.masechtot?.append(contentsOf: sederMasechtot)
                        
                    }
                }
            }
        }
    }
    
    var masechtot:[Masechet]?
    var todaysShiurim:[Shiur]?
    var sdarimWithSavedShiurs:[Seder]?
    
    var maggidiShiurWithSavedShiurs:[MaggidShiur]?
    
    lazy var cycleStaretDate:Date = {
        
        var numberOfDaysInCycle = 2711
        
        var cycleStaretDate = Date.dateFromString("2012-08-03", withFormat: "yyy-MM-dd")!
        
        while cycleStaretDate.numberOfDaysToDate(Date()) > numberOfDaysInCycle
        {
            cycleStaretDate = cycleStaretDate.dateByAddingDays(numberOfDaysInCycle)
        }
        
        return cycleStaretDate
        
    }()
    
    
    var todaysMaschet:Masechet?{
        
        get{
            let st = Date().stringWithFormat("yyyy-MM-dd") + " 00:00"
            let startDayDate = Date.dateFromString(st, withFormat:"yyyy-MM-dd HH:mm")
            
            return self.maschetForDate(startDayDate!)
        }
    }
    
    var todaysPage:Daf?{
        
        get{
            let st = Date().stringWithFormat("yyyy-MM-dd") + " 00:00"
            let startDayDate = Date.dateFromString(st, withFormat:"yyyy-MM-dd HH:mm")
            
            return self.pageForDate(startDayDate!, addOnePage:true)
        }
    }
    
    func updateSdarimWithSavedShiurs()
    {
        self.sdarimWithSavedShiurs = nil
        
        if self.sdarim != nil
        {
            var sdarimWithSavedShiurs = [Seder]()
            for seder in self.sdarim!
            {
                if let masechtotWithSavedLessons = seder.getMasechtotWithSavedLessons()
                {
                    if let sederWithSavedMasechtot = seder.copy() as? Seder
                    {
                        sederWithSavedMasechtot.masechtot = masechtotWithSavedLessons
                        sdarimWithSavedShiurs.append(sederWithSavedMasechtot)
                    }
                }
            }
            
            if sdarimWithSavedShiurs.count > 0
            {
                self.sdarimWithSavedShiurs = sdarimWithSavedShiurs
            }
        }
    }
    
    func updateMaggidiShiurWithSavedShiurs()
    {
        self.maggidiShiurWithSavedShiurs = nil
        
        if self.shasMaggideiShiours != nil
        {
            
            if let savedLessonsPath = DownloadManager.sharedManager.savedLessonsLocalPath()
            {
                var savedMaggidShioursIds = [String]()
                
                for lessonPath in savedLessonsPath
                {
                    if let maggidShiourId = lessonPath.slice(from: "lecturer_id", to: "_masechta_id")
                    {
                        if savedMaggidShioursIds.contains(maggidShiourId) == false
                        {
                            savedMaggidShioursIds.append(maggidShiourId)
                        }
                    }
                        /*
                    else if let maggidShiourId = lessonPath.slice(from: "lecturer_id", to: "_topic_id")
                    {
                        if savedMaggidShioursIds.contains(maggidShiourId) == false
                        {
                            savedMaggidShioursIds.append(maggidShiourId)
                        }
                    }
 */
                }
                
                self.maggidiShiurWithSavedShiurs = [MaggidShiur]()
                
                for maggidShoiur in self.shasMaggideiShiours!
                {
                    for savedMaggidShioursId in savedMaggidShioursIds
                    {
                        if "\(maggidShoiur.id ?? 0)" == savedMaggidShioursId
                        {
                            self.maggidiShiurWithSavedShiurs?.append(maggidShoiur)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func maschetForDate(_ date:Date) -> Masechet?
    {
        let pageNumber = self.pageNumberForDate(date)
        
        var pageSum = 0
        
        for maschet in self.masechtot ?? [Masechet]()
        {
            if let maschetNumberOfPages = maschet.numberOfPages
            {
                pageSum = pageSum + maschetNumberOfPages
                
                if pageSum > pageNumber
                {
                    return maschet
                }
            }
          
        }
        return nil
    }
    
    func pageForDate(_ date:Date, addOnePage:Bool) -> Daf?
    {
        let pageNumber = self.pageNumberForDate(date)
        
        var pageSum = 0
        
        for maschet in self.masechtot ?? [Masechet]()
        {
            if let maschetNumberOfPages = maschet.numberOfPages
            {
                pageSum = pageSum + maschetNumberOfPages
                
                if pageSum > pageNumber
                {
                    var pageIndex = maschetNumberOfPages - (pageSum - pageNumber)
                    if addOnePage
                    {
                        pageIndex += 1
                    }
                    let page = Daf(index: pageIndex)
                    
                    return page
                }
            }
        }
        return nil
    }
    
    func pageNumberForDate(_ date:Date) -> Int
    {
        let numberOfPagesInTalmud = 2711
        
        let daysBetweenDates = Date.daysBetweenDates(firstDate: self.cycleStaretDate, secondDate: date)
        
        if daysBetweenDates >= 0
        {
            let pageNumber = daysBetweenDates % numberOfPagesInTalmud
            return pageNumber
        }
        else{
            
            let pageNumber = numberOfPagesInTalmud - ((-1 * daysBetweenDates) % numberOfPagesInTalmud)
            return pageNumber
        }
    }
    
    
    func todaysPageDisplay() -> String
    {
        
        var todaysPageDisplay = "מסכת"
        todaysPageDisplay += " " + self.getTodaysMasechetName()
       
        
        if let todaysPageSymbol =  self.todaysPage?.symbol
        {
            todaysPageDisplay += " " + "דף"
            todaysPageDisplay += " " + todaysPageSymbol
        }
        
        return todaysPageDisplay
    }
    
    func getTodaysMasechetName() -> String
    {
        if let maschet = self.todaysMaschet
            , let page = self.todaysPage
        {
            return self.getMasechetNameforMasechet(maschet, page: page)
        }
        return ""
    }
    
    func getCurrentDateDisplay() -> String
    {
        if let appleLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String]
            , let local = appleLanguages.first
        {
            var calendar = Calendar.hebrew
            if local != "he_IL"
            {
                calendar = Calendar.current
            }
            
            return calendar.longDateDisplay(from: Date(), local: local)
        }
        else{
            return Calendar.hebrew.longDateDisplay(from: Date(), local: "he_IL")
        }
    }
    
    func getMasechetNameforMasechet(_ maschet:Masechet, page:Daf) -> String
    {
        var maschetName = maschet.hebrewName
        
        if maschetName == "מעילה"
            , let pageIndex = page.daf
        {
            if pageIndex >= 21
                && pageIndex <= 24
            {
                maschetName = "קנים"
            }
                
            else if pageIndex >= 25
                && pageIndex <= 32
            {
                maschetName = "תמיד"
            }
                
            else if pageIndex >= 33
                && pageIndex <= 36
            {
                maschetName = "מידות"
            }
        }
        
        return maschetName!
    }
    
    func getMasechetById(_ id:Int) -> Masechet?
    {
        if self.masechtot == nil
        {
            return nil
        }
        else{
            for masecht in self.masechtot!
            {
                if masecht.id == id
                {
                    return masecht
                }
            }
        }
        return nil
    }
    
    func getSpeakerById(_ speakerId:Int) -> MaggidShiur?
    {
        if let maggideiShiours = self.torahMaggideiShiours
        {
            for maggidShiur in maggideiShiours
            {
                if maggidShiur.id == speakerId
                {
                    return maggidShiur
                }
            }
        }
        
        if let maggideiShiours = self.shasMaggideiShiours
        {
            for maggidShiur in maggideiShiours
            {
                if maggidShiur.id == speakerId
                {
                    return maggidShiur
                }
            }
        }
        
        return nil
    }
    
    func getTopicById(_ topicId:Int) -> Topic? {
        
        if let torahTopis = self.torahTopis {
            
            if let topic = torahTopis.first(where: { $0.id == topicId }) {
                return topic
            }
            else {
                for topic in torahTopis{
                    if let chiledTopic = topic.children?.first(where: { $0.id == topicId }) {
                        return chiledTopic
                    }
                }
            }
        }
        
        return nil
    }
}
