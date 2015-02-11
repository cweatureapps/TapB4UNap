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

    private let timeKeeper = TimeKeeper()

    @IBOutlet weak private var statusMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var adjustSleepButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetUI", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }


    func resetUI() {
        statusMessageLabel.text = "TapB4UNap"
        timeLabel.text = ""
        adjustSleepButton.hidden = true
    }
    
    func saveToHealthStore() {
        if (timeKeeper.canSave()) {
            HealthStore.sharedInstance.saveSleepData(timeKeeper.getSleepStartDate()!, endDate:timeKeeper.getSleepEndDate()!) {
              (success, error) in
                    if (success) {
                        println("sleep data saved successfully!")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.statusMessageLabel.text = "Saved to HealthKit. You slept for:"
                            let timeElapsedString = TimeKeeper.formattedTimeFromDate(self.timeKeeper.getSleepStartDate()! , toDate: self.timeKeeper.getSleepEndDate()!)
                            self.timeLabel.text = timeElapsedString
                            
                            self.timeKeeper.reset()
                            
                            self.adjustSleepButton.hidden = false
                        }
                        
                        
                    } else {
                        println("Error: \(error)")
                    }
              }

        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    // MARK: unwind methods
    @IBAction func cancelToSaveDataController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveAdjustedSleeptime(segue: UIStoryboardSegue) {
        
        println("saveAdjustedSleeptime was called")
        
        self.statusMessageLabel.text = "Saving new value..."
        
        if let vc = segue.sourceViewController as? AdjustTimeTableViewController {
            
            let sleptForText = vc.sleptForLabel.text
            
            HealthStore.sharedInstance.overwriteMostRecentSleepSample(vc.startTimeDatePicker!.date, toDate: vc.endTimeDatePicker!.date) {
                success in
                
                    dispatch_async(dispatch_get_main_queue()) {
                    
                        if (success) {
                            self.statusMessageLabel.text = "Saved to HealthKit. You slept for:"
                            self.timeLabel.text = sleptForText
                            self.adjustSleepButton.hidden = true
                        }
                    }
                
            }
        }
    }
    
}