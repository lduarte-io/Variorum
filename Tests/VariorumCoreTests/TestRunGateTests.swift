import Foundation
import Testing

/// VX-604 — THE FALSE-GREEN GATE, pinned headless (`notes/plans/fixes/vx-912-open-source-gating.md`, "## B1 record").
///
/// When the test host died before its first test (2026-10-27 03:46), xcodebuild said `** TEST SUCCEEDED **` and Swift
/// Testing said `Test run with 0 tests in 1 suite passed` — both green, both false, and "Executed 0 tests" is in every
/// Swift-Testing-only run anyway. `Tools/assert-tests-ran` is the verdict a gate reads instead. These pins run the real
/// script (`python3 -I`) over synthetic logs and xcresulttool-shaped JSON, written per test to a temp dir, and read its
/// exit status and its loud lines. Exit codes: 0 green · 1 red · 2 zero executed · 3 host crash · 4 usage.
///
/// The result-bundle road (`xcrun xcresulttool`) needs a bundle, which no headless test owns; its analysis is the JSON
/// road's own functions, and the record holds the script's reading of two REAL pre-fix bundles.
@Suite("VX-604 — the false-green gate: zero executed, a host crash and an issue outside every test never read green")
struct TestRunGateTests {
    static let repo = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // Tests/VariorumCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // repo root
    static let script = repo.appendingPathComponent("Tools/assert-tests-ran")

    struct Outcome {
        let status: Int32
        let output: String
    }

    /// Writes `files` (name → contents) into a fresh temp dir and runs the gate over them, in order.
    static func gate(_ files: [(String, String)], extra: [String] = []) throws -> Outcome {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx604-gate-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        var paths: [String] = []
        for (name, contents) in files {
            let url = dir.appendingPathComponent(name)
            try contents.write(to: url, atomically: true, encoding: .utf8)
            paths.append(url.path)
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", "-I", script.path] + paths + extra
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return Outcome(status: process.terminationStatus, output: String(decoding: data, as: UTF8.self))
    }

    // MARK: - The fixtures (the console's real line shapes, from the 2026-11-08 run's emitted output)

    static let xctestPreamble = """
        Test Suite 'Selected tests' started at 2026-10-27 03:46:01.000.
        Test Suite 'VariorumTests.xctest' started at 2026-10-27 03:46:01.000.
        Test Suite 'VariorumTests.xctest' passed at 2026-10-27 03:46:01.001.
        \t Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.000) seconds
        Test Suite 'Selected tests' passed at 2026-10-27 03:46:01.001.
        \t Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.001) seconds
        ◇ Test run started.
        ↳ Testing Library Version: 2084
        """

    /// THE VX-604 FALSE GREEN, byte-shaped: every verdict line a reader would grep says green.
    static let zeroExecutedLog = xctestPreamble + """

        ◇ Suite "NoteExportMenuGateTests" started.
        ✔ Suite "NoteExportMenuGateTests" passed after 0.001 seconds.
        ✔ Test run with 0 tests in 1 suite passed after 0.001 seconds.
        ** TEST SUCCEEDED **
        """

    static let greenLog = xctestPreamble + """

        ◇ Suite "VX-509 — THE STANDING FIRST-RUN DRILL" started.
        ◇ Test arm1_theStandardSetUpRunsItsFirstRound() started.
        ✔ Test arm1_theStandardSetUpRunsItsFirstRound() passed after 3.409 seconds.
        ◇ Test arm2_theStandardJoinRunsItsFirstRound() started.
        ✔ Test arm2_theStandardJoinRunsItsFirstRound() passed after 3.401 seconds.
        ◇ Test negative_theAccountGateSaysPaused() started.
        ✔ Test negative_theAccountGateSaysPaused() passed after 3.367 seconds.
        ✔ Suite "VX-509 — THE STANDING FIRST-RUN DRILL" passed after 10.2 seconds.
        ✔ Test run with 3 tests in 1 suite passed after 10.2 seconds.
        ** TEST SUCCEEDED **
        """

    /// Swift Testing's N COUNTS SKIPPED tests: "2 tests passed" here ran nothing.
    static let skippedOnlyLog = xctestPreamble + """

        ◇ Suite "NoteExportMenuGateTests" started.
        ➜ Test theMenuReadsTheGate() skipped: "never executed — the VX-604 host-crash class"
        ➜ Test theMenuReadsTheVersionDoor() skipped: "never executed — the VX-604 host-crash class"
        ✔ Suite "NoteExportMenuGateTests" passed after 0.001 seconds.
        ✔ Test run with 2 tests in 1 suite passed after 0.001 seconds.
        ** TEST SUCCEEDED **
        """

    static let crashLog = xctestPreamble + """

        Restarting after unexpected exit, crash, or test timeout in TestHostInertTests; summary will include totals from previous launches.
        Variorum (51234) encountered an error (Early unexpected exit, operation never finished bootstrapping - no restart will be attempted. (Underlying Error: Test crashed with signal segv.))
        ✔ Test run with 0 tests in 1 suite passed after 0.001 seconds.
        ** TEST SUCCEEDED **
        """

    /// Every real test passed, and swift-dependencies' own note names an issue the HOST raised at launch.
    static let hostIssueLog = greenLog + """

        ↳ failed - @Dependency(\\.date) has no test implementation, but was accessed from a test context:
          This issue was emitted from tests running in a host application (io.lduarte.Variorum.debug).
        """

    static func tree(_ cases: [(String, String)], orphan: Bool = false) -> String {
        var children: [[String: Any]] = cases.map { name, result in
            ["nodeType": "Test Case", "name": name, "nodeIdentifier": "Suite/\(name)", "result": result]
        }
        if orphan {
            children.insert([
                "nodeType": "Test Case", "name": "Issues recorded without an associated test or suite",
                "nodeIdentifier": "Issues recorded without an associated test or suite", "result": "Failed",
                "children": [["nodeType": "Runtime Warning", "name": "Multiple Runtime Warnings"]],
            ], at: 0)
        }
        let root: [String: Any] = ["devices": [], "testPlanConfigurations": [], "testNodes": [[
            "nodeType": "Test Plan", "name": "Variorum", "result": "Passed",
            "children": [["nodeType": "Unit test bundle", "name": "VariorumTests", "result": "Passed",
                          "children": cases.isEmpty && !orphan ? [] : [[
                              "nodeType": "Test Suite", "name": "Suite", "result": "Passed", "children": children,
                          ]]]],
        ]]]
        let data = try! JSONSerialization.data(withJSONObject: root, options: [.sortedKeys])
        return String(decoding: data, as: UTF8.self)
    }

    // MARK: - The pins

    @Test func theVX604FalseGreenReadsZeroExecuted() throws {
        // The old gates' reading, stated: every verdict line here says green.
        #expect(Self.zeroExecutedLog.contains("** TEST SUCCEEDED **"))
        #expect(Self.zeroExecutedLog.contains("Test run with 0 tests in 1 suite passed"))
        let outcome = try Self.gate([("zero.log", Self.zeroExecutedLog)])
        #expect(outcome.status == 2, "zero executed is exit 2 (\(outcome.output))")
        #expect(outcome.output.contains("ZERO EXECUTED"), "said loudly (\(outcome.output))")
        #expect(outcome.output.contains("FALSE GREEN"), "and named for what it is (\(outcome.output))")
        #expect(outcome.output.contains("VERDICT: ZERO EXECUTED (2)"))
    }

    @Test func aRealGreenRunReadsGreenWithItsCount() throws {
        let outcome = try Self.gate([("green.log", Self.greenLog)])
        #expect(outcome.status == 0, "\(outcome.output)")
        #expect(outcome.output.contains("executed 3"), "the per-test lines are counted (\(outcome.output))")
        #expect(outcome.output.contains("VERDICT: GREEN (0) - 3 test(s) executed"))
        let short = try Self.gate([("green.log", Self.greenLog)], extra: ["--expect-at-least", "4"])
        #expect(short.status == 2, "fewer than expected is the same class (\(short.output))")
    }

    @Test func swiftTestingsCountOfSkippedTestsIsNeverAnExecutedCount() throws {
        let outcome = try Self.gate([("skipped.log", Self.skippedOnlyLog)])
        #expect(outcome.status == 2, "two skipped tests executed nothing (\(outcome.output))")
        #expect(outcome.output.contains("skipped 2"), "\(outcome.output)")
        #expect(outcome.output.contains("ZERO EXECUTED"))
    }

    @Test func aHostCrashOutranksEverything() throws {
        let outcome = try Self.gate([("crash.log", Self.crashLog)])
        #expect(outcome.status == 3, "\(outcome.output)")
        #expect(outcome.output.contains("HOST CRASH MARK"), "\(outcome.output)")
        #expect(outcome.output.contains("VERDICT: HOST CRASH (3)"))
        let summary = """
            {"passedTests": 2, "failedTests": 1, "skippedTests": 0, "expectedFailures": 0, "result": "Failed",
             "testFailures": [{"testName": "theProbe()", "failureText": "Crash: Variorum (51234) at closure in AppSession.init"}]}
            """
        let bundle = try Self.gate([("summary.json", summary)])
        #expect(bundle.status == 3, "a crash recorded in a bundle's failures (\(bundle.output))")
    }

    @Test func anIssueOutsideEveryTestIsAFailureNeverATest() throws {
        let tree = Self.tree([("a()", "Passed"), ("b()", "Passed"), ("c()", "Passed")], orphan: true)
        let outcome = try Self.gate([("tests.json", tree)])
        #expect(outcome.status == 1, "the 2026-11-08 shape: every real test passed, the run failed (\(outcome.output))")
        #expect(outcome.output.contains("executed 3"), "the pseudo-test is not counted (\(outcome.output))")
        #expect(outcome.output.contains("Issues recorded without an associated test or suite"))
        let log = try Self.gate([("host.log", Self.hostIssueLog)])
        #expect(log.status == 1, "the console's own note of a host-raised issue (\(log.output))")
        #expect(log.output.contains("VX-604's class"), "\(log.output)")
    }

    @Test func theTreeCountsExecutedExactly() throws {
        let empty = try Self.gate([("empty.json", Self.tree([]))])
        #expect(empty.status == 2, "a tree with no test case ran nothing (\(empty.output))")
        let mixed = try Self.gate([("mixed.json", Self.tree([("a()", "Passed"), ("b()", "Skipped")]))])
        #expect(mixed.status == 0, "\(mixed.output)")
        #expect(mixed.output.contains("executed 1") && mixed.output.contains("skipped 1"), "\(mixed.output)")
        let failed = try Self.gate([("failed.json", Self.tree([("a()", "Passed"), ("b()", "Failed")]))])
        #expect(failed.status == 1, "\(failed.output)")
    }

    @Test func everyRunMustExecuteAndAMissingInputIsUsage() throws {
        let two = try Self.gate([("green.log", Self.greenLog), ("zero.log", Self.zeroExecutedLog)])
        #expect(two.status == 2, "one chunk that ran nothing fails the whole (\(two.output))")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", "-I", Self.script.path, "/nonexistent/vx604.xcresult"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        try process.run()
        process.waitUntilExit()
        #expect(process.terminationStatus == 4, "an input that does not exist is a usage error")
    }
}
