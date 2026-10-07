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

    // MARK: - The provenance door's own empty line (VM-5 whole-round pass, MINOR 2)

    /// **UNDER BOOKLESS, A LIBRARY WHOSE NOTES ARE ALL IN BOOKS NEVER SAYS THE
    /// STORE IS EMPTY.** The journal-first default books every day's entry, so
    /// "every note is in a book" is an ordinary state — and the Bookless door's
    /// note listing (`Queries.poolPosts`) is then empty while the store is not.
    /// The old guard read only the DOOR's listing, so this surface rendered the
    /// fresh-install trio — *"No notes yet."* · *"+ New Note starts one."* ·
    /// *"Have an account? Settings ▸ Sync signs you in."* — three sentences
    /// that are false or misleading there, producing the exact "my writing is
    /// gone" reading the trio exists to prevent (`MobileEmptyStore.swift`'s
    /// own header).
    ///
    /// MOUNTED, not dumped: the rendered tree is what she reads. Both
    /// observations run (the app's own `.task`s), and the pin checks they
    /// loaded before it reads the empty state, so it cannot pass on a listing
    /// that simply had not arrived.
    @Test func aBooklessDoorOverBookedNotesNeverSaysTheStoreIsEmpty() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                let note = try ops.createPost(title: "Shelved note")
                let book = try ops.createReading(name: "Poems", kind: .book)
                _ = try ops.addPostToReading(note.id, to: book.id)
            }
            let tokens = VoiceTokens.terminalLight
            let library = MobileLibraryViewModel(session: session)
            library.filter = .bookless
            try await withHostedSurface(
                MobileLibraryView(
                    model: library,
                    scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session),
                    books: MobileShelfViewModel(session: session),
                    tokens: tokens, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(50)
                // The pin's premise, asserted rather than assumed: the store
                // HAS a note, and the Bookless door has none to list.
                #expect(library.all.count == 1, "the note listing must have loaded")
                #expect(library.bookless.isEmpty, "the booked note is not bookless")
                let labels = surface.visibleLabels
                for sentence in [
                    MobileEmptyStoreCopy.noNotes,
                    MobileEmptyStoreCopy.noNotesDoor,
                    MobileEmptyStoreCopy.signIn,
                ] {
                    #expect(!labels.contains { $0.contains(tokens.chromeLabel(sentence)) },
                            "Bookless over booked notes says the store is empty: \(sentence) — labels were \(labels)")
                }
                // …and the door says what IS true, in its own line (the
                // plain sentence is the accessibility label — the books
                // listing's empty-line rule).
                #expect(labels.contains(MobileListingFilter.noBooklessLine),
                        "the Bookless door's own empty line is missing — labels were \(labels)")
            }
        }
    }

    /// The complement: when the store genuinely holds NO notes, the trio is
    /// true under the Bookless door too — so it speaks there, and the
    /// door's own line (which would claim notes exist in books) does not.
    @Test func aBooklessDoorOverAnEmptyStoreStillSpeaksTheTrio() async throws {
        try await withEditorWorld { session, _ in
            let tokens = VoiceTokens.terminalLight
            let library = MobileLibraryViewModel(session: session)
            library.filter = .bookless
            try await withHostedSurface(
                MobileLibraryView(
                    model: library,
                    scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session),
                    books: MobileShelfViewModel(session: session),
                    tokens: tokens, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(50)
                let labels = surface.visibleLabels
                for sentence in [
                    MobileEmptyStoreCopy.noNotes,
                    MobileEmptyStoreCopy.noNotesDoor,
                    MobileEmptyStoreCopy.signIn,
                ] {
                    #expect(labels.contains { $0.contains(tokens.chromeLabel(sentence)) },
                            "an empty store under Bookless lost the trio: \(sentence) — labels were \(labels)")
                }
                #expect(!labels.contains(MobileListingFilter.noBooklessLine),
                        "the Bookless line claims notes are in books when there are none — labels were \(labels)")
            }
        }
    }

    /// **THE RULE, DOOR BY DOOR** — the pure table `emptyListing` documents,
    /// pinned whole so a door that gains or loses a line has to say so here.
    @Test func theEmptyLineIsDecidedByWhatIsTrueOnEveryDoor() {
        typealias Model = MobileLibraryViewModel
        // All and Notes: the listing IS the store's, so empty means empty.
        for door in [MobileListingFilter.all, .notes] {
            #expect(Model.emptyListing(filter: door, doorNotes: 0, storeNotes: 0, booksShown: 0)
                    == .storeEmpty)
            #expect(Model.emptyListing(filter: door, doorNotes: 2, storeNotes: 2, booksShown: 0)
                    == nil)
        }
        // All's union: books on screen are rows, so nothing is empty.
        #expect(Model.emptyListing(filter: .all, doorNotes: 0, storeNotes: 0, booksShown: 1) == nil)
        // Bookless: the trio only when the STORE is empty; otherwise its own line.
        #expect(Model.emptyListing(filter: .bookless, doorNotes: 0, storeNotes: 0, booksShown: 0)
                == .storeEmpty)
        #expect(Model.emptyListing(filter: .bookless, doorNotes: 0, storeNotes: 3, booksShown: 0)
                == .noBookless)
        #expect(Model.emptyListing(filter: .bookless, doorNotes: 1, storeNotes: 3, booksShown: 0)
                == nil)
        // Books and Scraps never reach the note listing's empty state.
        for door in [MobileListingFilter.books, .scraps] {
            #expect(Model.emptyListing(filter: door, doorNotes: 0, storeNotes: 0, booksShown: 0)
                    == nil)
        }
        // The door's line is a real sentence and names no other door.
        #expect(!MobileListingFilter.noBooklessLine.isEmpty)
    }
}
