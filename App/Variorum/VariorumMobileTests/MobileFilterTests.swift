//
//  MobileFilterTests.swift
//  VariorumMobileTests
//
//  **THE LIBRARY'S KIND FILTERS AND THE ARCHIVE'S INHERITED SET** (the filter
//  batch, 2026-08-31 — her QUESTIONS #85 and #92).
//
//  Every door below is proven by MOUNTING the real surface and ACTIVATING the
//  real control through `accessibilityActivate()` (§15's trap (b): a pin
//  asserting a view model's property proves nothing about what renders — which
//  is precisely how the Mac's dead purge doors shipped under green pins).
//
//  The row's WIDTH — the design record's flagged risk for this batch — is
//  measured separately, off real frames, in `MobileFilterRowGeometryTests`.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile listing filters — the Library's kinds and the Archive's set", .serialized)
struct MobileFilterTests {

    // MARK: - Fixtures

    /// The shelf model the Library wears for its books listing, driven the way
    /// the app drives it: the HELD observation belongs to the shelf root's
    /// `.task` (one loop per model, whichever surface is wearing it), and the
    /// tags column is its one-shot. A harness that mounts the Library ALONE
    /// must therefore start it here — the fact is written at
    /// `MobileLibraryView.books`.
    private func startedShelf(_ session: AppSession) async -> (MobileShelfViewModel, Task<Void, Never>) {
        let shelf = MobileShelfViewModel(session: session)
        let observing = Task { await shelf.start() }
        await shelf.refreshTags()
        return (shelf, observing)
    }

    // MARK: - The Library's vocabulary (#85, #92(a))

    /// **HER FIVE DOORS, AND EACH ONE REALLY SWITCHES THE LISTING.** #85: the
    /// provenance filters *"are less useful than 'books' 'posts', etc."*, and
    /// the kind doors join them rather than replacing them (`bookless` stays —
    /// PROVISIONAL, recorded: removing a shipped door is hers).
    ///
    /// Driven end to end on the real Library: five doors, five different
    /// listings, one row.
    @Test func theLibrarysFilterRowCarriesHerFiveDoorsAndEachSwitchesTheListing() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                let shelved = try ops.createPost(title: "Shelved note")
                _ = try ops.createPost(title: "Floating note")
                let book = try ops.createReading(name: "Poems", kind: .book)
                _ = try ops.addPostToReading(shelved.id, to: book.id)
                let pool = try ops.createPool(title: "Pool")
                _ = try ops.newBlock(in: pool.id, text: "A loose sentence.", at: .end)
            }
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(50)
                // Every door she named is on the surface, by its plain word.
                for door in MobileListingFilter.libraryDoors {
                    #expect(surface.visibleLabels.contains(door.word),
                            "the \(door.word) door is missing — labels were \(surface.visibleLabels)")
                }

                // ALL — the resting listing: her notes.
                #expect(surface.visibleLabels.contains { $0.contains("Shelved note") })
                #expect(surface.visibleLabels.contains { $0.contains("Floating note") })

                // BOOKS (#92(a)) — her books themselves, and the notes gone.
                #expect(surface.activate(MobileListingFilter.books.word),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(library.filter == .books)
                #expect(surface.visibleLabels.contains { $0.hasPrefix("Poems") },
                        "the book does not row — labels were \(surface.visibleLabels)")
                #expect(!surface.visibleLabels.contains { $0.contains("Shelved note") },
                        "a note rows under the books filter")

                // NOTES — the note listing again.
                #expect(surface.activate(MobileListingFilter.notes.word))
                await surface.settle(40)
                #expect(library.filter == .notes)
                #expect(surface.visibleLabels.contains { $0.contains("Shelved note") })
                #expect(!surface.visibleLabels.contains { $0.hasPrefix("Poems") },
                        "a book rows under the notes filter")

                // BOOKLESS — the Pool's phone home, untouched by this batch.
                #expect(surface.activate(MobileListingFilter.bookless.word))
                await surface.settle(40)
                #expect(library.filter == .bookless)
                #expect(surface.visibleLabels.contains { $0.contains("Floating note") })
                #expect(!surface.visibleLabels.contains { $0.contains("Shelved note") },
                        "a shelved note rows under the bookless filter")

                // SCRAPS — standalone blocks, also untouched.
                #expect(surface.activate(MobileListingFilter.scraps.word))
                await surface.settle(60)
                #expect(library.filter == .scraps)
                #expect(surface.visibleLabels.contains { $0.contains("A loose sentence") },
                        "labels were \(surface.visibleLabels)")

                // And back to ALL.
                #expect(surface.activate(MobileListingFilter.all.word))
                await surface.settle(40)
                #expect(library.filter == .all)
                #expect(surface.visibleLabels.contains { $0.contains("Shelved note") })
            }
        }
    }

    /// **A BOOK ROW REALLY OPENS THAT BOOK** — #92(a)'s *"openable rows"*, and
    /// the id it carries is asserted rather than the mere fact that something
    /// fired (the 6c n10 lesson: a door that opens the WRONG thing passes a
    /// door-exists pin).
    ///
    /// It also holds the reuse the brief demanded: the row's NAME is
    /// `MobileShelfFaces.name` — the finished " ✓" state rides it — and its
    /// META is `MobileShelfFaces.meta`, so the Library cannot grow a second
    /// book-row rule.
    @Test func aBookRowOpensThatBookAndWearsTheShelfsOwnFaces() async throws {
        try await withEditorWorld { session, _ in
            let (openID, finishedID) = try await session.runner.run { ops -> (String, String) in
                let open = try ops.createReading(name: "Aster", kind: .book)
                let note = try ops.createPost(title: "A member")
                _ = try ops.addPostToReading(note.id, to: open.id)
                let finished = try ops.createReading(name: "Zebra", kind: .book)
                try ops.lockReading(finished.id)
                return (open.id, finished.id)
            }
            let library = MobileLibraryViewModel(session: session)
            library.filter = .books
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }
            let opened = LockIsolatedBox<String?>(nil)

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { route in
                        if case .book(let id) = route { opened.value = id }
                    },
                    onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(50)
                let labels = surface.visibleLabels
                // The FACES are the Shelf's: the finished state rides the name
                // (" ✓") and the meta line is the count — and BOTH are spoken,
                // through `MobileShelfFaces.spokenRow`.
                let finishedName = MobileShelfFaces.name(
                    for: try #require(shelf.books.first { $0.reading.id == finishedID }).reading)
                #expect(finishedName.hasSuffix(" ✓"))
                #expect(labels.contains { $0.hasPrefix(finishedName) },
                        "the finished book's name+state is not the row's label — labels were \(labels)")
                #expect(labels.contains { $0.contains("1 note") },
                        "the shelf meta line is missing — labels were \(labels)")

                // And the row opens the book it names.
                let asterRow = try #require(labels.first { $0.hasPrefix("Aster") })
                #expect(surface.activate(asterRow), "labels were \(labels)")
                await surface.settle(20)
                #expect(opened.value == openID)
            }
        }
    }

    /// **THE BOOKS LISTING IS WINDOWED, AND IT SAYS SO** (P1 — MobileSoul §2's
    /// *"every list windowed"*, and never a silent cut).
    ///
    /// The FETCH is author-scale by core's own contract (`Queries.bookshelf`
    /// takes no limit, and the Shelf holds it unbounded for exactly that
    /// reason), so what is bounded is what the SURFACE BUILDS — the scraps
    /// area's own shape. `count > window` is exact truth here rather than a
    /// probe approximation, so an exact-window shelf cannot false-positive the
    /// marker.
    @Test func theBooksListingIsWindowedAndSaysSo() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                _ = try ops.createReading(name: "Aster", kind: .book)
                _ = try ops.createReading(name: "Basil", kind: .book)
                _ = try ops.createReading(name: "Cedar", kind: .book)
            }
            let library = MobileLibraryViewModel(session: session, listingLimit: 2)
            library.filter = .books
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(50)
                let labels = surface.visibleLabels
                #expect(labels.contains { $0.hasPrefix("Aster") })
                #expect(labels.contains { $0.hasPrefix("Basil") })
                #expect(!labels.contains { $0.hasPrefix("Cedar") },
                        "the window is not applied")
                // **TWO NUMBERS, not one** (the cold review's m4): this
                // listing's delivery is WHOLE, so the exact total is in hand
                // and the filterless rooms' probe-shaped sentence would be
                // saying less than is known.
                #expect(labels.contains(MobileRoomListing.truncationMarker(shown: 2, of: 3)),
                        "no truncation marker — labels were \(labels)")
                #expect(!labels.contains(MobileRoomListing.truncationMarker(shown: 2)),
                        "the books listing still speaks the one-number sentence")
            }
        }
    }

    /// **AN EMPTY SHELF SAYS SO RATHER THAN SHOWING A BLANK PAGE** (the
    /// fire-and-speak grammar: a filter that finds nothing must say what it
    /// found).
    @Test func anEmptyBooksListingSpeaks() async throws {
        try await withEditorWorld { session, _ in
            let library = MobileLibraryViewModel(session: session)
            library.filter = .books
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(MobileListingFilter.noBooksLine),
                        "labels were \(surface.visibleLabels)")
            }
        }
    }

    /// **THE ARCHIVED ROOM'S DOOR TRAILS A NOTE LISTING AND NOTHING ELSE.**
    /// It opens archived NOTES — a book cannot be archived at all (§0's model
    /// fact) — so trailing the books listing with it would be a door pointing
    /// somewhere its listing cannot go.
    @Test func theArchivedDoorTrailsNoteListingsOnly() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                _ = try ops.createPost(title: "A note")
                _ = try ops.createReading(name: "Poems", kind: .book)
            }
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(MobileRecoveryDoors.archiveLabel))
                #expect(surface.activate(MobileListingFilter.books.word))
                await surface.settle(40)
                #expect(!surface.visibleLabels.contains(MobileRecoveryDoors.archiveLabel),
                        "the Archived door trails the books listing — labels were \(surface.visibleLabels)")
                // And it comes back under a note listing.
                #expect(surface.activate(MobileListingFilter.notes.word))
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(MobileRecoveryDoors.archiveLabel))
            }
        }
    }

    // MARK: - THE UNION (#93(b))

    /// **`ALL` IS THE BOOKS + NOTES UNION** — her ruling, verbatim: *"All
    /// should be a book + notes union - otherwise it just doesn't make
    /// sense."* It overturns the batch's shipped PROVISIONAL 3, which built
    /// `.all` as the note listing alone.
    ///
    /// Driven on the real Library: `.all` shows BOTH kinds and interleaves
    /// them under the active stamp (the book is created between the two
    /// notes, so a union that merely appended one kind to the other would
    /// fail the ORDER assertion while passing every presence one); `.notes`
    /// shows notes and no book; and a book row found under `.all` opens that
    /// book, so the union's rows are the `.books` filter's rows and not a
    /// second, weaker rendering.
    @Test func theLibrarysAllDoorIsTheBooksAndNotesUnion() async throws {
        try await withEditorWorld { session, _ in
            // Created oldest first — the harness's clock ticks one second per
            // stamp — so the resting (last-touched, newest first) order is
            // Newer note · Poems · Older note.
            let bookID = try await session.runner.run { ops -> String in
                _ = try ops.createPost(title: "Older note")
                let book = try ops.createReading(name: "Poems", kind: .book)
                _ = try ops.createPost(title: "Newer note")
                return book.id
            }
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }
            let opened = LockIsolatedBox<String?>(nil)

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { route in
                        if case .book(let id) = route { opened.value = id }
                    },
                    onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(60)
                #expect(library.filter == .all)
                let labels = surface.visibleLabels

                // BOTH KINDS, on the resting surface.
                #expect(labels.contains { $0.contains("Older note") },
                        "labels were \(labels)")
                #expect(labels.contains { $0.contains("Newer note") })
                #expect(labels.contains { $0.hasPrefix("Poems") },
                        "her book does not row under All — labels were \(labels)")

                // INTERLEAVED, not appended: the book was made between the
                // two notes, so it must sit between them.
                let newer = try #require(labels.firstIndex { $0.contains("Newer note") })
                let book = try #require(labels.firstIndex { $0.hasPrefix("Poems") })
                let older = try #require(labels.firstIndex { $0.contains("Older note") })
                #expect(newer < book && book < older,
                        """
                        the union is not interleaved under the active stamp — \
                        newer=\(newer) book=\(book) older=\(older); labels \
                        were \(labels)
                        """)

                // A UNION ROW IS A BOOK ROW: it carries the Shelf's meta and
                // it opens the book it names.
                #expect(labels.contains { $0.hasPrefix("Poems") && $0.contains("0 notes") },
                        "the union's book row lost the shelf faces — labels were \(labels)")
                let row = try #require(labels.first { $0.hasPrefix("Poems") })
                #expect(surface.activate(row))
                await surface.settle(20)
                #expect(opened.value == bookID)

                // AND `.notes` STAYS NOTES — the union is `.all`'s, so the
                // door beside it still names one kind.
                #expect(surface.activate(MobileListingFilter.notes.word))
                await surface.settle(40)
                #expect(!surface.visibleLabels.contains { $0.hasPrefix("Poems") },
                        "a book rows under the notes filter — labels were \(surface.visibleLabels)")
                #expect(surface.visibleLabels.contains { $0.contains("Older note") })
            }
        }
    }

    /// **THE BOOK'S STAMP FOLLOWS THE SORT — the PROVISIONAL mapping, pinned**
    /// (her ruling left the interleaving detail unspecified; the built answer
    /// is `MobileLibraryViewModel.bookStamp`'s table, and a pin is what makes
    /// it a decision rather than an accident).
    ///
    /// Pure: a book whose `created_at` and `updated_at` disagree lands on
    /// DIFFERENT sides of one note depending on which stamp the sort names.
    /// A mapping that ignored the sort would put it on the same side twice.
    @Test func theUnionOrdersABookByTheStampTheSortNames() async throws {
        let day = { (iso: String) in
            DateFormatter.variorumISO8601.date(from: iso)!
        }
        // Made long ago, touched yesterday.
        let book = Queries.ShelfBook(
            reading: Reading(
                id: "book", name: "Poems", kind: .book,
                createdAt: day("2020-01-01T00:00:00.000Z"),
                updatedAt: day("2026-08-30T00:00:00.000Z")),
            postCount: 0, sectionCount: 0)
        // One note, stamped between the two.
        let note = Queries.TimelineItem(
            postID: "note", title: "A note", entryDate: nil,
            createdAt: "2023-01-01T00:00:00.000Z", stamp: "2023-01-01T00:00:00.000Z")

        // CREATED: the book is the older of the two, so it sorts BELOW.
        #expect(
            MobileLibraryViewModel.union(
                notes: [note], books: [book], sort: .createdAt).map(\.id)
            == ["note:note", "book:book"])
        // LAST TOUCHED: `updated_at` is the newer, so it sorts ABOVE.
        #expect(
            MobileLibraryViewModel.union(
                notes: [note], books: [book], sort: .lastTouched).map(\.id)
            == ["book:book", "note:note"])
        // LAST MEANINGFUL EDIT rides `updated_at` too (a book has no churn
        // stamp), and ENTRY DATE rides `created_at` (a book has no entry
        // date, so it behaves as an undated note does).
        #expect(
            MobileLibraryViewModel.union(
                notes: [note], books: [book], sort: .lastMajorRevision).map(\.id)
            == ["book:book", "note:note"])
        #expect(
            MobileLibraryViewModel.union(
                notes: [note], books: [book], sort: .entryDate).map(\.id)
            == ["note:note", "book:book"])

        // And the tie rule is deterministic: an exactly-equal stamp puts the
        // NOTE first, so the resting surface keeps its shape.
        let tied = Queries.TimelineItem(
            postID: "tied", title: "Tied", entryDate: nil,
            createdAt: "2026-08-30T00:00:00.000Z", stamp: "2026-08-30T00:00:00.000Z")
        #expect(
            MobileLibraryViewModel.union(
                notes: [tied], books: [book], sort: .lastTouched).map(\.id)
            == ["note:tied", "book:book"])
    }

    // MARK: - The sort glyph (#92(b))

    /// **THE SORT DOOR IS A GLYPH THAT SPEAKS ITS WHOLE VERB, ITS MENU OPENS,
    /// AND A SORT REALLY APPLIES.** Her #92(b): the width budget gives at the
    /// sort — so the text door becomes an icon, and everything it used to SAY
    /// moves into the accessibility label, which now carries MORE than the old
    /// door did (the verb AND the current stamp).
    ///
    /// **What is driven and what is not, stated rather than blurred** (the
    /// harness's own honesty rule): the door is activated for real and the
    /// menu's PRESENTATION is asserted — a SwiftUI `Menu`'s rows are not
    /// reachable in process (`MobileSurfaceDriver`'s measured finding), so the
    /// sort itself is applied through the model's named method, and what this
    /// pin then holds is that the LISTING re-orders and the DOOR re-speaks.
    @Test func theSortGlyphSpeaksItsVerbOpensItsMenuAndReallySorts() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                // Beta is created FIRST but dated LATER, so the two stamps
                // disagree and the order really distinguishes them.
                _ = try ops.createPost(title: "Beta", entryDate: "2026-12-01")
                _ = try ops.createPost(title: "Alpha", entryDate: "2026-01-01")
            }
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(50)
                let restingLabel = MobileSortDoor.label(
                    sortWord: MobileLibraryViewModel.sortWord(.lastTouched))
                #expect(surface.visibleLabels.contains(restingLabel),
                        "labels were \(surface.visibleLabels)")

                // The resting order is last-touched: Alpha (created later) first.
                @MainActor func order() -> [Int] {
                    let labels = surface.visibleLabels
                    return ["Alpha", "Beta"].compactMap { title in
                        labels.firstIndex { $0.contains(title) }
                    }
                }
                let resting = order()
                #expect(resting.count == 2)
                #expect(resting[0] < resting[1], "resting order is not last-touched")

                // THE MENU OPENS — the door is real and it presents.
                #expect(surface.activate(restingLabel))
                await surface.settle(30)
                #expect(surface.host.presentedViewController != nil,
                        "the sort door presents nothing")
                surface.host.dismiss(animated: false)
                await surface.settle(20)

                // A SORT APPLIES — the listing re-observes and re-orders, and
                // the door says what it is now set to.
                library.setSort(.entryDate)
                await surface.settle(60)
                let byDate = order()
                #expect(byDate.count == 2)
                #expect(byDate[0] > byDate[1],
                        "the listing did not re-order under entry date")
                #expect(surface.visibleLabels.contains(
                            MobileSortDoor.label(sortWord: MobileLibraryViewModel.sortWord(.entryDate))),
                        "the door does not re-speak its stamp — labels were \(surface.visibleLabels)")
            }
        }
    }

    /// **THE SORT'S AVAILABILITY RULE IS UNCHANGED: `.all` only.** Bookless
    /// keeps the core query's own order, scraps are pointer-ordered, and books
    /// order as the SHELF orders — so a sort door on any of them could not mean
    /// what it says (P-2: it is not rendered). *(PROVISIONAL, recorded: `.notes`
    /// shows the `.all` rows and loses the sort by this same rule.)*
    @Test func theSortDoorRendersOnTheAllFilterOnly() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                _ = try ops.createPost(title: "A note")
                _ = try ops.createReading(name: "Poems", kind: .book)
            }
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }
            let sortLabel = MobileSortDoor.label(
                    sortWord: MobileLibraryViewModel.sortWord(.lastTouched))

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(sortLabel))
                for door in [MobileListingFilter.books, .notes, .bookless, .scraps] {
                    #expect(surface.activate(door.word))
                    await surface.settle(30)
                    #expect(!surface.visibleLabels.contains(sortLabel),
                            "the sort door renders under \(door.word)")
                }
                #expect(surface.activate(MobileListingFilter.all.word))
                await surface.settle(30)
                #expect(surface.visibleLabels.contains(sortLabel))
            }
        }
    }

    // MARK: - The Archive room's inherited set (#85)

    /// **THE ARCHIVE ROOM WEARS THE SAME ROW, NARROWED TO WHAT CAN EXIST
    /// THERE** — her #85's *"it needs the same filters that the regular library
    /// has"*, in the only honest form: `reading` has no `archived_at`, so a
    /// books door there could never have content (P-2 in its strongest form),
    /// and no core read exists for archived-and-bookless or for archived scraps
    /// globally.
    ///
    /// **The absences are asserted against a POPULATED world** — a real book
    /// and a real scrap exist while the doors that would list them do not
    /// render — so the assertion can never pass vacuously.
    @Test func theArchiveRoomInheritsTheRowNarrowedToWhatCanExistThere() async throws {
        try await withEditorWorld { session, _ in
            let archivedID = try await session.runner.run { ops -> String in
                _ = try ops.createReading(name: "Poems", kind: .book)
                let pool = try ops.createPool(title: "Pool")
                _ = try ops.newBlock(in: pool.id, text: "A loose sentence.", at: .end)
                let note = try ops.createPost(title: "Set aside")
                try ops.archiveContainer(note.id)
                return note.id
            }
            let model = MobileArchiveModel(session: session)

            try await withHostedSurface(
                MobileArchiveView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(50)
                let labels = surface.visibleLabels
                // The row is there, in her vocabulary.
                #expect(labels.contains(MobileListingFilter.all.word),
                        "labels were \(labels)")
                #expect(labels.contains(MobileListingFilter.notes.word))
                // And the three doors that could not act are ABSENT — with a
                // live book and a live scrap in the world.
                #expect(!labels.contains(MobileListingFilter.books.word),
                        "an Archive books door renders, and a book can never be archived")
                #expect(!labels.contains(MobileListingFilter.bookless.word))
                #expect(!labels.contains(MobileListingFilter.scraps.word))
                // The room still lists what it holds.
                #expect(labels.contains { $0.contains("Set aside") })

                // The door acts: it selects, and the listing is still the
                // archived note (both doors name the same set here — the
                // model fact, recorded as a PROVISIONAL for her).
                #expect(surface.activate(MobileListingFilter.notes.word))
                await surface.settle(30)
                #expect(model.filter == .notes)
                #expect(model.visible.map(\.postID) == [archivedID])
                #expect(surface.visibleLabels.contains { $0.contains("Set aside") })
            }
        }
    }

    /// **ONE BRAIN, NOT TWO — the drift guard.** The two rooms' rows are the
    /// same component reading the same declaration, so a door's word can never
    /// come to differ between them. Asserted on the REAL surfaces (the labels
    /// they actually render), not merely on the declaration.
    @Test func bothRoomsSpeakTheSameFilterWordsFromOneDeclaration() async throws {
        // The declaration's own law first: the Archive's set is a SUBSET of the
        // Library's, never a parallel vocabulary.
        for door in MobileListingFilter.archiveDoors {
            #expect(MobileListingFilter.libraryDoors.contains(door))
        }

        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                let note = try ops.createPost(title: "Set aside")
                try ops.archiveContainer(note.id)
            }
            var libraryWords: [String] = []
            var archiveWords: [String] = []

            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }
            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars, books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                libraryWords = surface.visibleLabels.filter { label in
                    MobileListingFilter.allCases.contains { $0.word == label }
                }
            }

            let archive = MobileArchiveModel(session: session)
            try await withHostedSurface(
                MobileArchiveView(model: archive, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                archiveWords = surface.visibleLabels.filter { label in
                    MobileListingFilter.allCases.contains { $0.word == label }
                }
            }

            #expect(libraryWords == MobileListingFilter.libraryDoors.map(\.word))
            #expect(archiveWords == MobileListingFilter.archiveDoors.map(\.word))
            // The shared doors are byte-identical between the two rooms —
            // which is what "one brain" buys and what a second copy would lose.
            #expect(Set(archiveWords).isSubset(of: Set(libraryWords)))
        }
    }

    // MARK: - The composed road (the shell)

    /// **THE SHELL REALLY HANDS THE LIBRARY THE SHELF'S OWN BOOKS** — the whole
    /// road, through the app's own composition: the Library tab, the Books
    /// door, her book's row.
    ///
    /// **RED ON OLD by behavioural revert:** point the shell's `books:` at a
    /// fresh `MobileShelfViewModel(session:)` instead of `shelfModel` and the
    /// row never arrives — nothing starts that model's observation, because the
    /// held loop belongs to the shelf root's `.task`. That is the exact
    /// mechanism the property's doc records, and it is why this pin drives the
    /// composed road rather than the view in isolation.
    @Test func theShellGivesTheLibraryTheShelfsOwnBooks() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                _ = try ops.createReading(name: "Aster", kind: .book)
            }
            let suite = "filters-shell-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let router = MobileShellRouter(defaults: defaults)

            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(50)
                // **THE DOOR IS NOW LABELLED BY NAME, NOT BY CASING**
                // (batch 10). This read `"library"` because the label was the
                // voice-cased chrome text and `withEditorWorld` fixes the
                // voice to terminal, which lowercases it. That batch gave the
                // tab doors an explicit `accessibilityLabel` — the `+ New
                // Note` precedent — so an assistive reader hears the same
                // proper noun in both voices instead of one voice's casing.
                // The pin follows the door: same act, same door, the name it
                // is actually called.
                #expect(surface.activate("Library"), "labels were \(surface.visibleLabels)")
                await surface.settle(50)
                #expect(surface.activate(MobileListingFilter.books.word),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.visibleLabels.contains { $0.hasPrefix("Aster") },
                        "the shelf's books never reached the Library — labels were \(surface.visibleLabels)")
            }
        }
    }
}
