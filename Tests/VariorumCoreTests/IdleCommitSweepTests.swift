import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 8, Step 5's core half — the sweep's candidate query. The scheduler
/// (app-shared) decides WHEN to ask; `Operations.idleAutoCommit` already
/// enforces its own rules (at most one auto commit per dirty variant); this
/// query narrows WHOM to ask, at a cost bounded by recent edits, never the
/// corpus (P1).
@Suite("Idle auto-commit sweep candidates (Phase 8, Step 5)")
struct IdleCommitSweepTests {
    /// A cutoff after every stamp the harness clock has minted so far.
    private let afterEverything = "2026-07-01T23:59:59.999Z"
    private let openMark = ""

    @Test func idleCommitHoursReadsTheSettingWithA24Default() throws {
        let db = try AppDatabase.inMemory()
        #expect(try db.read { try Queries.idleCommitHours($0) } == 24)
        try db.write { db in
            try db.execute(
                sql: "UPDATE setting SET value = '6' WHERE key = 'idle_commit_hours'")
        }
        #expect(try db.read { try Queries.idleCommitHours($0) } == 6)
    }

    @Test func aDirtyIdlePostIsACandidateAndACleanOneIsNot() throws {
        try withOperations { ops, db in
            // Dirty: edited after its last commit.
            let dirty = try ops.createPost(title: "dirty", profile: .journal)
            let minted = try ops.newBlock(in: dirty.id, text: "draft", at: .end)
            _ = try ops.commit(minted.variant.id)
            try ops.autosave(minted.variant.id, text: "draft, changed since", charDelta: 14)

            // Clean: committed after its last edit.
            let clean = try ops.createPost(title: "clean", profile: .journal)
            let cleanMint = try ops.newBlock(in: clean.id, text: "settled", at: .end)
            try ops.autosave(cleanMint.variant.id, text: "settled text", charDelta: 5)
            _ = try ops.commit(cleanMint.variant.id)

            let candidates = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: openMark, cutoff: afterEverything)
            }
            #expect(candidates == [dirty.id].sorted())
        }
    }

    @Test func theSweepIsBoundedByDirtyPostsNotCorpus() throws {
        try withOperations { ops, db in
            // A corpus of clean posts…
            for index in 1...30 {
                let post = try ops.createPost(title: "clean \(index)", profile: .blog)
                let minted = try ops.newBlock(in: post.id, text: "text \(index)", at: .end)
                _ = try ops.commit(minted.variant.id)
            }
            // …and exactly two dirty ones.
            var dirtyIDs: [String] = []
            for index in 1...2 {
                let post = try ops.createPost(title: "dirty \(index)", profile: .journal)
                let minted = try ops.newBlock(in: post.id, text: "x", at: .end)
                _ = try ops.commit(minted.variant.id)
                try ops.autosave(minted.variant.id, text: "x revised \(index)", charDelta: 9)
                dirtyIDs.append(post.id)
            }
            let candidates = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: openMark, cutoff: afterEverything)
            }
            #expect(candidates == dirtyIDs.sorted(),
                    "the sweep asks exactly the dirty posts — clean corpus invisible (P1)")
        }
    }

    @Test func theWindowExcludesNotYetIdleAndAlreadyInsuredPosts() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "recent", profile: .journal)
            let minted = try ops.newBlock(in: post.id, text: "still warm", at: .end)
            try ops.autosave(minted.variant.id, text: "still warm, edited", charDelta: 8)
            let touched = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])!

            // Cutoff BEFORE the edit: the post is not yet idle.
            let beforeEdit = "2026-07-01T00:00:00.000Z"
            #expect(try db.read {
                try Queries.idleCommitCandidates($0, afterMark: self.openMark, cutoff: beforeEdit)
            }.isEmpty)

            // Mark AT the touch stamp: a previous sweep already insured it.
            #expect(try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: touched, cutoff: self.afterEverything)
            }.isEmpty)

            // Window straddling the stamp: candidate.
            #expect(try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: self.openMark, cutoff: self.afterEverything)
            } == [post.id])
        }
    }

    /// `newBlock` stamps `last_touched_at` since Phase 9 (author decision
    /// 2026-07-07, QUESTIONS #5 option (a)): a one-burst entry (mint, then
    /// closed) or a teardown-minted tail is an ordinary touch-branch
    /// candidate — no special branch needed.
    @Test func aMintOnlyPostIsCaughtByTheTouchBranch() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "one burst", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "typed once, never edited again", at: .end)
            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) != nil,
                "the mint stamps the touch — QUESTIONS #5 (a)")

            let candidates = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: self.openMark, cutoff: self.afterEverything)
            }
            #expect(candidates == [post.id])
        }
    }

    /// The created_at branch stays as the net for STAMP-LESS rows — real
    /// ones exist: containers written by pre-Phase-9 builds (the author's
    /// devices ran Phase 8 code) whose mints never stamped. Simulated here
    /// by clearing the stamp the mint wrote.
    @Test func aLegacyStamplessMintOnlyPostIsStillCaughtByTheCreatedAtBranch() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "phase-8 era row", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "minted by an old build", at: .end)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container SET last_touched_at = NULL WHERE id = ?",
                    arguments: [post.id])
            }

            let candidates = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: self.openMark, cutoff: self.afterEverything)
            }
            #expect(candidates == [post.id])
        }
    }

    @Test func sealedPostsAndLockedVariantsAreNeverCandidates() throws {
        try withOperations { ops, db in
            // Sealed: lockPost already auto-committed its dirty buffers.
            let sealed = try ops.createPost(title: "sealed", profile: .journal)
            _ = try ops.newBlock(in: sealed.id, text: "insured by the seal", at: .end)
            try ops.lockPost(sealed.id)

            // A dirty buffer behind a variant lock: lockVariant insured it.
            let lockedVariantPost = try ops.createPost(title: "locked take", profile: .journal)
            let minted = try ops.newBlock(in: lockedVariantPost.id, text: "guarded", at: .end)
            try ops.autosave(minted.variant.id, text: "guarded, edited", charDelta: 8)
            try ops.lockVariant(minted.variant.id)

            let candidates = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: self.openMark, cutoff: self.afterEverything)
            }
            #expect(candidates.isEmpty)
        }
    }

    @Test func runningTheSweepDropsTheCandidateExactlyOnce() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "swept", profile: .journal)
            let minted = try ops.newBlock(in: post.id, text: "never committed", at: .end)
            try ops.autosave(minted.variant.id, text: "never committed, grown", charDelta: 7)

            let before = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: self.openMark, cutoff: self.afterEverything)
            }
            #expect(before == [post.id])

            // The sweep: exactly one quiet insurance commit…
            let committed = try ops.idleAutoCommit(post.id)
            #expect(committed.count == 1)
            #expect(committed.first?.kind == .auto)

            // …and the candidate is gone (idempotence at the sweep level).
            let after = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: self.openMark, cutoff: self.afterEverything)
            }
            #expect(after.isEmpty)
            #expect(try ops.idleAutoCommit(post.id).isEmpty, "a second ask finds nothing dirty")
        }
    }
}

// MARK: - The QUESTIONS #5 pin (Phase 9; was Phase 8's documented gap)

@Suite("Idle sweep mint coverage (Phase 9 — QUESTIONS #5 red-on-old pin)")
struct IdleSweepMintCoverageTests {
    /// THE RED-ON-OLD PIN for the `newBlock` stamp+churn change (author
    /// decision 2026-07-07, QUESTIONS #5 option (a), implementation owned by
    /// Phase 9). This is Phase 8's documented-gap test FLIPPED: a mint into
    /// a previously-touched post whose stamp was already behind the sweep
    /// mark used to match neither branch (asserted `.isEmpty` — no idle
    /// insurance until the next real edit). With `newBlock` stamping
    /// `last_touched_at`, the mint re-enters the touch window and the block
    /// gets idle insurance like any other edit. Fails on the pre-fix code.
    @Test func aMintIntoAPreviouslyTouchedAndSweptPostIsNowInsured() throws {
        try withOperations { ops, db in
            // A post with real edit history…
            let post = try ops.createPost(title: "old post", profile: .blog)
            let first = try ops.newBlock(in: post.id, text: "Edited once.", at: .end)
            try ops.autosave(first.variant.id, text: "Edited once, truly.", charDelta: 7)
            _ = try ops.commit(first.variant.id)
            let touched = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])!

            // …a sweep has advanced the mark past its stamp…
            let mark = touched  // the previous sweep's cutoff covered it

            // …then a tail block is MINTED (an idle-/teardown-minted tail)
            // and the post is left alone. The mint stamps the touch, so the
            // post re-enters the window and the sweep sees it.
            _ = try ops.newBlock(in: post.id, text: "Teardown-minted tail, never edited again.", at: .end)

            let candidates = try db.read {
                try Queries.idleCommitCandidates(
                    $0, afterMark: mark, cutoff: "2026-07-01T23:59:59.999Z")
            }
            #expect(candidates == [post.id],
                    "the mint stamps last_touched_at — the swept-past post is a candidate again (QUESTIONS #5 (a))")

            // And the insurance actually lands on the minted block.
            let committed = try ops.idleAutoCommit(post.id)
            #expect(committed.count == 1)
            #expect(committed.first?.kind == .auto)
        }
    }
}
