// The visual walk, wrapped as an OPT-IN test (18l U-VIS). Nothing here asserts geometry itself: the
// driver does (`visual-walk.sh`, `scenarios.zsh`) and writes the per-scenario report; these tests
// only make "run it" one command and turn its exit status into a verdict.
import Foundation
import Testing

private let enabled = ProcessInfo.processInfo.environment["VARIORUM_VISUAL_WALK"] == "1"
private let driver = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .appendingPathComponent("visual-walk.sh")

/// Runs the driver with `arguments`, streaming its output, and answers its exit status.
private func walk(_ arguments: [String]) throws -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = [driver.path] + arguments
    try process.run()
    process.waitUntilExit()
    return process.terminationStatus
}

@Suite(
    "The visual walk (18l U-VIS — opt-in; DISABLED unless VARIORUM_VISUAL_WALK=1)",
    .enabled(if: enabled,
             "drives the REAL dev-store window — run deliberately: cd Tools/VisualWalk && VARIORUM_VISUAL_WALK=1 swift test"),
    .serialized)
struct VisualWalkTests {
    /// The tripwire's own tripwire: a planted, knowingly wrong expectation must come back RED (exit 1)
    /// with its capture and report — a harness that cannot red is hollow.
    @Test(.timeLimit(.minutes(5)))
    func theHarnessCanRed() throws {
        #expect(try walk(["--selftest"]) == 1, "the planted failure must be caught and reported non-zero")
    }

    /// The seeded scenarios in both voices (override with VARIORUM_VISUAL_WALK_ARGS). Exit 0 means no
    /// FAIL and no ERROR — XFAIL/XPASS rows are in the report, never red.
    @Test(.timeLimit(.minutes(60)))
    func theSeededWalkPasses() throws {
        let extra = ProcessInfo.processInfo.environment["VARIORUM_VISUAL_WALK_ARGS"]?
            .split(separator: " ").map(String.init) ?? ["--voices", "terminal,study"]
        #expect(try walk(extra) == 0, "a FAIL or ERROR in notes/plans/vis-walks/<date>/<run>/report.md")
    }
}
