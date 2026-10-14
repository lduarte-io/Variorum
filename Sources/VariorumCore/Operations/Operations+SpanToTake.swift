import Dependencies
import Foundation
import GRDB

// **SELECTION → A TAKE ON THE SAME BLOCK** (13u4 UNIT C2 — her 13u3 morning
// addition, item 9, verbatim: *"Having a command where you could highlight
// part of a block and move it into a take on that block (out of the take it's
// currently in) would be a nice time saver. not sure what complexities that
// would add."*)
//
// The semantics were HERS to rule and she ruled them at the 13u4 kickoff
// sitting (**R-13u4-4**, verbatim): *"move alone should be fine - the fact
// that there'll be a savepoint/commit of the current take right before moving
// is enough to cover the case that someone wants it to stay - they can just
// revert it to that point if they want."*
//
// So: MOVE alone — the span LEAVES the take it was in — and **the quiet
// savepoint is load-bearing rather than plumbing.** It is her whole answer to
// "but I wanted it to stay in both": the take's state one keystroke before
// the move is a savepoint she can restore from Block History. That is why it
// sits inside the same transaction as the move rather than beside it.
extension Operations {
    /// The op's result: the minted take, and whether the insurance savepoint
    /// had to be written.
    ///
    /// `insuranceSavepoint` is nil when the take's buffer already MATCHED its
    /// latest savepoint (the standing `isDirty` dedupe the five quiet
    /// occasions before this one share). **Her cover holds in both branches,
    /// and that is why the dedupe is safe here:** either this op wrote the
    /// pre-move text as a savepoint, or the take's last savepoint already
    /// held it byte-for-byte. A face may report the moment it saved; it must
    /// never read nil as "nothing to restore".
    public struct SpanToTakeResult: Sendable {
        public let take: Variant
        public let insuranceSavepoint: CommitPoint?
    }

    /// Moves `span` (intra-take UTF-16 offsets) out of `variantID`'s buffer
    /// and into a FRESH take on the same block, in ONE transaction, in
    /// R-13u4-4's shape exactly:
    ///
    /// 1. **the insurance savepoint** of the current take (`kind: .auto`,
    ///    deduped against its own last savepoint — the `editTakesAtomically`
    ///    / `lockVariant` one-quiet-commit pattern, not `insureTakes`'
    ///    skip-silently pass, because THIS op's guards are refusals: a take
    ///    it cannot edit must refuse the gesture, never be skipped past);
    /// 2. **the span leaves** the current take's buffer — EXACTLY as selected.
    ///    No snapping (`BoundarySnapping` serves CUTS, and this mints no
    ///    block boundary) and no whitespace trimming (U-19 (2) — never eat
    ///    what she typed; a doubled space left at the seam is hers to tidy,
    ///    recorded as PROVISIONAL at QUESTIONS #128);
    /// 3. **a new take mints at the fan's END**, holding the span verbatim,
    ///    `parent_variant_id` = the take it came out of, `label` nil,
    ///    never chosen (neither the placement's `chosen_variant_id` nor the
    ///    block's `default_variant_id` moves) and never locked;
    /// 4. **ONE structural-undo entry**, with the exact-row redo beside it.
    ///
    /// **Refusals** (each one the standing convention's, none invented): a
    /// sealed post, a locked take, an archived take and a tombstoned take all
    /// refuse through `editableVariant` — the autosave/edit class, because
    /// the span leaving the buffer IS a buffer edit and the lock is exactly
    /// what guards a buffer. A dead BLOCK refuses (`blockNotFound`); a
    /// `expectedText` that no longer matches refuses
    /// (`bufferChangedSinceGesture` — the Phase 5 reject-path doctrine the
    /// editor's deferred gestures already ride, so a door's plan can never
    /// land on a buffer that moved under it).
    ///
    /// **I10 is untouched by construction**: the source take keeps its
    /// remainder — **even when the span is the whole buffer**, in which case
    /// the take is left EMPTY, which is legal (an empty buffer has been legal
    /// since Phase 1, and the Return chain mints empty blocks on purpose).
    /// Nothing is archived, nothing is tombstoned, and the block gains a take
    /// rather than losing one.
    ///
    /// **Churn and touch** ride `registerTextChange` like any buffer edit —
    /// the moved characters are a deletion from this take's buffer, so the
    /// note stamps `last_touched_at` and accumulates churn (AppSpec §10). The
    /// mint itself adds no churn: a new take is fan growth, and `branchVariant`
    /// has never churned either.
    ///
    /// **Under sync it is three ordinary rows** — a `commit_point` insert, a
    /// `variant` UPDATE (the one mutable field, S5) and a `variant` insert —
    /// all carried by the shipped outbox triggers. Zero engine lines, zero
    /// schema, no repair class (a `fan_position` is plain metadata CAS and a
    /// residual tie is stable by SyncSpec §8's own promise).
    @discardableResult
    public func moveSpanToNewTake(
        from variantID: String, span: Range<Int>, expectedText: String? = nil
    ) throws -> SpanToTakeResult {
        let (result, preImage): (SpanToTakeResult, TextPreImage) = try database.write { db in
            var source = try editableVariant(db, variantID)
            _ = try liveBlock(db, source.blockId)
            let text = source.workingText
            if let expectedText, text != expectedText {
                throw OperationError.bufferChangedSinceGesture(variantID: variantID)
            }
            // The span's own validation — bounds, non-empty, and GRAPHEME
            // alignment through the one brain (`extract`'s check, kept as a
            // check rather than a binding for the same reason: the halves are
            // taken by UTF-16 offset). It is the caller-bug answer, not a
            // road she can walk: the door plans the span from the surface's
            // own tiling and never offers an empty one.
            guard span.lowerBound >= 0, span.lowerBound < span.upperBound,
                  span.upperBound <= (text as NSString).length,
                  BoundarySnapping.graphemeRange(span, in: text) != nil
            else {
                throw OperationError.invalidCut(variantID: variantID, cut: span.lowerBound)
            }

            let now = date.now
            // (1) THE INSURANCE SAVEPOINT — her cover for the stay case.
            var savepoint: CommitPoint?
            if try isDirty(db, source) {
                savepoint = try insertCommit(
                    db, variant: source, kind: .auto, message: nil, now: now)
            }

            // (2) The span leaves the buffer, exactly as selected.
            let whole = text as NSString
            let range = NSRange(location: span.lowerBound, length: span.count)
            let spanText = whole.substring(with: range)
            let remainder = whole.replacingCharacters(in: range, with: "")
            source.workingText = remainder
            source.updatedAt = now
            try source.update(db)
            try registerTextChange(
                db, blockID: source.blockId, charDelta: range.length,
                forceMajorRevision: false, now: now)

            // (3) The mint, at the fan's END, branched from the take it left.
            let take = Variant(
                id: newID(), blockId: source.blockId, parentVariantId: source.id,
                workingText: spanText, status: .active, locked: false, label: nil,
                fanPosition: try fanPosition(db, blockID: source.blockId, at: .end),
                createdAt: now, updatedAt: now)
            try take.insert(db)

            return (
                SpanToTakeResult(take: take, insuranceSavepoint: savepoint),
                TextPreImage(variantID: source.id, text: text, postOpText: remainder)
            )
        }
        // (4) ONE entry — the compound of the two effects, not two entries.
        let mintID = result.take.id
        // VX-246 U2 — an entry with two PARTS (the source's words, the
        // minted take): each half moves only the parts its partner last
        // moved, and the redo revives the take only on its undo's stamp.
        let parts = LockIsolated(SpanParts(text: true, mint: true, mintStamp: nil))
        undoStack?.register(
            label: "Move into a New Take",
            inverse: { ops in
                let undone = try ops.revertSpanToNewTake(mintedTakeID: mintID, preImage: preImage, only: parts.value)
                parts.setValue(undone)
                return undone.changed
            },
            redo: { ops in
                let redone = try ops.reapplySpanToNewTake(mintedTakeID: mintID, preImage: preImage, only: parts.value)
                parts.setValue(redone)
                return redone.changed
            },
            // A12: the buffer this undo would restore, carried as data so the
            // destructive-undo warning can be asked BEFORE the act.
            insuring: [preImage])
        return result
    }

    // MARK: - The entry's two halves (exact-row, from the SAME do-time images)

    /// The inverse: the span comes home to the buffer it left, and the take
    /// it minted is tombstoned. ONE transaction, so the two can never
    /// half-apply.
    ///
    /// Refusal buckets are `revertStructural`'s, unchanged: **resolvable
    /// refusals throw** and keep the entry for retry (a sealed note; a
    /// source take since locked, archived or dead; a mint she has since
    /// CHOSEN — `variantIsChosen`, the `deleteVariant` guard, whose door is
    /// "choose another take first"; an I10 violation, if the source take
    /// died meanwhile). **Divergence is left alone quietly**: a mint already
    /// deleted stays deleted, and a buffer already back at the pre-image
    /// writes nothing.
    ///
    /// The buffer restore carries the FOURTH quiet occasion's insurance
    /// (`wouldInsure`), exactly as `revertStructural`'s does: text she typed
    /// into the source take since the move is committed before it is
    /// overwritten.
    /// Which of the entry's two parts a half changed (VX-246 U2), and the
    /// stamp an undo tombstoned the minted take on.
    struct SpanParts: Sendable {
        var text: Bool
        var mint: Bool
        var mintStamp: String?

        var changed: Bool { text || mint }
    }

    func revertSpanToNewTake(
        mintedTakeID: String, preImage: TextPreImage, only: SpanParts
    ) throws -> SpanParts {
        try database.write { db in
            let now = date.now
            var undone = SpanParts(text: false, mint: false, mintStamp: nil)

            var source = try liveVariant(db, preImage.variantID)
            _ = try liveBlock(db, source.blockId)
            try ensurePlacementUnlocked(db, blockID: source.blockId)
            try ensureEditable(source)
            if only.text, source.workingText != preImage.text {
                if Self.wouldInsure(
                    currentText: source.workingText, preImage: preImage,
                    dirty: try isDirty(db, source)) {
                    _ = try insertCommit(
                        db, variant: source, kind: .auto, message: nil, now: now)
                }
                source.workingText = preImage.text
                source.updatedAt = now
                try source.update(db)
                undone.text = true
            }

            guard only.mint,
                  var mint = try Variant.fetchOne(db, key: mintedTakeID),
                  mint.deletedAt == nil
            else { return undone }  // already gone — the world moved past this entry
            try ensurePlacementUnlocked(db, blockID: mint.blockId)
            let chosenBy = try Int.fetchOne(
                db,
                sql: """
                    SELECT COUNT(*) FROM container_block
                    WHERE chosen_variant_id = ? AND deleted_at IS NULL
                    """,
                arguments: [mintedTakeID]) ?? 0
            guard chosenBy == 0 else {
                throw OperationError.variantIsChosen(id: mintedTakeID)
            }
            try ensureNotLastActive(db, mint)
            mint.deletedAt = now
            mint.updatedAt = now
            try mint.update(db)
            try reassignDefaultIfNeeded(
                db, blockID: mint.blockId, removing: mintedTakeID, now: now)
            undone.mint = true
            undone.mintStamp = DateFormatter.variorumISO8601.string(from: now)
            return undone
        }
    }

    /// The RE-APPLY (13c 1B's law): the SAME rows, from the SAME do-time
    /// images — the minted take's tombstone flips back (never a fresh mint,
    /// which would strand the inverse's captured id) and the source buffer
    /// returns to its post-op text. Refusal buckets mirror the inverse's.
    func reapplySpanToNewTake(
        mintedTakeID: String, preImage: TextPreImage, only: SpanParts
    ) throws -> SpanParts {
        try database.write { db in
            let now = date.now
            var redone = SpanParts(text: false, mint: false, mintStamp: nil)

            if only.mint, let stamp = only.mintStamp,
               var mint = try Variant.fetchOne(db, key: mintedTakeID),
               mint.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp {
                _ = try liveBlock(db, mint.blockId)
                try ensurePlacementUnlocked(db, blockID: mint.blockId)
                mint.deletedAt = nil
                mint.updatedAt = now
                try mint.update(db)
                // 13j ladder B (B1): a restored row voids any live purge
                // intent naming it — a leftover intent must never claim the
                // take a redo just brought back.
                try voidPurgeIntents(db, table: "variant", rowID: mintedTakeID)
                redone.mint = true
            }

            guard only.text else { return redone }
            var source = try liveVariant(db, preImage.variantID)
            _ = try liveBlock(db, source.blockId)
            try ensurePlacementUnlocked(db, blockID: source.blockId)
            try ensureEditable(source)
            guard source.workingText != preImage.postOpText else { return redone }
            if source.workingText != preImage.text, try isDirty(db, source) {
                _ = try insertCommit(db, variant: source, kind: .auto, message: nil, now: now)
            }
            source.workingText = preImage.postOpText
            source.updatedAt = now
            try source.update(db)
            redone.text = true
            return redone
        }
    }
}
