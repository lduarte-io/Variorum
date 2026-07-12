// swift-tools-version: 6.2
// THROWAWAY SPIKE — Phase 10 Step 0 read-tier measurement. Never a dependency
// of VariorumCore. The decision memo in
// notes/plans/phase-10-readings-and-first-views.md (closeout) is the artifact;
// this harness is kept only as its evidence, per the plan's Step 0.
import PackageDescription

let package = Package(
    name: "ReadTierSpike",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        .executableTarget(
            name: "ReadTierSpike",
            path: "Sources",
            swiftSettings: [
                // Throwaway measurement harness (the TK2Spike posture):
                // language mode 5 keeps AppKit/SwiftUI closure friction out
                // of the way of the measurements.
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
