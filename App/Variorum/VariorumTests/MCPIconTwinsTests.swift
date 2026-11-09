//
//  MCPIconTwinsTests.swift
//  VariorumTests (Mac)
//
//  VX-900 — THE ICON TWINS' ONE RULE. Her ruling (the #264 sitting, Nov 8):
//  "it's weird for private and shared to go by different rules. I do think
//  they should show, but maybe they should be a bit greyed out or something
//  when the server is off (and hovering it could say the server is off). they
//  should both be standardized though. and it's helpful to see what's shared /
//  what's private BEFORE you flip the server to on."
//
//  The shared icon (`MCPSharedIcon`) and the Private eye (`PrivateMarkView`)
//  draw while a client is APPROVED, server on or off; while the server's
//  switch is OFF both wear the dimmed face (`tokens.faint`, F-900-A) and their
//  hovers append "The MCP server is off." (F-900-B) — ONE rule,
//  `MCPServerOffFace`, read off the window's road. The trace (the record's
//  BATCH 2 LIVE STATUS): the ROWS never waited for the server; the note's
//  MASTHEAD was the one waiter (VX-164's `indicatorOn`) — so on rows the batch
//  adds the dimmed state, and on the masthead it also makes the icon draw.
//
//  The record's three pins:
//    (a) approved + server OFF ⇒ both marks drawn, dimmed, the hover saying so
//        — the faces mounted, and the masthead mounted over a store (RED ON
//        OLD by construction: the old masthead drew no shared icon with the
//        switch off — `if indicatorOn, …`);
//    (b) no approved client ⇒ neither drawn, nothing read past the client list
//        — the masthead's composed read traced (RED ON OLD for the
//        asked-for-reach arm: the old singular `mcpNoteReach` read the note's
//        facts before it knew nobody was approved) and mounted under both
//        switch states; the core fences, extended across the switch, are
//        `MCPRowReachTests` / `PrivateMarkFactsTests` (headless);
//    (c) approved + server ON (and no road at all) ⇒ today's face byte for
//        byte — the same tokens, the same hover strings.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withTwinsWorld<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        // Random ids: the eye's probe is keyed by subject id across the whole
        // test host, so these never collide with another suite's.
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 900))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private let vault = Queries.BookRef(id: "vx900-b-vault", name: "the vault")

private func approvedClient(_ name: String = "claude-code") -> MCPClient {
    MCPClient(id: "vx900-c-\(name)", name: name, version: nil, state: .approved,
              firstSeenAt: "", lastSeenAt: "", decidedAt: nil)
}

/// An approved client's reach on a place through an always Home wing grant.
private func wingReach() -> MCPPlaceReach {
    let client = approvedClient()
    return MCPPlaceReach(
        client: client, rung: .read,
        grant: MCPGrantRow(
            id: "vx900-g", clientID: client.id, rung: .read, scopeKind: .wing, scopeID: "",
            duration: .always, createdAt: "", consumedAt: nil, revokedAt: nil),
        throughTitle: "Home")
}

/// A window's road with the gates set (no sheet — the pins read faces).
/// VX-934 (A JUSTIFIED EDIT): the road carries her AI-pair switch; every arm
/// here keeps it ON — her default, today's state — unless it says otherwise.
@MainActor
private func road(serverOn: Bool, canShare: Bool = true, aiMarksOn: Bool = true) -> MCPShareRoad {
    MCPShareRoad(
        canShare: canShare, serverOn: serverOn, aiMarksOn: aiMarksOn, open: { _ in },
        sheet: { _, _ in AnyView(EmptyView()) }, revoke: { _ in })
}

private let offSentence = "The MCP server is off."

@MainActor
@Suite("VX-900 — the icon twins: one rule, a dimmed face while the server is off", .serialized)
struct MCPIconTwinsTests {
    // MARK: - The rule, pure

    /// The ONE rule both marks read: the dim is the switch read OFF (no road ⇒
    /// never), the hover is today's saying with the one sentence APPENDED
    /// (never reordered — F-900-B), the ink is `faint` (F-900-A) — and undimmed
    /// every one of them is today's, byte for byte (pin (c)'s pure half).
    @Test func theServerOffFaceIsOneRuleForBothMarks() {
        #expect(MCPServerOffFace.dimmed(serverOn: false))
        #expect(!MCPServerOffFace.dimmed(serverOn: true))
        #expect(!MCPServerOffFace.dimmed(serverOn: nil), "no road (a harness mount): today's face")
        #expect(MCPServerOffFace.sentence == offSentence, "F-900-B, ruled")
        // VX-272's settings-class rule: no "AI" in a mark's words.
        #expect(!offSentence.split(whereSeparator: { !$0.isLetter }).contains("AI"))

        let sayings = [
            MCPShareCopy.iconHelp([wingReach()]),
            PrivateMarkFace.help(.ownNote(alsoVia: [])),
            PrivateMarkFace.help(.ownNote(alsoVia: [vault])),
            PrivateMarkFace.help(.viaBooks([vault])),
            PrivateMarkFace.help(.ownBook),
        ]
        for saying in sayings {
            #expect(MCPServerOffFace.help(saying, dimmed: false) == saying, "server on: today's hover, byte for byte")
            #expect(!saying.hasSuffix("."), "today's sayings end without a stop (the join's shape): \(saying)")
            #expect(MCPServerOffFace.help(saying, dimmed: true) == saying + ". " + offSentence,
                    "server off: the fact appended, the saying untouched")
        }
        // Her words, as they read at the hover.
        #expect(MCPServerOffFace.help(MCPShareCopy.iconHelp([wingReach()]), dimmed: true)
                == "Shared with claude-code (read) \u{2014} click for details. The MCP server is off.")
        #expect(MCPServerOffFace.help(PrivateMarkFace.help(.viaBooks([vault])), dimmed: true)
                == "Private \u{2014} via \u{201C}the vault\u{201D}. The MCP server is off.")

        // F-900-A: the one disabled ink, in every voice and appearance — and
        // the mark's own token otherwise.
        for tokens in [VoiceTokens.studyLight, .studyDark, .terminalLight, .terminalDark] {
            #expect(MCPServerOffFace.ink(tokens.accent, tokens, dimmed: false) == tokens.accent, "the icon's own ink")
            #expect(MCPServerOffFace.ink(tokens.ink, tokens, dimmed: false) == tokens.ink, "the eye's own ink")
            #expect(MCPServerOffFace.ink(tokens.accent, tokens, dimmed: true) == tokens.faint)
            #expect(MCPServerOffFace.ink(tokens.ink, tokens, dimmed: true) == tokens.faint)
            #expect(tokens.faint != tokens.accent && tokens.faint != tokens.ink,
                    "the dim is visible: faint is neither mark's own ink (non-vacuity)")
        }
    }

    /// The road carries the switch itself; VX-164's `indicatorOn` survives
    /// derived (the masthead's pending-ask leg — an ask lives only while
    /// connected); a flip of the switch is a change of the road, so every face
    /// reading it re-renders.
    @Test func theRoadCarriesTheSwitchAndTheAskLegKeepsItsGate() {
        #expect(road(serverOn: true).indicatorOn)
        #expect(!road(serverOn: false).indicatorOn)
        #expect(!road(serverOn: true, canShare: false).indicatorOn)
        #expect(road(serverOn: true) == road(serverOn: true))
        #expect(road(serverOn: true) != road(serverOn: false), "a flip of the switch re-renders the faces")
        #expect(road(serverOn: true, canShare: true) != road(serverOn: true, canShare: false))
        // VX-934 (A JUSTIFIED EDIT — the road gained the AI pair's switch): a
        // flip of HER switch is a change of the road too, and it never moves
        // the ask leg's gate (the pending glyph is no part of the pair).
        #expect(road(serverOn: true, aiMarksOn: false) != road(serverOn: true), "her AI switch re-renders the faces")
        #expect(road(serverOn: true, aiMarksOn: false).indicatorOn, "the ask leg ignores the AI switch")
    }

    /// Every host draws both marks through the two faces, so the one rule
    /// reaches them all: the closed eye is drawn only by `PrivateMarkView`,
    /// and the shared glyph outside `MCPSharedIcon` only as the ⌘L ▾ menu's
    /// item image (system ink, no hover — the recorded residual) and the
    /// trail row's details door (a session row, not a reach mark).
    @Test func everyHostDrawsTheMarksThroughTheTwoFacesSoTheOneRuleReachesThemAll() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Variorum")
        let files = try #require(FileManager.default.enumerator(at: app, includingPropertiesForKeys: nil))
            .compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        var eye: [String] = []
        var glyph: [String] = []
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            if text.contains("ClosedEyeGlyph()") { eye.append(file.lastPathComponent) }
            if text.contains("MCPSharedIcon.symbol") { glyph.append(file.lastPathComponent) }
        }
        #expect(!files.isEmpty, "the app's sources were read (non-vacuity)")
        #expect(eye == ["PrivateMarkView.swift"], "the eye is drawn only by its face (\(eye))")
        #expect(Set(glyph) == ["WingSwitcherMenu.swift", "MCPTrailSection.swift"],
                "the shared glyph outside its face: the ▾ menu's image and the trail's door only (\(glyph))")
        // …and both faces read the ONE rule off the road.
        func source(_ path: String) throws -> String {
            try String(contentsOf: app.appendingPathComponent(path), encoding: .utf8)
        }
        for face in ["Core/Views/MCPSharedIcon.swift", "Core/Views/PrivateMarkView.swift"] {
            let text = try source(face)
            #expect(text.contains("MCPServerOffFace.dimmed(serverOn: road?.serverOn)"), "\(face) reads the switch")
            #expect(text.contains("MCPServerOffFace.help("), "\(face) speaks the one hover")
            #expect(text.contains("MCPServerOffFace.ink("), "\(face) wears the one ink")
            // VX-934 (A JUSTIFIED EDIT): and both faces draw only under her AI
            // pair's switch, read off the same road through the ONE rule.
            #expect(text.contains("MCPAIMarksSwitch.drawn(aiMarksOn: road?.aiMarksOn)"),
                    "\(face) draws only while her AI-pair switch is on")
        }
        // VX-934: the ⌘L ▾ menu's image of the shared icon follows that rule too.
        #expect(try source("Core/Views/WingSwitcherMenu.swift")
            .contains("shared: MCPAIMarksSwitch.drawn(aiMarksOn: road?.aiMarksOn)"))
        // The masthead: the shared icon's gate is the rows' (a client
        // approved), no longer the server-and-client `indicatorOn`; its reach
        // rides the rows' gated batched read.
        let indicator = try source("Core/Views/MCPNoteIndicator.swift")
        #expect(indicator.contains("private var drawsReach: Bool { road?.canShare == true }"))
        #expect(indicator.contains("if drawsReach, let state, !state.reach.isEmpty {"))
        #expect(!indicator.contains("if indicatorOn, let state"), "the masthead's icon no longer waits for the server")
        #expect(indicator.contains("Queries.mcpNoteReaches(db, noteIDs: [postID])"))
        #expect(!indicator.contains("Queries.mcpNoteReach(db"), "no ungated singular reach read at the masthead")
    }

    // MARK: - (a) and (c) — the two faces, mounted

    /// The four marks a row can wear, under one road.
    private func faces(_ session: AppSession, road: MCPShareRoad?) -> some View {
        let tokens = VoiceTokens.studyLight
        return VStack(alignment: .leading, spacing: 8) {
            MCPSharedIcon(reaches: [wingReach()], tokens: tokens)
            PrivateMarkView(
                door: PrivateMarkDoor(mark: .ownNote(alsoVia: []), subjectID: "vx900-n-own", session: session),
                tokens: tokens)
            PrivateMarkView(
                door: PrivateMarkDoor(mark: .viaBooks([vault]), subjectID: "vx900-n-via", session: session),
                tokens: tokens)
            PrivateMarkView(
                door: PrivateMarkDoor(
                    mark: .ownBook, subjectID: "vx900-b-own", subjectName: "the vault", session: session),
                tokens: tokens)
        }
        .padding(12)
        .environment(\.mcpShareRoad, road)
    }

    private static let eyeIDs = ["vx900-n-own", "vx900-n-via", "vx900-b-own"]

    private func drawnEyes() -> [String: PrivateMarkProbe.Face] {
        PrivateMarkProbe.faces.filter { Self.eyeIDs.contains($0.key) }
    }

    /// **(a)** — a client approved, the server's switch OFF: the shared icon and
    /// all three eyes are DRAWN (nothing hidden), each in the dimmed face, each
    /// hover saying the server is off; the via-book eye is the same mark at the
    /// same dim as an own one (its "full strength" relation, kept).
    @Test func whileTheServerIsOffBothMarksDrawDimmedAndTheirHoversSaySo() async throws {
        try await withTwinsWorld { session, _ in
            #if DEBUG
            for id in Self.eyeIDs { PrivateMarkProbe.faces[id] = nil }
            let rig = SharedIconRig(faces(session, road: road(serverOn: false)), width: 420, height: 200)
            defer { rig.close() }
            let drawn = await rig.poll(timeout: 6) {
                MCPSharedIconProbe.faces(in: rig.window).count == 1 && drawnEyes().count == 3
            }
            #expect(drawn, "the icon and the three eyes drew (icons \(MCPSharedIconProbe.faces(in: rig.window).count), eyes \(drawnEyes().count))")
            let icon = try #require(MCPSharedIconProbe.faces(in: rig.window).first)
            #expect(icon == .init(
                dimmed: true, help: "Shared with claude-code (read) \u{2014} click for details. The MCP server is off."))
            #expect(drawnEyes()["vx900-n-own"] == .init(
                dimmed: true, help: PrivateMarkCopy.markOwnNoteHelp + ". " + offSentence))
            #expect(drawnEyes()["vx900-n-via"] == .init(
                dimmed: true, help: "Private \u{2014} via \u{201C}the vault\u{201D}. The MCP server is off."))
            #expect(drawnEyes()["vx900-b-own"] == .init(
                dimmed: true, help: PrivateMarkCopy.markOwnBookHelp + ". " + offSentence))
            #expect(PrivateMarkProbe.drawn["vx900-n-via"] == .viaBooks([vault]),
                    "the via-book mark stays its own mark — dimmed exactly as an own one, never a muted twin")
            #endif
        }
    }

    /// **(c)** — the switch ON, and a host no window built a road for: today's
    /// face byte for byte — undimmed, the hovers exactly today's strings.
    @Test func whileTheServerIsOnOrWithNoRoadBothMarksWearTodaysFace() async throws {
        try await withTwinsWorld { session, _ in
            #if DEBUG
            let roads: [(String, MCPShareRoad?)] = [("server on", road(serverOn: true)), ("no road", nil)]
            for (label, theRoad) in roads {
                for id in Self.eyeIDs { PrivateMarkProbe.faces[id] = nil }
                let rig = SharedIconRig(faces(session, road: theRoad), width: 420, height: 200)
                let drawn = await rig.poll(timeout: 6) {
                    MCPSharedIconProbe.faces(in: rig.window).count == 1 && drawnEyes().count == 3
                }
                #expect(drawn, "\(label): the icon and the three eyes drew")
                #expect(MCPSharedIconProbe.faces(in: rig.window)
                        == [.init(dimmed: false, help: MCPShareCopy.iconHelp([wingReach()]))],
                        "\(label): the icon's face and hover are today's")
                #expect(MCPShareCopy.iconHelp([wingReach()])
                        == "Shared with claude-code (read) \u{2014} click for details", "today's hover, spelled")
                #expect(drawnEyes()["vx900-n-own"] == .init(dimmed: false, help: PrivateMarkCopy.markOwnNoteHelp))
                #expect(drawnEyes()["vx900-n-via"] == .init(
                    dimmed: false, help: "Private \u{2014} via \u{201C}the vault\u{201D}"))
                #expect(drawnEyes()["vx900-b-own"] == .init(dimmed: false, help: PrivateMarkCopy.markOwnBookHelp))
                rig.close()
            }
            #endif
        }
    }

    // MARK: - (a) and (c) at the note's masthead, over a store

    /// **(a) + (c) at the masthead** — her #264 nuance: with a client approved
    /// and the switch OFF the bar showed the eye and NOT the shared icon (the
    /// one waiter). Now both draw, dimmed, the hovers saying so; with the
    /// switch ON both wear today's face. RED ON OLD (by construction — the old
    /// masthead's `if indicatorOn, …` drew no icon while the switch was off, so
    /// the first poll finds none).
    @Test func theMastheadDrawsTheSharedIconWhileAClientIsApprovedDimmedWhileTheServerIsOff() async throws {
        try await withTwinsWorld { session, _ in
            #if DEBUG
            let ops = session.operations
            let open = try ops.createPost(title: "an open page")
            _ = try ops.newBlock(in: open.id, text: "an open page text", registeringUndo: false)
            let secret = try ops.createPost(title: "a secret")
            _ = try ops.newBlock(in: secret.id, text: "a secret text", registeringUndo: false)
            try ops.setNotePrivate(secret.id, true)
            let client = try ops.recordMCPContact(name: "claude-code", version: "2")
            try ops.approveMCPClient(client.id, granting: nil)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            let shared = "Shared with claude-code (read) \u{2014} click for details"
            for (on, label) in [(false, "server OFF"), (true, "server ON")] {
                PrivateMarkProbe.faces[secret.id] = nil
                let tokens = VoiceTokens.studyLight
                let rig = SharedIconRig(
                    VStack(alignment: .trailing, spacing: 8) {
                        MCPNoteIndicator(session: session, postID: open.id, tokens: tokens)
                        MCPNoteIndicator(session: session, postID: secret.id, tokens: tokens)
                    }
                    .padding(12)
                    .environment(\.mcpShareRoad, road(serverOn: on)),
                    width: 320, height: 120)
                let drawn = await rig.poll(timeout: 8) {
                    MCPSharedIconProbe.faces(in: rig.window).count == 1 && PrivateMarkProbe.faces[secret.id] != nil
                }
                #expect(drawn, "\(label): the open note's masthead wears the shared icon and the Private one the eye (icons \(MCPSharedIconProbe.faces(in: rig.window).count))")
                #expect(MCPSharedIconProbe.faces(in: rig.window)
                        == [.init(dimmed: !on, help: on ? shared : shared + ". " + offSentence)],
                        "\(label): one icon — the open note's (the wing grant never reaches a Private note)")
                #expect(PrivateMarkProbe.faces[secret.id] == .init(
                    dimmed: !on,
                    help: on ? PrivateMarkCopy.markOwnNoteHelp : PrivateMarkCopy.markOwnNoteHelp + ". " + offSentence))
                rig.close()
            }
            #endif
        }
    }

    // MARK: - (b) — no approved client: neither drawn, nothing read

    /// **(b)** — no client approved (a pending one, a denied one holding an
    /// always wing grant, the open book ON): the masthead's composed read —
    /// even ASKED for reach, as a lagging window gate would ask — answers
    /// nothing and reads nothing but the client list, under BOTH switch
    /// states; mounted, neither mark draws, whatever the window's gates say.
    /// RED ON OLD for the asked-for-reach arm: the old singular `mcpNoteReach`
    /// read the note's facts (`container`) before it found nobody approved.
    @Test func withNoApprovedClientTheMastheadDrawsNeitherMarkAndReadsNothingPastTheClientList() async throws {
        try await withTwinsWorld { session, db in
            #if DEBUG
            let ops = session.operations
            let open = try ops.createPost(title: "an open page")
            _ = try ops.newBlock(in: open.id, text: "an open page text", registeringUndo: false)
            let secret = try ops.createPost(title: "a secret")
            try ops.setNotePrivate(secret.id, true)
            _ = try ops.recordMCPContact(name: "asking", version: nil)
            let denied = try ops.recordMCPContact(name: "denied", version: "1")
            try ops.approveMCPClient(denied.id, granting: nil)
            _ = try ops.grantMCPAccess(denied.id, .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always))
            try ops.denyMCPClient(denied.id)
            try ops.setMCPSwitch(.openBook, on: true)

            for on in [false, true] {
                try ops.setMCPSwitch(.server, on: on)
                let label = on ? "server ON" : "server OFF"
                for postID in [open.id, secret.id] {
                    let (state, sqls) = try await db.read { db -> (MCPNoteIndicatorState, [String]) in
                        var sqls: [String] = []
                        db.trace { sqls.append($0.description) }
                        defer { db.trace(options: [], nil) }
                        return (try MCPNoteIndicatorState.read(db, postID: postID, includingReach: true), sqls)
                    }
                    #expect(state.isEmpty && state.mark == nil && state.reach.isEmpty,
                            "\(label): no approved client — nothing to draw")
                    #expect(!sqls.isEmpty, "\(label): the gates ran (non-vacuity)")
                    for table in ["container", "reading", "mcp_grant"] {
                        #expect(!sqls.contains { $0.contains(table) },
                                "\(label): nothing past the client list — no `\(table)` (\(sqls))")
                    }
                }
                // Mounted, under every gate a window could hand it (a lagging
                // `canShare` included): neither mark draws.
                for gate in [false, true] {
                    PrivateMarkProbe.faces[secret.id] = nil
                    let tokens = VoiceTokens.studyLight
                    let rig = SharedIconRig(
                        VStack(alignment: .trailing, spacing: 8) {
                            MCPNoteIndicator(session: session, postID: open.id, tokens: tokens)
                            MCPNoteIndicator(session: session, postID: secret.id, tokens: tokens)
                        }
                        .padding(12)
                        .environment(\.mcpShareRoad, road(serverOn: on, canShare: gate)),
                        width: 320, height: 120)
                    await rig.poll(timeout: 1.2) { false }
                    #expect(MCPSharedIconProbe.faces(in: rig.window).isEmpty,
                            "\(label), canShare \(gate): no shared icon")
                    #expect(PrivateMarkProbe.faces[secret.id] == nil, "\(label), canShare \(gate): no eye")
                    rig.close()
                }
            }

            // The control (non-vacuity — the same rig CAN draw): a client
            // approved under the switch OFF, and both marks arrive, dimmed
            // (the open book reaches the unfenced note; the eye is the
            // Private note's).
            PrivateMarkProbe.faces[secret.id] = nil
            let tokens = VoiceTokens.studyLight
            let rig = SharedIconRig(
                VStack(alignment: .trailing, spacing: 8) {
                    MCPNoteIndicator(session: session, postID: open.id, tokens: tokens)
                    MCPNoteIndicator(session: session, postID: secret.id, tokens: tokens)
                }
                .padding(12)
                .environment(\.mcpShareRoad, road(serverOn: false, canShare: true)),
                width: 320, height: 120)
            defer { rig.close() }
            let approved = try ops.recordMCPContact(name: "claude-code", version: "2")
            try ops.approveMCPClient(approved.id, granting: nil)
            let arrived = await rig.poll(timeout: 8) {
                MCPSharedIconProbe.faces(in: rig.window).count == 1 && PrivateMarkProbe.faces[secret.id] != nil
            }
            #expect(arrived, "control: an approval brings both marks into the same rig")
            #expect(MCPSharedIconProbe.faces(in: rig.window).first?.dimmed == true)
            #expect(PrivateMarkProbe.faces[secret.id]?.dimmed == true)
            #endif
        }
    }
}
