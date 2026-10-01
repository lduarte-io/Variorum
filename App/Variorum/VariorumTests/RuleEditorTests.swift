//
//  RuleEditorTests.swift
//  VariorumTests
//
//  13i-b U3 — the rule editor's face (the plan §4 item 1): what the mounted
//  sheet DRAWS for each shape the grammar offers, what its add doors OFFER
//  (never a legacy term), what a save WRITES (exactly the tree, nothing on
//  an unedited save, never a malformed rule), and a book's Collecting rows —
//  the join dial, the auto-tag row and its "also tag the N current members"
//  offer, and a rule edit's gap arriving at the door (U2's line).
//
//  The brain's own property pins (every edit touches only its node, legacy
//  never removable through any parent) are core's `RuleEditingTests`.
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
private func withEditorWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
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

/// Mounts the sheet in a real window for the body of `run`, the model
/// already loaded (hosted `.task` callbacks don't fire under this host).
@MainActor
private func mounted(_ model: RuleEditorModel, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 640),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: RuleEditorSheet(model: model))
    window.orderFrontRegardless()
    await settle()
    try await run()
}

/// The drawn rows, in a stable reading order (depth-first is the sheet's;
/// the probe is keyed, so sort by the words and depth for comparison).
@MainActor
private func drawnRows(_ readingID: String) -> [RuleEditorProbe.DrawnRow] {
    (RuleEditorProbe.drawn[readingID]?.rows.values.map { $0 } ?? [])
        .sorted { ($0.depth, $0.words) < ($1.depth, $1.words) }
}

@MainActor
@Suite("The rule editor's face (13i-b U3)", .serialized)
struct RuleEditorTests {
    /// The tags `#work`, `#work/ideas` and `#life` in Home, and `#elsewhere`
    /// in ANOTHER wing (direct rows — no door mints a second wing's tag yet).
    private func vocabulary(_ session: AppSession, _ db: AppDatabase) throws
        -> (work: VariorumCore.Tag, ideas: VariorumCore.Tag, life: VariorumCore.Tag, elsewhereID: String)
    {
        let ops = session.operations
        let work = try ops.createTag(name: "work")
        let ideas = try ops.createTag(parent: work.id, name: "ideas")
        let life = try ops.createTag(name: "life")
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO tag (id, name, path, wing_id, created_at, updated_at)
                VALUES ('tag-elsewhere', 'elsewhere', 'elsewhere', 'wing-2',
                        '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')
                """)
        }
        return (work, ideas, life, "tag-elsewhere")
    }

    private func editor(
        _ session: AppSession, _ readingID: String
    ) async -> RuleEditorModel {
        let model = RuleEditorModel(session: session, readingID: readingID)
        await model.load()
        return model
    }

    // MARK: - What it draws

    /// Every shape the grammar offers, drawn — and the grandfathered term
    /// READ-ONLY (no door), a dead tag as "(deleted tag)", a negated group
    /// with its `not`, one notice for the old term, no Collecting rows on a
    /// gathering, and Save disabled until something changes.
    @Test func itDrawsEveryShapeWithItsDoorsAndTheLegacyTermReadOnly() async throws {
        try await withEditorWorld { session, db in
            let (work, ideas, life, _) = try vocabulary(session, db)
            let rule = RuleTerm.and([
                .tag(work.id),
                .not(.or([.tag(ideas.id), .star])),
                .tag(""),
                .legacyProfile("journal"),
            ])
            let gathering = try session.operations.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(rule))
            _ = life
            RuleEditorProbe.reset()
            let model = await editor(session, gathering.id)

            try await mounted(model) {
                let rows = drawnRows(gathering.id)
                #expect(rows.contains(.init(depth: 0, negations: 0, words: RuleEditorCopy.allOf,
                                            doors: [RuleEditorCopy.not])),
                        "the root group: not — but no remove, it holds the old term")
                #expect(rows.contains(.init(depth: 1, negations: 0, words: "#work",
                                            doors: [RuleEditorCopy.not, RuleEditorCopy.remove])))
                #expect(rows.contains(.init(depth: 1, negations: 1, words: RuleEditorCopy.anyOf,
                                            doors: [RuleEditorCopy.not, RuleEditorCopy.remove])))
                #expect(rows.contains(.init(depth: 2, negations: 0, words: "#work/ideas",
                                            doors: [RuleEditorCopy.not, RuleEditorCopy.remove])))
                #expect(rows.contains(.init(depth: 2, negations: 0, words: RuleEditorCopy.starred,
                                            doors: [RuleEditorCopy.not, RuleEditorCopy.remove])))
                #expect(rows.contains(.init(depth: 1, negations: 0, words: RuleEditorCopy.deadTag,
                                            doors: [RuleEditorCopy.not, RuleEditorCopy.remove])))
                #expect(rows.contains(.init(depth: 1, negations: 0,
                                            words: "profile is \u{201C}journal\u{201D}", doors: [])),
                        "the grandfathered term is drawn READ-ONLY")
                #expect(rows.count == 7)
                let drawn = try #require(RuleEditorProbe.drawn[gathering.id])
                #expect(drawn.notice == RuleEditorCopy.legacyNotice)
                #expect(drawn.collecting == false, "a gathering has no Collecting rows")
                #expect(drawn.saveEnabled == false, "nothing to save yet")
            }
        }
    }

    /// The add doors offer EXACTLY the wing's live tags and the star — never
    /// a legacy term (#166(d)), never another wing's tag (§9), never a dead
    /// one.
    @Test func theAddDoorsOfferOnlyTheWingsTagsAndTheStar() async throws {
        try await withEditorWorld { session, db in
            let (work, _, _, _) = try vocabulary(session, db)
            let gone = try session.operations.createTag(name: "gone")
            try session.operations.deleteTag(gone.id)
            let gathering = try session.operations.createReading(
                name: "g", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(work.id), .legacyEntryDateFrom("2026-01-01")])))
            RuleEditorProbe.reset()
            let model = await editor(session, gathering.id)

            try await mounted(model) {
                let adders = try #require(RuleEditorProbe.drawn[gathering.id]?.adders)
                #expect(Set(adders.keys) == ["[]"], "the root group's own door")
                #expect(adders["[]"] == ["#life", "#work", "#work/ideas", RuleEditorCopy.starred])
            }
        }
    }

    // MARK: - What it writes

    @Test func editsRedrawAndSaveWritesExactlyTheTreeBuilt() async throws {
        try await withEditorWorld { session, db in
            let (work, ideas, life, _) = try vocabulary(session, db)
            let gathering = try session.operations.createReading(name: "g", kind: .gathering)
            RuleEditorProbe.reset()
            let model = await editor(session, gathering.id)

            try await mounted(model) {
                // No rule: the honest empty state + the root's add door.
                #expect(RuleEditorProbe.drawn[gathering.id]?.adders["root"] != nil)
                // #work ∧ ★ ∧ ¬(#work/ideas ∨ #life)
                model.add(.tag(work.id), into: nil)
                model.add(.star, into: nil)
                model.addGroup(.any, seededWith: .tag(ideas.id), into: nil)
                model.add(.tag(life.id), into: [2])
                let group = try #require(model.rows.first {
                    if case .group(.any, _) = $0.kind { return true } else { return false }
                })
                model.toggleNot(group)
                await settle()
                let rows = drawnRows(gathering.id)
                #expect(rows.contains { $0.words == RuleEditorCopy.anyOf && $0.negations == 1 })
                #expect(rows.contains { $0.words == "#life" && $0.depth == 2 })
                #expect(RuleEditorProbe.drawn[gathering.id]?.saveEnabled == true)

                // Flip the root to any-of, then back: the children untouched.
                let root = try #require(model.rows.first)
                model.setCombinator(.any, of: root)
                model.setCombinator(.all, of: try #require(model.rows.first))
                let built = RuleTerm.and([
                    .tag(work.id), .star, .not(.or([.tag(ideas.id), .tag(life.id)])),
                ])
                #expect(model.draft == built)

                #expect(await model.save())
                let stored = try await db.read { try Queries.reading($0, id: gathering.id)?.querySpec }
                #expect(RuleGrammar.decode(stored) == built, "stored exactly as built")
            }
        }
    }

    /// "Saving never silently drops a term", and its twin: an UNEDITED save
    /// writes NOTHING — not even an outbox row (a non-canonical stored
    /// spelling would otherwise look "changed", and on a book a changed rule
    /// is a catch-up occasion).
    @Test func anUneditedSaveWritesNothingEvenOverANonCanonicalSpelling() async throws {
        try await withEditorWorld { session, db in
            let (work, _, _, _) = try vocabulary(session, db)
            let spaced = "{ \"and\" : [ {\"tag\":\"\(work.id)\"}, {\"profile\":\"blog\"} ] }"
            let book = try session.operations.createReading(name: "b", kind: .book)
            let bookID = book.id
            try await db.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = ? WHERE id = ?",
                               arguments: [spaced, bookID])
                try db.execute(sql: "DELETE FROM sync_outbox")
            }
            let model = await editor(session, book.id)
            #expect(model.isDirty == false)
            #expect(await model.save())
            #expect(try await db.read { try Queries.reading($0, id: book.id)?.querySpec } == spaced,
                    "byte-identical: nothing written")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox")
            } == 0)
        }
    }

    /// A MALFORMED stored rule (a newer client's, say) is refused, not
    /// rewritten: the face says so and draws no rows; a book's Collecting
    /// settings still save, and the rule's bytes stay exactly as stored.
    @Test func aMalformedRuleIsRefusedAndNeverRewritten() async throws {
        try await withEditorWorld { session, db in
            let book = try session.operations.createReading(name: "b", kind: .book)
            let unreadable = #"{"near":{"tag":"x","within":3}}"#
            let bookID = book.id
            try await db.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = ? WHERE id = ?",
                               arguments: [unreadable, bookID])
            }
            RuleEditorProbe.reset()
            let model = await editor(session, book.id)

            try await mounted(model) {
                #expect(model.ruleIsEditable == false)
                #expect(RuleEditorProbe.drawn[book.id]?.notice == RuleEditorCopy.malformedNotice)
                #expect(drawnRows(book.id).isEmpty)
                #expect(RuleEditorProbe.drawn[book.id]?.adders.isEmpty ?? true, "no add doors")
                model.add(.star, into: nil)
                #expect(model.draft == nil, "an edit is refused")

                model.seating = .arrivals
                #expect(await model.save())
                let row = try #require(try await db.read { try Queries.reading($0, id: book.id) })
                #expect(row.intakeSeating == .arrivals, "the dial saved")
                #expect(row.querySpec == unreadable, "the rule untouched")
            }
        }
    }

    // MARK: - A book's Collecting rows

    /// The walk's spine, headless: on a LIVING book, a rule EDIT routes the
    /// gap through Arrivals (U1's catch-up) — the note waits at the door
    /// (U2's line counts it), it is never seated by the edit.
    @Test func aRuleEditOnALivingBookSendsTheGapToTheDoor() async throws {
        try await withEditorWorld { session, db in
            let (work, _, life, _) = try vocabulary(session, db)
            let book = try session.operations.createReading(
                name: "b", kind: .book, querySpec: try RuleGrammar.encode(.tag(work.id)))
            let lifeNote = try session.operations.createPost(title: "life note")
            _ = try session.operations.applyTag(life.id, toPost: lifeNote.id)
            RuleEditorProbe.reset()
            let model = await editor(session, book.id)

            try await mounted(model) {
                #expect(RuleEditorProbe.drawn[book.id]?.collecting == true)
                // #work → #work ∨ #life
                let root = try #require(model.rows.first)
                model.add(.tag(life.id), into: nil)
                model.setCombinator(.any, of: try #require(model.rows.first))
                _ = root
                #expect(model.draft == .or([.tag(work.id), .tag(life.id)]))
                #expect(await model.save())
            }
            let door = try await db.read { try Queries.bookArrivals($0, readingID: book.id, limit: 10) }
            #expect(door.count == 1)
            #expect(door.rows.map(\.postID) == [lifeNote.id], "the gap waits at the door")
            #expect(try await db.read { try Queries.assembleReading($0, readingID: book.id) }.isEmpty,
                    "never seated by the edit")
        }
    }

    /// The auto-tag row and its offer (the sitting record §4, ruled): saving
    /// an auto-tag offers "also tag the N current members now" on the status
    /// seam (an OFFER — always shown); its act tags them (`tagAllMembers`)
    /// and says so.
    @Test func settingAnAutoTagOffersToTagTheCurrentMembers() async throws {
        try await withEditorWorld { session, db in
            let (work, _, _, _) = try vocabulary(session, db)
            let book = try session.operations.createReading(name: "b", kind: .book)
            var members: [Container] = []
            for i in 0..<3 {
                let post = try session.operations.createPost(title: "m\(i)")
                try session.operations.addPostToReading(post.id, to: book.id)
                members.append(post)
            }
            _ = try session.operations.applyTag(work.id, toPost: members[0].id)
            let model = await editor(session, book.id)

            model.autoTagID = work.id
            #expect(model.isDirty)
            #expect(await model.save())

            let said = try #require(session.status.current)
            #expect(said.kind == .offer)
            #expect(said.text == "Also tag the 2 current members with #work now?")
            #expect(said.action?.label == RuleEditorCopy.tagMembersAction)
            #expect(try await db.read { try Queries.reading($0, id: book.id)?.autoTagId } == work.id)

            said.action?.perform()
            await settle(until: { session.status.spoken?.text != said.text })
            #expect(try await db.read {
                try Queries.membersMissingTag($0, readingID: book.id, tagID: work.id)
            } == 0, "every member wears it now")
            #expect(session.status.spoken?.text == "Tagged 2 members with #work.")
        }
    }

    /// No members to reach → no offer at all (a question with no answer is
    /// not asked); and an unchanged auto-tag never re-asks.
    @Test func noOfferWhenThereIsNothingToTag() async throws {
        try await withEditorWorld { session, db in
            let (work, _, _, _) = try vocabulary(session, db)
            let book = try session.operations.createReading(name: "b", kind: .book)
            let model = await editor(session, book.id)
            model.autoTagID = work.id
            #expect(await model.save())
            #expect(session.status.current?.kind != .offer)
            _ = db
        }
    }
}
