//
//  MembershipChoiceTests.swift
//  VariorumTests
//
//  13i-c U4 — THE MEMBERSHIP CHOICE (the 13i-c plan §3, §4 rows 14–18, §7 U4
//  row; the sitting record §2, §6).
//
//  What is pinned:
//  - the WORDS as static copy (the brief's two leads verbatim; the edit law
//    said at the door; the move's severed list; the finished-book block);
//  - the ONE model: a plain add lands with no choice; each ownership refusal
//    names its choice; the item lists exactly what the ops act on; Copy in
//    and Move in through their operations, with their receipts;
//  - EVERY HOST (§4 rows 14–18, one test each, named for the row): the road's
//    ownership refusal OPENS the sheet — read from what the presented sheet
//    recorded (P-2: the refusal opens the ceremony, never ends in words);
//    row 15's honest shape: the book view's drag roads create no membership,
//    and its own add road (the daily book's "+ new entry") BELLS like ⌘J.
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
private func withChoiceWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval = 0.05) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(until condition: () -> Bool) async {
    for _ in 0..<60 where !condition() {
        pump(0.05)
        for _ in 0..<10 { await Task.yield() }
    }
}

/// Mounts `view` in a real window for the body of `run`; any sheet the run
/// presented is ended before the window goes.
@MainActor
private func mounted<V: View>(_ view: V, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 900, height: 700),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.attachedSheet.map { window.endSheet($0) }
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: view)
    window.orderFrontRegardless()
    await settle(until: { false })
    try await run()
}

/// THE FIXTURE: an OWNED book "Mine", a plain book "Other" holding `shared`,
/// a plain book "Plain", and `claimed` — a note "Owner" (owned) holds.
private struct Shelf {
    let mine: Reading
    let other: Reading
    let plain: Reading
    let owner: Reading
    let shared: Container
    let claimed: Container
    let free: Container
}

@MainActor
private func shelf(_ session: AppSession) throws -> Shelf {
    let ops = session.operations
    let mine = try ops.createReading(name: "Mine", kind: .book)
    try ops.setReadingOwned(mine.id, owned: true)
    let other = try ops.createReading(name: "Other", kind: .book)
    let plain = try ops.createReading(name: "Plain", kind: .book)
    let owner = try ops.createReading(name: "Owner", kind: .book)
    try ops.setReadingOwned(owner.id, owned: true)
    let shared = try ops.createPost(title: "shared")
    _ = try ops.addPostToReading(shared.id, to: other.id)
    let claimed = try ops.createPost(title: "claimed")
    _ = try ops.addPostToReading(claimed.id, to: owner.id)
    let free = try ops.createPost(title: "free")
    return Shelf(
        mine: mine, other: other, plain: plain, owner: owner,
        shared: shared, claimed: claimed, free: free)
}

@MainActor
private func members(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
    try await db.read { try Queries.assembleReading($0, readingID: readingID) }.map(\.postID)
}

@MainActor
@Suite("The membership choice (13i-c U4)", .serialized)
struct MembershipChoiceTests {
    // MARK: - The words

    @Test func theWordsSayTheRuledTruth() {
        // The brief's two leads, verbatim.
        #expect(MembershipChoiceCopy.ownedTargetLead(book: "Book", elsewhere: ["X", "Y"])
                == "\u{201C}Book\u{201D} owns its notes. This note also lives in "
                + "\u{201C}X\u{201D} and \u{201C}Y\u{201D}.")
        #expect(MembershipChoiceCopy.ownedElsewhereLead(owner: "X")
                == "This note belongs to \u{201C}X\u{201D}, which owns its notes.")
        // The edit law AT the door (§2 — lesson 2's sentences).
        #expect(MembershipChoiceCopy.editLaw.contains("never copies"))
        #expect(MembershipChoiceCopy.editLaw.contains("because you choose one"))
        #expect(MembershipChoiceCopy.editLaw.contains("remembers where it came from"))
        // The list joiner.
        #expect(MembershipChoiceCopy.list(["A"]) == "\u{201C}A\u{201D}")
        #expect(MembershipChoiceCopy.list(["A", "B", "C"])
                == "\u{201C}A\u{201D}, \u{201C}B\u{201D} and \u{201C}C\u{201D}")
        // The move names what it severs — members it leaves, doors it stops waiting at.
        #expect(MembershipChoiceCopy.moveExplains(book: "M", leaves: ["X"], waitingAt: ["Z"])
                == "Move it in: it leaves \u{201C}X\u{201D} and stops waiting at "
                + "\u{201C}Z\u{201D}\u{2019}s door, and lives only in \u{201C}M\u{201D}.")
        #expect(MembershipChoiceCopy.moveBlocked(by: "Done").contains("copy it in instead"))
        // The receipts.
        #expect(MembershipChoiceCopy.copied(book: "M")
                == "Copied into \u{201C}M\u{201D} \u{2014} a linked copy; the original stays "
                + "where it was.")
        #expect(MembershipChoiceCopy.moved(book: "M", left: ["X", "Y"])
                == "Moved into \u{201C}M\u{201D} \u{2014} it left \u{201C}X\u{201D} and "
                + "\u{201C}Y\u{201D}.")
        // The verbs the registry declares.
        #expect(CapabilityRegistry.capability(.copyIn).verb == MembershipChoiceCopy.copyInVerb)
        #expect(CapabilityRegistry.capability(.moveIn).verb == MembershipChoiceCopy.moveInVerb)
    }

    /// The walk's W-1: the Terminal voice lowercased the whole copy-only
    /// button, her book's name with it ("copy into “poems”"). The chrome half
    /// is voiced; her name is not.
    @Test func theCopyButtonVoicesTheChromeNotHerBookName() {
        let item = MembershipChoice(
            kind: .copyOnly, postID: "n", noteTitle: "Ode",
            book: Queries.BookRef(id: "b", name: "Poems"), elsewhere: ["Owner"],
            owner: Queries.BookRef(id: "o", name: "Owner"), severed: [])
        #expect(item.copyButtonTitle(chrome: { $0.lowercased() })
                == "copy into \u{201C}Poems\u{201D}")
        let both = MembershipChoice(
            kind: .copyOrMove, postID: "n", noteTitle: "Ode",
            book: Queries.BookRef(id: "b", name: "Mine"), elsewhere: ["X"],
            owner: nil, severed: [])
        #expect(both.copyButtonTitle(chrome: { $0.lowercased() }) == "copy in")
    }

    // MARK: - The model

    @Test func aBooklessNoteMovesIntoAnOwnedBookCleanWithNoChoice() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            let doors = MembershipDoors(session: session)
            let choice = try await doors.add(world.free.id, to: world.mine.id)
            #expect(choice == nil, "bookless notes move in clean (§6)")
            #expect(try await members(db, world.mine.id) == [world.free.id])
            #expect(doors.pending == nil)
        }
    }

    @Test func anOwnedTargetOffersCopyOrMoveNamingWhereElseItLives() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            let doors = MembershipDoors(session: session)
            let added = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            #expect(!added)
            let item = try #require(doors.pending)
            #expect(item.kind == .copyOrMove)
            #expect(item.title == "Add \u{201C}shared\u{201D} to \u{201C}Mine\u{201D}?")
            #expect(item.elsewhere == ["Other"])
            #expect(item.leaves == ["Other"])
            #expect(item.moveBlockedBy == nil)
            #expect(item.offersMove)
            #expect(item.lines == [
                MembershipChoiceCopy.ownedTargetLead(book: "Mine", elsewhere: ["Other"]),
                MembershipChoiceCopy.copyExplains(book: "Mine", elsewhere: ["Other"]),
                MembershipChoiceCopy.moveExplains(book: "Mine", leaves: ["Other"], waitingAt: []),
            ])
            #expect(item.copyLabel == MembershipChoiceCopy.copyInVerb)
            #expect(try await members(db, world.mine.id).isEmpty, "nothing joins until she says")
        }
    }

    @Test func aPlainTargetOffersCopyOnlyNamingTheOwner() async throws {
        try await withChoiceWorld { session, _ in
            let world = try shelf(session)
            let doors = MembershipDoors(session: session)
            #expect(try await doors.addOrOffer(world.claimed.id, to: world.plain.id) == false)
            let item = try #require(doors.pending)
            #expect(item.kind == .copyOnly)
            #expect(item.owner?.name == "Owner")
            #expect(!item.offersMove, "a plain book is offered no move (§4)")
            #expect(item.lines.first == MembershipChoiceCopy.ownedElsewhereLead(owner: "Owner"))
            #expect(item.copyLabel == "Copy Into \u{201C}Plain\u{201D}")
        }
    }

    @Test func copyInLandsALinkedCopyAndLeavesTheOriginal() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            let item = try #require(doors.pending)
            let receipt = await doors.copyIn(item)
            #expect(receipt == MembershipChoiceCopy.copied(book: "Mine"))
            #expect(session.status.spoken?.text == receipt)
            #expect(doors.pending == nil)
            let mineNow = try await members(db, world.mine.id)
            #expect(mineNow.count == 1 && mineNow[0] != world.shared.id, "a copy joined")
            #expect(try await members(db, world.other.id) == [world.shared.id],
                    "the original keeps its life in Other")
        }
    }

    @Test func moveInLeavesTheOtherBooksAndSaysWhich() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            let item = try #require(doors.pending)
            let receipt = await doors.moveIn(item)
            #expect(receipt == MembershipChoiceCopy.moved(book: "Mine", left: ["Other"]))
            #expect(try await members(db, world.mine.id) == [world.shared.id])
            #expect(try await members(db, world.other.id).isEmpty, "it left Other")
        }
    }

    @Test func aFinishedBookAmongTheSeveredBlocksMoveAndSaysSo() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            try session.operations.lockReading(world.other.id)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            let item = try #require(doors.pending)
            #expect(item.moveBlockedBy == "Other")
            #expect(item.lines.contains(MembershipChoiceCopy.moveBlocked(by: "Other")),
                    "the sheet says Move can't, where Move would be")
            // The op itself refuses with THAT book's name — spoken if reached.
            #expect(await doors.moveIn(item) == nil)
            #expect(session.status.current?.text == MembershipChoiceCopy.moveRefusedFinished("Other"))
            #expect(try await members(db, world.mine.id).isEmpty)
            // Copy in stays open.
            _ = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            #expect(await doors.copyIn(try #require(doors.pending)) != nil)
        }
    }

    /// 13i-c ladder round 1 (the sealed-named-reopen class): a SEALED book
    /// among the severed names UNSEAL as the road out — Reopen refuses on a
    /// sealed book (`readingSealed`, R-13ic-3), so "is finished — reopen it
    /// first" named a door that cannot act (the P-2 class, in copy).
    /// Red-on-old: the sheet's blocked line and the Move refusal both said
    /// "is finished … reopen".
    @Test func aSealedBookAmongTheSeveredNamesUnsealNeverReopen() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            try session.operations.sealReading(world.other.id)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            let item = try #require(doors.pending)
            #expect(item.moveBlockedBy == "Other")
            let blocked = try #require(item.lines.last)
            #expect(blocked.localizedCaseInsensitiveContains("sealed")
                    && blocked.localizedCaseInsensitiveContains("unseal"),
                    "the road out of a sealed book is Unseal (which reopens it too)")
            #expect(!blocked.contains("is finished"),
                    "never 'finished — reopen' on a sealed book (Reopen refuses there)")
            // The op's refusal, spoken if Move is reached anyway.
            #expect(await doors.moveIn(item) == nil)
            let refusal = try #require(session.status.current?.text)
            #expect(refusal.localizedCaseInsensitiveContains("sealed")
                    && refusal.localizedCaseInsensitiveContains("unseal"))
            #expect(!refusal.contains("is finished"))
            #expect(try await members(db, world.mine.id).isEmpty, "nothing moved")
        }
    }

    /// 13i-c ladder, the sanity pass's CONCERN 1: a blocking book the sheet's
    /// stale preview never saw is read FRESH and named — never the R93-banned
    /// "Refused: lockedReading(id: …)" dump (`OpsRefusalCopy.message` has no
    /// words for `lockedReading`, so the round-1 fallback spoke the raw
    /// error). Red-on-old: the dump.
    @Test func aBlockingBookTheSheetNeverSawIsNamedFreshNeverDumped() async throws {
        try await withChoiceWorld { session, _ in
            let world = try shelf(session)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            let item = try #require(doors.pending)
            #expect(item.moveBlockedBy == nil, "nothing blocked when the sheet opened")
            // The race, staged: while the sheet is up, the note joins a THIRD
            // book, which is then finished — the op refuses naming a book the
            // sheet's severed preview does not carry.
            let late = try session.operations.createReading(name: "Late", kind: .book)
            _ = try session.operations.addPostToReading(world.shared.id, to: late.id)
            try session.operations.lockReading(late.id)
            #expect(await doors.moveIn(item) == nil)
            let refusal = try #require(session.status.current?.text)
            #expect(!refusal.contains("Refused:"), "the R93-banned dump never speaks")
            #expect(refusal == MembershipChoiceCopy.moveRefusedFinished("Late"),
                    "the blocking book is read fresh and named with its own road")
        }
    }

    /// The last rung — a blocking book that cannot be read at all (it died
    /// between the op's refusal and the read; no deterministic stage exists,
    /// recorded) — speaks a BOOK-LESS true sentence, never the dump.
    @Test func theUnnamedMoveRefusalIsASentenceNotADump() {
        let words = MembershipChoiceCopy.moveRefusedUnnamed
        #expect(!words.contains("Refused:") && !words.contains("("),
                "a sentence, never an error dump")
        #expect(words.localizedCaseInsensitiveContains("finished")
                && words.localizedCaseInsensitiveContains("copy"),
                "true for finished AND sealed blockers (sealed ⇒ finished), and it names the ceremony that works")
    }

    /// The same class at the chip's arms (the add's fall-through and the
    /// diverge row): the sealed fork of `ChipRefusals` — the new truth, pure.
    /// (The class's red-on-old is carried by the two DB-driven pins above
    /// and in `JournalBooksTests` — this signature is the fix's own.)
    @Test func theChipAndDivergeRefusalsNameTheSealedBooksRealDoor() {
        let sealed = ChipRefusals.message(
            for: OperationError.lockedReading(id: "b"), bookName: "Edition", sealed: true)
        #expect(sealed.contains("sealed") && sealed.localizedCaseInsensitiveContains("unseal"))
        #expect(!sealed.contains("finished"))
        let finished = ChipRefusals.message(
            for: OperationError.lockedReading(id: "b"), bookName: "Edition")
        #expect(finished.contains("finished") && finished.contains("reopen"))
        let diverge = DivergeCopy.refusal(
            for: OperationError.lockedReading(id: "b"), book: "Edition", sealed: true)
        #expect(diverge.contains("sealed") && diverge.localizedCaseInsensitiveContains("unseal"))
    }

    /// 13i-c ladder round 1 (the silent-offer NIT): when the choice's book
    /// vanished between the refusal and the offer, the door SPEAKS (P-2 —
    /// the shared words) instead of vanishing the press. Red-on-old: `offer`
    /// assigned nothing and said nothing.
    @Test func anOfferWhoseBookVanishedSpeaksInsteadOfGoingSilent() async throws {
        try await withChoiceWorld { session, _ in
            let note = try session.operations.createPost(title: "n")
            let doors = MembershipDoors(session: session)
            await doors.offer(.copyOnly, postID: note.id, readingID: "gone-book-id")
            #expect(doors.pending == nil, "no sheet — there is no book to offer")
            let spoken = try #require(session.status.current,
                                      "the press lands as the operation's words, never silence")
            #expect(spoken.kind == .refusal)
        }
    }

    @Test func theSheetDrawsExactlyItsItem() async throws {
        try await withChoiceWorld { session, _ in
            let world = try shelf(session)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(world.shared.id, to: world.mine.id)
            let item = try #require(doors.pending)
            MembershipChoiceProbe.shown = nil
            try await mounted(MembershipChoiceSheet(choice: item, onCopy: {}, onMove: {})) {
                #expect(MembershipChoiceProbe.shown == item)
            }
            #expect(MembershipChoiceSheet.surfaceCapabilities == [.copyIn, .moveIn])
        }
    }

    // MARK: - The hosts (§4 rows 14–18 — each road's refusal OPENS the sheet)

    @Test func row14_theChipsAddOffersTheChoice() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            MembershipChoiceProbe.shown = nil
            MembershipChipProbe.addDoor = nil
            try await mounted(MembershipChip(session: session, postID: world.shared.id)) {
                await settle(until: { MembershipChipProbe.addDoor != nil })
                let add = try #require(MembershipChipProbe.addDoor, "the chip mounted its door")
                add(world.mine)
                await settle(until: { MembershipChoiceProbe.shown != nil })
                let shown = try #require(MembershipChoiceProbe.shown, "the choice sheet presented")
                #expect(shown.kind == .copyOrMove)
                #expect(shown.book.id == world.mine.id)
                #expect(shown.lines.first
                        == MembershipChoiceCopy.ownedTargetLead(book: "Mine", elsewhere: ["Other"]))
            }
            #expect(try await members(db, world.mine.id).isEmpty)
        }
    }

    /// Row 15's honest shape (the plan named `BookStructureModel`'s roads):
    /// its two DRAG roads (the navigator's and Outline's rows) file and
    /// reorder MEMBERS only — a payload from outside the book decodes to
    /// nothing and adds nothing; its one ADD road is the daily book's
    /// "+ new entry", whose ownership refusal BELLS exactly as ⌘J does (the
    /// sitting record §6) — the entry opens, the note names who holds it, and
    /// the Arrivals line offers the choice (row 19).
    @Test func row15_theBookViewsRoadsAddNothingByDragAndBellAtTheDailyDoor() async throws {
        try await withChoiceWorld { session, db in
            let ops = session.operations
            let journal = try ops.createReading(
                name: "Journal", kind: .book, profile: Queries.journalTraitProfile,
                sortField: .entryDate, sortDir: .desc)
            try ops.setDailyJournalBook(journal.id)
            let claimer = try ops.createReading(name: "Claimer", kind: .book)
            try ops.setReadingOwned(claimer.id, owned: true)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-06-30")
            _ = try ops.addPostToReading(entry.container.id, to: claimer.id)

            let structure = BookStructureModel(session: session, readingID: journal.id)
            // The drag roads: a bare note id (the Pool's / Library's payload).
            let accepted = structure.acceptDrop(
                [entry.container.id], chapter: .end, post: .unfiled,
                entries: [], viewOrder: nil)
            #expect(!accepted, "a payload from outside the book is refused, never added")
            #expect(try await members(db, journal.id).isEmpty)

            // The daily door's own add road.
            let opened = await structure.newEntry(day: "2026-06-30")
            #expect(opened == entry.container.id, "the entry still opens")
            #expect(structure.lastError == JournalWaitingCopy.note(
                journal: "Journal", journalOwned: false, elsewhere: ["Claimer"], owner: "Claimer"))
            #expect(structure.lastError?.contains("because \u{201C}Claimer\u{201D} owns it") == true)
            #expect(try await db.read {
                try Queries.pendingArrivalCount($0, readingID: journal.id)
            } == 1, "it waits at the Journal's door (the bell)")
            #expect(try await members(db, journal.id).isEmpty)
        }
    }

    @Test func row16_thePoolsAddOffersTheChoice() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            let model = PoolPostsModel(session: session)
            MembershipChoiceProbe.shown = nil
            try await mounted(PoolPostsView(
                session: session, model: model,
                onDuplicateAsVersion: { _, _ in }, onArchive: { _ in },
                readings: ReadingsViewModel(session: session),
                tags: TagsViewModel(session: session),
                onOpen: { _ in })
            ) {
                // A note claimed since the listing was read (the Pool lists
                // bookless notes — the race is the road's one way to meet it).
                await model.addToBook(world.claimed.id, readingID: world.plain.id)
                await settle(until: { MembershipChoiceProbe.shown != nil })
                let shown = try #require(MembershipChoiceProbe.shown, "the choice sheet presented")
                #expect(shown.kind == .copyOnly)
                #expect(shown.owner?.name == "Owner")
                #expect(model.lastError == nil, "the refusal opened the ceremony, not words")
            }
            #expect(try await members(db, world.plain.id).isEmpty)
        }
    }

    @Test func row17_theShelfRowsDropOffersTheChoice() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            let model = ShelfViewModel(session: session)
            MembershipChoiceProbe.shown = nil
            try await mounted(ShelfView(
                session: session, model: model,
                readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {})
            ) {
                await model.addPost(world.shared.id, to: world.mine.id)
                await settle(until: { MembershipChoiceProbe.shown != nil })
                let shown = try #require(MembershipChoiceProbe.shown, "the choice sheet presented")
                #expect(shown.kind == .copyOrMove)
                #expect(model.lastError == nil)
            }
            #expect(try await members(db, world.mine.id).isEmpty)
        }
    }

    @Test func row18_manageNotesAddOffersTheChoice() async throws {
        try await withChoiceWorld { session, db in
            let world = try shelf(session)
            let readings = ReadingsViewModel(session: session)
            MembershipChoiceProbe.shown = nil
            try await mounted(ManageReadingPostsSheet(
                session: session, model: readings, reading: world.plain)
            ) {
                await readings.addPost(world.claimed.id, to: world.plain.id)
                await settle(until: { MembershipChoiceProbe.shown != nil })
                let shown = try #require(MembershipChoiceProbe.shown, "the choice sheet presented")
                #expect(shown.kind == .copyOnly)
                #expect(readings.lastError == nil)
            }
            #expect(try await members(db, world.plain.id).isEmpty)
        }
    }

    // MARK: - ⌘J names who holds the entry (F-U2-6)

    @Test func theDailyDoorNamesWhoHoldsTheEntry() async throws {
        try await withChoiceWorld { session, _ in
            let ops = session.operations
            let journal = try ops.createReading(
                name: "Journal", kind: .book, profile: Queries.journalTraitProfile)
            try ops.setDailyJournalBook(journal.id)
            let claimer = try ops.createReading(name: "Claimer", kind: .book)
            try ops.setReadingOwned(claimer.id, owned: true)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-06-30")
            _ = try ops.addPostToReading(entry.container.id, to: claimer.id)

            let outcome = try await JournalBooks.openToday(session: session, day: "2026-06-30")
            #expect(outcome.postID == entry.container.id)
            #expect(outcome.note == JournalWaitingCopy.note(
                journal: "Journal", journalOwned: false, elsewhere: ["Claimer"], owner: "Claimer"))
            // The OWNED-Journal arm names its own ownership and where else it lives.
            #expect(JournalWaitingCopy.note(
                journal: "J", journalOwned: true, elsewhere: ["X"], owner: nil)
                .contains("because \u{201C}J\u{201D} owns its notes and the entry also lives in "
                          + "\u{201C}X\u{201D}"))
        }
    }
}
