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

final class SimpleVaccinationCertificateTests: BusinessRulesTest {
    
    func testSimpleEvaluationForVaccination() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
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
        }
    }
    
    func testSimpleEvaluationForVaccinationWithEqualToProfile() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Club", originalCertificateObject: certificate)
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
        }
    }
    
    func testSimpleEvaluationForExpiredVaccination() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 271, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: let violations):
            XCTAssertEqual(violations.count, 1)
            XCTAssertEqual(violations[0].condition, "isVaccinationDateLessThan270DaysAgo")
        case .valid(result: _):
            XCTFail()
        }
    }
    
    func testSimpleEvaluationForPartialVaccination() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 40, dateOfBirthAge: (20, 0), doses: 1, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: let violations):
            XCTAssertEqual(violations.count, 1)
            XCTAssertEqual(violations[0].condition, "isFullVaccination")
        case .valid(result: _):
            XCTFail()
        }
    }
    
    func testSimpleEvaluationForInvalidVaccine() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination("EU/xxxx", vaccinationAgeInDays: 40, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: let violations):
            XCTAssertEqual(violations.count, 1)
            XCTAssertEqual(violations[0].condition, "isAllowedVaccine")
        case .valid(result: _):
            XCTFail()
        }
    }
    
    func testSimpleEvaluationForMultipleGeneralConditionViolations() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination("EU/xxxx", vaccinationAgeInDays: 40, dateOfBirthAge: (20, 0), doses: 1, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
        XCTAssertNotNil(validationResult)
        switch validationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: let violations):
            XCTAssertEqual(violations.count, 2)
            XCTAssertEqual(violations[0].condition, "isAllowedVaccine")
            XCTAssertEqual(violations[1].condition, "isFullVaccination")
        case .valid(result: _):
            XCTFail()
        }
    }
    
    func testSimpleEvaluationForVaccinationWithMaxValidity() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination_max_validity")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
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
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheDay(with: ISO8601DateFormatter().date(from: "2024-01-01T16:00:00Z")!))
        }
    }
    
    func testSimpleEvaluationForVaccinationWithInvalidMaxValidity() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination_unknown_time_intervals")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Club", originalCertificateObject: certificate)
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
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheDay(with: Date().modified(days: -30).modified(days: 5000)))
        }
    }
    
    func testSimpleEvaluationForVaccinationWithUnknownTimeIntervals() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination_unknown_time_intervals")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
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
            XCTAssertTrue(result.validUntil.first!.time.isEqualToTheDay(with: Date().modified(days: -30)))
        }
    }
    
    func testSimpleEvaluationForVaccinationWithoutRuleValidity() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profile: "Entry", originalCertificateObject: certificate)
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
        }
    }
    
    func testSimpleEvaluationForAllDefinedProfiles() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", originalCertificateObject: certificate)
        XCTAssertEqual(2, validationResult.count)
        XCTAssertNotNil(validationResult["Entry"])
        XCTAssertNotNil(validationResult["Club"])
    }
    
    func testSimpleEvaluationForMultipleProfiles() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profiles: ["Entry", "Club"], originalCertificateObject: certificate)
        XCTAssertEqual(2, validationResult.count)
        XCTAssertNotNil(validationResult["Entry"])
        XCTAssertNotNil(validationResult["Club"])
    }
    
    func testSimpleEvaluationForMultipleProfilesWithUnknown() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination")
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", profiles: ["Entry", "Club", "MissingProfile"], originalCertificateObject: certificate)
        XCTAssertEqual(2, validationResult.count)
        XCTAssertNotNil(validationResult["Entry"])
        XCTAssertNotNil(validationResult["Club"])
    }
    
    func testSimpleEvaluationOfTimeModifier() throws {
        let validationCore = try getValidationCore(rulesPath: "simple_vaccination_time_modifier")
        
        let vaccinationDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -30, to: Date())!
        
        let certificate = TestUtil.generateVaccination(.moderna, vaccinationAgeInDays: 30, dateOfBirthAge: (20, 0), doses: 2, sequence: 2)
        let validationResult = validationCore.evaluateCertificate(certificate, certificateType: .vaccination, expiration: Date(), issue: Date(), country: "AT", region: "W", originalCertificateObject: certificate)
        XCTAssertEqual(2, validationResult.count)
        
        let entryValidationResult = validationResult["Entry"]
        let clubValidationResult = validationResult["Club"]
        
        switch entryValidationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertTrue(result.validUntil.first?.time.isEqualToTheMinute(with: vaccinationDate.dateByAddingUnitAndValue(unit: .day, interval: 180).dateByModifyingWith(modifier: .endOfMonth).dateByModifyingWith(modifier: .endOfDay)) == true)
            break
        }
        
        switch clubValidationResult! {
        case .error(failedConditions: _): XCTFail()
        case .invalid(violations: _): XCTFail()
        case .valid(result: let result):
            XCTAssertTrue(result.validUntil.first?.time.isEqualToTheMinute(with: vaccinationDate.dateByAddingUnitAndValue(unit: .day, interval: 180).dateByModifyingWith(modifier: .endOfDay)) == true)
            break
        }
    }
}

extension Date {
    func modified(years: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        var date = self
        date = Calendar.autoupdatingCurrent.date(byAdding: .minute, value: minutes, to: date) ?? date
        date = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: hours, to: date) ?? date
        date = Calendar.autoupdatingCurrent.date(byAdding: .day, value: days, to: date) ?? date
        date = Calendar.autoupdatingCurrent.date(byAdding: .year, value: years, to: date) ?? date
        return date
    }
    
    func isEqualToTheDay(with date: Date) -> Bool {
        return Calendar.autoupdatingCurrent.isDate(self, equalTo: date, toGranularity: .day)
    }
    
    func isEqualToTheMinute(with date: Date) -> Bool {
        return Calendar.autoupdatingCurrent.isDate(self, equalTo: date, toGranularity: .minute)
    }
}

