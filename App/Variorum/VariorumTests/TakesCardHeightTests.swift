//
//  TakesCardHeightTests.swift
//  VariorumTests
//
//  QoL round 2026-07-29, batch 2 (L3 · L4) — the takes styles on LONG
//  blocks. Her reports:
//
//    L3 "the takes mode is not as useful as it needs to be on long
//        blocks. on the slot split mode it's limited in height - you
//        shoudl be able to see it at full length for that mode i think.
//        maybe the height of the block should even be draggable?"
//    L4 "equally, for margin grid, even when there is a long block, the
//        margin grid note is sticky note sized which isn't that helpful
//        for long blocks"
//
//  The shipped rule was ONE fixed card height (110) for carousel, slot
//  split AND the margin rail — S4-31b/N40's "the strip never changes
//  height as takes differ or pages turn". The sitting SUPERSEDED it FOR
//  SLOT SPLIT ONLY (full length + a shorten-drag) and capped the margin
//  card at 330 (3 × the card height) instead of pinning it. Carousel and
//  the rail's short-block strip keep the ruled 110 BYTE-UNCHANGED, and
//  that parity had never been pinned by anything — this suite creates it.
//
//  Measurement discipline, adopted from batch 1 verbatim: *"a pin for a
//  feature reached by input must be driven through an input path, or it
//  is a pin on our arithmetic, not on her experience."* Every hosted pin
//  here measures what a READER can see — `visibleRect.height` against
//  `PaneMeasurement.height` — never a constant we chose.
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
@Suite("Take card heights on long blocks (QoL batch 2 — L3 · L4)", .serialized)
struct TakesCardHeightTests {

    // MARK: - Harness (the TakesRailPagingTests board-hosting pattern)

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    /// The fan CARDS' panes only (`role: "mini"` — the article cell is
    /// `"article"`, the stack's cards are `"card"`).
    private func cardPanes(in view: NSView) -> [PaneTextView] {
        panes(in: view).filter { $0.identifier?.rawValue.hasPrefix("pane:mini|") == true }
    }

    /// Every NSScrollView between a pane and the hosting root, nearest
    /// first — how the composition's clipping is read without guessing.
    private func scrollAncestors(of view: NSView, upTo root: NSView) -> [NSScrollView] {
        var found: [NSScrollView] = []
        var current: NSView? = view.superview
        while let node = current, node != root {
            if let scroll = node as? NSScrollView { found.append(scroll) }
            current = node.superview
        }
        return found
    }

    /// A post with ONE fanned block whose takes are as long as asked.
    private struct Fixture {
        let postID: String
        let blockID: String
        let variantIDs: [String]
    }

    /// R24's strip rule is a pure character threshold (<200), so a "short"
    /// fixture has to be genuinely short — the first version of this suite
    /// used one PARAGRAPH of the long text, which is ~208 chars and 165 pt
    /// tall, and three pins failed for saying "short" while meaning "less
    /// long". Recorded because it is the fixture-honesty class.
    static let shortTake = "one honest line of prose."

    private func makeFixture(
        session: AppSession, style: FanStyle, takes: Int, paragraphs: Int,
        text explicitText: String? = nil
    ) throws -> Fixture {
        let text = explicitText ?? (1...paragraphs).map { i in
            "Paragraph \(i). " + Array(
                repeating: "honest prose words keep flowing along the measured line and wrap",
                count: 3
            ).joined(separator: " ") + "."
        }.joined(separator: "\n\n")
        let post = try session.operations.createPost(title: "long block fixture")
        let minted = try session.operations.newBlock(in: post.id, text: text)
        var ids = [minted.variant.id]
        for n in 2...max(takes, 1) where takes > 1 {
            let take = try session.operations.branchVariant(
                minted.block.id, from: minted.variant.id)
            try session.operations.autosave(take.id, text: text + "\n\ntake \(n).", charDelta: 9)
            ids.append(take.id)
        }
        try session.operations.setFanStyle(style)
        return Fixture(postID: post.id, blockID: minted.block.id, variantIDs: ids)
    }

    /// Mount the real board on the fixture, bloom the block, and hand the
    /// body the mounted host.
    private func withBoard(
        style: FanStyle, takes: Int = 2, paragraphs: Int = 14,
        text: String? = nil,
        gridRows: Int = 2, gridCols: Int = 1, seed: UInt64 = 42,
        _ body: @MainActor (
            _ hosting: NSHostingView<TakesBoardView>, _ window: NSWindow,
            _ model: TakesViewModel, _ fixture: Fixture
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let defaults = UserDefaults.standard
        let savedRows = defaults.object(forKey: "takesGridRows")
        let savedCols = defaults.object(forKey: "takesGridCols")
        defaults.set(gridRows, forKey: "takesGridRows")
        defaults.set(gridCols, forKey: "takesGridCols")
        defer {
            if let savedRows { defaults.set(savedRows, forKey: "takesGridRows") }
            else { defaults.removeObject(forKey: "takesGridRows") }
            if let savedCols { defaults.set(savedCols, forKey: "takesGridCols") }
            else { defaults.removeObject(forKey: "takesGridCols") }
        }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let fixture = try makeFixture(
                session: session, style: style, takes: takes, paragraphs: paragraphs,
                text: text)
            // A PRIVATE defaults domain per mount. Two reasons, both found
            // by this suite failing: slot heights PERSIST, so a pin that
            // drags would otherwise write into her real `.standard`
            // defaults; and `$0.uuid = .incrementing` gives every test the
            // SAME postID, so one pin's stored height silently capped a
            // later pin's cards (it turned a green pin red only once a
            // neighbour started dragging).
            let model = TakesViewModel(
                session: session, postID: fixture.postID,
                defaults: freshBoardDefaults("board"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            #expect(model.projection.fanStyle == style, "the store carries the style under test")
            defer { model.teardown() }

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1400, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(
                    session: session, postID: fixture.postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1400, height: 900)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !panes(in: hosting).isEmpty })
            model.toggleExpanded(fixture.blockID)
            await settle(window, hosting, until: { !cardPanes(in: hosting).isEmpty })
            // The published heights land a turn after the first layout
            // (the accepted first-bloom settle) — give them their turns.
            await settle(window, hosting, until: { false }, maxTurns: 6)
            try await body(hosting, window, model, fixture)
        }
    }

    // MARK: - PARITY (green on both sides — labelled CHARACTERIZATION):
    // carousel and the rail's short-block strip keep the RULED 110

    /// **CHARACTERIZATION — green before and after, by design.** The
    /// sitting superseded S4-31b's one-fixed-strip-height rule FOR SLOT
    /// SPLIT ONLY; carousel keeps it. Nothing in the suite pinned
    /// carousel's height before this batch (`railCardHeight` and the
    /// literal 110 appeared in ZERO test files), so the rule it keeps was
    /// unguarded — this pin is that guard, created here.
    ///
    /// Measured semantically, not by a constant we chose: a capped card
    /// wraps its pane in a vertical ScrollView, so the pane's NEAREST
    /// scroll ancestor is that in-card clip and its height is the card's
    /// text room. Uncapping removes the wrapper entirely, which is exactly
    /// what the slot-split pin below asserts.
    @Test func carouselKeepsTheRuledFixedCardHeight() async throws {
        try await withBoard(style: .carousel, takes: 2, paragraphs: 14) { hosting, _, model, _ in
            guard let card = cardPanes(in: hosting).first,
                  let clip = scrollAncestors(of: card, upTo: hosting).first else {
                Issue.record("no carousel card / no in-card clip")
                return
            }
            let measured = PaneMeasurement.height(of: card)
            #expect(measured > 500, "the fixture take is genuinely long (\(measured))")
            #expect(clip.bounds.height <= TakesBoardLayout.railCardHeight,
                    "carousel's card still caps at one card-height (clip \(clip.bounds.height))")
            #expect(scrollAncestors(of: card, upTo: hosting).count == 3,
                    "carousel keeps its in-card vertical clip inside the strip inside the article")
            // The seam's other parity half: carousel subscribes to NOTHING,
            // so its invalidation profile is untouched by this batch.
            #expect(model.measuredHeightWrites == 0,
                    "no measured-height delivery reaches the board in carousel (saw \(model.measuredHeightWrites))")
        }
    }

    /// **CHARACTERIZATION — green on both sides.** R24's one-card-high
    /// strip for a SHORT fanned block at density "1 high" is untouched by
    /// L4: it is the shape her report explicitly did not complain about.
    @Test func theRailShortBlockStripKeepsItsOneCardHeight() async throws {
        // Under 200 chars ⇒ `usesHorizontalStrip`; gridRows 1 ⇒ the strip.
        try await withBoard(
            style: .marginGrid, takes: 2, paragraphs: 1, text: Self.shortTake, gridRows: 1
        ) { hosting, _, model, _ in
            #expect(TakesBoardLayout.usesHorizontalStrip(text: Self.shortTake),
                    "the fixture really is R24's short block (the <200-char rule)")
            guard let card = cardPanes(in: hosting).first else {
                Issue.record("no rail card")
                return
            }
            #expect(card.bounds.height <= TakesBoardLayout.railCardHeight,
                    "a short block's strip card is still one card-height (pane \(card.bounds.height))")
        }
    }

    // MARK: - L3 — slot split at FULL LENGTH (RED on the shipped code)

    /// **RED ON SHIPPED.** Her report: *"on the slot split mode it's
    /// limited in height - you shoudl be able to see it at full length."*
    /// Measured on the shipped build: a 2,081-pt take showed **84 pt** —
    /// four lines — with the rest reachable only by scrolling inside a
    /// sticky-note-sized card.
    ///
    /// The assertion is the composition, not a number we picked: an
    /// uncapped card has NO in-card vertical clip, so the pane's nearest
    /// scroll ancestor is the strip itself and the strip is at least as
    /// tall as the take's full measured height — i.e. the take is laid out
    /// at full length in the flow, and ordinary article scrolling reaches
    /// all of it.
    ///
    /// DISCRIMINATING REVERT: pass `Self.railCardHeight` for slot split in
    /// `slotSplitBloom` ⇒ this fails and `carouselKeepsTheRuledFixedCardHeight`
    /// still passes.
    @Test func slotSplitShowsALongTakeAtFullLength() async throws {
        try await withBoard(style: .slotSplit, takes: 2, paragraphs: 14) { hosting, _, _, _ in
            guard let card = cardPanes(in: hosting).first,
                  let nearest = scrollAncestors(of: card, upTo: hosting).first else {
                Issue.record("no slot-split card mounted")
                return
            }
            let measured = PaneMeasurement.height(of: card)
            #expect(measured > 500, "the fixture take is genuinely long (\(measured))")
            #expect(scrollAncestors(of: card, upTo: hosting).count == 2,
                    "the in-card vertical clip is GONE — the card is the take's full height")
            #expect(nearest.bounds.height >= measured,
                    "the strip holds the take at full length (strip \(nearest.bounds.height) vs take \(measured)) — on the shipped code the clip was 84 pt")
        }
    }

    /// **RED ON SHIPPED** (no such API existed). L3's second half: *"maybe
    /// the height of the block should even be draggable?"* — per BLOCK,
    /// clamped, and remembered on this Mac.
    ///
    /// DISCRIMINATING REVERT: drop `saveSlotHeights()` from
    /// `slotDragEnded` ⇒ only the reopen assertion fails.
    @Test func theShortenDragClampsAndIsRememberedPerBlock() async throws {
        let defaults = freshBoardDefaults("slot-drag")
        let layout = TakesBoardLayout(postID: "post-1", defaults: defaults)
        #expect(layout.slotHeight("block-A") == nil, "full length is the default (L3's ruling)")

        // A shorten drag, from a natural height of 900.
        layout.beginSlotDrag("block-A", naturalHeight: 900)
        layout.slotDragChanged("block-A", translation: -500)
        #expect(layout.slotHeight("block-A", naturalHeight: 900) == 400,
                "the live drag shows exactly what it will commit")
        layout.slotDragEnded("block-A", translation: -500, naturalHeight: 900)
        #expect(layout.slotHeight("block-A", naturalHeight: 900) == 400)
        #expect(layout.slotHeight("block-B") == nil, "per BLOCK — its neighbour is untouched")

        // Remembered: a fresh board on the same defaults reopens shortened.
        let reopened = TakesBoardLayout(postID: "post-1", defaults: defaults)
        #expect(reopened.slotHeight("block-A") == 400,
                "the shorten survives the view being rebuilt (LOCAL memory, never synced)")
        #expect(TakesBoardLayout(postID: "post-2", defaults: defaults).slotHeight("block-A") == nil,
                "…and it is scoped to its own post")

        // "Full length" — the double-click / reset door.
        reopened.resetSlotHeight("block-A")
        #expect(reopened.slotHeight("block-A") == nil)
        #expect(TakesBoardLayout(postID: "post-1", defaults: defaults).slotHeight("block-A") == nil,
                "the reset persists too")
    }

    /// The clamp brain alone (the `CanvasBoardGeometry.clampedSize`
    /// precedent — pure, no hosting).
    @Test func theSlotHeightClampFloorsAtOneCardAndReleasesAtNatural() {
        let natural: CGFloat = 900
        #expect(TakesBoardLayout.clampedSlotHeight(20, naturalHeight: natural)
                == TakesBoardLayout.railCardHeight,
                "below one card-height the in-card scroll is useless — it floors")
        #expect(TakesBoardLayout.clampedSlotHeight(400, naturalHeight: natural) == 400)
        #expect(TakesBoardLayout.clampedSlotHeight(900, naturalHeight: natural) == nil,
                "dragging back to natural IS how full length comes back")
        #expect(TakesBoardLayout.clampedSlotHeight(2000, naturalHeight: natural) == nil,
                "…and past it, likewise — never a card taller than its text")
        #expect(TakesBoardLayout.clampedSlotHeight(2000, naturalHeight: nil) == 2000,
                "with nothing measured yet there is no ceiling to release at")
    }

    /// **RED ON SHIPPED** (shortening did not exist): a shortened slot
    /// re-enters the EXISTING `capped` in-card-scroll machinery, so no
    /// part of the take becomes unreachable (the AD-2 law).
    @Test func aShortenedSlotReEntersTheInCardScroll() async throws {
        try await withBoard(style: .slotSplit, takes: 2, paragraphs: 14) {
            hosting, window, model, fixture in
            model.board.slotDragEnded(
                fixture.blockID, translation: -10_000, naturalHeight: 900)
            #expect(model.slotHeight(fixture.blockID) == TakesBoardLayout.railCardHeight,
                    "the drag floored at one card-height")
            await settle(window, hosting, until: { false }, maxTurns: 6)
            guard let card = cardPanes(in: hosting).first,
                  let clip = scrollAncestors(of: card, upTo: hosting).first else {
                Issue.record("no card / no clip after shortening")
                return
            }
            #expect(scrollAncestors(of: card, upTo: hosting).count == 3,
                    "the in-card vertical clip is BACK — the existing capped machinery")
            #expect(clip.bounds.height <= TakesBoardLayout.railCardHeight,
                    "…bounded by the height she dragged to (clip \(clip.bounds.height))")
            #expect(PaneMeasurement.height(of: card) > 500,
                    "and the whole take is still there, reachable by scrolling in the card")
        }
    }

    /// AD-7's SLAB LAW under the new drag: a cap or a drag frames the
    /// CARD, never the pane. A stored height far taller than a one-line
    /// take must not stretch the pane into a slab.
    @Test func aStoredSlotHeightNeverStretchesThePaneIntoASlab() async throws {
        try await withBoard(style: .slotSplit, takes: 2, paragraphs: 1, text: Self.shortTake) {
            hosting, window, model, fixture in
            model.board.slotDragEnded(
                fixture.blockID, translation: 0, naturalHeight: nil)
            model.board.slotDragEnded(
                fixture.blockID, translation: 400, naturalHeight: nil)
            await settle(window, hosting, until: { false }, maxTurns: 6)
            guard let card = cardPanes(in: hosting).first else {
                Issue.record("no card")
                return
            }
            #expect(card.bounds.height < 120,
                    "a one-line pane under a tall card frame hugs its text (pane \(card.bounds.height)) — never the slab")
        }
    }

    // MARK: - L4 — the margin card grows to the RULED cap

    /// **RED ON SHIPPED.** Her report: *"for margin grid, even when there
    /// is a long block, the margin grid note is sticky note sized which
    /// isn't that helpful for long blocks."* Measured on the shipped
    /// build: 84 pt of visible prose. After: the RULED cap (330 − chrome).
    ///
    /// DISCRIMINATING REVERT: put `Self.railCardHeight` back as the card's
    /// height in `railCards` ⇒ this fails and the short-card pin below
    /// still passes.
    @Test func aMarginCardGrowsWithItsContentToTheCap() async throws {
        try await withBoard(style: .marginGrid, takes: 2, paragraphs: 14) { hosting, _, _, _ in
            guard let card = cardPanes(in: hosting).first,
                  let clip = scrollAncestors(of: card, upTo: hosting).first else {
                Issue.record("no rail card / no clip")
                return
            }
            let measured = PaneMeasurement.height(of: card)
            #expect(measured > TakesBoardLayout.marginCardCapHeight,
                    "the fixture take genuinely outgrows the cap (\(measured))")
            #expect(clip.bounds.height > TakesBoardLayout.railCardHeight * 2,
                    "the margin card grew well past the sticky note (clip \(clip.bounds.height)) — it was 84 pt on the shipped build")
            #expect(clip.bounds.height <= TakesBoardLayout.marginCardCapHeight,
                    "…and stops at the RULED cap (clip \(clip.bounds.height))")
            #expect(scrollAncestors(of: card, upTo: hosting).count == 3,
                    "beyond the cap the content still SCROLLS in place — nothing unreachable")
        }
    }

    /// **RED on a naive fix** (a flat taller card): a one-line take's
    /// margin card must NOT grow to the cap. Padding every card to 330
    /// would "fix" her long-block report by reintroducing exactly the dead
    /// space A47 was about.
    @Test func aShortTakesMarginCardStaysASticky() async throws {
        try await withBoard(
            style: .marginGrid, takes: 2, paragraphs: 1, text: Self.shortTake
        ) { hosting, _, _, _ in
            guard let card = cardPanes(in: hosting).first,
                  let clip = scrollAncestors(of: card, upTo: hosting).first else {
                Issue.record("no rail card / no clip")
                return
            }
            #expect(PaneMeasurement.height(of: card) < TakesBoardLayout.railCardHeight,
                    "the fixture take really is short")
            #expect(clip.bounds.height <= TakesBoardLayout.railCardHeight,
                    "a short take keeps the sticky note — no dead space (clip \(clip.bounds.height))")
        }
    }

    /// L4's reserve: ACTUAL heights bounded by the cap, and — the property
    /// that had to survive the change to variable heights —
    /// **page-independent**, so ◀ ▶ never move the article.
    @Test func theRailReserveIsCapBoundedAndPageIndependent() {
        // No measurements yet ⇒ byte-identical to the uniform arithmetic
        // it replaces (min(cards, rows) × 110 + gaps).
        let card = TakesBoardLayout.railCardHeight
        let gap = TakesBoardLayout.cardGap
        let uniformTwoHigh: CGFloat = card * 2 + gap
        #expect(TakesBoardLayout.reservedRailHeight(
            cardTextHeights: [nil, nil, nil], rowsPerColumn: 2) == uniformTwoHigh,
                "the pre-measurement fallback IS the old arithmetic")
        #expect(TakesBoardLayout.reservedRailHeight(
            cardTextHeights: [nil], rowsPerColumn: 2) == 110,
                "never an empty reserve below a 1-take fan (the AD-6 property)")

        // Variable heights: the reserve is the TALLEST column, whichever
        // page is showing — the steadiness property, which is exactly what
        // could have been lost by deriving the reserve from visible cards.
        let ragged: [CGFloat?] = [40, 900, 40, 40, 40, 40]
        let reserve = TakesBoardLayout.reservedRailHeight(
            cardTextHeights: ragged, rowsPerColumn: 2)
        let tallestColumn: CGFloat = TakesBoardLayout.marginCardCapHeight + card + gap
        #expect(reserve == tallestColumn,
                "the tallest column: one capped card + one sticky note + the gap (got \(reserve))")
        for rotation in 1..<ragged.count {
            let paged = Array(ragged[rotation...] + ragged[..<rotation])
            #expect(TakesBoardLayout.reservedRailHeight(
                cardTextHeights: paged, rowsPerColumn: 2) <= reserve,
                    "no page ordering can exceed the reserve the article already made room for")
        }
        #expect(TakesBoardLayout.marginCardHeight(measuredText: 10_000)
                == TakesBoardLayout.marginCardCapHeight,
                "a card never exceeds the cap, however long the take")
    }

    // MARK: - Safety: convergence, settle, and the P1 claim

    /// The RULING's REQUIRED spot-check. Uncapping removes the wrapper the
    /// A47/A47b machinery reasoned about, so the question is whether an
    /// uncapped tall pane still converges — frame == measurement — through
    /// the events that reach it: a liveness flip (the ring arriving) and a
    /// scroll-end occasion.
    @Test func anUncappedSlotSplitPaneStaysConvergedThroughItsOccasions() async throws {
        try await withBoard(style: .slotSplit, takes: 2, paragraphs: 14) {
            hosting, window, model, fixture in
            guard let card = cardPanes(in: hosting).first,
                  let variantID = card.identifier?.rawValue
                    .replacingOccurrences(of: "pane:mini|", with: "") else {
                Issue.record("no slot-split card")
                return
            }
            @MainActor func converged() -> Bool {
                abs(card.bounds.height - PaneMeasurement.height(of: card))
                    <= PanePublisher.convergenceSlack
            }
            #expect(converged(), "an uncapped tall pane mounts converged")

            // The ring arrives — a real liveness transition through the model.
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesBoardView.fanColumnID,
                blockID: fixture.blockID, variantID: variantID))
            await settle(window, hosting, until: { false }, maxTurns: 6)
            #expect(card.occasionsFired > 0, "the liveness WIRE fired on the uncapped pane")
            #expect(converged(),
                    "…and it stays converged (frame \(card.bounds.height) vs measured \(PaneMeasurement.height(of: card)))")

            // Scroll-end: the occasion now arrives from the STRIP's scroll
            // view (uncapping moved `enclosingScrollView` off the in-card
            // clip) — the wire the ruling asked to be checked, not assumed.
            guard let enclosing = card.enclosingScrollView else {
                Issue.record("an uncapped pane has no enclosing scroll view to observe")
                return
            }
            let before = card.convergenceChecksRun
            NotificationCenter.default.post(
                name: NSScrollView.didEndLiveScrollNotification, object: enclosing)
            #expect(card.convergenceChecksRun > before,
                    "scroll-end still runs the divergence check on an uncapped pane")
            await settle(window, hosting, until: { false }, maxTurns: 4)
            #expect(converged(), "and the occasion leaves it converged")
        }
    }

    /// The seam SETTLES: deliveries converge to one write per card and
    /// stop. (The termination argument made mechanical — a delivery can
    /// change only the wrapper height, and the pane's measurement is
    /// width-driven, so the sequence has a fixed point.)
    @Test func theMeasuredHeightSeamSettles() async throws {
        try await withBoard(style: .marginGrid, takes: 3, paragraphs: 14) {
            hosting, window, model, _ in
            let cards = cardPanes(in: hosting).count
            #expect(cards > 0)
            let afterMount = model.measuredHeightWrites
            #expect(afterMount > 0, "the seam delivered at all (\(afterMount))")
            await settle(window, hosting, until: { false }, maxTurns: 12)
            #expect(model.measuredHeightWrites == afterMount,
                    "twelve further turns add ZERO writes — the gate holds and the board stops re-rendering (\(afterMount) → \(model.measuredHeightWrites))")
        }
    }

    /// The seam's DEFERRAL contract, pinned mechanically — the "stronger
    /// arm" the standing rule demands, because the obvious revert (deliver
    /// synchronously) went GREEN on every other pin here.
    ///
    /// Recorded honestly with it: making delivery synchronous did **not**
    /// measurably raise SwiftUI's "Modifying state during view update"
    /// count in these suites (44 either way — they come from pre-existing
    /// board machinery, and the seam adds none in either mode). So the
    /// deferral's justification is not a warning count; it is the
    /// contract this pin states — the publish it rides fires inside
    /// SwiftUI updates by design (the width-gated layout hook,
    /// `updateNSView`'s adopt-remeasure), and a composer's `@Observable`
    /// write there is the dropped/undefined-write class `PanePublisher`
    /// exists for. A composer must never be handed a height mid-update
    /// even when today's composer happens to survive it.
    ///
    /// RED on a synchronous delivery (verified by behavioral revert).
    @Test func theMeasuredHeightSeamNeverDeliversInsideALayoutPass() async {
        let text = (1...12).map { "paragraph number \($0) of honest prose" }
            .joined(separator: "\n")
        let insideLayout = LockIsolated(0)
        let delivered = LockIsolated(0)
        let layingOut = LockIsolated(false)
        let host = NSHostingController(
            rootView: PaneSurfaceView(
                text: text, isLive: false,
                onMeasuredHeight: { _ in
                    delivered.withValue { $0 += 1 }
                    if layingOut.value { insideLayout.withValue { $0 += 1 } }
                }
            ).frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 700),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 420, height: 700)
        defer { window.contentViewController = nil }

        // Every layout pass the mount needs, flagged: a delivery that
        // lands while `layingOut` is true came out synchronously from
        // inside the pass, which is precisely what must never happen.
        for _ in 0..<6 {
            layingOut.setValue(true)
            host.view.layoutSubtreeIfNeeded()
            layingOut.setValue(false)
            pump(0.02)
            await Task.yield()
        }
        // A width change — the publish trigger with the clearest
        // inside-a-layout-pass shape.
        layingOut.setValue(true)
        host.view.frame = NSRect(x: 0, y: 0, width: 380, height: 700)
        host.view.layoutSubtreeIfNeeded()
        layingOut.setValue(false)
        pump(0.05)
        await Task.yield()
        pump(0.05)

        #expect(delivered.value > 0,
                "the seam delivered at all (\(delivered.value)) — otherwise this pin is vacuous")
        #expect(insideLayout.value == 0,
                "no measured height is handed to the composer from inside a layout pass (saw \(insideLayout.value) of \(delivered.value))")
    }

    /// T4's measured fact, asserted rather than trusted: **the cap saved
    /// DRAW, not LAYOUT.** `PaneMeasurement` runs a full-document
    /// `ensureLayout` per pane either way, so uncapping adds drawn area and
    /// scroll extent — never new layout work. If this ever fails, the P1
    /// argument for L3 has changed and the batch record's claim is stale.
    @Test func paneMeasurementIsIndependentOfCapping() async throws {
        var byStyle: [FanStyle: CGFloat] = [:]
        for style in [FanStyle.carousel, .slotSplit] {
            try await withBoard(style: style, takes: 2, paragraphs: 14) { hosting, _, _, _ in
                guard let card = cardPanes(in: hosting).first else {
                    Issue.record("\(style): no card")
                    return
                }
                byStyle[style] = PaneMeasurement.height(of: card)
            }
        }
        guard let capped = byStyle[.carousel], let uncapped = byStyle[.slotSplit] else {
            Issue.record("missing measurements")
            return
        }
        #expect(abs(capped - uncapped) <= 1,
                "the same take measures the same capped (\(capped)) or not (\(uncapped))")
    }
}

/// A private defaults domain per pin — slot heights persist, so a pin
/// writing `.standard` would leak into her real app and into its neighbours.
@MainActor
private func freshBoardDefaults(_ name: String) -> UserDefaults {
    let suite = "TakesCardHeightTests.\(name).\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}
