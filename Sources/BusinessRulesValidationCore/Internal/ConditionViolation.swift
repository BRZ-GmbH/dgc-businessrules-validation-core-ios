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
 Wraps the violation of an individual condition
 */
public struct ConditionViolation: Equatable {
    /**
     The identifier for the condition that was violated
     */
    public let condition: String
    
    /**
     The localized violation message for this condition that provides a user-readable description of the reason why this condition was violated
     */
    public let message: LocalizedValue<String>?
        
    public static func == (lhs: ConditionViolation, rhs: ConditionViolation) -> Bool {
        return lhs.condition == rhs.condition
    }
}
