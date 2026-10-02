//
//  ShelfViewModel.swift
//  Variorum
//
//  Phase 13, B2 — the shelf's model (the sitting-1 books reversal + R4's
//  terminal list + R38's pinning). Two cost tiers by contract: the book
//  list + pins ride a held observation (author-scale); word counts and the
//  tags column are ONE-SHOT loads on appearance/refresh (corpus-scale
//  aggregates must never re-run at autosave rate — the P1 discipline the
//  core query documents).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class ShelfViewModel {
    @ObservationIgnored let session: AppSession

    private(set) var books: [Queries.ShelfBook] = []
    private(set) var pins: [String] = []
    private(set) var wordCounts: [String: Int] = [:]
    private(set) var bookTags: [String: [String]] = [:]
 var ruleTags: [String: [String]] = [:]
    private(set) var lastError: String?
    /// R98: apply-and-report's REPORT half — not an error, rendered muted.
    private(set) var lastReport: String?

    /// 13i-c U3: the book's STATE doors (Finish/Reopen · Seal…/Unseal ·
    /// Own Its Notes…/Stop Owning) — the shared brain the settings sheet
    /// also holds one of; the shelf presents its confirms.
    @ObservationIgnored let stateDoors: BookStateDoors
    /// 13i-c U4 (§4 row 17): the row drop's ownership CHOICE — the one shared
    /// road; the shelf presents its sheet.
    @ObservationIgnored let membershipDoors: MembershipDoors

    init(session: AppSession) {
        self.session = session
        self.stateDoors = BookStateDoors(session: session)
        self.membershipDoors = MembershipDoors(session: session)
    }

    /// The observed snapshot (a struct — the observe seam wants Equatable;
    /// nonisolated: it crosses off the main actor inside the observation).
    nonisolated struct ShelfSnapshot: Equatable, Sendable {
        var books: [Queries.ShelfBook]
        var pins: [String]
    }

    /// The held half: books + pins (both tiny).
    func start() async {
        do {
            for try await value in session.database.observe({ db in
                ShelfSnapshot(
                    books: try Queries.bookshelf(db),
                    pins: try Queries.shelfPins(db))
            }) {
                books = value.books
                pins = value.pins
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The one-shot half: word counts + the tags column (refresh on
    /// appearance and after membership edits — a deliberate fetch, never a
    /// held observation).
    func refreshAggregates() async {
        do {
            let (words, tags, rules) = try await session.database.read { db in
                (try Queries.bookWordCounts(db), try Queries.shelfBookTags(db),
                 try Queries.ruleTagPaths(db))
            }
            wordCounts = words
            bookTags = tags
            ruleTags = rules
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Shelf order (presentation, pinned by test): pinned books first in
    /// pin order (R38), then journal-profile books (the journal lives on
    /// the shelf), then the rest by name.
    var orderedBooks: [Queries.ShelfBook] {
        Self.ordered(books: books, pins: pins)
    }

    /// 13u1 UNIT 1 (the sweep's P40): the RULE moved to
    /// `Shared/ShelfOrder.swift` — the phone carried a byte-identical copy.
    /// A forwarder, so every Mac caller and pin reads as it did.
    nonisolated static func ordered(
        books: [Queries.ShelfBook], pins: [String]
    ) -> [Queries.ShelfBook] {
        ShelfOrder.ordered(books: books, pins: pins)
    }

    /// The ls-line's numbers ("~/shelf · 6 books · 2 finished").
    var finishedCount: Int { books.filter(\.reading.locked).count }

    /// The tags column's content for one book: a smart book shows its own
    /// query tags (the spec IS its identity); a curated book shows its
    /// member posts' most-applied paths (the core aggregate).
    func tagsColumn(for book: Queries.ShelfBook) -> [String] {
        // 13u1 UNIT 1 (P40): the smart-book half is `ShelfOrder`'s now — the
        // phone asked the identical question of the identical spec.
        ShelfOrder.smartQueryTagPaths(of: book.reading, rulePaths: ruleTags)
            ?? bookTags[book.reading.id] ?? []
    }

    /// Bounded progress for the meta column ("62% of 10,000w" — the
    /// word-target face, R38's bounded thread).
    func progress(for book: Queries.ShelfBook) -> (percent: Int, target: Int)? {
        guard let target = book.reading.wordTarget, target > 0 else { return nil }
        let words = wordCounts[book.reading.id] ?? 0
        return (Int((Double(words) / Double(target) * 100).rounded()), target)
    }

    // MARK: - Actions

    // The bar's mint road lives in `QuickEntryModel.submit()` (13l's
    // extraction; 13u3 UNIT C's two-key rule rides it). A parallel
    // `quickEntry(_:)` mint survived here test-only until 13u3 — deleted
    // at the orchestrator's adjudication of UNIT C's hand-up: two mint
    // roads for one door is the forked-brains class, and every behaviour
    // its one test asserted is pinned on the live road (QuickEntryBarTests).

    func setPinned(_ readingID: String, pinned: Bool) async {
        await run { try $0.setShelfPinned(readingID, pinned: pinned) }
    }

    // (13i-c U3: `setFinished` — the shelf's own finish/reopen road — RETIRED
    // onto `stateDoors`, the ONE road the shelf menu and the settings sheet
    // share: Finish now asks when arrivals wait (§24), and a sealed book's
    // Reopen is not rendered at all (it refuses — Unseal is the door). Two
    // roads for one act is the forked-brains class.)

    func setWordTarget(_ readingID: String, target: Int?) async {
        await run { try $0.setReadingWordTarget(readingID, wordTarget: target) }
        await refreshAggregates()
    }

    func setMaxPosts(_ readingID: String, maxPosts: Int?) async {
        await run { try $0.setReadingMaxPosts(readingID, maxPosts: maxPosts) }
    }

    /// The re-designation door (round 2, MAJOR 2): point Today's Entry at
    /// a new daily journal book.
    func designateDailyJournal(_ readingID: String) async {
        await run { try $0.setDailyJournalBook(readingID) }
    }

    /// **BIND INTO A BOOK** (13i-b U3 — the sitting record §3, §14.6; the
    /// door 13c 2D shipped as "convert to a hand-shaped book"). The SAME row
    /// becomes the book (§19.6) and it keeps collecting. Reports what
    /// happened rather than going quiet: binding changes what a shelf row
    /// IS, so a silent success would be the least legible outcome here.
    ///
    /// No "(collecting)" sibling any more — the ruling's own clause ("the
    /// '(collecting)' offer dies"); its reason (the book stopped collecting)
    /// is gone, and the deliberate sibling road is `spawnBook` below.
    func bind(
        _ readingID: String, ownedNotes: Operations.BindOwnedNotes = .leaveOut
    ) async {
        do {
            let result = try await session.runner.run { ops in
                try ops.convertSmartReadingToCurated(readingID, ownedNotes: ownedNotes)
            }
            lastError = nil
            // 13i-c U3: the receipt names the owned-notes limb's outcome.
            lastReport = BindCopy.bound(
                result.reading.name, count: result.membershipIDs.count,
                copied: result.copied.count, leftOut: result.leftOut.count)
        } catch let error as OperationError {
            lastReport = nil
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastReport = nil
            lastError = String(describing: error)
        }
        await refreshAggregates()
    }

    /// **MAKE A BOOK FROM THIS GATHERING** (13i-b U3 — the spawn; the sitting
    /// record §3): a SIBLING book carrying the gathering's rule, in its wing,
    /// with intake on (a book with a rule IS a living book) and the auto-tag
    /// OFF (PROVISIONAL P-13ib-3 — the ruled auto-tag-on default belongs to a
    /// book born from a TAG, and a rule may be a tree with no one tag to flow
    /// out). `createReading`'s creation-time BACKFILL seats the current
    /// matches (birth = intent). The gathering is untouched.
    ///
    /// Composition, not a new operation: the duplicate-name guard (E13) and
    /// the mint ride ONE serialized runner closure, and the gathering's rule
    /// is read INSIDE it, so the copy is the rule as it stands at the act.
    /// Returns the new book's id.
    /// **The spawn's PREFILL** (13i-c — R-13ic-1 and her item (i)): the
    /// rule's POSITIVE tags (`RuleGrammar.positiveTagIDs` — never a tag the
    /// rule excludes, F-R1-2's letter), in tree order, each a LIVE tag of the
    /// gathering's wing (a dead reference would make an outflow a silent
    /// no-op from birth). ONE function: the spawn sheet prefills from it and
    /// a spawn with no chooser answer (`outflow: nil`) uses it.
    nonisolated static func spawnPrefill(_ db: Database, gathering: Reading) throws -> [String] {
        try RuleGrammar.positiveTagIDs(of: RuleGrammar.decode(gathering.querySpec))
            .filter { try Queries.tagIsLive(db, id: $0, wingID: gathering.wingId) }
    }

    /// 13i-c U3: `outflow` is the spawn sheet's CHOSEN set (her edit of the
    /// prefill — the spawn OFFERS the choice); nil = the prefill itself. A
    /// chosen id that died meanwhile is dropped at the act (the chooser's
    /// own rule), never written as a silent no-op.
    @discardableResult
    func spawnBook(
        from gatheringID: String, named name: String, outflow chosen: [String]? = nil
    ) async -> String? {
        let database = session.database
        do {
            let (book, seated, ruleState) = try await session.runner.run {
                ops -> (Reading, Int, RuleGrammar.ReadResult) in
                guard let gathering = try database.read({
                    try Queries.reading($0, id: gatheringID)
                }) else { throw OperationError.readingNotFound(id: gatheringID) }
                guard gathering.kind == .gathering else {
                    throw OperationError.wrongReadingKind(id: gatheringID, expected: .gathering)
                }
                try ops.assertBookNameIsFree(name)
                // Ladder F-R1-3's gate, carried whole into the receipt's
                // vocabulary at round 2 (NEW-R2-1): the receipt speaks the
                // same THREE-STATE rule reading as the sheet — only a
                // READABLE rule collects (P-13ib-5), and the malformed cell
                // must not name Edit Rule (the editor refuses a malformed
                // rule by design).
                let ruleState = RuleGrammar.read(gathering.querySpec)
                // 13i-c (R-13ic-1 — her closing-sitting outflow ruling,
                // refining the 13i-b morning one): the spawn's outflow is
                // the rule's POSITIVE tags — every one of them (several are
                // legal), never a tag the rule excludes (F-R1-2's letter
                // kept inside `positiveTagIDs`). The view model adds only the
                // liveness fact: a dead reference would make an outflow a
                // silent no-op from birth, so it is dropped. (U3 lets her
                // EDIT this prefill in the spawn sheet before the mint.)
                let outflow = try database.read { db in
                    try chosen.map { ids in
                        try ids.filter { try Queries.tagIsLive(db, id: $0, wingID: gathering.wingId) }
                    } ?? Self.spawnPrefill(db, gathering: gathering)
                }
                let book = try ops.createReading(
                    name: name, kind: .book,
                    querySpec: gathering.querySpec, wingId: gathering.wingId,
                    autoTagIDs: outflow)
                let seated = try database.read {
                    try Queries.assembleReading($0, readingID: book.id).count
                }
                return (book, seated, ruleState)
            }
            lastError = nil
            lastReport = BindCopy.spawned(book.name, count: seated, rule: ruleState)
            await refreshAggregates()
            return book.id
        } catch let error as OperationError {
            lastReport = nil
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastReport = nil
            lastError = String(describing: error)
        }
        return nil
    }

    /// Drag a post ONTO a book row (sitting 1: "drag posts onto a book").
    /// Tolerant of the already-in case — a drop is a gesture, not a form.
    /// R98 (batch 10): a SMART book accepts the drop BY TAGGING —
    /// apply-and-report; a filter tagging can't satisfy refuses
    /// descriptively (the op's reason reaches the shelf's status line).
    func addPost(_ postID: String, to readingID: String) async {
        do {
            let kind = books.first { $0.reading.id == readingID }?.reading.kind
            if kind == .gathering {
                let result = try await session.runner.run { ops in
                    try ops.collectPostIntoSmartReading(postID, into: readingID)
                }
                lastError = nil
                lastReport = result.alreadyMatched
                    ? "Already collected — it matches this book's filter."
                    : "Added by tagging \(result.appliedTagPaths.map { "#\($0)" }.joined(separator: " ")) — smart books collect by filter."
            } else {
                // 13i-c U4 (§4 row 17): the one membership road — an
                // ownership refusal OPENS the choice sheet (P-2).
                try await membershipDoors.addOrOffer(postID, to: readingID)
                lastError = nil
            }
        } catch let error as OperationError {
            if case .alreadyInReading = error { return }
            if case .smartFilterUnsatisfiable(_, let reason) = error {
                lastError = "That book can't take this note: \(reason)"
            } else {
                lastError = ReadingsViewModel.message(error)
            }
        } catch {
            lastError = String(describing: error)
        }
        await refreshAggregates()
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
