//
//  LibraryCatalogPaging.swift
//  Variorum (Mac)
//
//  **17y B1 item (k) — THE LIBRARY SCROLLS THROUGH EVERY NOTE.** A LAUNCH
//  BLOCKER in her words: "the fact that the library only shows you the first
//  40 notes is completely unacceptable… we need an area in which people can
//  scroll through ALL of their notes, that kind of access is literally what
//  library is supposed to be. has to be fixed before launch even — otherwise
//  people could literally lose their work basically." And her bar: it "needs
//  to be SMOOTH like the rest of the app — no performance losses are
//  acceptable for it! including if it's in the notes view".
//
//  The model's half of the infinite scroll, the brain both Library views
//  (List and Cards) drive through two calls — a note row APPEARED, a note row
//  DISAPPEARED:
//
//  - **The next page** is asked for as she nears the end of what is listed
//    (`prefetchMargin` rows before it) — ONE keyset page read
//    (`Queries.catalogNotesPage`), appended; nothing listed is read again.
//  - **The near WINDOW** — the pages around what is on screen, quantized to
//    page boundaries so it moves only when she crosses one — is the only part
//    of the listing whose extras (tag chips, card words) are read, and the
//    only part whose ownership facts are HELD in an observation
//    (`nearNoteIDs`): the held region stays the size of a few pages however
//    deep she scrolls.
//
//  The listing's reads themselves (`search`, `refresh`) and the extras loader
//  are `LibraryCatalogModel.swift`'s; this file decides WHEN.
//

import Foundation
import VariorumCore

extension LibraryCatalogModel {
    /// The ids the near window covers — what the ownership facts observe.
    var nearNoteIDs: [String] {
        nearPages.flatMap { notesOfPage($0) }.map(\.id)
    }

    /// **The near window** (pure): the pages holding the visible rows, one
    /// page beyond on each side — a page boundary is the only thing that moves
    /// it. Nothing visible yet (a fresh listing) is the first page and the next.
    nonisolated static func window(visible: Set<Int>, count: Int) -> ClosedRange<Int> {
        let lastPage = max(0, (count - 1) / pageSize)
        guard let low = visible.min(), let high = visible.max() else {
            return 0...min(1, lastPage)
        }
        let from = max(0, low / pageSize - 1)
        let to = min(lastPage, high / pageSize + 1)
        return from...max(from, to)
    }

    /// Rebuild the position index after the listing changed (a read; a page).
    func reindexNotes() {
        var index: [String: Int] = [:]
        index.reserveCapacity(noteHits.count)
        for (position, hit) in noteHits.enumerated() { index[hit.id] = position }
        noteIndex = index
    }

    /// **A note row came on screen** (both views' `.onAppear`). Moves the near
    /// window when it crosses a page, and asks for the next page when she is
    /// within `prefetchMargin` rows of the end. Answers whether it asked
    /// (`spawning: false` is the pins' road — they drive the read themselves).
    @discardableResult
    func noteRowAppeared(_ id: String, spawning: Bool = true) -> Bool {
        guard let position = noteIndex[id] else { return false }
        visibleNoteIndices.insert(position)
        windowMaybeMoved(spawning: spawning)
        guard notesHaveMore, !loadingMoreNotes,
              position >= noteHits.count - Self.prefetchMargin else { return false }
        if spawning { Task { await loadMoreNotes() } }
        return true
    }

    /// A note row left the screen (both views' `.onDisappear`).
    func noteRowDisappeared(_ id: String, spawning: Bool = true) {
        guard let position = noteIndex[id] else { return }
        visibleNoteIndices.remove(position)
        // The window only ever widens toward what she is looking at; it does
        // not shrink to an empty screen between two rows' callbacks.
        if !visibleNoteIndices.isEmpty { windowMaybeMoved(spawning: spawning) }
    }

    private func windowMaybeMoved(spawning: Bool) {
        let next = Self.window(visible: visibleNoteIndices, count: noteHits.count)
        guard next != nearPages else { return }
        nearPages = next
        if spawning {
            Task { await loadNearExtras(generation: searchGeneration, replacing: false) }
        }
    }

    /// **The next page of notes** — one keyset read after the cursor, under
    /// the question the listing is answering (a new question since — a typed
    /// letter, a sort — supersedes it, and its page never lands).
    func loadMoreNotes() async {
        guard notesHaveMore, !loadingMoreNotes, editedOn == nil,
              let cursor = notesCursor else { return }
        loadingMoreNotes = true
        let generation = searchGeneration
        let (query, sort, direction) = (query, sort, direction)
        let wing = session.wing.currentID
        do {
            let page = try await session.database.read { db in
                try Queries.catalogNotesPage(
                    db, query: query, sort: sort, direction: direction,
                    after: cursor, limit: Self.pageSize, wingID: wing)
            }
            guard generation == searchGeneration else {
                // Superseded: the new question's read owns the listing now.
                loadingMoreNotes = false
                return
            }
            // A note edited between two pages can move across the cursor; it
            // is listed once (the first place it was read), never twice.
            let fresh = page.hits.filter { noteIndex[$0.id] == nil }
            let start = noteHits.count
            noteHits += fresh
            for (offset, hit) in fresh.enumerated() { noteIndex[hit.id] = start + offset }
            notesCursor = page.next
            notesHaveMore = page.next != nil
            loadingMoreNotes = false
            // The page just landed sits beside what is on screen: its extras
            // are the window's to read.
            let next = Self.window(visible: visibleNoteIndices, count: noteHits.count)
            nearPages = next
            await loadNearExtras(generation: generation, replacing: false)
        } catch {
            loadingMoreNotes = false
            guard generation == searchGeneration else { return }
            report(String(describing: error))
        }
    }
}
