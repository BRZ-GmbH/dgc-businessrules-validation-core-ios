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
 Enum for possible syntax errors in the BusinessRuleContainer
 */
public enum BusinessRulesSyntaxError: Equatable {
    /**
     A condition is referenced that is not defined
     */
    case unavailableCondition(conditionName: String)
    /**
     A target group is referenced in a profile ruleset that is not defined for the rule
     */
    case unavailableTargetGroup(targetGroup: String)
    /**
     Rules for a profile that is not defined are specified
     */
    case unavailableProfile(profile: String)
    /**
     A reserved group name was used
     */
    case reservedTargetGroupName(targetGroupName: String)
    /**
     A profile that is not defined was linked in a ruleset via equal_to_profile
     */
    case unknownLinkedProfile(profile: String)
    /**
     The target group in which a equal_to_profile condition was specified does not exist in the target profile
     */
    case unknownTargetGroupInLinkedProfile(profile: String, targetGroup: String)
    /**
     The target group and profile that is referenced also references another profile which is not allowed
     */
    case unallowedMultistepProfileChain(profile: String, targetGroup: String)
}
