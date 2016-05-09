//
//  SaveDataViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 28/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import HealthKit

class SaveDataViewController: UIViewController, TimerViewControllerDelegate {

    // MARK: privates

    private let sleepManager = SleepManager()
    private weak var timerViewController: TimerViewController!

    // MARK: Outlets

    @IBOutlet weak private var aboutButton: UIButton!
    @IBOutlet weak private var copyrightLabel: UILabel!
    @IBOutlet weak private var aboutBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var copyrightBottomConstraint: NSLayoutConstraint!

    // MARK: controller code

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timerViewController?.refreshUI()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let timerViewController = segue.destinationViewController as? TimerViewController {
            timerViewController.delegate = self
            self.timerViewController = timerViewController
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    // MARK: Notifications

    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SaveDataViewController.willEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SaveDataViewController.didEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
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
                log("extension authorization failed", error)
                dispatch_async(dispatch_get_main_queue()) {
                    this.timerViewController.handleSleepManagerError(error)
                }
                return
            }
        }
    }

    // MARK: unwind methods

    @IBAction func cancelToSaveDataViewController(segue: UIStoryboardSegue) {
    }

    @IBAction func saveAdjustedSleeptime(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? AdjustTimeTableViewController {
            let sleepSample = vc.sleepSample
            sleepManager.saveAdjustedSleepTimeToHealthStore(sleepSample) { result in
                switch result {
                case .Success:
                    log("saveAdjustedSleeptime was successful")
                    self.timerViewController.refreshUI()
                case .Failure(let error):
                    log("Error with saveAdjustedSleeptime", error)
                    self.timerViewController.handleSleepManagerError(error)
                }
            }
        }
    }

    // MARK: TimerViewControllerDelegate

    func adjustButtonHandler() {
        performSegueWithIdentifier("adjustSegue", sender: self)
    }

    // MARK: copyright animation

    @IBAction func showCopyrightLabel(sender: UIButton) {
        swapControls(contraintToMoveOffScreen: aboutBottomConstraint, constraintToMoveOnScreen: copyrightBottomConstraint)
    }

    @IBAction func showAboutButton(sender: AnyObject) {
        swapControls(contraintToMoveOffScreen: copyrightBottomConstraint, constraintToMoveOnScreen: aboutBottomConstraint)
    }

    private func swapControls(contraintToMoveOffScreen contraintToMoveOffScreen: NSLayoutConstraint, constraintToMoveOnScreen: NSLayoutConstraint) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.3, animations: {
                contraintToMoveOffScreen.constant = -100
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.view.layoutIfNeeded()
                UIView.animateWithDuration(0.3) {
                    constraintToMoveOnScreen.constant = 20
                    self.view.layoutIfNeeded()
                }
            })
    }
}
