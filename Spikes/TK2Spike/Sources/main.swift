// TK2Spike — entry point (throwaway; Phase 6).
// Boots NSApplication programmatically, runs the scenarios, dumps the table, exits.
// Scenario args (default all, in order): load fallback height scrub typing ensure scale

import AppKit

/// First line of a helper tool's output — used to stamp the toolchain into the results
/// artifact (cold review 2026-07-06, NIT: the ground rule wants macOS AND Xcode/SDK
/// versions auto-recorded so a point-release re-run can't silently omit them).
private func firstLine(of tool: String, _ arguments: [String]) -> String {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: tool)
    p.arguments = arguments
    let out = Pipe()
    p.standardOutput = out
    p.standardError = Pipe()
    do { try p.run() } catch { return "unavailable(\(error.localizedDescription))" }
    p.waitUntilExit()
    guard let data = try? out.fileHandleForReading.readToEnd(),
          let s = String(data: data, encoding: .utf8),
          let line = s.split(separator: "\n").first
    else { return "unavailable" }
    return String(line)
}

final class SpikeAppDelegate: NSObject, NSApplicationDelegate {
    var manualHarness: Harness?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let rec = Recorder.shared
        let pi = ProcessInfo.processInfo
        rec.rec("0.env", "macOS", pi.operatingSystemVersionString)
        rec.rec("0.env", "xcode", firstLine(of: "/usr/bin/xcodebuild", ["-version"]))
        rec.rec("0.env", "sdk.macosx", firstLine(of: "/usr/bin/xcrun", ["--show-sdk-version", "--sdk", "macosx"]))
        rec.rec("0.env", "swift", firstLine(of: "/usr/bin/xcrun", ["swift", "--version"]))
        rec.rec("0.env", "process", "TK2Spike (swift run, debug), arm64")

        FallbackCanary.shared.arm()

        let args = Array(CommandLine.arguments.dropFirst())
        func enabled(_ name: String) -> Bool { args.isEmpty || args.contains(name) }

        let corpus = Corpus.build()
        let runner = Runner(corpus: corpus)

        // Manual feel pass (author item): window stays open, canary armed, no scenarios.
        // Type/scroll/jump by hand; any canary firing prints loudly to the terminal.
        if args.contains("manual") {
            NSApp.setActivationPolicy(.regular)
            let h = Harness(corpus: corpus.attributed, title: "MANUAL feel pass — 50k words, canary armed")
            manualHarness = h
            h.window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            print("Manual mode: \(corpus.wordCount) words / \(corpus.paragraphCount) blocks loaded.")
            print("Type at start/middle/end, scroll hard, drag-resize the window, jump with the scroller.")
            print("Canary is armed — a TK1 fallback prints *** CANARY FIRED *** here. Close the window to quit.")
            return
        }

        let overallT0 = nowMS()
        if enabled("load") { autoreleasepool { runner.runLoad() } }
        if enabled("fallback") { autoreleasepool { runner.runFallback() } }
        if enabled("height") { autoreleasepool { runner.runHeight() } }
        if enabled("scrub") { autoreleasepool { runner.runScrub() } }
        if enabled("typing") { autoreleasepool { runner.runTyping() } }
        if enabled("ensure") { autoreleasepool { runner.runEnsure() } }
        if enabled("scale") { autoreleasepool { runner.runScale() } }
        rec.rec("7.run", "totalRunTime", fmt((nowMS() - overallT0) / 1000, 1), "s")

        let events = FallbackCanary.shared.events
        rec.rec("7.run", "canaryEventsWholeRun", "\(events.count)",
                note: events.isEmpty
                    ? "TK2 never fell back to TK1"
                    : events.map { "\($0.phase)@\($0.action)" }.joined(separator: "; "))

        rec.dump()
        exit(0)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = SpikeAppDelegate()
app.delegate = delegate
app.run()
