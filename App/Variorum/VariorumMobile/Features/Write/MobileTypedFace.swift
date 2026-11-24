//
//  MobileTypedFace.swift
//  VariorumMobile
//
//  **VM-243 (D-243-1) — the face a typed character wears is derived where it
//  lands** (the record `notes/plans/vm-24-unwarned-edit-routing.md` §4.4–§4.5;
//  her words: "after I use a dash, the rest of the text after that is also in
//  a faint wash and sometimes it doesn't go away for the rest of the note,
//  sometimes it does").
//
//  THE MECHANISM (§4.4, confirmed by its pin, `MobileTypedTextFaceTests`). The
//  markdown face marks every run it styles and its restyle clears only marked
//  runs (`MarkdownFaceCore`). On iOS a typed character takes UIKit's typing
//  attributes — font and ink, derived from the character before the caret —
//  and never the face's custom mark (MobileSoul §5 item 2: text you didn't
//  type is attribute-stripped; the Stage 0 spike's `keys=NSColor,NSFont`). So
//  a word typed after a dash line's `"- "`, after a closing `*`, or on the line
//  after a heading lands in the marker's ink (and the heading's font) WITHOUT
//  the mark; no restyle ever clears it, and every next character inherits it.
//  The Mac never has it: AppKit's typing attributes carry the mark, so the same
//  clear resets the inherited run.
//
//  THE RULE, applied by `storageDidEdit` to every routed edit BEFORE the line's
//  `MarkdownFace.restyle`: the CHANGED CHARACTERS (and nothing wider — never the
//  widened report) are reset to the surface's base face — the base font and
//  ink, strikethrough and the code chip's background removed — and the restyle
//  then derives whatever face those lines truly have. Identity on this platform
//  is a re-stamped projection, never an inheritance; so is the face.
//
//  · Equality-gated: characters already wearing the base write nothing, so
//    plain prose typed in plain prose costs one attribute walk over the typed
//    characters and no storage edit.
//  · Never the paragraph style (the reservations own it —
//    `MobileEditorTextView.setReservation`), never the block identity (the
//    re-stamp's), never the face's mark (the restyle's own bookkeeping).
//  · ∝ the changed characters (P1).
//
//  Pure over a storage and the values it is handed, so its pins run on a bare
//  `NSTextStorage` (`MobileTypedFaceRuleTests`).
//

import UIKit

nonisolated enum MobileTypedFace {
    /// Resets the face attributes of `range` to the base, writing only the
    /// runs that differ from it. `font` and `ink` are what a reset writes;
    /// `baseInks` are every colour object that already counts as the base
    /// ink (the surface's ink and the face's own prose ink, which draws the
    /// same — a cleared face run wears it). Returns whether it wrote; a run of
    /// `false` means the storage saw no edit at all.
    @discardableResult
    static func reset(
        _ storage: NSTextStorage, range: NSRange,
        font: UIFont, ink: UIColor, baseInks: [UIColor]
    ) -> Bool {
        let length = storage.length
        let start = min(max(range.location, 0), length)
        let end = min(max(range.location + max(range.length, 0), start), length)
        guard start < end else { return false }
        let scope = NSRange(location: start, length: end - start)

        // Read first — enumerating attributes while writing them is not a
        // contract NSAttributedString makes (the face's own posture).
        var dirty: [NSRange] = []
        storage.enumerateAttributes(in: scope, options: []) { attributes, run, _ in
            if !wearsTheBase(attributes, font: font, baseInks: baseInks) {
                dirty.append(run)
            }
        }
        guard !dirty.isEmpty else { return false }

        // One editing session: the storage reports ONE attribute edit.
        storage.beginEditing()
        defer { storage.endEditing() }
        for run in dirty {
            storage.addAttribute(.font, value: font, range: run)
            storage.addAttribute(.foregroundColor, value: ink, range: run)
            storage.removeAttribute(.strikethroughStyle, range: run)
            storage.removeAttribute(.backgroundColor, range: run)
        }
        return true
    }

    /// Whether one run already wears the base face: the base font, a base ink,
    /// no strikethrough, no chip.
    static func wearsTheBase(
        _ attributes: [NSAttributedString.Key: Any], font: UIFont, baseInks: [UIColor]
    ) -> Bool {
        guard let runFont = attributes[.font] as? UIFont,
              runFont === font || runFont.isEqual(font)
        else { return false }
        guard let runInk = attributes[.foregroundColor] as? UIColor,
              baseInks.contains(where: { $0 === runInk || $0.isEqual(runInk) })
        else { return false }
        return attributes[.strikethroughStyle] == nil && attributes[.backgroundColor] == nil
    }
}
