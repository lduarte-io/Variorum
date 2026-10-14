//
//  MobileUndoDoor.swift
//  VariorumMobile
//
//  **M20 — THE STRUCTURAL UNDO/REDO DOOR, and it is HER OWN PROPOSAL**
//  (round 2, §29's R10, verbatim: *"the phone just needs a structural undo /
//  redo? and a block restore door?"*).
//
//  **Nothing here is machinery.** The stack is `UndoStack` in core, held
//  session-scoped on `AppSession`, and the phone has been REGISTERING
//  entries into it since parity C2 — divide, merge, extract, delete, the
//  takes browser's verbs, and the whole "Delete Blocks" compound (batch 1b
//  verified the round trip against store bytes: one undo restores all N
//  blocks in place, one redo removes them again). What was missing was the
//  AFFORDANCE, which is exactly the distinction §24's MAJOR turned on: *a
//  capability verified at the API is not a capability until a door reaches
//  it.*
//
//  This controller is that affordance's brain-free routing layer: it holds
//  no rule of its own. LIFO, the redo future, the insurance class, the
//  labels — all `UndoStack`'s, shared. What lives here is the phone's face
//  on it: the flush contract, which surface is asking, and the words (the
//  shared ones from `StructuralUndoCopy`).
//
//  **TWO DOORS, by her ruling and for two different moments:**
//  · **THE RECEIPT** — the phone already shows "N blocks deleted." after a
//    structural act, and an Undo beside it is the standard iOS shape. This
//    is the one that matters, because it is where she is looking at the
//    moment she wants it back. `MobileEditorViewModel.report(_:action:)`
//    carries it; every structural door that registers an entry offers it.
//  · **THE PERSISTENT DOOR** — the masthead's ⋯ sheet
//    (`MobileNoteActions`), carrying the stack's live `topLabel` and
//    `topRedoLabel`, for acts whose receipt has already passed.
//
//  **WHY THIS DOOR FLUSHES FIRST, and it is not tidiness.** The A12
//  destructive-undo warning (her 13d ruling) is precisely the question
//  *"has any take been edited SINCE the operation?"*, and
//  `UndoStack.pendingUndoWarning` answers it by reading `working_text`
//  ROWS. Inside the autosave debounce those rows do not yet hold what she
//  typed, so an unflushed buffer makes the warning answer NO to a question
//  whose true answer is YES — the warning would silently not fire in
//  exactly the case it exists for. The flush is what makes it honest, and
//  the phone's standing structural contract wanted it anyway.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileUndoDoor {
    /// Which surface raised the warning. Two `.alert` hosts exist (the
    /// masthead's receipt and the ⋯ sheet), and only the one that ASKED may
    /// present — a sheet is over the masthead, so two unconditioned hosts
    /// would both try. The copy still lives in ONE place; only the host is
    /// discriminated.
    enum Surface: Equatable, Sendable {
        case receipt
        case sheet
    }

    struct PendingWarning: Equatable {
        let warning: UndoStack.PendingUndoWarning
        let surface: Surface
    }

    @ObservationIgnored private let session: AppSession
    @ObservationIgnored weak var model: MobileEditorViewModel?

    /// **THE ASK'S PRESENTATION.** Non-nil while the A12 warning is on
    /// screen; the two host bindings below project it, and SwiftUI clears it
    /// through them the instant an action is tapped.
    var pendingWarning: PendingWarning?

    /// **THE ASK'S AUTHORIZATION — and it deliberately OUTLIVES the
    /// presentation** (batch 4.5b's confirm BLOCKER).
    ///
    /// THE RULE, and it names the property that matters rather than a shape:
    /// *a binding setter must never clear state that an action's continuation
    /// will read back.* SwiftUI sets `isPresented` to `false` synchronously
    /// inside tap handling, while an action's `Task { … }` cannot resume
    /// until that handling yields. The shipped setter answered that write-back
    /// with `cancelPendingUndo()` — so pressing **Undo** CANCELLED the undo
    /// and reported *"Undo cancelled — nothing changed."*, while
    /// `confirmPendingUndo()`'s `guard pendingWarning != nil` found the state
    /// already gone.
    ///
    /// The deeper defect is the one that made it possible: **the setter was
    /// deciding a PRODUCT question ("she cancelled") from a MECHANICAL event
    /// ("the alert closed")**, which it cannot know — only the buttons know,
    /// and both hosts already carry an explicit `Button("Cancel") {
    /// cancelPendingUndo() }`. So the setter now clears the PRESENTATION and
    /// nothing else, and this field is what the confirm and cancel roads both
    /// stand on. Whichever order the setter and the button's closure run in,
    /// the authorization is intact when the continuation reads it.
    ///
    /// **Why the fix is here and not at the hosts:** this door has TWO alert
    /// hosts — the receipt's (`MobileWriteView`) and the ⋯ sheet's
    /// (`MobileNoteActions`) — so a seam fix immunizes both and cannot be
    /// re-broken by a third host later. The three value-carrying confirms
    /// (Trash, Library row, shelf row) take the other shape, `presenting:`,
    /// because their acts genuinely need the value.
    private var askedWarning: PendingWarning?

    /// **The two alert hosts' bindings — `@Bindable`-projected, never an
    /// inline `Binding(get:set:)`** (§15's trap (a), the phone's rule stated
    /// as code). Each is true only for the surface that ASKED, so the two
    /// hosts are mutually exclusive by construction and the copy stays in
    /// one place. **The setter clears the PRESENTATION only** — see
    /// `askedWarning`.
    var warningAtReceipt: Bool {
        get { pendingWarning?.surface == .receipt }
        set { if !newValue { pendingWarning = nil } }
    }

    var warningAtSheet: Bool {
        get { pendingWarning?.surface == .sheet }
        set { if !newValue { pendingWarning = nil } }
    }

    /// One flight at a time — the structural doors' latch, same reason: an
    /// inverse is a DB write, and a second press inside the first's
    /// suspension would pop a second entry she never asked for.
    private(set) var inFlight = false

    init(session: AppSession) {
        self.session = session
    }

    /// The stack's live ends, straight from the session's own projection
    /// (`UndoMenuState`, refreshed by the stack's change observer). Read in
    /// a SwiftUI body these track, so a door's words can never name an
    /// entry that has since moved.
    var undoLabel: String? { session.undoMenuState.topLabel }
    var redoLabel: String? { session.undoMenuState.topRedoLabel }

    // MARK: - Undo

    /// The door's entry point. Flush (above), ask the stack whether this
    /// undo is in the INSURANCE class, and either raise the warning or act.
    func beginUndo(from surface: Surface) async {
        guard let model else { return }
        guard !inFlight else {
            model.report(Self.anotherIsLanding)
            return
        }
        inFlight = true
        defer { inFlight = false }
        // A fresh ask supersedes any authorization left behind by a warning
        // that was dismissed without an answer (a sheet closing over its own
        // alert is the only road there, and it must not authorize this one).
        askedWarning = nil

        guard await model.flushPendingText() else { return }
        let stack = session.undoStack
        do {
            let warning = try await session.runner.run { ops in
                stack.pendingUndoWarning(with: ops)
            }
            if let warning {
                let asked = PendingWarning(warning: warning, surface: surface)
                pendingWarning = asked
                askedWarning = asked
                return
            }
        } catch {
            model.report(StructuralUndoCopy.undoFailed(Self.refusal(error)))
            return
        }
        await runUndo()
    }

    /// The confirmed road (the warning was shown and she said yes). It stands
    /// on `askedWarning`, NOT on `pendingWarning` — the presentation is
    /// already gone by the time this continuation runs.
    func confirmPendingUndo() async {
        guard askedWarning != nil else { return }
        askedWarning = nil
        pendingWarning = nil
        guard !inFlight else { return }
        inFlight = true
        defer { inFlight = false }
        await runUndo()
    }

    /// The Cancel button's road — the only road that means *she cancelled*.
    /// It guards on the AUTHORIZATION, because the alert's dismissal may
    /// already have cleared the presentation in the same synchronous turn.
    func cancelPendingUndo() {
        guard askedWarning != nil else { return }
        askedWarning = nil
        pendingWarning = nil
        model?.report(StructuralUndoCopy.undoCancelled)
    }

    private func runUndo() async {
        guard let model else { return }
        let stack = session.undoStack
        do {
            let label = try await session.runner.run { ops in
                try stack.undo(with: ops)
            }
            // The surface is a projection of rows the inverse just moved —
            // re-read through the ONE fresh-read door, exactly as every
            // structural door settles.
            await model.refreshTakesFromStore()
            // A landed undo can itself be redone, so the receipt offers the
            // OTHER direction — the ping-pong her R10 asked for, reachable
            // without opening anything.
            model.report(
                label.map(StructuralUndoCopy.undone) ?? StructuralUndoCopy.nothingToUndo,
                action: label == nil ? nil : .redo)
        } catch {
            // A failed inverse STAYS on the stack (the UndoStack doctrine):
            // she resolves the refusal — unseal the note, say — and presses
            // again, so the door keeps offering.
            model.report(StructuralUndoCopy.undoFailed(Self.refusal(error)))
        }
    }

    // MARK: - Redo

    /// The undo door's exact mirror, with NO warning — A12 named undo alone,
    /// deliberately. Redo is NOT discard-free, and this door must not say it
    /// is: it re-applies from do-time pre-images, so a take whose buffer she
    /// edited since the undo is overwritten by the post-op text — that
    /// writing is set aside, in the undo warning's own words
    /// (`discardingUndoDetail`) — behind the quiet insurance savepoint
    /// `Operations.reapplyStructural` takes first, readable back from the
    /// block's Block History. (18o U1, 17e P29: this line used to claim the
    /// opposite; the behaviour is unchanged.)
    func redo() async {
        guard let model else { return }
        guard !inFlight else {
            model.report(Self.anotherIsLanding)
            return
        }
        inFlight = true
        defer { inFlight = false }

        guard await model.flushPendingText() else { return }
        let stack = session.undoStack
        do {
            let label = try await session.runner.run { ops in
                try stack.redo(with: ops)
            }
            await model.refreshTakesFromStore()
            model.report(
                label.map(StructuralUndoCopy.redone) ?? StructuralUndoCopy.nothingToRedo,
                action: label == nil ? nil : .undo)
        } catch {
            model.report(StructuralUndoCopy.redoFailed(Self.refusal(error)))
        }
    }

    // MARK: - Words

    /// 18k C5: the words live in the shared home now (the Mac's door speaks
    /// them too) — byte-identical, forwarded so this door's call sites and
    /// pins read exactly as before.
    static let anotherIsLanding = StructuralUndoCopy.anotherIsLanding

    /// **The A12 warning's DETAIL, in phone words.** The question is shared
    /// (`StructuralUndoCopy.discardingUndoQuestion`); this half is not,
    /// because the Mac's names ⌘S and a chord is a platform fact.
    ///
    /// **It names a FACE, deliberately, and not a road** — and since batch
    /// 9 that distinction is load-bearing: her ⋯ letter moved `Block
    /// History…` off the block ⋯ and onto each live take card's own ⋯
    /// (bar ⑂ → the take's ⋯ → the row, composed at
    /// `MobileTakesBrowserController.historyTitle`), so a sentence that
    /// spelled the road would now be three taps long and would go stale
    /// the next time she moves it. The face is where a savepoint is read
    /// back here, the face's NAME is what she looks for, and the guide's
    /// "five places" lesson is where the road is taught.
    /// **If this sentence ever grows a road, compose it from that
    /// constant** rather than typing the menu names again.
    static func discardingUndoDetail(_ warning: UndoStack.PendingUndoWarning) -> String {
        let subject = warning.bufferCount == 1
            ? "One take has been edited since"
            : "\(warning.bufferCount) takes have been edited since"
        return "\(subject) — undoing puts back the text as it was before the "
            + "\(warning.label.lowercased()), so that writing is set aside. "
            + "It is saved first, so you can bring it back from the block's "
            + "Block History at any time."
    }

    /// The everyday refusals in phone words. **18m U3:** the shared refusal
    /// table speaks everything it has words for — the seal included ("This
    /// note is locked — unlock it first.": the ONE stem in the phone's door
    /// words, act-less because an undo has no one act to name) — and the
    /// operations layer's own description stands where it has none. Only the
    /// locked-take arm stays: it names the phone's takes-sheet road. (The
    /// Mac's undo door already spoke the table, so the two undo-failure lines
    /// now read the same but for each platform's door words.)
    static func refusal(_ error: Error) -> String {
        guard let error = error as? OperationError else { return String(describing: error) }
        switch error {
        case .lockedVariant:
            return MobileEditorViewModel.lockedTakeRefusal
        default:
            return OpsRefusalCopy.words(for: error, roads: .phone) ?? String(describing: error)
        }
    }
}
