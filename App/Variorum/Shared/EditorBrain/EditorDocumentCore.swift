//
//  EditorDocumentCore.swift
//  Variorum / VariorumMobile (Shared/EditorBrain)
//
//  The platform-neutral half of `EditorDocument` — the pure mapping between
//  the store's rendered slots and an editor's text surface (Phase 7 Step 2;
//  made shared at the mobile project's Stage 1 batch 1, the parity move: the
//  identity brain compiles into both app targets, and no AppKit/UIKit type
//  may live here). The Mac keeps its fonts/styling and the exact pre-move
//  `materialize(_:tail:)` signature as a forward in
//  `Features/Editor/EditorDocument.swift`; the phone supplies its own base
//  attributes the same way. NOTHING in this file may depend on a platform
//  UI framework.
//
//  Separator doctrine (decided once, tested — Phase 6 review note): blocks
//  are joined by a single "\n" (author-confirmed interpretation 2a, a
//  render-time artifact distinct from the renderedText projection's "\n\n"),
//  and the separator character is owned by NEITHER neighboring block — it
//  carries no block-ID attribute, and BlockRangeIndex excludes it from every
//  block range. Attribute ownership and range math therefore agree by
//  construction: the spike's boundary-membership accident cannot recur.
//
//  Empty takes render as empty slots (Phase 4 ratification): a zero-length
//  range in the index. Zero-length ranges cannot carry attributes, so the
//  index — not the attribute run — is the authority for edit routing; the
//  attributes are the cross-check (and the AppSpec §4 "block IDs ride block
//  ranges" mechanism the spike proved cheap). On iOS the attributes are
//  strictly a DERIVED PROJECTION re-stamped from the index after every edit
//  (the Stage 0 memo's obligation 1 — iOS strips custom keys on every
//  insertion path), which is the same authority rule taken to its letter.
//

import Foundation
import VariorumCore

nonisolated enum EditorDocument {
    /// The custom attribute carrying block identity over block ranges.
    static let blockIDAttribute = NSAttributedString.Key("io.lduarte.variorum.blockID")

    /// The editor-surface separator between blocks (author-confirmed 2a).
    static let separator = "\n"

    /// Materializes an editable surface: blocks in position order joined by
    /// the separator, block-ID attributes over each block's range, an
    /// optional open tail (local-only fresh text) after a trailing
    /// separator. Gap slots (missing block/variant, SyncSpec §5) render as
    /// empty read-only slots — render gaps, never crash.
    ///
    /// `base` is the caller's platform-resolved base attributes (font,
    /// paragraph style, color) — the Mac's `materialize(_:tail:)` forward
    /// passes `baseAttributes` and then applies its markdown face; the
    /// phone passes its own. The returned string is mutable so a platform
    /// wrapper can style it without a copy; the index tiles the returned
    /// bytes exactly.
    static func materializeCore(
        _ slots: [Queries.RenderedBlock],
        tail: String? = nil,
        base: [NSAttributedString.Key: Any]
    ) -> (text: NSMutableAttributedString, index: BlockRangeIndex) {
        let index = BlockRangeIndex(slots: slots, tail: tail)
        let result = NSMutableAttributedString()
        for (i, slot) in slots.enumerated() {
            if i > 0 {
                // The separator: base attributes only — owned by no block.
                result.append(NSAttributedString(string: separator, attributes: base))
            }
            var attributes = base
            attributes[blockIDAttribute] = slot.blockID
            result.append(NSAttributedString(string: slot.text ?? "", attributes: attributes))
        }
        if let tail {
            if !slots.isEmpty {
                result.append(NSAttributedString(string: separator, attributes: base))
            }
            result.append(NSAttributedString(string: tail, attributes: base))
        }
        return (result, index)
    }

    /// Reverse mapping: the block ID the attribute run reports at a character
    /// offset (nil on separators, the tail, and out-of-range offsets).
    /// Zero-length (empty) blocks cannot be seen this way — the index is the
    /// authority; this is the cross-check direction.
    static func blockID(at offset: Int, in text: NSAttributedString) -> String? {
        guard offset >= 0, offset < text.length else { return nil }
        return text.attribute(blockIDAttribute, at: offset, effectiveRange: nil) as? String
    }
}
