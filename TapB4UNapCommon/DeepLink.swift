//
//  DeepLink.swift
//  TapB4UNap
//
//  Created by Ken Ko on 14/06/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation

enum DeepLink: String {
    case Add = "cwtapb4unap://add"
    case Edit = "cwtapb4unap://edit"

    var url: NSURL {
        return NSURL(string: self.rawValue)!
    }
}
