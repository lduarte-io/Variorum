//
//  MobileBookDetailsJoinRowsTests.swift
//  VariorumMobileTests
//
//  VM-47 batch 7 (the re-land of main) — **THE JOIN'S ROW ON BOOK DETAILS.**
//  VM-78 (VM-81, W-120) gave an archived book its way out — an Unarchive row
//  on the Book Details sheet — drawn as a plain button in the Mac's type slots,
//  and this run's layer had never seen it: no hunk of the merge showed it, so
//  the re-land restyled it by hand onto the row its siblings wear
//  (`PhoneMenuRowStyle`, the menu row's 44 pt floor — sheet §E), its verb on
//  `control` and its pause sentence on `meta` in the corrected muted. The type
//  scan and the two faint rules hold the role and the ink; nothing held the
//  target. This does: on an archived book's sheet, in both voices, the
//  Unarchive row and its two neighbours (Finish, Delete Book…) each answer at
//  least the menu row's floor.
//
//  RED on the raw merge by construction (the plain style answers at its
//  word's own line, well under 44 pt); green on the re-land.
//

import Foundation
import Testing
import UIKit  // the rows' accessibility frames
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-47 batch 7 — Book Details' Unarchive row answers across the menu row's floor (the join)")
struct MobileBookDetailsJoinRowsTests {
    @Test(arguments: [ThemeVoice.study, .terminal])
    func anArchivedBooksRowsEachAnswerTheMenuRowsFloor(voice: ThemeVoice) async throws {
        let tokens: VoiceTokens = voice == .study ? .studyLight : .terminalLight
        try await withEditorWorld { session, _ in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Old projects", kind: .book)
                try ops.archiveReading(book.id)
                return book.id
            }
            try await withHostedSurface(
                MobileBookDetailsSheet(session: session, readingID: bookID, tokens: tokens)
            ) { surface in
                await surface.settle(30)
                let rows: [String] = [
                    BookStateCopy.finishVerb,
                    BookStateCopy.unarchiveVerb,
                    MobileShelfFaces.deleteDoorTitle(for: .book),
                ]
                for label in rows {
                    let row = try #require(surface.element(labeled: label),
                                           "\(voice): the \(label) row — labels were \(surface.visibleLabels)")
                    #expect(row.accessibilityFrame.height >= PhoneControlMetrics.menuRowPlain - 0.5,
                            "\(voice): the \(label) row answers \(row.accessibilityFrame.height) pt tall, under the menu row's \(PhoneControlMetrics.menuRowPlain)")
                }
            }
        }
    }
}
