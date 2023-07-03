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

/**
 Represent the validation result of linked conditions
 */
public struct BusinessRuleValidationLinkedConditionResult : Equatable {
    /**
     The localized violation message for this condition that provides a user-readable description of why the linked condition failed
     */
    public let violationMessage: LocalizedValue<String>?
    
    /**
     List of condition names that were evaluated with this linked condition
     */
    public let conditions: [String]
    
    public static func == (lhs: BusinessRuleValidationLinkedConditionResult, rhs: BusinessRuleValidationLinkedConditionResult) -> Bool {
        return lhs.conditions.elementsEqual(rhs.conditions)
    }
}
