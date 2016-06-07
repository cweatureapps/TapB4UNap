//
//  MainViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 28/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import HealthKit
import XCGLogger

class MainViewController: UIViewController, TimerViewControllerDelegate {

    // MARK: privates

    private let log = XCGLogger.defaultInstance()
    private let sleepManager = SleepManager()
    private weak var timerViewController: TimerViewController!

    // MARK: controller code

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let timerViewController = segue.destinationViewController as? TimerViewController {
            timerViewController.delegate = self
            self.timerViewController = timerViewController
        }
    }

    // MARK: Notifications

    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.willEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.didEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }

    func willEnterForeground() {
        timerViewController?.refreshUI()
        timerViewController?.startSleepingTimer()
    }

    func didEnterBackground() {
        timerViewController?.stopSleepingTimer()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Public API

    /// Called by deeplink to adjust the time
    func adjust() {
        performSegueWithIdentifier("adjustSegue", sender: nil)
    }

    /// Should be called by `AppDelegate.applicationShouldRequestHealthAuthorization(_:)` when handling HealthKit authorization request from an extension
    func handleExtensionAuthorization() {
        HealthStore.sharedInstance.handleExtensionAuthorization { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .Success:
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue()) {
                    this.timerViewController?.refreshUI()
                    this.timerViewController?.startSleepingTimer()
                }
            case .Failure(let error):
                Utils.logError("extension authorization failed", error)
                dispatch_async(dispatch_get_main_queue()) {
                    this.timerViewController.handleSleepManagerError(error)
                }
                return
            }
        }
    }

    // MARK: unwind methods

    @IBAction func cancelToMainViewController(segue: UIStoryboardSegue) {
        self.timerViewController.refreshUI()
    }

    @IBAction func saveAdjustedSleeptime(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? AdjustTimeTableViewController {
            let sleepSample = vc.sleepSample
            sleepManager.saveAdjustedSleepTimeToHealthStore(sleepSample) { result in
                switch result {
                case .Success:
                    self.log.debug("saveAdjustedSleeptime was successful")
                    self.timerViewController.refreshUI()
                case .Failure(let error):
                    Utils.logError("Error with saveAdjustedSleeptime", error)
                    self.timerViewController.handleSleepManagerError(error)
                }
            }
        }
    }

    // MARK: TimerViewControllerDelegate

    func adjustButtonHandler() {
        performSegueWithIdentifier("adjustSegue", sender: self)
    }
}
