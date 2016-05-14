//
//  Utils.swift
//  TapB4UNap
//
//  Created by Ken Ko on 17/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation

func log(message: String, _ error: ErrorType? = nil, file: String = #file, function: String = #function) {
    let errorMessage = (error as? TapB4UNapError)?.errorMessage ?? ""
    var logMessage = "[ \((file as NSString).lastPathComponent) \(function) ] \(message)"
    logMessage += errorMessage.isEmpty ? "" : ": " + errorMessage
    print(logMessage)
}
