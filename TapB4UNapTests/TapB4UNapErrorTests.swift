//
//  TapB4UNapErrorTests.swift
//  TapB4UNap
//
//  Created by Ken Ko on 17/04/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import XCTest
@testable import TapB4UNap

class TapB4UNapErrorTests: XCTestCase {
    func testErrorMessageHavingMessage() {
        let error = TapB4UNapError.NotAuthorized("something")
        XCTAssertEqual(error.errorMessage, "something")

        let error2 = TapB4UNapError.NotAuthorized("something with spaces")
        XCTAssertEqual(error2.errorMessage, "something with spaces")
    }

    func testErrorMessageBlankMessage() {
        let error = TapB4UNapError.NotAuthorized("")
        XCTAssertEqual(error.errorMessage, "NotAuthorized")
    }
}
