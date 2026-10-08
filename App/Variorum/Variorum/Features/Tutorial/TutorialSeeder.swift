//
//  TutorialSeeder.swift
//  Variorum
//
//  Phase 13b, Stage 2 (R113/P-6): THE tutorial — a curated BOOK built of
//  the app's own objects. Real chapters (`reading_section` rows), lessons
//  as act-ready posts, instructions in the prose: the app teaches itself
//  WITH itself, and by the time the reader has read the book she has used
//  books, chapters, posts, and blocks. The tutorial is the executable
//  spec: `TutorialWalkTests` executes every lesson's acts headlessly, and
//  the scripted screenshot walk drives them in the real app.
//
//  Seeding is a PRODUCT DOOR (Help ▸ Restore Tutorial…, registry-declared,
//  fire-and-DO): idempotent, replace-wholesale after a spoken confirm,
//  everything deletable like any post or book. Identity is the app's own
//  machinery — every lesson post wears the `tutorial` tag, the book and
//  the scrap pool carry reserved names; the tags lesson SAYS so, so the
//  mechanism is also the teaching.
//
//  Every write goes through Operations (never ad-hoc rows); all content is
//  NON-JOURNAL (`.generic`, no entry dates — R57: journal-shaped rows are
//  the daily Journal's assembly, and no tutorial text may ever land in it;
//  the rule's original reason, the Fragments bridge's day sweep, retired
//  2026-09-04 — the rule stays).
//
//  This absorbs the Phase 11 A10 modes tutorial: its polish-in-place /
//  thread-one-piece / fork-the-piece teaching is now the "three ways of
//  working" lesson, and the old entrances open this book (supersession
//  recorded in the Stage 2 closeout).
//

import Foundation
import GRDB
import OSLog
import VariorumCore

enum TutorialSeeder {
    // MARK: - Reserved identities (how Restore finds its own objects)

    nonisolated static let bookName = "the field guide"
    nonisolated static let tagName = "tutorial"
    nonisolated static let scrapPoolTitle = "tutorial scraps"

    /// The versions lesson's twin note — a `duplicateAsVersion` copy the
    /// seed renames so the ⌘K palette never shows two identical rows (the
    /// U7 walk finding). ONE constant since 17y B-DEDUPE: the mint and the
    /// furniture fold's reserved-title facts read the same spelling.
    nonisolated static let twinTitle = "compare & versions \u{2014} the twin"

    /// **17y B-DEDUPE (R-17y-5): the GUIDE half of the furniture-fold
    /// facts** — appended to the shared half at the Mac's `AppServices`
    /// construction (the engine's `furnitureFacts`; the phone passes
    /// nothing — its pocket guide is the recorded MOBILE PARITY row). The
    /// guide book folds by pairwise content identity; the scraps pool and
    /// a BOOKLESS twin fold at container grain (a twin membered in its
    /// guide rides the book's own fold).
    nonisolated static func furnitureFactsHalf() -> (
        guideBookName: String, guideTagPath: String,
        containers: [SeededFurnitureDedupeFacts.ReservedContainer]
    ) {
        (bookName, tagName, [
            .init(title: scrapPoolTitle, kind: "pool", seedTagPaths: [tagName]),
            .init(title: twinTitle, kind: "post", seedTagPaths: [tagName]),
        ])
    }

    /// **17y B-DEDUPE (the B2 ladder's MAJOR-2): the getting-around lesson's
    /// mode-row sentence, DERIVED from the (p) seam** (`PostMode` — the one
    /// place the build's mode order lives), so the seeded guide can never
    /// teach a mode the build lacks: Release reads six modes and ⌘1–⌘6,
    /// Debug keeps all seven. The count's word stays prose (13s re-voices).
    nonisolated static func modeRowSentence(
        keepingCanvas: Bool = PostMode.buildKeepsCanvas
    ) -> String {
        let count = PostMode.order(keepingCanvas: keepingCanvas).count
        let word = count == 7 ? "seven" : count == 6 ? "six" : "\(count)"
        // 13s-b triage landing (R-13s-30): the template re-voiced; the seam's
        // three calls are untouched.
        return "A note opens into one of \(word) modes. The tabs read "
            + PostMode.modeList(keepingCanvas: keepingCanvas) + ", and "
            + PostMode.keySpan(keepingCanvas: keepingCanvas)
            + " switch between them. The first time, a note opens in Write, the "
            + "plain full page; after that it remembers the mode you left it in. "
            + "The rest of this book visits each mode where it earns its keep."
    }

    /// **17y B-DEDUPE (MAJOR-2), the same seam for the "ways of looking"
    /// chapter's last lesson:** Release (no Canvas) gets the workbench
    /// lesson alone — title "blocks", two paragraphs; Debug keeps the
    /// canvas teaching whole. One pure function, so the mint, the plan and
    /// the pins read the same shape in both flavors.
    nonisolated static func lookingLessonContent(
        teachesCanvas: Bool = PostMode.buildKeepsCanvas
    ) -> (title: String, paragraphs: [String]) {
        // 13s-b triage landing (R-13s-30): both flavors re-voiced from the
        // approved draft; the seam (the title, the intro variant, the canvas
        // pair) still derives from `teachesCanvas` alone.
        var paragraphs: [String] = [
            teachesCanvas
                ? "Two more ways of looking, each a different traversal of the same "
                  + "note: nothing is ever copied into a view. (Outlining lives in "
                  + "Compare now: an outline is just a related note beside its draft, "
                  + "the previous lesson's \u{201C}make outline note\u{201D}.)"
                : "One more way of looking, a different traversal of the same note: "
                  + "nothing is ever copied into a view. (Outlining lives in Compare "
                  + "now: an outline is just a related note beside its draft, the "
                  + "previous lesson's \u{201C}make outline note\u{201D}.)",

            // 13b 4D (N39 + N32(a)) + wave 2c (item 16, W8-1 direction C):
            // the workbench, taught where the doors live. (The old
            // table-of-contents half of this lesson lives in Read's edit
            // face now.)
            "Blocks (\u{2318}6) is the workbench: the note's blocks as objects. "
            + "Every row shows what it carries: takes, comments, words, tags, a "
            + "lock, when it last moved. Click a row and its panel opens on the "
            + "right. Edit the text there, see its takes, or jump onward (Write, "
            + "Takes, its history). \u{2318}-click picks several, and the bar "
            + "above acts on all of them at once: merge, tag, archive, delete, "
            + "move out to snippets. One \u{2325}\u{2318}Z takes the whole act "
            + "back. Rows reorder with \u{2191} \u{2193}, or the row's \u{22EF} "
            + "menu moves by position: top, bottom, or the number you type. Move "
            + "out to snippets does what it says: the block leaves this note and "
            + "becomes a snippet there (a block lives in one place; "
            + "\u{2325}\u{2318}Z brings it back).",
        ]
        if teachesCanvas {
            paragraphs += [
                // 13b 4E (N30/S4-7): the canvas package, taught whole.
                "Canvas (\u{2318}7) scatters the blocks as sticky-note cards. They "
                + "open in a tidy grid until you arrange them; drag a card by its "
                + "\u{2823} header (arrangement is yours and is remembered; the "
                + "note's order doesn't move) and resize it from the corner grip. "
                + "Click into a card and type: edits land on the take the card is "
                + "showing. The little number in a card's corner is the block's place "
                + "in the note's current order.",

                "The canvas has one door back into order: \u{201C}order by "
                + "clicking\u{201D}. Click cards in the order the note should read "
                + "(each shows its number as you go), then Apply once: the numbered "
                + "cards lead the note and everything else keeps its relative order "
                + "after them (\u{2325}\u{2318}Z undoes; Cancel changes nothing). "
                + "\u{201C}Fit all\u{201D} shows every card at once; bigger boards "
                + "open a read-only overview, and a click on any card lands back on "
                + "it. The \u{2039} \u{203A} switcher on a card flips which take "
                + "you're viewing (\u{201C}viewing \u{2014} not what the note "
                + "shows\u{201D}); choosing stays a separate, deliberate \u{2713}.",
            ]
        }
        return (teachesCanvas ? "blocks \u{B7} canvas" : "blocks", paragraphs)
    }

    /// What the confirm sheet says before a wholesale replace — plain
    /// words, exact scope (the spoken confirm, brief decision 6; the
    /// Stage 2 ladder's MINOR-D3/D4 accuracy pass: the copy discloses the
    /// EXACT tag and the PLURAL name-based scope, because cleanup deletes
    /// every same-named book and pool — a user's colliding names included,
    /// accept-and-document per the architect's recorded call).
    nonisolated static let replaceQuestion = "Restore the tutorial?"
    /// 13i-d U7 (the walk's W-1): the door now composes the Welcome
    /// arrangement too, so the disclosure names it — exactly, the MINOR-D3/D4
    /// rule — before it promises the rest is untouched (PROVISIONAL wording).
    /// 13s-b U1b: the arrangement no longer makes the classics gathering or
    /// a quick note (R-13s-5/37), so the disclosure stopped claiming it.
    nonisolated static let replaceDetail =
        "This replaces the tutorial with a fresh copy: every note tagged exactly "
        + "\u{201C}\(tagName)\u{201D}, every pool named \u{201C}\(scrapPoolTitle)\u{201D}, and every book "
        + "named \u{201C}\(bookName)\u{201D} are deleted and re-seeded. It also sets up the "
        + "\(Operations.welcomeShelfName) shelf the books chapter walks: the seeded books that sit "
        + "unshelved go onto it, the classic books' shipped notes are tagged "
        + "#\(SampleLibrarySeeder.classicsTagPath), and \u{201C}\(SampleLibrarySeeder.bookName)\u{201D} owns its "
        + "notes if none of them lives in another book. Nothing else is touched."

    // MARK: - The lesson plan (the coverage CONTRACT, walk-asserted)

    /// Chapters and lessons, in book order. `TutorialWalkTests` asserts the
    /// seeded book matches this exactly — a lesson that drifts out of the
    /// seed (or a seed that drifts out of the plan) is a red test, and the
    /// scripted screenshot walk drives this same list.
    nonisolated static let plan: [(chapter: String, lessons: [String])] = [
        // 13g L1 (WT-1): "the workspace" JOINS the plan. Phase 13f built
        // windows, the split, the Open list, history, stars and the quick
        // note — and no lesson taught any of it, so her walkthrough ended
        // at *"i don't even konw how to get to any of the things that built
        // last phase."* It sits second, right after "getting around", where
        // the sidebar has just been introduced and the next honest question
        // is "can I see two of these at once".
        // 13s-b triage landing (the U3 RECORD's disposition 4): "three ways
        // of working" moved up from the library chapter's tail to close the
        // welcome chapter — the map, read before the details.
        ("welcome", ["start here", "getting around", "the workspace",
                     "three ways of working"]),
        // 13g L12: "formatting" joins WRITING, after the two lessons that
        // teach what a block IS — the vocabulary is about what a line of
        // text LOOKS like, so it belongs after blocks and before takes.
        ("writing", ["blocks & typing", "shaping blocks", "formatting"]),
        ("takes", ["your first take", "choosing & the board", "keeping takes safe"]),
        ("structure", ["divide", "divide choosing takes", "extract & make block",
                       "merge", "the two undos"]),
        // 13j J10 — **THE DELETION CHAPTER** (her instruction, verbatim:
        // *"the tutorial also needs to be updated more throughly in 13j to
        // encourage users to delete blocks during the tutorial … guide users
        // through cross block deletion, restoral, etc."*). It sits where its
        // prerequisites have just landed: blocks and takes exist, divide and
        // the two undos were the last thing read, and the honest next
        // question after "how do I cut this up" is "how do I throw a piece
        // away — and how do I get it back". Every lesson has the reader
        // delete something on purpose; the walk executes each act.
        ("deleting & getting it back",
         ["deleting blocks", "archive \u{B7} delete \u{B7} scraps",
          "the tray & the Trash", "what a block leaves behind"]),
        // THE POST-13L POLISH ROUND, ledger row 19 (G4) — **THE MAP**. Her
        // third-sitting expansion, verbatim: *"the next polish session should
        // definitely add a new tutorial chapter about this… the user should be
        // encouraged to get comfortable with each of the"* places. And her
        // stated fear is why it exists at all: *"people are going to conclude
        // that the one thing they really want (my whole note at this point in
        // time) … is way too hard to get, even though we're actually offering
        // infinitely more ways of saving your ideas."*
        //
        // It sits AFTER the deletion chapter because it is that chapter's
        // answer widened: the reader has just learned where a deleted block
        // goes, and the honest next question is "so where does everything
        // else go" — including the two places the round built (a note's
        // Versions, a block's History) and the one the app never had to build
        // (where you left it).
        // 13u3 UNIT E (item 15(b)) — "what a copy carries" joins the map
        // chapter, on the far side of ⌘⇧S: the previous lesson tells her the
        // chord copies the note, and this one is what makes that sentence
        // true rather than nearly true (her words: *"you're only saving the
        // placed notes - not the history that rides with it"*).
        ("where things go",
         ["the five places", "saving a moment", "what a copy carries",
          "the two exits"]),
        // PHASE 13p, knot 6 — **THE PRIVACY CHAPTER**. Her ruling,
        // verbatim: *"yes, short chapter, and make the options that are in
        // settings clear (require lock every time to open, don't, what you
        // need to reset it, saving it in keychain or not, etc.). It should
        // also be clear to a user everything they have to lose to lose
        // their writing AND that there's an option for a plaintext backup
        // if they want. basically give them their options in a non scary
        // way, but in a serious way."*
        //
        // It sits right after "where things go" because that chapter is
        // the recovery map, and this one is the same map's other face: the
        // reader has just learned every place their writing is kept, and
        // the honest next questions are "who else can read it" and "what
        // would it take to lose it for good". Two lessons — SHORT, as she
        // ruled.
        //
        // pre-13x 5a (copy §7 — the postures design §1.22): the SHORT
        // chapter re-seeded as copy §7's two lessons, VERBATIM from the copy
        // constants both seeders render (`ProtectionCopy.privacyLesson…`);
        // the walk asserts copy §7's own parenthetical — both modes, both
        // floors, keystone 3, keystone 4, and the book's door — so the
        // chapter cannot drift from the copy file's facts. The full story
        // is the seeded book *Encryption Explained*.
        ("keeping it private",
         [ProtectionCopy.privacyLessonOneTitle, ProtectionCopy.privacyLessonTwoTitle]),
        // 17y B-DEDUPE (MAJOR-2): the last lesson's title follows the BUILD
        // — Release (no Canvas after (p)) titles it "blocks"; the mint and
        // this plan read the ONE pure function, so the shape pins stay in
        // lockstep in both flavors.
        ("ways of looking", ["read", "lenses", "compare & versions",
                             lookingLessonContent().title]),
        // 13i-d U7: "books & the shelf" LEFT this chapter — its content moved
        // (swept) into the books chapter below as "a book from the inside".
        // VX-89 (R-VX83-3 — her *"add the content to the field guide now,
        // with whatever information a user needs for it"*): "search" JOINS,
        // right after the lesson that teaches tags — the finder leans on
        // them (`#tag` alone narrows the Library to the notes wearing it).
        ("the library of things", ["comments & tags", searchLessonTitle,
                                   "pool & scraps", "export — it's all yours",
                                   "the seal"]),
        // 13i-d U7 — **THE BOOKS CHAPTER** (the sitting record §25, written at
        // her instruction as SECONDARY ACCEPTANCE CRITERIA: "every lesson is a
        // sentence the field guide must be able to say TRUTHFULLY of the
        // shipped build"). The eleven lesson sentences and the five rituals,
        // in the guide's card form; `TutorialBooksChapterTests` executes each
        // sentence's truth and every ritual headless. It sits LAST: it leans
        // on tags (the library of things) and on everything a note can do.
        // Lesson 9's second sentence (archive · can't delete · comes back) is
        // 13i-e's unbuilt guard and is withheld until it ships (F-U7-2).
        (booksChapter, ["the classics walk", "a book from the inside",
                        "membership, not ownership", "gatherings & arrivals",
                        "owned, finished, sealed", "the bookcase",
                        "the journal & the pool", "wings"]),
    ]

    /// The books chapter's name, in one place (the plan, the section and the
    /// chapter's suite mean the same words).
    nonisolated static let booksChapter = "books & the bookcase"

    /// **VX-89 — the finder's lesson**, its title in one place (the plan, the
    /// seed and `TutorialCurrencyTests`' search pins mean the same words).
    nonisolated static let searchLessonTitle = "search"

    /// The word the search lesson's practice paragraph carries TWICE, so a
    /// search for it answers with that paragraph alone and ⌘G has a second
    /// one to step to (the act is walk-asserted — P-6). The prose spells it
    /// plainly; the pin ties the two.
    nonisolated static let searchPracticeWord = "marginalia"

    // MARK: - Discovery (reads — the doomed set for a wholesale replace)

    /// ONE discovery per door entrance (Stage 2 ladder, MAJOR-A): the
    /// confirm gates on `isEmpty` — the SAME predicate as the destruction —
    /// and the SAME `Existing` flows into the replace, so what the user
    /// confirmed is exactly what dies (no second read, no TOCTOU).
    struct Existing: Sendable {
        var readingIDs: [String] = []
        var taggedPostIDs: [String] = []
        var poolIDs: [String] = []
        var tagID: String?
        var isEmpty: Bool {
            readingIDs.isEmpty && taggedPostIDs.isEmpty && poolIDs.isEmpty
        }
    }

    nonisolated static func discover(_ db: Database) throws -> Existing {
        var existing = Existing()
        existing.readingIDs = try Queries.readings(db)
            .filter { $0.name == bookName }
            .map(\.id)
        if let tag = try Queries.allTags(db).first(where: { $0.path == tagName }) {
            existing.tagID = tag.id
            // The EXACT tag, never the subtree (MINOR-D3): the seeder only
            // ever applies `tutorial` itself — a post tagged `tutorial/…`
            // is hers, and the confirm's disclosure must stay true.
            existing.taggedPostIDs = try Queries
                .everythingTagged(db, tagID: tag.id, includeSubtree: false)
                .postIDs
        }
        existing.poolIDs = try Queries.pools(db)
            .filter { $0.title == scrapPoolTitle }
            .map(\.id)
        return existing
    }

    // MARK: - The doors

    /// Open door: an existing book simply opens. No book but tutorial
    /// RESIDUE (tagged lessons, the scrap pool a deleted book left behind)
    /// ⇒ the restore path, `confirmReplace` included (MINOR-D5/MAJOR-A:
    /// seeding beside residue minted a second "tutorial scraps" pool —
    /// titles aren't unique — and kept orphaned old lessons beside fresh
    /// ones; and the residue may include HER tagged posts, hers to refuse
    /// for). Nothing at all ⇒ a pure fresh seed (cleanup over an empty
    /// discovery is a no-op, so it is the same one shape). Returns nil
    /// when the confirm declined.
    @MainActor
    static func findOrSeed(
        session: AppSession, confirmReplace: () async -> Bool
    ) async throws -> String? {
        try await findOrSeedReporting(session: session, confirmReplace: confirmReplace)?.bookID
    }

    /// `findOrSeed` that also says whether it SEEDED (13i-d U7): the open
    /// door composes the Welcome arrangement only when it minted the guide —
    /// the restore road — and never when an existing guide simply opened
    /// (opening a book is not a restore; no silent arrangement of a store).
    @MainActor
    static func findOrSeedReporting(
        session: AppSession, confirmReplace: () async -> Bool
    ) async throws -> (bookID: String, seeded: Bool)? {
        let existing = try await session.database.read { db in try discover(db) }
        if let bookID = existing.readingIDs.first { return (bookID, false) }
        // 13u4 UNIT S3 (row 67): the confirm is ASYNC now, because the app's
        // own answer to it is a SwiftUI `.alert` the window presents rather
        // than an app-modal `NSAlert.runModal()`. A synchronous closure still
        // satisfies this type, so every pin that answers `{ true }` here is
        // untouched.
        if !existing.isEmpty, await !confirmReplace() { return nil }
        return (try await restore(session: session, existing: existing), true)
    }

    /// Restore door: wholesale replace — cleanup by reserved identity,
    /// then a pristine seed. Idempotent by construction (discovery finds
    /// whatever a partial earlier run left behind). The caller passes the
    /// SAME `Existing` its confirm disclosed (MAJOR-A).
    @MainActor
    @discardableResult
    static func restore(session: AppSession, existing: Existing) async throws -> String {
        try await session.runner.run { _ in
            // MINOR-D1: the seed is not HER act — nothing here may land on
            // the session's structural-undo stack (⌥⌘Z must never pop an
            // inverse for an act she never performed; the twin's
            // `duplicateAsVersion` registers one). The seeder runs through
            // a QUIET Operations facade: the same ambient database the
            // session's own Operations reads, the same serialized runner
            // turn, NO undo stack.
            let quiet = Operations(undoStack: nil)
            cleanup(ops: quiet, existing: existing)
            return try seed(ops: quiet, existingTagID: existing.tagID)
        }
    }

    /// One-discovery convenience for direct callers (tests, the walk).
    @MainActor
    @discardableResult
    static func restore(session: AppSession) async throws -> String {
        let existing = try await session.database.read { db in try discover(db) }
        return try await restore(session: session, existing: existing)
    }

    // MARK: - The birth seed (17y B-SEED — item (q))

    /// What a fresh store's birth did about the guide. Recorded (one log
    /// line), never surfaced — furniture is silent.
    enum BirthSeed: Equatable {
        /// Minted the pristine guide (the restore road over an empty store).
        case seeded(bookID: String)
        /// A live guide already stands (arrived by sync, or the interrupted
        /// launch this one resumes already made it) — nothing minted.
        case alreadyPresent
        /// A reading of the guide's name is TOMBSTONED — her deletion,
        /// honoured (the seeded books' rule, `readerDeletedTheBook`'s shape).
        case deletedByTheReader
        /// Tutorial RESIDUE with no guide (notes tagged exactly `tutorial`,
        /// the scraps pool): replacing it is the doors' CONFIRMED road
        /// (MAJOR-A / MINOR-D5), never silent furniture's — nothing touched.
        case residue
        /// A tutorial door holds the latch — it seeds and arranges the guide
        /// itself; the launch yields rather than racing it.
        case doorInFlight
        /// The store said no. Recorded, never surfaced; the doors still mint.
        case refused(String)
    }

    private static let birthLog = Logger(subsystem: "io.lduarte.Variorum", category: "tutorial")

    /// **THE GUIDE AT A FRESH STORE'S BIRTH** (17y B-SEED — her report: the
    /// field guide was the one seeded thing missing on a fresh store; §19.3
    /// "Welcome = the field guide + the classics trio"; the 13i-d U7 brief
    /// "fresh stores get it at birth"). The launch hands this to
    /// `SampleLibraryWelcome.arrangeAtLaunch(beforeArranging:)`, so it runs
    /// ONLY on the arrangement's arrange-now road (a fresh birth under the
    /// sync gate, or the `pending` resume of one) — never on an existing
    /// store — and the arrangement then shelves the guide on Welcome.
    ///
    /// SILENT: no receipt, no navigation, no ask (R-13r-11 — the seed is
    /// furniture); the QUIET facade (the restore road — nothing on ⌥⌘Z);
    /// under the doors' latch; and one read decides, in the seeded books'
    /// order — a live guide wins, then her deletion, then residue; only a
    /// store with no trace of the tutorial at all is seeded.
    @MainActor
    @discardableResult
    static func seedAtBirth(session: AppSession) async -> BirthSeed {
        let outcome = await performBirthSeed(session: session)
        birthLog.notice("field guide at a fresh store's birth: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    @MainActor
    private static func performBirthSeed(session: AppSession) async -> BirthSeed {
        guard session.beginTutorialDoor() else { return .doorInFlight }
        defer { session.endTutorialDoor() }
        do {
            let (existing, deleted) = try await session.database.read { db in
                (try discover(db), try Queries.readingTombstoneExists(db, name: bookName))
            }
            if !existing.readingIDs.isEmpty { return .alreadyPresent }
            if deleted { return .deletedByTheReader }
            if !existing.isEmpty { return .residue }
            return .seeded(bookID: try await restore(session: session, existing: existing))
        } catch {
            return .refused(String(describing: error))
        }
    }

    /// Deletion is tombstones through Operations — everything recoverable
    /// through the ordinary recovery surfaces, like any post or book.
    /// Individual failures (a row already deleted, a race) are tolerated:
    /// the seed that follows is the goal.
    nonisolated static func cleanup(ops: Operations, existing: Existing) {
        for postID in existing.taggedPostIDs {
            try? ops.deleteContainer(postID)
        }
        for poolID in existing.poolIDs {
            try? ops.deleteContainer(poolID)
        }
        for readingID in existing.readingIDs {
            try? ops.deleteReading(readingID)
        }
    }

    // MARK: - The seed (all content; Operations only)

    /// Mints the whole book and returns its id. `existingTagID` reuses a
    /// live `tutorial` tag (createTag refuses duplicate live paths).
    nonisolated static func seed(ops: Operations, existingTagID: String?) throws -> String {
        let tagID: String
        if let existingTagID {
            tagID = existingTagID
        } else {
            tagID = try ops.createTag(name: tagName).id
        }

        let book = try ops.createReading(
            name: bookName, kind: .book, profile: "collection",
            wordTarget: 4000)

        // Chapters, in reading order.
        let welcome = try ops.createSection(in: book.id, name: "welcome")
        let writing = try ops.createSection(in: book.id, name: "writing")
        let takes = try ops.createSection(in: book.id, name: "takes")
        let structure = try ops.createSection(in: book.id, name: "structure")
        // 13j J10: the deletion chapter, between the structural acts that
        // make blocks and the ways of looking at them.
        let deleting = try ops.createSection(
            in: book.id, name: "deleting & getting it back")
        // The post-13l polish round (row 19): the map, right after the chapter
        // that raises the question.
        let places = try ops.createSection(in: book.id, name: "where things go")
        // Phase 13p, knot 6: the privacy chapter — the recovery map's
        // other face, right after it.
        let privacy = try ops.createSection(in: book.id, name: "keeping it private")
        let looking = try ops.createSection(in: book.id, name: "ways of looking")
        let library = try ops.createSection(in: book.id, name: "the library of things")
        // 13i-d U7: the books chapter — last.
        let books = try ops.createSection(in: book.id, name: booksChapter)

        /// One lesson: a `.generic` post inside the book, tagged, blocks in
        /// order. Returns the minted block results for act-ready shaping.
        func lesson(
            _ section: ReadingSection, _ title: String, _ paragraphs: [String]
        ) throws -> (post: Container, blocks: [Operations.NewBlockResult]) {
            let post = try ops.newPostInReading(
                book.id, section: section.id, title: title, profile: .generic)
            try ops.applyTag(tagID, toPost: post.id)
            var blocks: [Operations.NewBlockResult] = []
            for text in paragraphs {
                blocks.append(try ops.newBlock(in: post.id, text: text, at: .end))
            }
            return (post, blocks)
        }

        /// A second take on a block, with its own text.
        @discardableResult
        func take(on block: Operations.NewBlockResult, _ text: String) throws -> Variant {
            let minted = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(minted.id, text: text, charDelta: text.count)
            return minted
        }

        // ————————————————————————————— welcome —————————————————————————————

        _ = try lesson(welcome, "start here", [
            // 13s-b triage landing (R-13s-30 — her “I'll add some vision upfront
            // too”): the guide opens on what the app believes, in the product's own
            // canon words (choices kept open, nothing destroyed, a family tree not a
            // court record) — a NEW first block; the four that follow are the old
            // lesson, re-voiced.
            "Welcome. Variorum is built on a few beliefs about writing. A "
            + "paragraph should be able to hold more than one version of itself, "
            + "side by side, for as long as you want. Nothing you write should "
            + "ever be destroyed: deleting, dividing and merging are all moves "
            + "you can take back. And what the app remembers is your choices, "
            + "never your keystrokes. A family tree, not a court record. "
            + "Everything this book teaches follows from those beliefs.",

            // 13i-d U7 (F-U1-5): the area is the BOOKCASE (§7).
            "This book is Variorum teaching itself with itself. You are reading "
            + "a note, inside a chapter, inside a book on your Bookcase, and "
            + "these are the same objects everything you write will live in. Each "
            + "lesson asks you to do the thing it describes, right here in its "
            + "own text.",

            "Everything in this book is safe to play with. Cut it up, rewrite "
            + "it, delete it. Help \u{25B8} Restore Tutorial\u{2026} replaces the "
            + "whole book with a pristine copy whenever you want one. Nothing you "
            + "do here can touch your own writing.",

            "Two companions to know from the start. When the app answers you (a "
            + "result, a refusal, an undo report), the answer appears briefly at "
            + "the bottom of the window. And \u{2318}/ opens the Shortcuts & "
            + "Dictionary helper: every key the app listens for, and every word "
            + "it uses, in plain language.",

            "The chapters of this book are listed on the left. Read in order, "
            + "or jump to what itches. When something in a lesson doesn't behave "
            + "as the words promise, that is a bug in the app, not in you.",
        ])

        _ = try lesson(welcome, "getting around", [
            // 13i-d U7 (F-U1-5): the sidebar area is the BOOKCASE (§7).
            // librarywalkpolish VR-122 (F-1, F-2): the sidebar has had FIVE
            // places since the post-13l polish round added ARCHIVED
            // (`SidebarView.areas`), and the Library's views are List · Cards
            // · Timeline (17y (d)'s word). Words functional, 13s re-voices.
            "The sidebar has five places. Bookcase is home: your books, and a "
            + "dashed box that reads \u{201C}new note \u{2014} just start "
            + "typing\u{201D}. Type a first line there and \u{23CE} mints a note "
            + "and opens it. Library is everything, searchable, with List, Cards "
            + "and Timeline views. Pool holds notes that belong to no book yet. "
            + "Snippets holds loose scraps, pieces of text that aren't notes at "
            + "all. Archived keeps the notes and books you set aside: forever, no "
            + "clock.",

            "\u{2318}K finds anything: notes, books, blocks and commands. Type "
            + "a few letters and \u{23CE} opens the hit. \u{2318}N makes a new "
            + "note from anywhere. \u{2318}J opens today's journal entry; the "
            + "journal is its own daily notebook on the Bookcase.",

            // 13b 4D (S4-20): the first-open default is WRITE now; the
            // per-post memory is worth teaching in the same breath.
            // 17y B-DEDUPE (the B2 ladder's MAJOR-2): the sentence DERIVES
            // from the mode seam — the guide can never teach a mode the
            // build lacks (Release has no Canvas after (p); the helper's
            // own precedent). Words functional, 13s re-voices.
            modeRowSentence(),

            "Try it now: press \u{2318}K, type \u{201C}getting\u{201D}, and "
            + "\u{23CE} back to this very lesson. Then press \u{2318}2 for Takes "
            + "and \u{2318}1 for Write, and watch the same text wear both faces.",
        ])

        // 13g L1 (WT-1): the workspace lesson — everything Phase 13f built,
        // taught where a reader meets it. Every act named here is a shipped,
        // registry-declared door; the ⌘/ helper's "Windows & panes" group is
        // the same list in key form.
        _ = try lesson(welcome, "the workspace", [
            "One window can show two notes at once. Right-click any note row "
            + "\u{25B8} \u{201C}Open Beside\u{201D} and it opens in a second pane "
            + "next to this one; View \u{25B8} Open Beside does the same with the "
            + "note you had open most recently. Drag the seam between them to "
            + "resize, and View \u{25B8} Close Split folds back to one.",

            "Only one pane writes at a time. Click into a pane and it becomes "
            + "the live one: its text is the text you type in, while the other "
            + "reads quietly beside it. That is deliberate, and it is what keeps "
            + "a note with ten thousand words as quick as an empty one. A split "
            + "never shows the same note twice. To see one note two ways, use "
            + "Lenses (\u{2318}4) or Compare (\u{2318}5).",

            "Whole windows too: File \u{25B8} New Window opens another full "
            + "window, with its own sidebar, its own Open list and its own trail. "
            + "Right-click a note row \u{25B8} \u{201C}Open in New Window\u{201D} "
            + "opens just that note, sidebar-less, for when one piece deserves "
            + "its own screen.",

            // librarywalkpolish VR-122 (F-3): back/forward are ⌥⌘[ / ⌥⌘]
            // since 13u4 UNIT S1 (PROVISIONAL #130 — ⌘[ / ⌘] outdent and
            // indent); both sentences below taught the old pair.
            "The sidebar keeps an Open list of the notes this window has open, "
            + "in the order you opened them. \u{2318}\u{21E7}1 through "
            + "\u{2318}\u{21E7}9 jump straight to them, drag the rows to "
            + "rearrange, and \u{2715} closes a row and nothing else (the note is "
            + "untouched). \u{2325}\u{2318}[ and \u{2325}\u{2318}] walk back and "
            + "forward through where this pane has been, like a browser.",

            // 13k round 2 (R2-1, the WT-1 class): this sentence taught the
            // PRE-K11 bar (born folded, a chevron to unfold) — retired by
            // K11/K12 and R4-1. The lesson now teaches the shipped bar: the
            // constant four-door icon row, tag cards visible by default,
            // the ＃ (and ⌘⇧I) folding the CARDS, never the bar.
            // 13j batch 7 (the J10 content-refresh sweep): the bar's four
            // constant doors are unchanged (K11), but J2 added a fifth thing
            // to see there — the ⌫ tray badge, which appears only when the
            // note has deleted blocks. A lesson that inventories the bar and
            // omits a door that exists is the J8 bar's other half.
            // The Act 10 correction round, batch G (row 85 — A's residue):
            // this sentence taught the RETIRED masthead fold ("＃ folds the
            // note's tag cards away and back") and a four-door bar. Row 15
            // made the ＃ THE tag door — an inline field with the cursor in
            // it — on the MASTHEAD beside the cards; the bar's own row is
            // three doors (`ContextBarDoors.Door`: back · book · forward).
            "Above the page sits the context bar, always the same three doors: "
            + "\u{2190} and \u{2192} walk back and forward through where this "
            + "pane has been (\u{2325}\u{2318}[ and \u{2325}\u{2318}] are the "
            + "same doors), and the book glyph opens the book this note lives in, "
            + "at this very note. One more thing joins them only when there is "
            + "something to say: a note that has deleted blocks wears a quiet "
            + "\u{232B} badge with the count, and clicking it opens that note's "
            + "tray. The deleting chapter has the whole story. The note's tags "
            + "live on the masthead's right edge, under the tray, scraps and "
            + "references icons. Click the \u{FF03} beside the cards and a tag "
            + "field slides out with the cursor already in it: type a name, "
            + "\u{23CE} applies it (a \u{201C}/\u{201D} nests, like life/goals), "
            + "\u{238B} puts the field away, and \u{2318}\u{21E7}I opens the same "
            + "field from anywhere in the note.",

            // librarywalkpolish VR-122 (F-4): the RIGHT-CLICK row reads Star /
            // Unstar (`StarDoor.title`); "Toggle Star" is the ⌘K act's verb.
            // Written plainly — the pin reads `StarCopy.starRow` (the H pattern).
            // 13g cold review R1-2: batch 7 (R6-4) moved the quick note's
            // landing — tagged, into the smart Quicknotes book — and this
            // sentence kept teaching the Pool. The WT-1 class, in the very
            // lesson WT-1 minted.
            // 13u3 UNIT C (her R-13u-4): this sentence taught the model the
            // ruling replaced — "Return there makes a new line, not a new
            // note". Both capture boxes answer the same two keys now.
            // 13i-d U7 (F-U6-3): Quicknotes is a GATHERING (§1/§20) on the
            // BOOKCASE (§7) — it shows the note; it never holds it.
            // 13s-b U1b (R-13s-36/38): the lesson NAMES the default
            // gathering — the one constant, the lowercase fresh default.
            "Two more, for keeping and catching. Right-click any note or book "
            + "\u{25B8} \u{201C}Star\u{201D} pins it to the sidebar's top: up to "
            + "fifteen, meant for what you are in right now rather than as a "
            + "filing system. And \u{2318}\u{21E7}N pops the quick note, a small "
            + "floating pad that stays above your writing, also reachable from "
            + "the \u{270F}\u{FE0E} in the system menu bar while you are in "
            + "another app entirely. \u{23CE} there files what you wrote and "
            + "closes the pad; \u{21E7}\u{23CE} adds another paragraph, so a "
            + "capture can be as long as the thought is. They are the same two "
            + "keys the new-note box on the Bookcase answers. Closing the pad (or "
            + "\u{2318}\u{23CE}) files it too, and what you wrote is kept as a "
            + "note, tagged \u{201C}quicknote\u{201D}. The "
            + "\(Operations.defaultQuicknoteBookName) gathering on the Bookcase "
            + "shows it, and taking the tag off sends it back to the Pool.",

            "\u{2318}/ opens the Shortcuts & Dictionary helper, and its "
            + "\u{201C}Windows & panes\u{201D} group is this whole lesson in key "
            + "form, including the doors that have no key and live in a menu "
            + "instead.",
        ])

        // 13s-b triage landing (R-13s-30; the U3 RECORD's disposition 4 — her
        // “I'll look at moving it up, that sounds like it might be useful to move
        // up”): “three ways of working” MOVED from the library chapter's tail
        // to welcome's close — the map of the whole app, read before the
        // details (“the chapters ahead teach each road in full”). It still
        // absorbs the Phase 11 A10 modes tutorial; its practice take travels
        // with it, so the act works in this seat.
        let threeWays = try lesson(welcome, "three ways of working", [
            "Everything in this book comes down to three ways of working with "
            + "one piece of writing. This lesson is the map; the chapters ahead "
            + "teach each road in full.",

            "Polish in place: just write. Most text needs no machinery. Type, "
            + "autosave keeps up, and commit \u{2318}S marks the moments you want "
            + "to be able to come back to. If your text looks like basic text, it "
            + "behaves like basic text.",

            "Thread one piece: when one block is the question, fan it. Takes "
            + "hold the attempts side by side; the \u{2713} picks what the note "
            + "says; a lens remembers a whole set of picks without touching the "
            + "note. The block below has a spare take to practice on.",

            "The keeper's logbook recorded weather, oil, and wicks; never once "
            + "the keeper.",

            "Fork the piece: when the structure should differ (a rearranged "
            + "argument, a different opening), duplicate the note as a version "
            + "and let the two grow apart, linked and comparable. A lens is the "
            + "same structure with different choices; a version is a different "
            + "structure; promote is the bridge.",
        ])
        try take(on: threeWays.blocks[3],
            "The logbook knew everything about the light and nothing about the keeping of it.")

        // ————————————————————————————— writing —————————————————————————————

        _ = try lesson(writing, "blocks & typing", [
            "Everything you write is made of blocks: paragraph-sized pieces "
            + "with permanent identity. You never manage them while drafting. "
            + "Switch to Write (\u{2318}1), click at the very end of this note, "
            + "and type a few paragraphs. Each paragraph quietly becomes its own "
            + "block as you type past it. No gesture, nothing to ask for.",

            // 13b 4D (N34 — S4-14): the opt-in one_block face gets a
            // sentence where crystallization is taught.
            "Return makes a block wherever your cursor is: at the end of a "
            + "paragraph, a new empty block below it; in the middle of one, a "
            + "divide at the cursor. Shift-Return is the newline that stays "
            + "inside a block, a blank line in the same paragraph, and a block "
            + "can hold several paragraphs that way, or by paste or merge. "
            + "Otherwise boundaries only ever change when you ask (divide, merge, "
            + "extract: the structure chapter). Prefer to place every boundary "
            + "yourself? The bottom bar's \u{201C}newlines make blocks\u{201D} "
            + "switch turns it off for one note. Then Return is just a newline "
            + "again, typing and pasting stay inside the block, and only Divide "
            + "or New Block Below make new ones.",

            "Boundaries are invisible at rest, on purpose: a note reads as "
            + "calm, seamless prose. When you want to see the seams, press "
            + "\u{2318}\u{21E7}B. Dotted lines appear between blocks, everywhere, "
            + "until you press it again.",

            "The bottom bar keeps quiet count for you: which block your cursor "
            + "is in, and the word counts, both for the take you're in and for "
            + "the whole note.",
        ])

        let shaping = try lesson(writing, "shaping blocks", [
            "Blocks mostly shape themselves as you type. This lesson is the "
            + "hand tools, and its blocks are staged for each one.",

            "The first tool needs a middle sentence. This lesson was written as "
            + "calm filler around exactly one restless line. This middle sentence "
            + "wants to be a block of its own. Select that whole sentence, press "
            + "\u{2318}\u{21E7}K (Make Block from Selection), and watch it become "
            + "its own block. From Takes, the app carries you to Write and does "
            + "it there.",

            // 13b 4D (N28/S4-13): the insert-below door joins the direct asks.
            // 13g L1: the KEY was stale — 13d batch 4 (A14) superseded ⌥⌘N
            // with ⌘⇧⏎ and this lesson kept teaching the old chord. Same
            // finding class as WT-1 (a discoverability surface that drifted
            // out of the registry); the helper had already been corrected.
            // librarywalkpolish VR-122 (F-5): the end-of-note row is on TAKES'
            // block ▾ only (`TakesBottomBar`; Write's has New block below).
            "New blocks can also be asked for directly: "
            + "\u{2318}\u{21E7}\u{23CE} (New Block Below) mints an empty block "
            + "right under the one you're in and puts your cursor in it, in Write "
            + "and Takes alike. In Takes, the block \u{25BE} menu in the bottom "
            + "bar also has \u{FF0B} New block at the end of the note. Either "
            + "way, just keep typing.",

            "A block can carry a name: a handle for finding it, never printed "
            + "in the prose. This block wears one. Open the Blocks tab "
            + "(\u{2318}6) and you'll see \u{201C}the named block\u{201D} where "
            + "every other row shows its first sentence. Name\u{2026} on any row "
            + "sets or clears one.",

            "This block is a callout: a colored frame that says this one is "
            + "different. An aside, a goal, a warning. In Write, put the cursor "
            + "here and use Block \u{25B8} Callout to change its color, set a "
            + "leading emoji, or remove the frame. Presentation only; the text "
            + "itself is untouched, and exports render it as a quote.",
        ])
        try ops.setBlockName(shaping.blocks[3].block.id, name: "the named block")
        try ops.setBlockPresentation(
            shaping.blocks[4].block.id,
            BlockPresentation(color: "blue", emoji: "\u{1F4A1}"))

        // 13g L12 (F-1…F-5): FORMATTING. Every paragraph below is written in
        // the vocabulary it teaches, so the lesson demonstrates itself the
        // moment it is seeded — and because storage IS markdown, the prose
        // here is literally the syntax the reader is being shown.
        _ = try lesson(writing, "formatting", [
            "Formatting in Variorum is **markdown**, and that is not a detail "
            + "of the implementation: it is the whole design. What you see is "
            + "exactly what is saved. Two stars around a word are the bold. The "
            + "editor styles the word and dims the stars, so the page reads "
            + "cleanly while the text stays plain characters you could open in "
            + "any editor on earth. Nothing about a formatted note is locked in, "
            + "and an export is already markdown because it was never anything "
            + "else.",

            "The vocabulary is small on purpose: **bold** (\u{2318}B), *italic* "
            + "(\u{2318}I), ~~struck out~~, and `inline code`. The last two live "
            + "in the Format menu, which also carries every act below, and "
            + "right-clicking in any writing surface offers the same rows under "
            + "\u{201C}Format\u{201D}. Try it: select these three words and press "
            + "\u{2318}B. Press it again to take the bold off; the act reads what "
            + "is already there rather than blindly adding.",

            "## Headings are sizes",

            // librarywalkpolish VR-122 (F-6): the submenu's rows read
            // "Heading 1/2/3" (`MarkdownActs.headingRows`).
            "A line that starts with #, ## or ### is a heading. Those three, "
            + "and nothing else. Put your cursor on this line and use Format "
            + "\u{25B8} Heading \u{25B8} Heading 2 to see it happen; the line "
            + "above is already one. Setting a lead replaces whatever lead the "
            + "line had, so a heading becomes a bullet in one press rather than "
            + "becoming a bullet with a stray # in it.",

            "- Lists are lines that start with \"- \"",

            "- Format \u{25B8} Bullet List makes one from the line you're on",

            "- Select several lines and it makes them all into a list",

            "- [ ] And a checkbox is a list item with a box: \"- [ ] \"",

            "- [x] Click the box to tick it. That is an ordinary edit, so "
            + "\u{2318}Z takes it back and a sealed note refuses it",

            "Links are written [like this](https://apple.com). Format \u{25B8} "
            + "Add Link wraps your selection in the brackets and leaves the "
            + "cursor inside the parentheses, ready for the address. In a writing "
            + "surface a plain click has to place your cursor, so \u{2318}-click "
            + "follows a link instead.",

            "Now the one place the app shows you something other than what is "
            + "stored. Open this book in Read mode (the Outline \u{B7} Index "
            + "\u{B7} Book \u{B7} Read row above) and look at this lesson again: "
            + "the markers are gone, the headings are sizes, the list has "
            + "bullets, the boxes are boxes, and a link is just the words. A "
            + "plain click opens it, because Read has no cursor to place. Read is "
            + "for reading; everywhere you can write, you see the text exactly as "
            + "it is saved.",
        ])

        // ————————————————————————————— takes ———————————————————————————————

        let firstTake = try lesson(takes, "your first take", [
            "The fan is the reason this app exists: a block can hold several "
            + "parallel takes, whole alternative texts, side by side, none of "
            + "them lost, for as long as you like. Most blocks live with one "
            + "take; the ones you're unsure about can hold ten.",

            "The next paragraph can't decide what it wants to be. It's yours to "
            + "fan out.",

            "The lighthouse keeper counted the ships going out, and never once "
            + "the ships coming home.",

            // librarywalkpolish VR-122 (F-7): a note opens in WRITE the first
            // time, and there ⌘T only mints the take behind a receipt and the
            // bar has no "+ take" — the board is where this paragraph happens.
            "Press \u{2318}2 for Takes, click into that paragraph and press "
            + "\u{2318}T (or \u{FF0B} take in the bottom bar): a second take "
            + "appears beside it, born as a copy of what you were reading. "
            + "Rewrite it freely: bolder, quieter, backwards. The first take is "
            + "untouched. \u{2325}\u{2318}T makes a blank take instead, for a "
            + "genuinely different attempt.",

            "Notice: exactly one pane is ever live for typing, the one with the "
            + "ring. Click any take to make it the live one. Your keystrokes only "
            + "ever land in the ring.",
        ])
        _ = firstTake

        let choosing = try lesson(takes, "choosing & the board", [
            "Takes are for trying; choosing is deciding. The take with the "
            + "\u{2713} is what the note actually says. Visible is what you're "
            + "looking at; chosen is what the note is. \u{2318}\u{23CE} chooses "
            + "the take you're in; nothing else changes the note.",

            // librarywalkpolish VR-122 (F-8): in Write, ⌘⏎ and ⌃⌘←/→ only open
            // the takes panel (`EditorView.handleRouted`) — stepping, paging
            // and the style: menu are the board's.
            "The block below carries four takes of one sentence, ready for "
            + "practice. In Takes (\u{2318}2), open its fan (\u{2318}\u{21E7}T), "
            + "step through them with \u{2303}\u{2318}\u{2190} and "
            + "\u{2303}\u{2318}\u{2192}, and choose your favorite.",

            "The rain came in from the sea without an opinion about any of us.",

            // 13b 4D (S4-24(1)/N40): the scroll+pager hybrid + the fixed
            // strip — the prose keeps pace with the ruled behavior.
            "When a fan holds more takes than fit, the strip scrolls freely "
            + "sideways and pages: \u{25C0} 1\u{2013}2 of 4 \u{25B6}. "
            + "\u{2325}\u{2318}\u{2190} and \u{2325}\u{2318}\u{2192} turn the "
            + "pages from the keyboard, and the counter always agrees with what "
            + "you scrolled to. Take cards keep one steady height; a long take "
            + "scrolls inside its card. The style: menu in the board's top line "
            + "picks how fans open (stack, carousel, margin grid, or slot split), "
            + "and \u{238B} closes every fan at once.",
        ])
        let fanned = choosing.blocks[2]
        try take(on: fanned, "The rain arrived off the sea like a verdict none of us had appealed.")
        try take(on: fanned, "Sea rain, indifferent rain: it fell on the just and the unjust and the ferry schedule alike.")
        try take(on: fanned, "The rain came in from the sea, and the sea did not explain itself.")

        let keeping = try lesson(takes, "keeping takes safe", [
            // 13s-b triage landing (R-13s-31/32): THE GUIDE'S ONE “savepoint” — the
            // explanatory common noun defining commit at its first teach, the tour's
            // step-4 exemplar's twin; every other savepoint in the guide says commit.
            "Everything autosaves, always. A commit is the deliberate one: "
            + "\u{2318}S keeps a savepoint of the take you're in, a version you "
            + "can always come back to, no matter what you type over it. Commits "
            + "only ever add; nothing overwrites one.",

            // 13u3 UNIT D (item 14): the lesson teaches the two keys, because
            // the door asks for a name now. The fast road is still two keys,
            // and saying so here is what keeps ⌘S from feeling slower.
            "Try it here: click into this paragraph, change a few words, press "
            + "\u{2318}S. A small field appears: type a name for the moment, "
            + "\u{201C}before the rewrite\u{201D}, or just press \u{23CE} to save "
            + "it unnamed. Then press history in the bottom bar, right beside "
            + "commit. Your commit is listed under this take, its name first "
            + "where it has one. Restore loads any commit back into the take. "
            + "Name (or Rename) changes what it is called; the name is always "
            + "editable, the saved text never is. And committing again just adds "
            + "another.",

            "The block below has a spare take to practice archiving on. Click "
            + "into the second take and press \u{2318}\u{21E7}A. It leaves the "
            + "board, out of the fan but never gone.",

            "Never gone means never gone: an \u{201C}archived \u{B7} 1\u{201D} "
            + "door appears right under that block's takes. Open it and Unarchive "
            + "puts the take straight back in the fan, no leaving the board. "
            + "(Write's takes panel keeps the same archived list, if you're over "
            + "there.)",

            // 13j batch 7 (the J10 content-refresh sweep): J11 gave the app
            // its own savepoint cadence and this lesson still described a
            // history with nothing in it but ⌘S. The words follow
            // `SavepointCadenceCopy` / `SavepointRuns` — the setting's own
            // home — so the lesson and the switch cannot drift apart.
            // 13s-b triage landing (LC-1 — U4's watch-out, P-U4-2): “the ones you
            // made yourself”, the cadence pane's own verb (“Commits you made
            // yourself with ⌘S”), where the draft said “took”.
            "You are not the only one committing. Leaving a note (closing it, "
            + "switching away, quitting) quietly commits each take you changed "
            + "while you were in it, and a note you leave open gets a commit "
            + "after about two hours. A take you haven't changed is never saved "
            + "twice. The quiet ones are muted and fold into a single \u{201C}N "
            + "quiet commits \u{B7} show\u{201D} line, so the ones you made "
            + "yourself stay the ones you see. Settings (\u{2318},) \u{25B8} "
            + "Writing has the one switch: every time you leave, only after a "
            + "note sits untouched, or only when you press \u{2318}S. Whichever "
            + "you pick, the app still saves a take right before anything could "
            + "put your words out of reach.",
        ])
        try take(on: keeping.blocks[2],
            "This is the spare take. Archive me: click into me, then \u{2318}\u{21E7}A.")

        // ———————————————————————————— structure ————————————————————————————

        _ = try lesson(structure, "divide", [
            // 13b 4A: the ruled cut redesign (S4-22) — cuts land between
            // any two words; sentence ends and line breaks pull gently.
            "Divide cuts a block in two at your cursor: the everyday gesture "
            + "for \u{201C}this part should stand on its own so I can work on it "
            + "separately.\u{201D} The cut can land between any two words. It "
            + "snaps to the nearest word edge, settles a little more readily onto "
            + "sentence ends and line breaks, and the app shows you where it "
            + "landed. Only a single word has nothing to divide.",

            "This block holds two thoughts and they deserve two blocks. Put "
            + "your cursor right before this second sentence and press "
            + "\u{2318}\u{21E7}D.",

            // 13j J4 (her 2026-08-03 ruling): the fanned default. Stated here
            // because THIS is the lesson someone reads before their first
            // divide on a block that already has takes.
            "If the block has several takes, \u{2318}\u{21E7}D still just cuts: "
            + "the take you're looking at splits across the two new blocks, and "
            + "every other take stays whole on the first block, the one you "
            + "divided. Nothing goes missing and there's nothing to hunt for. "
            + "When you'd rather send them somewhere else, or place a cut in each "
            + "take by hand, that's Divide choosing takes, "
            + "\u{2325}\u{2318}\u{21E7}D, and it has the next lesson to itself.",

            "From Takes, divide acts right there: press \u{2318}\u{21E7}D, or "
            + "Divide in the bottom bar's block \u{25BE} group, and the block "
            + "you're in is cut without leaving the board. (Extract, Make Block "
            + "and Merge still travel to Write and act there, visibly. That carry "
            + "is a feature, not a trick.)",

            "One \u{2325}\u{2318}Z (structural undo) puts a divided block back "
            + "together. The two undos lesson at this chapter's end has the whole "
            + "story.",
        ])

        let ceremony = try lesson(structure, "divide choosing takes", [
            // 13j J4: the ceremony is SUMMONED now, not the default. Her
            // ruling flipped ⌘⇧D on a fanned block to the duplicating shape;
            // this lesson teaches the door that still asks take by take.
            "Dividing a fanned block raises a real question: each take is a "
            + "different text, so where does each one go? \u{2318}\u{21E7}D "
            + "answers it the quick way: cut the take you're looking at, leave "
            + "the rest whole on the first block. When the answer matters, ask "
            + "for the choice instead. \u{2325}\u{2318}\u{21E7}D lays every take "
            + "out in one sheet and asks where they should go.",

            // 13b 4A: the sheet shows every checked take at once, the ✂
            // drags between word edges, keyboard placement, and PARKING.
            "The block below carries three takes, staged for it. Put your "
            + "cursor mid-block and press \u{2325}\u{2318}\u{21E7}D. The sheet "
            + "titled \u{201C}Divide choosing takes\u{201D} opens on a row of "
            + "four: keep the takes on the top block (the everyday answer, "
            + "already chosen), keep them on the bottom, copy them to both, or "
            + "\u{201C}Choose per take\u{2026}\u{201D}, the one you really have "
            + "to ask for. Pick that fourth one: every take gets a checkbox and "
            + "its text laid out with a \u{2702} you can place anywhere between "
            + "words. Drag it, click a spot, or use \u{2190}/\u{2192} (\u{2325} "
            + "jumps by sentence, \u{21E5} moves between takes). Leave the third "
            + "take unchecked before you confirm.",

            "The ferry crossed at dawn. Nobody on board spoke about the storm.",

            "Confirm makes two blocks: the first holds every checked take's "
            + "first half, the second the endings, so your openings and endings "
            + "stay mix-and-matchable. A take doesn't have to split at all: park "
            + "its \u{2702} at the very end and the whole take rides into the "
            + "first block (at the very start, the second). The unchecked take "
            + "didn't vanish: it stays with the original block, preserved whole "
            + "off-stage, and \u{2325}\u{2318}Z puts the whole thing back as it "
            + "was.",
        ])
        let ceremonyBlock = ceremony.blocks[2]
        try take(on: ceremonyBlock,
            "The ferry went out in the grey of first light. The storm was the one thing no passenger would name.")
        try take(on: ceremonyBlock,
            "At dawn the ferry crossed. The storm stayed in everyone's coat pockets, unmentioned.")

        _ = try lesson(structure, "extract & make block", [
            // 13b 4A: the N18 narrowing (3F, commit a78326f) REVERSES —
            // extract's span edges joined the ruled word rule (S4-22
            // ruling 4), so a selection starting anywhere snaps to the
            // nearest word edge and the late-start refusal class is gone.
            // The prose re-widens honestly.
            "Extract pulls a span at a block's edge out into its own block, no "
            + "fuss at all: the source block keeps its identity and all its "
            + "takes. Select from anywhere in this paragraph to its end and press "
            + "\u{2318}\u{21E7}E (the selection's edges snap to the nearest word "
            + "edge, settling gently onto sentence ends). This closing line is "
            + "begging to stand alone.",

            "A middle span can't extract (the two ends would be left holding "
            + "hands), so Make Block (\u{2318}\u{21E7}K) is the tool there: it "
            + "runs two divides as one undoable act. The lonely sentence in the "
            + "shaping blocks lesson was exactly this gesture.",

            "Both work from Takes: make your selection in the take you're "
            + "reading, press the key, and the app carries the selection to Write "
            + "and acts. If the block is fanned, the selection carries "
            + "approximately. The app snaps to boundaries and never cuts silently "
            + "where it isn't sure.",
        ])

        let merging = try lesson(structure, "merge", [
            // 13u4 UNIT E3 (her ruling R-13u4-3): this sentence promised a
            // single space at the seam and a sentence cut restored exactly.
            // The ruling made both false, so it says what merge does now —
            // lesson and pin moved together (the standing rule).
            "Merge is divide's opposite: neighboring blocks become one. The "
            + "seam between them becomes a line break inside the merged block, so "
            + "the page reads exactly as it did. Divide at a paragraph break and "
            + "merge it back, and you get precisely what you started with.",

            "These two short blocks are really one thought.",

            "They have been waiting for your \u{2318}\u{21E7}M since the day "
            + "they were seeded.",

            "In Write, put the cursor at the boundary between them "
            + "(\u{2318}\u{21E7}B shows seams) and press \u{2318}\u{21E7}M, or "
            + "select across both and merge the whole run as one undoable act. "
            + "From Takes, Merge joins the block you're in upward, into the one "
            + "above.",

            // 13b 4B (S4-23) gave merge its ceremony; 13j J4b (her
            // 2026-08-09 ruling) made CARRY-ALL the default and left the
            // ceremony as the summoned door — divide's story, one gesture
            // over.
            "When either block has other takes, Merge brings them all along: "
            + "the two takes you were looking at join, and every other take rides "
            + "onto the merged block whole. Nothing is left behind to hunt for, "
            + "and the extra copies are quick to delete. To choose instead, use "
            + "Merge choosing takes (\u{2325}\u{2318}\u{21E7}M). It asks first: "
            + "bring every take (the everyday answer, already chosen), only the "
            + "two you were looking at, or pair by hand, which opens pre-paired "
            + "with the two takes you were looking at, so \u{23CE} still gives "
            + "you exactly the everyday join. Pair takes with \u{FF0B} and the "
            + "merged block gets one joined take per pairing (divide a two-take "
            + "block, pair 1+1 and 2+2, and it comes back whole); check "
            + "\u{201C}carry\u{201D} to ride a take over unjoined; each pairing "
            + "previews its join: space, new line, or nothing. Takes are never "
            + "multiplied combinatorially. Pairing is choosing by hand.",

            "When you pair by hand, whatever you leave unpaired stays with the "
            + "released blocks in lineage. The app names the road, and "
            + "\u{2325}\u{2318}Z brings the sources back, takes and all, from "
            + "either road. Merging three or more blocks at once asks the same "
            + "question with two answers only (every take, or only the shown "
            + "ones) and never opens the pairing surface. The block below carries "
            + "a spare take so you can watch both: \u{2318}\u{21E7}M brings the "
            + "spare along, \u{2325}\u{2318}\u{21E7}M asks where the takes should "
            + "go.",

            "This block has a second take. Merge me upward and my spare comes "
            + "along whole; with \u{2325}\u{2318}\u{21E7}M you are asked first, "
            + "my takes laid out for pairing if you want them.",
        ])
        try take(on: merging.blocks[6],
            "The spare take: I come along whole on an ordinary merge. Or pair me, carry me, or leave me in lineage when you choose by hand. Undo brings me home either way.")

        _ = try lesson(structure, "the two undos", [
            "Variorum keeps two undo stacks, deliberately separate. \u{2318}Z "
            + "is text undo: your typing, inside the take you're editing, as in "
            + "any editor.",

            // 13j batch 7 (the J10 content-refresh sweep): structural REDO
            // shipped at 13c (A10 — her *"i desperately need a 'redo'
            // command"*) and this lesson never learned the chord; the J7 sign
            // at the junction is 13j's, and this is where the two stacks are
            // introduced, so both belong here.
            "\u{2325}\u{2318}Z is structural undo: divides, merges, extracts, "
            + "moves, deletions of blocks and takes. It never touches your "
            + "typing; it restores the shape. Every structural act in this book "
            + "is one \u{2325}\u{2318}Z away from undone, and the report of what "
            + "was undone lands at the bottom of the window. "
            + "\u{21E7}\u{2325}\u{2318}Z is its redo: undo an undo, as many times "
            + "as you like.",

            "The two stacks never mix, and the app helps you at the junction: "
            + "press \u{2318}Z when there is nothing left to undo in the text and "
            + "a structural change is what you actually did last, and the status "
            + "line says so and names \u{2325}\u{2318}Z. The key still does what "
            + "\u{2318}Z always does; the app only puts up a sign.",

            "If a structural undo would overwrite words you typed after the "
            + "act, the app asks first. That is the one undo that sets writing "
            + "aside, so it is the one that stops to check. Say yes and a commit "
            + "of your newer text is kept anyway: insurance, so nothing typed is "
            + "ever more than one restore away. Every other structural undo stays "
            + "silent. Try it: divide the block above, type a few words into the "
            + "first half, press \u{2325}\u{2318}Z, answer the question, then "
            + "look in history.",
        ])

        // ———————————————————— deleting & getting it back ————————————————————
        //
        // 13j J10. Four lessons that ask the reader to DELETE things — the
        // one act the book never encouraged before, and the one her morning
        // report found most confusing. Every door named below is shipped and
        // registry-declared, and `TutorialDeletionActsTests` executes each
        // act against the seeded content.

        let deletingBlocks = try lesson(deleting, "deleting blocks", [
            "Deleting is meant to be easy here, because nothing you delete is "
            + "gone the moment you delete it. A deleted block leaves the note "
            + "keeping its takes and its commits, and it waits: first on "
            + "\u{2325}\u{2318}Z, then in this note's tray, then in the Trash for "
            + "\(TrashWindow.days) days. This chapter has you delete things on "
            + "purpose, so you know exactly where each one landed.",

            "The everyday way is the way you already know: select a whole "
            + "paragraph and press \u{232B}. Triple-click the next paragraph, or "
            + "drag across it and a little past its end, then delete. The block "
            + "goes, and the note closes over it. (Select only the words inside a "
            + "paragraph and delete, and you get exactly what you asked for "
            + "instead: an empty block, still there, ready to type in.)",

            "Scratch one: this paragraph exists to be deleted. Triple-click me "
            + "and press \u{232B}.",

            "Several at once: hold \u{2318} and click each block you want "
            + "(\u{2318}\u{21E7}-click picks a whole run). A banner appears above "
            + "the page counting what you picked, with Delete N Blocks on it; the "
            + "right-click menu carries the same row. They all go under one undo. "
            + "A multi-delete is one mistake to reverse, not five.",

            "Scratch two: \u{2318}-click me and the paragraph below, then press "
            + "Delete 2 Blocks.",

            "Scratch three: I'm the other half of that pair.",

            "\u{2325}\u{2318}Z is the undo for all of it: one press brings back "
            + "one delete however many blocks it took, and "
            + "\u{21E7}\u{2325}\u{2318}Z deletes them again. If you reach for "
            + "\u{2318}Z out of habit and there is nothing left to undo in the "
            + "text, the app says so at the bottom of the window and names "
            + "\u{2325}\u{2318}Z for you. Two undo stacks, kept separate on "
            + "purpose, and a sign at the junction.",

            "Everything you just deleted is in This Note's Tray. Open it with "
            + "the tray icon at the top of the note, beside Scraps and "
            + "References. It opens in the panel on the right, and it is always "
            + "there. A note that has deleted blocks also wears a quiet \u{232B} "
            + "badge with the count in the context bar above the page; clicking "
            + "it opens the same panel. The next two lessons live there.",
        ])
        _ = deletingBlocks

        let trio = try lesson(deleting, "archive \u{B7} delete \u{B7} scraps", [
            "A block you don't want here has three different fates, and the "
            + "difference between them is the thing to learn once. Archive keeps "
            + "it forever: out of the note, in this note's tray, with no "
            + "countdown. Delete starts the \(TrashWindow.days)-day clock: it "
            + "waits in the Trash, and then it really is gone. Moving a block out "
            + "to Snippets cuts the tie to this note altogether and leaves it as "
            + "a scrap you can drag into anything.",

            "Archive me: I'm worth keeping and I don't belong in this note "
            + "today. Put your cursor in me and use Block \u{25B8} Archive Block; "
            + "the right-click menu has the same row. I leave the page and wait "
            + "under the tray's \(TrayPath.archivedTab) view wearing \u{201C}kept "
            + "\u{2014} no clock\u{201D}, and Put back returns me to this exact "
            + "spot.",

            "Delete me: I've had my day. Block \u{25B8} Delete Block, or "
            + "triple-click me and press \u{232B}. I go to the same tray's "
            + "\(TrayPath.leavingTab) view with a countdown on me, and to the "
            + "Trash in the Library, and in \(TrashWindow.days) days I'm gone for "
            + "real.",

            // 13u3 UNIT H (the ⋯ sweep): this row was renamed by the Snippets
            // vocabulary ruling and the sentence kept the old name, so a
            // reader looked in the menu for a row that is not there. The row
            // is interpolated from its own constant now.
            "Move me out: I'm a decent line in the wrong note. Open Blocks "
            + "(\u{2318}6), find my row, and use its \u{22EF} menu \u{25B8} "
            + "\(SnippetsCopy.moveOutRow). It opens onto your groups; pick one. I "
            + "become a scrap there, material for anywhere, and \u{2325}\u{2318}Z "
            + "brings me back if that wasn't what you meant.",

            "Which one? Archive when you want it kept and out of the way; "
            + "delete when you mean it; move it out when the words are fine and "
            + "the home is wrong. All three are one \u{2325}\u{2318}Z away for as "
            + "long as this session is open, and the two that leave something "
            + "behind put it somewhere you can find it.",
        ])
        _ = trio

        _ = try lesson(deleting, "the tray & the Trash", [
            "Every note keeps its own tray of what it set aside. Open it with "
            + "the tray icon at the top of the note: This Note's Tray, in the "
            + "panel on the right. Or use the quiet \u{232B} badge in the context "
            + "bar above the page, which opens the same panel. The badge counts "
            + "deleted blocks only and hides when there are none, which is "
            + "exactly why the icon is always there.",

            // 18d batch 2 (her ruling U-9; the round-1 ladder's MAJOR-1):
            // this paragraph taught the control that batch RETIRED — two
            // stacked SECTIONS, and the takes *"folded away until you open
            // them"*. There are no sections (a segmented choice at the top)
            // and no fold (the takes are a filter chip carrying their own
            // count), so the lesson now teaches what is on screen. P-6: the
            // tutorial is the executable spec, and a lesson that sends her
            // looking for a disclosure triangle that does not exist is the
            // row-44 class.
            "The tray offers two views at the top, each carrying its count. "
            + "\(TrayPath.archivedTab) holds what you set aside on purpose: kept, "
            + "with no clock, forever. \(TrayPath.leavingTab) holds everything of "
            + "this note's that is counting down: the blocks it deleted, the "
            + "takes deleted on their own, and any original riding a family's "
            + "countdown. Under both sits one filter, "
            + "\(RecoveryCopy.trayFilterAll) \u{B7} "
            + "\(RecoveryCopy.trayFilterBlocks) \u{B7} "
            + "\(RecoveryCopy.trayFilterTakes), so this note's deleted takes are "
            + "one click away with their number on the chip, never hidden under "
            + "the block cards; every card says which kind it is. One verb serves "
            + "every row: Put back, and a block returns to the place it stood in. "
            + "(A block kept whole by a divide or a merge is not leaving "
            + "anything, so it is not here. It waits in the block it became, "
            + "under \(BlockHistoryPath.cameFromSection). The next lesson has "
            + "it.)",

            "The Library holds the other half, in two rooms. Archived is its "
            + "own item in the sidebar: calm and clockless, whole notes you set "
            + "aside, each with Unarchive. The Trash is behind the trash icon at "
            + "the top of the Library, and it holds what is leaving: notes, books "
            + "and blocks, each row saying how many days it has left and which "
            + "note it came from. Filter it by kind, sort oldest first, and Put "
            + "back works on any row. (A deleted take never rows here: it waits "
            + "in its own block\u{2019}s History, where its block and its fan are "
            + "there to make sense of it.)",

            // The post-13l polish round, ledger row 12 (D2): this paragraph
            // taught "no door inside a note ever deletes something for good",
            // which her G5 ruling superseded IN PART — the note's own Leaving
            // section carries Delete Now on its take rows, *"to keep the
            // capability"* after takes left the global Trash. The rule that
            // replaced it is the one the lesson teaches now: purge doors live
            // in TRASH SURFACES — the Library's Trash and this note's own
            // trash section — and never in the writing flow.
            "Ending something early is deliberate, and it lives in exactly two "
            + "kinds of place: the Trash, and the \(TrayPath.leavingTab) view of "
            + "a note's own tray. Delete Now ends one row's remaining days; Empty "
            + "Trash takes everything the Trash lists at once. Both ask first. "
            + "Delete Now asks every single time (there is no don't-ask to set), "
            + "and Empty Trash's question names the full count by kind before it "
            + "takes anything, and says what it leaves alone. Nowhere you write "
            + "has such a door: not the page, not the block menu, not a block's "
            + "history. You have to go to where things are leaving to end "
            + "anything for good, which is why the Trash is worth visiting once "
            + "before you need it.",

            "Practice, and it is safe: go to the Library, right-click this very "
            + "lesson \u{25B8} Delete, then open the Trash and Put back the row "
            + "you find there. The lesson comes back into this book, in this "
            + "chapter, in its place. (And if you ever lose your nerve, Help "
            + "\u{25B8} Restore Tutorial\u{2026} rebuilds the whole book.)",
        ])

        let past = try lesson(deleting, "what a block leaves behind", [
            "A block remembers more than its text. Put your cursor in one and "
            + "press history in the bottom bar, the pair to commit, the same door "
            + "on both bars. Everything this block has been opens in the panel on "
            + "the right: every take's saved moments, the takes it archived, the "
            + "takes it deleted, and where it came from.",

            // U-2 (18c batch 1): \u{2318}\u{21E7}D keeps the other takes whole on
            // the TOP block. This lesson and its staged take taught 13j's
            // duplicate default until the 18f ladder's R3-2 (ledger row 44) —
            // the U-2 sweep reached the structure chapter's ceremony lesson
            // only, because neither text carries the word "ceremony".
            "This block has two takes. Put your cursor in the middle of it and "
            + "press \u{2318}\u{21E7}D: the take you are looking at splits across "
            + "two new blocks, and the other take stays whole on the first block. "
            + "What became of the block you cut? It was kept: whole, off to one "
            + "side, not deleted.",

            "Open history on either new block and its "
            + "\(BlockHistoryPath.cameFromSection) region shows the original "
            + "itself (\u{201C}From a divide on \u{2039}date\u{203A} \u{2014} the "
            + "original is preserved\u{201D}) with Bring back beside it. "
            + "Right-clicking the block \u{25B8} See original from divide\u{2026} "
            + "and \u{2318}K land in the same place. They wait there, with no "
            + "clock, for as long as anything descended from them is alive.",

            // The post-13l polish round, her A7 ruling: the per-merge message
            // is DECLINED (*"it's annoying to see that message every time"*)
            // and the teaching lands here instead — one sentence, in the
            // chapter about where things go when they leave a page.
            "Merging keeps its blocks the same way, and says nothing at the "
            + "time. Deliberately: a message on every join would be noise. Merge "
            + "two blocks (or select across them and delete the seam) and the "
            + "block you get lists both of the blocks it joined in "
            + "\(BlockHistoryPath.cameFromSection), each with its own Bring back, "
            + "three of them if you merged three. Nothing was deleted, so nothing "
            + "is counting down; the next chapter has you do it and find them.",

            // 13u3 UNIT H: the row is named by the ROW's own title and the
            // glyph by the menu's own constant, so a rename moves this
            // sentence with it — and the sentence now says WHERE the menu is.
            // It used to send a reader to "the ⋯ menu" without a place, and
            // the surface she is most likely standing on after the takes
            // chapter — the Takes board — had no ⋯ on its cards at all.
            "Deleted takes wait in the same panel, under "
            + "\(BlockPastCopy.deletedTakesHeader), each with the days it has "
            + "left. This paragraph carries a spare take for the experiment: open "
            + "its takes (\u{2318}\u{21E7}T in Write, or the Takes tab, "
            + "\u{2318}2, where every take card carries the same menu) and on the "
            + "spare card use \(TakeCardMenuCopy.menuGlyph) \u{25B8} "
            + "\(TakeCardMenuCopy.deleteTake). Then press history: the take is "
            + "listed with Put back, and it comes back with its label, its place "
            + "in the fan and its commits intact. (A saved lens pointing at a "
            + "take you archived or deleted says so right in its column, with a "
            + "Restore button there.)",

            "One honest thing about preserved originals, because it is the kind "
            + "of promise that should never surprise you: an original stays "
            + "permanent only while something descended from it is still alive. "
            + "Delete the last of its descendants and the original moves, "
            + "visibly, into the note's tray, out of lineage and onto the "
            + "family's \(TrashWindow.days)-day clock, labelled \u{201C}set aside "
            + "by a divide or merge \u{2014} kept until its family goes\u{201D}. "
            + "The delete that does it says so in its own receipt, while you are "
            + "standing there.",
        ])
        try take(on: past.blocks[1],
            "The other take of the dividing block: I stay whole on the first block when you press \u{2318}\u{21E7}D, and the block we came from is kept preserved.")
        // Index 4, not 3: A7's merge sentence joined this lesson at the
        // post-13l polish round and sits between the lineage paragraph and
        // this one. (The walk's `theChapterIsStagedForItsActs` holds the
        // count of fanned blocks, and `theDeletedSpareTakeWaitsInTheBlocksPast`
        // finds this one by its prose — both caught the shift.)
        try take(on: past.blocks[4],
            "the spare take: delete me from my own card's \u{22EF} menu (every take "
            + "card has one, in Takes and in Write's takes panel), then put me back "
            + "from the block's history panel.")

        // ————————————————————————— where things go ——————————————————————————
        //
        // The post-13l polish round, ledger rows 19 (G4), 26 and 27. THE MAP,
        // and the two lessons that make it usable: the pair of keys that save
        // the two sizes of moment, and the two exits a paragraph can take.
        // Every place named below is a surface this round built or verified,
        // and `TutorialWherePlacesActsTests` visits each one.

        _ = try lesson(places, "the five places", [
            "Nothing here goes anywhere you can't find. At any moment, "
            + "everything you have ever written is in exactly one of five places: "
            + "where you left it \u{B7} in Archive \u{B7} in the Trash \u{B7} in "
            + "this note's Versions \u{B7} in this block's History. This lesson "
            + "visits all five, and the two after it teach the ones that are new.",

            "One: where you left it. The ordinary case, said out loud because "
            + "it is the one nobody thinks to say. A note you wrote and did "
            + "nothing else to sits in your Library exactly as you left it, for "
            + "as long as you keep it. The other four places exist only for "
            + "things you deliberately set aside, deliberately changed, or "
            + "deliberately saved.",

            "Two: Archive. Notes, forever, no clock. Right-click any note "
            + "\u{25B8} Archive and it leaves the Library for Archived, its own "
            + "item in the sidebar, with its own search. Nothing is counting down "
            + "and nothing needs remembering. It is still yours, still editable, "
            + "still exportable; archiving is about your Library's attention, not "
            + "about the note. Unarchive puts it back. (Blocks and takes archive "
            + "too, and each waits where its context is: an archived block in its "
            + "note's tray, an archived take in its block's History. A thing set "
            + "aside stays next to what makes sense of it.)",

            "Three: the Trash. What is leaving, for \(TrashWindow.days) days. "
            + "Deleting a note, a book or a block starts the clock, and all three "
            + "wait it out behind the trash icon at the top of the Library, every "
            + "row saying how many days are left and which note it came from, and "
            + "Put back on any of them. A deleted take is the one thing that "
            + "never rows there: alone, out of its block, a take is too small to "
            + "make sense of, so it waits in that block's History instead.",

            "Four: this note's Versions. Moments of the whole note, saved by "
            + "hand. \u{2318}\u{21E7}S saves one; note \u{25BE} \u{25B8} "
            + "\(VersionsPath.menuLabel) lists them, newest first, each with "
            + "Read, Restore and Promote. A saved version is frozen at birth and "
            + "stays out of your way, never in the Library, never in Archived, "
            + "because it is not another note. It is this note's past. The next "
            + "lesson is about the key.",

            "Five: this block's History. Everything one block has been. The "
            + "history door sits in the bottom bar right beside commit, and it "
            + "opens the Block History panel: each live take's saved moments, the "
            + "takes this block archived, the takes it deleted (with their "
            + "clocks), and \(BlockHistoryPath.cameFromSection), the blocks it "
            + "came out of. Two lessons live in there, and they are the two that "
            + "follow.",

            "Practice me: I'm here to be visited. Put your cursor in me and "
            + "press history in the bottom bar to read my (empty) past. Then come "
            + "back after the next lesson and look again.",

            "A last honest word about the map: it is a map of places, not of "
            + "promises about time. Archive keeps forever; the Trash keeps for "
            + "\(TrashWindow.days) days and then really does delete; a note's "
            + "Versions and a block's History keep for as long as the note or the "
            + "block does. Wherever something is, the surface it is on tells you "
            + "which of those it is. That is the whole design, and the reason "
            + "there are five places instead of one.",
        ])

        // Row 26 + row 19's savepoint half: the grain pairing IS the lesson,
        // and the commit↔history pairing in the bottom chrome is where it is
        // taught (her: *"making it clear where commit / that particular
        // history by the take is, is also important"*).
        let saving = try lesson(places, "saving a moment", [
            "Two keys save two different sizes of the same idea, and the pair "
            + "is worth learning together. \u{2318}S saves a moment of this take "
            + "(a commit: the block you're in, the take you're looking at). "
            + "\u{2318}\u{21E7}S saves a moment of this note (a version: all of "
            + "it, as it stands). One grain apart, one shift key apart.",

            "\u{2318}S's moments live exactly where you'd look for them: press "
            + "history in the bottom bar, immediately beside commit. That pairing "
            + "is deliberate. Commit writes a moment, history shows the moments, "
            + "and the two sit together so the bar reads as the block's own time "
            + "controls. Every live take of the block has its own run in there, "
            + "with the take you're in already open.",

            "Practice take: change a few words in me, press \u{2318}S, then "
            + "press history. I'm where your moment will be listed.",

            "Restore beside a moment loads it back into the take. It does not "
            + "overwrite anything: moments only ever append, so restoring an old "
            + "one and pressing \u{2318}S again just adds another. That is the "
            + "whole promise of a commit here. You can always come back, "
            + "including from the coming back.",

            // 13u3 UNIT E: *"every block, every take"* over-claimed by one
            // word — a version copies the note's PLACED blocks, which is the
            // next lesson's whole subject — and the one-way-door promise was
            // the confirm's own (corrected there in the same batch: the WORDS
            // come back, the history does not).
            "\u{2318}\u{21E7}S is the same idea one size up. It copies the "
            + "whole note as it stands, every paragraph on the page, every take "
            + "on them, and keeps it under \(VersionsPath.menuLabel) in the note "
            + "\u{25BE} menu. Restore makes the note say that again, and it saves "
            + "where the note is now first, so none of its words are lost. "
            + "Promote turns a moment into a note of its own, if you'd rather "
            + "work with it than go back to it. What a copy carries, and what it "
            + "leaves behind, is the next lesson.",

            "Which one to reach for? \u{2318}S when one paragraph is about to "
            + "change and you might want this wording back. \u{2318}\u{21E7}S "
            + "before a rewrite, anything that will touch several blocks at once. "
            + "And you are not the only one saving: leaving a note quietly "
            + "commits each take you changed while you were in it, so the "
            + "\u{2318}S you forget is mostly already taken for you.",
        ])
        _ = saving

        // **13u3 UNIT E — item 15(b), her instruction verbatim:** *"It should
        // be made clear in the tutorial that when you make a version of a
        // block or copy it or save it as a version, that you're only saving
        // the placed notes - not the history that rides with it. it's worth
        // making sure that's clear in the tutorial anyway."*
        //
        // ONE lesson for BOTH halves of the rule, as the brief asks: a copy
        // carries the words (placed blocks and their takes) and never the
        // past (no savepoint has ever ridden a copy — the standing pool-drag
        // rule, true of every copying gesture the app has). It sits HERE, on
        // the far side of ⌘⇧S, because the previous lesson just told her the
        // chord copies the note and this is the sentence that makes that true
        // rather than nearly true — and it is the reason RESTORE's confirm
        // counts what it takes (13u3 UNIT E's other half).
        let copies = try lesson(places, "what a copy carries", [
            "A copy carries the words, not the past. One rule, and it covers "
            + "every gesture that makes a second thing out of a first: saving a "
            + "version of this note (\u{2318}\u{21E7}S), duplicating a note, "
            + "dragging a piece out of Snippets into a draft. What arrives is the "
            + "text and every take on it, and nothing standing behind them.",

            "So the moments do not travel. Commits stay on the take you pressed "
            + "\u{2318}S on, in that block's \(BlockHistoryPath.name); a copy's "
            + "takes are born with one fresh moment of the instant they were made "
            + "and nothing before it. When you want the run of moments, you go "
            + "back to the block that has them, which is what the "
            + "\(BlockHistoryPath.doorLabel) door is for, and why it is worth "
            + "knowing where the original is.",

            "And a copy holds only what the note places: the paragraphs on the "
            + "page, in their order. A note keeps things beside its page that are "
            + "not on it: blocks a divide or a merge set aside whole "
            + "(\(BlockHistoryPath.cameFromSection)), blocks you archived, blocks "
            + "on their way out in \(TrayPath.menuLabel). None of those are in a "
            + "saved version. They belong to the note and they stay with it, "
            + "exactly where the map two lessons ago says they are.",

            "Practice copy: put your cursor in me and press \u{2318}S to save a "
            + "moment of this take. Now press \u{2318}\u{21E7}S to save the whole "
            + "note. Open note \u{25BE} \u{25B8} \(VersionsPath.menuLabel) and "
            + "\(VersionsPath.openVerb) the new moment: every word is there, mine "
            + "included. The moment you just saved is not. It is still here, in "
            + "my history, where you left it.",

            "This is why \(VersionsPath.restoreVerb) asks before it acts. It "
            + "replaces the note's paragraphs with the moment's, and the past of "
            + "the paragraphs it replaces goes with them: their saved moments, "
            + "any take you deleted from them, any comment you deleted. The "
            + "confirm counts them and says so before you press it. "
            + "\(VersionsPath.promoteVerb) is the road that takes nothing. It "
            + "makes the moment a note of its own and leaves everything where it "
            + "is.",

            "None of this contradicts the map; it is the map applied to copies. "
            + "A copy is a new thing in the place you made it, and the past of "
            + "the thing you copied stays exactly where it already was. Which is "
            + "the same reason nothing in this app is ever in two places at once.",
        ])
        _ = copies

        // Row 27, her eleventh-sitting mandate — TAUGHT BY DOING (her idea):
        // the reader deletes a whole block and finds it, then makes an edit
        // that merges two and finds the originals. Both staged blocks below
        // are single-take deliberately: a cross-block edit joins the halves
        // only where no fan hangs on the seam (the #11a ruling).
        let exits = try lesson(places, "the two exits", [
            "A paragraph can leave a page two different ways, and telling them "
            + "apart answers the question this whole chapter exists for: "
            + "\u{201C}I deleted a paragraph, so where is it?\u{201D} The rule is "
            + "short. Deletion goes to the Trash; transformation goes to lineage.",

            "The first exit: you deleted it. Triple-click the paragraph below "
            + "and press \u{232B}. It leaves the page onto a "
            + "\(TrashWindow.days)-day clock, and it is now in two listings of "
            + "the same fact: \(TrayPath.menuLabel) (the tray icon at the top of "
            + "the note, \(TrayPath.leavingTab)) and the Trash in the Library. "
            + "Put back in either one returns it to the place it stood in. "
            + "Deleted means leaving, and anything that is leaving always says "
            + "how long it has.",

            "Exit one: triple-click me and press \u{232B}. I'm the deletion. "
            + "Look for me under the tray's \(TrayPath.leavingTab) view, and in "
            + "the Trash, and put me back from either.",

            "The second exit: it became something else. Select from the middle "
            + "of the next paragraph to the middle of the one after it and press "
            + "\u{232B}. The two become one, quietly, the way any editor would "
            + "join them. But the two blocks you started with were not deleted. "
            + "They were kept whole, set aside, and the block they became "
            + "remembers both.",

            "Exit two, first half: select from somewhere in me all the way into "
            + "the paragraph below, and press \u{232B}.",

            "Exit two, second half: and what we become will remember us both, "
            + "by name.",

            "Now look. Put your cursor in the joined paragraph and press "
            + "history: its \(BlockHistoryPath.cameFromSection) region lists both "
            + "originals, not one of them, each with its own text and a "
            + "\(BlockHistoryPath.bringBackVerb) button that puts it into the "
            + "note again, beside what it became. Nothing counted down. Nothing "
            + "was in the Trash. All the app said at the time was one quiet line "
            + "at the bottom, naming where the two originals went, and this panel "
            + "is where that line points.",

            // **13u1 UNIT 2 — the FANNED CROSS-BLOCK MATRIX**, which row 27
            // deliberately left to this phase (*"the fanned cross-block
            // matrix is 13u's — its sitting + its own lesson update"*). Her
            // item 5 legibility mandate is why it is here at all:
            // *teachability is a design constraint*, and the gesture now has
            // three answers where the lesson taught one.
            "One more thing, and it is the whole shape of a big selection. "
            + "Select across several paragraphs, press \u{232B}, and every block "
            + "you touched gets exactly one of two fates, decided by how much of "
            + "it you selected. A block you covered whole leaves the page the "
            + "first way: to the Trash, with every take on it, together, so "
            + "\(TrayPath.putBackVerb) returns the whole family, not a piece of "
            + "it. A block you covered only in part keeps its name and its place, "
            + "and only the take you can see loses its piece. The takes you are "
            + "not looking at are never touched.",

            "The two ends then join, or they don't, and that is decided by "
            + "where you cut. Cut in the middle of a paragraph at both ends and "
            + "the remainders become one paragraph, the way any editor would join "
            + "them: the second exit, with both originals kept whole under "
            + "\(BlockHistoryPath.cameFromSection). Cut at a paragraph break at "
            + "either end (the top of a block, the bottom of one, or a line break "
            + "inside one) and the ends keep their own blocks. You meant whole "
            + "paragraphs, so whole paragraphs is what you get.",

            "And there is one more way the ends stay apart: a take hanging on "
            + "one of them. A keystroke will never fold a fan away. The edit "
            + "lands in the take you can see, the fan stays where it is, and the "
            + "two blocks stay two. When you do want them joined, merge them "
            + "deliberately and choose what the takes do.",

            "Exit three, top: select from the middle of me\u{2026}",

            "Exit three, middle: \u{2026}straight through all of me. I have two "
            + "takes, and I go to the Trash whole, both of them with me.",

            "Exit three, bottom: \u{2026}to the middle of me, and press "
            + "\u{232B}. Then look: the top and I are one paragraph, the middle "
            + "is in the tray with both its takes, and one \u{2325}\u{2318}Z puts "
            + "all of it back.",

            "So, whenever something is missing: if you deleted it, look where "
            + "things are leaving, the note's tray, then the Trash. If you "
            + "changed it (merged, divided), look inside what it became, under "
            + "\(BlockHistoryPath.cameFromSection). There is one place the two "
            + "exits meet, and it is honest about itself: a preserved original "
            + "has no clock only while something descended from it is alive, so "
            + "deleting the last of those descendants moves it, visibly, into the "
            + "tray and onto the family's clock. The delete that does it says so "
            + "in its own receipt, while you are standing there.",
        ])
        // The fan the matrix teaches, staged on the MIDDLE block of the
        // EXIT THREE trio — the cell her item 5 ruling actually CHANGED: a
        // fanned block covered WHOLE goes to the Trash with its family
        // intact, where the older behaviour emptied the take you could see
        // and left a blank block with a fan hanging on it.
        // 13s-b triage landing: the staged trio reads in sentence case now
        // (“Exit three, …”), and this prefix moved IN THE SAME COMMIT as
        // the prose — a stale prefix would silently never mint the take.
        if let middle = exits.blocks.first(where: {
            $0.variant.workingText.hasPrefix("Exit three, middle")
        }) {
            try take(on: middle, "the middle block's second take: it rides to the Trash too.")
        }

        // ————————————————————————— keeping it private —————————————————————
        //
        // pre-13x 5a — copy §7's SHORT chapter (the postures design §1.22 /
        // §8): two lessons, their paragraphs VERBATIM from the copy
        // constants (`PostureCopy.swift`), the device nouns interpolated.
        // What's true in every mode; Standard and Castle and what you must
        // keep in each; the open-app sentence; the door to the seeded book
        // *Encryption Explained*, which carries the whole story. The 13p
        // dials lesson and its loss-math composition retired with the
        // presets, the escrow dial and the reset door they described (§13).

        _ = try lesson(privacy, ProtectionCopy.privacyLessonOneTitle,
                       ProtectionCopy.privacyLessonOneParagraphs)
        _ = try lesson(privacy, ProtectionCopy.privacyLessonTwoTitle,
                       ProtectionCopy.privacyLessonTwoParagraphs)

        // ——————————————————————————— ways of looking ———————————————————————

        // pre-13u Act 10 wave 2c (item 16, W8-1) gave this chapter two
        // modes; the Act 10 correction round (R-cor-5/7) folded them into
        // ONE tab named Read with an in-place `edit · read` switch — taught
        // first in this chapter, because getting around and reading are the
        // FUNDAMENTAL ways of looking ("obviously a need, seems more
        // fundamental").
        _ = try lesson(looking, "read", [
            "Read (\u{2318}3) is the note beside its own index, and it opens on "
            + "edit. The column on the left is the index: markdown headings "
            + "become sections, every other block files under the one above it, "
            + "and a note with no headings lists plainly. Click a row and the "
            + "text beside it scrolls there; the \u{22EF} menu carries the block "
            + "acts. In the text, click any block and it goes live right where it "
            + "is, one block at a time. The outline button folds the column away "
            + "and back. Read opens standing at the block you were just in, "
            + "whichever mode you came from.",

            "Switch the face to read and the same note is a page: the paper a "
            + "book's reading flow uses. Markdown rendered, boundaries gone, "
            + "nothing to edit. Choose continuous, or pages (the book's own "
            + "leaves; \u{2190} \u{2192} turn them); Aa \u{2212} / Aa \u{FF0B} "
            + "size the type. Reading is the point. And when a sentence needs "
            + "work, click its paragraph: the page turns to edit with that block "
            + "live.",

            "Try it: press \u{2318}3. The column stands at this lesson. Click "
            + "this very paragraph in the text and it goes live; type a word. "
            + "Switch to read, click this paragraph again, and the page turns to "
            + "edit with it live. Then \u{2318}1 back to Write.",
        ])

        let lenses = try lesson(looking, "lenses", [
            "A lens is a saved way of looking at a note: for each block, which "
            + "take to show. It never changes the note. A lens is the same "
            + "structure with different choices. Lenses mode (\u{2318}4) is their "
            + "home: full-text columns side by side.",

            "Both blocks of this lesson carry two takes, and a lens named "
            + "\u{201C}the other reading\u{201D} is saved beside the chosen text. "
            + "In Lenses, add its column (\u{FF0B} column \u{25B8} Open "
            + "\u{201C}the other reading\u{201D}) and read the two versions of "
            + "this lesson side by side. The \u{2039} \u{203A} arrows on any cell "
            + "re-pick that block's take; \u{1F4BE} saves your current picks as a "
            + "new lens.",

            "\u{2713} Make this the note adopts a column: the note's chosen "
            + "takes become what it shows. Adopting swaps, never destroys. The "
            + "outgoing chosen is auto-saved as a lens named \u{201C}chosen until "
            + "(today)\u{201D}, so you can always swap back.",
        ])
        // 13s-b triage landing: the two staged alternates in the drafts' text
        // (the caps and dashes out; the lens and its two choices unchanged).
        let lensAlt1 = try take(on: lenses.blocks[0],
            "A lens is a bookmark on your choices: it remembers, for every "
            + "block, which take you'd show, without moving the note an inch. "
            + "Lenses mode (\u{2318}4) lays such readings out as columns.")
        let lensAlt2 = try take(on: lenses.blocks[2],
            "\u{2713} Make this the note is the one door from looking to being: "
            + "adopt, and the column's picks become the note's chosen takes. The "
            + "old chosen is kept as \u{201C}chosen until (today)\u{201D}: swaps, "
            + "never destroys.")
        let lens = try ops.createLens(post: lenses.post.id, name: "the other reading")
        _ = try ops.setLensChoice(lens: lens.id, block: lenses.blocks[0].block.id, variant: lensAlt1.id)
        _ = try ops.setLensChoice(lens: lens.id, block: lenses.blocks[2].block.id, variant: lensAlt2.id)

        let versions = try lesson(looking, "compare & versions", [
            "A version is a different note related to this one. A version is a "
            + "different structure. Two gestures share the word: Mark as Versions "
            + "just draws a link between two existing notes; Duplicate as Version "
            + "mints a whole copy (takes and all) and draws the link in one "
            + "gesture. Mark = connect, duplicate = copy + connect.",

            "This lesson already has a version twin; it was duplicated when the "
            + "book was seeded. Open Compare (\u{2318}5): the notes sit side by "
            + "side, related blocks tied by lineage, and every pane is editable. "
            + "Click into either column and type: the edit lands in that note, "
            + "and the one live ring moves wherever you click, across notes. Drag "
            + "a block's \u{28FF} handle to reorder it; each column reorders its "
            + "own note only.",

            "Compare is honest about relationships. \u{201C}Follow this note's "
            + "order\u{201D} arranges the other columns beside their related "
            + "blocks (display only; nothing moves); lineage colors mark the "
            + "families, and rails appear only where a real relationship exists. "
            + "Compare against an unrelated note and it says \u{201C}there is no "
            + "relationship here\u{201D}. The two just sit plainly side by side, "
            + "no blanks, no colors.",

            "Compare opens with \u{201C}related blocks only\u{201D} on: it "
            + "hides every block lineage has nothing to say about, leaving just "
            + "the material that connects across the columns. Nothing is moved or "
            + "deleted. It is a way of looking, and one click back: turn the chip "
            + "off to read the notes whole. Against an unrelated note it tells "
            + "you there is nothing to show, rather than showing you nothing.",

            "Outlines live here too: press \u{201C}make outline note\u{201D} in "
            + "Compare's header and the app mints a linked condensation, first "
            + "sentence per block, and opens it beside this note, registered "
            + "point by point. And the Diff sheet has Save\u{2026}: the whole "
            + "diff as a plain-text file, ready to hand to an AI agent.",

            "Unmark deletes only the connection; both notes stay exactly as "
            + "they are. The library's right-click menu has Duplicate as Version "
            + "for any note, any time.",
        ])
        let twin = try ops.duplicateAsVersion(versions.post.id)
        // A distinct title (walk finding): the copy inherits the lesson's
        // title, and two identical rows in the ⌘K palette invite opening
        // the wrong one.
        try ops.renameContainer(twin.post.id, title: Self.twinTitle)
        // 17y B3 item (c): Duplicate as Version now CARRIES the source's tags,
        // so the twin is born wearing the guide's tag (a row copy) and this
        // apply finds it already there. Tolerated ONLY for that refusal — the
        // seeded result is identical (the twin wears the tag either way); any
        // other refusal still aborts the seed.
        do {
            try ops.applyTag(tagID, toPost: twin.post.id)
        } catch OperationError.alreadyTagged {}

        // 17y B-DEDUPE (the B2 ladder's MAJOR-2): the lesson teaches the
        // BUILD's modes — Release (no Canvas after (p)) gets the workbench
        // lesson alone, its title and intro following; the Debug guide keeps
        // the canvas teaching whole. ONE pure function carries both flavors
        // (`lookingLessonContent`), the same seam as the helper's "canvas"
        // dictionary entry. Words functional, 13s re-voices.
        let looking2 = Self.lookingLessonContent()
        _ = try lesson(looking, looking2.title, looking2.paragraphs)

        // —————————————————————————— the library of things ——————————————————

        let commentsTags = try lesson(library, "comments & tags", [
            // 13b 4D (N35/S4-33): the doors she couldn't find, named where
            // comments are taught — the bar button (both editors now) and
            // the margin's own + door.
            //
            // 13e E7 keeps the promise TRUE (P-6): 13g R5-3 retired the
            // right-hand ＋ and this sentence went on describing it, so the
            // lesson has been one door ahead of the app since. The door is
            // back where the margin now is — on the LEFT — and it appears
            // when she points at a block, which the words say.
            //
            // librarywalkpolish VR-122 (F-12): …and 13l RETIRED that hover ＋
            // (her 8c rider: "I need the comment + on the left removed … it's
            // too crowded"; `BlockDecor` records it), so the promise left
            // with the door. The margin card/badge, ⌘⇧' and both bars'
            // comments button stay.
            "A COMMENT is a working note on a BLOCK — about the writing, not in "
            + "it: \u{201C}take 1 is better, but take 2's ending\u{2026}\u{201D}. This block "
            + "carries one; it renders in the margin with a // prefix. Click it "
            + "to open the block's comments panel — or press \u{2318}\u{21E7}' anywhere. "
            + "The comments button sits in the bottom bar in Write and Takes "
            + "alike.",

            "Comments survive the knife: divide or merge a commented block and "
            + "the note rides onto the successors. Deleted comments stay "
            + "visible in the panel and can be brought back — the feature is "
            + "deliberately never skimpy.",

            // 13i-d U7 continuation (F-U7-4 — row 85's twin): this paragraph
            // taught tag cards "on the CONTEXT BAR" and "Fold the bar with
            // ⌘⇧I", a fold the app retired; it now teaches the masthead's ＃
            // field exactly as "the workspace" does. (F-U6-3 earlier: the tag
            // door mints a GATHERING — Settings ▸ Tags' "Make a Gathering…".)
            "TAGS organize notes (and blocks) without moving them: hierarchical "
            + "paths like life/goals/2024. A note wears them as little coloured "
            + "cards on its masthead's right edge \u{2014} click the \u{FF03} beside "
            + "them and a tag field opens with the cursor in it (type a name; "
            + "\u{201C}/\u{201D} nests, and a name that doesn't exist yet is made; "
            + "\u{23CE} applies it), \u{2715} on a card takes one off, and "
            + "\u{2318}\u{21E7}I opens the same field from anywhere in the note. "
            + "Every tag keeps its own colour everywhere. The tag manager lives in "
            + "Settings (\u{2318},), where Make a Gathering\u{2026} turns a tag into a "
            + "gathering that shows everything wearing it.",

            "Full disclosure: every lesson note wears the \u{201C}tutorial\u{201D} tag — "
            + "that is exactly how Help \u{25B8} Restore Tutorial\u{2026} finds what to "
            + "replace. Your own notes never wear it unless you put it there; "
            + "everything else in your library is invisible to the restore.",
        ])
        _ = try ops.addBlockComment(
            to: commentsTags.blocks[0].block.id,
            text: "a comment lives in the margin — about the block, never inside its text")

        // VX-89 — **THE FINDER'S LESSON** (her question at the 13o follow-up
        // report: *"were search details added to the field guide?"* — they
        // were not; R-VX83-3: *"add the content to the field guide now, with
        // whatever information a user needs for it"*). Functional words only
        // (the VR-122 seed-edit class — 13s re-voices the guide), written as
        // the finder stands at the VX-83 run's close: the one field, the
        // answer sheet, land-at-match with ⌘G, `#tag` ALONE narrowing to the
        // tagged notes (VX-84a, R-VX83-1) and the tag offer (VX-84b), the
        // rebuilt `when ▾` (VX-87, direction 1), `+ archived`, the book's 🔍,
        // ⌘K's passages. Every door named here is tied to its own home by
        // `TutorialCurrencyTests`' search pins, and the two practice acts —
        // `#tutorial` alone, and the practice word — are walk-asserted (P-6).
        // VX-72 (U-B's rider, the same run's U-C): ONE sentence for the
        // `+ commits` facet (her word, R-VX83-9) — savepoint history joins
        // the answer, each line marked "commit" with its day (R-VX83-10).
        _ = try lesson(library, searchLessonTitle, [
            "The search field at the top of the Library is the one place to look "
            + "for anything you wrote. Type words and it searches the TEXT itself: "
            + "the body of every note \u{2014} every take, not only the one showing "
            + "\u{2014} and titles, snippets, comments, block names and take labels. "
            + "Capitals and accents don't matter: \u{201C}cafe\u{201D} finds "
            + "\u{201C}Caf\u{E9}\u{201D}.",

            "Words answer as a sheet. A band under the field counts what was found "
            + "\u{2014} books, notes, passages \u{2014} and its chips say what is "
            + "narrowing the search, starting with the wing you're in "
            + "(\u{201C}in: Home\u{201D}): search looks inside one wing, though "
            + "snippets are found from every wing. Books whose names match come "
            + "first; then each note that matches, best match first, with up to "
            + "three of its matching lines and the words highlighted. "
            + "\u{201C}all N \u{203A}\u{201D} on a note opens the rest of its lines.",

            "Click a line and you land IN the note: in Write, at that block, the "
            + "match selected and the find bar already holding your words. "
            + "\u{2318}G steps to the next match, \u{21E7}\u{2318}G back. A line "
            + "marked \u{201C}in another take\u{201D} matched a take that isn't "
            + "showing \u{2014} you land at its block with the find bar ready, and "
            + "nothing is selected, because those words aren't on the page.",

            "A TAG typed alone narrows the Library to the notes wearing it. Type "
            + "#tutorial and the Library shows this guide's notes \u{2014} every "
            + "lesson wears that tag \u{2014} as its own rows, in the order its "
            + "sort \u{25BE} says, with any books the tag flows into listed on top. "
            + "A tag covers the tags under it: #life finds a note tagged "
            + "life/goals too. Put words beside a tag and it narrows the search "
            + "instead: #tutorial rain looks for rain in these lessons only (the "
            + "choosing lesson's rain takes answer). "
            + "And when a word you type is the name of a tag, the band offers it "
            + "\u{2014} \u{201C}tag: #name \u{203A}\u{201D} \u{2014} and one click "
            + "searches the tag.",

            "when \u{25BE}, beside the sort, narrows the Library to a day. It opens "
            + "a small calendar with two choices above it. \u{201C}on a day\u{201D}: "
            + "click a day. \u{201C}between days\u{201D}: click the first day, then "
            + "the last, and the run between them fills in. The sentence under the "
            + "calendar always says what is showing \u{2014} \u{201C}Showing notes "
            + "edited on Oct 6.\u{201D} \u{2014} and that sentence is the "
            + "confirmation: nothing changes until you click a day, and Esc or a "
            + "click outside keeps exactly what it says. \u{201C}any day\u{201D} "
            + "clears it, and so does the \u{2715} on the day's chip in the band. "
            + "One honest limit: a note keeps one edit stamp, so a note edited on "
            + "two days answers for the later one \u{2014} the earlier day finds it "
            + "where a savepoint landed.",

            "Archived notes stay out of the way: search leaves them out until you "
            + "press \u{201C}+ archived\u{201D} in the band, and that chip's "
            + "\u{2715} leaves them out again. What you saved is searchable the "
            + "same way: \u{201C}+ commits\u{201D} brings in the words your "
            + "commits kept, each such line marked \u{201C}commit\u{201D} "
            + "with the day it was saved. Inside a book, the \u{1F50D} at the "
            + "right of the book's masthead searches that book alone \u{2014} the "
            + "same kind of answer, scoped to the book. And \u{2318}K finds "
            + "passages too: under the notes and books whose names match, a few "
            + "matching lines, and \u{201C}All matches in the Library "
            + "\u{203A}\u{201D} to open the whole answer.",

            "Try it: open the Library and type marginalia. This paragraph "
            + "answers \u{2014} click its line and you land right here, in Write, "
            + "with the word selected and the find bar holding it. Press \u{2318}G "
            + "and the selection steps to the next marginalia. Then try "
            + "#tutorial on its own, and watch the Library become this guide.",
        ])

        // 13i-d U7: "books & the shelf" MOVED — swept — into the books
        // chapter at the end of this book ("a book from the inside" carries
        // its chapters/views/targets paragraphs; finishing and deleting are
        // lessons 6 and 8 there). Its last paragraph claimed a book "never
        // owns" its notes, false since 13i-c's Owned books (lesson 1).

        // **13u4 UNIT S3 — KnownIssues row 68: this chapter's prose swept
        // against `SnippetsCopy`'s own vocabulary.** It said *"the Snippets
        // area's pool menu switches between pools"* while the surface speaks
        // GROUPS, and called the items SCRAPS where every UI string says
        // SNIPPET (the pre-13u vocabulary ruling, W8-1: the scrap area speaks
        // as Snippets, with GROUPS as the container noun; the bookless-notes
        // POOL keeps its name, which is why the first card's "POOL (sidebar)"
        // is untouched).
        //
        // **The H pattern, as this suite practises it:** the prose is written
        // PLAINLY — never interpolated from the constant it means to assert,
        // which would make the pin vacuous (`TutorialWherePlacesActsTests`'
        // own doc says exactly this) — and `TutorialWherePlacesActsTests`
        // ties every door named here to the surface's constant, so the next
        // rename makes the lesson RED rather than merely wrong.
        //
        // Two words deliberately NOT swept, both recorded in the unit record:
        // the CHAPTER'S TITLE (the phone's seeder holds the same string, and
        // renaming it here alone would put the two tutorials' chapters out of
        // step — the mobile catch-up's, on row 55's own precedent), and the
        // seeded group's name `scrapPoolTitle`, which is a RESERVED IDENTITY
        // the restore door's discovery filters on: renaming it would orphan
        // every already-seeded store's group from Restore Tutorial, which is
        // a behaviour change wearing a copy change's clothes.
        let scraps = try lesson(library, "pool & scraps", [
            "Not everything starts as a note. The POOL (sidebar) holds notes "
            + "that belong to no book yet \u{2014} drafts in waiting. SNIPPETS "
            + "(sidebar) holds exactly that: loose blocks that aren't notes at "
            + "all \u{2014} overheard lines, stray sentences, one-liners you'll "
            + "want later.",

            "A group named \u{201C}tutorial scraps\u{201D} was seeded for you with "
            + "two snippets \u{2014} the Snippets area's groups column switches "
            + "between groups, and \u{201C}all snippets\u{201D} at its top shows "
            + "every one at once. To drag a snippet into a note: open any "
            + "lesson in Write (\u{2318}1) and press the Scraps button in the "
            + "note's top-right corner (beside References). They sit beside "
            + "the page \u{2014} drag one in, and it lands as a COPY with lineage "
            + "back to the snippet, which stays in its group. Hold \u{2325} while "
            + "dragging and the whole fan rides the copy, takes and all (the "
            + "second snippet has two, to try exactly that).",

            "The Snippets area's own dashed box mints them: start typing in "
            + "it, press \u{23CE}, and the line is kept as a standalone snippet. "
            + "Drag pieces out as your drafts want them \u{2014} copy out is the "
            + "only direction, so the snippets never tangle with your notes.",

            // 13b 4D (N32(b)/(c) \u{2014} S4-8/S4-15): snippets are individual
            // items; the groups-vs-tags distinction said plainly.
            // librarywalkpolish VR-122 (F-9): the Snippets area's Canvas face
            // is Debug-only since 17y (p) — "or on a canvas card" left (the
            // guide teaches Canvas only through `lookingLessonContent`).
            "Each snippet is its own item and can wear TAGS: right-click a "
            + "snippet row \u{2014} here, or in the side panel "
            + "\u{2014} and Tags\u{2026} opens its tag sheet. Worth keeping "
            + "straight: a GROUP is a container (a snippet lives in exactly "
            + "one; Move to Group moves it), while a TAG is a label (a snippet "
            + "can wear many, and filtering by tag never moves anything).",
        ])
        _ = scraps
        let scrapPool = try ops.createPool(title: scrapPoolTitle)
        _ = try ops.newBlock(
            in: scrapPool.id,
            text: "a scrap: the harbor bell rang twice for no ship anyone could see.",
            at: .end)
        let fannedScrap = try ops.newBlock(
            in: scrapPool.id,
            text: "a scrap with two takes — \u{2325}-drag me and both come along.",
            at: .end)
        try take(on: fannedScrap,
            "the second take of the scrap — riding along on an \u{2325}-drag.")

        _ = try lesson(library, "export — it's all yours", [
            "Your work is always yours to take out. Any note exports as "
            + "Markdown or PDF from the library's right-click Export menu; a "
            + "block exports alone via File \u{25B8} Export Block as Markdown\u{2026}; a "
            // 13i-d U7 (F-U1-5): the book's row on the BOOKCASE carries Export.
            + "book exports as one document — its chapters as headings, this "
            + "very book included — from its row's right-click on the Bookcase; and "
            + "File \u{25B8} Export Library\u{2026} writes the whole library as a folder "
            + "of Markdown in one gesture.",

            "Exports are honest projections: the chosen take in place, and "
            + "Markdown with Takes\u{2026} adds a labeled Alternates section for "
            + "every fanned block, so nothing you kept open is lost on paper. "
            + "Try it on the choosing lesson — its four rain takes all reach "
            + "the page.",

            // 13r U3-A — R-13r-14 (her refinement at the U3 kickoff,
            // verbatim: *"if the user guide needs an updated backups session
            // reflecting where you can choose a backup folder … add that."*).
            // The guide covered backups only custody-side (the privacy
            // chapter's "what opens a backup"); these two paragraphs say
            // WHERE backups live on their own and teach the second-folder
            // door, in the same words as the pane and as the offer the app
            // makes a few days in (R-13r-12's toast, whose Set Up… opens the
            // same choice). Every name below is the surface's own constant.
            // Placement (the U3-A RECORD's piece 3 says why): this lesson,
            // because export is the copy you TAKE and a backup is the copy
            // Variorum KEEPS — the same promise, "it's all yours", from the
            // other side; the Mac-only seeder, so the phone (which has no
            // picked-folder road) is never told about a door it lacks.
            "BACKUPS happen on their own. Once a day while Variorum is open, it "
            + "copies your whole library into a backups folder right beside the "
            + "library, on this Mac \u{2014} no button, nothing to remember. Those "
            + "copies survive a mistake; they don\u{2019}t survive losing the Mac.",

            "So you can add a second folder of your own choosing \u{2014} iCloud "
            + "Drive, an external drive, any folder your cloud service syncs \u{2014} "
            + "and every backup lands there too: Settings \u{25B8} "
            + "\(SettingsPane.dataSafety.title), under \u{201C}"
            + "\(DataSafetyCopy.secondFolderSection)\u{201D} \u{2014} its "
            + "\(CapabilityRegistry.capability(.chooseBackupFolder).verb) button. If you "
            + "haven\u{2019}t picked one, Variorum offers it a few days into your "
            + "writing, with a quiet note at the bottom of the window: \u{201C}"
            + "\(ProtectionCopy.iCloudOfferTitle)\u{201D}",
        ])

        let sealed = try lesson(library, "the seal", [
            "This note is SEALED — marked complete. Everything under a sealed "
            + "note refuses to change: typing, new takes, commits, divides, "
            + "all of it, until you unseal.",

            "Try to break it. Press \u{2318}S to commit, or \u{2318}\u{21E7}D to divide — each "
            + "attempt is answered OUT LOUD at the bottom of the window: the "
            + "app tells you the note is sealed rather than doing nothing. "
            + "Typing simply finds the text read-only. A door that can't act "
            + "tells you why, never nothing.",

            "The seal is reversible and gentle: the unseal door sits in the "
            + "bottom bar's note \u{25BE} group. Unseal this note, change a word, "
            + "seal it again (same place). Sealing quietly commits any unsaved takes "
            + "first — the guard insures exactly what it protects.",
        ])
        try ops.lockPost(sealed.post.id)

        // ————————————————————————— books & the bookcase —————————————————————
        //
        // 13i-d U7 — THE BOOKS CHAPTER (the sitting record §25). Her eleven
        // lesson sentences, kept as close to her words as the shipped
        // surface's own words allow (the WHAT is ruled; 13s re-voices), and
        // her five rituals as things to DO here. Written PLAINLY — never
        // interpolated from the constants the chapter's suite ties each door
        // to (the H pattern), so a renamed door turns a lesson red rather
        // than merely wrong. Every sentence below is executed headless by
        // `TutorialBooksChapterTests`.

        // Lesson 1 + ritual R1 — the classics walk (§7/§17(b): the seeded
        // lesson the Welcome arrangement puts on the Welcome shelf).
        _ = try lesson(books, "the classics walk", [
            "Three kinds of thing live on your Bookcase, and this whole chapter "
            + "rests on telling them apart. A GATHERING shows you every note "
            + "matching its rule \u{2014} it holds nothing. A BOOK holds its notes "
            + "as members. An OWNED book is the only place its notes live.",

            // 17y B-DEDUPE (R-17y-8): Jekyll left the default seed, so the
            // lesson teaches with what stands — Sherlock (owned), this guide
            // (a plain book), the classics gathering — and carries her
            // intake's own sentence: Jekyll is one Restore press away, an
            // example you choose. Words functional, 13s re-voices.
            "All three are waiting on the Welcome shelf, where this guide sits "
            + "too. Open the Bookcase in the sidebar, and on Welcome open the "
            + "gathering called \u{201C}classics\u{201D}. Every Sherlock note wears "
            + "the tag #classics, and the gathering is made from that tag \u{2014} "
            + "so it shows every note wearing it without holding a single one "
            + "of them.",

            "Look closer: every Sherlock note wears a quiet \u{201C}owned by\u{201D} "
            + "mark naming its book. That book OWNS its notes \u{2014} they live there "
            + "and nowhere else. This guide is the plain kind: a book whose notes "
            + "are ordinary members, free to live in other books too. And a second "
            + "classic is one press away \u{2014} Help \u{25B8} Restore "
            + "\u{201C}\(SampleLibraryJekyllBook.name)\u{201D} adds it as an example: "
            + "its notes arrive wearing #classics and join this gathering beside "
            + "Sherlock's.",

            "Click a Sherlock note's mark and you land in its book, at that very "
            + "note. A gathering is a window onto notes that live somewhere; the "
            + "mark is the door to where they live.",
        ])

        // The old "books & the shelf" lesson's working paragraphs, swept
        // (the area is the BOOKCASE; finishing and deleting moved to their
        // own lessons below).
        _ = try lesson(books, "a book from the inside", [
            "You are inside a BOOK right now: an ordered collection of notes "
            + "with real chapters. The chapter list on the left is workable: "
            + "\u{FF0B} new chapter, right-click a chapter to rename, move, or "
            + "delete it, and drag the \u{28FF} dots \u{2014} in the list or on the "
            + "page's chapter headings \u{2014} to reorder chapters. \u{FF0B} new note "
            + "mints a note right inside the book. Notes show as collapsed cards: "
            + "clicking a card opens the note in the full editor; its \u{25B8} "
            + "expands it in place, right here.",

            // librarywalkpolish VR-122 (F-10): the toggle is FOUR —
            // Outline · Index · Book · Read (`BookView.bookMasthead`; the book
            // Index since pre-13u Act 10 wave 2c, editable in place since the
            // correction round). Words functional, 13s re-voices.
            "Four views of a book share the toggle at the top. OUTLINE is "
            + "this scroll, and it is where a book gets WRITTEN: chapter "
            + "headings, notes you can collapse, and the same editor you "
            + "write a note in. INDEX keeps a column of the chapters and notes "
            + "beside the whole text; click any block in the text and it goes "
            + "live right where it is. BOOK is a two-page spread \u{2014} each page is one "
            + "whole note, and the page you are in is editable as Write or "
            + "as its takes; \u{25C0} \u{25B6} turn the leaf two notes at a "
            + "time, and \u{25C1} \u{25B7} nudge by one so you can re-pair. "
            + "READ is for reading only, in two faces: SCROLL, the whole "
            + "book as one calm continuous page, and PAGES, real book pages "
            + "with the text flowing across them \u{2014} turn the leaf, or scrub. "
            + "A finished book opens into Read by itself.",

            "A book can carry a word target (right-click it on the Bookcase "
            + "\u{25B8} Length & Extent\u{2026}) \u{2014} this one wears one, so its "
            + "row on the Bookcase shows progress. A single note can wear its own "
            + "target too: click the word counts in the editor's bottom bar. "
            + "Targets are a measure, never a wall.",
        ])

        // Lesson 2 (the edit law, her sentence nearly verbatim) + ritual R2 +
        // lesson 8's first sentence, where the ritual meets it.
        _ = try lesson(books, "membership, not ownership", [
            "Editing a note that is in a book is always editing every book it "
            + "appears in \u{2014} owned or not. Adding a note to a book never copies "
            + "it. A copy only ever happens because you asked for one, and it "
            + "always remembers where it came from.",

            "Try it, start to finish. On the Bookcase press \u{FF0B} New Book and "
            + "make a book called \u{201C}practice\u{201D}; inside it, \u{FF0B} new "
            + "chapter, then \u{FF0B} new note, and write a line. Make a second book "
            + "the same way. Now put that same note in the second book too: click "
            + "the line naming the note's book at the top of its page, and the "
            + "panel it opens has Add to Book.",

            "Edit the note from either book and look at the other: it changed "
            + "too, because it is ONE note in two books. Then delete one of the "
            + "books \u{2014} right-click it on the Bookcase \u{25B8} Delete "
            + "Book\u{2026}. Deleting a plain book never touches a note: yours is "
            + "still there, in the other book and in the Library.",

            "A deleted book waits \(TrashWindow.days) days in the Trash (the "
            + "trash icon at the top of the Library) with a Put back door \u{2014} "
            + "its chapters and memberships come back with it. The only way a "
            + "note dies is deleting the note.",
        ])

        // Lesson 3 + ritual R3 + lesson 4 (with item 10's road back).
        _ = try lesson(books, "gatherings & arrivals", [
            "A gathering is made from a tag. Remove the tag and the note leaves "
            + "on its own. You can't rearrange a gathering \u{2014} bind it into a "
            + "book to take it in hand, and it keeps collecting after you do.",

            "Try it with two of this chapter's own lessons. Give this lesson and "
            + "the next one a tag of your own \u{2014} say #trial, with the "
            + "\u{FF03} on the masthead. On the Bookcase, \u{FF0B} New Book "
            + "\u{25B8} Create Gathering\u{2026}, and gather from #trial: both "
            + "lessons show. Take the tag off one \u{2014} it leaves the gathering "
            + "at once.",

            "Now right-click the gathering on the Bookcase \u{25B8} Bind into a "
            + "Book\u{2026}. It becomes a book holding the lesson it showed "
            + "\u{2014} and it keeps collecting: tag the other lesson #trial again "
            + "and the book takes it in. Being a book, it can wear your own "
            + "order: drag one note above the other. Then take the tag off "
            + "either one \u{2014} it STAYS. A book's notes are members, and "
            + "untagging never sends a member away.",

            // 17y B-DEDUPE (B3's F-B3-1): the door moved to the book
            // masthead's Arrivals icon at 17y B3 (R-17y-1/2) — the lesson
            // names the face that exists. Words functional, 13s re-voices.
            "A collecting book auto-adds freely; anything it can't seat on its "
            + "own waits at Arrivals \u{2014} the little tray beside the book's "
            + "settings gear \u{2014} for you to judge: add it, copy it in, or dismiss it. "
            + "Finishing a book dismisses whatever is still waiting. Changed your "
            + "mind? Add it by hand; dismissing only stops the book from adding "
            + "it on its own.",
        ])

        // Lesson 5 + ritual R4 + lesson 6 + lesson 8 whole.
        _ = try lesson(books, "owned, finished, sealed", [
            "Put a note in an owned book and that book is its home. Want it "
            + "elsewhere too? You'll get a copy, and you'll know. Remove it and "
            + "it goes back to the Pool, whole.",

            "Try it on your \u{201C}practice\u{201D} book: right-click it on the "
            + "Bookcase \u{25B8} Own Its Notes\u{2026}. Now add its note to "
            + "another book \u{2014} the app stops and offers the copy, and says "
            + "so. Then, inside the book, right-click the note \u{25B8} Release "
            + "from This Book: it goes to the Pool, whole. (On a book that "
            + "doesn't own its notes the same door reads Remove from This Book.)",

            "Finished means the table of contents is done \u{2014} the writing "
            + "inside can still change. Sealed means the book is done. Both "
            + "doors are on the book's right-click and in its Book "
            + "Settings\u{2026}: Finish and Seal\u{2026}, and Reopen and Unseal "
            + "take them back.",

            "Deleting a plain book never touches a note. Deleting an owned book "
            + "asks: keep the notes (they go to the Pool) or take them too. The "
            + "Trash gives back whatever went in together, together.",
        ])

        // Lesson 7 + ritual R5 (its drags are hers; every drag has a menu
        // twin, named here too) + the place/finder boundary (§22/§23).
        // librarywalkpolish F-BW-1 (round 1's MINOR-3, a PRE-0.9.2 GATE):
        // "my order" and Send to Top/Bottom step back for 0.9.2 (VR-118, her
        // R-LWP-4), so the lesson teaches what the release ships — the
        // order ▾'s A–Z · last edited and the drop onto a shelf's name.
        // Words functional; 13s re-voices; VR-120's return brings the
        // hand-placing sentence back (`noLessonTeachesADoorThisReleaseHides`
        // holds every lesson to the release's doors).
        _ = try lesson(books, "the bookcase", [
            "Your books live on shelves, alphabetical until you choose otherwise. "
            + "The shelves run left to right exactly as All stacks them top to "
            + "bottom. Unshelved books wait at the top until you file them.",

            // librarywalkpolish VR-122 (F-11 — the round-2 ladder's one note
            // for this pass): the strip reads All · starred · the shelves since
            // 17y (s) (R-17y-9's VIRTUAL shelf — no menu, never deleted).
            "The shelves are the strip across the top of the Bookcase: All, "
            + "then starred, then each shelf by name \u{2014} Welcome is the one this guide "
            + "came on. Starred isn't a shelf you file into: it shows every starred "
            + "book, wherever it's shelved, and it can't be renamed or deleted. "
            + "\u{FF0B} shelf makes another; right-click a shelf to "
            + "rename it, give it a glyph, make it the default, or delete it "
            + "(its books just return to Unshelved). The order \u{25BE} beside "
            + "them reads A\u{2013}Z or last edited.",

            "Try it: drag a book onto a shelf's name to file it there (or "
            + "right-click the book \u{25B8} Move to Shelf). Switch the order "
            + "\u{25BE} to last edited and the books you worked in most recently "
            + "come first. Then star a book (right-click \u{25B8} Star): starred "
            + "books float first, under any order, and starred gathers them all "
            + "in one place.",

            "The Bookcase is a PLACE \u{2014} arranged by you, and it stays "
            + "where you put it. Finding is the Library's work: search and the "
            + "day filter live there, never here.",
        ])

        // Lesson 9 WHOLE — its second sentence (archive · can't delete ·
        // comes back) landed WITH 13i-e's guard (F-U7-2's pin flipped at
        // 13i-e U2) — + lesson 10, shown on the seeded quicknote the Welcome
        // arrangement left in the Pool.
        _ = try lesson(books, "the journal & the pool", [
            "The daily Journal is an ordinary book that is special in one way: "
            + "it's where \u{2318}J and Today's Entry file. You can archive it; you "
            + "can't delete it; it comes back when a day arrives. Today's Entry sits at "
            + "the top of the Bookcase; the Journal itself waits among your "
            + "unshelved books until you file it.",

            "The Pool is every note with no book. Notes that show in gatherings "
            + "tuck behind the count in its masthead \u{2014} one click shows them.",

            "There is one waiting for you: \u{201C}a first quick note\u{201D} has "
            + "no book, so it lives in the Pool \u{2014} and \(Operations.defaultQuicknoteBookName) shows it, "
            + "so it tucks behind the count. Open the Pool, click show, and there "
            + "it is.",
        ])

        // Lesson 11 (+ §18.6's small note: the Work is a SHELF; a wing when
        // you want true separation).
        _ = try lesson(books, "wings", [
            "A wing is a separate library in the same app \u{2014} a different room "
            + "in the same house. Nothing crosses between wings except what you "
            + "move or copy yourself.",

            "Most separation wants a SHELF. A wing is for when you want a whole "
            + "separate library: the Bookcase's masthead names the one you're in "
            + "\u{2014} Home, to begin with \u{2014} and its menu has New "
            + "Wing\u{2026}. Switch, and everything shows that wing alone: the "
            + "Bookcase, the Library, the Pool, your tags, search.",

            "Once a second wing exists, a note's right-click carries Move to "
            + "Wing and Copy to Wing, and a book's carries Move to Wing. Those "
            + "are the only crossings. Home "
            + "holds the daily Journal, your quick notes and this guide, and it "
            + "can't be deleted.",
        ])

        return book.id
    }
}
