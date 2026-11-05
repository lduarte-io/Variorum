//
//  LibraryCatalogPlace.swift
//  Variorum (Mac)
//
//  **VX-823 (the VX-828 run, batch C) — the MODEL's half of "the Library
//  remembers where you were."** The pure brain is `LibraryPlace.swift`; the
//  view's half (the rows' reports, the scroll window, the unbound landing) is
//  `LibraryPlaceScroll.swift`. This file holds what must OUTLIVE the view —
//  the catalog model is `RootView`'s `@State`, the view dies with every note
//  opened — and the model's acts on it (the orchestrator's ruling on the fork,
//  P-828-11…14 and Q5):
//
//  - **Every leave remembers** (P-828-13): the place is noted when her scroll
//    RESTS and at a row's OPEN — never read at teardown — so whatever road
//    leaves (a row, the sidebar, ⌘K, ⌥⌘[, the quick entry) finds it noted.
//  - **Every return this session restores it while the question is
//    unchanged**: the mount re-asks the SAME question IN PLACE to the place's
//    depth (Q5 — "∝ the place's depth": the remembered reach plus one page,
//    one statement off the main thread, `refresh()`'s cost class), and the
//    view lands on the rows it already holds (the landing reads nothing). A
//    NEW question — `search()`: the field, scope, sort, a day, a facet, ⌘K's
//    Library road — or a wing switch drops every place: today's top start.
//  - **The return mark** (P-828-12): a row's OPEN marks the row she left from
//    where the surface draws selection; it wears the existing SUBJECT face,
//    no panel, until her next row click, a new question, a mode switch or her
//    next open (Cards: the place only — P-828-14).
//  - **Per pane** (the ruling's amendment — "if a per-pane memory is trivially
//    reachable, prefer it"): every value is keyed by the pane the catalog is
//    mounted in (`PaneID.raw`, handed down by `RootView`). The LISTING stays
//    the window's one model's, so two Library panes still share the question
//    and its rows; each remembers its own place and mark.
//

import CoreGraphics
import Foundation
import Observation
import VariorumCore

/// **Where each Library pane was left, and from what** — one per catalog model.
/// The marks and the re-ask's token are OBSERVED (the rows draw the mark; a
/// pane's scroll re-resolves when its re-ask lands); everything the scroll
/// writes at its own rate is not (a scroll re-renders nothing — the Open
/// list's `SidebarSectionMemory` posture).
@MainActor
@Observable
final class LibraryPlaceMemory {
    /// P-828-12: the row each pane was left from by a row's open.
    private(set) var marks: [String: String] = [:]
    /// Bumped per pane when the return's in-place re-ask has landed.
    private(set) var relisted: [String: Int] = [:]

    @ObservationIgnored private(set) var places: [String: LibraryRememberedPlace] = [:]
    @ObservationIgnored private(set) var windows: [String: LibraryPlace.Window] = [:]
    @ObservationIgnored private(set) var surfaces: [String: LibraryPlace.Surface] = [:]
    /// Each pane's realized rows' frames, in their column's CONTENT space —
    /// written when a row appears or the layout above it moves (never per
    /// scroll frame), dropped when it leaves the screen.
    @ObservationIgnored private(set) var frames: [String: [String: CGRect]] = [:]
    /// The panes whose return re-ask is in flight.
    @ObservationIgnored private(set) var restoring: Set<String> = []

    // MARK: Reads

    func mark(in key: String) -> String? { marks[key] }
    func relistedToken(_ key: String) -> Int { relisted[key] ?? 0 }
    func place(_ key: String) -> LibraryRememberedPlace? { places[key] }
    func window(_ key: String) -> LibraryPlace.Window? { windows[key] }
    func surface(_ key: String) -> LibraryPlace.Surface? { surfaces[key] }
    func frames(_ key: String) -> [String: CGRect] { frames[key] ?? [:] }
    func frame(_ key: String, _ id: String) -> CGRect? { frames[key]?[id] }
    func isRestoring(_ key: String) -> Bool { restoring.contains(key) }

    // MARK: The view's reports

    func noteFrame(_ frame: CGRect, id: String, key: String) {
        frames[key, default: [:]][id] = frame
    }

    func forgetFrame(id: String, key: String) {
        frames[key]?[id] = nil
    }

    func noteWindow(_ window: LibraryPlace.Window, surface: LibraryPlace.Surface, key: String) {
        windows[key] = window
        noteSurface(surface, key: key)
    }

    /// The scroll view a pane SHOWS — said at its appear too, before any
    /// reading (a return resolves in the surface it mounted, never in the
    /// last one that reported).
    func noteSurface(_ surface: LibraryPlace.Surface, key: String) {
        if surfaces[key] != surface { surfaces[key] = surface }
    }

    // MARK: The model's writes

    func remember(_ place: LibraryRememberedPlace, key: String) {
        places[key] = place
    }

    /// nil clears that pane's mark. Equal writes never notify.
    func setMark(_ id: String?, key: String) {
        guard marks[key] != id else { return }
        marks[key] = id
    }

    /// Her next row click (in any pane — the pick and the panel are the
    /// window's one model's too) or a mode switch: every mark goes.
    func clearMarks() {
        guard !marks.isEmpty else { return }
        marks = [:]
    }

    /// **A new question** (`search()`): every place and every mark goes —
    /// the next return starts at the top, as it always did.
    func questionChanged() {
        places = [:]
        clearMarks()
    }

    func beginRestore(_ key: String) { restoring.insert(key) }

    func endRestore(_ key: String) {
        restoring.remove(key)
        relisted[key, default: 0] &+= 1
    }
}

extension LibraryCatalogModel {
    /// **The order a surface draws its rows in** — over the listing the model
    /// holds, read through lookups (never a copy of a long listing).
    func placeOrder(_ surface: LibraryPlace.Surface) -> LibraryPlace.Order {
        let hits = noteHits
        let index = noteIndex
        let notes = LibraryPlace.Order(
            count: hits.count, position: { index[$0] },
            id: { hits.indices.contains($0) ? hits[$0].id : nil })
        switch surface {
        case .cards:
            return notes
        case .list(let includesBooks):
            var segments: [LibraryPlace.Order] = []
            if includesBooks { segments.append(.init(ids: bookHits.map(\.id))) }
            segments.append(notes)
            if !blockHits.isEmpty { segments.append(.init(ids: blockHits.map(\.id))) }
            return .concatenated(segments)
        case .sheet:
            let groups = searchState.groups
            let groupIndex = searchState.groupIndex
            return .concatenated([
                .init(ids: searchState.books.map(\.id)),
                .init(count: groups.count, position: { groupIndex[$0] },
                      id: { groups.indices.contains($0) ? groups[$0].homeID : nil }),
            ])
        }
    }

    /// **Note the pane's place now** — at her scroll's rest, and at a row's
    /// open (`opened`). Nothing on screen measured yet keeps what was noted.
    func notePlace(placeKey key: String, opened: String? = nil) {
        guard let surface = placeMemory.surface(key), let window = placeMemory.window(key),
              let place = LibraryPlace.capture(
                window: window, frames: placeMemory.frames(key), order: placeOrder(surface),
                openedID: opened)
        else { return }
        let ids = place.rows.map(\.id) + place.above + place.below
        placeMemory.remember(
            LibraryRememberedPlace(
                place: place, wing: session.wing.currentID, surface: surface,
                noteReach: ids.compactMap { noteIndex[$0] }.max(),
                groupReach: surface == .sheet
                    ? ids.compactMap { searchState.groupIndex[$0] }.max() : nil),
            key: key)
    }

    /// **A row's OPEN** — every door that leaves the Library FROM a row (the
    /// title, the double-click, the panel's Open, the row menu's Open, a card,
    /// a passage, a tag's block line): the place now, with the row it was left
    /// from (P-828-11 — not an anchor while another on-screen row survives),
    /// and the return MARK where the surface draws a selection (P-828-12;
    /// Cards, P-828-14, the place alone). `marks: false` for a row that wears
    /// no selection face (a scraps group's head, a tag's block line).
    func rowOpened(_ id: String, placeKey key: String, marks: Bool = true) {
        notePlace(placeKey: key, opened: id)
        let draws = placeMemory.surface(key)?.drawsSelection ?? Self.drawsSelection(mode)
        placeMemory.setMark(marks && draws ? id : nil, key: key)
    }

    /// Before the pane has reported its surface: the mode's own answer.
    nonisolated static func drawsSelection(_ mode: Mode) -> Bool { mode != .notes }

    /// **The mount's read** (the catalog's `.task(id: wing)`):
    /// - a remembered place in THIS wing → the SAME question re-asked IN
    ///   PLACE to the place's depth (Q5), the pane's scroll told when it lands;
    /// - the wing moved since the listing was read → a NEW question
    ///   (`search()` — every place and mark dropped);
    /// - otherwise the first page again (`startOver()` — not a new question,
    ///   so another pane's place survives).
    func listingAppeared(placeKey key: String) async {
        let wing = session.wing.currentID
        if let remembered = placeMemory.place(key), remembered.wing == wing {
            placeMemory.beginRestore(key)
            await reread(
                noteDepth: LibraryPlace.depth(reach: remembered.noteReach, page: Self.pageSize),
                groupDepth: LibraryPlace.depth(
                    reach: remembered.groupReach, page: LibrarySearchModel.groupPageSize))
            placeMemory.endRestore(key)
        } else if placeMemory.place(key) != nil || listedWing != wing {
            await search()
        } else {
            await startOver()
        }
    }

    /// The wing the listed rows were read in (the search state's, stamped by
    /// every read).
    var listedWing: String { searchState.wing }

    /// **Where a pane's return lands** — its remembered place resolved in
    /// what the pane draws NOW; nil (the top) when nothing survives or the
    /// place is another wing's.
    func placeLanding(placeKey key: String) -> LibraryPlace.Landing? {
        guard let remembered = placeMemory.place(key),
              remembered.wing == session.wing.currentID,
              let surface = placeMemory.surface(key), remembered.surface.isSameKind(as: surface)
        else { return nil }
        return LibraryPlace.resolve(remembered.place, in: placeOrder(surface))
    }

    /// **Does a pane mounting `surface` owe a return landing?** — a place
    /// remembered in this wing, on this kind of scroll view.
    func owesReturn(placeKey key: String, surface: LibraryPlace.Surface) -> Bool {
        guard let remembered = placeMemory.place(key) else { return false }
        return remembered.wing == session.wing.currentID && remembered.surface.isSameKind(as: surface)
    }
}
