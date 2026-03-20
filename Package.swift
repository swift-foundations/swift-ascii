// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-ascii",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "ASCII", targets: ["ASCII"]),
        .library(name: "ASCII Test Support", targets: ["ASCII Test Support"])
    ],
    dependencies: [
        .package(path: "../../swift-incits/swift-incits-4-1986"),
        .package(path: "../../swift-primitives/swift-ascii-primitives"),
        .package(path: "../../swift-primitives/swift-base62-standard"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
        .package(path: "../../swift-primitives/swift-parser-primitives"),
        .package(path: "../../swift-primitives/swift-binary-parser-primitives"),
        .package(path: "../../swift-primitives/swift-serializer-primitives"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-string-primitives")
    ],
    targets: [
        .target(
            name: "ASCII",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "Base62 Standard", package: "swift-base62-standard"),
                .product(name: "Binary Parser Primitives", package: "swift-binary-parser-primitives"),
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(name: "Serialization Primitives", package: "swift-serializer-primitives"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "String Primitives", package: "swift-string-primitives")
            ]
        ),
        .target(
            name: "ASCII Test Support",
            dependencies: ["ASCII"],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "ASCII Tests",
            dependencies: ["ASCII", "ASCII Test Support"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
