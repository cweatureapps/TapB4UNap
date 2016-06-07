//
//  TodayViewController.swift
//  TapB4UNapWidget
//
//  Created by Ken Ko on 24/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import NotificationCenter
import XCGLogger

class TodayViewController: UIViewController, NCWidgetProviding, TimerViewControllerDelegate {

    private let log: XCGLogger = ({
        Utils.configureLogger()
        return XCGLogger.defaultInstance()
    })()

    private weak var timerViewController: TimerViewController?

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let timerViewController = segue.destinationViewController as? TimerViewController {
            timerViewController.delegate = self
            self.timerViewController = timerViewController
        }
    }

    // MARK: NCWidgetProviding

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {

        // system calls occasionally so that it can preload the content in the background

        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        log.debug("widgetPerformUpdateWithCompletionHandler was called")

        timerViewController?.refreshUI()
        completionHandler(NCUpdateResult.NewData)
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        let newInsets = UIEdgeInsets(top:defaultMarginInsets.top, left:0, bottom:0, right:0)
        return newInsets
    }

    // MARK: TimerViewControllerDelegate

    func adjustButtonHandler() {
        extensionContext?.openURL(NSURL(string: "cwtapb4unap://adjust")!, completionHandler: nil)
    }

}
