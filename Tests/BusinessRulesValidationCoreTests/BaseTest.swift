/*
 * Copyright (c) 2022 BRZ GmbH &lt;https://www.brz.gv.at&gt;
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import XCTest
@testable import BusinessRulesValidationCore

class BusinessRulesTest: XCTestCase {
    let externalConditionEvaluator = ExternalConditionTestEvaluator()
    
    func getBusinessRules(rulesPath: String) throws -> BusinessRuleContainer {
        let ruleData = try Data(contentsOf: URL(fileURLWithPath: Bundle.module.path(forResource: rulesPath, ofType: "json")!), options: .mappedIfSafe)

        return try BusinessRuleContainer.parsedFrom(data: ruleData)
    }
    
    func getValidationCore(rulesPath: String, externalConditionEvaluationStrategy: ExternalConditionEvaluationStrategy = .failCondition, validationClock: Date = Date()) throws -> BusinessRuleValidator {
        let businessRules = try getBusinessRules(rulesPath: rulesPath)
        
        let valueSetData = try Data(contentsOf: URL(fileURLWithPath: Bundle.module.path(forResource: "valuesets", ofType: "json")!), options: .mappedIfSafe)

        let valueSets = try JSONDecoder().decode([String:[String]].self, from: valueSetData)
        
        return BusinessRuleValidator(businessRules: businessRules, valueSets: valueSets, validationClock: validationClock, externalConditionEvaluator: externalConditionEvaluator, externalConditionEvaluationStrategy: externalConditionEvaluationStrategy)
    }
}
