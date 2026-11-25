//
//  StatusToastCardsBandTests.swift
//  VariorumTests
//
//  VX-1070 (the VX-1082 run, batch D; `notes/plans/fixes/vx-1082-nov-24-fixes.md`
//  BATCH D) — **a toast over the Bookcase sits ABOVE the cards band, never on
//  it.** Seen at the VX-981 closing walk: while a card shows (the tour offer,
//  the twelve-words card), a toast hides the card's sentence and most of its
//  click target for the seconds it stays.
//
//  THE MECHANISM (traced in the record): the one toast host lifts the toast
//  above every band that marks itself `statusToastKeepClear()` (VX-121,
//  `StatusToastPlacement`), and only the quick entry marked itself — the
//  cards band directly above it did not, so the toast landed just above the
//  quick entry: on the cards.
//
//  THE PIN mounts the REAL Bookcase (`ShelfView`) with a real tour-offer card
//  (`TourOfferCard` over its own model) and a words-card stand-in of a card's
//  height in the band (the real words card is Castle's; the pin is about the
//  BAND, the `TourOfferCardTests` precedent), under the SAME toast host the
//  shell composes (`statusToastHost`), puts a refusal up, and reads the
//  toast's card against both cards and the quick entry, in one `.global`
//  space. **Red on old** (the fix commit's product diff reverse-applied): the
//  toast sits just above the quick entry — over the words card (the first
//  three expectations in the two-card case, the first two in the one-card
//  case). The no-card case is a GUARD, green on both trees: with no card the
//  toast still sits just above the quick entry, as VX-121 placed it.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

#if DEBUG
/// A words card's stand-in: a card's height in the band, reporting its frame
/// (the `TourOfferCardTests` stand-in's shape, kept file-private here).
private struct CardStandIn: View {
    @MainActor static var frames: [UUID: CGRect] = [:]
    let id: UUID

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { [id] frame in
                CardStandIn.frames[id] = frame
            }
            .padding(.horizontal, 28)
            .padding(.top, 4)
            .padding(.bottom, 8)
    }
}
#endif

@MainActor
@Suite("VX-1070 — a toast over the Bookcase sits above the cards band", .serialized)
struct StatusToastCardsBandTests {
    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, turns: Int = 200, until predicate: () -> Bool
    ) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    private struct Read {
        let toast: CGRect
        /// The cards' own frames, top to bottom (the offer card's paper, the
        /// stand-in's).
        let cards: [CGRect]
        let entry: CGRect
    }

    /// The Bookcase in a 900 × 640 window under the shell's toast host, with
    /// the offer card (`offer`) and/or the words stand-in (`words`) in its
    /// band, a refusal up; hands the body the toast and the band's frames.
    private func withAToastOverTheBookcase(
        offer withOffer: Bool, words withWords: Bool, _ body: (Read) throws -> Void
    ) async throws {
        #if DEBUG
        let suite = "vx1070-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            session.status.dismissAfter = .seconds(60)
            _ = try session.operations.createReading(name: "alpha", kind: .book)
            let shelf = ShelfViewModel(session: session, defaults: defaults)
            let offer = TourOfferModel(defaults: defaults, helpRoadDuration: .seconds(60))
            let standIn = UUID()
            StatusToastOracle.forget()
            BookcaseRowOracle.forgetAll()

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 640),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: ShelfView(
                session: session, model: shelf,
                readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {},
                offerCard: withOffer ? AnyView(TourOfferCard(model: offer) {}) : nil,
                wordsBand: withWords ? AnyView(CardStandIn(id: standIn)) : nil)
                // The shell's ONE toast host (`RootView`'s pane row), as composed there.
                .statusToastHost(session.status, tokens: .fallback(for: .light)))
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                session.status.clear()
                window.orderOut(nil)
                window.close()
                CardStandIn.frames[standIn] = nil
            }

            @MainActor func cards() -> [CGRect] {
                [withOffer ? TourOfferCardOracle.cardFrame(for: offer) : nil,
                 withWords ? CardStandIn.frames[standIn] : nil].compactMap { $0 }
            }
            let expected = (withOffer ? 1 : 0) + (withWords ? 1 : 0)
            await settle(window, hosting) {
                cards().count == expected
                    && BookcaseRowOracle.frame(BookcaseRowOracle.entryKey, in: session) != nil
                    && (!withOffer || TourOfferCardOracle.drawn(for: offer) == .offer)
            }
            await settle(window, hosting, turns: 20) { false }

            session.status.refuse(
                "Nothing was imported — “field notes.md” line 12 starts a take with no block above it.")
            await settle(window, hosting) { StatusToastOracle.frame != nil }
            await settle(window, hosting, turns: 20) { false }
            let toast = try #require(StatusToastOracle.frame, "the toast drew")
            let entry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey, in: session))
            let band = cards()
            #expect(band.count == expected, "premise: every card drew in the band (\(band))")
            print("[VX-1070 toast vs cards] offer \(withOffer) words \(withWords) · toast \(toast) · cards \(band) · entry \(entry)")
            try body(Read(toast: toast, cards: band.sorted { $0.minY < $1.minY }, entry: entry))
        }
        #endif
    }

    /// The card's gutter above its paper (`TourOfferCard`/`WordsBandCard`:
    /// `.padding(.top, 4)`), so "just above the band" is read from the paper.
    private static let cardTopGutter: CGFloat = 4

    private func expectAboveTheCards(_ read: Read, _ surface: String) {
        guard let top = read.cards.first else {
            Issue.record("\(surface): no card to read")
            return
        }
        for card in read.cards {
            #expect(read.toast.maxY <= card.minY, """
                \(surface): the toast never covers a card (toast foot \(read.toast.maxY), card top \(card.minY))
                """)
        }
        #expect(read.toast.maxY <= top.minY - Self.cardTopGutter - StatusToastPlacement.clearance + 0.5, """
            \(surface): the toast sits ABOVE the cards band, with the band's air \
            (toast foot \(read.toast.maxY), top card's paper \(top.minY))
            """)
        #expect(read.toast.maxY >= top.minY - Self.cardTopGutter - StatusToastPlacement.clearance - 2, """
            \(surface): …and just above it, not floating up the page \
            (toast foot \(read.toast.maxY), top card's paper \(top.minY))
            """)
    }

    /// **RED ON OLD.** Both cards stand (the tour offer over the words card,
    /// P-292-13's stacking): the toast clears the band's top card.
    @Test func withBothCardsTheToastSitsAboveTheBand() async throws {
        try await withAToastOverTheBookcase(offer: true, words: true) { read in
            expectAboveTheCards(read, "two cards")
        }
    }

    /// **RED ON OLD.** One card (the twelve-words card alone — the ticket's
    /// sighting).
    @Test func withTheWordsCardAloneTheToastSitsAboveIt() async throws {
        try await withAToastOverTheBookcase(offer: false, words: true) { read in
            expectAboveTheCards(read, "the words card")
        }
    }

    /// GUARD (green on both trees): no card in the band — the toast sits just
    /// above the quick entry, VX-121's placement unchanged.
    @Test func withNoCardTheToastSitsJustAboveTheQuickEntry() async throws {
        try await withAToastOverTheBookcase(offer: false, words: false) { read in
            #expect(read.cards.isEmpty)
            #expect(read.toast.maxY <= read.entry.minY - StatusToastPlacement.clearance + 0.5,
                    "above the quick entry (toast foot \(read.toast.maxY), entry top \(read.entry.minY))")
        }
    }
}
