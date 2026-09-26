// swift-tools-version: 6.2
//
// 18l U-VIS — the env-flagged WRAPPER around the visual walk (the keychain-drill gating pattern:
// `.enabled(if: VARIORUM_VISUAL_WALK == "1")`). Its own tiny package, so no default suite — not the
// core `swift test`, not the Mac scheme — ever contains it:
//
//     cd Tools/VisualWalk && VARIORUM_VISUAL_WALK=1 swift test
//
// Always on (no GUI): the headless pins, `pins/*.zsh`. Unset, the two GUI tests report SKIPPED with
// their reason; set, they drive the REAL dev-store window through `visual-walk.sh` (README.md) —
// the self-test, then the seeded walk in both voices (~15 minutes, measured).
import PackageDescription

let package = Package(
    name: "VisualWalk",
    platforms: [.macOS(.v26)],
    targets: [.testTarget(name: "VisualWalkTests", path: "Tests/VisualWalkTests")]
)
