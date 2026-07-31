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

    /// Her ruling: *"you should be able to collapse the named back chip if
    /// you want."* Session state, per window; never persisted.
    ///
    /// 13f batch 5 (W20 b): ONE collapse for the WHOLE context bar — the
    /// back half and the "in <book>" half fold together, because her ruling
    /// asked for one hideable bar and never for two hiding mechanisms.
    var contextBarCollapsed = false

    /// The books visited THIS SESSION, most recent first — the chooser's
    /// float (her round-10 shaping, W20 c). View state like everything else
    /// here: never persisted, never synced, ids only.
    private(set) var recentBookIDs: [String] = []

    /// Display names for the ids on screen — resolved from the store, held
    /// only for rendering. Navigation state itself never holds text.
    private(set) var titles: [String: String] = [:]

    /// A pane's history — **the FOCUSED pane's by default** (13f batch 4,
    /// item 3). Making the default focus-aware is where the gate's
    /// "focused-pane refinement" landed: the registry's `canNavigateBack` /
    /// `canNavigateForward` closures the shell wired in batch 3 call
    /// `history()`, so they became focus-aware without a line changing at
    /// either end, and ⌘[ / ⌘] act on the focused pane for the same reason.
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
    @discardableResult
    func select(_ destination: SidebarSelection, in pane: PaneID? = nil) -> SelectionOutcome {
        let pane = pane ?? focusedPane
        if let existing = paneShowing(destination), existing != pane {
            focusedPane = existing
            return .focusedExistingPane(existing)
        }
        selections[pane] = destination
        focusedPane = pane
        visit(destination, in: pane)
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
            focusedPane = existing
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
        let closing = panes.remove(at: index)
        selections.removeValue(forKey: closing)
        histories.removeValue(forKey: closing)
        splitFractions = PaneLayout.evenFractions(paneCount: panes.count)
        focusedPane = panes[min(index, panes.count - 1)]
        return true
    }

    /// The ring migrates on click (item 2). A pane that is not in the
    /// collection is ignored rather than becoming a focus nobody renders —
    /// `focusedPane` is always a member, which is what makes
    /// `PaneMount.liveCount` answer exactly one.
    func focus(_ pane: PaneID) {
        guard panes.contains(pane) else { return }
        focusedPane = pane
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
    /// already current (which is how ⌘[ / ⌘] avoid a re-entrancy flag),
    /// while the recency touch still runs — arriving IS opening, however
    /// you got there.
    func visit(_ destination: SidebarSelection, in pane: PaneID? = nil) {
        let pane = pane ?? focusedPane
        var history = self.history(pane)
        history.visit(destination)
        histories[pane] = history
        if case .post(let id) = destination { openNotes.opened(id) }
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

    /// ⌘[ — the destination to navigate to, or nil. Acts on the FOCUSED
    /// pane (item 3).
    func goBack(in pane: PaneID? = nil) -> SidebarSelection? {
        let pane = pane ?? focusedPane
        var history = self.history(pane)
        let destination = history.goBack()
        histories[pane] = history
        return destination
    }

    /// ⌘] — the mirror.
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
    /// grey), `canNavigateBack/Forward` are false (⌘[ / ⌘] grey),
    /// `openBesideCandidate` is nil (Open Beside grey) and `panes.count` is
    /// 1 (Close Split grey) — four honest greys and not one new rule.
    func showOnly(_ destination: SidebarSelection) {
        selections[focusedPane] = destination
    }

    /// Closes an Open row. Pure view state: the note is untouched, and it
    /// returns to the strip the next time it is opened.
    func closeNote(_ id: String) {
        openNotes.close(id)
    }

    /// The strip's manual reorder (her round-7 ruling) — session-only, per
    /// window, never a setting and never persisted.
    func moveOpenNotes(fromOffsets source: IndexSet, toOffset destination: Int) {
        openNotes.move(fromOffsets: source, toOffset: destination)
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
        let origins = histories
            .sorted { $0.key.raw < $1.key.raw }
            .compactMap { $0.value.origin }
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
    func resolveTitles(session: AppSession) async {
        let subjects = titleSubjects
        guard !subjects.isEmpty else {
            titles = [:]
            return
        }
        let resolved = try? await session.database.read { db -> [String: String] in
            var out: [String: String] = [:]
            var tagPaths: [String: String]?
            for subject in subjects {
                switch subject {
                case .post(let id), .pool(let id):
                    if let title = try Queries.containerTitle(db, id: id) { out[id] = title }
                case .reading(let id):
                    if let reading = try Queries.reading(db, id: id) { out[id] = reading.name }
                case .tag(let id):
                    // Fetched at most once, and only when a tag is actually
                    // on screen (the FolderView precedent's query).
                    if tagPaths == nil {
                        tagPaths = Dictionary(
                            try Queries.allTags(db).map { ($0.id, $0.path) },
                            uniquingKeysWith: { first, _ in first })
                    }
                    if let path = tagPaths?[id] { out[id] = path }
                case .shelf, .library, .poolPosts, .blocks, .recovery:
                    break  // these name themselves (WorkspaceNaming)
                }
            }
            return out
        }
        titles = resolved ?? [:]
    }

    // MARK: - Naming (the views' one call)

    func label(for selection: SidebarSelection) -> String {
        WorkspaceNaming.label(for: selection, titles: titles)
    }
}
