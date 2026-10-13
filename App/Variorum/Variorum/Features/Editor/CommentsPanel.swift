//
//  CommentsPanel.swift
//  Variorum
//
//  Phase 13, C1 — the block's comments panel (R7 + the §14 items 6/9
//  letter): every comment face (margin card, inline strip, count badge,
//  Block menu) opens here. Working notes on a BLOCK, never per-take; CRUD
//  through the Stage A operations; and the DELETED section — visible and
//  resurrectable ("the feature shouldn't be excessively skimpy").
//
//  ── 13u3 UNIT A2: THE PANEL BECAME A TEXT EDITOR ─────────────────────────
//  The gutter memo's §2 D, from her item 3: *"the comment add box is so
//  small and it doesn't make sense given how big the overall comment box is
//  that the whole thing isn't more of the text editor that you can write and
//  click on."* So the `List` of rows with a one-line `TextField` stapled
//  underneath is gone: the panel is ONE scrolling writing surface — every
//  comment an editable area in place, the add area owning every point they
//  leave, ⌘⏎ committing what you are writing and ⎋ undoing the most local
//  thing, ⏎ a newline everywhere (a comment is free prose).
//
//  Three things that did NOT change, deliberately: the OPERATIONS (add,
//  edit, delete, restore, their seal refusals and their travel rules are
//  core's, byte-untouched), the deleted fold and its restore door, and the
//  page — the margin card in the gutter stays a read face and a door, which
//  is her ruling R-13u3-6, so a comment has ONE live-text home.
//
//  Messages are CLASSED at the door they come from (refusal · receipt, the
//  status seam's law) and rendered in the voice's own registers.
//
//  ── VX-179 U1: TRUE DELETE (her R-VX179-3, 2026-10-12) ────────────────────
//  Her ask: *"why when a comment is deleted you can go into deleted comments
//  and not even true delete it from there."* Each deleted row now carries
//  "Delete forever…" beside Restore, confirming every time. It is the Delete
//  Now road, not a new one: `requestPurge` writes a purge intent, the fold's
//  fence (`Queries.deletedBlockComments`) drops the row at once on every
//  device, and the janitor (or, unsynced, the local sweep) takes the bytes.
//
//  ── VX-179 U3: THE CARET, AND THE PRISTINE PASS (her items 1 + 4) ────────
//  *"the comment pane's cursor to start typing in is misaligned"* — the
//  placeholder was a SwiftUI overlay placed by a guess at `TextEditor`'s
//  private insets, 8 pt off on macOS 27 (traced and measured — the run
//  record's U3 section). Every writing area is now `CommentTextArea`, whose
//  geometry is ours (`CommentsPanelMetrics`) and whose placeholder and mark
//  are laid out by the same engine as her text. Then the look: one WRITING
//  column for every word (the composer's, each comment's, each stamp's) and
//  one CHROME column for edges; the add area reads as a writing box — the
//  voice's card paper and hairline, the accent while the caret is in it, its
//  keys and its Add inside it; the deleted fold a quieter twin of the live
//  list; every word in `CommentsPanelCopy`; every refusal in words
//  (`CommentsPanelRefusalCopy`). The §2 D contract is untouched: the add
//  area owns the leftover room, a click anywhere in it lands the caret,
//  ⌘⏎ files, ⎋ clears, ⏎ is a newline.
//

import AppKit
import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class CommentsPanelModel {
    @ObservationIgnored let session: AppSession
    let blockID: String

    init(session: AppSession, blockID: String) {
        self.session = session
        self.blockID = blockID
        // Deliberately side-effect-free (ladder round 3, F1): this model is
        // minted inside `State(initialValue:)`, whose expression SwiftUI
        // runs on EVERY construction of the view value — including the
        // phantom values the sheet/popover content closures produce while
        // the panel is presented, which are then discarded. The park
        // restore lives in `restoreParkedDraft()`, called from the panel's
        // `.task` — the installed lifecycle, once per real presentation.
    }

    /// **RUN A ladder round 2 (the MAJOR, binding 5's sweep) — the open of
    /// the SAME block's panel reads a REFUSED draft back**, amended twice
    /// at round 3: it runs from the panel's `.task` (F1 — never from
    /// `init`, whose `State(initialValue:)` home runs on phantom view
    /// constructions too; the pad's `.onAppear` shape), and it is a PEEK
    /// (F2 — this panel's close never files the add draft, #118(a), so a
    /// consuming restore made reopen-then-close lose the words for good;
    /// the park holds until the same draft LANDS or a newer refusal
    /// replaces it). The add draft comes back into the add area, a refused
    /// in-place edit back onto its row. One recorded corner (QUESTIONS
    /// #140): a parked EDIT draft whose comment was deleted elsewhere
    /// while parked is pruned by the first snapshot's `survivingDrafts` —
    /// over-preservation everywhere else, never loss.
    func restoreParkedDraft() {
        guard let heldDraft = session.commentDraftPark.peek(forBlock: blockID) else { return }
        if let id = heldDraft.commentID {
            drafts[id] = heldDraft.text
        } else {
            addDraft = heldDraft.text
        }
        // The receipt register, deliberately — nothing is being refused;
        // the line says why the box is not empty.
        status = .receipt(CommentDraftPark.restoredNote)
    }

    private(set) var comments: [BlockComment] = []
    private(set) var deleted: [BlockComment] = []

    /// **THE PANEL'S ONE MESSAGE SLOT — receipt or refusal** (13u3 UNIT A2).
    /// The class is decided AT THE DOOR that produced it (18i's R-Q5, the
    /// status seam's law), never guessed by the view from the words. This is
    /// `Shared/RecoveryStatus`, the same type the tray's panel uses, for the
    /// reason that type's own doc gives: a receipt/refusal split written
    /// twice is the drift the split exists to prevent.
    ///
    /// **Why a LOCAL slot and not `StatusCenter`:** the panel is a sheet or a
    /// popover over the shell, so the shell's toast sits BEHIND it — a
    /// refusal delivered there is a refusal she cannot read. The tray panel
    /// made the same call for the same geometry. Everything the panel says is
    /// classed here and rendered in the voice's own registers (alarm for a
    /// refusal, muted for a receipt).
    private(set) var status: RecoveryStatus?

    /// The pre-existing read, kept as a forwarder so every shipped pin over
    /// the panel rides unmodified (the `TrayViewModel` parity pattern).
    var statusMessage: String? { status?.text }

    /// **THE DRAFTS.** Edit-in-place means the panel holds unsaved prose, and
    /// it holds it HERE rather than in per-row view state for three concrete
    /// reasons: a row is rebuilt on every projection arrival (its own
    /// `@State` is one identity change away from going with it), the panel
    /// itself is a sheet or a popover that can leave while a draft is dirty
    /// (`onDisappear` commits what the model holds), and a draft in a view
    /// body cannot be pinned — the rules below are the FACE, not pixels.
    /// An entry exists only for a comment she has actually typed into.
    private(set) var drafts: [String: String] = [:]

    /// The add area's draft. Settable — the add editor binds straight to it.
    var addDraft: String = ""

    /// How many comments this panel has filed — the view's cue to reveal the
    /// newest one (a filed comment that lands below the fold was not visibly
    /// done). A counter rather than an id because the id arrives with the
    /// projection, not with the write.
    private(set) var filedCount = 0

    /// Ids whose save has LANDED and whose echo has not arrived yet. Without
    /// this the row wears its "unsaved" mark for the milliseconds between the
    /// write committing and the observation delivering — a mark that says the
    /// opposite of what just happened.
    private var justSaved: Set<String> = []

    /// Live for the panel's lifetime — one block's notes, both lists.
    func start() async {
        do {
            for try await value in session.database.observe({ [blockID] db in
                Snapshot(
                    live: try Queries.blockComments(db, blockID: blockID),
                    deleted: try Queries.deletedBlockComments(db, blockID: blockID))
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(CommentsPanelCopy.observationFailed)
        }
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var live: [BlockComment] = []
        var deleted: [BlockComment] = []
    }

    /// Internal so tests drive the panel without the observation.
    func adopt(_ snapshot: Snapshot) {
        comments = snapshot.live
        deleted = snapshot.deleted
        let stored = Dictionary(
            snapshot.live.map { ($0.id, $0.text) }, uniquingKeysWith: { _, last in last })
        drafts = CommentComposition.survivingDrafts(drafts, stored: stored)
        justSaved = justSaved.filter { drafts[$0] != nil }
    }

    // MARK: - The drafts (13u3 UNIT A2 — edit in place)

    /// What the row shows: her draft if she has typed into it, else what is
    /// stored. A clean row renders the store directly — no copy to drift.
    func draft(for id: String) -> String {
        drafts[id] ?? stored(id) ?? ""
    }

    func setDraft(_ text: String, for id: String) {
        drafts[id] = text
        justSaved.remove(id)
    }

    /// Has this row unsaved changes — meaning exactly "committing would do
    /// something"? (`CommentComposition.isDirty`'s rule, plus the landed-but-
    /// not-yet-echoed window.)
    func isDirty(_ id: String) -> Bool {
        guard !justSaved.contains(id),
              let draft = drafts[id], let stored = stored(id) else { return false }
        return CommentComposition.isDirty(draft: draft, stored: stored)
    }

    var isAddDraftFilable: Bool { CommentComposition.filing(addDraft) != .nothing }

    /// Every comment with unsaved changes, in the panel's own order. The
    /// panel commits these when it closes or otherwise leaves.
    var dirtyCommentIDs: [String] {
        comments.map(\.id).filter { isDirty($0) }
    }

    /// **WHAT THE PANEL IS WRITING**, as the brain's own value — so the view
    /// hands the rule its inputs rather than re-deriving them, and ⎋'s
    /// meaning is a pinnable function of (focus, drafts, store).
    func writing(_ focus: CommentPanelFocus?) -> CommentComposition.Writing {
        switch focus {
        case .add:
            return .addDraft(addDraft)
        case .comment(let id):
            guard let stored = stored(id) else { return .nothing }
            return .comment(id: id, draft: draft(for: id), stored: stored)
        case nil:
            return .nothing
        }
    }

    private func stored(_ id: String) -> String? {
        comments.first { $0.id == id }?.text
    }

    // MARK: - The doors

    /// ⌘⏎ (or the Add button) in the add area.
    func fileAddDraft() async {
        switch CommentComposition.filing(addDraft) {
        case .nothing:
            // Silent. Nothing was typed, so nothing is refused — a scold
            // here would be the app talking to itself.
            return
        case .file(let text):
            if await perform({ [blockID] ops in
                _ = try ops.addBlockComment(to: blockID, text: text)
            }) {
                addDraft = ""
                filedCount += 1
                // A landed ADD clears a parked ADD draft — the same draft,
                // (blockID, nil) — so nothing comes back as a ghost. It
                // deliberately does NOT clear a parked EDIT draft (round
                // 3's raise): that draft never landed, and under the peek
                // its insurance must outlive unrelated submits.
                session.commentDraftPark.clearIfHeld(blockID: blockID, commentID: nil)
            } else {
                // **Parked at REFUSAL time, from the SUBMITTED text** (RUN
                // A ladder round 2, the MAJOR — binding 5's sweep): this
                // model dies with its presentation, and the add draft is
                // deliberately never filed on leaving (#118(a)), so the
                // refusal was one Close from gone. An UNSUBMITTED draft
                // still parks nothing — her ⎋-clear and close stay her
                // ordinary abandon (the guard pin).
                session.commentDraftPark.park(
                    blockID: blockID, text: text, commentID: nil)
            }
        }
    }

    func clearAddDraft() {
        addDraft = ""
    }

    /// ⌘⏎ in a comment, and what moving focus away from a dirty one does.
    func commitEdit(_ id: String) async {
        guard let stored = stored(id) else { return }
        switch CommentComposition.commit(draft: draft(for: id), stored: stored) {
        case .unchanged:
            drafts[id] = nil
        case .emptied:
            drafts[id] = nil
            status = .refusal(CommentsPanelCopy.emptied)
        case .save(let text):
            if await perform({ ops in try ops.editBlockComment(id, text: text) }) {
                drafts[id] = text
                justSaved.insert(id)
                // The same-draft clear (round 3's raise): a landed edit of
                // THIS comment clears only a parked edit of this comment —
                // never a parked add draft, whose words have no row yet.
                session.commentDraftPark.clearIfHeld(blockID: blockID, commentID: id)
            } else {
                // The refused in-place edit rides the park WITH its row
                // (the phone's editingID arm, in the Mac's grammar). The
                // `onDisappear` net's close-time retry is exactly this
                // call, so the refusal at close parks with zero close-site
                // changes (binding 2) — and ONE held draft, newest wins,
                // is the ruled bounded trade when several dirty rows
                // refuse at once (QUESTIONS #140).
                session.commentDraftPark.park(
                    blockID: blockID, text: text, commentID: id)
            }
        }
    }

    /// ⎋ in a comment: back to what is stored.
    func revertEdit(_ id: String) {
        drafts[id] = nil
        justSaved.remove(id)
    }

    func add(_ text: String) async {
        _ = await perform { [blockID] ops in
            _ = try ops.addBlockComment(to: blockID, text: text)
        }
    }

    func edit(_ id: String, text: String) async {
        // The ONE trim rule, so this door and `commitEdit` cannot store
        // different text for the same keystrokes.
        let text = CommentComposition.trimmed(text)
        _ = await perform { ops in try ops.editBlockComment(id, text: text) }
    }

    func delete(_ id: String) async {
        if await perform({ ops in try ops.deleteBlockComment(id) }) {
            status = .receipt(CommentsPanelCopy.deleted)
        }
    }

    func restore(_ id: String) async {
        if await perform({ ops in try ops.restoreBlockComment(id) }) {
            status = .receipt(CommentsPanelCopy.restored)
        }
    }

    // MARK: - Delete forever (VX-179 — her R-VX179-3)

    /// **The deleted comment "Delete forever…" is asking about.** Her ruling
    /// is the Delete Now posture: a permanent act asks EVERY time (13j round
    /// 10 — no don't-ask state exists anywhere, and none may be added). So the
    /// row's door only RAISES this; the act waits for the confirm.
    private(set) var pendingDeleteForever: String?

    /// The fold row's door: raises the confirm, never acts. A row that is no
    /// longer in the fold (restored or purged elsewhere since the listing)
    /// raises nothing — the door asks only about what it shows.
    func requestDeleteForever(_ id: String) {
        guard deleted.contains(where: { $0.id == id }) else { return }
        pendingDeleteForever = id
    }

    func cancelDeleteForever() {
        pendingDeleteForever = nil
    }

    /// **The confirmed act — the Delete Now road for one comment.** The id is
    /// PASSED IN by the confirm, never read back from `pendingDeleteForever`
    /// (13l Act 2's rule: SwiftUI writes the alert's `isPresented = false`
    /// synchronously inside the button's click, before this task resumes —
    /// four dead confirm doors were found by reading the pending value back).
    ///
    /// ONE op, `requestPurge` (the intent write — the fold's fence drops the
    /// row at once, on every device), through the panel's own `perform` seam
    /// so a refusal (the seal, above all) is classed and worded here. Then the
    /// local sweep, exactly as `TrashPurge.confirm` runs it: on an install with
    /// no sync chain the cleanup IS the app's, so the bytes go now; under a
    /// configured chain it is a no-op and the janitor takes them at the
    /// horizon. No undo entry anywhere — the confirm is the guard.
    func deleteForever(_ id: String) async {
        pendingDeleteForever = nil
        let target = SyncPurgeTarget(table: "block_comment", rowID: id)
        if await perform({ ops in _ = try ops.requestPurge([target]) }) {
            status = .receipt(CommentsPanelCopy.deletedForever)
            await session.sweepLocalPurge()
        }
    }

    /// Runs one operation and CLASSES what came back. Returns whether it
    /// landed, so the caller can speak its own receipt (a receipt says what
    /// happened, which only the door knows).
    private func perform(
        _ body: @escaping @Sendable (Operations) throws -> Void
    ) async -> Bool {
        status = nil
        do {
            try await session.runner.run(body)
            return true
        } catch {
            // Every refusal in words (VX-179 U3, O-3): the seal and the empty
            // comment exactly as before, the comment races in the panel's
            // own words, everything else in the app's ONE vocabulary.
            status = .refusal(CommentsPanelRefusalCopy.message(for: error))
            return false
        }
    }
}

/// The panel's words, in one place — the wordings a pin reads and the walk
/// sees.
enum CommentsPanelCopy {
    static let sealed = "This note is sealed — unseal it to change comments."
    static let needsText = "A comment needs some text."
    /// Emptying a comment is not how you remove one: the door that removes
    /// it is named, and it is one click away on the same row.
    static let emptied = "A comment needs some text — Delete removes it."
    /// Names the fold by its own word (VX-179 U3: the toggle reads "Deleted").
    static let deleted = "Comment deleted — it's under Deleted below, restorable."
    static let restored = "Comment restored."
    /// VX-179 (R-VX179-3) — "Delete forever…" beside Restore in the deleted
    /// fold. Sentence case throughout (her no-shouty-caps rule); the ellipsis
    /// says the door asks before it acts.
    static let deleteForeverVerb = "Delete forever…"
    static let deleteForeverTitle = "Delete this comment forever?"
    /// The confirm's body names the two facts that make it permanent: the
    /// purge travels (the intent syncs — every device drops it), and no door
    /// brings it back. "There's no putting it back" is the Trash's own phrase
    /// (`RecoveryCopy.deleteNowConfirm`), so the app says permanence one way.
    static let deleteForeverMessage =
        "It leaves every device, and there's no putting it back."
    static let deleteForeverConfirm = "Delete forever"
    static let deletedForever = "Comment deleted forever."
    static let deleteForeverHelp = "Removes this comment from every device. Asks first."
    static let addPlaceholder = "Write a comment…"
    /// Sentence case since VX-179 U3 (her no-shouty-caps rule, read both
    /// ways: a sentence starts with its capital). The Terminal voice
    /// lowercases it through `chromeLabel`, exactly as before.
    static let unsavedMark = "Unsaved · ⌘⏎"
    /// The composer's standing line — it teaches all three keys at once and
    /// never changes, so nothing under her hands moves as she types.
    static let keysHint = "⏎ new line · ⌘⏎ saves · ⎋ undoes"

    // VX-179 U3 — every word the panel shows lives here (the pass's rule:
    // one place a pin reads and the walk sees; chrome goes through the
    // voice's `chromeLabel` at the view).
    static let title = "Comments"
    static let close = "Close"
    static let save = "Save"
    static let revert = "Revert"
    static let delete = "Delete"
    static let restore = "Restore"
    static let add = "Add"
    static let cancel = "Cancel"
    /// The word before a deleted comment's date ("Deleted Oct 12, …"), and
    /// the fold's own noun.
    static let deletedWord = "Deleted"

    /// The deleted fold's toggle: its state mark, its noun, its count.
    static func deletedFold(count: Int, open: Bool) -> String {
        "\(open ? "▾" : "▸") \(deletedWord) (\(count))"
    }

    /// A comment's stamp — the one date format both lists wear.
    static func stamp(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    /// The live listing could not be read (the observation threw). Said as
    /// what happened and what to do — never the raw error (O-3's class).
    static let observationFailed =
        "This block's comments couldn't be read just now — close this and open it again."
}

/// **The panel's refusals, in words** (VX-179 U3 — U1's observation O-3: the
/// `perform` door's fallback printed `Refused: \(error)`, a raw enum with a
/// UUID in it). `TrayRefusalCopy`'s shape: the surface speaks the cases only
/// it can word well, then hands everything else to the app's ONE operations
/// vocabulary (`OpsRefusalCopy.message(for:)`).
///
/// The comment cases are the panel's own because nothing else words them:
/// `commentNotFound` and `commentNotDeleted` are mapped NOWHERE in the
/// shared table (whose own fallback is still the raw dump), and the table's
/// `purgeTargetNotDeleted` sentence speaks of the Trash — wrong here, where
/// it means a comment restored (elsewhere, or by a second press) between the
/// listing and "Delete forever". Each is a race the panel can meet; each
/// says nothing was lost.
enum CommentsPanelRefusalCopy {
    static let commentGone =
        "That comment isn't here any more — it may have just been changed on another device."
    static let commentAlreadyBack = "That comment is already back — it's in the list above."
    static let nothingToDeleteForever =
        "That comment was restored, so there's nothing to delete forever — it's in the list above."
    static let blockGone = "This block is gone, and its comments went with it."

    static func message(for error: Error) -> String {
        if let error = error as? OperationError {
            switch error {
            case .lockedPost: return CommentsPanelCopy.sealed
            case .invalidCommentText: return CommentsPanelCopy.needsText
            case .commentNotFound: return commentGone
            case .commentNotDeleted: return commentAlreadyBack
            case .purgeTargetNotDeleted: return nothingToDeleteForever
            case .blockNotFound: return blockGone
            default: break
            }
        }
        return OpsRefusalCopy.message(for: error)
    }
}

// MARK: - Where the caret is (13u3 UNIT A2)

/// **WHAT THE PANEL IS WRITING**, as a value the model and the keys can both
/// read. It is a top-level type rather than the view's own `@State` enum for
/// one reason: ⌘⏎ and ⎋ MEAN different things depending on it, and a meaning
/// that lives only inside a view body cannot be pinned.
nonisolated enum CommentPanelFocus: Hashable {
    case add
    case comment(String)

    /// **What one area's first-responder report does to the panel's focus**
    /// (VX-179 U3 — the reports replaced `@FocusState`). The caret ARRIVING
    /// in an area makes that area the focus; the caret LEAVING an area clears
    /// the focus only if that area still held it — so a click from comment
    /// A to comment B, which AppKit reports as "A left, B arrived", reads as
    /// A → nil → B, and A's departure can never clear B's arrival whatever
    /// order the two reports meet. `.onChange(of: focus)` then saves A
    /// exactly once, as `@FocusState`'s A → B did.
    static func after(
        report area: CommentPanelFocus, inArea: Bool, current: CommentPanelFocus?
    ) -> CommentPanelFocus? {
        if inArea { return area }
        return current == area ? nil : current
    }
}

// MARK: - The keys (13u3 UNIT A2)

/// **⌘⏎ AND ⎋, DECIDED AS A VALUE.**
///
/// The panel is a writing surface now, so ⏎ belongs to the text (a comment is
/// free prose — `text` holds paragraphs) and the two acts need chords:
/// **⌘⏎ commits what you are writing** — files the add draft, saves the
/// comment — and **⎋ undoes the most local thing** (see
/// `CommentComposition.escape`).
nonisolated enum CommentPanelKeys {
    enum Act: Equatable {
        /// ⌘⏎ — file or save whatever is focused.
        case commit
        /// ⎋ — the escape ladder.
        case escape
    }

    static let returnKeyCode: UInt16 = 36
    /// The keypad's Enter, so a full-size keyboard behaves like the laptop's.
    static let enterKeyCode: UInt16 = 76
    static let escapeKeyCode: UInt16 = 53

    /// nil for every key the panel does NOT claim — and a key it does not
    /// claim must reach the text view untouched, which is why this says "no"
    /// loudly rather than swallowing near-misses: plain ⏎ types a newline,
    /// ⇧⏎ types a newline, ⌥⌘⏎ is nobody's.
    static func act(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Act? {
        let chord = modifiers.intersection([.command, .option, .control, .shift])
        switch keyCode {
        case returnKeyCode, enterKeyCode:
            return chord == [.command] ? .commit : nil
        case escapeKeyCode:
            return chord.isEmpty ? .escape : nil
        default:
            return nil
        }
    }

    /// **Is this key event the panel's to claim?** (VX-179 U3 FIX LEG 2 — the
    /// walk's F-W-4, traced offscreen.) Its own window's, of course — and its
    /// window's PARENT's: in a popover host the keyboard's events are
    /// addressed to the parent window (which keeps window-server key status)
    /// and AppKit delivers them into the popover's first responder — measured:
    /// a key addressed to the parent lands in the popover's composer. Claiming
    /// only its own window, the panel let ⎋ pass to `cancelOperation:`, which
    /// closed the popover with her unsubmitted draft in it. What each key
    /// MEANS is still `act` and the panel's ladder; this only says whose it is
    /// — and an act the panel does not handle still passes on (⎋ with nothing
    /// to undo closes the popover, as before).
    @MainActor
    static func claims(eventWindow: NSWindow?, panelWindow: NSWindow) -> Bool {
        guard let eventWindow else { return false }
        if eventWindow === panelWindow { return true }
        if let parent = panelWindow.parent, eventWindow === parent { return true }
        return false
    }
}

/// The door: a zero-size view owning a local `keyDown` monitor for the window
/// it lives in — `PageTurnKeyMonitor`'s shape, adopted for its stated reason
/// (R1-5): SwiftUI resolves a `.keyboardShortcut` in `performKeyEquivalent`
/// BEFORE the first responder's `keyDown`, so a Button carrying ⌘⏎ would
/// claim the chord for the whole panel no matter which area the caret is in —
/// and a key the panel does not claim must reach the text view exactly as if
/// the panel were not there. The monitor sees the event first, asks the pure
/// rule, and consumes only what it actually handled.
struct CommentPanelKeyMonitor: NSViewRepresentable {
    /// Returns whether the act was handled — an unhandled key is passed on,
    /// so ⎋ with nothing to undo still closes the sheet or popover by the
    /// host's own standard road.
    let onAct: (CommentPanelKeys.Act) -> Bool

    func makeNSView(context: Context) -> MonitorView {
        let view = MonitorView()
        view.onAct = onAct
        return view
    }

    func updateNSView(_ nsView: MonitorView, context: Context) {
        nsView.onAct = onAct
    }

    final class MonitorView: NSView {
        var onAct: ((CommentPanelKeys.Act) -> Bool)?
        private var monitor: Any?

        override var isFlipped: Bool { true }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            guard window != nil else { return }
            // **THE PANEL ASKS FOR THE KEYBOARD** (the walk's fourth find).
            // The panel opens focused on the add area, so a caret blinks
            // there — but a sheet or popover that comes up NON-KEY (measured:
            // reopening the panel right after closing it) swallows every
            // keystroke while still drawing that caret. A caret you cannot
            // type into is worse than no caret, and the one honest fix is to
            // ask for key status once, after the presentation settles.
            DispatchQueue.main.async { [weak self] in
                guard let window = self?.window, !window.isKeyWindow else { return }
                window.makeKey()
            }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                // Whose key (FIX LEG 2, F-W-4): the panel's window's — or its
                // parent's, which is how a popover host's keys arrive.
                guard let self, let window = self.window,
                      CommentPanelKeys.claims(eventWindow: event.window, panelWindow: window)
                else {
                    return event
                }
                guard let act = CommentPanelKeys.act(
                    keyCode: event.keyCode, modifiers: event.modifierFlags) else { return event }
                return (self.onAct?(act) ?? false) ? nil : event
            }
        }
        // (No `deinit`: the view leaves its window before it dies and
        // `viewDidMoveToWindow` removes the monitor then — the
        // `PageTurnKeyMonitor` note, same reason.)
    }
}

// MARK: - The panel

/// **THE COMMENTS PANEL AS A TEXT EDITOR** (13u3 UNIT A2 — the gutter memo's
/// §2 D, her item 3: *"the comment add box is so small and it doesn't make
/// sense given how big the overall comment box is that the whole thing isn't
/// more of the text editor that you can write and click on"*).
///
/// One scrolling writing surface: every comment is an editable text area IN
/// PLACE (no bordered-field swap, no Edit button — click it and type), a
/// hairline and a muted stamp line separate them, and below the last one the
/// ADD AREA owns every point the comments leave. The deleted fold and its
/// restore door keep their place at the foot ("never skimpy"), outside the
/// writing surface so the add area's space is never theirs.
///
/// **R-13u3-6 is why this exists:** comment editing lives in the panel ONLY —
/// the margin card in the gutter is a read face and a door. One live-text
/// home for a comment, exactly as the page has one live editor.
struct CommentsPanel: View {
    let session: AppSession
    let blockID: String
    @State private var model: CommentsPanelModel
    @State private var deletedShown = false
    /// The comments' own measured height, which is what decides how much
    /// space is left for the add area.
    @State private var commentsHeight: CGFloat = 0
    /// The open deleted fold's measured height — it takes what it holds, not
    /// the whole cap.
    @State private var deletedHeight: CGFloat = 0
    /// **Where the caret is** — fed by the writing areas' own first-responder
    /// reports (VX-179 U3: the areas are AppKit views, whose first responder
    /// is the one truth; `@FocusState` was the `TextEditor`'s road). Read
    /// exactly as before: ⌘⏎/⎋ route by it, and leaving an edited comment
    /// saves it (`.onChange(of: focus)` below).
    @State private var focus: CommentPanelFocus?
    /// The add area's counted focus request — raised once when the panel
    /// opens (it opens ready to write).
    @State private var addFocusRequest = 0
    /// The stamp line's MEASURED height (FIX LEG 2 — F-W-3): every row's
    /// stamp line is one line of the same chrome, so one number serves all;
    /// a row being edited reveals itself plus this, its gap and its own
    /// bottom air, so its dirty face never sits below the list's edge.
    @State private var stampLineHeight: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(session: AppSession, blockID: String, model: CommentsPanelModel? = nil) {
        self.session = session
        self.blockID = blockID
        _model = State(initialValue: model
            ?? CommentsPanelModel(session: session, blockID: blockID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private typealias Metrics = CommentsPanelMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if let status = model.status { statusLine(status) }
            hairline
            writingSurface
            deletedFold
        }
        // The shipped panel was 440 × 320 — a list with a one-line field. A
        // writing surface needs room to be one: this is the size at which
        // two or three comments still leave a real add area on the walk.
        // **PROVISIONAL** (a taste number, chosen against the surface).
        .frame(minWidth: 460, minHeight: 440)
        .background(tokens.surface)
        .background(CommentPanelKeyMonitor(onAct: handle))
        // VX-179 (R-VX179-3): "Delete forever…" asks EVERY time — the Delete
        // Now posture. The pending id rides into the action through
        // `presenting:` and `deleteForever(_:)` takes it as a parameter (13l
        // Act 2's rule — never read back after SwiftUI's synchronous
        // dismissal write). The `BlockHistoryPane` alert shape: a title that
        // asks, a body that says why it is permanent.
        .alert(
            CommentsPanelCopy.deleteForeverTitle,
            isPresented: Binding(
                get: { model.pendingDeleteForever != nil },
                set: { if !$0 { model.cancelDeleteForever() } }),
            presenting: model.pendingDeleteForever
        ) { id in
            Button(CommentsPanelCopy.deleteForeverConfirm, role: .destructive) {
                Task { await model.deleteForever(id) }
            }
            Button(CommentsPanelCopy.cancel, role: .cancel) { model.cancelDeleteForever() }
        } message: { _ in
            Text(CommentsPanelCopy.deleteForeverMessage)
        }
        .task {
            // The park restore runs HERE, not in the model's init (ladder
            // round 3, F1): `.task` runs once per INSTALLED presentation,
            // while `State(initialValue:)` runs the init on every phantom
            // view value the presenting body's re-evaluations construct.
            model.restoreParkedDraft()
            // The panel opens ready to write — the add area is the act it is
            // usually opened for, and ⎋ (nothing typed) still closes it. The
            // area serves the request now, or the moment it has a window; its
            // own report then sets `focus` to `.add`.
            addFocusRequest += 1
            await model.start()
        }
        .onChange(of: focus) { old, _ in
            // **Focus loss SAVES an in-place edit** (the brief's rule). It
            // deliberately does NOT file the add draft: saving keeps prose
            // that already exists, while filing MINTS a comment, and a click
            // somewhere else is not an act of minting. (QUESTIONS #118(a).)
            if case .comment(let id)? = old {
                Task { await model.commitEdit(id) }
            }
        }
        .onDisappear {
            // The panel can also leave without a focus change. Every dirty
            // row is committed the same way; a commit that would write
            // nothing writes nothing, so this is idempotent beside `close()`
            // and the popover watcher below.
            commitDirtyEdits()
        }
        // **A POPOVER HOST'S CLOSING SAVES** (VX-179 U3 FIX LEG 2 — ladder
        // R1-2, AGREED and measured offscreen): a dismissed popover is only
        // ordered out — SwiftUI never tears its content down, so neither
        // `.onDisappear` above nor the caret's departure report ever fires,
        // and a dirty in-place edit died with this model (pre-existing since
        // 13u3 A2). The popover's own `willClose` is the one moment every
        // dismissal road shares (a click away, ⎋, the binding), so it commits
        // here — the same body `.onDisappear` was always meant to run.
        .background(CommentPanelHostWatcher(onHostClosing: commitDirtyEdits))
    }

    /// Commits every comment with unsaved changes — the panel's ONE leaving
    /// body (Close, `.onDisappear`, a popover host's closing). The model is
    /// captured, so a commit lands even after the view is gone.
    private func commitDirtyEdits() {
        let model = model
        for id in model.dirtyCommentIDs {
            Task { await model.commitEdit(id) }
        }
    }

    // MARK: Chrome

    /// The title, the count (only when there is something to count — a "0"
    /// beside an empty panel says nothing the empty panel does not), Close.
    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(tokens.chromeLabel(CommentsPanelCopy.title))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            if !model.comments.isEmpty {
                Text("\(model.comments.count)")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Button(tokens.chromeLabel(CommentsPanelCopy.close)) { close() }
                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
        }
        .padding(.horizontal, Metrics.inset)
        .padding(.top, Metrics.headerTop)
        .padding(.bottom, Metrics.headerBottom)
    }

    /// The panel's ONE message slot, in the class its door gave it: a refusal
    /// in the voice's alarm, a receipt in its muted ink.
    private func statusLine(_ status: RecoveryStatus) -> some View {
        ChromeNotice(
            tokens: tokens, text: status.text,
            ink: status.isRefusal ? tokens.alarm : tokens.muted, lines: 3)
            .padding(.horizontal, Metrics.inset)
            .padding(.bottom, Metrics.headerBottom)
    }

    private var hairline: some View {
        Rectangle().fill(tokens.line).frame(height: 1)
    }

    /// Between two comments: the same hairline, held in from the panel's
    /// edges — rows of one list, not bands of the panel.
    private var rowHairline: some View {
        hairline.padding(.horizontal, Metrics.inset)
    }

    // MARK: The writing surface

    /// **Comments, then the add area owning every point they leave.**
    ///
    /// The comments take exactly the height they need and scroll once they
    /// would take more than the panel can spare; the add area takes the rest
    /// and is NEVER less than its floor. The floor is why the two are
    /// separate boxes rather than one long scroll: the walk built three
    /// comments in the shipped 320 pt panel and the one-scroll version put
    /// the add area entirely below the fold — a writing surface you have to
    /// go looking for is the complaint 13u3 A2 answered, not an answer to
    /// it.
    private var writingSurface: some View {
        GeometryReader { geo in
            let room = max(0, geo.size.height)
            let cap = max(0, room - Metrics.addFloor)
            // Before the first measurement the list takes its whole cap —
            // otherwise nothing mounts, nothing measures, and the panel
            // renders no comments at all (the walk's second find: "comments
            // 3" above an empty page).
            let listHeight = model.comments.isEmpty
                ? 0 : (commentsHeight > 0 ? min(commentsHeight, cap) : cap)
            VStack(alignment: .leading, spacing: 0) {
                if listHeight > 0 {
                    commentsList
                        .frame(height: listHeight)
                }
                composer(height: max(Metrics.addFloor, room - listHeight))
            }
        }
    }

    private var commentsList: some View {
        ScrollViewReader { scroller in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(model.comments.enumerated()), id: \.element.id) { pair in
                        commentRow(pair.element)
                            .id(pair.element.id)
                        if pair.offset < model.comments.count - 1 { rowHairline }
                    }
                }
                .padding(.top, Metrics.listTop)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                    commentsHeight = $0
                }
            }
            .onChange(of: model.filedCount) { _, _ in
                // A filed comment must be VISIBLE (P-2: a door performs the
                // act, done visibly). With a full list the newest one lands
                // below the fold otherwise.
                guard let last = model.comments.last?.id else { return }
                withAnimation(.easeOut(duration: 0.15)) {
                    scroller.scrollTo(last, anchor: .bottom)
                }
            }
        }
    }

    /// **THE COMPOSER — the add area, as a place to write** (VX-179 U3, her
    /// item 4: *"make sure that the comment area is actually pristine"*; the
    /// screenshot's empty panel read as a void with a word floating in it).
    ///
    /// It is still the add area of §2 D, whole: it owns every point the
    /// comments leave (the card IS that room, at the floor or more), a click
    /// anywhere in it lands the caret (the text fills the card; its padding
    /// and its foot ask for the caret too), ⌘⏎ or Add files, ⎋ clears, ⏎ is
    /// a newline. What changed is only how it reads: the voice's own card
    /// paper and hairline (`VoicedField`'s idiom — the app's writing box, no
    /// bezel), the hairline taking the accent while the caret is in it, and
    /// the keys and the Add door living IN the box they act on rather than in
    /// a bar below the panel.
    private func composer(height: CGFloat) -> some View {
        let live = focus == .add
        let shape = RoundedRectangle(cornerRadius: Metrics.composerCorner)
        return VStack(alignment: .leading, spacing: Metrics.composerFootGap) {
            CommentTextArea(
                text: $model.addDraft,
                style: CommentTextStyle(tokens: tokens, ink: tokens.ink),
                placeholder: tokens.chromeLabel(CommentsPanelCopy.addPlaceholder),
                growsWithText: false,
                focusRequest: addFocusRequest,
                onFocusChange: { report(.add, inArea: $0) })
            HStack(alignment: .center, spacing: 10) {
                Text(tokens.chromeLabel(CommentsPanelCopy.keysHint))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    // The words are a hint, not a door: a click on them is a
                    // click on the composer (the background's caret ask).
                    .allowsHitTesting(false)
                Spacer(minLength: 8)
                Button(tokens.chromeLabel(CommentsPanelCopy.add)) {
                    Task { await model.fileAddDraft() }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .disabled(!model.isAddDraftFilable)
            }
        }
        .padding(.horizontal, Metrics.composerPadding)
        .padding(.top, Metrics.composerPadding)
        .padding(.bottom, Metrics.composerFootPadding)
        .frame(height: max(0, height - Metrics.composerMargin * 2))
        .background {
            // Click-anywhere, for the points the text view does not cover —
            // the card's padding and its foot. (The text's own points are
            // AppKit's: a click there places the caret where she clicked.)
            shape.fill(tokens.card)
                .onTapGesture { addFocusRequest += 1 }
        }
        .overlay(
            shape.stroke(
                live ? tokens.accent.opacity(Metrics.composerLiveStrokeOpacity) : tokens.line,
                lineWidth: 1)
                .allowsHitTesting(false))
        .padding(.horizontal, Metrics.inset)
        .padding(.vertical, Metrics.composerMargin)
    }

    @ViewBuilder
    private func commentRow(_ comment: BlockComment) -> some View {
        let dirty = model.isDirty(comment.id)
        VStack(alignment: .leading, spacing: Metrics.stampGap) {
            // The voice's own comment mark (R1's idiom slot — "// " in
            // Terminal, nothing in Study) is the AREA's: a twin beside the
            // text, on the text's own first baseline (VX-179 U3). Never part
            // of the text — an editable area cannot hold the idiom without
            // writing it into her prose.
            CommentTextArea(
                text: binding(for: comment),
                style: CommentTextStyle(tokens: tokens, ink: tokens.commentInk),
                mark: tokens.commentPrefix,
                revealBelow: Metrics.stampGap + stampLineHeight + Metrics.rowAir,
                onFocusChange: { report(.comment(comment.id), inArea: $0) })
            stampLine(comment, dirty: dirty)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                    if stampLineHeight != height { stampLineHeight = height }
                }
        }
        .padding(.horizontal, Metrics.writingInset)
        .padding(.vertical, Metrics.rowAir)
    }

    /// The muted line under a comment: when it was written, whether it holds
    /// unsaved changes, and its doors.
    private func stampLine(_ comment: BlockComment, dirty: Bool) -> some View {
        HStack(spacing: 6) {
            Text(CommentsPanelCopy.stamp(comment.createdAt))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
            if dirty {
                Text(tokens.chromeLabel(CommentsPanelCopy.unsavedMark))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if dirty {
                Button(tokens.chromeLabel(CommentsPanelCopy.save)) {
                    Task { await model.commitEdit(comment.id) }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                Button(tokens.chromeLabel(CommentsPanelCopy.revert)) {
                    model.revertEdit(comment.id)
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            }
            Button(tokens.chromeLabel(CommentsPanelCopy.delete)) {
                Task { await model.delete(comment.id) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        }
        // The stamp starts where the row's writing starts — the area's own
        // first-line origin (its mark's column in Terminal, its text in Study).
        .padding(.leading, Metrics.firstLineOrigin.x)
    }

    // MARK: The foot — the deleted fold

    /// **The deleted fold, at the foot** (§2 D: "never skimpy"; outside the
    /// writing surface, so the add area's space is never theirs). Only
    /// present when something is deleted — an empty panel has no foot.
    ///
    /// ONE visual language with the live list (VX-179 U3): a deleted row is
    /// a live row in a quieter register — its words struck through and
    /// muted, and under them the same stamp line (when it was deleted, then
    /// its doors at the trailing edge: Restore, the door you probably want,
    /// and U1's "Delete forever…", present but never calling).
    @ViewBuilder
    private var deletedFold: some View {
        if !model.deleted.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                hairline
                Button(tokens.chromeLabel(CommentsPanelCopy.deletedFold(
                    count: model.deleted.count, open: deletedShown))) {
                    deletedShown.toggle()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                // The word, not the button's hover wash, lines up with the
                // rows' writing: the vocabulary's own label inset, by name.
                .padding(.horizontal, Metrics.inset - VoicedButtonStyle.labelInset)
                .padding(.vertical, Metrics.foldToggleAir)
                if deletedShown { deletedList }
            }
        }
    }

    private var deletedList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(model.deleted.enumerated()), id: \.element.id) { pair in
                    deletedRow(pair.element)
                    if pair.offset < model.deleted.count - 1 { rowHairline }
                }
            }
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                deletedHeight = $0
            }
        }
        // A scroll view takes every point it is offered, so the fold would
        // eat 132 pt of the writing surface to show ONE struck-through line
        // (the walk's third find: opening it clipped the live comments).
        // It takes what it holds, up to the cap.
        .frame(height: min(max(deletedHeight, 1), Metrics.deletedListMaxHeight))
    }

    private func deletedRow(_ comment: BlockComment) -> some View {
        VStack(alignment: .leading, spacing: Metrics.stampGap) {
            Text(comment.text)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .strikethrough(color: tokens.faint)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(CommentsPanelCopy.deletedWord) + " "
                    + CommentsPanelCopy.stamp(comment.deletedAt ?? comment.updatedAt))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Button(tokens.chromeLabel(CommentsPanelCopy.restore)) {
                    Task { await model.restore(comment.id) }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                // VX-179 (R-VX179-3): the fold is a TRASH SURFACE — every row
                // in it is already deleted — so the purge door may live here
                // and nowhere in the writing. Quiet ink: present, never
                // calling; the confirm is where the destructive register
                // speaks.
                Button(tokens.chromeLabel(CommentsPanelCopy.deleteForeverVerb)) {
                    model.requestDeleteForever(comment.id)
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(CommentsPanelCopy.deleteForeverHelp)
            }
        }
        .padding(.leading, Metrics.firstLineOrigin.x)
        .padding(.horizontal, Metrics.writingInset)
        .padding(.vertical, Metrics.rowAir)
    }

    // MARK: Doors

    /// One writing area says the caret arrived or left (`CommentPanelFocus.
    /// after(report:inArea:current:)` — the rule, pinned).
    private func report(_ area: CommentPanelFocus, inArea: Bool) {
        let next = CommentPanelFocus.after(report: area, inArea: inArea, current: focus)
        if next != focus { focus = next }
    }

    private func binding(for comment: BlockComment) -> Binding<String> {
        Binding(
            get: { model.draft(for: comment.id) },
            set: { model.setDraft($0, for: comment.id) })
    }

    /// ⌘⏎ and ⎋, routed by what is focused. Returns whether the panel handled
    /// the key — an unhandled ⎋ falls through to the host's own close.
    private func handle(_ act: CommentPanelKeys.Act) -> Bool {
        switch act {
        case .commit:
            switch focus {
            case .add:
                Task { await model.fileAddDraft() }
                return true
            case .comment(let id):
                Task { await model.commitEdit(id) }
                return true
            case nil:
                return false
            }
        case .escape:
            switch CommentComposition.escape(writing: model.writing(focus)) {
            case .clearDraft:
                model.clearAddDraft()
                return true
            case .revert(let id):
                model.revertEdit(id)
                return true
            case .close:
                // Nothing is being written: let the sheet or the popover
                // close itself the way every other one does.
                return false
            }
        }
    }

    private func close() {
        commitDirtyEdits()
        dismiss()
    }
}

/// **The panel's host-closing watcher** (VX-179 U3 FIX LEG 2 — R1-2). A
/// zero-size view that knows its window and hears `NSPopover`'s
/// `willClose` for the popover whose content lives in that window — and only
/// that one (the app shows other popovers). A sheet host never posts it, so
/// in a sheet this view does nothing; Close and `.onDisappear` cover sheets.
struct CommentPanelHostWatcher: NSViewRepresentable {
    let onHostClosing: () -> Void

    func makeNSView(context: Context) -> WatcherView {
        let view = WatcherView()
        view.onHostClosing = onHostClosing
        return view
    }

    func updateNSView(_ nsView: WatcherView, context: Context) {
        nsView.onHostClosing = onHostClosing
    }

    final class WatcherView: NSView {
        var onHostClosing: (() -> Void)?
        private var observer: NSObjectProtocol?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let observer {
                NotificationCenter.default.removeObserver(observer)
                self.observer = nil
            }
            guard window != nil else { return }
            observer = NotificationCenter.default.addObserver(
                forName: NSPopover.willCloseNotification, object: nil, queue: .main
            ) { [weak self] note in
                // Read before the hop: the notification itself is not
                // Sendable; the popover (a main-actor class) is.
                let closing = note.object as? NSPopover
                MainActor.assumeIsolated {
                    guard let self, let window = self.window,
                          CommentPanelHostWatcher.isHost(closing, ofPanelIn: window)
                    else { return }
                    self.onHostClosing?()
                }
            }
        }
        // (No `deinit`: the view leaves its window before it dies, and
        // `viewDidMoveToWindow` with a nil window removes the observer.)
    }

    /// Is this closing popover the one hosting the panel in `window`? Its
    /// content view lives in the popover's own window.
    @MainActor
    static func isHost(_ popover: NSPopover?, ofPanelIn window: NSWindow) -> Bool {
        guard let popover, let contentWindow = popover.contentViewController?.view.window
        else { return false }
        return contentWindow === window
    }
}

// MARK: - The panel's numbers (ONE place — VX-179 U3, the F-U3-1 ruling)

/// **Every number the panel and its writing areas are built from.** The text
/// geometry is here beside the layout's taste numbers on purpose: the trace
/// behind VX-179 U3 was a placeholder placed by numbers that lived in one
/// file while the geometry they described lived in another (a `TextEditor`'s
/// private insets), so nothing kept them in step. Now the inset, the padding
/// and every alignment that reads them are one name each.
///
/// The TEXT numbers are geometry (what the twins and the stamp line align
/// to); the rest are taste, **PROVISIONAL** — chosen against the real
/// surface on the walk, in both voices.
nonisolated enum CommentsPanelMetrics {
    // MARK: The writing areas' text geometry (owned)

    /// The text container's inset inside every writing area — OURS (the
    /// `TextEditor` it replaces had (0, 0) on macOS 27, where the panel had
    /// assumed (5, 8)). Horizontal air is the panel's padding, not the text's.
    static let textInset = NSSize(width: 0, height: 2)
    /// The container's own padding: none — the host pads.
    static let lineFragmentPadding: CGFloat = 0
    /// Where an area's first line starts, inside the area — the caret's, the
    /// first typed glyph's, the placeholder twin's and the mark twin's line.
    static var firstLineOrigin: CGPoint {
        CGPoint(x: textInset.width + lineFragmentPadding, y: textInset.height)
    }
    /// A row's height from its measured content (`PaneMeasurement`: the
    /// laid-out text plus the inset, top and bottom) — whole points, so the
    /// list never lays out on a fraction.
    static func rowHeight(measured: CGFloat) -> CGFloat {
        max(0, measured).rounded(.up)
    }
    /// The mark's column: its own measured width in the text's font, whole
    /// points. Horizontal only — the mark's BASELINE is the twin's, never a
    /// number.
    static func markColumn(measured: CGFloat) -> CGFloat {
        max(0, measured).rounded(.up)
    }
    /// The mark's ink: the panel row's shipped 0.75 of the comment ink.
    static let markInkOpacity: CGFloat = 0.75

    // MARK: The panel's layout (taste — PROVISIONAL, VX-179 U3's pass)

    /// THE CHROME COLUMN — the title, the composer card's edge, the
    /// hairlines, the fold's toggle. (12 before the pass.)
    static let inset: CGFloat = 16
    /// The composer card's inner padding, sides and top.
    static let composerPadding: CGFloat = 12
    /// **THE WRITING COLUMN** — where every piece of prose in the panel
    /// starts: the composer's text (the card's edge + its padding), every
    /// comment and every stamp line, live or deleted. One edge for words,
    /// one for chrome.
    static var writingInset: CGFloat { inset + composerPadding }
    static let headerTop: CGFloat = 14
    static let headerBottom: CGFloat = 10
    /// Air between the header's hairline and the first comment.
    static let listTop: CGFloat = 4
    /// A row's vertical padding. (7 before the pass — when every row also
    /// carried 16 pt of dead air under its text, which the pass's control
    /// retired.)
    static let rowAir: CGFloat = 9
    /// Between a comment's text and its stamp line.
    static let stampGap: CGFloat = 3
    /// The add area never shrinks below this, however many comments there
    /// are: a writing box you cannot write two lines in is the complaint
    /// 13u3 A2 answered. (132 before the pass; the floor now holds the
    /// composer card's margins and its foot row too, so 156 keeps ≈ 86 pt
    /// of writing room — three lines of Study, four of Terminal.)
    static let addFloor: CGFloat = 156
    /// The composer card's margin above and below.
    static let composerMargin: CGFloat = 12
    /// The card's inner padding under its foot row.
    static let composerFootPadding: CGFloat = 8
    /// Between the writing and the foot row (the keys, Add).
    static let composerFootGap: CGFloat = 6
    /// `VoicedField`'s radius — the app's writing box.
    static let composerCorner: CGFloat = 8
    /// The card's hairline while the caret is in it: the accent at
    /// `VoicedChip`'s "on" strength.
    static let composerLiveStrokeOpacity: Double = 0.55
    /// The deleted fold's toggle row, above and below.
    static let foldToggleAir: CGFloat = 6
    static let deletedListMaxHeight: CGFloat = 132
}
