import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **Phase 13j, J11 — the savepoint cadence, core half.**
///
/// Her sitting-round-1 ruling, in three parts, each pinned here:
///
/// 1. **on-leaving savepoints** — `Operations.closeAutoCommit`: one quiet
///    `kind:'auto'` commit per DIRTY take under the container, deduped by the
///    `idleAutoCommit` guard's exact pattern (an unchanged take writes
///    nothing), and never throwing at a lifecycle moment;
/// 2. **the backstop 24 h → 2 h** — the seed for fresh stores and the
///    only-if-still-default migration for existing ones;
/// 3. **the ONE cadence setting** — three modes over TWO occasions, with the
///    INSURANCE occasions ungoverned by it in every mode (the matrix below is
///    the load-bearing pin: a setting that silently stopped the seal from
///    insuring buffers would lose text).
@Suite("The savepoint cadence (13j, J11)")
struct SavepointCadenceTests {

    // MARK: - Item 1: leaving a note leaves a savepoint

    @Test func leavingANoteCommitsEveryDirtyTakeOnce() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .journal)
            let first = try ops.newBlock(in: post.id, text: "one", at: .end)
            let second = try ops.newBlock(in: post.id, text: "two", at: .end)

            let committed = try ops.closeAutoCommit(post.id)
            #expect(committed.count == 2, "both fresh takes are dirty — never committed")
            #expect(committed.allSatisfy { $0.kind == .auto })
            #expect(
                Set(committed.map(\.variantId))
                    == Set([first.variant.id, second.variant.id]))

            // THE DEDUPE: leaving twice with nothing typed in between writes
            // nothing (the `isDirty` guard, shared with idleAutoCommit).
            #expect(try ops.closeAutoCommit(post.id).isEmpty)
            let rows = try db.fetchInt("SELECT COUNT(*) FROM commit_point")
            #expect(rows == 2)
        }
    }

    @Test func onlyTheTakesThatCHANGEDGetASavepoint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .journal)
            let touched = try ops.newBlock(in: post.id, text: "before", at: .end)
            let untouched = try ops.newBlock(in: post.id, text: "settled", at: .end)
            _ = try ops.closeAutoCommit(post.id)  // both insured

            try ops.autosave(touched.variant.id, text: "before, and after", charDelta: 11)
            let second = try ops.closeAutoCommit(post.id)
            #expect(second.count == 1)
            #expect(second.first?.variantId == touched.variant.id)
            #expect(
                try db.fetchInt(
                    "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                    [untouched.variant.id]) == 1,
                "the take she never touched keeps its one savepoint")
        }
    }

    @Test func aScrapsContainerLeavesSavepointsToo() throws {
        try withOperations { ops, db in
            // The brief's letter: "the quick note and scraps follow the same
            // rule through the same authority" — the op is container-scoped,
            // so a pool needs no second road.
            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.newBlock(in: pool.id, text: "a loose line", at: .end)
            let committed = try ops.closeAutoCommit(pool.id)
            #expect(committed.map(\.variantId) == [scrap.variant.id])
            _ = db
        }
    }

    @Test func aLockedTakeIsSkippedAndTheRestStillLand() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .journal)
            let locked = try ops.newBlock(in: post.id, text: "frozen", at: .end)
            let open = try ops.newBlock(in: post.id, text: "moving", at: .end)
            try ops.lockVariant(locked.variant.id)

            let committed = try ops.closeAutoCommit(post.id)
            #expect(committed.map(\.variantId) == [open.variant.id])
            _ = db
        }
    }

    /// **A lifecycle moment must never throw at a surface that is going
    /// away.** Both refusals answer `[]` instead — the divergence from
    /// `idleAutoCommit` is deliberate and is this op's whole reason for
    /// existing beside it.
    @Test func aSealedOrVanishedNoteIsAQuietNoOpNotARefusal() throws {
        try withOperations { ops, db in
            let sealed = try ops.createPost(title: "finished", profile: .blog)
            _ = try ops.newBlock(in: sealed.id, text: "done", at: .end)
            try ops.lockPost(sealed.id)  // the seal already insured the buffer
            #expect(try ops.closeAutoCommit(sealed.id).isEmpty)

            let gone = try ops.createPost(title: "goes away", profile: .blog)
            _ = try ops.newBlock(in: gone.id, text: "typed", at: .end)
            try ops.deleteContainer(gone.id)
            #expect(try ops.closeAutoCommit(gone.id).isEmpty)

            #expect(try ops.closeAutoCommit("no-such-container").isEmpty)
            _ = db
        }
    }

    // MARK: - Item 3: the three modes' occasion matrix

    /// **THE MATRIX.** Two cadence occasions obey the setting; the INSURANCE
    /// occasions fire in every mode, because they insure what is about to
    /// become unreachable (OverallModel §3) and a cadence preference must
    /// never be able to lose text.
    @Test func theThreeModesGovernTheTwoCadenceOccasionsAndNothingElse() throws {
        for mode in SavepointCadence.allCases {
            try withOperations { ops, db in
                try ops.setSavepointCadence(mode)

                // (a) leaving a note
                let leaving = try ops.createPost(title: "leaving", profile: .journal)
                _ = try ops.newBlock(in: leaving.id, text: "typed", at: .end)
                #expect(
                    try ops.closeAutoCommit(leaving.id).isEmpty != mode.savesOnLeaving,
                    "close, \(mode.rawValue)")

                // (b) the idle backstop
                let idle = try ops.createPost(title: "idle", profile: .journal)
                _ = try ops.newBlock(in: idle.id, text: "typed", at: .end)
                #expect(
                    try ops.idleAutoCommit(idle.id).isEmpty != mode.savesWhenIdle,
                    "idle, \(mode.rawValue)")

                // (c) INSURANCE — sealing a note commits its dirty buffers in
                // EVERY mode, "Only when I commit" included.
                let sealing = try ops.createPost(title: "sealing", profile: .blog)
                let take = try ops.newBlock(in: sealing.id, text: "insured", at: .end)
                try ops.lockPost(sealing.id)
                #expect(
                    try db.fetchInt(
                        "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                        [take.variant.id]) == 1,
                    "the seal insures in \(mode.rawValue)")

                // (d) INSURANCE — locking a dirty take, likewise.
                let guarding = try ops.createPost(title: "guarding", profile: .blog)
                let dirty = try ops.newBlock(in: guarding.id, text: "held", at: .end)
                try ops.lockVariant(dirty.variant.id)
                #expect(
                    try db.fetchInt(
                        "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                        [dirty.variant.id]) == 1,
                    "the lock insures in \(mode.rawValue)")

                // (e) A DELIBERATE ⌘S always writes.
                let manual = try ops.createPost(title: "manual", profile: .blog)
                let typed = try ops.newBlock(in: manual.id, text: "by hand", at: .end)
                _ = try ops.commit(typed.variant.id)
                #expect(
                    try db.fetchInt(
                        "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                        [typed.variant.id]) == 1)
            }
        }
    }

    @Test func theCadenceSettingRoundTripsAndDefaultsToEverySession() throws {
        try withOperations { ops, db in
            #expect(try db.read { try Queries.savepointCadence($0) } == .everySession)
            try ops.setSavepointCadence(.idleOnly)
            #expect(try db.read { try Queries.savepointCadence($0) } == .idleOnly)
            #expect(try db.outboxContains("setting", "savepoint_cadence"))

            // An unrecognized value reads as the default rather than
            // refusing — a setting arriving from a newer device must never
            // wedge an older one (the `fan_style`/`theme_voice` rule).
            try db.write { db in
                try db.execute(
                    sql: "UPDATE setting SET value = 'hourly' WHERE key = 'savepoint_cadence'")
            }
            #expect(try db.read { try Queries.savepointCadence($0) } == .everySession)
        }
    }

    // MARK: - Item 2: the backstop drops to two hours

    @Test func aFreshStoreSeedsTheTwoHourBackstop() throws {
        let fresh = try AppDatabase.inMemory()
        #expect(try fresh.read { try Queries.idleCommitHours($0) } == 2)
    }

    /// A real pre-13j store, reconstructed: migrate to v1_12, put the shipped
    /// default back, then let `v1_13_savepoint_backstop` run.
    @Test func theMigrationMovesAStoreStillAtTheShippedDefault() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_12_container_word_target")
        try queue.write { db in
            try db.execute(
                sql: "UPDATE setting SET value = '24' WHERE key = 'idle_commit_hours'")
        }
        try AppDatabase.migrator.migrate(queue)
        #expect(
            try queue.read { try Queries.idleCommitHours($0) } == 2,
            "a store still at 24 h moves to the ruled backstop")
    }

    /// **The guard is the point.** No UI has ever exposed this setting, so in
    /// practice every store reads '24' — but a value set by hand is hers, and
    /// a migration that overwrote it would be the app deciding it knows
    /// better.
    @Test func theMigrationLeavesAHandSetBackstopAlone() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_12_container_word_target")
        try queue.write { db in
            try db.execute(
                sql: "UPDATE setting SET value = '6' WHERE key = 'idle_commit_hours'")
        }
        try AppDatabase.migrator.migrate(queue)
        #expect(try queue.read { try Queries.idleCommitHours($0) } == 6)
    }

    @Test func aStoreWithNoRowReadsTheSameBackstopASeededOneDoes() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try db.execute(sql: "DELETE FROM setting WHERE key = 'idle_commit_hours'")
        }
        #expect(try db.read { try Queries.idleCommitHours($0) } == 2)
    }
}

// MARK: - Item 4's brain: the quiet-run collapse

@Suite("The quiet-run collapse (13j, J11 — the legibility half)")
struct SavepointRunsTests {
    private func rows(_ pattern: String) -> [SavepointRuns.Row<Character>] {
        // 'a' = an auto savepoint, 'm' = a deliberate one.
        SavepointRuns.rows(
            Array(pattern.enumerated()),
            isQuiet: { $0.element == "a" },
            id: { "\($0.offset)" }
        ).map { row in
            switch row {
            case .single(let item, let id): return .single(item.element, id: id)
            case .quietRun(let id, let items):
                return .quietRun(id: id, items: items.map(\.element))
            }
        }
    }

    @Test func consecutiveQuietSavepointsCollapseAndDeliberateOnesNeverDo() {
        let collapsed = rows("aaamaam")
        #expect(collapsed.map(\.id) == ["run:0", "3", "run:4", "6"])
        #expect(collapsed.map(\.runCount) == [3, nil, 2, nil])
        #expect(collapsed[0].items == ["a", "a", "a"])
        #expect(collapsed[1].items == ["m"], "a deliberate savepoint stands alone")
    }

    @Test func aLoneQuietSavepointStaysItsOwnRow() {
        // The build-time call (#70): "1 quiet savepoint — show" would hide
        // one line behind a click.
        #expect(rows("ama").map(\.runCount) == [nil, nil, nil])
        #expect(rows("ama").map(\.id) == ["0", "1", "2"])
    }

    @Test func theGroupingIsOrderAgnostic() {
        // Write's face is newest-first, the Takes sheet's is oldest-first;
        // a run is contiguous read either way, so one rule serves both.
        #expect(rows("maa").map(\.runCount) == [nil, 2])
        #expect(rows("aam").map(\.runCount) == [2, nil])
    }

    @Test func theEdgesHoldEmptyAllQuietAllDeliberate() {
        #expect(rows("").isEmpty)
        #expect(rows("aaaa").map(\.runCount) == [4])
        #expect(rows("mmm").map(\.runCount) == [nil, nil, nil])
    }

    @Test func theWordsCountWhatTheRowStandsFor() {
        // 13s-b U4 (R-13s-31): the word is COMMIT — "N quiet savepoints"
        // retired on both platforms (this line is the phone's too).
        #expect(SavepointRuns.runLabel(count: 3) == "3 quiet commits")
        #expect(SavepointRuns.runLabel(count: 1) == "1 quiet commit")
        // The collapsed row's help must not overclaim: it names the two
        // CADENCE occasions and says ⌘S is never folded in.
        #expect(SavepointRuns.runHelp.contains("\u{2318}S commits are never folded in"))
        #expect(SavepointRuns.runHelp.contains("idle backstop"))
        #expect(SavepointRuns.runHelp.range(of: "savepoint", options: .caseInsensitive) == nil,
                "the help the collapsed row hangs speaks commit too")
    }
}

extension SavepointRuns.Row: Equatable where Item: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.single(let a, let x), .single(let b, let y)): return a == b && x == y
        case (.quietRun(let x, let a), .quietRun(let y, let b)): return x == y && a == b
        default: return false
        }
    }
}
