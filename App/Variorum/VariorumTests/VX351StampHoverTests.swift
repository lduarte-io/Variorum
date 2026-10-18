//
//  VX351StampHoverTests.swift
//  VariorumTests
//
//  **VX-351 (the VX-348 run, U4) — the exact edit time past today, AS RULED.**
//  Her ask (2026-10-14): *"you should be able to see the actual time (with
//  hours) that you last edited something at even if it's in the past."* Her
//  rulings at the run's kickoff sitting: **R-VX348-1 "Hover everywhere"** (the
//  glances stay calm — today 1:33 AM · yesterday · Sep 9 — and every stamp
//  speaker gains the existing whole-fact hover) and **R-VX348-3 "All
//  speakers"** (the two gaps move onto `TimeStampFace` with hover; the
//  Timeline, the search answer sheet, the book's Arrivals and Archived lines
//  and the MCP grant picker gain the same hover).
//
//  RED ON OLD, every test in this file — each reads ONLY what the pre-fix tree
//  has (`LibraryPreview.note`'s `factsLine`, `NoteBoxCopy.stampsLine`,
//  `SidebarNoteBox`, `LibrarySearchLine`, `MCPActivityRowView`,
//  `TimeStampFace.stamp/relative/tooltip(_:date:)`):
//  · the info panel's facts line printed the RAW DAY KEY of the last MAJOR
//    revision (`edited 2025-03-02`) — a second wording rule and a second fact;
//  · the note box's stamps line was date-only (`edited Aug 29`, no time today);
//  · the note box, the answer sheet's commit line and the MCP Activity line
//    hovered nothing.
//  The hovers are read through the view's own COMPOSITION (the
//  `SurfaceComposition` road — `ProtectionSurfaceRenderTests`' header says why
//  `dump` and not the AX tree, which is empty in this environment): a `.help`
//  stores its words in the composed value, so a hover deleted from the face
//  turns these red. The hovers on rows drawn inside a `ForEach` (the Timeline,
//  the Arrivals and Archived lines, the pickers' rows, the Pool, Snippets,
//  Blocks, the Tray) cannot be reached this way: their WORDS are pinned in
//  `VX351HoverWordsTests.swift` (new API — fixed-only, removed from the red
//  product) and their faces are the walk's.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The whole fact as the PRE-FIX brain spells it — the subject tooltip minus
/// its verb — so a red-on-old pin needs no new API to know the words.
private func wholeFact(_ date: Date) -> String {
    let edited = TimeStampFace.tooltip(.edited, date: date)
    return String(edited.dropFirst("Edited ".count))
}

/// A FRAGMENT of a composed string, in the composition's own escaping
/// (`dump` escapes non-ASCII — the time's U+202F, the line's ·): the
/// fragment's escaped form, quotes dropped, is a substring of the whole
/// string's escaped form, wherever in it the fragment sits.
private func composes(_ fragment: String, in composition: String) -> Bool {
    let escaped = String(reflecting: fragment)
    return composition.contains(String(escaped.dropFirst().dropLast()))
}

/// One voice's light tokens (the hover is voice-blind; the words' case is not).
@MainActor
private func tokens(_ voice: ThemeVoice) -> VoiceTokens {
    voice == .terminal ? .terminalLight : .studyLight
}

@MainActor
@Suite("VX-351 — the two gaps speak the one stamp rule, and hover the whole fact", .serialized)
struct VX351StampGapsTests {
    private final class Clock: @unchecked Sendable {
        let now = LockIsolated(Date(timeIntervalSince1970: 1_740_909_600))  // 2025-03-02 10:00 UTC
        func set(_ date: Date) { now.setValue(date) }
        func read() -> Date { now.value }
    }

    /// **THE INFO PANEL'S FACTS LINE (gap 1).** A note committed on one day
    /// (its last MAJOR revision) and touched three days later: the panel says
    /// the row's own fact — the last touch — in the row's own words. On the
    /// pre-fix tree it printed `edited 2025-03-02`: the raw day key of the
    /// other stamp.
    @Test func thePanelSaysTheRowsEditStampInTheOneRule() async throws {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.read() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 351))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let post = try ops.createPost(title: "the panel's stamp")
            let minted = try ops.newBlock(in: post.id, text: "lanterns along the quay at dusk")
            _ = try ops.commit(minted.variant.id)  // the last MAJOR revision: Mar 2
            let touched = Date(timeIntervalSince1970: 1_741_188_600)  // 2025-03-05 15:30 UTC
            clock.set(touched)
            try ops.autosave(minted.variant.id, text: "lanterns along the quay at dusk.", charDelta: 1)

            let read = try await db.read { [id = post.id] db in try LibraryPreview.note(db, id: id) }
            let preview = try #require(read)
            let majorKey = JournalDay.dayString(from: Date(timeIntervalSince1970: 1_740_909_600))
            #expect(!preview.factsLine.contains(majorKey),
                    "the raw day key of the last major revision is gone: \(preview.factsLine)")
            let expected = "6 words \u{B7} 1 block \u{B7} "
                + TimeStampFace.stamp(.edited, date: touched, now: Date())
            #expect(preview.factsLine == expected,
                    "the List row's words, about the List row's fact: \(preview.factsLine)")
        }
    }

    /// **THE NOTE BOX'S STAMPS LINE (gap 2) — its words.** Edited today and
    /// committed two days back: the glance rule's own words, the time today
    /// and the day past it. Pre-fix: `edited Aug 29 · saved Aug 27`.
    @Test func theNoteBoxsLineSpeaksTheGlanceRule() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let locale = Locale(identifier: "en_US")
        let now = Date(timeIntervalSince1970: 1_788_000_000)          // 2026-08-29 10:40 UTC
        let edited = now.addingTimeInterval(-600)
        let saved = Date(timeIntervalSince1970: 1_787_800_000)        // 2026-08-27
        let line = NoteBoxCopy.stampsLine(
            edited: edited, saved: saved, now: now, calendar: calendar, locale: locale)
        let expected = TimeStampFace.stamp(.edited, date: edited, now: now, calendar: calendar, locale: locale)
            + " \u{B7} saved "
            + TimeStampFace.relative(saved, now: now, calendar: calendar, locale: locale)
        #expect(line == expected, "\(line ?? "nil")")
        #expect(line?.hasPrefix("edited today 10:30") == true, "today carries its time: \(line ?? "nil")")
    }

    /// **THE NOTE BOX'S HOVER — both facts whole.** The box composed in its
    /// selected state over the two stamps: its composition carries each
    /// stamp's whole fact (the year and the minute). Pre-fix: no hover at all.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theNoteBoxHoversBothFactsWhole(voice: ThemeVoice) async {
        let edited = Date(timeIntervalSince1970: 1_788_000_000)
        let saved = Date(timeIntervalSince1970: 1_787_800_000)
        let tokens = tokens(voice)
        let box = SidebarNoteBox(
            tokens: tokens, subjectKey: "vx351-box-\(voice)", state: .selected("vx351-note"),
            identity: NoteBoxIdentity(postID: "vx351-note", title: "VX351 box", index: 2, total: 9),
            facts: NoteBoxFacts(words: 12, blocks: 2, fannedBlocks: 0, editedAt: edited, savedAt: saved),
            caretLabel: nil, now: edited)
        await SurfaceComposition.host(box, size: NSSize(width: 230, height: 260))
        let composed = SurfaceComposition.text(of: box.body)
        #expect(SurfaceComposition.carries(
            tokens.chromeLabel(NoteBoxCopy.stampsLine(edited: edited, saved: saved, now: edited) ?? "?"),
            in: composed),
            "the line is composed (the premise)")
        #expect(composes(wholeFact(edited), in: composed), "the edit's whole fact hovers the line")
        #expect(composes(wholeFact(saved), in: composed), "the commit's whole fact hovers the line")
    }
}

@MainActor
@Suite("VX-351 W2-1 — the BOOK's note box hovers its stamps in every state that draws them", .serialized)
struct VX351BookBoxStampsTests {
    /// **The walk's W2-1, as a pin.** The sidebar note box is the BOOK's box
    /// (`RootView.noteBoxView` builds `SidebarNoteBox` for every book mode —
    /// there is no second box and no second stamps-line composer:
    /// `NoteBoxCopy.stampsLine` has ONE caller, `factsBlock`). It draws the
    /// stamps line in exactly two states: SELECTED (a note the book points
    /// at — Outline's focus, Index's selection, the spread's page) and LIVE
    /// WITHOUT A BAR (Index: its liveness is one block's pane, never a full
    /// editor, so the facts stay where Outline's and the spread's live box
    /// show the bar). Both compose the line's words AND its whole-fact hover;
    /// a stamp from another YEAR (the seeded classics are stamped 1892 — the
    /// seeder's own clock, m6) spells its year in both.
    /// Pre-fix: the words, no hover — RED on old in all four cases.
    @Test(arguments: [(ThemeVoice.terminal, false), (.study, false), (.terminal, true), (.study, true)])
    func theBookBoxHoversItsStampsWhereverItDrawsThem(voice: ThemeVoice, indexLive: Bool) async throws {
        let edited = try #require(DateFormatter.variorumISO8601.date(from: "1892-10-14T00:00:00.000Z"))
        let saved = Date(timeIntervalSince1970: 1_791_720_000)          // 2026-10-11 12:00 UTC
        let now = Date(timeIntervalSince1970: 1_792_324_800)            // 2026-10-18 12:00 UTC
        let tokens = tokens(voice)
        let note = "vx351-sherlock"
        let box = SidebarNoteBox(
            tokens: tokens, subjectKey: "vx351-book-\(voice)-\(indexLive)",
            state: indexLive ? .live(note) : .selected(note),
            identity: NoteBoxIdentity(postID: note, title: "A Scandal in Bohemia", index: 1, total: 13),
            facts: NoteBoxFacts(words: 8_500, blocks: 120, fannedBlocks: 0, editedAt: edited, savedAt: saved),
            caretLabel: nil, now: now)
        await SurfaceComposition.host(box, size: NSSize(width: 230, height: 260))
        let composed = SurfaceComposition.text(of: box.body)
        let words = try #require(NoteBoxCopy.stampsLine(edited: edited, saved: saved, now: now))
        #expect(SurfaceComposition.carries(tokens.chromeLabel(words), in: composed),
                "the premise: the box draws the stamps line in this state (\(words))")
        #expect(composes(wholeFact(edited), in: composed), "the edit's whole fact (its year and minute) hovers the line")
        #expect(composes(wholeFact(saved), in: composed), "the commit's whole fact hovers the line")
    }
}

@MainActor
@Suite("VX-351 — the named speakers composed with their hover", .serialized)
struct VX351SpeakerHoverCompositionTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(7) }
                return value
            }
        }
    }

    /// **THE SEARCH ANSWER SHEET'S COMMIT LINE** (`commit · Jul 1`): the line
    /// composed over a REAL savepoint passage (the `+ commits` facet's own
    /// road) carries the commit's whole fact. Pre-fix: no hover.
    @Test func theAnswerSheetsCommitLineHoversItsWholeFact() async throws {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3511))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "vx351-commit-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let ops = session.operations
            let post = try ops.createPost(title: "Harbor Log")
            let minted = try ops.newBlock(in: post.id, text: "lanterns along the quay")
            _ = try ops.commit(minted.variant.id)
            try ops.autosave(minted.variant.id, text: "the take moved on entirely", charDelta: 20)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            model.query = "lanterns"
            model.toggleSavepointsFacet()
            await model.search()
            let passage = try #require(model.searchState.groups.flatMap(\.lines).first)
            #expect(passage.kind == .savepoint, "the premise: a savepoint passage")
            let saved = try #require(passage.savedAt.flatMap { DateFormatter.variorumISO8601.date(from: $0) })

            let line = LibrarySearchLine(
                tokens: VoiceTokens.fallback(for: .light), passage: passage, onOpen: {})
            await SurfaceComposition.host(line, size: NSSize(width: 520, height: 40))
            let composed = SurfaceComposition.text(of: line.body)
            #expect(composes(wholeFact(saved), in: composed), "the commit's whole fact hovers its line")
        }
    }

    /// **THE MCP ACTIVITY LINE** ("39 seconds ago"): the AI's act on her
    /// writing hovers its whole fact. Pre-fix: no hover.
    @Test func theActivityLineHoversItsWholeFact() async throws {
        let at = Date(timeIntervalSince1970: 1_782_864_000)
        let stamp = DateFormatter.variorumISO8601.string(from: at)
        let line = MCPActivityRowView(line: MCPActivityFace.Line(
            id: 1, clientName: "codex", act: "edit_take", targetKind: "note", targetID: "n1",
            targetTitle: "Harbor Log", allowed: true, count: 1, at: stamp))
        await SurfaceComposition.host(line, size: NSSize(width: 520, height: 40))
        let composed = SurfaceComposition.text(of: line.body)
        #expect(composes(wholeFact(at), in: composed), "the act's whole fact hovers its line")
    }
}

