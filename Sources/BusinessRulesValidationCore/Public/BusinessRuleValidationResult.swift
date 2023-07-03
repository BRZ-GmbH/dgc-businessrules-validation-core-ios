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
 Represents the valid validation result of a certificate for a single region and profile
 */
public struct BusinessRuleValidationResult : Equatable {
    /**
     The profile for which the certificate is valid
     */
    public let profile: String
    /**
     The region for which the certificate is valid
     */
    public let region: String
    
    /**
     Time results from when this certificate is valid. Sorted ascending with the first entry holding the "earliest possible date". Each ValidityTimeResult might hold conditions when it applies.
     */
    public let validFrom: [ValidityTimeResult]
    /**
     Time results until when this certificate is valid. Sorted descending with the first entry being the "latest possible date". Each ValidityTimeResult might hold conditions when it applies.
     */
    public let validUntil: [ValidityTimeResult]
    /**
     List of linked conditions that were successfully evaluated to determine the validity of this certificate
     */
    public let matchingLinkedConditions: [BusinessRuleValidationLinkedConditionResult]
    /**
     List of linked conditions that were violated while determining the validity of this certificate
     */
    public let violatedOrFailedLinkedConditions: [BusinessRuleValidationLinkedConditionResult]
    
    public static func == (lhs: BusinessRuleValidationResult, rhs: BusinessRuleValidationResult) -> Bool {
        guard lhs.profile == rhs.profile else { return false }
        guard lhs.region == rhs.region else { return false }
        
        guard lhs.validFrom.elementsEqual(rhs.validFrom) else { return false }
        guard lhs.validUntil.elementsEqual(rhs.validUntil) else { return false }
        
        guard lhs.matchingLinkedConditions.elementsEqual(rhs.matchingLinkedConditions) else { return false }
        guard lhs.violatedOrFailedLinkedConditions.elementsEqual(rhs.violatedOrFailedLinkedConditions) else { return false }
        
        return true
    }
}
