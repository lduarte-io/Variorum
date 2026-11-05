//
//  TagSweepTests.swift
//  VariorumTests (Mac)
//
//  VX-840 (the VX-828 run, batch E) — Settings ▸ Tags' door to delete every
//  tag no note wears. Her ask (2026-11-04): *"file a ticket to be able to
//  delete every tag that's not on a note currently please"*. The fork's ruling
//  (`notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch E — THE FORK'S
//  RULING"): Q-E3 (i) every unused tag listed checked with LINKED boxes, Q-E4
//  (a) the counted door not drawn at zero, P-828-4 ONE "Delete Unused Tags"
//  entry; the words PROVISIONAL.
//
//  The listing and the act are pinned core-side, exact rows
//  (`UnusedTagsTests`); these pin the pane's half — the boxes' subtree rule,
//  the door's visibility and words, the declaration, and the model's road
//  through the session (its observation, its act, its one undo entry).
//
//  An Improvement: the old tree had no door, so these are red on old by
//  construction.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withSweepWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 840))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-840 — Settings ▸ Tags' unused-tags sweep (the pane's half)", .serialized)
struct TagSweepTests {
    // MARK: - The linked boxes (Q-E3 (i))

    private typealias Row = UnusedTagSelection.Row

    /// Home's `a`, `b ⊃ b/c ⊃ b/c/d`, `e`; and another wing's same-path `b/x`
    /// (another library's vocabulary — never under Home's `b`).
    private static let rows: [Row] = [
        Row(id: "a", name: "a", path: "a", wingID: ""),
        Row(id: "b", name: "b", path: "b", wingID: ""),
        Row(id: "bc", name: "c", path: "b/c", wingID: ""),
        Row(id: "bcd", name: "d", path: "b/c/d", wingID: ""),
        Row(id: "bx", name: "x", path: "b/x", wingID: "far"),
        Row(id: "e", name: "e", path: "e", wingID: ""),
    ]

    @Test func everyListedTagStartsChecked() {
        let selection = UnusedTagSelection(rows: Self.rows)
        #expect(selection.checkedIDs == ["a", "b", "bc", "bcd", "bx", "e"])
        #expect(selection.checkedCount == 6)
        #expect(Self.rows[3].depth == 2, "b/c/d indents twice")
    }

    /// Unchecking a tag unchecks its listed ANCESTORS (their delete would take
    /// it); checking a tag checks everything listed UNDER it. Another wing's
    /// same-path tag is never "under".
    @Test func theBoxesCarryTheSubtreeRule() {
        var selection = UnusedTagSelection(rows: Self.rows)
        selection.toggle("bcd")
        #expect(selection.checkedIDs == ["a", "bx", "e"],
                "keeping b/c/d keeps b/c and b; Far's b/x is not under Home's b")
        selection.toggle("b")
        #expect(selection.checkedIDs == ["a", "b", "bc", "bcd", "bx", "e"],
                "checking b checks its whole listed subtree")
        selection.toggle("bc")
        #expect(selection.checkedIDs == ["a", "bcd", "bx", "e"], "b/c off takes b off; b/c/d stays")
        selection.toggle("nope")
        #expect(selection.checkedIDs == ["a", "bcd", "bx", "e"], "an unknown id changes nothing")
    }

    /// Whatever she clicks, a checked tag's listed subtree stays wholly
    /// checked — so the act deletes exactly what the boxes show.
    @Test func noClickSequenceEverChecksATagWithoutItsSubtree() {
        var selection = UnusedTagSelection(rows: Self.rows)
        let clicks = ["a", "bcd", "b", "bc", "e", "bcd", "b", "bx", "bc", "b", "bcd", "bcd", "a"]
        for click in clicks {
            selection.toggle(click)
            for parent in Self.rows where selection.isChecked(parent.id) {
                for child in Self.rows where UnusedTagSelection.isAncestor(parent, of: child) {
                    #expect(selection.isChecked(child.id),
                            "after \(click): \(parent.path) is checked, so \(child.path) must be")
                }
            }
        }
    }

    // MARK: - The door and its words (Q-E4 (a); PROVISIONAL)

    @Test func theDoorIsDrawnOnlyWhileItCouldActAndCountsWhatItLists() {
        #expect(!TagManagerPane.showsSweepDoor(unusedCount: 0), "count 0 ⇒ not rendered (P-2)")
        #expect(TagManagerPane.showsSweepDoor(unusedCount: 1))
        #expect(TagManagerCopy.doorLabel(count: 1) == "Delete 1 unused tag\u{2026}")
        #expect(TagManagerCopy.doorLabel(count: 3) == "Delete 3 unused tags\u{2026}")
        #expect(TagManagerCopy.confirmVerb(count: 1) == "Delete 1 Tag")
        #expect(TagManagerCopy.confirmVerb(count: 3) == "Delete 3 Tags")
        #expect(TagManagerCopy.sheetTitle(wingName: "Home") == "Unused tags in Home")
    }

    /// The pane speaks what really went: a receipt counting it, the race's
    /// refusal when nothing was left, nothing of its own when the act threw
    /// (the model's error line speaks then).
    @Test func theLineSaysWhatReallyWent() {
        #expect(TagManagerPane.sweepLine(taken: 3)
                == .receipt("Deleted 3 unused tags \u{2014} \u{2325}\u{2318}Z puts them back."))
        #expect(TagManagerPane.sweepLine(taken: 1)
                == .receipt("Deleted 1 unused tag \u{2014} \u{2325}\u{2318}Z puts it back."))
        #expect(TagManagerPane.sweepLine(taken: 0)
                == .refusal("None of those tags are unused any more \u{2014} nothing was deleted."))
        #expect(TagManagerPane.sweepLine(taken: nil) == nil)
    }

    @Test func theSweepIsDeclaredOnThePaneItLivesOn() {
        let sweep = CapabilityRegistry.capability(.deleteUnusedTags)
        #expect(sweep.verb == "Delete Unused Tags")
        #expect(sweep.verb == Operations.deleteUnusedTagsUndoLabel, "the door and its ⌥⌘Z entry say one thing")
        #expect(sweep.doors == [.surface] && sweep.scope == .app)
        #expect(sweep.unavailableNote == TagManagerCopy.nothingLeftToDelete)
        #expect(TagManagerPane.surfaceCapabilities.contains(.deleteUnusedTags))
    }

    // MARK: - The model's road (the session's runner and undo stack)

    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private func settle(until condition: () -> Bool, turns: Int = 150) async {
        for _ in 0..<turns {
            if condition() { return }
            pump()
            await Task.yield()
        }
    }

    /// The model lists the CURRENT wing's unused tags live, its act takes the
    /// checked ones as ONE "Delete Unused Tags" entry on the session's stack
    /// (⌥⌘Z's), and the list empties; a press whose tags were all worn by then
    /// answers 0 — the refusal — with nothing written.
    @Test func theModelListsActsAndRegistersOneEntry() async throws {
        try await withSweepWorld { session, db in
            let ops = session.operations
            let idle = try ops.createTag(name: "idle")
            let old = try ops.createTag(name: "old")
            let older = try ops.createTag(parent: old.id, name: "older")
            let worn = try ops.createTag(name: "worn")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(worn.id, toPost: note.id)
            session.undoStack.removeAll()

            let model = TagsViewModel(session: session)
            let run = Task { await model.startUnused() }
            defer { run.cancel() }
            await settle(until: { model.unused.count == 3 })
            #expect(model.unused.map(\.path) == ["idle", "old", "old/older"])

            let selection = TagManagerPane.selection(for: model.unused)
            let taken = await model.deleteUnusedTags(selection.checkedIDs)
            #expect(taken == 3)
            #expect(session.undoStack.depth == 1)
            #expect(session.undoStack.topLabel == "Delete Unused Tags")
            await settle(until: { model.unused.isEmpty })
            #expect(model.unused.isEmpty, "the list empties when they go")
            let live = try await db.read {
                try String.fetchAll($0, sql: "SELECT path FROM tag WHERE deleted_at IS NULL")
            }
            #expect(live == ["worn"])

            // The race: the sheet named `worn`… which a note wears.
            let raced = await model.deleteUnusedTags([worn.id])
            #expect(raced == 0, "nothing left — the refusal's answer")
            #expect(session.undoStack.depth == 1, "no entry for an act that did nothing")
            _ = idle; _ = older
        }
    }
}
