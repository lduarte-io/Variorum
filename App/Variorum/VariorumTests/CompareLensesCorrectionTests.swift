//
//  CompareLensesCorrectionTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch D — Compare + Lenses, MECHANICAL ONLY
//  (R-cor-6: the design is the memo; these pin the three mechanical rows).
//
//  Row 17 — the anchor column ALWAYS renders the note whole. Two mechanisms
//  emptied it: "related blocks only" (13c 2E) collapsed the anchor too, and
//  the body rendered the offer cards INSTEAD of the rows whenever no peer was
//  open. Both are gone: the model hands the whole anchor through the filter
//  (peers stay filtered by kinship — the pure brain is byte-unmodified), and
//  the rows render in every state. The card names a nameless note by its
//  day (`Queries.noteDisplayTitle`), never the literal "This note".
//
//  Row 46 — ONE placement per act, at any moment: "make outline note" is the
//  offer card while the band shows and the header door only while a peer is
//  open; "+ note" lives at the END of the header strip and only while no
//  empty slot stands (the dashed slot IS the add door until then).
//
//  Row 16 — one left edge for the toolbar, the header cards and the offer
//  cards; the add door at the strip's end at the header's height; on the
//  Lenses board the header cards sit over their panes, the toolbar on the
//  rows' edge, and the `＋ column` door at the header's height — never a
//  page-tall dashed column with its words floating mid-way down.
//
//  The geometry pins read the boards' DEBUG oracles (`CompareGeometry`,
//  `LensesGeometry` — the `MastheadGeometry` idiom: frames in the board's
//  own named space). The one-placement pins reflect the board's composition
//  (`SurfaceComposition` — a `Text` in an untaken branch is absent from the
//  dump, so a count is a count of what the board composes).
//
//  **Two limits of the reflection road, measured here and recorded beside
//  the ones `ProtectionSurfaceRenderTests` names:** (1) a `CalmCard { … }`
//  content closure and a `ForEach` body are OPAQUE to `dump` — a `Text`
//  inside either never appears; the anchor card and the offer cards are
//  therefore value views whose `title` is a stored property, and the dashed
//  slot (inside the peer-slot `ForEach`) is asserted through the geometry
//  oracle instead. (2) a view under `if` dumps as an `Optional(…)` whose
//  ONE-LINE description repeats every label inside it before the expanded
//  tree does — so a substring count over-counts by one per optional. The
//  counts below read whole `- title:` / `- verbatim:` LINES (the label as
//  the line's suffix), never substrings.
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
private func withBoardWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 46))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// The compare world every pin shares: an anchor (2 blocks), its
/// duplicate-as-version twin, an unrelated stranger.
@MainActor
private func makeCompareWorld(_ session: AppSession) async throws
    -> (anchor: String, twin: String, stranger: String)
{
    try await session.runner.run { ops in
        let anchor = try ops.createPost(title: "the piece")
        _ = try ops.newBlock(in: anchor.id, text: "First block of the piece.", at: .end)
        _ = try ops.newBlock(in: anchor.id, text: "Second block of the piece.", at: .end)
        let twin = try ops.duplicateAsVersion(anchor.id)
        let stranger = try ops.createPost(title: "unrelated")
        _ = try ops.newBlock(in: stranger.id, text: "Nothing to do with it.", at: .end)
        return (anchor.id, twin.post.id, stranger.id)
    }
}

@MainActor
private func adoptFresh(
    _ model: CompareViewModel, _ db: AppDatabase, anchor: String, peers: [String]
) async throws {
    model.adopt(try await db.read { db in
        try CompareViewModel.read(db, anchor: anchor, peers: peers)
    })
}

@MainActor
private func pump(_ seconds: TimeInterval = 0.03) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(
    _ window: NSWindow, _ hosting: NSView,
    until predicate: () -> Bool, maxTurns: Int = 80
) async {
    for _ in 0..<maxTurns {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        pump()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(20))
        if predicate() { return }
    }
}

/// How many times the board COMPOSES this exact label: the dump lines that
/// END with the quoted label (`- title: "…"` for a value view's stored title,
/// `- verbatim: "…"` for a bare `Text`'s storage). An `Optional(…)` node's
/// inline description repeats its labels mid-line and is deliberately not
/// counted.
private func occurrences(of label: String, in composition: String) -> Int {
    let quoted = String(reflecting: label)
    return composition.components(separatedBy: "\n").filter { $0.hasSuffix(quoted) }.count
}

// MARK: - Row 17: the anchor renders whole

@MainActor
@Suite("Compare's anchor renders whole (correction round, row 17)", .serialized)
struct CompareAnchorWholeTests {
    /// RED ON OLD: with no peer the offer cards stood in the rows' place
    /// (zero anchor rows); beside an unrelated peer the filter collapsed the
    /// anchor to nothing and the whole-board line spoke over empty columns.
    @Test func theAnchorRendersWholeWithNoPeerAndBesideAnUnrelatedPeer() async throws {
        try await withBoardWorld { session, db in
            let world = try await makeCompareWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            #expect(model.relatedOnly, "Compare opens filtered — #47(c)")

            // No peer at all: the default single empty slot (the first adopt
            // auto-fills the twin — cleared here, the auto-fill spent).
            try await adoptFresh(model, db, anchor: world.anchor, peers: [])
            model.setPeer(slotID: model.peerSlots[0].id, postID: nil)
            #expect(model.noPeerIsOpen)
            let alone = model.display
            #expect(alone.anchorHasBlocks, "the note is here")
            #expect(alone.rows.count == model.projection.anchor.slots.count,
                    "every anchor block renders with no peer (got \(alone.rows.count))")

            // An unrelated peer: the anchor stays whole; the peer column is
            // empty and SAYS so (the per-column line's condition).
            model.peerSlots = [.init(postID: world.stranger)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.stranger])
            let mixed = model.display
            #expect(mixed.isFiltered)
            #expect(mixed.anchorHasBlocks)
            #expect(mixed.rows.count == model.projection.anchor.slots.count,
                    "every anchor block renders beside a kin-less peer (got \(mixed.rows.count))")
            #expect(mixed.peerHasBlocks == [false], "the stranger contributes nothing — the column line fires")
            for row in mixed.rows {
                if case .free(let anchor, let peers, _) = row {
                    #expect(anchor != nil, "the anchor's block flows")
                    #expect(peers == [nil], "with an empty peer cell beside it")
                } else {
                    Issue.record("no kin exists, so no row can be aligned")
                }
            }

            // The filter OFF is 2E's byte-unchanged side: the stranger flows.
            model.relatedOnly = false
            #expect(model.display.peerHasBlocks == [true])
            model.teardown()
        }
    }

    /// RED ON OLD: `anchor.title ?? "This note"` — a nameless journal entry
    /// wore the literal. The ONE display rule (the masthead's) names it by
    /// its day; the peer cards and the Diff titles read the same rule.
    @Test func theAnchorCardNamesANamelessNoteByItsDayNeverThisNote() async throws {
        try await withBoardWorld { session, db in
            let entry = try await session.runner.run { ops in
                let post = try ops.createPost(title: nil, entryDate: "2026-08-27")
                _ = try ops.newBlock(in: post.id, text: "A day's writing.", at: .end)
                return post.id
            }
            let model = CompareViewModel(session: session, anchorPostID: entry)
            try await adoptFresh(model, db, anchor: entry, peers: [])
            #expect(model.projection.anchor.title == nil, "the note is genuinely nameless")
            #expect(model.projection.anchor.displayTitle == "2026-08-27",
                    "the display rule falls back to the entry's day")

            let board = CompareBoardView(session: session, postID: entry, model: model)
            let shown = SurfaceComposition.text(of: board.body)
            #expect(occurrences(of: "2026-08-27", in: shown) == 1,
                    "the anchor card names the note by its day")
            #expect(!SurfaceComposition.carries("This note", in: shown),
                    "the literal fallback is gone")
            model.teardown()
        }
    }
}

// MARK: - Row 46: one placement per act

@MainActor
@Suite("Compare offers each act ONCE (correction round, row 46)", .serialized)
struct CompareOnePlacementTests {
    /// RED ON OLD: "make outline note" composed TWICE with no peer (the
    /// toolbar button AND the offer card) and "+ note" stood in the toolbar
    /// beside a dashed empty slot that opens the same door.
    @Test func eachOfferActHasExactlyOnePlacementInEveryState() async throws {
        try await withBoardWorld { session, db in
            let world = try await makeCompareWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)

            // No peer: the offer band is the ONE outline door; the empty
            // slot's dashed door is the ONE add door.
            try await adoptFresh(model, db, anchor: world.anchor, peers: [])
            model.setPeer(slotID: model.peerSlots[0].id, postID: nil)  // stays empty; the auto-fill is spent
            let band = SurfaceComposition.text(
                of: CompareBoardView(session: session, postID: world.anchor, model: model).body)
            #expect(occurrences(of: "make outline note", in: band) == 1,
                    "one outline door while the band shows (got \(occurrences(of: "make outline note", in: band)))")
            #expect(occurrences(of: "⌕ compare with a note", in: band) == 1)
            #expect(occurrences(of: "+ note", in: band) == 0,
                    "an empty slot is the add door — no second one")
            // (The dashed slot's own door sits inside the peer-slot ForEach —
            // opaque to the dump; the geometry pin holds that half.)

            // One peer open: the header carries the outline door; the add
            // door stands at the strip's end (every slot filled, room left).
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.twin)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])
            #expect(model.addNoteDoorShows)
            let open = SurfaceComposition.text(
                of: CompareBoardView(session: session, postID: world.anchor, model: model).body)
            #expect(occurrences(of: "make outline note", in: open) == 1,
                    "one outline door while a peer is open (got \(occurrences(of: "make outline note", in: open)))")
            #expect(occurrences(of: "⌕ compare with a note", in: open) == 0, "the band is gone")
            #expect(occurrences(of: "+ note", in: open) == 1, "the add door, once")

            // A second, EMPTY slot added: its dashed door is the add door
            // again, so "+ note" yields.
            model.addPeerSlot()
            #expect(!model.addNoteDoorShows)
            let twoSlots = SurfaceComposition.text(
                of: CompareBoardView(session: session, postID: world.anchor, model: model).body)
            #expect(occurrences(of: "+ note", in: twoSlots) == 0)
            #expect(occurrences(of: "make outline note", in: twoSlots) == 1)
            model.teardown()
        }
    }
}

// MARK: - Row 16: the alignment, as geometry

@MainActor
@Suite("Compare + Lenses alignment (correction round, row 16)", .serialized)
struct CompareLensesAlignmentTests {
    private func window(_ size: NSSize) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: 80, y: 80), size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    /// RED ON OLD: the toolbar led at 16 pt, the header cards at 12, the
    /// offer cards centered on the page (~220 pt in at 1000 wide) — three
    /// left edges. And the "+ note" button lived in the toolbar (its top
    /// ~30 pt above the header cards); at the strip's end it shares the
    /// cards' top and stays inside the board.
    @Test func theToolbarTheHeaderCardsAndTheOfferCardsShareOneLeftEdgeAndTheAddDoorSitsAtTheStripsEnd() async throws {
        try await withBoardWorld { session, db in
            let world = try await makeCompareWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [])
            model.setPeer(slotID: model.peerSlots[0].id, postID: nil)

            #if DEBUG
            // Row 50: this pin's OWN board, named by its own session — a
            // concurrent suite's mount cannot answer for it.
            let compare = CompareGeometry.reader(session.debugProbeScope)
            compare.reset()
            #endif
            let size = NSSize(width: 1000, height: 700)
            let window = window(size)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: CompareBoardView(session: session, postID: world.anchor, model: model)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(origin: .zero, size: size)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            #if DEBUG
            await settle(window, hosting, until: {
                compare.frames[.toolbarLead] != nil
                    && compare.frames[.anchorCard] != nil
                    && compare.frames[.offerCard] != nil
            })
            let toolbar = try #require(compare.frames[.toolbarLead], "the toolbar reported")
            let anchorCard = try #require(compare.frames[.anchorCard], "the anchor card reported")
            let offer = try #require(compare.frames[.offerCard], "the offer card reported")
            #expect(abs(toolbar.minX - anchorCard.minX) <= 1,
                    "the toolbar (\(toolbar.minX)) and the header cards (\(anchorCard.minX)) share one left edge")
            #expect(abs(offer.minX - anchorCard.minX) <= 1,
                    "the offer cards (\(offer.minX)) lead at the same edge, never centered")
            #expect(compare.frames[.addNote] == nil,
                    "no add door while an empty slot stands — the dashed slot is the door")

            // A peer opens: the add door appears at the strip's END, at the
            // header's height, inside the board. (No reset here: the oracle
            // reports on CHANGE, and the board's own bounds do not change.)
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.twin)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])
            await settle(window, hosting, until: {
                compare.frames[.addNote] != nil
                    && compare.frames[.peerCard(0)] != nil
                    && compare.frames[.anchorCard] != nil
            })
            let board = try #require(compare.frames[.board], "the board reported its bounds")
            let addNote = try #require(compare.frames[.addNote], "the add door reported")
            let peerCard = try #require(compare.frames[.peerCard(0)], "the peer card reported")
            let anchorAgain = try #require(compare.frames[.anchorCard])
            #expect(abs(addNote.minY - anchorAgain.minY) <= 1,
                    "the add door's top (\(addNote.minY)) sits on the header cards' top (\(anchorAgain.minY))")
            #expect(addNote.minX >= peerCard.maxX, "…at the strip's end, past the last card")
            #expect(addNote.maxX <= board.width + 0.5, "…inside the board")
            #endif
            model.teardown()
        }
    }

    /// RED ON OLD: the `＋ column` stub filled the page's height (its two
    /// lines floating mid-way down — her image 9); the header cards sat
    /// ~17 pt LEFT of the panes under them (a 4-pt spacer stood in for the
    /// row's ⠿ + stripe gutter); the toolbar led at 24 while the rows led
    /// at 12.
    @Test func lensesHeaderCardsSitOverTheirPanesTheToolbarOnTheRowsEdgeAndTheStubAtTheHeadersHeight() async throws {
        try await withBoardWorld { session, _ in
            let post = try await session.runner.run { ops in
                let post = try ops.createPost(title: "a note with takes")
                _ = try ops.newBlock(in: post.id, text: "The first paragraph, which runs on long enough to wrap in a column.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "The second paragraph.", at: .end)
                return post.id
            }
            let suite = "CompareLensesCorrectionTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let model = TakesViewModel(session: session, postID: post, defaults: defaults)
            #expect(model.alignmentLocked, "the default layout is the registered one")
            let observing = Task { await model.start() }
            defer {
                model.teardown()
                observing.cancel()
            }

            #if DEBUG
            // Row 50: this pin's OWN board (see the compare arms above).
            let lenses = LensesGeometry.reader(session.debugProbeScope)
            lenses.reset()
            #endif
            let size = NSSize(width: 1000, height: 700)
            let window = window(size)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: LensesBoardView(session: session, postID: post, model: model)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(origin: .zero, size: size)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            #if DEBUG
            // ONE column: the stub is a header-height door at the strip's end.
            await settle(window, hosting, until: {
                lenses.frames[.stub] != nil
                    && lenses.frames[.headerCard(0)] != nil
                    && lenses.frames[.firstCell] != nil
            })
            let stub = try #require(lenses.frames[.stub], "the ＋ column door reported")
            let header = try #require(lenses.frames[.headerCard(0)], "the header card reported")
            #expect(abs(stub.minY - header.minY) <= 1,
                    "the door's top (\(stub.minY)) sits on the header card's top (\(header.minY))")
            #expect(stub.height <= header.height + 60,
                    "a header-height door (\(stub.height) pt tall against a \(header.height) pt card), never the page's height")

            // TWO columns: the header cards sit over their panes; the toolbar
            // leads where the rows lead. (No reset: the row's handle does not
            // move when a column is added, so it would never re-report; the
            // card and the pane DO move and re-report.)
            model.addScratchColumn()
            await settle(window, hosting, until: {
                lenses.frames[.toolbarLead] != nil
                    && lenses.frames[.headerCard(0)] != nil
                    && lenses.frames[.firstCell] != nil
                    && lenses.frames[.rowLead] != nil
            })
            let card = try #require(lenses.frames[.headerCard(0)], "the first header card reported")
            let cell = try #require(lenses.frames[.firstCell], "the first pane reported")
            let toolbar = try #require(lenses.frames[.toolbarLead], "the toolbar reported")
            let rowLead = try #require(lenses.frames[.rowLead], "the first row's handle reported")
            #expect(abs(card.minX - cell.minX) <= 1,
                    "the header card (\(card.minX)) sits over its pane (\(cell.minX))")
            #expect(abs(toolbar.minX - rowLead.minX) <= 1,
                    "the toolbar (\(toolbar.minX)) leads where the rows lead (\(rowLead.minX))")
            #endif
        }
    }
}

// MARK: - The Act 10 correction round, batch G — row 72

extension CompareLensesAlignmentTests {
    /// **Row 72 (the orchestrator's walk of D): the header strip's cards
    /// share ONE bottom edge.** The anchor card was two lines and a peer
    /// card three plus its doors, so the strip's bottom stepped. Every
    /// card stretches to the strip's height now, content top-aligned. RED
    /// ON OLD: the anchor card's bottom sat above the peer card's.
    @Test func theHeaderStripsCardsShareOneBottomEdge() async throws {
        try await withBoardWorld { session, db in
            let world = try await makeCompareWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.twin)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            #if DEBUG
            // Row 50: this pin's OWN board, named by its own session — a
            // concurrent suite's mount cannot answer for it.
            let compare = CompareGeometry.reader(session.debugProbeScope)
            compare.reset()
            #endif
            let size = NSSize(width: 1000, height: 700)
            let window = window(size)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: CompareBoardView(session: session, postID: world.anchor, model: model)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(origin: .zero, size: size)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            #if DEBUG
            await settle(window, hosting, until: {
                compare.frames[.anchorCard] != nil
                    && compare.frames[.peerCard(0)] != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let anchorCard = try #require(compare.frames[.anchorCard], "the anchor card reported")
            let peerCard = try #require(compare.frames[.peerCard(0)], "the peer card reported")
            #expect(abs(anchorCard.minY - peerCard.minY) <= 1,
                    "the cards share one top edge: \(anchorCard.minY) vs \(peerCard.minY)")
            #expect(abs(anchorCard.maxY - peerCard.maxY) <= 1,
                    "…and ONE bottom edge (the anchor \(anchorCard.maxY), the peer \(peerCard.maxY)) — the strip no longer steps")
            #expect(peerCard.height > 30, "the peer card is a real card (its doors laid out): \(peerCard.height)")
            #endif
            model.teardown()
        }
    }
}

// MARK: - VX-223 — the Lenses column doors pop at menu size

extension CompareLensesAlignmentTests {
    /// **VX-223** (her report: "Lenses dropdown text too small"). A column's
    /// doors — "⧉ Duplicate as Version" on the Chosen column, "⧉ Make this a
    /// note" on a lens — sit in a row carrying `.controlSize(.mini)`, and the
    /// menus inherited it: their popped rows drew at the mini 9 pt. RED ON
    /// OLD by that mechanism; the class lives in `ChromeMenuRowSizeTests`.
    @Test func theColumnDoorMenusPopAtMenuSize() async throws {
        try await withBoardWorld { session, _ in
            let post = try await session.runner.run { ops in
                let post = try ops.createPost(title: "a note with takes")
                _ = try ops.newBlock(in: post.id, text: "The first paragraph.", at: .end)
                return post.id
            }
            let suite = "CompareLensesCorrectionTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let model = TakesViewModel(session: session, postID: post, defaults: defaults)
            let observing = Task { await model.start() }
            defer {
                model.teardown()
                observing.cancel()
            }
            #if DEBUG
            let lenses = LensesGeometry.reader(session.debugProbeScope)
            lenses.reset()
            #endif
            let size = NSSize(width: 1000, height: 700)
            let window = window(size)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: LensesBoardView(session: session, postID: post, model: model)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(origin: .zero, size: size)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            // The Chosen column plus a lens — both kinds of column door.
            model.addScratchColumn()
            #if DEBUG
            await settle(window, hosting, until: {
                lenses.frames[.headerCard(0)] != nil && lenses.frames[.headerCard(1)] != nil
            })
            #endif
            await settle(window, hosting, until: { false }, maxTurns: 10)
            let sizes = ChromeMenuProbe.rowSizes(in: hosting)
            #expect(sizes.count >= 2, "both columns' doors are pop-ups underneath (\(sizes))")
            #expect(sizes.allSatisfy { $0 >= ChromeMenuProbe.menuSize },
                    "every popped row reads at menu size, never mini: \(sizes)")
        }
    }
}
