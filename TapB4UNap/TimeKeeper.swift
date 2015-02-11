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
    let mostRecentSleepStartKey = "mostRecentSleepStart"
    let mostRecentSleepEndKey = "mostRecentSleepEnd"
    let userDefaults:NSUserDefaults = NSUserDefaults(suiteName: "group.au.com.cweature.TapB4UNap")!

    func startSleep(date:NSDate) {
        resetRecentSleepData()
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
        return userDefaults.objectForKey(sleepStartedKey) as! NSDate?
    }

    func getSleepEndDate() -> NSDate? {
        return userDefaults.objectForKey(sleepEndedKey) as! NSDate?
    }
    
    /* returns true when both start date and end date are recorded */
    func canSave() -> Bool {
        return getSleepStartDate() != nil && getSleepEndDate() != nil
    }
    
    /* returns true when a start date is recorded, but no end date is recorded */
    func isSleeping() -> Bool {
        return getSleepStartDate() != nil && getSleepEndDate() == nil
    }
    
    /* backup the most recent start and end dates, then remove original stored data */
    func reset() {
        userDefaults.setObject(getSleepStartDate(), forKey: mostRecentSleepStartKey)
        userDefaults.setObject(getSleepEndDate(), forKey: mostRecentSleepEndKey)
        userDefaults.removeObjectForKey(sleepStartedKey)
        userDefaults.removeObjectForKey(sleepEndedKey)
        userDefaults.synchronize()
    }
    
    func resetRecentSleepData() {
        userDefaults.removeObjectForKey(mostRecentSleepStartKey)
        userDefaults.removeObjectForKey(mostRecentSleepEndKey)
        userDefaults.synchronize()
    }
    
    func mostRecentSleepData() -> (startDate: NSDate? , endDate: NSDate?) {
        let mostRecentStartDate = userDefaults.objectForKey(mostRecentSleepStartKey) as! NSDate?
        let mostRecentEndDate = userDefaults.objectForKey(mostRecentSleepEndKey) as! NSDate?
        return (startDate: mostRecentStartDate, endDate: mostRecentEndDate)
    }
    
    class func formattedTimeFromDate(fromDate:NSDate, toDate:NSDate) -> String {
        if (fromDate.compare(toDate).rawValue > 0) {
            return "From Date was after To Date"
        } else {        
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components( .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: fromDate, toDate: toDate, options: NSCalendarOptions.allZeros)
            let result = "\(components.hour)hr \(components.minute)min \(components.second)sec"
            println(result)
            return result
        }
    }



}
