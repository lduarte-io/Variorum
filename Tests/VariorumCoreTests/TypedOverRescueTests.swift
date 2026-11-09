import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-683 B — THE GUARDED AUTOSAVE** (the run record
/// `notes/plans/fixes/vx-849-typed-over-rescue.md`, batch 1; the memo
/// `notes/plans/fixes/vx-683-sync-into-debounce.md`, her rulings R-683-1…4).
///
/// An autosave never overwrites words it has not seen. The editor's buffer
/// was built on the text it last adopted; when the row has changed under it
/// since (a sync pull applied on the locally-clean path, the MCP door, a
/// second window), the autosave does not blind-write: HER BUFFER KEEPS THE
/// ROW (R-683-1) and the displaced words land as a new take on the same
/// block, label `'conflict'` (R-683-2), branched from the same parent, at
/// the fan's end — exactly where an S5 card lands. Both texts survive; both
/// push. No new schema, no §7 repair, no savepoint occasion.
@Suite("The typed-over rescue (VX-683 B — the guarded autosave)")
struct TypedOverRescueTests {
    // MARK: - Staging

    /// The row rewritten the way a sync pull lands it on the LOCALLY-CLEAN
    /// path (SyncSpec §5): apply mode (the outbox triggers muted), the
    /// server's text and its bumped `sync_version`, nothing enqueued.
    private func applyFromServer(_ db: AppDatabase, variant: String, text: String) throws {
        try db.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(
                sql: "UPDATE variant SET working_text = ?, sync_version = sync_version + 1 WHERE id = ?",
                arguments: [text, variant])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    private func liveTakes(_ db: AppDatabase, block: String) throws -> [Row] {
        try db.read { db in
            try Row.fetchAll(
                db,
                sql: """
                SELECT id, working_text, label, parent_variant_id, status, locked, fan_position
                FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id
                """,
                arguments: [block])
        }
    }

    // MARK: - THE PIN

    /// THE PIN (red on the pre-fix behavior: the blind write leaves the
    /// server's words nowhere). Her buffer, built on "The base.", lands while
    /// the row already holds the words a pull applied in the debounce window.
    @Test func aStaleAutosaveKeepsHerBufferOnTheRowAndRescuesTheDisplacedWords() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "The base.")
            let take = made.variant.id
            try db.clearOutbox()
            try applyFromServer(db, variant: take, text: "The base, rewritten on the phone.")

            try ops.autosave(
                take, text: "The base. And her next sentence.", charDelta: 24,
                expectedText: "The base.")

            // R-683-1: her buffer keeps the row — nothing moves under her caret.
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [take])
                    == "The base. And her next sentence.")
            // R-683-2: the displaced words, as an S5 card.
            let takes = try liveTakes(db, block: made.block.id)
            #expect(takes.count == 2)
            let card = try #require(takes.first { $0["id"] as String != take })
            #expect(card["working_text"] as String == "The base, rewritten on the phone.")
            #expect(card["label"] as String? == "conflict")
            #expect(card["parent_variant_id"] as String? == made.variant.parentVariantId)
            #expect(card["status"] as String == "active")
            #expect(card["locked"] as Int == 0)
            #expect((card["fan_position"] as String) > made.variant.fanPosition, "the fan's end")
            // Both push: her row and the card are both in the outbox.
            #expect(try db.outboxContains("variant", take))
            #expect(try db.outboxContains("variant", card["id"] as String))
            // The card is never chosen; the block's default is untouched.
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [made.block.id])
                    == made.placement.chosenVariantId)
            #expect(try db.fetchString("SELECT default_variant_id FROM block WHERE id = ?", [made.block.id])
                    == take)
        }
    }

    // MARK: - The guards (green on both sides)

    /// The ordinary case: the row is what she last saw — the write is
    /// today's, byte for byte, and no card is minted.
    @Test func anAutosaveOnTheTextItSawWritesAsBefore() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Seen.")
            try ops.autosave(made.variant.id, text: "Seen. More.", charDelta: 6, expectedText: "Seen.")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [made.variant.id])
                    == "Seen. More.")
            #expect(try liveTakes(db, block: made.block.id).count == 1)
        }
    }

    /// No snapshot rides the call (`expectedText: nil`): today's blind write,
    /// unchanged — the shape every caller had before VX-683.
    @Test func anUnguardedAutosaveIsTheBlindWriteItAlwaysWas() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Old.")
            try applyFromServer(db, variant: made.variant.id, text: "Remote.")
            try ops.autosave(made.variant.id, text: "Old. Mine.", charDelta: 5)
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [made.variant.id])
                    == "Old. Mine.")
            #expect(try liveTakes(db, block: made.block.id).count == 1)
        }
    }

    /// Nothing displaced, nothing to rescue: the other writer landed exactly
    /// her words, so no card.
    @Test func whenTheRowAlreadyHoldsHerWordsNoCardIsMinted() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "A.")
            try applyFromServer(db, variant: made.variant.id, text: "A. B.")
            try ops.autosave(made.variant.id, text: "A. B.", charDelta: 3, expectedText: "A.")
            #expect(try liveTakes(db, block: made.block.id).count == 1)
        }
    }

    /// The card lands EXACTLY where an S5 card lands: the rescued take's
    /// parent is the edited take's own parent (a branched take's rescue
    /// names the take it was branched from), at the fan's end past every
    /// existing take — `resolveSyncConflict`'s shape, the one face.
    @Test func theRescuedCardLandsWhereAnS5CardLands() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Root.")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            try applyFromServer(db, variant: branch.id, text: "Root, elsewhere.")

            try ops.autosave(branch.id, text: "Root. Mine.", charDelta: 6, expectedText: "Root.")

            let takes = try liveTakes(db, block: made.block.id)
            #expect(takes.count == 3)
            let card = try #require(takes.last)
            #expect(card["working_text"] as String == "Root, elsewhere.")
            #expect(card["label"] as String? == "conflict")
            #expect(card["parent_variant_id"] as String? == made.variant.id,
                    "branched from the same parent the edited take carries")
            #expect((card["fan_position"] as String) > branch.fanPosition)
        }
    }

    /// The take's guards still refuse FIRST: a locked take or a sealed post
    /// refuses the autosave exactly as before, and a refused autosave mints
    /// no card (the coordinator keeps her bytes pending, its standing
    /// posture).
    @Test func aLockedTakeOrASealedPostRefusesBeforeAnyRescue() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Kept.")
            try applyFromServer(db, variant: made.variant.id, text: "Kept, remote.")
            try ops.lockVariant(made.variant.id)
            #expect(throws: OperationError.lockedVariant(id: made.variant.id)) {
                try ops.autosave(made.variant.id, text: "Kept. Mine.", charDelta: 5, expectedText: "Kept.")
            }
            #expect(try liveTakes(db, block: made.block.id).count == 1)
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [made.variant.id])
                    == "Kept, remote.")

            try ops.unlockVariant(made.variant.id)
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.autosave(made.variant.id, text: "Kept. Mine.", charDelta: 5, expectedText: "Kept.")
            }
            #expect(try liveTakes(db, block: made.block.id).count == 1)
        }
    }

    /// The comparison is made as the store keeps text (`StoredText`): a
    /// snapshot carrying a U+0000 the store stripped is the same words, not
    /// a stale one — no spurious card.
    @Test func theSnapshotIsComparedAsTheStoreKeepsText() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Nul\u{0}led.")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [made.variant.id])
                    == "Nulled.")
            try ops.autosave(made.variant.id, text: "Nulled. On.", charDelta: 4, expectedText: "Nul\u{0}led.")
            #expect(try liveTakes(db, block: made.block.id).count == 1)
        }
    }

    /// The rescue is a buffer edit and nothing more: the container's touch
    /// and churn read exactly as the same write's would without the rescue
    /// (the card is a LANDING, like S5's — it earns no churn of its own).
    @Test func theRescueTouchesAndChurnsExactlyAsTheWriteItIs() throws {
        func run(stale: Bool) throws -> [String: DatabaseValue]? {
            try withOperations { ops, db in
                let post = try ops.createPost(title: "p", profile: .blog)
                let made = try ops.seedBlock(in: post.id, text: String(repeating: "w", count: 100))
                _ = try ops.commit(made.variant.id)   // a real baseline (100)
                if stale {
                    try applyFromServer(db, variant: made.variant.id, text: String(repeating: "r", count: 100))
                }
                try ops.autosave(
                    made.variant.id, text: String(repeating: "w", count: 101), charDelta: 1,
                    expectedText: String(repeating: "w", count: 100))
                return try db.snapshotRow("container", post.id, excluding: [])
            }
        }
        let rescued = try run(stale: true)
        let plain = try run(stale: false)
        #expect(rescued != nil)
        #expect(rescued == plain)
    }
}

/// **VX-683 B, END TO END** — the convergence suite's standing shape (two
/// devices, one dumb server, production's pull → push rounds): a sync change
/// without a convergence test is unreviewed (AppSpec §15.3).
@Suite("The typed-over rescue converges (VX-683 B)")
struct TypedOverRescueConvergenceTests {
    private func texts(_ client: SyncClient, block: String) async throws -> Set<String> {
        try await client.db.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [block]))
        }
    }

    /// THE MECHANISM, whole (the memo's trace): her typing sits in the
    /// debounce window, so the row is CLEAN; the Mac's round pulls the phone's
    /// rewrite and applies it on the locally-clean path (correctly, by its own
    /// lights); then her debounced autosave fires with a buffer built on the
    /// OLD text. Pre-fix, it blind-wrote and its push was CAS-accepted (the
    /// base is the applied version) — the phone's words survived nowhere, on
    /// either device. Now the autosave rescues (R-683-1/-2) and both texts
    /// converge everywhere: her words on the row, the phone's as the
    /// `'conflict'` card. (Red under the batch record's named behavioral
    /// revert of the rescue.)
    @Test func aPullIntoTheDebounceWindowThenHerAutosaveConvergesWithBothTexts() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)
        let (block, take): (String, String) = try mac.with { ops, _ in
            let post = try ops.createPost(title: "p", profile: .journal)
            let made = try ops.newBlock(in: post.id, text: "The shared base.", at: .end)
            return (made.block.id, made.variant.id)
        }
        try await productionQuiescence(mac, phone, server: server)

        try phone.with { ops, _ in
            try ops.autosave(take, text: "The phone's rewrite.", charDelta: 12)
        }
        _ = try await productionRound(phone)

        // The Mac: her buffer is built on the base and NOT yet written; a
        // round lands the phone's words on the clean row.
        let herBuffer = "The shared base. Her next sentence."
        _ = try await productionRound(mac)
        #expect(try mac.db.fetchString("SELECT working_text FROM variant WHERE id = ?", [take])
                == "The phone's rewrite.", "staging: the pull applied on the locally-clean path")
        // Her debounced autosave fires, carrying the snapshot it was built on.
        try mac.with { ops, _ in
            try ops.autosave(take, text: herBuffer, charDelta: 19, expectedText: "The shared base.")
        }

        try await productionQuiescence(mac, phone, server: server)
        #expect(try mac.syncedDump() == phone.syncedDump())
        #expect(try mac.outboxCount() == 0 && phone.outboxCount() == 0)
        for client in [mac, phone] {
            #expect(try await texts(client, block: block) == [herBuffer, "The phone's rewrite."],
                    "\(client.name) lost a text")
            #expect(try client.db.fetchString("SELECT working_text FROM variant WHERE id = ?", [take])
                    == herBuffer, "\(client.name): her buffer keeps the row (R-683-1)")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND label = 'conflict' AND deleted_at IS NULL",
                [block]) == 1)
        }
    }
}
