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

/**
 A list of conditions that are linked together with an AND operation
 */
struct AndConditionGroup: Codable {
    /**
     The individual condition names
     */
    let conditions: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        conditions = try container.decode([String].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(conditions)
    }
    
    /**
     Validates if non-external conditions are available in the provided map.
     
     If a condition is not available a SyntaxValidationError.unavailableCondition with the condition name is returned for that condition 
     */
    func validate(withAvailableConditions availableConditions: [String:CertificateCondition]) -> [BusinessRulesSyntaxError] {
        return conditions.compactMap({
            if $0.isExternalCondition == false {
                if availableConditions[$0] == nil {
                    return BusinessRulesSyntaxError.unavailableCondition(conditionName: $0)
                }
            }
            return nil
        })
    }
    
}
