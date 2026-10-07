//
//  LibrarySearchRouting.swift
//  Variorum (Mac)
//
//  **13o U2 — the catalog's seam to its search state** (D2/D8). The search
//  state's brain is `LibrarySearchModel`; the catalog owns the read's
//  generation guard and the List's own rows. This file is where the two
//  meet for the one road that is neither's alone: the answer sheet's NEXT
//  PAGE of groups (R-13o-9 — every group reachable, never a cap), whose
//  note heads land in `noteHits` so the pick, the bulk bar, the info panel
//  and the near window's extras read them unchanged.
//
//  The first page and the in-place re-ask ride the catalog's one read
//  (`LibraryCatalogModel.read`); this decides WHEN the next page is asked.
//

import Foundation
import VariorumCore

extension LibraryCatalogModel {
    /// **The answer sheet is showing** (D1 — the field asks with words).
    var isSearching: Bool { searchState.isAnswering }

    /// **A group came on screen** (the answer sheet's rows). A NOTE group's
    /// head feeds the near window exactly as a listed note row does (its
    /// chips, its owned-by badge); near the end of the listed groups, the
    /// next page is asked for. Answers whether it asked (`spawning: false`
    /// is the pins' road — they drive the read themselves).
    @discardableResult
    func searchGroupAppeared(_ group: SearchGroup, spawning: Bool = true) -> Bool {
        if !group.isPool { noteRowAppeared(group.homeID, spawning: spawning) }
        guard canAskForMoreGroups,
              let ahead = searchState.groupsAhead(of: group.homeID),
              ahead < LibrarySearchModel.prefetchMargin else { return false }
        if spawning { Task { @MainActor in await loadMoreSearchGroups() } }
        return true
    }

    /// A group left the screen.
    func searchGroupDisappeared(_ group: SearchGroup, spawning: Bool = true) {
        if !group.isPool { noteRowDisappeared(group.homeID, spawning: spawning) }
    }

    /// A next page of groups may be asked for: another exists, none is in
    /// flight, and the listed answer is the newest question's (a page read
    /// under an older question could land after the new listing).
    var canAskForMoreGroups: Bool {
        searchState.hasMoreGroups && !searchState.loadingMore
            && listedGeneration == searchGeneration && searchState.generation == searchGeneration
    }

    /// **The next page of the answer sheet's groups** — one composer
    /// statement after the cursor, under the question the sheet answers; its
    /// note heads append to `noteHits` (each note once), and the near window
    /// re-aims.
    func loadMoreSearchGroups() async {
        guard canAskForMoreGroups, let cursor = searchState.next,
              let question = searchState.question else { return }
        searchState.beginLoadingMore()
        let generation = searchGeneration
        let (scope, wing) = (searchState.scope, searchState.wing)
        do {
            let page = try await session.database.read { db in
                try LibrarySearchModel.groupPage(
                    db, question: question, scope: scope, wing: wing, after: cursor)
            }
            guard generation == searchGeneration else {
                // Superseded: the new question's read owns the listing now.
                searchState.endLoadingMore()
                return
            }
            let fresh = searchState.append(page, generation: generation)
            let heads = fresh.compactMap(\.note).filter { noteIndex[$0.id] == nil }
            let start = noteHits.count
            noteHits += heads
            for (offset, hit) in heads.enumerated() { noteIndex[hit.id] = start + offset }
            nearPages = Self.window(visible: visibleNoteIndices, count: noteHits.count)
            holdNearFacts()
            await loadNearExtras(generation: generation, replacing: false)
        } catch {
            searchState.endLoadingMore()
            guard generation == searchGeneration else { return }
            report(String(describing: error))
        }
    }

    /// **The band's `#tag` chip's ✕** — the field without that tag, asked
    /// again (the caller spawns `search()`, this file's convention).
    func removeTypedTag(_ path: String) {
        query = LibrarySearchQuestion.removingTag(path, from: query)
    }

    /// **The band's archived chip** (D4): the facet flips; the caller
    /// re-reads.
    func toggleArchivedFacet() {
        searchState.toggleArchived()
    }
}
