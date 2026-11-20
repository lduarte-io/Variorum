import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-944 (the VX-981 run, batch 3 — the record
// `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 3 — RECORD; the VX-940
// ladder's F-R1-2): ONE STALLED CLIENT NEVER DELAYS ANOTHER SESSION'S ANNOUNCE,
// NOR THE UNLOCK.
//
// THE MECHANISM: the host's two announce roads — the grants observation and the
// unlock's `resume` — awaited each session's announce IN SERIES, and an announce
// to a connection whose writer still holds an earlier frame waits until that
// client reads. So a client that stopped reading with a big answer pending held
// the round at its session: every later session missed the change (and every
// later change), and `resume` never returned — the door's unlock face froze.
//
// THE PINS, made deterministic over real sockets (no seam): client A says it is
// ready, then sends a `ping` whose id is 200 KB and NEVER READS — the SDK's answer
// echoes the id, far past the socket's buffers, so A's writer is stuck the moment
// A holds its first bytes (the premise, read from `SO_NREAD`). Client B reads.
// Bug-class: RED on the old door (every API here predates the fix). Each "within
// the bound" is ten seconds (`announceStallBound`); a reading session hears in
// milliseconds. TWO grant changes make the red independent of the host's session
// order: if B comes first in the round it still misses the SECOND change, because
// the old round never finished the first.

/// A world of two approved clients past their gates: A stalled on its 200 KB
/// ping answer, B reading every line.
private struct StallWorld {
    let stalled: AnnounceRawClient
    let reader: AnnounceRawClient
    let readerID: String
    let notes: [String]

    static let longID = String(repeating: "s", count: 200_000)

    static func make(_ h: ServerHarness) async throws -> StallWorld {
        let notes = try (0..<4).map { index in
            try h.operations.createPost(title: "note \(index)").id
        }
        let stalledKey = try h.setupKey(for: "stall-a")
        let readerKey = try h.setupKey(for: "read-b")
        let stalled = try await AnnounceRawClient.open(
            h.directory, key: stalledKey, as: "stall-a", id: 1, then: AnnounceRawClient.initialized)
        let stalledFD = stalled.fd
        HarnessWait.bound(stalledFD, seconds: HarnessWait.receiveSeconds)
        let answer = await HarnessWait.offPool { MCPShim.readFirstLine(stalledFD, limit: 1 << 20) }
        try #require(AnnounceRawClient.object(answer)?["result"] != nil, "A's initialize answered")
        let reader = try await AnnounceRawClient.open(
            h.directory, key: readerKey, as: "read-b", id: 1, then: AnnounceRawClient.initialized)
        reader.startReading()
        try #require(await reader.waitUntil { !$0.isEmpty })
        let read = { (note: String) in
            Operations.MCPGrantSpec(rung: .read, scopeKind: .note, scopeID: note, duration: .always)
        }
        _ = try h.approve("stall-a", read(notes[0]))
        _ = try h.approve("read-b", read(notes[0]))
        // B's barrier: its gate is open and its answers flow.
        await reader.write(AnnounceRawClient.ping(900))
        try #require(await reader.waitUntil { AnnounceRawClient.answer($0, to: 900) != nil })

        // A pings with a 200 KB id and stops reading: its answer is stuck.
        await stalled.write(#"{"jsonrpc":"2.0","id":"\#(longID)","method":"ping"}"# + "\n")
        try #require(await pollUntil(HarnessDeadline.seconds) { stalled.unreadBytes >= 4_096 },
                     "premise: A's 200 KB answer has begun, so its writer waits on A")

        // Premise: B is still served while A has stopped reading. (Round 1's N5, the
        // VX-981 ladder: this is no barrier for the setup's own announces — a ping's
        // answer and a notice travel on different tasks, and the two approvals owe
        // B and A 0, 1 or 2 notices: the observation skips its first value, and two
        // commits may coalesce into one. So nothing below counts on them having
        // settled, and the 200 ms pause that stood here is gone.)
        await reader.write(AnnounceRawClient.ping(901))
        try #require(await reader.waitUntil { AnnounceRawClient.answer($0, to: 901) != nil })
        return StallWorld(
            stalled: stalled, reader: reader, readerID: try h.client("read-b").id, notes: notes)
    }

    func grant(_ h: ServerHarness, note index: Int) throws {
        _ = try h.operations.grantMCPAccess(
            readerID, .init(rung: .read, scopeKind: .note, scopeID: notes[index], duration: .always))
    }
}

@Suite("VX-944 — one stalled client never delays another's announce, nor the unlock", .serialized)
struct MCPAnnounceStallServerTests {
    /// **The grants observation:** with A stalled, each grant change reaches B
    /// within the bound — the first and the second (the second carries the teeth:
    /// on the old serial round at most ONE notice reaches B after A stalls, so
    /// `>= base + 2` cannot go green there, whatever the setup left pending). And
    /// the stalled client's own notices wait in its own order: once A reads, its
    /// answer arrives whole and AT LEAST its two notices after it, nothing but
    /// whole notices (none lost, nothing interleaved). Round 1's N5 (the VX-981
    /// ladder): "exactly two" is not assertable here — the setup's approvals owe
    /// A 0, 1 or 2 notices of their own, indistinguishable from a doubled one — so
    /// "none doubled" is guarded where no setup notice can confuse it:
    /// `MCPAnnounceOrderServerTests.nAsksSendNNoticesOnceTheGateIsOpen` (a GUARD — its
    /// strength is said in its own doc).
    @Test func aClientThatStoppedReadingNeverDelaysAnotherSessionsAnnounce() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let world = try await StallWorld.make(h)
            let base = world.reader.listChangedCount

            try world.grant(h, note: 1)
            #expect(await world.reader.waitUntil(announceStallBound) {
                $0.filter(AnnounceRawClient.isListChanged).count >= base + 1
            }, "the first grant change reached B while A has stopped reading")
            try world.grant(h, note: 2)
            #expect(await world.reader.waitUntil(announceStallBound) {
                $0.filter(AnnounceRawClient.isListChanged).count >= base + 2
            }, "and the second")

            // A reads now: everything it was owed, in its own order.
            world.stalled.startReading()
            let answered = { (lines: [Data]) -> Int? in
                lines.firstIndex { (AnnounceRawClient.object($0)?["id"] as? String) == StallWorld.longID }
            }
            #expect(await world.stalled.waitUntil { lines in
                guard let at = answered(lines) else { return false }
                return lines[(at + 1)...].filter(AnnounceRawClient.isListChanged).count >= 2
            }, "A's answer whole, then its two notices")
            let lines = world.stalled.lines
            if let at = answered(lines) {
                #expect(lines[..<at].allSatisfy(AnnounceRawClient.isListChanged), "only notices came before its answer")
                let after = lines[(at + 1)...]
                #expect(after.count >= 2 && after.allSatisfy(AnnounceRawClient.isListChanged),
                        "at least its two notices after it, each whole, and nothing else (\(after.count) lines)")
            }
            await world.stalled.finish()
            await world.reader.finish()
        }
    }

    /// **The unlock:** with A stalled, `resume` returns within the bound (the
    /// door's unlock face runs on its return — `MCPDoor.resumeSuspended`), the
    /// same connections are served, and B hears the resume's notice.
    @Test func theResumeNeverWaitsOnAClientThatStoppedReading() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let world = try await StallWorld.make(h)
            let base = world.reader.listChangedCount
            #expect(h.host.suspend())
            try h.lockStore()
            try h.unlockStore()

            let host = h.host
            let fresh = SeededExecutor(operations: h.writeOperations)
            let outcome = LockIsolated<MCPServerHost.ResumeOutcome?>(nil)
            let resuming = Task.detached {
                let resumed = await host.resume(executor: fresh)
                outcome.setValue(resumed)
            }
            let inTime = await pollUntil(announceStallBound) { outcome.value != nil }
            #expect(inTime, "the resume returned while a client has stopped reading")
            if !inTime { world.stalled.startReading() }  // let the stuck round go, so the pin reports
            await resuming.value
            #expect(outcome.value == .resumed)
            #expect(await world.reader.waitUntil(announceStallBound) {
                $0.filter(AnnounceRawClient.isListChanged).count >= base + 1
            }, "B heard the resume's notice")
            await world.reader.write(AnnounceRawClient.call("list_my_activity", id: 950))
            #expect(await world.reader.waitUntil { AnnounceRawClient.answer($0, to: 950) != nil })
            let served = AnnounceRawClient.answer(world.reader.lines, to: 950)?["result"] as? [String: Any]
            #expect(served != nil && (served?["isError"] as? Bool) != true, "the same connection is served")
            await world.stalled.finish()
            await world.reader.finish()
        }
    }
}
