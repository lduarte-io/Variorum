//
//  MobileEmptyStoreTests.swift
//  VariorumMobileTests
//
//  Pre-13u round, Act 0 — the empty-state copy that rides R-pre13u-1.
//
//  Seeding on first write means a fresh install genuinely holds nothing,
//  and the recorded cost of her ruling was *"'empty app' on first open —
//  which may read as broken without a little empty-state copy"*. These
//  pins hold the two things that make the copy do its job: it names BOTH
//  roads (start one · sign in), and the door it names is DERIVED from the
//  door rather than retyped beside it.
//

//  ── THE COMPOSITION PINS (added 2026-08-31, the midpoint review's m2) ──
//  The two pins below this line assert the CONSTANTS only, and the review
//  caught what that costs: deleting the empty-state `VStack` from either
//  view leaves this whole file green while the app ships the blank screen
//  the copy exists to prevent. That is the P47 hole — a pin that cannot
//  fail — reopened in the same round that closed it.
//
//  So each surface now also gets a pin that reads the SURFACE: `dump` over
//  the real `body`, matched through `String(reflecting:)` because `dump`
//  escapes non-ASCII. Same road as `MobileProtectionSurfaceTests`, and its
//  limit is the same one recorded there and in the Mac twin's header — it
//  proves a `Text` is COMPOSED, not that it is VISIBLE.
//

import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("What a fresh install says before her first write")
struct MobileEmptyStoreTests {

    private func composition<V: View>(of view: V) -> String {
        var out = ""
        dump(view, to: &out, maxDepth: 400)
        return out
    }

    /// True when the surface carries this sentence AS THE VOICE RENDERS IT
    /// — `chromeLabel` lowercases in the terminal voice, so matching the raw
    /// constant would look for a string no screen ever shows.
    private func carries(
        _ sentence: String, in composition: String,
        tokens: VoiceTokens = .terminalLight
    ) -> Bool {
        composition.contains(String(reflecting: tokens.chromeLabel(sentence)))
    }

    /// The door name is derived, never a second copy of the same string —
    /// so renaming the door cannot leave a sentence pointing at a button
    /// that no longer says that (the K5 naming discipline applied to copy).
    @Test func theEmptyLibraryNamesTheRealDoor() {
        #expect(MobileEmptyStoreCopy.noNotesDoor
            .contains(MobileNewNoteDoor.doorTitle))
    }

    /// **BOTH roads, on both empty surfaces.** A fresh install has exactly
    /// two kinds of owner — a new writer and a returning one on a new
    /// phone — and naming only the first is what makes an empty screen read
    /// as "my writing is gone" instead of "nothing here yet".
    ///
    /// *Red on the old behaviour:* the Library had no empty state at all
    /// (a path line, a search field, a filter row and nothing else), and
    /// no surface anywhere named the sign-in road.
    @Test func bothRoadsAreNamed() {
        #expect(!MobileEmptyStoreCopy.noNotes.isEmpty)
        #expect(!MobileEmptyStoreCopy.noBooks.isEmpty)
        // The returning-owner road, and it points where the door actually
        // is: Settings ▸ Sync holds `SyncStatusRow`, which presents the
        // account sheet.
        #expect(MobileEmptyStoreCopy.signIn.contains("Settings"))
        #expect(MobileEmptyStoreCopy.signIn.contains("Sync"))
    }

    // MARK: - …and the SURFACES really say it (m2)

    /// *Red on a tree with the empty-state `VStack` deleted:* the Library's
    /// three sentences vanish from the composition and this goes red, where
    /// the constant pins above stay green. Verified by deleting it.
    @Test func theEmptyLibrarySurfaceCarriesAllThreeSentences() async throws {
        try await withEditorWorld { session, _ in
            let shown = composition(
                of: MobileLibraryView(
                    model: MobileLibraryViewModel(session: session),
                    scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session),
                    books: MobileShelfViewModel(session: session),
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }).body)
            #expect(carries(MobileEmptyStoreCopy.noNotes, in: shown),
                    "an empty Library shows a path line, a search field and nothing else")
            #expect(carries(MobileEmptyStoreCopy.noNotesDoor, in: shown),
                    "…and never names the door that starts a note")
            #expect(carries(MobileEmptyStoreCopy.signIn, in: shown),
                    "…and never names the returning owner's road")
        }
    }

    /// The shelf's half of the same fact — **and it is MOUNTED, not
    /// dumped, for a measured reason.** The shelf's empty state lives inside
    /// `booksRegion`, which the body reaches through a `GeometryReader`, and
    /// a `GeometryReader`'s content is a CLOSURE evaluated at layout time —
    /// so `dump` over the body walks straight past it however deep it is
    /// allowed to go (checked at `maxDepth: 400`, not assumed). The phone
    /// has something the Mac's twin header records as unavailable there — a
    /// LIVE accessibility tree on a hosted surface — so the shelf gets the
    /// stronger pin instead: the sentence must reach the RENDERED tree, not
    /// merely the composition.
    ///
    /// *Red on a tree with the empty-state `VStack` deleted:* both labels
    /// leave the rendered tree. Verified by deleting it.
    @Test func theEmptyShelfSurfaceNamesBothRoads() async throws {
        try await withEditorWorld { session, _ in
            let tokens = VoiceTokens.terminalLight
            try await withHostedSurface(
                MobileShelfView(
                    model: MobileShelfViewModel(session: session),
                    stars: MobileStarsModel(session: session),
                    quickNote: MobileQuickNoteModel(session: session),
                    tokens: tokens, tabBar: { EmptyView() },
                    onOpenBook: { _ in }, onOpenForWriting: { _ in },
                    onSettings: {})
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(labels.contains {
                    $0.contains(tokens.chromeLabel(MobileEmptyStoreCopy.noBooks))
                }, "an empty shelf must say so")
                #expect(labels.contains {
                    $0.contains(tokens.chromeLabel(MobileEmptyStoreCopy.signIn))
                }, "…and must name the returning owner's road")
            }
        }
    }

    /// The complement, and what stops the two above from passing on a view
    /// that shows the empty state unconditionally: with a note in the store
    /// the Library's empty copy is GONE from the composition (an untaken
    /// `_ConditionalContent` branch is absent from a `dump` — the property
    /// the whole road rests on).
    @Test func aStoreWithANoteShowsNoEmptyStateAtAll() async throws {
        try await withEditorWorld { session, _ in
            _ = try await session.runner.run { ops in
                try ops.importPost(title: "Mine", text: "Something written.")
            }
            let model = MobileLibraryViewModel(session: session)
            let listing = Task { await model.startAll() }
            defer { listing.cancel() }
            var waited = 0
            while model.visible.isEmpty, waited < 400 {
                try await Task.sleep(for: .milliseconds(5))
                waited += 1
            }
            #expect(!model.visible.isEmpty, "the listing must have loaded")

            let shown = composition(
                of: MobileLibraryView(
                    model: model,
                    scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session),
                    books: MobileShelfViewModel(session: session),
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }).body)
            #expect(!carries(MobileEmptyStoreCopy.noNotes, in: shown),
                    "a Library with notes in it must not say the store is empty")
        }
    }
}
