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

    private enum UserDefaultsKeys {
        private static let sleepStartedKey = "sleepStarted"
        private static let sleepEndedKey = "sleepEnded"
        private static let mostRecentSleepStartKey = "mostRecentSleepStart"
        private static let mostRecentSleepEndKey = "mostRecentSleepEnd"
        private static let lastSavedKey = "lastSaved"
    }

    private let userDefaults: NSUserDefaults = SettingsManager.sharedUserDefaults
    private let wasRecentlySavedTimeInterval: NSTimeInterval = 60 * 5 // 5 minutes

    /**
     Saves the sleep start with the given value.
     - parameter date: The date value of when sleep started
     */
    func startSleep(date: NSDate) {
        resetRecentSleepData()
        userDefaults.setObject(date, forKey: UserDefaultsKeys.sleepStartedKey)
        userDefaults.synchronize()
    }

    /**
     Saves the sleep end with the given value.
     - parameter date: The date value of when sleep ended
     */
    func endSleep(date: NSDate) {
        userDefaults.setObject(date, forKey: UserDefaultsKeys.sleepEndedKey)
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
        return sleepSampleForKeys(startKey: UserDefaultsKeys.sleepStartedKey, endKey: UserDefaultsKeys.sleepEndedKey)
    }

    /**
     Should be called when data is saved in HealthKit successfully.
     This will backup the sleep data, and also record the time when this save occurred.
     - parameter sleepSample: The SleepSample to backup.
     */
    func saveSuccess(sleepSample: SleepSample) {
        userDefaults.setObject(sleepSample.startDate, forKey: UserDefaultsKeys.mostRecentSleepStartKey)
        userDefaults.setObject(sleepSample.endDate, forKey: UserDefaultsKeys.mostRecentSleepEndKey)
        userDefaults.setObject(NSDate(), forKey: UserDefaultsKeys.lastSavedKey)
        userDefaults.synchronize()
    }

    /**
     Removes the saved values for sleep start and sleep end.
     */
    func resetSleepData() {
        userDefaults.removeObjectForKey(UserDefaultsKeys.sleepStartedKey)
        userDefaults.removeObjectForKey(UserDefaultsKeys.sleepEndedKey)
        userDefaults.synchronize()
    }

    /**
    Removes the saved backup values for the most recent sleep sample.
    */
    func resetRecentSleepData() {
        userDefaults.removeObjectForKey(UserDefaultsKeys.mostRecentSleepStartKey)
        userDefaults.removeObjectForKey(UserDefaultsKeys.mostRecentSleepEndKey)
        userDefaults.synchronize()
    }

    /**
     The most recently saved sleep sample, when `saveSuccess(sleepSample)` was last called.
     - returns: The most recently backed up sleep sample. Returns nil if both start and end dates are nil.
     */
    func mostRecentSleepSample() -> SleepSample? {
        return sleepSampleForKeys(startKey: UserDefaultsKeys.mostRecentSleepStartKey, endKey: UserDefaultsKeys.mostRecentSleepEndKey)
    }


    /**
    Whether `saveSuccess` was called recently. You may want make it easy for the user to adjust the sleep sample if the save was recent.
    */
    func wasRecentlySaved() -> Bool {
        guard let lastSavedDate = userDefaults.objectForKey(UserDefaultsKeys.lastSavedKey) as? NSDate else { return false }
        return lastSavedDate.timeIntervalSinceNow > -wasRecentlySavedTimeInterval
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
