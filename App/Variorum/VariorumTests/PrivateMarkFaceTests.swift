//
//  PrivateMarkFaceTests.swift
//  VariorumTests
//
//  VX-831 — THE VISIBLE PRIVATE MARK (the closed eye with lashes, option A —
//  hers): the rule's three states (own · via a book · none), the badge
//  family's switch, the words (the via-book hover is hers: "Private — via
//  ‹book›"), the door's two arms through the real operations (own: un-private,
//  no confirm, the Private rows' receipts; via-book: nothing acts, the ruled
//  sentence speaks with ONE door to the book), the gate (her R-878-K3: the
//  mark draws only while a client is approved — the shared icon's exact gate,
//  superseding N-2 — while the menu's Private row keeps VX-641), the
//  masthead's read (the mark only while a client is approved, reach only while
//  the indicator is on), and the drawn-rows-only shape on every host (P1). The facts
//  themselves are pinned headless (`PrivateMarkFactsTests`). An Improvement:
//  no red-on-old is owed; the walk is its evidence.
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
private func withMarkWorld<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 831))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private let vault = Queries.BookRef(id: "b-vault", name: "the vault")
private let diary = Queries.BookRef(id: "b-diary", name: "diary")

@MainActor
@Suite("VX-831 — the Private mark: three states, the switch, the words, the door's two arms", .serialized)
struct PrivateMarkFaceTests {
    // MARK: - The rule

    @Test func theThreeStatesOwnViaABookAndNone() {
        #expect(PrivateMarkFace.note(nil, badgesOn: true) == nil, "not Private: no mark")
        #expect(PrivateMarkFace.note(.init(own: false, viaBooks: []), badgesOn: true) == nil)
        #expect(PrivateMarkFace.note(.init(own: true, viaBooks: []), badgesOn: true) == .ownNote(alsoVia: []))
        #expect(PrivateMarkFace.note(.init(own: false, viaBooks: [vault]), badgesOn: true) == .viaBooks([vault]),
                "via its book: the mark at FULL strength — the same glyph, no muted twin")
        #expect(PrivateMarkFace.note(.init(own: true, viaBooks: [vault]), badgesOn: true)
                == .ownNote(alsoVia: [vault]), "its own mark is the door; the book is remembered for the receipt")
        #expect(PrivateMarkFace.book(marked: true, badgesOn: true) == .ownBook)
        #expect(PrivateMarkFace.book(marked: false, badgesOn: true) == nil)
    }

    @Test func theBadgeFamilysOneSwitchGovernsTheMarkEverywhereTheMastheadIncluded() throws {
        let fact = Queries.PrivateMark(own: true, viaBooks: [])
        #expect(PrivateMarkFace.note(fact, badgesOn: false) == nil, "ownership_badges off: no mark on a row")
        #expect(PrivateMarkFace.book(marked: true, badgesOn: false) == nil)
        // The masthead reads the row's own rule over the row's own GATED fact
        // (R-878-K3 — `theMarkDrawsOnlyWhileAClientIsApproved` pins the gate),
        // silenced with the family (D-831-3 — so the switch's "Off: no marks
        // anywhere" stays true).
        let indicator = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Core/Views/MCPNoteIndicator.swift"),
            encoding: .utf8)
        #expect(indicator.contains(
            "PrivateMarkFace.note(state?.mark, badgesOn: themeStore?.settings.ownershipBadges ?? true)"))
        // The switch says it governs the eye, and still that off changes
        // nothing else.
        // R-878-K3: and it says when (it no longer claims the eye with no client).
        #expect(OwnershipSettingsCopy.badgesHelp.contains(
            "While an AI client is approved, a Private note or book wears a closed eye"))
        #expect(OwnershipSettingsCopy.badgesHelp.contains("Off: no marks anywhere; nothing else changes."))
    }

    /// **R-878-K3 — the gate arm** (her pick, "While a client is approved" —
    /// the shared icon's exact gate, superseding N-2): a thing marked Private,
    /// with the badges ON, draws NO mark while no client is approved — the
    /// gated read every host holds answers nothing — and draws it once one is;
    /// the note menu's Private row keeps VX-641 throughout (always shown on a
    /// marked thing), so the un-private road survives while the mark is hidden.
    @Test func theMarkDrawsOnlyWhileAClientIsApproved() async throws {
        try await withMarkWorld { session, db in
            let ops = session.operations
            let note = try ops.createPost(title: "a secret")
            let book = try ops.createReading(name: "the vault", kind: .book)
            try ops.setNotePrivate(note.id, true)
            try ops.setBookPrivate(book.id, true)
            func drawn() async throws -> (note: PrivateMarkFace.Mark?, book: PrivateMarkFace.Mark?) {
                let (notes, books) = try await db.read { db in
                    (try Queries.privateMarksDrawn(db, noteIDs: [note.id]),
                     try Queries.privateBookMarksDrawn(db, readingIDs: [book.id]))
                }
                return (PrivateMarkFace.note(notes[note.id], badgesOn: true),
                        PrivateMarkFace.book(marked: books.contains(book.id), badgesOn: true))
            }
            let none = try await drawn()
            #expect(none.note == nil && none.book == nil, "marked + badges on + NO approved client ⇒ no mark")
            #expect(try await db.read { try NotePrivacyState.read($0, postID: note.id) }.showsPrivateRow,
                    "VX-641 unchanged: the Private row still shows on a marked note — the un-private road")
            let client = try ops.recordMCPContact(name: "claude-code", version: "2")
            let pending = try await drawn()
            #expect(pending.note == nil && pending.book == nil, "a waiting client is not approved")
            try ops.approveMCPClient(client.id, granting: nil)
            let approved = try await drawn()
            #expect(approved.note == .ownNote(alsoVia: []))
            #expect(approved.book == .ownBook)
        }
    }

    @Test func eachMarksPressIsItsOwnArm() {
        #expect(PrivateMarkFace.press(.ownNote(alsoVia: [])) == .unmarkNote(stillVia: []))
        #expect(PrivateMarkFace.press(.ownNote(alsoVia: [vault])) == .unmarkNote(stillVia: [vault]))
        #expect(PrivateMarkFace.press(.viaBooks([vault])) == .sayVia([vault]))
        #expect(PrivateMarkFace.press(.ownBook) == .unmarkBook)
    }

    // MARK: - The words

    @Test func theHoversAndTheSayingSpeakHerWords() {
        #expect(PrivateMarkFace.help(.viaBooks([vault])) == "Private \u{2014} via \u{201C}the vault\u{201D}",
                "hers: \"Private — via ‹book›\"")
        #expect(PrivateMarkFace.help(.viaBooks([vault, diary]))
                == "Private \u{2014} via \u{201C}the vault\u{201D} and \u{201C}diary\u{201D}")
        #expect(PrivateMarkCopy.markViaHelp(["a", "b", "c", "d"])
                == "Private \u{2014} via \u{201C}a\u{201D}, \u{201C}b\u{201D} and 2 more")
        #expect(PrivateMarkFace.help(.ownNote(alsoVia: [])) == "Private \u{2014} click to remove this note\u{2019}s mark")
        #expect(PrivateMarkFace.help(.ownNote(alsoVia: [vault]))
                == "Private \u{2014} click to remove this note\u{2019}s own mark (it stays private via \u{201C}the vault\u{201D})")
        #expect(PrivateMarkFace.help(.ownBook) == "Private \u{2014} click to remove this book\u{2019}s mark")
        // The via-book saying — hers: "Private via ‹book› — change it on the
        // book, or move the note".
        #expect(PrivateMarkCopy.viaBookSaying(["the vault"])
                == "Private via \u{201C}the vault\u{201D} \u{2014} change it on the book, or move the note.")
        #expect(PrivateMarkCopy.viaBookSaying(["a", "b"])
                == "Private via \u{201C}a\u{201D} and \u{201C}b\u{201D} \u{2014} change it on the books, or move the note.")
        #expect(PrivateMarkCopy.openBookDoor("the vault") == "Open \u{201C}the vault\u{201D}")
        // VX-272's settings-class rule holds on the mark too: no "AI" word.
        for words in [PrivateMarkCopy.markOwnNoteHelp, PrivateMarkCopy.markOwnBookHelp,
                      PrivateMarkCopy.markViaHelp(["x"]), PrivateMarkCopy.viaBookSaying(["x"])] {
            #expect(!words.split(whereSeparator: { !$0.isLetter }).contains("AI"), "\(words)")
        }
    }

    // MARK: - The door's two arms, through the real operations

    @Test func theOwnArmUnPrivatesTheNoteWithTheRowsReceipt() async throws {
        try await withMarkWorld { session, db in
            let ops = session.operations
            let note = try ops.createPost(title: "a secret")
            try ops.setNotePrivate(note.id, true)
            await PrivateMarkAct.perform(
                .unmarkNote(stillVia: []), subjectID: note.id, subjectName: nil, session: session)
            #expect(try await db.read { try Queries.isNotePrivate($0, postID: note.id) } == false,
                    "the press ran the Private row's op — no confirm, as every Private toggle")
            #expect(session.status.spoken?.kind == .receipt)
            #expect(session.status.spoken?.text == PrivateMarkCopy.clearedNote)
        }
    }

    @Test func theOwnArmOnANoteAPrivateBookStillHoldsSaysItStaysPrivate() async throws {
        try await withMarkWorld { session, db in
            let ops = session.operations
            let note = try ops.createPost(title: "both")
            let book = try ops.createReading(name: "the vault", kind: .book)
            try ops.addPostToReading(note.id, to: book.id)
            try ops.setBookPrivate(book.id, true)
            try ops.setNotePrivate(note.id, true)
            let fact = try #require(try await db.read { try Queries.privateMarks($0, noteIDs: [note.id]) }[note.id])
            let mark = try #require(PrivateMarkFace.note(fact, badgesOn: true))
            await PrivateMarkAct.perform(
                PrivateMarkFace.press(mark), subjectID: note.id, subjectName: nil, session: session)
            let after = try await db.read { try Queries.privateMarks($0, noteIDs: [note.id]) }[note.id]
            #expect(after == Queries.PrivateMark(own: false, viaBooks: [.init(id: book.id, name: "the vault")]),
                    "its own mark is off; the book still holds it private")
            #expect(session.status.spoken?.text == PrivateMarkCopy.clearedNoteStillVia(["the vault"]))
            // …and the row now wears the via-book mark at full strength.
            #expect(PrivateMarkFace.note(after, badgesOn: true) == .viaBooks([.init(id: book.id, name: "the vault")]))
        }
    }

    @Test func theOwnArmUnPrivatesTheBookWithBookSettingsReceipt() async throws {
        try await withMarkWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "the vault", kind: .book)
            try ops.setBookPrivate(book.id, true)
            await PrivateMarkAct.perform(.unmarkBook, subjectID: book.id, subjectName: "the vault", session: session)
            #expect(try await db.read { try Queries.isBookPrivate($0, readingID: book.id) } == false)
            #expect(session.status.spoken?.text == PrivateMarkCopy.clearedBook("the vault"))
        }
    }

    @Test func theViaBookArmActsOnNothingSaysSoAndItsDoorOpensTheBookAtTheNote() async throws {
        try await withMarkWorld { session, db in
            let ops = session.operations
            let note = try ops.createPost(title: "kept close")
            let book = try ops.createReading(name: "the vault", kind: .book)
            try ops.addPostToReading(note.id, to: book.id)
            try ops.setBookPrivate(book.id, true)
            let ref = Queries.BookRef(id: book.id, name: "the vault")
            await PrivateMarkAct.perform(.sayVia([ref]), subjectID: note.id, subjectName: nil, session: session)
            // Nothing changed: the mark cannot be lifted in place.
            #expect(try await db.read { try Queries.privateMarks($0, noteIDs: [note.id]) }[note.id]
                    == Queries.PrivateMark(own: false, viaBooks: [ref]))
            #expect(try await db.read { try Queries.isBookPrivate($0, readingID: book.id) })
            // It SAYS so, names the book, and carries ONE door to it (a line
            // with a door is an offer on the seam — always the toast).
            let said = try #require(session.status.current)
            #expect(said.kind == .offer)
            #expect(said.text == "Private via \u{201C}the vault\u{201D} \u{2014} change it on the book, or move the note.")
            let door = try #require(said.action)
            #expect(door.label == "Open \u{201C}the vault\u{201D}")
            let received = LockIsolated<[[String: String]]>([])
            let token = NotificationCenter.default.addObserver(
                forName: .variorumOpenBookAtPost, object: nil, queue: nil
            ) { posted in
                guard let bookID = posted.userInfo?["bookID"] as? String,
                      let postID = posted.userInfo?["postID"] as? String else { return }
                received.withValue { $0.append(["bookID": bookID, "postID": postID]) }
            }
            defer { NotificationCenter.default.removeObserver(token) }
            door.perform()
            #expect(received.value == [["bookID": book.id, "postID": note.id]],
                    "the owned-by badge's click-through: the book opened at the note")
        }
    }

    // MARK: - The masthead's read

    /// R-878-K3 (A FLIPPED PIN — it read "the mark always", N-2's rule): the
    /// masthead reads the mark only while a client is approved, and reach only
    /// while the indicator is on.
    @Test func theMastheadReadsTheMarkOnlyWhileAClientIsApprovedAndReachOnlyWhileOn() async throws {
        try await withMarkWorld { session, db in
            let ops = session.operations
            let note = try ops.createPost(title: "marked")
            let open = try ops.createPost(title: "an open page")
            try ops.setNotePrivate(note.id, true)
            // No client approved: the masthead's read draws nothing marked.
            let unapproved = try await db.read {
                try MCPNoteIndicatorState.read($0, postID: note.id, includingReach: false)
            }
            #expect(unapproved.mark == nil && unapproved.isEmpty, "no approved client: no mark at the masthead")
            let client = try ops.recordMCPContact(name: "claude-code", version: "2")
            try ops.approveMCPClient(client.id, granting: nil)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            // A client approved: the mark is read whatever the indicator…
            let off = try await db.read { try MCPNoteIndicatorState.read($0, postID: note.id, includingReach: false) }
            #expect(off.mark == Queries.PrivateMark(own: true, viaBooks: []), "approved: the mark, indicator or not")
            let on = try await db.read { try MCPNoteIndicatorState.read($0, postID: note.id) }
            #expect(on.mark == off.mark)
            // The lock's two fields live on, derived (its pins read them).
            #expect(on.ownPrivate && on.privateBooks.isEmpty && on.isPrivate)
            // …and reach only while the indicator is on (the shared icon's law).
            let reachOff = try await db.read {
                try MCPNoteIndicatorState.read($0, postID: open.id, includingReach: false)
            }
            #expect(reachOff.reach.isEmpty && reachOff.mark == nil, "indicator off: no reach read")
            let reachOn = try await db.read { try MCPNoteIndicatorState.read($0, postID: open.id) }
            #expect(reachOn.reach.map(\.clientName) == ["claude-code"], "indicator on: the wing grant's reach")
        }
    }

    // MARK: - P1 — every host holds exactly the ids it draws

    /// Each host keys its mark hold on the SAME ids its shared icon's reach
    /// hold reads — the rows it draws (the facts' own statements are ∝ the
    /// ids, plan-pinned headless) — and nowhere reads the corpus.
    @Test func everyHostHoldsTheMarksOfExactlyTheRowsItDraws() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Variorum")
        func source(_ path: String) throws -> String {
            try String(contentsOf: app.appendingPathComponent(path), encoding: .utf8)
        }
        let paging = try source("Features/Library/LibraryCatalogPaging.swift")
        #expect(paging.contains("await PrivateMarkHold.notes(session, ids)"), "the Library's near window")
        #expect(paging.contains("try Queries.mcpNoteReaches($0, noteIDs: ids)"), "…the same ids as its reach")
        let library = try source("Features/Library/LibraryCatalogView.swift")
        #expect(library.contains(".task(id: model.listedBookIDs) { await model.holdBookMarks(model.listedBookIDs) }"))
        let timeline = try source("Features/Timeline/TimelineView.swift")
        #expect(timeline.contains(".task(id: model.reachIDs) { await model.holdPrivateMarks(model.reachIDs) }"))
        let pool = try source("Features/Pool/PoolPostsView.swift")
        #expect(pool.contains(".task(id: model.drawnIDs) { await model.holdPrivateMarks(model.drawnIDs) }"))
        let shelf = try source("Features/Shelf/ShelfView.swift")
        #expect(shelf.contains(".task(id: model.bookIDs) { await model.holdPrivateMarks(model.bookIDs) }"))
        let panel = try source("Features/BookView/BookPanelView.swift")
        #expect(panel.contains("await model.holdPrivateMarks(model.entryIDs(for: shown?.id))"))
        #expect(panel.contains("await model.holdReadingPrivateMarks(namedReadings(shown))"))
        let indicator = try source("Core/Views/MCPNoteIndicator.swift")
        // R-878-K3 (FLIPPED with the gate): the masthead and every host hold
        // the GATED reads — the facts' id-driven queries behind the
        // approved-client gate, never the plain facts.
        #expect(indicator.contains("Queries.privateMarksDrawn(db, noteIDs: [postID])"), "the masthead: one note")
        let face = try source("Core/Views/PrivateMarkView.swift")
        #expect(face.contains("try Queries.privateMarksDrawn($0, noteIDs: ids)"))
        #expect(face.contains("try Queries.privateBookMarksDrawn($0, readingIDs: ids)"))
        #expect(!face.contains("try Queries.privateMarks($0"), "no ungated hold")
        #expect(!indicator.contains("Queries.privateMarks(db"), "no ungated masthead read")
    }

    /// The fences, said as code: the mark only ever CLEARS her own stamps, by
    /// her press, through the existing ops — it mints no new writer of
    /// `ai_private_at`.
    @Test func theMarkWritesOnlyHerUnPrivateThroughTheExistingOps() throws {
        let face = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Core/Views/PrivateMarkView.swift"),
            encoding: .utf8)
        #expect(face.contains("setNotePrivate(subjectID, false)"))
        #expect(face.contains("setBookPrivate(subjectID, false)"))
        #expect(!face.contains("Private(subjectID, true)"))
        #expect(!face.contains("ai_private_at ="), "no raw write")
    }

    // MARK: - The face, mounted

    private func pump() { RunLoop.main.run(until: Date().addingTimeInterval(0.02)) }

    private func mount<V: View>(_ content: V) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 700, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: content.padding(12).frame(width: 700, height: 80, alignment: .leading))
        hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 80)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<12 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
        }
        return window
    }

    @Test func theLibrarysLinesDrawTheMarkTheyAreHandedAndNothingWithout() async throws {
        try await withMarkWorld { session, _ in
            #if DEBUG
            PrivateMarkProbe.reset()
            let tokens = VoiceTokens.studyLight
            let marked = mount(VStack {
                CatalogNoteLine(
                    tokens: tokens, title: "a secret", date: nil, tags: [], allTags: [],
                    onTitleTap: {}, onApply: { _ in }, onRemove: { _ in },
                    privateMark: PrivateMarkDoor(mark: .viaBooks([vault]), subjectID: "n-1", session: session))
                CatalogBookLine(
                    tokens: tokens, title: "the vault", detail: "book", onTitleTap: {},
                    privateMark: PrivateMarkDoor(
                        mark: .ownBook, subjectID: "b-vault", subjectName: "the vault", session: session))
                CatalogNoteLine(
                    tokens: tokens, title: "an open page", date: nil, tags: [], allTags: [],
                    onTitleTap: {}, onApply: { _ in }, onRemove: { _ in })
            })
            defer {
                marked.orderOut(nil)
                marked.close()
            }
            #expect(PrivateMarkProbe.drawn["n-1"] == .viaBooks([vault]), "via its book: drawn, full strength")
            #expect(PrivateMarkProbe.drawn["b-vault"] == .ownBook)
            #expect(PrivateMarkProbe.drawn.count == 2, "a line handed no mark draws none (the calm state)")
            #endif
        }
    }
}
