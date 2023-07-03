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

struct RuleSet: Codable {
    let conditions: OrConditionGroup?
    let validFrom: [ValidityTime]?
    let validUntil: [ValidityTime]?
    let invalid: Bool?
    let equalToProfile: String?
    let linkedConditions: [LinkedCondition]?
    
    private enum CodingKeys: String, CodingKey {
        case conditions
        case validFrom = "valid_from"
        case validUntil = "valid_until"
        case invalid
        case equalToProfile = "equal_to_profile"
        case linkedConditions = "linked_conditions"
    }
    
    func validate(withAvailableConditions availableConditions: [String:CertificateCondition], andAvailableProfiles availableProfiles: [RuleProfile]) -> [BusinessRulesSyntaxError] {
        let conditionErrors = conditions?.validate(withAvailableConditions: availableConditions) ?? []
        let linkedConditionErrors = linkedConditions?.flatMap({ return $0.validate(withAvailableConditions: availableConditions) }) ?? []
        let profileErrors = equalToProfile != nil && availableProfiles.first(where: { $0.id == equalToProfile }) == nil ? [BusinessRulesSyntaxError.unavailableProfile(profile: equalToProfile!)] : []
        let validFromErrors = validFrom?.flatMap({ $0.validate(withAvailableConditions: availableConditions) }) ?? []
        let validUntilErrors = validUntil?.flatMap({ $0.validate(withAvailableConditions: availableConditions) }) ?? []
        return conditionErrors + linkedConditionErrors + profileErrors + validFromErrors + validUntilErrors
    }
}


