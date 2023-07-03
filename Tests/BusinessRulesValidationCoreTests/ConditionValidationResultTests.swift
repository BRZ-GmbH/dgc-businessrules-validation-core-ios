//
/*
 * Copyright (c) 2022 BRZ GmbH <https://www.brz.gv.at>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import XCTest
@testable import BusinessRulesValidationCore

final class ConditionValidationResultTests: XCTestCase {
    
    func testFulfilled() {
        XCTAssertTrue(ConditionValidationResult.fulfilled.isFulfilled())
        XCTAssertFalse(ConditionValidationResult.violated(violation: ConditionViolation(condition: "condition", message: nil)).isFulfilled())
        XCTAssertFalse(ConditionValidationResult.failed(condition: "condition").isFulfilled())
    }
    
    func testFailed() {
        XCTAssertNil(ConditionValidationResult.fulfilled.failedCondition())
        XCTAssertNil(ConditionValidationResult.violated(violation: ConditionViolation(condition: "condition", message: nil)).failedCondition())
        XCTAssertEqual(ConditionValidationResult.failed(condition: "condition").failedCondition(), "condition")
    }
    
    func testViolated() {
        XCTAssertNil(ConditionValidationResult.fulfilled.violation())
        XCTAssertNil(ConditionValidationResult.failed(condition: "condition").violation())
        XCTAssertEqual(ConditionValidationResult.violated(violation: ConditionViolation(condition: "condition", message: nil)).violation(), ConditionViolation(condition: "condition", message: nil))
    }
    
}
