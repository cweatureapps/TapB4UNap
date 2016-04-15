//
//  TodayViewController.swift
//  TapB4UNapWidget
//
//  Created by Ken Ko on 24/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    // MARK: Privates

    private let sleepManager = SleepManager()

    private let timeKeeper = TimeKeeper()
    private var sleepTimer: NSTimer?
    private var pushCompletionTimer: NSTimer?
    private var pollingCount = 0

    @IBOutlet weak private var sleepButton: UIButton!
    @IBOutlet weak private var adjustButton: UIButton!
    @IBOutlet weak private var cancelButton: UIButton!
    @IBOutlet weak private var wakeButton: UIButton!
    @IBOutlet weak private var statusMessageLabel: UILabel!

    // MARK: UIViewController overrides

    override func viewDidLoad() {
        print("viewDidLoad was called")
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear was called")
        super.viewWillAppear(animated)

        refreshUI()

        if let sleepSample = timeKeeper.sleepSample() {
            if sleepSample.isSleeping() {
                startSleepingTimer()
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        print("viewWillDisappear was called")
    }

    override func viewDidDisappear(animated: Bool) {
        print("viewDidDisappear was called")
        // for the today widget, this is called as soon as you swipe up to close the notification center.
        // stop the timer so it doesn't consume resources when notification center is not visible.
        stopSleepingTimer()
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: NCWidgetProviding

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {

        // system calls occasionally so that it can preload the content in the background

        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        print("widgetPerformUpdateWithCompletionHandler was called")
        refreshUI()
        completionHandler(NCUpdateResult.NewData)
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        let newInsets = UIEdgeInsets(top:defaultMarginInsets.top, left:0, bottom:0, right:0)
        return newInsets
    }

    // MARK: handlers

    @IBAction func sleepButtonHandler(sender: AnyObject) {
        timeKeeper.startSleep(NSDate())
        startSleepingTimer()
    }

    @IBAction func adjustButtonHandler(sender: AnyObject) {
        extensionContext?.openURL(NSURL(string: "cwtapb4unap://adjust")!, completionHandler: nil)
    }

    @IBAction func cancelButtonHandler(sender: AnyObject) {
        timeKeeper.resetSleepData()
        refreshUI()
    }

    @IBAction func wakeButtonHandler(sender: AnyObject) {
        stopSleepingTimer()
        timeKeeper.endSleepIfNeeded(NSDate())
        refreshUI()
        saveToHealthKit()
    }

    private func saveToHealthKit() {
        sleepManager.saveToHealthStore { result in
            switch result {
            case .Success(let sleepSample):
                print("sleep data saved successfully!")
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    self.statusMessageLabel.text = "You slept for \(sleepSample.formattedString())"
                }
            case .Failure(let error):
                print("widget save error")
                dispatch_async(dispatch_get_main_queue()) {
                    let errorMessage: String
                    if let healthStoreError = error as? HealthStoreError,
                        case HealthStoreError.NotAuthorized  = healthStoreError {
                        errorMessage = "Please allow Apple Health to share sleep data with TapB4UNap"
                    } else {
                        errorMessage = "Sorry, something went wrong"
                    }
                    self.statusMessageLabel.text = errorMessage
                    self.adjustButton.hidden = true
                }
                self.timeKeeper.resetSleepData()
            }
        }
    }

    // MARK: sleeping timer
    private func startSleepingTimer() {
        sleepTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:#selector(TodayViewController.timerHandler), userInfo:nil, repeats:true)
        sleepTimer!.fire()
    }

    private func stopSleepingTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        print("timer stopped")
    }

    func timerHandler() {
        if let sleepSample = timeKeeper.sleepSample() {
            if !sleepSample.isSleeping() {
                stopSleepingTimer()
            }
        } else {
            stopSleepingTimer()
        }
        refreshUI()
    }

    // MARK: UI updates

    func refreshUI() {
        if var sleepSample = timeKeeper.sleepSample() {
            if sleepSample.isSleeping() {
                sleepSample.endDate = NSDate()
                let formattedTime = sleepSample.formattedString()
                if statusMessageLabel.text != formattedTime {
                    statusMessageLabel.text = formattedTime
                }
                sleepButton.hidden = true
                cancelButton.hidden = false
                wakeButton.hidden = false
                adjustButton.hidden = true

            } else if sleepSample.canSave() {
                statusMessageLabel.text = "Saving..."
                sleepButton.hidden = true
                cancelButton.hidden = true
                wakeButton.hidden = true
                adjustButton.hidden = false
            }
        } else {
            statusMessageLabel.text = "Tap sleep to start"
            sleepButton.hidden = false
            cancelButton.hidden = true
            wakeButton.hidden = true
            adjustButton.hidden = true
        }
    }

}
