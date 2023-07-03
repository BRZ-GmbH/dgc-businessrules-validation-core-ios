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
import JSON

class CertificateValidator {
    
    let originalCertificateObject: Any?
    let jsonObjectForValidation: JSON?
    let certificateType: BusinessRuleCertificateType
    let availableConditions: [String:CertificateCondition]
    let externalConditionEvaluator: ExternalConditionEvaluator?
    let externalConditionEvaluationStrategy: ExternalConditionEvaluationStrategy
    let region: String
    let profile: String
    
    init(originalCertificateObject: Any?,
         certificatePayload: String,
         certificateType: BusinessRuleCertificateType,
         certificateIssueDate: Date,
         certificateExpiresDate: Date,
         countryCode: String,
         valueSets: [String:[String]],
         validationClock: Date,
         region: String,
         profile: String,
         availableConditions: [String:CertificateCondition],
         externalConditionEvaluator: ExternalConditionEvaluator?,
         externalConditionEvaluationStrategy: ExternalConditionEvaluationStrategy) {
        self.region = region
        self.profile = profile
        self.originalCertificateObject = originalCertificateObject
        self.certificateType = certificateType
        self.availableConditions = availableConditions
        self.externalConditionEvaluator = externalConditionEvaluator
        self.externalConditionEvaluationStrategy = externalConditionEvaluationStrategy
        
        let externalParameter = BusinessRulesCoreHelper.getExternalParameterStringForValidation(certificateIssueDate: certificateIssueDate, certificateExpiresDate: certificateExpiresDate, countryCode: countryCode, valueSets: valueSets, validationClock: validationClock)
        jsonObjectForValidation = BusinessRulesCoreHelper.jsonObjectForValidation(forCertificatePayload: certificatePayload, externalParameter: externalParameter)
    }
    
    func jsonObject() -> JSON? {
        return jsonObjectForValidation
    }
           
    func evaluateValidTimeString(_ evaluationString: String) -> Date? {
        if evaluationString.hasPrefix("#") && evaluationString.hasSuffix("#") {
            let placeholderValue = BusinessRulesCoreHelper.evaluatePlaceholderSubstitution(withValue: evaluationString.replacingOccurrences(of: "#", with: ""), onValidationObject: jsonObjectForValidation)
            switch placeholderValue {
            case .Date(let date): return date
            default: return nil
            }
        } else {
            return ISO8601DateFormatter().date(from: evaluationString)
        }
    }
    
    
    
    func evaluateConditions(_ conditions: [String], forRuleWithId ruleId: String, ruleCertificateType: String?) -> [ConditionValidationResult] {
        return conditions.map({
            return evaluateCondition($0, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType)
        })
    }
    
    private func evaluateCondition(_ conditionName: String, forRuleWithId ruleId: String, ruleCertificateType: String?) -> ConditionValidationResult {
        if conditionName.isExternalCondition {
            guard let conditionNameAndArguments = conditionName.externalConditionNameAndArguments else {
                return ConditionValidationResult.failed(condition: conditionName)
            }
            
            if let result = externalConditionEvaluator?.evaluateExternalCondition(conditionNameAndArguments.condition, parameters: conditionNameAndArguments.parameters, fromRuleWithId: ruleId, ruleCertificateType: ruleCertificateType, region: region, profile: profile, originalCertificateObject: originalCertificateObject) {
                if result {
                    return ConditionValidationResult.fulfilled
                } else {
                    return ConditionValidationResult.violated(violation: ConditionViolation(condition: conditionName, message: nil))
                }
            } else {
                switch externalConditionEvaluationStrategy {
                    case .defaultToTrue:
                        return ConditionValidationResult.fulfilled
                    case .defaultToFalse:
                        return ConditionValidationResult.violated(violation: ConditionViolation(condition: conditionName, message: nil))
                    case .failCondition:
                        return ConditionValidationResult.failed(condition: conditionName)
                }
            }
        } else {
            guard let condition = availableConditions[conditionName] else { return .failed(condition: conditionName) }
            if let result = BusinessRulesCoreHelper.evaluateBooleanRule(try? condition.parsedJsonLogic(), forValidationObject: jsonObjectForValidation) {
                if result {
                    return .fulfilled
                } else {
                    return .violated(violation: ConditionViolation(condition: conditionName, message: condition.localizedViolationDescription))
                }
            } else {
                return ConditionValidationResult.failed(condition: conditionName)
            }
        }
    }
}
