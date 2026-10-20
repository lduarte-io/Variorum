import Foundation
import Testing
@testable import AmbientKit

/// Rail 2. The claims here are written by the REAL `Tools/stage` (into a throwaway HOME), so the
/// parser is checked against the tool's exact `printf %q` spelling — including the em dash the
/// coordinator's own hold reason carries, which bash writes as raw and octal-escaped bytes.
@Suite struct StageClaimTests {
    static let stageTool = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().appendingPathComponent("stage")

    struct Sandbox {
        let home: URL
        var lock: URL { home.appendingPathComponent(".variorum/stage.d", isDirectory: true) }

        init() throws {
            home = FileManager.default.temporaryDirectory.appendingPathComponent("ambient-stage-\(UUID().uuidString)")
            try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        }

        /// The locale the real tool runs under: bash's `printf %q` writes non-ASCII differently under each
        /// (all-octal `$'…\342\200\224…'` under C; under UTF-8, bash 3.2 writes the lead byte RAW and the
        /// rest octal, which is not valid UTF-8 — the coordinator's own sessions run UTF-8).
        var locale = "en_US.UTF-8"

        @discardableResult
        func stage(_ args: String...) throws -> Int32 {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/bin/bash")
            p.arguments = [StageClaimTests.stageTool.path] + args
            p.environment = ["HOME": home.path, "PATH": "/usr/bin:/bin", "LANG": locale, "LC_ALL": locale]
            p.standardOutput = FileHandle.nullDevice
            p.standardError = FileHandle.nullDevice
            try p.run()
            p.waitUntilExit()
            return p.terminationStatus
        }

        func cleanup() { try? FileManager.default.removeItem(at: home) }
    }

    @Test func stageToolIsWhereTheTestLooks() {
        #expect(FileManager.default.isExecutableFile(atPath: Self.stageTool.path))
    }

    @Test func noLockIsFree() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        #expect(StageClaim.read(lockDirectory: box.lock) == .free)
    }

    @Test(arguments: ["en_US.UTF-8", "C"])
    func theCoordinatorsHoldPermitsTheAmbient(locale: String) throws {
        var box = try Sandbox()
        box.locale = locale
        defer { box.cleanup() }
        try box.stage("claim", "--who", "1018coordinator", "--reason", "HOLD: coordinator queue — ask 1018coordinator", "--minutes", "180")
        let v = StageClaim.read(lockDirectory: box.lock)
        #expect(v == .hold(who: "1018coordinator"))
        #expect(v.permitsAmbient)
    }

    @Test(arguments: ["en_US.UTF-8", "C"])
    func aGoPendingBridgeEndsIt(locale: String) throws {
        var box = try Sandbox()
        box.locale = locale
        defer { box.cleanup() }
        try box.stage("claim", "--who", "coord-for-vx309", "--reason", "GO pending: vx-309 — U2 batch", "--minutes", "15")
        let v = StageClaim.read(lockDirectory: box.lock)
        #expect(v == .foreign(who: "coord-for-vx309", reason: "GO pending: vx-309 — U2 batch"))
        #expect(!v.permitsAmbient)
    }

    /// The exact bytes 1018coordinator's hold left on 2026-10-20 (bash 3.2, UTF-8 locale): a raw 0xE2
    /// followed by the escapes `\200\224`. Not valid UTF-8 as a file — read as text it vanished, and the
    /// ambient refused the coordinator's own hold as "lock without a claim file".
    static let coordinatorHoldBytes: [UInt8] = Array("WHO=1018coordinator\nREASON=$'HOLD: coordinator queue ".utf8)
        + [0xE2] + Array("\\200\\224 ask 1018coordinator'\nCLAIMED=2026-10-19\\ 22:41:07\nEXPIRES_EPOCH=1792482067\n".utf8)

    @Test func theCoordinatorsRealHoldBytesReadAsAHold() throws {
        #expect(String(data: Data(Self.coordinatorHoldBytes), encoding: .utf8) == nil) // the trap, as found
        let box = try Sandbox()
        defer { box.cleanup() }
        try FileManager.default.createDirectory(at: box.lock, withIntermediateDirectories: true)
        try Data(Self.coordinatorHoldBytes).write(to: box.lock.appendingPathComponent("claim"))
        #expect(StageClaim.read(lockDirectory: box.lock) == .hold(who: "1018coordinator"))
        #expect(StageClaim.parse(Self.coordinatorHoldBytes)["REASON"] == "HOLD: coordinator queue — ask 1018coordinator")
    }

    @Test func aClaimFileWithoutItsFieldsIsUnreadableNotMissing() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try FileManager.default.createDirectory(at: box.lock, withIntermediateDirectories: true)
        try Data("garbage\n".utf8).write(to: box.lock.appendingPathComponent("claim"))
        let v = StageClaim.read(lockDirectory: box.lock)
        #expect(v == .unreadable)
        #expect(!v.permitsAmbient)
    }

    @Test func holdForAWalkIsNotTheHoldPrefix() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try box.stage("claim", "--who", "1018coordinator", "--reason", "HOLD FOR vx-308-walk (expired mid-row)", "--minutes", "60")
        #expect(!StageClaim.read(lockDirectory: box.lock).permitsAmbient)
    }

    @Test func anOrdinaryClaimEndsIt() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try box.stage("claim", "--who", "vx-458-probe", "--reason", "VX-458 quit probe", "--minutes", "10")
        #expect(StageClaim.read(lockDirectory: box.lock) == .foreign(who: "vx-458-probe", reason: "VX-458 quit probe"))
    }

    @Test func theAllowedClaimantIsPermittedAndNobodyElse() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try box.stage("claim", "--who", "vx-458-ambient", "--reason", "VX-458 evidence window", "--minutes", "10")
        #expect(StageClaim.read(lockDirectory: box.lock, allowedClaimant: "vx-458-ambient") == .allowed(who: "vx-458-ambient"))
        #expect(!StageClaim.read(lockDirectory: box.lock, allowedClaimant: "someone-else").permitsAmbient)
        #expect(!StageClaim.read(lockDirectory: box.lock).permitsAmbient)
    }

    @Test func releasingFreesIt() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try box.stage("claim", "--who", "x", "--reason", "walk", "--minutes", "10")
        try box.stage("release", "--who", "x")
        #expect(StageClaim.read(lockDirectory: box.lock) == .free)
    }

    @Test func aLockWithoutItsClaimFileIsPending() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try FileManager.default.createDirectory(at: box.lock, withIntermediateDirectories: true)
        #expect(StageClaim.read(lockDirectory: box.lock) == .pending)
        #expect(!StageVerdict.pending.permitsAmbient)
    }

    @Test(arguments: [
        ("HOLD:\\ coordinator\\ queue", "HOLD: coordinator queue"),
        ("$'HOLD: a \\342\\200\\224 b'", "HOLD: a — b"),
        ("$'it\\'s'", "it's"),
        ("''", ""),
        ("plain", "plain"),
        ("$'tab\\there'", "tab\there"),
    ])
    func unquoteReversesPrintfQ(_ quoted: String, _ plain: String) {
        #expect(StageClaim.unquote(quoted) == plain)
    }
}

@Suite struct InputRuleTests {
    @Test func withoutAGateInputDuringTheLaunchGraceIsIgnored() {
        // Launched 0.5 s ago; the last event was 0.4 s ago (inside the grace).
        #expect(!InputRule.inputArrived(watching: InputRule.watching(uptime: 0.5, gateAge: nil), idle: 0.4))
    }

    @Test func inputBeforeTheWatchIsIgnored() {
        #expect(!InputRule.inputArrived(watching: InputRule.watching(uptime: 30, gateAge: nil), idle: 600))
        #expect(!InputRule.inputArrived(watching: InputRule.watching(uptime: 30, gateAge: 31), idle: 600))
    }

    @Test func inputAfterTheWatchStartsEndsIt() {
        #expect(InputRule.inputArrived(watching: InputRule.watching(uptime: 30, gateAge: nil), idle: 0.05))
        #expect(InputRule.inputArrived(watching: InputRule.watching(uptime: 2, gateAge: nil), idle: 1.0))
    }

    /// `on` read the idle time, then built and launched: a touch in between happened BEFORE launch but
    /// AFTER the gate. Launch-relative counting ignored it for good and the ambient came up over her.
    @Test func aTouchBetweenTheGateAndLaunchEndsIt() {
        // Gate 3 s ago, launched 1 s ago, her touch 2 s ago.
        #expect(InputRule.inputArrived(watching: InputRule.watching(uptime: 1, gateAge: 3), idle: 2))
    }

    @Test func anUntrustworthyGateFallsBackToLaunch() {
        #expect(InputRule.watching(uptime: 5, gateAge: -1) == 5 - InputRule.launchGrace)
        #expect(InputRule.watching(uptime: 5, gateAge: 600) == 5 - InputRule.launchGrace)
        #expect(InputRule.watching(uptime: 5, gateAge: .nan) == 5 - InputRule.launchGrace)
    }

    @Test func nonsenseNeverEndsIt() {
        #expect(!InputRule.inputArrived(watching: .nan, idle: 0))
        #expect(!InputRule.inputArrived(watching: 10, idle: .infinity))
    }
}

@Suite struct StageWatchTests {
    func go(_ w: inout StageWatch, _ v: StageVerdict, _ t: Double) -> Bool { w.mustGo(after: v, at: t) }

    /// `Tools/stage` truncates and rewrites the claim file on every claim and renew — the coordinator's
    /// own HOLD renewals too — so a poll can land on an empty file. That must not end the ambient.
    @Test func theCoordinatorsRenewMidWriteDoesNotEndIt() {
        var w = StageWatch()
        #expect(!go(&w, .hold(who: "c"), 0))
        #expect(!go(&w, .unreadable, 0.25))
        #expect(!go(&w, .hold(who: "c"), 0.5))
        #expect(!go(&w, .unreadable, 0.75)) // a fresh grace after the hold came back
    }

    @Test func aLockThatStaysUnsettledEndsItAfterTheGrace() {
        var w = StageWatch()
        #expect(!go(&w, .pending, 10))
        #expect(!go(&w, .pending, 10.25))
        #expect(go(&w, .pending, 10.5))
        var u = StageWatch()
        #expect(!go(&u, .unreadable, 0))
        #expect(go(&u, .unreadable, 0.5))
    }

    @Test func aForeignClaimEndsItAtOnce() {
        var w = StageWatch()
        #expect(go(&w, .foreign(who: "coord-for-x", reason: "GO pending: x"), 0))
        var v = StageWatch()
        #expect(!go(&v, .pending, 0))
        #expect(go(&v, .foreign(who: "x", reason: "walk"), 0.1))
    }

    @Test func freeHoldAndTheAllowedClaimantKeepItUp() {
        var w = StageWatch()
        for (i, v) in [StageVerdict.free, .hold(who: "c"), .allowed(who: "me"), .free].enumerated() {
            #expect(!go(&w, v, Double(i)))
        }
    }
}

@Suite struct LaunchRuleTests {
    @Test func itComesUpOnlyWhenTheStageIsItsTheScreenIsUnlockedAndTheDisplayIsAwake() {
        #expect(LaunchRule.refusal(stage: .hold(who: "c"), screenLocked: false, displayAsleep: false) == nil)
        #expect(LaunchRule.refusal(stage: .free, screenLocked: false, displayAsleep: false) == nil)
        #expect(LaunchRule.refusal(stage: .foreign(who: "x", reason: "walk"), screenLocked: false, displayAsleep: false)?.exitCode == 3)
        #expect(LaunchRule.refusal(stage: .unreadable, screenLocked: false, displayAsleep: false)?.reason == "stage claim file unreadable")
        #expect(LaunchRule.refusal(stage: .hold(who: "c"), screenLocked: true, displayAsleep: false)?.exitCode == 4)
    }

    /// The overnight road: the display slept long before the coordinator's after-RELEASE `on`. Drawing to
    /// a dark display helps nobody, and waking it takes input, which ends the ambient anyway.
    @Test func anAsleepDisplayRefuses() {
        let r = LaunchRule.refusal(stage: .hold(who: "c"), screenLocked: false, displayAsleep: true)
        #expect(r == LaunchRule.Refusal(reason: "display asleep", exitCode: 7))
    }
}
