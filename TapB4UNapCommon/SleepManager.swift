//
//  SleepManager.swift
//  TapB4UNap
//
//  Created by Ken Ko on 6/04/2015.
//  Copyright (c) 2015 Ken Ko. All rights reserved.
//

import Foundation

/// Coordinates interaction between TimeKeeper and HealthStore
class SleepManager {

    private let timeKeeper = TimeKeeper()

    /**
     Saves the sleep sample which was recorded by TimeKeeper.

     - parameter completion: The completion called after saving to HealthKit, passing the sleepSample that was saved, whether save was successful, and an error if it failed.
     */
    func saveToHealthStore(completion: ((SleepSample!, Bool, NSError!) -> Void)!) {
        if let sleepSample = timeKeeper.sleepSample() {
            if sleepSample.canSave() {
                HealthStore.sharedInstance.saveSleepSample(sleepSample) { success, error in
                    if success {
                        print("sleep data saved successfully")
                        self.timeKeeper.backupSleepData(sleepSample)
                        self.timeKeeper.resetSleepData()
                    } else {
                        print("Error saving to health store: \(error?.localizedDescription)")
                        // note: "Not authorized" error control flow goes into here
                        // TODO: introduce Swift errors; should map HKErrorCode to friendly messages
                    }
                    if completion != nil {
                        completion(sleepSample, success, error)
                    }
                }
            } else {
                print("warning: saveToHealthStore() was called when sleepSample was not in a state that could be saved")
                // TODO: should call completion with error
            }
        }
    }

    /**
     Overwrite the most recent sleep sample with another sleep sample. Used to adjust/edit an entry.

     - parameter sleepSample: The new sleep sample you wish to use to overwrite the most recent one.
     - parameter completion:  The completion called after saving to HealthKit, passing whether save was successful, and an error if it failed.
     */
    func saveAdjustedSleepTimeToHealthStore(sleepSample: SleepSample, completion: (Bool, NSError!) -> Void) {
        HealthStore.sharedInstance.overwriteMostRecentSleepSample(timeKeeper.mostRecentSleepSample()!, withSample: sleepSample) {
            success, error in
            if success {
                print("sleep data adjusted successfully")
                self.timeKeeper.backupSleepData(sleepSample)
            } else {
                print("Error saving to health store: \(error)")
                // TODO: should call completion with error
            }
            completion(success, error)
        }
    }
}
