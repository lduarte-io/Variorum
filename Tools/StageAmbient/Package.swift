// swift-tools-version: 6.2
//
// VX-458 — the stage ambient: a full-screen 1-bit scene for the Pro's screen while the stage
// coordinator holds the stage. A coordinator tool, never part of the Variorum app; its own package so
// no app scheme or core `swift test` ever contains it. Apple frameworks only. Driven by `Tools/ambient`
// (README.md); the headless tests are `cd Tools/StageAmbient && swift test`.
import PackageDescription

let package = Package(
    name: "StageAmbient",
    platforms: [.macOS(.v26)],
    targets: [
        // Everything testable without a window: the canvas, dithering, noise, the scene system, the
        // stage-claim rule and the scenes themselves.
        .target(name: "AmbientKit"),
        // The AppKit host: the window, the frame clock, the input and claim watchers, the exit paths.
        .executableTarget(name: "StageAmbient", dependencies: ["AmbientKit"]),
        .testTarget(name: "AmbientKitTests", dependencies: ["AmbientKit"]),
    ]
)
