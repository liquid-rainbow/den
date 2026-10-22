// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "face_liveness_detector",
    platforms: [
        // If your plugin only supports iOS, remove `.macOS(...)`.
        // If your plugin only supports macOS, remove `.iOS(...)`.
        .iOS("15.0"),
    ],
    products: [
        // If the plugin name contains "_", replace with "-" for the library name.
        .library(name: "face-liveness-detector", targets: ["face_liveness_detector"])
    ],
    dependencies: [
        .package(url: "https://github.com/aws-amplify/amplify-swift", exact: "2.58.0"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", exact: "1.6.71"),
        .package(url: "https://github.com/smithy-lang/smithy-swift", exact: "0.191.0"),
        .package(url: "https://github.com/aws-amplify/amplify-ui-swift-liveness", exact: "1.4.4")
    ],
    targets: [
        .target(
            name: "face_liveness_detector",
            dependencies: [
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSCognitoAuthPlugin", package: "amplify-swift"),
                .product(name: "FaceLiveness", package: "amplify-ui-swift-liveness")
            ],
            resources: []
        )
    ]
)
