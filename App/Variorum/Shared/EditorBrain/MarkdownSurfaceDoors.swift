//
//  MarkdownSurfaceDoors.swift
//  Variorum / VariorumMobile (Shared/EditorBrain)
//
//  Mobile Stage 1, batch 2 — the PURE half of the markdown doors, shared by
//  both app targets (the batch-1 parity pattern applied to the formatting
//  machinery). The law itself lives in `VariorumCore/Domain`
//  (`MarkdownSyntax` / `MarkdownEditing` — line-scoped plans, the ⏎ verdict,
//  the checkbox toggle, the one outdent unit); what THIS file shares is the
//  line-lookup-and-rebase arithmetic every surface door repeats: find the
//  lines a selection touches, hand the pure brain LINE-relative offsets,
//  and shift its answers back into DOCUMENT offsets. Two platforms
//  rediscovering that rebasing is exactly the two-brains drift class the
//  one-brain rule exists to kill; the platform doors (`MarkdownActs` on the
//  Mac, `MobileMarkdownActs` on the phone) keep only their own input trio.
//
//  Charter (EditorDocumentCore's): NOTHING here may depend on a platform UI
//  framework — Foundation + VariorumCore only. Offsets are UTF-16
//  (`MarkdownSyntax`'s convention), so `NSRange`s go straight in and out.
//

import Foundation
import VariorumCore

nonisolated enum MarkdownSurfaceDoors {
    /// One planned replacement in DOCUMENT offsets.
    struct Edit: Equatable {
        let range: NSRange
        let replacement: String
    }

    /// A formatting act's plan rebased to the document: `edits` ascending
    /// and disjoint (apply LAST FIRST so earlier offsets stay valid — the
    /// pure brain's own contract), `selection` where the selection lands
    /// once every edit is applied.
    struct DocumentPlan: Equatable {
        let edits: [Edit]
        let selection: NSRange
    }

    /// Plans `act` over `selection`: whole lines in, shifted results out
    /// (the `MarkdownStyling.restyle` shape — the cost is the lines the
    /// selection touches, never the note; P1's letter). Nil = an empty plan,
    /// the "not ours" signal the fallthrough doors key on.
    static func plan(
        _ act: MarkdownEditing.Act, document: NSString, selection: NSRange
    ) -> DocumentPlan? {
        guard selection.location != NSNotFound,
              selection.upperBound <= document.length
        else { return nil }
        let lines = document.lineRange(for: selection)
        let low = selection.location - lines.location
        let high = selection.upperBound - lines.location
        let plan = MarkdownEditing.plan(
            act, inLines: document.substring(with: lines), selection: low..<high)
        guard !plan.isEmpty else { return nil }
        return DocumentPlan(
            edits: plan.edits.map {
                Edit(
                    range: NSRange(
                        location: lines.location + $0.range.lowerBound,
                        length: $0.range.count),
                    replacement: $0.replacement)
            },
            selection: NSRange(
                location: lines.location + plan.selection.lowerBound,
                length: plan.selection.count))
    }

    /// The caret line's ⏎ verdict, rebased so `exitList`/`outdentItem`
    /// ranges are DOCUMENT offsets (`continueList`'s lead is text and needs
    /// no shift). The caller guards its own surface conditions (editable,
    /// zero-length selection) — a selection's ⏎ is deliberately ordinary.
    static func returnVerdict(
        document: NSString, caret: Int
    ) -> MarkdownEditing.ReturnKey {
        guard caret >= 0, caret <= document.length else { return .ordinary }
        let lines = document.lineRange(for: NSRange(location: caret, length: 0))
        let verdict = MarkdownEditing.returnKey(
            inLines: document.substring(with: lines),
            at: caret - lines.location)
        switch verdict {
        case .exitList(let lead):
            return .exitList(
                lead: (lines.location + lead.lowerBound)..<(lines.location + lead.upperBound))
        case .outdentItem(let unit):
            return .outdentItem(
                unit: (lines.location + unit.lowerBound)..<(lines.location + unit.upperBound))
        case .ordinary, .continueList:
            return verdict
        }
    }

    /// The 3-for-3 edit a click/tap ON a checkbox's box makes, in document
    /// offsets — or nil where the insertion index does not land STRICTLY
    /// INSIDE a box (an ordinary caret click the caller must not consume;
    /// `MarkdownEditing.checkboxToggle` carries the boundary reasoning).
    static func checkboxToggleEdit(
        document: NSString, insertionIndex: Int
    ) -> Edit? {
        guard document.length > 0, insertionIndex >= 0,
              insertionIndex <= document.length
        else { return nil }
        let lines = document.lineRange(for: NSRange(location: insertionIndex, length: 0))
        guard let edit = MarkdownEditing.checkboxToggle(
            inLines: document.substring(with: lines),
            insertionIndex: insertionIndex - lines.location)
        else { return nil }
        return Edit(
            range: NSRange(
                location: lines.location + edit.range.lowerBound,
                length: edit.range.count),
            replacement: edit.replacement)
    }

    /// The link address an offset falls in (whole span counts, `(url)`
    /// included — `MarkdownEditing.link`'s reasoning), or nil.
    static func linkAddress(document: NSString, at offset: Int) -> String? {
        guard document.length > 0, offset >= 0, offset <= document.length else { return nil }
        let lines = document.lineRange(for: NSRange(location: offset, length: 0))
        return MarkdownEditing.link(
            inLines: document.substring(with: lines),
            at: offset - lines.location)
    }
}
