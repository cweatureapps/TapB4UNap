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

    // MARK: Constants

    private enum Constants {
        static let adjustSegue = "adjustSegue"
    }

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
        } else if segue.identifier == Constants.adjustSegue,
            let navVC = segue.destinationViewController as? UINavigationController,
            let adjustVC = navVC.viewControllers.first as? AdjustTimeTableViewController {
            adjustVC.title = adjustIsEdit ? "Edit" : "Add"
        }
    }

    // MARK: Notifications

    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.willResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
    }

    func didBecomeActive() {
        log.debug("didBecomeActive called")
        timerViewController?.refreshUI()
        timerViewController?.startSleepingTimer()
    }

    func willResignActive() {
        log.debug("willResignActive called")
        timerViewController?.stopSleepingTimer()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Public API

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
                LogUtils.logError("extension authorization failed", error)
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
            let handler: (Result<Void>) -> Void = { result in
                switch result {
                case .Success:
                    self.log.debug("saveAdjustedSleeptime was successful")
                    self.timerViewController.refreshUI()
                case .Failure(let error):
                    LogUtils.logError("Error with saveAdjustedSleeptime", error)
                    self.timerViewController.handleSleepManagerError(error)
                }
            }
            if adjustIsEdit {
                sleepManager.saveAdjustedSleepTimeToHealthStore(sleepSample, completion: handler)
            } else {
                sleepManager.saveSleep(sleepSample, completion: handler)
            }
        }
    }

    // MARK: TimerViewControllerDelegate

    var adjustIsEdit = false

    func addButtonTapped() {
        adjustIsEdit = false
        performSegueWithIdentifier(Constants.adjustSegue, sender: self)
    }

    func editButtonTapped() {
        adjustIsEdit = true
        performSegueWithIdentifier(Constants.adjustSegue, sender: self)
    }
}
