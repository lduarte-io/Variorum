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

    /// Her ruling: *"you should be able to collapse the named back chip if
    /// you want."* Session state, per window; never persisted.
    var backChipCollapsed = false

    /// Display names for the ids on screen — resolved from the store, held
    /// only for rendering. Navigation state itself never holds text.
    private(set) var titles: [String: String] = [:]

    func history(_ pane: PaneID = .primary) -> NavigationHistory {
        histories[pane] ?? NavigationHistory()
    }

    // MARK: - Recording (the shell calls exactly one of these)

    /// A navigation HAPPENED (any door). Records it in the pane's history
    /// and touches the open-notes recency when the destination is a note.
    ///
    /// Idempotent on re-arrival: the history no-ops when the destination is
    /// already current (which is how ⌘[ / ⌘] avoid a re-entrancy flag),
    /// while the recency touch still runs — arriving IS opening, however
    /// you got there.
    func visit(_ destination: SidebarSelection, in pane: PaneID = .primary) {
        var history = self.history(pane)
        history.visit(destination)
        histories[pane] = history
        if case .post(let id) = destination { openNotes.opened(id) }
    }

    /// ⌘[ — the destination to navigate to, or nil.
    func goBack(in pane: PaneID = .primary) -> SidebarSelection? {
        var history = self.history(pane)
        let destination = history.goBack()
        histories[pane] = history
        return destination
    }

    /// ⌘] — the mirror.
    func goForward(in pane: PaneID = .primary) -> SidebarSelection? {
        var history = self.history(pane)
        let destination = history.goForward()
        histories[pane] = history
        return destination
    }

    /// Closes an Open row. Pure view state: the note is untouched, and it
    /// returns to the strip the next time it is opened.
    func closeNote(_ id: String) {
        openNotes.close(id)
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
        return openNotes.ids.map { SidebarSelection.post($0) } + origins
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
