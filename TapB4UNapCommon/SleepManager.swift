//
//  SleepManager.swift
//  TapB4UNap
//
//  Created by Ken Ko on 6/04/2015.
//  Copyright (c) 2015 Ken Ko. All rights reserved.
//

import Foundation
import XCGLogger

/// Coordinates interaction between TimeKeeper and HealthStore
class SleepManager {

    private let log = XCGLogger.defaultInstance()
    private let timeKeeper = TimeKeeper()
    private let locationManager = LocationManager.sharedInstance

    /// Checks that we have HealthKit authorization, and save the sleep start data if we have permission
    func startSleep(completion: (Result<Void>) -> Void) {
        HealthStore.sharedInstance.requestAuthorisationForHealthStore { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case .Success:
                    self.timeKeeper.startSleep(NSDate())
                    self.locationManager.setupGeofence()
                    completion(.Success())
                case .Failure(let error):
                    // When invoked from widget, if the auth screen takes too long, start timer anyway.
                    // If user ends up authorizing, then sleep is tracked as expected.
                    // If user denies auth, then UI should indicate authorization is required when ticking the timer.
                    if let customError = error as? TapB4UNapError {
                        if case .AuthorizationCancelled = customError {
                            self.timeKeeper.startSleep(NSDate())
                            completion(.Success())
                        }
                    }
                    completion(.Failure(error))
                }
            }
        }
    }

    /**
     Records the sleep end to TimeKeeper, then saving this to HealthKit. All geofences are also cancelled.

     - parameter completion: The completion called after saving to HealthKit, passing the sleepSample that was saved, whether save was successful, and an error if it failed.
     */
    func wakeIfNeeded(completion: ((Result<SleepSample>) -> Void)?) {
        locationManager.cancelAllGeofences()
        timeKeeper.endSleepIfNeeded(NSDate())
        guard let sleepSample = timeKeeper.sleepSample() where sleepSample.canSave() else {
            return
        }
        HealthStore.sharedInstance.saveSleepSample(sleepSample) { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case .Success:
                    self.log.debug("sleep data saved successfully")
                    self.timeKeeper.saveSuccess(sleepSample)
                    self.timeKeeper.resetSleepData()
                    completion?(.Success(sleepSample))
                case .Failure(let error):
                    Utils.logError("saveToHealthStore failed", error)
                    completion?(.Failure(error))
                }
            }
        }
    }

    /// Coordinates resetting sleep with `TimeKeeper` and `LocationManager`
    func reset() {
        timeKeeper.resetSleepData()
        timeKeeper.resetRecentSleepData()
        locationManager.cancelAllGeofences()
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
                    self.log.debug("sleep data adjusted successfully")
                    self.timeKeeper.saveSuccess(sleepSample)
                    completion(.Success())
                case .Failure(let error):
                    Utils.logError("Error saving to health store", error)
                    completion(result)
                }
            }
        }
    }
}
