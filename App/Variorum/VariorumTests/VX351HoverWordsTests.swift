//
//  VX351HoverWordsTests.swift
//  VariorumTests
//
//  **VX-351 (the VX-348 run, U4) — every speaker's hover, in the one brain's
//  words.** NEW API (fixed-only — this file is removed from the red product):
//  the red-on-old proof of the hovers is `VX351StampHoverTests.swift`'s
//  composition suites and the walk. Her rulings R-VX348-1/3.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// **The hovers' WORDS, speaker by speaker** (new API — fixed-only: the
/// red-on-old proof is the composition suites above and the walk). Every
/// hover is the one brain's whole fact (`TimeStampFace.whole`), led by the
/// speaker's own verb or verbless where its line already names the act.
@MainActor
@Suite("VX-351 — every speaker's hover, in the one brain's words")
struct VX351HoverWordsTests {
    private let instant = Date(timeIntervalSince1970: 1_791_720_000)  // 2026-10-11 12:00 UTC
    private var iso: String { DateFormatter.variorumISO8601.string(from: instant) }
    private var whole: String { TimeStampFace.whole(instant) }

    @Test func theNamedSpeakersHoverTheWholeFact() {
        #expect(ArrivalsCopy.arrivedHelp(iso) == "Arrived \(whole)")
        #expect(ArrivalsCopy.arrivedHelp("soon") == nil, "a stamp that is not one hovers nothing")
        #expect(ArchivedLineCopy.archivedHelp(iso) == "Archived \(whole)")
        #expect(LibrarySearchFace.kindHelp(kind: .savepoint, savedAt: iso) == "Committed \(whole)")
        #expect(LibrarySearchFace.kindHelp(kind: .take, savedAt: nil) == nil, "prose says no stamp")
        #expect(LibrarySearchFace.kindHelp(kind: .comment, savedAt: nil) == nil)
        #expect(MCPPane.whole(iso) == whole, "the Activity line names its act: verbless")
        #expect(MCPPane.whole("soon") == nil)
        #expect(OriginPeekCopy.lineageHelp(at: iso) == whole, "the lineage row names its act: verbless")
    }

    @Test func theTwoGapsHoverTheirFactsWhole() {
        let saved = instant.addingTimeInterval(-86_400 * 3)
        #expect(LibraryPreview.NotePreview(editedAt: instant).factsHelp() == "Edited \(whole)")
        #expect(LibraryPreview.NotePreview().factsHelp() == nil, "no stamp, no hover")
        #expect(NoteBoxCopy.stampsHelp(edited: instant, saved: saved)
                == "Edited \(whole) \u{B7} Saved \(TimeStampFace.whole(saved))", "the line's own order")
        #expect(NoteBoxCopy.stampsHelp(edited: instant, saved: nil) == "Edited \(whole)")
        #expect(NoteBoxCopy.stampsHelp(edited: nil, saved: nil) == nil)
    }

    @Test func thePickersHoverTheirDays() {
        let day = "2026-10-13"
        #expect(NotePickerRanking.detailHelp(title: "Harbor Log", entryDate: day, touchedStamp: iso)
                == TimeStampFace.tooltip(.dated, day: day), "a stated day: the day, with its year")
        #expect(NotePickerRanking.detailHelp(title: day, entryDate: day, touchedStamp: iso) == nil,
                "a nameless note's day IS its title — the detail is suppressed, so is its hover")
        #expect(NotePickerRanking.detailHelp(title: "Harbor Log", entryDate: nil, touchedStamp: iso)
                == "Edited \(whole)", "no stated day: the last edit, to the minute")

        let sections = MCPGrantPicker.noteSections([
            MCPGrantPicker.NoteRow(id: "n1", title: "Harbor Log", snippet: nil, day: day, fence: nil,
                                   dayHelp: "Dated Oct 13, 2026"),
            MCPGrantPicker.NoteRow(id: "n2", title: "Journal", snippet: nil, day: day, fence: .journal,
                                   dayHelp: "Dated Oct 13, 2026"),
        ], query: "")
        let options = sections.flatMap(\.options)
        #expect(options.first { $0.id == "n1" }?.help == "Dated Oct 13, 2026", "the row's day hovers whole")
        #expect(options.first { $0.id == "n2" }?.help == nil, "a fence word stands in the day's place: no stamp")

        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let en = Locale(identifier: "en_US")
        let book = Queries.MCPGrantableBook(
            id: "b1", name: "percy", wingID: "", shelfID: nil, starred: false, noteCount: 3,
            createdAt: iso, lastEdited: iso)
        let option = MCPGrantPicker.bookOption(
            book, places: MCPGrantPlaces(books: [book]), distinguisher: nil, now: instant,
            calendar: utc, locale: en)
        #expect(option.help == TimeStampFace.tooltip(.edited, date: instant, calendar: utc, locale: en),
                "the context line's edited stamp hovers to the minute")
    }

    @Test func theFoundSpeakersHoverTheirStamps() {
        #expect(SnippetCardFace.editedHelp(updatedAt: iso) == "Edited \(whole)")
        #expect(SnippetCardFace.metadata(activeTakes: 1, text: "a b", updatedAt: iso).last
                == SnippetCardFace.editedPart(updatedAt: iso), "the part the card hovers IS the metadata's")
        #expect(TrayRowPreview.stampHelp(iso, verb: "deleted") == "Deleted \(whole)")
        #expect(TrayRowFace.leadHelp(stamp: iso, when: "archived") == "Archived \(whole)")
        #expect(TrayRowFace.leadHelp(stamp: nil, when: "deleted") == nil)
    }
}
