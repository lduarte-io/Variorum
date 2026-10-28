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
//  *(VX-633 U2b — R-633-16, her word: "FRESH STORES ONLY": ONE book bends
//  this. *The Prince* (`Book.seedsFreshStoresOnly`) seeds on a fresh store's
//  launch road only — an existing store never gains it at an update, on
//  either platform; Help ▸ Restore is its road. The rule, what "fresh" means
//  and when each platform judges it: `SampleLibraryFreshStore.swift`. Every
//  other book keeps the no-guard doctrine above, byte-unchanged.)*
//
//  ── DELETION IS FINAL, AND THAT IS THE POINT ──────────────────────────
//  The device mark is set only after a COMPLETE seed (or, since 18o U2, when
//  a launch declines on her recorded deletion — below). Delete the book (or
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
//  *(18o U2 — her R-18k-5 on QUESTIONS #138(f), "honour the tombstone at
//  launch": while the tombstone stands they are NO LONGER the same reading.
//  The launch reads the tutorial door's own rule (`readerDeletedTheBook` — a
//  tombstoned reading of the reserved name) at every read that decides, and
//  declines on it (`Outcome.deletedByTheReader`), recording the decision in
//  the mark as it goes. That covers the lost mark AND the second device — the
//  book arrived by sync, so no mark was ever written there — which used to
//  re-mint a deletion made anywhere at its next launch. What remains is the
//  purge: once Delete Now's janitor removes the row, a device that never
//  launched (or opened the tutorial) in between holds no evidence and mints
//  (#138(e), the recorded gap; the travelling marker was #138(f)'s option
//  (iii), not taken). A RENAMED book is still minted afresh — the reserved
//  name is the identity. The phone's first-write occasion rides this same
//  brain, so it declines the same way.)*
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
//  ── TWO BOOKS, ONE SEEDER (pre-13x batch 5a — design §1.22, copy §7b) ──
//  *Encryption Explained* — the full story of the two postures, every key
//  and where it lives — is a SECOND seeded book in Home beside Sherlock and
//  the tutorial, restorable from Help like both, and a member of the seeded-
//  book dedupe facts so two devices never seed two of it. It rides this
//  seeder GENERALIZED to a per-book description (`Book`): Sherlock's values
//  are `.sherlock` (every reserved identity keeps its name and its value,
//  so the Mac and phone pins ride unmodified), the encryption book's are
//  `.encryptionExplained`. The whole machinery — the delimiter parse, the
//  manifest, the facts, discovery, the resumable seed, the marks — takes
//  the book; the callers seed both, and the dedupe engine takes the facts
//  as a LIST (the batch's one `Sync/` touch, ruled).
//
//  ── A THIRD BOOK, AND A NOTE WITH A HISTORY (18l-c U6 — R-18l-11/12) ──
//  *The Strange Case of Dr Jekyll and Mr Hyde* holds the author's test note
//  **takemania**, whose history is REAL ROWS written by a scripted run of
//  the operations API (`Takemania.swift`) — so a `Book` may now name ONE
//  `ScriptedNote` beside its imported stories. Two consequences, each its
//  own named rule below:
//    · **Completeness is title-last.** A scripted note is minted under a
//      reserved working title and takes its real one as its last act, so
//      discovery (keyed on titles) never counts a half-written history as
//      present and the mark is never set over one; the next occasion trashes
//      the half-built note and mints afresh (`Existing.halfBuiltNoteIDs`).
//    · **The dedupe does not judge this book** (`Book.joinsPristineDedupe`,
//      PROVISIONAL — QUESTIONS #155). A book born with history reads EDITED
//      to the pristine-copy classifier, and the engine's defense leg revives
//      a deliberately deleted edited copy while its twin stands — which
//      would undo the very advice R-18l-12's disclaimer gives. Out of the
//      facts list the engine never sees it: two copies are two ordinary
//      books, and the facts it receives stay byte-identical (zero `Sync/`).
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

    // MARK: - The per-book description (pre-13x 5a — two books, one seeder)

    /// Everything that differs between the seeded books, and nothing that
    /// does not: the reserved identities discovery finds its objects by, the
    /// bundled resource, the front-matter note, the defaults mark, and the
    /// clock the mint runs under. `Equatable` so a pin can name one.
    nonisolated struct Book: Sendable, Equatable {
        /// The book's reserved name — EXACT, case-sensitive (discovery's rule;
        /// a rename is engagement and the copy is hers from then on).
        var name: String
        /// The reserved tag path, applied to every note the seed mints.
        var tagName: String
        /// The front-matter chapter's name and its note's title + text.
        var frontMatterChapter: String
        var frontMatterTitle: String
        var frontMatterText: String
        /// The bundled `.txt` resource (`%%% <title>` lines separate the
        /// notes and are never stored).
        var resourceName: String
        /// The `reading.profile` the book is minted with.
        var profile: String
        /// The defaults mark's suffix — nil keeps the ORIGINAL key
        /// (`SampleLibrarySeeded.<variant>`), so an existing store's Sherlock
        /// mark is honoured and only the new book seeds at the next occasion.
        var markSuffix: String?
        /// The clock every write of the seed carries — nil = the ambient
        /// clock (the tutorial's shape: a book about THIS build lands now).
        var clock: Date?
        /// 18l-c U6: a note minted by a SCRIPTED HISTORY rather than
        /// imported (takemania) — nil for every book before it.
        var scriptedNote: ScriptedNote? = nil
        /// 18l-c U6: whether the sync engine's pristine-copy dedupe judges
        /// this book (`allDedupeFacts`). True for every book before it; the
        /// Jekyll book opts OUT (the header's reason; QUESTIONS #155).
        var joinsPristineDedupe: Bool = true
        /// VX-633: how the book's notes map onto its chapters — one chapter
        /// per note for every book before it; the Prince's notes ARE its
        /// chapters and its `reading_section` rows are the four parts.
        var grouping: NoteGrouping = .chapterPerNote
        /// VX-633: a pass run right after each FRESH import, in the note's
        /// own runner turn (the Prince's other takes) — nil for every book
        /// before it.
        var takePass: TakePass? = nil
        /// **VX-633 U2b (R-633-16, her word: "FRESH STORES ONLY"):** whether
        /// the LAUNCH road seeds this book only into a fresh store
        /// (`SampleLibraryFreshStore` — the rule and its reasons). False for
        /// every book before the Prince: their launch behaviour is
        /// byte-unchanged, and no restore door ever asks.
        var seedsFreshStoresOnly: Bool = false

        /// *The Adventures of Sherlock Holmes* — pre-13u Act 3's book, its
        /// values exactly as they shipped.
        static let sherlock = Book(
            name: SampleLibrarySeeder.bookName,
            tagName: SampleLibrarySeeder.tagName,
            frontMatterChapter: SampleLibrarySeeder.frontMatterChapter,
            frontMatterTitle: SampleLibrarySeeder.frontMatterTitle,
            frontMatterText: SampleLibrarySeeder.attributionText,
            resourceName: SampleLibrarySeeder.resourceName,
            profile: "book",
            markSuffix: nil,
            clock: SampleLibrarySeeder.publicationDate)

        /// *Encryption Explained* — the postures design's second seeded
        /// book (§1.22; copy §7b VERBATIM in `EncryptionExplained.txt`): one
        /// note per chapter in Chapter 1 → 8 order, the chapter heading its
        /// title, the front-matter note the register rule's definitions.
        /// Its name is the copy's own quoted name (the tutorial's door
        /// sentence names it); its tag path a top-level sibling of Sherlock's
        /// and the tutorial's. Stamped at seed time — a book about this
        /// build is not an 1892 text.
        static let encryptionExplained = Book(
            name: SampleLibraryEncryptionBook.name,
            tagName: SampleLibraryEncryptionBook.tagName,
            frontMatterChapter: SampleLibraryEncryptionBook.frontMatterChapter,
            frontMatterTitle: SampleLibraryEncryptionBook.frontMatterTitle,
            frontMatterText: SampleLibraryEncryptionBook.aboutThisBook,
            resourceName: SampleLibraryEncryptionBook.resourceName,
            profile: "book",
            markSuffix: SampleLibraryEncryptionBook.markSuffix,
            clock: nil)

        /// *The Strange Case of Dr Jekyll and Mr Hyde* — 18l-c U6
        /// (R-18l-11): the front matter (R-18l-12's disclaimer), the
        /// novella's first and last chapters as straight text, and between
        /// them takemania, minted by its scripted history. The book's own
        /// clock is the novella's publication (Sherlock's m6 precedent);
        /// takemania's history runs on a seed-relative clock of its own
        /// (`Takemania`'s header).
        static let jekyllAndHyde = Book(
            name: SampleLibraryJekyllBook.name,
            tagName: SampleLibraryJekyllBook.tagName,
            frontMatterChapter: SampleLibraryJekyllBook.frontMatterChapter,
            frontMatterTitle: SampleLibraryJekyllBook.frontMatterTitle,
            frontMatterText: SampleLibraryJekyllBook.aboutThisBook,
            resourceName: SampleLibraryJekyllBook.resourceName,
            profile: "book",
            markSuffix: SampleLibraryJekyllBook.markSuffix,
            clock: SampleLibraryJekyllBook.publicationDate,
            scriptedNote: .takemania,
            joinsPristineDedupe: false)

        /// *The Prince*, bilingual — VX-633 (R-633-1…14,
        /// `notes/plans/vx-633-prince-book.md`): the dedication and all
        /// twenty-six chapters, one note each, grouped into the four parts;
        /// every block Marriott's English (chosen) + the Italian, a few with a
        /// third take (`SampleLibraryPrinceBook`). The book's clock is the
        /// first printing's (Sherlock's m6 precedent). Born fanned, so it
        /// reads EDITED to the pristine-copy classifier and stays OUT of the
        /// dedupe (the Jekyll precedent — the engine's facts byte-identical).
        /// U2b (R-633-16): it seeds on a FRESH store's launch road only — an
        /// existing store's road is Help ▸ Restore “the prince”.
        static let prince = Book(
            name: SampleLibraryPrinceBook.name,
            tagName: SampleLibraryPrinceBook.tagName,
            frontMatterChapter: SampleLibraryPrinceBook.frontMatterChapter,
            frontMatterTitle: SampleLibraryPrinceBook.frontMatterTitle,
            frontMatterText: SampleLibraryPrinceBook.aboutThisText,
            resourceName: SampleLibraryPrinceBook.resourceName,
            profile: "book",
            markSuffix: SampleLibraryPrinceBook.markSuffix,
            clock: SampleLibraryPrinceBook.publicationDate,
            joinsPristineDedupe: false,
            grouping: .princeParts,
            takePass: .princeBilingual,
            seedsFreshStoresOnly: true)

        /// Every seeded book, in seeding order — the RESTORE doors' and the
        /// pins' vocabulary. Since 17y B-DEDUPE this is NOT the launch's
        /// list: `launchSet` is. (VX-633: the Prince joins at the end.)
        static let all: [Book] = [.sherlock, .encryptionExplained, .jekyllAndHyde, .prince]

        /// **The DEFAULT seed — what a fresh store is born with (R-17y-8,
        /// 2026-10-05, her word: "I don't want it in people's libraries
        /// anymore").** Jekyll (takemania inside it) leaves the launch on
        /// BOTH platforms; existing stores are never retrofitted (their
        /// marks and discovery already hold), and Help ▸ Restore keeps
        /// minting it on demand — `all` is the doors' list.
        /// **13s-b U1b (R-13s-5/37, her launch list verbatim: "field guide,
        /// sherlock holmes, and a starred notes empty gathering"):**
        /// *Encryption Explained* leaves the launch too, on BOTH platforms
        /// (the R-17y-8 precedent — her ruling names people's libraries,
        /// and a phone-seeded copy re-arrives everywhere by sync). Her word
        /// goes further than Jekyll's did: EE is "not present and NOT
        /// restorable", so its doors leave with it (U1b piece 3) and `all`
        /// keeps it only as the dedupe facts' vocabulary for the installed
        /// base.
        /// **VX-633 (R-633-6, her word: "sherlock and jekyll and hyde are
        /// still restorable"):** *The Prince*, bilingual, REPLACES Sherlock
        /// in the launch, on BOTH platforms (the R-17y-8 / R-13s-37
        /// precedent: a launch list names people's libraries, and the phone's
        /// first-write occasion reads this same list); Sherlock joins Jekyll
        /// as restore-only (`all` keeps every door). An existing store keeps
        /// what it has. **U2b (R-633-16, her D1 ruling — superseding U2's
        /// PROVISIONAL, which seeded the Prince into existing stores by its
        /// own mark, the 5a/U6 precedent):** the Prince seeds on a FRESH
        /// store's launch road only (`Book.seedsFreshStoresOnly`,
        /// `SampleLibraryFreshStore`); an existing store — hers, the
        /// testers' — never gains it at an update, on either platform, and
        /// Help ▸ Restore “the prince” is its road (arranged by the door).
        static let launchSet: [Book] = [.prince]

        /// **The launch set's FIRST book — the one whose launch outcome
        /// decides a FRESH store's birth** (the Welcome arrangement's
        /// decision, `SampleLibraryWelcome.arrangeAtLaunch`; 13i-d U7's
        /// "this launch's Sherlock seed minted every story" — the Prince's
        /// since VX-633) and the book the phone's first-write occasion seeds.
        static var launchBook: Book { launchSet[0] }

        /// The books the sync engine's pristine-copy dedupe judges
        /// (`allDedupeFacts`) — every book whose shipped seed is PRISTINE by
        /// construction. 18l-c U6: `Book.all` and this list stopped being
        /// the same list; the engine's facts stay byte-identical.
        static var dedupeCovered: [Book] { all.filter(\.joinsPristineDedupe) }
    }

    /// **A note minted by a scripted history** (18l-c U6). One case today;
    /// the seeder asks it for its title, its reserved working title, its
    /// chapter, where it stands in the book, and how to mint it.
    nonisolated enum ScriptedNote: Sendable, Equatable {
        case takemania

        var title: String { Takemania.title }
        var workingTitle: String { Takemania.workingTitle }
        var chapter: String { Takemania.chapter }
        /// The story it follows in the book's order (appended when absent).
        var follows: String { Takemania.follows }

        func mint(
            _ ops: Operations, anchor: Date, bookID: String, sectionID: String, tagID: String,
            interruptAfterStep: Int?
        ) throws -> String {
            try Takemania.mint(
                ops, anchor: anchor, bookID: bookID, sectionID: sectionID, tagID: tagID,
                interruptAfterStep: interruptAfterStep)
        }
    }

    /// **How a book's notes map onto its chapters** (VX-633). Every book
    /// before the Prince mints one chapter per note, named after it; the
    /// Prince's chapters are its four PARTS (R-633-5), each holding several
    /// notes — the seed reuses a part's section by name, so eleven notes share
    /// one row — after the Dedication's own, "dedication" (R-633-17).
    nonisolated enum NoteGrouping: Sendable, Equatable {
        case chapterPerNote
        case princeParts

        /// The chapter (section name) a note of this title is filed in.
        func chapter(for title: String) -> String {
            switch self {
            case .chapterPerNote: return title
            case .princeParts: return SampleLibraryPrinceBook.part(for: title)
            }
        }
    }

    /// **A pass run right after each FRESH import, in the same runner turn**
    /// (VX-633) — so the note never exists without what it adds, and the
    /// resumable seed stays correct by construction (cancellation lands only
    /// between turns). Never run on a re-membered or copied note: those
    /// carry whatever takes they already have. One case today.
    nonisolated enum TakePass: Sendable, Equatable {
        /// The Prince's Italian take on every block, the third takes and the
        /// English verse's line breaks (`SampleLibraryPrinceBook.attachTakes`).
        case princeBilingual

        /// The pass's companion text, note title → paragraphs — loaded once
        /// per seed, off the main actor. A build missing it throws the
        /// seeder's own `resourceMissing` BEFORE anything is minted: the same
        /// class as a missing English text (the restore door words it "This
        /// build is missing the book's text — nothing was restored."), so a
        /// broken bundle never seeds a one-language book.
        func loadCompanion() throws -> [String: [String]] {
            switch self {
            case .princeBilingual:
                let raw = try SampleLibrarySeeder.bundledText(SampleLibraryPrinceBook.italianResourceName)
                let notes = SampleLibrarySeeder.parse(raw).map { (title: $0.title, text: $0.text) }
                guard !notes.isEmpty else { throw LoadError.noStories }
                return SampleLibraryPrinceBook.italianParagraphs(notes)
            }
        }

        /// Runs the pass on one freshly imported note (its takes, then —
        /// R-633-15 — its saved lenses).
        func apply(
            _ ops: Operations, title: String, note: ImportedNote, companion: [String: [String]]
        ) throws -> SampleLibraryPrinceBook.PassReport {
            switch self {
            case .princeBilingual:
                return try SampleLibraryPrinceBook.attachTakes(
                    ops, title: title, noteID: note.noteID, blockIDs: note.blockIDs,
                    italian: companion[title], undoLabel: SampleLibrarySeeder.undoLabel)
            }
        }
    }

    /// What `place` minted when it imported a note afresh: the note and its
    /// blocks in placement order — the take pass's input (VX-633).
    nonisolated struct ImportedNote: Sendable, Equatable {
        var noteID: String
        var blockIDs: [String]
    }

    /// One note of a book's seed, in book order: an imported story, or the
    /// scripted note. Plain values, so the runner's closures read them
    /// without touching the seeder's isolation.
    nonisolated enum PlanEntry: Sendable, Equatable {
        case story(title: String, text: String)
        case scripted(ScriptedNote)

        var title: String {
            switch self {
            case .story(let title, _): return title
            case .scripted(let note): return note.title
            }
        }
    }

    /// Every title a COMPLETE copy of `book` holds, beyond its front matter:
    /// the resource's stories, plus the scripted note's (18l-c U6). What
    /// discovery's `isComplete` is asked about on every road — the launch
    /// seed's two reads and the restore door's.
    static func expectedTitles(for book: Book, stories: [Story]) -> [String] {
        plan(for: book, stories: stories).map(\.title)
    }

    /// The seed's order: the stories as the resource lists them, with the
    /// scripted note (if any) right after the story it follows. A book
    /// without one plans exactly its stories — every pre-U6 seed unchanged.
    static func plan(for book: Book, stories: [Story]) -> [PlanEntry] {
        var entries = stories.map { PlanEntry.story(title: $0.title, text: $0.text) }
        if let scripted = book.scriptedNote {
            let index = entries.firstIndex { $0.title == scripted.follows }.map { $0 + 1 }
            entries.insert(.scripted(scripted), at: index ?? entries.endIndex)
        }
        return entries
    }

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
    /// main actor — it is ~0.5 MB of string work for Sherlock. The
    /// parameterless form is Sherlock's (every pre-5a caller and pin).
    nonisolated static func loadStories(for book: Book = .sherlock) throws -> [Story] {
        let stories = parse(try bundledText(book.resourceName))
        guard !stories.isEmpty else { throw LoadError.noStories }
        return stories
    }

    /// A bundled `.txt` resource's text (VX-633: shared by the book's own
    /// resource and the Prince's Italian companion). Missing or unreadable →
    /// `resourceMissing`.
    nonisolated static func bundledText(_ resourceName: String) throws -> String {
        let bundle = Bundle(for: SampleLibraryBundleAnchor.self)
        guard let url = bundle.url(forResource: resourceName, withExtension: "txt"),
              let raw = try? String(contentsOf: url, encoding: .utf8)
        else { throw LoadError.resourceMissing }
        return raw
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
    nonisolated static func manifest(book: Book = .sherlock, stories: [Story]) -> SampleLibraryManifest {
        var hashes = [book.frontMatterTitle: BridgeHash.body(book.frontMatterText)]
        for story in stories { hashes[story.title] = BridgeHash.body(story.text) }
        return SampleLibraryManifest(
            bookName: book.name, tagName: book.tagName, noteHashes: hashes)
    }

    /// The manifest for what this build actually ships. ~0.5 MB of string
    /// work plus thirteen hashes — call it off the main actor, as the seed
    /// does its own parse. The parameterless form is Sherlock's.
    nonisolated static func manifest(for book: Book = .sherlock) throws -> SampleLibraryManifest {
        manifest(book: book, stories: try loadStories(for: book))
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
    /// **The classics tag's ONE spelling** (13i-d U7, her #166(b) ruling —
    /// the seeded triad wears `#classics`): the seeder's tagging step and
    /// the dedupe facts' seed-tag declaration both read THIS constant, so
    /// the classifier's skip and the seed's own act can never drift.
    nonisolated static let classicsTagPath = "classics"

    nonisolated static func dedupeFacts(for book: Book = .sherlock) -> SampleLibraryDedupeFacts {
        SampleLibraryDedupeFacts(
            bookName: book.name,
            tagPath: book.tagName,
            loadNoteHashes: { try manifest(for: book).noteHashes },
            hash: BridgeHash.body(_:),
            // 13i-d U7 (F-U7-1's ruled letter): the classics tag is
            // seed-authored on EVERY dedupe-covered book's notes — a live
            // application of it never marks a copy edited.
            seedTagPaths: [classicsTagPath])
    }

    /// Every DEDUPE-COVERED book's facts, in seeding order — what
    /// `SyncSession.configure` hands the engine (pre-13x 5a: the facts
    /// became a LIST; the pass runs per entry exactly as it ran for one).
    /// 18l-c U6: `Book.dedupeCovered`, not `Book.all` — the Jekyll book is
    /// seeded everywhere but judged nowhere (the header's reason), so the
    /// list the engine receives is byte-identical to before it existed.
    nonisolated static func allDedupeFacts() -> [SampleLibraryDedupeFacts] {
        Book.dedupeCovered.map { dedupeFacts(for: $0) }
    }

    /// **17y B-DEDUPE (R-17y-5): the seeded-furniture fold's SHARED half** —
    /// the three seeded gatherings and the seeded quicknote, the objects
    /// both platforms mint. The GUIDE half is the platform's to append (the
    /// Mac passes `TutorialSeeder`'s at its `AppServices` construction; the
    /// phone passes nothing — the pocket guide's symmetric entry is its
    /// recorded MOBILE PARITY row). Every signature reads the minting
    /// code's OWN constants, so the fold and the seeds can never drift.
    nonisolated static func furnitureDedupeFacts(
        guideBookName: String? = nil,
        guideTagPath: String? = nil,
        guideContainers: [SeededFurnitureDedupeFacts.ReservedContainer] = []
    ) -> SeededFurnitureDedupeFacts {
        SeededFurnitureDedupeFacts(
            guideBookName: guideBookName,
            guideTagPath: guideTagPath,
            gatherings: [
                // classics — minted ON Welcome by the arrangement, rule =
                // the ONE seed tag (the F-U7-1 letter), unstarred.
                .init(
                    name: SampleLibraryWelcome.classicsGatheringName,
                    rule: .tagPath(classicsTagPath)),
                // starred notes — unshelved, rule ★, unstarred (13i-b U4).
                .init(name: Operations.starredNotesGatheringName, rule: .star),
                // Quicknotes — unshelved, rule = the quicknote tag, BORN
                // STARRED (R-13id-5), with the designation that must
                // re-point to the keeper (§20: re-point, never mint).
                .init(
                    name: Operations.defaultQuicknoteBookName,
                    rule: .tagPath(Operations.quicknoteTagPath),
                    designationKey: Operations.quicknoteBookDesignationKey,
                    bornStarred: true),
            ],
            containers: [
                // The ONE seeded quicknote (the pad's own road; its tag is
                // the seed's hands).
                .init(
                    title: SampleLibraryWelcome.quicknoteTitle, kind: "post",
                    seedTagPaths: [Operations.quicknoteTagPath]),
            ] + guideContainers,
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
        /// **The BOOK's wing as surfaces read it** (13i-d ladder B fix C):
        /// `''` (Home) when no book exists or its wing pointer dangles. The
        /// seed resolves the reserved tag here and mints missing notes here —
        /// a book she moved to another wing restores IN that wing. A stray in
        /// ANOTHER wing wears that wing's tag twin and is deliberately not
        /// found (its title mints fresh): the restore never crosses wings by
        /// itself — lesson 11's fence.
        var wing: String = ""
        /// **The seeder's own half-built scripted note** (18l-c U6 — design
        /// call 3): members of the book still wearing the scripted note's
        /// RESERVED working title, which only a history stopped before its
        /// last act can leave. The scripted mint trashes them (the Trash
        /// keeps them 30 days) before minting afresh. Empty for every book
        /// without a scripted note.
        var halfBuiltNoteIDs: [String] = []

        func isComplete(for titles: [String]) -> Bool {
            bookID != nil && titles.allSatisfy { presentTitles.contains($0) }
        }
    }

    nonisolated static func discover(_ db: Database, book: Book = .sherlock) throws -> Existing {
        var existing = Existing()
        let found = try Queries.readings(db)
            .first { $0.name == book.name && $0.deletedAt == nil }
        existing.bookID = found?.id
        // 13i-d LADDER B fix C: the restore is WING-AWARE — the book may
        // have been MOVED to another wing (U5b's door), and everything the
        // seed resolves or mints must live where the book lives, or the
        // re-membering refuses `crossWingMembership` partway with a retry
        // that can never succeed. Home when no book exists (the fresh seed's
        // shape, unchanged); a dangling wing reads as Home, the surfaces' rule.
        existing.wing = try found.map {
            try Queries.wingIsLive(db, id: $0.wingId) ? $0.wingId : ""
        } ?? ""
        // The EXACT tag, never the subtree (the tutorial's MINOR-D3 rule):
        // a reader's own `sherlock holmes/…` child is hers — and the BOOK's
        // WING's row (fix C: a moved book's tag twin lives beside it; Home's
        // old row stays Home's vocabulary).
        existing.tagID = try Queries.allTags(db, wingID: existing.wing)
            .first { $0.path == book.tagName }?.id
        if let bookID = existing.bookID {
            let entries = try Queries.assembleReading(db, readingID: bookID)
            existing.presentTitles = Set(entries.compactMap(\.title))
            if let scripted = book.scriptedNote {
                existing.halfBuiltNoteIDs = entries
                    .filter { $0.title == scripted.workingTitle }
                    .map(\.postID)
            }
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
    /// one build can open either store — the dev fence's opt-in — so within one
    /// build's domain an unscoped key would let a dev-store seed suppress the
    /// real store's (the Debug and Release domains themselves are separate).
    nonisolated static func seededDefaultsKey(
        for variant: AppDatabase.StoreVariant, book: Book = .sherlock
    ) -> String {
        let base = "SampleLibrarySeeded.\(variant.rawValue)"
        guard let suffix = book.markSuffix else { return base }
        return base + "." + suffix
    }

    /// pre-13x ladder round 2, F3 (MINOR-N3): this device's per-book seeded
    /// mark, as the launch seeder reads it (production's `loadMark`) — and
    /// the tutorial door's SILENT ensure reads the same mark as the reader's
    /// standing decision ("deleted ⇒ never re-seeded", `Outcome.alreadySeeded`).
    nonisolated static func isMarkedSeeded(storeVariant: AppDatabase.StoreVariant, book: Book) -> Bool {
        UserDefaults.standard.bool(forKey: seededDefaultsKey(for: storeVariant, book: book))
    }

    /// **The reader's decision as the STORE records it — ONE rule for the
    /// silent road** (18o U2 lifted it here from the tutorial door's ensure,
    /// R-18k-5; that ensure retired with Encryption Explained's doors at
    /// 13s-b U1b, so the launch seed (`perform` — *"honour the tombstone at
    /// launch"*, QUESTIONS #138(f)) is the rule's silent reader now). A TOMBSTONED reading of the book's
    /// reserved name — any age, a Delete Now included
    /// (`Queries.readingTombstoneExists`) — is her deletion, made on this
    /// device or arrived from another. The explicit doors (Help ▸ Restore, the
    /// phone's Settings row) are asks and never read it. A physically purged
    /// row leaves nothing to read, so both roads RECORD the decision in the
    /// device mark (`isMarkedSeeded`, the other evidence) whenever this answers
    /// true (RUN A A2); a device that ran neither road between the deletion
    /// and the purge is the recorded gap (#138(e)).
    nonisolated static func readerDeletedTheBook(_ db: Database, book: Book) throws -> Bool {
        try Queries.readingTombstoneExists(db, name: book.name)
    }

    /// RUN A batch A2, row 8 (17l item 1 / KnownIssues 38): the WRITE half —
    /// what `perform` has always done through its `save` leaf, named so the
    /// seeded-book DOORS can record the same decision (see
    /// `AppSession.markSeededBook`, which is how they reach it; a headless
    /// run injects its own leaf and never touches the shared domain).
    nonisolated static func markSeeded(storeVariant: AppDatabase.StoreVariant, book: Book) {
        UserDefaults.standard.set(true, forKey: seededDefaultsKey(for: storeVariant, book: book))
    }

    // MARK: - The latch (RUN A batch A2, row 8 — 17l item 1 / KnownIssues 38)

    /// **ONE discover-then-mint per book per store, at a time.**
    ///
    /// Every road that mints a seeded book does the same two things with
    /// awaits between them — DISCOVER what the store holds, then MINT what
    /// is missing — and the awaits are real: the ~0.5 MB resource parse on a
    /// detached task, the database read, and one serial runner turn per
    /// note. So two roads that each correctly saw "no book here" both mint
    /// one, and the reader ends up with two *Encryption Explained* books on
    /// her shelf. The two roads are the launch seed (`seedIfNeeded`) and the
    /// restore road (`SeededBookRestore.restore`, which the tutorial door's
    /// silent ensure, Help ▸ Restore and the phone's Settings row all ride)
    /// — F2's question 6 and F3's question 2, and pre-existing for two
    /// Restore presses.
    ///
    /// The latch WAITS rather than declining, and the body re-discovers
    /// inside it: a second road that skipped would leave the tutorial's
    /// Lesson 2 pointing at a book that is not there yet, and a second road
    /// that ran with the `Existing` it read BEFORE waiting would mint the
    /// twin anyway — the stale projection is the whole defect.
    ///
    /// Scoped to the SESSION (one per store) rather than to a process-wide
    /// key, so parallel test worlds never serialize against each other, and
    /// to the book, so Sherlock and the encryption book seed side by side.
    /// A waiter is resumed by the holder's `defer`, so a cancelled body
    /// still releases; a waiter itself is not cancellable (it is always
    /// resumed, never dropped).
    private static var seedsInFlight: Set<LatchKey> = []
    private static var seedWaiters: [LatchKey: [CheckedContinuation<Void, Never>]] = [:]

    private struct LatchKey: Hashable {
        let store: ObjectIdentifier
        let book: String
    }

    static func withSeedLatch<T>(
        session: AppSession, book: Book, _ body: () async throws -> T
    ) async rethrows -> T {
        let key = LatchKey(store: ObjectIdentifier(session), book: book.name)
        while seedsInFlight.contains(key) {
            await withCheckedContinuation { continuation in
                seedWaiters[key, default: []].append(continuation)
            }
        }
        seedsInFlight.insert(key)
        defer {
            seedsInFlight.remove(key)
            for waiter in seedWaiters.removeValue(forKey: key) ?? [] { waiter.resume() }
        }
        return try await body()
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
        /// 18o U2 (R-18k-5, QUESTIONS #138(f)): the reader DELETED this book
        /// — a tombstoned reading of its name is on record
        /// (`readerDeletedTheBook`), made here or arrived by sync — so the
        /// launch honours it exactly as the tutorial door's ensure does, and
        /// RECORDS the decision in the mark. Nothing minted; Help ▸ Restore
        /// still brings it back.
        case deletedByTheReader
        /// This store belongs to an account whose first clean round has not
        /// landed, so whether the library already exists is not yet
        /// knowable. NOT marked: the next launch asks again.
        case awaitingFirstSync
        /// Minted `stories` story notes (fewer than the full set when a
        /// cancelled earlier run is being resumed).
        case seeded(readingID: String, stories: Int)
        /// **VX-633 U2b (R-633-16, her word: "FRESH STORES ONLY"):** a book
        /// that seeds on a fresh store's launch road alone
        /// (`Book.seedsFreshStoresOnly` — the Prince) met an EXISTING store —
        /// it has held writing, or this device already settled its launch
        /// (`SampleLibraryFreshStore`). Nothing minted; the decision is
        /// RECORDED in the mark (`deletedByTheReader`'s precedent), so later
        /// launches short-circuit before the parse. Help ▸ Restore is an
        /// existing store's road, and never reads the mark.
        case existingStore
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

    /// `freshness` (VX-633 U2b — R-633-16) is read only for a book that seeds
    /// fresh stores alone (`Book.seedsFreshStoresOnly`); every other book
    /// ignores it. The default judges the store at the deciding reads — the
    /// Mac's launch hands `.settled` when this device already settled the
    /// store, the phone its launch-time fact.
    @discardableResult
    static func seedIfNeeded(
        session: AppSession,
        book: Book = .sherlock,
        storeVariant: AppDatabase.StoreVariant = .real,
        gate: SyncGate = .unowned,
        freshness: SampleLibraryFreshness = .readAtDecision,
        firstRoundWait: Duration? = nil,
        pollInterval: Duration = .milliseconds(100),
        loadMark: (() -> Bool)? = nil,
        saveMark: ((Bool) -> Void)? = nil,
        pacing: Pacing? = nil
    ) async -> Outcome {
        let outcome = await perform(
            session: session, book: book, storeVariant: storeVariant, gate: gate,
            freshness: freshness,
            firstRoundWait: firstRoundWait, pollInterval: pollInterval,
            loadMark: loadMark, saveMark: saveMark, pacing: pacing)
        log.notice("sample library (\(book.name, privacy: .public)): \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    private static func perform(
        session: AppSession,
        book: Book,
        storeVariant: AppDatabase.StoreVariant,
        gate: SyncGate,
        freshness: SampleLibraryFreshness,
        firstRoundWait: Duration?,
        pollInterval: Duration,
        loadMark: (() -> Bool)?,
        saveMark: ((Bool) -> Void)?,
        pacing: Pacing?
    ) async -> Outcome {
        let key = seededDefaultsKey(for: storeVariant, book: book)
        let load = loadMark ?? { isMarkedSeeded(storeVariant: storeVariant, book: book) }
        let save = saveMark ?? { UserDefaults.standard.set($0, forKey: key) }

        guard !load() else { return .alreadySeeded }

        do {
            // Off the main thread: half a megabyte of string work.
            let stories = try await Task.detached(priority: .utility) {
                try loadStories(for: book)
            }.value
            // 18l-c U6: the scripted note's title counts toward "complete".
            let titles = expectedTitles(for: book, stories: stories)

            // 18o U2 (R-18k-5): every read that can DECIDE reads the same two
            // facts — what the store holds, and whether the reader deleted
            // this book (`readerDeletedTheBook`, the tutorial door's rule) —
            // and decides the same way (`decidedWithoutMinting`). VX-633 U2b
            // (R-633-16): a third, for a fresh-only book alone — whether the
            // store is an EXISTING one. Here, before the gate, it can only
            // decline (writing already in the store cannot un-exist); an
            // account store that reads empty now is judged again below, by
            // what its first clean round brought.
            let known = try await session.database.read { db in
                try facts(db, book: book, titles: titles, freshness: freshness)
            }
            if let decided = decidedWithoutMinting(known, titles: titles, save: save) {
                return decided
            }

            if gate.belongsToAnAccount() {
                guard await waitForFirstCleanRound(
                    gate: gate,
                    limit: firstRoundWait ?? Self.firstRoundWait,
                    poll: pollInterval)
                else { return .awaitingFirstSync }
            }

            // THE CRITICAL SECTION (row 8): discover, then mint, with no
            // other road doing the same for this book on this store in
            // between. The read above stays OUTSIDE it — it is a cheap early
            // out and, when an account owns the store, the answer it gives is
            // stale by the length of the wait anyway; the discovery that
            // DECIDES is this one. (18o U2: the tombstone too — the book and
            // her deletion of it can both land IN the first round the gate
            // waited for, which is the row's own "arrived by sync" road.)
            return try await withSeedLatch(session: session, book: book) {
                let known = try await session.database.read { db in
                    try facts(db, book: book, titles: titles, freshness: freshness)
                }
                if let decided = decidedWithoutMinting(known, titles: titles, save: save) {
                    return decided
                }
                let seeded = try await seed(
                    session: session, book: book, stories: stories, existing: known.existing, pacing: pacing)
                save(true)
                return .seeded(readingID: seeded.readingID, stories: seeded.minted)
            }
        } catch {
            return .refused(String(describing: error))
        }
    }

    /// The facts a launch read decides on, from ONE read transaction — what
    /// the store holds of the book (`discover`) and whether the reader deleted
    /// it (`readerDeletedTheBook`) — so they can never disagree. VX-633 U2b
    /// (R-633-16): for a book that seeds fresh stores alone, a third, read in
    /// the same transaction — whether the store is an EXISTING one
    /// (`SampleLibraryFreshStore.mayMint` answered no: a settled store, or one
    /// that has held writing and holds no partial copy of this book's own to
    /// complete). Always false for every other book, whose reads are
    /// byte-unchanged (nothing more is read for them).
    nonisolated private static func facts(
        _ db: Database, book: Book, titles: [String], freshness: SampleLibraryFreshness
    ) throws -> (existing: Existing, readerDeleted: Bool, existingStore: Bool) {
        let existing = try discover(db, book: book)
        let readerDeleted = try readerDeletedTheBook(db, book: book)
        var existingStore = false
        if book.seedsFreshStoresOnly {
            let resuming = SampleLibraryFreshStore.isResuming(
                bookExists: existing.bookID != nil, presentTitles: existing.presentTitles,
                shippedTitles: [book.frontMatterTitle] + titles)
            existingStore = try !SampleLibraryFreshStore.mayMint(freshness, resuming: resuming) {
                try SampleLibraryFreshStore.storeIsFresh(db, ownBook: book.name)
            }
        }
        return (existing, readerDeleted, existingStore)
    }

    /// **What the facts decide WITHOUT a mint — asked at both of the launch's
    /// reads.** A whole copy is present, first: nothing to mint, whatever an
    /// older tombstone says (a book she deleted and then restored). Else a
    /// tombstoned reading of the name is HER word — 18o U2, R-18k-5
    /// (QUESTIONS #138(f)): *honour the tombstone at launch*, exactly as the
    /// tutorial door's silent ensure already does (pre-13x F3, MINOR-N3) —
    /// and the decision is RECORDED in this device's mark while the evidence
    /// stands (RUN A A2's rule — a purge removes the tombstone, and the mark
    /// is then what remembers). A partial live copy beside a tombstone is NOT
    /// healed here, the ensure's answer too: it is a copy arriving from a
    /// device that restored the book (sync brings the rest), or residue of a
    /// re-mint only the pre-18o launch could make; Help ▸ Restore completes
    /// either on request. **VX-633 U2b (R-633-16):** then, for a book that
    /// seeds fresh stores alone, an EXISTING store declines — recorded the
    /// same way — AFTER both answers above, so a whole copy still reads
    /// present and her deletion still reads as hers. `nil` = nothing decided:
    /// seed what is missing.
    private static func decidedWithoutMinting(
        _ facts: (existing: Existing, readerDeleted: Bool, existingStore: Bool),
        titles: [String],
        save: (Bool) -> Void
    ) -> Outcome? {
        if facts.existing.isComplete(for: titles) {
            save(true)
            return .alreadyPresent
        }
        if facts.readerDeleted {
            save(true)
            return .deletedByTheReader
        }
        if facts.existingStore {
            save(true)
            return .existingStore
        }
        return nil
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
    /// What `seed` minted — the book (existing or fresh) and the count of
    /// notes minted. pre-13x ladder round 2, F3 (NIT-N6): `seed` used to
    /// answer the launch seeder's whole `Outcome` though it could only ever
    /// return `.seeded`, so every caller carried an unreachable arm (the
    /// restore road's dumped it raw); now it answers what it did, by type.
    struct Seeded: Equatable, Sendable {
        var readingID: String
        var minted: Int
    }

    ///
    /// **18l-c U6 — the scripted note.** A book's plan may carry ONE note
    /// minted by a scripted history (takemania): it gets ONE runner turn of
    /// its own (so cancellation, which lands only between turns, can never
    /// split its history), its history runs on a clock RELATIVE to this
    /// seed's own `now` (read here from `\.date`, outside the book's clock),
    /// and before it mints, the seeder's own half-built note from a stopped
    /// earlier history goes to the Trash. `interruptScriptAfterStep` is the
    /// pins' seam for that stopped history — nil in production.
    ///
    /// **VX-633 — chapters by NAME across turns, and the take pass.** A note's
    /// chapter is `book.grouping`'s answer (its own title for every book
    /// before the Prince; the Prince's PART), and the seed remembers every
    /// chapter it reuses or mints as it goes, so the eleven notes of a part
    /// share ONE section row — the m5 reuse-by-name rule, extended from "a
    /// cancelled run's chapter" to "this run's chapter". A book with a
    /// `takePass` loads its companion text ONCE, before anything is minted
    /// (a build missing it throws `resourceMissing` with nothing written),
    /// and runs the pass on each FRESHLY imported note inside that note's own
    /// runner turn — so cancellation can never leave a note without its
    /// takes; a re-membered or copied note is never passed again.
    @discardableResult
    static func seed(
        session: AppSession, book: Book = .sherlock, stories: [Story], existing: Existing,
        pacing: Pacing? = nil, interruptScriptAfterStep: Int? = nil
    ) async throws -> Seeded {
        let bookName = book.name
        let tagName = book.tagName
        let frontChapter = book.frontMatterChapter
        let frontTitle = book.frontMatterTitle
        let frontText = book.frontMatterText
        let profile = book.profile
        let label = Self.undoLabel
        let present = existing.presentTitles
        // VX-633: every chapter this seed knows by name — what discovery
        // found, plus what each turn reuses or mints (read back after it).
        var chapterIDs = existing.chapterIDsByName
        let strays = existing.strayNoteIDsByTitle
        // 13i-d ladder B fix C: everything the seed mints lives where the
        // book lives ('' = Home when none exists — the fresh seed's shape).
        let wing = existing.wing

        // The book's own clock (Sherlock: 1892 — m6), or the ambient one.
        let clock = book.clock

        // VX-633: the take pass's companion text, parsed once and off the
        // main actor, BEFORE the skeleton turn — a missing companion throws
        // with nothing minted.
        let takePass = book.takePass
        let companion: [String: [String]]
        if let takePass {
            companion = try await Task.detached(priority: .utility) {
                try takePass.loadCompanion()
            }.value
        } else {
            companion = [:]
        }

        // Turn 1: the book, the tag, and the front matter.
        await pacing?()
        let chapters = chapterIDs
        let skeleton = try await session.runner.run {
            _ -> (book: String, tag: String, frontChapter: String?) in
            try Self.underClock(clock) {
                let quiet = Operations(undoStack: nil)
                let bookID: String
                if let known = existing.bookID {
                    bookID = known
                } else {
                    bookID = try quiet.createReading(
                        name: bookName, kind: .book, profile: profile).id
                }
                let tagID = try existing.tagID
                    ?? quiet.createTag(name: tagName, wingID: wing).id
                var frontSectionID: String?
                if !present.contains(frontTitle) {
                    // m5: reuse a chapter a cancelled run already left behind,
                    // never mint a second one wearing the same name.
                    let sectionID = try chapters[frontChapter]
                        ?? quiet.createSection(in: bookID, name: frontChapter).id
                    try Self.place(
                        quiet, title: frontTitle, text: frontText, stray: strays[frontTitle],
                        in: bookID, wing: wing, section: sectionID, tag: tagID, label: label)
                    frontSectionID = sectionID
                }
                return (bookID, tagID, frontSectionID)
            }
        }
        if let frontSectionID = skeleton.frontChapter { chapterIDs[frontChapter] = frontSectionID }

        // 18l-c U6: the scripted note's "now" — read once, OUTSIDE the book's
        // clock, so its history lands relative to this seed (the tray and the
        // janitor age tombstones by the 30-day window; `Takemania`'s header).
        @Dependency(\.date) var date
        let anchor = date.now
        let halfBuilt = existing.halfBuiltNoteIDs

        // One turn per note, in the book's order.
        var minted = 0
        for entry in plan(for: book, stories: stories) where !present.contains(entry.title) {
            try Task.checkCancellation()
            await pacing?()
            let bookID = skeleton.book
            let tagID = skeleton.tag
            let stray = strays[entry.title]
            let chapters = chapterIDs
            switch entry {
            case .story(let title, let text):
                let chapter = book.grouping.chapter(for: title)
                let turn = try await session.runner.run {
                    _ -> (section: String, pass: SampleLibraryPrinceBook.PassReport?) in
                    try Self.underClock(clock) {
                        let quiet = Operations(undoStack: nil)
                        // m5, again: a run cancelled between `createSection` and
                        // `importPost` left this story's chapter standing empty
                        // — and (VX-633) a part an earlier note of THIS run
                        // minted is reused by name, never doubled.
                        let sectionID = try chapters[chapter]
                            ?? quiet.createSection(in: bookID, name: chapter).id
                        let minted = try Self.place(
                            quiet, title: title, text: text, stray: stray,
                            in: bookID, wing: wing, section: sectionID, tag: tagID, label: label)
                        // VX-633: the take pass, in THIS turn — only on a note
                        // this turn imported (a re-membered stray or a copy
                        // already carries its takes).
                        var pass: SampleLibraryPrinceBook.PassReport?
                        if let minted, let takePass {
                            pass = try takePass.apply(
                                quiet, title: title, note: minted, companion: companion)
                        }
                        return (sectionID, pass)
                    }
                }
                chapterIDs[chapter] = turn.section
                if let skipped = turn.pass?.skipped, !skipped.isEmpty {
                    // Release only (a DEBUG build stopped at the first one):
                    // the note seeded with the takes that DID match.
                    log.error("sample library (\(book.name, privacy: .public)): take pass skipped \(skipped.count): \(skipped.joined(separator: " | "), privacy: .public)")
                }
            case .scripted(let scripted):
                try await session.runner.run { _ in
                    let quiet = Operations(undoStack: nil)
                    let sectionID = try Self.underClock(clock) {
                        try chapters[scripted.chapter]
                            ?? quiet.createSection(in: bookID, name: scripted.chapter).id
                    }
                    // F10 holds for the scripted note too: a surviving note
                    // (the book deleted, the note kept) is RE-MEMBERED, with
                    // whatever history she has given it since.
                    if let stray {
                        _ = try Self.underClock(clock) {
                            try Self.place(
                                quiet, title: scripted.title, text: "", stray: stray,
                                in: bookID, wing: wing, section: sectionID, tag: tagID, label: label)
                        }
                        return
                    }
                    // Design call 3's heal: a history stopped before its last
                    // act left a note under the reserved working title — it
                    // goes to the Trash (30 days, Put back) before a whole one
                    // is minted.
                    try withDependencies { $0.date = .constant(anchor) } operation: {
                        for noteID in halfBuilt { try quiet.deleteContainer(noteID) }
                    }
                    _ = try scripted.mint(
                        quiet, anchor: anchor, bookID: bookID, sectionID: sectionID,
                        tagID: tagID, interruptAfterStep: interruptScriptAfterStep)
                }
            }
            minted += 1
        }
        return Seeded(readingID: skeleton.book, minted: minted)
    }

    /// The seed's clock scope: a book with a clock of its own mints every
    /// row under it (Sherlock's m6); a book without one mints on the
    /// ambient clock (the tutorial's shape).
    nonisolated private static func underClock<T>(
        _ clock: Date?, _ body: () throws -> T
    ) rethrows -> T {
        guard let clock else { return try body() }
        return try withDependencies({ $0.date = .constant(clock) }, operation: body)
    }

    /// Puts one shipped note into the book: a surviving tagged note is
    /// RE-MEMBERED (F10 — it already wears the tag and carries whatever she
    /// did to it); only a title with no such note mints afresh. VX-633:
    /// answers the FRESH import (the note and its blocks in placement order —
    /// the take pass's input), nil when it re-membered or copied a note it
    /// did not mint.
    @discardableResult
    nonisolated private static func place(
        _ quiet: Operations, title: String, text: String, stray: String?,
        in bookID: String, wing: String, section sectionID: String, tag tagID: String,
        label: String
    ) throws -> ImportedNote? {
        let noteID: String
        var minted: ImportedNote?
        if let stray {
            noteID = stray
        } else {
            // The 18l-c U6 ladder's R2-M2: the book's refusals (finished, at
            // its note cap, gone, wrong kind) BEFORE the mint — the
            // `assertReadingAcceptsPosts` gate exists for exactly this road,
            // read inside the same serialized runner turn. Without it a
            // restore into a finished book imported the note, tagged it, and
            // THEN had the membership refused: one tagged orphan left in the
            // Pool per missing note (the scripted note's F1 class, bounded
            // here because the next press re-members it as a stray).
            try quiet.assertReadingAcceptsPosts(bookID)
            // 13i-d ladder B fix C: born in the BOOK's wing — a book she
            // moved restores where it lives (a Home-born mint met the
            // membership guard's `crossWingMembership` partway, with a
            // "try again" that could never succeed).
            let imported = try quiet.importPost(
                title: title, text: text, undoLabel: label,
                segmentation: Self.segmentation, wingId: wing)
            noteID = imported.container.id
            minted = ImportedNote(noteID: noteID, blockIDs: imported.blockIDs)
            _ = try quiet.applyTag(tagID, toPost: noteID)
        }
        // 13i-d U7 continuation — F-U7-3, RULED re-add-as-COPY (the ownership
        // doctrine's own answer, 13i-c §6): a STRAY that now lives in another
        // book can meet the consult — an OWNED target (`noteMemberedElsewhere`,
        // the seeded Sherlock owns its notes since U7) or a story owned
        // ELSEWHERE (`noteOwnedElsewhere`). The restore never severs her book
        // and never fails with a "try again" that cannot succeed: the story
        // comes back as a COPY (its family, tags riding, lineage kept); her
        // book keeps the original.
        let memberID: String
        do {
            _ = try quiet.addPostToReading(noteID, to: bookID)
            memberID = noteID
        } catch let refusal as OperationError {
            switch refusal {
            case .noteMemberedElsewhere, .noteOwnedElsewhere:
                memberID = try quiet.copyPostIntoReading(noteID, into: bookID).copy.id
            default:
                throw refusal
            }
        }
        try quiet.assignPostToSection(memberID, in: bookID, section: sectionID)
        return minted
    }
}
