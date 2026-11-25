//
//  MobileNoteTopRowTests.swift
//  VariorumMobileTests
//
//  VM-260 batch 4b (R-260-13 as picked, ratified R-260-14) — **THE NOTE'S TOP:
//  THE TITLE ON ITS OWN ROW, ONE ROW OF ICONS UNDER IT, AND ONLY THAT ROW
//  STAYS.** Her words (2026-11-25): "maybe it would be best for the title to
//  get more space on top and then there's one row of icons, and just that row
//  of icons is what stays with you as you scroll … the title is quite cut off
//  when it's long - which having a row of icons below it might fix, then the
//  title could be more centered." Her pick: "A — the title on top, one icon row
//  that stays … I don't think there should be a verticle line between the
//  options. i'd make sure it's easy to click on tags to see them expand and then
//  click on the tag icon so tags close again too. i feel like sealing the note
//  can also go in the note's menu (maybe it can stay an easy to click icon at
//  the top of the note menu instead of another row). i also think that date
//  could go in the note menu, again it could be an easy to click icon at the
//  top." The drawing is `notes/plans/vm-260/note-top-options.html`, frame P; the
//  record is BATCH 4b in `notes/plans/fixes/vm-260-phone-look.md`.
//
//  THE PINS, on the app's own screen (`MobileWriteScreen` with the model it
//  drove — the screen's own test seam), 402 × 874, both voices where the
//  surface has a face:
//  · the row is what stays — at rest the title stands above the row; after a
//    scroll the row holds the top and the title has left with her text; back at
//    the top the title returns (RED ON OLD: the whole masthead stayed);
//  · a long title wraps, centred, and is never cut (RED ON OLD: one line, cut,
//    leading);
//  · # opens the note's tags in place — no sheet — under the row, travelling
//    with it; the same # closes them; adding a tag stays one press away (RED ON
//    OLD: the tags chip opened a sheet);
//  · the seal and the date head the Note sheet, side by side above its rows,
//    each its old act (RED ON OLD: neither is in the sheet);
//  · the book door is grey while the note is in no book (RED ON OLD: the
//    membership line read the same muted words either way).
//  The six doors' one row is `MobileNoteTopTests` (the four tools' guard,
//  moved with the ruling).
//
//  Only literals and symbols both trees declare: the red-on-old tree is the
//  commit that lands this file.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// Seeds one note: a title, `paragraphs` blocks of plain words, the tags it
/// wears and the book that holds it (if any).
@MainActor
private func seedNote(
    _ session: AppSession, title: String = "Harbor notes", paragraphs: Int = 3,
    tags: [String] = [], inBook: String? = nil
) async throws -> String {
    try await session.runner.run { ops -> String in
        let post = try ops.createPost(title: title, profile: .blog)
        for index in 1...max(paragraphs, 1) {
            _ = try ops.newBlock(
                in: post.id,
                text: "Paragraph \(index) carries enough plain words to wrap across a couple of lines on a phone page.",
                at: .end, registeringUndo: false)
        }
        for name in tags {
            let tag = try ops.createTag(name: name)
            _ = try ops.applyTag(tag.id, toPost: post.id)
        }
        if let inBook {
            let book = try ops.createReading(name: inBook, kind: .book)
            _ = try ops.addPostToReading(post.id, to: book.id)
        }
        return post.id
    }
}

/// Lets the surface settle until `condition` holds (or the turns run out).
@MainActor
private func settleUntil<Content: View>(
    _ surface: HostedSurface<Content>, until condition: () -> Bool, turns: Int = 150
) async -> Bool {
    for _ in 0..<turns where !condition() { await surface.settle(1) }
    return condition()
}

@MainActor
@Suite("VM-260 4b — the note's top: one row of icons stays", .serialized)
struct MobileNoteTopRowTests {
    /// The stack door's name (blocks · lens · more info behind one door).
    static let stackDoor = "Blocks, Lenses and More Info"
    /// The open tag strip's add door.
    static let addTag = "Add Tag"
    /// A title long enough to need three lines in either voice at 402 pt.
    static let longTitle = "XXII. Concerning the secretaries of princes, and how they should be chosen"

    /// The app's Write screen over a seeded note, in one voice, at the phone's width.
    private func mounted(
        _ voice: ThemeVoice, title: String = "Harbor notes", paragraphs: Int = 3,
        tags: [String] = [], inBook: String? = nil,
        _ body: @MainActor (MobileEditorViewModel, HostedSurface<MobileWriteScreen>) async throws -> Void
    ) async throws {
        try await withEditorWorld { session, _ in
            MobileEditorStyle.voice = voice
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let postID = try await seedNote(
                session, title: title, paragraphs: paragraphs, tags: tags, inBook: inBook)
            let model = MobileEditorViewModel(session: session, postID: postID)
            let surface = HostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model),
                size: CGSize(width: 402, height: 874))
            defer { surface.tearDown() }
            for _ in 0..<300 {
                if let tv = model.textView, tv.textStorage.length > 0 { break }
                await surface.settle(1)
            }
            await surface.settle(30)
            try await body(model, surface)
        }
    }

    // MARK: - The row stays; the title rides away

    /// **RED ON OLD — "I don't want this whole header to be sticky, it takes up
    /// too much room as you scroll."** At rest the title stands on its own row
    /// above the icon row, and everything above her text is that title's row (its
    /// own frame and at most 12 of air), the one 44 pt row and the 4 below. Once
    /// she has scrolled, the row holds the top of the screen, the title has gone
    /// with her text, and the chrome above her text is the row alone. Back at the
    /// top, the title returns. The old tree kept the whole masthead (136 pt) at
    /// the top however far she scrolled, the title on the tools' row.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theIconRowIsWhatStaysAsSheScrolls(voice: ThemeVoice) async throws {
        try await mounted(voice, paragraphs: 30) { model, surface in
            let tv = try #require(model.textView, "the editor is up")
            let safeTop = surface.host.view.safeAreaInsets.top
            func chrome() -> CGFloat { tv.convert(tv.bounds, to: nil).minY - safeTop }

            let title = try #require(surface.element(labeled: "Rename Note"),
                                     "the title at rest: \(surface.visibleLabels)").accessibilityFrame
            let row = try #require(surface.element(labeled: "Copy Note"),
                                   "the row at rest: \(surface.visibleLabels)").accessibilityFrame
            let rest = chrome()
            print("PERF[sim] VM-260 4b note top \(voice) at rest: chrome \(rest), title \(title), row \(row)")
            #expect(title.maxY <= row.minY + 0.5,
                    "\(voice): at rest the title stands on its own row above the icons (\(title) · \(row))")
            #expect(rest <= title.height + 12 + PhoneMetrics.touchMinimum + MobileWriteScreen.mastheadBottom + 1,
                    "\(voice): at rest the note's top is the title's row and ONE row of icons (\(rest) pt)")

            tv.setContentOffset(CGPoint(x: 0, y: 300), animated: false)
            await surface.settle(40)
            let scrolled = chrome()
            let rowScrolled = try #require(surface.element(labeled: "Copy Note"),
                                           "the row, scrolled: \(surface.visibleLabels)").accessibilityFrame
            let titleScrolled = surface.element(labeled: "Rename Note")?.accessibilityFrame
            print("PERF[sim] VM-260 4b note top \(voice) scrolled: chrome \(scrolled), row \(rowScrolled), "
                  + "title \(titleScrolled.map { "\($0)" } ?? "gone")")
            #expect(titleScrolled == nil || titleScrolled!.maxY <= safeTop + 0.5,
                    "\(voice): scrolled, the title rode away with her text (\(String(describing: titleScrolled)))")
            #expect(abs(rowScrolled.minY - safeTop) <= 0.5,
                    "\(voice): scrolled, the row holds the top (\(rowScrolled), safe top \(safeTop))")
            #expect(scrolled <= PhoneMetrics.touchMinimum + MobileWriteScreen.mastheadBottom + 1,
                    "\(voice): scrolled, only the row stays above her text (\(scrolled) pt)")
            #expect(scrolled >= PhoneMetrics.touchMinimum - 0.5, "\(voice): the row itself stays (\(scrolled))")

            tv.setContentOffset(.zero, animated: false)
            await surface.settle(40)
            let back = try #require(surface.element(labeled: "Rename Note"),
                                    "\(voice): back at the top the title returns: \(surface.visibleLabels)")
            #expect(abs(back.accessibilityFrame.minY - title.minY) <= 0.5,
                    "\(voice): the title is back where it stood (\(back.accessibilityFrame) · \(title))")
            #expect(abs(chrome() - rest) <= 0.5, "\(voice): back at the top, the top is as it was (\(chrome()) · \(rest))")
        }
    }

    // MARK: - The title wraps, centred

    /// **RED ON OLD — "the title is quite cut off when it's long".** A long title
    /// wraps onto as many lines as it needs, centred on the screen, inside the
    /// gutter — never cut. The old title was one line, cut, at the leading edge
    /// beside the tools.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func aLongTitleWrapsCentredAndIsNeverCut(voice: ThemeVoice) async throws {
        try await mounted(voice, title: Self.longTitle) { _, surface in
            let title = try #require(surface.element(labeled: "Rename Note"),
                                     "\(voice): \(surface.visibleLabels)").accessibilityFrame
            let line = PhoneType.spec(.noteTitle, voice: voice).lineHeight
            print("PERF[sim] VM-260 4b long title \(voice): \(title) (line \(line))")
            #expect(title.height >= 2 * line - 2,
                    "\(voice): the long title wraps (\(title.height) pt for \(line)-pt lines)")
            #expect(abs(title.midX - 201) <= 1, "\(voice): the title is centred (\(title))")
            #expect(title.minX >= PhoneMetrics.gutter - 0.5 && title.maxX <= 402 - PhoneMetrics.gutter + 0.5,
                    "\(voice): inside the gutter (\(title))")
        }
    }

    // MARK: - # opens the tags in place, and closes them

    /// **RED ON OLD — "easy to click on tags to see them expand and then click on
    /// the tag icon so tags close again".** # opens the note's tags IN PLACE —
    /// no sheet — as a strip under the row; scrolled, the strip travels with the
    /// row; the same # closes it; and adding a tag stays one press away, the
    /// strip's own door opening the note's tags sheet. The old tags chip opened
    /// the sheet.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theHashOpensTheTagsInPlaceAndTheSameHashClosesThem(voice: ThemeVoice) async throws {
        try await mounted(voice, paragraphs: 30, tags: ["poems"]) { model, surface in
            let tv = try #require(model.textView, "the editor is up")
            let safeTop = surface.host.view.safeAreaInsets.top

            #expect(surface.activate("Tags"), "\(voice): the # door: \(surface.visibleLabels)")
            await surface.settle(30)
            #expect(surface.host.presentedViewController == nil, "\(voice): no sheet — the tags open in place")
            let hash = try #require(surface.element(labeled: "Tags"), "\(voice): \(surface.visibleLabels)")
                .accessibilityFrame
            let add = try #require(surface.element(labeled: Self.addTag),
                                   "\(voice): the open strip: \(surface.visibleLabels)").accessibilityFrame
            #expect(surface.visibleLabels.contains { $0.localizedCaseInsensitiveContains("poems") },
                    "\(voice): the note's tag shows in the strip: \(surface.visibleLabels)")
            #expect(add.minY >= hash.maxY - 0.5, "\(voice): the strip sits under the row (\(hash) · \(add))")
            #expect(add.width >= 43.5 && add.height >= 43.5, "\(voice): the add door answers 44 × 44 (\(add))")

            tv.setContentOffset(CGPoint(x: 0, y: 300), animated: false)
            await surface.settle(40)
            let hashScrolled = try #require(surface.element(labeled: "Tags")).accessibilityFrame
            let addScrolled = try #require(surface.element(labeled: Self.addTag),
                                           "\(voice): scrolled, the strip stays open: \(surface.visibleLabels)")
                .accessibilityFrame
            #expect(abs(hashScrolled.minY - safeTop) <= 0.5, "\(voice): the row holds the top (\(hashScrolled))")
            #expect(addScrolled.minY >= hashScrolled.maxY - 0.5,
                    "\(voice): the open strip travels with the row (\(hashScrolled) · \(addScrolled))")

            #expect(surface.activate("Tags"))
            await surface.settle(30)
            #expect(surface.element(labeled: Self.addTag) == nil, "\(voice): the same # closes the strip")
            #expect(surface.host.presentedViewController == nil)

            #expect(surface.activate("Tags"))
            await surface.settle(30)
            #expect(surface.activate(Self.addTag), "\(voice): \(surface.visibleLabels)")
            await surface.settle(40)
            #expect(surface.host.presentedViewController != nil,
                    "\(voice): the strip's add door opens the note's tags sheet")
        }
    }

    // MARK: - The seal and the date head the Note sheet

    /// **RED ON OLD — "sealing the note can also go in the note's menu (maybe it
    /// can stay an easy to click icon at the top of the note menu instead of
    /// another row) … date could go in the note menu, again … an easy to click
    /// icon at the top."** The Note sheet opens headed by the two doors, side by
    /// side above its rows, each answering 44 × 44: the seal's own act (the note
    /// locks; the door then shows the sealed state and offers the unlock) and the
    /// date's own act (the Entry Date alert). The old sheet had neither.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theSealAndTheDateHeadTheNoteSheet(voice: ThemeVoice) async throws {
        try await mounted(voice) { model, surface in
            #expect(surface.activate(MobileNoteActionsSheet.doorLabel), "\(voice): \(surface.visibleLabels)")
            await surface.settle(40)
            let seal = try #require(surface.element(labeled: MobileWriteScreen.lockDoorTitle),
                                    "\(voice): the seal at the sheet's head: \(surface.visibleLabels)")
                .accessibilityFrame
            let date = try #require(surface.element(labeled: "Entry Date"),
                                    "\(voice): the date at the sheet's head: \(surface.visibleLabels)")
                .accessibilityFrame
            let firstRow = try #require(surface.element(labeled: VersionsPath.saveVerb),
                                        "\(voice): the sheet's first row: \(surface.visibleLabels)")
                .accessibilityFrame
            #expect(seal.maxY <= firstRow.minY + 0.5 && date.maxY <= firstRow.minY + 0.5,
                    "\(voice): both head the sheet, above its rows (\(seal) · \(date) · \(firstRow))")
            #expect(abs(seal.midY - date.midY) <= 0.5, "\(voice): side by side (\(seal) · \(date))")
            for (name, frame) in [("seal", seal), ("date", date)] {
                #expect(frame.width >= 43.5 && frame.height >= 43.5, "\(voice): the \(name) door answers 44 × 44 (\(frame))")
            }

            #expect(surface.activate(MobileWriteScreen.lockDoorTitle))
            #expect(await settleUntil(surface, until: { model.isSealed }), "\(voice): the seal's own act locked the note")
            await surface.settle(20)
            #expect(surface.element(labeled: MobileWriteScreen.unlockDoorTitle) != nil,
                    "\(voice): the door shows the sealed state and offers the unlock: \(surface.visibleLabels)")

            #expect(surface.activate("Entry Date"), "\(voice): \(surface.visibleLabels)")
            await surface.settle(30)
            #expect(surface.presentedAlert?.title == "Entry Date",
                    "\(voice): the date's own act — the Entry Date alert (\(String(describing: surface.presentedAlert?.title)))")
        }
    }

    // MARK: - The book door is grey while the note is in no book

    /// **RED ON OLD — "in no book should be replaced with a book icon that you can
    /// tap on to add it to a book, maybe greyed out when there's no book."** Read
    /// as pixels off a real scene window: the book door of a note in no book
    /// draws in the corrected faint — still a glyph that reads (the glyph floor,
    /// 3:1) — and the same door on a note a book holds draws in ink, well above
    /// it. The old membership line read the same muted words either way.
    @Test(arguments: [false, true])
    func theBookDoorIsGreyWhileTheNoteIsInNoBook(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let loose = try await seedNote(session, title: "Loose")
            let held = try await seedNote(session, title: "Held", inBook: "Poems")
            func contrast(_ postID: String) async throws -> Double {
                let model = MobileEditorViewModel(session: session, postID: postID)
                return try await withSceneSurface(
                    MobileWriteScreen(session: session, postID: postID, editor: model), dark: dark
                ) { surface in
                    await surface.settle(60)
                    let door = try #require(surface.onScreen("Books holding this note"),
                                            "the book door: \(surface.labels)")
                    let pixels = try surface.render()
                    let read = try #require(pixels.inkAndGround(in: door.accessibilityFrame),
                                            "nothing drawn in the book door")
                    return read.ink.contrast(with: read.ground)
                }
            }
            let bookless = try await contrast(loose)
            let inBook = try await contrast(held)
            print("PERF[sim] VM-260 4b book door dark \(dark): bookless \(bookless) · in a book \(inBook)")
            #expect(bookless >= 2.95, "dark \(dark): the grey book still reads as a glyph (\(bookless):1)")
            #expect(inBook >= 4.5, "dark \(dark): a held note's book door reads in ink (\(inBook):1)")
            #expect(inBook - bookless >= 2,
                    "dark \(dark): the book door is GREY while the note is in no book (\(bookless):1 against \(inBook):1)")
        }
    }
}
