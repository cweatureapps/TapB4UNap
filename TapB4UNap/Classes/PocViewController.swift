//
//  PocViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 20/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation
import UIKit
import HealthKit


/*
BACKLOG

- fade animation transisitions for showing and hiding counting clock
- conserve processing and battery, ensure timer is stopped when closing extension, start again when on screen

*/

class PocViewController : UIViewController {

    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var wakeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var elapsedLabel: UILabel!
    
    let timeKeeper = TimeKeeper()
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func sleepButtonHandler(sender: AnyObject) {
        timeKeeper.addSleepRecord(NSDate())
        startTimer()
    }
    
    @IBAction func cancelButtonHandler(sender: AnyObject) {
        reset()
    }
    
    @IBAction func wakeButtonHandler(sender: AnyObject) {
        let sleepRecord = timeKeeper.sleepRecord()!
        reset()
        HealthStore.sharedInstance.saveSleepData(sleepRecord, endDate: NSDate(), withCompletion: {
          (success, error) in
                if (success) {
                    println("sleep data saved successfully!")
                    // TODO: interestingly, changing UI here wont reflect in UI immediately. UI thread vs other thread?
                } else {
                    println("Error: \(error)")
                }
          })
    }
    
    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:Selector("refreshElapsedLabel"), userInfo:nil, repeats:true)
        timer!.fire()
    }
    
    private func reset() {
        if (timer != nil) {
            timer!.invalidate()
            timer = nil;
        }
        timeKeeper.removeSleepRecord()
        refreshElapsedLabel()
    }
    
    func refreshElapsedLabel() {
        //println("refreshElapsedLabel called")
        if (timeKeeper.sleepRecord() == nil) {
            //println("sleep record is nil, resetting text")
            elapsedLabel.text = "Tap sleep to start!"
        } else {
            //println("sleep record was found...")
            let formattedTime = timeKeeper.formattedTimeElapsedFromSleepRecordUntil(NSDate())
            if (elapsedLabel.text != formattedTime) {
                //println("setting the label text")
                elapsedLabel.text = formattedTime
            }
        }
    }
    
}
