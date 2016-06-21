//
//  AppDelegate.swift
//  TapB4UNap
//
//  Created by Ken Ko on 20/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import XCGLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LocationManagerDelegate {

    let log = XCGLogger.defaultInstance()

    var window: UIWindow?

    private var rootViewController: MainViewController? {
        guard let tabController = window?.rootViewController as? UITabBarController,
            mainViewController = tabController.viewControllers?.first as? MainViewController else { return nil }
        return mainViewController
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        LogUtils.configureLogger()
        log.debug("didFinishLaunchingWithOptions called")
        registerNotifications()

        // handle launch due to location update
        if let _ = launchOptions?[UIApplicationLaunchOptionsLocationKey] {
            log.info("app was launched due to location update")
            didExitRegion()
            return true  // return early to prevent LocationManagerDelegate from receiving a second region exit message
        }

        // Start receiving location region update
        LocationManager.sharedInstance.delegate = self

        // handle launch from local notification when app is terminated
        if let _ = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] {
            log.info("app was launched due to local notification")
            wakeIfNeeded()
        }

        return true
    }

    private func registerNotifications() {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        guard let rootViewController = rootViewController, deepLink = DeepLink(rawValue: url.absoluteString) else {
            return false
        }
        switch deepLink {
            case .Add:
                rootViewController.addButtonTapped()
            case .Edit:
                rootViewController.editButtonTapped()
        }
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {

        // User manually taps on a previous notification while the app is suspended.
        // This includes when the user pulls down the notification view over the top of the active app.
        if application.applicationState == .Inactive {
            log.debug("local notification received in Inactive state")
            if let alertDate = notification.userInfo?["alertDate"] as? NSDate {
                let secondsSinceFiring = (NSDate()).timeIntervalSinceDate(alertDate)
                log.debug("local notification was fired \(secondsSinceFiring) seconds ago")

                // If notification center is over the top of the app when region exit fires,
                // dont wake without user intervention.
                // We can only tell the difference of this scenario by the fact it's just fired a fraction of a second ago.
                // If the user manually taps on a previous notification, the secondsSinceFiring will be a much larger value.
                if secondsSinceFiring > 0.2 {
                    wakeIfNeeded()
                }
            }

        // When the app is in the foreground, and a notification is received, due to `didExitRegion` firing.
        // Prompt user because they didn't explictly say they want to wake.
        } else if application.applicationState == .Active {
            log.debug("local notification received in Active state")
            let alertController = UIAlertController(title: "", message: "Looks like you've moved from your sleep location, tap OK to wake", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Default) { _ in
                self.wakeIfNeeded()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style:.Cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        rootViewController?.handleExtensionAuthorization()
    }

    // MARK: - LocationManagerDelegate

    func didExitRegion() {
        log.info("AppDelegate didExitRegion called")
        let notification = UILocalNotification()
        notification.alertBody = "It looks like you are awake... do you want to stop recording sleep?"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        notification.userInfo = ["alertDate": NSDate()]
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

    private func wakeIfNeeded() {
        log.debug("AppDelegate wakeIfNeeded called")
        SleepManager().wakeIfNeeded(nil)
    }
}
