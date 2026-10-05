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
        // The read starts on the NEXT turn, never inside the layout that
        // reported the row.
        if spawning { Task { @MainActor in await loadMoreNotes() } }
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

    /// The window check — coalesced into ONE per turn when the views report
    /// (`spawning`), run at once when a pin drives it.
    private func windowMaybeMoved(spawning: Bool) {
        guard spawning else {
            applyWindow()
            return
        }
        guard !windowCheckQueued else { return }
        windowCheckQueued = true
        Task { @MainActor in
            windowCheckQueued = false
            applyWindow()
            await loadNearExtras(generation: searchGeneration, replacing: false)
        }
    }

    /// Move the window to what is on screen; re-aim the held facts if it moved.
    private func applyWindow() {
        let next = Self.window(visible: visibleNoteIndices, count: noteHits.count)
        guard next != nearPages else { return }
        nearPages = next
        holdNearFacts()
    }

    // MARK: - The held facts (the near window's ownership badges)

    /// Observe the owned-by facts of the near window's notes — and nothing
    /// else: re-aimed only when the window's ids change (a page boundary, a
    /// new page in the window, a re-read), so the held region stays a few
    /// pages however deep she scrolls.
    func holdNearFacts() {
        let ids = nearNoteIDs
        guard ids != heldNoteIDs || ownershipHold == nil else { return }
        heldNoteIDs = ids
        ownershipHold?.cancel()
        let ownership = ownership
        let session = session
        ownershipHold = Task { @MainActor in
            await ownership.observe(session: session, postIDs: ids, inBook: nil)
        }
    }

    /// The listing left the screen: the held observation ends with it.
    func stopHoldingFacts() {
        ownershipHold?.cancel()
        ownershipHold = nil
        heldNoteIDs = []
    }

    /// **The next page of notes** — one keyset read after the cursor, under
    /// the question the listing is answering (a new question since — a typed
    /// letter, a sort — supersedes it, and its page never lands).
    func loadMoreNotes() async {
        guard notesHaveMore, !loadingMoreNotes, editedOn == nil,
              let cursor = notesCursor else { return }
        loadingMoreNotes = true
        let generation = searchGeneration
        let (query, sort, direction, mode) = (query, sort, direction, mode)
        let wing = session.wing.currentID
        do {
            // The page AND its extras in ONE read, landed in ONE update — so
            // the rows on screen re-draw once per page, never once for the
            // rows and again for their chips (measured: the second pass was
            // half of a page's stall).
            let (page, chips, cards, cardIDs) = try await session.database.read { db in
                let page = try Queries.catalogNotesPage(
                    db, query: query, sort: sort, direction: direction,
                    after: cursor, limit: Self.pageSize, wingID: wing)
                let ids = page.hits.map(\.id)
                let plan = LibraryCardRead.plan(mode: mode, hits: page.hits)
                return (
                    page,
                    ids.isEmpty ? [:] : try TagChips.load(db, postIDs: ids),
                    plan.ids.isEmpty ? [:] : try NoteCards.load(
                        db, postIDs: plan.ids, includingBooks: plan.books),
                    plan.ids)
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
            mergeExtras(
                chipIDs: page.hits.map(\.id), chips: chips, cardIDs: cardIDs, cards: cards)
            // The pages this one filled are loaded (chips; cards for this mode).
            let landed = Set(fresh.compactMap { noteIndex[$0.id] }.map { $0 / Self.pageSize })
            chipPages.formUnion(landed)
            cardPages.formUnion(landed)
            notesCursor = page.next
            notesHaveMore = page.next != nil
            loadingMoreNotes = false
            nearPages = Self.window(visible: visibleNoteIndices, count: noteHits.count)
            holdNearFacts()
            // Anything else the window now covers (rare — a page split by a
            // dedupe) fills here; normally there is nothing left to read.
            await loadNearExtras(generation: generation, replacing: false)
        } catch {
            loadingMoreNotes = false
            guard generation == searchGeneration else { return }
            report(String(describing: error))
        }
    }
}
