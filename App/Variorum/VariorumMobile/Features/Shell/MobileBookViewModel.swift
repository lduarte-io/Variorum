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
    /// **Which live chapters hold a member ANYWHERE in the book** — read
    /// only while the listing is truncated (the cold review's MINOR 4).
    /// The window is what makes it necessary: `grouped` fills a chapter
    /// from the WINDOWED entries, so past the cut every chapter looked
    /// empty, and this batch had just taught an empty chapter header to
    /// MEAN "this chapter is empty". Ids only, book-scoped, one `DISTINCT`
    /// beside the assembly in the same transaction.
    private(set) var populatedChapters: Set<String> = []
    private(set) var truncated = false
    /// A STORE-READ failure — the screen's own, not a tap's. It belongs to
    /// the header, where the book's identity is.
    private(set) var lastError: String?
    /// **A DOOR'S REFUSAL, HELD APART FROM THE SCREEN'S OWN ERROR** (the
    /// batch-10 cold review, MAJOR 2). The two doors sit at the BOTTOM of
    /// the contents list; a refusal rendered only in the header spoke
    /// hundreds of points above the finger that fired it, so on a book
    /// longer than a screen the tap read as nothing happening at all —
    /// which is exactly what the finished-book divergence (doors stay so
    /// they can EXPLAIN) cannot afford. One slot per speaker: this one
    /// renders beside the doors.
    private(set) var doorRefusal: String?

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
        /// Ids of chapters holding at least one live member (MINOR 4).
        /// EMPTY unless the listing is truncated — an untruncated window
        /// holds every entry, so a chapter with no windowed entry has none.
        var populatedChapters: Set<String>
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
                let entries = try Queries.assembleReading(db, readingID: id, limit: probe)
                // Smart readings refuse sections by model rule, so the
                // read is skipped rather than returning an empty list —
                // the same shape `assembleReading` uses for `hasChapters`.
                let chapters = reading?.kind == .book
                    ? try Queries.readingSections(db, readingID: id) : []
                // MINOR 4: only when the window actually cut something, so
                // the ordinary book pays nothing for the corner. Mirrors the
                // assembly's own membership join (live, unarchived posts) so
                // the two readings can never disagree about what counts.
                let populated: Set<String> = entries.count > probe - 1 && !chapters.isEmpty
                    ? Set(try String.fetchAll(
                        db,
                        sql: """
                            SELECT DISTINCT rp.section_id
                            FROM reading_post rp
                            JOIN container c
                              ON c.id = rp.post_id
                             AND c.deleted_at IS NULL
                             AND c.archived_at IS NULL
                             AND c.kind = 'post'
                            WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                              AND rp.section_id IS NOT NULL
                            """,
                        arguments: [id]))
                    : []
                return Snapshot(
                    reading: reading, entries: entries, chapters: chapters,
                    populatedChapters: populated)
            }) {
                truncated = value.entries.count > window
                entries = Array(value.entries.prefix(window))
                reading = value.reading
                chapters = value.chapters
                populatedChapters = value.populatedChapters
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The list grouped by the assembly's own section transitions —
    /// pure, pinned. `section` nil ⇒ unsectioned rows (no header).
    var groupedRows: [(section: String?, entries: [Queries.ReadingEntry])] {
        Self.grouped(entries, chapters: chapters, populated: populatedChapters)
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
    ///
    /// **`populated` is the TRUNCATION answer** (the cold review's MINOR 4).
    /// A chapter is filled from the WINDOWED entries, so on a book past its
    /// 300-note window a chapter whose notes all lie past the cut rendered a
    /// header with nothing under it — indistinguishable from the genuinely
    /// empty chapter this batch had just taught the list to show, and a lie
    /// where the empty one is a fact. The ids of chapters holding a member
    /// ANYWHERE settle the difference: a chapter with no windowed entry and
    /// no member is EMPTY and renders; one with no windowed entry and a
    /// member is BEYOND THE CUT and folds under the listing's own truncation
    /// marker, which already says the rest of the book isn't loaded. The set
    /// is supplied only when the listing is truncated, so an ordinary book
    /// takes exactly the path it always did.
    nonisolated static func grouped(
        _ entries: [Queries.ReadingEntry], chapters: [ReadingSection] = [],
        populated: Set<String> = []
    ) -> [(section: String?, entries: [Queries.ReadingEntry])] {
        if !chapters.isEmpty {
            var groups = chapters.compactMap {
                chapter -> (section: String?, entries: [Queries.ReadingEntry])? in
                let mine = entries.filter { $0.sectionID == chapter.id }
                guard !mine.isEmpty || !populated.contains(chapter.id) else { return nil }
                return (section: Optional(chapter.name), entries: mine)
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
        reading?.kind == .book
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
            doorRefusal = nil
            return post.id
        } catch {
            doorRefusal = Self.refusal(error, bookName: reading?.name)
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
            doorRefusal = nil
        } catch {
            doorRefusal = Self.refusal(error, bookName: reading?.name)
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
