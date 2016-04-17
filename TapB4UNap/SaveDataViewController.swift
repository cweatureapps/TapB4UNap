//
//  SaveDataViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 28/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import HealthKit

class SaveDataViewController: UIViewController {

    private enum Strings {
        static let saveSuccess = "Saved to HealthKit. You slept for:"
        static let genericError = "Sorry, something went wrong"
        static let saving = "Saving..."
        static let authNeeded = "Please allow Apple Health to share sleep data with TapB4UNap"
    }

    // MARK: privates

    private let sleepManager = SleepManager()

    @IBOutlet weak private var statusMessageLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var adjustSleepButton: UIButton!
    @IBOutlet weak private var aboutButton: UIButton!
    @IBOutlet weak private var copyrightButton: UILabel!
    @IBOutlet weak private var aboutBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var copyrightBottomConstraint: NSLayoutConstraint!

    // MARK: controller code

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SaveDataViewController.resetUI), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func resetUI() {
        statusMessageLabel.text = "TapB4UNap"
        timeLabel.text = ""
        adjustSleepButton.hidden = true
    }

    func saveToHealthStore() {
        sleepManager.saveToHealthStore { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case .Success(let sleepSample):
                    log("SaveDataViewController, sleep data saved successfully")
                    self.statusMessageLabel.text = Strings.saveSuccess
                    self.timeLabel.text = sleepSample.formattedString()
                    self.adjustSleepButton.hidden = false
                case .Failure(let error):
                    log("SaveDataViewController saveToHealthStore error", error)
                    TimeKeeper().resetSleepData()
                }
            }
        }
    }

    /// Called by deeplink to adjust the time
    func adjust() {
        performSegueWithIdentifier("adjustSegue", sender: nil)
    }

    /// Should be called by `AppDelegate.applicationShouldRequestHealthAuthorization(_:)` when handling HealthKit authorization request from an extension
    func handleExtensionAuthorization() {
        self.statusMessageLabel.text = Strings.saving
        HealthStore.sharedInstance.handleExtensionAuthorization { result in

            if case .Failure(let error) = result {
                log("extension authorization failed", error)
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusMessageLabel.text = Strings.authNeeded
                    self.adjustSleepButton.hidden = true
                }
                return
            }

            /*
            If user authorizes quickly, control flow will go back to the widget via the original closure.
            However, that first auth request might timeout and fail silently if the user stays on the auth screen.
            If there is no recent sleep sample here, it means we need to try to save again.
            */
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                if let mostRecentSleepSample = TimeKeeper().mostRecentSleepSample() {
                    self.statusMessageLabel.text = Strings.saveSuccess
                    self.timeLabel.text = mostRecentSleepSample.formattedString()
                    self.adjustSleepButton.hidden = false
                } else {
                    self.saveToHealthStore() // try again
                }
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: unwind methods

    @IBAction func cancelToSaveDataViewController(segue: UIStoryboardSegue) {
    }

    @IBAction func saveAdjustedSleeptime(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? AdjustTimeTableViewController {
            let sleepSample = vc.sleepSample
            sleepManager.saveAdjustedSleepTimeToHealthStore(sleepSample) { result in
                dispatch_async(dispatch_get_main_queue()) {
                    switch result {
                    case .Success:
                        log("saveAdjustedSleeptime was successful")
                        self.statusMessageLabel.text = Strings.saveSuccess
                        self.timeLabel.text = sleepSample.formattedString()
                        self.adjustSleepButton.hidden = false
                    case .Failure(let error):
                        log("Error with saveAdjustedSleeptime", error)
                        self.statusMessageLabel.text = Strings.genericError
                        self.timeLabel.text = ""
                        self.adjustSleepButton.hidden = true
                    }
                }
            }
        }
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
