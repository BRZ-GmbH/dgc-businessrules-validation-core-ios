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

struct BusinessRule: Codable {
    let id: String
    let schemaVersion: Int
    let regionCondition: RegionCondition
    let certificateTypeString: String?
    
    var certificateType: BusinessRuleCertificateType? {
        guard let certificateTypeString = certificateTypeString else {
            return nil
        }
        if certificateTypeString.caseInsensitiveCompare(BusinessRuleCertificateType.vaccination.rawValue) == .orderedSame {
            return .vaccination
        } else if certificateTypeString.caseInsensitiveCompare(BusinessRuleCertificateType.test.rawValue) == .orderedSame {
            return .test
        } else if certificateTypeString.caseInsensitiveCompare(BusinessRuleCertificateType.recovery.rawValue) == .orderedSame {
            return .recovery
        } else if certificateTypeString.caseInsensitiveCompare(BusinessRuleCertificateType.vaccinationExemption.rawValue) == .orderedSame {
            return .vaccinationExemption
        }
        return nil
    }
    
    let certificateTypeConditions: AndConditionGroup
    private let validFromString: String?
    var validFrom: Date {
        guard let validFromString = validFromString else { return Date.distantPast }
        return ISO8601DateFormatter().date(from: validFromString) ?? Date.distantPast
    }
    
    private let validUntilString: String?
    var validUntil: Date {
        guard let validUntilString = validUntilString else { return Date.distantFuture }
        return ISO8601DateFormatter().date(from: validUntilString) ?? Date.distantFuture
    }
    
    let generalConditions: AndConditionGroup?
    let ruleSetsByProfileId: [String:ProfileRuleSet]
    let targetGroupsByGroupId: [String:RuleTargetGroup]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case certificateTypeString = "certificate_type"
        case schemaVersion = "schema_version"
        case regionCondition = "regions"
        case certificateTypeConditions = "certificate_type_conditions"
        case validFromString = "valid_from"
        case validUntilString = "valid_until"
        case generalConditions = "general_conditions"
        case ruleSetsByProfileId = "profiles"
        case targetGroupsByGroupId = "groups"
    }
    
    func validate(withAvailableConditions availableConditions: [String:CertificateCondition], andAvailableProfiles availableProfiles: [RuleProfile]) -> [BusinessRulesSyntaxError] {
        var errors = [BusinessRulesSyntaxError]()
        errors.append(contentsOf: generalConditions?.validate(withAvailableConditions: availableConditions) ?? [])
        errors.append(contentsOf: certificateTypeConditions.validate(withAvailableConditions: availableConditions))
        errors.append(contentsOf: targetGroupsByGroupId?.values.flatMap({ $0.validate(withAvailableConditions: availableConditions)}) ?? [])
        
        if targetGroupsByGroupId?["all"] != nil {
            errors.append(BusinessRulesSyntaxError.reservedTargetGroupName(targetGroupName: "all"))
        }
        errors.append(contentsOf: ruleSetsByProfileId.keys.compactMap({ profileKey in availableProfiles.first(where: { $0.id == profileKey }) == nil ? BusinessRulesSyntaxError.unavailableProfile(profile: profileKey) : nil }))
        errors.append(contentsOf: ruleSetsByProfileId.values.flatMap({ $0.validate(withAvailableConditions: availableConditions, andAvailableProfiles: availableProfiles, availableTargetGroups: targetGroupsByGroupId) }))
        
        ruleSetsByProfileId.forEach { profile, profileRuleSet in
            profileRuleSet.ruleSetsByGroupKey.forEach { group, ruleSet in
                if let linkedProfile = ruleSet.equalToProfile, let error = checkForNonLinkedRuleSetForProfile(linkedProfile, group: group) {
                    errors.append(error)
                }
            }
        }
        
        return errors
    }
    
    func isCompatibleToSupportedSchemaVersion(_ supportedSchemaVersion: Int) -> Bool {
        return schemaVersion <= supportedSchemaVersion
    }
    
    func isApplicableForRegion(_ region: String) -> Bool {
        let includedRegions = regionCondition.include ?? []
        let excludedRegions = regionCondition.exclude ?? []
        
        return (includedRegions.contains(region) || includedRegions.contains("all")) && excludedRegions.contains(region) == false
    }
    
    func isValid(atValidationClock validationClock: Date) -> Bool {
        return validFrom.isBefore(validationClock) && validUntil.isAfter(validationClock)
    }
    
    func usesTargetGroups() -> Bool {
        return (targetGroupsByGroupId?.count ?? 0) > 0
    }
    
    func checkForNonLinkedRuleSetForProfile(_ profile: String, group: String) -> BusinessRulesSyntaxError? {
        guard let profileRuleSet = ruleSetsByProfileId[profile] else { return BusinessRulesSyntaxError.unknownLinkedProfile(profile: profile) }
        
        guard let ruleSet = profileRuleSet.ruleSetsByGroupKey[group] else { return BusinessRulesSyntaxError.unknownTargetGroupInLinkedProfile(profile: profile, targetGroup: group) }
        
        guard ruleSet.equalToProfile == nil else {
            return BusinessRulesSyntaxError.unallowedMultistepProfileChain(profile: profile, targetGroup: group)
            
        }
        
        return nil
    }
}
