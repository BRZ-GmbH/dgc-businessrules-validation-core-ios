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

final class SimpleTestCertificateTests: BusinessRulesTest {
    
    func testSimpleEvaluationForPCRTestOf8YearOld() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_tests")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (52, 0), dateOfBirthAge: (8, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        guard case let .valid(result: result) = validationResult else {
            XCTFail("Excepted valid result")
            return
        }
        XCTAssertEqual(result.validFrom.first?.format, .dateTime)
        XCTAssertEqual(result.validUntil.first?.format, .dateTime)
        XCTAssertTrue(result.validFrom.first!.time.isEqualToTheMinute(with: Date().modified(hours: -52)))
        XCTAssertTrue(result.validUntil.first!.time.isEqualToTheMinute(with: Date().modified(hours: -52).modified(hours: 72)))
    }
    
    func testSimpleEvaluationForPCRTestOfAdult() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_tests")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (52, 0), dateOfBirthAge: (24, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        guard case let .invalid(violations: violations) = validationResult else {
            XCTFail("Excepted invalid result")
            return
        }
        XCTAssertEqual(violations.count, 0)
    }
    
    func testSimpleEvaluationForPCRTestOf13YearOld() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_tests")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (14, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        guard case let .valid(result: result) = validationResult else {
            XCTFail("Excepted valid result")
            return
        }
        XCTAssertEqual(result.validFrom.first?.format, .dateTime)
        XCTAssertEqual(result.validUntil.first?.format, .dateTime)
        XCTAssertTrue(result.validFrom.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59)))
        XCTAssertTrue(result.validUntil.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59).modified(hours: 48)))
    }
    
    func testSimpleEvaluationForPCRTestOf13YearOldInNightClub() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_tests")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (14, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Club", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        guard case let .invalid(violations: violations) = validationResult else {
            XCTFail("Excepted invalid result")
            return
        }
        XCTAssertEqual(violations.count, 0)
    }
    
    func testSimpleEvaluationForPCRTestOfAdultInNightClub() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_tests")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (52, 0), dateOfBirthAge: (24, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Club", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        guard case let .invalid(violations: violations) = validationResult else {
            XCTFail("Excepted invalid result")
            return
        }
        XCTAssertEqual(violations.count, 0)
    }
    
    func testSimpleEvaluationForPCRTestOf4YearOld() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_tests")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (4, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNil(validationResult)
    }
    
    func testSimpleEvaluationForPCRTestOf4YearOldInNightClub() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_tests")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (4, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Club", originalCertificateObject: certificate)
        guard case let .invalid(violations: violations) = validationResult else {
            XCTFail("Excepted invalid result")
            return
        }
        XCTAssertEqual(violations.count, 0)
    }
    
    func testNonMatchingCertificateType() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (4, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Club", originalCertificateObject: certificate)
        XCTAssertNil(validationResult)
    }
}
