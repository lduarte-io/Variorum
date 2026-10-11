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

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
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

// MARK: - The chapter

@MainActor
@Suite("Tutorial contract — AI & the MCP door (13n-c U5)")
struct TutorialMCPChapterTests {

    /// Six lessons, the guide's appendix after the privacy chapter (P-13nc-U5-1),
    /// every lesson seeded under it. Three guards over the WHOLE chapter: no
    /// gathering promise before U6 (R-AIR-12) lands; the pending mark by its
    /// ROLE, never its shape (O-1 may change the glyph); the app's vocabulary
    /// (commit, never savepoint) and no shouted word.
    @Test func theChapterIsSixLessonsAndTheGuidesAppendix() async throws {
        #expect(TutorialSeeder.plan.last?.chapter == TutorialSeeder.mcpChapter)
        #expect(TutorialSeeder.plan.last?.lessons == lessons)
        #expect(lessons.count == 6)
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
                #expect(!text.localizedCaseInsensitiveContains("gathering"),
                        "\(title): gatherings under a wing grant are U6's to teach (R-AIR-12)")
                #expect(!text.localizedCaseInsensitiveContains("filled"),
                        "\(title): the pending mark is taught by its role, never its shape")
                #expect(!text.localizedCaseInsensitiveContains("savepoint"))
                #expect(text.range(of: #"\b(?!MCP\b|JSON\b)[A-Z]{3,}\b"#, options: .regularExpression) == nil,
                        "\(title): no shouted word")
            }
        }
    }

    // MARK: - Lesson 1 — what the door is

    @Test func lessonOneTheDoorIsShutUntilYouOpenIt() async throws {
        try await withGuideWorld { _, db, guideID in
            let text = try await prose(db, guideID, lessons[0])
            #expect(text.contains("MCP, the Model Context Protocol"))
            #expect(text.contains("it stays shut until you open it"))
            #expect(text.contains("the phone has no door"))
            // The doors, by their own words.
            #expect(text.contains("Settings \u{25B8} \(SettingsPane.mcp.title)"))
            #expect(text.contains(MCPPaneCopy.enableTitle), "the switch, by its own title")
            let chord = try #require(CapabilityRegistry.capability(.mcpSettings).shortcutLabel)
            #expect(text.contains("(\(chord) takes you there)"), "⌥⌘, by the registry's own label")
            #expect(text.contains("comes back out with \u{2325}\u{2318}Z"))

            // THE TRUTH. "it stays shut until you open it" — the switch and the
            // open book are both OFF on a fresh store.
            let (server, openBook) = try await db.read { db in
                (try Queries.mcpSwitch(db, .server), try Queries.mcpSwitch(db, .openBook))
            }
            #expect(!server && !openBook)
            // "grants never sync to your other devices" — the grants family is
            // outside the sync registry entirely.
            #expect(text.contains("grants never sync to your other devices"))
            for table in MCPGrantSchema.tables {
                #expect(SyncSchema.table(named: table) == nil, "\(table) never syncs")
            }
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
            #expect(text.contains("press \(CapabilityRegistry.capability(.mcpCopySetupCommand).verb)"))
            #expect(text.contains("a few lines of JSON"))
            #expect(MCPSetupClient.anyClient.text(shimPath: "/x", isDebugBuild: false).contains("\"mcpServers\""))
            #expect(MCPSetupClient.claudeCode.text(shimPath: "/x", isDebugBuild: false).hasPrefix("claude mcp add"))
            #expect(MCPSetupClient.codex.text(shimPath: "/x", isDebugBuild: false).hasPrefix("codex mcp add"))
            #expect(text.contains("the door is a standard MCP server: one program inside the app"))
            #expect(MCPPaneCopy.stdioLine.contains("standard MCP server")
                && MCPPaneCopy.stdioLine.contains("one program"), "the pane says the same")
            #expect(text.contains("as a connection request"))
            #expect(MCPPaneCopy.requestsSection == "Connection requests")
            for id in [CapabilityID.mcpApproveClient, .mcpDenyClient, .mcpChangeClientAccess, .mcpRevokeClient] {
                #expect(text.contains(CapabilityRegistry.capability(id).verb), "\(id)'s verb")
            }
            #expect(text.contains("Variorum can't check that name"))
            #expect(MCPPaneCopy.clientBoundary.contains("can't verify the name"), "L1 says the same")

            // THE TRUTH. "it can reach nothing yet": a connection request is
            // refused by the one rule, even with the open book on.
            let ops = session.operations
            let page = try note(ops, "a page anyone could read")
            try ops.setMCPSwitch(.openBook, on: true)
            let pending = try ops.recordMCPContact(name: "claude-code", version: "1.0")
            #expect(pending.state == .pending)
            #expect(try await reachers(db, page).isEmpty, "a request reaches nothing")
            // "Approve… lets it in and asks what to share first."
            _ = try ops.approveMCPClient(pending.id, granting: grant(.read, .note, page))
            #expect(try await reachers(db, page) == ["claude-code"])
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
            #expect(text.contains("commits the take just before and just after"))
            let bracket = Operations.mcpEditCommitNames(client: "claude-code")
            #expect(bracket.before.hasPrefix("before") && bracket.after.hasPrefix("after"))
            // Where, and how long — the durations by their own words.
            #expect(text.contains("one note; one book, with its notes now and any added to it later; or a whole wing"))
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
            // "one switch … lets every approved client read everything": with
            // the open book on, a client holding NO grant reads the loose page.
            _ = try approvedClient(ops, "local-llama", nil)
            #expect(!(try await reachers(db, loose)).contains("local-llama"))
            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try await reachers(db, loose).contains("local-llama"))
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
            #expect(text.contains("An entry \u{2318}J made keeps asking even if you later file it in another book."))
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
            // "An entry ⌘J made keeps asking even if you later file it in another book."
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
            #expect(text.contains("Once a client is approved"), "the doors render only then (R-AIR-8)")
            #expect(text.contains("choose \(MCPShareCopy.shareVerb)"))
            #expect(CapabilityRegistry.capability(.mcpShareHere).verb == MCPShareCopy.shareVerb)
            #expect(text.contains(MCPShareCopy.shareNotes(3)), "the bulk door, by its own words")
            #expect(LibraryCatalogView.surfaceCapabilities.contains(.mcpShareNotes), "…on the Library")
            #expect(text.contains("with \(MCPShareCopy.shareButton) beside"))
            let share = CapabilityRegistry.capability(.mcpShareThisNote)
            #expect(text.contains("\(try #require(share.shortcutLabel)) (Edit \u{25B8} \(share.verb))"))
            #expect(text.contains("until it disconnects if it's connected, otherwise once, never always"))
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

    // MARK: - Lesson 6 — seeing, answering, undoing

    @Test func lessonSixSeeingAnsweringUndoing() async throws {
        try await withGuideWorld { session, db, guideID in
            let text = try await prose(db, guideID, lessons[5])
            #expect(text.contains("a small icon beside a book means a client can reach it"))
            #expect(text.contains("(through the Home wing grant, say)"))
            #expect(text.contains("with \(MCPShareCopy.change) and \(MCPShareCopy.revoke)"))
            #expect(text.contains("the right end of the context bar above the page, or a lock when the note is Private"))
            #expect(text.contains("under \(MCPPaneCopy.activitySection), every call a client made"))
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
            #expect(text.contains("the Edit menu names it: \(undo)."))
            #expect(text.contains("only while Variorum is the app in front; it never brings a window forward"))

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
