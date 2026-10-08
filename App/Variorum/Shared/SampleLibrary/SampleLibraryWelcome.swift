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
//  ── 13s-b U1b — THE SEED RESHAPE (R-13s-5/26/27/37; her launch list,
//  verbatim: *"I think it's field guide, sherlock holmes, and a starred
//  notes empty gathering. quicknotes and journal are created at first
//  mint."*) ──────────────────────────────────────────────────────────────
//  The arrangement no longer MINTS the classics gathering or the seeded
//  quicknote — both left the fresh seed (with Encryption Explained and,
//  since 17y, Jekyll). What survives of #166(b)'s lesson: Sherlock still
//  OWNS its notes and the classic books' shipped notes still wear
//  #classics (so the classics GATHERING, now behind its own Help ▸ Restore
//  door — U1b piece 3 — shows them the moment it is made). The shelving
//  step keeps every seeded name in its vocabulary, so a RESTORED book or
//  gathering still lands on Welcome. The reserved quicknote identities
//  below stay for the installed base: stores born before this build carry
//  the seeded quicknote, and the furniture fold still folds it.
//
//  ── ONE BRAIN, OCCASIONS PER PLATFORM (the seeder's own grammar) ────────
//  `arrange` is the whole arrangement, idempotent, in ONE runner turn on the
//  QUIET facade (furniture never lands on her structural-undo stack — the
//  tutorial's MINOR-D1), every write an operation. WHEN it runs is the
//  caller's: the Mac runs it at a FRESH store's birth (`arrangeAtLaunch` —
//  only when this launch's Sherlock seed minted every story; since 17y
//  B-SEED the Mac seeds its field guide on that same road first, through
//  `beforeArranging`, so Welcome holds the guide at first open) and from every
//  RESTORE door (Help ▸ Restore Tutorial, the tutorial's open door when it
//  seeds the guide, Help ▸ Restore for each seeded book). An existing store
//  is never arranged silently: its launch marks the decision `declined` and
//  writes nothing. The phone's occasions are untouched (the mobile catch-up
//  calls this same brain — recorded in the U7 RECORD).
//
//  ── #classics — THE RULED LETTER (F-U7-1 RULED; the U7 continuation) ────
//  "Both tagged #classics": every SHIPPED note of both classic books wears the
//  tag at `SampleLibrarySeeder.classicsTagPath`, and the classics gathering is
//  made from that ONE tag. The sync dedupe's pristine classifier skips
//  applications of that declared SEED path (the architect's `Sync/` half,
//  17aa1113 — `SampleLibraryDedupeFacts.seedTagPaths`), so a seeded Sherlock
//  still reads PRISTINE and two fresh devices still converge on one copy.
//  Both sides read the same constant, so the skip and the seed's own act can
//  never drift. (P-13id-U7-1's two-book-tag stand-in is superseded.)
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

    /// The seeded quicknote's reserved title. **The MINT is retired (13s-b
    /// U1b — R-13s-5/37: the seeded quick note left the fresh seed); the
    /// identity stays** for the installed base: stores born before this
    /// build carry the note, and the furniture fold's facts still name it
    /// so two old copies keep folding.
    static let quicknoteTitle = "a first quick note"

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

    /// The classics gathering's rule — the ONE seed tag (the ruled letter).
    static func classicsRule(classicsTagID: String) -> RuleTerm {
        .tag(classicsTagID)
    }

    /// The books whose SHIPPED notes wear `#classics` (her §7 triad: Sherlock
    /// owned, Jekyll plain, both tagged).
    static let classicBooks: [SampleLibrarySeeder.Book] = [.sherlock, .jekyllAndHyde]

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
        /// How many shipped classic notes THIS arrangement tagged `#classics`.
        var taggedClassics: Int
        /// The seeded readings this arrangement put onto Welcome now (they
        /// were unshelved); a book filed elsewhere is never moved.
        var shelved: [String]
        // (The classics-gathering and quicknote mint fields left with their
        // mints — 13s-b U1b: the arrangement no longer makes either.)

        /// Whether anything at all was written — a door that did nothing
        /// speaks a refusal (§12's message kinds), one that did a receipt.
        var didAnything: Bool {
            welcome.minted || sherlock == .owned || taggedClassics > 0
                || !shelved.isEmpty
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

        // (3) #classics — THE RULED LETTER. Every SHIPPED note of each classic
        // book in Home (a live member wearing the book's reserved tag — the
        // seed tags every note it ships; a note she added does not) wears the
        // tag at `classicsTagPath` (Home's live one adopted, else minted).
        // Applying is an applying act like any other (intake hears it); the
        // dedupe classifier skips this declared seed path (17aa1113).
        let tags = try database.read { db in try Queries.allTags(db, wingID: "") }
        var classicsTagID = tags.first { $0.path == SampleLibrarySeeder.classicsTagPath }?.id
        var taggedClassics = 0
        let classicHomeBooks = try classicBooks.flatMap { book in
            try homeReadings(database, named: book.name).filter { $0.kind == .book }
                .map { (reading: $0, reservedTagID: tags.first { $0.path == book.tagName }?.id) }
        }
        if !classicHomeBooks.isEmpty, classicsTagID == nil {
            classicsTagID = try ops.createTag(
                name: SampleLibrarySeeder.classicsTagPath, wingID: "").id
        }
        if let classicsTagID {
            for (reading, reservedTagID) in classicHomeBooks {
                guard let reservedTagID else { continue }
                let untagged = try database.read { db in
                    try String.fetchAll(
                        db,
                        sql: """
                            SELECT rp.post_id FROM reading_post rp
                            JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                            WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                              AND rp.status = 'member'
                              AND EXISTS (SELECT 1 FROM post_tag pt WHERE pt.post_id = rp.post_id
                                          AND pt.tag_id = ? AND pt.deleted_at IS NULL)
                              AND NOT EXISTS (SELECT 1 FROM post_tag pt WHERE pt.post_id = rp.post_id
                                              AND pt.tag_id = ? AND pt.deleted_at IS NULL)
                            ORDER BY rp.position, rp.id
                            """,
                        arguments: [reading.id, reservedTagID, classicsTagID])
                }
                for postID in untagged {
                    _ = try ops.applyTag(classicsTagID, toPost: postID)
                    taggedClassics += 1
                }
            }
        }

        // (3b — RETIRED, 13s-b U1b): the classics GATHERING left the fresh
        // seed (R-13s-5/37). Its door is Help ▸ Restore (U1b piece 3 —
        // `ShellActions.restoreClassicsGathering`, which adopts a live one
        // or mints on Welcome); the tagging above stays, so the gathering
        // shows the shipped classics the moment it is made.

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

        // (5 — RETIRED, 13s-b U1b): the seeded quicknote left the fresh seed
        // with the Quicknotes gathering its filing minted (R-13s-5/37, her
        // word: "quicknotes and journal are created at first mint"). The
        // reserved title above stays the installed base's fold identity.

        return Arrangement(
            welcome: welcome, sherlock: sherlock,
            taggedClassics: taggedClassics, shelved: shelved)
    }

    /// Live HOME readings (a dangling wing reads as Home — `wingScope`), by
    /// EXACT name when one is given (the seeders' discovery rule).
    private static func homeReadings(_ database: AppDatabase, named name: String?) throws -> [Reading] {
        try database.read { db in
            try Queries.readings(db, wingID: "").filter { name == nil || $0.name == name }
        }
    }

    // MARK: - The classics gathering's restore brain (13s-b U1b)

    /// **ADOPT-OR-MINT the classics gathering** — the retired arrangement
    /// step 3b's exact shape, now the Help ▸ Restore door's brain (R-13s-37,
    /// her word: "classics restorable"; the gathering left the fresh seed at
    /// R-13s-5). At operations level so the door's runner turn and any
    /// fixture drive ONE body: ensure Welcome, ensure the `#classics` tag,
    /// adopt a live Home gathering wearing the rule or the reserved name,
    /// else mint one ON Welcome. Returns the gathering and whether THIS
    /// call minted it.
    static func restoreClassicsGathering(ops: Operations) throws -> (id: String, minted: Bool) {
        @Dependency(\.database) var database
        let welcome = try ops.ensureWelcomeShelf(wingID: "")
        let tags = try database.read { db in try Queries.allTags(db, wingID: "") }
        let tagID = try tags.first { $0.path == SampleLibrarySeeder.classicsTagPath }?.id
            ?? ops.createTag(name: SampleLibrarySeeder.classicsTagPath, wingID: "").id
        let rule = classicsRule(classicsTagID: tagID)
        if let present = try homeReadings(database, named: nil).first(where: { reading in
            reading.kind == .gathering
                && (RuleGrammar.read(reading.querySpec) == .rule(rule)
                    || BookNaming.sameName(reading.name, classicsGatheringName))
        }) {
            return (present.id, false)
        }
        let gathering = try ops.createReading(
            name: classicsGatheringName, kind: .gathering, profile: "collection",
            sortField: .createdAt, sortDir: .asc,
            querySpec: try RuleGrammar.encode(rule), wingId: "",
            shelfId: welcome.shelf.id)
        return (gathering.id, true)
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
    ///
    /// **`beforeArranging`** (17y B-SEED — item (q)): the platform's OWN
    /// seeded furniture that must exist before the arrangement shelves it —
    /// the Mac's field guide (Mac-only content; the phone never calls this).
    /// It runs on the arrange-now road only (this birth, or a `pending`
    /// resume of one), AFTER the decision and BEFORE `arrange`, so it
    /// inherits every guarantee of that decision — the sync gate behind
    /// Sherlock's outcome, and never on an existing store (`declined` /
    /// `done` never reach it) — and the arrangement's shelving step puts what
    /// it made on Welcome. Furniture: it answers nothing and must never
    /// throw; its own outcome is its own log line.
    @MainActor
    @discardableResult
    static func arrangeAtLaunch(
        session: AppSession,
        sherlock outcome: SampleLibrarySeeder.Outcome,
        storeVariant: AppDatabase.StoreVariant = .real,
        guideName: String?,
        beforeArranging: (@MainActor () async -> Void)? = nil,
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
        await beforeArranging?()
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
