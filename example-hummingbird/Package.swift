// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ResendHummingbirdExample",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .executableTarget(
            name: "ResendHummingbirdExample",
            dependencies: [
                .product(name: "ResendHummingbird", package: "Resend"),
                .product(name: "ResendCore", package: "Resend"),
                .product(name: "ResendKit", package: "Resend")
            ]
        )
    ]
)
