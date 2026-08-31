//
//  MobileEditMenuSeam.swift
//  VariorumMobile
//
//  Mobile Stage 2, batch 2 (M2's door; spike item 5) — the custom
//  "Takes…" item on the iOS text edit menu, isolated behind THIS ONE
//  FILE. The mechanism is the documented iOS 26 one:
//  `UITextViewDelegate.textView(_:editMenuForTextIn:suggestedActions:)`
//  returning `UIMenu(children: suggested + custom)` — and NEVER a second
//  `UIEditMenuInteraction` (UITextView owns one; a second is the
//  community-confirmed conflict source, the spike memo's own warning).
//
//  THE SEAM (the memo's Stage-1 obligation 5): current docs annotate the
//  delegate method "Deprecated: iOS 27.0". Everything the door needs —
//  the target resolution, the item, the method itself — lives in this
//  file, so the iOS 27-era successor API is a ONE-FILE swap.
//

import UIKit
import VariorumCore

/// The door's brain, test-visible: WHERE the menu offers Takes (a block
/// resolves at the range — boundary-tolerant) and what the item does
/// (open the browser there).
@MainActor
enum MobileEditMenu {
    static let takesTitle = "Takes…"

    /// The block the menu would act on: the RANGE's start, with the
    /// caret-at-block-end tolerance (`blockIDNearOffset`). nil in the
    /// open tail / gaps — the item simply isn't offered there (P-2: a
    /// door that can never act isn't rendered).
    static func takesTarget(model: MobileEditorViewModel?, range: NSRange) -> String? {
        model?.blockIDNearOffset(range.location)
    }

    /// The extended edit menu's Block submenu title (S4 batch 1 — the ⋯
    /// block menu's second door; M2's long-press reading widened).
    static let blockTitle = "Block"

    /// The selection acts (parity C4b item 4 — her mid-chain ruling 5:
    /// extract + make-block "CROSS via the selection menu"). The
    /// registry's own verbs; rendered ONLY when the range has length
    /// (P-2 — a caret can never span, so a door that could only refuse
    /// isn't offered), and the acts route the ONE shared planner.
    static let extractTitle = "Extract Selection"
    static let makeBlockTitle = "Make Block from Selection"

    /// The composed menu: the system's suggested actions, then Takes…
    /// where a block resolves — the SELECTION acts where a selection
    /// exists (C4b) — and, since S4, the Block submenu (the ⋯ menu's
    /// same rows from the ONE builder).
    ///
    /// **THIS door's flat `Takes…` SURVIVED batch 9's removal of the block
    /// ⋯'s row, deliberately.** Her letter names *"the three ... menu"*,
    /// and her reason is that the takes door is already the keyboard bar's
    /// middle act one inch away from it. Nothing about that reasoning
    /// reaches HERE: this is the SELECTION's menu, summoned on the text she
    /// is holding, and its Takes… is the only takes door in that gesture's
    /// reach. The `includeTakes:` parameter it used to pass is gone because
    /// the block builder no longer has a row to suppress.
    /// Displayed titles are VOICE-CASED (P26/P43,
    /// parity A3 — one register with the block menu's rows).
    static func menu(
        model: MobileEditorViewModel?, range: NSRange, suggested: [UIMenuElement]
    ) -> UIMenu {
        guard let model, let blockID = takesTarget(model: model, range: range) else {
            return UIMenu(children: suggested)
        }
        let cased = MobileEditorStyle.chromeCase
        let takes = UIAction(title: cased(takesTitle)) { [weak model] _ in
            model?.openTakesBrowser(blockID: blockID)
        }
        var custom: [UIMenuElement] = [takes]
        if range.length > 0 {
            custom.append(UIAction(title: cased(extractTitle)) { [weak model] _ in
                guard let model else { return }
                Task { await model.structural.extractSelection(range: range) }
            })
            custom.append(UIAction(title: cased(makeBlockTitle)) { [weak model] _ in
                guard let model else { return }
                Task { await model.structural.makeBlockFromSelection(range: range) }
            })
        }
        custom.append(UIMenu(
            title: cased(blockTitle),
            children: model.blockMenu.menuElements(blockID: blockID)))
        return UIMenu(children: suggested + custom)
    }
}

/// The delegate method itself — on the ONE gate delegate every host
/// already shares (never a second UIEditMenuInteraction, never a second
/// delegate).
extension MobileEditorGateDelegate {
    func textView(
        _ textView: UITextView,
        editMenuForTextIn range: NSRange,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        MobileEditMenu.menu(model: model, range: range, suggested: suggestedActions)
    }
}
