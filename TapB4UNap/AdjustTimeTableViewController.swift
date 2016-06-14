//
//  AdjustTimeTableViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 14/02/2015.
//  Copyright (c) 2015 Ken Ko. All rights reserved.
//

import UIKit

class AdjustTimeTableViewController: UITableViewController {

    private enum Constants {
        static let textColor = UIColor.blackColor()
    }

    private let timeKeeper = TimeKeeper()
    private let sleepManager = SleepManager()

    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var sleptForLabel: UILabel!
    @IBOutlet private var startTimeDatePicker: UIDatePicker!
    @IBOutlet private var endTimeDatePicker: UIDatePicker!
    @IBOutlet private var deleteCell: UITableViewCell!

    /// true if this screen is in edit mode, false if this screen is to add new
    var isEditMode = false

    var sleepSample = SleepSample(startDate: nil, endDate: nil)

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isEditMode ? "Edit" : "Add"
        deleteCell.hidden = !isEditMode
        startTimeDatePicker.addTarget(self, action: #selector(AdjustTimeTableViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        endTimeDatePicker.addTarget(self, action: #selector(AdjustTimeTableViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        if let mostRecentSleep = timeKeeper.mostRecentSleepSample(),
            sleepStartDate = mostRecentSleep.startDate,
            sleepEndDate = mostRecentSleep.endDate {
            sleepSample.startDate = sleepStartDate
            sleepSample.endDate = sleepEndDate
            refreshUI()
        } else {
            sleptForLabel.text = "0:00:00"
        }
    }

    func datePickerChanged(datePicker: UIDatePicker) {
        sleepSample.startDate = startTimeDatePicker.date
        sleepSample.endDate = endTimeDatePicker.date
        sleepSample.resetSeconds()
        refreshUI()
    }

    private func refreshUI() {
        startTimeDatePicker.date = sleepSample.startDate!
        endTimeDatePicker.date = sleepSample.endDate!

        let formattedSleepTime = sleepSample.formattedString()
        if formattedSleepTime.isEmpty {
            sleptForLabel.text = "Error: invalid sleep time"
            sleptForLabel.textColor = UIColor.redColor()
            saveButton.enabled = false
        } else {
            sleptForLabel.text = formattedSleepTime
            sleptForLabel.textColor = Constants.textColor
            saveButton.enabled = true
        }
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

    // MARK: - Delete

    @IBAction func deleteTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "Are you sure you want to delete this sleep record?", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style:.Destructive) { _ in
            self.deleteMostRecentSleep()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    private func deleteMostRecentSleep() {
        self.sleepManager.deleteMostRecentSleepSample { result in
            switch result {
            case .Failure(let error):
                LogUtils.logError("delete failed", error)
                self.alertMessage("Sorry, something went wrong")
            case .Success:
                self.alertMessage("The record has been deleted successfully") {
                    self.performSegueWithIdentifier("mainSegue", sender: self)
                }
            }
        }
    }

    private func alertMessage(message: String, okHandler: ((Void) -> Void)? = nil) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default) { _ in
            okHandler?()
        }
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

}
