//
//  Utils.swift
//  TapB4UNap
//
//  Created by Ken Ko on 17/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation
import XCGLogger

struct Utils {
    static func logError(message: String, _ error: ErrorType, file: String = #file, function: String = #function) {
        let errorMessage = (error as? TapB4UNapError)?.errorMessage ?? ""
        var logMessage = "[ \((file as NSString).lastPathComponent) \(function) ] \(message)"
        logMessage += errorMessage.isEmpty ? "" : ": " + errorMessage
        XCGLogger.defaultInstance().error(logMessage)
    }

    static func configureLogger() {
        let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let path = documentsDirectory.URLByAppendingPathComponent("tapb4unap.log")
        let log = XCGLogger.defaultInstance()
        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: path, fileLogLevel: .Debug)
        log.xcodeColorsEnabled = true
    }
}
