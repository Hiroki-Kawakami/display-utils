// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "display-utils",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "DisplayUtils",
            targets: ["DisplayUtils"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/FullQueueDeveloper/StaticMemberIterable.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DisplayUtilsBridge",
            publicHeadersPath: "."
        ),
        .target(
            name: "DisplayUtils",
            dependencies: [
                "DisplayUtilsBridge",
                .product(name: "StaticMemberIterable", package: "StaticMemberIterable"),
            ],
            linkerSettings: [
                .linkedFramework("CoreDisplay", .when(platforms: [.macOS])),
            ],
        ),
        .executableTarget(
            name: "display-utils",
            dependencies: [
                "DisplayUtils",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
