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

final class RuleValidityTests: BusinessRulesTest {
    
    func testValidationBeforeValidFrom() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination", validationClock: ISO8601DateFormatter().date(from: "2021-01-01T21:59:59Z")!)
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNil(validationResult)
    }
    
    func testValidationAfterValidUntil() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination", validationClock: ISO8601DateFormatter().date(from: "2030-06-01T00:00:01Z")!)
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNil(validationResult)
    }
    
    func testInvalidTargetGroup() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "validation_unknown_group")
        let validation = parsedPayload.validate()
        XCTAssertEqual(validation.count, 1)
        XCTAssertEqual(validation.first, BusinessRulesSyntaxError.unavailableTargetGroup(targetGroup: "childrenUnknown"))
    }
    
    func testInvalidMultichain() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "validation_unallowed_multichain")
        let validation = parsedPayload.validate()
        XCTAssertEqual(validation.count, 1)
        XCTAssertEqual(validation.first, BusinessRulesSyntaxError.unallowedMultistepProfileChain(profile: "Club", targetGroup: "all"))
    }
    
    func testUnknownCondition() throws {
        let parsedPayload = try getBusinessRules(rulesPath: "validation_unknown_condition")
        let validation = parsedPayload.validate()
        XCTAssertEqual(validation.count, 4)
        XCTAssertTrue(validation.contains(BusinessRulesSyntaxError.unavailableCondition(conditionName: "isSomeUnknownCertificateTypeCondition")))
        XCTAssertTrue(validation.contains(BusinessRulesSyntaxError.unavailableCondition(conditionName: "isSomeUnknownGeneralCondition")))
        XCTAssertTrue(validation.contains(BusinessRulesSyntaxError.unavailableCondition(conditionName: "isSomeUnknownCondition")))
        XCTAssertTrue(validation.contains(BusinessRulesSyntaxError.unavailableCondition(conditionName: "isAnotherUnknownCondition")))
    }
}
