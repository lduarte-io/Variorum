//
//  BookWindowRoadTests.swift
//  VariorumTests
//
//  **13o U3 — the book's window gets a road** (the brief's item 8,
//  PROVISIONAL P-13o-U3-8; U2's close named it): the book Index said
//  "showing the first 300 notes" and offered nothing more — her
//  ruled-against class (R-13o-9: *"the 40 cap with no escape is
//  terrible"*). Now the line carries "show 300 more ›", which widens the
//  window by one window (a deliberate widening, never a default — P1) and
//  restarts the observation through its key.
//
//  RED-ON-OLD by construction for the reach claim: on the pre-U3 model the
//  301st note was unreachable from the book at any press (`window`,
//  `showMore` did not exist; the limit was the constant).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U3 — the book window's road (show more ›)")
struct BookWindowRoadTests {
    private func model() -> BookViewModel {
        let db = try! AppDatabase.inMemory()
        let session = withDependencies {
            $0.database = db
            $0.date = DateGenerator { harnessNow }
        } operation: { AppSession(database: db) }
        return BookViewModel(session: session, readingID: "book")
    }

    private func entries(_ n: Int) -> [Queries.ReadingEntry] {
        (0..<n).map { Queries.ReadingEntry(postID: "p\($0)", title: nil, entryDate: nil, sectionPath: nil) }
    }

    @Test func theWindowGrowsByOneWindowPerPressAndReachesEveryNote() async {
        let model = model()
        let window = BookViewModel.entryWindow
        await model.adopt(entries(window * 2 + 5 + 1))  // the observation's +1 probe row included
        #expect(model.truncated && model.entries.count == window, "the first window")
        let key = model.observationKey

        model.showMore()
        #expect(model.window == window * 2)
        #expect(model.observationKey != key, "a wider window restarts the observation (its key)")
        await model.adopt(entries(window * 2 + 5 + 1))
        #expect(model.truncated && model.entries.count == window * 2)

        model.showMore()
        await model.adopt(entries(window * 2 + 5))
        #expect(!model.truncated && model.entries.count == window * 2 + 5,
                "every note reached — the line goes away")
    }

    @Test func theLineSaysWhatIsReadAndOffersTheNextWindow() {
        #expect(BookWindowCopy.showing(300) == "showing the first 300 notes \u{2014}",
                "the shipped words, kept")
        #expect(BookWindowCopy.showMore(300) == "show 300 more \u{203A}")
    }
}
