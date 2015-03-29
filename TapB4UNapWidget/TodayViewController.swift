//
//  TodayViewController.swift
//  TapB4UNapWidget
//
//  Created by Ken Ko on 24/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import NotificationCenter
import Parse

class TodayViewController: UIViewController, NCWidgetProviding {

    // MARK: Privates

    private let timeKeeper = TimeKeeper()
    private var sleepTimer:NSTimer?
    private var pushCompletionTimer:NSTimer?
    private var pollingCount = 0
    
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
        
        if let sleepSample = timeKeeper.sleepSample() {
            if sleepSample.isSleeping() {
                startSleepingTimer()
            }
        }
    }
    
    override func viewWillDisappear(animated:Bool) {
        println("viewWillDisappear was called")
    }
    
    override func viewDidDisappear(animated:Bool) {
        println("viewDidDisappear was called")
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
        startSleepingTimer()
    }
    
    @IBAction func cancelButtonHandler(sender: AnyObject) {
        timeKeeper.resetSleepData()
        refreshUI()
    }
    
    @IBAction func wakeButtonHandler(sender: AnyObject) {
        stopSleepingTimer()
        timeKeeper.endSleep(NSDate())
        refreshUI()
        saveUsingPushNotification()
    }
    
    @IBAction func wakeLongPressHandler(sender: UILongPressGestureRecognizer) {
        stopSleepingTimer()
        timeKeeper.endSleepIfNeeded(NSDate())
        refreshUI()
        saveUsingContainingApp()
    }
    
    private func saveUsingContainingApp() {
        extensionContext?.openURL(NSURL(string: "cwtapb4unap://save")!, completionHandler: nil)
    }
    
    // MARK: sleeping timer
    private func startSleepingTimer() {
        sleepTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:Selector("timerHandler"), userInfo:nil, repeats:true)
        sleepTimer!.fire()
    }
    
    private func stopSleepingTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil;
        println("timer stopped")
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
                
            } else if sleepSample.canSave() {
                statusMessageLabel.text = "saving."
                
                sleepButton.hidden = true
                cancelButton.hidden = false
                wakeButton.hidden = false
            }
        } else {
            statusMessageLabel.text = "Tap sleep to start!"
            
            sleepButton.hidden = false
            cancelButton.hidden = true
            wakeButton.hidden = true
        }
    }
    
    // MARK: push notification
    
    private func saveUsingPushNotification() {
        let pushWasSent = sendSilentPush()
        if (pushWasSent) {
            self.pollingCount = 0;
            pollForSaveCompletion()
        } else {
            self.saveUsingContainingApp()
        }
    }
    
    private func sendSilentPush() -> Bool {
    
        println("attempting to send silent push")
        if let
            appId = SettingsManager.stringForKey(.ParseAppId),
            clientKey = SettingsManager.stringForKey(.ParseClientKey)
        {
            Parse.setApplicationId(appId, clientKey: clientKey)
            
            let data = ["content-available":"1", "sound":""]
        
            let push = PFPush()
            push.setChannel("global")
            push.setData(data)
            push.sendPushInBackgroundWithBlock(nil)
            
            return true
        }
        println("Parse settings not available, cannot send push")
        return false
    }
    
    private func pollForSaveCompletion() {
        pushCompletionTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:Selector("checkForSaveCompletion"), userInfo:nil, repeats:true)
        pushCompletionTimer!.fire()
    }
    
    private func pollingForSaveCompletionDidComplete() {
        self.pollingCount = 0;
        pushCompletionTimer?.invalidate()
        pushCompletionTimer = nil;
    }
    
    func checkForSaveCompletion() {
        println("checkForSaveCompletion, pollingCount is \(self.pollingCount)")
        
        let sleepSample = self.timeKeeper.sleepSample()
        let mostRecentSleep = self.timeKeeper.mostRecentSleepSample()
        
        // sucessfully saved
        if sleepSample == nil {
            pollingForSaveCompletionDidComplete()
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshUI()
                self.statusMessageLabel.text = mostRecentSleep?.formattedString()
                
                // refresh again after 3 seconds to remove the message
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                    self.refreshUI()
                }
            }
            
        // poll up to 10 times before falling back to saving using containing app
        } else if sleepSample!.canSave() {
            self.pollingCount++
            if self.pollingCount <= 10 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusMessageLabel.text = self.statusMessageLabel.text! + "."
                }
            } else {
                pollingForSaveCompletionDidComplete()
                self.saveUsingContainingApp()
            }
        }
    }
    
}
