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

final class DateExtensionTests: XCTestCase {
    
    func testComparisons() {
        XCTAssertTrue(Date().isBefore(Date().addingTimeInterval(10)))
        XCTAssertFalse(Date().isBefore(Date().addingTimeInterval(-10)))
        
        XCTAssertFalse(Date().isAfter(Date().addingTimeInterval(10)))
        XCTAssertTrue(Date().isAfter(Date().addingTimeInterval(-10)))
        
        let date1 = Date()
        let date2 = Date().addingTimeInterval(10)
        
        XCTAssertEqual(date1.dateOrEarlierDate(date: nil), date1)
        XCTAssertEqual(date1.dateOrEarlierDate(date: date2), date1)
        XCTAssertEqual(date2.dateOrEarlierDate(date: date1), date1)
    }
    
    func testDateModifications() {
        XCTAssertTrue(Date().dateByAddingUnitAndValue(unit: .minute, interval: 10).isEqualToTheMinute(with: Date().addingTimeInterval(60 * 10)))
        XCTAssertTrue(Date().dateByAddingUnitAndValue(unit: .hour, interval: 10).isEqualToTheMinute(with: Date().addingTimeInterval(60 * 60 * 10)))
        XCTAssertTrue(Date().dateByAddingUnitAndValue(unit: .day, interval: 2).isEqualToTheDay(with: Date().addingTimeInterval(60 * 60 * 24 * 2)))
        
        XCTAssertTrue(Date().dateByAddingUnitAndValue(unit: .month, interval: 5).isEqualToTheDay(with: Calendar.autoupdatingCurrent.date(byAdding: .month, value: 5, to: Date())!))
    }
    
    func testDateModifiers() {
        let date = ISO8601DateFormatter().date(from: "2022-08-03T17:42:00Z")!
        
        let startOfDay = Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date.dateByModifyingWith(modifier: .startOfDay))
        XCTAssertEqual(startOfDay.day, 3)
        XCTAssertEqual(startOfDay.month, 8)
        XCTAssertEqual(startOfDay.hour, 0)
        XCTAssertEqual(startOfDay.minute, 0)

        let endOfDay = Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date.dateByModifyingWith(modifier: .endOfDay))
        XCTAssertEqual(endOfDay.day, 3)
        XCTAssertEqual(endOfDay.month, 8)
        XCTAssertEqual(endOfDay.hour, 23)
        XCTAssertEqual(endOfDay.minute, 59)
        
        let startOfMonth = Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date.dateByModifyingWith(modifier: .startOfMonth))
        XCTAssertEqual(startOfMonth.day, 1)
        XCTAssertEqual(startOfMonth.month, 8)
        XCTAssertEqual(startOfMonth.hour, 0)
        XCTAssertEqual(startOfMonth.minute, 0)

        let endOfMonth = Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date.dateByModifyingWith(modifier: .endOfMonth))
        XCTAssertEqual(endOfMonth.day, 31)
        XCTAssertEqual(endOfMonth.month, 8)
        XCTAssertEqual(endOfMonth.hour, 23)
        XCTAssertEqual(endOfMonth.minute, 59)
    }
}
