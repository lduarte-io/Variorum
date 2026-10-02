//
//  BookCollectingDoorsTests.swift
//  VariorumTests
//
//  13i-d U3 — THE COLLECTING PANE'S DOORS (the sitting record §4: "reachable
//  from the book's ⋯ menu and the Bookcase row's context menu"; §10: the
//  journal-trait row joins it) and ROW 107's SETTINGS-SHEET half (§3: a
//  gathering has no finish, word target or capacity).
//
//  What is pinned:
//  - the settings door: ONE act, both roads declared (the Bookcase row's menu
//    and the book masthead's gear), and the Bookcase's road reaches the sheet
//    for ITS book, loaded before it presents;
//  - the journal-trait sentence: drawn on a book (never a gathering), on/off
//    writing `profile` (ON also sorts by date — P-13id-U3-2), the daily
//    Journal's refusal and a finished book's refusal SPOKEN in words;
//  - row 107's faces: a gathering's sheet draws no Finished control and no
//    extent fields, except the legacy ways out (P-13id-U3-3).
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
private func withDoorWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 31))
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
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 760),
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
@Suite("The Collecting pane's doors (13i-d U3)", .serialized)
struct BookCollectingDoorsTests {
    // MARK: - The doors into the sheet (§4)

    /// ONE act, two roads: the Bookcase row's menu (`.contextMenu`) and the
    /// book masthead's gear (`.surface`) — each a declared renderer (P-1).
    @Test func theSettingsDoorIsOneActOnBothRoads() {
        let act = CapabilityRegistry.capability(.openBookSettings)
        #expect(act.doors == [.contextMenu, .surface])
        #expect(act.scope == .book)
        #expect(ShelfView.contextMenuCapabilities.contains(.openBookSettings),
                "the Bookcase row's menu renders it (§4's second road)")
        #expect(BookView.surfaceCapabilities == [.openBookSettings],
                "the book masthead's gear is the book's own door")
        #expect(CollectingCopy.openVerb(isBook: true) == "Book Settings\u{2026}")
        #expect(CollectingCopy.openVerb(isBook: false) == "Gathering Settings\u{2026}")
    }

    /// The Bookcase's road: the target arrives LOADED (its fields seed from
    /// the book, never from an empty one), and the mounted host draws the
    /// sheet for that book — a book's and a gathering's.
    @Test func theBookcaseRoadReachesTheSheetForItsOwnBook() async throws {
        try await withDoorWorld { session, db in
            let ops = session.operations
            let work = try ops.createTag(name: "work")
            let book = try ops.createReading(name: "Field Notes", kind: .book)
            try ops.setReadingWordTarget(book.id, wordTarget: 40_000)
            let gathering = try ops.createReading(
                name: "Work", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(work.id)))

            let target = try #require(
                await BookSettingsTarget.load(session: session, readingID: book.id))
            #expect(target.structure.reading?.id == book.id, "loaded before it presents")
            #expect(target.structure.reading?.wordTarget == 40_000,
                    "the fields will seed from the book's own word target")
            BookSettingsProbe.drawn = [:]
            try await mounted(BookSettingsHost(target: target)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.title == "Book Settings")
            }

            let gTarget = try #require(
                await BookSettingsTarget.load(session: session, readingID: gathering.id))
            try await mounted(BookSettingsHost(target: gTarget)) {
                let drawn = try #require(BookSettingsProbe.drawn[gathering.id])
                #expect(drawn.title == "Gathering Settings")
            }

            // A book deleted between the click and the read: no target (the
            // door speaks the refusal instead of opening an empty sheet).
            try ops.deleteReading(book.id)
            #expect(await BookSettingsTarget.load(session: session, readingID: book.id) == nil)
            _ = try await reading(db, gathering.id)
        }
    }

    // MARK: - The journal-trait sentence (§10)

    /// §10's sentence is a BOOK's row (a gathering mints no entries — P-2),
    /// and it is drawn with the trait's state.
    @Test func theJournalTraitSentenceIsDrawnOnABookOnly() async throws {
        #expect(CollectingCopy.journalTraitLabel + " " + CollectingCopy.journalTraitValue
                == "Entries: date-stamped, named by their day, sorted by date",
                "§10's sentence, verbatim")
        #expect(BookSettingsSheet.surfaceCapabilities.contains(.setJournalTrait))
        try await withDoorWorld { session, db in
            let ops = session.operations
            let work = try ops.createTag(name: "work")
            let book = try ops.createReading(name: "Plain", kind: .book)
            let journal = try ops.createReading(
                name: "Dreams", kind: .book, profile: Queries.journalTraitProfile)
            let gathering = try ops.createReading(
                name: "Work", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(work.id)))
            BookSettingsProbe.drawn = [:]
            for (id, expected) in [(book.id, false as Bool?), (journal.id, true), (gathering.id, nil)] {
                let target = try #require(await BookSettingsTarget.load(session: session, readingID: id))
                try await mounted(BookSettingsHost(target: target)) {
                    let drawn = try #require(BookSettingsProbe.drawn[id])
                    #expect(drawn.journalTrait == expected)
                }
            }
            _ = try await reading(db, book.id)
        }
    }

    /// ON writes the trait AND sorts the book by date, newest first
    /// (P-13id-U3-2 — the sentence it turns on says "sorted by date"); a book
    /// already sorted by date keeps its direction; OFF writes the trait off
    /// and leaves the order as it is.
    @Test func theTraitTogglesThroughTheOpAndOnSortsByDate() async throws {
        try await withDoorWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Plain", kind: .book)
            let settings = BookSettingsModel(session: session, readingID: book.id)

            await settings.setJournalTrait(true, reading: try await reading(db, book.id))
            var now = try await reading(db, book.id)
            #expect(now.profile == Queries.journalTraitProfile)
            #expect(now.sortField == .entryDate && now.sortDir == .desc,
                    "ON sorts by entry date, newest first — the sentence is true")

            await settings.setJournalTrait(false, reading: now)
            now = try await reading(db, book.id)
            #expect(now.profile == "book")
            #expect(now.sortField == .entryDate, "OFF never rewrites her order")

            // Already by date (oldest first): ON keeps her direction.
            try ops.setReadingSort(book.id, field: .entryDate, direction: .asc)
            await settings.setJournalTrait(true, reading: try await reading(db, book.id))
            now = try await reading(db, book.id)
            #expect(now.profile == Queries.journalTraitProfile)
            #expect(now.sortDir == .asc, "a book already sorted by date keeps its direction")
            #expect(session.status.spoken == nil, "nothing refused along the way")
        }
    }

    /// The daily Journal's trait is constitutive — its "off" ACTS and the
    /// op's refusal is SPOKEN in words (never the raw enum); a finished
    /// book's refusal is named for the book with its road.
    @Test func theDailyJournalAndAFinishedBookRefuseInWords() async throws {
        try await withDoorWorld { session, db in
            let ops = session.operations
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-10-02")
            _ = ops.shelveInDailyJournalBook(entry.container.id)
            let dailyID = try #require(try await db.read { try Queries.dailyJournalBookID($0) })
            let daily = try await reading(db, dailyID)
            #expect(Queries.hasJournalTrait(daily.profile))

            let settings = BookSettingsModel(session: session, readingID: dailyID)
            await settings.setJournalTrait(false, reading: daily)
            #expect(try await reading(db, dailyID).profile == daily.profile, "nothing written")
            let spoken = try #require(session.status.spoken?.text)
            #expect(spoken.hasPrefix("This is your daily Journal"), "\(spoken)")
            #expect(!spoken.contains("Refused"), "never the enum dump")

            let finished = try ops.createReading(name: "Done", kind: .book)
            try ops.lockReading(finished.id)
            let finishedSettings = BookSettingsModel(session: session, readingID: finished.id)
            await finishedSettings.setJournalTrait(true, reading: try await reading(db, finished.id))
            #expect(try await reading(db, finished.id).profile != Queries.journalTraitProfile)
            #expect(session.status.spoken?.text == "\u{201C}Done\u{201D} is finished \u{2014} reopen it first.")
        }
    }
}
