// swift-tools-version: 6.3.1

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
        .package(url: "https://github.com/swift-incits/swift-incits-4-1986.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-binary-base-primitives.git", branch: "main"),
        // W3 PRUNE: binary's Binary.Borrowed deleted + the parse engine
        // re-homed to the Span.Borrowed.`Protocol` byte-span seam — path-dep
        // binary + binary-parser (changed) and span (the seam's conformance
        // home, imported in the 3 Machine.Access files).
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-binary-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-binary-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-string-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-span-primitives.git", branch: "main"),
        // transitive-collision overrides (Finding 7): the binary-parser →
        // machine → graph → data-structure cluster pulls these W2/W3 packages
        // url→main, colliding with the path-dep'd W2 memory. Path-dep their
        // canonical-basename worktrees to unify identities.
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-cursor-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-cursor-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-cursor-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-iterator-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-storage-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-storage-split-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-ring-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-linear-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-slots-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-hash-table-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-array-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-set-ordered-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-heap-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-stack-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-text-primitives.git", branch: "main")
    ],
    targets: [
        .target(
            name: "ASCII",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "Binary Base Primitives", package: "swift-binary-base-primitives"),
                .product(name: "Binary Serializable Primitives", package: "swift-binary-serializer-primitives"),
                .product(name: "Binary Parser Primitives", package: "swift-binary-parser-primitives"),
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(name: "Binary ASCII Serializable Primitives", package: "swift-ascii-serializer-primitives"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "String Primitives", package: "swift-string-primitives"),
                // W3 PRUNE: Swift.Span: Span.Borrowed.`Protocol` conformance for
                // the byte-span parse calls in the Machine.Access files (Finding 3/8).
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives")
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
