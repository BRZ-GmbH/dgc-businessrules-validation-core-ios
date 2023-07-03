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

final class GroupingIdentifierTests: XCTestCase {
    
    func testGroupingIdentifierNormalization() {
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "Mustermann", givenName: "Max Peter", dateOfBirth: "1980-01-01"), "mustermann_max_1980-01-01")
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "Mustermann", givenName: "Max-Peter", dateOfBirth: "1980-01-01"), "mustermann_max_1980-01-01")
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "Mustermann-Mueller", givenName: "Max-Peter", dateOfBirth: "1980-01-01"), "mustermann_max_1980-01-01")
    }
    
    func testEmptyValues() {
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "", givenName: "Max Peter", dateOfBirth: "1980-01-01"), "_max_1980-01-01")
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: nil, givenName: "Max Peter", dateOfBirth: "1980-01-01"), "_max_1980-01-01")
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "Mustermann", givenName: "", dateOfBirth: "1980-01-01"), "mustermann__1980-01-01")
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "Mustermann", givenName: nil, dateOfBirth: "1980-01-01"), "mustermann__1980-01-01")
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "Mustermann", givenName: "Max Peter", dateOfBirth: ""), "mustermann_max_")
        XCTAssertEqual(String.personGroupingIdentiferForDGCCertificate(withFamilyName: "Mustermann", givenName: "Max-Peter", dateOfBirth: nil), "mustermann_max_")
    }
}
