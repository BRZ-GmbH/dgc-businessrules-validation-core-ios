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

final class EqualityTests: XCTestCase {
    
    private func localizedValueFrom(_ value: [String:String]) -> LocalizedValue<String> {
        return try! JSONDecoder().decode(LocalizedValue<String>.self, from: try! JSONEncoder().encode(value))
    }
    
    func testConditionViolation() {
        XCTAssertEqual(ConditionViolation(condition: "condition", message: nil), ConditionViolation(condition: "condition", message: nil))
        XCTAssertEqual(ConditionViolation(condition: "condition", message: nil), ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test", "en": "test"])))
        XCTAssertEqual(ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test"])), ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test", "en": "test"])))
       XCTAssertNotEqual(ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test", "en": "test"])), ConditionViolation(condition: "Condition", message: localizedValueFrom(["de": "test", "en": "test"])))
    }
    
    func testBusinessRuleValidationLinkedConditionResult() {
        XCTAssertEqual(BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition"]), BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition"]))
        XCTAssertEqual(BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["condition"]), BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition"]))
        XCTAssertEqual(BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition"]), BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["condition"]))
        
        XCTAssertEqual(BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom(["de": "test", "en": "test"]), conditions: ["condition"]), BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition"]))
        
        
        XCTAssertNotEqual(BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition"]), BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["Condition"]))
        XCTAssertNotEqual(BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition"]), BusinessRuleValidationLinkedConditionResult(violationMessage: localizedValueFrom([:]), conditions: ["condition", "condition2"]))
    }
    
    func testBusinessRuleValidationResult() {
        let timeinterval = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: timeinterval)
        let sameDate = Date(timeIntervalSince1970: timeinterval)
    
        let anotherDate = Date().addingTimeInterval(-20)
        
        // Check equality check for profile and region
        var result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        var result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "NG", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "NOE", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)

        // Check equality check for valid from
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: date, format: .date, conditions: ["condition"])], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: sameDate, format: .date, conditions: ["condition"])], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: date, format: .date, conditions: ["condition1"])], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: sameDate, format: .date, conditions: ["condition2"])], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: date, format: .date, conditions: ["condition"])], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: date, format: .date, conditions: ["condition2"])], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        // Check equality check for valid until
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [ValidityTimeResult(time: date, format: .date, conditions: ["condition"])], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [ValidityTimeResult(time: sameDate, format: .date, conditions: ["condition"])], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [ValidityTimeResult(time: date, format: .date, conditions: ["condition1"])], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [ValidityTimeResult(time: sameDate, format: .date, conditions: ["condition2"])], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [ValidityTimeResult(time: date, format: .date, conditions: ["condition"])], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [ValidityTimeResult(time: date, format: .date, conditions: ["condition2"])], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        // Check equality check for matchingLinkedConditions
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test"])], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test"])], violatedOrFailedLinkedConditions: [])
        XCTAssertEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test"])], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test1"])], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"]), BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test 3"])], violatedOrFailedLinkedConditions: [])
        XCTAssertNotEqual(result1, result2)
        
        // Check equality check for violatedOrFailedLinkedConditions
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test"])])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test"])])
        XCTAssertEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test"])])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test1"])])
        XCTAssertNotEqual(result1, result2)
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])])
        XCTAssertNotEqual(result1, result2)
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"]), BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test 3"])])
        XCTAssertNotEqual(result1, result2)
    }
    
    func testValidationResult() {
        XCTAssertEqual(ValidationResult.invalid(violations: []), ValidationResult.invalid(violations: []))
        XCTAssertEqual(ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: nil)]), ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test"]))]))
        XCTAssertEqual(ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test"]))]), ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: nil)]))
        XCTAssertEqual(ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test"]))]), ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test", "en": "test"]))]))
        XCTAssertNotEqual(ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: nil)]), ValidationResult.invalid(violations: [ConditionViolation(condition: "condition1", message: localizedValueFrom(["de": "test"]))]))
        XCTAssertNotEqual(ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: nil)]), ValidationResult.invalid(violations: [ConditionViolation(condition: "Condition", message: localizedValueFrom(["de": "test"]))]))
        XCTAssertNotEqual(ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: nil)]), ValidationResult.invalid(violations: [ConditionViolation(condition: "condition", message: localizedValueFrom(["de": "test"])), ConditionViolation(condition: "condition", message: nil)]))
        
        XCTAssertEqual(ValidationResult.error(failedConditions: []), ValidationResult.error(failedConditions: []))
        XCTAssertEqual(ValidationResult.error(failedConditions: ["test"]), ValidationResult.error(failedConditions: ["test"]))
        XCTAssertEqual(ValidationResult.error(failedConditions: ["test", "Test"]), ValidationResult.error(failedConditions: ["test", "Test"]))
        XCTAssertNotEqual(ValidationResult.error(failedConditions: ["Test", "test"]), ValidationResult.error(failedConditions: ["test", "Test"]))
        XCTAssertNotEqual(ValidationResult.error(failedConditions: ["test", "Test"]), ValidationResult.error(failedConditions: ["test", "Test", "X"]))
        
        XCTAssertNotEqual(ValidationResult.invalid(violations: []), ValidationResult.error(failedConditions: []))
        XCTAssertNotEqual(ValidationResult.valid(result: BusinessRuleValidationResult(profile: "", region: "", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])), ValidationResult.error(failedConditions: []))
        
        var result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [])
        var result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])])
        XCTAssertNotEqual(ValidationResult.valid(result: result1), ValidationResult.valid(result: result2))
        
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [], validUntil: [], matchingLinkedConditions: [], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"]), BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test 3"])])
        XCTAssertNotEqual(ValidationResult.valid(result: result1), ValidationResult.valid(result: result2))
        
        let timeinterval = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: timeinterval)
        let sameDate = Date(timeIntervalSince1970: timeinterval)
        
        let anotherDate = Date(timeIntervalSince1970: timeinterval - 20)
        let anotherSameDate = Date(timeIntervalSince1970: timeinterval - 20)
            
        result1 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: date, format: .dateTime, conditions: ["condition"])], validUntil: [ValidityTimeResult(time: anotherDate, format: .date, conditions: [])], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Condition1"])], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])])
        result2 = BusinessRuleValidationResult(profile: "W", region: "ET", validFrom: [ValidityTimeResult(time: sameDate, format: .dateTime, conditions: ["condition"])], validUntil: [ValidityTimeResult(time: anotherSameDate, format: .date, conditions: [])], matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Condition1"])], violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult(violationMessage: nil, conditions: ["Test", "Test 2"])])
        XCTAssertEqual(ValidationResult.valid(result: result1), ValidationResult.valid(result: result2))
    }
    
    func testValidityTimeResult() {
        let timeinterval = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: timeinterval)
        let sameDate = Date(timeIntervalSince1970: timeinterval)
    
        let anotherDate = Date().addingTimeInterval(-20)
        
        XCTAssertEqual(ValidityTimeResult(time: date, format: .date, conditions: nil), ValidityTimeResult(time: sameDate, format: .date, conditions: nil))
        XCTAssertNotEqual(ValidityTimeResult(time: date, format: .date, conditions: nil), ValidityTimeResult(time: sameDate, format: .dateTime, conditions: nil))
        XCTAssertEqual(ValidityTimeResult(time: date, format: .date, conditions: nil), ValidityTimeResult(time: sameDate, format: .date, conditions: []))
        XCTAssertEqual(ValidityTimeResult(time: date, format: .date, conditions: []), ValidityTimeResult(time: sameDate, format: .date, conditions: nil))
        XCTAssertNotEqual(ValidityTimeResult(time: date, format: .date, conditions: ["Test"]), ValidityTimeResult(time: sameDate, format: .date, conditions: nil))
        XCTAssertNotEqual(ValidityTimeResult(time: date, format: .date, conditions: ["Test"]), ValidityTimeResult(time: sameDate, format: .date, conditions: ["test"]))
        XCTAssertNotEqual(ValidityTimeResult(time: date, format: .date, conditions: ["test", "Test"]), ValidityTimeResult(time: sameDate, format: .date, conditions: ["Test", "test"]))
        XCTAssertNotEqual(ValidityTimeResult(time: date, format: .date, conditions: ["test"]), ValidityTimeResult(time: sameDate, format: .date, conditions: ["test", "Test"]))
        
        XCTAssertNotEqual(ValidityTimeResult(time: date, format: .date, conditions: ["test", "Test"]), ValidityTimeResult(time: anotherDate, format: .date, conditions: ["Test", "test"]))
        XCTAssertNotEqual(ValidityTimeResult(time: date, format: .date, conditions: nil), ValidityTimeResult(time: anotherDate, format: .date, conditions: nil))
    }
}
