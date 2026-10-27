//
//  TutorialMCPChapterTests.swift
//  VariorumTests
//
//  13n-c U5 — THE MCP CHAPTER IS EXECUTABLE SPEC (P-6; her kickoff: "notes /
//  documentation for the user need to be made clear (especially since that's
//  what a user's AI might need as advice too)"; D-2 — the guide chapter and the
//  server's advice, one set of facts). The books chapter's form
//  (`TutorialBooksChapterTests`), three halves per lesson:
//    · THE PROSE — the seeded lesson says the sentence;
//    · THE DOORS — every door it names is tied to that door's OWN constant
//      (the H pattern: the prose is written plainly, never interpolated from
//      what it asserts, so a renamed door turns the lesson RED);
//    · THE TRUTH — the sentence is EXECUTED headless against the store and
//      the one grant rule (`MCPGrantRule`, through `Queries.mcpNoteSharing` /
//      `mcpNoteFacts` — the faces' own reads, never a parallel fence).
//  The wire's half of the same facts is `MCPAdviceServerTests` (headless) and
//  U1's `MCPFenceRekeyServerTests` (the one answer, byte for byte).
//
//  VX-197 (RUN VX-336, U8b — the record `notes/plans/fixes/vx-336-mcp-wire-
//  tools-ai-docs.md`, U8b UNIT RECORD): the chapter's truth pass over the
//  as-built door — every tool VX-184, VX-246 and VX-336 added, taught in its
//  lesson; organization as recipes; Private, Seal and Own as hers alone; the
//  label rule; the shared icon's rows; lesson 2 re-voiced for VX-258's tab
//  rule; 13s's voice (R-13s-22: no em dash outside a quoted surface). Written
//  AHEAD of the chapter (red on the old seed). Where a claim's truth lives
//  inside the wire (a tool's rung, a description, `aiLabel`, the
//  instructions), the pin reads the catalog itself — `@testable import
//  VariorumMCP`, the W-UX-14 tie made direct — and the behaviour behind it is
//  the headless suite each pin names.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMCP
@testable import Variorum

// MARK: - The world

/// A store with the field guide seeded (the restore road), plus a session.
@MainActor
private func withGuideWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, _ guideID: String) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 211))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        let guideID = try await TutorialSeeder.restore(session: session)
        return try await body(session, db, guideID)
    }
}

private enum ChapterError: Error { case missing(String) }

/// A lesson's whole stored text, by its exact title.
private func prose(_ db: AppDatabase, _ guideID: String, _ title: String) async throws -> String {
    try await db.read { db in
        guard let id = try String.fetchOne(
            db,
            sql: """
                SELECT c.id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                """,
            arguments: [guideID, title])
        else { throw ChapterError.missing(title) }
        return try Queries.renderedText(db, containerID: id)
    }
}

/// A plain note with one line of text (bookless, or minted inside a book).
@MainActor
private func note(
    _ ops: Operations, _ text: String, in bookID: String? = nil, wing: String = ""
) throws -> String {
    let post: Container
    if let bookID {
        post = try ops.newPostInReading(bookID, section: nil, title: nil, profile: .generic)
    } else {
        post = try ops.createPost(title: nil, wingId: wing)
    }
    _ = try ops.newBlock(in: post.id, text: text, at: .end, registeringUndo: false)
    return post.id
}

/// An approved client holding `spec` (or nothing).
private func approvedClient(_ ops: Operations, _ name: String, _ spec: Operations.MCPGrantSpec?) throws -> MCPClient {
    let client = try ops.recordMCPContact(name: name, version: "1.0")
    _ = try ops.approveMCPClient(client.id, granting: spec)
    return client
}

private func grant(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

/// Who reaches a note right now, by name — the in-note indicator's own read.
private func reachers(_ db: AppDatabase, _ noteID: String) async throws -> [String] {
    try await db.read { try Queries.mcpNoteSharing($0, noteID: noteID).map(\.clientName) }
}

private let lessons = TutorialSeeder.mcpLessons

/// A tool's declaration, by name — the catalog the wire serves (VX-197 U8b).
private func tool(_ name: String) throws -> MCPToolDeclaration {
    try #require(MCPToolCatalog.declaration(named: name), "\(name) is a declared tool")
}

/// The client placeholder the chapter quotes (lesson 7's "Undo ‹name›'s take").
private let placeholderName = "\u{2039}name\u{203A}"

// MARK: - The chapter

@MainActor
@Suite("Tutorial contract — AI & the MCP door (13n-c U5)")
struct TutorialMCPChapterTests {

    /// Seven lessons, the guide's appendix after the privacy chapter (P-13nc-U5-1),
    /// every lesson seeded under it. Three guards over the WHOLE chapter: the
    /// gathering promise only where U6 (VX-273) put it — lesson 3, with its
    /// truth pinned there — and her ruled "how to use it" (lesson 6's wing
    /// recipe, its truth pinned there); the pending mark by its ROLE, never its
    /// shape (O-1 may change the glyph); the app's vocabulary (commit, never
    /// savepoint) and no shouted word.
    /// 13n-c U6 JOB 4 (A JUSTIFIED EDIT, the ritual — her ruled lesson,
    /// 2026-10-11): six → seven, the test renamed with it.
    @Test func theChapterIsSevenLessonsAndTheGuidesAppendix() async throws {
        #expect(TutorialSeeder.plan.last?.chapter == TutorialSeeder.mcpChapter)
        #expect(TutorialSeeder.plan.last?.lessons == lessons)
        #expect(lessons.count == 7)
        try await withGuideWorld { _, db, guideID in
            let filed = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT c.title FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                        JOIN reading_section rs ON rs.id = rp.section_id
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rs.name = ?
                        ORDER BY rp.position, rp.id
                        """,
                    arguments: [guideID, TutorialSeeder.mcpChapter])
            }
            #expect(filed == lessons, "every lesson, in order, under the chapter")
            for title in lessons {
                let text = try await prose(db, guideID, title)
                #expect(!text.isEmpty)
                // 13n-c U6 (A JUSTIFIED EDIT, the ritual — U6 landed VX-273):
                // gatherings are taught in lesson 3, and named again only in
                // her "how to use it" wing recipe (JOB 4 — the second justified
                // edit; its truth is pinned in that lesson's test).
                // VX-197 U8b (A JUSTIFIED EDIT, the ritual — VX-184 U2's carry
                // and VX-268/VX-185's icon): lesson 7's icon sentence says "a
                // book or a gathering", and its truth is pinned there.
                #expect(text.localizedCaseInsensitiveContains("gathering")
                            == [lessons[2], lessons[5], lessons[6]].contains(title),
                        "\(title): gatherings are lesson 3's (VX-273), the wing recipe's and the icon's (VX-185)")
                #expect(!text.localizedCaseInsensitiveContains("filled"),
                        "\(title): the pending mark is taught by its role, never its shape")
                #expect(!text.localizedCaseInsensitiveContains("savepoint"))
                #expect(text.range(of: #"\b(?!MCP\b|JSON\b)[A-Z]{3,}\b"#, options: .regularExpression) == nil,
                        "\(title): no shouted word")
                // VX-197 U8b — 13s's voice (R-13s-22, her words: "reduce AIisms
                // in your writing like emoji's and em dashes"): no em dash in
                // the chapter's own prose; a surface's own words, quoted, keep
                // theirs (the Private row, lesson 4 — the 13s overview's
                // quoted-UI rule). RED ON OLD: lessons 1 and 6.
                #expect(!text.replacingOccurrences(of: PrivateMarkCopy.rowWords, with: "").contains("\u{2014}"),
                        "\(title): no em dash outside a quoted surface")
            }
        }
    }

    // MARK: - Lesson 1 — what the door is

    @Test func lessonOneTheDoorIsShutUntilYouOpenIt() async throws {
        try await withGuideWorld { _, db, guideID in
            let text = try await prose(db, guideID, lessons[0])
            #expect(text.contains("MCP, the Model Context Protocol"))
            // 13n-c O-4 (her ask): the door is described for ANY client — no
            // provider is named outside the setup lesson's menu card.
            #expect(text.contains("a standard way for AI apps to use another app's tools"))
            for name in ["claude", "codex"] { #expect(!text.localizedCaseInsensitiveContains(name)) }
            #expect(text.contains("it stays shut until you open it"))
            #expect(text.contains("the phone has no door"))
            // The doors, by their own words.
            #expect(text.contains("Settings \u{25B8} \(SettingsPane.mcp.title)"))
            #expect(text.contains(MCPPaneCopy.enableTitle), "the switch, by its own title")
            let chord = try #require(CapabilityRegistry.capability(.mcpSettings).shortcutLabel)
            #expect(text.contains("(\(chord) takes you there)"), "⌥⌘, by the registry's own label")
            // Stage B R1 B10: the undo stack is session-scoped (AppSpec §9 —
            // in memory), so the promise says how long it holds — the guide's
            // own words for it ("for as long as this session is open").
            #expect(text.contains("comes back out with \u{2325}\u{2318}Z for as long as this session is open"))
            // VX-168 U2: a client's own commit (save_commit) is the one act
            // ⌥⌘Z never walks back — the promise names the exception (its
            // TRUTH is executed below).
            #expect(text.contains("comes back out with \u{2325}\u{2318}Z for as long as this session is open, "
                                  + "except a commit, which stays, as yours do."))
            // "The last lesson in this chapter shows how to watch it, answer it
            // and undo it" — true only while that lesson stays LAST (JOB 4
            // seats her "how to use it" before it — P-13nc-U6-9).
            // 13n-c UX walk W-UX-17 (A JUSTIFIED EDIT, the ritual): Read shows
            // no lesson titles, so the pointer NAMES the lesson ("The last
            // lesson in this chapter shows how…" before).
            #expect(text.contains("The chapter's last lesson, \u{201C}\(try #require(lessons.last))\u{201D}, shows how to watch it, answer it and undo it."))
            #expect(lessons.last == "seeing, answering, undoing")
            // W-UX-17: "way in" is said once ("Variorum calls its way in the door" before).
            #expect(text.components(separatedBy: "way in").count - 1 <= 1)

            // THE TRUTH. "it stays shut until you open it" — the switch and the
            // open book are both OFF on a fresh store.
            let (server, openBook) = try await db.read { db in
                (try Queries.mcpSwitch(db, .server), try Queries.mcpSwitch(db, .openBook))
            }
            #expect(!server && !openBook)
            // "grants never sync to your other devices" — the grants family is
            // outside the sync registry entirely.
            // Stage B R1 B1 (MAJOR): only the GRANTS stay on this Mac. What a
            // client reads leaves with the client (read_note, search and
            // export_note hand text over the wire, and a client sends its work
            // to its model's provider), so the lesson must never say that what
            // you share stays here — and says plainly where it goes.
            // VX-197 U8b (A JUSTIFIED EDIT, the ritual — R-13s-22's em dash):
            // "Your grants stay on this Mac — they never sync…" before.
            #expect(text.contains("Your grants stay on this Mac and never sync to your other devices."))
            #expect(!text.localizedCaseInsensitiveContains("share stays"),
                    "what you share leaves with the client — only the grants stay")
            #expect(!text.localizedCaseInsensitiveContains("shared stays"))
            #expect(text.contains("What a client reads goes wherever that client sends its work: for most "
                                  + "clients, the company that runs its model."))
            for table in MCPGrantSchema.tables {
                #expect(SyncSchema.table(named: table) == nil, "\(table) never syncs")
            }

            // THE TRUTH (VX-168 U2). "except a commit, which stays, as yours
            // do": a client's commit and her own register NO undo entry, and
            // the commit is the only MCP act whose receipt makes no undo claim.
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let page = try note(ops, "a page a client checked")
            let take = try #require(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT chosen_variant_id FROM container_block WHERE container_id = ?", arguments: [page])
            })
            let depth = stack.depth
            _ = try ops.commitTakeForClient(take, message: "checked", client: "a-client")
            _ = try ops.commit(take, message: "mine")
            #expect(stack.depth == depth, "a commit, theirs or yours, never joins the undo stack")
            #expect(try await db.read { db in
                try String.fetchAll(db, sql: "SELECT message FROM commit_point WHERE variant_id = ? ORDER BY created_at",
                                    arguments: [take])
            } == ["a-client: checked", "mine"], "both stay")
            #expect(Operations.MCPWriteAct.allCases.filter { !$0.isUndoable } == [.commit])
        }
    }

    // MARK: - Lesson 2 — connecting a client

    @Test func lessonTwoConnectingAClient() async throws {
        try await withGuideWorld { session, db, guideID in
            let text = try await prose(db, guideID, lessons[1])
            #expect(text.contains("under \(MCPPaneCopy.connectSection), choose yours"))
            #expect(text.contains("Claude Code, Codex, or Any MCP client"))
            #expect(MCPSetupClient.allCases.map(\.label) == ["Claude Code", "Codex", "Any MCP client"],
                    "the menu the lesson names, in its order")
            // VX-197 U8b (A JUSTIFIED EDIT, the ritual — VX-205, built at
            // VX-281): "Then press Copy setup command" taught a button the pane
            // no longer has. The act's face is the code block's copy icon, in
            // its upper right, with the act's verb as its help (one act, one
            // door). RED ON OLD: the old seed says "press Copy setup command".
            let copyVerb = CapabilityRegistry.capability(.mcpCopySetupCommand).verb
            #expect(!text.contains("press \(copyVerb)"), "no button by that name is on the pane")
            #expect(text.contains("choose yours at the top of the setup block: Claude Code, Codex, or Any MCP client. "
                                  + "Then click the copy icon in the block's upper right corner."))
            #expect(MCPSetupCodeBlock.copySymbol == "doc.on.doc", "the standard copy glyph")
            #expect(MCPPane.surfaceCapabilities.contains(.mcpCopySetupCommand), "…the one copy act's door")
            #expect(text.contains("a few lines of JSON"))
            #expect(MCPSetupClient.anyClient.text(shimPath: "/x", isDebugBuild: false).contains("\"mcpServers\""))
            // VX-168 (A JUSTIFIED EDIT, the ritual): Claude Code's one line
            // clears an earlier user-scope setup, then adds this one.
            #expect(MCPSetupClient.claudeCode.text(shimPath: "/x", isDebugBuild: false).contains("; claude mcp add -s user"))
            #expect(MCPSetupClient.codex.text(shimPath: "/x", isDebugBuild: false).hasPrefix("codex mcp add"))
            #expect(text.contains("the door is a standard MCP server: one program inside the app"))
            #expect(MCPPaneCopy.stdioLine.contains("standard MCP server")
                && MCPPaneCopy.stdioLine.contains("one program"), "the pane says the same")
            #expect(text.contains("as a connection request"))
            #expect(MCPPaneCopy.requestsSection == "Connection requests")
            for id in [CapabilityID.mcpApproveClient, .mcpDenyClient, .mcpChangeClientAccess, .mcpRevokeClient] {
                #expect(text.contains(CapabilityRegistry.capability(id).verb), "\(id)'s verb")
            }
            // VX-168 (A JUSTIFIED EDIT, the ritual): the limit the setup key
            // falsified ("Variorum can't check that name") is true of the
            // build now — and pinned against the rule it describes.
            #expect(!text.contains("Variorum can't check that name"))
            // VX-198 (A JUSTIFIED EDIT, the ritual — R-VX184-5): "so a second
            // tool using the same name is turned away" was falsified (the
            // newest copied setup takes the name); the sentence says the rule
            // as built, and is pinned against it here.
            #expect(!text.contains("a second tool using the same name is turned away"))
            // VX-258 (A JUSTIFIED EDIT, the ritual — VX-246 ladder round 1,
            // F-1): "Running the setup again moves the name to the new key"
            // was falsified in its turn — only a CLIENT'S OWN setup (a key
            // copied for its name) re-binds with zero clicks; an "Any MCP
            // client" copy under a name she approved waits for her OK
            // (`MCPSetupKeyRule.decide`'s `.unclaimed` arm, pinned below). The
            // lesson now says L1's clause verbatim, and the parity guard holds
            // the guide and the pane to the one rule.
            #expect(!text.contains("Running the setup again moves the name"),
                    "the unscoped re-run sentence (false for an Any-client copy since VX-258)")
            #expect(text.contains("a key that ties that name to it. Running the client's own setup again moves the "
                                  + "name to the new key; a setup copied for any MCP client waits for your OK before "
                                  + "it takes a name you approved; and a tool still using an older key, or none, is "
                                  + "turned away."))
            let oneRule = "Running the client's own setup again moves the name to the new key; a setup copied for "
                + "any MCP client waits for your OK before it takes a name you approved"
            #expect(text.contains(oneRule), "the guide says L1's clause")
            #expect(MCPPaneCopy.clientBoundary.contains(oneRule), "…and L1 says it (the parity guard)")
            #expect(text.contains("where any program running as you can read it"), "K2's non-defeat, said")
            #expect(MCPPaneCopy.clientBoundary.contains("binds that name to it"), "L1 says the same")
            // VX-258 (A JUSTIFIED EDIT, the ritual — VX-246 U1b): L1 scopes the
            // re-run to the client's OWN setup and says the Any-client wait (the
            // guide's lesson 2 is U8's to re-voice — the follow-on run's).
            #expect(MCPPaneCopy.clientBoundary.contains("Running the client's own setup again moves the name to the new key"))
            #expect(MCPPaneCopy.clientBoundary.contains("a setup copied for any MCP client waits for your OK"))
            #expect(MCPPaneCopy.clientBoundary.contains("any of them can read the key"))
            // VX-197 U8b — LESSON 2 RE-VOICED (VX-258's tab rule, her ruling:
            // "tie keys to their tab … the re-bind waits for my ok"). The
            // parity clause above stays byte-shared with L1; the lesson adds
            // what the clause leaves out — which setup is a client's OWN, that
            // it needs no clicks, and where any other waits, seeing nothing
            // until she allows it. RED ON OLD: none of it is said.
            #expect(text.contains("A client names itself when it connects, and the setup you copy carries a key "
                                  + "that ties that name to it."))
            #expect(text.contains("A client's own setup is the one copied from its tab, and moving its name "
                                  + "takes no clicks."))
            #expect(text.contains("Any other new setup for a name you approved waits under "
                                  + "\(MCPPaneCopy.waitingSection), above the tabs in Settings \u{25B8} MCP, as a new "
                                  + "setup for that name."))
            #expect(MCPPaneCopy.rebindTitle("x") == "New setup for x", "Waiting's row, by its own words")
            let allow = CapabilityRegistry.capability(.mcpAllowRebind).verb
            let decline = CapabilityRegistry.capability(.mcpDeclineRebind).verb
            #expect(text.contains("It sees no tools until you choose \(allow), which moves the name and its grants "
                                  + "to it; \(decline) turns it away."))
            #expect(MCPPaneCopy.rebindDetail(name: "x", version: nil, firstSeen: "today")
                        .contains("allowing moves the name, with its grants, to this setup"), "the row says the same")
            #expect(text.contains("One honest limit: the key sits in the client's own settings, where any program "
                                  + "running as you can read it. It tells two tools apart, not programs running as you."))
            #expect(MCPPaneCopy.clientBoundary.contains("tells two tools apart, not programs running as you"),
                    "L1 says the same")
            // THE TRUTH: "its own setup" is a tab's (a tab names its client;
            // Any MCP client names nobody), and any OTHER fresh key under an
            // approved name — another tab's included — waits.
            #expect(MCPSetupClient.claudeCode.expectedName != nil && MCPSetupClient.codex.expectedName != nil)
            #expect(MCPSetupClient.anyClient.expectedName == nil)
            let bound = MCPSetupKeyRule.Client(id: "c", boundHash: MCPSetupKeyRule.hash("vmk1_first"))
            let second = MCPSetupKeyRule.hash("vmk1_second")
            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds
            // with zero clicks only the name its setup was copied FOR): "running
            // the setup again" is the client's OWN setup, so the key carries its
            // name; an "Any MCP client" copy waits for her OK (pinned beside, so
            // the sentence's scope is said). U8's guide pass re-voices lesson 2.
            #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: second,
                                           copiedFor: "claude-code", standing: .unclaimed)
                    == .rebind, "running the setup again moves the name to the new key")
            #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: second, standing: .unclaimed)
                    == .awaitRebind, "an Any-client copy under an approved name waits for her OK (VX-258)")
            // VX-197 U8b: "Any other new setup for a name you approved waits" —
            // another tab's copy too, not only an Any-client one.
            #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: second,
                                           copiedFor: MCPSetupClient.codex.expectedName, standing: .unclaimed)
                    == .awaitRebind, "another tab's setup under an approved name waits too")
            #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: second, standing: .replaced)
                    == .refuse(.replaced), "a tool still using an older key is turned away")
            #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: second, standing: .unknown)
                    == .refuse(.notThisNamesKey), "…as is one using a key never issued")
            #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: nil, standing: .unknown)
                    == .refuse(.bare), "…or none")

            // THE TRUTH. "it can reach nothing yet": a connection request is
            // refused by the one rule, even with the open book on.
            let ops = session.operations
            let page = try note(ops, "a page anyone could read")
            try ops.setMCPSwitch(.openBook, on: true)
            let pending = try ops.recordMCPContact(name: "claude-code", version: "1.0")
            #expect(pending.state == .pending)
            #expect(try await reachers(db, page).isEmpty, "a request reaches nothing")
            // A JUSTIFIED EDIT (13n-c UX walk W-UX-2 — her ruling, sitting round
            // 6: APPROVE ALONE, GRANT SEPARATE; the ritual): the sentence was
            // "Approve… lets it in and asks what to share first."; now "Approve…
            // lets it in, still reaching nothing until you share something: its
            // sheet offers a first grant, with nothing picked for you."
            #expect(text.contains("still reaching nothing until you share something"))
            #expect(text.contains("with nothing picked for you"))
            #expect(MCPGrantSheet.start(approving: true, mostRecentBookID: "b1").place == .nothing,
                    "the approval sheet picks nothing (the sheet's own start)")
            // VX-197 U8b — THE TOOLS LINE (U7's carry, builder A's OWED 6):
            // an approved client with nothing shared is not toolless — it can
            // always read its own recent acts (P-VX261-2). A connection
            // request and a waiting setup see none (VX-258; the decide arms
            // above). RED ON OLD: never said.
            #expect(text.contains("it shows up at the top of Settings \u{25B8} MCP as a connection request"))
            #expect(text.contains("Until then, the one thing an approved client can do is look back over its own "
                                  + "recent acts."))
            #expect(MCPToolCatalog.all.filter(\.listedWhenApproved).map(\.name) == ["list_my_activity"],
                    "the ONE tool listed for every approved client")
            #expect(try tool("list_my_activity").rung == .read)
            #expect(text.contains("Every approved client is listed under \(MCPPaneCopy.clientsSection), with"))
            try ops.setMCPSwitch(.openBook, on: false)
            _ = try ops.approveMCPClient(pending.id, granting: nil)
            #expect(try await reachers(db, page).isEmpty, "approved alone, it reaches nothing")
            _ = try ops.grantMCPAccess(pending.id, grant(.read, .note, page))
            #expect(try await reachers(db, page) == ["claude-code"], "its first grant reaches")
        }
    }

    // MARK: - Lesson 3 — how much, where, how long

    @Test func lessonThreeHowMuchWhereHowLong() async throws {
        try await withGuideWorld { session, db, guideID in
            let text = try await prose(db, guideID, lessons[2])
            // The four steps, by the sheet's own names, in order.
            let names = MCPPaneCopy.offeredRungs.map { "\(MCPPaneCopy.rungName($0)):" }
            let positions = names.compactMap { text.range(of: $0)?.lowerBound }
            #expect(positions.count == 4 && positions == positions.sorted(), "Read · Suggest · Write new · Edit")
            #expect(text.contains("each including the ones before it"))
            #expect(text.contains("it can't change a word you wrote"))
            #expect(MCPPaneCopy.rungDetail(.suggest).contains("cannot touch a word you wrote"))
            let bracket = Operations.mcpEditCommitNames(client: "claude-code")
            #expect(bracket.before.hasPrefix("before") && bracket.after.hasPrefix("after"))

            // VX-197 U8b — THE STEPS' REACH AS BUILT (VX-184 U3–U5, VX-246,
            // VX-336 U5–U6). Every act a sentence names is a tool at that rung
            // in the catalog the wire serves. RED ON OLD: the old Suggest and
            // Write new sentences named none of the new acts, and the old Edit
            // sentence (A JUSTIFIED EDIT below) stopped at blocks.
            #expect(text.contains("Suggest: it can add new takes and comments beside your text, one at a time or "
                                  + "many at once, and save a lens"))
            for name in ["add_take", "add_takes", "add_comment", "add_comments", "save_lens"] {
                #expect(MCPToolFacts.rung(of: name) == .suggest, "\(name) is a suggest-rung act")
            }
            #expect(text.contains("Write new: it can also make new notes, books, chapters and tags, file notes into "
                                  + "books and chapters, and give a book a rule that collects notes by tag. It can add "
                                  + "blocks at the end of a note, duplicate a note to work on a copy, and link two notes "
                                  + "as versions by naming which paragraphs match."))
            for name in ["create_note", "create_book", "create_section", "apply_tag", "add_note_to_book",
                         "file_note_in_chapter", "set_book_rule", "insert_blocks", "duplicate_note", "link_versions"] {
                #expect(MCPToolFacts.rung(of: name) == .writeNew, "\(name) is a write-new act")
            }
            #expect(try tool("insert_blocks").description.contains("they go at the note's END — write new on the note "
                                                                     + "is enough"), "write new adds at the end only")
            #expect(try tool("link_versions").description.contains("Name at least one pair"),
                    "the client names which paragraphs match (R-VX187-1)")
            // VX-168 U2: Edit's step names the deliberate acts — choosing and
            // committing a take, making a lens the note. THE TRUTH: every act
            // the sentence names is an edit-rung tool in the catalog.
            // VX-197 U8b (A JUSTIFIED EDIT, the ritual — R-VX184-1, "as capable
            // as her at the keyboard"): the Edit step says its reach as built,
            // inside a note and across the library ("Edit: it can also change,
            // choose and commit takes, make a lens the note, and divide, merge,
            // move or delete blocks." before).
            let editStep = """
                Edit: it can also do most of what you can do at the keyboard. In a note, it can change, choose, \
                commit, archive or delete takes, restore a commit, make a lens the note, add blocks anywhere, \
                divide, merge, move or delete blocks, and edit or delete any comment. Across the library, it can \
                take a tag off a note, rename, archive or delete notes and books, finish or reopen a book, reorder \
                a book's notes and chapters, and rename or delete a chapter.
                """
            #expect(text.contains(editStep))
            for name in ["edit_take", "choose_take", "save_commit", "archive_take", "delete_take", "restore_commit",
                         "adopt_lens", "divide_block", "merge_blocks", "move_block", "delete_block", "edit_comment",
                         "remove_tag", "rename_note", "archive_note", "delete_note", "rename_book", "archive_book",
                         "delete_book", "finish_book", "reopen_book", "move_note_in_book", "move_chapter",
                         "rename_chapter", "delete_chapter"] {
                #expect(MCPToolFacts.rung(of: name) == .edit, "\(name) is an edit-rung act")
            }
            #expect(try tool("insert_blocks").description.contains("Placing them anywhere else needs edit"),
                    "blocks anywhere: insert_blocks at edit (VX-255, her ruling)")
            #expect(try tool("delete_comment").description.contains("With edit on the note you may delete any comment"),
                    "any comment at edit (R-VX188-1)")

            // VX-197 U8b (A JUSTIFIED EDIT, the ritual — U4's OWED, U8a's
            // description truth): "When it changes a take, Variorum commits
            // the take just before and just after" was true only of a take's
            // WORDS, and the first commit is skipped when the take's latest
            // commit already holds them. THE TRUTH below runs the act.
            #expect(!text.contains("commits the take just before and just after"))
            #expect(text.contains("When it rewrites the words of a take, Variorum first commits the words it "
                                  + "replaces, unless the take's latest commit already holds them, and then commits the "
                                  + "new words, so you can always compare and come back. Both commits stay even if you "
                                  + "undo the edit."))

            // VX-197 U8b — WHO WROTE WHAT: the label rule (her VX-197 split,
            // VX-267's form) and the comment rule (VX-260). RED ON OLD.
            let suggested = MCPWriteTools.aiLabel(client: placeholderName, own: "english")
            #expect(suggested == "\(placeholderName)\(MCPWriteTools.labelSeparator)english")
            #expect(MCPWriteTools.labelSeparator == " \u{00B7} ", "the dot the lesson names")
            #expect(MCPWriteTools.aiLabel(client: placeholderName, own: nil) == placeholderName, "no label: the name")
            #expect(text.contains("You can always see who suggested a take. A take a client adds beside yours wears "
                                  + "its name, then a dot and its own label if it gave one, like \(suggested)."))
            #expect(text.contains("Takes it writes into a new note or new blocks, and labels it sets on a take, carry "
                                  + "only the label it gave."))
            for name in ["add_take", "add_takes"] {
                #expect(try tool(name).description.contains(MCPToolCatalog.suggestedLabelRule), "\(name) names itself")
            }
            for name in ["create_note", "insert_blocks", "import_document", "duplicate_note", "set_take_label"] {
                #expect(try tool(name).description.contains(MCPToolCatalog.labelNotPrefixed),
                        "\(name) stores the label as given")
            }
            #expect(text.contains("With Suggest it can delete a comment it left, but only while the words are still "
                                  + "the ones it wrote; once anyone changes them, deleting that comment takes Edit, "
                                  + "which can delete any comment."))
            #expect(MCPToolFacts.rung(of: "delete_comment") == .suggest)

            // VX-197 U8b — R-VX184-2: "three acts stay hers alone: Private,
            // Seal, Own … though the AI should know about them so it can tell
            // a user that they might want that." The chapter and the advice
            // say the same three; no tool can do any of them. RED ON OLD.
            #expect(text.contains("Three things stay yours alone, whatever you grant: marking something Private, "
                                  + "sealing a book, and making a book own its notes. A client knows what each one does "
                                  + "and may suggest one when it would help, but only you can do it."))
            for act in ["marking something Private", "sealing a book", "making a book own its notes"] {
                #expect(MCPSession.instructions.contains(act), "the advice names \u{201C}\(act)\u{201D} too (D-2)")
            }
            for name in MCPToolFacts.toolNames {
                let words = Set(name.split(separator: "_").map(String.init))
                #expect(words.isDisjoint(with: ["private", "seal", "sealed", "own", "owned", "owning"]),
                        "\(name): no tool marks Private, seals or owns")
            }
            // Where, and how long — the durations by their own words.
            #expect(text.contains("one note; one book, with its notes now and any added to it later; or a whole wing"))
            // The wing and the open book never overclaim: the exceptions are
            // named, and "the next lesson" really is the one that names them.
            // W-UX-17 (A JUSTIFIED EDIT, the ritual): the exceptions are named
            // where they are pointed at — Read shows no lesson titles.
            #expect(text.contains("everything in it, except what always asks: your daily Journal's entries and anything Private (the next lesson)"))
            #expect(text.contains("read everything, always, again except what always asks"))
            #expect(lessons[3] == "what always asks")
            for duration in MCPGrantRule.Duration.allCases {
                #expect(text.contains(MCPPaneCopy.durationWord(duration)), "\(duration)'s word")
            }
            #expect(text.contains("(offered while it's connected)"))
            #expect(MCPGrantSheet.durations(connected: false) == [.once, .always],
                    "until it disconnects is offered only while the client is connected")
            #expect(text.contains("The open book is the widest grant of all"))
            #expect(text.contains("It is off to begin with"))

            // THE TRUTH. Cumulative steps: an edit grant reads.
            let ops = session.operations
            let book = try ops.createReading(name: "chapters", kind: .book)
            let early = try note(ops, "the first chapter", in: book.id)
            _ = try approvedClient(ops, "claude-code", grant(.edit, .book, book.id))
            let reached = try await db.read { try Queries.mcpNoteSharing($0, noteID: early) }
            #expect(reached.map(\.rung) == [.edit], "edit includes read")
            // "with its notes now and any added to it later".
            let later = try note(ops, "a chapter added later", in: book.id)
            #expect(try await reachers(db, later) == ["claude-code"], "membership is live")
            // "or a whole wing and everything in it".
            let loose = try note(ops, "a loose page in Home")
            _ = try approvedClient(ops, "codex", grant(.read, .wing, ""))
            #expect(try await reachers(db, loose) == ["codex"])
            // "once, for a single act": a once read grant is spent by its first
            // content read (the decision says so), never by a listing.
            let once = MCPGrantRule.Grant(id: "g", rung: .read, scopeKind: .note, scopeID: loose, duration: .once)
            let looseFacts = try #require(try await db.read { try Queries.mcpNoteFacts($0, noteID: loose) })
            #expect(MCPGrantRule.decide(
                client: .approved, grants: [once], openBook: false, target: .note(looseFacts),
                rung: .read, consumes: true) == .allow(grantID: "g", consumesOnce: true))
            #expect(MCPGrantRule.decide(
                client: .approved, grants: [once], openBook: false, target: .note(looseFacts),
                rung: .read, consumes: false) == .allow(grantID: "g", consumesOnce: false))
            #expect(!MCPGrantRule.Grant(
                id: "g", rung: .read, scopeKind: .note, scopeID: loose, duration: .once,
                consumedAt: "2026-07-01T00:00:00.000Z").isLive, "spent, it reaches nothing more")
            // 13n-c U6 — the fourth card (VX-273 + VX-160), prose then truth.
            #expect(text.contains("A wing grant also lets a client read that wing's gatherings"))
            #expect(text.contains("a gathering is never shared on its own"))
            #expect(text.contains("move a note to another wing only with edit where the note is and write new "
                                  + "in the wing it goes to"))
            #expect(text.contains("the note leaves its books there, its tags come along, and "
                                  + "\u{2325}\u{2318}Z brings it back"))
            // "read that wing's gatherings": codex's Home-wing read grant reaches
            // a Home gathering; claude-code's book grant never does.
            let topic = try ops.createTag(name: "drafts")
            let gathering = try ops.createReading(
                name: "every draft", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            let gatheringFacts = try #require(try await db.read {
                try Queries.mcpGatheringFacts($0, readingID: gathering.id)
            })
            func reachesGathering(_ name: String) async throws -> Bool {
                let grants = try await db.read { db in
                    try Queries.mcpGrants(db, clientID: try Queries.mcpClient(db, name: name)!.id).map(\.ruleGrant)
                }
                return MCPGrantRule.decideGathering(
                    client: .approved, grants: grants, openBook: false, gathering: gatheringFacts).isAllowed
            }
            #expect(try await reachesGathering("codex"), "a wing grant reads its gatherings")
            #expect(try await !reachesGathering("claude-code"), "a book grant never does")
            // "never shared on its own": no grant may name one.
            let codex = try #require(try await db.read { try Queries.mcpClient($0, name: "codex") })
            #expect(throws: OperationError.self) {
                _ = try ops.grantMCPAccess(codex.id, grant(.read, .book, gathering.id))
            }
            // "only with edit where the note is and write new in the wing it
            // goes to": the two decisions, on the note's own facts.
            let annex = try ops.createWing(name: "Annex")
            let mover = try note(ops, "a page that moves", in: book.id)
            try ops.applyTag(topic.id, toPost: mover)
            let moverFacts = try #require(try await db.read { try Queries.mcpNoteFacts($0, noteID: mover) })
            let writeNewHere = MCPGrantRule.Grant(id: "w", rung: .writeNew, scopeKind: .wing, scopeID: "",
                                                  duration: .always)
            let writeNewThere = MCPGrantRule.Grant(id: "t", rung: .writeNew, scopeKind: .wing, scopeID: annex.id,
                                                   duration: .always)
            #expect(!MCPGrantRule.decide(client: .approved, grants: [writeNewHere], openBook: false,
                                         target: .note(moverFacts), rung: .edit, consumes: true).isAllowed,
                    "write new where the note is cannot move it")
            #expect(MCPGrantRule.decideWing(client: .approved, grants: [writeNewThere], openBook: false,
                                            wingID: annex.id, rung: .writeNew).isAllowed)
            // "the note leaves its books there, its tags come along, and ⌥⌘Z
            // brings it back" — the act and its one undo.
            let stack = UndoStack()
            let moved = try Operations(undoStack: stack).mcpMoveNoteToWing(
                mover, to: annex.id, undoLabel: Operations.MCPWriteAct.wingMove.undoLabel(client: "codex"))
            #expect(moved.leftBookIDs == [book.id], "it leaves its books")
            #expect(try await db.read { try Queries.effectiveWing($0, ofPost: mover) } == annex.id)
            let carried = try await db.read { db in
                try String.fetchAll(db, sql: """
                    SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL AND t.wing_id = ?
                    """, arguments: [mover, annex.id])
            }
            #expect(carried == ["drafts"], "its tags come along, by their path")
            #expect(try stack.undo(with: Operations(undoStack: stack)) == "codex's wing move", "one ⌥⌘Z")
            #expect(try await db.read { try Queries.effectiveWing($0, ofPost: mover) } == "")
            #expect(try await db.read { try Queries.mcpNoteFacts($0, noteID: mover) }?.bookIDs == [book.id],
                    "back in its book")

            // "one switch … lets every approved client read everything": with
            // the open book on, a client holding NO grant reads the loose page.
            _ = try approvedClient(ops, "local-llama", nil)
            #expect(!(try await reachers(db, loose)).contains("local-llama"))
            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try await reachers(db, loose).contains("local-llama"))

            // VX-197 U8b — THE TRUTH of the commit sentence, on the wire's own
            // act (`editTakeUnderInsurance`; the headless twin is U8a's
            // `MCPEditServerTests.editTakesBeforeCommitIsDedupedAndTheDescriptionSaysSo`).
            let editStack = UndoStack()
            let editOps = Operations(undoStack: editStack)
            let page = try note(ops, "first words")
            let take = try #require(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT chosen_variant_id FROM container_block WHERE container_id = ?", arguments: [page])
            })
            func commits() async throws -> [String] {
                try await db.read { db in
                    try String.fetchAll(db, sql: "SELECT text FROM commit_point WHERE variant_id = ? "
                                        + "ORDER BY created_at, id", arguments: [take])
                }
            }
            let editLabel = Operations.MCPWriteAct.edit.undoLabel(client: "claude-code")
            _ = try ops.commit(take, message: "hers")
            // "unless the take's latest commit already holds them".
            let kept = try editOps.editTakeUnderInsurance(
                take, text: "second words", expectedText: "first words", client: "claude-code", undoLabel: editLabel)
            #expect(kept.before == nil && kept.after?.text == "second words", "no second copy of kept words")
            // "first commits the words it replaces … then commits the new words".
            try ops.autosave(take, text: "her third words", charDelta: 9)
            let insured = try editOps.editTakeUnderInsurance(
                take, text: "fourth words", expectedText: "her third words", client: "claude-code",
                undoLabel: editLabel)
            #expect(insured.before?.text == "her third words" && insured.after?.text == "fourth words")
            #expect(insured.before?.message == bracket.before && insured.after?.message == bracket.after)
            // "Both commits stay even if you undo the edit."
            let before = try await commits()
            #expect(try editStack.undo(with: editOps) == editLabel)
            #expect(try await db.read { try Variant.fetchOne($0, key: take) }?.workingText == "her third words")
            #expect(try await commits() == before, "the commits stay")
            // "the WORDS of a take": relabelling it commits nothing — and the
            // label is stored as given, with no client name ("labels it sets
            // on a take carry only the label it gave").
            _ = try editOps.labelTakeForClient(
                take, label: "  english  ", undoLabel: Operations.MCPWriteAct.takeLabel.undoLabel(client: "claude-code"))
            #expect(try await commits() == before, "a label is not the take's words")
            #expect(try await db.read { try Variant.fetchOne($0, key: take) }?.label == "english",
                    "trimmed, as given — no client name")

            // VX-197 U8b — THE TRUTH of the comment rule (VX-260; the
            // headless twin is `MCPCommentWordsServerTests`): a comment a
            // client left is its own while its words are; her edit makes it hers.
            let block = try #require(try await db.read { try Queries.renderPost($0, containerID: page).first })
            let left = try editOps.addComment(
                toBlock: block.blockID, text: "a client's note on this", author: "claude-code",
                undoLabel: Operations.MCPWriteAct.comment.undoLabel(client: "claude-code"))
            #expect(try await db.read { try Queries.mcpCommentIsOwn($0, commentID: left.id, client: "claude-code") })
            try ops.editBlockComment(left.id, text: "her words now")
            #expect(try await !db.read { try Queries.mcpCommentIsOwn($0, commentID: left.id, client: "claude-code") },
                    "once anyone changes the words, deleting it takes Edit")
        }
    }

    // MARK: - Lesson 4 — what always asks

    @Test func lessonFourWhatAlwaysAsks() async throws {
        try await withGuideWorld { session, db, guideID in
            let text = try await prose(db, guideID, lessons[3])
            #expect(text.contains("never reached by a book grant, a wing grant or the open book"))
            #expect(text.contains("the entries in your daily Journal"))
            #expect(text.contains("anything marked Private"))
            #expect(text.contains("Always is never offered for them."))
            #expect(text.contains("choose \(PrivateMarkCopy.rowWords)"), "the note's row, by its own words")
            #expect(text.contains("in its Book Settings"))
            #expect(text.contains("Other books with date-stamped entries share like any book"))
            #expect(CollectingCopy.journalTraitValue.hasPrefix("date-stamped"),
                    "the trait, by the Book Settings row's own word")
            // W-UX-17 (A JUSTIFIED EDIT, the ritual): "An entry ⌘J made" read oddly.
            #expect(text.contains("An entry made with \u{2318}J keeps asking even if you later file it in another book."))
            #expect(text.contains("Snippets can't be reached through the door at all"))
            #expect(text.contains("Snippets is the one room every wing shares"))
            let wingChord = try #require(CapabilityRegistry.capability(.switchWing).shortcutLabel)
            #expect(text.contains("(\(wingChord) switches wings)"))
            #expect(text.contains("looks exactly like something that isn't there"))

            let ops = session.operations
            // Wings first, with the open book OFF (it reads every wing).
            let annex = try ops.createWing(name: "Annex")
            let elsewhere = try note(ops, "a page in another wing", wing: annex.id)
            _ = try approvedClient(ops, "claude-code", grant(.edit, .wing, ""))
            #expect(try await reachers(db, elsewhere).isEmpty, "a grant in one wing never reaches another")
            try ops.setMCPSwitch(.openBook, on: true)

            // THE FENCE under the widest reach: a Home-wing EDIT grant + the open book.
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            _ = try ops.newBlock(in: entry.id, text: "a day's entry", at: .end, registeringUndo: false)
            guard case .shelved(let dailyID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            #expect(try await reachers(db, entry.id).isEmpty, "a daily Journal entry is reached by no standing grant")
            let filedInDaily = try note(ops, "a page filed in the daily Journal")
            _ = try ops.addPostToReading(filedInDaily, to: dailyID)
            #expect(try await reachers(db, filedInDaily).isEmpty)
            let privateNote = try note(ops, "a Private page")
            _ = try ops.setNotePrivate(privateNote, true)
            #expect(try await reachers(db, privateNote).isEmpty, "anything marked Private")
            let privateBook = try ops.createReading(name: "diary", kind: .book)
            let inPrivateBook = try note(ops, "a page in a Private book", in: privateBook.id)
            _ = try ops.setBookPrivate(privateBook.id, true)
            #expect(try await reachers(db, inPrivateBook).isEmpty, "a book's mark covers every note in it")
            // "Other books with date-stamped entries share like any book."
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            let dream = try note(ops, "the flood dream", in: trait.id)
            #expect(try await reachers(db, dream) == ["claude-code"], "a date-stamped book shares like any book")
            // "An entry made with ⌘J keeps asking even if you later file it in another book."
            let another = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            _ = try ops.addPostToReading(another.id, to: trait.id)
            #expect(try await reachers(db, another.id).isEmpty, "a ⌘J entry keeps asking wherever it's filed (D-1)")
            // "only through a grant on that one note, once or until it
            // disconnects. Always is never offered for them."
            let client = try #require(try await db.read { try Queries.mcpClient($0, name: "claude-code") })
            #expect(throws: OperationError.self) {
                _ = try ops.grantMCPAccess(client.id, grant(.read, .note, entry.id, .always))
            }
            _ = try ops.grantMCPAccess(client.id, grant(.read, .note, entry.id, .once))
            #expect(try await reachers(db, entry.id) == ["claude-code"], "one note, one ask at a time")
            // "Snippets can't be reached through the door at all."
            let pool = try ops.createPool(title: "scraps")
            _ = try ops.newBlock(in: pool.id, text: "a snippet", at: .end, registeringUndo: false)
            #expect(try await db.read { try Queries.mcpNoteFacts($0, noteID: pool.id) } == nil,
                    "a scraps group has no facts — no grant, no open book reaches it")
            #expect(throws: OperationError.self) {
                _ = try ops.grantMCPAccess(client.id, grant(.read, .note, pool.id, .once))
            }
        }
    }

    // MARK: - Lesson 5 — sharing from where you are

    @Test func lessonFiveSharingFromWhereYouAre() async throws {
        try await withGuideWorld { session, db, guideID in
            let text = try await prose(db, guideID, lessons[4])
            #expect(text.contains("Once a client is approved"), "the doors render only then (VX-272)")
            #expect(text.contains("choose \(MCPShareCopy.shareVerb)"))
            #expect(CapabilityRegistry.capability(.mcpShareHere).verb == MCPShareCopy.shareVerb)
            #expect(text.contains(MCPShareCopy.shareNotes(3)), "the bulk door, by its own words")
            #expect(LibraryCatalogView.surfaceCapabilities.contains(.mcpShareNotes), "…on the Library")
            #expect(text.contains("with \(MCPShareCopy.shareButton) beside"))
            let share = CapabilityRegistry.capability(.mcpShareThisNote)
            #expect(text.contains("\(try #require(share.shortcutLabel)) (Edit \u{25B8} \(share.verb))"))
            #expect(text.contains("until it disconnects if it's connected, otherwise once, never always"))
            // 13n-c UX walk W-UX-19: the pane's rows carry Change… beside Revoke.
            #expect(text.contains("with \(CapabilityRegistry.capability(.mcpChangeGrant).verb) to raise or lower it and \(CapabilityRegistry.capability(.mcpRevokeGrant).verb) to take it back"))
            #expect(MCPPane.surfaceCapabilities.contains(.mcpChangeGrant))
            // VX-515 (the VX-548 run): the tab's own add door, by its own words.
            #expect(text.contains("\(CapabilityRegistry.capability(.mcpShareAnotherPlace).verb) adds one beside them"))
            #expect(MCPPane.surfaceCapabilities.contains(.mcpShareAnotherPlace))
            #expect(text.contains("with \(MCPShareCopy.change) to adjust it and \(MCPShareCopy.revokeDoor) to take it back"))

            // THE TRUTH — ⌥⌘A's decision (D1): the newest grant's client and
            // step; connected → until it disconnects, else once; never always;
            // no history → the sheet on this note.
            let newest = MCPShareChord.Newest(clientID: "c", clientName: "claude-code", rung: .suggest)
            #expect(MCPShareChord.decide(newest: newest, connected: true, reached: nil)
                == .grant(clientID: "c", clientName: "claude-code", rung: .suggest, duration: .connection))
            #expect(MCPShareChord.decide(newest: newest, connected: false, reached: nil)
                == .grant(clientID: "c", clientName: "claude-code", rung: .suggest, duration: .once))
            #expect(MCPShareChord.decide(newest: nil, connected: true, reached: nil) == .openSheet)
            // "Sharing several notes at once makes one row there, and one
            // Revoke covers them all."
            let ops = session.operations
            let client = try approvedClient(ops, "claude-code", nil)
            let picked = try (1...3).map { try note(ops, "picked note \($0)") }
            let ids = try ops.grantMCPAccess(client.id, notes: picked, rung: .read, duration: .always)
            let groups = try await db.read { try Queries.mcpSharedGroups($0) }
            #expect(groups.count == 1 && groups.first?.memberCount == 3, "one row for the act")
            try ops.revokeMCPGrants(ids)
            #expect(try await db.read { try Queries.mcpSharedGroups($0) }.isEmpty, "one Revoke covers them all")
        }
    }

    // MARK: - Lesson 6 — how to use it (her ruled lesson, 13n-c U6 JOB 4)

    /// **HER RULED LESSON** (her sitting, 2026-10-11, third round — "fold in
    /// the 'How to use it' — I think specific examples would be good"; "We
    /// should help people with how to use AI within the note and within the
    /// app"): four worked recipes, each sentence EXECUTED. The wire's half of
    /// the same facts is already proven server-side and cited, never
    /// duplicated: `MCPWriteServerTests.theFactCheckShapeLandsATakeBeside…`
    /// (a suggest book grant's takes land labeled and unchosen, the shown
    /// text unchanged, one undo walks the last act back),
    /// `.aSuggestGrantProvablyCannotModifyAnExistingTake`,
    /// `.writeNewCreatesInsideItsScopeOnlyAndNeverPullsAnUnreachableNoteIn`,
    /// `MCPServerTests.aBookGrantReadsTheBookAndIsRefusedPastIt`, and this
    /// suite's lesson 3 (once spent by a content read; a wing grant reads its
    /// gatherings) and lesson 4 (the daily Journal's entries and Private
    /// under a wing grant + the open book) truths.
    @Test func lessonSixHowToUseIt() async throws {
        try await withGuideWorld { session, db, guideID in
            #expect(lessons[5] == "how to use it")
            let text = try await prose(db, guideID, lessons[5])
            let ops = session.operations
            let suggest = MCPPaneCopy.rungName(.suggest)
            let writeNew = MCPPaneCopy.rungName(.writeNew)

            // ——— Recipe 1: the design doc (her example, leading) ———
            #expect(text.hasPrefix("Say your notes for a design doc live in a book."))
            #expect(text.contains("Share that book at \(suggest) and ask your AI to go through it"))
            #expect(text.contains("it can leave implementation ideas or tradeoffs as new takes on each block, and "
                                  + "they join the block's takes unchosen, so the page doesn't change until you "
                                  + "choose one."))
            #expect(PostMode.allCases.firstIndex(of: .takes) == 1, "⌘2 is Takes (the mode row's one order)")
            #expect(text.contains("Review them in \(PostMode.takes.rawValue) (\u{2318}2)"))
            let show = try #require(CapabilityRegistry.capability(.showLastAIChange).shortcutLabel)
            #expect(text.contains("\(show) shows the client's last change"))
            let undoChord = try #require(CapabilityRegistry.capability(.structuralUndo).shortcutLabel)
            #expect(text.contains("\(undoChord) takes the latest back, named after the client."))
            // THE TRUTH. A suggest grant on the book reaches its notes at
            // suggest — and never at edit (the page can't be rewritten).
            let design = try ops.createReading(name: "design doc", kind: .book)
            let spec = try note(ops, "Sync runs every minute.", in: design.id)
            _ = try approvedClient(ops, "claude-code", grant(.suggest, .book, design.id))
            #expect(try await db.read { try Queries.mcpNoteSharing($0, noteID: spec) }.map(\.rung) == [.suggest])
            let specFacts = try #require(try await db.read { try Queries.mcpNoteFacts($0, noteID: spec) })
            let suggestGrant = MCPGrantRule.Grant(id: "s", rung: .suggest, scopeKind: .book, scopeID: design.id,
                                                  duration: .always)
            #expect(!MCPGrantRule.decide(client: .approved, grants: [suggestGrant], openBook: false,
                                         target: .note(specFacts), rung: .edit, consumes: true).isAllowed,
                    "suggest can't change a word she wrote")
            // A client's take joins the fan unchosen: the page reads the same.
            let stack = UndoStack()
            let undoable = Operations(undoStack: stack)
            let before = try await db.read { try Queries.renderedText($0, containerID: spec) }
            let block = try #require(try await db.read { try Queries.renderPost($0, containerID: spec).first })
            let idea = try undoable.addTake(
                toBlock: block.blockID, text: "Tradeoff: sync on every edit instead — fresher, chattier.",
                label: nil, undoLabel: Operations.MCPWriteAct.take.undoLabel(client: "claude-code"))
            #expect(try await db.read { try Queries.renderedText($0, containerID: spec) } == before,
                    "the page doesn't change until you choose")
            #expect(try await db.read { try Queries.renderPost($0, containerID: spec).first?.variantID }
                    == block.variantID, "the take joins unchosen")
            #expect(try await db.read { db in
                try String.fetchAll(db, sql: "SELECT id FROM variant WHERE block_id = ? AND status = 'active' "
                                    + "AND deleted_at IS NULL", arguments: [block.blockID])
            }.contains(idea.id), "it is in the block's takes")
            // "⌥⌘Z takes the latest back, named after the client."
            #expect(EditorCommands.undoMenuTitle(for: stack.topLabel) == "Undo claude-code's take")
            #expect(try stack.undo(with: undoable) == Operations.MCPWriteAct.take.undoLabel(client: "claude-code"))
            #expect(try await db.read { try Variant.fetchOne($0, key: idea.id) }?.deletedAt != nil)

            // ——— Recipe 2: the AI inbox ———
            #expect(text.contains("Or make a book just for your AI, even an empty one, and grant it \(writeNew) "
                                  + "on that book alone."))
            #expect(text.contains("It can read what's in that book and add new notes to it; if that is its only "
                                  + "grant and the open book is off, nothing else in your library is readable to it."))
            // THE TRUTH, on an EMPTY book: write new reaches it, a note the
            // client makes there is readable to it, nothing else is.
            let inbox = try ops.createReading(name: "for my AI", kind: .book)
            _ = try approvedClient(ops, "codex", grant(.writeNew, .book, inbox.id))
            let inboxFacts = try #require(try await db.read { try Queries.mcpBookFacts($0, readingID: inbox.id) })
            let inboxGrant = MCPGrantRule.Grant(id: "i", rung: .writeNew, scopeKind: .book, scopeID: inbox.id,
                                                duration: .always)
            #expect(MCPGrantRule.decide(client: .approved, grants: [inboxGrant], openBook: false,
                                        target: .book(inboxFacts), rung: .writeNew, consumes: true).isAllowed,
                    "an empty book takes new notes")
            #expect(try await db.read { try Queries.mcpBookReach($0, readingID: inbox.id) }.map(\.clientName)
                    == ["codex"], "the empty book is readable to it")
            let written = try ops.createNote(
                title: "a client's note", text: "an idea for later", in: .book(inbox.id),
                undoLabel: Operations.MCPWriteAct.note.undoLabel(client: "codex"))
            #expect(try await reachers(db, written.post.id).contains("codex"), "it can read what it wrote there")
            #expect(try await db.read { try Queries.mcpSwitch($0, .openBook) } == false)
            #expect(try await !reachers(db, spec).contains("codex"), "nothing else in the library")
            let loose = try note(ops, "a loose page")
            #expect(try await !reachers(db, loose).contains("codex"))

            // ——— Recipe 3: whole-library help, Private carved out first ———
            #expect(text.contains("For help across everything, grant a whole wing instead: it reaches every note, "
                                  + "book and gathering in the wing except what always asks"))
            #expect(lessons[3] == "what always asks", "the words name lesson 4")
            // VX-197 U8b (A JUSTIFIED EDIT, the ritual — R-13s-22's em dash):
            // the exception is parenthesized now ("…always asks — your daily
            // Journal's … one note." before), so the sentence closes ")".
            #expect(text.contains("except what always asks (your daily Journal's entries and anything marked "
                                  + "Private, which a client reaches only through a grant on that one note)."))
            #expect(text.contains("So mark Private whatever should stay off-limits first, then grant the wing."))
            // THE TRUTH, in the recipe's order: mark first, then the wing.
            let offLimits = try note(ops, "not for any AI")
            _ = try ops.setNotePrivate(offLimits, true)
            _ = try approvedClient(ops, "local-llama", grant(.read, .wing, ""))
            #expect(try await reachers(db, loose).contains("local-llama"), "every note")
            #expect(try await db.read { try Queries.mcpBookReach($0, readingID: design.id) }.map(\.clientName)
                    .contains("local-llama"), "every book")
            let topic = try ops.createTag(name: "ideas")
            let gathering = try ops.createReading(
                name: "every idea", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            let gatheringFacts = try #require(try await db.read {
                try Queries.mcpGatheringFacts($0, readingID: gathering.id)
            })
            let llama = try #require(try await db.read { try Queries.mcpClient($0, name: "local-llama") })
            let llamaGrants = try await db.read { try Queries.mcpGrants($0, clientID: llama.id).map(\.ruleGrant) }
            #expect(MCPGrantRule.decideGathering(client: .approved, grants: llamaGrants, openBook: false,
                                                 gathering: gatheringFacts).isAllowed, "every gathering")
            #expect(try await !reachers(db, offLimits).contains("local-llama"), "Private is carved out")
            // "only through a grant on that one note."
            _ = try ops.grantMCPAccess(llama.id, grant(.read, .note, offLimits, .once))
            #expect(try await reachers(db, offLimits) == ["local-llama"])

            // ——— Recipe 4: the one-off ———
            #expect(text.contains("And for a one-off, right-click a note in the Library, choose "
                                  + "\(MCPShareCopy.shareVerb) and grant \(MCPPaneCopy.rungName(.read)), "
                                  + "\(MCPPaneCopy.durationWord(.once)):"))
            #expect(CapabilityRegistry.capability(.mcpShareHere).verb == MCPShareCopy.shareVerb)
            #expect(text.contains("the client's first read of the note spends the grant, and nothing stands "
                                  + "afterwards."))
            // THE TRUTH: a once note grant reaches; spent by the read (the
            // server's in-transaction stamp), nothing stands.
            let oneOff = try note(ops, "a page to check once")
            let claude = try #require(try await db.read { try Queries.mcpClient($0, name: "claude-code") })
            let onceID = try ops.grantMCPAccess(claude.id, grant(.read, .note, oneOff, .once))
            #expect(try await reachers(db, oneOff).contains("claude-code"))
            try await db.write { try ops.consumeMCPOnceGrant($0, onceID) }
            #expect(try await !reachers(db, oneOff).contains("claude-code"), "nothing stands afterwards")
            #expect(try await db.read { try Queries.mcpGrant($0, id: onceID) }?.ruleGrant.isLive == false,
                    "spent, it reaches nothing more")

            // ——— VX-197 U8b — the recipes beside her four (RED ON OLD) ———
            // Her four lead, unchanged and in her order (above); organization,
            // a revision and a long job follow, in that order.
            let organized = try #require(text.range(of: "Your AI can help keep the library in order, too."))
            let revision = try #require(text.range(of: "For a revision,"))
            let longJob = try #require(text.range(of: "For a long job,"))
            let oneOffRecipe = try #require(text.range(of: "And for a one-off,"))
            #expect(oneOffRecipe.lowerBound < organized.lowerBound && organized.lowerBound < revision.lowerBound
                    && revision.lowerBound < longJob.lowerBound, "her four first, then the three")

            // ——— Recipe 5: organization (the advice's own, D-2) ———
            let organizeRecipe = """
                Grant it \(writeNew) on a wing and ask it to put plans, summaries and research into notes rather \
                than leave them in the chat. It can make a book for a project, give it chapters and file notes into \
                them, tag notes, and make a book that collects every note wearing a tag.
                """
            #expect(text.contains(organizeRecipe))
            #expect(MCPSession.instructions.contains("put plans, summaries and research into notes"),
                    "the advice says the same (U8a)")
            #expect(MCPToolFacts.scopes(of: "create_book") == [.wing], "making a book takes a wing grant")
            #expect(text.contains("A rule it writes moves nothing by itself: notes that already match wait at the "
                                  + "book's \(ArrivalsCopy.word) for you to let in, and notes it tags afterwards join "
                                  + "the way they would if you had tagged them."))
            #expect(MCPBookFacts.matchesWaitWords.contains("undecided matches wait at Arrivals for the author to let in"),
                    "the wire tells the client the same (P-13nb-U4-16)")
            // THE TRUTH, on the wire's own acts: a note she tagged before the
            // rule WAITS at Arrivals; a note the client tags after it JOINS.
            let teaBook = try ops.createReading(name: "tea", kind: .book)
            let tagLabel = Operations.MCPWriteAct.tag.undoLabel(client: "claude-code")
            let hers = try note(ops, "green tea, brewed cooler")
            let teaTag = try ops.createTag(name: "tea")
            try ops.applyTag(teaTag.id, toPost: hers)
            _ = try ops.setBookRule(
                teaBook.id, Operations.MCPBookRuleWrite(rule: .some(RuleTerm.tag("tea"))),
                undoLabel: Operations.MCPWriteAct.bookRule.undoLabel(client: "claude-code"))
            func standing(_ postID: String) async throws -> String? {
                try await db.read { db in
                    try String.fetchOne(
                        db, sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? "
                            + "AND deleted_at IS NULL", arguments: [teaBook.id, postID])
                }
            }
            #expect(try await standing(hers) == "arrival", "a match from before the rule waits for her")
            let theirs = try note(ops, "oolong, three steeps")
            _ = try ops.applyTagPath("tea", toPost: theirs, undoLabel: tagLabel)
            #expect(try await standing(theirs) == "member", "a note tagged afterwards joins")
            let alsoHers = try note(ops, "her own tea note")
            try ops.applyTag(teaTag.id, toPost: alsoHers)
            #expect(try await standing(alsoHers) == "member", "…as hers would")

            // ——— Recipe 6: a revision (VX-311, VX-298) ———
            let compareKey = try #require(PostMode.allCases.firstIndex(of: .compare)) + 1
            let editRung = MCPPaneCopy.rungName(.edit)
            let compareName = PostMode.compare.rawValue
            let revisionRecipe = """
                For a revision, grant \(editRung) on the note's wing and ask your AI to duplicate the note and \
                rewrite the copy. The copy lands in that wing's Pool unless you name a book for it or a book collects its \
                tags, and your original never changes. \
                Because each block of the copy remembers the block it came from, \(compareName) \
                (\u{2318}\(compareKey)) lines the two up row by row.
                """
            #expect(text.contains(revisionRecipe))
            #expect(compareKey == 5)
            #expect(text.contains("Ask your AI to show you the two side by side and, while Variorum is the app in "
                                  + "front, it opens \(PostMode.compare.rawValue) on them."))
            #expect(try tool("duplicate_note").description.contains("Needs read on the note and write new on its wing"))
            #expect(try tool("show_in_app").description.contains("or \"compare\" (note_id + peer_ids"),
                    "the show road has a Compare target (VX-298)")
            // THE TRUTH, on the wire's own act: the copy is bookless, in the
            // note's wing, every block linked to its source, the source unchanged.
            let draftBook = try ops.createReading(name: "drafts", kind: .book)
            let draft = try note(ops, "The first paragraph.", in: draftBook.id)
            _ = try ops.newBlock(in: draft, text: "The second paragraph.", at: .end, registeringUndo: false)
            let read = try await db.read { try Queries.renderedText($0, containerID: draft) }
            let copy = try undoable.duplicateNoteForClient(
                draft, undoLabel: Operations.MCPWriteAct.duplicate.undoLabel(client: "claude-code"))
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                 arguments: [copy.post.id])
            } == 0, "the copy lands in no book")
            #expect(try await db.read { try Queries.effectiveWing($0, ofPost: copy.post.id) }
                    == (try await db.read { try Queries.effectiveWing($0, ofPost: draft) }), "…in the note's wing")
            #expect(copy.blockCopies.count == 2)
            for pair in copy.blockCopies {
                #expect(try await db.read { db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM edge WHERE source_block_id = ? AND "
                                     + "target_block_id = ? AND type = 'derived_from' AND deleted_at IS NULL",
                                     arguments: [pair.copy, pair.source])
                } == 1, "each block of the copy remembers the block it came from")
            }
            #expect(try await db.read { try Queries.renderedText($0, containerID: draft) } == read,
                    "your original never changes")

            // ——— Recipe 7: a long job (VX-256, VX-254, VX-261) — no numbers ———
            let longJobRecipe = """
                For a long job, like translating a whole book, ask your AI to check its work as it goes. It can \
                read a long note a page at a time instead of all at once. Most writes that add or rewrite words \
                answer with a fingerprint of exactly what was stored (a sha256), so it can confirm every word \
                landed as it sent it. And if the connection drops partway through, it can look back over its own \
                recent acts to see which ones landed before it carries on.
                """
            #expect(text.contains(longJobRecipe))
            let longJobText = String(text[longJob.lowerBound...]).replacingOccurrences(of: "sha256", with: "")
            #expect(longJobText.range(of: #"[0-9]"#, options: .regularExpression) == nil,
                    "P-VX256-1 is PROVISIONAL: no page number is promised (sha256's own digits aside)")
            #expect(try tool("read_note").description.contains("Big notes read in pages"))
            // "Most": these answer a digest, and divide and merge do not.
            for name in ["add_take", "add_takes", "create_note", "import_document", "insert_blocks",
                         "duplicate_note", "edit_take", "restore_commit"] {
                #expect(try tool(name).description.contains(MCPToolCatalog.digestSentence), "\(name) answers sha256")
            }
            for name in ["divide_block", "merge_blocks"] {
                #expect(try !tool(name).description.contains("sha256"), "\(name) answers none — so \u{201C}most\u{201D}")
            }
            #expect(try tool("list_my_activity").description.contains("Use it after a dropped call or a lost context "
                                                                       + "to learn whether a call landed"))
        }
    }

    // MARK: - Lesson 7 — seeing, answering, undoing

    /// 13n-c U6 JOB 4 (A JUSTIFIED EDIT, the ritual): lesson six → seven, the
    /// index and the name follow her ruled lesson's seat.
    @Test func lessonSevenSeeingAnsweringUndoing() async throws {
        try await withGuideWorld { session, db, guideID in
            let text = try await prose(db, guideID, lessons[6])
            // VX-197 U8b (A JUSTIFIED EDIT, the ritual — VX-184 U2's carry,
            // VX-185): a gathering wears the icon on the Bookcase too ("a small
            // icon beside a book means…" before).
            #expect(text.contains("On the Bookcase, a small icon beside a book or a gathering means a client can "
                                  + "reach it."))
            // VX-197 U8b — THE ICON'S ROWS AS BUILT (VX-268 at VX-281; VX-330
            // at VX-336 U6b; the ⌘L sheet): every host renders the one icon
            // and declares its acts (`MCPSharedRowsRulesTests`' hosts), and a
            // book panel chapter that IS its one note wears that note's icon
            // (`BookPanelMCPMarksTests`). RED ON OLD: "the guide still says
            // Bookcase only".
            let wingChord = try #require(CapabilityRegistry.capability(.switchWing).shortcutLabel)
            let iconRows = """
                The same icon shows on notes, books and gatherings in the Library, on notes in the Pool, on the \
                notes listed in the panel that shows a note's book, and on wings in the switcher that \(wingChord) \
                opens. In that panel, a chapter that shares a row with its only note wears the note's icon.
                """
            #expect(text.contains(iconRows))
            for (host, declared) in [("Library", LibraryCatalogView.surfaceCapabilities),
                                     ("Pool", PoolPostsView.surfaceCapabilities),
                                     ("the book panel", BookPanelView.surfaceCapabilities),
                                     ("the wing switcher", WingSwitcherSheet.surfaceCapabilities),
                                     ("Bookcase", ShelfView.surfaceCapabilities)] {
                #expect(declared.contains(.mcpShowSharing), "\(host) renders the shared icon")
            }
            let stamp = Date(timeIntervalSince1970: 1_782_864_000)
            let chapter = ReadingSection(id: "s", readingId: "b", name: "The Red-Headed League", position: "a",
                                         createdAt: stamp, updatedAt: stamp)
            let story = Queries.ReadingEntry(postID: "p", title: "The Red-Headed League", entryDate: nil,
                                             sectionPath: nil)
            #expect(BookPanelBrain.markedNote(.chapter(chapter, collapsed: story)) == "p",
                    "a chapter sharing a row with its one note wears that note's icon")
            #expect(text.contains("(through the Home wing grant, say)"))
            #expect(text.contains("with \(MCPShareCopy.change) and \(MCPShareCopy.revoke)"))
            #expect(text.contains("the right end of the context bar above the page, or a lock when the note is Private"))
            // Stage B R1 B10: Activity is coarse and capped (the store keeps the
            // newest `mcpActivityCap` lines), so the lesson says "recently",
            // never "every call".
            #expect(text.contains("under \(MCPPaneCopy.activitySection), the calls clients made recently"))
            #expect(!text.contains("every call"))
            #expect(Operations.mcpActivityCap == 500, "the log is capped — 'recently' is the true word")
            // Stage B R2-5 (B10's class, on the pane): the empty Activity line
            // says the same — never "every call".
            #expect(MCPPaneCopy.noActivity.contains("the calls clients made recently"), "the pane says the same")
            #expect(!MCPPaneCopy.noActivity.contains("every call"))
            // VX-197 U8b — VX-261: a client reads its OWN recent acts, and
            // Activity says so in the pane's own words (P-VX261-2). RED ON OLD.
            let checked = MCPPaneCopy.activityLine(MCPActivityFace.Line(
                id: 1, clientName: placeholderName, act: "list_my_activity", targetKind: nil, targetID: nil,
                targetTitle: nil, allowed: true, count: 1, at: "2026-10-14T00:00:00.000Z"))
            #expect(checked == "\(placeholderName) checked its recent activity")
            #expect(text.contains("A client can look back over its own recent acts as well, which is how it learns "
                                  + "whether a call landed after a dropped connection; Activity then says "
                                  + "\u{201C}\(checked)\u{201D}."))
            // Answering — the ask's own buttons and Waiting's own name.
            #expect(text.contains("nothing pops up and nothing interrupts you"))
            #expect(text.contains("a small mark appears beside the place it names"))
            #expect(text.contains("under \(MCPPaneCopy.waitingSection) in Settings \u{25B8} MCP"))
            let settingsChord = try #require(CapabilityRegistry.capability(.mcpSettings).shortcutLabel)
            #expect(text.contains("which \(settingsChord) opens"))
            let answers = [MCPGrantRule.Duration.once, .connection, .always].map(MCPAskCopy.button)
            #expect(text.contains("\(answers[0]), \(answers[1]) or \(answers[2]), whichever fit, or \(MCPAskCopy.dontAllow)"))
            // Undoing — the receipt's door, ⌥⌘O, the client-named undo.
            #expect(text.contains("with \(MCPReceiptCopy.openDoor) to go and look"))
            #expect(text.contains("unless \(ReceiptStyleCopy.title) is off, in Settings \u{25B8} \(SettingsPane.general.title)"))
            let show = CapabilityRegistry.capability(.showLastAIChange)
            #expect(text.contains("\(try #require(show.shortcutLabel)) (\(show.verb), in the Edit menu)"))
            let undo = EditorCommands.undoMenuTitle(
                for: Operations.MCPWriteAct.take.undoLabel(client: "claude-code"))
            #expect(undo == "Undo claude-code's take")
            // 13n-c O-4 (A JUSTIFIED EDIT, the ritual — her ask: no provider
            // hardwired outside the setup): the lesson quotes the menu's words
            // over a PLACEHOLDER name, composed by the menu's own functions —
            // the real client's title above is the same shape.
            let placeholder = EditorCommands.undoMenuTitle(
                for: Operations.MCPWriteAct.take.undoLabel(client: "\u{2039}name\u{203A}"))
            #expect(text.contains("the Edit menu names it after the client: \(placeholder)."))
            #expect(!text.localizedCaseInsensitiveContains("claude"))
            #expect(text.contains("only while Variorum is the app in front; it never brings a window forward"))
            // VX-197 U8b — Compare from the wire (VX-298) and link_versions'
            // receipt (VX-187 at VX-336 U6a): both land in Compare. The landing
            // itself is U6a's `MCPCompareLandingTests` (the Mac batch). RED ON OLD.
            #expect(text.contains("when it links two notes as versions, \(MCPReceiptCopy.openDoor) shows them side by "
                                  + "side in \(PostMode.compare.rawValue)."))
            #expect(try tool("link_versions").description.contains("opens the two side by side in Compare"))
            #expect(text.contains("Asked to show you a note beside another, it opens \(PostMode.compare.rawValue) "
                                  + "with them side by side."))
            #expect(try tool("show_in_app").description.contains("Variorum's Compare with note_id first and each peer "
                                                                  + "beside it"))

            // THE TRUTH — the icon and its why: a book reached through the Home
            // wing grant says so, through the popover's own words.
            let ops = session.operations
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            _ = try note(ops, "a chapter", in: book.id)
            _ = try approvedClient(ops, "claude-code", grant(.read, .wing, ""))
            let reach = try #require(try await db.read { try Queries.mcpBookReach($0, readingID: book.id) }.first)
            #expect(MCPShareCopy.why(reach) == "through the Home wing grant")
            let iconBooks = try await db.read { try Queries.mcpBookReaches($0) }
            #expect(iconBooks[book.id] != nil, "the Bookcase's icon set holds the book")
            // "⌥⌘Z takes a client's act back … the Edit menu names it": a
            // client's take lands as ONE undo entry carrying its name.
            let stack = UndoStack()
            let undoable = Operations(undoStack: stack)
            let target = try note(ops, "a line a client suggests beside")
            let block = try #require(try await db.read { try Queries.renderPost($0, containerID: target).first })
            _ = try undoable.addTake(
                toBlock: block.blockID, text: "a client's line", label: nil,
                undoLabel: Operations.MCPWriteAct.take.undoLabel(client: "claude-code"))
            #expect(EditorCommands.undoMenuTitle(for: stack.topLabel) == undo)
        }
    }
}
