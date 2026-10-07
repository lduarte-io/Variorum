//
//  MobileBlockMenu.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 — the ⋯ BLOCK MENU: Comments… · Callout ▸ ·
//  Name Block… · Commit Take · New Block Below · Divide Block · Merge
//  with Previous · Archive Block · Delete Block, on the caret's block,
//  through TWO doors that cannot drift (the CalloutMenu one-vocabulary
//  precedent): the keyboard bar's ⋯ and the extended edit menu both
//  render `menuElements` — ONE builder decides the words and the order.
//
//  **TWO ROWS LEFT THIS MENU AT ROUND 2 BATCH 9, BOTH BY HER LETTER**
//  (2026-08-23, `notes/author-reports/2026-08-23-device-walk-and-product-
//  asks.md`), and the absences are recorded here rather than left to be
//  re-derived from a diff:
//
//  · **`Takes…` is GONE** — her words: *"i also don't think takes needs to
//    be an option on the three dot menu, it's already the middle bar."* It
//    literally is: the keyboard bar rests on **Aa · ⑂ · ⋯** and ⑂ is the
//    middle act, opening the same browser on the same caret block
//    (`MobileKeyboardBarController.fireTakes`). The row was a second door
//    onto one surface, one inch away from the first. The
//    `includeTakes:` parameter went with it — it existed ONLY to keep this
//    row out of the edit menu's Block submenu, which carries its own flat
//    `Takes…` (`MobileEditMenu.takesTitle`, untouched: that door is the
//    SELECTION's, not this menu's, and she did not name it).
//  · **`Block History…` MOVED** — her words: *"take history should move
//    into the three ... menu on each take rather than the main three dot
//    menu."* Its home is now every live take card's own ⋯ in the takes
//    browser (`MobileTakesBrowserController.historyTitle`, composed from
//    the SHARED `BlockHistoryPath.name` so the word did not fork on the
//    way over). One consequence is recorded at that door: the face is no
//    longer reachable on a GAP block, because the browser refuses to open
//    on one.
//
//  **Her G2 commit/history pairing therefore ends here, deliberately and
//  visibly.** `Commit Take` stays: it is a block-scale act on the caret's
//  DISPLAYED take, and she asked for the listing to move, not the act.
//  The pairing survives one grain up — the note ⋯ keeps its own
//  `Save a Version` + `Versions…` twin (batch 6c's finding 2).
//
//  Every row performs a STANDING act or delivers the ops' real refusal
//  (P-2): Takes/Comments open their sheets; Callout rides the mirrored
//  `MobileCallout` transform through `updateBlockPresentation`; Name is
//  `setBlockName`; Divide/Merge/Delete are `MobileStructuralController`'s
//  doors (M10; Delete joined at the S4 ladder — MAJOR 1's latch +
//  flush-guard contract) — the deleted-blocks TRAY stays
//  Mac-side in v1 (the refusal-free recovery road, named in the note).
//  **"ARCHIVE BLOCK" LANDED AT ROUND 2 BATCH 6b (PR6), and the note above
//  it is kept because it was TRUE WHEN WRITTEN and is now exactly false.**
//  It said the row was a deliberate absence because *"no such operation
//  exists (blocks archive nowhere — only containers and takes do), the Mac
//  offers no such door"*. **13j's round-7 ruling built both ops**
//  (`archiveBlock` / `unarchiveBlock`), the Mac's tray grew an archived
//  section for them the same phase, and `Queries.archivedBlocks` has been
//  reading that population ever since — so the phone was the one platform
//  where a block could be UN-archived (from this batch's tray) and never
//  archived. A capability with a way back and no way in is the half-door
//  class, so the row is here now, one place above Delete Block: archive is
//  the gentler of the two ways a block leaves the page.
//
//  Its way BACK is the tray — blocks ▸ archived — which is why the ruling
//  that built the op and the batch that built the tray had to meet before
//  this row could honestly exist (P-2: a door that sets a block aside owes
//  a visible road to the place it set it aside in).
//
//  PROMPTS (Name…, Emoji…, the delete confirm) ride injectable seams —
//  production installs UIAlertController plumbing at attach; tests
//  inject answers. The emoji prompt's semantics are the Mac
//  `CalloutMenu.promptEmoji`'s exactly: cancel = nil (nothing happens);
//  EMPTY is a real answer ("no glyph").
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileBlockMenuController {
    private let session: AppSession
    weak var model: MobileEditorViewModel?

    /// The prompt seams (production: UIAlertController; tests inject).
    /// completion(nil) = cancelled.
    var promptForText:
        (@MainActor (_ title: String, _ message: String, _ current: String?,
                     _ completion: @escaping @MainActor (String?) -> Void) -> Void)?
    /// The destructive confirm seam. completion(true) = proceed.
    var confirmDestructive:
        (@MainActor (_ title: String, _ message: String, _ actionTitle: String,
                     _ completion: @escaping @MainActor (Bool) -> Void) -> Void)?

    /// **ONE ACT AT A TIME — this controller's own latch** (batch 4.5b;
    /// §53 finding 3). Every row here is a bare `Task { await … }` off a
    /// `UIAction`, and a rapid double-tap runs two of them concurrently.
    ///
    /// Its two siblings already latch — `MobileStructuralController`'s
    /// `structuralInFlight` and `MobileUndoDoor`'s `inFlight` — and this is
    /// the same idiom, deliberately, rather than a third one.
    ///
    /// **What it covers, and what it does not, stated so the boundary is not
    /// re-derived:** it guards the write roads this controller OWNS —
    /// `applyCallout` (the callout submenu's toggle, five colours, remove and
    /// emoji rows all land here) and `rename`. The structural rows (Insert
    /// Below · Divide · Merge · Delete) hand straight to
    /// `MobileStructuralController`, which latches them one layer down, and
    /// double-latching would only change which of two identical sentences she
    /// reads. Commit Take hands to `MobileTakeHistory.commitNow`, which
    /// carries NO latch of its own — recorded, not fixed here, because that
    /// file belongs to another sub-batch this round; a double-tap there mints
    /// a duplicate savepoint (append-only, so never a loss).
    ///
    /// The exposure it closes is a LOST UPDATE, never corruption: two
    /// concurrent `updateBlockPresentation` read-modify-writes each read the
    /// pre-state, so the second silently discards the first — a toggle that
    /// un-toggles, a colour that does not stick. **Batch 7 adds more take and
    /// block rows to this same menu**, which is why the latch lands before
    /// them rather than after.
    private(set) var actInFlight = false

    /// The latch's sentence — the siblings' copy, in this menu's terms.
    static let anotherActIsLanding = "Another change to this block is still landing."

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - The row vocabulary (one builder, two doors)

    static let commentsTitle = "Comments…"
    static let calloutTitle = "Callout"
    static let nameTitle = "Name Block…"
    /// The savepoint WRITER (parity C4a — AppSpec §9's deliberate-commit
    /// pillar reaches the phone: Commit acts on the caret block's DISPLAYED
    /// take, through `MobileBlockHistoryController`). **Its old partner
    /// left at batch 9** — the header's G2 note has the whole reasoning —
    /// so this is a savepoint pair no longer; the READER is each take
    /// card's own `MobileTakesBrowserController.historyTitle`.
    ///
    /// `nonisolated` because the pocket guide's savepoint lesson composes
    /// the word rather than re-typing it (batch 9's fix wave, MAJOR 2),
    /// and `MobileTutorialSeeder` runs off the main actor.
    nonisolated static let commitTitle = "Commit Take"
    /// The insert door (parity C4b item 1 — the registry's own verb).
    /// It heads the structural family: minting under the block is the
    /// gentlest structural act, so it reads before the knives.
    static let insertBelowTitle = "New Block Below"
    static let divideTitle = "Divide Block"
    static let mergeTitle = "Merge with Previous"
    /// **PR6 — the block-level archive door** (13j's round-7 ruling built
    /// `archiveBlock`; the Mac wears it in the block TOC and the Takes
    /// bottom bar through `CapabilityID.archiveBlock`). It sits immediately
    /// above Delete Block because the two are the same shape — a block
    /// leaves the page — and this is the gentler one: kept, forever, no
    /// clock, one tap back from blocks ▸ archived.
    static let archiveTitle = "Archive Block"
    static let deleteTitle = "Delete Block"
    /// The Mac CalloutMenu's row words, mirrored (one vocabulary).
    static let calloutToggleTitle = "Toggle Callout"
    static let calloutEmojiTitle = "Emoji…"
    static let calloutRemoveTitle = "Remove Callout"

    /// The flat titles both doors must agree on (the drift pin's oracle).
    static var rowTitles: [String] {
        [commentsTitle, calloutTitle, nameTitle, commitTitle,
         insertBelowTitle, divideTitle, mergeTitle, archiveTitle, deleteTitle]
    }

    /// The callout submenu's titles in order (separators excluded) —
    /// `CalloutMenu.rowTitles`' mirror.
    static var calloutRowTitles: [String] {
        [calloutToggleTitle]
            + MobileCallout.names.map(\.capitalized)
            + [calloutEmojiTitle, calloutRemoveTitle]
    }

    /// The menu's elements for one block — consumed by the bar's ⋯ and by
    /// the edit menu's Block submenu, which since batch 9 render the SAME
    /// list with no arm between them (the `includeTakes:` split died with
    /// the row it existed for — see the header).
    /// Displayed titles are VOICE-CASED (P26/P43, parity A3 — the flip
    /// of P26/P43's recorded system-register posture): `rowTitles` stays
    /// the canonical vocabulary, `chromeCase` is the render register.
    func menuElements(blockID: String) -> [UIMenuElement] {
        let cased = MobileEditorStyle.chromeCase
        var elements: [UIMenuElement] = []
        elements.append(UIAction(title: cased(Self.commentsTitle)) { [weak self] _ in
            self?.model?.openComments(blockID: blockID)
        })
        elements.append(calloutSubmenu(blockID: blockID))
        elements.append(UIAction(title: cased(Self.nameTitle)) { [weak self] _ in
            self?.promptRename(blockID: blockID)
        })
        elements.append(UIAction(title: cased(Self.commitTitle)) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.blockHistory.commitNow(blockID: blockID) }
        })
        elements.append(UIAction(title: cased(Self.insertBelowTitle)) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.structural.insertBlockBelow(blockID: blockID) }
        })
        elements.append(UIAction(title: cased(Self.divideTitle)) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.structural.divideAtCaret() }
        })
        elements.append(UIAction(title: cased(Self.mergeTitle)) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.structural.mergeWithPrevious() }
        })
        // PR6: archive before delete — the gentler exit reads first, the
        // same way Insert Below heads the structural family "before the
        // knives". NOT `.destructive`: nothing is destroyed and there is no
        // clock, which is exactly what distinguishes it from the row below.
        elements.append(UIAction(title: cased(Self.archiveTitle)) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.structural.archiveBlock(blockID: blockID) }
        })
        elements.append(UIAction(
            title: cased(Self.deleteTitle), attributes: .destructive
        ) { [weak self] _ in
            self?.confirmDelete(blockID: blockID)
        })
        return elements
    }

    private func calloutSubmenu(blockID: String) -> UIMenu {
        let cased = MobileEditorStyle.chromeCase
        var rows: [UIMenuElement] = [
            UIAction(title: cased(Self.calloutToggleTitle)) { [weak self] _ in
                Task { await self?.applyCallout(blockID: blockID, edit: .toggle) }
            },
        ]
        // **PR19 — THE COLOUR ROWS WEAR THEIR COLOUR** (the Mac's 13e E1,
        // phone-imaged through `MobileCallout.swatchImage`, which resolves
        // the SAME `color(_:)` the block's own frame does — a preview, never
        // a second source of truth, and the stored value is still the NAME).
        //
        // **The word stays beside the chip, deliberately** — the Mac's own
        // reason, which binds here twice over: a swatch alone would be the
        // one control in the app that cannot be read aloud (R93's legibility
        // mandate, and MobileSoul §5.6's VoiceOver expectation), and the
        // words are what the drift pin compares against `CalloutMenu`'s.
        // So `calloutRowTitles` is UNCHANGED by this batch: no row was
        // added, only an image hung on the FIVE that existed
        // (`MobileCallout.names` — blue · green · sand · violet · rose,
        // value-mirroring the Mac's `CalloutPalette`; the count is derived
        // from that array everywhere and was mis-stated as four in three
        // places, corrected at the fix wave — cold review NIT 1).
        rows += MobileCallout.names.map { name in
            UIAction(
                title: cased(name.capitalized),
                image: MobileCallout.swatchImage(for: name)
            ) { [weak self] _ in
                Task { await self?.applyCallout(blockID: blockID, edit: .color(name)) }
            }
        }
        rows += [
            UIAction(title: cased(Self.calloutEmojiTitle)) { [weak self] _ in
                self?.promptEmoji(blockID: blockID)
            },
            UIAction(title: cased(Self.calloutRemoveTitle)) { [weak self] _ in
                Task { await self?.applyCallout(blockID: blockID, edit: .color(nil)) }
            },
        ]
        return UIMenu(title: cased(Self.calloutTitle), children: rows)
    }

    // MARK: - Callout (M12 — the one mirrored transform through the op)

    func applyCallout(blockID: String, edit: MobileCallout.Edit) async {
        guard let model else { return }
        guard !actInFlight else {
            model.report(Self.anotherActIsLanding)
            return
        }
        actInFlight = true
        defer { actInFlight = false }
        do {
            try await session.runner.run { ops in
                try ops.updateBlockPresentation(blockID) { existing in
                    MobileCallout.apply(edit, to: existing)
                }
            }
            model.report(nil)
            await model.refreshTakesFromStore()
        } catch {
            model.report(Self.refusalMessage(error, act: "change the callout"))
        }
    }

    static let emojiPromptTitle = "Callout Emoji"
    static let emojiPromptMessage = "A leading glyph for this callout (leave empty for none)."

    /// **PR19's emoji road.** The seam is SEPARATE from `promptForText` and
    /// **falls back to it when nothing installed one** — so the emoji
    /// keyboard is a strict upgrade over the prompt that shipped, and every
    /// harness that injects only `promptForText` keeps driving this door
    /// unchanged (the fallback is structural, not promised).
    ///
    /// Semantics are the Mac `CalloutMenu.promptEmoji`'s exactly, and both
    /// arms honour them: cancel = nil (nothing happens); EMPTY is a real
    /// answer ("no glyph"), which is why the completion cannot collapse the
    /// two.
    var promptForEmoji:
        (@MainActor (_ title: String, _ message: String,
                     _ completion: @escaping @MainActor (String?) -> Void) -> Void)?

    /// Internal, not private, for the `requestLabel` reason: the menu row is
    /// a one-line forward to this, `UIMenu` rows are not invocable in
    /// process, and the ROW's presence is pinned separately by the callout
    /// drift pin — so this is where the door's behaviour is driven.
    func promptEmoji(blockID: String) {
        let land: @MainActor (String?) -> Void = { [weak self] glyph in
            guard let glyph else { return } // cancelled
            Task { await self?.applyCallout(blockID: blockID, edit: .emoji(glyph)) }
        }
        if let promptForEmoji {
            promptForEmoji(Self.emojiPromptTitle, Self.emojiPromptMessage, land)
            return
        }
        guard let promptForText else { return }
        promptForText(Self.emojiPromptTitle, Self.emojiPromptMessage, nil, land)
    }

    // MARK: - Name (the block's handle — `setBlockName`)

    func promptRename(blockID: String) {
        guard promptForText != nil, let postID = model?.postID else { return }
        Task { [weak self] in
            guard let self else { return }
            // The seed reads through the standing query vocabulary (S4
            // ladder NIT 1 — the read-side home is `Queries`, never raw
            // SQL in a feature controller): `blockTOC` is the standing
            // name-carrying read, cost ∝ the post (P1).
            let current: String? = (try? await self.session.database.read { db in
                try Queries.blockTOC(db, post: postID)
                    .first { $0.blockID == blockID }?.name
            }) ?? nil
            guard let promptForText = self.promptForText else { return }
            promptForText(
                "Name Block",
                "A handle for this block (leave empty to clear).",
                current
            ) { [weak self] name in
                guard let name else { return } // cancelled
                Task { await self?.rename(blockID: blockID, name: name) }
            }
        }
    }

    func rename(blockID: String, name: String?) async {
        guard let model else { return }
        guard !actInFlight else {
            model.report(Self.anotherActIsLanding)
            return
        }
        actInFlight = true
        defer { actInFlight = false }
        do {
            try await session.runner.run { ops in
                try ops.setBlockName(blockID, name: name)
            }
            model.report(nil)
        } catch {
            model.report(Self.refusalMessage(error, act: "name the block"))
        }
    }

    // MARK: - Delete block (confirmed, and since batch 6b the confirm names
    // the tray — the durable road back, beside the session's undo)

    /// The confirm's detail.
    ///
    /// **13j batch 2 — MADE TRUE ON THE PHONE'S OWN TERMS.** Parity C2 kept
    /// the "deleted-blocks tray" sentence here after dissolving its "on the
    /// Mac" redirect, on the reading that the tray was a FACT even without a
    /// phone face. J8's copy doctrine says otherwise, and her own morning
    /// report is the evidence: a promise a user cannot act on is not a fact
    /// she can use, it is a place she goes looking for and does not find.
    /// This phone had NO tray face and NO undo door then (v1's recorded
    /// posture, verified by sweep at that batch: no `restoreBlock` door
    /// anywhere in `VariorumMobile`, and the structural undo stack used only
    /// for compounds), so the confirm said the two things that were true and
    /// promised nothing else. **Both halves have since landed** — see the two
    /// graduations below.
    ///
    /// It does NOT say "do it on the Mac" — the no-redirect principle
    /// (MobileSoul §4) — and it does not say "gone forever" either, because
    /// the block is tombstoned, not purged.
    ///
    /// **ROUND 2 BATCH 4 — THE SENTENCE GRADUATES, because M20 made its
    /// second half FALSE.** It used to end *"There's no undo here"*, which
    /// was true when written and is the exact class J8 warns about from the
    /// other side: a copy line that keeps saying no after the door opens.
    /// The structural undo door (her R10) stands on the receipt this delete
    /// writes and in the note's ⋯, so the confirm names the road it has.
    ///
    /// **ROUND 2 BATCH 6b — IT GRADUATES AGAIN, and for the same reason a
    /// second time.** The clause above ended *"The tray twin is still the
    /// ledger's and is still not promised here"* — the tray landed at this
    /// batch (§69.3), so the promise is real and the confirm makes it.
    /// Undo is the SESSION's road back (it dies with the app; the phone's
    /// stack is in-memory by construction); the tray is the DURABLE one, and
    /// a destructive confirm owes her the durable one first.
    /// Pinned static — a promise made in a literal is a promise no test can
    /// keep.
    static var deleteConfirmDetail: String {
        "The block leaves this note, with its takes. "
            + "\(MobileNoteTrayModel.putBackRoadPhrase.prefix(1).uppercased())"
            + "\(MobileNoteTrayModel.putBackRoadPhrase.dropFirst()) for "
            + "\(TrashWindow.days) days; Undo is on the receipt afterwards, "
            + "and in the note's ⋯."
    }

    static let deleteNeedsItsConfirm =
        "Deleting a block needs its confirmation — nothing was deleted."

    /// **It FAILS CLOSED when its seam is missing** (§44's NIT 7). This used
    /// to fall through to `delete(blockID:)` with no confirm at all — a
    /// destructive door proceeding *because* its confirm machinery was
    /// absent, which is exactly backwards, and the one shape M-E cannot
    /// tolerate (*a door that destroys must name what it destroys before it
    /// acts*; R13's carve-out covers the in-editor ⌫ keystroke, never this
    /// menu row). Production installs the seam at attach
    /// (`MobileEditorViewModel`), so the refusal is unreachable there and
    /// costs nothing; a harness that forgot to inject one now gets told so
    /// instead of silently deleting a block.
    private func confirmDelete(blockID: String) {
        guard let confirmDestructive else {
            model?.report(Self.deleteNeedsItsConfirm)
            return
        }
        confirmDestructive(
            "Delete Block",
            Self.deleteConfirmDetail,
            "Delete"
        ) { [weak self] proceed in
            guard proceed else { return }
            Task { await self?.delete(blockID: blockID) }
        }
    }

    /// The act itself rides the STRUCTURAL controller's contract (S4
    /// ladder MAJOR 1): `deleteBlock` is a structural op, so it takes the
    /// one-flight latch + the flush-guard its siblings carry — a refused
    /// flush refuses the delete, which is what keeps the typed bytes inside
    /// the take the tombstone takes down with it. This door keeps only the
    /// confirm seam.
    func delete(blockID: String) async {
        await model?.structural.deleteBlock(blockID: blockID)
    }

    // MARK: - Refusal copy

    /// The everyday cases in phone words (the S2 posture). **18m U3:** the
    /// seal speaks the ONE stem in the phone's door words, with this door's
    /// act; the rest is the shared refusal table's words where it has them,
    /// and this door's own fallback where it has none.
    static func refusalMessage(_ error: Error, act: String) -> String {
        guard let error = error as? OperationError else {
            return String(describing: error)
        }
        switch error {
        case .lockedPost:
            return SealedNoteCopy.sentence(act: act, words: .phone)
        default:
            return OpsRefusalCopy.words(for: error, roads: .phone)
                ?? DeletionRefusal.fallback(error)
        }
    }
}
