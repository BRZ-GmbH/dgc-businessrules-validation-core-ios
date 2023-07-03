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

enum ConditionValidationResult {
    case fulfilled
    case violated(violation: ConditionViolation)
    case failed(condition: String)
    
    func isFulfilled() -> Bool {
        switch self {
            case .fulfilled: return true
            default: return false
        }
    }
    
    func failedCondition() -> String? {
        switch self {
            case .failed(condition: let condition): return condition
            default: return nil
        }
    }
    
    func violation() -> ConditionViolation? {
        switch self {
            case .violated(violation: let violation): return violation
            default: return nil
        }
    }
}
