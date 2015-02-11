//
//  AdjustTimeTableViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 14/02/2015.
//  Copyright (c) 2015 Ken Ko. All rights reserved.
//

import UIKit
import HealthKit

class AdjustTimeTableViewController: UITableViewController {

    private let timeKeeper = TimeKeeper()

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var sleptForLabel: UILabel!
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimeDatePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        endTimeDatePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        var mostRecentSleep = timeKeeper.mostRecentSleepData()
        
        if let sleepStartDate = mostRecentSleep.startDate, sleepEndDate = mostRecentSleep.endDate {
        
            startTimeLabel.text = formatDate(sleepStartDate)
            startTimeDatePicker.date = sleepStartDate

            endTimeLabel.text = formatDate(sleepEndDate)
            endTimeDatePicker.date = sleepEndDate
            
            sleptForLabel.text = TimeKeeper.formattedTimeFromDate(sleepStartDate, toDate: sleepEndDate)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func datePickerChanged(datePicker:UIDatePicker) {
        let labelToChange = (datePicker===startTimeDatePicker ? startTimeLabel : endTimeLabel)
        labelToChange.text = formatDate(datePicker.date)
        
        sleptForLabel.text = TimeKeeper.formattedTimeFromDate(startTimeDatePicker.date, toDate: endTimeDatePicker.date)
    }


    private func formatDate(date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy hh:mm a"
        return formatter.stringFromDate(date)
    }
    
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
//        if (segue.identifier == "saveAdjusted") {
//            overwriteMostRecentSleepSample(startTimeDatePicker.date, toDate: endTimeDatePicker.date);
//        }
        
    }

  
    
}
