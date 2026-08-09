//
//  MobileLibraryTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 3, batch 1 — the Library tab's suite: the bounded
//  newest-first listing (the Phase 8 bounded-listing pin, re-pointed at
//  the new shape), search over `searchCatalog`'s EXISTING scope (with
//  the never-invent-body-search pin), the bookless filter (the Pool's
//  phone home), hit navigation (P-2: pool-home block hits render no
//  door), and the "+ new note" minting door.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile library — listing, search, bookless (S3 batch 1)")
struct MobileLibraryTests {
    /// The Phase 8 bounded-listing pin, re-pointed: a held observation is
    /// viewport-shaped (P1) — the limit holds and the newest note leads.
    @Test func theListingIsBoundedAndNewestFirst() async throws {
        try await withEditorWorld { session, _ in
            var lastID: String?
            for index in 1...6 {
                lastID = try await session.runner.run { ops in
                    try ops.createPost(title: "note \(index)").id
                }
            }
            let model = MobileLibraryViewModel(session: session, listingLimit: 5)
            let observation = Task { await model.startAll() }
            defer { observation.cancel() }
            for _ in 0..<2000 where model.all.count < 5 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.all.count == 5, "a held observation is viewport-shaped (P1)")
            #expect(model.all.first?.postID == lastID, "newest first — the standing sort")
        }
    }

    /// S3 ladder, MINOR 1: a CANCELLED in-flight search — `.task(id:)`
    /// cancels on every keystroke and on the root's disappearance; GRDB's
    /// async read throws `CancellationError` for it — never lands as a
    /// persistent red error line, and a landed search clears any earlier
    /// error.
    @Test func aCancelledSearchNeverLandsAsAnError() async throws {
        try await withEditorWorld { session, _ in
            _ = try await session.runner.run { ops in
                try ops.createPost(title: "Moonrise essay")
            }
            let model = MobileLibraryViewModel(session: session)

            // The keystroke's cancellation: the wrapping task dies before
            // the read lands (Task.isCancelled is set before the read
            // schedules, so GRDB throws CancellationError deterministically).
            let inFlight = Task { await model.search("moon") }
            inFlight.cancel()
            await inFlight.value
            #expect(model.lastError == nil,
                    "a cancelled search is never an error to show")

            // The next search lands normally — and would clear any earlier
            // error (the Mac catalog catch's success-clear).
            await model.search("moon")
            #expect((model.hits ?? []).isEmpty == false)
            #expect(model.lastError == nil)
        }
    }

    /// Search covers the standing catalog scope: titles, entry dates, and
    /// book names — and an empty query clears back to the resting listing.
    @Test func searchFindsTheStandingCatalogScope() async throws {
        try await withEditorWorld { session, _ in
            let (postID, bookID) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "Moonrise essay")
                _ = try ops.createPost(title: nil, profile: .journal, entryDate: "2026-08-03")
                let book = try ops.createReading(name: "Moonlight", kind: .curated)
                return (post.id, book.id)
            }
            let model = MobileLibraryViewModel(session: session)

            await model.search("moon")
            let hits = try #require(model.hits)
            #expect(hits.contains { $0.kind == .post && $0.id == postID })
            #expect(hits.contains { $0.kind == .book && $0.id == bookID })

            await model.search("2026-08-03")
            let dated = try #require(model.hits)
            #expect(dated.contains { $0.kind == .post && $0.title == "2026-08-03" },
                    "a nameless note is found by its date and NAMED by it (the one display brain)")

            await model.search("   ")
            #expect(model.hits == nil, "an empty query rests back to the listing")
        }
    }

    /// THE SCOPE PIN: body prose is NOT searchable — `searchCatalog`'s
    /// existing scope (titles / names / dates / named blocks / pool
    /// scraps) ships as-is; whole-library body search belongs to its own
    /// roadmap row and is deliberately NOT invented here.
    @Test func searchNeverInventsBodySearch() async throws {
        try await withEditorWorld { session, _ in
            _ = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "plain title")
                _ = try ops.newBlock(in: post.id, text: "A xylophone hides in the prose.", at: .end)
                return post.id
            }
            let model = MobileLibraryViewModel(session: session)
            await model.search("xylophone")
            #expect(model.hits == [],
                    "body prose stays out of scope — the roadmap row owns it")
        }
    }

    /// The bookless filter is the Pool's phone home: no live curated
    /// membership and no smart book collecting. Adding the note to a book
    /// drains it from the filter, live.
    @Test func theBooklessFilterIsThePoolsPhoneHome() async throws {
        try await withEditorWorld { session, _ in
            let (booklessID, bookID) = try await session.runner.run { ops -> (String, String) in
                let bookless = try ops.createPost(title: "floating")
                let shelved = try ops.createPost(title: "shelved")
                let book = try ops.createReading(name: "Home", kind: .curated)
                _ = try ops.addPostToReading(shelved.id, to: book.id)
                return (bookless.id, book.id)
            }
            let model = MobileLibraryViewModel(session: session)
            let observation = Task { await model.startBookless() }
            defer { observation.cancel() }
            for _ in 0..<2000 where model.bookless.isEmpty {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.bookless.map(\.postID) == [booklessID],
                    "only the bookless note lists")

            try await session.runner.run { ops in
                _ = try ops.addPostToReading(booklessID, to: bookID)
            }
            for _ in 0..<2000 where !model.bookless.isEmpty {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.bookless.isEmpty, "a shelved note leaves the Pool's phone home")
        }
    }

    /// Block hits navigate to their HOME NOTE; a pool-home block has no
    /// phone door, so its hit renders no row (P-2: a door that can never
    /// act isn't rendered).
    @Test func blockHitsNavigateHomeAndPoolHomesRenderNoDoor() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "host")
                let minted = try ops.newBlock(in: post.id, text: "Named prose.", at: .end)
                try ops.setBlockName(minted.block.id, name: "anchor-block")
                let pool = try ops.createPool(title: "scraps")
                _ = try ops.newBlock(in: pool.id, text: "anchor-scrap floats here", at: .end)
                return post.id
            }
            let model = MobileLibraryViewModel(session: session)

            await model.search("anchor-block")
            let hits = try #require(model.hits)
            let blockHit = try #require(hits.first { $0.kind == .block })
            #expect(MobileLibraryViewModel.destination(for: blockHit)
                    == .note(postID, focus: false), "a block hit opens its home note")

            await model.search("anchor-scrap")
            #expect(model.hits?.contains { $0.kind == .block } == false,
                    "a pool-home block hit is filtered out — no phone door exists (P-2)")

            // The pure rule, pinned directly.
            let poolHit = Queries.CatalogHit(
                kind: .block, id: "b", title: "scrap", detail: "scraps",
                homeContainerID: "pool-id", homeIsPool: true)
            #expect(MobileLibraryViewModel.destination(for: poolHit) == nil)
            let bookHit = Queries.CatalogHit(kind: .book, id: "r", title: "Home", detail: "book")
            // `.book` is the book's FRONT — since P35's inversion (parity
            // A3) that front is the CONTENTS list; Read is its door.
            #expect(MobileLibraryViewModel.destination(for: bookHit) == .book("r"))
        }
    }

    /// P35's flip (parity A3), the headless half of the flow pin: a book
    /// tap routes to `.book` — whose screen is the CONTENTS list — and
    /// the Read flow is a separate route reached only through the
    /// contents screen's voiced "Read" door (`MobileBookView.
    /// readDoorTitle`). The SwiftUI push wiring itself rides the batch's
    /// screenshot set (the A1 masthead precedent).
    @Test func bookTapOpensContentsFirstAndReadIsTheDoor() {
        let bookHit = Queries.CatalogHit(kind: .book, id: "r", title: "Home", detail: "book")
        #expect(MobileLibraryViewModel.destination(for: bookHit) == .book("r"))
        #expect(MobileRoute.bookRead("r") != MobileRoute.book("r"),
                "Read is its own route — a door, never the book tap's landing")
        #expect(MobileBookView.readDoorTitle == "Read")
        #expect(VoiceTokens.terminalLight.chromeLabel(MobileBookView.readDoorTitle) == "read",
                "the door renders voice-cased (P26/P43's one register)")
    }

    /// "+ new note" mints a NAMELESS note (13g R6-3: no stored
    /// placeholder; the display brain shows its created day — 13k K1).
    @Test func theNewNoteDoorMintsANamelessNote() async throws {
        try await withEditorWorld { session, db in
            let model = MobileLibraryViewModel(session: session)
            let postID = try #require(await model.newNote())
            let stored = try await db.read { db in
                try Row.fetchOne(
                    db, sql: "SELECT title, created_at FROM container WHERE id = ?",
                    arguments: [postID])
            }
            #expect((stored?["title"] as String?) == nil, "no stored placeholder title")
            let day = try #require(DisplayTitle.day(fromStamp: stored?["created_at"]))
            #expect(MobileLibraryViewModel.rowTitle(
                Queries.TimelineItem(
                    postID: postID, title: nil, entryDate: nil,
                    createdAt: stored?["created_at"], stamp: "")) == day,
                    "a nameless note shows its created day")
        }
    }

    @Test func theTruncationMarkerCarriesNoMacRedirect() {
        // P32's flip (parity A1, item 5): the marker rewords NEUTRALLY —
        // the "full book lives on the Mac" tail violated the no-redirect
        // principle; load-more stays deferred with the Mac's own
        // bounded-window family. One shared sentence serves both book
        // surfaces (the note list and the Read flow).
        let copy = MobileBookViewModel.truncationMarker(shown: 300)
        #expect(copy
                == "Showing the first 300 notes — the rest of this book isn't loaded yet.")
        #expect(!copy.contains("Mac"))
    }
}

@MainActor
@Suite("Mobile library — the sort picker (parity C3, her ruling 9)")
struct MobileLibrarySortTests {
    /// The picker reorders the listing by STORE truth: each option is
    /// the core `LibrarySort`'s own stamp expression, and flipping the
    /// sort restarts the observation exactly as the view's `.task(id:)`
    /// does. The default stays the standing last-touched.
    @Test func theSortPickerReordersTheListingByStoreTruth() async throws {
        try await withEditorWorld { session, db in
            let (a, b, c) = try await session.runner.run { ops -> (String, String, String) in
                let a = try ops.createPost(title: "Alpha")
                let b = try ops.createPost(title: "Beta")
                let c = try ops.createPost(title: "Gamma")
                try ops.setEntryDate(a.id, entryDate: "2026-03-01")
                try ops.setEntryDate(b.id, entryDate: "2026-01-01")
                // The LAST text act touches Alpha — so created order and
                // touched order deliberately disagree.
                _ = try ops.newBlock(in: a.id, text: "harbor light")
                return (a.id, b.id, c.id)
            }
            let model = MobileLibraryViewModel(session: session)
            #expect(model.sort == .lastTouched, "the standing default")

            var listing = Task { await model.startAll() }
            await settle { model.all.count == 3 }
            #expect(model.all.map(\.postID) == [a, c, b],
                    "last touched: Alpha's text act outranks creation order")

            // The view's restart contract, mirrored: cancel, flip, restart.
            listing.cancel()
            model.setSort(.createdAt)
            listing = Task { await model.startAll() }
            await settle { model.all.map(\.postID) == [c, b, a] }
            #expect(model.all.map(\.postID) == [c, b, a],
                    "created: newest mint first, the touch ignored")

            listing.cancel()
            model.setSort(.entryDate)
            listing = Task { await model.startAll() }
            await settle { model.all.map(\.postID) == [c, a, b] }
            #expect(model.all.map(\.postID) == [c, a, b],
                    "entry date: undated Gamma rides its created stamp; dated notes by their days")
            listing.cancel()
        }
    }

    /// The vocabulary, pinned: the brief's four words over the core's
    /// own sort cases, the picker's order, and the no-op flip —
    /// setting the SAME sort wakes no observer, so the view's
    /// `.task(id: sort)` never restarts the listing observation
    /// (FIX-C3d: the C3 ladder's NIT — the comment claimed this pin;
    /// now the pin exists, as a BEHAVIOR pin). Measured honestly
    /// (2026-08-09, iOS 26.2): the silence is guaranteed TWICE — by
    /// `setSort`'s own guard AND by the platform (the @Observable
    /// macro on this SDK skips notification for equal-value writes to
    /// Equatable properties: with the guard dropped, the equal-value
    /// write still woke nothing while a different-value write did —
    /// probe-verified both ways). So this pin holds the no-op-flip
    /// CONTRACT; it cannot discriminate the model's guard line alone,
    /// and does not claim to (the hallucination guard's honesty rule).
    @Test func theSortVocabularyIsPinned() async throws {
        typealias M = MobileLibraryViewModel
        #expect(M.sortOptions == [.entryDate, .createdAt, .lastTouched, .lastMajorRevision])
        #expect(M.sortWord(.entryDate) == "entry date")
        #expect(M.sortWord(.createdAt) == "created")
        #expect(M.sortWord(.lastTouched) == "last touched")
        #expect(M.sortWord(.lastMajorRevision) == "last meaningful edit")

        // The no-op flip: same value ⇒ no mutation ⇒ no observation
        // fires (the registration stays armed); a real flip fires it.
        try await withEditorWorld { session, _ in
            let model = M(session: session)
            #expect(model.sort == .lastTouched, "the standing default")
            let notified = LockIsolated(false)
            withObservationTracking {
                _ = model.sort
            } onChange: {
                notified.setValue(true)
            }
            model.setSort(.lastTouched)
            #expect(notified.value == false,
                    "the same value writes nothing — the view's .task(id:) never restarts")
            model.setSort(.entryDate)
            #expect(notified.value == true, "a real flip wakes the observer")
            #expect(model.sort == .entryDate)
        }
    }
}
