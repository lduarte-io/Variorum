//
//  EditorDocument.swift
//  Variorum
//
//  The Mac's platform half of `EditorDocument`. The pure mapping itself —
//  the attribute key, the separator doctrine, `materializeCore`, and the
//  reverse `blockID(at:in:)` — moved to `Shared/EditorBrain/
//  EditorDocumentCore.swift` at the mobile project's Stage 1 batch 1 (the
//  parity move), so both app targets compile ONE brain. This file keeps
//  everything AppKit-flavored — the voice-resolved fonts, the paragraph
//  gap, the markdown face — and preserves every pre-move name as a forward:
//  `materialize(_:tail:)` is byte-for-byte the old behavior (core
//  materialization with `baseAttributes`, then `MarkdownStyling.style`).
//

import AppKit
import Foundation
import VariorumCore

nonisolated extension EditorDocument {
    /// The one base font — voice-resolved since Phase 13 C1 (the editor
    /// surfaces get their voice in Stage C; `EditorTypography.current` is
    /// the single source every surface write shares).
    static var baseFont: NSFont { EditorTypography.current.font }

    /// The uniform paragraph gap (author ruling 2026-07-12, QUESTIONS #12's
    /// presentation half): a PURE-STYLE spacing after every paragraph —
    /// stored nowhere; stored blank lines add on top, like any normal
    /// editor. Deliberately per-PARAGRAPH, not per-block-seam: AppSpec §12
    /// keeps block boundaries INVISIBLE at rest, and a gap applied only at
    /// seams would make every boundary inferable — a uniform gap after
    /// every paragraph (intra-block newlines and seams alike) reveals
    /// nothing. The size rides the voice's font (and widens uniformly when
    /// inline comments are on — EditorTypography's letter).
    ///
    /// 13d batch 4 (A23): plus this Mac's `ParagraphGap` choice, read HERE
    /// rather than cached in `EditorTypography.current` — every surface
    /// rebuilds this style, so reading at construction means there is no
    /// global to keep in sync and no ordering hazard between the setting
    /// changing and a surface re-styling. Still per-PARAGRAPH, still stored
    /// nowhere.
    static var baseParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        let typography = EditorTypography.current
        style.paragraphSpacing = typography.paragraphSpacing
            + ParagraphGap.current.extraSpacing(for: typography.font)
        return style
    }

    /// The base attributes EVERY surface write uses — materialization,
    /// programmatic replaces, differential structural applies, and the
    /// read tier. One source so no path can drop the paragraph style.
    static var baseAttributes: [NSAttributedString.Key: Any] {
        [.font: baseFont, .paragraphStyle: baseParagraphStyle]
    }

    /// The pre-move materialization, exactly as it always behaved: the
    /// shared core with this Mac's base attributes, then the markdown face.
    ///
    /// 13g batch 2 (L7, F-2): the markdown editing face. ATTRIBUTES ONLY —
    /// the string bytes are untouched, so the index built by the core still
    /// tiles the surface exactly. Applied HERE, at the one materialization
    /// every Mac surface's full render goes through (this editor and the
    /// read tier), so a future surface inherits the face by construction
    /// rather than by remembering to ask for it. Text with no markdown
    /// writes nothing.
    static func materialize(
        _ slots: [Queries.RenderedBlock],
        tail: String? = nil
    ) -> (text: NSAttributedString, index: BlockRangeIndex) {
        let (result, index) = materializeCore(slots, tail: tail, base: baseAttributes)
        MarkdownStyling.style(result)
        return (result, index)
    }
}
