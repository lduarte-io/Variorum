import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-874 (the VX-878 run, batch 3 — the record
// `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3 RECORD): THE TRAIL
// DIAL CHANGES NOTHING ON THE WIRE. The dial is the sidebar's AI section's (an
// app face no tool reads), stored as one row of the local-only `mcp_switch`
// family beside the server switch and the open book — and that family's rows
// are part of the grants store's fingerprint, whose every change re-announces
// `tools/list_changed` to each connected client. So the trail dial's row is
// excluded exactly as the show dial's is (VX-676): turning it announces nothing.
// RED by construction before the exclusion (the fingerprint read every key but
// `show_dial`). The control: the open book — a real switch — still moves it.

@Suite("VX-874 — the trail dial stays off the grants store's fingerprint")
struct MCPTrailDialFingerprintTests {
    @Test func turningTheTrailDialAnnouncesNothing() throws {
        let database = try AppDatabase.inMemory()
        let tick = LockIsolated(0)
        try withDependencies {
            $0.database = database
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return Date(timeIntervalSince1970: 1_782_864_000).addingTimeInterval(Double(seconds))
            }
        } operation: {
            let ops = Operations()
            let before = try database.read { try MCPServerHost.grantsFingerprint($0) }
            for dial in [MCPTrailDial.asksOnly, .off, .everything] {
                try ops.setMCPTrailDial(dial)
                let now = try database.read { try MCPServerHost.grantsFingerprint($0) }
                #expect(now == before, "the trail dial (\(dial)) is no part of what the tool list depends on")
            }
            try ops.setMCPShowDial(.never)
            #expect(try database.read { try MCPServerHost.grantsFingerprint($0) } == before, "nor the show dial")
            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try database.read { try MCPServerHost.grantsFingerprint($0) } != before,
                    "the control: a real switch still moves it")
        }
    }
}
