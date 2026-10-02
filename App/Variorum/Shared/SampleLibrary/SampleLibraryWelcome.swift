//
//  SampleLibraryWelcome.swift
//  Shared (Variorum + VariorumMobile)
//
//  13i-d U7 — THE WELCOME ARRANGEMENT: the Welcome shelf and the seeded
//  classics lesson (the sitting record §7, §17(a)/(b), §19.3; QUESTIONS
//  #166(b) ruled in; the 13i-d plan's U7 brief).
//
//  Her two rulings this file builds, verbatim-faithful:
//    · THE WELCOME SHELF (§7, her name: *"it's literally a welcome to the
//      app, designed to make you feel comfortable"*) holds the SEEDED content
//      only (§19) — the field guide, the Sherlock and Jekyll books,
//      *Encryption Explained* and the classics gathering. Journal and
//      Quicknotes start UNSHELVED: they are her working objects, not samples
//      (§19.3, ratified §24).
//    · THE CLASSICS LESSON (#166(b), "RULED IN"): Sherlock OWNED · Jekyll
//      plain · a seeded classics GATHERING on Welcome (one bookcase row, zero
//      new notes — "the whole ladder visible at first launch, the owned badge
//      teaching itself") · ONE seeded quicknote, so the Quicknotes gathering
//      is a live example.
//
//  ── ONE BRAIN, OCCASIONS PER PLATFORM (the seeder's own grammar) ────────
//  `arrange` is the whole arrangement, idempotent, in ONE runner turn on the
//  QUIET facade (furniture never lands on her structural-undo stack — the
//  tutorial's MINOR-D1), every write an operation. WHEN it runs is the
//  caller's: the Mac runs it at a FRESH store's birth (`arrangeAtLaunch` —
//  only when this launch's Sherlock seed minted every story) and from every
//  RESTORE door (Help ▸ Restore Tutorial, the tutorial's open door when it
//  seeds the guide, Help ▸ Restore for each seeded book). An existing store
//  is never arranged silently: its launch marks the decision `declined` and
//  writes nothing. The phone's occasions are untouched (the mobile catch-up
//  calls this same brain — recorded in the U7 RECORD).
//
//  ── THE CLASSICS GATHERING'S RULE (PROVISIONAL P-13id-U7-1 — F-U7-1) ────
//  The ruled letter is "both tagged #classics". Applying ANY tag but the
//  reserved one to a Sherlock note makes the sync dedupe's pristine
//  classifier (`Sync/SampleLibraryDedupe.swift`) read the copy EDITED, so two
//  fresh devices would keep two Sherlock books forever. Until the architect
//  rules the `Sync/` half (Fable work), the gathering is made from the two
//  books' OWN reserved tags — `#sherlock holmes ∨ #jekyll and hyde` — and no
//  new application touches a judged note. Flipping to `#classics` is this
//  rule plus one tagging step.
//
//  ── SHERLOCK OWNED, FORK-FREE ONLY (PROVISIONAL P-13id-U7-3) ────────────
//  `setReadingOwned` FORKS a member that also lives in another book. A copy
//  "only ever happens because you asked for one" (lesson 2), so the
//  arrangement owns Sherlock only when that forks nothing and the book is
//  open; otherwise it leaves Sherlock plain and says so in its result.
//

import Dependencies
import Foundation
import GRDB
import OSLog
import VariorumCore

nonisolated enum SampleLibraryWelcome {
    // MARK: - Reserved identities

    /// The seeded gathering's name (lowercase — the shelf's quiet idiom, the
    /// "starred notes" / "the field guide" precedent). Identity is its RULE
    /// or this name (E13's sense), the starred gathering's signature.
    static let classicsGatheringName = "classics"

    /// The seeded quicknote's reserved title — how a restore finds it (a quick
    /// note is untitled by default; a seeded one wears a name so the seeder
    /// can recognise its own, the seeders' identity convention).
    static let quicknoteTitle = "a first quick note"

    /// The seeded quicknote's text. ONE paragraph, so it mints one block.
    /// The chord and the gathering's words are tied to their constants by the
    /// tutorial pins (`TutorialBooksChapterTests`) — written plainly here.
    static let quicknoteText =
        "This is a quick note \u{2014} the kind \u{2318}\u{21E7}N catches from anywhere, even "
        + "from inside another app. Filing one tags it \u{201C}quicknote\u{201D}, and the "
        + "Quicknotes gathering on your Bookcase shows it. Take the tag off and it leaves "
        + "Quicknotes for the Pool."

    /// The seeded books the Welcome shelf holds (her §19 list), by their
    /// reserved names — the field guide is the caller's (it is Mac-only
    /// today; the phone's guide is its own seeder's).
    static func seededBookNames(guideName: String?) -> [String] {
        [guideName,
         SampleLibrarySeeder.Book.sherlock.name,
         SampleLibrarySeeder.Book.jekyllAndHyde.name,
         SampleLibrarySeeder.Book.encryptionExplained.name,
         classicsGatheringName].compactMap { $0 }
    }

    /// The classics gathering's rule over the two books' reserved tag ids
    /// (P-13id-U7-1). Sherlock first, the Collecting sentence's order.
    static func classicsRule(sherlockTagID: String, jekyllTagID: String) -> RuleTerm {
        .or([.tag(sherlockTagID), .tag(jekyllTagID)])
    }

    // MARK: - What one arrangement did

    enum SherlockOwnership: Equatable, Sendable {
        /// Owned now — every member was Sherlock's alone.
        case owned
        /// Already owned (a second arrangement, or her own door).
        case alreadyOwned
        /// Left plain: owning would have FORKED this many shared members.
        case leftPlainShared(Int)
        /// Left plain: the book is finished or sealed (owning refuses there).
        case leftPlainFrozen
        /// No live Sherlock book in Home (deleted, renamed, or moved away).
        case absent
    }

    struct Arrangement: Equatable, Sendable {
        /// The Welcome shelf — adopted or minted.
        var welcome: Operations.WelcomeShelfEnsure
        var sherlock: SherlockOwnership
        /// The classics gathering's id (nil = not minted: a book's reserved
        /// tag is missing in Home), and whether THIS arrangement minted it.
        var classicsID: String?
        var mintedClassics: Bool
        /// The seeded readings this arrangement put onto Welcome now (they
        /// were unshelved); a book filed elsewhere is never moved.
        var shelved: [String]
        /// The seeded quicknote's id, and whether THIS arrangement minted it.
        var quicknoteID: String?
        var mintedQuicknote: Bool

        /// Whether anything at all was written — a door that did nothing
        /// speaks a refusal (§12's message kinds), one that did a receipt.
        var didAnything: Bool {
            welcome.minted || sherlock == .owned || mintedClassics
                || !shelved.isEmpty || mintedQuicknote
        }
    }

    // MARK: - The arrangement

    /// **THE WELCOME ARRANGEMENT**, ONE runner turn on the quiet facade.
    @MainActor
    @discardableResult
    static func arrange(session: AppSession, guideName: String?) async throws -> Arrangement {
        try await session.runner.run { _ in
            try arrange(ops: Operations(undoStack: nil), guideName: guideName)
        }
    }

    /// The body, at operations level (a pin drives it directly). Each step
    /// re-reads what it acts on; every write is an operation.
    static func arrange(ops: Operations, guideName: String?) throws -> Arrangement {
        // The SAME ambient database the facade writes through (Operations
        // reads `\.database` and nothing else) — the reads below see its writes.
        @Dependency(\.database) var database
        // (1) Welcome — adopted (the R5 keeper's keep) or minted.
        let welcome = try ops.ensureWelcomeShelf(wingID: "")

        // (2) Sherlock OWNED — fork-free only (P-13id-U7-3).
        let sherlockName = SampleLibrarySeeder.Book.sherlock.name
        let sherlockBooks = try homeReadings(database, named: sherlockName).filter { $0.kind == .book }
        var sherlock = SherlockOwnership.absent
        for book in sherlockBooks {
            if book.owned { sherlock = .alreadyOwned; continue }
            if book.locked || book.sealedAt != nil { sherlock = .leftPlainFrozen; continue }
            let shared = try database.read { db in
                try Queries.sharedMembers(db, readingID: book.id).count
            }
            if shared > 0 { sherlock = .leftPlainShared(shared); continue }
            _ = try ops.setReadingOwned(book.id, owned: true)
            sherlock = .owned
        }

        // (3) The classics gathering — adopted, else minted ON Welcome when
        // both books' reserved tags are live in Home.
        let tags = try database.read { db in try Queries.allTags(db, wingID: "") }
        let sherlockTag = tags.first { $0.path == SampleLibrarySeeder.Book.sherlock.tagName }
        let jekyllTag = tags.first { $0.path == SampleLibrarySeeder.Book.jekyllAndHyde.tagName }
        var classicsID: String?
        var mintedClassics = false
        let rule = (sherlockTag?.id).flatMap { sherlockID in
            (jekyllTag?.id).map { classicsRule(sherlockTagID: sherlockID, jekyllTagID: $0) }
        }
        if let present = try homeReadings(database, named: nil).first(where: { reading in
            reading.kind == .gathering
                && ((rule.map { RuleGrammar.read(reading.querySpec) == .rule($0) } ?? false)
                    || BookNaming.sameName(reading.name, classicsGatheringName))
        }) {
            classicsID = present.id
        } else if let rule {
            // Publication order: Jekyll (1886) beside Sherlock (1892) — the
            // seeds' own clocks make created-at the honest "side by side".
            let gathering = try ops.createReading(
                name: classicsGatheringName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .asc,
                querySpec: try RuleGrammar.encode(rule), wingId: "",
                shelfId: welcome.shelf.id)
            classicsID = gathering.id
            mintedClassics = true
        }

        // (4) Shelving — every live HOME seeded reading that is UNSHELVED
        // (nil or dangling) goes onto Welcome; hers on another shelf stay.
        let liveShelves = Set(try database.read { db in
            try Queries.shelves(db, wingID: "").map(\.id)
        })
        var shelved: [String] = []
        for name in seededBookNames(guideName: guideName) {
            for reading in try homeReadings(database, named: name) {
                if let shelfID = reading.shelfId, liveShelves.contains(shelfID) { continue }
                try ops.setReadingShelf(reading.id, shelf: welcome.shelf.id)
                shelved.append(reading.id)
            }
        }

        // (5) The ONE seeded quicknote — the quick note's own road (the pad's
        // `QuickNoteFiler.file`): an ordinary bookless note in HOME, filed so
        // it wears `quicknote` and Quicknotes shows it (Quicknotes is minted
        // here the ordinary way when a store never filed one: unshelved,
        // starred — §19.3, R-13id-5).
        var quicknoteID = try database.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT id FROM container
                    WHERE kind = 'post' AND deleted_at IS NULL AND title = ?
                      AND \(Queries.wingScope(column: "wing_id", wingID: "").sql)
                    ORDER BY id LIMIT 1
                    """,
                arguments: [quicknoteTitle])
        }
        var mintedQuicknote = false
        if quicknoteID == nil {
            let note = try ops.importPost(
                title: quicknoteTitle, text: quicknoteText, undoLabel: "Quick Note",
                segmentation: .oneBlock, wingId: "")
            _ = ops.fileAsQuicknote(note.container.id)
            quicknoteID = note.container.id
            mintedQuicknote = true
        }

        return Arrangement(
            welcome: welcome, sherlock: sherlock, classicsID: classicsID,
            mintedClassics: mintedClassics, shelved: shelved,
            quicknoteID: quicknoteID, mintedQuicknote: mintedQuicknote)
    }

    /// Live HOME readings (a dangling wing reads as Home — `wingScope`), by
    /// EXACT name when one is given (the seeders' discovery rule).
    private static func homeReadings(_ database: AppDatabase, named name: String?) throws -> [Reading] {
        try database.read { db in
            try Queries.readings(db, wingID: "").filter { name == nil || $0.name == name }
        }
    }

    // MARK: - The launch occasion (fresh stores at birth)

    /// What a launch decided. Recorded, never surfaced (furniture is silent).
    enum LaunchOutcome: Equatable {
        /// This device already settled this store (`done` or `declined`).
        case alreadySettled
        /// Not a fresh store — the library was already here (or she deleted
        /// it), so NOTHING is written and the decision is marked. The restore
        /// doors are the road for an existing store.
        case declined
        /// Not decidable yet (an account store awaiting its first clean round,
        /// or a refused seed): not marked; the next launch asks again.
        case undecided
        case arranged(Arrangement)
        /// The arrangement threw; the mark stays `pending`, so the next launch
        /// resumes it.
        case failed(String)
    }

    /// The device mark, per store variant like every seeded mark (one build
    /// can open either store): absent · `pending` · `done` · `declined`.
    static func launchMarkKey(for variant: AppDatabase.StoreVariant) -> String {
        "SampleLibraryWelcome.\(variant.rawValue)"
    }

    private static let log = Logger(subsystem: "io.lduarte.Variorum", category: "sample-library")

    /// **A FRESH STORE'S BIRTH.** The store is fresh when THIS launch's
    /// Sherlock seed minted every story — the sample library was born here
    /// now. Marked `pending` before arranging (a window closed mid-arrange
    /// resumes at the next launch), `done` after. Any other Sherlock outcome
    /// on an undecided store marks `declined` and writes nothing.
    @MainActor
    @discardableResult
    static func arrangeAtLaunch(
        session: AppSession,
        sherlock outcome: SampleLibrarySeeder.Outcome,
        storeVariant: AppDatabase.StoreVariant = .real,
        guideName: String?,
        loadMark: (() -> String?)? = nil,
        saveMark: ((String) -> Void)? = nil
    ) async -> LaunchOutcome {
        let key = launchMarkKey(for: storeVariant)
        let load = loadMark ?? { UserDefaults.standard.string(forKey: key) }
        let save = saveMark ?? { UserDefaults.standard.set($0, forKey: key) }
        let decided = await decide(mark: load(), sherlock: outcome, save: save)
        guard decided == nil else {
            log.notice("welcome arrangement: \(String(describing: decided!), privacy: .public)")
            return decided!
        }
        do {
            let arranged = try await arrange(session: session, guideName: guideName)
            save("done")
            log.notice("welcome arrangement: arranged")
            return .arranged(arranged)
        } catch {
            log.error("welcome arrangement failed: \(String(describing: error), privacy: .public)")
            return .failed(String(describing: error))
        }
    }

    /// nil = arrange now (the mark was `pending`, or this launch found the
    /// store fresh and marked it `pending`); otherwise the decided outcome.
    @MainActor
    private static func decide(
        mark: String?, sherlock outcome: SampleLibrarySeeder.Outcome, save: (String) -> Void
    ) async -> LaunchOutcome? {
        switch mark {
        case "done", "declined": return .alreadySettled
        case "pending": return nil
        default: break
        }
        switch outcome {
        case .seeded(_, let minted):
            let expected: Int
            do {
                let stories = try await Task.detached(priority: .utility) {
                    try SampleLibrarySeeder.loadStories(for: .sherlock)
                }.value
                expected = SampleLibrarySeeder.expectedTitles(for: .sherlock, stories: stories).count
            } catch {
                return .undecided
            }
            guard expected > 0, minted == expected else {
                save("declined")
                return .declined
            }
            save("pending")
            return nil
        case .awaitingFirstSync, .refused:
            return .undecided
        case .alreadySeeded, .alreadyPresent, .deletedByTheReader:
            save("declined")
            return .declined
        }
    }
}
