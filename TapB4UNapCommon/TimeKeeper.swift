//
//  TimeKeeper.swift
//  TapB4UNap
//
//  Created by Ken Ko on 21/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation

/// This class interacts with the userDefaults to allow sharing data between the extension and the app.
class TimeKeeper {

    private let sleepStartedKey = "sleepStarted"
    private let sleepEndedKey = "sleepEnded"
    private let mostRecentSleepStartKey = "mostRecentSleepStart"
    private let mostRecentSleepEndKey = "mostRecentSleepEnd"
    private let userDefaults: NSUserDefaults = SettingsManager.sharedUserDefaults

    /**
     Saves the sleep start with the given value.
     - parameter date: The date value of when sleep started
     */
    func startSleep(date: NSDate) {
        resetRecentSleepData()
        userDefaults.setObject(date, forKey: sleepStartedKey)
        userDefaults.synchronize()
    }

    /**
     Saves the sleep end with the given value.
     - parameter date: The date value of when sleep ended
     */
    func endSleep(date: NSDate) {
        userDefaults.setObject(date, forKey: sleepEndedKey)
        userDefaults.synchronize()
    }

    /**
     Saves the sleep end to the given value, but only if there is currently no sleep end value (i.e. will not overwrite the existing value).
     - parameter date: The date value of when sleep ended
     */
    func endSleepIfNeeded(date: NSDate) {
        if let sleepSample = sleepSample() where sleepSample.endDate == nil {
            endSleep(date)
        }
    }

    /**
     The current sleep sample.
     - returns: The current sleep sample. Returns nil if both start and end dates are nil.
     */
    func sleepSample() -> SleepSample? {
        return sleepSampleForKeys(startKey:sleepStartedKey, endKey:sleepEndedKey)
    }

    /**
     Backup the sleep data. The last backed up value can be retrieved again `mostRecentSleepSample()`.
     - parameter sleepSample: The SleepSample to backup.
     */
    func backupSleepData(sleepSample: SleepSample) {
        userDefaults.setObject(sleepSample.startDate, forKey: mostRecentSleepStartKey)
        userDefaults.setObject(sleepSample.endDate, forKey: mostRecentSleepEndKey)
    }

    /**
     Removes the saved values for sleep start and sleep end.
     */
    func resetSleepData() {
        userDefaults.removeObjectForKey(sleepStartedKey)
        userDefaults.removeObjectForKey(sleepEndedKey)
        userDefaults.synchronize()
    }

    private func resetRecentSleepData() {
        userDefaults.removeObjectForKey(mostRecentSleepStartKey)
        userDefaults.removeObjectForKey(mostRecentSleepEndKey)
        userDefaults.synchronize()
    }

    /**
     The last saved recent sleep sample, as saved by `backupSleepData(sleepSample)`
     - returns: The most recently backed up sleep sample. Returns nil if both start and end dates are nil.
     */
    func mostRecentSleepSample() -> SleepSample? {
        return sleepSampleForKeys(startKey:mostRecentSleepStartKey, endKey:mostRecentSleepEndKey)
    }


    private func sleepSampleForKeys(startKey startKey: String, endKey: String) -> SleepSample? {
        let startDate = userDefaults.objectForKey(startKey) as! NSDate?
        let endDate = userDefaults.objectForKey(endKey) as! NSDate?
        if startDate == nil && endDate == nil {
            return nil
        } else {
            return SleepSample(startDate: startDate, endDate: endDate)
        }
    }

}
