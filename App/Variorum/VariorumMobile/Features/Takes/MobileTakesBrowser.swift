//
//  MobileTakesBrowser.swift
//  VariorumMobile
//
//  Mobile Stage 2, batch 2 (M4 + LK4): the takes BROWSER's brain — the
//  sheet-over-page surface carrying all four ruled verbs. A SIBLING type
//  beside `MobileTakesController` and `MobileEditorViewModel` (the S1
//  ladder's binding NIT-3: composition, never VM growth); the pixels live
//  in `MobileTakesBrowserView`.
//
//  THE FOUR VERBS (M4), every one a STANDING operation with its real
//  refusal speaking (P-2; no invented behavior):
//  - ✓ CHOOSE on any card — `Operations.chooseVariant` (I3: the choice
//    lives on the pointer). A successful choose ends any peek on the
//    block: the explicit ✓ is THE deciding act, so the page shows the
//    store's truth afterwards (M6's unambiguity, the browser's reading).
//  - NEW TAKE — the two Mac gestures verbatim: branch-this-one
//    (`branchVariant`, inheriting the DISPLAYED take's text — the page's
//    "this one") and blank (`newBlankVariant`, the genuinely-different
//    gesture). Minting NEVER chooses (R90); the minted card goes live for
//    editing so she is typing instantly (the Mac's ring-follow, the
//    phone's reading).
//  - EDIT ANY TAKE — a tapped card upgrades to the ONE live editor (P3:
//    exactly one live pane anywhere; the in-page editor stands down while
//    the browser is open). Card edits route to THAT take's autosave via
//    the VM's one ledger (batch 1's variant-routed pattern) — never
//    silently the chosen one (R8/R23).
//  - ARCHIVE / DELETE under each card's ⋯ — `archiveVariant` /
//    `deleteVariant`; I10 (the last active take) and the chosen-slot
//    guard refuse through the ops' own errors. Recovery surfaces
//    (deleted/archived take resurrection) stay Mac-side in v1 — a
//    DELIBERATE ABSENCE recorded for the stage gate, not a hole.
//
//  Verbs each end in a fresh store read through the VM's one projection
//  door (`refreshTakesFromStore` — flush first so the delivery adopts
//  cleanly), so the browser is correct with or without the standing
//  observation running (headless tests drive it deterministically; in
//  production the observation's delivery is an echo).
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileTakesBrowserController {
    private let runner: OperationsRunner
    weak var model: MobileEditorViewModel?

    /// The block the sheet is open on. nil = closed.
    private(set) var openBlockID: String?
    /// The take whose card is the LIVE editor right now. nil = all cards
    /// read-only (P3's split inside the sheet).
    private(set) var editingVariantID: String?

    /// The pixels' hook: state or content changed — re-render the sheet.
    var onChanged: (() -> Void)?

    /// The card gate's exact-cost capture (the VM's `pendingEditCost`
    /// pattern): policed card edits carry the gate's own figure; gateless
    /// system paths fall back to a length-delta approximation (churn is
    /// approximate by design, SyncSpec §6).
    private var pendingCardCost: Int?
    private var lastRecordedCardText: String?

    var isOpen: Bool { openBlockID != nil }

    init(runner: OperationsRunner) {
        self.runner = runner
    }

    // MARK: - The card model (brain here, pixels in the view)

    struct Card: Equatable {
        let variantID: String
        /// 1-based fan position (the mockup's "take 3" meta).
        let ordinal: Int
        /// Ledger-first (the surface family's own record — an edited,
        /// unflushed take shows its current bytes; batch 1's rule).
        let text: String
        let label: String?
        /// The STORE's chosen truth (originals-aware while a peek covers
        /// the slot) — the ✓-ringed card.
        let isChosen: Bool
        /// The in-page peek's card (M9's sticky peek, visible in the
        /// sheet too — the mockup's "peeking" state).
        let isPeeked: Bool
        let isLocked: Bool
    }

    /// The open block's cards in fan order. Empty when closed.
    func cards() -> [Card] {
        guard let model, let blockID = openBlockID,
              let fan = model.takes.fans[blockID]
        else { return [] }
        let chosen = model.takes.chosenVariantID(blockID)
        let peek = model.takes.peeks[blockID]
        return fan.enumerated().map { i, take in
            Card(
                variantID: take.id,
                ordinal: i + 1,
                text: model.surfaceKnownText(variantID: take.id) ?? take.workingText,
                label: take.label,
                isChosen: take.id == chosen,
                isPeeked: take.id == peek,
                isLocked: take.locked)
        }
    }

    /// "block k of n" for the sheet's header (the mockup's shead; the
    /// voice casing is the view's).
    func headerOrdinal() -> (k: Int, n: Int)? {
        guard let model, let blockID = openBlockID,
              let i = model.slots.firstIndex(where: { $0.blockID == blockID })
        else { return nil }
        return (i + 1, model.slots.count)
    }

    // MARK: - Open / close

    /// The expand door (badge tap, the bar's ⑂, the edit-menu item all
    /// land here). Opens on any non-gap block — a single-take block opens
    /// too: the browser IS the fan-birth door (the 9d "Show Takes"
    /// chicken-and-egg, the phone's edition).
    func open(blockID: String) {
        guard let model else { return }
        guard let slot = model.slot(for: blockID) else { return }
        guard !slot.isGap else {
            // The standing read-only-slot copy — the one block the verbs
            // cannot act on (no variant to branch from, nothing to show).
            model.report("This block hasn't fully synced; it is read-only for now.")
            return
        }
        if openBlockID != nil { endEditing() }
        openBlockID = blockID
        onChanged?()
    }

    /// Done: the live card resigns, pending edits flush, the page heals
    /// from the store (walk 6's "the page shows the new chosen text"),
    /// the in-page editor is restored by the view.
    func close() async {
        guard isOpen else { return }
        endEditing()
        openBlockID = nil
        onChanged?()
        await model?.refreshTakesFromStore()
    }

    /// The synchronous escape (the open block vanished from the surface —
    /// deleted elsewhere): clear state, no flush round.
    func forceClose() {
        guard isOpen else { return }
        editingVariantID = nil
        openBlockID = nil
        pendingCardCost = nil
        lastRecordedCardText = nil
        onChanged?()
    }

    /// Every projection ingest routes here (VM routing): re-render open
    /// sheets; close when the block left the surface.
    func projectionDidChange() {
        guard let blockID = openBlockID else { return }
        if model?.slot(for: blockID) == nil {
            forceClose()
        } else {
            // The live card's take may have vanished (archived/deleted on
            // another device) — its editor resigns with it.
            if let editing = editingVariantID,
               cards().first(where: { $0.variantID == editing }) == nil {
                endEditing()
            }
            onChanged?()
        }
    }

    // MARK: - ✓ choose (M6: the ONLY choosing act, the browser's door)

    func choose(variantID: String) async {
        guard let model, let blockID = openBlockID else { return }
        do {
            try await runner.run { ops in
                try ops.chooseVariant(blockID, variantID: variantID)
            }
            model.report(nil)
            // The explicit ✓ decides what the page shows: any peek on the
            // block ends, and the refresh below delivers the store's
            // truth through the ordinary projection door.
            model.takes.endPeek(blockID)
            await model.refreshTakesFromStore()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, verb: .choose))
        }
    }

    // MARK: - New take (the two Mac gestures)

    /// Branch-this-one: inherits the DISPLAYED take's text (the page's
    /// "this one" — the peeked take while peeking, else the shown chosen;
    /// PROVISIONAL reading of the mockup's footer, recorded). The mint
    /// goes live for editing; chosen never moves (R90).
    @discardableResult
    func branchDisplayed() async -> Variant? {
        guard let model, let blockID = openBlockID,
              let displayed = model.slot(for: blockID)?.variantID
        else { return nil }
        // FLUSH FIRST (S2 ladder round 1, MAJOR — the 13f R1-4 class): a
        // copy door offered at a possibly-dirty moment must carry the
        // keystrokes that summoned it. `branchVariant` copies
        // `working_text` from the STORE, which lags the surface until the
        // flush lands — without this, the source card showed the edited
        // bytes (ledger-first) while the fresh "branch of this one" held
        // older ones. Blank copies no text and needs nothing; ✓ repoints
        // and reads no text (batch 1's interpretation 6 stands).
        await model.autosave.flushNow()
        // Q-M1 — RULED (a) at the gate sitting ("seed-from-ledger"; her
        // words: "I think that's fine for it to say as A"): under a
        // REFUSED flush — you typed into a take a remote lock then froze;
        // the refusal itself recommends branching — the branch carries
        // what the card SHOWS. The shown bytes are the surface's own
        // record (ledger-first, exactly what `cards()` renders); the mint
        // is fresh and unlocked, so they ride into it through the same
        // ordinary card-edit road and land at the refresh's flush. A
        // successful flush makes this a byte-for-byte no-op (shown ==
        // store == the branch's copy).
        let shown = model.surfaceKnownText(variantID: displayed)
        do {
            let take = try await runner.run { ops in
                try ops.branchVariant(blockID, from: displayed)
            }
            model.report(nil)
            if let shown, shown != take.workingText {
                model.recordTakeEdit(
                    variantID: take.id, text: shown,
                    charDelta: abs(shown.utf16.count - take.workingText.utf16.count))
            }
            await model.refreshTakesFromStore()
            beginEditing(variantID: take.id)
            return take
        } catch {
            model.report(Self.refusalMessage(error, verb: .branch))
            return nil
        }
    }

    /// Blank: the genuinely-different-take gesture, at the fan's end.
    @discardableResult
    func newBlank() async -> Variant? {
        guard let blockID = openBlockID else { return nil }
        return await mint(verb: .blank) { ops in
            try ops.newBlankVariant(blockID)
        }
    }

    private func mint(
        verb: Verb, _ body: @escaping @Sendable (Operations) throws -> Variant
    ) async -> Variant? {
        guard let model else { return nil }
        do {
            let take = try await runner.run(body)
            model.report(nil)
            await model.refreshTakesFromStore()
            beginEditing(variantID: take.id)
            return take
        } catch {
            model.report(Self.refusalMessage(error, verb: verb))
            return nil
        }
    }

    // MARK: - Edit any take (P3: the one live pane moves into the sheet)

    /// Upgrades a card to the live editor. Refuses upfront where typing
    /// could never land (the standing copies — a gate at the door, not a
    /// lecture after typed text is refused at flush).
    func beginEditing(variantID: String) {
        guard let model else { return }
        guard let card = cards().first(where: { $0.variantID == variantID }) else { return }
        if model.isSealed {
            model.report("This note is locked — unlock it to edit.")
            return
        }
        if card.isLocked {
            model.report("This take is locked — branch it or unlock it on the Mac to edit.")
            return
        }
        editingVariantID = variantID
        pendingCardCost = nil
        lastRecordedCardText = card.text
        onChanged?()
    }

    func endEditing() {
        guard editingVariantID != nil else { return }
        editingVariantID = nil
        pendingCardCost = nil
        lastRecordedCardText = nil
        onChanged?()
    }

    /// The card editor's gate (its UITextViewDelegate consult) — the
    /// sealed/locked belt re-checked per keystroke, and the exact cost
    /// captured for the record (the VM gate's pattern).
    func cardGateAllows(range: NSRange, replacement: String) -> Bool {
        guard let model, let variantID = editingVariantID else { return false }
        if model.isSealed {
            model.report("This note is locked — unlock it to edit.")
            return false
        }
        // The LOCKED half, made real (S2 ladder round 1, MINOR 1): a take
        // locked WHILE its card is live — a remote lock arriving by
        // delivery (fans adopt even when the slot apply defers) — refuses
        // the NEXT keystroke here with the standing copy, instead of
        // admitting text the flush can only refuse. Text typed BEFORE the
        // lock stays pending (the coordinator's keep-pending posture) and
        // the card keeps showing it ledger-first; refusing new keystrokes
        // drops nothing.
        if cards().first(where: { $0.variantID == variantID })?.isLocked == true {
            model.report("This take is locked — branch it or unlock it on the Mac to edit.")
            return false
        }
        pendingCardCost = range.length + (replacement as NSString).length
        return true
    }

    /// The card editor's text-changed report: the edit routes to the
    /// LIVE take's autosave through the VM's one ledger — the batch-1
    /// variant-routed pattern, so the in-page peek overlay and the sheet
    /// can never disagree about a take's bytes.
    func cardTextDidChange(_ text: String) {
        guard let model, let variantID = editingVariantID else { return }
        let cost = pendingCardCost
            ?? abs(text.utf16.count - (lastRecordedCardText?.utf16.count ?? 0))
        pendingCardCost = nil
        lastRecordedCardText = text
        model.recordTakeEdit(variantID: variantID, text: text, charDelta: cost)
    }

    // MARK: - Archive / delete (each card's ⋯)

    func archive(variantID: String) async {
        await lifecycle(variantID: variantID, verb: .archive) { ops in
            try ops.archiveVariant(variantID)
        }
    }

    func delete(variantID: String) async {
        await lifecycle(variantID: variantID, verb: .delete) { ops in
            try ops.deleteVariant(variantID)
        }
    }

    private func lifecycle(
        variantID: String, verb: Verb,
        _ body: @escaping @Sendable (Operations) throws -> Void
    ) async {
        guard let model else { return }
        if editingVariantID == variantID { endEditing() }
        do {
            try await runner.run(body)
            model.report(nil)
            await model.refreshTakesFromStore()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, verb: verb))
        }
    }

    // MARK: - Refusal copy (the ops' REAL refusals, in the phone's words)

    enum Verb { case choose, branch, blank, archive, delete }

    /// The everyday refusals get phone words (the batch-1 posture: the
    /// named cases speak plainly and name the Mac where the road lives
    /// there); rarer races speak in the operations layer's own words —
    /// the op's real message, never invented behavior.
    static func refusalMessage(_ error: Error, verb: Verb) -> String {
        guard let error = error as? OperationError else {
            return String(describing: error)
        }
        switch error {
        case .lockedPost:
            let act = switch verb {
            case .choose: "choose a take"
            case .branch, .blank: "add a take"
            case .archive: "archive a take"
            case .delete: "delete a take"
            }
            return "This note is locked — unlock it to \(act)."
        case .lastActiveVariant:
            // I10's letter: removing the last active take is not a take
            // operation — it is deleting the block. Since S4 batch 1 the
            // phone HAS that door (the ⋯ menu), so the copy names it
            // instead of the Mac (the S2 wording retired with the road
            // it pointed down — a sanctioned copy update, pins flipped).
            return "This is the block's only take — a block always keeps one. "
                + "To remove it all, use Delete Block in the ⋯ menu."
        case .variantIsChosen:
            // The chosen-slot guard (re-point first).
            return "This take is what the note shows — choose another take first, "
                + "then delete this one."
        case .lockedVariant:
            return "That take is locked — unlock it on the Mac first."
        case .archivedVariant:
            return "That take is archived — unarchive it on the Mac first."
        default:
            return String(describing: error)
        }
    }
}
