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

struct ValidityTime: Codable {
    
    var conditions: OrConditionGroup?
    var value: String
    private var maxDateString: String?
    var maxDate: Date? {
        guard let maxDateString = maxDateString else { return nil }
        return ISO8601DateFormatter().date(from: maxDateString)
    }
    
    var unitString: String?
    var unit: ValidityTimeModificationUnit? {
        guard let unitString = unitString else { return nil }
        
        return ValidityTimeModificationUnit(rawValue: unitString)
    }
    
    var interval: Int?
    private var formatString: String?
    var format: ValidityTimeFormat {
        guard let formatString = formatString else {
            return .dateTime
        }
        return ValidityTimeFormat(rawValue: formatString) ?? .dateTime
    }
    
    private var modifierString: String?
    
    var modifier: ValidityTimeModifier? {
        guard let modifierString = modifierString else {
            return nil
        }
        return ValidityTimeModifier(rawValue: modifierString)
    }
    
    func dateByModifying(date: Date) -> Date {
        guard let unit = unit, let interval = interval else { return date.dateOrEarlierDate(date: maxDate) }
        
        return date
            .dateByAddingUnitAndValue(unit: unit, interval: interval)
            .dateByModifyingWith(modifier: modifier)
            .dateOrEarlierDate(date: maxDate)
    }
    
    private enum CodingKeys: String, CodingKey {
        case value
        case unitString = "plus_unit"
        case interval = "plus_interval"
        case conditions
        case formatString = "format"
        case maxDateString = "max"
        case modifierString = "modifier"
    }
    
    func validate(withAvailableConditions availableConditions: [String:CertificateCondition]) -> [BusinessRulesSyntaxError] {
        return conditions?.validate(withAvailableConditions: availableConditions) ?? []
    }
}
