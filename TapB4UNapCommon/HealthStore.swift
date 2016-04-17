//
//  HealthStore.swift
//  TapB4UNap
//
//  Created by Ken Ko on 21/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation
import HealthKit

///  Wraps the single instance of HKHealthStore and provides helper methods.
class HealthStore {

    static let sharedInstance: HealthStore = HealthStore()

    private let hkHealthStore: HKHealthStore

    private init() {
        self.hkHealthStore = HKHealthStore()
    }

    /// Whether sharing has been authorized for sleep data
    func isAuthorized() -> Bool {
        return hkHealthStore.authorizationStatusForType(HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!) == HKAuthorizationStatus.SharingAuthorized
    }

    private func requestAuthorisationForHealthStore(completion: (Result<Void>) -> Void) {
        let dataTypesToReadAndWrite: Set = [HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!]
        hkHealthStore.requestAuthorizationToShareTypes(dataTypesToReadAndWrite,
            readTypes: dataTypesToReadAndWrite) { promptCompleted, error in
                if self.isAuthorized() {
                    completion(.Success())
                } else {
                    let errorMessage = error?.localizedDescription ?? ""
                    completion(.Failure(TapB4UNapError.NotAuthorized(errorMessage)))
                }
            }
    }

    /// saves a sleep sample to health kit 
    func saveSleepSample(sleepSample: SleepSample, completion: (Result<Void>) -> Void) {
        requestAuthorisationForHealthStore { result in
            switch result {
            case .Success:
                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
                let metadata = [ HKMetadataKeyWasUserEntered : true ]
                let sample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.Asleep.rawValue, startDate: sleepSample.startDate!, endDate: sleepSample.endDate!, metadata: metadata)

                log("Saving...")

                self.hkHealthStore.saveObject(sample) { success, error in
                    if success {
                        completion(.Success())
                    } else {
                        let errorMessage = error?.localizedDescription ?? "HealthKit save failed"
                        completion(.Failure(TapB4UNapError.SaveFailed(errorMessage)))
                    }
                }
            case .Failure:
                completion(result)
            }
        }
    }

    /// looks for Sleep Analysis samples in HealthKit which have a start date in the given SleepSample range 
    func querySleepSample(sleepSample: SleepSample, completion: (Result<[HKSample]?>) -> Void) {
        self.requestAuthorisationForHealthStore { result in
            switch result {
            case .Success:
                let predicate = HKQuery.predicateForSamplesWithStartDate(sleepSample.startDate!, endDate: sleepSample.endDate!, options: .StrictStartDate)
                let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
                let sampleQuery = HKSampleQuery(sampleType: categoryType, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) {
                    sampleQuery, results, error in
                    if let error = error {
                        completion(.Failure(TapB4UNapError.QueryFailed(error.localizedDescription)))
                    } else {
                        completion(.Success(results))
                    }
                }
                self.hkHealthStore.executeQuery(sampleQuery)
            case .Failure(let error):
                completion(.Failure(error))
            }
        }
    }

    /// delete an HKObject from health kit 
    func deleteSleepData(hkObject: HKObject, completion: (Result<Void>) -> Void) {
        self.requestAuthorisationForHealthStore { result in
            switch result {
            case .Success:
                self.hkHealthStore.deleteObject(hkObject) { success, error in
                    if success {
                        completion(.Success())
                    } else {
                        let errorMessage = error?.localizedDescription ?? "Delete failed"
                        completion(.Failure(TapB4UNapError.DeleteFailed(errorMessage)))
                    }
                }
            case .Failure:
                completion(result)
            }
        }
    }

    /// queries and then deletes the recent sleep sample from HealthKit, and then saves the new sample
    func overwriteMostRecentSleepSample(mostRecentSleepSample: SleepSample, withSample sleepSample: SleepSample, completion: (Result<Void>) -> Void) {
        log("overwriting most recent sleep")
        querySleepSample(mostRecentSleepSample) { result in
            switch result {
                case .Failure(let error):
                    completion(.Failure(error))
                case .Success(let samples):
                    guard let samples = samples where !samples.isEmpty else {
                        completion(.Failure(TapB4UNapError.OverwriteFailed("no records found in sleep sample query")))
                        return
                    }
                    guard let firstSample = samples.first where samples.count == 1 else {
                        completion(.Failure(TapB4UNapError.OverwriteFailed("more than 1 record was found in sleep sample query")))
                        return
                    }

                    self.deleteSleepData(firstSample) { result in
                        switch result {
                        case .Success:
                            self.saveSleepSample(sleepSample) { result in
                                log("saveSleepData completed")
                                completion(.Success())
                            }
                        case .Failure:
                            completion(result)
                        }
                    }
            }
        }
    }

}
