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

final class ExternalConditionParsingTests: XCTestCase {
    
    func testExternalConditionCheck() {
        XCTAssertTrue("ext.".isExternalCondition)
        XCTAssertTrue("ext.Test".isExternalCondition)
        XCTAssertFalse(" ext.".isExternalCondition)
        XCTAssertTrue("ext.ext.".isExternalCondition)
        XCTAssertFalse("Ext.".isExternalCondition)
        XCTAssertFalse("ext:".isExternalCondition)
    }
    
    func testExternalConditionNameWithArguments() {
        var parsedConditions = "ext.hasSomeCertificate".externalConditionNameAndArguments
        XCTAssertNotNil(parsedConditions)
        XCTAssertEqual(parsedConditions!.condition, "hasSomeCertificate")
        XCTAssertTrue(parsedConditions?.parameters.isEmpty == true)
        
        parsedConditions = "ext.hasSomeCertificate(withBracket)".externalConditionNameAndArguments
        XCTAssertNotNil(parsedConditions)
        XCTAssertEqual(parsedConditions!.condition, "hasSomeCertificate(withBracket)")
        XCTAssertTrue(parsedConditions?.parameters.isEmpty == true)
    }
    
    func testInvalidExternalConditionName() {
        XCTAssertNil("hasSomeCertificate".externalConditionNameAndArguments)
        XCTAssertNil(" ext.hasSomeCertificate".externalConditionNameAndArguments)
        XCTAssertNil("test.ext.hasSomeCertificate".externalConditionNameAndArguments)
    }
    
    func testExternalConditionWithMultipleParameters() {
        var parsedConditions = "ext.hasSomeCertificate__type:test__24hours".externalConditionNameAndArguments
        XCTAssertNotNil(parsedConditions)
        XCTAssertEqual(parsedConditions!.condition, "hasSomeCertificate")
        XCTAssertEqual(parsedConditions!.parameters.count, 1)
        XCTAssertEqual(parsedConditions!.parameters["type"], "test")
        
        parsedConditions = "ext.hasSomeCertificate__type:Recovery__duration:180__unit:Days".externalConditionNameAndArguments
        XCTAssertNotNil(parsedConditions)
        XCTAssertEqual(parsedConditions!.condition, "hasSomeCertificate")
        XCTAssertEqual(parsedConditions!.parameters.count, 3)
        XCTAssertEqual(parsedConditions!.parameters["type"], "Recovery")
        XCTAssertEqual(parsedConditions!.parameters["duration"], "180")
        XCTAssertEqual(parsedConditions!.parameters["unit"], "Days")
    }
    
    func testEmptyValues() {
        var parsedConditions = "ext.".externalConditionNameAndArguments
        XCTAssertNil(parsedConditions)
        
        parsedConditions = "ext.hasSomeCertificate_".externalConditionNameAndArguments
        XCTAssertNotNil(parsedConditions)
        XCTAssertTrue(parsedConditions?.parameters.isEmpty == true)
        
        parsedConditions = "ext.hasSomeCertificate___".externalConditionNameAndArguments
        XCTAssertNotNil(parsedConditions)
        XCTAssertTrue(parsedConditions?.parameters.isEmpty == true)
        
        parsedConditions = "ext.hasSomeCertificate_test__duration:24__unit:hours__".externalConditionNameAndArguments
        XCTAssertNotNil(parsedConditions)
        XCTAssertEqual(parsedConditions?.parameters["duration"], "24")
        XCTAssertEqual(parsedConditions?.parameters["unit"], "hours")
    }
}
