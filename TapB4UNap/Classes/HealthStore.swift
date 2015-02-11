//
//  HealthStore.swift
//  TapB4UNap
//
//  Created by Ken Ko on 21/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation
import HealthKit

class HealthStore {
    
    static let sharedInstance : HealthStore = HealthStore()
    
    private let hkHealthStore : HKHealthStore
    
    init() {
        self.hkHealthStore = HKHealthStore()
    }

    private func requestAuthorisationForHealthStore(completion: ((Bool, NSError!) -> Void)!) {
      let dataTypesToReadAndWrite = [
        HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
      ]
      self.hkHealthStore.requestAuthorizationToShareTypes(NSSet(array: dataTypesToReadAndWrite) as Set<NSObject>,
        readTypes: NSSet(array: dataTypesToReadAndWrite) as Set<NSObject>,
        completion: completion)
    }
    
    func saveSleepData(startDate:NSDate, endDate:NSDate, withCompletion completion: ((Bool, NSError!) -> Void)!) {
    
        self.requestAuthorisationForHealthStore({(success:Bool, error:NSError!) -> Void in
            
            if success {
                println("Authorised to write to HealthKit")
            
                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
                let metadata = [ HKMetadataKeyWasUserEntered : true ]
                let sample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.Asleep.rawValue, startDate: startDate, endDate: endDate, metadata: metadata)
                
                println("Saving...")
                
                self.hkHealthStore.saveObject(sample, withCompletion: completion)
            }
            
        })
        
    }
    
    
    
    func querySleepData(startDate:NSDate, endDate:NSDate, completion: (([AnyObject]!, NSError!) -> Void)!) {
     
        self.requestAuthorisationForHealthStore({(success:Bool, error:NSError!) -> Void in
        
            if success {

                let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .StrictStartDate)

                let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)


                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
                let sampleQuery = HKSampleQuery(sampleType: categoryType, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
                { (sampleQuery, results, error ) -> Void in

                  if let queryError = error {
                    println( "There was an error while reading the samples: \(queryError.localizedDescription)")
                  }
                  completion(results, error)
                }

                self.hkHealthStore.executeQuery(sampleQuery)
            }
        })
    }
    
    func deleteSleepData(hkObject:HKObject!, completion: ((Bool, NSError!) -> Void)!) {
        self.requestAuthorisationForHealthStore({(success:Bool, error:NSError!) -> Void in
            if success {
                self.hkHealthStore.deleteObject(hkObject, withCompletion:completion)
            }
        })
    }
    
    
    private func CreateDate(day:Int, month:Int, year:Int) -> NSDate? {
        let comps = NSDateComponents()
        comps.day = day
        comps.month = month
        comps.year = year
        return NSCalendar.currentCalendar().dateFromComponents(comps)
    }
    
    func overwriteMostRecentSleepSample(fromDate:NSDate, toDate:NSDate, completion: (Bool) -> Void) {
    
        println("overwriting most recent sleep")
        
        var saveSuccessful = false;
        
        // TODO: recent sleep sample should be passed in
        let mostRecentSleepData = TimeKeeper().mostRecentSleepData()
        
        HealthStore.sharedInstance.querySleepData(mostRecentSleepData.startDate!, endDate: mostRecentSleepData.endDate!) {
            objArr, error in
            assert(objArr.count == 1, "Should be exactly one record found")
        
            HealthStore.sharedInstance.deleteSleepData(objArr[0] as! HKObject) {
                success, error in
                if (success) {
                    HealthStore.sharedInstance.saveSleepData(fromDate, endDate: toDate) {
                        success, error in
                        println("saveSleepData completed")
                        completion(success)
                    }
                }
            }
        }
    }
    
}