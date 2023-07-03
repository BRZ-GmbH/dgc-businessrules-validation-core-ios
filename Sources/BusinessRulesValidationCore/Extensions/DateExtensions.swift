/*
 * Copyright (c) 2022 BRZ GmbH &lt;https://www.brz.gv.at&gt;
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

internal extension DateFormatter {
    
    static let shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
}

extension Date {
    
    func formattedShortDate() -> String {
        return DateFormatter.shortDateFormatter.string(from: self)
    }
    
    func isBefore(_ date: Date) -> Bool {
        if #available(iOS 13.0, *) {
            return distance(to: date) > 0
        } else {
            return self < date
        }
    }
    
    func isAfter(_ date: Date) -> Bool {
        if #available(iOS 13.0, *) {
            return distance(to: date) < 0
        } else {
            return self > date
        }
    }
    
    /**
     Returns the earlier date of the instance and the passed date. If the passed date is nil, it is ignored and the instance is returned
     */
    func dateOrEarlierDate(date: Date?) -> Date {
        guard let date = date else { return self }
        
        if self.isBefore(date) {
            return self
        }
        return date
    }
    
    /**
     Adds the calendar unit with the given internal to the date instance. Supported units are minute, hour, day and month (all singular).
     
     If an unknown unit is passed, the date instance itself is returned without modification.
     */
    public func dateByAddingUnitAndValue(unit: ValidityTimeModificationUnit, interval: Int) -> Date {
        switch unit {
            case .minute:
                if let date = Calendar.autoupdatingCurrent.date(byAdding: .minute, value: interval, to: self) {
                    return date
                }
            case .hour:
                if let date = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: interval, to: self) {
                    return date
                }
            case .day:
                if let date = Calendar.autoupdatingCurrent.date(byAdding: .day, value: interval, to: self) {
                    return date
                }
            case .month:
                if let date = Calendar.autoupdatingCurrent.date(byAdding: .month, value: interval, to: self) {
                    return date
                }
            default: break
        }
        return self
    }
    
    func dateByModifyingWith(modifiers: [ValidityTimeModifier]?) -> Date {
        guard let modifiers = modifiers else {
            return self
        }
        var date = self
        for modifier in modifiers {
            date = date.dateByModifyingWith(modifier: modifier)
        }
        return date
    }
    
    func dateByModifyingWith(modifier: ValidityTimeModifier?) -> Date {
        guard let modifier = modifier else {
            return self
        }
        
        switch modifier {
        case .startOfDay:
            return Calendar.autoupdatingCurrent.startOfDay(for: self)
        case .endOfDay:
            return Calendar.autoupdatingCurrent.date(byAdding: DateComponents(day: 1, second: -1), to: Calendar.autoupdatingCurrent.startOfDay(for: self))!
        case .startOfMonth:
            return self.startOfMonth()
        case .endOfMonth:
            return self.endOfMonth()
        }
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
        
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!.endOfDay()
    }
    
    func endOfDay() -> Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}
