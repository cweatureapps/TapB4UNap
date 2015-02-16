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

    private let timeKeeper = TimeKeeper()
    private var timer:NSTimer?
    
    @IBOutlet weak private var sleepButton: UIButton!
    @IBOutlet weak private var cancelButton: UIButton!
    @IBOutlet weak private var wakeButton: UIButton!
    @IBOutlet weak private var statusMessageLabel: UILabel!
    
    // MARK: UIViewController overrides
    
    override func viewDidLoad() {
        println("viewDidLoad was called")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        println("viewWillAppear was called")
        super.viewWillAppear(animated)
        
        refreshUI()
        
        let sleepSample = timeKeeper.sleepSample()
        if (sleepSample.isSleeping()) {
            startTimer()
        }
    }
    
    override func viewWillDisappear(animated:Bool) {
        println("viewWillDisappear was called")
    }
    
    override func viewDidDisappear(animated:Bool) {
        println("viewDidDisappear was called")
        // for the today widget, this is called as soon as you swipe up to close the notification center.
        // stop the timer so it doesn't consume resources when notification center is not visible.
        stopTimer()
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
    
        // system calls occasionally so that it can preload the content in the background
    
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        println("widgetPerformUpdateWithCompletionHandler was called")
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
        startTimer()
    }
    
    @IBAction func cancelButtonHandler(sender: AnyObject) {
        timeKeeper.cancelSleep()
        refreshUI()
    }
    
    @IBAction func wakeButtonHandler(sender: AnyObject) {
        timeKeeper.endSleep(NSDate())
        refreshUI()
        saveUsingContainingApp()
    }
    
    private func saveUsingContainingApp() {
        let url = NSURL(scheme: "cwtapb4unap", host: nil, path: "/save")!
        extensionContext?.openURL(url, completionHandler: nil)
    }
    
    // MARK: timer related
    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:Selector("timerHandler"), userInfo:nil, repeats:true)
        timer!.fire()
    }
    
    private func stopTimer() {
        if (timer != nil) {
            timer!.invalidate()
            timer = nil;
            println("timer stopped")
        }
    }
    
    func timerHandler() {
        let sleepSample = timeKeeper.sleepSample()
        if (!sleepSample.isSleeping()) {
            stopTimer()
        }
        refreshUI()
    }

    // MARK: UI updates

    func refreshUI() {
        var sleepSample = timeKeeper.sleepSample()
        if (sleepSample.isSleeping()) {

            sleepSample.endDate = NSDate()
            let formattedTime = sleepSample.formattedString()
            if (statusMessageLabel.text != formattedTime) {
                statusMessageLabel.text = formattedTime
            }
            
            sleepButton.hidden = true
            cancelButton.hidden = false
            wakeButton.hidden = false
            
        } else if (sleepSample.canSave()) {
            statusMessageLabel.text = "saving..."
            
            sleepButton.hidden = true
            cancelButton.hidden = true
            wakeButton.hidden = true
        } else {
            statusMessageLabel.text = "Tap sleep to start!"
            
            sleepButton.hidden = false
            cancelButton.hidden = true
            wakeButton.hidden = true
        }
    }
    
}
