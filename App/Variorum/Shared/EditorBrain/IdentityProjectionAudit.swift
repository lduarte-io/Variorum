//
//  IdentityProjectionAudit.swift
//  Variorum / VariorumMobile (Shared/EditorBrain)
//
//  Phase 13l, ACT 3 / L-a — the DEBUG identity oracle, HOISTED.
//
//  It was written for the phone (mobile round 2, obligation 1 + the
//  round-2 ladder's M15 Q2) and lived inside `MobileEditorViewModel`, so
//  the Mac — which shares `BlockRangeIndex`, took the same crash fix, and
//  had the SAME corruption reproduced against it Mac-side
//  (`stored → ["Alpha", "Beta beta", "G"]`, her paragraph written to the
//  store as one character) — carried no oracle for the one class its other
//  two are blind to. MobileSoul §3's rule, applied: the brain moves to the
//  shared layer, and each platform keeps its own counter and its own
//  call sites.
//
//  **What it is FOR — the class the other two oracles cannot see.** The
//  editor already has two: `documentLength == storage.length` (totals) and
//  `desyncRecoveryCount` (an edit the router refused). Both are satisfied
//  by a MIS-ROUTED ZERO-NET edit — the tiling slips against the storage,
//  the totals still agree, nothing is refused, and the wrong block's text
//  goes to the store through the ledger with no announcement anywhere.
//  That is exactly the shape the traced Mac-side corruption produced.
//
//  NOTHING here may depend on a platform UI framework: `NSTextStorage` is
//  AppKit on macOS and UIKit on iOS, so the storage arrives typed as its
//  Foundation superclass `NSMutableAttributedString` (both platforms'
//  storages are one). The same rule `EditorDocumentCore.swift` states.
//

import Foundation

nonisolated enum IdentityProjectionAudit {
    /// Walks the tiling and answers whether the attribute PROJECTION still
    /// agrees with the index AUTHORITY: every entry's range uniformly
    /// carries its block ID (no MISSING runs — the measured iOS failure
    /// mode is pure absence, never bleed), **every separator position IS a
    /// separator** and carries no block ID, the tail carries none, and the
    /// index tiles the storage exactly. O(blocks) per call, and the call
    /// sites are DEBUG-only.
    ///
    /// **Why the separator's CHARACTER is checked** (mobile round 2's
    /// ladder round 2, M15 Q2 — the reviewer's adopted home for the
    /// boundary check): the two oracles that already exist are both blind
    /// to a tiling that has slipped against the storage's real newlines.
    /// `documentLength == storage.length` compares TOTALS, which a
    /// mis-routed zero-net edit leaves agreeing; and the attribute walk
    /// compares the projection to the index, which a re-stamp has by then
    /// made self-consistent with the corrupted index. The character at an
    /// entry's upper bound answers a question neither asks — *does the
    /// storage still agree that a block ends here* — and it costs one O(1)
    /// read of an offset this walk already computed.
    ///
    /// **It is deliberately PARTIAL, and that is not a defect.** Under I4
    /// internal newlines are content, so a boundary that has slipped onto a
    /// block-INTERNAL newline still reads `\n` and passes. It catches the
    /// misalignment onto ordinary prose — which is the shape both traced
    /// corruption cases produce — and claims nothing more.
    ///
    /// **The empty-entry hole, closed at the hoist** (13l L-a's carried
    /// half): the walk used to skip the whole iteration for a zero-length
    /// entry, which left an EMPTY block's separator unaudited — and an
    /// empty block is precisely where the index, not the attribute run, is
    /// the sole authority (a zero-length range can carry no attribute), so
    /// its boundary is the one most worth reading. Only the attribute walk
    /// is conditional now.
    static func isClean(index: BlockRangeIndex, storage: NSMutableAttributedString) -> Bool {
        guard index.documentLength == storage.length else { return false }
        // Running-location walk: `range(ofEntryAt: i)` is O(i), so a
        // per-entry call would make this per-keystroke audit O(entries²)
        // — ~1.9M additions per keystroke at 1,370 blocks, real DEBUG
        // milliseconds on the keystroke road. Same ranges, same checks,
        // one walk.
        var runningLocation = 0
        let separatorScalar = EditorDocument.separator.utf16.first
        // Hoisted, both of them: the walk must add no per-entry bridging
        // (M15 Q2(c)'s implementation constraint). `mutableString` is the
        // storage's own backing string — an O(1) accessor, never a copy,
        // and never `storage.string`.
        let characters = storage.mutableString
        for i in index.entries.indices {
            let entry = index.entries[i]
            let range = NSRange(location: runningLocation, length: entry.length)
            runningLocation += entry.length + 1
            if range.length > 0 {
                var uniform = true
                storage.enumerateAttribute(
                    EditorDocument.blockIDAttribute, in: range
                ) { value, _, stop in
                    if (value as? String) != entry.blockID {
                        uniform = false
                        stop.pointee = true
                    }
                }
                if !uniform { return false }
            }
            // The separator after this entry (if any) is owned by no block
            // — AND is a separator. Read through `mutableString`, never
            // `storage.string`: the bridge would be O(document) per
            // keystroke at the 100k fixture.
            if i < index.entries.count - 1 || index.tailLength != nil {
                let separatorAt = range.upperBound
                if separatorAt < storage.length {
                    if EditorDocument.blockID(at: separatorAt, in: storage) != nil {
                        return false
                    }
                    if let separatorScalar,
                       characters.character(at: separatorAt) != separatorScalar {
                        return false
                    }
                }
            }
        }
        if let tail = index.tailRange, tail.length > 0 {
            var unowned = true
            storage.enumerateAttribute(
                EditorDocument.blockIDAttribute, in: tail
            ) { value, _, stop in
                if value != nil {
                    unowned = false
                    stop.pointee = true
                }
            }
            if !unowned { return false }
        }
        return true
    }

    /// The one sentence both platforms fire when the walk says no — shared
    /// so the two seams can never drift into different words for the same
    /// state (the `RecoveryCopy` hoist's rule, one layer down).
    static let failureMessage =
        "identity projection audit failed: block-ID attributes disagree with BlockRangeIndex"
}

#if DEBUG
extension IdentityProjectionAudit {
    /// **The CONSUMER, once for both platforms** (18m U2). Both view models
    /// ran the same five lines around the walk — no storage, nothing to say;
    /// a clean walk, nothing to say; otherwise count the disagreement, then
    /// fire the honest road's debug voice — differing only in the accessor
    /// that reaches the storage. The COUNTER stays each platform's own
    /// (`identityAuditFailures`, the pins' oracle), so it arrives as
    /// `countingFailure`, and it runs BEFORE the seam fires — the order both
    /// consumers always had. The call site's `#fileID`/`#line` are handed to
    /// the seam, so an assertion still points at the view model that asked.
    ///
    /// DEBUG-only, like both call sites always were: in Release neither view
    /// model's audit does any work at all (the same `#if` wraps each call).
    @MainActor
    static func audit(
        index: BlockRangeIndex,
        storage: NSMutableAttributedString?,
        countingFailure: () -> Void,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        guard let storage else { return }
        guard !isClean(index: index, storage: storage) else { return }
        countingFailure()
        EditorAssertionSeam.fire(failureMessage, file: file, line: line)
    }
}
#endif
