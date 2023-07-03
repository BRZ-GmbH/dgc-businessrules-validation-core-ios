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

struct LinkedCondition: Codable {
    let localizedViolationDescription: LocalizedValue<String>?
    let conditions: AndConditionGroup
    
    private enum CodingKeys: String, CodingKey {
        case conditions
        case localizedViolationDescription = "violation_description"
    }
    
    /**
     Validates if non-external conditions are available in the provided map.
     
     If a condition is not available a SyntaxValidationError.unavailableCondition with the condition name is returned for that condition
     */
    func validate(withAvailableConditions availableConditions: [String:CertificateCondition]) -> [BusinessRulesSyntaxError] {
        return conditions.conditions.compactMap({
            if $0.isExternalCondition == false {
                if availableConditions[$0] == nil {
                    return BusinessRulesSyntaxError.unavailableCondition(conditionName: $0)
                }
            }
            return nil
        })
    }
}
