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
 Validator that allows performing evaluation of modern business rule format on a given certificate
 */
public class BusinessRuleValidator {

    enum LinkedConditionValidationResult {
        case fulfilled
        case violated
        case failed
    }

    private static let supportedBusinessRuleSchemaVersion: Int = 1
    
    private let businessRules: BusinessRuleContainer
    private let valueSets: [String:[String]]
    private let validationClock: Date
    private let externalConditionEvaluator: ExternalConditionEvaluator?
    private let externalConditionEvaluationStrategy: ExternalConditionEvaluationStrategy
    
    /**
     Constructor for the Validator.
     */
    public init(businessRules: BusinessRuleContainer,
                valueSets: [String:[String]],
                validationClock: Date,
                externalConditionEvaluator: ExternalConditionEvaluator?,
                externalConditionEvaluationStrategy: ExternalConditionEvaluationStrategy) {
        self.businessRules = businessRules
        self.valueSets = valueSets
        self.validationClock = validationClock
        self.externalConditionEvaluator = externalConditionEvaluator
        self.externalConditionEvaluationStrategy = externalConditionEvaluationStrategy
    }
    
    /**
     Evaluates the given certificate according to the business rules
     
     - certificate The certificate to validate
     - certificateType the type of the given certificate
     - expiration the expiration date of the certificate's signature
     - issue the issue date of the certificate's signature
     - country the country of issuance of this certificate
     - region the region (most likely used for federal states) to evaluate the certificate against
     - profiles the list of profiles to evaluate the certificate against. If nil, all defined profiles in the business rules format are evaluated
     - originalCertificateObject the original certificate object, only passed along to the ExternalConditionEvaluator
     */
    public func evaluateCertificate(_ certificate: String, certificateType: BusinessRuleCertificateType, expiration: Date, issue: Date, country: String, region: String, profiles: [String]? = nil, originalCertificateObject: Any?) -> [String:ValidationResult] {
        var evaluationResults = [String:ValidationResult]()
        (profiles ?? businessRules.profiles.map({ $0.id })).forEach { profile in
            if let result = evaluateCertificate(certificate, certificateType: certificateType, expiration: expiration, issue: issue, country: country, region: region, profile: profile, originalCertificateObject: originalCertificateObject) {
                evaluationResults[profile] = result
            }
        }
        return evaluationResults
    }
    
    /**
     Evaluates the given certificate according to the business rules for a single profile
     
     - certificate The certificate to validate
     - certificateType the type of the given certificate
     - expiration the expiration date of the certificate's signature
     - issue the issue date of the certificate's signature
     - country the country of issuance of this certificate
     - region the region (most likely used for federal states) to evaluate the certificate against
     - profile the profile to evaluate the certificate against
     - originalCertificateObject the original certificate object, only passed along to the ExternalConditionEvaluator
     */
    public func evaluateCertificate(_ certificate: String, certificateType: BusinessRuleCertificateType, expiration: Date, issue: Date, country: String, region: String, profile: String, originalCertificateObject: Any?) -> ValidationResult? {
        let validator = CertificateValidator(
                                             originalCertificateObject: originalCertificateObject,
                                             certificatePayload: certificate,
                                             certificateType: certificateType,
                                             certificateIssueDate: issue,
                                             certificateExpiresDate: expiration,
                                             countryCode: country,
                                             valueSets: valueSets,
                                             validationClock: validationClock,
                                             region: region,
                                             profile: profile,
                                             availableConditions: businessRules.conditions,
                                             externalConditionEvaluator: externalConditionEvaluator,
                                             externalConditionEvaluationStrategy: externalConditionEvaluationStrategy)
        
        return evaluateCertificateWithValidator(validator: validator, forRegion: region, profile: profile)
    }
    
    private func evaluateCertificateWithValidator(validator: CertificateValidator, forRegion region: String, profile: String, group: String? = nil) -> ValidationResult? {
        for businessRule in businessRules.rules {
            if !businessRule.isCompatibleToSupportedSchemaVersion(BusinessRuleValidator.supportedBusinessRuleSchemaVersion) {
                continue
            }
            if !businessRule.isValid(atValidationClock: validationClock) {
                continue
            }
            if !businessRule.isApplicableForRegion(region) {
                continue
            }
            
            if let type = businessRule.certificateType {
                if validator.certificateType != type {
                    continue
                }
            }
            
            let certificateTypeConditions = validator.evaluateConditions(businessRule.certificateTypeConditions.conditions, forRuleWithId: businessRule.id, ruleCertificateType: businessRule.certificateTypeString)
            if !certificateTypeConditions.allSatisfy({ $0.isFulfilled() }) {
                continue
            }
            
            let evaluatedGeneralConditions = validator.evaluateConditions(businessRule.generalConditions?.conditions ?? [], forRuleWithId: businessRule.id, ruleCertificateType: businessRule.certificateTypeString)
            if !evaluatedGeneralConditions.allSatisfy({ $0.isFulfilled() }) {
                let failed = evaluatedGeneralConditions.compactMap({ $0.failedCondition() })
                if failed.count > 0 {
                    return ValidationResult.error(failedConditions: failed)
                }
                let violations = evaluatedGeneralConditions.compactMap({ $0.violation() })
                if violations.count > 0 {
                    return ValidationResult.invalid(violations: violations)
                }
            }
            
            guard let rulesetForProfile = businessRule.ruleSetsByProfileId[profile] else { return nil }
            
            if businessRule.usesTargetGroups(), !(rulesetForProfile.ruleSetsByGroupKey.keys.first == "all" && rulesetForProfile.ruleSetsByGroupKey.keys.count == 1) {
                var matchingGroup: String? = group
                if group == nil {
                    for (groupName, group) in businessRule.targetGroupsByGroupId! {
                        if validateConditionsInOrGroup(group, validator: validator, forRuleWithId: businessRule.id, ruleCertificateType: businessRule.certificateTypeString).allSatisfy({ $0.isFulfilled() }) {
                            matchingGroup = groupName
                            break
                        }
                    }
                }
                guard let group = matchingGroup, let ruleSet = rulesetForProfile.ruleSetsByGroupKey[group] else { return nil }
                return validateRuleSet(ruleSet: ruleSet, validator: validator, region: region, profile: profile, forRuleWithId: businessRule.id, ruleCertificateType: businessRule.certificateTypeString)
            } else {
                guard let ruleSet = rulesetForProfile.ruleSetsByGroupKey["all"] else { return nil }
                return validateRuleSet(ruleSet: ruleSet, validator: validator, region: region, profile: profile, forRuleWithId: businessRule.id, ruleCertificateType: businessRule.certificateTypeString)
            }
        }
        return nil
    }
    
    private func validateRuleSet(ruleSet: RuleSet, validator: CertificateValidator, region: String, profile: String, forRuleWithId ruleId: String, ruleCertificateType: String?) -> ValidationResult? {
        if let equalToProfile = ruleSet.equalToProfile {
            let result = evaluateCertificateWithValidator(validator: validator, forRegion: region, profile: equalToProfile)
            if case let .valid(validationResult) = result, let linkedConditionsValidation = validateLinkedConditionsForRuleSet(ruleSet, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType) {                
                var validFrom = validationResult.validFrom
                var validUntil = validationResult.validUntil
                
                if let overwrittenValidFrom = ruleSet.validFrom {
                    // Overwrite validFrom from equal rule
                    validFrom = validateTimes(overwrittenValidFrom, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType, sortAscending: true)
                }
                
                if let overwrittenValidUntil = ruleSet.validUntil {
                    // Overwrite validUntil from equal rule
                    validUntil = validateTimes(overwrittenValidUntil, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType, sortAscending: false)
                }
                
                return ValidationResult.valid(result: BusinessRuleValidationResult(profile: profile, region: region, validFrom: validFrom, validUntil: validUntil, matchingLinkedConditions: linkedConditionsValidation.fulfilled, violatedOrFailedLinkedConditions: linkedConditionsValidation.failed))
            } else {
                return result
            }
        } else {
            if ruleSet.invalid == true {
                return ValidationResult.invalid(violations: [])
            } else {
                let result = validateConditionsInOrGroup(ruleSet.conditions, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType)
                if result.first?.isFulfilled() == true {
                    if let linkedConditionsValidation = validateLinkedConditionsForRuleSet(ruleSet, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType) {
                        return ValidationResult.valid(result: BusinessRuleValidationResult(profile: profile, region: region, validFrom: validateTimes(ruleSet.validFrom, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType, sortAscending: true), validUntil: validateTimes(ruleSet.validUntil, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType, sortAscending: false), matchingLinkedConditions: linkedConditionsValidation.fulfilled, violatedOrFailedLinkedConditions: linkedConditionsValidation.failed ))
                    } else {
                        return ValidationResult.valid(result: BusinessRuleValidationResult(profile: profile, region: region, validFrom: validateTimes(ruleSet.validFrom, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType, sortAscending: true), validUntil: validateTimes(ruleSet.validUntil, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType, sortAscending: false), matchingLinkedConditions: [], violatedOrFailedLinkedConditions: []))
                    }
                } else if result.isEmpty {
                    return nil
                } else {
                    return ValidationResult.invalid(violations: result.compactMap({ $0.violation() }))
                }
            }
        }
    }
    
    private func validateLinkedConditionsForRuleSet(_ ruleSet: RuleSet, validator: CertificateValidator, forRuleWithId ruleId: String, ruleCertificateType: String?) -> (fulfilled: [BusinessRuleValidationLinkedConditionResult], failed: [BusinessRuleValidationLinkedConditionResult])? {
        if let linkedConditions = ruleSet.linkedConditions, linkedConditions.count > 0 {
            let validatedLinkedConditions = validateLinkedConditions(linkedConditions: linkedConditions, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType)
            let fulfilledLinkedConditions = validatedLinkedConditions.filter({ $0.1 == .fulfilled }).map({ BusinessRuleValidationLinkedConditionResult(violationMessage:  $0.0.localizedViolationDescription, conditions:  $0.0.conditions.conditions )})
            let failedLinkedConditions = validatedLinkedConditions.filter({ $0.1 != .fulfilled }).map({ BusinessRuleValidationLinkedConditionResult(violationMessage:  $0.0.localizedViolationDescription, conditions:  $0.0.conditions.conditions )})
            return (fulfilledLinkedConditions, failedLinkedConditions)
        }
        return nil
    }

    
    func validateLinkedConditions(linkedConditions: [LinkedCondition], validator: CertificateValidator, forRuleWithId ruleId: String, ruleCertificateType: String?) -> [(LinkedCondition, LinkedConditionValidationResult)] {
        var validationResults = [(LinkedCondition, LinkedConditionValidationResult)]()
        for linkedCondition in linkedConditions {
            let evaluations = validator.evaluateConditions(linkedCondition.conditions.conditions, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType)
            if evaluations.allSatisfy({ $0.isFulfilled() }) {
                validationResults.append((linkedCondition, LinkedConditionValidationResult.fulfilled))
            } else {
                let failed = evaluations.compactMap({ $0.failedCondition() })
                if failed.count > 0 {
                    validationResults.append((linkedCondition, LinkedConditionValidationResult.failed))
                } else {
                    validationResults.append((linkedCondition, LinkedConditionValidationResult.violated))
                }
            }
        }
        return validationResults
    }

    func validateConditionsInOrGroup(_ orGroup: OrConditionGroup?, validator: CertificateValidator, forRuleWithId ruleId: String, ruleCertificateType: String?) -> [ConditionValidationResult] {
        guard let orGroup = orGroup else {
            return [ConditionValidationResult.fulfilled]
        }

        var violations = [ConditionViolation]()
        var failedConditions = [String]()
        for andConditionGroup in orGroup.conditionGroups {
            let evaluations = validator.evaluateConditions(andConditionGroup.conditions, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType)
            if evaluations.allSatisfy({ $0.isFulfilled() }) {
                return [ConditionValidationResult.fulfilled]
            } else {
                violations.append(contentsOf: evaluations.compactMap({ $0.violation() }))
                failedConditions.append(contentsOf: evaluations.compactMap({ $0.failedCondition() }))
            }
        }
        if (!failedConditions.isEmpty) {
            return failedConditions.map({ ConditionValidationResult.failed(condition:  $0) })
        } else if (!violations.isEmpty) {
            return violations.map({ ConditionValidationResult.violated(violation:  $0) })
        } else {
            return [ConditionValidationResult.failed(condition: "")]
        }
    }
    
    func validateTimes(_ times: [ValidityTime]?, validator: CertificateValidator, forRuleWithId ruleId: String, ruleCertificateType: String?, sortAscending: Bool) -> [ValidityTimeResult] {
        guard let times = times else { return [] }
        
        var validityTimes = [ValidityTimeResult]()
            
        for time in times {
            if let validationResult = validateTime(time, validator: validator, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType) {
                validityTimes.append(validationResult)
            }
        }
        return validityTimes.sorted { r1, r2 in
            return sortAscending ? r1.time.isBefore(r2.time) : r1.time.isAfter(r2.time)
        }
    }
    
    func validateTime(_ time: ValidityTime, validator: CertificateValidator, forRuleWithId ruleId: String, ruleCertificateType: String?) -> ValidityTimeResult? {
        if let conditions = time.conditions, conditions.conditionGroups.isEmpty == false {
            for andConditionGroup in conditions.conditionGroups {
                if validator.evaluateConditions(andConditionGroup.conditions, forRuleWithId: ruleId, ruleCertificateType: ruleCertificateType).allSatisfy({ $0.isFulfilled() }) {
                    if let date = validator.evaluateValidTimeString(time.value) {
                        return ValidityTimeResult(time: time.dateByModifying(date: date), format: time.format, conditions: andConditionGroup.conditions)
                    }
                }
            }
        } else {
            if let date = validator.evaluateValidTimeString(time.value) {
                return ValidityTimeResult(time: time.dateByModifying(date: date), format: time.format, conditions: nil)
            }
        }
        return nil
    }
}


