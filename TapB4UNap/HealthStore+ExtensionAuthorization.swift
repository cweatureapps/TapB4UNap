//
//  HealthStore+ExtensionAuthorization.swift
//  TapB4UNap
//
//  Created by Ken Ko on 17/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation
import HealthKit
import XCGLogger

extension HealthStore {
    /**
    Should be called by `AppDelegate.applicationShouldRequestHealthAuthorization(_:)` when handling HealthKit authorization request from an extension.
    This code cannot be included in the widget target, only the app target.
    */
    func handleExtensionAuthorization(completion: (Result<Void>) -> Void) {
        HKHealthStore().handleAuthorizationForExtensionWithCompletion { success, error in

            // do some logging
            let log = XCGLogger.defaultInstance()
            if success {
                log.info("healthkit authorization process completed by parent app")
            } else {
                log.error("something went wrong with HealthKit authorization. Error: \(error?.localizedDescription)")
            }

            // guard against not authorized
            guard HealthStore.sharedInstance.isAuthorized() else {
                log.error("not authorized after extension requested auth")
                completion(.Failure(TapB4UNapError.NotAuthorized("")))
                return
            }

            completion(.Success())
        }
    }
}
