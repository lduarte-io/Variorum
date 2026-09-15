//
//  MarkdownLinkOpening.swift
//  Variorum (Mac) — Features/Formatting
//
//  **The RULE moved to `App/Variorum/Shared/MarkdownLink.swift` at 13u1
//  UNIT 1** (the 2026-08-30 sweep's P41): the phone carried a
//  statement-for-statement copy of `openableSchemes` + `openable`, against
//  this file's own "one rule, one guard, one door" declaration. What stays
//  here is the half that needs a platform — opening.
//
//  Every Mac call site is untouched: `MarkdownLink.openable` and
//  `MarkdownLink.open` both still resolve, the type is the same type, and
//  no pin moved.
//

import AppKit
import Foundation

extension MarkdownLink {
    /// Open it, and say whether anything happened — the caller consumes the
    /// click only when it did, so a click on an inert link still behaves like
    /// the ordinary click it visually is.
    @discardableResult
    @MainActor
    static func open(_ raw: String) -> Bool {
        guard let url = openable(raw) else { return false }
        return NSWorkspace.shared.open(url)
    }
}
