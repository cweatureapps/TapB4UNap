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

    /// Checks that we have HealthKit authorization, and save the sleep start data if we have permission
    func startSleep(completion: (Result<Void>) -> Void) {
        HealthStore.sharedInstance.requestAuthorisationForHealthStore { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                    case .Success:
                        self.timeKeeper.startSleep(NSDate())
                        completion(.Success())
                    case .Failure(let error):
                        completion(.Failure(error))
                }
            }
        }
    }

    /**
     Saves the sleep sample which was recorded by TimeKeeper.

     - parameter completion: The completion called after saving to HealthKit, passing the sleepSample that was saved, whether save was successful, and an error if it failed.
     */
    func saveToHealthStore(completion: (Result<SleepSample>) -> Void) {
        guard let sleepSample = timeKeeper.sleepSample() where sleepSample.canSave() else {
            let errorMessage = "sleepSample was not in a state that could be saved"
            log(errorMessage)
            completion(.Failure(TapB4UNapError.SaveFailed(errorMessage)))
            return
        }
        HealthStore.sharedInstance.saveSleepSample(sleepSample) { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case .Success:
                    log("sleep data saved successfully")
                    self.timeKeeper.saveSuccess(sleepSample)
                    self.timeKeeper.resetSleepData()
                    completion(.Success(sleepSample))
                case .Failure(let error):
                    log("saveToHealthStore failed", error)
                    completion(.Failure(error))
                }
            }
        }
    }

    /**
     Overwrite the most recent sleep sample with another sleep sample. Used to adjust/edit an entry.

     - parameter sleepSample: The new sleep sample you wish to use to overwrite the most recent one.
     - parameter completion:  The completion called after saving to HealthKit with the result of whether it was successful
     */
    func saveAdjustedSleepTimeToHealthStore(sleepSample: SleepSample, completion: (Result<Void>) -> Void) {
        HealthStore.sharedInstance.overwriteMostRecentSleepSample(timeKeeper.mostRecentSleepSample()!, withSample: sleepSample) { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case .Success:
                    log("sleep data adjusted successfully")
                    self.timeKeeper.saveSuccess(sleepSample)
                    completion(.Success())
                case .Failure(let error):
                    log("Error saving to health store", error)
                    completion(result)
                }
            }
        }
    }
}
