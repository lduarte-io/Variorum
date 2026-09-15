//
//  FlowParagraphFace.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  **The BRAIN moved to `App/Variorum/Shared/FlowParagraph.swift` at 13u1
//  UNIT 1** (the 2026-08-30 sweep's P41 — the phone carried a byte-identical
//  mirror and said so in its own header). What stays here is the Mac's FACE:
//  the reading page's type scale, which the two platforms deliberately
//  disagree about (15 pt base here, 16 pt on the phone). Every Mac consumer
//  and every Mac pin is untouched by the move — the address changed, not a
//  byte of the behaviour.
//

import SwiftUI
import VariorumCore

extension FlowParagraph {
    func font(_ page: ReadingPageTokens) -> Font {
        switch style {
        case .heading(let level):
            let scale: CGFloat = level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15)
            return .system(size: (15 * scale).rounded(), weight: .semibold, design: .serif)
        case .body, .bullet, .checkbox:
            return page.serif
        }
    }
}
