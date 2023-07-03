# BusinessRulesValidationCore

Core functionality for validating digital green certificates with the New Business Rule Format described in https://github.com/Federal-Ministry-of-Health-AT/green-pass-overview

The response from the endpoints provided there can be parsed with a BusinessRulesContainer provided in https://github.com/ehn-dcc-development/ValidationCore which will contain only a single BusinessRule entry for the New Business Rule Format. This BusinessRule contains a String which can then be provided to the BusinessRuleValidator provided in this library.

A simple pseudocode implementation looks like this:

```
let responseFromEndpoint: ValidationCore.BusinessRulesContainer = ...
let ruleString: String = responseFromEndpoint.rules.first!.rule
let parsedRules: BusinessRuleContainer = try! BusinessRuleContainer.parsedFrom(data: ruleString.data(using: .utf8)!)
let validator = BusinessRuleValidator(businessRules: parsedRules, valueSets: ...)
let validationResult = validator.evaluateCertificate(...)
```

The evaluateCertificate method in BusinessRuleValidator can then be used to evaluate a certificate for one or more profiles in a given region (e.g. W for Wien/Vienna).

See the provided unit tests for detailed examples on the usage and format of this library. Alternatively you can also check the usage of this library in the official Austrian Green Pass app for iOS on https://github.com/BRZ-GmbH/CovidCertificate-App-iOS

# Integration

At the moment we recommend integrating this package either through Git submodules or even easier by using Swift Package Manager and referencing this repository.