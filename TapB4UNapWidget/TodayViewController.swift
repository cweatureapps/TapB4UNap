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

    // ------------------

    private let timeKeeper = TimeKeeper()
    private var timer:NSTimer?
    
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var wakeButton: UIButton!
    @IBOutlet weak var statusMessageLabel: UILabel!
    
    // ----- UIViewController -----
    
    override func viewDidLoad() {
        println("viewDidLoad was called")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        println("viewWillAppear was called")
        super.viewWillAppear(animated)
        
        refreshUI()
        if (timeKeeper.isSleeping()) {
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
    
    // ------ NCWidgetProviding -----
    
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
    
    // ------- handlers ------
    
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
    
    // -------- timer related --------
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
        if (!timeKeeper.isSleeping()) {
            stopTimer()
        }
        refreshUI()
    }

    // ------- UI updates -------

    func refreshUI() {
        if (timeKeeper.isSleeping()) {
            let formattedTime = timeKeeper.formattedTimeElapsedSleeping()
            if (statusMessageLabel.text != formattedTime) {
                statusMessageLabel.text = formattedTime
            }
            
            self.sleepButton.hidden = true
            self.cancelButton.hidden = false
            self.wakeButton.hidden = false
            
        } else if (timeKeeper.canSave()) {
            statusMessageLabel.text = "saving..."
            
            self.sleepButton.hidden = true
            self.cancelButton.hidden = true
            self.wakeButton.hidden = true
        } else {
            statusMessageLabel.text = "Tap sleep to start!"
            
            self.sleepButton.hidden = false
            self.cancelButton.hidden = true
            self.wakeButton.hidden = true
        }
    }
    
}
