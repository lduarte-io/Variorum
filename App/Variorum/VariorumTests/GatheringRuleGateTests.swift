//
//  GatheringRuleGateTests.swift
//  VariorumTests
//
//  13i-c U3 — R-13ic-4's FACES (her kickoff ruling: "refuse, offer delete";
//  "Trash them at migration; NULL = shows nothing"; her post-close ruling 1:
//  the mint door requires a rule). What is pinned:
//  - the empty state's re-word (F-U1-3): a rule-less gathering "shows
//    nothing until it has one";
//  - the GATE: removing a gathering's last term disables Save with "A
//    gathering needs a rule." and offers "Delete this gathering…" — while a
//    BOOK's clear stays legal (the kill switch); a Trash restoree (stored
//    NULL) opens gated too;
//  - the gate's Trash door: the ordinary road, confirmed, landing in the
//    Trash with no note touched;
//  - THE MINT (F-U1-2): the mint sheet's Create is disabled until a term
//    exists; it mints WITH the rule; a taken name refuses and keeps.
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
private func withGateWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 37))
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

@MainActor
private func mounted<V: View>(_ view: V, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 640),
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
private func editor(_ session: AppSession, _ readingID: String) async -> RuleEditorModel {
    let model = RuleEditorModel(session: session, readingID: readingID)
    await model.load()
    return model
}

@MainActor
@Suite("R-13ic-4's faces — the gathering gate and the mint (13i-c U3)", .serialized)
struct GatheringRuleGateTests {
    @Test func theEmptyStateSaysARuleLessGatheringShowsNothing() {
        // F-U1-3: the "shows every note" letter died at U1 (R-13ic-4).
        #expect(RuleEditorCopy.noRuleGathering
                == "No rule \u{2014} this gathering shows nothing until it has one.")
        #expect(!RuleEditorCopy.noRuleGathering.contains("every note"))
        #expect(RuleEditorCopy.gatheringNeedsRule == "A gathering needs a rule.")
        #expect(BookStateCopy.deleteGatheringDoor == "Delete this gathering\u{2026}")
    }

    /// Removing the last term of a GATHERING's rule: Save disables with the
    /// words, and the Trash door is offered in its place.
    @Test func removingAGatheringsLastTermGatesSaveAndOffersDelete() async throws {
        try await withGateWorld { session, _ in
            let work = try session.operations.createTag(name: "work")
            let gathering = try session.operations.createReading(
                name: "Work", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(work.id)))
            RuleEditorProbe.reset()
            let model = await editor(session, gathering.id)
            try await mounted(RuleEditorSheet(model: model)) {
                #expect(RuleEditorProbe.drawn[gathering.id]?.gate == nil)
                model.remove(try #require(model.rows.first))
                await settle(until: { RuleEditorProbe.drawn[gathering.id]?.gate != nil })
                let drawn = try #require(RuleEditorProbe.drawn[gathering.id])
                #expect(model.isDirty, "she changed something")
                #expect(!model.canSave && drawn.saveEnabled == false, "but Save is gated")
                #expect(drawn.gate == "A gathering needs a rule.")
                #expect(drawn.gateDoor == "Delete this gathering\u{2026}")
            }
        }
    }

    /// A BOOK's clear stays legal — the kill switch (13i-b's morning sitting).
    @Test func aBooksClearIsNotGated() async throws {
        try await withGateWorld { session, _ in
            let work = try session.operations.createTag(name: "work")
            let book = try session.operations.createReading(
                name: "Living", kind: .book, querySpec: try RuleGrammar.encode(.tag(work.id)))
            let model = await editor(session, book.id)
            model.remove(try #require(model.rows.first))
            #expect(!model.gatheringNeedsRule)
            #expect(model.canSave)
        }
    }

    /// A Trash RESTOREE (stored NULL — the one way a rule-less gathering is
    /// live) opens already gated, its empty state saying it shows nothing.
    @Test func aRuleLessRestoreeOpensGated() async throws {
        try await withGateWorld { session, db in
            let work = try session.operations.createTag(name: "work")
            let gathering = try session.operations.createReading(
                name: "Bare", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(work.id)))
            try await db.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = NULL WHERE id = ?",
                               arguments: [gathering.id])
            }
            RuleEditorProbe.reset()
            let model = await editor(session, gathering.id)
            #expect(model.gatheringNeedsRule)
            #expect(!model.canSave)
            try await mounted(RuleEditorSheet(model: model)) {
                #expect(RuleEditorProbe.drawn[gathering.id]?.gate == RuleEditorCopy.gatheringNeedsRule)
            }
        }
    }

    /// The gate's Trash door: the confirm names the Trash and promises no
    /// note is touched; confirming sends the gathering there.
    @Test func theGatesDeleteDoorConfirmsAndSendsTheGatheringToTheTrash() async throws {
        try await withGateWorld { session, db in
            let work = try session.operations.createTag(name: "work")
            let gathering = try session.operations.createReading(
                name: "Work", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(work.id)))
            let note = try session.operations.createPost(title: "tagged")
            _ = try session.operations.applyTag(work.id, toPost: note.id)
            let model = await editor(session, gathering.id)
            model.remove(try #require(model.rows.first))

            await model.stateDoors.open(.deleteBook, readingID: gathering.id)
            let asked = try #require(model.stateDoors.pending)
            #expect(asked == BookStateCopy.deleteGathering(readingID: gathering.id, name: "Work"))
            #expect(asked.lines.contains("No note is touched: a gathering holds none."))
            await model.stateDoors.confirm()

            #expect(try await db.read { try Queries.reading($0, id: gathering.id) } == nil)
            // The world's clock, not the wall's: the Trash window is 30 days
            // back from `now`, and this world's stamps start at its `start`.
            let worldNow = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)
            let trash = try await db.read { try Queries.trash($0, now: worldNow, kinds: [.book]) }
            #expect(trash.map(\.id).contains(gathering.id), "the ordinary Trash road")
            #expect(try await db.read {
                try Queries.containerHeader($0, containerID: note.id)
            } != nil, "no note touched")
            #expect(session.status.spoken?.text == BookStateCopy.deleted("Work"))
        }
    }

    // MARK: - The mint

    @Test func theMintSheetGatesCreateUntilATermExists() async throws {
        try await withGateWorld { session, _ in
            let work = try session.operations.createTag(name: "work")
            let readings = ReadingsViewModel(session: session)
            let model = RuleEditorModel(session: session, mintingIn: "")
            await model.load()
            #expect(model.tags.map(\.id) == [work.id], "the wing's live tags are offered")
            MintGatheringProbe.drawn = nil
            try await mounted(MintGatheringSheet(model: model, readings: readings)) {
                let empty = try #require(MintGatheringProbe.drawn)
                // 13i-d U6 (a), a JUSTIFIED EDIT: the gathering mint's words —
                // "smart" is retired app-wide (the sitting record §14).
                #expect(empty.title == "Create Gathering")
                #expect(empty.createEnabled == false, "no term — no Create")
                #expect(empty.emptyNotice == RuleEditorCopy.mintEmpty)
                model.add(.tag(work.id), into: nil)
                await settle(until: { MintGatheringProbe.drawn?.createEnabled == true })
                #expect(MintGatheringProbe.drawn?.createEnabled == true)
            }
        }
    }

    @Test func theMintMakesAGatheringWithItsRuleAndATakenNameRefusesAndKeeps() async throws {
        try await withGateWorld { session, db in
            let work = try session.operations.createTag(name: "work")
            _ = try session.operations.createReading(name: "Taken", kind: .book)
            let readings = ReadingsViewModel(session: session)
            let model = RuleEditorModel(session: session, mintingIn: "")
            await model.load()
            model.mintName = "Work notes"
            #expect(await model.mint(through: readings) == nil, "no term — nothing minted")
            #expect(try await db.read { try Queries.readings($0) }.count == 1)

            model.add(.tag(work.id), into: nil)
            model.mintName = "Taken"
            #expect(await model.mint(through: readings) == nil)
            #expect(readings.lastError == BookNameCopy.refusal(existing: "Taken"),
                    "a taken name refuses (E13) — the sheet keeps her draft")
            #expect(model.mintSpec != nil)

            model.mintName = "Work notes"
            let id = try #require(await model.mint(through: readings))
            let made = try #require(try await db.read { try Queries.reading($0, id: id) })
            #expect(made.kind == .gathering)
            #expect(made.name == "Work notes")
            #expect(RuleGrammar.decode(made.querySpec) == .tag(work.id), "minted WITH its rule")
        }
    }
}
