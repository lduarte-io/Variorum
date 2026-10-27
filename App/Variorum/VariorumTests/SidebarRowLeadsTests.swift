//
//  SidebarRowLeadsTests.swift
//  VariorumTests
//
//  **VX-580 (the VX-439 run, A-439-11) — the sidebar's untitled notes lead
//  with their own first words, by default.** Her note (2026-10-21): *"I NEED
//  to make showing a preliminary title on the lefthand bar the default."* The
//  words are the LIBRARY's one brain's (`NoteCardFace` over the card's own
//  opening window — read FLAT since the ladder's M-1, `Queries.leadingBlockTexts`),
//  for exactly the notes the Library leads with words (no name of their own,
//  not a daily entry), display-only.
//
//  Pins: the derivation on a store (which notes, which words — the Library's
//  rule, a markdown heading rendered, a long opening capped at a word edge);
//  the wiring, read (the Open row's title, its chip and Starred's notes all
//  read the one answer; the read is HELD and bounded by the rows); and the row
//  as DRAWN in a mounted column, following her typing live. A guard holds what
//  must NOT change: what a note is CALLED elsewhere (`readTitles` — the pane
//  line, the back chip, the View menu's Open Note rows) stays its date.
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
@Suite("VX-580 — the sidebar's untitled notes show their first words", .serialized)
struct SidebarRowLeadsTests {
    // MARK: - The derivation

    /// **The rule and the words — the Library's, exactly.** An untitled note
    /// with words leads with them (a heading rendered, not printed); a titled
    /// note, a daily entry and a note with no words have no lead (their rows
    /// keep the name they already had); a long opening is capped at a word
    /// edge with the brain's own cap.
    @Test func onlyAnUntitledNonJournalNoteWithWordsLeadsAndWithTheLibrarysWords() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let heading = try ops.createPost()
            _ = try ops.newBlock(in: heading.id, text: "# Garden plans\nbeds by the fence")
            let titled = try ops.createPost(title: "Kept")
            _ = try ops.newBlock(in: titled.id, text: "words under a name")
            let journal = try ops.createPost(profile: .journal, entryDate: "2026-10-27")
            _ = try ops.newBlock(in: journal.id, text: "today I walked")
            let empty = try ops.createPost()
            let long = try ops.createPost()
            let sentence = String(repeating: "lantern ", count: 20)
            _ = try ops.newBlock(in: long.id, text: sentence)
            let leads = try await db.read { db in
                try SidebarRowLeads.read(
                    db, noteIDs: [heading.id, titled.id, journal.id, empty.id, long.id])
            }
            #expect(leads[heading.id] == "Garden plans", "a heading is the note's name, rendered")
            #expect(leads[titled.id] == nil, "a name she typed is the row's name")
            #expect(leads[journal.id] == nil, "a daily entry's day is its identity")
            #expect(leads[empty.id] == nil, "no words: the row keeps its day")
            let capped = try #require(leads[long.id])
            #expect(capped.count <= NoteCardFace.leadCap + 1 && capped.hasPrefix("lantern lantern"),
                    "capped by the brain's own cap, at a word edge: \(capped)")
            // The Library's brain says exactly the same for the same facts.
            let library = NoteCardFace.card(storedTitle: nil, leadingTexts: [sentence])
            #expect(library.lead == .words(capped), "one brain, one answer: \(library.lead)")
            #expect(try await db.read { try SidebarRowLeads.read($0, noteIDs: []) }.isEmpty)
        }
    }

    /// **THE P1 PIN (VX-439 ladder round 1, M-1) — RED ON OLD.** The read is
    /// HELD (the column observes it, and every autosave stamps `container`,
    /// so it re-runs at typing rate), so its words must be read FLAT in the
    /// note's length: one bounded, index-ordered seek per untitled note,
    /// stopped by a `LIMIT` — never a window function over the note's whole
    /// placement list. The old read went through `NoteCards.load`, whose
    /// `ROW_NUMBER() OVER (PARTITION BY …) … WHERE n <= 3` materializes EVERY
    /// block of the note before its filter (the reviewer measured 0.2 ms at 3
    /// blocks, 36 ms at 20,000 — linear, at autosave rate). Shape facts, never
    /// a stopwatch (`LeadingBlockTextsTests`' rule): the statements the read
    /// issues, as traced, and each words statement's plan.
    @Test func theReadsWordsAreBoundedSeeksNeverAWindowOverTheWholeNote() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let long = try ops.createPost()
            for i in 0..<40 { _ = try ops.newBlock(in: long.id, text: "line \(i)", registeringUndo: false) }
            let titled = try ops.createPost(title: "Kept")
            _ = try ops.newBlock(in: titled.id, text: "words under a name", registeringUndo: false)
            let traced = LockIsolated<[String]>([])
            let leads = try await db.read { database in
                database.trace(options: .statement) { event in
                    guard case .statement(let statement) = event else { return }
                    let sql = statement.expandedSQL
                    traced.withValue { $0.append(sql) }
                }
                defer { database.trace(options: .statement, nil) }
                return try SidebarRowLeads.read(database, noteIDs: [long.id, titled.id])
            }
            #expect(leads[long.id] == "line 0", "the untitled note leads with its first words: \(leads)")
            #expect(leads[titled.id] == nil)
            let words = traced.value.filter {
                $0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("SELECT")
                    && $0.contains("container_block")
            }
            #expect(words.count == 1, "one words statement — the untitled note's; a named note reads none: \(words)")
            for sql in words {
                #expect(!sql.contains("OVER ("), "no window over the note's placements: \(sql)")
                #expect(sql.contains("LIMIT"), "the words stop at their bound: \(sql)")
                let plan = try await db.read { database in
                    try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                        .map { ($0["detail"] as String?) ?? "" }
                        .joined(separator: "\n")
                }
                #expect(plan.contains("SEARCH cb USING INDEX idx_cblock_order"),
                        "the placements are SEEKED by the ordered index: \(plan)")
                #expect(!plan.contains("SCAN cb") && !plan.contains("USE TEMP B-TREE FOR ORDER BY"),
                        "never a scan, never a full sort of the note's placements: \(plan)")
            }
        }
    }

    /// **A GUARD — what a note is CALLED elsewhere is untouched.** The
    /// workspace's names (the pane line, the back chip, the View menu's Open
    /// Note rows) are `DisplayTitle`'s: an untitled note's is still its date.
    /// Green on both sides by design.
    @Test func whatANoteIsCalledElsewhereIsStillItsDisplayName() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let note = try ops.createPost(entryDate: "2026-10-27")
            _ = try ops.newBlock(in: note.id, text: "Garden plans")
            let names = try await db.read { db in
                try WorkspaceModel.readTitles(db, subjects: [.post(note.id)])
            }
            let shown = try #require(names[note.id])
            #expect(shown != "Garden plans" && !shown.isEmpty, "the chrome's name is its date: \(shown)")
        }
    }

    // MARK: - The wiring, read

    @Test func everySidebarNoteRowReadsTheOneLeadThroughAHeldBoundedRead() throws {
        let sidebar = try String(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
                .appending(path: "Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        let start = try #require(sidebar.range(of: "private func openRow("))
        let row = String(sidebar[start.upperBound...].prefix(8_000))
        #expect(row.contains("text: tokens.chromeLabel(noteRowLabel(noteID))"), "the Open row's title")
        #expect(row.contains("Self.openRowChip(noteRowLabel(noteID), tokens: tokens)"), "its drag chip")
        #expect(sidebar.contains("text: tokens.chromeLabel(starredRowLabel(item, destination: destination))"),
                "Starred's rows")
        #expect(sidebar.contains("rowLeads[noteID] ?? workspace.label(for: .post(noteID))"),
                "the lead, else the name every surface gives it")
        let task = try #require(sidebar.range(of: ".task(id: noteRowIDs) {"), "keyed on the rows (bounded)")
        let held = String(sidebar[task.upperBound...].prefix(400))
        #expect(held.contains("session.database.observe(") && held.contains("SidebarRowLeads.read(db, noteIDs: ids)"),
                "HELD — her typing renames the row")
    }

    // MARK: - As drawn

    /// **The row as DRAWN** — a mounted column: an untitled note's Open row is
    /// called by its first words, a named note's by its name; and as she types
    /// the opening changes, the row follows (the held read).
    @Test func theOpenRowDrawsTheFirstWordsAndFollowsHerTyping() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let untitled = try ops.createPost()
            let block = try ops.newBlock(in: untitled.id, text: "Garden plans for spring")
            let titled = try ops.createPost(title: "Kept")
            let workspace = WorkspaceModel()
            workspace.visit(.post(untitled.id))
            workspace.visit(.post(titled.id))
            workspace.select(.library)
            let stars = StarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let theme = ThemeStore(session: session)
            SidebarGeometry.forgetSections(for: workspace)
            defer { SidebarGeometry.forgetSections(for: workspace) }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 230, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: SidebarView(
                session: session, model: LibraryViewModel(session: session),
                pool: PoolViewModel(session: session), workspace: workspace, stars: stars,
                selection: Binding(
                    get: { workspace.selections[workspace.focusedPane] },
                    set: { picked in if let picked { workspace.select(picked) } }))
                .frame(width: 230)
                .environment(theme))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let key = SidebarGeometry.bodyKey(for: workspace)
            @MainActor func labels() -> [String: String] { SidebarGeometry.openRowLabels[key] ?? [:] }
            #expect(await poll { labels()[untitled.id] == "Garden plans for spring" },
                    "the untitled row is called by its first words: \(labels())")
            #expect(await poll { labels()[titled.id] == "Kept" }, "a named row keeps its name: \(labels())")
            try ops.autosave(block.variant.id, text: "Seed list", charDelta: -14)
            #expect(await poll { labels()[untitled.id] == "Seed list" },
                    "the row follows her typing: \(labels())")
            _ = db
        }
    }

    // MARK: - Rig

    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
    }

    private func poll(_ condition: () -> Bool) async -> Bool {
        for _ in 0..<300 {
            if condition() { return true }
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    private func withWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            // The LIVE generator: the oracle keys must not collide with a
            // parallel suite's (the DEBUG-oracle keying rule).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 580))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }
}
