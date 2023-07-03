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
import jsonlogic

struct ExternalParameter: Codable {
    let validationClock: Date
    let valueSets: Dictionary<String, [String]>
    let issuerCountryCode: String
    let exp: Date
    let iat: Date
}

public class BusinessRulesCoreHelper {
    
    static let backendFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static var defaultEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        
        let formatter = BusinessRulesCoreHelper.backendFormatter
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        return encoder
    }
    
    public class func jsonObjectForValidation(forCertificatePayload certificatePayload: String, externalParameter: String) -> JSON? {
        let validationString = getJSONStringForValidation(externalJsonString: externalParameter, payload: certificatePayload)
        
        return JSON(string: validationString)
    }
    
    public class func getJSONStringForValidation(externalJsonString: String, payload: String) -> String {
        var result = ""
        result = "{" + "\"external\":" + "\(externalJsonString)" + "," + "\"payload\":" + "\(payload)"  + "}"
        return result
    }
    
    
    public class func getExternalParameterStringForValidation(certificateIssueDate: Date, certificateExpiresDate: Date, countryCode: String, valueSets: [String:[String]], validationClock: Date) -> String {
        let externalParameter = ExternalParameter(validationClock: validationClock, valueSets: valueSets, issuerCountryCode: countryCode, exp: certificateExpiresDate, iat: certificateIssueDate)
        guard let jsonData = try? defaultEncoder.encode(externalParameter) else { return ""}
        return String(data: jsonData, encoding: .utf8)!
    }
    
    /**
     Evaluates the given JsonLogic rule on the validationObject. If any of the arguments is nil, return nil
     */
    public class func evaluateBooleanRule(_ rule: JsonLogic?, forValidationObject validationObject: JSON?) -> Bool? {
        guard let rule = rule else { return nil }
        do {
            return try rule.applyRuleInternal(to: validationObject)
        } catch {
        }
        return nil
    }
    
    class func evaluatePlaceholderSubstitution(withValue variablePath: String, onValidationObject validationObject: JSON?) -> JSON {
        let variablePathParts = variablePath.split(separator: ".").map({String($0)})
        var partialResult: JSON? = validationObject
        for key in variablePathParts {
            if partialResult?.type == .array {
              if let index = Int(key), let maxElement = partialResult?.array?.count,  index < maxElement, index >= 0  {
                partialResult = partialResult?[index]
              } else {
                partialResult = partialResult?[key]
              }
            } else {
              partialResult = partialResult?[key]
            }
        }
        return partialResult ?? JSON.Null
    }
    
    /**
     Searches for placeholders (contained between two hash symbols - e.g. #name#) in the given string and evaluates the referenced path in the given JSON object to replace them with actual values or an empty string if they are not successfully evaluated
     */
    public class func evaluatePlaceholdersInString(_ string: String, onValidationObject validationObject: JSON?) -> String {
        var evaluationString = string
        var placeHolderRange = evaluationString.range(of: #"#[^#]*#"#, options: .regularExpression)
        while placeHolderRange != nil {
            let placeholder = evaluationString[placeHolderRange!].replacingOccurrences(of: "#", with: "")
            let placeholderValue = evaluatePlaceholderSubstitution(withValue: placeholder, onValidationObject: validationObject)
            switch placeholderValue {
            case .Null, .Error(_), .Bool(_), .Array(_), .Dictionary(_):
                evaluationString.replaceSubrange(placeHolderRange!, with: "")
            case .Int(let int64):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(int64)")
            case .Double(let double):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(double)")
            case .String(let string):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(string)")
            case .Date(let date):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(date.formattedShortDate())")
            }
            placeHolderRange = evaluationString.range(of: #"#[^#]*#"#, options: .regularExpression)
        }
        
        return evaluationString
    }
}
