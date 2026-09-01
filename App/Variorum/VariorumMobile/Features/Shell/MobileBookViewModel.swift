//
//  MobileBookViewModel.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — a book's note list (M7: tapping a book opens
//  its notes; the Read flow itself is S4's). ONE held observation delivers
//  the book row + its assembly coherently (the standing reading-assembly
//  read: curated order or the smart predicate, chapters resolved to
//  section names in book order). Bounded like every held listing
//  (window + probe row, so an exact-window book never false-positives
//  the truncation marker — the Phase 10 discipline).
//
//  Chapters honored (scope item 1): rows group by the assembly's OWN
//  section transitions — the phone never re-sorts, so chapter headers
//  appear exactly where the book's order puts them.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileBookViewModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let readingID: String
    /// The bounded window (P1); the fetch carries one probe row past it.
    @ObservationIgnored private let window: Int

    private(set) var reading: Reading?
    private(set) var entries: [Queries.ReadingEntry] = []
    /// The book's live chapters in book order (batch 10) — carried so an
    /// EMPTY chapter still renders a header. Without it the New Chapter
    /// door below would create a real row she could not see, which is the
    /// fire-and-DO failure (R115) dressed as a success.
    private(set) var chapters: [ReadingSection] = []
    private(set) var truncated = false
    private(set) var lastError: String?

    init(session: AppSession, readingID: String, window: Int = 300) {
        self.session = session
        self.readingID = readingID
        self.window = window
    }

    /// The bounded-window truncation marker (never a silent cut) — ONE
    /// sentence for both book surfaces (the note list and the Read flow).
    /// Reworded at parity A1, P32's flip: NEUTRAL — the "full book lives
    /// on the Mac" tail violated the no-redirect principle and went;
    /// load-more itself stays deferred with the Mac's own bounded-window
    /// family (the Phase 12 windowing row).
    static func truncationMarker(shown: Int) -> String {
        "Showing the first \(shown) notes — the rest of this book isn't loaded yet."
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var reading: Reading?
        var entries: [Queries.ReadingEntry]
        /// The book's live CHAPTERS (batch 10). Author-scale and bounded by
        /// the book — the `bookshelf` cost class, not a corpus read — and it
        /// rides the SAME held observation so the contents list and its
        /// chapters can never disagree about what exists.
        var chapters: [ReadingSection]
    }

    func start() async {
        do {
            let id = readingID
            let probe = window + 1
            for try await value in session.database.observe({ db in
                let reading = try Reading.fetchOne(
                    db,
                    sql: "SELECT * FROM reading WHERE id = ? AND deleted_at IS NULL",
                    arguments: [id])
                return Snapshot(
                    reading: reading,
                    entries: try Queries.assembleReading(db, readingID: id, limit: probe),
                    // Smart readings refuse sections by model rule, so the
                    // read is skipped rather than returning an empty list —
                    // the same shape `assembleReading` uses for `hasChapters`.
                    chapters: reading?.kind == .curated
                        ? try Queries.readingSections(db, readingID: id) : [])
            }) {
                truncated = value.entries.count > window
                entries = Array(value.entries.prefix(window))
                reading = value.reading
                chapters = value.chapters
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The list grouped by the assembly's own section transitions —
    /// pure, pinned. `section` nil ⇒ unsectioned rows (no header).
    var groupedRows: [(section: String?, entries: [Queries.ReadingEntry])] {
        Self.grouped(entries, chapters: chapters)
    }

    /// **The grouping, and since batch 10 it resolves CHAPTERS BY ID.**
    ///
    /// Two resolutions under one shape, exactly as `Queries.exportReading`
    /// already does them (the rule the Mac's `BookStructureModel.grouped`
    /// owns; this is the phone's face of the same rule, never a third one):
    ///
    /// · **With chapters** — every live chapter gets a group in
    ///   `(position, id)` order, **EMPTY ONES INCLUDED**, matched on
    ///   `sectionID` rather than on the name (chapter names have no
    ///   uniqueness — AppSpec §7 — so two chapters called "One" are two
    ///   groups, and a name match would have merged them); unfiled entries
    ///   trail under no header, which is the assembly's own order.
    /// · **Without chapters** — the run-clustering this always did, which
    ///   is what a smart book and a tag-grouped curated book still get
    ///   (both have no `reading_section` rows by model rule).
    ///
    /// An empty chapter renders a HEADER and nothing under it. That is the
    /// point: it is what makes the New Chapter door's result visible on a
    /// screen that has no chapter navigator to put it in.
    nonisolated static func grouped(
        _ entries: [Queries.ReadingEntry], chapters: [ReadingSection] = []
    ) -> [(section: String?, entries: [Queries.ReadingEntry])] {
        if !chapters.isEmpty {
            var groups = chapters.map { chapter in
                (section: Optional(chapter.name),
                 entries: entries.filter { $0.sectionID == chapter.id })
            }
            let unfiled = entries.filter { $0.sectionID == nil }
            if !unfiled.isEmpty {
                groups.append((section: nil, entries: unfiled))
            }
            return groups
        }
        var groups: [(section: String?, entries: [Queries.ReadingEntry])] = []
        for entry in entries {
            if let last = groups.indices.last, groups[last].section == entry.sectionPath {
                groups[last].entries.append(entry)
            } else {
                groups.append((section: entry.sectionPath, entries: [entry]))
            }
        }
        return groups
    }

    // MARK: - The two doors inside a book (batch 10)

    /// Her ask, verbatim: *"when you're within a book, there should be a
    /// new note and new chapter button, which the mac up does have."*

    /// **Whether this book can wear the two doors at all.** CURATED only —
    /// a smart book's membership is derived and its chapters are refused by
    /// model rule, so neither door could ever mean what it says there and
    /// P-2 says a door that cannot act is not rendered. A FINISHED book
    /// keeps them and they REFUSE in the family's voice: finished is a
    /// state she can reverse in Details, one tap away, and a door that
    /// silently vanished when she finished a book would teach nothing.
    var showsBookDoors: Bool {
        reading?.kind == .curated
    }

    /// **+ new note** — the Mac's own door (R62/R75), through the Mac's own
    /// operation: `newPostInReading` mints the note AND its membership in
    /// ONE transaction, with the gate — missing, wrong kind, locked, at
    /// capacity — checked INSIDE it, before `insertPost` runs. That is the
    /// refuse-before-mint doctrine in its strongest form: a refusal cannot
    /// leave a stray note behind, because the refusal happens before the
    /// note exists and in the same transaction.
    ///
    /// Returns the new note to open for writing.
    func newNote() async -> String? {
        let id = readingID
        do {
            let post = try await session.runner.run { ops in
                try ops.newPostInReading(id)
            }
            lastError = nil
            return post.id
        } catch {
            lastError = Self.refusal(error, bookName: reading?.name)
            return nil
        }
    }

    /// **+ new chapter** — `createSection`, curated-only and locked-refusing
    /// by the operation's own guards. No undo entry is registered here or
    /// there: chapters are the tags/locks class, where the recovery door
    /// (`restoreSection`) IS the inverse (AppSpec §9).
    func newChapter(named name: String) async {
        let id = readingID
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.canName(trimmed) else { return }
        do {
            try await session.runner.run { ops in
                try ops.createSection(in: id, name: trimmed)
            }
            lastError = nil
        } catch {
            lastError = Self.refusal(error, bookName: reading?.name)
        }
    }

    /// The chapter name's face gate — the book-rename door's own rule
    /// (C2 ladder R1-3: a blank name never fires a silent no-op).
    nonisolated static func canName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// **Forwards to the phone's ONE reading-refusal home** — the membership
    /// sheet's, which already says *"“X” is finished — reopen it to change
    /// what's in it"* and *"“X” is at its note cap."* in the phone's voice.
    /// Copying either sentence here is the drift class (MobileSoul §3); the
    /// `MobileBookDetailsModel.refusal` forwarder is the precedent.
    nonisolated static func refusal(_ error: Error, bookName: String?) -> String {
        MobileMembershipModel.refusal(error, bookName: bookName)
    }

    /// A row's display name — the ONE display brain (13k K1).
    nonisolated static func rowTitle(_ entry: Queries.ReadingEntry) -> String {
        DisplayTitle.note(
            title: entry.title, entryDate: entry.entryDate, createdAt: entry.createdAt)
    }

    /// A section header's displayed text: chapter names pass through;
    /// tag-grouping paths show their leaf (the K3 doctrine).
    nonisolated static func sectionLabel(_ section: String) -> String {
        MobileShelfFaces.leaf(section)
    }
}
