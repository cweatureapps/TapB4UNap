//
//  LogUtils.swift
//  TapB4UNap
//
//  Created by Ken Ko on 17/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation
import XCGLogger

/// Logging related helper methods
struct LogUtils {
    private enum Constants {
        static let logfile = "tapb4unap.log"
    }

    static func logError(message: String, _ error: ErrorType) {
        let errorMessage = (error as? TapB4UNapError)?.errorMessage ?? ""
        let logMessage = message + (errorMessage.isEmpty ? "" : ": " + errorMessage)
        XCGLogger.defaultInstance().error(logMessage)
    }

    static func configureLogger() {
        let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let path = documentsDirectory.URLByAppendingPathComponent(Constants.logfile)
        let log = XCGLogger.defaultInstance()
        log.setup(.Debug, showThreadName: false, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: path, fileLogLevel: .Info)
        log.xcodeColorsEnabled = true

        log.removeLogDestination(XCGLogger.Constants.baseConsoleLogDestinationIdentifier)
        log.addLogDestination(XCGNSLogDestination(owner: log, identifier: XCGLogger.Constants.nslogDestinationIdentifier))
    }
}
