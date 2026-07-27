import Foundation
import GRDB

// The block-extent index (13c Batch 2C — the uniform-page brief §5, option
// (a): "derived, in-memory, per open book … zero schema change, zero sync
// surface"). This is the MODEL tier of Read's two-tier pagination: it answers
// "how much text is in each block of these posts" in ONE indexed query,
// **without transferring a single character of prose** — the lengths are
// computed in SQL.
//
// Why lengths and not text: the page domain must be derivable for a whole
// book cheaply (P1), and the whole point of the estimated tier is that it
// never lays anything out and never loads anything it isn't rendering. The
// exact tier (CoreText, app-side) reads real text — for the handful of posts
// actually on screen.
//
// AppSpec §4's escape hatch reads "stored per-block length estimates"; this
// is the DERIVED form of exactly that number, which is why the schema door
// (a `block.length_estimate` column) stays closed and unbuilt: reading
// lengths is cheap, and a stored column would owe a lockstep event and a
// maintenance path for a need nothing has demonstrated.
extension Queries {
    /// One live block's rendered EXTENT — its length, never its text.
    ///
    /// `characters` is SQLite `LENGTH()` over the rendered take (Unicode
    /// code points, not Swift grapheme clusters, and not bytes): an
    /// ESTIMATOR input, deliberately not a substitute for `text.count`
    /// anywhere a byte-exact answer matters.
    public struct BlockExtent: Equatable, Sendable {
        public let containerID: String
        public let blockID: String
        /// Characters in the rendered take. A gap slot, a blank take, and a
        /// slot whose variants are all unresolvable all read 0 — which is
        /// what `renderedText` does with them too (they contribute nothing,
        /// not even a join).
        public let characters: Int
        /// Newlines INSIDE the rendered take (I4: newlines are content, and
        /// a multi-paragraph block is the case that makes character count
        /// alone a bad page estimate).
        public let newlines: Int

        public init(containerID: String, blockID: String, characters: Int, newlines: Int) {
            self.containerID = containerID
            self.blockID = blockID
            self.characters = characters
            self.newlines = newlines
        }
    }

    /// The rendered extents of every live block in these containers, in
    /// reading order per container.
    ///
    /// The take resolution MIRRORS `renderPost` exactly — chosen while it is
    /// live, active and on this block, else the block's live default, else
    /// nothing — so a page estimate is built from the same text a page will
    /// render. (`Operations.renderedLength`'s looser COALESCE is deliberately
    /// NOT reused: it feeds churn counters and documents its own divergence.)
    ///
    /// Cost: one indexed pass per chunk of containers, no prose crossing the
    /// boundary. Callers pass a BOUNDED post list (the book view's window),
    /// never a corpus.
    public static func blockExtents(
        _ db: Database, containerIDs: [String]
    ) throws -> [BlockExtent] {
        guard !containerIDs.isEmpty else { return [] }
        var result: [BlockExtent] = []
        // Chunked so a caller with a large window can never hit SQLite's
        // bound-parameter limit (the window is 300 today; this costs nothing
        // and removes the trap).
        for chunk in stride(from: 0, to: containerIDs.count, by: 400).map({ start in
            Array(containerIDs[start..<min(start + 400, containerIDs.count)])
        }) {
            // Placeholders are generated from a COUNT and the ids are bound
            // as arguments — no identifier ever reaches the SQL text (the
            // Phase 5 injection-guard discipline).
            let placeholders = Array(repeating: "?", count: chunk.count).joined(separator: ",")
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT
                      cb.container_id AS container_id,
                      cb.block_id     AS block_id,
                      LENGTH(COALESCE(chosen.working_text, dflt.working_text, ''))
                                      AS characters,
                      LENGTH(COALESCE(chosen.working_text, dflt.working_text, ''))
                        - LENGTH(REPLACE(
                            COALESCE(chosen.working_text, dflt.working_text, ''),
                            char(10), ''))
                                      AS newlines
                    FROM container_block cb
                    LEFT JOIN block b
                      ON b.id = cb.block_id AND b.deleted_at IS NULL
                    LEFT JOIN variant chosen
                      ON chosen.id = cb.chosen_variant_id
                     AND chosen.block_id = b.id
                     AND chosen.deleted_at IS NULL
                     AND chosen.status = 'active'
                    LEFT JOIN variant dflt
                      ON dflt.id = b.default_variant_id
                     AND dflt.deleted_at IS NULL
                    WHERE cb.container_id IN (\(placeholders))
                      AND cb.deleted_at IS NULL
                    ORDER BY cb.container_id, cb.position, cb.id
                    """,
                arguments: StatementArguments(chunk))
            result += rows.map { row in
                BlockExtent(
                    containerID: row["container_id"],
                    blockID: row["block_id"],
                    characters: row["characters"],
                    newlines: row["newlines"])
            }
        }
        return result
    }
}
