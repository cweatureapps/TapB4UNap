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

class PocViewController : UIViewController {

    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var wakeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sleepButtonHandler(sender: AnyObject) {
    }
    
    @IBAction func wakeButtonHandler(sender: AnyObject) {

        let now = NSDate()
        let wakeTime = now.dateByAddingTimeInterval(8 * 60 * 60)
      
        HealthStore.sharedInstance.saveSleepData(now, endDate: wakeTime, withCompletion: {
          (success, error) in
              if success {
                println("sleep data saved successfully!")
              } else {
                println("Error: \(error)")
              }
          })
    }

}
