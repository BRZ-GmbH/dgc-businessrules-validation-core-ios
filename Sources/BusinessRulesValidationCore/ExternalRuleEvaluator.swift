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
 Determines which strategy to use if no ExternalConditionEvaluator is passed to the validation or a nil value is returned from the ExternalConditionEvaluator (signaling that the condition could not be evaluated)
 */
public enum ExternalConditionEvaluationStrategy {
    /**
     Always assume the condition to be evaluated to true
     */
    case defaultToTrue
    /**
     Always assume the condition to be evaluated to true
     */
    case defaultToFalse
    /**
     Return an error duration validation for this condition. Validation returns a ValidationResult.error with the name of the external condition in failedConditions
     */
    case failCondition
}

/**
 Protocol for an ExternalConditionEvaluator. If passed to validation, this gets called for all external conditions found during validating rules.
 */
public protocol ExternalConditionEvaluator {
    
    /**
     Evaluate the given external condition with the given parameters. BusinessRulesValidationCore also passes the id and certificateType of the rule from which this external condition was triggered as well as the original certificate object that was passed to the validation.
     */
    func evaluateExternalCondition(_ condition: String, parameters: [String:String], fromRuleWithId ruleId: String, ruleCertificateType: String?, region: String, profile: String, originalCertificateObject: Any?) -> Bool?
}
