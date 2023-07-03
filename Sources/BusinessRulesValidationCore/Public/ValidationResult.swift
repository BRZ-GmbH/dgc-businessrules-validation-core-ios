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
 Represents the validation result from BusinessRulesValidationCore for a certificate and profile
 */
public enum ValidationResult : Equatable {
    /**
     The certificate was evaluated successfully and is valid for the evaluated region and profile
     */
    case valid(result: BusinessRuleValidationResult)
    /**
     The certificate was evaluated successfully but is not valid for the evaluated region and profile. The list of violations contains ALL conditions that the certificate failed.
     */
    case invalid(violations: [ConditionViolation])
    /**
     The certificate was not evaluated successfully because the evaluation of certain conditions failed. The list of failedConditions contains ALL conditions that led to an error.
     */
    case error(failedConditions: [String])
    
    public static func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
        switch (lhs, rhs) {
            case (.valid(let lhsResult), .valid(let rhsResult)):
                return lhsResult == rhsResult
            case (.invalid(let lhsViolations), .invalid(let rhsViolations)):
                return lhsViolations.elementsEqual(rhsViolations)
            case (.error(let lhsFailedConditions), .error(let rhsFailedConditions)):
                return lhsFailedConditions.elementsEqual(rhsFailedConditions)
            default: return false
        }
    }
}
