//
//  JournalPrivateFaceTests.swift
//  VariorumTests
//
//  VX-1007 — THE DAILY JOURNAL SHOWS AS PRIVATE WHEREVER PRIVATE IS SHOWN (the
//  VX-981 run, BATCH 1). Her report (2026-11-18): "the journal does not wear
//  the private eye icon & it doesn't show with "private" ticked in its book
//  settings." Her ruling: "I honestly think it always being private is good. I
//  don't want to change it for now. It should just show as ticked and locked
//  in the immediate sense also."
//
//  The faces only — the fence does not change (its facts are pinned headless,
//  `JournalPrivateFacesTests`). Pinned here: the eye's rule chooses the
//  Journal's arms (the Journal's own book mark; each journal leg's note mark;
//  a journal leg wins over a stamp the locked row hides — PROVISIONAL
//  P-981-B1-2), each arm's press acts on NOTHING and says why (the via-Journal
//  arm with ONE door to the Journal), and the two Private rows read ticked and
//  LOCKED on a Journal-fenced thing with one line saying why — their setters
//  refusing there (contract 6: the door closed, never the op) — while an
//  ordinary book or note reads exactly as before. Bug-class: RED on the
//  scaffold commit (the arms and fields declared, the old rule and reads kept).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withJournalWorld<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1007))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private let journal = Queries.BookRef(id: "b-journal", name: "Journal")
private let vault = Queries.BookRef(id: "b-vault", name: "the vault")

@MainActor
@Suite("VX-1007 — the daily Journal shows as Private: the eye's arms, the two rows ticked and locked", .serialized)
struct JournalPrivateFaceTests {
    // MARK: - The rule: which mark a Journal-fenced thing wears

    /// RED on old: THE daily Journal's book row wears the eye — its own arm,
    /// never `.ownBook` (whose press would `setBookPrivate(false)` a stamp the
    /// locked row hides), its own stamp or not. A plain Private book is as
    /// before.
    @Test func theDailyJournalWearsItsOwnArm() {
        #expect(PrivateMarkFace.book(.init(own: false, dailyJournal: true)) == .dailyJournal)
        #expect(PrivateMarkFace.book(.init(own: true, dailyJournal: true)) == .dailyJournal,
                "its own stamp too: the Journal's arm — no press clears it")
        #expect(PrivateMarkFace.book(.init(own: true, dailyJournal: false)) == .ownBook, "unchanged")
        #expect(PrivateMarkFace.book(nil) == nil, "unchanged")
    }

    /// RED on old: each journal leg marks its note. A member of the Journal
    /// (a day entry filed there, or a loose page) wears the via-book form
    /// naming the Journal first; a day entry outside it wears the entry arm; a
    /// journal leg WINS over the note's own stamp and over a Private book
    /// (P-981-B1-2 — the row is locked, so the press never clears a stamp it
    /// hides). Notes with no journal leg read exactly as before.
    @Test func eachJournalLegMarksItsNote() {
        func mark(own: Bool = false, via: [Queries.BookRef] = [], entry: Bool = false,
                  journals: [Queries.BookRef] = []) -> PrivateMarkFace.Mark? {
            PrivateMarkFace.note(.init(own: own, viaBooks: via, journalEntry: entry, viaJournals: journals))
        }
        #expect(mark(entry: true, journals: [journal]) == .viaJournal([journal]), "a day entry in the Journal")
        #expect(mark(journals: [journal]) == .viaJournal([journal]), "a loose page in the Journal")
        #expect(mark(entry: true) == .journalEntry, "a day entry outside the Journal")
        #expect(mark(own: true, journals: [journal]) == .viaJournal([journal]), "its own stamp too")
        #expect(mark(own: true, entry: true) == .journalEntry)
        #expect(mark(via: [vault], journals: [journal]) == .viaJournal([journal, vault]),
                "the Journal named first, then the Private book")
        #expect(mark(via: [vault], entry: true) == .journalEntry, "the entry leg never clears")
        // No journal leg: byte-for-byte as before.
        #expect(mark() == nil)
        #expect(mark(own: true) == .ownNote(alsoVia: []))
        #expect(mark(via: [vault]) == .viaBooks([vault]))
        #expect(mark(own: true, via: [vault]) == .ownNote(alsoVia: [vault]))
    }

    /// RED on old: through the real store and the GATED read every host holds
    /// — a ⌘J day entry filed in the Journal and the Journal itself wear their
    /// arms once a client is approved (R-878-K3 unchanged: nothing before).
    @Test func aDayEntryAndTheJournalWearTheirArmsThroughTheDrawnRead() async throws {
        try await withJournalWorld { session, db in
            let ops = session.operations
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            let name = try #require(try await db.read { try Reading.fetchOne($0, key: journalID) }).name
            func drawn() async throws -> (note: PrivateMarkFace.Mark?, book: PrivateMarkFace.Mark?) {
                let (notes, books) = try await db.read { db in
                    (try Queries.privateMarksDrawn(db, noteIDs: [entry.id]),
                     try Queries.privateBookMarksDrawn(db, readingIDs: [journalID]))
                }
                return (PrivateMarkFace.note(notes[entry.id]), PrivateMarkFace.book(books[journalID]))
            }
            let closed = try await drawn()
            #expect(closed.note == nil && closed.book == nil, "no approved client: no mark (R-878-K3)")
            let client = try ops.recordMCPContact(name: "claude-code", version: "2")
            try ops.approveMCPClient(client.id, granting: nil)
            let open = try await drawn()
            #expect(open.note == .viaJournal([.init(id: journalID, name: name)]))
            #expect(open.book == .dailyJournal)
            // The masthead reads the same rule over the same gated fact.
            let masthead = try await db.read { try MCPNoteIndicatorState.read($0, postID: entry.id) }
            #expect(PrivateMarkFace.note(masthead.mark) == .viaJournal([.init(id: journalID, name: name)]))
            #expect(!masthead.isEmpty, "the masthead has something to say")
        }
    }

    // MARK: - The press, per arm — nothing acts, the why is said

    @Test func eachJournalArmsPressSaysAndActsOnNothing() {
        #expect(PrivateMarkFace.press(.dailyJournal) == .sayDailyJournal)
        #expect(PrivateMarkFace.press(.journalEntry) == .sayJournalEntry)
        #expect(PrivateMarkFace.press(.viaJournal([journal])) == .sayViaJournal([journal]))
    }

    /// RED on old (the rule's half): the Journal's eye — its own stamp
    /// included — never un-privates: the press says her ruled fact as a
    /// refusal-kind line (a door that did nothing) and the stamp stays.
    @Test func theJournalsEyeNeverClearsAStampAndSaysWhy() async throws {
        try await withJournalWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            try ops.setBookPrivate(book.id, true)
            let fact = try #require(try await db.read { try Queries.privateBookMarks($0, readingIDs: [book.id]) }[book.id])
            let mark = try #require(PrivateMarkFace.book(fact))
            await PrivateMarkAct.perform(
                PrivateMarkFace.press(mark), subjectID: book.id, subjectName: "Journal", session: session)
            #expect(try await db.read { try Queries.isBookPrivate($0, readingID: book.id) },
                    "the stamp the locked row hides is untouched")
            let said = try #require(session.status.current)
            #expect(said.kind == .refusal)
            #expect(said.text == PrivateMarkCopy.dailyJournalSaying)
            #expect(said.action == nil, "no door")
        }
    }

    /// The via-Journal arm acts on nothing, says why, and carries ONE door —
    /// the Journal opened at the note (the via-book arm's ascent).
    @Test func theViaJournalArmSaysWhyWithOneDoorToTheJournal() async throws {
        try await withJournalWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            let page = try ops.createPost(title: "a loose page")
            _ = try ops.addPostToReading(page.id, to: book.id)
            let ref = Queries.BookRef(id: book.id, name: "Journal")
            await PrivateMarkAct.perform(.sayViaJournal([ref]), subjectID: page.id, subjectName: nil, session: session)
            #expect(try await db.read { try Queries.isNotePrivate($0, postID: page.id) } == false, "nothing stamped")
            let said = try #require(session.status.current)
            #expect(said.kind == .offer)
            #expect(said.text == "Private via \u{201C}Journal\u{201D} \u{2014} your daily Journal is always Private.")
            let door = try #require(said.action)
            #expect(door.label == "Open \u{201C}Journal\u{201D}")
            let received = LockIsolated<[[String: String]]>([])
            let token = NotificationCenter.default.addObserver(
                forName: .variorumOpenBookAtPost, object: nil, queue: nil
            ) { posted in
                guard let bookID = posted.userInfo?["bookID"] as? String,
                      let postID = posted.userInfo?["postID"] as? String else { return }
                received.withValue { $0.append(["bookID": bookID, "postID": postID]) }
            }
            defer { NotificationCenter.default.removeObserver(token) }
            door.perform()
            #expect(received.value == [["bookID": book.id, "postID": page.id]])
        }
    }

    @Test func theDayEntryArmSaysWhyWithNoDoor() async throws {
        try await withJournalWorld { session, db in
            let entry = try session.operations.createPost(title: "a day", profile: .journal)
            await PrivateMarkAct.perform(.sayJournalEntry, subjectID: entry.id, subjectName: nil, session: session)
            #expect(try await db.read { try Queries.isNotePrivate($0, postID: entry.id) } == false)
            let said = try #require(session.status.current)
            #expect(said.kind == .refusal && said.action == nil)
            #expect(said.text == PrivateMarkCopy.journalEntrySaying)
        }
    }

    // MARK: - The words

    /// The hovers and sayings (PROVISIONAL wording, her pass — P-981-B1-4); the
    /// via-Journal hover is hers ("Private — via ‹book›"); VX-272's
    /// settings-class rule holds on the mark's words (no "AI").
    @Test func theWordsAreThePlainOnesAndTheMarkSaysNoAI() {
        #expect(PrivateMarkFace.help(.viaJournal([journal])) == "Private \u{2014} via \u{201C}Journal\u{201D}")
        #expect(PrivateMarkFace.help(.viaJournal([journal, vault]))
                == "Private \u{2014} via \u{201C}Journal\u{201D} and \u{201C}the vault\u{201D}")
        #expect(PrivateMarkFace.help(.journalEntry) == "Private \u{2014} always, as a daily Journal entry")
        #expect(PrivateMarkFace.help(.dailyJournal) == "Private \u{2014} always, as your daily Journal")
        #expect(PrivateMarkCopy.dailyJournalSaying == "Your daily Journal is always Private, and so is every entry in it.")
        #expect(PrivateMarkCopy.journalEntrySaying == "A daily Journal entry is always Private, wherever it\u{2019}s filed.")
        #expect(!PrivateMarkCopy.viaJournalSaying(["Journal"]).contains("move the note"),
                "never a road that does not un-private a day entry")
        for words in [PrivateMarkCopy.markJournalEntryHelp, PrivateMarkCopy.markDailyJournalHelp,
                      PrivateMarkCopy.dailyJournalSaying, PrivateMarkCopy.journalEntrySaying,
                      PrivateMarkCopy.viaJournalSaying(["Journal"])] {
            #expect(!words.split(whereSeparator: { !$0.isLetter }).contains("AI"), "\(words)")
        }
    }

    // MARK: - Book Settings: the Journal's row is ticked and locked

    /// RED on old: on THE daily Journal (no stamp of its own) the row reads
    /// TICKED and LOCKED with the Journal's line; on an ordinary book it reads
    /// exactly as before — plain, its caption the book caption. VX-641's
    /// appearance rule is untouched (a client has been seen here).
    @Test func bookSettingsReadsTheJournalTickedAndLockedAndAPlainBookAsBefore() async throws {
        try await withJournalWorld { session, db in
            let ops = session.operations
            let daily = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            let plain = try ops.createReading(name: "plain", kind: .book)
            _ = try ops.recordMCPContact(name: "claude-code", version: "1")
            @MainActor func loaded(_ id: String) async throws -> BookSettingsModel {
                let reading = try #require(try await db.read { try Reading.fetchOne($0, key: id) })
                let model = BookSettingsModel(session: session, readingID: id)
                await model.load(for: reading)
                return model
            }
            let journalModel = try await loaded(daily.id)
            #expect(journalModel.showsPrivateRow && journalModel.isDailyJournal && !journalModel.isPrivate,
                    "the Journal: the row shows, derived — nothing stamped")
            #expect(BookSettingsFace.privateRow(isPrivate: journalModel.isPrivate,
                                                isDailyJournal: journalModel.isDailyJournal)
                    == .init(ticked: true, locked: true, caption: PrivateMarkCopy.dailyJournalCaption))
            let plainModel = try await loaded(plain.id)
            #expect(!plainModel.isDailyJournal)
            #expect(BookSettingsFace.privateRow(isPrivate: plainModel.isPrivate,
                                                isDailyJournal: plainModel.isDailyJournal)
                    == .init(ticked: false, locked: false, caption: PrivateMarkCopy.bookCaption))
            try ops.setBookPrivate(plain.id, true)
            #expect(BookSettingsFace.privateRow(isPrivate: true, isDailyJournal: false)
                    == .init(ticked: true, locked: false, caption: PrivateMarkCopy.bookCaption),
                    "a Private book's row is the plain toggle, as before")
        }
    }

    /// RED on old: the locked row's door is CLOSED — the model's setter
    /// refuses on the Journal, its own stamp included, so no write hides
    /// behind the lock (contract 6); `setBookPrivate` itself is unchanged.
    @Test func theJournalsRowSetterActsOnNothing() async throws {
        try await withJournalWorld { session, db in
            let ops = session.operations
            let daily = try ops.createReading(name: "Journal", kind: .book, profile: "daily")
            try ops.setBookPrivate(daily.id, true)
            let reading = try #require(try await db.read { try Reading.fetchOne($0, key: daily.id) })
            let model = BookSettingsModel(session: session, readingID: daily.id)
            await model.load(for: reading)
            await model.setPrivate(false, name: "Journal")
            #expect(try await db.read { try Queries.isBookPrivate($0, readingID: daily.id) },
                    "the door is closed: nothing cleared")
            // The op keeps its store behaviour (contract 6 — the door, never the op).
            #expect(try ops.setBookPrivate(daily.id, false))
        }
    }

    // MARK: - The note ▾ menu's row

    /// RED on old: a day entry filed in the Journal, a loose page there and a
    /// day entry outside it read TICKED and LOCKED with their line; a plain
    /// note, a marked note and a note in a Private book read as before.
    @Test func theNotesRowReadsJournalFencedNotesTickedAndLocked() async throws {
        try await withJournalWorld { session, db in
            let ops = session.operations
            _ = try ops.recordMCPContact(name: "claude-code", version: "1")
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let journalID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            let loose = try ops.createPost(title: "a loose page")
            _ = try ops.addPostToReading(loose.id, to: journalID)
            let away = try ops.createPost(title: "a day elsewhere", profile: .journal)
            let plain = try ops.createPost(title: "open")
            let marked = try ops.createPost(title: "marked")
            try ops.setNotePrivate(marked.id, true)
            func row(_ id: String) async throws -> NotePrivacyState {
                try await db.read { try NotePrivacyState.read($0, postID: id) }
            }
            for (id, entryLine) in [(entry.id, true), (loose.id, false), (away.id, true)] {
                let state = try await row(id)
                #expect(state.showsPrivateRow && state.rowTicked && state.rowLocked, "ticked and locked: \(id)")
                #expect(state.alwaysPrivateLine == PrivateMarkCopy.noteAlwaysPrivate(entry: entryLine))
            }
            let plainRow = try await row(plain.id)
            #expect(!plainRow.rowTicked && !plainRow.rowLocked && plainRow.alwaysPrivateLine == nil)
            let markedRow = try await row(marked.id)
            #expect(markedRow.rowTicked && !markedRow.rowLocked && markedRow.alwaysPrivateLine == nil,
                    "an own mark is the plain toggle, as before")
        }
    }

    /// RED on old: the locked note row's door is closed — a day entry carrying
    /// its own stamp too keeps it (the locked row hides it; P-981-B1-2).
    @Test func theNotesLockedRowSetterActsOnNothing() async throws {
        try await withJournalWorld { session, db in
            let ops = session.operations
            let entry = try ops.createPost(title: "a day", profile: .journal)
            try ops.setNotePrivate(entry.id, true)
            let state = try await db.read { try NotePrivacyState.read($0, postID: entry.id) }
            #expect(state.rowLocked)
            await NotePrivacyAct.set(false, state: state, session: session)
            #expect(try await db.read { try Queries.isNotePrivate($0, postID: entry.id) }, "nothing cleared")
            // An unlocked row still acts (control).
            let plain = try ops.createPost(title: "open")
            let plainState = try await db.read { try NotePrivacyState.read($0, postID: plain.id) }
            await NotePrivacyAct.set(true, state: plainState, session: session)
            #expect(try await db.read { try Queries.isNotePrivate($0, postID: plain.id) })
        }
    }

    // MARK: - The fences, said as code

    /// No new writer of `ai_private_at`: the face clears only her own stamps
    /// through the existing ops, and the Journal's arms call none.
    @Test func noNewWriterOfThePrivateStamp() throws {
        let views = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Core/Views")
        let face = try String(contentsOf: views.appendingPathComponent("PrivateMarkView.swift"), encoding: .utf8)
        #expect(!face.contains("Private(subjectID, true)"))
        #expect(!face.contains("ai_private_at ="))
        let row = try String(contentsOf: views.appendingPathComponent("PrivateMark.swift"), encoding: .utf8)
        #expect(!row.contains("ai_private_at ="))
    }
}
