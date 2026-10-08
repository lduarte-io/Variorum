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
    /// window when it crosses a page, lands a waiting page when she is close
    /// to the end, and asks for the next page early enough that it is in hand
    /// before she gets there. Answers whether it asked (`spawning: false` is
    /// the pins' road — they drive the read themselves).
    @discardableResult
    func noteRowAppeared(_ id: String, spawning: Bool = true) -> Bool {
        guard let position = noteIndex[id] else { return false }
        visibleNoteIndices.insert(position)
        lastSeenPosition = position
        if spawning { rowsMoved() }
        windowMaybeMoved(spawning: spawning)
        if pendingLanding != nil, rowsAhead <= Self.landNowMargin {
            landPendingPage()
        }
        guard canAskForMore,
              rowsAhead < max(Self.prefetchMargin, nextPageSize / 2) else { return false }
        // The read starts on the NEXT turn, never inside the layout that
        // reported the row.
        if spawning { Task { @MainActor in await loadMoreNotes() } }
        return true
    }

    /// A next page may be asked for: another exists, none is in flight or in
    /// hand, the listing is paged (a day's answer is whole), and no newer
    /// question is being read (`listedGeneration`).
    ///
    /// VX-84a: a `#tag` typed alone is a PAGED listing even with a day armed
    /// beside it (the day joins the tag's narrowing — only the day ALONE is
    /// answered whole), so the day stands the paging down only when nothing
    /// narrows the listing; otherwise the tag's notes past the first page
    /// would be a cap with no road (R-13o-9).
    var canAskForMore: Bool {
        notesHaveMore && !loadingMoreNotes && pendingLanding == nil
            && (editedOn == nil || listedNarrowing != nil)
            && notesCursor != nil && listedGeneration == searchGeneration
    }

    /// How many listed rows lie below what she is looking at.
    var rowsAhead: Int {
        noteHits.count - 1 - (visibleNoteIndices.max() ?? lastSeenPosition)
    }

    /// **The next page's size — it GROWS** (17y B1 (k), measured): a page
    /// LANDING costs a stall of its own in the List (the table re-measures and
    /// re-diffs — 70–130 ms in the Debug build, barely moved by the page's
    /// size), so the listing doubles with each page up to `maxPageSize`: a
    /// whole corpus is a handful of landings, and each is still ONE bounded
    /// read (∝ the page, never the corpus).
    var nextPageSize: Int {
        min(Self.maxPageSize, max(Self.pageSize, noteHits.count))
    }

    /// **She is scrolling** — the rows themselves say so (a row came or went
    /// on screen; both views, where the List reports no scroll phase): a
    /// page that arrives while the rows move WAITS for them to rest
    /// `restInterval` — unless she gets within `landNowMargin` rows of the
    /// end first — so a landing's stall falls in a pause, never under her
    /// moving hand.
    private func rowsMoved() {
        lastRowMotion = ContinuousClock.now
        listMoving = true
        guard restWatch == nil else { return }
        restWatch = Task { @MainActor [weak self] in
            while let model = self {
                let quiet = ContinuousClock.now - model.lastRowMotion
                if quiet >= Self.restInterval {
                    model.restWatch = nil
                    model.rowsRested()
                    return
                }
                try? await Task.sleep(for: Self.restInterval - quiet)
            }
        }
    }

    /// The rows have rested: a page in hand lands now.
    func rowsRested() {
        listMoving = false
        if pendingLanding != nil { landPendingPage() }
    }

    /// A note row left the screen (both views' `.onDisappear`).
    func noteRowDisappeared(_ id: String, spawning: Bool = true) {
        guard let position = noteIndex[id] else { return }
        visibleNoteIndices.remove(position)
        if spawning { rowsMoved() }
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
        guard !ids.isEmpty else {
            ownershipHold = nil
            return
        }
        let session = session
        ownershipHold = Task { @MainActor [weak self] in
            do {
                for try await value in session.database.observe({ db in
                    try Queries.ownershipFacts(db, postIDs: ids, inBook: nil)
                }) {
                    // Each answer reaches only the rows whose facts changed.
                    self?.landFacts(value, for: ids)
                }
            } catch {
                // A failed read draws no new badge — silence, never a wrong mark.
            }
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
        guard canAskForMore, let cursor = notesCursor else { return }
        loadingMoreNotes = true
        let generation = searchGeneration
        let (query, sort, direction, mode) = (query, sort, direction, mode)
        // VX-84a: a tag typed alone narrows EVERY page the way it narrowed
        // the first — the field's text is the tag, never a title to LIKE.
        let narrowing = listedNarrowing
        let wing = session.wing.currentID
        let limit = nextPageSize
        do {
            // The page AND its extras in ONE read, landed in ONE update — so
            // the rows on screen re-draw once per page, never once for the
            // rows and again for their chips (measured: the second pass was
            // half of a page's stall).
            let (page, chips, cards, cardIDs) = try await session.database.read { db in
                let page = try Queries.catalogNotesPage(
                    db, query: narrowing == nil ? query : "", sort: sort, direction: direction,
                    after: cursor, limit: limit, wingID: wing, narrowing: narrowing)
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
            pendingLanding = PendingNotesPage(
                page: page, chips: chips, cards: cards, cardIDs: cardIDs, generation: generation)
            // Land now unless she is mid-scroll with rows still ahead of her
            // (then it lands when the rows rest — `rowsMoved`).
            if !listMoving || rowsAhead <= Self.landNowMargin { landPendingPage() }
        } catch {
            loadingMoreNotes = false
            guard generation == searchGeneration else { return }
            report(String(describing: error))
        }
    }

    /// **Land the page in hand** — ONE update: the rows, their chips, their
    /// card words, the cursor.
    func landPendingPage() {
        guard let pending = pendingLanding else { return }
        pendingLanding = nil
        loadingMoreNotes = false
        guard pending.generation == searchGeneration else { return }
        let page = pending.page
        // A note edited between two pages can move across the cursor; it is
        // listed once (the first place it was read), never twice. Moved the
        // OTHER way — above every page read so far — it is ABSENT until the
        // next question or act (the B1 ladder's NIT-2): the one-shot
        // listing's own staleness, the shipped 40-row class — the catalog
        // re-asks on Library appear and after every row act, and an
        // already-listed note keeps its old position either way.
        let fresh = page.hits.filter { noteIndex[$0.id] == nil }
        let start = noteHits.count
        noteHits += fresh
        for (offset, hit) in fresh.enumerated() { noteIndex[hit.id] = start + offset }
        mergeExtras(
            chipIDs: page.hits.map(\.id), chips: pending.chips,
            cardIDs: pending.cardIDs, cards: pending.cards)
        // The pages this one filled are loaded (chips; cards for this mode).
        let landed = Set(fresh.compactMap { noteIndex[$0.id] }.map { $0 / Self.pageSize })
        chipPages.formUnion(landed)
        cardPages.formUnion(landed)
        notesCursor = page.next
        notesHaveMore = page.next != nil
        nearPages = Self.window(visible: visibleNoteIndices, count: noteHits.count)
        holdNearFacts()
    }
}
