//
//  AppDelegate.swift
//  TapB4UNap
//
//  Created by Ken Ko on 20/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private let sleepManager = SleepManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        
        if let
            appId = SettingsManager.stringForKey(.ParseAppId),
            clientKey = SettingsManager.stringForKey(.ParseClientKey)
        {
            SettingsManager.registerDefaultsFromPlist()
            
            Parse.setApplicationId(appId, clientKey: clientKey)
            
            let settings = UIUserNotificationSettings(forTypes:(UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound), categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        // handle the url scheme "cwtapb4unap://save" and save to the HealthStore
        if let ctrl = window?.rootViewController as? SaveDataController {
            if url.absoluteString == "cwtapb4unap://save" {
                ctrl.saveToHealthStore()
            }
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:  NSData) {
        println("didRegisterForRemoteNotificationsWithDeviceToken was called, deviceToken: \(deviceToken)")
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackgroundWithBlock(nil)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        if let
            aps = userInfo["aps"] as? [String: AnyObject],
            contentAvailable = aps["content-available"] as? Int
            where contentAvailable == 1
        {
            // silent notification
            println("silent notification received")
            sleepManager.handleSilentNotification()
            completionHandler(UIBackgroundFetchResult.NewData);
        } else {
            PFPush.handlePush(userInfo)
        }
    }

}

