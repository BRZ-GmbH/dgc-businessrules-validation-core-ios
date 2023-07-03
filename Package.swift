// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BusinessRulesValidationCore",
    platforms: [
        .iOS(.v12),
        .macOS("10.14")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BusinessRulesValidationCore",
            targets: ["BusinessRulesValidationCore"]),
    ],
    dependencies: [
        .package(name: "jsonlogic", url: "https://github.com/BRZ-GmbH/json-logic-swift.git", .branch("feature/avoid-date-parsing-attempts")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BusinessRulesValidationCore",
            dependencies: ["jsonlogic"]),
        .testTarget(
            name: "BusinessRulesValidationCoreTests",
            dependencies: ["BusinessRulesValidationCore"],
            resources: [
                .copy("Resources/valuesets.json"),
                .copy("Resources/simple.json"),
                .copy("Resources/full.json"),
                .copy("Resources/full_spec.json"),
                .copy("Resources/simple_vaccination.json"),
                .copy("Resources/simple_vaccination_max_validity.json"),
                .copy("Resources/simple_vaccination_time_modifier.json"),
                .copy("Resources/simple_vaccination_unknown_time_intervals.json"),
                .copy("Resources/parsing_without_rule_validity.json"),
                .copy("Resources/validation_unallowed_multichain.json"),
                .copy("Resources/validation_unknown_condition.json"),
                .copy("Resources/validation_unknown_group.json"),
                .copy("Resources/simple_tests.json"),
                .copy("Resources/simple_test_with_external_condition.json"),
                .copy("Resources/simple_test_with_external_condition_and_validity.json"),
                .copy("Resources/simple_test_with_external_condition_and_validity_and_fallback.json"),
                .copy("Resources/parsing_validitytime.json"),
                .copy("Resources/validation_reserved_group_name.json"),
            ]),
    ]
)

