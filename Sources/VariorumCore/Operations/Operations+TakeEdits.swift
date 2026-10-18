import Dependencies
import Foundation
import GRDB

// Phase 11, Step A9 — the #11 rulings' operation (author, 2026-07-13,
// asked live at the sitting): ONE transaction applying per-take text
// replacements across any number of takes and blocks. Both faces ride it:
// the VISIBLE-TAKE cross-block edit (#11a — the plain gesture's everyday
// behavior on fanned spans: each touched block's visible take loses its
// piece; fan, seam, and block structure untouched) and the named
// "Delete in Every Take" command (#11b — matching takes edited, skipped
// takes reported by the caller).
extension Operations {
    /// One take's replacement: the whole new buffer text plus this edit's
    /// churn cost (inserted + deleted, UTF-16 — AppSpec §10).
    public struct TakeEdit: Equatable, Sendable {
        public let variantID: String
        public let newText: String
        public let charDelta: Int
        /// COMPARE-AND-SET (the edit-during-await guard): when present, the
        /// take's current buffer must equal this or the WHOLE batch refuses
        /// (`bufferChangedSinceGesture`) — a gesture planned against one
        /// surface must never overwrite a newer one (the Phase 5 reject-path
        /// doctrine, applied to the editor's deferred compounds).
        public let expectedText: String?

        public init(
            variantID: String, newText: String, charDelta: Int,
            expectedText: String? = nil
        ) {
            self.variantID = variantID
            self.newText = newText
            self.charDelta = charDelta
            self.expectedText = expectedText
        }
    }

    /// Applies every edit in ONE transaction (all-or-nothing — a refusal on
    /// any target leaves every buffer untouched). Guards per target are
    /// exactly `autosave`'s (live + active + unlocked variant, unsealed
    /// post). **Insurance (the quiet-auto-commit doctrine — a commit
    /// insures exactly what an operation is about to make unreachable):**
    /// any target dirty against its last commit is auto-committed FIRST,
    /// so text removed from an UNSEEN take stays one restore away beyond
    /// the session. Registers ONE structural-undo entry restoring the
    /// pre-image texts (the ruling's "one undo compound"); churn/touch
    /// flow per block like any text edit.
    @discardableResult
    public func editTakesAtomically(_ edits: [TakeEdit], undoLabel: String) throws -> Int {
        guard !edits.isEmpty else { return 0 }
        let preImages: [TextPreImage] = try database.write { db in
            var pre: [TextPreImage] = []
            let now = date.now
            for edit in edits.sorted(by: { $0.variantID < $1.variantID }) {
                var variant = try editableVariant(db, edit.variantID)
                if let expected = edit.expectedText, variant.workingText != expected {
                    throw OperationError.bufferChangedSinceGesture(variantID: edit.variantID)
                }
                // VX-357: the new text with U+0000 removed (`StoredText`) —
                // the no-op check, the row and the entry's pre-image read what
                // is stored; `expectedText` compares with the stored buffer.
                let newText = StoredText.stripped(edit.newText)
                guard variant.workingText != newText else { continue }
                if try isDirty(db, variant) {
                    _ = try insertCommit(db, variant: variant, kind: .auto, message: nil, now: now)
                }
                pre.append(TextPreImage(
                    variantID: variant.id,
                    text: variant.workingText,
                    postOpText: newText))
                variant.workingText = newText
                variant.updatedAt = now
                try variant.update(db)
                try registerTextChange(
                    db, blockID: variant.blockId, charDelta: edit.charDelta,
                    forceMajorRevision: false, now: now)
            }
            return pre
        }
        guard !preImages.isEmpty else { return 0 }
        // 13c 1B (A10): the same pre-images, other field — the buffers
        // go back to their post-edit text.
        // A12: the buffers this undo would restore — the same values,
        // carried as data so the warning can be asked before the act.
        registerStructuralEntry(
            label: undoLabel,
            restoringTexts: preImages,
            insuring: preImages)
        return preImages.count
    }
}
