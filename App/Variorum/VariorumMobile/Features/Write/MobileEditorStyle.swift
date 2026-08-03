//
//  MobileEditorStyle.swift
//  VariorumMobile
//
//  The phone's base attributes for the Write surface — the platform half
//  `EditorDocument.materializeCore` asks its caller for (the Mac's is
//  `EditorDocument.baseAttributes` in Features/Editor/EditorDocument.swift).
//
//  Deliberately minimal: the mobile look (voices, LK2's switch, the styling
//  canon) is the LOOK TRACK's (ledger L13) and lands with her sittings;
//  batch 1 renders functional Dynamic-Type body text. The ONE presentation
//  rule carried over is the Mac's ratified uniform paragraph gap
//  (2026-07-12, QUESTIONS #12): spacing applied after EVERY paragraph —
//  intra-block newlines and seams alike — so block boundaries stay
//  invisible at rest (a gap only at seams would make every boundary
//  inferable). PROVISIONAL size: a font-derived constant, the look track's
//  to restyle.
//

import UIKit

nonisolated enum MobileEditorStyle {
    static var baseFont: UIFont { .preferredFont(forTextStyle: .body) }

    static var baseParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        // Uniform per-PARAGRAPH gap (the 2026-07-12 rule's letter);
        // font-derived so Dynamic Type scales it. PROVISIONAL size (L13).
        style.paragraphSpacing = (baseFont.pointSize * 0.35).rounded()
        return style
    }

    /// The base attributes EVERY mobile surface write uses —
    /// materialization and programmatic replaces. One source so no path
    /// can drop the paragraph style (the Mac's exact doctrine).
    static var baseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: baseFont,
            .foregroundColor: UIColor.label,
            .paragraphStyle: baseParagraphStyle,
        ]
    }
}
