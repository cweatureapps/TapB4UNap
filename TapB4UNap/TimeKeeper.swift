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
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    func addSleepRecord(startSleepDate:NSDate) {
        userDefaults.setObject(startSleepDate, forKey: sleepStartedKey)
        userDefaults.synchronize()
    }
    
    func removeSleepRecord() {
        userDefaults.removeObjectForKey(sleepStartedKey)
        userDefaults.synchronize()
    }
    
    func sleepRecord() -> NSDate? {
        return userDefaults.objectForKey(sleepStartedKey) as NSDate?
    }
    
    func formattedTimeElapsedFromSleepRecordUntil(toDate:NSDate) -> String {
        var savedDate:NSDate? = self.sleepRecord()
        if (savedDate==nil) {
            return ""
        } else {
            let calendar:NSCalendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
            let unitFlats = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
            let components = calendar.components(unitFlats, fromDate: savedDate!, toDate: toDate, options: NSCalendarOptions.allZeros)
            let result = "\(components.hour)hr \(components.minute)min \(components.second)sec"
            println(result)
            return result
        }
    }
    
    
    /*
    func writeDateToPlistFile(date:NSDate?) {
        let data : Dictionary = ["value" : date ?? NSNull()]
        (data as NSDictionary).writeToFile(documentFilePath(), atomically: true)
    }
    
    private func documentFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectory = String(paths[0] as NSString)
        let filePath = documentDirectory + "data.plist"
        return filePath
    }
    */
}
