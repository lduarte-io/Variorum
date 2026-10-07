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
//    guard refuse through the ops' own errors. Since parity C4a the
//    card's ⋯ also carries LOCK/UNLOCK (`lockVariant`/`unlockVariant`,
//    flush-first on lock) and the sheet lists the block's ARCHIVED
//    takes below the fan with per-card Unarchive/Delete — the S2-era
//    "recovery surfaces stay Mac-side" absence dissolved with the
//    doors (deleted-take resurrection alone stays PL-3/13j's, with the
//    rest of the trash family).
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
    /// The session (parity C4a — the archived listing is a direct read;
    /// the comments controller's own shape). The runner rides it.
    private let session: AppSession
    private var runner: OperationsRunner { session.runner }
    weak var model: MobileEditorViewModel?

    /// The block the sheet is open on. nil = closed.
    private(set) var openBlockID: String?
    /// The take whose card is the LIVE editor right now. nil = all cards
    /// read-only (P3's split inside the sheet).
    private(set) var editingVariantID: String?
    /// The open block's ARCHIVED takes, fan-ordered (parity C4a —
    /// see-your-data: archived takes are her information, and the road
    /// back lives where the fan lives). Loaded at open and re-read after
    /// every verb / projection ingest; empty when closed.
    private(set) var archived: [Variant] = []

    /// One flight at a time for the MINTS (the architectural review's
    /// MAJOR 1). `branchDisplayed` awaits a flush before it writes, which
    /// is a wide window on a button that stays hittable throughout — and
    /// nothing beneath the door catches a second `branchVariant`: the fan
    /// is a list, so a double tap simply grew it by two takes she asked for
    /// once. Scoped to the minting doors deliberately: choose/label/lock
    /// are last-write-wins on one row and a latch would only hide a second
    /// tap that changed nothing.
    private let mintLatch = MobileWriteLatch()

    /// **THE STRUCTURAL DOORS' LATCH (batch 7 — the `commitNow` rider's own
    /// criterion, applied forward).** `takeToBlockBelow` and `takesToBlocks`
    /// each MINT rows, and `takesToBlocks` mints a whole run of them; both
    /// await a flush before they write, which is a wide window. The card ⋯'s
    /// row dismisses on the first tap and could not fire twice, but **"All
    /// Takes to Blocks" is a persistent chrome BUTTON in the sheet's actions
    /// row** — the exact non-dismissing host the rider names — so the pair
    /// latches rather than only the one that needs it (a door and its twin
    /// with different concurrency rules is the drift class).
    ///
    /// Separate from `mintLatch` deliberately: a take mint and a structural
    /// conversion are different gestures, and one wedging the other would be
    /// a refusal she never asked for.
    private let structureLatch = MobileWriteLatch()

    /// The pixels' hook: state or content changed — re-render the sheet.
    var onChanged: (() -> Void)?

    /// The card gate's exact-cost capture (the VM's `ArmedEdit.cost`
    /// pattern — named `pendingEditCost` there until round 2 folded it into
    /// the arming it belongs to): policed card edits carry the gate's own
    /// figure; gateless system paths fall back to a length-delta
    /// approximation (churn is approximate by design, SyncSpec §6).
    private var pendingCardCost: Int?
    private var lastRecordedCardText: String?

    var isOpen: Bool { openBlockID != nil }

    init(session: AppSession) {
        self.session = session
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

    // MARK: - The archived listing (parity C4a — see-your-data; the Mac
    // WriteTakesPanel's "archived takes" section, the phone's cards)

    /// An archived take's card: read-only (an archived buffer refuses
    /// edits by the op's own rule — history is not an editing surface),
    /// with the road back (Unarchive) and Delete on its ⋯. The label
    /// rides — the archived listing is exactly where a label helps
    /// identify a take (the core op's own recorded rationale).
    struct ArchivedCard: Equatable {
        let variantID: String
        let text: String
        let label: String?
    }

    func archivedCards() -> [ArchivedCard] {
        archived.map { take in
            ArchivedCard(
                variantID: take.id,
                text: model?.surfaceKnownText(variantID: take.id) ?? take.workingText,
                label: take.label)
        }
    }

    /// One fresh read of the open block's archived takes, fan-ordered
    /// (`Queries.blockFan` — the standing read; archived filtered here,
    /// cost ∝ the block's own fan). Verbs and projection ingests both
    /// land here, so the section is correct with or without the standing
    /// observation (the browser's own deterministic-refresh discipline).
    func reloadArchived() async {
        guard let blockID = openBlockID else { return }
        let rows = (try? await session.database.read { db in
            try Queries.blockFan(db, blockID: blockID)
                .filter { $0.status == .archived }
        }) ?? []
        guard openBlockID == blockID else { return }
        archived = rows
        onChanged?()
    }

    // MARK: - Label (each card's ⋯ — parity C4a: the 13b `setTakeLabel`
    // op's phone face; the Mac card menu's "Label take…" door)

    /// The label prompt's seam (production: a UIAlertController installed
    /// at the VM's attach — the block menu's plumbing pattern; tests
    /// inject answers). completion(nil) = cancelled; EMPTY is a real
    /// answer — the op clears (trim-and-NULL).
    var promptForText:
        (@MainActor (_ title: String, _ message: String, _ current: String?,
                     _ completion: @escaping @MainActor (String?) -> Void) -> Void)?

    static let labelPromptTitle = "Label Take"
    /// The Mac label sheet's caption, phone-alerted: identity only,
    /// never printed in the prose.
    static let labelPromptMessage =
        "A short name for this take's card — never printed in the prose. Leave empty to clear."

    /// Opens the label prompt prefilled with the take's CURRENT label
    /// (live or archived — labels serve both listings).
    func requestLabel(variantID: String) {
        guard let promptForText else { return }
        let current = cards().first { $0.variantID == variantID }?.label
            ?? archivedCards().first { $0.variantID == variantID }?.label
        promptForText(Self.labelPromptTitle, Self.labelPromptMessage, current) {
            [weak self] answer in
            guard let answer else { return } // cancelled — nothing happens
            Task { await self?.setLabel(variantID: variantID, label: answer) }
        }
    }

    /// The op call (empty clears — the core trims and NULLs). Legal on a
    /// LOCKED take (the lock freezes the BUFFER, not identity metadata)
    /// and on an ARCHIVED one (the listing is where a label identifies) —
    /// both the core op's own recorded rules, not door inventions.
    func setLabel(variantID: String, label: String?) async {
        guard let model else { return }
        do {
            try await runner.run { ops in try ops.setTakeLabel(variantID, label: label) }
            model.report(nil)
            await model.refreshTakesFromStore()
            await reloadArchived()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, verb: .label))
        }
    }

    // MARK: - History (batch 9 — HER MOVE: the door leaves the block ⋯ and
    // lands on each take's own card)

    /// The card ⋯'s history row, verbatim her instruction: *"take history
    /// should move into the three ... menu on each take rather than the main
    /// three dot menu."*
    ///
    /// **The word is COMPOSED from the shared face's own name, never written
    /// again** (`BlockHistoryPath.name`, `Shared/BlockHistoryFace.swift`) —
    /// the block ⋯ carried a `"Block History…"` literal, and moving a row is
    /// exactly the moment a literal becomes two literals. It still reads
    /// `Block History…` byte-for-byte, which is also the honest word for
    /// what opens: the face is the BLOCK's whole past (batch 6a's F2
    /// rename), reached from a take rather than scoped to one.
    ///
    /// **`nonisolated` since batch 9's fix wave (cold-review MAJOR 2):**
    /// the pocket guide's two history lessons compose this row's word
    /// instead of re-typing it — they had gone on teaching the retired
    /// block-⋯ road for a whole batch — and `MobileTutorialSeeder` runs
    /// off the main actor. Composition is what makes the walk's pin red
    /// on the next move rather than merely stale.
    nonisolated static var historyTitle: String { "\(BlockHistoryPath.name)…" }

    /// Opens the Block History face on the open block, with THIS take's
    /// savepoint run expanded.
    ///
    /// **It closes the browser first, and that is the phone's own established
    /// grammar rather than a compromise:** the note ⋯'s `Versions…` row
    /// dismisses its sheet and then asks the shell to push. Two reasons make
    /// it the right one here too. The mechanical one: both faces are overlay
    /// views installed lazily as SIBLINGS on the page's host, so their z-order
    /// is whichever opened FIRST in the session — a history sheet raised over
    /// a live browser would render under it for anyone who had opened the
    /// browser first, and neither view is `accessibilityViewIsModal`, so both
    /// surfaces' labels would sit in one tree. The product one: the browser
    /// is where you CHOOSE a take and the history face is where you read what
    /// a block has been — one subject at a time is the phone's calm default.
    ///
    /// `close()` also flushes (through `refreshTakesFromStore`), so a card
    /// edited a keystroke ago is in the store before the face reads it — the
    /// standing flush-first contract, and the reason this is async.
    func openHistory(variantID: String) async {
        guard let model, let blockID = openBlockID else { return }
        await close()
        model.blockHistory.open(blockID: blockID, focused: variantID)
    }

    /// Back into the fan — the road the archive refusals name.
    func unarchive(variantID: String) async {
        guard let model else { return }
        do {
            try await runner.run { ops in try ops.unarchiveVariant(variantID) }
            model.report(nil)
            await model.refreshTakesFromStore()
            await reloadArchived()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, verb: .unarchive))
        }
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
        archived = []
        onChanged?()
        // The archived section loads fresh per open (tests await
        // `reloadArchived()` directly for determinism).
        Task { await reloadArchived() }
    }

    /// Done: the live card resigns, pending edits flush, the page heals
    /// from the store (walk 6's "the page shows the new chosen text"),
    /// the in-page editor is restored by the view.
    func close() async {
        guard isOpen else { return }
        endEditing()
        openBlockID = nil
        archived = []
        onChanged?()
        await model?.refreshTakesFromStore()
    }

    /// The synchronous escape (the open block vanished from the surface —
    /// deleted elsewhere): clear state, no flush round.
    func forceClose() {
        guard isOpen else { return }
        editingVariantID = nil
        openBlockID = nil
        archived = []
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
            // A remote archive/unarchive arrives by the same delivery —
            // the archived section re-reads (parity C4a).
            Task { await reloadArchived() }
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
        await mintLatch.run { await self.branchDisplayedOnce() } ?? nil
    }

    private func branchDisplayedOnce() async -> Variant? {
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
        await mintLatch.run { await self.mintOnce(verb: verb, body) } ?? nil
    }

    private func mintOnce(
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
            model.report(Self.lockedTakeCardRefusal)
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
            model.report(Self.lockedTakeCardRefusal)
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

    // MARK: - Fan ORDER (PL-10(a) — the phone's face on `reorderTake`)

    /// **The reorder door, composed from the Mac's ruled semantics (#57).**
    /// Move a take one place EARLIER (`delta < 0`) or LATER in its block's
    /// fan. The card ⋯'s Move Take Up / Move Take Down rows call this.
    ///
    /// **NO DRAG, deliberately, and the call is recorded rather than
    /// re-derived:** the phone's card list is a scroll of manual-frame cards
    /// inside an overlay sheet, and 13e's canvas-drag rider (the jitter fix)
    /// named a coordinate-space rule that any new drag on this app owes —
    /// a first iOS drag-reorder is its own project, not a row in a takes
    /// batch. Two menu rows are the phone-native shape (the phone has no
    /// chord culture either — #57(d)'s keyless arrows read as menu rows
    /// here).
    ///
    /// **The Mac's shipped answer, matched arm for arm** (`TakesStructure
    /// Controller.moveTake`):
    /// - **flush first, then read the fan FROM THE STORE.** The takes
    ///   projection is deliberately frozen while a buffer is dirty, so a
    ///   projection-read neighbour is an ENABLEMENT hint and never an
    ///   authorization — a take that arrived mid-burst would otherwise make
    ///   the move land beside the wrong card. This is the very room B45-2's
    ///   structural fix exists for, one layer up.
    /// - **stepping happens within the ACTIVE fan** (#57(b)): an archived
    ///   take keeps its own key and is neither stepped onto nor stepped over.
    /// - **the ends refuse by name** (#57(e)'s "greys rather than vanishing",
    ///   in the phone's register: the row is rendered DISABLED at the end it
    ///   cannot move, and this belt still speaks if the store disagrees with
    ///   what the card showed).
    /// - **a LOCKED take may be moved** (#57(a)) — the lock freezes the
    ///   BUFFER, not identity metadata; the op's own rule, not a door's.
    /// - **no touch, no churn** (#57(c)) — the op's, and nothing here adds any.
    ///
    /// **No latch, and the reason is the rider's own criterion:** every
    /// caller is a `UIMenu` row, which dismisses on the first tap, so the
    /// door cannot fire twice. A future non-dismissing host takes
    /// `MobileWriteLatch` the same day.
    func moveTake(variantID: String, by delta: Int) async {
        guard let model, let blockID = openBlockID, delta != 0 else { return }
        guard await model.flushPendingText() else { return }
        let fan: [Variant]
        do {
            fan = try await session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
        } catch {
            model.report(Self.refusalMessage(error, verb: .reorder))
            return
        }
        let active = fan.filter { $0.status == .active }
        guard let index = active.firstIndex(where: { $0.id == variantID }) else {
            model.report(Self.fanChangedRefusal)
            return
        }
        let target = index + delta
        guard active.indices.contains(target) else {
            model.report(delta < 0 ? Self.alreadyFirstRefusal : Self.alreadyLastRefusal)
            return
        }
        let anchor = active[target].id
        do {
            try await runner.run { ops in
                try ops.reorderTake(
                    variantID, to: delta < 0 ? .before(anchor) : .after(anchor))
            }
            model.report(delta < 0 ? Self.movedUpNote : Self.movedDownNote)
            await model.refreshTakesFromStore()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, verb: .reorder))
        }
    }

    /// Can this card step in this direction? The card ⋯ reads it to render
    /// the row DISABLED rather than absent at the fan's end (#57(e)'s
    /// "greys rather than vanishing"). A projection read, so it is an
    /// enablement HINT — `moveTake` re-decides from the store.
    func canMoveTake(variantID: String, by delta: Int) -> Bool {
        let cards = cards()
        guard cards.count > 1,
              let index = cards.firstIndex(where: { $0.variantID == variantID })
        else { return false }
        return cards.indices.contains(index + delta)
    }

    // MARK: - Take ↔ block structure (PL-10(d) — the phone's face on the
    // AR-1 ops; the semantics are #58's and are never re-decided here)

    /// **Her A20 on the phone** (`takeToBlockBelow`): this take leaves the
    /// fan and becomes its own block directly below.
    ///
    /// **AR-1 in one line: the new block gets a COPY and the original is
    /// ARCHIVED on its own block** — never a row move. Everything the door
    /// could be tempted to pre-check is decided INSIDE the write instead
    /// (fan arity/I10, the blank take, the seal, a locked take's
    /// permission), which is the Mac's own posture and the only honest one
    /// over a deliberately-frozen projection: this door offers the row and
    /// speaks the op's real answer.
    ///
    /// **The op registers its own structural undo AND redo** — verified at
    /// `Operations+TakeStructure.registerTakeConversions`, one entry
    /// carrying inverse and redo from do-time pre-images — so nothing is
    /// registered here (a second registration would be two entries for one
    /// act).
    func takeToBlockBelow(variantID: String) async {
        guard let model, let blockID = openBlockID else { return }
        await structureLatch.run {
            guard await model.flushPendingText() else { return }
            do {
                try await self.runner.run { ops in
                    _ = try ops.takeToBlockBelow(blockID, variantID: variantID)
                }
                model.report(MobileTakeStructureCopy.movedNote, action: .undo)
                await model.refreshTakesFromStore()
                await self.reloadArchived()
                self.onChanged?()
            } catch {
                model.report(Self.refusalMessage(error, verb: .takeToBlock))
            }
        }
    }

    /// **Her A21's second half on the phone** (`takesToBlocks`): every OTHER
    /// take of this block becomes its own block below it, in fan order,
    /// under ONE undo entry.
    ///
    /// **The block keeps showing what it showed** (#58(c)) — the take the
    /// slot RENDERS stays put and the alternates become the run below it, so
    /// the note reads exactly as it read. Blank takes are SKIPPED and the
    /// receipt says so (#58(d)); archived takes ride nowhere (#58(f)). All
    /// of that is the op's; this door carries the flush, the latch and the
    /// words.
    func takesToBlocks() async {
        guard let model, let blockID = openBlockID else { return }
        await structureLatch.run {
            guard await model.flushPendingText() else { return }
            do {
                let result: Operations.TakesToBlocksResult
                    = try await self.runner.run { ops in
                    try ops.takesToBlocks(blockID)
                }
                model.report(
                    MobileTakeStructureCopy.convertedNote(
                        blocks: result.converted.count,
                        skippedBlanks: result.skippedBlankTakes),
                    action: .undo)
                await model.refreshTakesFromStore()
                await self.reloadArchived()
                self.onChanged?()
            } catch {
                model.report(Self.refusalMessage(error, verb: .takesToBlocks))
            }
        }
    }

    /// Is there anything for "All Takes to Blocks" to convert? P-2's
    /// enablement hint for the chrome door — a fan with at least one OTHER
    /// take. The op still owns the verdict (`noConvertibleTakes` when every
    /// alternate is blank), and it speaks.
    var canTurnTakesIntoBlocks: Bool { cards().count > 1 }

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

    // MARK: - Lock / unlock (each card's ⋯ — parity C4a: the note seal's
    // sibling, through the core's own lockVariant/unlockVariant; the six
    // locked-take "on the Mac" redirects dissolve WITH this door)

    /// Locks or unlocks a take. The LOCK road is FLUSH-GUARDED (the A1
    /// `lockNote` trace, the take's edition): the op's own insurance
    /// auto-commits a dirty STORE buffer, but pending SURFACE bytes live
    /// in the coordinator until a flush lands — locking past them would
    /// insure the STALE store text, and the later flush would refuse
    /// `.lockedVariant`, stranding the typed bytes pending forever (the
    /// text-loss class the flush-first contract exists to kill). A flush
    /// that cannot land refuses the whole act with the standing wording.
    /// Unlock needs no flush: nothing about it reads a buffer, and a
    /// locked take admits no pending edits to begin with.
    func setLocked(variantID: String, locked: Bool) async {
        guard let model else { return }
        if locked {
            await model.autosave.flushNow()
            guard !model.autosave.isDirty else {
                model.report(
                    "Unsaved changes couldn't be written — resolve that first, then retry.")
                return
            }
            if editingVariantID == variantID { endEditing() }
        }
        do {
            try await runner.run { ops in
                if locked {
                    try ops.lockVariant(variantID)
                } else {
                    try ops.unlockVariant(variantID)
                }
            }
            model.report(nil)
            await model.refreshTakesFromStore()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, verb: locked ? .lock : .unlock))
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
            await reloadArchived()
            onChanged?()
        } catch {
            model.report(Self.refusalMessage(error, verb: verb))
        }
    }

    // MARK: - Refusal copy (the ops' REAL refusals, in the phone's words)

    enum Verb {
        case choose, branch, blank, archive, delete, lock, unlock, unarchive, label
        /// Batch 7 (PL-10): the fan-order door and the two AR-1 doors.
        case reorder, takeToBlock, takesToBlocks
    }

    // MARK: - Batch 7's row vocabulary (declared once — the card ⋯ renders
    // it and the drift pin reads it; a title written at the menu would be a
    // second copy of the same word)

    /// The fan-order pair (PL-10(a)). "Up"/"Down" and not the Mac's
    /// "earlier"/"later" because #57(e)'s rule is that the direction word
    /// follows the strip, and the phone's cards are a vertical STACK — the
    /// case the Mac itself draws ▲▼ for.
    static let moveUpTitle = "Move Take Up"
    static let moveDownTitle = "Move Take Down"
    /// E5's row (PL-10(d)) — the block it mints stands immediately below,
    /// which is the whole promise, so the title says so.
    static let takeToBlockTitle = "Take to New Block Below"
    /// E6b's chrome door, in the sheet's actions row (the one door onto the
    /// block-scoped half of the pair).
    static let takesToBlocksTitle = "All Takes to Blocks"

    /// The card ⋯'s pre-batch-7 rows, promoted from menu literals to named
    /// statics so `cardRowTitles` below is the ONE place the order lives and
    /// the menu composes it (batch 7 adds three rows to this menu, which is
    /// exactly the moment a literal becomes several literals — the
    /// `historyTitle` lesson, applied to its neighbours).
    static let labelRowTitle = "Label Take…"
    static let lockTitle = "Lock Take"
    static let unlockTitle = "Unlock Take"
    static let archiveTitle = "Archive Take"
    static let deleteTitle = "Delete Take"

    /// The card ⋯'s rows in order, for one take, in the vocabulary's own
    /// register (the pin's oracle — the rendered casing is `chromeCase`'s).
    /// The move rows are always PRESENT once a fan exists and are DISABLED
    /// at the end they cannot reach (#57(e): "greys rather than vanishing");
    /// a one-take fan draws neither (P-2, and #57(e)'s own last clause).
    static func cardRowTitles(fanned: Bool, locked: Bool) -> [String] {
        var rows = [historyTitle, labelRowTitle]
        if fanned { rows += [moveUpTitle, moveDownTitle] }
        rows += [locked ? unlockTitle : lockTitle,
                 takeToBlockTitle, archiveTitle, deleteTitle]
        return rows
    }

    // MARK: - Batch 7's own words

    /// The fan moved under the door between the card's render and the tap
    /// (a remote archive, a delete on the Mac). It keeps her picks — there
    /// is nothing to re-click — and mints nothing.
    static let fanChangedRefusal = "This block's takes changed — try the move again."
    static let alreadyFirstRefusal = "This take is already first in the fan."
    static let alreadyLastRefusal = "This take is already last in the fan."
    /// The receipts. "Up"/"Down" rather than the Mac's "earlier"/"later"
    /// because the phone's cards are a vertical STACK and #57(e)'s own rule
    /// is that the direction word follows the strip — ▲▼ in a stack.
    static let movedUpNote = "Take moved up."
    static let movedDownNote = "Take moved down."

    /// The in-sheet locked-take refusal (parity C4a — the unlock door is
    /// ON this card's ⋯, one tap away, so the copy points at it; the
    /// fire-and-DO message-names-the-door form).
    static let lockedTakeCardRefusal =
        "This take is locked — unlock it from its card's ⋯, or branch it."

    /// The verb arm's locked-take refusal (delete/branch reaching a
    /// locked take — same door, "that" grammar).
    static let lockedTakeVerbRefusal =
        "That take is locked — unlock it from its card's ⋯ first."

    /// The archived-take refusal (parity C4a — the "unarchive it on the
    /// Mac" redirect dissolved WITH the archived listing: the road back
    /// sits under the live cards in this same sheet).
    static let archivedTakeRefusal =
        "That take is archived — unarchive it from the archived list below."

    /// The everyday refusals get phone words (the batch-1 posture — and
    /// since parity C4a every named road lives on the PHONE: the lock
    /// and archive redirects dissolved with their doors); rarer races
    /// speak in the operations layer's own words — the op's real
    /// message, never invented behavior.
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
            case .lock: "lock a take"
            case .unlock: "unlock a take"
            case .unarchive: "unarchive a take"
            case .label: "label a take"
            case .reorder: "reorder takes"
            case .takeToBlock: "move a take into a block"
            case .takesToBlocks: "turn takes into blocks"
            }
            return "This note is locked — unlock it to \(act)."
        // 13e batch 3's two AR-1 refusals, in the phone's register (the Mac
        // words the same two facts in `OpsRefusalCopy`, which is Mac-app-
        // local — the fork is recorded on the KnownIssues forked-brains row
        // with every other copy home this app cannot reach).
        case .emptyTakeCannotBecomeABlock:
            return "That take is empty — there's no text to become a block."
        case .noConvertibleTakes:
            return "This block has no other takes with text in them — "
                + "nothing to turn into blocks."
        case .lastActiveVariant where verb == .takeToBlock:
            // I10 through this door reads differently from the delete door's
            // I10: nothing is being removed, so naming Delete Block would be
            // wrong. It names the act that actually splits a block in two —
            // and it names the PHONE's door for it, never a Mac chord
            // (`MobileBlockMenuController.divideTitle`, composed so a rename
            // reaches this sentence).
            return "This block has only one take — a take moves out when there's "
                + "another one left behind. Use \(MobileBlockMenuController.divideTitle) "
                + "in the ⋯ menu instead."
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
            return Self.lockedTakeVerbRefusal
        case .archivedVariant:
            return Self.archivedTakeRefusal
        default:
            return String(describing: error)
        }
    }
}
