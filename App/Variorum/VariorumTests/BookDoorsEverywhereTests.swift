//
//  BookDoorsEverywhereTests.swift
//  VariorumTests
//
//  VX-829 (the VX-878 run, batch 1 — her 2026-11-04 ask, two screenshots):
//  "(1) the Book Settings sheet has no Move to Wing door — add it (beside the
//  State doors; it's book configuration like the rest). (2) A book row in the
//  LIBRARY offers only Ask Siri · Open · Star · Book Settings… · Export
//  Markdown/PDF · Share with AI… · Archive · Delete Book… — 'the options that
//  are available in bookcase on a book should be available on library (within
//  reason, like the shelf options don't need to be there).'"
//
//  A ruled BUILD (no red-on-old owed): the pins fix the Book Settings wing
//  row (drawn only where another wing exists, from the book's own wing, its
//  act the Bookcase row's), the ONE book-menu table and its DERIVATION — the
//  menu beyond the Bookcase is the Bookcase row's minus shelf placement, with
//  Open leading — and the declarations both faces read. The walk captures the
//  two menus side by side at the closing window.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withDoorsWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 829))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval = 0.05) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(until condition: () -> Bool = { false }) async {
    for _ in 0..<20 where !condition() {
        pump()
        for _ in 0..<10 { await Task.yield() }
    }
}

/// Mounts `view` in a real window for the body of `run`.
@MainActor
private func mounted<V: View>(_ view: V, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 820),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: view)
    window.orderFrontRegardless()
    await settle()
    try await run()
}

@MainActor
@Suite("VX-829 — a book's doors everywhere", .serialized)
struct BookDoorsEverywhereTests {
    // MARK: - (1) Book Settings: the wing row

    /// The act is the Bookcase row's, with a second door on its one
    /// declaration: the sheet's State section draws it (`.surface`).
    @Test func theWingRowIsTheBookcaseActsSecondDoor() {
        #expect(CapabilityRegistry.capability(.moveBookToWing).doors.contains(.surface))
        #expect(BookSettingsSheet.surfaceCapabilities.contains(.moveBookToWing))
        #expect(CollectingCopy.wingCaption("Home", isGathering: false)
                == "In \u{201C}Home\u{201D}. Moving the book takes its notes with it.")
        #expect(CollectingCopy.wingCaption("Imports", isGathering: true)
                == "In \u{201C}Imports\u{201D}. A gathering shows the notes of the wing it\u{2019}s in.")
    }

    /// The row draws only where it can act (P-2 — `WingBookMoveDoor.drawn`):
    /// with one library, no row; with another wing, the OTHER wings from the
    /// book's own wing, Home first — on a book, a gathering and a book that
    /// lives in an additional wing alike. A mount without a wings brain draws
    /// none.
    @Test func theWingRowDrawsTheOtherWingsOnlyWhereAnotherExists() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Field Notes", kind: .book)
            let wings = WingsModel(session: session)
            await wings.load()

            let target = try #require(await BookSettingsTarget.load(session: session, readingID: book.id))
            BookSettingsProbe.drawn = [:]
            try await mounted(BookSettingsHost(target: target).environment(wings)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.wingDestinations == [], "one library — no wing row")
            }

            let imports = try ops.createWing(name: "Imports")
            let archive = try ops.createWing(name: "Archive room")
            await wings.load()
            BookSettingsProbe.drawn = [:]
            let again = try #require(await BookSettingsTarget.load(session: session, readingID: book.id))
            try await mounted(BookSettingsHost(target: again).environment(wings)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.wingDestinations == ["Imports", "Archive room"],
                        "a Home book is offered every other wing")
            }

            // A gathering in an ADDITIONAL wing: Home first, its own omitted.
            let gathering = try ops.createReading(
                name: "Starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star),
                wingId: imports.id)
            let gTarget = try #require(await BookSettingsTarget.load(session: session, readingID: gathering.id))
            try await mounted(BookSettingsHost(target: gTarget).environment(wings)) {
                let drawn = try #require(BookSettingsProbe.drawn[gathering.id])
                #expect(drawn.wingDestinations == ["Home", "Archive room"],
                        "from the gathering's OWN wing, Home first")
            }

            // A harness mount with no wings brain draws no row (nil, not []).
            let bare = try #require(await BookSettingsTarget.load(session: session, readingID: book.id))
            BookSettingsProbe.drawn = [:]
            try await mounted(BookSettingsHost(target: bare)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.wingDestinations == nil)
            }
            _ = archive
            _ = try await db.read { try Queries.reading($0, id: book.id) }
        }
    }

    /// The row's road IS the Bookcase row's: a pick asks through
    /// `WingsModel.bookMoveAsk` (the counting confirm's item), and the
    /// confirm's act moves the book with its notes.
    @Test func theWingRowsPickRunsTheBookcaseRowsAct() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Field Notes", kind: .book)
            let note = try ops.createPost(title: "a note")
            _ = try ops.addPostToReading(note.id, to: book.id)
            let imports = try ops.createWing(name: "Imports")
            let wings = WingsModel(session: session)
            await wings.load()

            let reading = try #require(try await db.read { try Queries.reading($0, id: book.id) })
            let offered = BookSettingsSheet.wingDestinations(for: reading, wings: wings)
            #expect(offered.map(\.id) == [imports.id])
            let ask = try #require(await wings.bookMoveAsk(reading: reading, to: imports.id))
            #expect(ask.readingID == book.id && ask.wingName == "Imports")
            await wings.moveBook(ask)
            #expect(try await db.read { try Queries.reading($0, id: book.id) }?.wingId == imports.id)
        }
    }

    // MARK: - (2) One table, two faces

    private static let now = Date(timeIntervalSince1970: 1_782_864_000)

    private static func reading(
        _ id: String, kind: ReadingKind = .book, profile: String? = nil, querySpec: String? = nil,
        locked: Bool = false, sealed: Bool = false, owned: Bool = false, archived: Bool = false
    ) -> Reading {
        var reading = Reading(
            id: id, name: id, kind: kind, profile: profile, owned: owned,
            archivedAt: archived ? now : nil, createdAt: now, updatedAt: now)
        reading.querySpec = querySpec
        reading.locked = locked || sealed
        reading.sealedAt = sealed ? now : nil
        return reading
    }

    /// Every kind of book row the table can meet: a plain book, an owned, a
    /// finished, a sealed, an archived one; a journal-trait book and THE daily
    /// Journal; a gathering with a rule, a rule-less one, a legacy-finished one.
    private static var rows: [Reading] {
        let star = (try? RuleGrammar.encode(.star)) ?? ""
        return [
            reading("plain"), reading("owned", owned: true), reading("finished", locked: true),
            reading("sealed", sealed: true), reading("archived", archived: true),
            reading("journal", profile: "journal"),
            reading("daily", profile: Queries.dailyJournalBookProfile),
            reading("ruled", kind: .gathering, querySpec: star),
            reading("ruleless", kind: .gathering),
            reading("legacy", kind: .gathering, querySpec: star, locked: true),
        ]
    }

    /// Every combination of the per-host facts, over every kind of row.
    private static var matrix: [BookMenuFacts] {
        var out: [BookMenuFacts] = [BookMenuFacts(reading: nil)]
        for row in rows {
            for shareable in [false, true] {
                for wings in [0, 2] {
                    for canMove in [false, true] {
                        for placing in [false, true] {
                            out.append(BookMenuFacts(
                                reading: row, shareable: shareable, wingDestinations: wings,
                                shelfMoveCanAct: canMove, placesByHand: placing))
                        }
                    }
                }
            }
        }
        return out
    }

    /// **THE DERIVATION** (her ask: "the options that are available in
    /// bookcase on a book should be available on library (within reason, like
    /// the shelf options don't need to be there)"): for every row and every
    /// host fact, the face beyond the Bookcase is EXACTLY the Bookcase face
    /// minus the shelf-placement family, Open leading — group by group, so
    /// even the dividers fall in the same places.
    @Test func theFaceBeyondTheBookcaseIsTheBookcasesMinusShelfPlacement() {
        for facts in Self.matrix {
            let board = BookRowMenuTable.groups(facts, face: .bookcase)
            let beyond = BookRowMenuTable.groups(facts, face: .elsewhere)
            var expected = board.map { $0.filter { !$0.isShelfPlacement } }
            expected[0].insert(.open, at: 0)
            #expect(beyond == expected.filter { !$0.isEmpty }, "\(facts.reading?.id ?? "nil")")
            let shelfDoorBeyond = beyond.joined().contains { $0.isShelfPlacement }
            #expect(!shelfDoorBeyond, "never a shelf door beyond")
            #expect(!board.joined().contains(.open), "the Bookcase row opens by its click")
        }
    }

    /// The shelf-placement family draws on the Bookcase only, and there only
    /// where it can act (P-2): Move to Shelf ▸ with somewhere to go, Send to
    /// Top / Bottom in the placing mode.
    @Test func theShelfPlacementFamilyDrawsOnTheBookcaseWhereItCanAct() {
        let plain = Self.reading("plain")
        let idle = BookRowMenuTable.doors(BookMenuFacts(reading: plain), face: .bookcase)
        let idleShelfDoor = idle.contains { $0.isShelfPlacement }
        #expect(!idleShelfDoor)
        let placing = BookRowMenuTable.doors(
            BookMenuFacts(reading: plain, shelfMoveCanAct: true, placesByHand: true), face: .bookcase)
        #expect(placing.prefix(4) == [.star, .moveToShelf, .sendToTop, .sendToBottom])
    }

    /// The Bookcase row's whole door set, in the board's shipped order — the
    /// source face (a plain book, every host fact true).
    @Test func theBookcaseFaceKeepsTheBoardsDoorsAndOrder() {
        let doors = BookRowMenuTable.doors(BookMenuFacts(
            reading: Self.reading("journal", profile: "journal"), shareable: true, wingDestinations: 1,
            shelfMoveCanAct: true, placesByHand: true), face: .bookcase)
        #expect(doors == [
            .star, .moveToShelf, .moveToWing, .sendToTop, .sendToBottom,
            .rename, .settings, .share, .duplicate, .editRule, .manageNotes, .extent,
            .useAsDailyJournal,
            .state(.finishBook), .state(.sealBook), .state(.ownBook),
            .exportMarkdown, .exportPDF,
            .state(.archiveBook), .state(.deleteBook),
        ])
        // A gathering: no duplicate, no Manage Notes, no extent — its two
        // strengthening doors in their place; no Finish (13i-d U1, row 107).
        let gathering = BookRowMenuTable.doors(BookMenuFacts(
            reading: Self.reading("g", kind: .gathering, querySpec: try? RuleGrammar.encode(.star))),
            face: .elsewhere)
        #expect(gathering == [
            .open, .star, .rename, .settings, .editRule, .bind, .makeBook,
            .exportMarkdown, .exportPDF, .state(.archiveBook), .state(.deleteBook),
        ])
    }

    /// N-1 (the VX-878 record — the ticket's "Archive-in-Delete's-place" line
    /// is STALE against VX-436): the daily Journal's row offers Delete beside
    /// Archive on BOTH faces, with the ordinary book door.
    @Test func theDailyJournalsRowCarriesDeleteBesideArchiveOnBothFaces() {
        let daily = Self.reading("daily", profile: Queries.dailyJournalBookProfile)
        #expect(Queries.isDailyJournalMintShape(daily))
        for face in [BookMenuFace.bookcase, .elsewhere] {
            let doors = BookRowMenuTable.doors(BookMenuFacts(reading: daily), face: face)
            #expect(doors.contains(.state(.archiveBook)), "\(face)")
            #expect(doors.contains(.state(.deleteBook)), "\(face)")
        }
    }

    /// P-1's walk, per face: every door a face draws is one of the face's
    /// declared acts (or one of the three doors that were never acts — Open
    /// and the two exports), and every declared act is drawn for SOME row —
    /// no declaration dead. The Bookcase face is read over the rows the board
    /// lists (never an archived one).
    @Test func eachFacesDeclaredActsAreExactlyTheActsItDraws() {
        for face in [BookMenuFace.bookcase, .elsewhere] {
            let declared = Set(BookRowMenuTable.capabilities(face))
            var drawn: Set<CapabilityID> = []
            for facts in Self.matrix {
                if face == .bookcase, facts.reading?.archivedAt != nil { continue }
                for door in BookRowMenuTable.doors(facts, face: face) {
                    guard let act = door.capability else {
                        #expect([.open, .exportMarkdown, .exportPDF].contains(door))
                        continue
                    }
                    #expect(declared.contains(act), "\(face): \(act) drawn but not declared")
                    drawn.insert(act)
                }
            }
            #expect(drawn == declared, "\(face): declared \(declared.subtracting(drawn)) never drawn")
            for act in declared {
                #expect(CapabilityRegistry.capability(act).doors.contains(.contextMenu), "\(act)")
            }
        }
        // The two renderers' walk lines ARE the table's — derived, not kept.
        #expect(ShelfView.contextMenuCapabilities == BookRowMenuTable.capabilities(.bookcase))
        #expect(BookRowMenu.contextMenuCapabilities == BookRowMenuTable.capabilities(.elsewhere))
        #expect(Set(BookRowMenuTable.capabilities(.elsewhere))
                == Set(BookRowMenuTable.capabilities(.bookcase))
                    .subtracting(BookRowMenuTable.shelfPlacementCapabilities)
                    .union([.unarchiveBook]))
        #expect(!BookRowMenuTable.capabilities(.bookcase).contains(.unarchiveBook),
                "an archived book is never on the Bookcase")
    }

    /// The four doors the Bookcase never declared are declared now — once,
    /// each its board word, a context door on a book.
    @Test func theFourBookcaseDoorsAreDeclaredWithTheBoardsWords() {
        let words: [CapabilityID: String] = [
            .renameBook: "Rename\u{2026}", .manageBookNotes: "Manage Notes\u{2026}",
            .setBookExtent: "Length & Extent\u{2026}", .useAsDailyJournal: "Use as Daily Journal",
        ]
        for (act, verb) in words {
            let capability = CapabilityRegistry.capability(act)
            #expect(capability.verb == verb, "\(act)")
            #expect(capability.doors == [.contextMenu], "\(act)")
            #expect(capability.scope == .book, "\(act)")
        }
    }

    /// Both faces draw the ONE renderer (a context menu's content is not
    /// evaluated by the test host — the grep form, the 17y precedent).
    @Test func bothFacesDrawTheOneRenderer() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let shelf = try String(
            contentsOf: appRoot.appending(path: "Variorum/Features/Shelf/ShelfView.swift"), encoding: .utf8)
        #expect(shelf.contains("BookRowMenuItems(\n            face: .bookcase"))
        #expect(shelf.contains(".bookRowDoors(model.rowDoors, hostsStateConfirms: false)"))
        #expect(!shelf.contains("Button(\"Manage Notes\\u{2026}\")"), "no second spelling on the board")
        let menu = try String(
            contentsOf: appRoot.appending(path: "Variorum/Core/Views/BookRowMenu.swift"), encoding: .utf8)
        #expect(menu.contains("BookRowMenuItems(\n            face: .elsewhere"))
    }

    // MARK: - The one brain's acts (every face's)

    /// The Bookcase's brain IS the shared one, sharing the board's state
    /// doors (one confirm road).
    @Test func theBookcaseHoldsTheOneBrain() async throws {
        try await withDoorsWorld { session, _ in
            let shelf = ShelfViewModel(session: session)
            #expect(shelf.rowDoors.stateDoors === shelf.stateDoors)
        }
    }

    /// Rename… through the brain: E13's guard SPEAKS its refusal (the name is
    /// another book's), and a free name lands and tells the surface.
    @Test func renameThroughTheBrainGuardsTheNameAndLands() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Essays", kind: .book)
            _ = try ops.createReading(name: "Ideas", kind: .book)
            let doors = BookRowDoors(session: session)
            var landed = 0
            doors.onLanded = { landed += 1 }

            let row = try #require(try await db.read { try Queries.reading($0, id: book.id) })
            doors.beginRename(row)
            #expect(doors.renameTarget?.id == book.id && doors.renameField == "Essays",
                    "the ask is seeded with the stored name")

            await doors.rename(book.id, to: "Ideas")
            #expect(session.status.spoken?.text == BookNameCopy.refusal(existing: "Ideas"))
            #expect(session.status.spoken?.kind == .refusal)
            #expect(try await db.read { try Queries.reading($0, id: book.id) }?.name == "Essays")
            #expect(landed == 0)

            await doors.rename(book.id, to: "Field Notes")
            #expect(try await db.read { try Queries.reading($0, id: book.id) }?.name == "Field Notes")
            #expect(landed == 1, "the one-shot listing re-asks")
        }
    }

    /// Length & Extent… through the brain: the two writes land on an open
    /// book; on a finished one the refusal SPEAKS (fire-and-speak).
    @Test func extentsThroughTheBrainLandOrSpeak() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Essays", kind: .book)
            let doors = BookRowDoors(session: session)
            await doors.saveExtents(book.id, wordTarget: 40_000, maxPosts: 12)
            let row = try #require(try await db.read { try Queries.reading($0, id: book.id) })
            #expect(row.wordTarget == 40_000 && row.maxPosts == 12)

            try ops.lockReading(book.id)
            await doors.saveExtents(book.id, wordTarget: 50_000, maxPosts: 12)
            #expect(session.status.spoken?.kind == .refusal, "a finished book's extents refuse, said")
            #expect(try await db.read { try Queries.reading($0, id: book.id) }?.wordTarget == 40_000)
        }
    }

    /// Use as Daily Journal through the brain moves the designation.
    @Test func useAsDailyJournalThroughTheBrainDesignates() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Diary", kind: .book, profile: "journal")
            let doors = BookRowDoors(session: session)
            await doors.designateDailyJournal(book.id)
            #expect(try await db.read { try Queries.dailyJournalBookID($0) } == book.id)
        }
    }

    /// Bind into a Book… through the brain: the ONE body the board runs too
    /// (`BookRowActs.bind`) — the same row becomes the book, the same receipt.
    @Test func bindThroughTheBrainIsTheBoardsOneBody() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let note = try ops.createPost(title: "a")
            try ops.setStarred(.post(note.id), starred: true)
            let gathering = try ops.createReading(
                name: "Starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let doors = BookRowDoors(session: session)
            let row = try #require(try await db.read { try Queries.reading($0, id: gathering.id) })
            await doors.openBind(row)
            #expect(doors.bindOffer?.reading.id == gathering.id && doors.bindOffer?.count == 1)

            await doors.bind(gathering.id, ownedNotes: .leaveOut)
            let bound = try #require(try await db.read { try Queries.reading($0, id: gathering.id) })
            #expect(bound.kind == .book, "the same row is the book now")
            #expect(session.status.spoken?.text
                    == BindCopy.bound("Starred", count: 1, hearsActs: BindCopy.hearsActs(bound)))
        }
    }

    /// Make a Book… through the brain: the ONE spawn body — a sibling book
    /// with the rule, its receipt; a taken name SPEAKS E13's refusal.
    @Test func spawnThroughTheBrainIsTheBoardsOneBody() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            _ = try ops.createReading(name: "Essays", kind: .book)
            let gathering = try ops.createReading(
                name: "Starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let doors = BookRowDoors(session: session)
            await doors.spawn(from: gathering.id, named: "Essays", outflow: [])
            #expect(session.status.spoken?.text == BookNameCopy.refusal(existing: "Essays"))
            #expect(session.status.spoken?.kind == .refusal)

            await doors.spawn(from: gathering.id, named: "Starred book", outflow: [])
            let books = try await db.read { try Queries.readings($0) }.filter { $0.kind == .book }
            #expect(books.map(\.name).sorted() == ["Essays", "Starred book"])
            #expect(session.status.spoken?.text
                    == BindCopy.spawned("Starred book", count: 0, rule: RuleGrammar.read(gathering.querySpec)))
        }
    }

    /// A row act re-reads the listed rows' facts (P-2 beyond the Bookcase:
    /// the menu draws from them, so a Finish must turn the door into Reopen
    /// on the next right-click, never offer a Finish that cannot act).
    @Test func aLandedActRereadsTheRowsFactsSoTheNextMenuIsTrue() async throws {
        try await withDoorsWorld { session, _ in
            let book = try session.operations.createReading(name: "Essays", kind: .book)
            let doors = BookRowDoors(session: session)
            await doors.load([book.id])
            let before = BookRowMenuTable.doors(
                BookMenuFacts(reading: doors.facts[book.id]), face: .elsewhere)
            #expect(before.contains(.state(.finishBook)))

            await doors.open(.finishBook, readingID: book.id)   // nothing waits: acts at once
            for _ in 0..<200 where doors.facts[book.id]?.locked != true {
                try? await Task.sleep(for: .milliseconds(5))
            }
            let after = BookRowMenuTable.doors(
                BookMenuFacts(reading: doors.facts[book.id]), face: .elsewhere)
            #expect(after.contains(.state(.reopenBook)) && !after.contains(.state(.finishBook)),
                    "the next right-click offers Reopen")
        }
    }

    /// The items the other doors present: each its sheet's whole input.
    @Test func theOtherDoorsPresentTheirSheetsItems() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Essays", kind: .book)
            try ops.setReadingOwned(book.id, owned: true)
            let wing = try ops.createWing(name: "Imports")
            let row = try #require(try await db.read { try Queries.reading($0, id: book.id) })
            let doors = BookRowDoors(session: session)
            doors.openManage(row)
            #expect(doors.manageTarget?.id == book.id)
            doors.openExtent(row)
            #expect(doors.extentTarget?.id == book.id)
            doors.openDuplicate(row)
            #expect(doors.duplicateOffer == DuplicateBookOffer(readingID: book.id, name: "Essays", owned: true))
            doors.openRuleEditor(book.id)
            #expect(doors.ruleEditor != nil)
            let wings = WingsModel(session: session)
            await wings.load()
            await doors.askMove(row, to: wing.id, wings: wings)
            #expect(doors.bookMoveAsk?.wingID == wing.id && doors.moveWings === wings,
                    "Move to Wing ▸'s pick: the counting confirm's item, and the brain that asked")
        }
    }
}
