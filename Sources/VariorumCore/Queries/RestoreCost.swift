import Foundation
import GRDB

// **WHAT A RESTORE TAKES THAT NO VERSION HOLDS** (13u3 UNIT E — item 15(a),
// her #80(e) ratification: *"keep as built — defensible, and the confirm can
// name it"*).
//
// `restoreNoteVersion` saves a version of NOW first and then sends the note's
// outgoing blocks down the **Delete Now road** — a tombstone plus a purge
// intent per block, in the restore's own transaction. Her ruling kept that
// road; what it owes her is a confirm that says what it costs. This read is
// that sentence's only source of facts, and every number in it was MEASURED
// against the operation rather than reasoned about (the probe is recorded in
// the UNIT E RECORD).
//
// ── THE FOUR POPULATIONS, AND WHY EACH IS REAL ───────────────────────────────
// A version copy carries **the words and the takes, never the past**
// (`copyPlacements`: live placements only, whole live fan, live comments — and
// `commit_point` is copied by NOTHING in this app, the standing pool-drag
// rule). So when the outgoing blocks go:
//
//   1. **the saved moments on their live takes** — every ⌘S she pressed and
//      every quiet savepoint the app took, unreachable the instant the block
//      is tombstoned (`commit_point` has no `deleted_at`; §14 item 4) and
//      physically removed when the janitor executes the intent. The version of
//      NOW holds ONE fresh insurance savepoint per copied take (the seal's own
//      occasion, `mintNoteVersion`) — the text of that instant, never her run
//      of moments;
//   2. **the deleted takes waiting in their Block History**, clocks and Put
//      back and all — a tombstoned variant never travels into a copy;
//   3. **the deleted comments** waiting in their comment panel, for the same
//      reason (`copyLiveComments` carries the live ones only);
//   4. **the set-aside originals that would JOIN the purge family** — the
//      round-8b rule (`PurgeFamily.joinStrandedOriginals`): a live, unplaced,
//      un-archived ancestor whose ENTIRE descendant set is inside the purge
//      goes with it, carrying every take it holds.
//
// ── WHAT THE PROBE MEASURED ABOUT (4), AND WHY IT IS STILL COMPUTED ──────────
// **Today it is always zero for a restore, and the mechanism is worth stating
// so nobody re-derives it.** Step 1's version of NOW copies EVERY outgoing
// block, and each copy mints a `derived_from` edge back to the block it copied
// (`copyPlacements`' `insertLineageEdge`). So the moment the restore is over,
// every outgoing block has a LIVE descendant outside the purge family — which
// is exactly the condition `joinStrandedOriginals` requires to be absent. The
// preserved original therefore stays live, keeps listing in the note's tray,
// and survives a full physical sweep (measured: `RestoreCostTests
// .aRestoreStrandsNoAncestorBecauseTheVersionOfNowIsTheirSurvivingDescendant`).
//
// It is computed anyway, for two reasons that are not speculation: her ruling
// names this population by name, and the zero is a CONSEQUENCE of one line in
// the copy loop — remove that lineage edge, or reach the one shape where a
// slot copies as nothing (the SyncSpec §5 gap window), and the population is
// real again. The face then names it without anyone noticing it had to.
//
// ── THE MIRROR, AND ITS DRIFT GUARD ──────────────────────────────────────────
// (4)'s predicate is `PurgeFamily.joinStrandedOriginals`' predicate, written a
// second time — deliberately, and not happily. `PurgeFamily` lives in
// `Sources/VariorumCore/Sync/`, which is sync-engine surgery (CLAUDE.md's
// standing rider) and off limits to a faces batch, and it is internal to the
// module besides. So the copy carries a PIN instead of a promise:
// `RestoreCostTests.theSetAsideReadAgreesWithThePurgeFamilyItMirrors` stages
// the shapes where the population is non-empty and asserts this read's answer
// EQUALS `PurgeFamily.expand(...).strandedOriginals`. If the two ever
// disagree, that pin says so before a confirm does.
//
// ── COST (P1) ────────────────────────────────────────────────────────────────
// Every statement is scoped to the note's own live placements and their
// lineage: proportional to the note and to what the note's blocks came out of,
// never to the corpus. It runs once per ASK (the press of Restore), never per
// keystroke and never per listing row — the `versionCount` precedent (read at
// ask time, so the confirm is about the note as it IS).
extension Queries {
    /// What the Delete Now road would take on a restore of this note, counted
    /// at ask time.
    public struct RestoreCost: Equatable, Sendable {
        /// The note's outgoing blocks — removed, but their words are saved
        /// into the version of NOW first, so they are not a loss.
        public let outgoingBlocks: Int
        /// Savepoints on those blocks' live takes (population 1).
        public let savedMoments: Int
        /// Takes deleted from those blocks, still waiting in Block History
        /// (population 2).
        public let deletedTakes: Int
        /// Comments deleted from those blocks, still restorable (population 3).
        public let deletedComments: Int
        /// The set-aside originals that would join the purge family
        /// (population 4) — ids, because the pin compares them to
        /// `PurgeFamily`'s own answer.
        public let setAsideOriginals: [String]
        /// Live takes carried by those originals.
        public let setAsideTakes: Int

        public init(
            outgoingBlocks: Int, savedMoments: Int, deletedTakes: Int,
            deletedComments: Int, setAsideOriginals: [String], setAsideTakes: Int
        ) {
            self.outgoingBlocks = outgoingBlocks
            self.savedMoments = savedMoments
            self.deletedTakes = deletedTakes
            self.deletedComments = deletedComments
            self.setAsideOriginals = setAsideOriginals
            self.setAsideTakes = setAsideTakes
        }

        /// Nothing here is held by any version — the confirm's one question.
        public var isEmpty: Bool {
            savedMoments == 0 && deletedTakes == 0 && deletedComments == 0
                && setAsideOriginals.isEmpty
        }

        public static let none = RestoreCost(
            outgoingBlocks: 0, savedMoments: 0, deletedTakes: 0,
            deletedComments: 0, setAsideOriginals: [], setAsideTakes: 0)
    }

    /// The read itself. A note that does not exist, or holds nothing, costs
    /// nothing — the door refuses such a restore on its own terms.
    public static func restoreCost(_ db: Database, of postID: String) throws -> RestoreCost {
        // The outgoing set, defined EXACTLY as `restoreNoteVersion` step 2
        // defines it: this note's live placements whose block is still live.
        let outgoing = try String.fetchAll(
            db,
            sql: """
                SELECT cb.block_id FROM container_block cb
                JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY cb.position, cb.id
                """,
            arguments: [postID])
        guard !outgoing.isEmpty else { return .none }

        let ids = jsonIDs(outgoing)
        let row = try Row.fetchOne(
            db,
            sql: """
                SELECT
                  (SELECT COUNT(*) FROM commit_point c
                     JOIN variant v ON v.id = c.variant_id AND v.deleted_at IS NULL
                    WHERE v.block_id IN (SELECT value FROM json_each(:ids))) AS moments,
                  (SELECT COUNT(*) FROM variant v
                    WHERE v.block_id IN (SELECT value FROM json_each(:ids))
                      AND v.deleted_at IS NOT NULL) AS deleted_takes,
                  -- VX-179: a comment she already deleted forever is not
                  -- "still restorable" — the panel's fence, applied here so
                  -- the confirm never counts what no door can bring back.
                  (SELECT COUNT(*) FROM block_comment bc
                    WHERE bc.block_id IN (SELECT value FROM json_each(:ids))
                      AND bc.deleted_at IS NOT NULL
                      AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                        WHERE pi.table_name = 'block_comment' AND pi.row_id = bc.id
                          AND (pi.deleted_at IS NULL OR pi.deleted_at >= bc.deleted_at))
                  ) AS deleted_comments
                """,
            arguments: ["ids": ids])

        let originals = try setAsideOriginals(db, family: Set(outgoing))
        let takes = originals.isEmpty ? 0 : (try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM variant
                WHERE block_id IN (SELECT value FROM json_each(?))
                  AND deleted_at IS NULL
                """,
            arguments: [jsonIDs(originals)]) ?? 0)

        return RestoreCost(
            outgoingBlocks: outgoing.count,
            savedMoments: row?["moments"] ?? 0,
            deletedTakes: row?["deleted_takes"] ?? 0,
            deletedComments: row?["deleted_comments"] ?? 0,
            setAsideOriginals: originals,
            setAsideTakes: takes)
    }

    /// **The round-8b predicate, mirrored** (see this file's header for why it
    /// is a mirror and what pins it): the live, unplaced, un-archived ancestors
    /// of `family` whose entire descendant set is inside `family` or already
    /// absent from the store — computed to a fixpoint, because an original
    /// joining can strand ITS own original in turn.
    ///
    /// Lineage is read PAST edge tombstones on both legs, and a descendant
    /// counts as SURVIVING while its `block` row exists at all (tombstoned or
    /// not) — both exactly as the purge reads them, because a confirm that
    /// counted a different population than the janitor takes would be a
    /// different kind of lie than the one it is fixing.
    static func setAsideOriginals(
        _ db: Database, family seed: Set<String>
    ) throws -> [String] {
        var family = seed
        var joined: Set<String> = []
        while true {
            let candidates = try String.fetchAll(
                db,
                sql: """
                    WITH RECURSIVE anc(id) AS (
                      SELECT e.target_block_id FROM edge e
                      WHERE e.source_block_id IN (SELECT value FROM json_each(?))
                        AND e.type = 'derived_from'
                      UNION
                      SELECT e.target_block_id FROM edge e
                      JOIN anc a ON e.source_block_id = a.id
                      WHERE e.type = 'derived_from'
                    )
                    SELECT DISTINCT b.id FROM anc
                    JOIN block b ON b.id = anc.id
                    WHERE b.deleted_at IS NULL AND b.archived_at IS NULL
                      AND NOT EXISTS (
                        SELECT 1 FROM container_block placed
                        WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
                    """,
                arguments: [jsonIDs(family)])
            var grew = false
            for candidate in candidates where !family.contains(candidate) {
                let surviving = try Int.fetchOne(
                    db,
                    sql: """
                        WITH RECURSIVE fam(id) AS (
                          SELECT e.source_block_id FROM edge e
                          WHERE e.target_block_id = ? AND e.type = 'derived_from'
                          UNION
                          SELECT e.source_block_id FROM edge e
                          JOIN fam f ON e.target_block_id = f.id
                          WHERE e.type = 'derived_from'
                        )
                        SELECT COUNT(*) FROM fam
                        JOIN block d ON d.id = fam.id
                        WHERE fam.id NOT IN (SELECT value FROM json_each(?))
                        """,
                    arguments: [candidate, jsonIDs(family)]) ?? 0
                guard surviving == 0 else { continue }
                family.insert(candidate)
                joined.insert(candidate)
                grew = true
            }
            guard grew else { return joined.sorted() }
        }
    }

    private static func jsonIDs(_ values: some Collection<String>) -> String {
        let data = try? JSONEncoder().encode(values.sorted())
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
