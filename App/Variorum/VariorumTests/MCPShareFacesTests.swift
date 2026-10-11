//
//  MCPShareFacesTests.swift
//  VariorumTests (Mac)
//
//  13n-c U3 — GRANT FROM WHERE YOU ARE (VX-156 items 2/3; R-AIR-4/6/7/8;
//  VX-164): the road's two gates (an approved client; the server ON) read off
//  the door's narrow observables; the place-door sheet's bulk act landing as
//  ONE act with its receipt and its two doors (Change… replaces, Revoke ›
//  covers the act); ⌥⌘A's three outcomes (with history, without, already
//  reaching — never always); the pane's one row per act; the pure gates of
//  every door (no approved client ⇒ no door; never a door the op refuses);
//  the icon's and the indicator's words and states; ⌥⌘A's registry facts.
//  A ruled BUILD — the walk (or, while the session is locked, the gated
//  capture harness `MCPShareFacesCaptureTests`) shows the faces.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 53))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// Wait (bounded) for a condition an async act or observation settles.
@MainActor
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<300 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// Every grant row ever written, in insertion order (revoked ones included).
@MainActor
private func liveGrants(_ db: AppDatabase) throws -> [MCPGrantRow] {
    try db.read { db in
        try Row.fetchAll(db, sql: "SELECT * FROM mcp_grant ORDER BY rowid").compactMap { row in
            guard let rung = MCPGrantRule.Rung(rawValue: row["rung"]),
                  let kind = MCPGrantRule.ScopeKind(rawValue: row["scope_kind"]),
                  let duration = MCPGrantRule.Duration(rawValue: row["duration"]) else { return nil }
            return MCPGrantRow(
                id: row["id"], clientID: row["client_id"], rung: rung, scopeKind: kind,
                scopeID: row["scope_id"], duration: duration, createdAt: row["created_at"],
                consumedAt: row["consumed_at"], revokedAt: row["revoked_at"])
        }
    }
}

@MainActor
@Suite("13n-c U3 — grant from where you are: the road, the doors, ⌥⌘A, the icon, the indicator", .serialized)
struct MCPShareFacesTests {
    private func approved(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2")
        try ops.approveMCPClient(client.id, granting: nil)
        return MCPClient(
            id: client.id, name: client.name, version: client.version, state: .approved,
            firstSeenAt: client.firstSeenAt, lastSeenAt: client.lastSeenAt, decidedAt: nil)
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        _ = try ops.newBlock(in: post.id, text: "\(title) text", registeringUndo: false)
        return post
    }

    // MARK: - The road's gates (R-AIR-8, R-AIR-7)

    @Test func theGatesFollowAnApprovedClientAndTheServerSwitch() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(try await settle { door.snapshot.approvedCount == 0 })
            #expect(!door.hasApprovedClient && !door.serverOn, "no client, no server — no share face at all")
            let pending = try session.operations.recordMCPContact(name: "codex", version: nil)
            try await Task.sleep(for: .milliseconds(80))
            #expect(!door.hasApprovedClient, "a PENDING request is not an approved client (R-AIR-8)")
            try session.operations.approveMCPClient(pending.id, granting: nil)
            #expect(try await settle { door.hasApprovedClient })
            try session.operations.setMCPSwitch(.server, on: true)
            #expect(try await settle { door.serverOn })
            try session.operations.denyMCPClient(pending.id)
            #expect(try await settle { !door.hasApprovedClient }, "the last approved client denied — the faces go")
            door.detach()
            #expect(!door.hasApprovedClient, "a locked library shows no share face")
        }
    }

    // MARK: - The place-door sheet's act and its receipt

    @Test func aBulkShareLandsAsOneActAndItsReceiptCarriesChangeAndRevoke() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let client = try approved(ops)
            let notes = try ["parser notes", "grammar sketch", "morning pages"].map { try note(ops, $0) }
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            session.status.receiptStyle = .quiet
            var reopened: MCPGrantOpening?
            door.grantNotes(
                client, notes.map(\.id), rung: .read, duration: .once, replacing: [],
                saying: MCPShareCopy.notesCount(3), change: { reopened = $0 })
            #expect(try await settle { session.status.spoken != nil })
            let rows = try liveGrants(db)
            #expect(rows.count == 3 && Set(rows.map(\.createdAt)).count == 1, "ONE act, one stamp")
            let spoken = try #require(session.status.spoken)
            #expect(spoken.text == "Shared 3 notes with claude-code \u{2014} read, once.")
            #expect(spoken.kind == .receipt, "a share is a RECEIPT (her setting governs it)")
            #expect(spoken.action?.label == "Revoke \u{203A}" && spoken.secondary?.label == "Change\u{2026}")
            #expect(try await settle { door.snapshot.sharedGroups.count == 1 })
            #expect(door.snapshot.sharedGroups.first?.memberCount == 3, "the pane shows ONE row for the act")

            // Change… re-opens the sheet on exactly what landed.
            spoken.secondary?.perform()
            let opening = try #require(reopened)
            #expect(opening.client?.id == client.id && opening.place == .notes(notes.map(\.id)))
            #expect(opening.rung == .read && opening.duration == .once && opening.origin == .place)
            #expect(opening.replacing == rows.map(\.id), "confirming REPLACES the act (T-U3-8)")

            // Revoke › covers the whole act.
            spoken.action?.perform()
            #expect(try await settle { (try? liveGrants(db))?.allSatisfy { $0.revokedAt != nil } == true })
            #expect(try await settle { session.status.spoken?.text == MCPShareCopy.revoked })
        }
    }

    @Test func changeFromTheReceiptReplacesTheGrantAndSaysChanged() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let client = try approved(ops)
            let parser = try note(ops, "parser notes")
            let old = try ops.grantMCPAccess(
                client.id, .init(rung: .edit, scopeKind: .note, scopeID: parser.id, duration: .always))
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            session.status.receiptStyle = .quiet
            door.grant(
                client, .init(rung: .read, scopeKind: .note, scopeID: parser.id, duration: .once),
                replacing: [old], saying: MCPShareCopy.quoted("parser notes"), change: { _ in })
            #expect(try await settle { session.status.spoken != nil })
            #expect(session.status.spoken?.text == "Changed \u{201C}parser notes\u{201D} for claude-code \u{2014} read, once.")
            let rows = try liveGrants(db)
            #expect(rows.first { $0.id == old }?.revokedAt != nil, "the lowered rung lands — the old grant is gone")
            #expect(rows.filter { $0.revokedAt == nil }.map(\.rung) == [.read])
        }
    }

    @Test func aPlaceDoorRefusalSpeaksOnTheWindowAndWritesNothing() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let client = try approved(ops)
            let open = try note(ops, "open")
            let secret = try note(ops, "secret")
            _ = try ops.setNotePrivate(secret.id, true)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.grantNotes(
                client, [open.id, secret.id], rung: .read, duration: .always, replacing: [],
                saying: MCPShareCopy.notesCount(2), change: nil)
            #expect(try await settle { session.status.spoken != nil })
            #expect(session.status.spoken?.kind == .refusal)
            #expect(session.status.spoken?.text == MCPPaneCopy.refusal(
                OperationError.mcpGrantScopeFenced(kind: "note", id: secret.id)))
            #expect(try liveGrants(db).isEmpty)
        }
    }

    // MARK: - ⌥⌘A (the brief §4, D1)

    @Test func theChordOpensTheSheetGrantsTheNewestAndRefusesWhenAlreadyReaching() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let client = try approved(ops)
            let parser = try note(ops, "parser notes")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            session.status.receiptStyle = .quiet
            var sheet: MCPGrantOpening?

            // No history ⇒ the deliberate road: THE sheet, WHERE = this note, WHO asked.
            await door.shareThisNote(parser.id) { sheet = $0 }
            #expect(sheet?.place == .note(parser.id) && sheet?.client == nil && sheet?.origin == .place)
            #expect(try liveGrants(db).isEmpty, "nothing guessed, nothing written")

            // History: her last grant was suggest (on a book) — the chord grants suggest, ONCE (not connected).
            let book = try ops.createReading(name: "a book", kind: .book)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .suggest, scopeKind: .book, scopeID: book.id, duration: .always))
            sheet = nil
            await door.shareThisNote(parser.id) { sheet = $0 }
            #expect(sheet == nil)
            let minted = try #require(try liveGrants(db).last)
            #expect(minted.scopeKind == .note && minted.scopeID == parser.id)
            #expect(minted.rung == .suggest && minted.duration == .once, "never always by a key")
            #expect(session.status.spoken?.text
                    == "Shared \u{201C}parser notes\u{201D} with claude-code \u{2014} read and suggest, once.")
            #expect(session.status.spoken?.action?.label == "Revoke \u{203A}"
                    && session.status.spoken?.secondary?.label == "Change\u{2026}", "R-AIR-4's door")

            // Already reaching at that rung ⇒ the refusal, nothing written.
            let before = try liveGrants(db).count
            await door.shareThisNote(parser.id) { sheet = $0 }
            #expect(session.status.spoken?.kind == .refusal)
            #expect(session.status.spoken?.text == "claude-code already reaches this note (read and suggest).")
            #expect(try liveGrants(db).count == before)

            // Connected now ⇒ while connected.
            let other = try note(ops, "grammar sketch")
            #expect(try await settle { door.snapshot.approvedCount == 1 })
            door.previewConnected(["claude-code"])
            await door.shareThisNote(other.id) { sheet = $0 }
            #expect(try liveGrants(db).last?.duration == .connection)
        }
    }

    @Test func theChordIsAPostActOnTheMenuWithItsKeyAndItsHelperRow() {
        let chord = CapabilityRegistry.capability(.mcpShareThisNote)
        #expect(chord.verb == "Share This Note with AI" && chord.shortcutLabel == "\u{2325}\u{2318}A")
        #expect(chord.doors == [.menuBar])
        #expect(chord.availability(CapabilityContext()) == .unavailable, "no note open — grey")
        #expect(chord.availability(CapabilityContext(mode: .write)) == .act)
        #expect(chord.availability(CapabilityContext(mode: .takes)) == .act, "natively in Takes (R118)")
        #expect(EditorCommands.keyEquivalent(for: .mcpShareThisNote)?.0 == "a")
        #expect(EditorCommands.keyEquivalent(for: .mcpShareThisNote)?.1 == [.command, .option])
        #expect(EditorCommands.menuRendered.contains(.mcpShareThisNote))
        #expect(HelperView.shortcutKeysShown.contains("\u{2325}\u{2318}A"))
    }

    // MARK: - The pure gates: no approved client ⇒ no door; never a door the op refuses

    @Test func theBookRowMenuDrawsShareOnlyOnAShareableBook() {
        let book = Reading(
            id: "b", name: "the lightning thief", kind: .book,
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
        var gathering = book
        gathering.kind = .gathering
        #expect(!BookRowMenuTable.doors(for: book).contains(.share), "no approved client ⇒ no door")
        #expect(BookRowMenuTable.doors(for: book, shareable: true).contains(.share))
        #expect(!BookRowMenuTable.doors(for: gathering, shareable: true).contains(.share),
                "a gathering is never a grant target (R-AIR-12)")
        #expect(!BookRowMenuTable.doors(for: nil, shareable: true).contains(.share), "facts unknown ⇒ not drawn")
        let doors = BookRowMenuTable.doors(for: book, shareable: true)
        #expect(doors.firstIndex(of: .share)! > doors.firstIndex(of: .exportPDF)!, "after the exports (mockup §2)")
    }

    @Test func theBookSettingsGrantRowDrawsOnlyWhereAGrantCanLand() {
        var book = Reading(
            id: "b", name: "dream journal", kind: .book,
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
        #expect(BookSettingsFace.showsGrantRow(for: book, isPrivate: false, canShare: true))
        #expect(!BookSettingsFace.showsGrantRow(for: book, isPrivate: false, canShare: false), "R-AIR-8")
        #expect(!BookSettingsFace.showsGrantRow(for: book, isPrivate: true, canShare: true), "the fence (P-2)")
        book.profile = Queries.journalTraitProfile
        #expect(BookSettingsFace.showsGrantRow(for: book, isPrivate: false, canShare: true),
                "a journal-TRAIT book takes grants (R-AIR-1)")
        book.profile = Queries.dailyJournalBookProfile
        #expect(!BookSettingsFace.showsGrantRow(for: book, isPrivate: false, canShare: true), "THE daily Journal")
        book.profile = nil
        book.kind = .gathering
        #expect(!BookSettingsFace.showsGrantRow(for: book, isPrivate: false, canShare: true))
    }

    @Test func theFencedBooksAreExactlyTheOnesTheSheetNeverOffers() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let plain = try ops.createReading(name: "plain", kind: .book)
            let privateBook = try ops.createReading(name: "private", kind: .book)
            _ = try ops.setBookPrivate(privateBook.id, true)
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            let gathering = try ops.createReading(
                name: "a gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let fenced = try await db.read { try Queries.mcpFencedBookIDs($0) }
            let offered = Set(try await db.read { try Queries.mcpGrantableBooks($0) }.map(\.id))
            #expect(fenced == [privateBook.id])
            #expect(offered == [plain.id, trait.id])
            #expect(fenced.isDisjoint(with: offered) && !fenced.contains(gathering.id))
        }
    }

    // MARK: - The words (app voice on menus and receipts; no "AI" in settings-class faces)

    @Test func theShareFacesSayTheMockupsWords() {
        #expect(MCPShareCopy.shareVerb == "Share with AI\u{2026}", "mockup §2's row menu")
        #expect(MCPShareCopy.shareNotes(3) == "Share 3 notes with AI\u{2026}", "mockup §2's bulk bar")
        #expect(MCPShareCopy.shared(place: "\u{201C}parser notes\u{201D}", client: "claude-code",
                                    rung: .suggest, duration: .connection)
                == "Shared \u{201C}parser notes\u{201D} with claude-code \u{2014} read and suggest, while connected.",
                "mockup §3's receipt, verbatim")
        #expect(MCPShareCopy.alreadyReaches("claude-code", .suggest)
                == "claude-code already reaches this note (read and suggest).", "mockup §3's refusal, verbatim")
        #expect(MCPPaneCopy.confirmPartsForNotes(verb: "Grant", rung: .read, count: 3, duration: .connection)
                == ("Grant read on ", "3 notes", " while connected"), "mockup §2's confirm")
        #expect(MCPPaneCopy.alwaysWithheldAmong([.journal])
                == "Always isn't offered: 1 of these notes is a daily Journal entry, which is only ever "
                    + "shared one ask at a time.", "mockup §2's why, verbatim")
        #expect(MCPPaneCopy.alwaysWithheldAmong([.privateMark, .journal]).hasPrefix(
            "Always isn't offered: 2 of these notes are Private or daily Journal entries"))
        #expect(MCPPaneCopy.theseNotes(3) == "These 3 notes")
        #expect(MCPPaneCopy.notesList(["a", "b", "c", "d", "e"]) == "a \u{00B7} b \u{00B7} c and 2 more")
        #expect(MCPPaneCopy.groupMembers(["a", nil, "c"], total: 7) == "a \u{00B7} (gone) \u{00B7} c and 4 more")
        #expect(MCPPaneCopy.sheetTitle(client: "claude-code", changing: true) == "Change access \u{2014} claude-code")
        #expect(MCPPaneCopy.sheetTitle(client: nil, changing: false) == MCPPaneCopy.sheetTitleChoosing)
        // R-AIR-8: the settings-class faces carry no "AI".
        for words in [MCPShareCopy.sharedWithLabel, MCPShareCopy.notShared, MCPShareCopy.shareButton,
                      MCPShareCopy.popoverTitle, MCPShareCopy.openBookNote, MCPShareCopy.zeroState,
                      MCPShareCopy.lockHelp, MCPPaneCopy.groupInert(2), MCPPaneCopy.groupChip] {
            #expect(!words.split(whereSeparator: { !$0.isLetter }).contains("AI"), "\(words)")
        }
    }

    @Test func theWhySaysTheWiderPlaceAndChangeNamesTheGrantsOwnPlace() throws {
        let client = MCPClient(
            id: "c", name: "claude-code", version: nil, state: .approved,
            firstSeenAt: "", lastSeenAt: "", decidedAt: nil)
        func grant(_ kind: MCPGrantRule.ScopeKind, _ id: String) -> MCPGrantRow {
            MCPGrantRow(id: "g-\(kind.rawValue)", clientID: "c", rung: .suggest, scopeKind: kind, scopeID: id,
                        duration: .connection, createdAt: "", consumedAt: nil, revokedAt: nil)
        }
        let viaWing = MCPPlaceReach(client: client, rung: .suggest, grant: grant(.wing, ""), throughTitle: "Home")
        let viaBook = MCPPlaceReach(
            client: client, rung: .suggest, grant: grant(.book, "b"), throughTitle: "the lightning thief")
        let own = MCPPlaceReach(client: client, rung: .suggest, grant: grant(.note, "n"), throughTitle: nil)
        let open = MCPPlaceReach(client: client, rung: .read, grant: nil, throughTitle: nil)
        #expect(MCPShareCopy.why(viaWing) == "through the Home wing grant", "R-AIR-7's words")
        #expect(MCPShareCopy.why(viaBook) == "through \u{201C}the lightning thief\u{201D}")
        #expect(MCPShareCopy.why(own) == nil, "the place's own grant needs no why")
        #expect(MCPShareCopy.why(open) == "through the open book")
        #expect(MCPShareCopy.reachLine(viaWing) == "read and suggest \u{00B7} while connected")
        #expect(MCPShareCopy.iconHelp([viaWing])
                == "Shared with claude-code (read and suggest) \u{2014} click for details")
        let change = MCPReachPopover.changeOpening(client, try #require(viaWing.grant))
        #expect(change.place == .wing("") && change.replacing == ["g-wing"])
        #expect(change.rung == .suggest && change.duration == .connection && change.client?.id == "c")
    }

    // MARK: - The in-note indicator's state (VX-164)

    @Test func theIndicatorSaysOnlyWhatIsTrue() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let plain = try note(ops, "plain")
            #expect(try await db.read { try MCPNoteIndicatorState.read($0, postID: plain.id) }.isEmpty,
                    "nothing to say ⇒ nothing drawn (calm)")
            let client = try approved(ops)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            let shared = try await db.read { try MCPNoteIndicatorState.read($0, postID: plain.id) }
            #expect(shared.reach.map(\.clientName) == ["claude-code"] && !shared.isPrivate)
            #expect(shared.reach.first.flatMap(MCPShareCopy.why) == "through the Home wing grant")

            _ = try ops.setNotePrivate(plain.id, true)
            let locked = try await db.read { try MCPNoteIndicatorState.read($0, postID: plain.id) }
            #expect(locked.ownPrivate && locked.reach.isEmpty, "Private: the lock, and the wing no longer reaches")

            let inBook = try note(ops, "kept close")
            let privateBook = try ops.createReading(name: "diary", kind: .book)
            _ = try ops.addPostToReading(inBook.id, to: privateBook.id)
            _ = try ops.setBookPrivate(privateBook.id, true)
            let through = try await db.read { try MCPNoteIndicatorState.read($0, postID: inBook.id) }
            #expect(!through.ownPrivate && through.privateBooks == ["diary"] && through.isPrivate)
            #expect(MCPNoteIndicatorState.matching(through, postID: plain.id) == nil, "a stale read never draws")
        }
    }

    @Test func theIconsGlyphIsTheMCPPanesOwnAndItsPendingTwinExists() {
        #expect(MCPSharedIcon.symbol == SettingsPane.mcp.symbol, "the permission's home, pictured")
        #expect(NSImage(systemSymbolName: MCPSharedIcon.symbol, accessibilityDescription: nil) != nil)
        #expect(NSImage(systemSymbolName: MCPSharedIcon.pendingSymbol, accessibilityDescription: nil) != nil)
    }
}
