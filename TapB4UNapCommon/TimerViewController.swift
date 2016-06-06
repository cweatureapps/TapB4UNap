//
//  TimerViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 9/05/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import UIKit

protocol TimerViewControllerDelegate {
    func adjustButtonHandler()
}

class TimerViewController: UIViewController {

    var delegate: TimerViewControllerDelegate?

    // MARK: Privates

    private let sleepManager = SleepManager()
    private let timeKeeper = TimeKeeper()
    private var sleepTimer: NSTimer?

    // MARK: Outlets

    @IBOutlet weak private var sleepButton: UIButton!
    @IBOutlet weak private var resetButton: UIButton!
    @IBOutlet weak private var wakeButton: UIButton!
    @IBOutlet weak private var adjustButton: UIButton!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var timerLabel: UILabel!

    // MARK: UIViewController overrides

    override var nibName: String? {
        return "TimerViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clearColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
        if let sleepSample = timeKeeper.sleepSample() {
            if sleepSample.isSleeping() {
                startSleepingTimer()
            } else if sleepSample.canSave() {
                wake()
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        stopSleepingTimer()
        super.viewDidDisappear(animated)
    }

    // MARK: Button handlers

    @IBAction func sleepButtonHandler(sender: AnyObject) {
        sleepManager.startSleep { result in
            switch result {
            case .Success:
                self.startSleepingTimer()
            case .Failure(let error):
                log("sleep start failed", error)
                self.handleSleepManagerError(error)
            }
        }
    }

    @IBAction func resetButtonHandler(sender: AnyObject) {
        sleepManager.reset()
        refreshUI()
    }

    @IBAction func wakeButtonHandler(sender: AnyObject) {
        wake()
    }

    @IBAction func adjustButtonHandler(sender: AnyObject) {
        delegate?.adjustButtonHandler()
    }

    private func wake() {
        sleepManager.wakeIfNeeded { [weak self] result in
            switch result {
            case .Success:
                log("sleep data saved successfully!")
                self?.refreshUI()
            case .Failure(let error):
                log("widget save error", error)
                self?.handleSleepManagerError(error)
            }
        }
    }

    func handleSleepManagerError(error: ErrorType) {
        let errorMessage: String
        if let error = error as? TapB4UNapError,
            case TapB4UNapError.NotAuthorized  = error {
            errorMessage = "Please allow Apple Health to share sleep data with TapB4UNap"
        } else {
            errorMessage = "Sorry, something went wrong"
        }
        updateScreen(screenState: .Error)
        messageLabel.text = errorMessage
    }

    // MARK: sleeping timer

    func startSleepingTimer() {
        log("timer start")
        sleepTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:#selector(TimerViewController.timerHandler), userInfo:nil, repeats:true)
        sleepTimer!.fire()
    }

    func stopSleepingTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        log("timer stopped")
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
        guard !HealthStore.sharedInstance.isDenied() else {
            handleSleepManagerError(TapB4UNapError.NotAuthorized("status was already denied"))
            return
        }
        if var sleepSample = timeKeeper.sleepSample() {
            if sleepSample.isSleeping() {
                sleepSample.endDate = NSDate()
                let formattedTime = sleepSample.formattedString()
                updateScreen(screenState: .Sleeping)
                timerLabel.text = formattedTime
            }
        } else {
            if let mostRecentSleep = timeKeeper.mostRecentSleepSample() where timeKeeper.wasRecentlySaved() {
                updateScreen(screenState: .Finished)
                messageLabel.text = "You slept for \(mostRecentSleep.formattedString())"
            } else {
                updateScreen(screenState: .Begin)
                messageLabel.text = "Tap sleep to start"
            }
        }
    }

    private enum ScreenState {
        case Begin, Sleeping, Saving, Finished, Error
    }

    private func updateScreen(screenState screenState: ScreenState) {
        switch screenState {
        case .Begin:
            sleepButton.hidden = false
            resetButton.hidden = true
            wakeButton.hidden = true
            adjustButton.hidden = true
            messageLabel.hidden = false
            timerLabel.hidden = true
        case .Sleeping:
            sleepButton.hidden = true
            resetButton.hidden = false
            wakeButton.hidden = false
            adjustButton.hidden = true
            messageLabel.hidden = true
            timerLabel.hidden = false
        case .Saving: fallthrough
        case .Error:
            sleepButton.hidden = true
            resetButton.hidden = true
            wakeButton.hidden = true
            adjustButton.hidden = true
            messageLabel.hidden = false
            timerLabel.hidden = true
        case .Finished:
            sleepButton.hidden = true
            resetButton.hidden = false
            wakeButton.hidden = true
            adjustButton.hidden = false
            messageLabel.hidden = false
            timerLabel.hidden = true
        }
    }

}
