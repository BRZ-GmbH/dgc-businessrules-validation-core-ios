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
 A list of AndConditionGroup that are linked together with an OR operation
 */
struct OrConditionGroup: Codable {
    /**
     The individual condition groups
     */
    let conditionGroups: [AndConditionGroup]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        conditionGroups = try container.decode([AndConditionGroup].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(conditionGroups)
    }
    
    /**
     Validates the AND condition groups for possible SyntaxValidationErrors
     */
    func validate(withAvailableConditions availableConditions: [String:CertificateCondition]) -> [BusinessRulesSyntaxError] {
        return conditionGroups.flatMap({ $0.validate(withAvailableConditions: availableConditions)})
    }
}

