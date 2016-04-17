//
//  Errors.swift
//  TapB4UNap
//
//  Created by Ken Ko on 15/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation

enum TapB4UNapError: ErrorType {
    case NotAuthorized(String)
    case SaveFailed(String)
    case DeleteFailed(String)
    case OverwriteFailed(String)
    case QueryFailed(String)
    case Unknown(String)

    /// Parses the string description to get the associated value, and defaults to the name of the enum if the associated value is empty
    var errorMessage: String {
        guard let re = try? NSRegularExpression(pattern: "^.*\\(\"(.*)\"\\)", options: NSRegularExpressionOptions.CaseInsensitive) else { return "" }
        let s = String(self)
        let matches = re.matchesInString(s, options: [], range: NSRange(location: 0, length: s.utf16.count))
        let result = (s as NSString).substringWithRange(matches[0].rangeAtIndex(1))
        if result.isEmpty {
            return s.substringToIndex(s.rangeOfString("(")!.startIndex)
        } else {
            return result
        }
    }
}
