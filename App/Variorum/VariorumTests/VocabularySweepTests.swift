//
//  VocabularySweepTests.swift
//  VariorumTests
//
//  13i-d U6 — THE VOCABULARY SWEEP's word-table pins (the plan's item 5 +
//  item 10, the riders routed to U6). Each test names its lettered piece in
//  the U6 RECORD. The dead SPELLINGS are banned by `DeadVocabularyTests`
//  (the grep pins); this file pins the words that replaced them, where a
//  sentence carries a fact (a count, a road, a state).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withSweepWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 61))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("13i-d U6 — the vocabulary sweep's word tables", .serialized)
struct VocabularySweepTests {
    // MARK: - (g) F-U3-4 — the chip counts books and gatherings apart

    /// TRACED FIRST: `readingsContaining`'s membership arm reads BOOK rows
    /// only (13i-c's contract holds — no reader counted a gathering's row);
    /// the gatherings it appends SHOW the note. The lie was the word: the
    /// chip said "in 2 books" for one book and one gathering. Red on the old
    /// label by construction (its only words were "in N books").
    @Test func theChipCountsBooksAndGatheringsApart() {
        let path: (String) -> String = { "in \($0)" }
        #expect(MembershipChip.label(bookNames: [], gatheringCount: 0, singleBook: path)
                == "in no book")
        #expect(MembershipChip.label(bookNames: ["Orbit"], gatheringCount: 0, singleBook: path)
                == "in Orbit")
        #expect(MembershipChip.label(bookNames: ["Orbit"], gatheringCount: 1, singleBook: path)
                == "in Orbit \u{00B7} 1 gathering",
                "F-U3-4's walk case: ONE book and ONE gathering never reads \"in 2 books\"")
        #expect(MembershipChip.label(bookNames: [], gatheringCount: 2, singleBook: path)
                == "in no book \u{00B7} 2 gatherings")
        #expect(MembershipChip.label(bookNames: ["A", "B"], gatheringCount: 0, singleBook: path)
                == "in 2 books")
        #expect(MembershipChip.label(bookNames: ["A", "B"], gatheringCount: 1, singleBook: path)
                == "in 2 books \u{00B7} 1 gathering")

        #expect(MembershipChip.headline(bookCount: 0, gatheringCount: 0)
                == "This note is in no book \u{2014} it lives in the Pool.")
        #expect(MembershipChip.headline(bookCount: 1, gatheringCount: 1)
                == "This note is in 1 book and appears in 1 gathering:")
        #expect(MembershipChip.headline(bookCount: 2, gatheringCount: 0)
                == "This note is in 2 books:")
        #expect(MembershipChip.headline(bookCount: 0, gatheringCount: 3)
                == "This note is in no book \u{2014} it lives in the Pool \u{2014} and appears in "
                    + "3 gatherings:",
                "a gathering-only note is still a Pool note (§8) — it just shows elsewhere")
    }

    // MARK: - (a) + (e) — the book's own count lines and the gathering footer

    /// "gathering", never "smart book" (§1/§14); singular where one
    /// (KnownIssues row 111's "1 chapters", captured on the 13i-b walk).
    @Test func theBooksCountLinesSayGatheringAndCountRight() {
        #expect(BookViewCopy.metaLine(gathering: true, chapters: 0, notes: 3, archived: 0)
                == "gathering \u{00B7} 3 notes")
        #expect(BookViewCopy.metaLine(gathering: false, chapters: 1, notes: 1, archived: 0)
                == "book \u{00B7} 1 chapter \u{00B7} 1 note")
        #expect(BookViewCopy.metaLine(gathering: false, chapters: 2, notes: 5, archived: 2)
                == "book \u{00B7} 2 chapters \u{00B7} 5 notes \u{00B7} "
                    + ArchivedLineCopy.line(count: 2))
        #expect(BookIndexColumn.footerWords(chapters: 1, notes: 1, filtered: false)
                == "1 chapter · 1 note")
        #expect(BookIndexColumn.footerWords(chapters: 1, notes: 1, filtered: true)
                == "1 chapter · 1 shown")
    }

    /// (A JUSTIFIED EDIT at VX-217: this slot pinned the gathering's
    /// navigator FOOTER — row 111's truth-of-any-rule sentence — which her
    /// 2026-10-13 ruling RETIRED: "we don't need that info here, it's in the
    /// field guide if they care and it looks cluttered. the bottom of a book
    /// and the bottom of a gathering should look the same." The pin retires
    /// with its copy; what replaced the footer is pinned here instead.)
    ///
    /// VX-217: the gathering's foot says the BOOK's word ("+ new note"); the
    /// door's hover and receipt say what the new note wears — sentence case,
    /// never "collects"/"added" of a thing that holds nothing.
    @Test func theGatheringFootSaysTheBooksWord() throws {
        #expect(GatheringNoteDoorCopy.navigatorWord == "+ new note")
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/BookView/BookView.swift"),
            encoding: .utf8)
        #expect(source.contains("chromeLabel(\"+ new note\")"),
                "the book's own foot says the same word")
        #expect(!source.contains("ChromeNotice("),
                "no explainer stands at a navigator's foot (or anywhere in the book view)")

        let tagged = GatheringMintFace(
            outcome: .plan(.init(tagIDs: ["t"], star: false)), tagPaths: ["poems"])
        #expect(GatheringNoteDoorCopy.help(tagged) == "A new note tagged #poems, so this gathering shows it")
        let both = GatheringMintFace(
            outcome: .plan(.init(tagIDs: ["t"], star: true)), tagPaths: ["poems"])
        #expect(GatheringNoteDoorCopy.help(both)
                == "A new note tagged #poems and starred, so this gathering shows it")
        // (JUSTIFIED EDIT at VX-250 (2): her shorter hover is the whole
        // sentence; the "This gathering can't take a new note: …" frame is
        // retired.)
        let archived = GatheringMintFace(outcome: .blocked(.archived), tagPaths: [])
        #expect(GatheringNoteDoorCopy.help(archived) == "Archived \u{2014} unarchive it to add notes.")
        let ghost = GatheringMintFace(outcome: .blocked(.deadTag(path: "essays")), tagPaths: [])
        #expect(GatheringNoteDoorCopy.help(ghost) == "Its rule needs #essays, which no longer exists.")
        let unmatchable = GatheringMintFace(outcome: .blocked(.unreachableTerm), tagPaths: [])
        #expect(GatheringNoteDoorCopy.help(unmatchable) == "Its rule can't match a new note.")

        // (A JUSTIFIED EDIT at VX-250: the receipt's words are her SHORTER
        // ones now — pinned verbatim in `herShorterMintReceiptsLandVerbatim`.)
        #expect(BookcaseCopy.shownByMint(["poems"], starred: false)
                == BookcaseCopy.shownByTagging(["poems"]), "tags alone read exactly the tagging receipt")
        #expect(BookcaseCopy.shownByMint(["poems"], starred: true)
                == "Tagged #poems and starred \u{2014} the gathering shows it now.")
        #expect(BookcaseCopy.shownByMint([], starred: true)
                == "Starred \u{2014} the gathering shows it now.")
        for line in [GatheringNoteDoorCopy.help(both), BookcaseCopy.shownByMint(["a"], starred: true)] {
            #expect(!line.contains("collect") && !line.contains("added"), "\(line)")
        }
    }

    /// VX-250 (1) — her answer to #VX217-b (QUESTIONS #217), byte for byte:
    /// the mint's receipt SHORTER, every arm. Under P-VX381-1 (PROVISIONAL,
    /// the kickoff) R98's collect receipt shortens with it, so the tags-only
    /// arm still reads exactly `shownByTagging`.
    @Test func herShorterMintReceiptsLandVerbatim() {
        #expect(BookcaseCopy.shownByMint(["essays"], starred: false)
                == "Tagged #essays \u{2014} the gathering shows it now.")
        #expect(BookcaseCopy.shownByMint(["essays"], starred: true)
                == "Tagged #essays and starred \u{2014} the gathering shows it now.")
        #expect(BookcaseCopy.shownByMint([], starred: true)
                == "Starred \u{2014} the gathering shows it now.")
        #expect(BookcaseCopy.shownByMint([], starred: false) == "Added to the gathering.")
        #expect(BookcaseCopy.shownByTagging(["essays"])
                == "Tagged #essays \u{2014} the gathering shows it now.",
                "P-VX381-1: the collect receipt speaks in the same register")
    }

    /// (a) — the Bookcase's own words for what a gathering is and does.
    @Test func theBookcaseSaysWhatAGatheringDoes() {
        #expect(BookcaseCopy.newBookMessage.contains("a gathering shows every note its rule matches"))
        // (JUSTIFIED EDIT at VX-250 — P-VX381-1's shorter register.)
        #expect(BookcaseCopy.shownByTagging(["poems", "odes"])
                == "Tagged #poems #odes \u{2014} the gathering shows it now.")
        #expect(RuleEditorCopy.mintTitle == "Create Gathering")
    }

    // MARK: - (e) row 111 item 3 — "keeps collecting" only where an act can reach the rule

    /// A legacy-only rule (profile / date terms) hears no tagging or starring
    /// act, so the bind and spawn doors stop promising that it keeps
    /// collecting; every rule an act can reach keeps the shipped words.
    @Test func theCollectingPromiseIsTrueOfTheRule() {
        let legacy = RuleTerm.legacyProfile("journal")
        let explained = BindCopy.explanation(count: 2, followUp: .none, hearsActs: false)
        #expect(explained.contains("catches up") && !explained.contains("keeps collecting"))
        #expect(BindCopy.explanation(count: 2, followUp: .none).contains(BindCopy.keepsCollecting))
        #expect(BindCopy.bound("g", count: 2, hearsActs: false).hasSuffix(
            "It collects only when it catches up."))
        #expect(BindCopy.bound("g", count: 2).hasSuffix("It keeps collecting."))
        #expect(BindCopy.spawned("b", count: 1, rule: .rule(legacy)).contains("catches up"))
        #expect(BindCopy.spawned("b", count: 1, rule: .rule(RuleTerm.star))
                .contains("keeps collecting"))
        #expect(BindCopy.spawnMessage(for: .rule(legacy)).contains("only when it catches up"))
        #expect(BindCopy.spawnMessage(for: .rule(RuleTerm.star)).contains("keep joining"))
    }

    // MARK: - (b) a wing presents as a SEPARATE LIBRARY (§9's language line)

    /// The doors that MAKE or CROSS a wing say what it is; the noun stays
    /// "wing" (lesson 11's own sentence; "Library" already names the finder).
    @Test func theWingDoorsSayItIsASeparateLibrary() {
        #expect(WingCopy.switcherHeader == "Wings \u{2014} each a separate library")
        #expect(WingCopy.minted("Annex").contains("a separate library"))
        let leaving = WingCopy.moveMessage(leaves: ["Alpha"])
        #expect(leaving.hasPrefix("It leaves \u{201C}Alpha\u{201D}"))
        #expect(leaving.contains("a wing is a separate library"))
        #expect(WingCopy.copied("n", to: "Annex").contains("a separate library"))
        #expect(WingCopy.versionElsewhere("Annex")
                == "a version of this note lives in another library \u{2014} the wing \u{201C}Annex\u{201D}")
        #expect(WingWords.lesson.hasPrefix("A wing is a separate library in the same app"),
                "lesson 11's sentence stays the New Wing prompt's (U7 pins the lesson)")
    }

    // MARK: - (c) the Library's "Posts" → "Notes" (§21, hers)

    @Test func theLibrarySaysNotesNeverPosts() {
        #expect(LibraryCatalogModel.Scope.allCases.map(\.label) == ["All", "Books", "Notes", "Blocks"])
    }

    // MARK: - (j) KnownIssues row 103's LIBRARY half — the quiet receipt's home

    /// The Library's laid-out message row hosts the status seam's quiet line
    /// when nothing of its own speaks — its own refusal and receipt keep
    /// their precedence; nothing reserves a blank line.
    @Test func theLibraryHostsTheQuietReceiptWhenItsOwnSlotIsFree() {
        typealias Slot = LibraryCatalogView.MessageSlot
        #expect(LibraryCatalogView.messageSlot(error: nil, receipt: nil, quietReceipt: true) == Slot.quiet)
        #expect(LibraryCatalogView.messageSlot(error: nil, receipt: nil, quietReceipt: false) == Slot.none)
        #expect(LibraryCatalogView.messageSlot(error: "no", receipt: "yes", quietReceipt: true) == Slot.error)
        #expect(LibraryCatalogView.messageSlot(error: nil, receipt: "Archived.", quietReceipt: true)
                == Slot.receipt)
    }

    // MARK: - (k) the note ▾ menu's Move/Copy to Wing renderer

    /// The note ▾ menu lists the wings OTHER than the open NOTE's own (an
    /// open note can be another wing's — the Open strip keeps it), named by
    /// the one display brain; a moved note's context follows it.
    @Test func theNoteMenuReadsTheNotesOwnWing() async throws {
        try await withSweepWorld { session, _ in
            let ops = session.operations
            let annex = try ops.createWing(name: "Annex")
            let note = try ops.createPost(title: "loose")
            let home = try #require(await NoteMenuWingContext.load(session, postID: note.id))
            // (postID joined the context at ladder B fix B — a mechanical
            // edit here; the pin's subject is unchanged.)
            #expect(home == NoteMenuWingContext(postID: note.id, wingID: "", title: "loose"))
            _ = try ops.moveNoteToWing(note.id, to: annex.id)
            let moved = try #require(await NoteMenuWingContext.load(session, postID: note.id))
            #expect(moved.wingID == annex.id, "after a move the menu offers the OTHER wings")
            let wings = WingsModel(session: session)
            await wings.load()
            #expect(wings.destinations(from: moved.wingID).map(\.id) == [""],
                    "from Annex the one other library is Home")
            #expect(wings.destinations(from: home.wingID).map(\.id) == [annex.id])
        }
    }

    /// **13i-d LADDER B fix B** (round 1's MINOR 2 — ladder A's superseded-
    /// observation class, re-found on U6's new code): the bars render the
    /// wing doors only from a context whose `postID` MATCHES the open note,
    /// so a stale load landing after a note switch — or a cancelled task's
    /// nil — can never draw another note's destinations or put its title on
    /// the move confirm. The write sites carry the sibling cancellation
    /// guard; this pure gate is the belt a test can hold without the race.
    @Test func aStaleWingContextNeverDrawsAnotherNotesDoors() {
        let stale = NoteMenuWingContext(postID: "note-a", wingID: "w1", title: "A")
        #expect(NoteMenuWingContext.matching(stale, postID: "note-a") == stale,
                "the note's own context draws")
        #expect(NoteMenuWingContext.matching(stale, postID: "note-b") == nil,
                "another note's stale context draws NOTHING")
        #expect(NoteMenuWingContext.matching(nil, postID: "note-b") == nil)
    }

    /// **The RELOAD gate** (the sanity pass's NIT on fix B, confirmed and
    /// fixed): a post-act reload runs in an UNSTRUCTURED Task — cancellation
    /// never reaches it — so the subject check is the real guard: a reload
    /// adopts only over ITS OWN note's standing context. A reload for note A
    /// landing after the bar moved to note B writes nothing, so B's loaded
    /// context never blinks out behind the render gate; A's own refresh
    /// still lands.
    @Test func aPostActReloadNeverStompsTheNextNotesContext() {
        let noteA = NoteMenuWingContext(postID: "note-a", wingID: "w1", title: "A")
        let noteB = NoteMenuWingContext(postID: "note-b", wingID: "", title: "B")
        #expect(NoteMenuWingContext.reloadAdopts(over: noteA, postID: "note-a"),
                "the note's own refresh lands")
        #expect(!NoteMenuWingContext.reloadAdopts(over: noteB, postID: "note-a"),
                "a stale reload never overwrites the next note's context")
        #expect(!NoteMenuWingContext.reloadAdopts(over: nil, postID: "note-a"),
                "nothing standing, nothing to refresh — the note's own task(id:) load owns the first fill")
    }

    // MARK: - (h) F-U4-4 — the Archived view's inline Unarchive is declared

    /// The registry walk is a UNION equality and `.unarchiveNote` already has
    /// a renderer (a book's archived line), so the walk alone could not see
    /// this declaration go — pinned directly (P-1: every rendered door is
    /// declared), with the face reading its verb from the declaration.
    @Test func theArchivedViewDeclaresItsUnarchive() {
        // 13i-d U7 rider (F-U6-4), a JUSTIFIED EDIT: the row's inline Delete
        // Note… joined the view's declared set — this pin's own subject
        // (Unarchive declared) is unchanged and asserted exactly as before.
        // 13i-e U2, a JUSTIFIED EDIT: the BOOKS group joined the view
        // (R-13ie-1) — its rows render `.unarchiveBook` and the shared
        // `.deleteBook`; this pin's subject (the note row's Unarchive is
        // declared) is unchanged and asserted exactly as before.
        #expect(ArchivedView.surfaceCapabilities
                == [.unarchiveNote, .deleteNote, .unarchiveBook, .deleteBook])
        #expect(CapabilityRegistry.capability(.unarchiveNote).doors.contains(.surface))
        #expect(CapabilityRegistry.capability(.unarchiveNote).verb == "Unarchive")
    }

    // MARK: - The walk's W-1 — the chip never speaks a raw enum

    /// Walked: Diverge on an EMPTY note refused (rightly) as "Refused:
    /// postHasNoBlocks(id: …)" — the chip's table fell through to a dump
    /// while the app's one refusal table has the sentence. Red on the old
    /// default arm (it returned exactly that dump).
    @Test func theChipDefersToTheSharedRefusalWordsNeverADump() {
        let empty = ChipRefusals.message(
            for: OperationError.postHasNoBlocks(id: "p"), bookName: "Odes")
        #expect(!empty.hasPrefix("Refused:"), "\(empty)")
        #expect(empty == OpsRefusalCopy.message(for: OperationError.postHasNoBlocks(id: "p")))
    }

    // MARK: - (f) item 10 — the dismiss receipt teaches the road back

    @Test func theDismissReceiptSaysHowToChangeYourMind() {
        #expect(ArrivalsCopy.dismissed("Ode")
                == "Dismissed \u{201C}Ode\u{201D} \u{2014} it won\u{2019}t come back on its own; "
                    + "add it by hand any time.")
    }

    // MARK: - (d) KnownIssues row 106 — a SEALED book's road is Unseal

    @Test func theArrivalsRefusalNamesUnsealOnASealedBook() {
        let locked = OperationError.lockedReading(id: "r")
        let sealed = ArrivalsCopy.refusal(for: locked, book: "Odes", cap: nil, sealed: true)
        #expect(sealed.contains("sealed") && sealed.contains("Unseal"))
        #expect(!sealed.contains("Reopen"), "Reopen refuses on a sealed book (R-13ic-3)")
        let finished = ArrivalsCopy.refusal(for: locked, book: "Odes", cap: nil)
        #expect(finished.contains("finished") && finished.contains("Reopen"))
    }

    /// The generic arms hold no book, so each names BOTH true roads — never
    /// the dead "locked — unlock" nor a bare "reopen" a sealed book refuses.
    @Test func theBooklessArmsNameBothRoads() {
        let locked = OperationError.lockedReading(id: "r")
        for words in [
            ReadingsViewModel.message(locked),
            DeletionRefusal.words(locked),
            SeededBookRestore.failureLine(for: locked),
        ] {
            #expect(words.contains("reopen"), "\(words)")
            #expect(words.contains("unseal"), "\(words)")
            #expect(!words.contains("unlock"), "\(words)")
        }
    }

    /// The choice sheet's TARGET sealed while the sheet stood open: the
    /// refusal reads the book FRESH and names Unseal. Red on the old arm
    /// ("“Mine” is finished — reopen it (its settings) to add to it.").
    @Test func aTargetSealedUnderTheSheetNamesUnseal() async throws {
        try await withSweepWorld { session, _ in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let other = try ops.createReading(name: "Other", kind: .book)
            let shared = try ops.createPost(title: "shared")
            _ = try ops.addPostToReading(shared.id, to: other.id)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(shared.id, to: mine.id)
            let item = try #require(doors.pending)
            try ops.sealReading(mine.id)

            #expect(await doors.copyIn(item) == nil)
            let refusal = try #require(session.status.current?.text)
            #expect(refusal.contains("sealed") && refusal.contains("unseal"), "\(refusal)")
            #expect(!refusal.contains("reopen it (its settings)"))
        }
    }

    /// The Bookcase holds the row, so a drop or a bind refused by a SEALED
    /// book speaks that book's own road (the generic arm said "locked —
    /// unlock it first").
    @Test func theBookcaseSpeaksASealedBooksOwnRoad() async throws {
        try await withSweepWorld { session, _ in
            let ops = session.operations
            let book = try ops.createReading(name: "Odes", kind: .book)
            try ops.sealReading(book.id)
            let model = ShelfViewModel(session: session)
            let task = Task { await model.start() }
            defer { task.cancel() }
            for _ in 0..<60 where !model.books.contains(where: { $0.reading.id == book.id }) {
                try await Task.sleep(for: .milliseconds(20))
            }
            let words = model.bookRefusal(.lockedReading(id: book.id), readingID: book.id)
            #expect(words.contains("\u{201C}Odes\u{201D} is sealed") && words.contains("unseal"),
                    "\(words)")
        }
    }
}
