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

    // MARK: privates
    
    private let timeKeeper = TimeKeeper()

    @IBOutlet weak private var statusMessageLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var adjustSleepButton: UIButton!
    @IBOutlet weak private var aboutButton: UIButton!
    @IBOutlet weak private var copyrightButton: UILabel!
    @IBOutlet weak private var aboutBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var copyrightBottomConstraint: NSLayoutConstraint!
    
    // MARK: controller code
    
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
        let sleepSample = timeKeeper.sleepSample()
        if sleepSample.canSave() {
            HealthStore.sharedInstance.saveSleepSample(sleepSample) {
                success, error in
                if success {
                    println("sleep data saved successfully!")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.statusMessageLabel.text = "Saved to HealthKit. You slept for:"
                        let timeElapsedString = sleepSample.formattedString()
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
        
        if let vc = segue.sourceViewController as? AdjustTimeTableViewController {
            
            let sleepSample = vc.sleepSample
            HealthStore.sharedInstance.overwriteMostRecentSleepSample(timeKeeper.mostRecentSleepData()! , withSample: sleepSample) {
                success in
                dispatch_async(dispatch_get_main_queue()) {
                
                    if success {
                        self.statusMessageLabel.text = "Saved to HealthKit. You slept for:"
                        self.timeLabel.text = sleepSample.formattedString()
                        self.adjustSleepButton.hidden = true
                    }
                }
                
            }
        }
    }
    
    // MARK: copyright animation
    
    @IBAction func showCopyrightLabel(sender: UIButton) {
        swapControls(contraintToMoveOffScreen: aboutBottomConstraint, constraintToMoveOnScreen: copyrightBottomConstraint)
    }
    
    @IBAction func showAboutButton(sender: AnyObject) {
        swapControls(contraintToMoveOffScreen: copyrightBottomConstraint, constraintToMoveOnScreen: aboutBottomConstraint)
    }
    
    private func swapControls(#contraintToMoveOffScreen:NSLayoutConstraint , constraintToMoveOnScreen:NSLayoutConstraint) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.3,
            animations: {
                contraintToMoveOffScreen.constant = -100
                self.view.layoutIfNeeded()
            },
            completion: {
                finished in
                if finished {
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.3) {
                        constraintToMoveOnScreen.constant = 20
                        self.view.layoutIfNeeded()
                    }
                }
            })
    }
}