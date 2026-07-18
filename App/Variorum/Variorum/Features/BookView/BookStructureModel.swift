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
        var assignments: [String: String]
    }

    func start() async {
        do {
            for try await value in session.database.observe({ [readingID] db in
                Snapshot(
                    reading: try Queries.reading(db, id: readingID),
                    sections: try Queries.readingSections(db, readingID: readingID),
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
        do {
            let deleted = try await session.database.read { [readingID] db in
                try Queries.deletedReadingSections(db, readingID: readingID)
            }
            guard let newest = deleted.first else {
                lastError = "No deleted chapter to restore."
                return
            }
            await run { try $0.restoreSection(newest.id) }
        } catch {
            lastError = String(describing: error)
        }
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
    /// a Fragments-bridge rule and is UNTOUCHABLE (R50); OTHER journal
    /// books (the dream journal) mint a plain dated post and add it to
    /// THIS book — several entries on one day are legal there, and the
    /// daily rule's scope stays exactly the daily door (pinned).
    func newEntry(day: String? = nil) async -> String? {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        do {
            let readingID = readingID
            let dailyBookID = try await session.database.read { db in
                try Queries.dailyJournalBookID(db)
            }
            return try await session.runner.run { ops in
                if dailyBookID == readingID {
                    let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
                    do {
                        _ = try ops.addPostToReading(entry.container.id, to: readingID)
                    } catch OperationError.alreadyInReading {}
                    return entry.container.id
                }
                let post = try ops.createPost(
                    title: nil, profile: .journal, entryDate: entryDay)
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

    @MainActor
    static func openToday(session: AppSession, day: String? = nil) async throws -> String {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        let existing = try await session.database.read { db in
            try Queries.dailyJournalBookID(db)
        }
        return try await session.runner.run { ops in
            let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
            let bookID: String
            if let existing {
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
            }
            return entry.container.id
        }
    }
}
