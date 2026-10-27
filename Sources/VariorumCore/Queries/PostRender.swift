import Foundation
import GRDB

/// The read layer (Phase 4): every view is a traversal of the one store, and
/// these are the traversals — plain read-only fetch functions over `Database`,
/// composed into live projections by `Observations.swift`. Queries never
/// mutate and carry no business rules beyond the documented read-time
/// fallbacks (AppSpec §7); anything that smells like a mutation belongs in
/// `Operations`.
///
/// Missing-row tolerance is a correctness requirement, not defensive style
/// (SyncSpec §5): a placement whose block hasn't arrived renders as a gap; a
/// dangling `chosen_variant_id` falls back; a dangling `grouping_tag_id`
/// means ungrouped. Render gaps, never crash.
public enum Queries {}

extension Queries {
    /// One slot of a rendered container (post or pool), in reading order.
    public struct RenderedBlock: Equatable, Sendable {
        public let blockID: String
        /// The `container_block` pointer row backing this slot.
        public let placementID: String
        public let position: String
        /// The variant this slot renders — the read-time rule (AppSpec §7):
        /// the pointer's chosen variant while it is live, active, and on this
        /// block; else the block's default variant while it is live. `nil` ⇒
        /// a **gap**: the block row is missing or tombstoned, or no variant
        /// is renderable (sync-race states; SyncSpec §5/§7).
        public let variantID: String?
        public let text: String?
        /// Live *active* variants on the block; the fan badge shows only
        /// when > 1 (AppSpec §12 badge behavior). Counted through the live
        /// block row, so a gap slot never badges — variants that arrived
        /// before their block (sync order) count 0 until the block lands.
        public let activeVariantCount: Int
        /// **Live variants on the block regardless of `status`** — active
        /// AND archived (13c Stage 1 ladder, R1-1). `activeVariantCount` is
        /// the FAN: what the badge shows and what the author is looking at.
        /// This is what EXISTS. The two differ exactly when a block carries
        /// archived takes, and an archived take is still prose that a
        /// `deleteBlock` cascade takes with it — so any gesture whose
        /// authorization is "there is no text to lose here" must read THIS
        /// count, never the fan's. Counted through the live block row like
        /// its sibling, so a gap slot reads 0.
        public let liveVariantCount: Int
        /// **Live `block_comment` rows on the block** (13c Stage 1 ladder,
        /// R2-1). Comments are authored prose the SLOT never renders, and
        /// `deleteBlock` fires v1_8's cascade over them — so, like an
        /// archived take, a commented block that renders empty is not a
        /// textless block. Counted through the live block row like its two
        /// siblings, so a gap slot reads 0.
        public let commentCount: Int
        /// The rendered variant's lock (frozen buffer, edit by branch/unlock).
        public let variantLocked: Bool

        public var isGap: Bool { variantID == nil }
        public var hasFan: Bool { activeVariantCount > 1 }
        /// True when the block carries takes the fan does not show — the
        /// "renders empty but is not textless" state R1-1 found.
        public var hasArchivedTakes: Bool { liveVariantCount > activeVariantCount }
        /// True when the block carries working notes (13c R2-1).
        public var hasComments: Bool { commentCount > 0 }

        /// **THE read for any gesture authorized on "there is no text to
        /// lose here"** (13c Stage 1 ladder, R1-1 + R2-1 — the two halves
        /// of one class, wired through one name so a third kind of unshown
        /// prose extends this property rather than growing a parallel
        /// guard). `text` is what the slot SHOWS; this is what the block
        /// additionally HOLDS — archived takes, and block comments. Both
        /// die in `deleteBlock`'s cascade, and the comment half additionally
        /// breaks AppSpec §7's ratified "deleted comments are visible and
        /// resurrectable — never skimpy", because `deletedBlockComments` is
        /// keyed by block and a tombstoned block is only in the tray.
        ///
        /// Deliberately NOT included (13c R2-1, PROVISIONAL — QUESTIONS
        /// #40): `block.name` and `block.presentation`. Those are columns
        /// ON the block row: the tombstone keeps them, `restoreBlock` and
        /// structural undo bring them back with the block, and the tray
        /// lists the block BY its name. Nothing of them becomes
        /// unrecoverable or unreachable, which is what separates them from
        /// the two counted here.
        public var carriesUnshownText: Bool { hasArchivedTakes || hasComments }

        /// Public so view layers and tests can build projections directly
        /// (the editor's pure mapping functions take these as input).
        ///
        /// `liveVariantCount` and `commentCount` are REQUIRED, never
        /// defaulted: a projection builder that has not thought about
        /// archived takes or comments must say so, rather than silently
        /// reporting a block as textless (the `UndoStack.register(redo:)`
        /// precedent — green by construction, not by audit).
        public init(
            blockID: String, placementID: String, position: String,
            variantID: String?, text: String?,
            activeVariantCount: Int, liveVariantCount: Int, commentCount: Int,
            variantLocked: Bool
        ) {
            self.blockID = blockID
            self.placementID = placementID
            self.position = position
            self.variantID = variantID
            self.text = text
            self.activeVariantCount = activeVariantCount
            self.liveVariantCount = liveVariantCount
            self.commentCount = commentCount
            self.variantLocked = variantLocked
        }
    }

    /// Renders a container: walk the live pointer list by `(position, id)`,
    /// resolving each slot by the read-time rule. One indexed query (no
    /// N+1); cost ∝ the container's own size, never the corpus (P1). Pools
    /// render exactly like posts — same table, same traversal.
    ///
    /// The variant resolution deliberately mirrors `Operations.renderedVariant`
    /// (and `renderedLength`'s COALESCE): chosen-if-live-and-active-and-same-
    /// block, else default-if-live — the default may be archived and still
    /// render (archive hides a take from the fan, not from a slot that has
    /// nothing else to show). The equivalence is pinned by a test that runs
    /// both against the same fallback matrix.
    public static func renderPost(_ db: Database, containerID: String) throws -> [RenderedBlock] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT
                  cb.id                                            AS placement_id,
                  cb.block_id                                      AS block_id,
                  cb.position                                      AS position,
                  COALESCE(chosen.id, dflt.id)                     AS variant_id,
                  COALESCE(chosen.working_text, dflt.working_text) AS text,
                  COALESCE(chosen.locked, dflt.locked, 0)          AS variant_locked,
                  (SELECT COUNT(*) FROM variant v
                    WHERE v.block_id = b.id
                      AND v.deleted_at IS NULL
                      AND v.status = 'active')                     AS active_variant_count,
                  -- Archived takes included: what EXISTS on the block, as
                  -- against what the fan shows (R1-1).
                  (SELECT COUNT(*) FROM variant v
                    WHERE v.block_id = b.id
                      AND v.deleted_at IS NULL)                    AS live_variant_count,
                  -- Working notes on the block (R2-1): prose the slot never
                  -- renders, taken by the same cascade. Indexed by
                  -- idx_block_comment_block; cost stays ∝ the container.
                  (SELECT COUNT(*) FROM block_comment bc
                    WHERE bc.block_id = b.id
                      AND bc.deleted_at IS NULL)                   AS comment_count
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
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY cb.position, cb.id
                """,
            arguments: [containerID])
        return rows.map { row in
            RenderedBlock(
                blockID: row["block_id"],
                placementID: row["placement_id"],
                position: row["position"],
                variantID: row["variant_id"],
                text: row["text"],
                activeVariantCount: row["active_variant_count"],
                liveVariantCount: row["live_variant_count"],
                commentCount: row["comment_count"],
                variantLocked: row["variant_locked"])
        }
    }

    // MARK: - The resolution as a fragment (13u3 UNIT G — UNIT B's hand-up)

    /// **`renderPost`'s two joins, for a statement that resolves an opening
    /// take inside a bigger question.** Three reads of a note's opening were
    /// found disagreeing about which take they render (13u3 UNIT B's hand-up):
    /// the Library card's `COALESCE(cb.chosen_variant_id, b.default_variant_id)`
    /// — which previews an ARCHIVED chosen take, blanks on a TOMBSTONED one
    /// and shows another block's prose through a FOREIGN pointer — and the
    /// note picker's `b.default_variant_id` alone, which previews the wrong
    /// take for every block whose take she has switched, since `chooseVariant`
    /// writes only the placement's chosen. Neither was the rule the note
    /// itself renders by, so the rule ships as text a statement can paste in.
    ///
    /// **Contract (a fragment, not a query):** the statement must alias
    /// `container_block` as `cb` and `block` as `b`, and reads its text
    /// through `renderedTakeTextSQL`. A reader that wants the ANSWER rather
    /// than a fragment calls `renderedVariantIDs` below; `renderPost` and
    /// `leadingBlockTextsSQL` keep their own copies of these lines
    /// deliberately — re-typing a shipped, load-bearing statement for
    /// tidiness is the risk, and their agreement is pinned by behaviour
    /// instead (`renderAgreesWithOperationsRenderedVariant`,
    /// `renderedVariantIDAgreesWithBothResolvers`).
    public static let renderedTakeJoinSQL = """
        LEFT JOIN variant chosen
          ON chosen.id = cb.chosen_variant_id
         AND chosen.block_id = b.id
         AND chosen.deleted_at IS NULL
         AND chosen.status = 'active'
        LEFT JOIN variant dflt
          ON dflt.id = b.default_variant_id
         AND dflt.deleted_at IS NULL
        """

    /// The text those joins resolve — chosen while it renders, else the
    /// block's default. NULL is a gap (the caller decides what a gap reads as).
    public static let renderedTakeTextSQL = "COALESCE(chosen.working_text, dflt.working_text)"

    // MARK: - The rendered take of NAMED blocks (13u3 UNIT G — the 18f ladder's R3-9)

    /// The SQL behind `renderedVariantIDs`, held as one constant for the same
    /// reason `leadingBlockTextsSQL` is: the rule ships once. The resolution is
    /// `renderPost`'s, verbatim — chosen-if-live-and-active-and-same-block,
    /// else default-if-live — with the traversal turned around: it is driven
    /// by the BLOCK rows named, not by a container's pointer list, and the
    /// placement joins in beside them. `uq_cblock_ownership` (live-unique on
    /// `block_id`, I2) makes that join at most one row per block, so nothing
    /// multiplies and the seek is indexed.
    ///
    /// The `%%MARKS%%` placeholder is substituted with `?`s by the caller —
    /// GRDB's own `databaseQuestionMarks`, the `notePickerNotes(ids:)` pattern.
    static let renderedVariantIDsSQL = """
        SELECT b.id AS block_id, COALESCE(chosen.id, dflt.id) AS variant_id
        FROM block b
        LEFT JOIN container_block cb
          ON cb.block_id = b.id AND cb.deleted_at IS NULL
        LEFT JOIN variant chosen
          ON chosen.id = cb.chosen_variant_id
         AND chosen.block_id = b.id
         AND chosen.deleted_at IS NULL
         AND chosen.status = 'active'
        LEFT JOIN variant dflt
          ON dflt.id = b.default_variant_id
         AND dflt.deleted_at IS NULL
        WHERE b.id IN (%%MARKS%%) AND b.deleted_at IS NULL
        """

    /// **Which take do THESE blocks render — for a caller that holds block
    /// ids and has no use for the note around them** (13u3 UNIT G, the 18f
    /// ladder's R3-9). The merge sheet's drift check is the first caller: it
    /// compares two ids (a pair) or the run's handful against what the sheet
    /// SHOWED, on a deliberate confirm, and used to reach that answer through
    /// `Queries.renderPost` — which loads every slot's rendered TEXT of the
    /// whole note to read two ids. Inside the app's cost model (the editor's
    /// own projection is that query at every change) and so never a P1 breach,
    /// but ∝ the note where ∝ the blocks named is available; this keeps the
    /// confirm's cost the size of the gesture.
    ///
    /// **One rule, not a second one.** The resolution is `renderPost`'s and
    /// `Operations.renderedVariant`'s — chosen while it is live, active and on
    /// this block, else the block's default while it is live (the default may
    /// be ARCHIVED and still render: archive hides a take from the fan, not
    /// from a slot with nothing else to show). The equivalence with BOTH is
    /// pinned over the same fallback matrix
    /// (`PostRenderQueryTests.renderedVariantIDAgreesWithBothResolvers`).
    ///
    /// Read-layer conventions, deliberately unlike the operations layer's:
    /// a dead block, an unknown id, and a block with nothing renderable are
    /// simply ABSENT from the result (render gaps, never crash — SyncSpec §5),
    /// where `Operations.renderedVariant` throws. An UNPLACED live block
    /// resolves by its default, exactly as the operations layer's optional
    /// placement does — this is the one read that can be asked about a block
    /// released to lineage, and it answers.
    public static func renderedVariantIDs(
        _ db: Database, blockIDs: [String]
    ) throws -> [String: String] {
        let ids = Array(Set(blockIDs))
        guard !ids.isEmpty else { return [:] }
        let sql = renderedVariantIDsSQL.replacingOccurrences(
            of: "%%MARKS%%", with: databaseQuestionMarks(count: ids.count))
        var result: [String: String] = [:]
        result.reserveCapacity(ids.count)
        for row in try Row.fetchAll(db, sql: sql, arguments: StatementArguments(ids)) {
            guard let variantID = row["variant_id"] as String? else { continue }
            result[row["block_id"] as String] = variantID
        }
        return result
    }

    /// The single-block form — the shape the finding named. `nil` is a gap
    /// (dead, unknown, or nothing renderable), never an error.
    public static func renderedVariantID(_ db: Database, blockID: String) throws -> String? {
        try renderedVariantIDs(db, blockIDs: [blockID])[blockID]
    }

    // MARK: - The LEADING blocks (13u2 UNIT A2 — the book cards' preview prime)

    /// The SQL behind `leadingBlockTexts`, held as one constant so a pin can
    /// `EXPLAIN QUERY PLAN` **exactly the statement that ships** rather than a
    /// hand-copied twin of it. The resolution is `renderPost`'s, verbatim —
    /// chosen-if-live-and-active-and-same-block, else default-if-live — minus
    /// the three counting subqueries, which a preview has no use for.
    static let leadingBlockTextsSQL = """
        SELECT COALESCE(chosen.working_text, dflt.working_text) AS text
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
        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
        ORDER BY cb.position, cb.id
        LIMIT ?
        """

    /// **The first `blocks` slots of a container, rendered — and nothing
    /// else.** A container's opening text for a caller that needs an opening:
    /// the book Outline's collapsed card, whose preview is at most ~forty
    /// words (`BookOutlineRows.cardPreview`, which also skips a lone heading
    /// or numeral at the front, hence a small constant rather than one block).
    /// Gaps contribute nothing (`renderPost`'s rule — render gaps, never
    /// crash), so the result may be shorter than `blocks`: a gap (a live
    /// placement over a dead block, or a block with no resolvable take — the
    /// cross-batch sync states SyncSpec §5 designs for) reads as SQL NULL,
    /// decoded as `String?` and DROPPED, while it still spends its slot of the
    /// `LIMIT`. (The VX-439 ladder's R2-1: this decoded `String` and THREW on
    /// the NULL until then — this sentence was false, and its pin's gap leg
    /// never held a gap.)
    ///
    /// **Why it exists, and why it is not `renderPost(...).prefix(k)` (P1 is
    /// the law here).** The card used to derive its preview from a WHOLE-note
    /// render — one `renderPost` per realized row, cost ∝ the note's text, for
    /// forty words. Measured on a synthetic note of 20,000 blocks: this read
    /// **0.017 ms**, the whole render **20.5 ms**; and this read costs the SAME
    /// 0.018 ms on a ten-block note, i.e. it is FLAT in the note's length,
    /// because `ORDER BY cb.position` rides `idx_cblock_order` and the `LIMIT`
    /// stops the scan (pinned by the query-plan test, not by a stopwatch).
    /// Derived at read time, never stored (the snippet doctrine).
    ///
    /// The one bounded consequence, stated rather than hidden: a note whose
    /// first `blocks` slots are all gaps or blank takes previews as empty
    /// where a whole-note render would have found text further down. Sync-race
    /// states and a note that opens with several empty blocks; the card is a
    /// preview, and the cure — an unbounded read per card — is the defect.
    public static func leadingBlockTexts(
        _ db: Database, containerID: String, blocks: Int
    ) throws -> [String] {
        guard blocks > 0 else { return [] }
        return try String?.fetchAll(
            db, sql: leadingBlockTextsSQL, arguments: [containerID, blocks]
        ).compactMap { $0 }
    }

    /// Several containers' leading slots in ONE read — the book's card-preview
    /// prime (13u2 UNIT A2). Cost is ∝ `containerIDs.count × blocks`, never ∝
    /// the book's text: each container takes its own bounded, index-ordered
    /// `LIMIT` seek rather than one big scan the planner would have to sort.
    /// Containers with no live slots are simply absent from the result.
    public static func leadingBlockTexts(
        _ db: Database, containerIDs: [String], blocks: Int
    ) throws -> [String: [String]] {
        var result: [String: [String]] = [:]
        result.reserveCapacity(containerIDs.count)
        for id in containerIDs where result[id] == nil {
            result[id] = try leadingBlockTexts(db, containerID: id, blocks: blocks)
        }
        return result
    }

    /// The default blocks-join separator used by `renderedText` — the
    /// rendering join that re-creates stored-nothing separators (block text
    /// never stores its trailing separator; SegmentationRules doctrine).
    /// See `joinRenderedTexts` for the one conditional (author ruling
    /// 2026-07-12).
    public static let blockJoinSeparator = "\n\n"

    /// THE rendered-text join (author ruling 2026-07-12, QUESTIONS #12 —
    /// the export half of spacing preservation, shaped on the ratified
    /// merge-join precedent "a single space at the join unless either
    /// side's edge already carries whitespace"): blocks join with
    /// `"\n\n"` UNLESS the left side already ends in a newline (stored
    /// spacing — option (a)'s trailing-newline content), in which case the
    /// join completes it with a single `"\n"` — so a k-newline paste
    /// (k ≥ 2) exports as k newlines again, while a SINGLE-newline paste
    /// stores no trailing content and exports through the default
    /// `"\n\n"` join (the ratified rendering separator); unspaced posts
    /// join byte-identical to the pre-ruling `"\n\n"`. One join brain: `renderedText` calls
    /// this (the retired bridge's per-day projection did too — its pushed
    /// body always equalled the export).
    public static func joinRenderedTexts(_ texts: [String]) -> String {
        var result = ""
        for (i, text) in texts.enumerated() {
            if i > 0 {
                result += result.hasSuffix("\n") ? "\n" : blockJoinSeparator
            }
            result += text
        }
        return result
    }

    /// The container's full rendered prose, for export and diff callers:
    /// each slot's rendered text joined by `joinRenderedTexts`. Gaps
    /// contribute nothing (render gaps, never crash — SyncSpec §5), and
    /// **blank takes skip like gaps** (author decision 2026-07-06: a
    /// chosen-but-empty variant contributes nothing — export reads
    /// `"a\n\nb"`, never `"a\n\n\n\nb"`; the blank take still renders as an
    /// empty slot in `renderPost` for the editor). Cost is inherently ∝ the
    /// container's own length — this is the whole-document projection, for
    /// read-side consumers that need exactly that.
    public static func renderedText(_ db: Database, containerID: String) throws -> String {
        joinRenderedTexts(
            try renderPost(db, containerID: containerID)
                .compactMap(\.text)
                .filter { !$0.isEmpty })
    }
}
