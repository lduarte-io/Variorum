// swift-tools-version: 6.2
// PHASE 13 MEASUREMENT SPIKE — Step A0(i), the three design-prerequisite
// numbers pulled forward from deferred Phase 12 ("answer 4"):
//   (a) decoration budget on the live TK2 editor (overlay views — the
//       Phase 7 badge pattern — vs typing-attribute gaps vs, for the
//       record only, TK2 rendering attributes);
//   (b) read-tier per-view cost at design-corpus scale (Phase 10 recorded
//       0.35 ms median — re-verify);
//   (c) keystroke-path headroom under seam/ring/badge/gap decorations.
// Never a dependency of VariorumCore; the recorded numbers live in the
// phase plan's Stage A closeout (this harness is their evidence).
import PackageDescription

let package = Package(
    name: "Phase13DecorationSpike",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        .executableTarget(
            name: "Phase13DecorationSpike",
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
