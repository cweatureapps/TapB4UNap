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
    
    private let healthStore : HKHealthStore
    
    // singleton pattern
    // http://stackoverflow.com/questions/24024549/dispatch-once-singleton-model-in-swift
    class var sharedInstance : HealthStore {
        struct Static {
            static let instance : HealthStore = HealthStore()
        }
        return Static.instance
    }
    
    init() {
        self.healthStore = HKHealthStore()
        //self.requestAuthorisationForHealthStore()
    }

    private func requestAuthorisationForHealthStore(completion: ((Bool, NSError!) -> Void)!) {
      let dataTypesToReadAndWrite = [
        HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
      ]
      self.healthStore.requestAuthorizationToShareTypes(NSSet(array: dataTypesToReadAndWrite),
        readTypes: NSSet(array: dataTypesToReadAndWrite),
        completion: completion)
    }
    
    func saveSleepData(startDate:NSDate, endDate:NSDate, withCompletion completion: ((Bool, NSError!) -> Void)!) {
    
        self.requestAuthorisationForHealthStore({
        
            (success:Bool, error:NSError!) -> Void in
            
            if success {
                println("Authorised to write to HealthKit")
            
                let categoryType = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
                let metadata = [ HKMetadataKeyWasUserEntered : true ]
                let sample = HKCategorySample(type: categoryType, value: HKCategoryValueSleepAnalysis.Asleep.rawValue, startDate: startDate, endDate: endDate, metadata: metadata)
                
                println("Saving...")
                
                self.healthStore.saveObject(sample, withCompletion: completion)
            }
            
        })
        
    }
    
}