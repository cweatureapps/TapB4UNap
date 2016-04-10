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
                HealthStore.sharedInstance.saveSleepSample(sleepSample) {
                    success, error in
                    if success {
                        print("sleep data saved successfully")
                        self.timeKeeper.backupSleepData(sleepSample)
                        self.timeKeeper.resetSleepData()
                    } else {
                        print("Error saving to health store: \(error)")
                        // TODO: should call completion with error
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

    /**
     Handles silent push notifications triggered from the today extension.
     This will save the sleep sample to HealthKit if it can save,
     or set up a geo-fence if currently sleeping.
     */
    func handleSilentNotification() {
        if let sleepSample = timeKeeper.sleepSample() {
            if sleepSample.canSave() {
                saveToHealthStore(nil)
            } else if sleepSample.isSleeping() {
                // TODO: set up geofence
            }
        }
    }

}
