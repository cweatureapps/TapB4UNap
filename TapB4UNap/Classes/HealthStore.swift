//
//  HealthStore.swift
//  TapB4UNap
//
//  Created by Ken Ko on 21/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//
//  Wraps the single instance of HKHealthStore
//  and provides helper methods.

import Foundation
import HealthKit

class HealthStore {

    static let sharedInstance: HealthStore = HealthStore()

    private let hkHealthStore: HKHealthStore

    private init() {
        self.hkHealthStore = HKHealthStore()
    }

    private func requestAuthorisationForHealthStore(completion: ((Bool, NSError?) -> Void)!) {
        let dataTypesToReadAndWrite: Set = [HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!]
        self.hkHealthStore.requestAuthorizationToShareTypes(dataTypesToReadAndWrite,
            readTypes: dataTypesToReadAndWrite,
            completion: completion)
    }

    /* saves a sleep sample to health kit */
    func saveSleepSample(sleepSample: SleepSample, completion: ((Bool, NSError?) -> Void)!) {

        self.requestAuthorisationForHealthStore {
            success, error in
            if success {
                print("Authorised to write to HealthKit")

                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
                let metadata = [ HKMetadataKeyWasUserEntered : true ]
                let sample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.Asleep.rawValue, startDate: sleepSample.startDate!, endDate: sleepSample.endDate!, metadata: metadata)

                print("Saving...")

                self.hkHealthStore.saveObject(sample, withCompletion: completion)
            } else if error != nil {
                print(error)
            }

        }
    }

    /* looks for Sleep Analysis samples in HealthKit which have a start date in the given SleepSample range */
    func querySleepSample(sleepSample: SleepSample, completion: (([AnyObject]!, NSError!) -> Void)!) {
        self.requestAuthorisationForHealthStore {
            success, error in
            if success {
                let predicate = HKQuery.predicateForSamplesWithStartDate(sleepSample.startDate!, endDate: sleepSample.endDate!, options: .StrictStartDate)
                let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)!
                let sampleQuery = HKSampleQuery(sampleType: categoryType, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) {
                    sampleQuery, results, error in
                    completion(results, error)
                }
                self.hkHealthStore.executeQuery(sampleQuery)
            }
        }
    }

    /* delete an HKObject from health kit */
    func deleteSleepData(hkObject: HKObject!, completion: ((Bool, NSError?) -> Void)!) {
        self.requestAuthorisationForHealthStore {
            success, error in
            if success {
                self.hkHealthStore.deleteObject(hkObject, withCompletion:completion)
            }
        }
    }

    /* queries and then deletes the recent sleep sample from HealthKit, and then saves the new sample */
    func overwriteMostRecentSleepSample(mostRecentSleepSample: SleepSample, withSample sleepSample: SleepSample, completion: (Bool, NSError!) -> Void) {

        print("overwriting most recent sleep")

        HealthStore.sharedInstance.querySleepSample(mostRecentSleepSample) {
            objArr, error in

            if let error = error {
                let error = NSError(domain: "com.cweatureapps.TapB4UNap.HealthStore", code: 11, userInfo: ["message": "error during query: \(error.localizedDescription)"])
                completion(false, error)
                return
            }

            if objArr.isEmpty {
                let error = NSError(domain: "com.cweatureapps.TapB4UNap.HealthStore", code: 12, userInfo: ["message": "no records found in sleep sample query"])
                completion(false, error)
                return
            }

            if objArr.count > 1 {
                // NOTE: this is a rare edge case and shouldn't happen with realistic data
                let error = NSError(domain: "com.cweatureapps.TapB4UNap.HealthStore", code: 13, userInfo: ["message": "more than 1 record was found in sleep sample query"])
                completion(false, error)
                return
            }

            HealthStore.sharedInstance.deleteSleepData(objArr[0] as! HKObject) {
                success, error in
                if success {
                    HealthStore.sharedInstance.saveSleepSample(sleepSample) {
                        success, error in
                        print("saveSleepData completed")
                        completion(success, nil)
                    }
                } else {
                    completion(false, error)
                }
            }
        }
    }

}
