// swift-tools-version: 6.2
// Single dev machine (M3, Xcode 26) as of 2026-07-06; no older-OS support — see CLAUDE.md environment notes.
import PackageDescription

let package = Package(
    name: "VariorumCore",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
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
