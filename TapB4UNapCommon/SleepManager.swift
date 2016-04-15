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
    func saveToHealthStore(completion: (Result<SleepSample>) -> Void) {
        if let sleepSample = timeKeeper.sleepSample() where sleepSample.canSave() {
            HealthStore.sharedInstance.saveSleepSample(sleepSample) { result in
                switch result {
                case .Success:
                    print("sleep data saved successfully")
                    self.timeKeeper.backupSleepData(sleepSample)
                    self.timeKeeper.resetSleepData()
                    completion(.Success(sleepSample))
                case .Failure(let error):
                    completion(.Failure(error))
                    // note: "Not authorized" error control flow goes into here
                    // TODO: introduce Swift errors; should map HKErrorCode to friendly messages
                }
//                if completion != nil {
//                    completion(sleepSample, success, error)
//                }
            }
        } else {
            print("warning: saveToHealthStore() was called when sleepSample was not in a state that could be saved")
            completion(.Failure(SleepManagerError.SaveFailed("sleepSample was not in a state that could be saved")))
        }
    }

    /**
     Overwrite the most recent sleep sample with another sleep sample. Used to adjust/edit an entry.

     - parameter sleepSample: The new sleep sample you wish to use to overwrite the most recent one.
     - parameter completion:  The completion called after saving to HealthKit, passing whether save was successful, and an error if it failed.
     */
    func saveAdjustedSleepTimeToHealthStore(sleepSample: SleepSample, completion: (Result<Void>) -> Void) {
        HealthStore.sharedInstance.overwriteMostRecentSleepSample(timeKeeper.mostRecentSleepSample()!, withSample: sleepSample) { result in
            switch result {
            case .Success:
                print("sleep data adjusted successfully")
                self.timeKeeper.backupSleepData(sleepSample)
                completion(.Success())
            case .Failure(let error):
                print("Error saving to health store: \(error)")
                completion(result)
            }
        }
    }
}
