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

        @discardableResult
        func stage(_ args: String...) throws -> Int32 {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/bin/bash")
            p.arguments = [StageClaimTests.stageTool.path] + args
            p.environment = ["HOME": home.path, "PATH": "/usr/bin:/bin"]
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

    @Test func theCoordinatorsHoldPermitsTheAmbient() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try box.stage("claim", "--who", "1018coordinator", "--reason", "HOLD: coordinator queue — ask 1018coordinator", "--minutes", "180")
        let v = StageClaim.read(lockDirectory: box.lock)
        #expect(v == .hold(who: "1018coordinator"))
        #expect(v.permitsAmbient)
    }

    @Test func aGoPendingBridgeEndsIt() throws {
        let box = try Sandbox()
        defer { box.cleanup() }
        try box.stage("claim", "--who", "coord-for-vx309", "--reason", "GO pending: vx-309 — U2 batch", "--minutes", "15")
        let v = StageClaim.read(lockDirectory: box.lock)
        #expect(v == .foreign(who: "coord-for-vx309", reason: "GO pending: vx-309 — U2 batch"))
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
    @Test func inputDuringTheLaunchGraceIsIgnored() {
        // Launched 0.5 s ago; the last event was 0.4 s ago (inside the grace).
        #expect(!InputRule.inputArrived(uptime: 0.5, idle: 0.4))
    }

    @Test func inputBeforeLaunchIsIgnored() {
        #expect(!InputRule.inputArrived(uptime: 30, idle: 600))
    }

    @Test func inputAfterTheGraceEndsIt() {
        #expect(InputRule.inputArrived(uptime: 30, idle: 0.05))
        #expect(InputRule.inputArrived(uptime: 2, idle: 1.0))
    }

    @Test func nonsenseNeverEndsIt() {
        #expect(!InputRule.inputArrived(uptime: .nan, idle: 0))
        #expect(!InputRule.inputArrived(uptime: 10, idle: .infinity))
    }
}
