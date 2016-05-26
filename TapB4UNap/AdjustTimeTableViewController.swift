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
        static let textColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
    }

    private let timeKeeper = TimeKeeper()

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

        setupTextColours()
        addBlurredImage()
        setupNavBar()
    }

    func setupTextColours() {
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        startTimeDatePicker.setValue(Constants.textColor, forKey: "textColor")
        endTimeDatePicker.setValue(Constants.textColor, forKey: "textColor")
    }

    func addBlurredImage() {
        let image = UIImage(named: "background")
        let blurImage = UIImageEffects.imageByApplyingBlurToImage(image, withRadius: 40, tintColor: UIColor.clearColor(), saturationDeltaFactor: 1.2, maskImage: nil)
        let backgroundImageView = UIImageView(image: blurImage)
        backgroundImageView.contentMode = .ScaleAspectFill
        tableView.backgroundView = backgroundImageView
    }

    private func setupNavBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
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
        sleptForLabel.text = formattedSleepTime.isEmpty ? "Error: invalid sleep time" : formattedSleepTime
        sleptForLabel.textColor = formattedSleepTime.isEmpty ? UIColor.redColor() : Constants.textColor
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
