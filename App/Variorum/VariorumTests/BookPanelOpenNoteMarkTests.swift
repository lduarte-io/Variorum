//
//  BookPanelOpenNoteMarkTests.swift
//  VariorumTests
//
//  VX-356 (the VX-440 run, batch 3 — a Suspected rider from VX-336's U6 stage
//  run, the runner's note 4: "Book Panel in Study: the open note's collapsed
//  chapter row shows no open-note marker (Terminal shows "›")").
//
//  VERIFIED REAL, by trace: the panel marks the open note with the voice's
//  selection glyph (`tokens.selectionMarker` — Terminal "› ", Study ""), and a
//  NOTE row also says it with its title's weight and ink (semibold + ink when
//  open, regular + muted when not) — "Study's empty marker leaves the weight
//  and the ink to say it". A COLLAPSED one-note chapter row IS its note's row
//  (row 8), but its name is ALWAYS semibold and in the accent: in Study the open
//  note's chapter row and every other chapter row were pixel-identical — no
//  glyph, no weight, no ink to say it.
//
//  The fix: one voice-tokened mark, decided by `BookPanelBrain.chapterRowMark`
//  — the voice's glyph where it has one (Terminal unchanged), else the
//  navigator's own "you are here" face for a chapter row (VX-562's viewed
//  chapter: the accent fill behind the row, the name in ink — PROVISIONAL
//  P-440-12, the face hers).
//
//  RED ON OLD, stated per pin: the seam commit drew every chapter row from
//  `chapterRowMark`, which then answered `.none` in Study — the pure pin's
//  Study leg and the mounted pin's Study leg fail there; the Terminal legs and
//  the not-the-open-note legs are guards, green on both sides.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private let markStamp = Date(timeIntervalSince1970: 1_782_864_000)

private func markSection(_ id: String, _ name: String) -> ReadingSection {
    ReadingSection(id: id, readingId: "b", name: name, position: "a",
                   createdAt: markStamp, updatedAt: markStamp)
}

private func markEntry(_ id: String, _ title: String) -> Queries.ReadingEntry {
    Queries.ReadingEntry(postID: id, title: title, entryDate: nil, sectionPath: nil)
}

@MainActor
@Suite("VX-356 — the open note's collapsed chapter row says so in both voices", .serialized)
struct BookPanelOpenNoteMarkTests {
    // MARK: - The decision (pure)

    @Test func theOpenNotesCollapsedChapterRowIsMarkedInEitherVoice() {
        let storm = markSection("s1", "The Storm")
        let open = markEntry("p1", "The Storm")
        let collapsed = BookPanelBrain.Line.chapter(storm, collapsed: open)
        // Study: no glyph — the chapter row wears the navigator's chapter mark.
        #expect(BookPanelBrain.chapterRowMark(collapsed, openPostID: "p1", selectionMarker: "") == .fill,
                "Study: the open note's collapsed chapter row is marked (VX-356)")
        // Terminal: the voice's glyph, unchanged.
        #expect(BookPanelBrain.chapterRowMark(collapsed, openPostID: "p1", selectionMarker: "\u{203A} ")
                == .glyph("\u{203A}"), "Terminal keeps its \u{203A}")
        // Guards — green on both sides: another note's chapter row, a plain
        // chapter heading, a note row and "unfiled" wear no chapter mark.
        for marker in ["", "\u{203A} "] {
            #expect(BookPanelBrain.chapterRowMark(collapsed, openPostID: "p2", selectionMarker: marker) == .none)
            #expect(BookPanelBrain.chapterRowMark(
                .chapter(storm, collapsed: nil), openPostID: "p1", selectionMarker: marker) == .none)
            #expect(BookPanelBrain.chapterRowMark(
                .note(open, indented: true), openPostID: "p1", selectionMarker: marker) == .none,
                "a note row says it its own way (glyph, weight, ink)")
            #expect(BookPanelBrain.chapterRowMark(.unfiled, openPostID: "p1", selectionMarker: marker) == .none)
        }
    }

    // MARK: - What the panel DRAWS (mounted, both voices)

    /// A book whose chapter "The Storm" holds one note named the same (row 8 —
    /// collapsed), the open note; a second chapter with two notes. Mounted in
    /// STUDY (a fresh store's voice, the theme store started), the collapsed
    /// row DRAWS the fill (red on old: `.none`); switched to Terminal, the ›.
    @Test func theMountedPanelMarksTheOpenNotesChapterRowInStudyAndTerminal() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // Live ids: the probe is keyed by chapter id and suites run in
            // parallel (`BookPanelDragGateTests`' reason).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(markStamp)
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 356))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let book = try ops.createReading(name: "Adventures", kind: .book)
            let storm = try ops.createSection(in: book.id, name: "The Storm")
            let calm = try ops.createSection(in: book.id, name: "Calm")
            let open = try ops.createPost(title: "The Storm")
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            for note in [open, a, b] { try ops.addPostToReading(note.id, to: book.id) }
            try ops.assignPostToSection(open.id, in: book.id, section: storm.id)
            try ops.assignPostToSection(a.id, in: book.id, section: calm.id)
            try ops.assignPostToSection(b.id, in: book.id, section: calm.id)

            let theme = ThemeStore(session: session)
            let themeTask = Task { await theme.start() }
            let membership = NoteMembershipModel()
            let model = BookPanelModel(session: session, postID: open.id)
            let track = Task { await membership.track(session: session, postID: open.id) }
            let contents = Task { await model.observe(bookID: book.id) }
            defer { themeTask.cancel(); track.cancel(); contents.cancel() }
            @MainActor func settle(_ condition: () -> Bool) async throws {
                for _ in 0..<300 {
                    if condition() { return }
                    try await Task.sleep(for: .milliseconds(10))
                }
                #expect(condition(), "condition never settled")
            }
            try await settle {
                model.snapshot(for: book.id)?.entries.count == 3
                    && membership.readings(for: open.id).count == 1
                    && theme.settings.voice == .study
            }

            #if DEBUG
            BookPanelMarkProbe.drawn[storm.id] = nil
            BookPanelMarkProbe.drawn[calm.id] = nil
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 340, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer { window.orderOut(nil); window.close() }
            let hosting = NSHostingView(rootView: BookPanelView(
                session: session, postID: open.id, membership: membership, model: model)
                .environment(theme))
            hosting.frame = NSRect(x: 0, y: 0, width: 340, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            @MainActor func pump() async {
                for _ in 0..<8 {
                    hosting.layoutSubtreeIfNeeded()
                    window.displayIfNeeded()
                    try? await Task.sleep(for: .milliseconds(30))
                }
            }
            await pump()
            #if DEBUG
            #expect(BookPanelMarkProbe.drawn[storm.id] == .fill,
                    "Study: the open note's collapsed chapter row is marked (drew \(String(describing: BookPanelMarkProbe.drawn[storm.id])))")
            #expect(BookPanelMarkProbe.drawn[calm.id] == BookPanelBrain.OpenNoteMark.none,
                    "a plain chapter heading wears no open-note mark")
            #endif

            // The same panel, Terminal: the voice's › — unchanged.
            try ops.setThemeVoice(.terminal)
            try await settle { theme.settings.voice == .terminal }
            await pump()
            #if DEBUG
            #expect(BookPanelMarkProbe.drawn[storm.id] == .glyph("\u{203A}"),
                    "Terminal: the \u{203A} (drew \(String(describing: BookPanelMarkProbe.drawn[storm.id])))")
            #endif
        }
    }
}
