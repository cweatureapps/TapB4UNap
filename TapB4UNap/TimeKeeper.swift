//
//  TimeKeeper.swift
//  TapB4UNap
//
//  Created by Ken Ko on 21/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//
//  This class interacts with the userDefaults to allow sharing data between the extension and the app.
//

import Foundation

class TimeKeeper {

    private let sleepStartedKey = "sleepStarted"
    private let sleepEndedKey = "sleepEnded"
    private let mostRecentSleepStartKey = "mostRecentSleepStart"
    private let mostRecentSleepEndKey = "mostRecentSleepEnd"
    private let userDefaults:NSUserDefaults = NSUserDefaults(suiteName: "group.com.cweatureapps.TapB4UNap")!

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
    
    private func getSleepStartDate() -> NSDate? {
        return userDefaults.objectForKey(sleepStartedKey) as! NSDate?
    }

    private func getSleepEndDate() -> NSDate? {
        return userDefaults.objectForKey(sleepEndedKey) as! NSDate?
    }
    
    func sleepSample() -> SleepSample {
        return SleepSample(startDate:  getSleepStartDate() , endDate:  getSleepEndDate())
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
    
    func mostRecentSleepData() -> SleepSample? {
        let mostRecentStartDate = userDefaults.objectForKey(mostRecentSleepStartKey) as! NSDate?
        let mostRecentEndDate = userDefaults.objectForKey(mostRecentSleepEndKey) as! NSDate?
        if let mostRecentStartDate = mostRecentStartDate, mostRecentEndDate = mostRecentEndDate {
            return SleepSample(startDate: mostRecentStartDate, endDate: mostRecentEndDate)
        } else {
            return nil
        }
    }

}
