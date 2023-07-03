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
 The container holding the definitions in the Modern Business Rule Format
 */
public struct BusinessRuleContainer: Codable {
    /**
     The specified profiles
     */
    public let profiles: [RuleProfile]
    internal let conditions: [String:CertificateCondition]
    internal let rules: [BusinessRule]
    
    private enum CodingKeys: String, CodingKey {
        case profiles
        case conditions
        case rules
    }
    
    /**
     Validates the contents of the BusinessRuleContainer to check for BusinessRulesSyntaxErrors.
     
     With the exception of external conditions this validates all conditions and rules in the container for any undefined conditions, profiles or groups, mismatches in the rules or illegal constructs within the rules
     */
    public func validate() -> [BusinessRulesSyntaxError] {
        return rules.flatMap({ $0.validate(withAvailableConditions:  conditions, andAvailableProfiles:  profiles)})
    }
    
    /**
     Parses a BusinessRuleContainer from the given Data. Throws in case the syntax is wrong or the data cannot be parsed for any other reason.
     */
    public static func parsedFrom(data: Data) throws -> BusinessRuleContainer {
        return try JSONDecoder().decode(BusinessRuleContainer.self, from: data)
    }
    
}
