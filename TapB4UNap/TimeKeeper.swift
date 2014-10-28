//
//  TimeKeeper.swift
//  TapB4UNap
//
//  Created by Ken Ko on 21/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation

class TimeKeeper {

    let sleepStartedKey = "sleepStarted"
    let sleepEndedKey = "sleepEnded"
    let userDefaults:NSUserDefaults = NSUserDefaults(suiteName: "group.au.com.cweature.TapB4UNap")!

    func startSleep(date:NSDate) {
        userDefaults.setObject(date, forKey: sleepStartedKey)
        userDefaults.synchronize()
    }
    
    func cancelSleep() {
        userDefaults.removeObjectForKey(sleepStartedKey)
        userDefaults.synchronize()
    }
    
    func endSleep(date:NSDate) {
        userDefaults.setObject(date, forKey: sleepEndedKey)
        userDefaults.synchronize()
    }
    
    func getSleepStartDate() -> NSDate? {
        return userDefaults.objectForKey(sleepStartedKey) as NSDate?
    }

    func getSleepEndDate() -> NSDate? {
        return userDefaults.objectForKey(sleepEndedKey) as NSDate?
    }
    
    /* returns true when both start date and end date are recorded */
    func canSave() -> Bool {
        return getSleepStartDate() != nil && getSleepEndDate() != nil
    }
    
    /* returns true when a start date is recorded, but no end date is recorded */
    func isSleeping() -> Bool {
        return getSleepStartDate() != nil && getSleepEndDate() == nil
    }
    
    func reset() {
        userDefaults.removeObjectForKey(sleepStartedKey)
        userDefaults.removeObjectForKey(sleepEndedKey)
        userDefaults.synchronize()
    }
    
    func formattedTimeElapsedSleeping() -> String {
        let calendar:NSCalendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        let unitFlats = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
        let components = calendar.components(unitFlats, fromDate: getSleepStartDate()!, toDate: NSDate(), options: NSCalendarOptions.allZeros)
        let result = "\(components.hour)hr \(components.minute)min \(components.second)sec"
        println(result)
        return result
    }

}
