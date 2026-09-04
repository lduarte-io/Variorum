//
//  SampleLibrarySeeder.swift
//  Shared (Variorum + VariorumMobile)
//
//  Pre-13u round, Act 3 — THE SAMPLE LIBRARY: *The Adventures of Sherlock
//  Holmes* as a real book of the app's own objects, one short story per
//  note, one chapter per story.
//
//  ── HOISTED TO `Shared/` AT ACT 0 (2026-08-31 — R-pre13u-8) ───────────
//  Her ruling gave the PHONE the same library: *"some people will be phone
//  only users and they should get to experience it."* MobileSoul §3's rule
//  is that a capability built Mac-side with its brain in app-local code is
//  a parity defect at birth — so the seeder MOVED rather than being copied,
//  file and resource together, into the `Shared/` synchronized group both
//  app targets already carry. The type keeps its name, so **every Mac pin
//  rides the hoist unmodified** (the 3C parity proof: a zero-test-edit Mac
//  suite is the evidence that an address moved and behaviour did not).
//
//  What is per-platform, and deliberately NOT here: WHEN the seed runs.
//  The Mac seeds from the window's `.task` after `start()` (her Act 3
//  ruling — every reader's store); the phone seeds at the FIRST WRITE and
//  only when the store belongs to no account (R-pre13u-1 + R-pre13u-8,
//  `MobileFirstWriteFurniture`). Same brain, two occasions — §4's grammar.
//
//  Her ask and her rulings (2026-08-30, recorded in
//  `notes/plans/pre-13u-round.md` § Act 3):
//
//    · IT SHIPS IN EVERY READER'S STORE — default-on, not opt-in. Her
//      reasoning: *"it'll only be about 10 notes, fewer than the tutorial,
//      and it can be tagged sherlock holmes. it's easy to delete if they
//      want but it makes the power of the app clear in a way that the
//      tutorial just doesn't — one is made to be digestible, the other is
//      meant to show scale."*
//    · TAGGED `sherlock holmes` — so the whole library is findable and
//      removable as a set.
//    · The Gutenberg boilerplate is stripped and the public-domain text
//      ships with a plain attribution (the front-matter chapter below).
//    · The Pool — bookless notes — must stay BLANK on a fresh store: every
//      seeded story is a member of the book. `SampleLibraryTests` pins it.
//
//  ── WHY THIS IS NOT THE TUTORIAL, AND NOT THE STARTER JOURNAL ─────────
//  It borrows from both, deliberately:
//
//    · From `TutorialSeeder`: reserved identities (a book name and a tag),
//      discovery-as-the-guard, and the QUIET operations facade
//      (`Operations(undoStack: nil)`) — furniture the reader never placed
//      must never put an inverse on her structural-undo stack. `importPost`
//      registers one entry per call, so twelve stories would otherwise make
//      a new reader's first ⌥⌘Z do something baffling.
//    · From `MobileStarterJournal`: a per-device, per-store-variant mark,
//      and the SYNC GATE — a store that belongs to an ACCOUNT is not judged
//      until sync has had its say, because a second machine that seeds
//      before its first pull mints a duplicate library that then propagates.
//      *(Dated correction, 2026-08-31 — Act 0: the starter journal's own
//      version of that gate is GONE. R-pre13u-1 moved its occasion to the
//      first WRITE, where the account question is a fact, and deleted the
//      bounded wait; this file keeps the wait because ITS occasion is still
//      the Mac's launch, which has the race the wait narrows. The phone
//      never spends it — `MobileFirstWriteFurniture` answers the account
//      question once and hands this seeder `.unowned`.)*
//
//  It differs from both in one respect that is deliberate: there is NO
//  virgin-store guard. The sample library is not first-launch furniture for
//  new users only — her ruling is *every* reader's store, so a store that
//  already holds her writing gets it at the next launch too.
//
//  ── DELETION IS FINAL, AND THAT IS THE POINT ──────────────────────────
//  The device mark is set only after a COMPLETE seed. Delete the book (or
//  the notes, or the tag) and nothing puts it back: the mark short-circuits
//  before discovery ever runs. This is `MobileStarterJournal`'s ruled shape
//  — *"if they delete that journal book or archive it, it just doesn't
//  appear at all"* — applied to the same class of object. There is
//  deliberately no restore door; whether one should exist is a product
//  question, recorded for the author rather than invented here.
//
//  **The honest residual, recorded rather than papered over** (added
//  2026-08-31, the midpoint review's m5 — the `MobileStarterJournal`
//  header's own precedent, and the same mechanism): "deletion is final"
//  is only as durable as the DEVICE MARK, and the mark is `UserDefaults`.
//  Three ordinary things lose it — deleting and reinstalling the app, a
//  store restored onto a new machine (13x's road: the store comes back,
//  this device's defaults do not), and clearing the app's defaults — and
//  a lost mark makes the store look unseeded. Discovery then covers the
//  case where the library is still THERE (the reserved book name and tag
//  are found, so nothing is re-minted), but it cannot cover the case the
//  rule is actually about: a reader who DELETED the library, or renamed
//  the book, gets it re-minted, because a deleted book and a never-seeded
//  store are the same local reading.
//
//  Closing it needs a marker that travels with the STORE rather than the
//  device — the `setting` table — and `upsertSetting` has no public write
//  door from app code, which is exactly the blocker `MobileStarterJournal`
//  records for its own version of this. Narrow, non-destructive, named.
//  *(Two devices that each seed are a different problem with a different
//  answer already built: the R-pre13u-8 pristine-copy dedupe repair in
//  `Sources/VariorumCore/Sync/`.)*
//
//  ── RESUMABLE, BECAUSE THE SEED CAN BE CANCELLED ──────────────────────
//  On the Mac the seed runs from the window's `.task`, so closing the
//  window mid-seed cancels it; on the phone the occasion's task dies with
//  a lock or a session teardown. Discovery therefore reports WHICH story
//  titles are already in the book, and the seed mints only the missing
//  ones; the mark lands only when the whole set is present. A half-seeded
//  library heals itself at the next occasion instead of standing there
//  forever.
//
//  ── P2, AND THE FIRST-LAUNCH CRITICAL PATH ────────────────────────────
//  Every write goes through `session.runner` (the serial off-main executor)
//  and every story is its OWN runner turn, so autosave and anything else
//  the reader does can interleave between stories rather than queueing
//  behind the whole library. The 562 KB resource is parsed off the main
//  thread too. Nothing here is awaited before first paint: the call site
//  sits after `AppServices.start()` inside the window's own task.
//

import Dependencies
import Foundation
import GRDB
import OSLog
import VariorumCore

/// Anchors `Bundle(for:)` on this module, so the resource resolves in the
/// app AND under the app-hosted test bundle.
private final class SampleLibraryBundleAnchor {}

/// **What the bundled source says every note of this library should say.**
/// Built for R-pre13u-8's dedupe repair — see `SampleLibrarySeeder.manifest`
/// for the whole reasoning. Deliberately at FILE SCOPE rather than nested
/// inside the `@MainActor` seeder: it is a value that has to travel — read
/// inside a database closure off the main actor, handed to the sync
/// engine — and a nested type would inherit an isolation it has no use for.
/// `nonisolated` for the same reason: both app targets default to
/// MainActor isolation, and a manifest that could only be read on the main
/// actor could not be read where it is needed.
nonisolated struct SampleLibraryManifest: Sendable, Equatable {
    /// The book's reserved name — half of the identity predicate a repair
    /// uses to recognise a copy (`SampleLibrarySeeder.discover`'s own rule).
    var bookName: String
    /// The reserved tag path — the other half.
    var tagName: String
    /// note title → SHA-256 hex of the text the seed stores for it. Carries
    /// the front-matter note as well as the twelve stories: the attribution
    /// IS part of the shipped library.
    var noteHashes: [String: String]

    var titles: Set<String> { Set(noteHashes.keys) }

    /// True when this note is byte-identical to what shipped. A title the
    /// manifest does not know is NOT pristine — a note the reader added to
    /// the book is her own writing, and the whole point of the rule is that
    /// her writing is never the copy that gets retired.
    func isPristine(title: String, renderedText: String) -> Bool {
        guard let expected = noteHashes[title] else { return false }
        return expected == BridgeHash.body(renderedText)
    }
}

@MainActor
enum SampleLibrarySeeder {

    // MARK: - Reserved identities (how discovery finds its own objects)

    /// Lowercase like the tutorial's "the field guide" — the shelf's idiom.
    nonisolated static let bookName = "the adventures of sherlock holmes"
    /// Her word, exactly.
    nonisolated static let tagName = "sherlock holmes"
    /// The front-matter chapter carrying the source attribution (her
    /// Gutenberg ruling: strip the boilerplate, ship the attribution).
    nonisolated static let frontMatterChapter = "about this text"
    nonisolated static let frontMatterTitle = "About this book"
    /// The label the mint WOULD carry if it were undoable. It is not: the
    /// seed runs on the quiet facade (no undo stack) — the `TutorialSeeder`
    /// and `MobileStarterJournal` precedent.
    nonisolated static let undoLabel = "Sample Library"

    /// **The seed's OWN segmentation, named rather than inherited** (the
    /// pre-13u midpoint review's M1). The stories are hard-unwrapped into
    /// one line per paragraph by `notes/source/sherlock-extract.py`
    /// precisely so `.paragraph` mints one block per paragraph — 2,530 of
    /// them across the twelve — and that shape IS the point of the act:
    /// her ruling is that this library "makes the power of the app clear",
    /// which means real blocks, a real Blocks/Index/Outline listing, and
    /// autosaves proportional to a paragraph.
    ///
    /// Reading the reader's `default_segmentation` instead would have made
    /// the shipped library depend on a setting she can change: under the
    /// shipped "One block" option the whole 105k words seeded as thirteen
    /// giant blocks, with an autosave rewriting ~60 KB per keystroke
    /// inside a story. `TutorialSeeder` never had this exposure — it mints
    /// through `newBlock`, which takes no mode — so naming the mode here
    /// restores the property the precedent already had rather than
    /// inventing one. (The plan's build-shape line conflated "segments on
    /// entry" with "segments by paragraph"; it now carries a correction.)
    nonisolated static let segmentation: Segmentation = .paragraph

    /// **The library's own clock: 14 October 1892, the day *The Adventures
    /// of Sherlock Holmes* was published** (the pre-13u midpoint review's
    /// m6 — PROVISIONAL, the author's nod pending).
    ///
    /// The seed is default-on into EXISTING stores, so without this every
    /// story lands stamped NOW and thirteen Conan Doyle notes sit above her
    /// own recent writing in the Library and on the Timeline — on her real
    /// store, at the next launch of the refreshed build. Stamping them with
    /// the work's publication date sorts them where they belong (the bottom
    /// of every recency view) and reads honestly on a timeline, which is a
    /// better answer than a special case in the sort: the sort is right,
    /// the stamps were wrong.
    ///
    /// Legal by the model's own rules: wall-clock timestamps are DISPLAY
    /// data (SyncSpec §9 — sync's ordering authority is `server_seq`,
    /// never a clock), and the seed is a local mint of shipped content, so
    /// nothing downstream reads these stamps as evidence about when
    /// anything happened on a device.
    ///
    /// The alternative, if she prefers it: stamp at seed time and accept
    /// the displacement. One constant and one `withDependencies` scope
    /// change back.
    nonisolated static let publicationStamp = "1892-10-14T00:00:00.000Z"
    /// Parsed by the store's OWN canonical formatter, so the stamp the rows
    /// carry is byte-identical to the string above. The fallback can only
    /// fire if that formatter regresses, and it is deliberately also very
    /// old — the sort intent survives even then.
    nonisolated static let publicationDate =
        DateFormatter.variorumISO8601.date(from: publicationStamp)
            ?? Date(timeIntervalSince1970: 0)

    nonisolated static let attributionText = """
        \u{201C}The Adventures of Sherlock Holmes\u{201D} by Arthur Conan Doyle, first \
        published in 1892. The twelve stories are in the public domain.

        The text comes from Project Gutenberg\u{2019}s edition (eBook #1661), with \
        Project Gutenberg\u{2019}s own header and licence matter removed and the \
        hard line wrapping undone so each paragraph is one block.

        This library is here to show you the app at the size you will \
        actually work at: a real book, real chapters, and notes of eight to \
        ten thousand words that open at once. Every note is tagged \
        \u{201C}\(tagName)\u{201D} \u{2014} delete the book, or everything wearing that \
        tag, and it will not come back.
        """

    /// The bundled resource, derived from the raw Gutenberg download by
    /// `notes/source/sherlock-extract.py` (the recipe is in that script's
    /// header). `%%% <title>` lines separate the stories and are never
    /// stored; the app never parses the raw PG file.
    nonisolated static let resourceName = "SherlockAdventures"
    nonisolated static let storyDelimiter = "%%% "

    // MARK: - The text

    struct Story: Sendable, Equatable {
        let title: String
        let text: String
    }

    enum LoadError: Error, Equatable {
        case resourceMissing
        case noStories
    }

    /// Parses the bundled text. `nonisolated` so callers can run it off the
    /// main actor — it is ~0.5 MB of string work.
    nonisolated static func loadStories() throws -> [Story] {
        let bundle = Bundle(for: SampleLibraryBundleAnchor.self)
        guard let url = bundle.url(forResource: resourceName, withExtension: "txt"),
              let raw = try? String(contentsOf: url, encoding: .utf8)
        else { throw LoadError.resourceMissing }
        let stories = parse(raw)
        guard !stories.isEmpty else { throw LoadError.noStories }
        return stories
    }

    /// Split on the delimiter lines. Kept separate from the bundle read so
    /// a pin can drive it with a fixture.
    nonisolated static func parse(_ raw: String) -> [Story] {
        var stories: [Story] = []
        var title: String?
        var body: [Substring] = []
        func flush() {
            guard let title else { return }
            let text = body.joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty { stories.append(Story(title: title, text: text)) }
        }
        for line in raw.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.hasPrefix(storyDelimiter) {
                flush()
                title = String(line.dropFirst(storyDelimiter.count))
                    .trimmingCharacters(in: .whitespaces)
                body = []
            } else {
                body.append(line)
            }
        }
        flush()
        return stories
    }

    // MARK: - The manifest (the PRISTINE predicate's shared artifact)

    /// **The artifact R-pre13u-8's dedupe repair consults.** Once the phone
    /// can seed the library too, two devices can each correctly decide "no
    /// sample library exists yet" and both seed, and the pair meets under
    /// sync. Her ruled resolution needs one fact per note — *is this copy
    /// still exactly what shipped?* — because the rule turns on it: both
    /// pristine → deterministic keeper; one edited → the EDITED copy is
    /// kept; both edited → both survive. **An edited copy is never silently
    /// retired**, which is why the predicate is per-NOTE rather than
    /// per-book: a reader who rewrote one paragraph of one story has edited
    /// the library, and a book-level hash would have to be re-derived from
    /// the notes anyway.
    ///
    /// **Why the hash is `BridgeHash.body`** and not a new primitive: the
    /// repair runs inside `Sources/VariorumCore/Sync/`, which cannot see
    /// app-target code at all — so the two sides must agree on a recipe
    /// that BOTH can name. `BridgeHash.body` is public core (SHA-256 hex of
    /// the UTF-8 bytes; it WAS the retired bridge's change-detection recipe
    /// and lives on as the manifest recipe, `Domain/BridgeHash.swift`), so
    /// the engine side reads
    /// `BridgeHash.body(Queries.renderedText(db, containerID: id))` with
    /// nothing new imported and nothing duplicated.
    ///
    /// **The comparison is apples to apples by construction:** the seed
    /// mints through `importPost` in this seeder's OWN `segmentation` mode,
    /// whose bulk segmentation round-trips byte-for-byte through
    /// `Queries.renderedText` (its own documented contract, and
    /// `theManifestMatchesWhatTheSeedActuallyStores` pins it against the
    /// real bundled text rather than a fixture). Naming the mode is what
    /// makes that contract hold for every reader rather than for readers
    /// who left `default_segmentation` alone.
    ///
    /// Pure, so a pin can drive it with a fixture.
    nonisolated static func manifest(stories: [Story]) -> SampleLibraryManifest {
        var hashes = [frontMatterTitle: BridgeHash.body(attributionText)]
        for story in stories { hashes[story.title] = BridgeHash.body(story.text) }
        return SampleLibraryManifest(
            bookName: bookName, tagName: tagName, noteHashes: hashes)
    }

    /// The manifest for what this build actually ships. ~0.5 MB of string
    /// work plus thirteen hashes — call it off the main actor, as the seed
    /// does its own parse.
    nonisolated static func manifest() throws -> SampleLibraryManifest {
        manifest(stories: try loadStories())
    }

    /// **The dedupe repair's injected facts** (pre-13u Act 0, R-pre13u-8):
    /// what the sync engine — which cannot see this file — needs to
    /// recognise and classify a seeded copy. Wired at the ONE shared
    /// composition site (`SyncSession.configure`), so both platforms hand
    /// the engine the same facts and cannot drift. The manifest loader is
    /// LAZY: the ~0.5 MB parse runs only if two same-name copies actually
    /// meet, which happens at most about once in a store's life. The hash
    /// recipe rides along as the same function the manifest's own
    /// `isPristine` uses, so the pair can never disagree
    /// (`SampleLibraryDedupeFactsTests` pins the agreement).
    nonisolated static func dedupeFacts() -> SampleLibraryDedupeFacts {
        SampleLibraryDedupeFacts(
            bookName: bookName,
            tagPath: tagName,
            loadNoteHashes: { try manifest().noteHashes },
            hash: BridgeHash.body(_:))
    }

    // MARK: - Discovery (the idempotence guard)

    /// What the store already holds of this library. Deliberately reports
    /// the PRESENT TITLES rather than a bool, so a cancelled seed resumes.
    struct Existing: Sendable, Equatable {
        var bookID: String?
        var tagID: String?
        var presentTitles: Set<String> = []
        /// **The book's live chapters, name → id** (the midpoint review's
        /// m5). `createSection` and `importPost` are separate transactions,
        /// so a cancelled seed can leave a chapter with no note in it — and
        /// chapter names are deliberately NOT unique (AppSpec §7: "duplicate
        /// names legal, no natural key, no repair class"), so a resumed run
        /// that only checked `presentTitles` would mint a SECOND chapter of
        /// the same name beside the empty one, forever. Reusing the chapter
        /// heals the half-state instead of doubling it, and does it without
        /// ever skipping the note the reader is actually missing.
        ///
        /// Reads on the same one `discover` transaction as `presentTitles`,
        /// for the same reason it is safe: this book's chapters have exactly
        /// one minter — this seeder — and a second occasion is already
        /// serialized (the device mark, the Mac's single window task, the
        /// phone's single `occasion` task). Two DEVICES seeding is the
        /// dedupe repair's job, not this projection's.
        var chapterIDsByName: [String: String] = [:]
        /// **Live notes wearing the reserved tag that are NOT members of the
        /// book, title → id** (the ladder's F10). Deleting the BOOK
        /// tombstones its memberships and never its notes, so the thirteen
        /// stories survive alive and bookless; a restore that derived
        /// presence from membership alone minted thirteen fresh twins beside
        /// them (26 Sherlock notes, the tag on both sets). These are
        /// RE-MEMBERED into the book instead — the note she has is the note
        /// that comes back — and only a title with no live tagged note mints.
        /// Read by the reserved tag among LIVE posts (a deleted note is hers
        /// to have deleted, so its title mints afresh); smallest id first
        /// where two live tagged notes share a title, for determinism.
        var strayNoteIDsByTitle: [String: String] = [:]

        func isComplete(for titles: [String]) -> Bool {
            bookID != nil && titles.allSatisfy { presentTitles.contains($0) }
        }
    }

    nonisolated static func discover(_ db: Database) throws -> Existing {
        var existing = Existing()
        existing.bookID = try Queries.readings(db)
            .first { $0.name == bookName && $0.deletedAt == nil }?.id
        // The EXACT tag, never the subtree (the tutorial's MINOR-D3 rule):
        // a reader's own `sherlock holmes/…` child is hers.
        existing.tagID = try Queries.allTags(db).first { $0.path == tagName }?.id
        if let bookID = existing.bookID {
            existing.presentTitles = Set(
                try Queries.assembleReading(db, readingID: bookID)
                    .compactMap(\.title))
            // `(position, id)` order, first wins — deterministic if an
            // older half-run already left two chapters wearing one name.
            for chapter in try Queries.readingSections(db, readingID: bookID)
            where existing.chapterIDsByName[chapter.name] == nil {
                existing.chapterIDsByName[chapter.name] = chapter.id
            }
        }
        // F10: the stories that survive OUTSIDE the book — `everythingTagged`
        // lists live posts in id order, so the first holder of a title wins.
        if let tagID = existing.tagID {
            for postID in try Queries.everythingTagged(db, tagID: tagID).postIDs {
                guard let title = try Queries.containerTitle(db, id: postID),
                      !existing.presentTitles.contains(title),
                      existing.strayNoteIDsByTitle[title] == nil
                else { continue }
                existing.strayNoteIDsByTitle[title] = postID
            }
        }
        return existing
    }

    // MARK: - The door

    /// Marks are scoped by store variant, exactly like
    /// `IdleCommitScheduler.markDefaultsKey` and the starter journal's —
    /// Debug and Release share a defaults domain, so an unscoped key would
    /// let a dev-store seed suppress the real store's.
    nonisolated static func seededDefaultsKey(
        for variant: AppDatabase.StoreVariant
    ) -> String {
        "SampleLibrarySeeded.\(variant.rawValue)"
    }

    /// What the seed needs to know about sync, and nothing more — the
    /// starter journal's gate, same two facts, same injection shape.
    struct SyncGate {
        /// True when this store's contents are defined by an ACCOUNT rather
        /// than by this launch.
        var belongsToAnAccount: @MainActor () -> Bool
        /// True once a round has finished WITHOUT error.
        var hasSyncedCleanly: @MainActor () -> Bool

        /// No account anywhere — a dev store, or a caller with no services.
        static let unowned = SyncGate(
            belongsToAnAccount: { false }, hasSyncedCleanly: { true })
    }

    /// How long a signed-in device waits for its first clean round before
    /// declining. Declining is free: nothing is marked, so the next launch
    /// asks again — and nothing the reader asked for is waiting on this.
    static let firstRoundWait: Duration = .seconds(20)

    /// Every case is a real outcome and none of them throws: sample content
    /// must never be able to block or break a launch.
    enum Outcome: Equatable {
        /// This device already seeded this store variant — including the
        /// case where the reader then deleted the library. Never re-seeded.
        case alreadySeeded
        /// The library is already here (a prior run, or it arrived by sync).
        case alreadyPresent
        /// This store belongs to an account whose first clean round has not
        /// landed, so whether the library already exists is not yet
        /// knowable. NOT marked: the next launch asks again.
        case awaitingFirstSync
        /// Minted `stories` story notes (fewer than the full set when a
        /// cancelled earlier run is being resumed).
        case seeded(readingID: String, stories: Int)
        /// The store said no. Recorded, never surfaced.
        case refused(String)
    }

    /// Why a launch-path seeder logs: every outcome here is silent by
    /// design (sample content must never speak to the reader), so without
    /// one line there is no way to tell "already present" from "the gate
    /// declined" from "the store refused" — which is exactly the question
    /// asked the first time it does not appear. `log show --predicate
    /// 'subsystem == "io.lduarte.Variorum" AND category == "sample-library"'`.
    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "sample-library")

    /// **Pacing** (the ladder's F12): awaited before the skeleton turn and
    /// before EVERY story turn. A story import is one serial runner turn
    /// (~2,500 blocks across the twelve; hundreds of milliseconds each on a
    /// phone), and an autosave that reaches the runner behind one waits the
    /// whole turn — so a caller whose reader may be TYPING hands in a wait
    /// that holds the next turn while her text is still landing. nil (the
    /// Mac's launch seed, the restore door) paces nothing.
    typealias Pacing = @MainActor () async -> Void

    @discardableResult
    static func seedIfNeeded(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant = .real,
        gate: SyncGate = .unowned,
        firstRoundWait: Duration? = nil,
        pollInterval: Duration = .milliseconds(100),
        loadMark: (() -> Bool)? = nil,
        saveMark: ((Bool) -> Void)? = nil,
        pacing: Pacing? = nil
    ) async -> Outcome {
        let outcome = await perform(
            session: session, storeVariant: storeVariant, gate: gate,
            firstRoundWait: firstRoundWait, pollInterval: pollInterval,
            loadMark: loadMark, saveMark: saveMark, pacing: pacing)
        log.notice("sample library: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    private static func perform(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant,
        gate: SyncGate,
        firstRoundWait: Duration?,
        pollInterval: Duration,
        loadMark: (() -> Bool)?,
        saveMark: ((Bool) -> Void)?,
        pacing: Pacing?
    ) async -> Outcome {
        let key = seededDefaultsKey(for: storeVariant)
        let load = loadMark ?? { UserDefaults.standard.bool(forKey: key) }
        let save = saveMark ?? { UserDefaults.standard.set($0, forKey: key) }

        guard !load() else { return .alreadySeeded }

        do {
            // Off the main thread: half a megabyte of string work.
            let stories = try await Task.detached(priority: .utility) {
                try loadStories()
            }.value
            let titles = stories.map(\.title)

            var existing = try await session.database.read { db in try discover(db) }
            if existing.isComplete(for: titles) {
                save(true)
                return .alreadyPresent
            }

            if gate.belongsToAnAccount() {
                guard await waitForFirstCleanRound(
                    gate: gate,
                    limit: firstRoundWait ?? Self.firstRoundWait,
                    poll: pollInterval)
                else { return .awaitingFirstSync }
                // Whatever the account holds has landed. Ask again.
                existing = try await session.database.read { db in try discover(db) }
                if existing.isComplete(for: titles) {
                    save(true)
                    return .alreadyPresent
                }
            }

            let seeded = try await seed(
                session: session, stories: stories, existing: existing, pacing: pacing)
            save(true)
            return seeded
        } catch {
            return .refused(String(describing: error))
        }
    }

    /// Polled: `SyncSession` exposes no round-completed closure (the one it
    /// had was the Fragments bridge's trigger and left with it, 2026-09-04);
    /// the gate reads the scheduler's status, which is the seam.
    private static func waitForFirstCleanRound(
        gate: SyncGate, limit: Duration, poll: Duration
    ) async -> Bool {
        if gate.hasSyncedCleanly() { return true }
        let deadline = ContinuousClock.now.advanced(by: limit)
        while ContinuousClock.now < deadline {
            do { try await Task.sleep(for: poll) } catch { return false }
            if gate.hasSyncedCleanly() { return true }
        }
        return gate.hasSyncedCleanly()
    }

    // MARK: - The seed

    /// Mints what is missing. ONE runner turn for the book's skeleton, then
    /// ONE PER STORY — so a reader typing during the seed waits at most one
    /// story's writes, never the library's.
    ///
    /// **Every turn runs under the library's own clock** (m6): the whole
    /// seed is scoped by `withDependencies { $0.date = .constant(...) }`,
    /// which is the operations layer's OWN time seam — `Operations` reads
    /// `@Dependency(\.date)` and nothing else, so every stamp it writes
    /// (`created_at`, `updated_at`, `last_touched_at`, and the
    /// `last_major_revision_at` the first churn crossing lands) carries the
    /// publication date. No raw row edit, no new operation, no second write
    /// pass — the seed simply mints in 1892. The scope covers the book, the
    /// tag and the chapters as well as the notes, deliberately: a library
    /// whose notes say 1892 and whose book says today would be incoherent,
    /// and books sort by NAME (`Queries.readings`), so nothing on the shelf
    /// moves either way.
    @discardableResult
    static func seed(
        session: AppSession, stories: [Story], existing: Existing,
        pacing: Pacing? = nil
    ) async throws -> Outcome {
        let bookName = Self.bookName
        let tagName = Self.tagName
        let frontChapter = Self.frontMatterChapter
        let frontTitle = Self.frontMatterTitle
        let frontText = Self.attributionText
        let label = Self.undoLabel
        let present = existing.presentTitles
        let chapters = existing.chapterIDsByName
        let strays = existing.strayNoteIDsByTitle

        let clock = Self.publicationDate

        // Turn 1: the book, the tag, and the front matter.
        await pacing?()
        let skeleton = try await session.runner.run { _ -> (book: String, tag: String) in
            try withDependencies { $0.date = .constant(clock) } operation: {
                let quiet = Operations(undoStack: nil)
                let bookID: String
                if let known = existing.bookID {
                    bookID = known
                } else {
                    bookID = try quiet.createReading(
                        name: bookName, kind: .curated, profile: "book").id
                }
                let tagID = try existing.tagID ?? quiet.createTag(name: tagName).id
                if !present.contains(frontTitle) {
                    // m5: reuse a chapter a cancelled run already left behind,
                    // never mint a second one wearing the same name.
                    let sectionID = try chapters[frontChapter]
                        ?? quiet.createSection(in: bookID, name: frontChapter).id
                    try Self.place(
                        quiet, title: frontTitle, text: frontText, stray: strays[frontTitle],
                        in: bookID, section: sectionID, tag: tagID, label: label)
                }
                return (bookID, tagID)
            }
        }

        // One turn per story.
        var minted = 0
        for story in stories where !present.contains(story.title) {
            try Task.checkCancellation()
            await pacing?()
            let bookID = skeleton.book
            let tagID = skeleton.tag
            let stray = strays[story.title]
            try await session.runner.run { _ in
                try withDependencies { $0.date = .constant(clock) } operation: {
                    let quiet = Operations(undoStack: nil)
                    // m5, again: a run cancelled between `createSection` and
                    // `importPost` left this story's chapter standing empty.
                    let sectionID = try chapters[story.title]
                        ?? quiet.createSection(in: bookID, name: story.title).id
                    try Self.place(
                        quiet, title: story.title, text: story.text, stray: stray,
                        in: bookID, section: sectionID, tag: tagID, label: label)
                }
            }
            minted += 1
        }
        return .seeded(readingID: skeleton.book, stories: minted)
    }

    /// Puts one shipped note into the book: a surviving tagged note is
    /// RE-MEMBERED (F10 — it already wears the tag and carries whatever she
    /// did to it); only a title with no such note mints afresh.
    nonisolated private static func place(
        _ quiet: Operations, title: String, text: String, stray: String?,
        in bookID: String, section sectionID: String, tag tagID: String, label: String
    ) throws {
        let noteID: String
        if let stray {
            noteID = stray
        } else {
            noteID = try quiet.importPost(
                title: title, text: text, undoLabel: label,
                segmentation: Self.segmentation).container.id
            _ = try quiet.applyTag(tagID, toPost: noteID)
        }
        _ = try quiet.addPostToReading(noteID, to: bookID)
        try quiet.assignPostToSection(noteID, in: bookID, section: sectionID)
    }
}
