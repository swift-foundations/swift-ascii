// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-ascii",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "ASCII", targets: ["ASCII"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986-fork.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-parsing-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-serialization-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-test-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-testing-extras.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "ASCII",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986-fork"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "Parsing Primitives", package: "swift-parsing-primitives"),
                .product(name: "Serialization Primitives", package: "swift-serialization-primitives"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
            ]
        ),
        .testTarget(
            name: "ASCII Tests",
            dependencies: [
                "ASCII",
                .product(name: "Test Primitives", package: "swift-test-primitives"),
                .product(name: "Testing Extras", package: "swift-testing-extras"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
