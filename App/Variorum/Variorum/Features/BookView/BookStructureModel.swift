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

    enum ViewMode { case book, read }

    private(set) var reading: Reading?
    private(set) var sections: [ReadingSection] = []
    /// Non-empty when a chapter can be restored — the recovery door must
    /// exist even when NO section rows remain to hang a menu off (round 2,
    /// MINOR: deleting the only chapter made restoreSection unreachable).
    private(set) var deletedSections: [ReadingSection] = []
    private(set) var assignments: [String: String] = [:]
    private(set) var lastError: String?
    var mode: ViewMode = .book
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
    /// reading flow; a working book opens into the book view.
    nonisolated static func defaultMode(for reading: Reading) -> ViewMode {
        reading.locked ? .read : .book
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
    func newEntry(day: String? = nil) async -> String? {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        do {
            let readingID = readingID
            return try await session.runner.run { ops in
                if try ops.dailyJournalBookID() == readingID {
                    let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
                    do {
                        _ = try ops.addPostToReading(entry.container.id, to: readingID)
                    } catch OperationError.alreadyInReading {}
                    return entry.container.id
                }
                let post = try ops.createPost(
                    title: nil, profile: .generic, entryDate: entryDay)
                try ops.setSegmentationDefault(post.id, segmentation: .oneBlock)
                _ = try ops.addPostToReading(post.id, to: readingID)
                return post.id
            }
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
            let bookID: String
            var bookName = defaultDailyBookName
            if let existing = try ops.dailyJournalBookID() {
                bookID = existing
            } else {
                let book = try ops.createReading(
                    name: defaultDailyBookName, kind: .curated, profile: "journal",
                    sortField: .entryDate, sortDir: .asc)
                try ops.setDailyJournalBook(book.id)
                try ops.setShelfPinned(book.id, pinned: true)
                bookID = book.id
            }
            do {
                _ = try ops.addPostToReading(entry.container.id, to: bookID)
            } catch OperationError.alreadyInReading {
                // The day's entry is already shelved — the notebook page
                // was simply reopened.
            } catch OperationError.lockedReading {
                // The daily book is FINISHED (the bounded-notebook flow's
                // expected end): the entry still opens; the note speaks
                // and points at the re-designation door.
                bookName = (try? ops.dailyJournalBookName() ?? nil) ?? bookName
                return Outcome(
                    postID: entry.container.id,
                    note: "Today's entry opened, but “\(bookName)” is finished — "
                        + "it wasn't added. Pick a new daily journal from a book's "
                        + "shelf menu (Use as Daily Journal), or reopen “\(bookName)”.")
            } catch OperationError.readingAtCapacity {
                bookName = (try? ops.dailyJournalBookName() ?? nil) ?? bookName
                return Outcome(
                    postID: entry.container.id,
                    note: "Today's entry opened, but “\(bookName)” is at its post cap — "
                        + "it wasn't added. Extend the cap or start a new daily journal "
                        + "(Use as Daily Journal in a book's shelf menu).")
            }
            return Outcome(postID: entry.container.id, note: nil)
        }
    }
}
