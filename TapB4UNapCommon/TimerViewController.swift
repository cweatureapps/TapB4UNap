//
//  TimerViewController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 9/05/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import UIKit
import XCGLogger

protocol TimerViewControllerDelegate {
    func addButtonTapped()
    func editButtonTapped()
}

class TimerViewController: UIViewController {

    // Constants

    private enum Constants {
        static let animationDuration = 0.6
        static let m34: CGFloat = 1.0 / -180
        static let m34Less: CGFloat = 1.0 / -300
    }

    private let log = XCGLogger.defaultInstance()

    // MARK: Public properties

    var delegate: TimerViewControllerDelegate?

    // MARK: Privates

    private let sleepManager = SleepManager()
    private let timeKeeper = TimeKeeper()
    private var sleepTimer: NSTimer?

    // MARK: Outlets

    @IBOutlet var beginView: DashboardView!
    @IBOutlet var sleepingView: DashboardView!
    @IBOutlet var finishView: DashboardView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var monitoringLocationView: UIView!

    // MARK: UIViewController overrides

    override var nibName: String? {
        return "TimerViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clearColor()
        errorLabel.text = ""
        monitoringLocationView.alpha = 0.0

        beginView.setupButtons(target: self, button1Action: .addTapped, button2Action: .sleepTapped)
        sleepingView.setupButtons(target: self, button1Action: .cancelTapped, button2Action: .wakeTapped)
        finishView.setupButtons(target: self, button1Action: .editTapped, button2Action: .doneTapped)
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
        if let sleepSample = timeKeeper.sleepSample() {
            if sleepSample.isSleeping() {
                startSleepingTimer()
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        stopSleepingTimer()
        super.viewDidDisappear(animated)
    }

    // MARK: Button handlers

    func addTapped() {
        delegate?.addButtonTapped()
    }

    func sleepTapped() {
        sleepManager.startSleep { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .Success:
                this.startSleepingTimer()
            case .Failure(let error):
                LogUtils.logError("sleep start failed", error)
                this.handleSleepManagerError(error)
            }
        }
    }

    func cancelTapped() {
        sleepManager.reset()
        animateToDashboardView(beginView, direction: .Back)
    }

    func wakeTapped() {
        sleepManager.wakeIfNeeded { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .Success:
                this.log.debug("sleep data saved successfully!")
                this.refreshUI()
            case .Failure(let error):
                LogUtils.logError("widget save error", error)
                this.handleSleepManagerError(error)
            }
        }
    }

    func editTapped() {
        delegate?.editButtonTapped()
    }

    func doneTapped() {
        sleepManager.reset()
        self.animateToDashboardView(beginView, direction: .Forward)
    }

    func handleSleepManagerError(error: ErrorType) {
        let errorMessage: String
        if let error = error as? TapB4UNapError,
            case TapB4UNapError.NotAuthorized  = error {
            errorMessage = "Please allow Apple Health to share sleep data with TapB4UNap"
        } else {
            errorMessage = "Sorry, something went wrong"
        }

        errorLabel.text = errorMessage
        beginView.hide()
        sleepingView.hide()
        finishView.hide()
        currentView = nil
    }

    // MARK: sleeping timer

    func startSleepingTimer() {
        log.debug("timer start")
        sleepTimer?.invalidate()
        sleepTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:#selector(TimerViewController.timerHandler), userInfo:nil, repeats:true)
        sleepTimer!.fire()
    }

    func stopSleepingTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        log.debug("timer stopped")
    }

    func timerHandler() {
        if HealthStore.sharedInstance.isAuthorizationNotDetermined() {
            stopSleepingTimer()
        } else if let sleepSample = timeKeeper.sleepSample() {
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

        guard !HealthStore.sharedInstance.isAuthorizationNotDetermined() else {
            animateToDashboardView(beginView, direction: .Forward)
            return
        }

        guard !HealthStore.sharedInstance.isAuthorizationDenied() else {
            handleSleepManagerError(TapB4UNapError.NotAuthorized("status was already denied"))
            return
        }

        errorLabel.text = ""
        if var sleepSample = timeKeeper.sleepSample() {
            if sleepSample.isSleeping() {
                sleepSample.endDate = NSDate()
                let formattedTime = sleepSample.formattedString()
                sleepingView.messageLabel.text = formattedTime
                animateToDashboardView(sleepingView, direction: .Forward)
            }
        } else {
            if let mostRecentSleep = timeKeeper.mostRecentSleepSample() where timeKeeper.wasRecentlySaved() {
                finishView.messageLabel.text = "You slept for \(mostRecentSleep.formattedString())"
                animateToDashboardView(finishView, direction: .Forward)
            } else {
                animateToDashboardView(beginView, direction: .Forward)
            }
        }

        refreshLocationView()
    }

    private func refreshLocationView() {
        func animateLocationViewAlpha(alpha: CGFloat) {
            if monitoringLocationView.alpha != alpha {
                UIView.animateWithDuration(Constants.animationDuration) {
                    self.monitoringLocationView.alpha = alpha
                }
            }
        }
        if LocationManager.sharedInstance.isMonitoring {
            animateLocationViewAlpha(1.0)
        } else {
            animateLocationViewAlpha(0.0)
        }
    }

    // MARK: - Animations

    private var currentView: DashboardView?

    private enum ButtonTransitionDirection {
        case Forward, Back
    }

    private func animateToDashboardView(view2: DashboardView, direction: ButtonTransitionDirection) {
        guard currentView != view2 else { return }
        guard let currentView = currentView else {
            self.currentView = view2
            UIView.animateWithDuration(Constants.animationDuration, animations: {
                view2.show()
                self.view.bringSubviewToFront(view2)
            })
            return
        }
        self.currentView = view2
        animateFromView(currentView.button1, toView: view2.button1, direction: direction, m34: Constants.m34)
        animateFromView(currentView.button2, toView: view2.button2, direction: direction, m34: Constants.m34)
        animateFromView(currentView.messageLabel, toView: view2.messageLabel, direction: direction, m34: Constants.m34Less)
        view.bringSubviewToFront(view2)
    }

    private func animateFromView(view1: UIView, toView view2: UIView, direction: ButtonTransitionDirection, m34: CGFloat) {
        func performTransition(button1EndAngle button1EndAngle: CGFloat, button2StartAngle: CGFloat) {
            // animate view 1
            UIView.animateWithDuration(Constants.animationDuration/2.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = m34
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, button1EndAngle, 0.0, 1.0, 0.0)
                view1.layer.transform = rotationAndPerspectiveTransform

            }) { _ in
                // hide and reset view 1
                view1.alpha = 0.0
                view1.layer.transform = CATransform3DIdentity

                // set starting posiition for view 2
                view2.layer.transform = CATransform3DMakeRotation(button2StartAngle, 0.0, 1.0, 0.0)
                view2.alpha = 1.0

                // animate view 2
                UIView.animateWithDuration(Constants.animationDuration/2.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    var rotationAndPerspectiveTransform = CATransform3DIdentity
                    rotationAndPerspectiveTransform.m34 = m34
                    view2.layer.transform = rotationAndPerspectiveTransform
                }, completion: nil)
            }
        }
        switch direction {
            case .Back:
                let view1EndAngle = CGFloat(M_PI)/2
                let view2StartAngle = -CGFloat(M_PI)/2
                performTransition(button1EndAngle: view1EndAngle, button2StartAngle: view2StartAngle)
            case .Forward:
                let view1EndAngle = -CGFloat(M_PI)/2
                let view2StartAngle = CGFloat(M_PI)/2
                performTransition(button1EndAngle: view1EndAngle, button2StartAngle: view2StartAngle)

        }
    }
}

private extension Selector {
    static let addTapped = #selector(TimerViewController.addTapped)
    static let sleepTapped = #selector(TimerViewController.sleepTapped)
    static let cancelTapped = #selector(TimerViewController.cancelTapped)
    static let wakeTapped = #selector(TimerViewController.wakeTapped)
    static let editTapped = #selector(TimerViewController.editTapped)
    static let doneTapped = #selector(TimerViewController.doneTapped)
}
