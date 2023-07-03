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

struct ProfileRuleSet: Codable {
    let ruleSetsByGroupKey: [String:RuleSet]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        ruleSetsByGroupKey = try container.decode([String:RuleSet].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(ruleSetsByGroupKey)
    }
    
    func validate(withAvailableConditions availableConditions: [String:CertificateCondition], andAvailableProfiles availableProfiles: [RuleProfile], availableTargetGroups: [String:RuleTargetGroup]?) -> [BusinessRulesSyntaxError] {
        var errors = [BusinessRulesSyntaxError]()
        errors.append(contentsOf: ruleSetsByGroupKey.values.flatMap({ $0.validate(withAvailableConditions:  availableConditions, andAvailableProfiles:  availableProfiles) }))
        errors.append(contentsOf: ruleSetsByGroupKey.keys.compactMap({ $0 != "all" && availableTargetGroups?[$0] == nil ? BusinessRulesSyntaxError.unavailableTargetGroup(targetGroup: $0) : nil }))
        return errors
    }
}
