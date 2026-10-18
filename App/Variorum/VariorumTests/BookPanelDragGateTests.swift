//
//  BookPanelDragGateTests.swift
//  VariorumTests
//
//  17y B2 — item (e): THE BOOK PANEL's handles and its gates, after the
//  shared mechanism (`DragTypeDeclarationTests` — the undeclared drag type
//  killed EVERY panel drop, which is her capture: the Jekyll book, manual
//  order, unfinished, four chapter grips, nothing moved).
//
//  The row's two trace candidates, answered (the B2 RECORD):
//  · a FINISHED/SEALED book already refuses WITH the road ("is finished —
//    reopen it first", `BookStateCopy.refusal`; pinned since U2 by
//    `aFinishedBookRefusesInWordsAndNothingMoves`) — U2-8 holds, not silent;
//  · `sort_field ≠ manual` DOES gate one road SILENTLY: a note dropped to
//    re-place it inside its own chapter (onto a sibling, or onto its own
//    chapter's heading) in a book that reads in a STAMP order resolves, by
//    the book view's own planner, to "file it into the chapter it is
//    already in" — a write that changes nothing — under a hairline that
//    promised "lands right above". It now refuses WITH the road (P-2).
//  And her stance — "a handle that cannot drag must not render": a lone
//  chapter's ⠿ can never move it anywhere, so it is not drawn.
//
//  Red-on-old, stated per pin: the two refusal pins drive the shipped
//  `BookPanelModel.drop` and read the status seam — on the pre-fix tree it
//  stays nil (the silent no-op). The grip gate is a new value — red by
//  behavioural revert (drawn for every count). The cross-chapter pin is a
//  GUARD (green on both sides by design: the legal half of a stamp-order
//  drop must keep filing, silently).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private let stamp = Date(timeIntervalSince1970: 1_782_864_000)

@MainActor
private func settle(
    within seconds: Double = 3, _ condition: () async throws -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if try await condition() { return }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(try await condition(), "condition never settled")
}

@MainActor
@Suite("17y (e) — the Book Panel's gates speak; a handle that cannot drag is not drawn",
       .serialized)
struct BookPanelDragGateTests {
    /// A book "Orbit" with chapters one (n1, n2) and two (n3), sorted by a
    /// STAMP order (entry date, newest first) unless `manual`.
    private struct World {
        let session: AppSession
        let db: AppDatabase
        let book: Reading
        let one: ReadingSection
        let two: ReadingSection
        let n1: String, n2: String, n3: String
    }

    private func withWorld(
        manual: Bool = false, _ body: @MainActor (World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(stamp)
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            var book = try ops.createReading(name: "Orbit", kind: .book)
            let one = try ops.createSection(in: book.id, name: "one")
            let two = try ops.createSection(in: book.id, name: "two")
            var ids: [String] = []
            for title in ["n1", "n2", "n3"] {
                let note = try ops.createPost(title: title)
                try ops.addPostToReading(note.id, to: book.id)
                ids.append(note.id)
            }
            try ops.assignPostToSection(ids[0], in: book.id, section: one.id)
            try ops.assignPostToSection(ids[1], in: book.id, section: one.id)
            try ops.assignPostToSection(ids[2], in: book.id, section: two.id)
            if !manual {
                let bookID = book.id
                try ops.setReadingSort(bookID, field: .entryDate, direction: .desc)
                book = try #require(try await db.read { try Queries.reading($0, id: bookID) })
            }
            try await body(World(session: session, db: db, book: book, one: one, two: two,
                                 n1: ids[0], n2: ids[1], n3: ids[2]))
        }
    }

    private func membershipOrder(_ world: World) async throws -> [String] {
        try await world.db.read { db in
            try String.fetchAll(db, sql: """
                SELECT post_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                """, arguments: [world.book.id])
        }
    }

    private func chapterOf(_ world: World, _ postID: String) async throws -> String? {
        try await world.db.read { try Queries.sectionAssignments($0, readingID: world.book.id) }[postID]
    }

    private func heldModel(_ world: World) async throws -> (BookPanelModel, Task<Void, Never>) {
        let model = BookPanelModel(session: world.session, postID: world.n1)
        let task = Task { await model.observe(bookID: world.book.id) }
        try await settle { model.snapshot(for: world.book.id)?.entries.count == 3 }
        return (model, task)
    }

    /// THE SILENT SORT GATE, made to speak: re-placing a note inside its
    /// own chapter of a stamp-ordered book refuses WITH the road, and
    /// nothing moves. (Red on the pre-fix tree: the status seam stays nil.)
    ///
    /// The drop is a REAL re-place — the note the stamp order shows LAST
    /// onto the note it shows FIRST. (B2 first wrote n2 onto n1, which in
    /// this order is n2 onto its own immediate successor: already satisfied,
    /// asking for nothing — the B2 ladder's NIT-4, pinned below.)
    @Test func aStampOrderedReplaceRefusesWithTheRoad() async throws {
        try await withWorld { world in
            let (model, task) = try await heldModel(world)
            defer { task.cancel() }
            let before = try await membershipOrder(world)
            let shown = try #require(model.groups(for: world.book.id)
                .first { $0.section?.id == world.one.id }?.entries.map(\.postID))
            #expect(shown.count == 2)
            let lower = try #require(shown.last)

            await model.drop(.note(lower), onto: .note(try #require(shown.first)), in: world.book)
            let refusal = try #require(world.session.status.current,
                                       "a drop that cannot land must SAY so (P-2)")
            #expect(refusal.kind == .refusal)
            #expect(refusal.text.contains("Orbit") && refusal.text.contains("Manual order"),
                    "names the book and the road: \(refusal.text)")
            #expect(try await membershipOrder(world) == before, "nothing moved")
            #expect(try await chapterOf(world, lower) == world.one.id)
        }
    }

    /// The same gate on the other re-place road: onto its OWN chapter's
    /// heading ("the top of this chapter" in a manual book). The dragged
    /// note is the one the stamp order shows LAST in the chapter — the one
    /// shown first is already at the top, a genuine nothing-to-do.
    @Test func aStampOrderedDropOnItsOwnChapterHeadingRefusesWithTheRoad() async throws {
        try await withWorld { world in
            let (model, task) = try await heldModel(world)
            defer { task.cancel() }
            let before = try await membershipOrder(world)
            let shown = try #require(model.groups(for: world.book.id)
                .first { $0.section?.id == world.one.id }?.entries.map(\.postID))
            #expect(shown.count == 2)
            let lower = try #require(shown.last)

            await model.drop(.note(try #require(shown.first)), onto: .chapter(world.one.id),
                             in: world.book)
            #expect(world.session.status.current == nil,
                    "the note shown first is already at the top — nothing to do, nothing said")
            #expect(try await membershipOrder(world) == before)

            await model.drop(.note(lower), onto: .chapter(world.one.id), in: world.book)
            let refusal = try #require(world.session.status.current)
            #expect(refusal.kind == .refusal)
            #expect(refusal.text.contains("Manual order"), "\(refusal.text)")
            #expect(try await membershipOrder(world) == before)
        }
    }

    /// **The B2 ladder's NIT-4 — an ALREADY-SATISFIED drop asks for nothing.**
    /// A note dropped onto its IMMEDIATE shown successor would land "right
    /// above" where it already stands: no placement was asked, so no refusal
    /// is owed (the refusal's words — "can't be placed by hand" — would be
    /// false). Manual order does the same gesture silently; so does a stamp
    /// order now. RED ON OLD (03a0513e's tree): the needsManualOrder refusal.
    @Test func aStampOrderedDropOntoItsOwnSuccessorAsksForNothing() async throws {
        try await withWorld { world in
            let (model, task) = try await heldModel(world)
            defer { task.cancel() }
            let before = try await membershipOrder(world)
            let shown = try #require(model.groups(for: world.book.id)
                .first { $0.section?.id == world.one.id }?.entries.map(\.postID))
            #expect(shown.count == 2)

            let dropped = await model.drop(.note(try #require(shown.first)),
                                           onto: .note(try #require(shown.last)), in: world.book)
            #expect(!dropped, "nothing to do")
            #expect(world.session.status.current == nil,
                    "already right above its successor — nothing said")
            #expect(try await membershipOrder(world) == before, "nothing moved")
        }
    }

    /// **The B2 ladder's MAJOR-1 — a FROZEN book's lock answers BEFORE the
    /// sort gate.** A finished (or sealed) book in a stamp order: re-placing a
    /// note inside its own chapter must speak the op's OWN refusal — "reopen
    /// it first" / "unseal it first" — never `needsManualOrder`, whose road
    /// (set the order ▾ to Manual and save it) a frozen book cannot take: the
    /// Save button is hidden there and `setReadingSort` refuses. Pre-B2 the
    /// drop reached `assignPostToSection`, whose lock guard runs before its
    /// no-op guard; the B2 gate answered first. RED ON OLD (d3560ab9's tree):
    /// the refusal names "Manual order", not "reopen" / "unseal".
    @Test(arguments: [false, true])
    func aFrozenStampOrderedBookSpeaksItsOwnRefusalNotManualOrder(sealed: Bool) async throws {
        try await withWorld { world in
            let ops = world.session.operations
            if sealed {
                _ = try ops.sealReading(world.book.id)
            } else {
                try ops.lockReading(world.book.id)
            }
            let bookID = world.book.id
            let frozen = try #require(try await world.db.read { try Queries.reading($0, id: bookID) })
            #expect(frozen.locked && (frozen.sealedAt != nil) == sealed)
            let (model, task) = try await heldModel(world)
            defer { task.cancel() }
            try await settle { model.snapshot(for: bookID)?.reading?.locked == true }
            let shown = try #require(model.groups(for: bookID)
                .first { $0.section?.id == world.one.id }?.entries.map(\.postID))
            #expect(shown.count == 2)
            let before = try await membershipOrder(world)

            // The note shown LAST dropped on the note shown FIRST: a real
            // re-place (in manual order it would land right above).
            await model.drop(.note(try #require(shown.last)), onto: .note(try #require(shown.first)),
                             in: frozen)
            let refusal = try #require(world.session.status.current,
                                       "a frozen book's drop must SAY why (U2-8)")
            #expect(refusal.kind == .refusal)
            #expect(refusal.text.contains(sealed ? "unseal" : "reopen"),
                    "the op's own road for a \(sealed ? "sealed" : "finished") book: \(refusal.text)")
            #expect(!refusal.text.contains("Manual order"),
                    "never the sort road — a frozen book cannot save an order: \(refusal.text)")
            #expect(try await membershipOrder(world) == before, "nothing moved")
            #expect(try await chapterOf(world, try #require(shown.last)) == world.one.id)
        }
    }

    /// GUARD (green on both sides): the LEGAL half of a stamp-order drop —
    /// filing a note into ANOTHER chapter — still files, silently (the book
    /// view's own ruling: "the chapter half of the drop always happens").
    @Test func aStampOrderedDropIntoAnotherChapterStillFiles() async throws {
        try await withWorld { world in
            let (model, task) = try await heldModel(world)
            defer { task.cancel() }

            #expect(await model.drop(.note(world.n3), onto: .note(world.n1), in: world.book))
            #expect(try await chapterOf(world, world.n3) == world.one.id, "filed into n1's chapter")
            #expect(world.session.status.current == nil, "a move that lands is silent (U2-8)")
        }
    }

    /// GUARD: in MANUAL order the re-place lands right above, silently.
    @Test func aManualOrderReplaceStillLands() async throws {
        try await withWorld(manual: true) { world in
            let (model, task) = try await heldModel(world)
            defer { task.cancel() }

            #expect(await model.drop(.note(world.n2), onto: .note(world.n1), in: world.book))
            try await settle { try await self.membershipOrder(world).prefix(2) == [world.n2, world.n1] }
            #expect(world.session.status.current == nil)
        }
    }

    /// HER STANCE: a handle that cannot drag must not render. A lone
    /// chapter's ⠿ has nowhere to go (every drop resolves to nothing), so
    /// the grip is drawn only when there is another chapter to move past.
    /// (VX-21: stated in MANUAL order — the order where a grip draws at all.)
    @Test func aLoneChapterDrawsNoGrip() {
        #expect(!BookPanelBrain.chapterGripDrawn(chapterCount: 0, manualOrder: true))
        #expect(!BookPanelBrain.chapterGripDrawn(chapterCount: 1, manualOrder: true),
                "one chapter: no drop can move it — no handle")
        #expect(BookPanelBrain.chapterGripDrawn(chapterCount: 2, manualOrder: true))
        #expect(BookPanelBrain.chapterGripDrawn(chapterCount: 9, manualOrder: true))
    }

    // MARK: - VX-21 (was VR-127): no grips under a derived sort

    /// HER 0.9.2 USE (her Journal, by entry date): *"you shouldn't see
    /// draggable bars when you can't drag."* Under a stamp order no row is
    /// placed by hand, so no grip draws, whatever the chapter count; in manual
    /// order the 17y rule stands. RED ON OLD by behavioural revert (the gate
    /// read the count alone).
    @Test func aGripDrawsOnlyWhereTheBookIsPlacedByHand() {
        for count in [2, 3, 9] {
            #expect(!BookPanelBrain.chapterGripDrawn(chapterCount: count, manualOrder: false),
                    "a stamp-ordered book with \(count) chapters draws no grip")
            #expect(BookPanelBrain.chapterGripDrawn(chapterCount: count, manualOrder: true),
                    "in manual order \(count) chapters draw theirs")
        }
        #expect(!BookPanelBrain.chapterGripDrawn(chapterCount: 1, manualOrder: false))
    }

    /// The same, MOUNTED — what the panel DRAWS (`BookPanelGripProbe`), so the
    /// view's own reading of the book's order is pinned and not only the
    /// brain's: a two-chapter book in entry-date order draws no grip on
    /// either chapter row; switched to manual order, both draw. RED ON OLD
    /// (the panel drew both grips under the stamp order).
    @Test func theMountedPanelDrawsNoGripUnderAStampOrderAndBothInManual() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // Live ids: the probe is keyed by chapter id and suites run in
            // parallel (`.incrementing` would share ids across them).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(stamp)
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 21))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let book = try ops.createReading(name: "Journal-ish", kind: .book)
            let one = try ops.createSection(in: book.id, name: "september")
            let two = try ops.createSection(in: book.id, name: "october")
            var ids: [String] = []
            for title in ["a", "b", "c"] {
                let note = try ops.createPost(title: title)
                try ops.addPostToReading(note.id, to: book.id)
                ids.append(note.id)
            }
            try ops.assignPostToSection(ids[0], in: book.id, section: one.id)
            try ops.assignPostToSection(ids[1], in: book.id, section: two.id)
            try ops.setReadingSort(book.id, field: .entryDate, direction: .desc)

            let membership = NoteMembershipModel()
            let model = BookPanelModel(session: session, postID: ids[0])
            let track = Task { await membership.track(session: session, postID: ids[0]) }
            let contents = Task { await model.observe(bookID: book.id) }
            defer { track.cancel(); contents.cancel() }
            try await settle {
                model.snapshot(for: book.id)?.entries.count == 3
                    && membership.readings(for: ids[0]).count == 1
            }
            #expect(model.manualOrder(for: book.id) == false, "the premise: a stamp order")

            #if DEBUG
            BookPanelGripProbe.drawn[one.id] = nil
            BookPanelGripProbe.drawn[two.id] = nil
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 340, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer { window.orderOut(nil); window.close() }
            let hosting = NSHostingView(rootView: BookPanelView(
                session: session, postID: ids[0], membership: membership, model: model)
                .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 340, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            @MainActor func pump() async {
                for _ in 0..<8 {
                    hosting.layoutSubtreeIfNeeded()
                    window.displayIfNeeded()
                    try? await Task.sleep(for: .milliseconds(30))
                }
            }
            await pump()
            #if DEBUG
            #expect(BookPanelGripProbe.drawn[one.id] == false && BookPanelGripProbe.drawn[two.id] == false,
                    "entry-date order: neither chapter row draws its grip (drew \(String(describing: BookPanelGripProbe.drawn[one.id])), \(String(describing: BookPanelGripProbe.drawn[two.id])))")
            #endif

            // The same book, placed by hand: both grips draw.
            try ops.setReadingSort(book.id, field: .manual, direction: .asc)
            try await settle { model.manualOrder(for: book.id) }
            await pump()
            #if DEBUG
            #expect(BookPanelGripProbe.drawn[one.id] == true && BookPanelGripProbe.drawn[two.id] == true,
                    "manual order: both chapter rows draw their grips")
            #endif
        }
    }
}
