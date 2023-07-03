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
@testable import BusinessRulesValidationCore

class ExternalConditionTestEvaluator: ExternalConditionEvaluator {
    
    var evaluationBlock: ((_ condition: String, _ parameters: [String:String], _ ruleId: String, _ ruleCertificateType: String?, _ region: String, _ profile: String, _ originalCertificateObject: Any?) -> Bool?)?
        
    func evaluateExternalCondition(_ condition: String, parameters: [String:String], fromRuleWithId ruleId: String, ruleCertificateType: String?, region: String, profile: String, originalCertificateObject: Any?) -> Bool? {
        return evaluationBlock?(condition, parameters, ruleId, ruleCertificateType, region, profile, originalCertificateObject)
    }
    
}
