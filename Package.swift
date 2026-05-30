// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Resend",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macCatalyst(.v16),
        .visionOS(.v1),
    ],
    products: [
        // Core models and protocols (no dependencies)
        .library(
            name: "ResendCore",
            targets: ["ResendCore"]),

        // HTTP client for iOS/macOS/Linux (URLSession-based)
        .library(
            name: "ResendKit",
            targets: ["ResendKit"]),

        // Vapor integration for server-side
        .library(
            name: "ResendVapor",
            targets: ["ResendVapor"]),

        // Convenience re-export module
        .library(
            name: "Resend",
            targets: ["Resend"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.10.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.66.1"),
    ],
    targets: [
        // Core: Models and protocols (no dependencies)
        .target(
            name: "ResendCore",
            dependencies: []),

        // Kit: URLSession-based HTTP client
        .target(
            name: "ResendKit",
            dependencies: [
                "ResendCore",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]),

        // Vapor: Server-side integration
        .target(
            name: "ResendVapor",
            dependencies: [
                "ResendCore",
                "ResendKit",
                .product(name: "Vapor", package: "vapor")
            ]),

        // Resend: Re-export module
        .target(
            name: "Resend",
            dependencies: ["ResendCore", "ResendKit"]),

        // Tests using Swift Testing framework
        .testTarget(
            name: "ResendTests",
            dependencies: [
                "Resend",
                "ResendKit",
                "ResendCore",
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
