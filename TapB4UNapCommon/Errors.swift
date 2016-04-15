//
//  Errors.swift
//  TapB4UNap
//
//  Created by Ken Ko on 15/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation

enum HealthStoreError: ErrorType {
    case NotAuthorized(String?)
    case SaveFailed(String?)
    case DeleteFailed(String?)
    case OverwriteFailed(String?)
    case QueryFailed(String?)
    case Unknown(String?)
}

enum SleepManagerError: ErrorType {
    case SaveFailed(String?)
}
