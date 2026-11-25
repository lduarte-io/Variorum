//
//  TagUseCountsP1Tests.swift
//  VariorumCoreTests
//
//  **The VX-1036 ladder, round 1 — R1-2 (MAJOR).** `Queries.tagUseCounts`
//  (VX-576's order key — "tag pickers list most-used first") runs ONCE every
//  time a tag field opens: the book card's "+", the masthead's ＃ field, the
//  List rows' ＋ popovers, both capture doors. Its first form drove from
//  `post_tag` and filtered on the tag's wing: the Home wing's scope
//  `(t.wing_id = '' OR t.wing_id NOT IN (live wings))` is unindexable, so the
//  plan read `SCAN pt USING INDEX uq_post_tag_live` — every live tag
//  application in the store, on every field's opening (P1's own shape of
//  wrong; the `ShelfQueries` ladder-A class).
//
//  The pins are SHAPE facts — query plans, never timings (the P48 lesson; the
//  `ReadLayerP1Tests` style): the statement never scans `post_tag`, in Home
//  or in a named wing. The semantics pin holds what the saturating form
//  answers: exact counts up to the cap, the cap beyond it (PROVISIONAL
//  P-1036-L1-1 — k = 50, `Queries.tagUseCountSaturation`).
//
//  **Round 2 — R2-1 (MAJOR).** R1-2's tag-first probe resolved through
//  `idx_post_tag_tag(tag_id)`, which is NOT partial (`Migrations.swift`): each
//  tag's probe walked EVERY application row ever written for the tag —
//  tombstones included (every un-tag, every note deletion's cascade; never
//  cleaned) — until it found `cap` live ones. The store never runs `ANALYZE`,
//  so the stats-free planner picks it. The probe now reads the LIVE partial
//  index `uq_post_tag_live(tag_id, post_id) WHERE deleted_at IS NULL`, which
//  holds the live rows alone; the plan pin says so, in Home and in a named
//  wing, and the tombstone-heavy case holds the counts exact through a long
//  history of dead applications.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// Every statement SQLite ran inside `body`, expanded (so each can be
/// EXPLAINed as it really ran) — `ReadLayerP1Tests`' capture, its own copy
/// (the helpers there are private to that file, as `NotePickerShapeTests`'
/// are to its).
private func captureStatements(
    _ db: AppDatabase, _ body: (Database) throws -> Void
) throws -> [String] {
    try db.read { database in
        let captured = LockIsolated<[String]>([])
        let capturing = LockIsolated(true)
        database.trace(options: .statement) { event in
            guard capturing.value, case .statement(let statement) = event else { return }
            let sql = statement.expandedSQL
            captured.withValue { $0.append(sql) }
        }
        try body(database)
        capturing.setValue(false)
        return captured.value
    }
}

/// The query plan of every SELECT-shaped statement `body` ran, joined.
private func capturedPlans(
    _ db: AppDatabase, _ body: (Database) throws -> Void
) throws -> String {
    let statements = try captureStatements(db, body)
    return try db.read { database in
        var plans: [String] = []
        for sql in statements {
            let head = sql.trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(6).uppercased()
            guard head.hasPrefix("SELECT") || head.hasPrefix("WITH") else { continue }
            plans += try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                .map { ($0["detail"] as String?) ?? "" }
        }
        return plans.joined(separator: "\n")
    }
}

@Suite("VX-1036 ladder R1-2 — the tag use counts read never scans the store's applications")
struct TagUseCountsP1Tests {
    /// A small library in two wings: Home's tags worn by Home's notes, a
    /// named wing's by its own — enough rows that every table has something
    /// to scan, so the plan is the planner's real choice.
    private func library(_ ops: Operations) throws -> Wing {
        let kitchen = try ops.createWing(name: "Kitchen")
        let homeTags = try ["week", "todo", "garden"].map { try ops.createTag(name: $0) }
        let kitchenTags = try ["bread", "soup"].map { try ops.createTag(name: $0, wingID: kitchen.id) }
        for i in 0..<6 {
            let home = try ops.createPost(title: "home \(i)")
            try ops.applyTag(homeTags[i % homeTags.count].id, toPost: home.id)
            let there = try ops.createPost(title: "kitchen \(i)", wingId: kitchen.id)
            try ops.applyTag(kitchenTags[i % kitchenTags.count].id, toPost: there.id)
        }
        return kitchen
    }

    /// **RED ON OLD (Home).** Every arm of the read reaches `post_tag` by a
    /// SEARCH from a tag — never a SCAN of the applications table, and never
    /// a scan of `container` either (a note is probed by its key).
    @Test(arguments: ["home", "named"])
    func theReadIsDrivenByTheWingsTagsAndNeverScansTheApplications(wing: String) throws {
        try withOperations { ops, db in
            let kitchen = try library(ops)
            let wingID = wing == "home" ? "" : kitchen.id
            let plan = try capturedPlans(db) { database in
                _ = try Queries.tagUseCounts(database, wingID: wingID)
            }
            let lines = plan.split(separator: "\n").map(String.init)
            #expect(!lines.contains { $0.hasPrefix("SCAN pt") || $0.hasPrefix("SCAN post_tag") },
                    "\(wing): the applications table must never be scanned; plan was:\n\(plan)")
            #expect(!lines.contains { $0.hasPrefix("SCAN c") || $0.hasPrefix("SCAN container") },
                    "\(wing): nor the notes; plan was:\n\(plan)")
            #expect(lines.contains { $0.contains("post_tag") || $0.contains(" pt ") || $0.hasPrefix("SEARCH pt") },
                    "\(wing): non-vacuity — the read does reach the applications; plan was:\n\(plan)")
        }
    }

    /// **What the saturating read answers** (P-1036-L1-1, k = 50): live notes
    /// wearing each tag of the wing, EXACT up to the cap and the cap beyond it
    /// (so two much-worn tags tie, and the suggest brain keeps them in path
    /// order — `TagSuggestOrderTests`); a taken-off application and a dead
    /// note's are not uses; a tag nobody wears is absent; another wing's
    /// vocabulary is its own.
    @Test func theCountsAreExactUpToTheCapAndTheCapBeyondIt() throws {
        try withOperations { ops, db in
            #expect(Queries.tagUseCountSaturation == 50, "P-1036-L1-1 — k, named once")
            let often = try ops.createTag(name: "often")
            let also = try ops.createTag(name: "also")
            let rare = try ops.createTag(name: "rare")
            let never = try ops.createTag(name: "never")
            let notes = try (0..<56).map { try ops.createPost(title: "note \($0)") }
            for note in notes.prefix(55) { try ops.applyTag(often.id, toPost: note.id) }
            for note in notes.prefix(52) { try ops.applyTag(also.id, toPost: note.id) }
            for note in notes.suffix(4) { try ops.applyTag(rare.id, toPost: note.id) }
            try ops.removeTag(rare.id, fromPost: notes[52].id)   // taken off: not a use
            try ops.deleteContainer(notes[53].id)                // a dead note's: not a use

            let counts = try db.read { try Queries.tagUseCounts($0, wingID: "") }
            #expect(counts[often.id] == 50, "55 wearers read as the cap: \(String(describing: counts[often.id]))")
            #expect(counts[also.id] == 50, "52 wearers read as the cap too — the two tie")
            #expect(counts[rare.id] == 2, "exact below the cap: \(String(describing: counts[rare.id]))")
            #expect(counts[never.id] == nil, "no live note wears it")

            // The cap is the caller's to name (the default is k).
            let low = try db.read { try Queries.tagUseCounts($0, wingID: "", saturatingAt: 3) }
            #expect(low[often.id] == 3 && low[also.id] == 3 && low[rare.id] == 2)

            let kitchen = try ops.createWing(name: "Kitchen")
            let bread = try ops.createTag(name: "bread", wingID: kitchen.id)
            let loaf = try ops.createPost(title: "a loaf", wingId: kitchen.id)
            try ops.applyTag(bread.id, toPost: loaf.id)
            #expect(try db.read { try Queries.tagUseCounts($0, wingID: kitchen.id) } == [bread.id: 1],
                    "a named wing counts its own vocabulary only")
            #expect(try db.read { try Queries.tagUseCounts($0, wingID: "") }[bread.id] == nil,
                    "…and Home never counts another wing's")
        }
    }

    /// **RED ON OLD — round 2, R2-1.** Each tag's probe walks the LIVE
    /// applications only: it reads `uq_post_tag_live` — the partial index
    /// that holds live rows alone — and NEVER `idx_post_tag_tag`, which holds
    /// every application ever written, tombstones included, so a probe
    /// through it costs the tag's whole history until it finds `cap` live
    /// rows. Library rows with dead applications in it, so the plan is read
    /// against a history that has tombstones to walk (the planner is
    /// stats-free — the store never runs `ANALYZE` — so this is its real
    /// choice, data or not).
    @Test(arguments: ["home", "named"])
    func eachTagsProbeReadsTheLiveApplicationsIndexNeverTheWholeHistory(wing: String) throws {
        try withOperations { ops, db in
            let kitchen = try library(ops)
            // A history to walk: Home's and the kitchen's tags taken off and
            // put back, leaving dead applications behind the live ones.
            for (tagWing, title) in [("", "home churn"), (kitchen.id, "kitchen churn")] {
                let tag = try ops.createTag(name: "churn", wingID: tagWing)
                let note = try ops.createPost(title: title, wingId: tagWing)
                for _ in 0..<4 {
                    try ops.applyTag(tag.id, toPost: note.id)
                    try ops.removeTag(tag.id, fromPost: note.id)
                }
                try ops.applyTag(tag.id, toPost: note.id)
            }
            let wingID = wing == "home" ? "" : kitchen.id
            let plan = try capturedPlans(db) { database in
                _ = try Queries.tagUseCounts(database, wingID: wingID)
            }
            let lines = plan.split(separator: "\n").map(String.init)
            #expect(lines.contains { $0.hasPrefix("SEARCH pt") && $0.contains("uq_post_tag_live") },
                    "\(wing): the probe reads the live partial index; plan was:\n\(plan)")
            #expect(!lines.contains { $0.contains("idx_post_tag_tag") },
                    "\(wing): never the index of every application ever written; plan was:\n\(plan)")
            #expect(!lines.contains { $0.hasPrefix("SCAN pt") || $0.hasPrefix("SCAN post_tag") },
                    "\(wing): and never a scan of the applications; plan was:\n\(plan)")
        }
    }

    /// **What a long history of dead applications leaves the counts** (R2-1's
    /// semantics case): a tag worn by three live notes, after hundreds of
    /// applications taken off and put back and notes deleted wearing it,
    /// counts exactly its three; a small cap is filled by live wearers only,
    /// never by tombstones; the deleted notes' cascade rows are not uses.
    @Test func aTagWithALongDeadHistoryStillCountsItsLiveWearersExactly() throws {
        try withOperations { ops, db in
            let worn = try ops.createTag(name: "worn")
            let wearers = try (0..<3).map { try ops.createPost(title: "wearer \($0)") }
            // Dead applications written BEFORE the live ones, so any walk
            // that does not skip tombstones meets them first.
            let churned = try (0..<20).map { try ops.createPost(title: "churned \($0)") }
            for note in churned {
                for _ in 0..<10 {
                    try ops.applyTag(worn.id, toPost: note.id)
                    try ops.removeTag(worn.id, fromPost: note.id)
                }
            }
            let gone = try (0..<10).map { try ops.createPost(title: "gone \($0)") }
            for note in gone {
                try ops.applyTag(worn.id, toPost: note.id)
                try ops.deleteContainer(note.id)   // the cascade tombstones its application
            }
            for note in wearers { try ops.applyTag(worn.id, toPost: note.id) }

            let history = try db.read { database in
                try Int.fetchOne(database, sql: """
                    SELECT COUNT(*) FROM post_tag WHERE tag_id = ? AND deleted_at IS NOT NULL
                    """, arguments: [worn.id]) ?? 0
            }
            try #require(history == 210, "the premise: 200 taken off + 10 cascaded, got \(history)")

            #expect(try db.read { try Queries.tagUseCounts($0, wingID: "") }[worn.id] == 3,
                    "three live wearers, whatever lies dead behind them")
            #expect(try db.read { try Queries.tagUseCounts($0, wingID: "", saturatingAt: 5) }[worn.id] == 3,
                    "a cap above the live wearers is never filled by tombstones")
            #expect(try db.read { try Queries.tagUseCounts($0, wingID: "", saturatingAt: 2) }[worn.id] == 2,
                    "a cap below them saturates on live wearers")
        }
    }
}
