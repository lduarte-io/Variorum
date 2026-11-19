#if DEBUG
import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-951 (the VX-981 run, batch 3 — the record
// `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 3 — RECORD; the VX-940
// W4 finding F-W4-1): `tools/list_changed` NEVER AHEAD OF A CONNECTION'S
// `initialize` ANSWER, and held until the client is ready — her R-981-3, "Ready or
// first request" (the shape memo's (b′)).
//
// THE MECHANISM: the session names itself inside the SDK's `initialize` hook,
// BEFORE the answer is sent, and the announce gated only on that name — so a grant
// change landing between the naming and the answer's write put the notification on
// the wire first (the recorded cause of `twoToolsUnderOneNameAreToldApart`'s load
// flake). The pins make that window DETERMINISTIC: the host's `namingProbe` (DEBUG)
// runs inside the hook just after the naming, and runs the very round a
// grants-fingerprint change runs (`announceGrantsChanged`) — the grant change,
// landed exactly there. No sleep is the mechanism.
//
// Bug-class pins are RED on the scaffold (`eb7de82e3` — the gate heard, the
// announce unchanged); GUARDS are green on both sides and say so.

/// The lines' first frame is the answer to the `initialize` with `id`.
private func firstIsTheAnswer(_ lines: [Data], id: Int) -> Bool {
    guard let first = lines.first.flatMap(AnnounceRawClient.object) else { return false }
    return (first["id"] as? Int) == id && first["result"] != nil && first["method"] == nil
}

private func describe(_ lines: [Data]) -> String {
    lines.map { line in
        let text = String(decoding: line.prefix(120), as: UTF8.self)
        return line.count > 120 ? text + "…" : text
    }.joined(separator: " | ")
}

@Suite("VX-951 — tools/list_changed never ahead of a connection's initialize answer", .serialized)
struct MCPAnnounceOrderServerTests {
    /// **A grant change inside the window** (the naming done, the answer not yet
    /// written): the connection's first frame is its `initialize` answer; nothing
    /// of ours follows while the client has not said it is ready (a `ping` —
    /// which MCP lets a client send at any time — opens nothing); once it says
    /// `initialized`, exactly ONE `list_changed` catches it up.
    @Test func theFirstFrameIsTheInitializeAnswerWhenAGrantChangeLandsInTheWindow() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let key = try h.setupKey(for: "claude-code")
            let host = h.host
            let window = LockIsolated(0)
            host.namingProbe = { _ in
                window.withValue { $0 += 1 }
                host.announceGrantsChanged()
            }
            let client = try await AnnounceRawClient.open(h.directory, key: key, as: "claude-code", id: 41)
            client.startReading()
            #expect(await client.waitUntil { !$0.isEmpty })
            #expect(window.value == 1, "premise: the grant change landed in the window")
            #expect(firstIsTheAnswer(client.lines, id: 41),
                    "the first frame a connection reads is its initialize answer: \(describe(client.lines))")

            await client.write(AnnounceRawClient.ping(42))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 42) != nil })
            #expect(client.listChangedCount == 0,
                    "nothing is announced before the client says it is ready: \(describe(client.lines))")

            await client.write(AnnounceRawClient.initialized + AnnounceRawClient.ping(43))
            #expect(await client.waitUntil {
                AnnounceRawClient.answer($0, to: 43) != nil && $0.contains(where: AnnounceRawClient.isListChanged)
            }, "the remembered announce goes out once it is ready: \(describe(client.lines))")
            await client.write(AnnounceRawClient.ping(44))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 44) != nil })
            #expect(client.listChangedCount == 1, "exactly ONE catch-up: \(describe(client.lines))")
            await client.finish()
        }
    }

    /// **(b′): a client that never says `initialized` but LISTS** has finished
    /// initializing — its first `tools/list` opens the gate and the remembered
    /// announce goes out, once. Without this arm such a client would never hear
    /// an announce again (VX-258's Allow, for one).
    @Test func aClientThatListsWithoutSayingInitializedOpensTheGateAtItsFirstRequest() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let key = try h.setupKey(for: "claude-code")
            let host = h.host
            host.namingProbe = { _ in host.announceGrantsChanged() }
            let client = try await AnnounceRawClient.open(h.directory, key: key, as: "claude-code", id: 51)
            client.startReading()
            #expect(await client.waitUntil { !$0.isEmpty })
            #expect(firstIsTheAnswer(client.lines, id: 51), "\(describe(client.lines))")
            await client.write(AnnounceRawClient.ping(52))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 52) != nil })
            #expect(client.listChangedCount == 0, "a ping opens nothing: \(describe(client.lines))")

            await client.write(AnnounceRawClient.listTools(53))
            #expect(await client.waitUntil {
                AnnounceRawClient.answer($0, to: 53) != nil && $0.contains(where: AnnounceRawClient.isListChanged)
            }, "its first tools/list opens the gate: \(describe(client.lines))")
            await client.write(AnnounceRawClient.ping(54))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 54) != nil })
            #expect(client.listChangedCount == 1, "exactly ONE catch-up: \(describe(client.lines))")
            await client.finish()
        }
    }

    /// **A client that PIPELINES `initialized` behind its `initialize`** (before
    /// reading the answer): the session hears the client ready while the answer
    /// is still unwritten, and a grant change then — the probe waits until the
    /// session has heard the `initialized` — must still not precede the answer.
    /// The gate's first half (the answer WRITTEN) is what holds it; the one
    /// catch-up follows the answer.
    @Test func aClientThatPipelinesInitializedStillHearsNothingBeforeItsAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let key = try h.setupKey(for: "claude-code")
            let host = h.host
            let heardReady = LockIsolated(false)
            let readyInWindow = LockIsolated(false)
            host.gateEventProbe = { _, event in
                if event == .clientInitialized { heardReady.setValue(true) }
            }
            host.namingProbe = { _ in
                let heard = await pollUntil(HarnessDeadline.seconds) { heardReady.value }
                readyInWindow.setValue(heard)
                host.announceGrantsChanged()
            }
            let client = try await AnnounceRawClient.open(
                h.directory, key: key, as: "claude-code", id: 61, then: AnnounceRawClient.initialized)
            client.startReading()
            #expect(await client.waitUntil { !$0.isEmpty })
            #expect(readyInWindow.value, "premise: the session heard initialized inside the window")
            #expect(firstIsTheAnswer(client.lines, id: 61),
                    "the answer first, whatever the client pipelined: \(describe(client.lines))")
            await client.write(AnnounceRawClient.ping(62))
            #expect(await client.waitUntil {
                AnnounceRawClient.answer($0, to: 62) != nil && $0.contains(where: AnnounceRawClient.isListChanged)
            }, "\(describe(client.lines))")
            await client.write(AnnounceRawClient.ping(63))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 63) != nil })
            #expect(client.listChangedCount == 1, "exactly ONE, after the answer: \(describe(client.lines))")
            await client.finish()
        }
    }

    /// GUARD (green on both sides): a gate that opens with nothing remembered
    /// sends nothing — the catch-up is owed only for an announce that was held.
    @Test func aGateThatOpensWithNothingRememberedSendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let key = try h.setupKey(for: "claude-code")
            let client = try await AnnounceRawClient.open(h.directory, key: key, as: "claude-code", id: 81)
            client.startReading()
            #expect(await client.waitUntil { !$0.isEmpty })
            #expect(firstIsTheAnswer(client.lines, id: 81))
            await client.write(AnnounceRawClient.initialized + AnnounceRawClient.ping(82))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 82) != nil })
            await client.write(AnnounceRawClient.ping(83))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 83) != nil })
            #expect(client.listChangedCount == 0, "\(describe(client.lines))")
            await client.finish()
        }
    }

    /// GUARD (round 1's N5, the VX-981 ladder — green on both trees): **N asks send N
    /// notices** — none doubled, none merged — on the open-gate road (batch 3's "counts
    /// unchanged"). A PENDING client (its row is outside the grants fingerprint), so its
    /// admission moves nothing and no round is natural: the gate opened (`initialized`, a
    /// ping barrier), three rounds asked, three notices, a ping barrier, then exactly three.
    /// The exactness `MCPAnnounceStallServerTests` gives up (its setup's approvals owe
    /// 0–2 notices of their own) lives here, where no setup notice can confuse it. Its
    /// honest strength (round 2's R2-N1): green on both trees and never a false red; it
    /// catches a doubled notice unless the extra one is still in flight past the ping's
    /// answer — a ping's answer and a notice ride different tasks, so the barrier orders
    /// nothing between them.
    @Test func nAsksSendNNoticesOnceTheGateIsOpen() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let key = try h.setupKey(for: "claude-code")
            let host = h.host
            let client = try await AnnounceRawClient.open(h.directory, key: key, as: "claude-code", id: 101)
            client.startReading()
            #expect(await client.waitUntil { !$0.isEmpty })
            #expect(firstIsTheAnswer(client.lines, id: 101), "\(describe(client.lines))")
            await client.write(AnnounceRawClient.initialized + AnnounceRawClient.ping(102))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 102) != nil }, "the gate is open")
            #expect(try h.client("claude-code").state == .pending, "premise: a pending client, outside the fingerprint")
            #expect(client.listChangedCount == 0, "premise: no round is natural here: \(describe(client.lines))")

            for _ in 0..<3 { host.announceGrantsChanged() }
            #expect(await client.waitUntil { $0.filter(AnnounceRawClient.isListChanged).count >= 3 },
                    "three asks, three notices: \(describe(client.lines))")
            await client.write(AnnounceRawClient.ping(103))
            #expect(await client.waitUntil { AnnounceRawClient.answer($0, to: 103) != nil })
            #expect(client.listChangedCount == 3, "exactly three — none doubled, none merged: \(describe(client.lines))")
            await client.finish()
        }
    }

    /// **VX-818 × VX-951 — a connection HELD by the lock** (its `initialize`
    /// answered while the library was locked, naming no one) is admitted at the
    /// unlock and told its tools changed — but a held client that has not yet
    /// said `initialized` hears nothing until it does, then exactly ONE.
    @Test func aHeldConnectionHearsNothingAtTheResumeUntilItSaysInitialized() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let key = try h.setupKey(for: "claude-code")
            #expect(h.host.suspend())
            try h.lockStore()
            let held = try await AnnounceRawClient.open(h.directory, key: key, as: "claude-code", id: 71)
            held.startReading()
            #expect(await held.waitUntil { !$0.isEmpty })
            #expect(firstIsTheAnswer(held.lines, id: 71), "answered while held: \(describe(held.lines))")

            try h.unlockStore()
            #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
            #expect(await pollUntil(HarnessDeadline.seconds) { h.host.connectedClientNames == ["claude-code"] },
                    "admitted at the resume")
            await held.write(AnnounceRawClient.ping(72))
            #expect(await held.waitUntil { AnnounceRawClient.answer($0, to: 72) != nil })
            #expect(held.listChangedCount == 0,
                    "the resume's announces wait for the client to say it is ready: \(describe(held.lines))")

            await held.write(AnnounceRawClient.initialized + AnnounceRawClient.ping(73))
            #expect(await held.waitUntil {
                AnnounceRawClient.answer($0, to: 73) != nil && $0.contains(where: AnnounceRawClient.isListChanged)
            }, "\(describe(held.lines))")
            await held.write(AnnounceRawClient.ping(74))
            #expect(await held.waitUntil { AnnounceRawClient.answer($0, to: 74) != nil })
            #expect(held.listChangedCount == 1, "exactly ONE catch-up: \(describe(held.lines))")
            await held.finish()
        }
    }

    /// GUARD (VX-818's held connection, kept): a held client that said
    /// `initialized` during the lock is admitted at the unlock and RESUMED WITH
    /// ITS ANNOUNCE, on the same connection.
    @Test func aHeldConnectionThatSaidInitializedDuringTheLockHearsTheResume() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await h.within {
            let key = try h.setupKey(for: "claude-code")
            #expect(h.host.suspend())
            try h.lockStore()
            let held = try await AnnounceRawClient.open(
                h.directory, key: key, as: "claude-code", id: 91,
                then: AnnounceRawClient.initialized + AnnounceRawClient.ping(92))
            held.startReading()
            #expect(await held.waitUntil { AnnounceRawClient.answer($0, to: 92) != nil })
            #expect(held.listChangedCount == 0, "nothing while locked: \(describe(held.lines))")

            try h.unlockStore()
            #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
            #expect(await held.waitUntil { $0.contains(where: AnnounceRawClient.isListChanged) },
                    "resumed with its announce: \(describe(held.lines))")
            #expect(h.host.connectedClientNames == ["claude-code"])
            await held.finish()
        }
    }
}
#endif
