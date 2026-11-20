//
//  MobileWingsTests.swift
//  VariorumMobileTests
//
//  VM-55 "Wings underneath", batch 1 — THE PHONE STANDS IN ONE WING. The
//  acceptance evidence for VM-56 (the current wing, its memory, the held
//  wings read, the roots' title), VM-57 (every listing reads the current
//  wing and re-reads when it changes), VM-58 (mints are born in the current
//  wing; Today's entry beside its Journal) and VM-60 (the tag manager per
//  wing) — state-transition and view-model tests over ONE two-wing fixture
//  whose twins make a leak visible: a note titled "Field notes", a book
//  named "Essays" and a tag "trip" in EACH wing, plus a Home-only tag.
//  (VM-59's red-on-old pins live in `MobileWingBlindPickerTests`.)
//

import Dependencies
import Foundation
import GRDB
import Observation
import Testing
import VariorumCore
@testable import VariorumMobile

// MARK: - The two-wing fixture

/// One store, two wings, a twin of each kind in each.
struct TwoWingWorld {
    let work: String
    let homeNote: String
    let workNote: String
    let homeBook: String
    let workBook: String
    let homeTrip: String
    let workTrip: String
    let homeOnly: String

    @MainActor
    static func make(_ session: AppSession) throws -> TwoWingWorld {
        let ops = session.operations
        let work = try ops.createWing(name: "Work").id
        return TwoWingWorld(
            work: work,
            homeNote: try ops.createPost(title: "Field notes").id,
            workNote: try ops.createPost(title: "Field notes", wingId: work).id,
            homeBook: try ops.createReading(name: "Essays", kind: .book).id,
            workBook: try ops.createReading(name: "Essays", kind: .book, wingId: work).id,
            homeTrip: try ops.createTag(name: "trip").id,
            workTrip: try ops.createTag(name: "trip", wingID: work).id,
            homeOnly: try ops.createTag(name: "homeonly").id)
    }
}

/// Polls until `condition` holds (a held observation delivers off the main
/// actor); answers whether it did.
@MainActor
func eventually(_ condition: () -> Bool, limit: Int = 4000) async -> Bool {
    for _ in 0..<limit where !condition() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
    return condition()
}

/// Simulates a sync apply's tombstone on a wing row (apply mode — the
/// outbox stays quiet, exactly as a pulled row lands).
func tombstoneWingAsSyncWould(_ db: AppDatabase, _ wingID: String) async throws {
    let stamp = DateFormatter.variorumISO8601.string(from: Date())
    try await db.write { db in
        try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
        try db.execute(
            sql: "UPDATE wing SET deleted_at = ?, updated_at = ? WHERE id = ?",
            arguments: [stamp, stamp, wingID])
        try db.execute(sql: "DELETE FROM _sync_applying")
    }
}

/// **The Library's listing, held the way its VIEW holds it** (the merge of
/// main — VM-55 — into the VM-64 run). Since VM-68 (VM-64 batch 5) the Library
/// model no longer follows the wing by itself: `MobileLibraryView` runs ONE
/// `.task(id: model.hold(onScreen:)) { await model.hold($0) }`, whose key is the
/// question the shown filter asks — the sort, the filter and the WING
/// (`Question.wing` is `WingState.readScope`, the current wing on the phone since
/// VM-56) — so SwiftUI restarts the hold whenever the wing changes, and the
/// restarted hold's first fetch is the new wing's page. This drives exactly that:
/// the key read under observation tracking, as the view's body reads it, and the
/// hold restarted on every change of it (cancelling the one before, as
/// `.task(id:)` does). VM-55's Library pins drove `startAll()` / `startBookless()`
/// when those were the view's road and followed the wing themselves
/// (`MobileWingScope.follow`); they drive this now, their expectations unchanged.
/// A key that stopped carrying the wing — or a wing state the key could not
/// observe — leaves the old wing's rows standing, and those pins go red.
@MainActor
func holdLibraryAsItsViewDoes(
    _ model: MobileLibraryViewModel, onScreen: Bool = true
) -> Task<Void, Never> {
    Task { @MainActor in
        var running: Task<Void, Never>?
        var last: MobileLibraryViewModel.Hold?
        defer { running?.cancel() }
        for await key in Observations({ model.hold(onScreen: onScreen) }) where key != last {
            last = key
            running?.cancel()
            running = Task { @MainActor in await model.hold(key) }
        }
    }
}

// MARK: - VM-56 — the phone stands in one wing

@MainActor
@Suite("VM-56 — the phone remembers its wing, and every root says which", .serialized)
struct MobileWingStandTests {
    /// The shared read scope is the current wing on the phone (it was nil —
    /// every wing — until VM-56).
    @Test func theReadScopeIsTheCurrentWingOnThePhone() {
        let state = WingState()
        #expect(state.readScope == "", "Home on a device that never switched")
        state.switchTo("w1")
        #expect(state.readScope == "w1", "the phone's shared reads take the wing it stands in")
    }

    /// The memory the bootstrap attaches (now on both platforms): local,
    /// written through on a switch, and a dead wing returns Home — an
    /// injected scratch suite, never the Debug app's defaults.
    @Test func theRememberedWingIsLocalAndRevalidatesOnThePhone() throws {
        let suite = "vm56-wing-tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let state = WingState()
        defaults.set("w2", forKey: WingState.memoryKey)
        state.attachMemory(defaults)
        #expect(state.currentID == "w2", "the phone stands where it last stood")
        state.switchTo("w3")
        #expect(defaults.string(forKey: WingState.memoryKey) == "w3")
        state.revalidate { $0.isEmpty }
        #expect(state.currentID == "")
        #expect(defaults.string(forKey: WingState.memoryKey) == "")
    }

    /// A wing deleted HERE while the phone stands in it returns the phone to
    /// Home through the held wings read.
    ///
    /// VM-225 (batch 4) — A JUSTIFIED EDIT of this pin and the next two:
    /// batch 1's interim `MobileWingModel` was FOLDED into the shared
    /// `WingsModel` (VM-63's hoist — the same `track`/`load`/`adopt`), which is
    /// what the shell now holds (`MobileWingDoor.phoneWings`). Each pin drives
    /// that brain and asserts the same facts: "the held read delivered" is its
    /// rows naming the wing (the folded holder's `loaded`), and the title is
    /// `MobileWingTitle.name`, batch 1's rule kept on the phone side.
    @Test func aWingDeletedHereReturnsThePhoneHome() async throws {
        try await withEditorWorld { session, _ in
            let empty = try session.operations.createWing(name: "Scratch")
            session.wing.switchTo(empty.id)
            let wings = MobileWingDoor.phoneWings(session)
            let held = Task { await wings.track() }
            defer { held.cancel() }
            #expect(await eventually { wings.wings.map(\.id) == [empty.id] },
                    "the held read delivered")
            #expect(session.wing.currentID == empty.id)
            try session.operations.deleteWing(empty.id)
            #expect(await eventually { session.wing.currentID == "" },
                    "the dead wing returned the phone to Home")
            #expect(MobileWingTitle.name(of: wings) == "Home")
        }
    }

    /// A wing ARRIVING deleted by sync (still holding a note — the race the
    /// dangling rule exists for) returns the phone to Home, and the held
    /// listings follow: no listing stays scoped to the dead id, and the dead
    /// wing's note now reads as Home's.
    ///
    /// *(The VM-64 merge: the Library is held as its view holds it —
    /// `holdLibraryAsItsViewDoes`; the expectations are VM-55's, unchanged.)*
    @Test func aWingArrivingDeletedBySyncReturnsThePhoneHomeAndTheListingsFollow() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let wings = MobileWingDoor.phoneWings(session)
            let library = MobileLibraryViewModel(session: session)
            let heldWings = Task { await wings.track() }
            let heldLibrary = holdLibraryAsItsViewDoes(library)
            defer {
                heldWings.cancel()
                heldLibrary.cancel()
            }
            #expect(await eventually { library.all.map(\.postID) == [world.workNote] })
            try await tombstoneWingAsSyncWould(db, world.work)
            #expect(await eventually { session.wing.currentID == "" },
                    "the wing that arrived dead returned the phone to Home")
            #expect(await eventually {
                Set(library.all.map(\.postID)) == [world.homeNote, world.workNote]
            }, "the Library re-read in Home, where the dead wing's note now lives")
        }
    }

    /// Every root's title is the wing's name: Home for the virtual wing, a
    /// live wing's own name, a rename re-titling it; never a false "Home"
    /// before the name is read.
    @Test func everyRootIsTitledWithTheWingsName() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let wings = MobileWingDoor.phoneWings(session)
            #expect(MobileWingTitle.name(of: wings) == "Home", "Home is known without a read")
            session.wing.switchTo(world.work)
            #expect(MobileWingTitle.name(of: wings) == nil, "not yet read — never a false Home")
            // Why the rule stays on the phone side through the fold: the
            // shared brain's own name falls back to "Home" for an unread id.
            #expect(wings.currentName == "Home")
            await wings.load()
            #expect(MobileWingTitle.name(of: wings) == "Work")
            try session.operations.renameWing(world.work, to: "Office")
            await wings.load()
            #expect(MobileWingTitle.name(of: wings) == "Office", "a rename re-titles the roots")
        }
    }

    /// The path line's words: the wing first, then the page, in each voice's
    /// own path grammar; an unread name leaves the page alone.
    @Test func thePathLineLeadsWithTheWing() {
        #expect(MobileWingTitle.components(wing: "Home", page: "Library") == ["Home", "Library"])
        #expect(MobileWingTitle.components(wing: nil, page: "Library") == ["Library"])
        let study = VoiceTokens.resolve(voice: .study, dark: false)
        let terminal = VoiceTokens.resolve(voice: .terminal, dark: false)
        // R-47-3 MOVED from "Shelf": the Bookcase root's page word is its tab's,
        // "Bookcase" (her ruling, 2026-11-19).
        #expect(study.path(MobileWingTitle.components(wing: "Work", page: "Bookcase")) == "Work · Bookcase")
        #expect(terminal.path(MobileWingTitle.components(wing: "Work", page: "Bookcase")) == "~/work/bookcase")
    }
}

// MARK: - VM-57 — every listing reads the current wing

@MainActor
@Suite("VM-57 — every phone listing shows only the current wing", .serialized)
struct MobileWingListingTests {
    /// *(The VM-64 merge — this pin and the next: the Library's listings are
    /// held as its view holds them, `holdLibraryAsItsViewDoes` — the paged
    /// model's road since VM-68; the expectations are VM-55's, unchanged.)*
    @Test func theLibraryListsOnlyTheCurrentWingAndFollowsIt() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let model = MobileLibraryViewModel(session: session)
            let held = holdLibraryAsItsViewDoes(model)
            defer { held.cancel() }
            #expect(await eventually { model.all.map(\.postID) == [world.workNote] },
                    "Work's Library holds Work's note alone")
            session.wing.switchTo("")
            #expect(await eventually { model.all.map(\.postID) == [world.homeNote] },
                    "the listing re-read when the wing changed")
        }
    }

    @Test func thePoolListsOnlyTheCurrentWing() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let model = MobileLibraryViewModel(session: session)
            // The Bookless listing is held while its filter is the one shown.
            model.filter = .bookless
            let held = holdLibraryAsItsViewDoes(model)
            defer { held.cancel() }
            #expect(await eventually { model.bookless.map(\.postID) == [world.workNote] })
            session.wing.switchTo("")
            #expect(await eventually { model.bookless.map(\.postID) == [world.homeNote] })
        }
    }

    /// The Shelf and the Library's Books filter wear one model: two books
    /// named "Essays", one per wing — each wing lists its own.
    @Test func theBooksListOnlyTheCurrentWing() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let shelf = MobileShelfViewModel(session: session)
            let held = Task { await shelf.start() }
            defer { held.cancel() }
            #expect(await eventually { shelf.books.map(\.reading.id) == [world.workBook] })
            session.wing.switchTo("")
            #expect(await eventually { shelf.books.map(\.reading.id) == [world.homeBook] })
        }
    }

    @Test func searchAsksTheCurrentWing() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let model = MobileLibraryViewModel(session: session)
            session.wing.switchTo(world.work)
            #expect(model.wingID == world.work, "the search task keys on the wing")
            await model.search("Essays")
            #expect(model.hits?.filter { $0.kind == .book }.map(\.id) == [world.workBook])
            await model.search("Field")
            #expect(model.hits?.filter { $0.kind == .post }.map(\.id) == [world.workNote])
            session.wing.switchTo("")
            await model.search("Field")
            #expect(model.hits?.filter { $0.kind == .post }.map(\.id) == [world.homeNote])
        }
    }

    @Test func starredListsTheCurrentWingsStars() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            try session.operations.setStarred(.post(world.homeNote), starred: true)
            try session.operations.setStarred(.post(world.workNote), starred: true)
            session.wing.switchTo(world.work)
            let stars = MobileStarsModel(session: session)
            let held = Task { await stars.start() }
            defer { held.cancel() }
            #expect(await eventually { stars.items.map(\.target) == [.post(world.workNote)] })
            session.wing.switchTo("")
            #expect(await eventually { stars.items.map(\.target) == [.post(world.homeNote)] })
            await stars.refresh()
            #expect(stars.items.map(\.target) == [.post(world.homeNote)], "the one-shot reads the wing too")
        }
    }

    @Test func archivedListsTheCurrentWing() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            try session.operations.archiveContainer(world.homeNote)
            try session.operations.archiveContainer(world.workNote)
            session.wing.switchTo(world.work)
            let model = MobileArchiveModel(session: session)
            let held = Task { await model.start() }
            defer { held.cancel() }
            #expect(await eventually { model.archived.map(\.postID) == [world.workNote] })
            session.wing.switchTo("")
            #expect(await eventually { model.archived.map(\.postID) == [world.homeNote] })
        }
    }

    /// The Trash lists the current wing's rows, and Empty Trash — the shared
    /// door that reads `WingState.readScope` — counts and takes exactly
    /// those: "a door may not take what it does not show", now on the phone.
    @Test func theTrashListsAndEmptiesTheCurrentWing() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            try session.operations.deleteContainer(world.homeNote)
            try session.operations.deleteContainer(world.workNote)
            session.wing.switchTo(world.work)
            let model = MobileTrashModel(session: session)
            let held = Task { await model.startTrash() }
            defer { held.cancel() }
            #expect(await eventually {
                model.trash.filter { $0.kind == .note }.map(\.id) == [world.workNote]
            })
            let confirm = try #require(try await TrashPurge.emptyTrashConfirm(session: session))
            guard case .emptyTrash(let counts, _) = confirm else {
                Issue.record("expected the empty-trash confirm, got \(confirm)")
                return
            }
            #expect(counts[.note] == 1, "the confirm counts this wing's Trash only")
            try await TrashPurge.confirm(session: session, confirm)
            let intents = try await db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT row_id FROM purge_intent WHERE table_name = 'container'")
            }
            #expect(intents == [world.workNote], "the act took this wing's row and no other")
        }
    }

    /// Snippets stay the ONE room all wings share (scope call 3): a snippet
    /// made in Home lists while the phone stands in Work.
    @Test func snippetsStayTheOneSharedRoom() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let scraps = MobileScrapsModel(session: session)
            #expect(await scraps.mintScrap("a loose line"))
            let made = try #require(scraps.items.first?.block.blockID)
            session.wing.switchTo(world.work)
            await scraps.refresh()
            #expect(scraps.items.map(\.block.blockID) == [made], "Snippets are not scoped to a wing")
        }
    }
}

// MARK: - VM-58 — mints are born in the current wing

@MainActor
@Suite("VM-58 — new notes, books and tags are born in the current wing", .serialized)
struct MobileWingMintTests {
    private func wing(ofPost id: String, _ db: AppDatabase) async throws -> String? {
        try await db.read { try Queries.effectiveWing($0, ofPost: id) }
    }

    /// + New Note (both doors share the one mint) lands in the current
    /// wing's Pool.
    @Test func aNewNoteIsBornInTheCurrentWing() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let id = try await MobileNewNoteDoor.mint(session: session)
            #expect(try await wing(ofPost: id, db) == world.work)
            let pool = try await db.read { try Queries.poolPosts($0, limit: 10, wingID: world.work) }
            #expect(pool.map(\.postID).contains(id), "it lands in the wing's Pool")
        }
    }

    /// Her SW-5: a quick note lands in the current wing, in its Pool.
    @Test func aQuickNoteLandsInTheCurrentWingsPool() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let box = MobileQuickNoteModel(session: session)
            box.sleep = { _ in throw CancellationError() }
            box.autosaveSleep = { _ in throw CancellationError() }
            box.text = "a thought on the bus"
            let id = try #require(await box.mintNow())
            #expect(try await wing(ofPost: id, db) == world.work)
            let pool = try await db.read { try Queries.poolPosts($0, limit: 10, wingID: world.work) }
            #expect(pool.map(\.postID).contains(id))
        }
    }

    /// + New Book mints in the wing the sheet opened in, and the name guard
    /// is that wing's: Home's "Essays" does not stop a fresh wing's, the
    /// wing's own does.
    @Test func aNewBookIsBornInTheCurrentWingAndTheNameGuardIsPerWing() async throws {
        try await withEditorWorld { session, db in
            _ = try TwoWingWorld.make(session)
            let fresh = try session.operations.createWing(name: "Garden").id
            session.wing.switchTo(fresh)
            let sheet = MobileCreateBookModel(session: session)
            sheet.name = "Essays"
            let id = try #require(await sheet.create(), "Home's Essays is another library's")
            let bookWing = try await db.read { try Queries.effectiveWing($0, ofReading: id) }
            #expect(bookWing == fresh)
            let again = MobileCreateBookModel(session: session)
            again.name = "Essays"
            #expect(await again.create() == nil, "the wing's own Essays refuses")
            #expect(again.lastError == BookNameCopy.refusal(existing: "Essays"))
        }
    }

    /// Today: with no Journal anywhere, the entry and the fresh Journal land
    /// where she stands; from another wing, Today opens the day's entry
    /// beside its Journal — never a second one where she stands.
    @Test func todaysEntryIsBornBesideTheJournal() async throws {
        try await withEditorWorld { session, db in
            let work = try session.operations.createWing(name: "Work").id
            session.wing.switchTo(work)
            let first = try await MobileTodayDoor.open(session: session, day: "2026-11-19")
            #expect(try await wing(ofPost: first.postID, db) == work)
            let journalWing = try await db.read { db -> String? in
                guard let id = try Queries.dailyJournalBookID(db) else { return nil }
                return try Queries.effectiveWing(db, ofReading: id)
            }
            #expect(journalWing == work, "the fresh Journal is born where she stands")
            session.wing.switchTo("")
            let second = try await MobileTodayDoor.open(session: session, day: "2026-11-19")
            #expect(second.postID == first.postID, "the Journal's own wing wins")
        }
    }
}

// MARK: - VM-60 — the tag manager per wing

@MainActor
@Suite("VM-60 — the tag manager shows and makes tags in the current wing", .serialized)
struct MobileWingTagManagerTests {
    @Test func theTagManagerListsAndNamesTheCurrentWing() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let model = MobileTagsModel(session: session)
            await model.refresh()
            #expect(model.tags.map(\.id) == [world.workTrip], "Work's vocabulary alone")
            #expect(model.title == "Tags \u{2014} in Work", "the Mac's words, naming the wing")
            let held = Task { await model.start() }
            defer { held.cancel() }
            #expect(await eventually { model.tags.map(\.id) == [world.workTrip] })
            // Let the held read settle in Work before the wing moves under it.
            for _ in 0..<20 { await Task.yield() }
            session.wing.switchTo("")
            #expect(await eventually {
                model.tags.map(\.id) == [world.homeOnly, world.homeTrip]
            }, "the list followed the wing")
            #expect(model.title == "Tags \u{2014} in Home")
        }
    }

    @Test func theTagManagerMakesRootTagsInTheCurrentWing() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let model = MobileTagsModel(session: session)
            await model.create(parentID: nil, name: "garden")
            #expect(model.lastError == nil)
            let garden = try #require(model.tags.first { $0.path == "garden" })
            #expect(garden.wingId == world.work, "a root tag is born in the current wing")
            await model.create(parentID: garden.id, name: "roses")
            let roses = try #require(model.tags.first { $0.path == "garden/roses" })
            #expect(roses.wingId == world.work, "a child is born in its parent's")

            // The typed path resolves in THIS wing: Home's "homeonly" does
            // not anchor it, so Work mints its own root and the child.
            await model.createTypedPath("homeonly/sub")
            #expect(model.lastError == nil)
            let made = try await db.read { db in
                try Queries.allTags(db, wingID: world.work).map(\.path)
            }
            #expect(made.contains("homeonly") && made.contains("homeonly/sub"))
            let homePaths = try await db.read { try Queries.allTags($0, wingID: "").map(\.path) }
            #expect(!homePaths.contains("homeonly/sub"), "Home's tree is untouched")

            // A path the wing already holds refuses as its duplicate; Home's
            // twin plays no part.
            await model.createTypedPath("trip")
            #expect(model.lastError == MobileTagsModel.refusal(
                OperationError.duplicateTagPath(path: "trip")))
        }
    }
}
