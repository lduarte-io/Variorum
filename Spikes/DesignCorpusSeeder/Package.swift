// swift-tools-version: 6.2
// PHASE 13 DEV TOOL — the design-corpus seeder (Step A0(ii), the deferred-12
// pull-forward): seeds a realistic shelf into the DEV store so density/calm
// decisions are made against volume, not a handful of posts. Never a
// dependency of VariorumCore; never part of the app. It writes ONLY the
// A4-fenced dev store (`Variorum-dev/`) — the real-store path is refused by
// construction (see main.swift's guard).
import PackageDescription

let package = Package(
    name: "DesignCorpusSeeder",
    platforms: [
        .macOS(.v26)
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "DesignCorpusSeeder",
            dependencies: [
                .product(name: "VariorumCore", package: "variorum")
            ],
            path: "Sources",
            swiftSettings: [
                // Dev-tool posture (the ReadTierSpike precedent): language
                // mode 5 keeps top-level-code actor friction out of the way.
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
