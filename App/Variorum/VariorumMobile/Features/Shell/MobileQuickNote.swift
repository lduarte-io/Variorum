//
//  MobileQuickNote.swift
//  VariorumMobile
//
//  Mobile Round 2, batch 3b — THE HOME-SCREEN QUICK NOTE (ledger M5, her
//  ruling R5: *"in the 'quick note' box on the home screen, if the user
//  just closes the app, their note should still be saved! it should have
//  generous instant saving so that even if they forget to hit enter or
//  press the button to edit it fully, it's still saved and it should show
//  a little icon when saved."*)
//
//  The Mac's `QuickEntryBar` is the surface she praised and this is its
//  phone edition — with ONE inversion that is the whole point of her
//  ruling: **the Mac bar keeps nothing until ⏎; this box mints first and
//  edits after.** The architect's rulings A5-1…A5-8 (`notes/plans/
//  mobile-round-2.md` §11) are the build spec; the mechanism survey they
//  rule over is `mobile-round-2-quicknote-survey.md`.
//
//  · **A5-2 — ONE BLOCK, minted through `Operations.importPost`.** Same
//    cost as `newBlock` and strictly better: newline-free typing yields
//    exactly one block, while a pre-mint PASTE of several paragraphs
//    segments correctly for free (AppSpec's bulk-entry rule, honoured
//    rather than special-cased). After the mint the box owns the LAST
//    minted block's variant and autosaves it like any note.
//  · **A5-3 — the mint clock.** The first NON-WHITESPACE character arms a
//    ~1 s clock; FOUR occasions mint early (⏎ · the open door · the app
//    backgrounding · navigating away). The early-mint occasions are the
//    load-bearing half — they are what make her sentence true instead of
//    true-after-a-second.
//  · **A5-6 — a fixed row under the path line**, outside the ScrollView,
//    and **NO AUTOFOCUS** (a keyboard on every launch is hostile; the
//    phone's home screen is also a place she reads).
//  · **A5-7 — three states** (typing → saving → saved) present from the
//    first non-whitespace character, spoken for VoiceOver, and NEVER
//    mentioning sync: this indicator can honestly claim only "on this
//    iPhone" (offline is the phone's normal; the sync row owns that
//    state).
//
//  **P3 is not engaged here**, exactly as the Mac pad's own header
//  reasons: a SwiftUI `TextField` mounts no TK2 surface, carries no
//  `BlockRangeIndex`, and is not a `MobileEditorViewModel`, so it never
//  takes the pen from the one live editor. The Library tab already ships
//  a `TextField` on an identically-composed "no live editor here"
//  surface.
//

import SwiftUI
import VariorumCore

// MARK: - The box's words (one home, so the pins read what renders)

@MainActor
enum MobileQuickNoteCopy {
    /// The Mac bar's hint, phone-worded (its `⏎ opens it` grammar is
    /// A5-1's, and it is the reason no newline can be typed here).
    static let hint = "new note — just start typing · ⏎ opens it"
    /// The visible door A5-1 requires beside ⏎ ("press a button to go into
    /// the particular note for it" — her sentence names both).
    static let openDoor = "open ↵"
    static let openDoorSpoken = "Open this note in the editor"
    /// The undo entry's words (`importPost`'s own `undoLabel` parameter —
    /// its doc comment names this very feature).
    static let undoLabel = "Quick Note"

    /// **What the box says when it holds at the boundary** (4.5a, Q1). A
    /// multi-paragraph capture's earlier paragraphs are REAL BLOCKS of a
    /// real note; editing them is a structural act a capture box does not
    /// perform. The hold used to be silent, which made the revert of her
    /// keystrokes a second defect beside the data loss — so the box says
    /// where that edit lives instead. PROVISIONAL copy (13s owns her
    /// voice).
    static let boundaryHold =
        "earlier paragraphs live in the note — tap open ↵ to edit them"

    /// **What the box says when the note was SAVED but the box lost its
    /// place in it** (17b P14). `importPost` committed — the words are in
    /// SQLite — and only the follow-up read failed (the store closing
    /// under an `AppBootstrap.lock()` is the credible cause), so the box
    /// can no longer name the variant it would autosave into. The truth
    /// worth saying is therefore the opposite of the old message: nothing
    /// is lost, and editing continues in the note. Same channel and same
    /// shape as `boundaryHold`, for the same reason. PROVISIONAL copy
    /// (13s owns her voice).
    static let handoffHold =
        "this note is saved — tap open ↵ to keep writing in it"

    /// The indicator's face. `nil` before the first non-whitespace
    /// character — the row does not render at all until there is something
    /// to be honest about (A5-7's "present from the first non-whitespace
    /// character").
    static func indicator(_ state: MobileQuickNoteModel.SaveState) -> String? {
        switch state {
        case .idle: return nil
        case .typing: return "typing…"
        case .saving: return "saving…"
        case .saved: return "✓ saved"
        }
    }

    /// The spoken form (MobileSoul §5.6 — a custom indicator with a
    /// glyph has no spoken form without one). **The "saved" state names
    /// the honest scope and NEVER sync** (A5-7): a committed row is on
    /// this phone, and whether it has reached the mirror is the sync
    /// row's fact, not this box's.
    static func spokenIndicator(_ state: MobileQuickNoteModel.SaveState) -> String? {
        switch state {
        case .idle: return nil
        case .typing: return "Typing. Not saved yet."
        case .saving: return "Saving."
        case .saved: return "Saved on this iPhone."
        }
    }

    /// **A refusal in her words, not the enum's** (4.5a, Q7 — the raw
    /// `\(error)` dump this used to be). Q2's fix is what lets any of these
    /// sentences promise *"your text is still here"*: a leaving that fails
    /// no longer clears the box.
    ///
    /// *(4.5a fix round, NIT 13 — this used to say EVERY sentence carries
    /// that promise, and two of its own arms do not: `.lockedVariant` and
    /// `.emptyImport` say nothing of the kind, deliberately. A locked take
    /// is a refusal about the DESTINATION, and "there's nothing to save
    /// yet" is about an empty box — reassuring either one about text it is
    /// not holding would be noise. The rule the arms actually keep is the
    /// one now stated: **no refusal here is ever reached by a road that
    /// discarded her text.**)*
    ///
    /// PROVISIONAL copy (13s owns her voice). **If 4.5b hoists a shared
    /// refusal vocabulary (A1-18 — three deletion homes today), these
    /// sentences join it rather than becoming a fourth home.**
    static func refusal(_ error: Error) -> String {
        // **13p Batch 4, item (i) — RATIFIED by the author** (*"i think
        // that's fine on demanding unlock first, if a user wants to set
        // the app to force unlock on every open"*): under the demanded
        // at-open modes, capture DEMANDS UNLOCK. The lobby normally makes
        // that structural — while it is up there is no shell, so there is
        // no box to type in — and this sentence covers the one reachable
        // seam, the re-lock landing on a box whose mint had already been
        // refused: the text stays in the box (Q2's rule), it is NOT
        // written to any side channel, and the words name the road.
        if error is StoreLockedError {
            return "Your library is locked, so this note can't be saved yet. Your text "
                + "is still here — unlock the library and it will save."
        }
        guard let error = error as? OperationError else {
            // Not an operations refusal — a store-level failure, and the
            // app's own comment names the reachable one: the device locked
            // mid-round and file protection cut the store off.
            return "This note couldn't be saved just now. Your text is still here — try again in a moment."
        }
        switch error {
        case .lockedPost:
            return "This note is sealed, so it can't take new text. Unseal it in the note to keep writing."
        case .lockedVariant:
            return "This take is locked, so it can't take new text."
        case .containerNotFound, .variantNotFound, .blockNotFound:
            return "That note is gone, so this text has nowhere to land. Your words are still here."
        case .emptyImport:
            return "There's nothing to save yet."
        default:
            return "This note couldn't be saved just now. Your text is still here."
        }
    }
}

// MARK: - The brain

/// The box's model. It holds the TEXT (never the view's `@State`) for two
/// load-bearing reasons: a navigation away must be able to file what is in
/// the box *after* the view has gone, and the app-lifecycle seam must be
/// able to reach it from `scenePhase`.
@MainActor
@Observable
final class MobileQuickNoteModel {

    /// A5-7's three states, plus the honest empty one.
    ///
    /// - `idle` — nothing worth saving has been typed; the indicator does
    ///   not render.
    /// - `typing` — typed text that is not in the store and has no write
    ///   under way. Two occasions: the pre-mint quiet window, and a
    ///   refusal that left the coordinator dirty (the survey's honesty
    ///   trap — a settle-driven icon must stay un-saved on a refusal
    ///   rather than settle optimistically).
    /// - `saving` — a write is in flight or scheduled (the mint running, or
    ///   an autosave inside its debounce).
    /// - `saved` — everything in the box is committed to SQLite. Durable
    ///   through an app kill (WAL), and queued for sync in the same
    ///   transaction (the outbox trigger — SyncSpec §3), which is why the
    ///   indicator never needs a second sync claim.
    enum SaveState: Equatable {
        case idle
        case typing
        case saving
        case saved
    }

    // MARK: Observable state

    /// The box's text. Every mutation route — the field's binding, the
    /// clear at a hand-off, a test — runs through `didSet`, so there is no
    /// "the view forgot to tell the model" failure mode.
    var text: String = "" {
        didSet {
            guard !suppressChange else { return }
            guard text != oldValue else { return }
            handleTextChange(from: oldValue)
        }
    }

    private(set) var saveState: SaveState = .idle

    /// What the STATUS ROW shows — deliberately not `saveState` (4.5a, Q8).
    ///
    /// A5-7 puts the indicator on screen *"from the first non-whitespace
    /// character"*, and that rule reads in both directions: an emptied box
    /// has nothing to be honest about. Before this, deleting a minted
    /// capture back to nothing left the box rendering THREE contradictory
    /// faces at once — the *"just start typing"* placeholder, a `✓ saved`
    /// indicator, and an `open ↵` door that (since Q3) deletes the note
    /// rather than opening it. The row now goes with the text.
    var visibleState: SaveState { mints ? saveState : .idle }

    private(set) var lastError: String?
    /// The box holding at a boundary it cannot cross (Q1) — a quiet note,
    /// never the red error slot: nothing failed, and nothing was lost.
    /// Cleared by the next change the box CAN take, and by a reset.
    private(set) var boundaryNote: String?
    /// The minted note, once it exists (nil in the sub-mint window).
    private(set) var postID: String?
    /// Set when a hand-off wants the shell to open the note — the ⏎ road
    /// and the open door both land here, so navigation stays the view's
    /// job and the model stays testable without a closure.
    private(set) var pendingOpen: String?
    /// Bumped every time the box actually FILES a note and lets go. The
    /// face drops the keyboard on it — found by driving the real surface:
    /// a tab switch files the box, but the field is still first responder
    /// on a shelf that is now behind the Library, so the keyboard stayed
    /// up over a box nobody can see. A `saveState == .idle` reading would
    /// not do: deleting back to an empty box is also idle, and dropping
    /// the keyboard while she is still typing is worse than the bug.
    private(set) var handOffCount = 0

    /// **Whether the box has the caret** — her 2026-08-30 ruling, *"the box
    /// should be one line until you click into it"*, made reachable.
    ///
    /// This is view state on a view model, deliberately and with a reason:
    /// the SHELF sizes its two regions from it, and a `@FocusState` lives
    /// inside the box and cannot be read by a sibling view. Keeping it here
    /// also makes the ruling drivable headlessly — a `@FocusState` cannot
    /// be set from a pin, and the software keyboard never presents under
    /// `xcodebuild test`, so a focus flag nothing can reach would be a
    /// behaviour nothing can verify.
    private(set) var isFocused = false

    /// The box's own `@FocusState` reports here. Idempotent.
    func setFocused(_ focused: Bool) {
        guard isFocused != focused else { return }
        isFocused = focused
    }

    // MARK: Wiring (never observed — none of it renders)

    @ObservationIgnored private(set) var session: AppSession?
    @ObservationIgnored private(set) var variantID: String?
    /// The text of the blocks the box does NOT own — everything the mint
    /// segmented ahead of the last block. Empty in the ordinary
    /// (newline-free) capture, which is why the ordinary case is exact.
    @ObservationIgnored private(set) var frozenPrefix = ""
    /// The tail as last handed to the autosave coordinator (the charDelta
    /// baseline).
    @ObservationIgnored private var lastRecordedTail = ""
    @ObservationIgnored private var autosave: AutosaveCoordinator?
    @ObservationIgnored private var settleToken: UUID?
    @ObservationIgnored private var clockTask: Task<Void, Never>?
    /// The pending boundary restore (`restore(_:)` — one turn late by
    /// necessity). Held so a `reset()` can cancel it: a queued restore
    /// landing in a box that has since let go would write a filed note's
    /// text back into an empty box.
    @ObservationIgnored private var restoreTask: Task<Void, Never>?
    @ObservationIgnored private var mintTask: Task<String?, Never>?
    @ObservationIgnored private var suppressChange = false

    // MARK: Injected clocks (production defaults; tests drive them)

    /// A5-3's number. Deliberately NOT the editor's 2 s idle clock: that
    /// one governs text which is ALREADY durable, and hers is *"generous
    /// instant saving"*.
    @ObservationIgnored var mintDelay: Duration = .milliseconds(1000)
    @ObservationIgnored var sleep: @Sendable (Duration) async throws -> Void = {
        try await Task.sleep(for: $0)
    }
    /// Passed to the post's coordinator when the box mints it (the session
    /// cache means the first caller's clock wins — exactly what a
    /// deterministic harness needs).
    @ObservationIgnored var autosaveDebounce: Duration = .milliseconds(500)
    @ObservationIgnored var autosaveSleep: (@Sendable (Duration) async throws -> Void)?

    /// **17b P14 — the mint's follow-up read, as a seam.** The endorsed
    /// defaulted-seam pattern (`QuickNotePad.mint`'s own words, adopted
    /// from `QuickEntryModel`): production never sets this, and a THROWN
    /// read is otherwise unreachable from a test without breaking the
    /// store underneath a live app — which is exactly the state this
    /// item's defect lives in.
    @ObservationIgnored
    var readMintedBlocks: (@Sendable (String) async throws -> [Queries.RenderedBlock])?

    init(session: AppSession? = nil) {
        self.session = session
    }

    /// Idempotent, and deliberately so: the shell binds the store's session
    /// once the bootstrap is ready, and a re-created view must never swap
    /// the session out from under a note the box already owns.
    func bind(session: AppSession) {
        if self.session == nil { self.session = session }
    }

    // MARK: - Predicates (pure — the door's grey reads them)

    /// Is there anything to mint? Mirrors `importPost`'s own `emptyImport`
    /// refusal, so the box can never fire into it.
    nonisolated static func mints(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var mints: Bool { MobileQuickNoteModel.mints(text) }

    /// **Does the box own EVERY character of the note it points at?**
    /// (4.5a fix round, MAJOR 1 — the gate the withdrawal arm reads.)
    ///
    /// `postID != nil` answers a different question — *"is there a note"* —
    /// and the two came apart the moment A1-19 shipped: `adopt` sets
    /// `postID` BEFORE the `frozenPrefix` guard, so its refusal arm exits
    /// with **a note that holds several real paragraphs and a box that owns
    /// none of them.** Withdrawing on `postID` from that state tombstones
    /// her prose. Ownership is the honest predicate, and it is two facts:
    ///
    /// · **`variantID != nil`** — the box took the note's last block and
    ///   has been autosaving into it. Nil means it refused ownership
    ///   (A1-19's arm) and the note's contents are none of its business.
    /// · **`frozenPrefix.isEmpty`** — nothing sits ahead of the owned
    ///   block, so *the note is exactly what the box was showing*, which is
    ///   the whole of the withdrawal's safety argument (*"the note this
    ///   could fail to remove is empty by construction"*).
    ///
    /// The second clause is **belt, and stated as belt**: a non-empty
    /// prefix always carries non-whitespace (`SegmentationRules.bulkSegments`
    /// never mints a blank piece), so `text == frozenPrefix + tail` makes
    /// `mints` un-emptyable there — the arm's own guard would refuse first.
    /// It is kept because the failure it fences is the destruction of her
    /// prose, and because a safety argument that lives only in a comment is
    /// one the next reader can quietly falsify.
    private var ownsTheWholeNote: Bool {
        variantID != nil && frozenPrefix.isEmpty
    }

    /// Churn cost for one text change: characters removed + characters
    /// inserted, equal weight (AppSpec §10). A plain field reports no
    /// ranges, so the cost is recovered from the common prefix/suffix —
    /// which is exact for a keystroke and honest for an autocorrect
    /// replacement (where a length diff alone would report zero).
    ///
    /// **Deliberately local, not hoisted (M-C weighed):** the Mac has no
    /// mint-as-you-type surface, so there is no second implementation for
    /// this to fork from. If the Mac's bar ever adopts this shape (the
    /// survey §8 records the question), this is the function that moves to
    /// `Shared/`.
    nonisolated static func charDelta(from old: String, to new: String) -> Int {
        let before = Array(old)
        let after = Array(new)
        let edges = commonEdges(before, after)
        return (before.count - edges.prefix - edges.suffix)
            + (after.count - edges.prefix - edges.suffix)
    }

    /// **The ONE decomposition of a text change**, shared by every rule
    /// below (the churn cost, the ⏎ test, and Q1's boundary decision) —
    /// three readings of "what changed" would be three chances to
    /// disagree. A plain `TextField` reports no ranges, so the changed
    /// region is recovered from the common edges: the change replaced
    /// `old[prefix ..< old.count - suffix]` with
    /// `new[prefix ..< new.count - suffix]`.
    ///
    /// The suffix scan is clamped by the prefix on BOTH sides (never
    /// double-counting a character), which is what makes the two ends a
    /// partition rather than a heuristic.
    nonisolated static func commonEdges(
        _ before: [Character], _ after: [Character]
    ) -> (prefix: Int, suffix: Int) {
        var prefix = 0
        while prefix < before.count, prefix < after.count, before[prefix] == after[prefix] {
            prefix += 1
        }
        var suffix = 0
        while suffix < before.count - prefix, suffix < after.count - prefix,
              before[before.count - 1 - suffix] == after[after.count - 1 - suffix] {
            suffix += 1
        }
        return (prefix, suffix)
    }

    /// Was this change a RETURN? A5-1 makes ⏎ open the note, which means a
    /// newline can never be typed into the box — but A5-2's whole benefit
    /// is that a pre-mint PASTE of several paragraphs segments correctly,
    /// so newlines that ARRIVE IN BULK must survive.
    ///
    /// **The test is on what was INSERTED, never on the length delta**
    /// (4.5a, Q6). The old rule required `new.count == old.count + 1`, so
    /// ⏎ over a SELECTION — which replaces the selected run with one
    /// newline and usually SHRINKS the text — was not recognised at all,
    /// and a literal newline landed in the box where A5-1 says one can
    /// never exist. Exactly one inserted newline is the return key
    /// whatever it replaced; anything longer is a paste and keeps every
    /// newline it carries.
    nonisolated static func isTypedReturn(from old: String, to new: String) -> Bool {
        let before = Array(old)
        let after = Array(new)
        let edges = commonEdges(before, after)
        let inserted = after[edges.prefix..<(after.count - edges.suffix)]
        return inserted.count == 1 && inserted.first == "\n"
    }

    // MARK: - The boundary rule (Q1's brain)

    /// What one owned-block change MEANS. Pure, so the rule that decides
    /// whether her prose survives is testable without a store.
    struct BoundaryDecision: Equatable {
        /// The text the box shows once the change is decided.
        var text: String
        /// The owned block's text — what the store must be told.
        var tail: String
        /// True when the change reached into the frozen prefix and the box
        /// held at the boundary (the face says so; nothing is destroyed).
        var heldAtBoundary: Bool
    }

    /// **THE FIX FOR THE DEFECT THAT DESTROYED HER PROSE** (4.5a, Q1 —
    /// traced independently by two cold reads).
    ///
    /// The box owns the LAST minted block; `frozenPrefix` is everything
    /// ahead of it, so the invariant is `text == frozenPrefix + tail`. The
    /// shipped clamp fired whenever `hasPrefix` failed, wrote back the
    /// PREFIX ALONE, and then derived the tail from the just-clamped
    /// text — which is `""`. The next flush wrote that empty string into
    /// the owned variant.
    ///
    /// The shipped comment (and the only pin) asserted the road was
    /// *"only reachable after… she has deleted back through the whole owned
    /// tail"*. **Any edit inside the frozen prefix falsifies `hasPrefix`
    /// just as well** — so fixing a typo in the FIRST paragraph of a pasted
    /// capture erased the SECOND one from the box and from SQLite, with no
    /// undo entry and no `commit_point` to restore from.
    ///
    /// The rule that replaces it: **apply the part of the change that fell
    /// in the owned tail; refuse the part that reached into the frozen
    /// prefix.** Decomposing old→new by its common edges says exactly which
    /// characters of the old tail the change touched, so:
    ///
    /// · a typo fixed inside the prefix leaves the tail untouched — the box
    ///   restores the whole text (prefix AND tail) and says why;
    /// · deleting back through the tail and into the prefix keeps the
    ///   surviving tail — `""` in the shipped pin's case, which is why the
    ///   store still hears the emptied tail and the box and the note never
    ///   diverge;
    /// · anything INSERTED by a change that crossed the boundary is
    ///   dropped, because there is no honest answer to which side of the
    ///   boundary it belongs on. That is a revert — but a spoken one
    ///   (`boundaryHold`), never a silent one.
    nonisolated static func applyingChange(
        frozenPrefix: String, from old: String, to new: String
    ) -> BoundaryDecision {
        // The ordinary capture (one block ⇒ empty prefix) takes this arm
        // every time: the box owns its whole text exactly, unchanged.
        if new.hasPrefix(frozenPrefix) {
            return BoundaryDecision(
                text: new, tail: String(new.dropFirst(frozenPrefix.count)),
                heldAtBoundary: false)
        }
        let before = Array(old)
        let after = Array(new)
        let edges = commonEdges(before, after)
        // Where the owned tail starts in the OLD text.
        let tailStart = min(frozenPrefix.count, before.count)
        // The old characters the change did NOT touch: the common prefix
        // and the common suffix. Intersect them with the tail's region.
        var survivors: [Character] = []
        // **UNREACHABLE FROM THE MODEL'S OWN CALLERS, AND KEPT ANYWAY**
        // (4.5a fix round, MINOR 11 — say so rather than leave it looking
        // load-bearing). Under the caller's invariant `old == frozenPrefix +
        // tail`, this arm is dead: a common prefix reaching `tailStart`
        // would mean `new` starts with `frozenPrefix`, which the `hasPrefix`
        // arm above already returned on. It is NOT dead for the FUNCTION,
        // which is pure, `nonisolated`, and called directly by its own pins
        // with unconstrained arguments — this is what keeps the tail's
        // untouched head from being dropped if `old` ever arrives not
        // matching the invariant.
        if edges.prefix > tailStart {
            survivors += before[tailStart..<edges.prefix]
        }
        let suffixStart = max(before.count - edges.suffix, tailStart)
        if suffixStart < before.count {
            survivors += before[suffixStart...]
        }
        let tail = String(survivors)
        return BoundaryDecision(
            text: frozenPrefix + tail, tail: tail, heldAtBoundary: true)
    }

    // MARK: - The text pipeline

    private func handleTextChange(from oldValue: String) {
        // ⏎ — strip the newline and hand off (A5-1). The strip happens
        // before anything else, so the newline never reaches the store,
        // never reaches the coordinator, and never reaches the mint.
        //
        // **Restoring `oldValue` restores a REPLACED SELECTION too**
        // (Q6's case): ⏎ over a selection is a request to open the note,
        // and the least-destructive reading of it keeps every character
        // she had. The illegal newline is what gets dropped, never her
        // prose.
        if MobileQuickNoteModel.isTypedReturn(from: oldValue, to: text) {
            write(oldValue)
            open()
            return
        }

        if variantID != nil {
            applyOwnedChange(from: oldValue)
            return
        }

        // NOT YET MINTED — or minted and NOT OWNED (the A1-19 arm below,
        // where the box refused ownership rather than claiming text it
        // cannot name). The first non-whitespace character arms the clock;
        // whitespace alone never mints (importPost refuses it).
        if mints {
            armMintClock()
            // **`.saving` is the only state this must not overwrite** (a
            // mint is genuinely in flight). Everything else — including
            // `.saved`, which is what an unowned post-mint box would
            // otherwise sit at while she types text nothing is recording —
            // becomes `.typing`, because that is the honest word for text
            // no write covers.
            if saveState != .saving { saveState = .typing }
        } else {
            cancelMintClock()
            saveState = .idle
            lastError = nil
            boundaryNote = nil
        }
    }

    /// One owned-block change: the box owns the last minted block's
    /// variant, and everything after the frozen prefix is that block's
    /// text.
    /// One owned-block change, decided by `applyingChange` (Q1's brain,
    /// which carries the whole reasoning).
    ///
    /// **The old value is a parameter, not re-derived**, because the
    /// decision needs to know what the change TOUCHED — and the invariant
    /// `old == frozenPrefix + tail` is what makes "the tail's surviving
    /// characters" a fact rather than a guess.
    ///
    /// **The record is load-bearing, not tidiness.** When the surviving
    /// tail differs from what the store was last told, the store has to
    /// hear it — a hold that only restored the text would leave the box
    /// showing one thing and the note holding another, which is the silent
    /// divergence this whole anchor exists to prevent.
    private func applyOwnedChange(from oldValue: String) {
        let decision = MobileQuickNoteModel.applyingChange(
            frozenPrefix: frozenPrefix, from: oldValue, to: text)
        if decision.heldAtBoundary {
            // Earlier paragraphs are REAL BLOCKS of a real note; removing
            // or rewriting them is a structural operation, which a capture
            // box has no business performing. So the box holds at the
            // boundary — and SAYS so, because a silent revert of her
            // keystrokes is its own defect (Q1's finding names both).
            restore(decision.text)
            boundaryNote = MobileQuickNoteCopy.boundaryHold
        } else {
            boundaryNote = nil
        }
        record(tail: decision.tail)
    }

    /// **THE HOLD'S RESTORE HAS TO REACH THE FIELD, AND A SAME-TURN WRITE
    /// DOES NOT** (4.5a fix round — found while building MAJOR 5's pin, and
    /// MEASURED on the mounted surface rather than reasoned about).
    ///
    /// SwiftUI pushes a binding's value into `TextField` only when it
    /// differs from the value SwiftUI last *rendered*. A hold that writes
    /// back inside `text`'s own `didSet` ends the turn at the value SwiftUI
    /// already rendered, so **it renders nothing and UIKit keeps the
    /// rejected text.** Measured on the real field (iOS 26.2 simulator):
    /// after one backspace inside a frozen paragraph the model read
    /// `"Kept.\n\nEditable."` while the field read `"Kep.\n\nEditable."`.
    ///
    /// **That divergence destroys her prose one keystroke later**, and it is
    /// the same loss Q1 exists to prevent, arriving through the fix's own
    /// door: the next change is reported as field-old → field-new, while
    /// `applyingChange` decomposes it against the MODEL's old text. Typing
    /// `"!"` at the end of the owned paragraph decomposed to *"everything
    /// after the prefix was touched"*, the surviving tail came back `""`,
    /// and the flush wrote that into the variant — traced, and pinned
    /// (`aHeldEditNeverStrandsTheFieldOnTextTheNoteDoesNotHold`), store
    /// reading `["Kept.\n", ""]` on the pre-fix code.
    ///
    /// Delivering the restore on the NEXT main-actor turn is what fixes it,
    /// and the mechanism is the same one that broke it: SwiftUI renders the
    /// rejected value once (adopting it as its known value), then sees a
    /// genuinely different value and pushes it into the field. One frame of
    /// the rejected keystroke is what a refused edit honestly looks like,
    /// and `boundaryNote` is on screen beside it.
    ///
    /// **The accepted, RECORDED consequence — and it is 4.5a's MAJOR 5,
    /// confirmed:** once the restore lands, UIKit collapses the selection to
    /// the end of the new text, so the caret leaves the paragraph she was
    /// typing in. Measured (`selectedTextRange` at 16 of 16). Her next
    /// characters therefore append to the block the box owns — recorded
    /// correctly, never misattributed — but the caret moved without being
    /// asked. Putting it back needs caret control this surface does not
    /// have (`TextField` exposes none), i.e. a `UIViewRepresentable` text
    /// view, which is a surface decision and not this fix's to take. It is
    /// reported, and it rides the device queue's D7.
    private func restore(_ value: String) {
        restoreTask?.cancel()
        restoreTask = Task { @MainActor [weak self] in
            guard !Task.isCancelled else { return }
            self?.write(value)
            self?.restoreTask = nil
        }
    }

    /// A programmatic write that must not re-enter the pipeline.
    private func write(_ value: String) {
        suppressChange = true
        text = value
        suppressChange = false
    }

    /// Hands the owned tail to the post's autosave coordinator — the
    /// ordinary road every note's text takes (A5-3: "autosaves like any
    /// note").
    ///
    /// A tail the coordinator was already handed is not re-recorded: it
    /// would schedule a write of identical bytes at zero churn and, worse,
    /// read as `.saving` when nothing is in flight. (Reachable from Q1's
    /// hold, where a refused prefix edit leaves the tail exactly as it
    /// was.)
    private func record(tail: String) {
        guard let variantID, let autosave else { return }
        guard tail != lastRecordedTail else { return }
        let delta = MobileQuickNoteModel.charDelta(from: lastRecordedTail, to: tail)
        lastRecordedTail = tail
        autosave.record(variantID: variantID, text: tail, charDelta: delta)
        saveState = .saving
    }

    // MARK: - The mint clock (A5-3)

    private func armMintClock() {
        guard clockTask == nil, postID == nil else { return }
        clockTask = Task { [weak self, mintDelay, sleep] in
            guard (try? await sleep(mintDelay)) != nil else { return }
            guard !Task.isCancelled else { return }
            await self?.mintNow()
        }
    }

    private func cancelMintClock() {
        clockTask?.cancel()
        clockTask = nil
    }

    // MARK: - The mint

    /// Mints the note if it does not exist yet, joining an in-flight mint
    /// rather than starting a second one. Returns the note's id.
    ///
    /// **This is the load-bearing half of her requirement.** The clock
    /// fires it a second in; the four early occasions fire it the instant
    /// she leaves, so *"if the user just closes the app, their note should
    /// still be saved"* is true rather than true-after-a-second.
    @discardableResult
    func mintNow() async -> String? {
        if let postID { return postID }
        if let mintTask { return await mintTask.value }
        guard let session, mints else { return nil }
        cancelMintClock()
        let snapshot = text
        let undoLabel = MobileQuickNoteCopy.undoLabel
        saveState = .saving
        let task = Task<String?, Never> { [weak self] in
            do {
                let result = try await session.runner.run { ops in
                    // A5-2: `importPost`, not `newBlock` — the paste that
                    // arrived before the mint segments correctly for free.
                    try ops.importPost(title: nil, text: snapshot, undoLabel: undoLabel)
                }
                // Act 0 (R-pre13u-1): the first-write signal — the box is
                // the phone's fastest capture path, so it is also the
                // likeliest first write there is. Announce, move on: the
                // furniture that follows is never on this path's clock.
                session.noteFirstWrite()
                return await self?.adopt(result, mintedFrom: snapshot, session: session)
            } catch {
                self?.lastError = MobileQuickNoteCopy.refusal(error)
                self?.saveState = .typing
                return nil
            }
        }
        mintTask = task
        let minted = await task.value
        mintTask = nil
        return minted
    }

    /// Takes ownership of the minted note: which variant the box now
    /// edits, what sits frozen ahead of it, and the settle wiring the
    /// indicator reads.
    private func adopt(
        _ result: Operations.ImportResult, mintedFrom snapshot: String, session: AppSession
    ) async -> String? {
        let containerID = result.container.id
        // **17b P14 — THE MINT'S IDENTITY IS OWNED FIRST.** `importPost`
        // has committed by the time we are here, so the note EXISTS; every
        // road out of this method must leave the box knowing that, or
        // `armMintClock`'s `postID == nil` guard passes on her next
        // keystroke and the clock mints a SECOND note holding the same
        // words, repeatably. (It used to be set only on the happy path.)
        postID = containerID

        // **AND A FAILED READ IS NOT AN EMPTY NOTE.** This was
        // `(try? …) ?? []`, which folded a thrown read into the identical
        // empty result the guard below treats as "nothing was minted" —
        // and that guard's own justification argues only about the WRITE
        // ("it mints at least one block or throws"), so the read road was
        // never covered by it. The consequences were all three wrong: she
        // was told *"There's nothing to save yet"* about a note sitting in
        // SQLite; the clock could mint it again; and `variantID` stayed
        // nil, so everything she typed afterwards was dropped by
        // `record(tail:)`. The failure is reachable — `AppBootstrap.lock()`
        // closes the pool while this read can be in flight, after the
        // write committed.
        let blocks: [Queries.RenderedBlock]
        do {
            if let readMintedBlocks {
                blocks = try await readMintedBlocks(containerID)
            } else {
                blocks = try await session.database.read { db in
                    try Queries.renderPost(db, containerID: containerID)
                }
            }
        } catch {
            // The A1-19 arm's shape, for the same reason: the note holds
            // what was minted, the box stops writing rather than guessing,
            // and it says where the editing lives.
            boundaryNote = MobileQuickNoteCopy.handoffHold
            saveState = .saved
            return containerID
        }
        guard let owned = blocks.last, let ownedVariant = owned.variantID else {
            // Unreachable through `importPost` (it mints at least one block
            // or throws), but a box that cannot name its variant must not
            // pretend to be saving into one.
            lastError = MobileQuickNoteCopy.refusal(OperationError.emptyImport)
            saveState = .typing
            return nil
        }

        guard let prefix = MobileQuickNoteModel.frozenPrefix(
            of: snapshot, ownedText: owned.text ?? "", blockCount: blocks.count)
        else {
            // **AN UNNAMEABLE BOUNDARY REFUSES OWNERSHIP** (4.5a, A1-19 —
            // a SHAPE fix, not a bug fix: Act 1 could construct no
            // reachable input and labelled it honestly, so no pin is
            // manufactured for it).
            //
            // The anchor could not be found, so the box cannot say which
            // characters belong to the block it owns. Claiming the WHOLE
            // text — which is what an empty prefix means — would autosave
            // earlier paragraphs into the last block's variant. The note
            // holds everything that was minted; the box simply stops
            // writing, and says where editing continues.
            //
            // Accepted consequence, recorded rather than papered over:
            // keystrokes after this point are not captured by the box.
            // That is a smaller loss than corrupting the note, and it
            // cannot occur through any input Act 1 or this session could
            // construct.
            boundaryNote = MobileQuickNoteCopy.boundaryHold
            saveState = .saved
            return containerID
        }
        variantID = ownedVariant
        frozenPrefix = prefix
        lastRecordedTail = String(snapshot.dropFirst(prefix.count))

        let coordinator = session.autosave(
            forPost: containerID, debounce: autosaveDebounce,
            sleep: autosaveSleep ?? { try await Task.sleep(for: $0) })
        autosave = coordinator
        settleToken = coordinator.observe(
            onError: { [weak self] error in
                self?.lastError = MobileQuickNoteCopy.refusal(error)
            },
            onSettled: { [weak self] in self?.settled() })

        saveState = .saved
        // Keystrokes that landed while the mint was in flight: the store
        // holds the snapshot, the box holds more, so hand the difference
        // to the coordinator immediately. The SNAPSHOT is the old value —
        // it is what the store holds, so `frozenPrefix + tail` describes
        // it exactly, which is what Q1's decision needs.
        if text != snapshot { applyOwnedChange(from: snapshot) }
        return containerID
    }

    /// What the box does NOT own, computed from the mint's own result.
    ///
    /// One block (the ordinary capture, and every newline-free one) ⇒
    /// `""`: nothing is frozen and the box owns the whole text exactly.
    /// Several blocks (a pre-mint paste) ⇒ the owned block's stored text is
    /// a contiguous piece of what was minted, so its LAST occurrence marks
    /// where the box's editable tail begins. Segmentation trims each
    /// piece's edges, so the anchor is searched rather than arithmetic'd
    /// off the end.
    ///
    /// **`nil` means "the boundary cannot be named"** (4.5a, A1-19). It
    /// used to return `""` for that case too — the same value that means
    /// *"the box owns everything"* — so an unfound anchor made the box
    /// claim text it does not own and write earlier paragraphs into the
    /// last block's variant. Two different answers now have two different
    /// values, and the caller refuses ownership on `nil`.
    nonisolated static func frozenPrefix(
        of minted: String, ownedText: String, blockCount: Int
    ) -> String? {
        guard blockCount > 1 else { return "" }
        guard !ownedText.isEmpty else { return nil }
        guard let anchor = minted.range(of: ownedText, options: .backwards) else { return nil }
        return String(minted[..<anchor.lowerBound])
    }

    private func settled() {
        guard let autosave else { return }
        // The survey's honesty trap: a refused entry goes BACK into
        // `pending` and keeps `isDirty` true, so the indicator must read
        // the same source rather than a "we called flush" flag.
        saveState = autosave.isDirty ? .typing : .saved
        if !autosave.isDirty { lastError = nil }
    }

    // MARK: - The hand-offs

    /// ⏎ and the open door (A5-1): file the note, then ask the shell to
    /// open it. The box clears, so one capture opens one note.
    ///
    /// *(4.5a: "the box clears" is now conditional, and deliberately so —
    /// a filing the store REFUSED keeps her text and hands nothing off, so
    /// nothing navigates onto a note whose words are still in the box.
    /// `file()` carries the whole rule.)*
    func open() {
        Task { [weak self] in
            guard let self else { return }
            if let id = await self.file() { self.pendingOpen = id }
        }
    }

    /// The shell takes the request exactly once.
    func takePendingOpen() -> String? {
        defer { pendingOpen = nil }
        return pendingOpen
    }

    /// A5-8 — LEAVING MINTS AND CLEARS (the Mac pad's closing-files-it
    /// grammar). A tab switch, a push onto a book or a note, and the app
    /// backgrounding all land here; combined with the mint clock this
    /// closes the un-minted loss window at EVERY exit, which is the whole
    /// point of her ruling.
    ///
    /// *(4.5a's two exceptions, both of which SERVE that ruling rather than
    /// bending it: a leaving the store refused keeps her text instead of
    /// clearing it (Q2), and a leaving from a WHOLLY emptied box withdraws
    /// the note she abandoned instead of leaving a blank one behind (Q3).)*
    func fileOnLeaving() async {
        _ = await file()
    }

    /// The ONE body every hand-off shares. Order is A5-4's: **mint first,
    /// then flush** — the mint covers the sub-mint window, the flush covers
    /// text the mint already wrote.
    ///
    /// *(A5-4's stated reason — "reversed, the last word is lost" — does
    /// not hold, and is corrected here rather than repeated: `mintNow`
    /// reads the BOX's current text, so a flush-then-mint order lands the
    /// same bytes today. The ruled order stays, because it is the one that
    /// remains correct if the mint ever stops being a single read. 4.5a,
    /// Q5.)*
    ///
    /// **THE BOX ONLY CLEARS WHEN THE HAND-OFF ACTUALLY COMPLETED**
    /// (4.5a, Q2). `reset()` writes `""` AND nils `lastError`, and it used
    /// to run on every road out of here — so a refused mint discarded her
    /// text and erased the reason for it in the same breath. The reachable
    /// input is the one this app's own scene handler names: the device
    /// locks mid-round, file protection cuts the store off, `importPost`
    /// throws. And the same road runs on an ordinary TAB SWITCH, where the
    /// app is not going away at all and she would watch the box empty
    /// itself. **A leaving that fails keeps her text and says why.**
    @discardableResult
    private func file() async -> String? {
        guard postID != nil || mints else {
            // An empty (or whitespace-only) box that never minted: there
            // is nothing to keep and nothing to file.
            reset()
            return nil
        }
        cancelMintClock()
        guard let session else { return postID }

        // **Q3 — AN EMPTIED BOX MUST NOT LEAVE A LIVE, EMPTY, UNTITLED
        // NOTE.** She typed a word (which mints a real note), deleted it,
        // and left: nothing tombstoned the note, so a blank date-titled
        // row sat in her library permanently. A5-3 disclosed *"an
        // abandoned one-word note"*; it never sanctioned a note with no
        // content at all, which is precisely the case where she withdrew
        // everything she typed.
        //
        // It composes the note's OWN delete road (`deleteContainer`, the
        // door batch 4 shipped) — never a second deletion rule — so the
        // note moves to the Trash on the ordinary 30-day clock and the
        // purge janitor ends it like any other.
        //
        // FLUSH FIRST: the coordinator is holding the emptied tail, and a
        // pending write landing on a tombstoned variant would be refused
        // and stay dirty forever.
        //
        // Quiet on failure, on `savepointOnLeaving`'s own recorded
        // precedent — *"a leaving is not a moment to refuse at"*. Nothing
        // of hers is at stake here: the note this could fail to remove is
        // empty by construction.
        //
        // **AND THE GATE IS OWNERSHIP, NEVER `postID`** (4.5a fix round,
        // MAJOR 1 — the inverse of the fix A1-19 had just made, and each
        // was correct alone). `adopt` sets `postID` before the
        // `frozenPrefix` guard, so A1-19's refusal arm exits with a note
        // holding several real paragraphs and a box owning none of them;
        // from there an emptied box + a leaving deleted prose the box had
        // never held a character of. `ownsTheWholeNote` is what makes
        // *"empty by construction"* true rather than assumed. An unowned
        // note simply falls through to the ordinary road below: it keeps
        // every paragraph and the box lets go of it.
        //
        // **The hand-off is announced** (MAJOR 3): the withdrawal reset the
        // box and returned `nil`, so `handOffCount` never bumped and the
        // face kept the keyboard up — over the Library, after a tab switch,
        // on a shelf nobody could see. Letting go is letting go, whichever
        // road it takes.
        if let postID, !mints, ownsTheWholeNote {
            await session.flushEveryOpenPost()
            _ = try? await session.runner.run { ops in
                try ops.deleteContainer(postID)
            }
            reset()
            handOffCount += 1
            return nil
        }

        let minted = await mintNow()
        guard let minted else {
            // Q2: the mint was refused. Her text lives NOWHERE but this
            // box, so the box keeps it — and keeps `lastError`, which
            // `mintNow`'s failure roads have just set.
            //
            // **AND SOMETHING TRIES AGAIN** (4.5a fix round, MINOR 9). The
            // refusal copy promises *"try again in a moment"*, and until
            // now nothing did: `file()` had already cancelled the mint
            // clock, so text refused because the device locked mid-round
            // sat in an in-memory box with no scheduled retry — and a
            // suspended app can be terminated. Re-arming the clock makes
            // the promise true. Bounded by construction: `mintNow` cancels
            // the clock as it runs, so a refusal buys exactly one retry,
            // never a spin — and the ordinary re-arm on her next keystroke
            // is unchanged.
            armMintClock()
            // **AND THE CARET GOES, THOUGH THE TEXT STAYS** (the R28 round
            // 2 review's R2-2). `reset()` is what drops focus on the roads
            // that clear the box — and this road deliberately does NOT
            // clear it, so until now a refused leaving left the keyboard
            // standing over the Library, above an invisible box holding
            // un-filed text and an error she could not see: the sweep's
            // finding-6 symptom, arriving from a state its fix never
            // reached. A leaving is a leaving of the SHELF SURFACE, focus
            // included; her text and its reason are still here when she
            // comes back to the Shelf.
            //
            // Accepted, recorded consequence: `open()` shares this body, so
            // a ⏎ (or open-door) press whose mint is refused now drops the
            // keyboard too. It is the same honest reading — the gesture
            // asked to leave the box for the note and could not — and the
            // error it leaves on screen is the thing worth looking at.
            setFocused(false)
            return nil
        }
        // A5-4 option (c): the existing shared drain, no new registry and
        // NOT `MobileLivenessAuthority` (registering there would stand the
        // real editor down from the shelf — the wrong category).
        await session.flushEveryOpenPost()
        // A5-5: the shared savepoint op at the hand-off — one line,
        // exactly what the Mac pad does at its filing. A captured thought
        // whose note no pane ever opened would otherwise carry no history
        // at all. (The phone's GENERAL on-leaving funnel stays
        // PL-11(e)/M6's; this is the box's own call.)
        await session.savepointOnLeaving(minted)
        guard autosave?.isDirty != true else {
            // Q2's other half, same class and the same one-line guard: the
            // note exists, but the store REFUSED the keystrokes that
            // followed the mint (a seal that landed mid-typing) and
            // `flushNow` put them back into `pending`. They exist only in
            // this box, so the box keeps them and the coordinator's own
            // error stands. Returning nil also keeps the box the single
            // writer — nothing navigates onto a note whose text the box is
            // still holding.
            //
            // The caret goes here too, and for the same reason as the
            // refused-mint road above (R2-2): the box keeps her keystrokes
            // and the coordinator's error, and neither is worth a keyboard
            // standing over the tab she moved to.
            setFocused(false)
            return nil
        }
        reset()
        handOffCount += 1
        return minted
    }

    /// Back to an empty box, owning nothing.
    ///
    /// **AND WITHOUT THE CARET** (the Fable sweep's finding 6, 2026-08-30 —
    /// the verdict §62 item 3 deliberately left to fresh eyes). A box that
    /// was FOCUSED BUT NEVER MINTED takes `file()`'s first guard — `reset()`
    /// and out, no hand-off, nothing announced — and `handOffCount` is the
    /// only signal the face drops the keyboard on. So tap the box, type
    /// nothing, tap Library, and the keyboard stood over the Library on a
    /// shelf nobody could see: the same visible symptom as §59's MAJOR 3,
    /// from a different state. (The tab bar really is reachable with the
    /// keyboard up — batch 5's own keyboard-avoidance finding lifts it onto
    /// the keyboard — so this is an ordinary gesture, not a corner.)
    ///
    /// **The fix is at the FOCUS seam, never at the counter.** The shipped
    /// `handOffCount == 0` contract is RIGHT — nothing was handed off, and
    /// bumping it would make the box claim a filing it never made. What is
    /// true instead is that a leaving is a leaving of the SHELF SURFACE,
    /// focus included: `reset()` runs on every road the box lets go by (the
    /// never-minted empty box, the withdrawal, the completed hand-off), so
    /// the caret goes with it here, and the face releases first responder
    /// when the model says the box no longer holds it.
    ///
    /// *(R2-2, the fix diff's own cold review: the two REFUSAL roads out of
    /// `file()` never reach here — by design, since Q2 keeps her text — so
    /// they drop focus themselves at the point they return. The rule is the
    /// same rule; only the road that carries it differs.)*
    private func reset() {
        cancelMintClock()
        setFocused(false)
        // A boundary restore queued for the next turn would otherwise land
        // AFTER this, writing a filed note's text back into an empty box.
        restoreTask?.cancel()
        restoreTask = nil
        if let settleToken { autosave?.stopObserving(settleToken) }
        settleToken = nil
        // **13l L-d — hand the coordinator back.** The box took one per
        // CAPTURE and the session had no way to let go, so a day of jotting
        // left a coordinator per jot for `flushEveryOpenPost` to walk at
        // every filing and every background flush. Releasing is safe here by
        // construction and safe in the session by guard: this runs only on a
        // completed hand-off or a withdrawal, both of which have just
        // flushed, and `releaseAutosave` keeps any coordinator that still
        // has something pending.
        if let postID, autosave != nil { session?.releaseAutosave(forPost: postID) }
        autosave = nil
        variantID = nil
        postID = nil
        frozenPrefix = ""
        lastRecordedTail = ""
        lastError = nil
        boundaryNote = nil
        saveState = .idle
        write("")
    }
}

// MARK: - The face

/// A5-6: a FIXED row outside the shelf's books scroller — it never
/// scrolls away. **No autofocus**, a deliberate divergence from the Mac
/// shelf's R102 behaviour: raising a keyboard on every phone launch is
/// hostile.
///
/// **Round 2, batch 5 — R27:** the box is now the shelf's MAIN AREA, and
/// it sits BELOW the bounded books region rather than above it (her
/// ruling: *"that's where I want the writing a note to go, so that
/// there's a good amount of space"*). `writingHeight` is the region the
/// shelf's own layout brain ruled for it; the field grows into that room
/// and then scrolls inside itself. **⏎ is unchanged** (A5-1) — the box
/// still holds ONE wrapped paragraph, so this is about WRAPPING, never
/// about holding several paragraphs.
///
/// **Her 2026-08-30 refinement — TWO SHAPES:** *"the box should be one
/// line until you click into it."* At rest it is a single line anchored
/// at the shelf's bottom, and the books have the room; on focus it opens
/// into the ruled region. **On blur it collapses again, WITH TEXT STILL
/// IN IT** — implemented literally, because her sentence is about focus
/// and not about emptiness, because the text is already durable (the mint
/// clock has fired, or leaving the shelf files it), and because a box
/// that stayed open whenever it held something would make the shelf's
/// layout depend on invisible state. The saved indicator and the
/// `open ↵` door stay visible in the collapsed row, so nothing about the
/// note goes quiet. *(PROVISIONAL — the alternative reading, "collapse
/// only when empty", is defensible too and is recorded for her.)*
struct MobileQuickNoteBox: View {
    @Bindable var model: MobileQuickNoteModel
    let tokens: VoiceTokens
    /// The ruled writing region (`MobileShelfLayout.split`). `nil` keeps
    /// the compact five-line box — the shape every other host would get.
    var writingHeight: CGFloat?
    /// Where a hand-off lands — the shelf's own open-for-writing road.
    let onOpen: (String) -> Void

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            field
            // Q8: the row reads `visibleState`, not `saveState` — an
            // emptied box has nothing to be honest about, and the indicator
            // + the open door go with the text rather than sitting over a
            // *"just start typing"* placeholder claiming `✓ saved`.
            if let indicator = MobileQuickNoteCopy.indicator(model.visibleState) {
                statusRow(indicator)
            }
            if let note = model.boundaryNote {
                // Q1's hold, spoken. Deliberately NOT the red slot:
                // nothing failed and nothing was lost — the box simply
                // cannot restructure a real note.
                Text(tokens.chromeLabel(note))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(3)
                    .accessibilityLabel(note)
            }
            if let error = model.lastError {
                // `lineLimit` beside a growing chrome text is standing law
                // (P-8, the b6dae25 class).
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(tokens.alarm)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .onChange(of: focused) { _, isFocused in
            // Her 2026-08-30 ruling needs the SHELF to know: the two
            // regions are sized from this, so focus has to leave the box.
            model.setFocused(isFocused)
        }
        .onChange(of: model.handOffCount) { _, _ in
            // The box has let go; the keyboard should let go with it.
            focused = false
        }
        .onChange(of: model.isFocused) { _, wants in
            // The other direction of the same seam (the Fable sweep's
            // finding 6): the model can also say the box has let go of the
            // caret — which `reset()` now does on EVERY road out, including
            // the never-minted empty box that announces no hand-off at all.
            // Only the drop is honoured: raising the keyboard is always the
            // user's own act, never a model's.
            if !wants { focused = false }
        }
        .onChange(of: model.pendingOpen) { _, _ in
            if let postID = model.takePendingOpen() { onOpen(postID) }
        }
    }

    /// R27: how far the field may wrap before it scrolls inside itself.
    /// Derived from the ruled region, so the box fills its area on a big
    /// phone and cannot overflow it on a small one (or with the keyboard
    /// up, which is the same arithmetic on a smaller region — §53 row 6).
    ///
    /// **AT REST IT IS ONE** (her 2026-08-30 ruling). See `collapsed`.
    private var lineCap: Int {
        if collapsed { return 1 }
        guard let writingHeight else { return 5 }
        return MobileShelfLayout.writingLineCap(writingHeight: writingHeight)
    }

    /// Her ruling: *"the box should be one line until you click into it."*
    ///
    /// **Hosted WITHOUT a ruled region the box keeps its old five-line
    /// shape** (`writingHeight == nil`) — nothing but the shelf asks for
    /// the two-state behaviour, and the standalone hosts in
    /// `MobileQuickNoteTests` must keep testing what they were written for.
    private var collapsed: Bool {
        writingHeight != nil && !model.isFocused
    }

    private var field: some View {
        ZStack(alignment: .topLeading) {
            if model.text.isEmpty {
                HStack(spacing: 6) {
                    Text(tokens.chromeLabel(MobileQuickNoteCopy.hint))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                    if tokens.showsBlockCursor && !focused {
                        BlinkingCursorBlock(color: tokens.accent)
                    }
                }
                .allowsHitTesting(false)
            }
            TextField("", text: $model.text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .focused($focused)
                .lineLimit(1...lineCap)
                .submitLabel(.return)
                // **The FIELD takes the ruled room, not merely the box
                // around it** (R27). Measured: with the height on the
                // enclosing box instead, the field's own frame stayed one
                // line tall at the top of a tall box — which reads as a
                // one-line field in a big empty rectangle, and is not
                // *"enough room that you can type in that for about half
                // the phone screen"*. Putting it here also makes the whole
                // area the field's own hit target, so a tap anywhere lands
                // the caret rather than merely raising the keyboard.
                .frame(
                    maxWidth: .infinity, minHeight: fieldMinHeight,
                    alignment: .topLeading)
                .accessibilityLabel("Quick note")
                .accessibilityHint("Type a note here. It saves itself. Return opens it in the editor.")
        }
        // The dashed box OCCUPIES the ruled area rather than hugging the
        // text: her *"a good amount of space"* is a visible invitation,
        // and the whole of it is tappable to focus.
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }

    /// What the box's own chrome leaves for the field. `nil` at rest —
    /// a collapsed box asks for nothing and renders at one line.
    private var fieldMinHeight: CGFloat? {
        guard let writingHeight, !collapsed else { return nil }
        return max(0, writingHeight - MobileShelfLayout.writingBoxChromeHeight)
    }

    private func statusRow(_ indicator: String) -> some View {
        HStack(spacing: 12) {
            Text(tokens.chromeLabel(indicator))
                .font(tokens.small)
                .foregroundStyle(model.visibleState == .saved ? tokens.accent : tokens.faint)
                .accessibilityLabel(
                    MobileQuickNoteCopy.spokenIndicator(model.visibleState) ?? "")
            Spacer()
            // P-2, fire-and-DO: the door is rendered only where it can act
            // (there is text to open), and it performs the whole hand-off.
            Button {
                model.open()
            } label: {
                Text(tokens.chromeLabel(MobileQuickNoteCopy.openDoor))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(MobileQuickNoteCopy.openDoorSpoken)
        }
        .padding(.horizontal, 2)
    }
}
