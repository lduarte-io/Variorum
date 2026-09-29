//
//  EditorSurfaceStorage.swift
//  Variorum / VariorumMobile (Shared/EditorBrain)
//
//  **18m U2 — the editor surface's three STORAGE DOORS, once for both
//  platforms.** Both editors kept their own copies of the same three
//  primitives — read a range, stamp (or clear) block identity over a range,
//  and replace a range programmatically with base attributes — identical
//  modulo the ACCESSOR each platform reaches its storage through
//  (`textView?.textStorage` on the Mac, the attached `storage` on the phone)
//  and the base attributes it resets to (the post-13u health review §3; the
//  18m U2 band map). The bodies live here now; each view model keeps its own
//  NAME for each door and its own STATE around it — the Mac's extraction
//  counter, the suppress-edit-processing toggle, the out-of-range guard that
//  heals from the store, the caret-to-end — because those are view-model
//  state, not storage.
//
//  **What is deliberately a PARAMETER, and why:** the base attributes (each
//  platform's voice resolves its own font, ink and paragraph style) and the
//  markdown RESTYLE over a replaced span — each platform's face is its own
//  (`MarkdownStyling` on the Mac, `MarkdownFace` with the phone's palette).
//  The phone always restyled here (mobile batch 2, "the Mac `applySeamEdit`'s
//  exact posture"); the Mac's programmatic replace did not until 18m U2's
//  rider F-3 — the band map's finding, pinned red on three user-reachable
//  roads (`ProgrammaticReplaceFaceTests`) and fixed as exactly this argument.
//
//  Charter (EditorDocumentCore's): NOTHING here may depend on a platform UI
//  framework — both platforms' `NSTextStorage` share the Foundation
//  superclass `NSMutableAttributedString` (the `IdentityProjectionAudit`
//  precedent). Main-actor by declaration: these doors mutate a live surface.
//

import Foundation

@MainActor
enum EditorSurfaceStorage {
    /// **The read** (`viewText`'s body): the text of `range`, or empty when
    /// there is no storage or the range runs past it. O(the asked range).
    static func text(of storage: NSMutableAttributedString?, in range: NSRange) -> String {
        guard let storage else { return "" }
        guard range.upperBound <= storage.length else { return "" }
        return storage.attributedSubstring(from: range).string
    }

    /// **The identity stamp** (`setBlockAttribute`'s body): `blockID` over
    /// `range`, or — for nil — the attribute removed there. A no-op for an
    /// empty range, a missing storage, or a range past the storage's end.
    static func setBlockID(
        _ blockID: String?, over range: NSRange, in storage: NSMutableAttributedString?
    ) {
        guard range.length > 0, let storage,
              range.upperBound <= storage.length else { return }
        if let blockID {
            storage.addAttribute(EditorDocument.blockIDAttribute, value: blockID, range: range)
        } else {
            storage.removeAttribute(EditorDocument.blockIDAttribute, range: range)
        }
    }

    /// **The programmatic replace** (`programmaticReplace`'s storage half):
    /// ONE editing transaction — the characters, then the replaced span reset
    /// to `base` (plus `blockID` when one owns it), then `restyle` over that
    /// span when the platform passes one. The caller owns everything around
    /// it: the range guard, suppressing its own edit processing across the
    /// call, and where the caret lands afterwards.
    static func replace(
        _ range: NSRange,
        with newText: String,
        blockID: String?,
        in storage: NSMutableAttributedString,
        base: [NSAttributedString.Key: Any],
        restyle: ((NSMutableAttributedString, NSRange) -> Void)?
    ) {
        storage.beginEditing()
        storage.replaceCharacters(in: range, with: newText)
        var attributes = base
        if let blockID { attributes[EditorDocument.blockIDAttribute] = blockID }
        let replaced = NSRange(location: range.location, length: (newText as NSString).length)
        storage.setAttributes(attributes, range: replaced)
        restyle?(storage, replaced)
        storage.endEditing()
    }
}
