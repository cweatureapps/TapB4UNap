//
//  HealthStore.swift
//  TapB4UNap
//
//  Created by Ken Ko on 21/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation
import HealthKit
import XCGLogger

///  Wraps the single instance of HKHealthStore and provides helper methods.
class HealthStore {

    private static let authCancelledErrorCode = 100

    private let log = XCGLogger.defaultInstance()

    static let sharedInstance: HealthStore = HealthStore()

    private let hkHealthStore: HKHealthStore

    private init() {
        self.hkHealthStore = HKHealthStore()
    }

    /// Whether sharing has been denied for sleep data
    func isAuthorizationNotDetermined() -> Bool {
        return hkHealthStore.authorizationStatusForType(HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!) == HKAuthorizationStatus.NotDetermined
    }

    /// Whether sharing has been authorized for sleep data
    func isAuthorized() -> Bool {
        return hkHealthStore.authorizationStatusForType(HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!) == HKAuthorizationStatus.SharingAuthorized
    }

    /// Whether sharing has been denied for sleep data
    func isAuthorizationDenied() -> Bool {
        return hkHealthStore.authorizationStatusForType(HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!) == HKAuthorizationStatus.SharingDenied
    }

    /// Request for authorization from HealthKit
    func requestAuthorisationForHealthStore(completion: (Result<Void>) -> Void) {
        let dataTypesToShare: Set = [HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!]
        hkHealthStore.requestAuthorizationToShareTypes(dataTypesToShare, readTypes: nil) { _, error in
            if self.isAuthorized() {
                completion(.Success())
            } else {
                if let error = error where (error as NSError).domain == HKErrorDomain && (error as NSError).code == HealthStore.authCancelledErrorCode {
                    completion(.Failure(TapB4UNapError.AuthorizationCancelled(error.localizedDescription ?? "")))
                } else {
                    let errorMessage = error?.localizedDescription ?? ""
                    completion(.Failure(TapB4UNapError.NotAuthorized(errorMessage)))
                }
            }
        }
    }

    /// saves a sleep sample to health kit
    func saveSleepSample(sleepSample: SleepSample, completion: (Result<Void>) -> Void) {
        guard sleepSample.canSave() else {
            let errorMessage = "sleepSample was not in a state that could be saved"
            log.error(errorMessage)
            completion(.Failure(TapB4UNapError.SaveFailed(errorMessage)))
            return
        }
        requestAuthorisationForHealthStore { result in
            switch result {
            case .Success:
                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
                let metadata = [ HKMetadataKeyWasUserEntered : true ]
                let sample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.Asleep.rawValue, startDate: sleepSample.startDate!, endDate: sleepSample.endDate!, metadata: metadata)

                self.log.debug("Saving...")

                self.hkHealthStore.saveObject(sample) { success, error in
                    if success {
                        self.log.info("saveSleepSample success")
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
    private func deleteSleepData(hkObject: HKObject, completion: (Result<Void>) -> Void) {
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

    /// Queries HealthKit for the recording matching the SleepSample and deletes it
    func deleteSleepSample(sleepSample: SleepSample, completion: (Result<Void>) -> Void) {
        log.debug("deleting sleep sample")
        querySleepSample(sleepSample) { result in
            switch result {
            case .Failure(let error):
                completion(.Failure(error))
            case .Success(let samples):
                guard let samples = samples where !samples.isEmpty else {
                    let errorMessage = "delete failed, no records found in sleep sample query"
                    self.log.error(errorMessage)
                    completion(.Failure(TapB4UNapError.DeleteFailed(errorMessage)))
                    return
                }
                guard let firstSample = samples.first where samples.count == 1 else {
                    let errorMessage = "delete failed, more than 1 record was found in sleep sample query"
                    self.log.error(errorMessage)
                    completion(.Failure(TapB4UNapError.DeleteFailed(errorMessage)))
                    return
                }

                self.deleteSleepData(firstSample) { result in
                    switch result {
                    case .Success:
                        self.log.info("delete successful")
                        completion(.Success())
                    case .Failure:
                        self.log.error("delete failed")
                        completion(result)
                    }
                }
            }
        }
    }

    /// Queries and then deletes the given sample from HealthKit, and then saves the new sample
    func overwriteSleepSample(existingSleepSample: SleepSample, withSample newSleepSample: SleepSample, completion: (Result<Void>) -> Void) {
        deleteSleepSample(existingSleepSample) { result in
            switch result {
            case .Failure:
                self.log.error("overwrite failed during delete")
                completion(result)
            case .Success:
                self.saveSleepSample(newSleepSample) { saveResult in
                    switch saveResult {
                    case .Failure:
                        self.log.error("overwrite failed during save")
                         completion(result)
                    case .Success:
                        self.log.info("Overwrite successful")
                        completion(.Success())
                    }
                }
            }
        }
    }

}
