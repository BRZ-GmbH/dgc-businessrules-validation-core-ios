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
 Extensions for String
 */
extension String {
    
    /**
     Returns whether this string represents and external condition.
     
     External conditions start with ext.
     
     The remaining part of the external condition name is split by a single underline, with the first part being the condition name and the remaining parts being treated as parameters
     */
    public var isExternalCondition: Bool {
        return self.hasPrefix("ext.")
    }
    
    var substringToFirstNonLetter: String {
        if let firstNonLetter = self.firstIndex(where: { $0.isLetter == false }) {
            return String(self[..<firstNonLetter])
        }
        return self
    }
    
    /**
     Returns a normalized identifier derived from the familyName, givenName and date of birth of a digital green certificate. This can be used to determine if different certificate likely belong to the same person despite slight differences in the name on the certificate (most-like differences due to multiple given names).
     
     This method clips the familyName and givenName at the first non-letter character and concatenated a lowercased version together with the date of birth.
     
     It is recommended to use the standardized familyName and givenName values of the certificate (fields fnt and gnt)
     */
    public static func personGroupingIdentiferForDGCCertificate(withFamilyName familyName: String?, givenName: String?, dateOfBirth: String?) -> String {
        let normalizedFamilyName = (familyName ?? "").localizedLowercase.substringToFirstNonLetter
        let normalizedGivenName = (givenName ?? "").localizedLowercase.substringToFirstNonLetter
        let normalizedDateOfBirth = dateOfBirth ?? ""
        return "\(normalizedFamilyName)_\(normalizedGivenName)_\(normalizedDateOfBirth)"
    }
    
    public var externalConditionNameAndArguments: (condition: String, parameters: [String:String])? {
        guard isExternalCondition else {
            return nil
        }
        
        var conditionNameAndArguments = dropFirst(4).components(separatedBy: "__").map({ String($0) }).filter({ $0.isEmpty == false })
        if let name = conditionNameAndArguments.first {
            conditionNameAndArguments.removeFirst()
            
            let parameters: [String:String] = conditionNameAndArguments.reduce([String:String]()) { partialResult, argument in
                var partialResult = partialResult
                let parameter = argument.split(separator: ":")
                if parameter.count == 2, let parameterName = parameter.first, let parameterValue = parameter.last, !parameterName.isEmpty, !parameterValue.isEmpty {
                    partialResult[String(parameterName)] = String(parameterValue)
                }
                return partialResult
            }
            return (name, parameters)
        }
        
        return nil
    }
}
