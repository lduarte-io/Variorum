//
//  MobileLibraryPagingRulesTests.swift
//  VariorumMobileTests
//
//  VM-68 (the VM-64 run, batch 5) — the Library's paging and hold RULES, on the
//  model (no view, no shared counters): the pages walk every note once in the
//  listing's own order; a hidden Library reads its note listing once and holds
//  nothing; the return re-asks; a deeper listing follows its first page; the
//  union withholds books it cannot yet place; the shell's on-screen fact. The
//  record is `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 5; §7).
//
//  These pins name VM-68's own API, so they are not part of the red-on-old
//  build (they could not compile against the code before it); the red-on-old
//  pins are `MobileLibraryPagingTests` and the four ASSERTED zeros in
//  `MobileHerPathsPerfTests`.
//
//  *(The VM-64 ladder's round 2 adds pins here that name only API older than
//  that round — the row delete, the line's Put back and its witness, the two
//  wing pins — so this file IS in that round's red-on-old build
//  (`vm64-gate2-red`, which reverses only the round's own hunks, VM-68 kept);
//  each pin's doc says what it shows there.)*
//
//  *(Round 3 adds three more that name only API older than it — a fully
//  listed listing kept complete through a Put back and an arrival — so they are
//  in that round's red-on-old build, which reverses only round 3's one hunk in
//  `land`.)*
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

/// Polls the main actor until `condition` holds (or a generous bound).
@MainActor
private func settle(_ condition: @MainActor () -> Bool) async {
    for _ in 0..<2_000 where !condition() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}

@MainActor
@Suite("VM-68 — the Library's paging and hold rules")
struct MobileLibraryPagingRulesTests {
    /// Notes titled `prefix 000…`, each touched in turn (newest = the last).
    private func seed(_ session: AppSession, _ count: Int, prefix: String = "n") async throws -> [String] {
        try await session.runner.run { ops in
            try (0..<count).map { index in
                let post = try ops.createPost(title: String(format: "\(prefix) %03d", index))
                _ = try ops.newBlock(in: post.id, text: "Words \(index).", at: .end)
                return post.id
            }
        }
    }

    // MARK: - The pages

    /// **Paging walks every note once, in the listing's own order** — the
    /// first page, then `loadMore` to the end, equals `Queries.library`'s
    /// whole listing (ids and stamps), for every sort the phone offers.
    @Test(arguments: MobileLibraryViewModel.sortOptions)
    func loadingMoreWalksEveryNoteOnceInTheListingsOrder(_ sort: Queries.LibrarySort) async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 23)
            let model = MobileLibraryViewModel(session: session, listingLimit: 5)
            model.setSort(sort)
            await model.hold(model.hold(onScreen: false))  // the one read: page one
            #expect(model.all.count == 5)
            #expect(model.allHasMore)
            var guardLoops = 0
            while model.allHasMore, guardLoops < 20 {
                await model.loadMore(.notes)
                guardLoops += 1
            }
            let whole = try await db.read { try Queries.library($0, sort: sort, direction: .desc) }
            #expect(model.all.map(\.postID) == whole.map(\.postID), "\(sort)")
            #expect(model.all.map(\.stamp) == whole.map(\.stamp), "\(sort)")
            #expect(!model.allHasMore)
        }
    }

    /// **A hidden Library reads its note listing ONCE and holds nothing**: a
    /// note minted afterwards is not listed while it stays hidden; on screen
    /// (the return), the held page lists it.
    @Test func aHiddenLibraryHoldsNothingAndTheReturnReAsks() async throws {
        try await withEditorWorld { session, _ in
            _ = try await seed(session, 3)
            let model = MobileLibraryViewModel(session: session)
            await model.hold(model.hold(onScreen: false))  // returns: nothing held
            #expect(model.all.count == 3)
            let late = try await session.runner.run { ops in
                try ops.createPost(title: "late").id
            }
            try? await Task.sleep(for: .milliseconds(150))
            #expect(!model.all.contains { $0.postID == late }, "a hidden Library re-read on a write")

            let onScreen = Task { await model.hold(model.hold(onScreen: true)) }
            defer { onScreen.cancel() }
            await settle { model.all.contains { $0.postID == late } }
            #expect(model.all.first?.postID == late, "the return re-asks: the new note leads")
        }
    }

    /// **On screen, a deeper listing FOLLOWS its first page** (the Mac's
    /// `followListingMove`): with two pages listed, a note that moves to the
    /// top re-asks the listed depth in place — the listing stays two pages
    /// deep, in order, with the moved note first and listed once.
    @Test func aDeeperListingFollowsItsFirstPage() async throws {
        try await withEditorWorld { session, db in
            let ids = try await seed(session, 12)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.all.count == 4 }
            await model.loadMore(.notes)
            #expect(model.all.count == 8)
            // The oldest note is touched again (a sync apply's shape: its
            // stamp moves) — it moves to the top of the edited sort.
            let oldest = ids[0]
            try await db.write { db in
                try db.execute(
                    sql: "UPDATE container SET last_touched_at = '2099-01-01T00:00:00.000Z' WHERE id = ?",
                    arguments: [oldest])
            }
            await settle { model.all.first?.postID == oldest }
            #expect(model.all.first?.postID == oldest, "the moved note leads")
            #expect(model.all.count == 8, "the listed depth is kept")
            #expect(Set(model.all.map(\.postID)).count == 8, "no note twice")
            let expected = try await db.read {
                try Queries.library($0, sort: .lastTouched, direction: .desc, limit: 8)
            }
            #expect(model.all.map(\.postID) == expected.map(\.postID))
        }
    }

    /// **A row deleted past the first page leaves the listing** (VM-64 ladder
    /// round 2, finding 1 — the Mac's `refresh` after an act on its own rows).
    /// Two pages listed, held on screen; the seventh row deleted through its
    /// own door: it leaves, and the listing keeps its LISTED depth (the row
    /// below moves up — the re-ask reads to the depth she scrolled to) in
    /// `Queries.library`'s order.
    ///
    /// RED ON OLD: only the first page is held, it did not change, and
    /// `AppDatabase.observe` delivers only a changed value — so nothing landed
    /// and the deleted note stayed listed. (Old API only: this pin is in the
    /// red-on-old build.)
    @Test func aRowDeletedPastTheFirstPageLeavesTheListing() async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 12)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.all.count == 4 }
            await model.loadMore(.notes)
            #expect(model.all.count == 8, "the premise: two pages listed")
            let doomed = model.all[6]
            #expect(await model.confirmDeleteNote(doomed))
            await settle { !model.all.contains { $0.postID == doomed.postID } }
            #expect(!model.all.contains { $0.postID == doomed.postID },
                    "the deleted note left the listing")
            let expected = try await db.read {
                try Queries.library($0, sort: .lastTouched, direction: .desc, limit: 8)
            }
            #expect(model.all.map(\.postID) == expected.map(\.postID),
                    "the listed depth is kept, in the listing's order")
        }
    }

    /// **The line's own Undo returns a row deleted past the first page** (VM-64
    /// ladder round 2, finding 1 — the Put back leg, arm (A); the pin as the
    /// reviewer's final call words it). Two pages listed, held on screen; the
    /// seventh row deleted through its own door until it is gone; then the
    /// message line's own Undo — Put back, read off the line as it spoke — is
    /// pressed: the note is listed again, in `Queries.library`'s first eight, and
    /// no note twice. The Put back stamps none of the sort keys, so the held
    /// first page does not change and nothing is delivered: only the line's
    /// signal (`.variorumPutBackLanded`) re-asks the listing.
    ///
    /// RED ON OLD — on the first turn's tree (the delete leg in, arm (A) not):
    /// the row never returns while the hold stands (the last two expectations).
    /// On `vm64-gate2-red`, where the delete leg is reversed too, the row never
    /// LEAVES, so this pin is red at its premise only and its Put back arm is
    /// vacuous there; the witness below is the Put back arm's own red-on-old.
    /// (Old API only: in the red-on-old build.)
    @Test func aPutBackThroughTheLinesUndoReturnsARowPastTheFirstPage() async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 12)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.all.count == 4 }
            await model.loadMore(.notes)
            #expect(model.all.count == 8, "the premise: two pages listed")
            let doomed = model.all[6]
            #expect(await model.confirmDeleteNote(doomed))
            let undo = try #require(session.status.current?.action, "the line offers its Undo (Put back)")
            await settle { !model.all.contains { $0.postID == doomed.postID } }
            #expect(!model.all.contains { $0.postID == doomed.postID },
                    "the premise: the deleted note left the listing")

            undo.perform()
            await settle { model.all.contains { $0.postID == doomed.postID } }
            #expect(model.all.contains { $0.postID == doomed.postID },
                    "the note Put back is listed again")
            let expected = try await db.read {
                try Queries.library($0, sort: .lastTouched, direction: .desc, limit: 8)
            }
            #expect(model.all.map(\.postID) == expected.map(\.postID),
                    "in its place, the listed depth kept, in the listing's order")
            #expect(Set(model.all.map(\.postID)).count == model.all.count, "no note twice")
        }
    }

    /// **WITNESS — the Put back arm's red-on-old on the one red build** (VM-64
    /// ladder round 2, finding 1, arm (A)). The same world and the same line's
    /// Undo, but between the delete and the Undo the Library leaves and comes
    /// back (the hold ended and taken again — a band swipe away and back), and
    /// the return's re-ask makes the listing honest on EVERY build: the deleted
    /// note is gone whether or not the delete leg re-asked. So between the
    /// Undo and the row there is only arm (A).
    ///
    /// RED ON OLD — on `vm64-gate2-red` (every production hunk of this pass
    /// reversed, arm (A)'s included): after the Undo nothing re-asks, the row
    /// stays missing (the last two expectations). (Old API only.)
    @Test func aPutBackAfterTheLibraryCameBackReturnsARowPastTheFirstPage() async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 12)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let first = Task { await model.hold(model.hold(onScreen: true)) }
            defer { first.cancel() }
            await settle { model.all.count == 4 }
            await model.loadMore(.notes)
            #expect(model.all.count == 8, "the premise: two pages listed")
            let doomed = model.all[6]
            #expect(await model.confirmDeleteNote(doomed))
            let undo = try #require(session.status.current?.action, "the line offers its Undo (Put back)")

            first.cancel()
            await first.value
            let back = Task { await model.hold(model.hold(onScreen: true)) }
            defer { back.cancel() }
            await settle { model.all.count == 8 && !model.all.contains { $0.postID == doomed.postID } }
            #expect(!model.all.contains { $0.postID == doomed.postID },
                    "the premise: the return re-asked — the deleted note is gone")

            undo.perform()
            await settle { model.all.contains { $0.postID == doomed.postID } }
            #expect(model.all.contains { $0.postID == doomed.postID },
                    "the note Put back is listed again")
            let expected = try await db.read {
                try Queries.library($0, sort: .lastTouched, direction: .desc, limit: 8)
            }
            #expect(model.all.map(\.postID) == expected.map(\.postID),
                    "in its place, the listed depth kept, in the listing's order")
        }
    }

    // MARK: - A fully listed listing stays complete (VM-64 ladder round 3, finding 1)

    /// Lists the note listing to its end (`loadMore` until no cursor is left).
    private func listToTheEnd(_ model: MobileLibraryViewModel) async {
        var guardLoops = 0
        while model.allHasMore, guardLoops < 20 {
            await model.loadMore(.notes)
            guardLoops += 1
        }
    }

    /// **The line's Undo of the LAST row of a fully listed listing returns it**
    /// (the round-3 reviewer's pin). Six notes, a page of four, held on screen
    /// and listed to the end; the last (oldest) row deleted through its own
    /// door; the message line's own Undo pressed. The Put back's re-ask reads
    /// the LISTED depth — five — which over six notes is the first five and a
    /// cursor, so the note Put back needs one more page; `land` asks for it
    /// because the rows it replaced were complete for the same question.
    ///
    /// RED ON OLD (round 2's tree with round 3's `land` hunk reversed): nothing
    /// asked for that page — `wantsMore` is raised only by a row coming on screen
    /// while a cursor stands, and the listing's tail was already on screen — so
    /// the note Put back is not listed and the listing reads as having more
    /// (3 issues: listed again; the store's whole listing; `!allHasMore`).
    @Test func aPutBackOfTheLastRowOfAFullyListedListingReturnsIt() async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 6)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.all.count == 4 }
            await listToTheEnd(model)
            #expect(model.all.count == 6 && !model.allHasMore, "the premise: listed to the end")
            let doomed = model.all[5]
            #expect(await model.confirmDeleteNote(doomed))
            let undo = try #require(session.status.current?.action, "the line offers its Undo (Put back)")
            await settle { model.all.count == 5 }
            #expect(!model.all.contains { $0.postID == doomed.postID },
                    "the premise: the deleted note left the listing")

            undo.perform()
            await settle { model.all.contains { $0.postID == doomed.postID } && !model.allHasMore }
            #expect(model.all.contains { $0.postID == doomed.postID }, "the note Put back is listed again")
            let whole = try await db.read { try Queries.library($0, sort: .lastTouched, direction: .desc) }
            #expect(model.all.map(\.postID) == whole.map(\.postID), "the store's whole listing, in its order")
            #expect(Set(model.all.map(\.postID)).count == model.all.count, "no note twice")
            #expect(!model.allHasMore, "a listing that was complete stays complete")
        }
    }

    /// **…and a row ABOVE the end comes back without the last row dropping off**
    /// (finding 1's shapes (b) and (c), at the model level). Twelve notes, three
    /// pages, listed to the end; the seventh row deleted and the line's Undo
    /// pressed: the re-ask at the listed depth — eleven — returns the restored
    /// note in its place and pushes the oldest off; one page more brings it back.
    /// In the app the two shapes differ only by a view's `onAppear` (a row
    /// within the last 30 asks for the page itself once it comes on screen; one
    /// further up does not), and a model world has no view, so this arm stands
    /// for both; a view-level arm for the 30-row margin needs a hosted list
    /// deeper than 30 rows past a page, which this world does not reach.
    ///
    /// RED ON OLD: the listing ends one row short of the store and reads as
    /// having more (2 issues: the store's whole listing; `!allHasMore`); the
    /// restored row itself is listed on both trees.
    @Test func aPutBackOfARowAboveTheEndOfAFullyListedListingKeepsItsLastRow() async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 12)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.all.count == 4 }
            await listToTheEnd(model)
            #expect(model.all.count == 12 && !model.allHasMore, "the premise: listed to the end")
            let doomed = model.all[6]
            #expect(await model.confirmDeleteNote(doomed))
            let undo = try #require(session.status.current?.action, "the line offers its Undo (Put back)")
            await settle { model.all.count == 11 }
            #expect(!model.all.contains { $0.postID == doomed.postID },
                    "the premise: the deleted note left the listing")

            undo.perform()
            await settle { model.all.count == 12 && !model.allHasMore }
            #expect(model.all.contains { $0.postID == doomed.postID }, "the note Put back is listed again")
            let whole = try await db.read { try Queries.library($0, sort: .lastTouched, direction: .desc) }
            #expect(model.all.map(\.postID) == whole.map(\.postID),
                    "the store's whole listing — the last row kept")
            #expect(!model.allHasMore, "a listing that was complete stays complete")
        }
    }

    /// **A note arriving at the top of a fully listed listing keeps its last row**
    /// (finding 1's arrival case — VM-242's neighbour, with no Undo: the same
    /// landing). Six notes listed to the end; a seventh minted: the held first
    /// page moves, the follow re-asks the listed depth (six) over seven notes,
    /// and the oldest — on screen at the listing's end — would drop off and wait
    /// for a scroll.
    ///
    /// RED ON OLD: 2 issues (the store's whole listing; `!allHasMore`).
    @Test func aNoteArrivingAtTheTopOfAFullyListedListingKeepsItsLastRow() async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 6)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.all.count == 4 }
            await listToTheEnd(model)
            #expect(model.all.count == 6 && !model.allHasMore, "the premise: listed to the end")

            let arrived = try await seed(session, 1, prefix: "arrived")[0]
            await settle { model.all.first?.postID == arrived && !model.allHasMore }
            #expect(model.all.first?.postID == arrived, "the arrival leads")
            let whole = try await db.read { try Queries.library($0, sort: .lastTouched, direction: .desc) }
            #expect(model.all.map(\.postID) == whole.map(\.postID),
                    "the store's whole listing — the oldest kept")
            #expect(!model.allHasMore, "a listing that was complete stays complete")
        }
    }

    /// **A listing's rows are drawn only while they answer the current wing**
    /// (VM-64 ladder round 2, finding 3). Bookless held on screen in Home lists
    /// Home's loose note; the hold ends; the wing switches while the Library is
    /// hidden (VM-55's door lands on the Shelf), so the hidden hold reads the
    /// note listing alone and Bookless still holds Home's rows. Until Work's
    /// first page lands the door draws NO Home note and says no empty line;
    /// on screen again it lists Work's.
    ///
    /// RED ON OLD: `visible` was Home's row — another wing's note, drawn and
    /// tappable. (The empty line and the return are guards, green on both.)
    @Test func aWingSwitchedWhileBooklessWasNotHeldDrawsNoOtherWingsRows() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let model = MobileLibraryViewModel(session: session)
            model.filter = .bookless
            let inHome = Task { await model.hold(model.hold(onScreen: true)) }
            await settle { model.bookless.map(\.postID) == [world.homeNote] }
            #expect(model.visible.map(\.postID) == [world.homeNote], "the premise: Home's loose note")
            inHome.cancel()
            await inHome.value

            session.wing.switchTo(world.work)
            await model.hold(model.hold(onScreen: false))  // hidden: the note listing alone
            #expect(!model.visible.contains { $0.postID == world.homeNote },
                    "no frame draws another wing's note")
            #expect(model.visible.isEmpty)
            #expect(model.emptyListing(booksShown: 0) == nil, "and no empty line flashes meanwhile")

            let inWork = Task { await model.hold(model.hold(onScreen: true)) }
            defer { inWork.cancel() }
            await settle { model.visible.map(\.postID) == [world.workNote] }
            #expect(model.visible.map(\.postID) == [world.workNote], "the return lists Work's")
        }
    }

    /// **The same, by the filter door** (finding 3's other trigger): Bookless
    /// last landed in Home; the wing switched while All showed; the Bookless door
    /// opened before its first fetch in Work draws no Home note and says nothing.
    ///
    /// RED ON OLD: `visible` was Home's row.
    @Test func aDoorOpenedAfterAWingSwitchDrawsNoOtherWingsRows() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let model = MobileLibraryViewModel(session: session)
            model.filter = .bookless
            let inHome = Task { await model.hold(model.hold(onScreen: true)) }
            await settle { model.bookless.map(\.postID) == [world.homeNote] }
            inHome.cancel()
            await inHome.value

            model.filter = .all
            session.wing.switchTo(world.work)
            let onAll = Task { await model.hold(model.hold(onScreen: true)) }
            await settle { model.all.map(\.postID) == [world.workNote] }
            onAll.cancel()
            await onAll.value

            model.filter = .bookless  // the door, before its first fetch in Work
            #expect(!model.visible.contains { $0.postID == world.homeNote },
                    "the door draws no other wing's note")
            #expect(model.emptyListing(booksShown: 0) == nil)
        }
    }

    /// **A new question starts over**: flipping the sort while two pages are
    /// listed lands the new sort's FIRST page, not the old depth.
    @Test func aNewQuestionStartsAtItsFirstPage() async throws {
        try await withEditorWorld { session, _ in
            _ = try await seed(session, 10)
            let model = MobileLibraryViewModel(session: session, listingLimit: 3)
            await model.hold(model.hold(onScreen: false))
            await model.loadMore(.notes)
            #expect(model.all.count == 6)
            model.setSort(.createdAt)
            await model.hold(model.hold(onScreen: false))
            #expect(model.all.count == 3, "a new question is its first page")
        }
    }

    /// **The Bookless door says nothing until its first answer**, then the
    /// truth: the trio over an empty wing, its own line over booked notes.
    @Test func theBooklessDoorSpeaksOnlyOnceItHasAnswered() async throws {
        try await withEditorWorld { session, _ in
            let model = MobileLibraryViewModel(session: session)
            model.filter = .bookless
            #expect(model.emptyListing(booksShown: 0) == nil, "no line before the first answer")
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            await settle { model.booklessLoaded }
            #expect(model.emptyListing(booksShown: 0) == .storeEmpty)
            held.cancel()
            await held.value

            try await session.runner.run { ops in
                let book = try ops.createReading(name: "b", kind: .book)
                let note = try ops.createPost(title: "booked")
                _ = try ops.addPostToReading(note.id, to: book.id)
            }
            let again = Task { await model.hold(model.hold(onScreen: true)) }
            defer { again.cancel() }
            await settle { model.emptyListing(booksShown: 0) == .noBookless }
            #expect(model.emptyListing(booksShown: 0) == .noBookless)
        }
    }

    /// The hold key: a note listing per filter (none for Books and Scraps),
    /// the sort for the note listing only, the wing, and the screen. *(The
    /// wing's lines: the merge of main — VM-55 — where the phone's read scope
    /// became the current wing.)*
    @Test func theHoldKeyNamesTheShownListing() async throws {
        try await withEditorWorld { session, _ in
            let model = MobileLibraryViewModel(session: session)
            #expect(model.hold(onScreen: true).question?.listing == .notes)
            model.filter = .bookless
            #expect(model.hold(onScreen: true).question?.listing == .bookless)
            #expect(model.hold(onScreen: true).question?.sort == .lastTouched)
            for door in [MobileListingFilter.books, .scraps] {
                model.filter = door
                #expect(model.hold(onScreen: true).question == nil)
            }
            model.filter = .all
            let before = model.hold(onScreen: true)
            model.setSort(.createdAt)
            #expect(model.hold(onScreen: true) != before, "a sort flip restarts the hold")
            #expect(model.hold(onScreen: false) != model.hold(onScreen: true))
            // The wing: the question reads the phone's current wing, so a switch
            // restarts the hold (the view's task re-keys) — shown or hidden.
            #expect(model.hold(onScreen: true).question?.wing == session.wing.currentID)
            let inHome = (shown: model.hold(onScreen: true), hidden: model.hold(onScreen: false))
            session.wing.switchTo("vm64-merge-wing")
            #expect(model.hold(onScreen: true).question?.wing == "vm64-merge-wing")
            #expect(model.hold(onScreen: true) != inHome.shown, "a wing switch restarts the shown hold")
            #expect(model.hold(onScreen: false) != inHome.hidden, "and the hidden one")
        }
    }

    // MARK: - Pure

    /// **The union of a paged listing withholds what it cannot yet place**:
    /// while notes remain, a book older than the last listed note waits; when
    /// every note is listed, every book shows.
    @Test func theUnionWithholdsBooksOlderThanTheLastListedNote() {
        func note(_ id: String, _ stamp: String) -> Queries.TimelineItem {
            Queries.TimelineItem(postID: id, title: id, entryDate: nil, stamp: stamp)
        }
        func book(_ id: String, _ seconds: TimeInterval) -> Queries.ShelfBook {
            let date = Date(timeIntervalSince1970: seconds)
            return Queries.ShelfBook(
                reading: Reading(
                    id: id, name: id, kind: .book, createdAt: date, updatedAt: date),
                postCount: 0, sectionCount: 0)
        }
        let notes = [
            note("n3", DateFormatter.variorumISO8601.string(from: Date(timeIntervalSince1970: 3_000))),
            note("n2", DateFormatter.variorumISO8601.string(from: Date(timeIntervalSince1970: 2_000))),
        ]
        let books = [book("new", 2_500), book("old", 1_000)]
        let paged = MobileLibraryViewModel.union(
            notes: notes, books: books, sort: .lastTouched, notesComplete: false)
        #expect(paged.map(\.id) == ["note:n3", "book:new", "note:n2"],
                "the older book waits for the notes not yet read")
        let whole = MobileLibraryViewModel.union(
            notes: notes, books: books, sort: .lastTouched, notesComplete: true)
        #expect(whole.map(\.id) == ["note:n3", "book:new", "note:n2", "book:old"])
        #expect(MobileLibraryViewModel.union(notes: notes, books: books, sort: .lastTouched).map(\.id)
                == whole.map(\.id), "the default is the whole listing (every existing caller)")
    }

    /// **A page's hits become the listing's rows**: the stored title (nil when
    /// absent), the stated day, the birth stamp, the profile, and the row's
    /// sort key as its stamp.
    @Test func aPagesHitsBecomeTheListingsRows() {
        let page = Queries.CatalogNotesPage(
            hits: [
                Queries.CatalogHit(
                    kind: .post, id: "a", title: "Alpha", detail: "2026-05-01",
                    storedTitle: "Alpha", createdAt: "2026-04-01T00:00:00.000Z",
                    lastTouchedAt: "2026-05-02T00:00:00.000Z", profile: "journal"),
                Queries.CatalogHit(
                    kind: .post, id: "b", title: "2026-04-03", detail: nil,
                    storedTitle: nil, createdAt: "2026-04-03T00:00:00.000Z"),
            ],
            next: nil, keys: ["K-a", "K-b"])
        let rows = MobileLibraryViewModel.timelineItems(page)
        #expect(rows == [
            Queries.TimelineItem(
                postID: "a", title: "Alpha", entryDate: "2026-05-01",
                createdAt: "2026-04-01T00:00:00.000Z", stamp: "K-a", profile: "journal"),
            Queries.TimelineItem(
                postID: "b", title: nil, entryDate: nil,
                createdAt: "2026-04-03T00:00:00.000Z", stamp: "K-b", profile: nil),
        ])
    }

    /// **The shell's on-screen fact** (`MobileShellBand.isDrawn`): the current
    /// page is drawn; a neighbour only while a drag pulls it into view; a page
    /// two away never; a zero-width pass draws only the current page.
    @Test func aPageIsDrawnOnlyWhileAnyOfItShows() {
        let width: CGFloat = 393
        #expect(MobileShellBand.isDrawn(.library, current: .library, drag: 0, width: width))
        #expect(!MobileShellBand.isDrawn(.library, current: .shelf, drag: 0, width: width))
        #expect(MobileShellBand.isDrawn(.library, current: .shelf, drag: -1, width: width),
                "a drag toward the Library reveals it")
        #expect(!MobileShellBand.isDrawn(.library, current: .shelf, drag: 40, width: width),
                "a drag the other way does not")
        #expect(!MobileShellBand.isDrawn(.library, current: .starred, drag: -width, width: width),
                "two pages away is never drawn")
        #expect(MobileShellBand.isDrawn(.shelf, current: .library, drag: 10, width: width))
        #expect(MobileShellBand.isDrawn(.shelf, current: .shelf, drag: 0, width: 0))
        #expect(!MobileShellBand.isDrawn(.library, current: .shelf, drag: -10, width: 0))
    }
}
