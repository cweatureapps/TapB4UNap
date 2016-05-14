//
//  AdjustTimeTableViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 14/02/2015.
//  Copyright (c) 2015 Ken Ko. All rights reserved.
//

import UIKit

class AdjustTimeTableViewController: UITableViewController {

    private let timeKeeper = TimeKeeper()

    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!
    @IBOutlet private weak var sleptForLabel: UILabel!
    @IBOutlet private weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet private weak var endTimeDatePicker: UIDatePicker!

    var sleepSample = SleepSample(startDate: nil, endDate: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        startTimeDatePicker.addTarget(self, action: #selector(AdjustTimeTableViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        endTimeDatePicker.addTarget(self, action: #selector(AdjustTimeTableViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        if  let mostRecentSleep = timeKeeper.mostRecentSleepSample(),
            sleepStartDate = mostRecentSleep.startDate,
            sleepEndDate = mostRecentSleep.endDate {
            sleepSample.startDate = sleepStartDate
            sleepSample.endDate = sleepEndDate
            refreshUI()
        }
    }

    func datePickerChanged(datePicker: UIDatePicker) {
        sleepSample.startDate = startTimeDatePicker.date
        sleepSample.endDate = endTimeDatePicker.date
        sleepSample.resetSeconds()

        refreshUI()
    }

    private func refreshUI() {
        startTimeLabel.text = formatDate(sleepSample.startDate!)
        startTimeDatePicker.date = sleepSample.startDate!

        endTimeLabel.text = formatDate(sleepSample.endDate!)
        endTimeDatePicker.date = sleepSample.endDate!

        let formattedSleepTime = sleepSample.formattedString()
        sleptForLabel.text = formattedSleepTime.isEmpty ? "Error: invalid sleep time" : formattedSleepTime
        sleptForLabel.textColor = formattedSleepTime.isEmpty ? UIColor.redColor() : UIColor.blackColor()
    }

    private func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy hh:mm a"
        return formatter.stringFromDate(date)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinastionViewController].
        // Pass the selected object to the new view controller.

        if segue.identifier == "saveAdjusted" {
            sleepSample.startDate = startTimeDatePicker.date
            sleepSample.endDate = endTimeDatePicker.date
        }

    }



}
