//
//  BookStructureModel.swift
//  Variorum
//
//  Phase 13, B3 — the book's STRUCTURE model: real chapters (R28/R50 —
//  reading_section rows + reading_post.section_id), the view mode (Book /
//  Read — R2's reading flow; a finished book opens into Read), the book
//  settings passthroughs, and the journal-book "New Entry" door (R50's
//  binding: ordinary membership; the ONE-ENTRY-PER-DAY rule stays the
//  DAILY journal door's — untouchable, and untouched: only the designated
//  daily book routes through create-or-open).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class BookStructureModel {
    @ObservationIgnored let session: AppSession
    let readingID: String

    /// The book's three modes. 13c Batch 2A (her 2026-07-23/24 direction):
    /// the picker reads **Outline · Book · Read**, and the cases are named
    /// for what each surface IS rather than for what it was called before:
    ///
    /// - `.outline` — the continuous vertical scroll, now the book's
    ///   WRITING surface (A39: "literally looks like write mode but has the
    ///   chapter headings and the posts are collapsible"). This was `.book`.
    /// - `.spread` — the picker's **"Book"**: the two-up spread where each
    ///   page is a whole scrollable POST. Today it is 13b 4F's single-page
    ///   Kindle view; Batch 2B makes it two-up. This was `.pages`.
    /// - `.read` — the reading flow (Batch 2C pairs it with true
    ///   pagination). Unchanged.
    ///
    /// **Why `.spread` and not `.book`** (Batch 2A judgment call 1): the
    /// picker's "Book" now names the surface the old `.book` case did NOT
    /// name, so reusing the identifier would let every stale reference —
    /// in code, in a rebased branch, in a future session reading an older
    /// batch record — compile silently against the wrong surface. Renaming
    /// BOTH cases out of the collision makes every stale reference a
    /// compile error instead.
    enum ViewMode { case outline, spread, read }

    /// READ's two faces (13c Batch 2C — her 2026-07-23/24 direction: Read is
    /// "the Apple-Books/Kindle PAIR of modes").
    ///
    /// - `.flow` — the vertical infinite scroll (`ReadingFlowView`), which is
    ///   what Read has always been.
    /// - `.pages` — TRUE BOOK PAGINATION: a two-page spread of identical
    ///   fixed pages with the text flowing across them (`PagedReadView`).
    ///
    /// `.flow` is the DEFAULT, deliberately: R2's ratified behavior is that a
    /// finished book *opens into the reading flow*, and a sub-mode default of
    /// `.pages` would silently change what she has been opening into for two
    /// phases. PROVISIONAL — QUESTIONS #45(e). Session/view state, never
    /// persisted (the collapse-set class, #43(b)/#44(a)).
    enum ReadForm: String, CaseIterable { case flow, pages }
    var readForm: ReadForm = .flow

    private(set) var reading: Reading?
    private(set) var sections: [ReadingSection] = []
    /// Non-empty when a chapter can be restored — the recovery door must
    /// exist even when NO section rows remain to hang a menu off (round 2,
    /// MINOR: deleting the only chapter made restoreSection unreachable).
    private(set) var deletedSections: [ReadingSection] = []
    private(set) var assignments: [String: String] = [:]
    private(set) var lastError: String?
    var mode: ViewMode = .outline
    /// Set exactly once from the first observed reading row (a finished
    /// book OPENS into the reading flow — R2; pinned).
    private var modeSeeded = false

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var reading: Reading?
        var sections: [ReadingSection]
        var deletedSections: [ReadingSection]
        var assignments: [String: String]
    }

    func start() async {
        do {
            for try await value in session.database.observe({ [readingID] db in
                Snapshot(
                    reading: try Queries.reading(db, id: readingID),
                    sections: try Queries.readingSections(db, readingID: readingID),
                    deletedSections: try Queries.deletedReadingSections(db, readingID: readingID),
                    assignments: try Queries.sectionAssignments(db, readingID: readingID))
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    func adopt(_ snapshot: Snapshot) {
        reading = snapshot.reading
        sections = snapshot.sections
        deletedSections = snapshot.deletedSections
        assignments = snapshot.assignments
        if !modeSeeded, let reading = snapshot.reading {
            mode = Self.defaultMode(for: reading)
            modeSeeded = true
        }
    }

    /// R2: a FINISHED book is nothing but the text — it opens into the
    /// reading flow; a working book opens into OUTLINE, which is where the
    /// book is written (13c 2A, A39).
    nonisolated static func defaultMode(for reading: Reading) -> ViewMode {
        reading.locked ? .read : .outline
    }

    /// Chapters apply to curated books; smart/stamp-sorted books keep the
    /// Phase 4 tag-path headers.
    var chaptersActive: Bool {
        guard let reading else { return false }
        return reading.kind == .curated && !sections.isEmpty
    }

    /// The grouped presentation (pure, pinned): chapters in (position, id)
    /// order, each with its member entries in the reading's own entry
    /// order; UNFILED entries last under a nil group (a chapter is an
    /// organization; stragglers trail — recorded call).
    nonisolated static func grouped(
        entries: [Queries.ReadingEntry],
        sections: [ReadingSection],
        assignments: [String: String]
    ) -> [(section: ReadingSection?, entries: [Queries.ReadingEntry])] {
        var bySection: [String: [Queries.ReadingEntry]] = [:]
        var unfiled: [Queries.ReadingEntry] = []
        for entry in entries {
            if let sectionID = assignments[entry.postID] {
                bySection[sectionID, default: []].append(entry)
            } else {
                unfiled.append(entry)
            }
        }
        var result: [(ReadingSection?, [Queries.ReadingEntry])] = sections.map {
            ($0, bySection[$0.id] ?? [])
        }
        if !unfiled.isEmpty {
            result.append((nil, unfiled))
        }
        return result
    }

    func grouped(entries: [Queries.ReadingEntry])
        -> [(section: ReadingSection?, entries: [Queries.ReadingEntry])] {
        Self.grouped(entries: entries, sections: sections, assignments: assignments)
    }

    // MARK: - Chapter CRUD (R28; movable chapters — sitting 2)

    func createChapter(named name: String) async {
        await run { try $0.createSection(in: self.readingID, name: name) }
    }

    func renameChapter(_ sectionID: String, to name: String) async {
        await run { try $0.renameSection(sectionID, name: name) }
    }

    func deleteChapter(_ sectionID: String) async {
        await run { try $0.deleteSection(sectionID) }
    }

    func restoreLastDeletedChapter() async {
        guard let newest = deletedSections.first else {
            lastError = "No deleted chapter to restore."
            return
        }
        await run { try $0.restoreSection(newest.id) }
    }

    /// Move a chapter one slot up/down (the movable-chapters gesture; the
    /// polished drag bar is Stage C's — R19).
    func moveChapter(_ sectionID: String, up: Bool) async {
        guard let index = sections.firstIndex(where: { $0.id == sectionID }) else { return }
        let target: Operations.InsertPosition
        if up {
            guard index > 0 else { return }
            target = .before(sections[index - 1].id)
        } else {
            guard index < sections.count - 1 else { return }
            target = .after(sections[index + 1].id)
        }
        await run { try $0.reorderSection(sectionID, to: target) }
    }

    /// R19's polished gesture (Stage C): drop a dragged chapter BEFORE
    /// `targetID` (nil = the end). Foreign strings and no-op drops (the
    /// chapter's own edges) touch nothing.
    func moveChapter(_ sectionID: String, before targetID: String?) async {
        guard sectionID != targetID,
              sections.contains(where: { $0.id == sectionID })
        else { return }
        if let targetID {
            guard let targetIndex = sections.firstIndex(where: { $0.id == targetID })
            else { return }
            if targetIndex > 0, sections[targetIndex - 1].id == sectionID { return }
            await run { try $0.reorderSection(sectionID, to: .before(targetID)) }
        } else {
            guard sections.last?.id != sectionID else { return }
            await run { try $0.reorderSection(sectionID, to: .end) }
        }
    }

    /// File a post into a chapter (nil = unfiled).
    func assign(_ postID: String, to sectionID: String?) async {
        await run { try $0.assignPostToSection(postID, in: self.readingID, section: sectionID) }
    }

    // MARK: - Book settings (the navigator's third leg — R43)

    func setFinished(_ finished: Bool) async {
        await run { finished ? try $0.lockReading(self.readingID) : try $0.unlockReading(self.readingID) }
    }

    func rename(to name: String) async {
        await run { try $0.renameReading(self.readingID, name: name) }
    }

    func setWordTarget(_ target: Int?) async {
        await run { try $0.setReadingWordTarget(self.readingID, wordTarget: target) }
    }

    func setMaxPosts(_ cap: Int?) async {
        await run { try $0.setReadingMaxPosts(self.readingID, maxPosts: cap) }
    }

    // MARK: - The journal-book entry door (R50, the B3 design detail)

    /// "New Entry" on a journal-profile book. THE DAILY BOOK routes
    /// through `createOrOpenJournalEntry` — the one-entry-per-day rule is
    /// a Fragments-bridge rule and is UNTOUCHABLE (R50). OTHER journal
    /// books (the dream journal) mint a **`.generic`** dated post with
    /// one-block segmentation set explicitly (the notebook feel) and add
    /// it to THIS book — **NEVER container `profile='journal'`** (Stage B
    /// review round 2, BLOCKER: that profile+date shape IS the daily
    /// journal's identity — `canonicalJournalEntry` and the Fragments
    /// bridge sweep both key on it, so a `.journal` dream entry became
    /// "the day's entry" for ⌘J and pushed/paused the bridge's day.
    /// Journal-BOOK identity lives on `reading.profile`, not the post).
    /// Several entries on one day stay legal in these books; the daily
    /// rule's scope is the daily SHAPE, which these entries no longer
    /// wear (pinned, red-on-old verified by revert).
    /// The designation read runs INSIDE the runner (round 2, MINOR: the
    /// pre-runner read raced).
    ///
    /// Round 3, MINOR — the Outcome doctrine at this sibling door (the
    /// round-2 ⌘J shape, applied consistently): on a LOCKED/FULL book the
    /// DAILY branch still opens the entry (the untouchable create-or-open)
    /// with a SPEAKING note; the NON-DAILY branch refuses BEFORE MINTING —
    /// `assertReadingAcceptsPosts` runs inside the serialized closure, so
    /// a concurrent lock can never strand a stray `.generic` post in the
    /// Pool — and its refusal speaks through the message table (the raw
    /// `String(describing:)` retired with it).
    func newEntry(day: String? = nil) async -> String? {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        do {
            let readingID = readingID
            let outcome: (id: String, note: String?) = try await session.runner.run { ops in
                if try ops.dailyJournalBookID() == readingID {
                    let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
                    do {
                        _ = try ops.addPostToReading(entry.container.id, to: readingID)
                    } catch OperationError.alreadyInReading {
                    } catch OperationError.lockedReading {
                        return (entry.container.id,
                                "Today's entry opened, but this book is finished — it "
                                + "wasn't added. Reopen the book in its settings, or pick "
                                + "a new daily journal (Use as Daily Journal).")
                    } catch OperationError.readingAtCapacity {
                        return (entry.container.id,
                                "Today's entry opened, but this book is at its post cap — "
                                + "it wasn't added. Extend the cap in the book's settings.")
                    }
                    return (entry.container.id, nil)
                }
                // REFUSE BEFORE MINT: the gate runs first, in the same
                // serialized closure as the mint it protects.
                try ops.assertReadingAcceptsPosts(readingID)
                let post = try ops.createPost(
                    title: nil, profile: .generic, entryDate: entryDay)
                try ops.setSegmentationDefault(post.id, segmentation: .oneBlock)
                _ = try ops.addPostToReading(post.id, to: readingID)
                return (post.id, nil)
            }
            lastError = outcome.note
            return outcome.id
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
            return nil
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    /// Sitting 9 (R62/R75): a NEW POST born INSIDE this book — one
    /// transaction (post + membership; refusals mint no stray), the
    /// non-journal sibling of "+ new entry".
    func newPost() async -> String? {
        do {
            let readingID = readingID
            let post = try await session.runner.run { ops in
                try ops.newPostInReading(readingID)
            }
            lastError = nil
            return post.id
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
            return nil
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastError = String(describing: error)
        }
    }
}

/// The Today's-Entry door with the R50 ensure-membership half (shared by
/// the shelf button, ⌘J, and the palette): create-or-open THE day's entry
/// (the untouchable rule), then make sure a designated DAILY JOURNAL BOOK
/// exists (created + pinned + designated on first use) and holds the
/// entry — the journal lives on the shelf as ordinary membership (R38 +
/// R50). PROVISIONAL shape, QUESTIONS bundle.
enum JournalBooks {
    nonisolated static let defaultDailyBookName = "Journal"

    /// The door's outcome: the entry ALWAYS opens; `note` speaks when the
    /// membership half couldn't happen (Stage B review round 2, MAJOR 2:
    /// finishing/filling the daily book is an EXPECTED gesture in the
    /// bounded-notebook flow — it must never wedge ⌘J into a thrown error,
    /// and never silently).
    struct Outcome: Equatable {
        let postID: String
        let note: String?
    }

    @MainActor
    static func openToday(session: AppSession, day: String? = nil) async throws -> Outcome {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        // The designation read runs INSIDE the runner (round 2, MINOR:
        // two rapid invocations both saw nil pre-runner and minted two
        // "Journal" books).
        return try await session.runner.run { ops in
            let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
            // CREATE-AND-PIN stays here, and only here: minting a book on
            // her shelf is the act only a button press she pressed may take
            // (QUESTIONS #37 — it is why this door is deliberately not the
            // shared helper wholesale).
            if try ops.dailyJournalBookID() == nil {
                let book = try ops.createReading(
                    name: defaultDailyBookName, kind: .curated, profile: "journal",
                    sortField: .entryDate, sortDir: .asc)
                try ops.setDailyJournalBook(book.id)
                try ops.setShelfPinned(book.id, pinned: true)
            }
            // …and the ENSURE half delegates to the one implementation
            // (13c Stage 1 ladder, R1-4). This door used to call
            // `addPostToReading` itself and catch `alreadyInReading`, which
            // fires on LIVE rows only — so a membership she had deliberately
            // removed (a tombstoned row) was invisible here and ⌘J silently
            // put the entry back on the shelf, while the bridge and the
            // phone correctly left it alone. "Any membership row, live or
            // tombstoned, means the pair is already decided" is ONE rule, and
            // now it really is one.
            var bookName = defaultDailyBookName
            func namedBook() -> String {
                (try? ops.dailyJournalBookName() ?? nil) ?? bookName
            }
            switch ops.shelveInDailyJournalBook(entry.container.id) {
            case .shelved, .alreadyDecided:
                return Outcome(postID: entry.container.id, note: nil)
            case .bookFinished:
                // The daily book is FINISHED (the bounded-notebook flow's
                // expected end): the entry still opens; the note speaks
                // and points at the re-designation door.
                bookName = namedBook()
                return Outcome(
                    postID: entry.container.id,
                    note: "Today's entry opened, but “\(bookName)” is finished — "
                        + "it wasn't added. Pick a new daily journal from a book's "
                        + "shelf menu (Use as Daily Journal), or reopen “\(bookName)”.")
            case .bookAtCapacity:
                bookName = namedBook()
                return Outcome(
                    postID: entry.container.id,
                    note: "Today's entry opened, but “\(bookName)” is at its post cap — "
                        + "it wasn't added. Extend the cap or start a new daily journal "
                        + "(Use as Daily Journal in a book's shelf menu).")
            case .wrongKind:
                bookName = namedBook()
                return Outcome(
                    postID: entry.container.id,
                    note: "Today's entry opened, but “\(bookName)” is a smart book — "
                        + "it collects by query and can't hold entries. Pick a curated "
                        + "book with Use as Daily Journal.")
            case .noDailyBook, .refused:
                // Unreachable in the ordinary path (the branch above
                // guarantees a designation); a race gets a speaking note
                // rather than a silent miss.
                return Outcome(
                    postID: entry.container.id,
                    note: "Today's entry opened, but it wasn't added to a daily "
                        + "journal book. Pick one with Use as Daily Journal.")
            }
        }
    }
}
