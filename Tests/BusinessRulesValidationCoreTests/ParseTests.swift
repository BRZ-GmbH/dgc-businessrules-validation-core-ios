/*
 * Copyright (c) 2022 BRZ GmbH &lt;https://www.brz.gv.at&gt;
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import XCTest
@testable import BusinessRulesValidationCore

final class ParseTests: BusinessRulesTest {

    func testParsingOfSimplePayload() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "simple")
        XCTAssertEqual(parsedPayload.profiles.count, 2)
        XCTAssertEqual(parsedPayload.profiles.first?.id, "Entry")
        XCTAssertEqual(parsedPayload.profiles.first?.localizedName.value(for: "de"), "Eintritt")
        XCTAssertEqual(parsedPayload.profiles.first?.localizedName.value(for: "en"), "Entry")
        
        XCTAssertEqual(parsedPayload.conditions.count, 26)
        guard let sampleCondition = parsedPayload.conditions["isNegativeTestResult"] else {
            XCTFail("Condition not found")
            return
        }
        XCTAssertNotNil(sampleCondition.logic)
        XCTAssertEqual(sampleCondition.localizedViolationDescription?.value(for: "de"), "Testresultat ist positiv")
        XCTAssertEqual(sampleCondition.localizedViolationDescription?.value(for: "en"), "Test result is positive")
        
        XCTAssertNoThrow(try sampleCondition.parsedJsonLogic())
        
        try parsedPayload.conditions.values.forEach { condition in
            XCTAssertNotNil(sampleCondition.logic)
            XCTAssertNoThrow(try sampleCondition.parsedJsonLogic())
        }
        
        XCTAssertEqual(parsedPayload.validate().count, 0)
    }
    
    func testParsingOfFullPayload() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "full")
        XCTAssertEqual(parsedPayload.profiles.count, 8)
        XCTAssertEqual(parsedPayload.profiles.first?.id, "Entry")
        XCTAssertEqual(parsedPayload.profiles.first?.localizedName.value(for: "de"), "Eintritt")
        XCTAssertEqual(parsedPayload.profiles.first?.localizedName.value(for: "en"), "Entry")
        
        XCTAssertEqual(parsedPayload.conditions.count, 26)
        guard let sampleCondition = parsedPayload.conditions["isNegativeTestResult"] else {
            XCTFail("Condition not found")
            return
        }
        XCTAssertNotNil(sampleCondition.logic)
        XCTAssertEqual(sampleCondition.localizedViolationDescription?.value(for: "de"), "Testresultat ist positiv")
        XCTAssertEqual(sampleCondition.localizedViolationDescription?.value(for: "en"), "Test result is positive")
        
        XCTAssertNoThrow(try sampleCondition.parsedJsonLogic())
        
        try parsedPayload.conditions.values.forEach { condition in
            XCTAssertNotNil(sampleCondition.logic)
            XCTAssertNoThrow(try sampleCondition.parsedJsonLogic())
        }
        
        XCTAssertEqual(parsedPayload.validate(), [])
    }
    
    func testParsingOfSimpleVaccinationRules() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "simple_vaccination")
        XCTAssertEqual(parsedPayload.profiles.count, 2)
        
        XCTAssertEqual(parsedPayload.conditions.count, 26)
        XCTAssertEqual(parsedPayload.validate(), [])
        XCTAssertEqual(parsedPayload.rules.count, 1)
    }
    
    func testParsingAndDeserializationOfFullPayload() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "full_spec")
        let encoded = try JSONEncoder().encode(parsedPayload)
        XCTAssertNotNil(encoded)
    }
    
    func testParsingOfValidityTime() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "parsing_validitytime")
        let ruleset = parsedPayload.rules.first?.ruleSetsByProfileId["Entry"]?.ruleSetsByGroupKey["all"]
        XCTAssertNotNil(ruleset)
        XCTAssertNotNil(ruleset?.validUntil)
        let validUntilList = ruleset!.validUntil!
        XCTAssertEqual(validUntilList.count, 4)
        XCTAssertEqual(validUntilList[0].format, .dateTime)
        XCTAssertEqual(validUntilList[1].format, .dateTime)
        XCTAssertEqual(validUntilList[2].format, .dateTime)
        XCTAssertEqual(validUntilList[3].format, .date)
    }
    
    func testParsingErrorReservedGroupName() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "validation_reserved_group_name")
        let errors = parsedPayload.validate()
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first, BusinessRulesSyntaxError.reservedTargetGroupName(targetGroupName: "all"))        
    }
    
    func testParsingWithoutRuleValidity() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "parsing_without_rule_validity")
        XCTAssertTrue(parsedPayload.rules.first?.validUntil.isEqualToTheDay(with: Date.distantFuture) == true)
        XCTAssertTrue(parsedPayload.rules.first?.validFrom.isEqualToTheDay(with: Date.distantPast) == true)
    }
}
