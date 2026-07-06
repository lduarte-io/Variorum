//
//  EditorDocument.swift
//  Variorum
//
//  Pure mapping between the store's rendered slots and the editor's text
//  surface (Phase 7 Step 2).
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
//  ranges" mechanism the spike proved cheap).
//

import AppKit
import Foundation
import VariorumCore

nonisolated enum EditorDocument {
    /// The custom attribute carrying block identity over block ranges.
    static let blockIDAttribute = NSAttributedString.Key("io.lduarte.variorum.blockID")

    /// The editor-surface separator between blocks (author-confirmed 2a).
    static let separator = "\n"

    /// The one base font of the unstyled technical-phase editor.
    static var baseFont: NSFont { .preferredFont(forTextStyle: .body) }

    /// Materializes the editable surface: blocks in position order joined by
    /// the separator, block-ID attributes over each block's range, an
    /// optional open tail (local-only fresh text) after a trailing separator.
    /// Gap slots (missing block/variant, SyncSpec §5) render as empty
    /// read-only slots — render gaps, never crash.
    static func materialize(
        _ slots: [Queries.RenderedBlock],
        tail: String? = nil
    ) -> (text: NSAttributedString, index: BlockRangeIndex) {
        let index = BlockRangeIndex(slots: slots, tail: tail)
        let result = NSMutableAttributedString()
        let base: [NSAttributedString.Key: Any] = [.font: baseFont]
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
