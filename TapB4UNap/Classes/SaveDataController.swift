//
//  SaveDataController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 28/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation
import UIKit

class SaveDataController : UIViewController {

    let timeKeeper = TimeKeeper()

    @IBOutlet weak private var statusMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak private var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        saveToHealthStore()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    private func saveToHealthStore() {
        if (timeKeeper.canSave()) {
            HealthStore.sharedInstance.saveSleepData(timeKeeper.getSleepStartDate()!, endDate:timeKeeper.getSleepEndDate()!, withCompletion: {
              (success, error) in
                    if (success) {
                        println("sleep data saved successfully!")
                        
                        
                        // update ui on main thread
                        dispatch_async(dispatch_get_main_queue()) {
                            self.statusMessageLabel.text = "Saved to HealthKit. You slept for:"
                            self.timeLabel.text = (self.timeKeeper.formattedTimeElapsedSleeping())
                            
                            self.timeKeeper.reset()
                        }
                        
                        
                    } else {
                        println("Error: \(error)")
                    }
              })

        }
    }
    
    @IBAction func saveHandler(sender: AnyObject) {
        saveToHealthStore() 
    }
    
    
}