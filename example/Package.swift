// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ResendExample",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .executableTarget(
            name: "ResendExample",
            dependencies: [
                .product(name: "Resend", package: "Resend")
            ]
        )
    ]
)
