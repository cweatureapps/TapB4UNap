//
//  Result.swift
//  TapB4UNap
//
//  Created by Ken Ko on 15/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}
