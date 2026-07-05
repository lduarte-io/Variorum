// swift-tools-version: 6.1
// Keep buildable under both Xcode 16.4 (Swift 6.1) and Xcode 26 — see CLAUDE.md environment notes.
import PackageDescription

let package = Package(
    name: "VariorumCore",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
    ],
    products: [
        .library(name: "VariorumCore", targets: ["VariorumCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.9.0"),
    ],
    targets: [
        .target(
            name: "VariorumCore",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "VariorumCoreTests",
            dependencies: ["VariorumCore"]
        ),
    ]
)
