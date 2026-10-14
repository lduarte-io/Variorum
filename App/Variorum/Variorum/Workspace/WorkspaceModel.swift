//
//  WorkspaceModel.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 3 — the window's workspace state: its OPEN notes, its
//  per-pane history, and the display titles those two need. One instance
//  per shell (it hangs off `ShellRouter`), so it is per-window by
//  construction the moment batch 4 mints a second window.
//
//  It is a HOLDER, not a brain: every decision lives in the pure types
//  beside it (`OpenNotes`, `NavigationHistory`, `WorkspaceNaming` — P-9),
//  and every navigation DECISION lives in the shell (`RootView` adopts a
//  destination; this records that it happened — P-4).
//

import Foundation
import GRDB  // the held title observation reads a `Database`
import Observation
import VariorumCore

@MainActor
@Observable
final class WorkspaceModel {
    /// The Open strip's list (W3/A27).
    private(set) var openNotes = OpenNotes()

    /// Per-PANE history (W16), keyed from day one — the free-tiling rider.
    private(set) var histories: [PaneID: NavigationHistory] = [:]

    // MARK: - The panes (13f batch 4, W1/A25 — the SPLIT)

    /// Her v1 ruling: *"I think two panes is the right choice for v1, but I
    /// would make a note for the future that free tiling is on my desire
    /// list… make sure the architecture isn't going down a road closed to
    /// that."* So this is a CAP on a collection, never the collection's
    /// shape: raising it is the only edit free tiling needs here.
    static let maximumPanes = 2

    /// The window's panes, in visual order. A collection from day one —
    /// never a pair, never left/right.
    private(set) var panes: [PaneID] = [.primary]
    /// What each pane shows. The shell's selection binding reads and writes
    /// the FOCUSED pane's entry, which is what makes a sidebar click target
    /// the focused pane by construction.
    private(set) var selections: [PaneID: SidebarSelection] = [.primary: .shelf]
    /// The pane under her hands — and, by `PaneMount`, the only one that
    /// mounts a live surface.
    private(set) var focusedPane: PaneID = .primary
    /// Divider positions (see `PaneLayout`); empty while one pane exists.
    private(set) var splitFractions: [Double] = []

    /// Mints pane keys that never collide with a closed pane's (a reused
    /// key would inherit its history).
    private var paneSequence = 0

    // **13k K11 — the bar's collapse state is GONE from here.** Her ruling
    // retired the whole-bar fold (*"the collapsing and growing in that bar
    // is a little annoying to me"*), and with it 13f's `contextBarCollapsed`
    // and 13g's WT-2 born-collapsed default. The one fold that survives is
    // the tag cards', and it is a STICKY THIS-MAC preference rather than
    // per-window session state (`TagChipsFold` — her K12: *"tag cards
    // should fold into the bar if you deliberately choose that"*, and a
    // deliberate choice that forgets itself at quit is not a choice).

    /// The books visited THIS SESSION, most recent first — the chooser's
    /// float (her round-10 shaping, W20 c). View state like everything else
    /// here: never persisted, never synced, ids only.
    private(set) var recentBookIDs: [String] = []

    /// Display names for the ids on screen — resolved from the store, held
    /// only for rendering. Navigation state itself never holds text.
    private(set) var titles: [String: String] = [:]

    /// **13j J11 — the LEAVING signal.** The notes this window's panes are
    /// showing right now, in pane order. Pools count alongside posts, exactly
    /// as `SidebarSelection.noteID` counts them: a scraps container opens in a
    /// detail editor and its buffers deserve the same savepoints (her ruling's
    /// "the quick note and scraps follow the same rule").
    var shownNoteIDs: [String] {
        panes.compactMap { selections[$0]?.noteID }
    }

    /// Raised with the notes that have just STOPPED being shown by this
    /// window. Wired by the shell to `AppSession.savepointOnLeaving`
    /// (`SavepointOnLeave.wire`); a no-op by default, so a workspace built in
    /// a test or a preview writes nothing.
    ///
    /// **Why the signal lives here and not in an `.onChange` in the view:**
    /// this type already owns the shown set, and every navigation door in the
    /// app funnels through `select` (its own contract). A view-side observer
    /// would answer the same question one layer further from the fact, and —
    /// the reason that matters — could not be driven by a test without
    /// mounting SwiftUI, which is precisely how a starting `.task` inside a
    /// false conditional shipped dead through five green pins at this
    /// phase's ladder A (finding A1). Emitted from ONE private helper that
    /// wraps every mutation of the set, so a future door that changes what a
    /// pane shows is covered without remembering anything.
    @ObservationIgnored var onNotesLeft: ([String]) -> Void = { _ in }

    /// **17y B3 item (f) — the FOCUSED subject signal.** Raised with what the
    /// focused pane shows whenever a navigation door ASKS it to show
    /// something (every `select` — a re-open of the same note included: she
    /// opened it) or focus MOVES to another pane. Wired by the shell to the
    /// cross-wing follow (`WingFollow.wire`); a no-op by default, so a
    /// workspace built in a test or a preview follows nothing. It lives here
    /// for `onNotesLeft`'s reason: the fact is this type's, and a test drives
    /// it without SwiftUI.
    @ObservationIgnored var onFocusedSubjectChanged: (SidebarSelection?) -> Void = { _ in }

    /// Runs a FOCUS move and raises the signal when the focused pane changed.
    private func reportingFocusMove(_ change: () -> Void) {
        let before = focusedPane
        change()
        if focusedPane != before { onFocusedSubjectChanged(focusedSelection) }
    }

    /// Runs `change`, then reports what left the shown set. Order-preserving
    /// and duplicate-safe: a note still shown by ANOTHER pane of this window
    /// has not been left (the ⌘-click-into-the-other-pane case, where only
    /// focus moved).
    private func reportingDepartures(_ change: () -> Void) {
        let before = shownNoteIDs
        change()
        let after = Set(shownNoteIDs)
        let departed = before.filter { !after.contains($0) }
        if !departed.isEmpty { onNotesLeft(departed) }
    }

    /// What the FOCUSED pane is showing — the shell's selection binding and
    /// every app-scope act that needs "the thing she is looking at" (13f
    /// batch 6: ⌘K's Toggle Star and its registry gate) read this one
    /// accessor rather than re-deriving the pair.
    var focusedSelection: SidebarSelection? { selections[focusedPane] }

    /// A pane's history — **the FOCUSED pane's by default** (13f batch 4,
    /// item 3). Making the default focus-aware is where the gate's
    /// "focused-pane refinement" landed: the registry's `canNavigateBack` /
    /// `canNavigateForward` closures the shell wired in batch 3 call
    /// `history()`, so they became focus-aware without a line changing at
    /// either end, and ⌥⌘[ / ⌥⌘] act on the focused pane for the same reason.
    func history(_ pane: PaneID? = nil) -> NavigationHistory {
        histories[pane ?? focusedPane] ?? NavigationHistory()
    }

    // MARK: - The split's acts

    /// What adopting a destination did.
    enum SelectionOutcome: Equatable {
        case adopted
        /// Her round-7.3 rule fired: the note is already showing in another
        /// pane, so focus moved there instead and the caller SPEAKS.
        case focusedExistingPane(PaneID)
    }

    /// Which pane already shows this destination — notes only (two panes on
    /// the shelf is nobody's confusion; two panes on one note is the thing
    /// she ruled out).
    func paneShowing(_ destination: SidebarSelection) -> PaneID? {
        guard destination.noteID != nil else { return nil }
        return panes.first { selections[$0] == destination }
    }

    /// Adopt a destination into a pane — the ONE door every navigation goes
    /// through, so the same-note rule cannot be bypassed by adding a door.
    ///
    /// **It RECORDS the arrival itself** (13f batch 4). Batch 3 put the one
    /// recording point in the shell's `onChange(of: selection)`, which was
    /// complete while there was one pane and one selection; with panes,
    /// adopting and recording are two writes that must not come apart —
    /// a pane whose history is never seeded shows no chip, silently. The
    /// shell's `onChange` stays as a harmless net (re-visiting the current
    /// destination is a no-op by construction).
    ///
    /// **`takingFocus` (VX-246's ruling 2, provisional: "a navigate-away never
    /// takes her focus").** Every door she presses takes the focus to the pane
    /// it fills, which is the default and unchanged. `notesDeleted` passes
    /// `false`: a pane leaving a tombstone lands IN PLACE, and the focus, with
    /// the one live surface `PaneMount` gives it, stays where she is. The
    /// focused-subject signal is then raised only when the landing pane IS the
    /// focused one, because only then did what she looks at change. It still
    /// funnels through here, so the recording and the departures stay one
    /// write. Its destinations are never notes, so the same-note rule above
    /// (which moves focus) cannot meet it; that is asserted.
    @discardableResult
    func select(
        _ destination: SidebarSelection, in pane: PaneID? = nil, takingFocus: Bool = true
    ) -> SelectionOutcome {
        assert(takingFocus || destination.noteID == nil,
               "an in-place landing is never a note (the same-note rule moves focus)")
        let pane = pane ?? focusedPane
        if let existing = paneShowing(destination), existing != pane {
            reportingFocusMove { focusedPane = existing }
            return .focusedExistingPane(existing)
        }
        // 13j J11: this is the door every navigation funnels through, so
        // wrapping it here is what makes "she left that note" complete
        // without instrumenting each door (the `visit` recording's own
        // argument, applied to the leaving half).
        reportingDepartures {
            selections[pane] = destination
            if takingFocus { focusedPane = pane }
            visit(destination, in: pane)
        }
        // 17y (f): an OPEN — followed even when it re-opens what is shown.
        // An in-place landing in a pane she is not in changed nothing she sees.
        if takingFocus || pane == focusedPane {
            onFocusedSubjectChanged(focusedSelection)
        }
        return .adopted
    }

    enum OpenBesideOutcome: Equatable {
        case opened(PaneID)
        /// Already showing somewhere (including the pane you are in — the
        /// "open this note beside itself" ask, which is the same refusal).
        case focusedExistingPane(PaneID)
    }

    /// "Open Beside": the note goes into a pane that is not the focused
    /// one, minting a second pane if there is room and re-using the other
    /// pane once the cap is reached (the browser-split behaviour).
    @discardableResult
    func openBeside(_ destination: SidebarSelection) -> OpenBesideOutcome {
        if let existing = paneShowing(destination) {
            reportingFocusMove { focusedPane = existing }
            return .focusedExistingPane(existing)
        }
        if panes.count < Self.maximumPanes {
            paneSequence += 1
            let pane = PaneID("pane-\(paneSequence)")
            panes.append(pane)
            splitFractions = PaneLayout.evenFractions(paneCount: panes.count)
            select(destination, in: pane)
            return .opened(pane)
        }
        // At the cap the note lands in the pane you are NOT in (the browser
        // split's behaviour) — her two-panes-in-v1 ruling is a CAP on a
        // collection, so raising it is all free tiling needs here.
        let target = panes.first { $0 != focusedPane } ?? focusedPane
        select(destination, in: target)
        return .opened(target)
    }

    /// Close the FOCUSED pane, folding the window back. Nothing is deleted
    /// and nothing is written — a pane is view state, like a row of the
    /// Open strip. Focus lands on the neighbour it sat beside.
    @discardableResult
    func closeSplit() -> Bool {
        guard panes.count > 1, let index = panes.firstIndex(of: focusedPane) else { return false }
        // 13j J11: folding the window back is a leaving for whatever that
        // pane was showing (unless the other pane shows it, which the
        // same-note rule already forbids).
        reportingFocusMove {
            reportingDepartures {
                let closing = panes.remove(at: index)
                selections.removeValue(forKey: closing)
                histories.removeValue(forKey: closing)
                splitFractions = PaneLayout.evenFractions(paneCount: panes.count)
                focusedPane = panes[min(index, panes.count - 1)]
            }
        }
        return true
    }

    /// The ring migrates on click (item 2). A pane that is not in the
    /// collection is ignored rather than becoming a focus nobody renders —
    /// `focusedPane` is always a member, which is what makes
    /// `PaneMount.liveCount` answer exactly one.
    func focus(_ pane: PaneID) {
        guard panes.contains(pane) else { return }
        // 17y (f): a focus MOVE is followed too (her "follow on focus").
        reportingFocusMove { focusedPane = pane }
    }

    func setSplitFraction(at index: Int, to value: Double) {
        splitFractions = PaneLayout.moving(splitFractions, divider: index, to: value)
    }

    /// The note the View menu's Open Beside would use: the most recently
    /// OPENED note no pane is showing. This is item 0's `recency` at its
    /// second job — order is hers to arrange, recency answers "which one
    /// did she mean". nil ⇒ the menu door is honestly grey.
    var openBesideCandidate: String? {
        openNotes.recency.first { paneShowing(.post($0)) == nil }
    }

    // MARK: - Recording (the shell calls exactly one of these)

    /// A navigation HAPPENED (any door). Records it in the pane's history
    /// and touches the open-notes recency when the destination is a note.
    ///
    /// Idempotent on re-arrival: the history no-ops when the destination is
    /// already current (which is how ⌥⌘[ / ⌥⌘] avoid a re-entrancy flag),
    /// while the recency touch still runs — arriving IS opening, however
    /// you got there.
    func visit(_ destination: SidebarSelection, in pane: PaneID? = nil) {
        let pane = pane ?? focusedPane
        var history = self.history(pane)
        history.visit(destination)
        histories[pane] = history
        if case .post(let id) = destination {
            openNotes.opened(id)
            rememberOpenNotesIfClaimed()
        }
        // W20(c): visiting a book floats it in the chooser. Recorded HERE,
        // in the one recording point, for the same reason the strip is —
        // every door already funnels through it, so nothing has to remember.
        if case .reading(let id) = destination {
            recentBookIDs.removeAll { $0 == id }
            recentBookIDs.insert(id, at: 0)
            if recentBookIDs.count > Self.recentBookBound {
                recentBookIDs.removeLast(recentBookIDs.count - Self.recentBookBound)
            }
        }
    }

    /// A session trail, not a history: bounded so it cannot grow with the
    /// corpus (the bounded-windows discipline applied to view state).
    static let recentBookBound = 20

    /// ⌥⌘[ — the destination to navigate to, or nil. Acts on the FOCUSED
    /// pane (item 3).
    func goBack(in pane: PaneID? = nil) -> SidebarSelection? {
        let pane = pane ?? focusedPane
        var history = self.history(pane)
        let destination = history.goBack()
        histories[pane] = history
        return destination
    }

    /// ⌥⌘] — the mirror.
    func goForward(in pane: PaneID? = nil) -> SidebarSelection? {
        let pane = pane ?? focusedPane
        var history = self.history(pane)
        let destination = history.goForward()
        histories[pane] = history
        return destination
    }

    /// **The NOTE-ONLY window's one destination** (13f batch 5b, the
    /// architect's ruling (d)): set what the pane shows and record
    /// *nothing* — no history, no Open strip, no book recency.
    ///
    /// That silence is the whole mechanism behind the ruling's promise that
    /// every app-scope act "resolves honestly grey there through the
    /// EXISTING gates". With no visit recorded, `openNoteCount` is 0 (⌘⇧1–9
    /// grey), `canNavigateBack/Forward` are false (⌥⌘[ / ⌥⌘] grey),
    /// `openBesideCandidate` is nil (Open Beside grey) and `panes.count` is
    /// 1 (Close Split grey) — four honest greys and not one new rule.
    func showOnly(_ destination: SidebarSelection) {
        // 13j J11: wrapped for completeness of the class, not because the
        // note-only window navigates — it calls this exactly once, from
        // nothing, so nothing departs. A later ruling giving that window a
        // history gets the leaving signal for free.
        reportingDepartures { selections[focusedPane] = destination }
    }

    /// Closes an Open row. Pure view state: the note is untouched, and it
    /// returns to the strip the next time it is opened.
    func closeNote(_ id: String) {
        openNotes.close(id)
        rememberOpenNotesIfClaimed()
    }

    // MARK: - VX-287 / VX-289 — Close Note (⌘⇧W) and Close All Notes

    /// **The note Close Note would close** — the FOCUSED pane's, when it shows
    /// one. Notes only (`.post`): the Open list tracks posts (ratified round
    /// 7.2), so a book, a place or a scraps container has no row to close and
    /// the key is grey there (the registry's `focusedPaneShowsNote`).
    var closeNoteTarget: String? {
        if case .post(let id)? = focusedSelection { return id }
        return nil
    }

    /// Where the FOCUSED pane lands when `id` closes: the next row, else the
    /// previous, else the Library (`OpenNotes.neighbour(ofClosing:)`), passing
    /// over notes another pane of this window shows.
    func landingAfterClosing(_ id: String) -> SidebarSelection {
        let elsewhere = Set(panes.filter { $0 != focusedPane }.compactMap { selections[$0]?.noteID })
        return openNotes.neighbour(ofClosing: id, skipping: elsewhere)
            .map(SidebarSelection.post) ?? .library
    }

    /// **CLOSE NOTE** (VX-287 — her ruling: ⌘⇧W, *"landing in the next note
    /// on the list is perfect-that way you can close them all quickly"*). The
    /// focused pane's note leaves the Open list, and the returned destination
    /// is where the pane LANDS — nil when the pane shows no note (nothing
    /// closes, nothing moves).
    ///
    /// **It RETURNS the landing rather than selecting it**, and that is the
    /// whole routing decision: the door hands it to the shell's EXISTING
    /// open-note road (`ShellRouter.pendingSelection`, adopted by `RootView`
    /// through `ShellRouter.adopt` — the road ⌘⇧1–9 and View ▸ Open Note
    /// take), so a park expires and the same-note rule stays the one door's,
    /// exactly as for every other navigation (ShellRouter's RULE ONE: nothing
    /// outside this type may call `select` around `adopt`). No new landing
    /// authority. Arriving there is an ordinary navigation, so leaving this
    /// note raises its savepoint-on-leave like any other departure.
    ///
    /// VIEW-ONLY: a row and a pane are view state; the note is untouched.
    @discardableResult
    func closeFocusedNote() -> SidebarSelection? {
        guard let id = closeNoteTarget else { return nil }
        let landing = landingAfterClosing(id)
        closeNote(id)
        return landing
    }

    /// **CLOSE ALL NOTES** (VX-289 — her triage word: *"close all now is
    /// good"*). Every Open row closes, and a pane that was showing a note
    /// lands by Close Note's rule — with the list now empty, the Library.
    ///
    /// - The FOCUSED pane's landing is RETURNED for the door to route through
    ///   the shell (`closeFocusedNote`'s reason); nil when it shows no note.
    /// - Any OTHER pane of this window showing a note lands IN PLACE, focus
    ///   kept — `notesDeleted`'s road (VX-246's ruling 2's shape), because a
    ///   closed note left on screen with no row is exactly the state the
    ///   ticket names as the defect, and "all" includes the pane she is not
    ///   in. PROVISIONAL P-U1-3.
    ///
    /// VIEW-ONLY: no note is touched.
    @discardableResult
    func closeAllNotes() -> SidebarSelection? {
        let landing: SidebarSelection? = closeNoteTarget == nil ? nil : .library
        for pane in panes where pane != focusedPane {
            if case .post? = selections[pane] {
                select(.library, in: pane, takingFocus: false)
            }
        }
        openNotes.closeAll()
        rememberOpenNotesIfClaimed()
        return landing
    }

    /// **NOTES HAVE BEEN DELETED — get off them** (13l Act 2, ledger item 3;
    /// her ruling's *"navigate-away covers EVERY pane/window showing the
    /// note"*). Called by every full window on the one signal, so a window
    /// she is not looking at cannot be left standing on a tombstone either.
    ///
    /// Two halves, and both are needed. The panes showing a deleted note
    /// move; the Open STRIP forgets it — otherwise its row survives and
    /// ⌘⇧n re-opens a tombstone, which is the same dead door one keystroke
    /// further away.
    ///
    /// **Where they land, and why the LIBRARY** rather than the pane's own
    /// history: the note is in the Trash now, and the Library is the room
    /// that holds the Trash's door — "where did it go?" is answerable from
    /// where she lands. Walking history back would be prettier and is a trap:
    /// a multi-delete's previous destination is frequently another note in
    /// the same gesture, so back can land on a second tombstone. One
    /// destination cannot.
    ///
    /// Returns whether this window showed any of them, so a caller can decide
    /// whether it has anything to say.
    ///
    /// **The landing never takes her focus** (VX-246's ruling 2, provisional;
    /// `select`'s `takingFocus`). Each pane leaves the tombstone IN PLACE, and
    /// the focused pane stays focused. A client deleting the note in the pane
    /// she is not typing in, or her own Delete aimed from one pane at the note
    /// in the other, no longer moves her caret's pane to the read tier.
    @discardableResult
    func notesDeleted(_ ids: [String]) -> Bool {
        let gone = Set(ids)
        let showing = panes.filter { selections[$0]?.noteID.map(gone.contains) == true }
        for pane in showing { select(.library, in: pane, takingFocus: false) }
        for id in ids { openNotes.close(id) }
        rememberOpenNotesIfClaimed()
        return !showing.isEmpty
    }

    /// The strip's manual reorder (her round-7 ruling). *Since VX-139 the
    /// remembered strip carries this order too* — her ruling made the
    /// REORDER a gesture rather than a setting, and her VX-139 ask extends
    /// the strip's lifetime; keeping her arrangement across that lifetime
    /// is the reading recorded in the run record.
    func moveOpenNotes(fromOffsets source: IndexSet, toOffset destination: Int) {
        openNotes.move(fromOffsets: source, toOffset: destination)
        rememberOpenNotesIfClaimed()
    }

    // MARK: - VX-139 — the strip across launches

    /// Whether THIS window's strip is the remembered one. The first full
    /// shell to ask claims it, and only the claimant writes — so a second
    /// main window can never fight the first over the stored rows (it
    /// starts empty, as every window always has).
    private(set) var remembersOpenNotes = false

    /// One claim per LIVE SHELL, not per process (the Pro review's MAJOR-1):
    /// a relock swaps `RootView` for the lock screen and tears the claimant
    /// down, and her store relocks on sleep, the screen lock and the idle
    /// clock — a per-process claim went stale at the first relock and the
    /// strip silently stopped being kept. The claimant RELEASES on
    /// disappear, so the post-unlock shell claims, restores the strip she
    /// just had, and keeps persisting. Note-only and quick-note windows
    /// never ask; RootView is the only caller.
    private static var launchRestoreClaimed = false

    /// Where the claimant writes — injected at the claim so the suites can
    /// hand a private domain (the `freshTakeCardDefaults` class).
    private var openNotesDefaults: UserDefaults = .standard

    #if DEBUG
    /// The suites mint many shells per process; a test world resets the
    /// launch claim so each one exercises the first-shell road.
    static func resetOpenNotesLaunchClaimForTesting() { launchRestoreClaimed = false }
    #endif

    /// **The claimant's shell is going away** (a relock, a window close).
    /// The claim returns to the pool so the NEXT full shell — the
    /// post-unlock `RootView` — can claim and restore. The stored rows
    /// stay exactly as last written; nothing is cleared here.
    func releaseOpenNotesClaimIfHeld() {
        guard remembersOpenNotes else { return }
        remembersOpenNotes = false
        Self.launchRestoreClaimed = false
    }

    /// **The restore (VX-139).** The first full shell — at launch AND after
    /// every relock (the claim is per shell) — claims the remembered strip:
    /// stored ids filtered to the notes that still LIVE (one indexed read,
    /// bounded by the strip — cost ∝ the strip, never the corpus) and
    /// adopted in their stored order. The claimant then persists every
    /// strip change; `OpenNotesMemory.remember` honors the off-switch live.
    /// With the setting OFF the stored rows are cleared at once (off means
    /// off — a later launch must not resurrect a weeks-old strip; the Pro
    /// review's MINOR-1) and nothing is restored — but the claim still
    /// lands, so flipping it on mid-session starts remembering without a
    /// relaunch. A FAILED read restores nothing and touches nothing — an
    /// error is never "every note is gone" (MINOR-2).
    func restoreRememberedOpenNotes(
        session: AppSession, defaults: UserDefaults = .standard
    ) async {
        guard !Self.launchRestoreClaimed else { return }
        Self.launchRestoreClaimed = true
        remembersOpenNotes = true
        openNotesDefaults = defaults
        guard OpenNotesMemory.isOn(defaults) else {
            OpenNotesMemory.forget(defaults)
            return
        }
        let stored = OpenNotesMemory.stored(defaults)
        guard openNotes.ids.isEmpty, !stored.ids.isEmpty else { return }
        guard let live = try? await session.database.read({ db in
            try Self.liveNoteIDs(db, among: stored.ids)
        }) else { return }
        // A note opened while the read ran keeps its row: it re-joins the
        // restored strip exactly as an open does (the end — she opened it
        // last).
        let openedMeanwhile = openNotes.ids
        var restored = OpenNotes(
            restoringIDs: stored.ids, recency: stored.recency,
            isLive: { live.contains($0) })
        for id in openedMeanwhile { restored.opened(id) }
        openNotes = restored
        // Normalize the store to what actually came back (dead rows gone).
        rememberOpenNotesIfClaimed()
    }

    /// Tombstone-only liveness: an ARCHIVED note still opens from the
    /// Library's archived facet, so its row survives the relaunch; a note
    /// in the Trash does not.
    nonisolated static func liveNoteIDs(
        _ db: Database, among ids: [String]
    ) throws -> Set<String> {
        guard !ids.isEmpty else { return [] }
        let marks = Array(repeating: "?", count: ids.count).joined(separator: ",")
        return try Set(String.fetchAll(
            db,
            sql: "SELECT id FROM container WHERE id IN (\(marks)) AND deleted_at IS NULL",
            arguments: StatementArguments(ids)))
    }

    private func rememberOpenNotesIfClaimed() {
        guard remembersOpenNotes else { return }
        OpenNotesMemory.remember(openNotes, in: openNotesDefaults)
    }

    // MARK: - Titles (display only)

    /// The destinations whose names are on screen right now: the strip's
    /// rows plus each pane's chip origin.
    ///
    /// Pane order is SORTED, not the dictionary's: `values` has no stable
    /// order across insertions, and this feeds a `.task(id:)` key — an
    /// unstable key restarts the read for no reason (and, worse, reads as a
    /// change when nothing changed).
    var titleSubjects: [SidebarSelection] {
        // 13k K11: the FORWARD destination joins the origins — the bar's →
        // names where it lands, and a name that never resolves reads
        // "Untitled" for every note (`WorkspaceNaming`'s last-resort
        // fallback, which exists for ids with no row at all).
        let origins = histories
            .sorted { $0.key.raw < $1.key.raw }
            .flatMap { [$0.value.origin, $0.value.next] }
            .compactMap { $0 }
        // …plus what each pane is SHOWING (13f batch 4): an unfocused pane
        // wears a quiet name line instead of the detail's masthead, and a
        // pool pane's name is in neither of the other two lists.
        let showing = panes.compactMap { selections[$0] }
        return openNotes.ids.map { SidebarSelection.post($0) } + origins + showing
    }

    /// A stable key for `.task(id:)` — re-resolves when the set OR the
    /// order changes, which is every navigation.
    var titleSubjectsKey: String {
        titleSubjects.map(Self.key).joined(separator: "|")
    }

    private static func key(_ selection: SidebarSelection) -> String {
        switch selection {
        case .shelf: return "shelf"
        case .library: return "library"
        case .poolPosts: return "poolPosts"
        case .blocks: return "blocks"
        case .recovery: return "recovery"
        case .archived: return "archived"
        case .post(let id): return "post:\(id)"
        case .pool(let id): return "pool:\(id)"
        case .reading(let id): return "reading:\(id)"
        case .tag(let id): return "tag:\(id)"
        }
    }

    /// One read for every name on screen (P2 — off the main thread through
    /// the reader pool; the assignment lands back here). The shipped
    /// `PostTitleLabel` precedent: chrome titles are one-shot reads keyed on
    /// what they show, never a held observation per row.
    /// **The names on screen, LIVE** (17o batch d, ledger row 18; §4.3's one
    /// fix). Her words: *"renaming a note won't rename it on the sidebar
    /// until you click on something else."* This used to be a one-shot read
    /// keyed on `titleSubjectsKey` — which changes when the SET of things on
    /// screen or its order changes, and a rename changes neither, so the
    /// strip kept the old name until the next navigation. The same fetch is
    /// now HELD, so the write itself moves the name — and a rename arriving
    /// from a sync pull lands the same way, which a one-shot never could.
    ///
    /// The fetch stays bounded by what is on screen — one indexed row per
    /// subject, and `Queries.tagPaths` rather than the whole taxonomy —
    /// because a held observation re-runs on every `container` write
    /// (autosave stamps land there) and `AppDatabase.observe`'s own rule is
    /// that its fetch must be viewport-shaped. `removeDuplicates` keeps the
    /// UI still while nothing it shows has changed.
    ///
    /// The caller keys its `.task` on `titleSubjectsKey` exactly as before,
    /// so the observation restarts when the subjects change; nothing else
    /// about the strip's road moves.
    func observeTitles(session: AppSession) async {
        let subjects = titleSubjects
        guard !subjects.isEmpty else {
            titles = [:]
            return
        }
        do {
            for try await resolved in session.database.observe({ db in
                try Self.readTitles(db, subjects: subjects)
            }) {
                titles = resolved
            }
        } catch is CancellationError {
        } catch {
            // A failed read leaves the last names standing rather than
            // blanking the strip — the chrome's posture everywhere else.
        }
    }

    /// The ONE-SHOT read — **and it has no production caller** (17o c/d/e
    /// ladder round 2, NIT-2; verified by grep, twice). Row 18 replaced the
    /// strip's one-shot with `observeTitles` above, and `SidebarView`'s is the
    /// only `.task` that resolves titles at all. What survives here is the
    /// TESTS' single resolution: two suites want the map settled once, without
    /// holding an observation task to get it — `NodSetTests`'
    /// `theChromeNamesAnUntitledNoteByItsDate` (K1's "Untitled" is a NAME, and
    /// every per-kind fallback) and `WorkspaceNavigationTests`'
    /// `titlesResolveForEveryKindOnScreen`.
    ///
    /// It is demoted rather than deleted deliberately: those two claims are not
    /// covered by the held road's pins (pools, tags and the K1 semantics are
    /// theirs alone), and folding them onto `readTitles` would re-type the
    /// subjects-and-empty-guard logic in test code — a worse copy than this one.
    ///
    /// **A NEW SURFACE TAKES `observeTitles`, NOT THIS.** Adopting the one-shot
    /// re-creates exactly her row-18 complaint — *"renaming a note won't rename
    /// it on the sidebar until you click on something else"* — because the only
    /// thing that re-runs it is a change of `titleSubjectsKey`, which a rename
    /// does not touch.
    func resolveTitles(session: AppSession) async {
        let subjects = titleSubjects
        guard !subjects.isEmpty else {
            titles = [:]
            return
        }
        titles = (try? await session.database.read { db in
            try Self.readTitles(db, subjects: subjects)
        }) ?? [:]
    }

    /// One read for every name on screen (P2 — off the main thread through
    /// the reader pool; the assignment lands back on the model).
    nonisolated static func readTitles(
        _ db: Database, subjects: [SidebarSelection]
    ) throws -> [String: String] {
        var out: [String: String] = [:]
        var tagPaths: [String: String]?
        for subject in subjects {
            switch subject {
            case .post(let id):
                // 13g batch 7 (R6-3): the map carries the DISPLAY name,
                // so the pane line, the back chip, the Open strip and a
                // star all say the same thing without re-deriving it.
                // `WorkspaceNaming`'s per-kind fallbacks stay for the one
                // case they were always for — an id that resolves to no
                // row at all.
                if let title = try Queries.noteDisplayTitle(db, id: id) { out[id] = title }
            case .pool(let id):
                // 13k K2: a nameless pool reads as the day it was
                // created, so the pane line, the back chip and the Open
                // strip say what the Blocks area's picker says.
                if let title = try Queries.poolDisplayTitle(db, id: id) { out[id] = title }
            case .reading(let id):
                if let reading = try Queries.reading(db, id: id) { out[id] = reading.name }
            case .tag(let id):
                // Fetched at most once, and only for the tags actually
                // on screen — `tagPaths`, not the whole taxonomy, so the
                // held observation's fetch stays viewport-shaped
                // (17o batch d, row 18).
                if tagPaths == nil {
                    tagPaths = try Queries.tagPaths(
                        db,
                        ids: subjects.compactMap {
                            if case .tag(let id) = $0 { return id } else { return nil }
                        })
                }
                if let path = tagPaths?[id] { out[id] = path }
            case .shelf, .library, .poolPosts, .blocks, .archived, .recovery:
                break  // these name themselves (WorkspaceNaming)
            }
        }
        return out
    }

    // MARK: - Naming (the views' one call)

    func label(for selection: SidebarSelection) -> String {
        WorkspaceNaming.label(for: selection, titles: titles)
    }
}

// MARK: - VX-139 — the strip's this-Mac memory

/// **VX-139 — keep tabs open across app close and open** (her ticket ask
/// verbatim: *"a keep tabs open setting would be super helpful for when the
/// app closes and opens"*; pulled into the VX-143 run at her word,
/// 2026-10-11: *"I want it fixed now"*).
///
/// A STICKY THIS-MAC preference — the `writeHoverHandles` class: local
/// `UserDefaults`, never the synced `setting` table. The strip is one
/// window's chrome on one machine, and its ids would mean nothing to
/// another device's windows. It lives HERE, beside the holder that does the
/// reading and writing — `WorkspaceNavigation.swift` keeps only pure types
/// (the Pro review's MINOR-5).
///
/// Storage is two parallel string arrays (never titles — navigation state
/// holds ids only). `remember` honors the off-switch LIVE: with the setting
/// off it clears the stored rows instead of writing, so "off" means off at
/// the very next launch, not two launches later.
nonisolated enum OpenNotesMemory {
    /// The off-switch (default ON — the remembered strip is what she asked
    /// for; the setting exists to turn it off). LOCAL, this Mac.
    static let settingKey = "keepOpenNotes"
    static let idsKey = "openNotes.remembered.ids"
    static let recencyKey = "openNotes.remembered.recency"

    static func isOn(_ defaults: UserDefaults) -> Bool {
        defaults.object(forKey: settingKey) == nil || defaults.bool(forKey: settingKey)
    }

    static func remember(_ notes: OpenNotes, in defaults: UserDefaults) {
        guard isOn(defaults) else { return forget(defaults) }
        defaults.set(notes.ids, forKey: idsKey)
        defaults.set(notes.recency, forKey: recencyKey)
    }

    static func forget(_ defaults: UserDefaults) {
        defaults.removeObject(forKey: idsKey)
        defaults.removeObject(forKey: recencyKey)
    }

    static func stored(_ defaults: UserDefaults) -> (ids: [String], recency: [String]) {
        (defaults.stringArray(forKey: idsKey) ?? [],
         defaults.stringArray(forKey: recencyKey) ?? [])
    }
}
