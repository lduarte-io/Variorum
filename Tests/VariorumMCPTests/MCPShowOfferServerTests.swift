import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-676 + VX-675 (the VX-677 run, batch 3 — the record
// `notes/plans/fixes/vx-677-editor-panes-ai-door.md`, BATCH 3 RECORD): `show_in_app` LANDS
// AS AN OFFER, and it opens a SAVED VERSION.
//
// Her sitting (2026-10-28): (1) DEFAULT = ASK; (3) the dial is GLOBAL in Settings ▸ MCP —
// move at once · ask · never; (4) the wire answers AT ONCE, fire-and-forget, "offered — she
// can open it with one press"; no callback on a later take; Activity logs the ask and the
// take. Her mid-run amendment: the frontmost-only refusal RETIRES into the ask — a show
// arriving while Variorum is not in front (or without a full window) is never refused for
// that reason, and lands as the ask under every dial value but never (RATIFIED). VX-675:
// a version id opens the full-size version view; the decision is the NOTE's read decision,
// and any id that isn't one of the note's saved versions answers the ONE not-shared shape.
//
// Headless: the SDK's own client over a real socket, a fake app applying the RULE with the
// request's dial (the contract `MCPHostHooks.show` states). Every read is bound to a local
// before an assertion reads it (the record's F-B3-1: a testing macro around a closure in a
// nested closure makes a later same-typed closure run the first one's body).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// A fake app: stands where the test says, records every request it is handed, applies the
/// RULE with the request's dial, and records what it moved and what it offered.
private final class FakeApp: @unchecked Sendable {
    let standing = LockIsolated(MCPShowRule.Standing.frontmostMainWindow)
    let received = LockIsolated<[MCPShowRequest]>([])
    let delivered = LockIsolated<[MCPShowTarget]>([])
    let offered = LockIsolated<[MCPShowRequest]>([])

    var hook: @Sendable (MCPShowRequest) async -> MCPShowRule.Verdict {
        { [self] request in
            received.withValue { $0.append(request) }
            let verdict = MCPShowRule.verdict(standing.value, dial: request.dial)
            switch verdict {
            case .navigate: delivered.withValue { $0.append(request.target) }
            case .offer: offered.withValue { $0.append(request) }
            case .refuse: break
            }
            return verdict
        }
    }
}

/// The offered answer, exactly (sorted keys — the encoder's).
private let offeredAnswer = #"{"landed":"\#(MCPShowRule.offeredWords)","offered":true,"shown":false}"#

@Suite("VX-676 + VX-675 — show_in_app lands as an offer, and opens a saved version", .serialized)
struct MCPShowOfferServerTests {
    private func note(_ h: ServerHarness, _ title: String) throws -> (Container, String) {
        let note = try h.operations.createPost(title: title)
        let block = try h.operations.newBlock(in: note.id, text: "\(title).", registeringUndo: false)
        return (note, block.block.id)
    }

    private func activity(_ h: ServerHarness) async throws -> [MCPActivityRow] {
        try await h.database.read { try Queries.mcpActivity($0) }
    }

    // MARK: - The rule (pure)

    /// The whole table: move at once moves only in front in a full window; every other
    /// standing under move at once, and every standing under ask, is the ask; never refuses
    /// wherever she stands. **RED on `rev676`** (the old etiquette ignores the dial).
    @Test func theRuleIsTheWholeTable() {
        let standings: [MCPShowRule.Standing] = [.frontmostMainWindow, .frontmostOtherWindow, .notFrontmost]
        for standing in standings {
            #expect(MCPShowRule.verdict(standing, dial: .ask) == .offer, "ask offers \(standing)")
            #expect(MCPShowRule.verdict(standing, dial: .never) == .refuse(MCPShowRule.neverWords), "never \(standing)")
            #expect(MCPShowRule.verdict(standing, dial: .moveAtOnce)
                    == (standing == .frontmostMainWindow ? .navigate : .offer),
                    "move at once \(standing): only in front, else the ask (her ratified background rule)")
        }
        #expect(MCPShowDial.default == .ask, "her default")
    }

    // MARK: - The dial on the wire

    /// Her DEFAULT (no dial set): in front, in another window, away — each call is OFFERED,
    /// answered at once in the offered shape, nothing moved; each logged as its own ask row
    /// (allowed, titled); a once grant never spent. **RED on `rev676`.**
    @Test func herDefaultIsTheAskInFrontAndAwayAndNothingMoves() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let (shared, _) = try note(h, "shared once")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, shared.id, .once))

            for standing in [MCPShowRule.Standing.frontmostMainWindow, .frontmostOtherWindow, .notFrontmost] {
                app.standing.setValue(standing)
                let result = try await call(connection, "show_in_app", ["note_id": .string(shared.id)])
                #expect(result.isError != true, "\(standing): \(text(result))")
                #expect(text(result) == offeredAnswer, "\(standing): the offered shape, at once")
            }
            #expect(app.delivered.value.isEmpty, "nothing moved — not even in front")
            let offeredDials = app.offered.value.map(\.dial)
            #expect(offeredDials == [.ask, .ask, .ask])
            let rows = try await activity(h)
            let shows = rows.filter { $0.targetID == shared.id }
            let showActs = shows.map(\.act), showAllowed = shows.map(\.allowed)
            let showTitles = shows.map(\.targetTitle), showKinds = shows.map(\.targetKind)
            #expect(showActs == Array(repeating: MCPShowActivity.offeredAct, count: 3) && showAllowed == [true, true, true],
                    "each ask is its own allowed row: \(showActs)")
            #expect(showTitles == ["shared once", "shared once", "shared once"] && showKinds == ["note", "note", "note"])
            let read = try await call(connection, "read_note", ["note_id": .string(shared.id)])
            #expect(read.isError != true, "an offered show never spent the ONCE grant")
            await h.hangUp(connection)
        }
    }

    /// MOVE AT ONCE: in front in a full window it moves and answers `{"shown":true}` byte for
    /// byte (the move's answer unchanged); in another window or away it is the ask — never
    /// refused for where she stands (the amendment's letter), never moved. Activity: the
    /// move keeps show_in_app's own row, each ask its own. **RED on `rev676`** (away refused).
    @Test func moveAtOnceMovesInFrontOnlyAndEveryArrivalAwayIsTheAsk() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            try h.operations.setMCPShowDial(.moveAtOnce)
            let (shared, block) = try note(h, "chapter one")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, shared.id))

            let moved = try await call(connection, "show_in_app", [
                "note_id": .string(shared.id), "block_id": .string(block),
            ])
            #expect(moved.isError != true && text(moved) == #"{"shown":true}"#, "\(text(moved))")
            #expect(app.delivered.value == [.note(noteID: shared.id, blockID: block, select: nil)])
            for standing in [MCPShowRule.Standing.frontmostOtherWindow, .notFrontmost] {
                app.standing.setValue(standing)
                let asked = try await call(connection, "show_in_app", ["note_id": .string(shared.id)])
                #expect(asked.isError != true && text(asked) == offeredAnswer,
                        "\(standing) under move at once: the ask, never a refusal — \(text(asked))")
            }
            #expect(app.delivered.value.count == 1, "nothing moved while she was elsewhere")
            let movedDials = app.offered.value.map(\.dial)
            #expect(movedDials == [.moveAtOnce, .moveAtOnce])
            let rows = try await activity(h)
            let mine = rows.filter { $0.targetID == shared.id }
            let acts = mine.map(\.act), allowed = mine.map(\.allowed)
            #expect(acts == [MCPShowActivity.offeredAct, MCPShowActivity.offeredAct, "show_in_app"],
                    "newest first: two asks, then the move's own row — \(acts)")
            #expect(allowed == [true, true, true])
            await h.hangUp(connection)
        }
    }

    /// NEVER: wherever she stands, nothing is shown or offered — the call answers the never
    /// sentence (PROVISIONAL P-676-2) and is logged refused. **RED on `rev676`** (in front, it
    /// moved).
    @Test func neverShowsAndOffersNothingWhereverSheStands() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            try h.operations.setMCPShowDial(.never)
            let (shared, _) = try note(h, "kept to herself")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, shared.id))
            for standing in [MCPShowRule.Standing.frontmostMainWindow, .frontmostOtherWindow, .notFrontmost] {
                app.standing.setValue(standing)
                let refused = try await call(connection, "show_in_app", ["note_id": .string(shared.id)])
                #expect(refused.isError == true && text(refused) == MCPShowRule.neverWords, "\(standing): \(text(refused))")
            }
            #expect(app.delivered.value.isEmpty && app.offered.value.isEmpty, "nothing shown, nothing offered")
            let rows = try await activity(h)
            let shows = rows.filter { $0.targetID == shared.id }
            let neverActs = shows.map(\.act), neverAllowed = shows.map(\.allowed)
            #expect(neverActs == ["show_in_app", "show_in_app", "show_in_app"] && neverAllowed == [false, false, false])
            await h.hangUp(connection)
        }
    }

    /// EVERY target rides the ONE offer machinery: the request names who asked, what (the
    /// title the decision read; compare's peers' titles in column order; a version's note),
    /// where Activity logged it, and the dial — for note, takes, lens, book, wing, compare and
    /// version alike. A GUARD for the request's content (the fake records every request,
    /// whatever the rule then says) — green on `rev676`; its version line RED on `rev675`.
    @Test func everyTargetIsHandedAsOneRequestNamingWhoWhatAndTheDial() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let wing = try h.operations.createWing(name: "studio")
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let (anchor, block) = try note(h, "anchor")
            _ = try h.operations.addPostToReading(anchor.id, to: book.id)
            let (peer, _) = try note(h, "peer")
            _ = try h.operations.addPostToReading(peer.id, to: book.id)
            let lens = try h.operations.createLens(post: anchor.id, name: "alt")
            let version = try h.operations.saveNoteVersion(anchor.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .wing, wing.id))

            let calls: [([String: Value], MCPShowTarget, String?, String, String, [String?])] = [
                (["note_id": .string(anchor.id)], .note(noteID: anchor.id, blockID: nil, select: nil),
                 "anchor", "note", anchor.id, []),
                (["target": .string("takes"), "note_id": .string(anchor.id), "block_id": .string(block)],
                 .takes(noteID: anchor.id, blockID: block), "anchor", "note", anchor.id, []),
                (["target": .string("lens"), "note_id": .string(anchor.id), "lens_id": .string(lens.id)],
                 .lens(noteID: anchor.id, lensID: lens.id), "anchor", "note", anchor.id, []),
                (["target": .string("book"), "book_id": .string(book.id)], .book(bookID: book.id, sectionID: nil),
                 "lessons", "book", book.id, []),
                (["target": .string("wing"), "wing_id": .string(wing.id)],
                 .wing(wingID: wing.id, name: "studio", shownBy: "claude-code"), "studio", "wing", wing.id, []),
                (["target": .string("compare"), "note_id": .string(anchor.id), "peer_ids": .array([.string(peer.id)])],
                 .compare(noteID: anchor.id, peerIDs: [peer.id]), "anchor", "note", anchor.id, ["peer"]),
                (["target": .string("version"), "note_id": .string(anchor.id), "version_id": .string(version.post.id)],
                 .version(noteID: anchor.id, versionID: version.post.id), "anchor", "note", anchor.id, []),
            ]
            for (arguments, target, title, kind, id, peers) in calls {
                let before = app.received.value.count
                let result = try await call(connection, "show_in_app", arguments)
                #expect(result.isError != true, "\(arguments): \(text(result))")
                let request = app.received.value.count == before + 1 ? app.received.value.last : nil
                #expect(request == MCPShowRequest(
                    target: target, clientName: "claude-code", title: title, peerTitles: peers, dial: .ask,
                    activityKind: kind, activityID: id), "\(target)")
            }
            await h.hangUp(connection)
        }
    }

    /// The decision comes FIRST: an unreadable target answers the ONE not-shared shape under
    /// every dial — never the never sentence, never offered — and nothing is handed to the app.
    /// A GUARD (green on both reverts).
    @Test func anUnreadableTargetAnswersTheOneNotSharedShapeUnderEveryDial() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let (shared, _) = try note(h, "shared")
            let (hidden, _) = try note(h, "hidden")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, shared.id))
            let notShared = MCPRefusalCopy.words(.notShared, .note)
            for dial in MCPShowDial.allCases {
                try h.operations.setMCPShowDial(dial)
                let refused = try await call(connection, "show_in_app", ["note_id": .string(hidden.id)])
                #expect(refused.isError == true && text(refused) == notShared, "\(dial): \(text(refused))")
            }
            #expect(app.received.value.isEmpty, "nothing reached the app")
            await h.hangUp(connection)
        }
    }

    /// `list_my_activity` (with the reads) answers the ask as the tool it was — show_in_app,
    /// allowed, `offered: true` — and NEVER her take (fire-and-forget: polling must not tell
    /// the client she opened it); without include_reads, neither. **RED on `rev676`** (no ask
    /// row exists there: the call moved).
    @Test func listMyActivitySaysTheAskAsAnOfferedShowAndNeverHerTake() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let (shared, _) = try note(h, "shared")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, shared.id))
            let asked = try await call(connection, "show_in_app", ["note_id": .string(shared.id)])
            #expect(asked.isError != true)
            try h.operations.recordMCPShowTaken(
                clientName: "claude-code", targetKind: "note", targetID: shared.id, targetTitle: "shared")

            let listed = try json(try await call(connection, "list_my_activity", ["include_reads": .bool(true)]))
            let acts = listed["acts"] as? [[String: Any]] ?? []
            let shows = acts.filter { ($0["tool"] as? String) == "show_in_app" }
            let ask = shows.first
            let askOffered = ask?["offered"] as? Bool, askOutcome = ask?["outcome"] as? String
            let askTarget = ask?["target_id"] as? String, askTitle = ask?["title"] as? String
            #expect(shows.count == 1, "the one ask: \(acts)")
            #expect(askOffered == true && askOutcome == "allowed")
            #expect(askTarget == shared.id && askTitle == "shared")
            let tools = acts.compactMap { $0["tool"] as? String }
            #expect(!tools.contains(MCPShowActivity.takenAct), "her take is never listed: \(tools)")
            #expect(!tools.contains(MCPShowActivity.offeredAct), "no raw act on the wire")
            let plain = try json(try await call(connection, "list_my_activity", [:]))
            let plainActs = plain["acts"] as? [[String: Any]] ?? []
            let plainTools = plainActs.compactMap { $0["tool"] as? String }
            #expect(!plainTools.contains("show_in_app"), "a show is a read")
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-675: a saved version

    /// A version id opens on the NOTE's read decision, never spending: under move at once it
    /// moves (the version target delivered); under the ask it is offered with the version as
    /// its target. **RED on `rev675`** (the old deliberate refusal: the one not-shared shape).
    @Test func aSavedVersionShowsOnTheNotesReadDecisionNeverSpendingItsOnceGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            try h.operations.setMCPShowDial(.moveAtOnce)
            let (doc, _) = try note(h, "draft")
            let version = try h.operations.saveNoteVersion(doc.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, doc.id, .once))
            let target = MCPShowTarget.version(noteID: doc.id, versionID: version.post.id)
            let arguments: [String: Value] = [
                "target": .string("version"), "note_id": .string(doc.id), "version_id": .string(version.post.id),
            ]

            let shown = try await call(connection, "show_in_app", arguments)
            #expect(shown.isError != true && text(shown) == #"{"shown":true}"#, "\(text(shown))")
            #expect(app.delivered.value == [target], "the saved version, full size")
            app.standing.setValue(.notFrontmost)
            let asked = try await call(connection, "show_in_app", arguments)
            #expect(asked.isError != true && text(asked) == offeredAnswer, "\(text(asked))")
            #expect(app.offered.value.map(\.target) == [target])
            let rows = try await activity(h)
            let newest = Array(rows.prefix(2))
            #expect(newest.map(\.targetID) == [doc.id, doc.id] && newest.map(\.allowed) == [true, true]
                    && newest.map(\.targetTitle) == ["draft", "draft"], "logged on the NOTE — the disclosure unit")
            let read = try await call(connection, "read_note", ["note_id": .string(doc.id)])
            #expect(read.isError != true, "showing a version never spent the note's ONCE grant")
            await h.hangUp(connection)
        }
    }

    /// Hidden = missing: every id that is not one of THIS note's saved versions — nothing, the
    /// note's own id, a live note, another note's version, a promoted version — answers the ONE
    /// not-shared shape BYTE-IDENTICAL to an unreadable note's (and a hidden note's real
    /// version answers it too, by the note's decision); nothing reaches the app. A GUARD (the
    /// shape is the same on `rev675`, which refused every version — the retirement is the pin
    /// above).
    @Test func everyIDThatIsntOneOfTheNotesSavedVersionsAnswersTheOneNotSharedShape() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            try h.operations.setMCPShowDial(.moveAtOnce)
            let (doc, _) = try note(h, "draft")
            let (other, _) = try note(h, "other")
            let (hidden, _) = try note(h, "hidden")
            let otherVersion = try h.operations.saveNoteVersion(other.id)
            let hiddenVersion = try h.operations.saveNoteVersion(hidden.id)
            let promoted = try h.operations.saveNoteVersion(doc.id)
            try h.operations.promoteNoteVersion(promoted.post.id, of: doc.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, doc.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, other.id))

            let unreadable = try await call(connection, "show_in_app", ["note_id": .string(hidden.id)])
            let shape = text(unreadable)
            #expect(unreadable.isError == true && shape == MCPRefusalCopy.words(.notShared, .note))
            for (noteID, versionID) in [
                (doc.id, "no-such-version"), (doc.id, doc.id), (doc.id, other.id), (doc.id, otherVersion.post.id),
                (doc.id, promoted.post.id), (hidden.id, hiddenVersion.post.id),
            ] {
                let refused = try await call(connection, "show_in_app", [
                    "target": .string("version"), "note_id": .string(noteID), "version_id": .string(versionID),
                ])
                #expect(refused.isError == true && text(refused) == shape, "\(versionID): \(text(refused))")
            }
            #expect(app.received.value.isEmpty, "nothing reached the app")
            await h.hangUp(connection)
        }
    }

    /// The version target's parse (before any read — no oracle) and VX-606: `version_id` joins
    /// the published schema and goes only with target "version"; an undeclared argument still
    /// refuses in words. A GUARD.
    @Test func theVersionArgumentIsDeclaredAndGoesOnlyWithItsTarget() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let (doc, _) = try note(h, "draft")
            let version = try h.operations.saveNoteVersion(doc.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, doc.id))

            let schema = MCPToolCatalog.showInApp.inputSchema.objectValue?["properties"]?.objectValue ?? [:]
            #expect(schema["version_id"] != nil, "declared")
            let targets = schema["target"]?.objectValue?["enum"]?.arrayValue?.compactMap(\.stringValue) ?? []
            #expect(targets.last == "version")
            for arguments: [String: Value] in [
                ["note_id": .string(doc.id), "version_id": .string(version.post.id)],
                ["target": .string("compare"), "note_id": .string(doc.id), "version_id": .string(version.post.id)],
            ] {
                let refused = try await call(connection, "show_in_app", arguments)
                #expect(refused.isError == true && text(refused) == MCPShowTool.versionNeedsItsTargetWords)
            }
            let missing = try await call(connection, "show_in_app", [
                "target": .string("version"), "note_id": .string(doc.id),
            ])
            #expect(missing.isError == true && text(missing) == MCPShowTool.versionNeedsWords)
            let undeclared = try await call(connection, "show_in_app", [
                "target": .string("version"), "note_id": .string(doc.id), "version_id": .string(version.post.id),
                "moment_id": .string(version.post.id),
            ])
            #expect(undeclared.isError == true
                    && text(undeclared) == MCPArgumentSchema.words(tool: "show_in_app", undeclared: ["moment_id"]))
            #expect(app.received.value.isEmpty, "nothing reached the app")
            await h.hangUp(connection)
        }
    }

    // MARK: - The model's docs say the new truth

    /// The tool description and the instructions say the offer (the default ask, the dial's
    /// other two values, the at-once answer with nothing following) and the version target;
    /// the instructions stay inside her bound. **RED on old** by absence (the words are new).
    @Test func theDescriptionAndTheInstructionsSayTheOffer() {
        let description = MCPToolCatalog.showInApp.description
        #expect(description.contains("By default it is OFFERED"))
        #expect(description.contains("move their view at once instead (only while Variorum is the app in front; "
                                     + "otherwise it is offered) or never to show"))
        #expect(description.contains(#"{"shown": true} if it moved, {"offered": true} if it was offered"#))
        #expect(description.contains("nothing follows when they open it"))
        #expect(description.contains(#""version" (note_id + version_id"#))
        #expect(!description.contains("it moves nothing unless Variorum is the app in front"), "the retired line")
        let advice = MCPSession.instructions
        #expect(advice.contains("Never call show_in_app unless the author asks to see something; by default it's "
                                + "offered for one press, not moved."))
        #expect(advice.count <= MCPSession.instructionsBound,
                "the instructions are \(advice.count) characters (bound \(MCPSession.instructionsBound))")
    }
}
