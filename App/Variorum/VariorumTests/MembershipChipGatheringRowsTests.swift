//
//  MembershipChipGatheringRowsTests.swift
//  VariorumTests
//
//  VX-1034 (the VX-1082 run, batch B) — a note's list of books, her two calls
//  (QUESTIONS #279 addendum, the VX-1033 sitting, 2026-11-22):
//  "g - agree the mac should show that it's archived." · "h - agree that mac
//  should hide it."
//
//  The chip's membership rows and its add picker each render from ONE pure
//  rule (`MembershipChip.rowDoors(for:)`, `MembershipChip.addOption(for:)`),
//  so the pins read the rules the faces draw. Red on the pre-fix tree: a
//  gathering's row carried `.diverge` (a door the operation always refuses —
//  `divergePostForReading` is books only, AppSpec §9; P-2), and an archived
//  gathering's add option read only "by tagging".
//
//  The Book Panel carries neither defect (traced in the run record): its
//  gatherings line lists only gatherings whose rule shows the note
//  (`readingsContaining` skips an archived one) and it draws no diverge and
//  no add list.
//

import Foundation
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("VX-1034 — the chip's gathering rows")
struct MembershipChipGatheringRowsTests {
    private static let now = Date(timeIntervalSince1970: 1_782_864_000)

    private static func reading(
        _ id: String, kind: ReadingKind = .book, owned: Bool = false, archived: Bool = false,
        locked: Bool = false
    ) -> Reading {
        var reading = Reading(
            id: id, name: id, kind: kind, owned: owned,
            archivedAt: archived ? now : nil, createdAt: now, updatedAt: now)
        reading.locked = locked
        return reading
    }

    /// Call (h): a gathering's row offers no Diverge — it keeps its honest
    /// "remove #tag" doors; a book's row (owned or not) keeps Diverge beside
    /// remove / release (the guard).
    @Test func aGatheringsRowOffersNoDivergeAndABooksRowStillDoes() {
        for gathering in [Self.reading("g", kind: .gathering),
                          Self.reading("archived g", kind: .gathering, archived: true),
                          Self.reading("legacy g", kind: .gathering, locked: true)] {
            let doors = MembershipChip.rowDoors(for: gathering)
            #expect(!doors.contains(.diverge), "\(gathering.id): no diverge on a gathering's row")
            #expect(doors == [.removeRuleTags], "\(gathering.id): only the honest tag doors")
        }
        #expect(MembershipChip.rowDoors(for: Self.reading("b")) == [.diverge, .remove])
        #expect(MembershipChip.rowDoors(for: Self.reading("owned", owned: true)) == [.diverge, .remove],
                "an owned book's row keeps diverge beside release")
        #expect(MembershipChip.surfaceCapabilities.contains(.divergeForBook),
                "the act is still drawn — on a book's row")
    }

    /// Call (g): an archived gathering in the add picker says it is archived,
    /// as an archived book already does there, and keeps its road ("by
    /// tagging"); the live ones are unchanged (the guards).
    @Test func anArchivedGatheringsAddRowSaysArchived() {
        let archivedGathering = MembershipChip.addOption(
            for: Self.reading("Quotes", kind: .gathering, archived: true))
        #expect(archivedGathering.label == "Quotes", "her name, never chrome")
        #expect(archivedGathering.annotation
                == "\(BookArchiveCopy.word) \u{00B7} \(AddToBookCopy.byTagging)",
                "archived first, then the road")
        #expect(MembershipChip.addOption(for: Self.reading("Live", kind: .gathering)).annotation
                == AddToBookCopy.byTagging, "a live gathering: the road alone, as before")
        #expect(MembershipChip.addOption(for: Self.reading("Old", archived: true)).annotation
                == BookArchiveCopy.word, "an archived book: as before")
        #expect(MembershipChip.addOption(for: Self.reading("Open")).annotation == nil,
                "a live book: no annotation, as before")
    }
}
