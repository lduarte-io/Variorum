//
//  MobileLenses.swift
//  VariorumMobile
//
//  Parity C5 (the RULED lens shape — her sketch: "choose between lenses
//  on the top bar and switch to a different active lens but can save the
//  one you're in"): LENSES on the phone, the compromised shape with the
//  capability whole. The organizing idea, ruled: **a lens is a saved
//  multi-block peek.** Activating a lens applies its EFFECTIVE picks
//  (`Queries.effectiveLensSelection` — dangling picks dropped, the
//  AppSpec §7 fallback class) as sticky peeks through the standing
//  `MobileTakesController` overlay: ZERO store writes to view, viewing
//  free under the seal, peeked-take editing already true, ✓ still the
//  only choosing act (M5/M6's letter — the swipe-writes shape was
//  RIGHTLY rejected at the ruling).
//
//  The acts, all through existing core ops (zero core change):
//  · SWITCH — reset the display to chosen truth, then peek each
//    effective pick (a pick equal to chosen is transparent — the sparse
//    doctrine); "the note" ends the lens session.
//  · SAVE the current view as a lens — the displayed DIVERGENCES from
//    chosen (== the live peeks, by the peek's own invariant), written
//    SPARSE (`createLens` + `setLensChoice`) — the lens doctrine's
//    storage philosophy ("only divergences stored").
//  · SAVE INTO the active lens — her "can save the one you're in"
//    verbatim: upsert the displayed divergences, clear what returned to
//    chosen. (Read-then-act across one runner turn — the R2-10 recorded
//    class; `setLensChoice`'s own guards are the belt.)
//  · ✓ MAKE THIS THE NOTE — `adoptPicksPreservingChosen` (the Mac
//    R89/R92 door's exact op): the outgoing chosen auto-preserved as
//    "chosen until ⟨date⟩", stale picks skipped, ONE core undo entry;
//    adopting what she SEES, so the door serves lens-active and
//    merely-swiped views alike; afterwards the peeks end through the
//    overlay's own chosen-caught-up self-heal and the lens session ends
//    (the ✓-ends-the-peek grammar, scaled up).
//  · RENAME / DELETE — confirm-free (deleting a way of looking never
//    deletes what is looked at — the core's own posture).
//
//  The ACTIVE LENS is SESSION-LOCAL (evaporates with the note — M9's
//  stickiness lifetime; PROVISIONAL PC5-class at the ruling: the Mac
//  keeps per-post lens view memory, and a reopen-in-last-lens flip is
//  one line if she wants it).
//
//  ── PR14 — THE DANGLE SAYS SO LOUDLY, AND OFFERS THE WAY BACK ────────────
//  Her 13j gate ruling (5), verbatim: *"say loudly if that take was archived
//  and this is a fallback WITH a button for quick restore."* Parity C5
//  shipped the honest half — a QUIET count in the row's meta — and recorded
//  that "the LOUD restore door stays 13j's". This is that door, at batch 6b.
//
//  Two places, because "where the lens renders" is two places on a phone:
//  · **the chip on the masthead**, which is on the page the lens is driving —
//    it wears a marker while the ACTIVE lens has a fallback, so the fact is
//    visible without opening anything;
//  · **the sheet, under the active lens's own row** — one line per dangling
//    pick, in the ALARM token, naming the BLOCK (`Queries.tocHandle`, the one
//    block-naming rule) and the state, with **Restore** where a road exists.
//
//  The states are the core's (`Queries.DanglingPick.State`) and they are
//  worded APART, never hedged into one sentence: archived and deleted are
//  different things with different roads back, and `gone`/`foreign` have no
//  road at all — so they say so plainly rather than wearing a button that
//  could only fail (P-2). Restore rides the existing core ops
//  (`unarchiveVariant` / `restoreVariant`); a deleted take that comes back
//  ARCHIVED still dangles, and the line says that too rather than claiming
//  the lens is whole.
//
//  Deliberately Mac-only (workspace-class, her distinction): the
//  multi-column Lenses board, scratch columns, cross-column drag, diff,
//  fan styles, branch-all-fans, promoteLens/duplicateLens (the version
//  family — her "wait for a felt need" ruling's family).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

// MARK: - The brain

@Observable
@MainActor
final class MobileLensesModel {
    /// One sheet row per saved lens, with the honest dangle meta.
    struct RowInfo: Equatable, Identifiable {
        let id: String
        let name: String
        /// Live picks the lens SAYS (raw — `lensChoices`).
        let pickCount: Int
        /// Raw − effective: picks pointing at removed/archived takes.
        let unavailable: Int
        /// **PR14** — the dangling picks themselves, one row each, so the
        /// active lens can say WHICH block fell back and offer the way
        /// back. Read for every lens (the read is one join per lens, the
        /// same pass the counts already ride) and RENDERED only for the
        /// active one — a lens she is not looking through is not falling
        /// back on anything she can see.
        var dangling: [Dangle] = []
        var meta: String { MobileLensesModel.rowMeta(pickCount: pickCount, unavailable: unavailable) }
    }

    /// One dangling pick, with the block it belongs to already named.
    struct Dangle: Equatable, Identifiable {
        let blockID: String
        let variantID: String
        let state: Queries.DanglingPick.State
        /// The block's handle through `Queries.tocHandle` — the ONE
        /// block-naming rule (explicit name where set, else its first
        /// sentence, derived at read time), never a second rule here.
        let handle: String

        var id: String { blockID }
        /// A road exists only for the two states an op can answer.
        var isRestorable: Bool { state == .archived || state == .deleted }
    }

    private let session: AppSession
    let postID: String
    /// The editor whose display the lens drives (the peek machinery's
    /// home). Weak — both live as the Write screen's state, same
    /// lifetime; nil in store-only harness use.
    @ObservationIgnored weak var editor: MobileEditorViewModel?

    private(set) var rows: [RowInfo] = []
    /// The ACTIVE lens — session-local by construction (never persisted,
    /// never synced; M9's lifetime).
    private(set) var activeLensID: String?
    private(set) var activeLensName: String?
    /// True when the displayed arrangement diverges from chosen (== any
    /// peek lives). Computed at refresh/act cadence, never per keystroke
    /// — the sheet covers the page while open, so it cannot go stale
    /// under her fingers.
    private(set) var viewDiverges = false
    /// Refusals + outcomes, one voice (the sheet renders it).
    private(set) var status: String?

    /// **ONE ADOPT AT A TIME** (the Fable sweep's finding 1, 2026-08-30).
    /// `adoptView`'s door is a persistent plain `Button { Task { … } }` in
    /// `saveDoors` — not an alert action, not a `UIMenu` row, so nothing
    /// dismisses it on the first tap — and it renders for as long as
    /// `viewDiverges`, which stays true for the whole of the first flight
    /// (the peeks end only at the chosen-caught-up self-heal, AFTER that
    /// flight's `refreshTakesFromStore`). `adoptView` captures its picks
    /// before its first suspension, so a second tap inside the store
    /// round-trip captures the SAME picks — and the op beneath,
    /// `adoptPicksPreservingChosen`, inserts its preservation lens
    /// UNCONDITIONALLY, before any pick validation, on a table with no
    /// uniqueness. Nothing under the door can notice the second flight, so
    /// a double tap left TWO auto-named "chosen until …" lenses in her list.
    /// Byte-for-byte the mints-a-second-row class the latch exists for.
    ///
    /// Scoped to `adoptView` deliberately: `saveIntoActiveLens`'s writes are
    /// an upsert plus a clear over one lens's rows — they converge, so a
    /// second flight lands the same state and a latch would only hide a tap
    /// that changed nothing. `saveCurrentView` and the rename door live
    /// behind `.alert` action buttons, which dismiss on the first tap and
    /// are outcome-safe by their host.
    private let adoptLatch = MobileWriteLatch()

    init(session: AppSession, postID: String, editor: MobileEditorViewModel? = nil) {
        self.session = session
        self.postID = postID
        self.editor = editor
    }

    // MARK: Copy (pinned statics — the one register)

    static let chipWord = "lens"
    static let noteRowTitle = "the note"
    static let saveDoorTitle = "save the current view as a lens…"
    static let adoptDoorTitle = "✓ make this the note"
    static let renameDoorTitle = "Rename Lens…"
    static let deleteDoorTitle = "Delete Lens"
    static let renameRefusal = "A lens needs a name — nothing was changed."
    static let sealedAdoptRefusal = "This note is locked — unlock it to adopt this view."
    static let emptyStateHint =
        "No lenses yet — swipe blocks to the takes you like, then save the current view."

    static func saveIntoDoorTitle(name: String) -> String {
        "save into \u{201C}\(name)\u{201D}"
    }

    static func adoptedStatus(preservationName: String) -> String {
        "Adopted — the note now shows this view. The old arrangement is kept "
            + "as the lens \u{201C}\(preservationName)\u{201D}."
    }

    /// The honest dangle clause on a lens ROW (parity C5's quiet half — it
    /// stays: a lens she is not looking through owes a count, not an alarm).
    static func rowMeta(pickCount: Int, unavailable: Int) -> String {
        var meta = "\(pickCount) \(pickCount == 1 ? "pick" : "picks")"
        if unavailable > 0 {
            meta += " · \(unavailable) point\(unavailable == 1 ? "s" : "") at a removed "
                + "take — those blocks show the note's own choice"
        }
        return meta
    }

    // MARK: PR14's words (phone-voiced; the Mac's `LensFallbackCopy` is
    // Mac-app-local and fenced this batch — the hoist is recorded)

    /// **The notice, worded to the ACTUAL state.** Her ruling names
    /// "archived" specifically, and archived/deleted/gone/foreign are four
    /// different facts with four different roads (or none) — a single hedged
    /// sentence covering them all would be the guessing-copy defect J8
    /// closed. Every line ends the same way, because the fact she needs
    /// FIRST is what the block is showing instead.
    static func fallbackNotice(_ dangle: Dangle) -> String {
        let cause: String
        switch dangle.state {
        case .archived: cause = "was archived"
        case .deleted: cause = "was deleted"
        case .gone: cause = "is gone"
        case .foreign: cause = "belongs to another block"
        }
        return "\(dangle.handle) — this lens's take \(cause); showing the note's take instead."
    }

    static let restoreVerb = "Restore"

    /// The two states with no road: nothing to act on, said plainly rather
    /// than by a button that could only fail (P-2).
    static let nothingToRestore =
        "That take isn't here to restore — pick another one for this block."

    static let restoredArchived = "Take unarchived — this lens is showing its pick again."
    static let restoredDeleted = "Take put back — this lens is showing its pick again."
    /// The exact flip (#68(b)) can revive a take ARCHIVED — the pick then
    /// STILL dangles, and the line above would have lied. Same correction
    /// the Mac's own door took at 13j ladder A's A3.
    static let restoredDeletedButArchived =
        "Take put back — it came back archived, so this pick still shows the "
        + "note's take. Restore again to unarchive it."

    var chipLabel: String {
        activeLensName.map { "\(Self.chipWord): \($0)" } ?? Self.chipWord
    }

    /// **The masthead marker** (PR14's first half): the chip wears it while
    /// the ACTIVE lens has a fallback, so the fact is loud on the page the
    /// lens is driving rather than only inside the sheet.
    var activeLensHasFallback: Bool {
        guard let activeLensID else { return false }
        return rows.first { $0.id == activeLensID }.map { !$0.dangling.isEmpty } ?? false
    }

    /// The active lens's dangling picks — the sheet's loud region.
    var activeDangles: [Dangle] {
        guard let activeLensID else { return [] }
        return rows.first { $0.id == activeLensID }?.dangling ?? []
    }

    // MARK: Reads

    /// The listing + divergence state, one read (cost ∝ this post's
    /// lenses × their picks — the open-a-sheet class, never corpus).
    func refresh() async {
        do {
            let fresh: [RowInfo] = try await session.database.read { [postID] db in
                // The block handles, once for the whole pass — `blockTOC` is
                // the standing name-carrying read and its cost is the POST's
                // (P1), where naming each dangle separately would be one read
                // per pick.
                let handles = try Queries.blockTOC(db, post: postID).reduce(
                    into: [String: String]()
                ) { $0[$1.blockID] = Queries.tocHandle(name: $1.name, text: $1.text) }
                return try Queries.lenses(db, post: postID).map { lens in
                    let raw = try Queries.lensChoices(db, lens: lens.id)
                    let effective = try Queries.effectiveLensSelection(db, lens: lens.id)
                    let dangling = try Queries.danglingLensPicks(db, lens: lens.id)
                    return RowInfo(
                        id: lens.id, name: lens.name,
                        pickCount: raw.count, unavailable: raw.count - effective.count,
                        dangling: dangling.keys.sorted().compactMap { blockID in
                            guard let pick = dangling[blockID] else { return nil }
                            return Dangle(
                                blockID: blockID, variantID: pick.variantID,
                                state: pick.state,
                                // A pick on a block that has LEFT this note
                                // has no handle to show; the id would be
                                // noise, so the row names the state alone.
                                handle: handles[blockID] ?? "a block no longer in this note")
                        })
                }
            }
            rows = fresh
            // A remotely-deleted active lens ends the session honestly.
            if let activeLensID, !fresh.contains(where: { $0.id == activeLensID }) {
                self.activeLensID = nil
                activeLensName = nil
            } else if let activeLensID {
                activeLensName = fresh.first { $0.id == activeLensID }?.name
            }
            viewDiverges = !(editor?.takes.peeks.isEmpty ?? true)
        } catch {
            status = String(describing: error)
        }
    }

    // MARK: Switch (zero store writes — viewing)

    /// Activate a lens: reset the display to chosen truth, then peek
    /// each EFFECTIVE pick. A dangling pick was dropped by the query —
    /// that block simply shows the note's own choice (the fallback,
    /// honest in the row meta). Bails silently mid-IME composition (the
    /// flip's own posture — the sheet's presence makes it unreachable
    /// in practice).
    func activate(_ lensID: String) async {
        guard let editor, !editor.markedTextActive else { return }
        status = nil
        do {
            let picks = try await session.database.read { db in
                try Queries.effectiveLensSelection(db, lens: lensID)
            }
            editor.takes.endAllPeeksRestoringDisplay()
            for (blockID, variantID) in picks.sorted(by: { $0.key < $1.key }) {
                editor.takes.peek(blockID: blockID, to: variantID)
            }
            activeLensID = lensID
            activeLensName = rows.first { $0.id == lensID }?.name
            viewDiverges = !editor.takes.peeks.isEmpty
        } catch {
            status = String(describing: error)
        }
    }

    /// "the note": end the lens session — every peek ends, the display
    /// is truth again.
    func returnToNote() {
        guard let editor, !editor.markedTextActive else { return }
        editor.takes.endAllPeeksRestoringDisplay()
        activeLensID = nil
        activeLensName = nil
        viewDiverges = false
        status = nil
    }

    // MARK: Saves (sparse — the lens doctrine's storage philosophy)

    /// The displayed arrangement's divergences from chosen — exactly the
    /// live peeks (the controller's invariant: a peek exists iff the
    /// display diverges; landing on chosen ends it).
    private var displayedDivergences: [String: String] {
        editor?.takes.peeks ?? [:]
    }

    /// Save the current view as a NEW lens (name prompted at the door).
    /// Sparse: only divergences are written; an undiverged view mints
    /// the empty lens — the transparent default, legal and harmless.
    /// The saved lens becomes the active one ("you're now in it").
    @discardableResult
    func saveCurrentView(name: String) async -> Bool {
        status = nil
        let picks = displayedDivergences
        do {
            let lens: Lens = try await session.runner.run { [postID] ops in
                let lens = try ops.createLens(post: postID, name: name)
                for (blockID, variantID) in picks.sorted(by: { $0.key < $1.key }) {
                    _ = try ops.setLensChoice(
                        lens: lens.id, block: blockID, variant: variantID)
                }
                return lens
            }
            activeLensID = lens.id
            activeLensName = lens.name
            await refresh()
            return true
        } catch {
            status = Self.refusalMessage(error)
            return false
        }
    }

    /// "Save the one you're in" (her verbatim): the active lens's picks
    /// become the displayed divergences — upsert what diverges, clear
    /// what returned to chosen. Read-then-act across one runner turn
    /// (the R2-10 recorded class; the op's own guards are the belt).
    func saveIntoActiveLens() async {
        guard let lensID = activeLensID else { return }
        status = nil
        let picks = displayedDivergences
        do {
            let (existing, effective) = try await session.database.read { db in
                (try Queries.lensChoices(db, lens: lensID),
                 try Queries.effectiveLensSelection(db, lens: lensID))
            }
            try await session.runner.run { ops in
                for (blockID, variantID) in picks.sorted(by: { $0.key < $1.key }) {
                    _ = try ops.setLensChoice(
                        lens: lensID, block: blockID, variant: variantID)
                }
                // Clear ONLY picks the user's view actually returned to
                // chosen — an EFFECTIVE pick with no displayed divergence.
                // A DANGLING pick (its take archived/dead — in `existing`
                // but not `effective`) shows nothing to return from, and
                // clearing it would tombstone exactly the row the honest
                // dangle meta reports and 13j's restore road revives
                // (C5 ladder MINOR-3). A pick on a DEPARTED block (live
                // take, block released from this note) still clears —
                // byte-identical to the prior behavior, in round 1's
                // recorded departed-blocks family (R2 NIT-2's precision).
                for blockID in existing.keys.sorted()
                where picks[blockID] == nil && effective[blockID] != nil {
                    try ops.clearLensChoice(lens: lensID, block: blockID)
                }
            }
            await refresh()
        } catch {
            status = Self.refusalMessage(error)
        }
    }

    // MARK: Adopt (the one lens→chosen door — R89/R92's op)

    /// "✓ make this the note": the displayed view's divergences → chosen
    /// through `adoptPicksPreservingChosen` — adopting SWAPS, never
    /// destroys (the outgoing chosen is auto-preserved as a lens; the
    /// status names it, the visible road back). The peeks then end
    /// through the overlay's own chosen-caught-up self-heal at the
    /// refresh delivery, and the lens session ends (✓ ends the peek,
    /// scaled up). Refuses under the seal in the standing wording.
    /// Returns whether this call FLEW — `false` means the latch turned it
    /// away because a flight was already in the air. Discardable, because
    /// the door does not care (P-2: a declined second tap is not a refusal
    /// and must never be reported as one); it exists so a PIN can tell the
    /// two outcomes apart. Counting the rows the store ended with cannot:
    /// a second flight that happened to start after the first finished
    /// finds `displayedDivergences` self-healed empty, returns at
    /// `guard !picks.isEmpty`, and leaves the same one row a latched
    /// decline would — green over nothing (R2-5).
    @discardableResult
    func adoptView() async -> Bool {
        await adoptLatch.runIfFree { await self.adoptViewOnce() }
    }

    private func adoptViewOnce() async {
        let picks = displayedDivergences
        guard !picks.isEmpty else { return }  // P-2: the door only renders divergent
        status = nil
        do {
            let preservation: Lens = try await session.runner.run { [postID] ops in
                try ops.adoptPicksPreservingChosen(post: postID, picks: picks)
            }
            activeLensID = nil
            activeLensName = nil
            await editor?.refreshTakesFromStore()
            status = Self.adoptedStatus(preservationName: preservation.name)
            await refresh()
        } catch {
            status = Self.refusalMessage(error)
        }
    }

    // MARK: PR14 — restore a dangling pick (her 13j gate ruling (5))

    /// **The one-tap way back**, on the existing core ops and nothing new:
    /// `unarchiveVariant` for an archived pick, `restoreVariant` for a
    /// deleted one. `gone` and `foreign` have no road and the door does not
    /// render for them — this guard is the belt behind that face (P-2).
    ///
    /// The receipt reads the OP's own answer, never an assumption: the
    /// restore is an exact flip (#68(b)), so a take that was archived when
    /// it was deleted comes back ARCHIVED — the pick still dangles, and
    /// saying "showing its pick again" there would be the same small
    /// dishonesty this door exists to end.
    ///
    /// Then the LENS IS RE-APPLIED: the pick is effective now, so the block
    /// really does go back to showing it. Re-activating is how a peek set
    /// gets rebuilt from `effectiveLensSelection` — the same road switching
    /// to the lens takes, so there is no second way for the display to be
    /// assembled.
    func restoreDangling(_ dangle: Dangle) async {
        status = nil
        guard dangle.isRestorable else {
            status = Self.nothingToRestore
            return
        }
        do {
            let receipt: String
            switch dangle.state {
            case .archived:
                try await session.runner.run { ops in
                    try ops.unarchiveVariant(dangle.variantID)
                }
                receipt = Self.restoredArchived
            case .deleted:
                let restored = try await session.runner.run { ops in
                    try ops.restoreVariant(dangle.variantID)
                }
                receipt = restored == .archived
                    ? Self.restoredDeletedButArchived
                    : Self.restoredDeleted
            case .gone, .foreign:
                return  // unreachable — the guard above
            }
            await editor?.refreshTakesFromStore()
            await refresh()
            if let activeLensID { await activate(activeLensID) }
            status = receipt
        } catch {
            status = Self.refusalMessage(error)
        }
    }

    // MARK: Rename / delete (confirm-free — the core's own posture)

    func rename(_ lensID: String, to name: String) async {
        status = nil
        do {
            try await session.runner.run { ops in
                try ops.renameLens(lensID, newName: name)
            }
            await refresh()
        } catch {
            status = Self.refusalMessage(error)
        }
    }

    func delete(_ lensID: String) async {
        status = nil
        do {
            try await session.runner.run { ops in
                try ops.deleteLens(lensID)
            }
            // Deleting the ACTIVE lens ends the session (staying "in" a
            // deleted way of looking would be incoherent); the display
            // resets to truth.
            if activeLensID == lensID {
                returnToNote()
            }
            await refresh()
        } catch {
            status = Self.refusalMessage(error)
        }
    }

    // MARK: Refusal voice

    static func refusalMessage(_ error: Error) -> String {
        switch error {
        case OperationError.invalidLensName:
            Self.renameRefusal
        case OperationError.lockedPost:
            Self.sealedAdoptRefusal
        default:
            String(describing: error)
        }
    }
}

// MARK: - The sheet (LK4 — the references sheet's grammar)

struct MobileLensSheet: View {
    @Bindable var model: MobileLensesModel
    let tokens: VoiceTokens
    @Environment(\.dismiss) private var dismiss

    @State private var savePresented = false
    @State private var saveField = ""
    @State private var renamePrompt: RowPrompt?
    @State private var renameField = ""

    /// The alert's SUBJECT, carried into its action closure by
    /// `presenting:` rather than read back out of `@State` at dismissal.
    /// It holds the id and nothing else: the TextField is seeded from
    /// `row.currentNameForPrompt` at the opener, so a second copy of the
    /// name here was write-only residue (round-1 NIT 10).
    struct RowPrompt: Identifiable {
        let lensID: String
        var id: String { lensID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tokens.chromeLabel("Lenses"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Done")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    noteRow
                    if model.rows.isEmpty {
                        Text(tokens.chromeLabel(MobileLensesModel.emptyStateHint))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(model.rows) { row in
                        lensRow(row)
                        // PR14: the LOUD half, under the row it is about —
                        // only for the lens she is actually looking through.
                        if row.id == model.activeLensID {
                            ForEach(row.dangling) { dangle in
                                fallbackRow(dangle)
                            }
                        }
                    }
                    Divider()
                    saveDoors
                    if let status = model.status {
                        Text(status)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await model.refresh() }
        .alert("Save as Lens", isPresented: $savePresented) {
            TextField("Name", text: $saveField)
            Button("Save") {
                let name = saveField
                let model = model
                Task {
                    if await model.saveCurrentView(name: name) { saveField = "" }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A lens remembers which take each block shows — the note itself never moves.")
        }
        // **THE CANDIDATE SIXTH CONFIRM SITE, SETTLED BY SHAPE** (4.5c-phone
        // item 3; §63 routed it here as *"not in the affected class — but it
        // could not drive a genuine tap, so it is NOT PROVEN IMMUNE"*).
        //
        // It was the last read-back-your-own-subject site on the phone: the
        // action asked `if let prompt = renamePrompt`, a computed binding over
        // this view's `@State`, whose setter SwiftUI's dismissal machinery
        // clears. The probe said the handler runs FIRST on the reachable road,
        // which is why it never shipped as a broken door — but "first" was a
        // measurement of SwiftUI's ordering, not a property of this code, and
        // the four doors 4.5b fixed were broken by exactly that ordering
        // moving one step.
        //
        // `presenting:` retires the question instead of re-answering it: the
        // subject arrives as the closure's PARAMETER, captured when the alert
        // is built, so there is nothing left to read back and no ordering to
        // depend on. The three row doors 4.5b fixed took this same shape, and
        // the rule it keeps is that batch's own: *a binding setter must never
        // clear state that an action's continuation will read back.*
        //
        // `renameField` stays read synchronously and that is safe by the same
        // rule read forwards: nothing clears it at dismissal.
        .alert(
            "Rename Lens",
            isPresented: .init(
                get: { renamePrompt != nil },
                set: { if !$0 { renamePrompt = nil } }),
            presenting: renamePrompt
        ) { prompt in
            TextField("Name", text: $renameField)
            Button("Rename") {
                let name = renameField
                let model = model
                Task { await model.rename(prompt.lensID, to: name) }
                renamePrompt = nil
            }
            Button("Cancel", role: .cancel) { renamePrompt = nil }
        }
    }

    /// "the note" — chosen truth; the active marker rides whichever row
    /// the display currently follows (the voice's own `›` selection
    /// grammar).
    private var noteRow: some View {
        Button {
            model.returnToNote()
        } label: {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(
                    (model.activeLensID == nil ? "› " : "") + MobileLensesModel.noteRowTitle))
                    .font(tokens.body)
                    .foregroundStyle(model.activeLensID == nil ? tokens.accent : tokens.ink)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("The Note")
    }

    private func lensRow(_ row: MobileLensesModel.RowInfo) -> some View {
        Button {
            let model = model
            Task { await model.activate(row.id) }
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(tokens.chromeLabel(
                    (model.activeLensID == row.id ? "› " : "") + row.name))
                    .font(tokens.body)
                    .foregroundStyle(model.activeLensID == row.id ? tokens.accent : tokens.ink)
                    .lineLimit(1)
                Text(tokens.chromeLabel(row.meta))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(row.name)
        .contextMenu {
            Button(tokens.chromeLabel(MobileLensesModel.renameDoorTitle)) {
                renameField = row.currentNameForPrompt
                renamePrompt = RowPrompt(lensID: row.id)
            }
            Button(tokens.chromeLabel(MobileLensesModel.deleteDoorTitle), role: .destructive) {
                let model = model
                Task { await model.delete(row.id) }
            }
        }
    }

    /// **PR14's loud line** — the ALARM token, not the quiet meta, because
    /// her ruling's word was *loudly*; and a real `Button` beside it where a
    /// road exists (§15's trap (b): a door a pin can drive). The two roadless
    /// states carry the plain sentence instead of a button that could only
    /// fail (P-2).
    private func fallbackRow(_ dangle: MobileLensesModel.Dangle) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tokens.chromeLabel(MobileLensesModel.fallbackNotice(dangle)))
                .font(tokens.small)
                .foregroundStyle(tokens.alarm)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(MobileLensesModel.fallbackNotice(dangle))
            if dangle.isRestorable {
                Button {
                    let model = model
                    Task { await model.restoreDangling(dangle) }
                } label: {
                    Text(tokens.chromeLabel(MobileLensesModel.restoreVerb))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "\(MobileLensesModel.restoreVerb) \(dangle.handle)")
            } else {
                Text(tokens.chromeLabel(MobileLensesModel.nothingToRestore))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(MobileLensesModel.nothingToRestore)
            }
        }
        .padding(.leading, 12)
    }

    /// The save/adopt doors (P-2 throughout: save-into renders only
    /// while a lens is active; adopt only while the view diverges).
    private var saveDoors: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                saveField = ""
                savePresented = true
            } label: {
                Text(tokens.chromeLabel(MobileLensesModel.saveDoorTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Save the Current View as a Lens")
            if let name = model.activeLensName {
                Button {
                    let model = model
                    Task { await model.saveIntoActiveLens() }
                } label: {
                    Text(tokens.chromeLabel(MobileLensesModel.saveIntoDoorTitle(name: name)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Save into the Active Lens")
            }
            if model.viewDiverges {
                Button {
                    let model = model
                    Task { await model.adoptView() }
                } label: {
                    Text(tokens.chromeLabel(MobileLensesModel.adoptDoorTitle))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Make This the Note")
            }
        }
    }
}

private extension MobileLensesModel.RowInfo {
    /// The rename prompt prefills the STORED name (the rename-note
    /// door's own grammar).
    var currentNameForPrompt: String { name }
}
