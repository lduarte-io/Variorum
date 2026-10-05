//
//  BookStateDoorsTests.swift
//  VariorumTests
//
//  13i-c U3 — THE BOOK'S STATE DOORS and THE BOOK SETTINGS SHEET (the 13i-c
//  plan §5, §7 U3 row; the sitting record §4, §5, §6, §24; R-13ic-3).
//
//  What is pinned:
//  - the door TABLE (which of each pair renders, per state — P-1's "gating is
//    data") cell for cell;
//  - every confirm's SENTENCES as static copy (§24's line verbatim; lesson
//    6's "Sealed means the book is done"; the listed forks and copies; the
//    unseal's "reopens");
//  - the N>0 gate (Finish asks only when something waits; else it acts);
//  - each door's act through the ONE model (the ops' outcomes, the receipts,
//    the refusal named for its book);
//  - the mounted confirm draws exactly its item; the mounted settings sheet
//    draws the Collecting sentences and the state doors the table names.
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
private func withStateWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 29))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval = 0.1) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(until condition: () -> Bool = { false }) async {
    for _ in 0..<20 where !condition() {
        pump(0.05)
        for _ in 0..<10 { await Task.yield() }
    }
}

/// Mounts `view` in a real window for the body of `run`.
@MainActor
private func mounted<V: View>(_ view: V, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 720),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: view)
    window.orderFrontRegardless()
    await settle()
    try await run()
}

@MainActor
private func reading(_ db: AppDatabase, _ id: String) async throws -> Reading {
    try #require(try await db.read { try Queries.reading($0, id: id) })
}

@MainActor
@Suite("The book's state doors (13i-c U3)", .serialized)
struct BookStateDoorsTests {
    // MARK: - The table (P-1: which door renders is data)

    @Test func theDoorTableRendersEachPairByState() {
        func facts(book: Bool = true, finished: Bool = false, sealed: Bool = false,
                   owned: Bool = false) -> BookStateFacts {
            BookStateFacts(isBook: book, finished: finished, sealed: sealed, owned: owned)
        }
        #expect(BookStateDoorSet.rendered(for: facts()) == [.finishBook, .sealBook, .ownBook])
        #expect(BookStateDoorSet.rendered(for: facts(finished: true))
                == [.reopenBook, .sealBook, .ownBook],
                "a finished book still renders Own — the op refuses with a road (P-13ic-2)")
        #expect(BookStateDoorSet.rendered(for: facts(finished: true, sealed: true))
                == [.unsealBook, .ownBook],
                "a sealed book renders NO Reopen (it refuses — Unseal is the one door down)")
        #expect(BookStateDoorSet.rendered(for: facts(owned: true))
                == [.finishBook, .sealBook, .unownBook])
        // 13i-d U3 (A JUSTIFIED FLIP — KnownIssues row 107, P-13ic-U3-2 ruled
        // to the sitting record §3's letter at the 13i-c adjudication; F-U1-8
        // folds the shelf menu's filter into THIS table): a gathering has NO
        // finish — an open one renders no state door at all (the old cell
        // read `[.finishBook]`); only a gathering ALREADY finished keeps
        // Reopen, as its way out (P-13id-U1-9 / P-13id-U3-3).
        #expect(BookStateDoorSet.rendered(for: facts(book: false)) == [],
                "a gathering renders no Finish, Seal or Own (§3: it has no finish; both others refuse — P-2)")
        #expect(BookStateDoorSet.rendered(for: facts(book: false, finished: true)) == [.reopenBook],
                "a legacy-finished gathering keeps Reopen as its way out")
        // Every rendered act is declared, on the doors that render it.
        for act in BookStateDoorSet.all {
            let doors = CapabilityRegistry.capability(act).doors
            #expect(doors == [.contextMenu, .surface], "\(act) — the shelf menu and the sheet")
        }
    }

    // MARK: - The words (static copy, read without a window)

    @Test func theFinishConfirmCarriesTheOneLineOnlyWhenSomethingWaits() {
        #expect(!BookStateCopy.finishNeedsConfirm(pendingArrivals: 0))
        #expect(BookStateCopy.finishNeedsConfirm(pendingArrivals: 1))
        let confirm = BookStateCopy.finish(readingID: "b", name: "Poems", pendingArrivals: 2)
        #expect(confirm.title == "Finish \u{201C}Poems\u{201D}?")
        // §24's line — 17y B3 (h), A JUSTIFIED EDIT (R-17y-2): its "door"
        // is the ONE word now; the subject (one line, only when N > 0) holds.
        #expect(confirm.lines == ["2 waiting at Arrivals will be dismissed."])
        #expect(confirm.list.isEmpty && confirm.after.isEmpty)
        #expect(confirm.confirmLabel == "Finish")
    }

    @Test func theSealConfirmListsTheForksAndSaysTheBookIsDone() {
        let shared = BookStateCopy.Fork(title: "Jekyll's diary", elsewhere: ["Classics", "Drafts"])
        let open = BookStateCopy.seal(
            readingID: "b", name: "Edition", finished: false, owned: false,
            forks: [shared], pendingArrivals: 1)
        #expect(open.title == "Seal \u{201C}Edition\u{201D}?")
        // Lesson 6's second sentence is the seal's lead.
        #expect(open.lines.first?.hasPrefix("Sealed means the book is done") == true)
        #expect(open.lines.contains(BookStateCopy.sealFinishesToo),
                "sealing an open book says it finishes it too (R-13ic-3)")
        #expect(open.lines.contains(BookStateCopy.sealForksLead))
        #expect(open.list == ["Jekyll's diary \u{2014} also in \u{201C}Classics\u{201D}, \u{201C}Drafts\u{201D}"])
        #expect(open.after == ["1 waiting at Arrivals will be dismissed."])

        let finishedOwned = BookStateCopy.seal(
            readingID: "b", name: "Edition", finished: true, owned: true,
            forks: [], pendingArrivals: 0)
        #expect(!finishedOwned.lines.contains(BookStateCopy.sealFinishesToo))
        #expect(finishedOwned.lines.contains("It owns its notes, so nothing needs copying."),
                "the composition prize, said: an owned book seals fork-free")
        #expect(finishedOwned.list.isEmpty && finishedOwned.after.isEmpty)

        let plainNoForks = BookStateCopy.seal(
            readingID: "b", name: "E", finished: true, owned: false, forks: [], pendingArrivals: 0)
        #expect(plainNoForks.lines.contains(BookStateCopy.noForks))
    }

    @Test func theUnsealConfirmSaysItReopens() {
        let living = BookStateCopy.unseal(readingID: "b", name: "Edition", collects: true)
        #expect(living.title == "Unseal \u{201C}Edition\u{201D}?")
        #expect(living.lines.first?.hasPrefix("Unsealing reopens the book too") == true)
        #expect(living.lines.contains(BookStateCopy.unsealCatchUp))
        #expect(living.lines.contains(BookStateCopy.unsealIndependent))
        let plain = BookStateCopy.unseal(readingID: "b", name: "Edition", collects: false)
        #expect(!plain.lines.contains(BookStateCopy.unsealCatchUp),
                "a book with no rule has no gap to catch up — the line is not said")
    }

    @Test func theOwnConfirmListsTheCopiesOrSaysNothingToCopy() {
        let none = BookStateCopy.own(readingID: "b", name: "Mine", forks: [])
        #expect(none.lines == [BookStateCopy.ownLead, BookStateCopy.noForks])
        #expect(none.list.isEmpty)
        let shared = BookStateCopy.Fork(title: "n", elsewhere: ["Other"])
        let some = BookStateCopy.own(readingID: "b", name: "Mine", forks: [shared])
        #expect(some.lines == [BookStateCopy.ownLead, BookStateCopy.ownForksLead])
        #expect(some.list == ["n \u{2014} also in \u{201C}Other\u{201D}"])
        #expect(some.confirmLabel == "Own Its Notes")
    }

    // MARK: - The acts, through the one model

    @Test func finishActsWithoutAskingWhenNothingWaits() async throws {
        try await withStateWorld { session, db in
            let book = try session.operations.createReading(name: "Quiet", kind: .book)
            let doors = BookStateDoors(session: session)
            await doors.open(.finishBook, readingID: book.id)
            #expect(doors.pending == nil, "N = 0 — no confirm")
            #expect(try await reading(db, book.id).locked)
            #expect(session.status.spoken?.text == BookStateCopy.finished("Quiet"))
            await doors.open(.reopenBook, readingID: book.id)
            #expect(try await reading(db, book.id).locked == false)
            #expect(session.status.spoken?.text == BookStateCopy.reopened("Quiet"))
        }
    }

    @Test func finishAsksWithTheLineWhenArrivalsWaitAndDismissesThem() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let tag = try ops.createTag(name: "poem")
            let book = try ops.createReading(
                name: "Poems", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)),
                intakeSeating: .arrivals)
            let note = try ops.createPost(title: "late")
            _ = try ops.applyTag(tag.id, toPost: note.id)
            #expect(try await db.read { try Queries.pendingArrivalCount($0, readingID: book.id) } == 1)

            let doors = BookStateDoors(session: session)
            await doors.open(.finishBook, readingID: book.id)
            let asked = try #require(doors.pending)
            #expect(asked == BookStateCopy.finish(readingID: book.id, name: "Poems", pendingArrivals: 1))
            #expect(try await reading(db, book.id).locked == false, "nothing happens until she says")

            await doors.confirm()
            #expect(doors.pending == nil)
            #expect(try await reading(db, book.id).locked)
            #expect(try await db.read { try Queries.pendingArrivalCount($0, readingID: book.id) } == 0,
                    "finishing dismissed what waited (§24)")
        }
    }

    /// 13i-c ladder round 1, the MAJOR: an ARCHIVED note's waiting row is
    /// DISMISSED by the finish, so the door must ASK and count it. Red-on-old:
    /// the door acted at once.
    ///
    /// 13i-d U4 — P-13ib-U2-2 REVERSED (her #169(a)(2)/(3)): the line arm below
    /// asserted the Arrivals LINE showed nothing (`== 0`) while the confirm
    /// counted the archived waiter. The flip is deliberate, RED on the
    /// pre-flip predicate: the line SHOWS it now (marked archived), so what
    /// she sees at the door is exactly what the finish dismisses.
    @Test func finishAsksWhenOnlyAnArchivedNoteWaits() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let tag = try ops.createTag(name: "poem")
            let book = try ops.createReading(
                name: "Poems", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)),
                intakeSeating: .arrivals)
            let note = try ops.createPost(title: "late")
            try ops.applyTag(tag.id, toPost: note.id)
            try ops.archiveContainer(note.id)
            let door = try await db.read {
                try Queries.bookArrivals($0, readingID: book.id, limit: 10)
            }
            #expect(door.count == 1, "the LINE shows the archived waiter — all visible")
            #expect(door.rows.map(\.archived) == [true], "marked archived")

            let doors = BookStateDoors(session: session)
            await doors.open(.finishBook, readingID: book.id)
            let asked = try #require(
                doors.pending,
                "the finish will dismiss the archived waiter, so it must ask (§24)")
            #expect(asked == BookStateCopy.finish(
                readingID: book.id, name: "Poems", pendingArrivals: 1))
            #expect(try await reading(db, book.id).locked == false,
                    "nothing happens until she says")

            await doors.confirm()
            #expect(try await reading(db, book.id).locked)
            #expect(try await db.read {
                try Queries.pendingArrivalCount($0, readingID: book.id)
            } == 0, "the archived waiter was dismissed — exactly what the confirm promised")
        }
    }

    @Test func sealListsTheForksThenForksAndSealsOnConfirm() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let edition = try ops.createReading(name: "Edition", kind: .book)
            let other = try ops.createReading(name: "Other", kind: .book)
            let shared = try ops.createPost(title: "shared")
            _ = try ops.addPostToReading(shared.id, to: edition.id)
            _ = try ops.addPostToReading(shared.id, to: other.id)
            let sole = try ops.createPost(title: "sole")
            _ = try ops.addPostToReading(sole.id, to: edition.id)

            let doors = BookStateDoors(session: session)
            await doors.open(.sealBook, readingID: edition.id)
            let asked = try #require(doors.pending)
            #expect(asked.list == ["shared \u{2014} also in \u{201C}Other\u{201D}"])
            #expect(asked.lines.contains(BookStateCopy.sealFinishesToo))
            #expect(try await reading(db, edition.id).sealedAt == nil)

            await doors.confirm()
            let sealed = try await reading(db, edition.id)
            #expect(sealed.sealedAt != nil && sealed.locked)
            let members = try await db.read { try Queries.assembleReading($0, readingID: edition.id) }
            #expect(members.count == 2)
            #expect(!members.map(\.postID).contains(shared.id), "the shared note forked")
            #expect(session.status.spoken?.text == BookStateCopy.sealed("Edition", forks: 1))
            let original = try await db.read {
                try Queries.containerHeader($0, containerID: shared.id)
            }
            #expect(original?.locked == false, "the original stays editable where it lives")
        }
    }

    @Test func unsealReopensTheBook() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Edition", kind: .book)
            let note = try ops.createPost(title: "n")
            _ = try ops.addPostToReading(note.id, to: book.id)
            try ops.sealReading(book.id)

            let doors = BookStateDoors(session: session)
            await doors.open(.unsealBook, readingID: book.id)
            let asked = try #require(doors.pending)
            #expect(asked == BookStateCopy.unseal(readingID: book.id, name: "Edition", collects: false))
            await doors.confirm()
            let open = try await reading(db, book.id)
            #expect(open.sealedAt == nil && open.locked == false, "R-13ic-3: sealed → open in one step")
            #expect(try await db.read {
                try Queries.containerHeader($0, containerID: note.id)
            }?.locked == false)
            #expect(session.status.spoken?.text == BookStateCopy.unsealed("Edition"))
        }
    }

    @Test func ownListsTheCopiesActsAndStopOwningActsAtOnce() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            let other = try ops.createReading(name: "Other", kind: .book)
            let shared = try ops.createPost(title: "shared")
            _ = try ops.addPostToReading(shared.id, to: mine.id)
            _ = try ops.addPostToReading(shared.id, to: other.id)

            let doors = BookStateDoors(session: session)
            await doors.open(.ownBook, readingID: mine.id)
            let asked = try #require(doors.pending)
            #expect(asked.list == ["shared \u{2014} also in \u{201C}Other\u{201D}"])
            await doors.confirm()
            #expect(try await reading(db, mine.id).owned)
            #expect(session.status.spoken?.text == BookStateCopy.owned("Mine", copies: 1))

            await doors.open(.unownBook, readingID: mine.id)
            #expect(doors.pending == nil, "Stop Owning moves nothing — no confirm")
            #expect(try await reading(db, mine.id).owned == false)
            #expect(session.status.spoken?.text == BookStateCopy.unowned("Mine"))
        }
    }

    @Test func owningAFinishedOrSealedBookSpeaksTheRefusalNamingItsDoor() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let finished = try ops.createReading(name: "Done", kind: .book)
            try ops.lockReading(finished.id)
            let sealed = try ops.createReading(name: "Edition", kind: .book)
            try ops.sealReading(sealed.id)

            let doors = BookStateDoors(session: session)
            await doors.open(.ownBook, readingID: finished.id)
            #expect(doors.pending == nil, "no confirm that could only fail")
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text
                    == "\u{201C}Done\u{201D} is finished \u{2014} reopen it first.")
            #expect(try await reading(db, finished.id).owned == false)

            await doors.open(.ownBook, readingID: sealed.id)
            #expect(session.status.current?.text
                    == "\u{201C}Edition\u{201D} is sealed \u{2014} unseal it first (that reopens it too).")
            // And the op itself refuses the same way (the door's words name
            // the operation's real refusal — P-2).
            #expect(await doors.perform(.ownBook, readingID: sealed.id) == false)
            #expect(session.status.current?.text
                    == "\u{201C}Edition\u{201D} is sealed \u{2014} unseal it first (that reopens it too).")
        }
    }

    // MARK: - Mounted

    @Test func theConfirmSheetDrawsExactlyItsItem() async throws {
        try await withStateWorld { _, _ in
            BookStateProbe.shown = nil
            let item = BookStateCopy.finish(readingID: "b", name: "Poems", pendingArrivals: 3)
            try await mounted(BookStateConfirmSheet(confirm: item, onConfirm: {})) {
                #expect(BookStateProbe.shown == item)
            }
        }
    }
}

// MARK: - The settings sheet

@MainActor
@Suite("The Book Settings sheet (13i-c U3)", .serialized)
struct BookSettingsSheetTests {
    @Test func theRuleIsReadAloudAsASentence() {
        let paths = ["a": "work", "b": "work/ideas", "c": "life"]
        #expect(CollectingCopy.ruleWords(.tag("a"), paths: paths) == "#work")
        #expect(CollectingCopy.ruleWords(.and([.tag("a"), .not(.tag("b"))]), paths: paths)
                == "#work and not #work/ideas")
        #expect(CollectingCopy.ruleWords(.or([.tag("a"), .and([.tag("b"), .star])]), paths: paths)
                == "#work or (#work/ideas and \u{2605} starred)")
        #expect(CollectingCopy.ruleWords(.not(.or([.tag("a"), .tag("c")])), paths: paths)
                == "not (#work or #life)")
        #expect(CollectingCopy.ruleWords(.tag("gone"), paths: paths) == RuleEditorCopy.deadTag)
    }

    @Test func theCollectingSentencesPerKindAndState() {
        let paths = ["a": "work", "b": "essay"]
        #expect(CollectingCopy.gathersFrom(.none, isBook: true, paths: paths)
                == CollectingLine(label: "Gathers from:", value: "nothing by itself", appWords: true))
        #expect(CollectingCopy.gathersFrom(.none, isBook: false, paths: paths)
                == CollectingLine(label: "", value: RuleEditorCopy.noRuleGathering))
        #expect(CollectingCopy.gathersFrom(.malformed, isBook: true, paths: paths).value
                == CollectingCopy.unreadableRule)
        #expect(CollectingCopy.newMatches(nil).value == RuleEditorCopy.joinAuto)
        #expect(CollectingCopy.newMatches(.arrivals).value == RuleEditorCopy.joinArrivals)
        #expect(CollectingCopy.taggedHere(["a", "b"], paths: paths)
                == CollectingLine(label: "Notes written here are tagged:", value: "#work #essay"),
                "her paths — never voiced")
        #expect(CollectingCopy.taggedHere([], paths: paths).value == "nothing")
        #expect(CollectingCopy.taggedHere([], paths: paths).appWords, "the app's word — voiced")
        #expect(CollectingCopy.newMatches(nil).appWords)
        #expect(CollectingCopy.hideOwnedWord(.followDefault, defaultHides: false)
                == "as the app does (shown)")
        #expect(CollectingCopy.hideOwnedWord(.followDefault, defaultHides: true)
                == "as the app does (hidden)")
        #expect(HideOwnedChoice(stored: nil) == .followDefault)
        #expect(HideOwnedChoice(stored: true).stored == true)
        #expect(HideOwnedChoice(stored: false).stored == false)
    }

    private func structure(
        _ session: AppSession, _ db: AppDatabase, _ id: String
    ) async throws -> BookStructureModel {
        let model = BookStructureModel(session: session, readingID: id)
        model.adopt(.init(
            reading: try await reading(db, id), sections: [], deletedSections: [],
            assignments: [:]))
        return model
    }

    /// Her discoverability report, answered: the book's OWN sheet says what
    /// it collects, how new matches join and what notes written here wear —
    /// and the state doors the table names for an open book.
    @Test func aBooksSheetDrawsItsCollectingSentencesAndItsStateDoors() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let work = try ops.createTag(name: "work")
            let essay = try ops.createTag(name: "essay")
            let book = try ops.createReading(
                name: "Living", kind: .book, querySpec: try RuleGrammar.encode(.tag(work.id)),
                intakeSeating: .arrivals, autoTagIDs: [work.id, essay.id])
            let settings = BookSettingsModel(session: session, readingID: book.id)
            await settings.load(for: try await reading(db, book.id))
            BookSettingsProbe.drawn = [:]
            let host = try await structure(session, db, book.id)
            try await mounted(BookSettingsSheet(structure: host, model: settings)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.title == "Book Settings")
                #expect(drawn.collecting == [
                    CollectingLine(label: "Gathers from:", value: "#work"),
                    CollectingLine(label: "New matches:", value: "wait at Arrivals", appWords: true),
                    CollectingLine(label: "Notes written here are tagged:", value: "#work #essay"),
                ])
                #expect(drawn.hideOwned.isEmpty, "a book never renders the hide-owned row")
                #expect(drawn.stateDoors == [.finishBook, .sealBook, .ownBook])
                #expect(drawn.finishedDisabled == false)
            }
            // The Edit… door's editor is for THIS reading — and the sheet
            // HANDS it to its host rather than nesting it (W-1, the U3 walk).
            #expect(settings.makeRuleEditor().readingID == book.id)
        }
    }

    @Test func aSealedBooksSheetShowsUnsealAndAFinishedControlItCannotFlip() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Edition", kind: .book)
            try ops.sealReading(book.id)
            BookSettingsProbe.drawn = [:]
            let host = try await structure(session, db, book.id)
            try await mounted(BookSettingsSheet(structure: host)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.stateDoors == [.unsealBook, .ownBook])
                #expect(drawn.finishedDisabled, "Reopen refuses a sealed book — the control is off")
            }
        }
    }

    /// The SAME pane for a gathering (§4): its rule, the HIDE-OWNED toggle's
    /// three words, no dial or outflow — and since 13i-d U3 (row 107, the
    /// sitting record §3's letter) no state door at all.
    @Test func aGatheringsSheetDrawsItsRuleAndTheHideOwnedToggle() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let work = try ops.createTag(name: "work")
            let gathering = try ops.createReading(
                name: "Work", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(work.id), .star])))
            let settings = BookSettingsModel(session: session, readingID: gathering.id)
            await settings.load(for: try await reading(db, gathering.id))
            BookSettingsProbe.drawn = [:]
            let host = try await structure(session, db, gathering.id)
            try await mounted(BookSettingsSheet(structure: host, model: settings)) {
                let drawn = try #require(BookSettingsProbe.drawn[gathering.id])
                #expect(drawn.title == "Gathering Settings")
                #expect(drawn.collecting == [
                    CollectingLine(label: "Gathers from:", value: "#work and \u{2605} starred"),
                ])
                #expect(drawn.hideOwned == [
                    "as the app does (shown)", "show them", "hide them",
                ])
                // 13i-d U3 (A JUSTIFIED FLIP, row 107 — the old cell read
                // `[.finishBook]`): a gathering has no finish (§3).
                #expect(drawn.stateDoors == [])
            }
        }
    }

    /// The hide-owned toggle writes all three states, and HIDE takes an owned
    /// note out of the gathering's assembly (the fragment it composes).
    @Test func theHideOwnedToggleRoundTripsAndHides() async throws {
        try await withStateWorld { session, db in
            let ops = session.operations
            let work = try ops.createTag(name: "work")
            let gathering = try ops.createReading(
                name: "Work", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(work.id)))
            let owner = try ops.createReading(name: "Owner", kind: .book)
            let note = try ops.createPost(title: "claimed")
            _ = try ops.addPostToReading(note.id, to: owner.id)
            try ops.setReadingOwned(owner.id, owned: true)
            _ = try ops.applyTag(work.id, toPost: note.id)
            let settings = BookSettingsModel(session: session, readingID: gathering.id)

            #expect(try await db.read { try Queries.assembleReading($0, readingID: gathering.id) }
                .map(\.postID) == [note.id], "SHOW is the default (badged)")
            await settings.setHideOwned(.hide)
            #expect(try await reading(db, gathering.id).hideOwned == true)
            #expect(try await db.read { try Queries.assembleReading($0, readingID: gathering.id) }
                .isEmpty, "hidden")
            await settings.setHideOwned(.show)
            #expect(try await reading(db, gathering.id).hideOwned == false)
            await settings.setHideOwned(.followDefault)
            #expect(try await reading(db, gathering.id).hideOwned == nil)
        }
    }
}
