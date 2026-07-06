// swift-tools-version: 6.2
// THROWAWAY SPIKE — Phase 6 TK2 de-risk. Never a dependency of VariorumCore.
// See README.md and notes/plans/phase-06-tk2-spike.md.
import PackageDescription

let package = Package(
    name: "TK2Spike",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        .executableTarget(
            name: "TK2Spike",
            path: "Sources",
            swiftSettings: [
                // Throwaway measurement harness: language mode 5 to keep AppKit
                // notification/closure friction out of the way of the measurements.
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
