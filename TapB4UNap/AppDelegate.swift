//
//  AppDelegate.swift
//  TapB4UNap
//
//  Created by Ken Ko on 20/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var rootViewController: MainViewController? {
        guard let tabController = window?.rootViewController as? UITabBarController,
            mainViewController = tabController.viewControllers?.first as? MainViewController else { return nil }
        return mainViewController
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        switch url.absoluteString {
            case "cwtapb4unap://adjust":
                rootViewController?.adjust()
            case "cwtapb4unap://reset":
                TimeKeeper().resetSleepData()
            default:
                return false
        }
        return true
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
}
