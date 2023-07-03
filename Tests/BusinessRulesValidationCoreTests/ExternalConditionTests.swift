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

import XCTest
@testable import BusinessRulesValidationCore

final class ExternalConditionTests: BusinessRulesTest {

    func testVaccinationWithAlwaysTrueEvaluation() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_test_with_external_condition", externalConditionEvaluationStrategy: .defaultToTrue)
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first!.format, .date)
            XCTAssertEqual(result.validUntil.first!.format, .date)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheDay(with: Date().modified(days: -30)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheDay(with: Date().modified(days: -30).modified(days: 270)))
            XCTAssertEqual(result.matchingLinkedConditions.count, 1)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.conditions)
        }
    }
    
    func testVaccinationWithAlwaysFalseEvaluation() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_test_with_external_condition", externalConditionEvaluationStrategy: .defaultToFalse)
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first!.format, .date)
            XCTAssertEqual(result.validUntil.first!.format, .date)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheDay(with: Date().modified(days: -30)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheDay(with: Date().modified(days: -30).modified(days: 270)))
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.count, 1)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.violationMessage)
        }
    }
    
    func testVaccinationWithAlwaysFalseAndTrueEvaluationEvaluation() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_test_with_external_condition", externalConditionEvaluationStrategy: .defaultToFalse)
        
        externalConditionEvaluator.evaluationBlock = { _, _, ruleId, ruleCertificateType, region, profile, _ in
            XCTAssertEqual(region, "W")
            XCTAssertEqual(profile, "2G+")
            XCTAssertEqual(ruleId, "Vaccination")
            XCTAssertEqual(ruleCertificateType, "vaccination")
            return true
        }
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first?.format, .date)
            XCTAssertEqual(result.validUntil.first?.format, .date)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheDay(with: Date().modified(days: -30)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheDay(with: Date().modified(days: -30).modified(days: 270)))
            XCTAssertEqual(result.matchingLinkedConditions.count, 1)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.violationMessage)
        }
    }
    
    func testPCRTestWithAlwaysFalseAndTrueEvaluationEvaluation() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_test_with_external_condition", externalConditionEvaluationStrategy: .defaultToFalse)
        
        var hasCheckedVaccinationCondition = false
        var hasCheckedRecoveryCondition = false
        externalConditionEvaluator.evaluationBlock = { condition, parameters, ruleId, ruleCertificateType, region, _, _ in
            XCTAssertEqual(region, "NOE")
            if condition == "hasValidVaccinationCertificateForPerson" {
                hasCheckedVaccinationCondition = true
                XCTAssertTrue(parameters.isEmpty)
                return true
            } else if condition == "hasValidRecoveryCertificateForPerson" {
                hasCheckedRecoveryCondition = true
                XCTAssertNotNil(parameters)
                XCTAssertEqual(parameters["parameterX"], "valueX")
                return false
            }
            return true
        }
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (14, 0), result: .negative)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "NOE", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first?.format, .dateTime)
            XCTAssertEqual(result.validUntil.first?.format, .dateTime)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59).modified(hours: 72)))
            XCTAssertEqual(result.matchingLinkedConditions.count, 1)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.matchingLinkedConditions.first?.conditions.first, "ext.hasValidVaccinationCertificateForPerson")
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.count, 1)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.first?.conditions.first, "ext.hasValidRecoveryCertificateForPerson__parameterX:valueX")
        }
        
        XCTAssertTrue(hasCheckedVaccinationCondition)
        XCTAssertTrue(hasCheckedRecoveryCondition)
    }
    
    func testPCRTestWithDifferentValidityBasedOnExternalCondition() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_test_with_external_condition_and_validity", externalConditionEvaluationStrategy: .defaultToFalse)
        
        externalConditionEvaluator.evaluationBlock = { condition, parameters, ruleId, ruleCertificateType, _, _, _ in
            if condition == "hasValidVaccinationCertificateForPerson" {
                return true
            }
            return false
        }
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (14, 0), result: .negative)
        var validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "NOE", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first?.format, .dateTime)
            XCTAssertEqual(result.validUntil.first?.format, .dateTime)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59).modified(hours: 144)))
            XCTAssertEqual(result.matchingLinkedConditions.count, 1)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.matchingLinkedConditions.first?.conditions.first, "ext.hasValidVaccinationCertificateForPerson")
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.count, 1)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.first?.conditions.first, "ext.hasValidRecoveryCertificateForPerson_parameterX:valueX")
        }
        
        externalConditionEvaluator.evaluationBlock = { condition, parameters, ruleId, ruleCertificateType, _, _, _ in
            if condition == "hasValidVaccinationCertificateForPerson" {
                return false
            }
            return false
        }
        
        validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "NOE", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first?.format, .dateTime)
            XCTAssertEqual(result.validUntil.first?.format, .dateTime)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59).modified(hours: 100)))
            XCTAssertEqual(result.matchingLinkedConditions.count, 0)
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.count, 2)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.first?.conditions.first, "ext.hasValidVaccinationCertificateForPerson")
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.last?.conditions.first, "ext.hasValidRecoveryCertificateForPerson_parameterX:valueX")
        }
    }
    
    func testPCRTestWithDifferentValidityBasedOnExternalConditionWithFallback() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_test_with_external_condition_and_validity_and_fallback", externalConditionEvaluationStrategy: .defaultToFalse)
        
        externalConditionEvaluator.evaluationBlock = { condition, parameters, ruleId, ruleCertificateType, _, _, _ in
            if condition == "hasValidVaccinationCertificateForPerson" {
                return true
            }
            return false
        }
        
        let certificate = TestUtil.generatePCRTestCertificate(sampleCollectionDateAge: (47, 59), dateOfBirthAge: (14, 0), result: .negative)
        var validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "NOE", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first?.format, .dateTime)
            XCTAssertEqual(result.validUntil.first?.format, .dateTime)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59).modified(hours: 144)))
            XCTAssertEqual(result.matchingLinkedConditions.count, 1)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.matchingLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.matchingLinkedConditions.first?.conditions.first, "ext.hasValidVaccinationCertificateForPerson")
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.count, 1)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.first?.conditions.first, "ext.hasValidRecoveryCertificateForPerson_parameterX:valueX")
        }
        
        externalConditionEvaluator.evaluationBlock = { condition, parameters, ruleId, ruleCertificateType, _, _, _ in
            if condition == "hasValidVaccinationCertificateForPerson" {
                return false
            }
            return false
        }
        
        validationResult = validationCore.evaluateCertificate(certificate, certificateType: .test, expiration: Date(), issue: Date(), country: "AT", region: "NOE", profile: "2G+", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertFalse(result.validFrom.isEmpty)
            XCTAssertFalse(result.validUntil.isEmpty)
            XCTAssertEqual(result.validFrom.first?.format, .dateTime)
            XCTAssertEqual(result.validUntil.first?.format, .dateTime)
            XCTAssertTrue(result.validFrom.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59)))
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheMinute(with: Date().modified(hours: -47, minutes: -59).modified(hours: 72)))
            XCTAssertEqual(result.matchingLinkedConditions.count, 0)
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.count, 2)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.conditions)
            XCTAssertNotNil(result.violatedOrFailedLinkedConditions.first?.violationMessage)
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.first?.conditions.first, "ext.hasValidVaccinationCertificateForPerson")
            XCTAssertEqual(result.violatedOrFailedLinkedConditions.last?.conditions.first, "ext.hasValidRecoveryCertificateForPerson_parameterX:valueX")
        }
    }
}
