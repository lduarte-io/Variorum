//
//  MobileTutorialSeeder.swift
//  VariorumMobile
//
//  Parity round Stage B, batch B1 (P-6: the tutorial is the executable
//  spec — the 13b tutorial-as-spec precedent, phone-native): THE POCKET
//  GUIDE — a curated book built of the app's own objects, teaching the
//  PHONE's app in the phone's own vocabulary. Real chapters
//  (`reading_section` rows), lessons as act-ready notes, instructions in
//  the prose: by the time the reader has read the book she has used
//  books, chapters, notes, blocks, and takes. `MobileTutorialWalkTests`
//  executes every lesson's acts headlessly through the same
//  controllers/operations the app's own surfaces route, and asserts the
//  STORE outcomes the prose promises — the round's permanent acceptance
//  spine.
//
//  This REUSES THE MAC SEEDER'S SHAPE (TutorialSeeder — seed through
//  ordinary Operations · discover-by-reserved-identity · wholesale
//  replace behind a spoken confirm · the quiet no-undo facade), NEVER
//  its Mac-specific copy or content: the lessons here are the phone's —
//  swipe, tap, long-press, the bottom bar's Aa · ⑂ · ⋯, the pill's ✓,
//  the shelf and the Library, contents-first books with the read door.
//
//  THE DEV-STORE FENCE (A4): the seeding DOOR is DEBUG-only (Settings),
//  and Debug builds resolve the dev store by construction — the pocket
//  guide never reaches her real corpus from this batch. The seeder type
//  itself compiles unconditionally so the walk suites (Debug) drive it;
//  a PRODUCT door on the phone is deliberately NOT built here
//  (PROVISIONAL PB1-1 — placement is hers).
//
//  Every write goes through Operations (never ad-hoc rows); all content
//  is NON-JOURNAL (`.generic`, no entry dates — R57: journal-shaped rows
//  are the daily Journal's and the phone's journal list's, and no tutorial
//  text may ever land there; the rule's original reason, the Fragments
//  bridge's day sweep, retired 2026-09-04 — the rule stays). Seeding runs through a QUIET Operations facade (undoStack: nil,
//  the Mac's MINOR-D1 discipline): a seed is not HER act, and nothing
//  here may land an inverse on the session's structural-undo stack.
//

import Foundation
import GRDB
import VariorumCore

enum MobileTutorialSeeder {
    // MARK: - Reserved identities (how Restore finds its own objects)

    /// Deliberately DISJOINT from the Mac's ("the field guide" /
    /// `tutorial`): if the two seeders ever meet on one store, neither
    /// cleanup can eat the other's book.
    nonisolated static let bookName = "the pocket guide"
    nonisolated static let tagName = "pocket guide"
    /// The bookless practice note the "getting around" lesson points at
    /// (the Library's bookless filter — the Pool's phone home, R29).
    nonisolated static let looseNoteTitle = "loose thought"

    /// What the confirm says before a wholesale replace — plain words,
    /// exact scope (the Mac's spoken-confirm discipline: the copy
    /// discloses the EXACT tag and the PLURAL name-based scope, because
    /// cleanup deletes every same-named book — colliding names included).
    nonisolated static let replaceQuestion = "Restore the pocket guide?"
    nonisolated static let replaceDetail =
        "This replaces the tutorial with a fresh copy: every note tagged exactly "
        + "\u{201C}\(tagName)\u{201D} and every book named \u{201C}\(bookName)\u{201D} "
        + "are deleted and re-seeded. Nothing else is touched."

    // MARK: - The lesson plan (the coverage CONTRACT, walk-asserted)

    /// Chapters and lessons, in book order. `MobileTutorialBookShapeTests`
    /// asserts the seeded book matches this exactly — a lesson that
    /// drifts out of the seed (or a seed that drifts out of the plan) is
    /// a red test.
    nonisolated static let plan: [(chapter: String, lessons: [String])] = [
        ("welcome", ["start here", "getting around"]),
        ("writing", ["blocks & typing", "formatting"]),
        ("takes", ["your first take", "swipe & choose", "the browser", "lenses"]),
        ("structure", ["divide", "divide with takes", "merge"]),
        ("the library of things", ["comments & callouts", "the seal", "the voice switch"]),
        // ROUND 2, BATCH 6b — **PR22, the deletion chapter** (§69.8). The
        // Mac's field guide teaches the five places, the two sizes of
        // moment, and the TWO EXITS by doing; this is the same map
        // RE-TAUGHT in phone grammar rather than copied, because the Mac's
        // text names Mac doors and chords (MobileSoul §4.4). It lands here,
        // after the things themselves and before privacy, because a reader
        // needs to know what a thing IS before being told where it goes.
        ("keeping & letting go", ["the five places", "the two exits"]),
        // PHASE 13p, knot 6 — the privacy chapter's PHONE edition, ONE
        // lesson. Her Batch-1 rider is why it is here at all: *"some
        // people will be mobile only users"* — a phone-only reader meets
        // no Mac and no field guide, so the teaching her knot-6 ruling
        // asked for has to exist on this device too. It is deliberately
        // SHORTER than the Mac's two-lesson chapter: the phone's Settings
        // ▸ Protection screen states the per-mode sentence, the chain and
        // the one-device fact live, so the lesson's job is to send the
        // reader there knowing what they will find.
        // pre-13x 5a: the lesson is copy §7's two lessons' paragraphs under
        // the copy's first title — ONE lesson, the phone's nouns; the door
        // to the seeded book *Encryption Explained* (in Home on the phone
        // too) carries the whole story.
        ("keeping it private", [ProtectionCopy.privacyLessonOneTitle]),
    ]

    // MARK: - Discovery (reads — the doomed set for a wholesale replace)

    /// ONE discovery per door entrance (the Mac's MAJOR-A discipline):
    /// the confirm gates on `isEmpty` — the SAME predicate as the
    /// destruction — and the SAME `Existing` flows into the replace, so
    /// what the user confirmed is exactly what dies.
    struct Existing: Sendable {
        var readingIDs: [String] = []
        var taggedPostIDs: [String] = []
        var tagID: String?
        var isEmpty: Bool {
            readingIDs.isEmpty && taggedPostIDs.isEmpty
        }
    }

    nonisolated static func discover(_ db: Database) throws -> Existing {
        var existing = Existing()
        existing.readingIDs = try Queries.readings(db)
            .filter { $0.name == bookName }
            .map(\.id)
        if let tag = try Queries.allTags(db).first(where: { $0.path == tagName }) {
            existing.tagID = tag.id
            // The EXACT tag, never the subtree (the Mac's MINOR-D3): the
            // seeder only ever applies `pocket guide` itself — a note
            // tagged `pocket guide/…` is hers, and the confirm's
            // disclosure must stay true.
            existing.taggedPostIDs = try Queries
                .everythingTagged(db, tagID: tag.id, includeSubtree: false)
                .postIDs
        }
        return existing
    }

    // MARK: - The doors

    /// Open door: an existing book simply reports/opens. No book but
    /// tutorial RESIDUE (tagged lessons a deleted book left behind) ⇒
    /// the restore path, `confirmReplace` included — the residue may
    /// include HER tagged notes, hers to refuse for. Nothing at all ⇒ a
    /// pure fresh seed (cleanup over an empty discovery is a no-op, so
    /// it is the same one shape). Returns nil when the confirm declined.
    @MainActor
    @discardableResult
    static func findOrSeed(
        session: AppSession, confirmReplace: () async -> Bool
    ) async throws -> String? {
        let existing = try await session.database.read { db in try discover(db) }
        if let bookID = existing.readingIDs.first { return bookID }
        if !existing.isEmpty {
            guard await confirmReplace() else { return nil }
        }
        return try await restore(session: session, existing: existing)
    }

    /// Restore door: wholesale replace — cleanup by reserved identity,
    /// then a pristine seed. Idempotent by construction (discovery finds
    /// whatever a partial earlier run left behind). The caller passes
    /// the SAME `Existing` its confirm disclosed (MAJOR-A).
    @MainActor
    @discardableResult
    static func restore(session: AppSession, existing: Existing) async throws -> String {
        try await session.runner.run { _ in
            // The QUIET facade (the Mac's MINOR-D1): same ambient
            // database, same serialized runner turn, NO undo stack —
            // the phone has no structural-undo door today, but entries
            // must not accumulate against the day it gains one.
            let quiet = Operations(undoStack: nil)
            cleanup(ops: quiet, existing: existing)
            return try seed(ops: quiet, existingTagID: existing.tagID)
        }
    }

    /// One-discovery convenience for direct callers (tests, the walks).
    @MainActor
    @discardableResult
    static func restore(session: AppSession) async throws -> String {
        let existing = try await session.database.read { db in try discover(db) }
        return try await restore(session: session, existing: existing)
    }

    /// Deletion is tombstones through Operations — everything
    /// recoverable like any note or book. Individual failures (a row
    /// already deleted, a race) are tolerated: the seed that follows is
    /// the goal. Doomed books are UNPINNED first so the shelf-pins
    /// setting never accrues dead ids across restores.
    nonisolated static func cleanup(ops: Operations, existing: Existing) {
        for postID in existing.taggedPostIDs {
            try? ops.deleteContainer(postID)
        }
        for readingID in existing.readingIDs {
            try? ops.setShelfPinned(readingID, pinned: false)
            try? ops.deleteReading(readingID)
        }
    }

    // MARK: - The seed (all content; Operations only)

    /// Mints the whole book and returns its id. `existingTagID` reuses a
    /// live `pocket guide` tag (createTag refuses duplicate live paths).
    nonisolated static func seed(ops: Operations, existingTagID: String?) throws -> String {
        let tagID: String
        if let existingTagID {
            tagID = existingTagID
        } else {
            tagID = try ops.createTag(name: tagName).id
        }

        let book = try ops.createReading(
            name: bookName, kind: .book, profile: "collection")
        // The shelf's pin face, taught by wearing it (pinned books sit
        // first — the guide leads the shelf so it is findable on a fresh
        // dev store; "getting around" says so). The star is a NICETY and
        // never worth failing the seed: since 13i-d U2's union star this
        // public door carries the 15-star cap, so with the cap full the
        // guide simply seeds unstarred (F-U2-1, the architect's
        // adjudication — every other refusal still aborts the seed).
        do {
            try ops.setShelfPinned(book.id, pinned: true)
        } catch OperationError.starLimitReached {
            // Proceed unstarred.
        }

        // Chapters, in reading order.
        let welcome = try ops.createSection(in: book.id, name: "welcome")
        let writing = try ops.createSection(in: book.id, name: "writing")
        let takes = try ops.createSection(in: book.id, name: "takes")
        let structure = try ops.createSection(in: book.id, name: "structure")
        let library = try ops.createSection(in: book.id, name: "the library of things")
        // Round 2, batch 6b — PR22's chapter (§69.8): the five-places map
        // and the two exits, in phone grammar.
        let keeping = try ops.createSection(in: book.id, name: "keeping & letting go")
        // 13p, knot 6: the privacy chapter (phone edition — one lesson).
        let privacy = try ops.createSection(in: book.id, name: "keeping it private")

        /// One lesson: a `.generic` note inside the book, tagged, blocks
        /// in order. Returns the minted blocks for act-ready staging.
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
            "Welcome. This is a book on your shelf, made of the same notes, "
            + "blocks, and takes everything you write here lives in. Each lesson "
            + "is a note, the chapters are real chapters, and every lesson asks "
            + "you to do the thing it teaches, right in its own text.",

            "Everything in this book is safe to play with. Rewrite it, cut it "
            + "up, delete it — Settings can restore the whole book to a fresh "
            + "copy whenever you want one. Nothing you do in here can touch "
            + "your own writing.",

            "When the app answers you — a result, a refusal — the answer "
            + "arrives in plain words on the page. A door that can't act tells "
            + "you why; it never does nothing.",

            "Read in order, or jump to what itches. When something doesn't "
            + "behave the way its lesson promises, that is a bug in the app, "
            + "not in you.",
        ])

        _ = try lesson(welcome, "getting around", [
            // Batch 6b (PR22's rider): this lesson described a shelf that
            // batch 5 had already replaced — Today's Entry as a full-width
            // door, and no mention at all of the quick-note box, which is
            // now half the screen. Rewritten to the shelf that exists.
            "The SHELF is home: your books at the top, with this one pinned "
            + "first — pinned books always sit first, and a long press on a "
            + "book row pins or unpins it. The daily journal's row wears a "
            + "small \(MobileShelfFaces.todayDoorTitle) badge: tap it and "
            + "today's entry opens, made if the day hasn't started yet. "
            + "(With no journal on the shelf the same door stands as its own "
            + "row at the list's end, and pressing it makes one.) + new note "
            + "starts a bookless note and drops you straight into writing; "
            + "+ new book, at the list's end, starts a fresh book — "
            + "hand-picked, a dated journal, or a smart book collecting by "
            + "tags. A long press also STARS a note or a book (up to fifteen) — "
            + "starred things sit above everything at the shelf's very top, "
            + "and the same press takes the star back off.",

            "Under the books is the QUICK NOTE box, and it is the shelf's "
            + "main room on purpose: just start typing and a note is already "
            + "being kept — no door to press first. The blinking cursor is "
            + "the invitation. The open ↵ door beside it takes what you've "
            + "written into the full editor when you want the rest of the "
            + "machinery; leave it alone and it stays a note like any other, "
            + "waiting in the Library.",

            "The LIBRARY tab is everything, newest first, with search across "
            + "titles, days, and book names — and a sort door: order the "
            + "list by entry date, created, last touched, or last "
            + "meaningful edit (fixing one typo never reshuffles that "
            + "last one). Its bookless filter is the pool: notes that "
            + "belong to no book yet. One loose practice note was seeded "
            + "there, so the filter has something to show you. The scraps "
            + "filter beside it is your pool of standalone blocks — loose "
            + "lines that live in no note — with + new scrap to keep "
            + "another.",

            "Tapping a book opens its CONTENTS — the chapter list you likely "
            + "arrived through. read, at the top, opens the same book as one "
            + "calm continuous page; details, beside it, holds the book's own "
            + "acts — rename it, finish or reopen it, or make it your daily "
            + "journal. Tapping any note, in either place, opens it for "
            + "writing.",

            "Writing happens in one place: the note's own page, one column, "
            + "nothing to manage. The machinery — takes, structure, comments — "
            + "is summoned per block from the bottom bar, and put away the "
            + "same way.",

            "The note's masthead is its identity: tap the title to rename "
            + "the note, tap the books line under it to see which books "
            + "hold it — add it to one, take it out of one, or diverge a "
            + "separate copy for a single book — and tap the date beside it "
            + "to set or clear the day this note counts as (journals sort "
            + "by it). Editing a note edits it everywhere it appears; "
            + "diverging is how one book gets its own. The magnifier up by "
            + "the title finds text inside this note — the system's own "
            + "find panel, and finding works even on a sealed note.",

            "The masthead's second line is the note's tags and its "
            + "sources: tap the tags to tag the note — type a tag and ⏎ "
            + "applies it, creating it if it's new (“/” nests: life/goals "
            + "makes the whole path), or tap a suggestion; ✕ takes one "
            + "off. Chips show a nested tag's last piece; the full path "
            + "lives in the sheet. more info, beside the tags, keeps "
            + "links and files with the note — tap a link to open it, or "
            + "add one; a file listed there stays on the device where it "
            + "was added, and only its name travels. blocks lists this "
            + "note's blocks — a block's name where you've set one, else "
            + "its first sentence, worked out fresh each time — and a tap "
            + "jumps you there. And lens, at the line's end, switches "
            + "between saved ways of looking at this note (the lenses "
            + "lesson shows it off).",

            "Settings, on the shelf's top line, holds the voice switch (the "
            + "last lesson), tag management — browse the whole tag tree "
            + "there, add tags and child tags, rename one (everything "
            + "nested under it follows), or delete one with its sub-tags — "
            + "and the door that restores this book.",
        ])

        // ————————————————————————————— writing —————————————————————————————

        _ = try lesson(writing, "blocks & typing", [
            "Everything you write is made of BLOCKS — paragraph-sized pieces "
            + "with permanent identity. You never manage them while drafting: "
            + "tap at the end of this note and type a few paragraphs. Each one "
            + "quietly becomes its own block as you type past it.",

            "Inside a block, return is just a new line — a block can hold "
            + "several paragraphs. Boundaries only change when you ask "
            + "(divide, merge — the structure chapter), and at rest the seams "
            + "are invisible: a note reads as calm, continuous prose.",

            "The bottom bar above the keyboard is the whole toolkit: Aa opens "
            + "the formatting strip, ⑂ opens the takes of the block you're in, "
            + "and ⋯ holds the block's own acts — comments, callout, "
            + "commits, a new block below, divide, merge, delete.",

            // The ROAD is composed, never re-typed (batch 9's fix wave,
            // cold-review MAJOR 2): `Block History…` LEFT the block ⋯ at
            // batch 9 — her letter moved it onto each take's own ⋯ — and
            // this lesson still taught the retired road. The row's word
            // comes from the door itself (`historyTitle`, composed in its
            // turn from the SHARED `BlockHistoryPath.name`), so a re-word
            // lands here for free and a MOVE reds the walk's pin.
            // 13s-b U4 (her R-13s-31, "I want that changed everywhere"):
            // the pocket guide's five savepoints became commits; this
            // defined term is written lowercase, her no-caps-for-emphasis
            // rule (the guide's other caps are a later pass's, not U4's).
            "Your writing is always autosaved; a commit is the "
            + "deliberate extra. \(MobileBlockMenuController.commitTitle), in ⋯, "
            + "keeps the exact text of the take you're in, forever — and the "
            + "moments themselves are read back one door along: ⑂ on the "
            + "bottom bar opens this block's takes, and each take's own ⋯ "
            + "carries \(MobileTakesBrowserController.historyTitle), which opens "
            + "everything this block has been: every take's saved "
            + "moments, with restore; the takes it archived or deleted, with "
            + "a way back; and the block it came out of. A commit from "
            + "before a divide says so, and asks first: restoring it brings "
            + "back the whole pre-split text.",

            "The page keeps a little room below the last line — typewriter "
            + "room — so what you're typing never sits against the bottom "
            + "edge of the screen.",
        ])

        // Written IN the vocabulary it teaches (the Mac formatting
        // lesson's device, phone-authored): storage IS markdown, so this
        // prose literally demonstrates itself the moment it is seeded.
        _ = try lesson(writing, "formatting", [
            "Formatting is **markdown**, and what you see is exactly what is "
            + "saved: two stars around a word ARE the bold. The editor styles "
            + "the word and dims the stars, so the page reads cleanly while "
            + "the text stays plain characters you could open anywhere.",

            "The vocabulary is small: **bold**, *italic*, `inline code`, "
            + "~~struck words~~, and [links](https://commonmark.org). "
            + "Aa on the bottom bar opens the strip — one row, every act "
            + "on it — and B or I wraps whatever you've selected. Press the "
            + "same button again and it takes the marks off; the act reads "
            + "what is already there rather than blindly adding.",

            "Three more character acts sit beside them: S strikes a "
            + "selection through, ⟨⟩ marks it as inline code, and the link "
            + "glyph wraps it as [text]() with the caret waiting between "
            + "the parentheses for the address. Same toggle rule, same "
            + "plain characters.",

            "## Headings are sizes",

            "A line starting with #, ## or ### is a heading — those three "
            + "and nothing else. Tap # in the strip to cycle this line "
            + "through them; press and HOLD it to pick Heading 1, 2, or 3 "
            + "directly, or clear one.",

            "- lists are lines that start with \u{201C}- \u{201D}",
            "- the strip's • makes one of the line you're in",

            "- [ ] a checkbox is a list item with a box",
            "- [x] tap a box on the page to tick it — an ordinary edit, so "
            + "a sealed note refuses it",

            "⇥ nudges a list line deeper and ⇤ brings it back out — the "
            + "two live side by side at the end of the strip. (Holding ⇥ "
            + "still outdents too, if your thumb is already there.) And "
            + "when you open this book through read, the markers "
            + "disappear — headings become sizes, boxes become boxes. "
            + "Everywhere you can write, you see the text exactly as it is "
            + "saved.",
        ])

        // ————————————————————————————— takes ———————————————————————————————

        _ = try lesson(takes, "your first take", [
            "The fan is the reason this app exists: a block can hold several "
            + "parallel TAKES — whole alternative texts, side by side, none "
            + "of them lost, for as long as you like. Most blocks live with "
            + "one take; the ones you're unsure about can hold ten.",

            "The next paragraph can't decide what it wants to be. It's yours "
            + "to fan out.",

            "The harbor kept its lights on for boats that had long since "
            + "found other shores.",

            "Tap into that paragraph and open ⑂ from the bottom bar: the "
            + "takes sheet rises over the page. + new take · branch this one "
            + "mints a copy of the take you were reading — rewrite it "
            + "freely; the first is untouched. blank starts an empty one "
            + "instead, for a genuinely different attempt. Minting never "
            + "chooses: the note keeps saying what it said.",
        ])

        let swipe = try lesson(takes, "swipe & choose", [
            "Takes are for trying; CHOOSING is deciding. The take with the ✓ "
            + "is what the note actually says. Only the ✓ — on the pill, or "
            + "on a card in the takes sheet — ever changes that.",

            "The block below carries three takes of one sentence, staged for "
            + "your thumb. Swipe it sideways — right on the text — and the "
            + "takes flip in place.",

            "The rain came in from the sea without an opinion about any of us.",

            "A flip is a PEEK: you are viewing a different take, and the note "
            + "still says what it said. The peek is sticky — a small marker "
            + "sits by the block while it holds, and the pill under the page "
            + "counts take 2/3 with ◀ ▶ and the ✓. Tap ✓ when a take should "
            + "BE the note; the peek ends, because what you see is now "
            + "simply what the note says.",
        ])
        let rain = swipe.blocks[2]
        try take(on: rain,
            "The rain arrived off the sea like a verdict none of us had appealed.")
        try take(on: rain,
            "The rain came in from the sea, and the sea did not explain itself.")

        let browser = try lesson(takes, "the browser", [
            "⑂ on the bottom bar — or a tap on a fanned block's ⑂ badge — "
            + "opens the takes sheet over the page. Every take is a card; "
            + "the ✓ card is the chosen one; a peeked card says so.",

            "The sheet holds all four verbs. Tap ✓ on any card to choose "
            + "it. + new take branches the one you were reading, or starts "
            + "blank. Tap a card to edit it right there — the card becomes "
            + "the page's one live editor. And each card's ⋯ holds the "
            + "take's own acts — label, lock, archive, delete.",

            "The keeper logged the weather twice, in two different moods.",

            "That block carries a spare take to practice on — archive it "
            + "from its card's ⋯ and it leaves the fan: out of the way, "
            + "kept just below under archived, never gone — unarchive "
            + "there brings it straight back. A block always keeps one "
            + "take: removing the last one refuses out loud and points at "
            + "Delete Block instead — that isn't a take act, it's "
            + "deleting the block.",

            // Parity C4a: the lock door's lesson lands WITH the door
            // (tutorial-as-spec) — appended after the staged paragraphs
            // so the walks' staging indices stand.
            "A LOCK is a reversible guard on one take: its text refuses "
            + "edits until you unlock it — one tap in the same ⋯ — or "
            + "branch a fresh copy. Locking a take that has unsaved "
            + "changes quietly commits it first, so the guard "
            + "insures exactly what it protects.",

            "A LABEL is a short name on a take's card — \u{201C}bolder "
            + "opening\u{201D}, \u{201C}the calm one\u{201D} — set from the same ⋯. "
            + "It names the take wherever its card appears, archived "
            + "included, and is never printed in the prose.",
        ])
        try take(on: browser.blocks[2],
            "the spare take — archive me from my card's ⋯.")

        // Parity C5 — the lens lesson lands WITH the door
        // (tutorial-as-spec). A staged fan to arrange, and a seeded
        // saved lens so the sheet has a way of looking to switch to on
        // first open (the walk drives both).
        let lensing = try lesson(takes, "lenses", [
            "A LENS is a saved way of looking at this note: which take "
            + "each block shows, remembered under a name. The note itself "
            + "never moves — a lens is viewing, not choosing, so switching "
            + "lenses writes nothing and works even on a sealed note.",

            "The lighthouse keeps its own hours.",

            "Tap lens on the masthead's second line to open the sheet: "
            + "the note is what the note really says, and each saved lens "
            + "is one tap to view. This note ships with one — switch to "
            + "it and the block above flips to its other take, wearing "
            + "the peek marker, because a lens IS a saved set of peeks. "
            + "Swipe blocks to takes you like and save the current view "
            + "as a lens, or save into the one you're in. And when a "
            + "view should BE the note, ✓ make this the note adopts it — "
            + "keeping the old arrangement as a lens of its own, so the "
            + "road back stays visible.",
        ])
        let lighthouse = lensing.blocks[1]
        let lighthouseTake = try take(on: lighthouse,
            "The lighthouse answers to nobody's clock.")
        let otherReading = try ops.createLens(
            post: lensing.post.id, name: "the other reading")
        _ = try ops.setLensChoice(
            lens: otherReading.id, block: lighthouse.block.id,
            variant: lighthouseTake.id)

        // ———————————————————————————— structure ————————————————————————————

        _ = try lesson(structure, "divide", [
            "Divide cuts a block in two at your cursor — the everyday "
            + "gesture for \u{201C}this part should stand on its own.\u{201D} The cut "
            + "lands between words, snapping to the nearest word edge and "
            + "settling a little more readily onto sentence ends and line "
            + "breaks.",

            "This block holds two thoughts and they deserve two blocks. Put "
            + "the cursor right before this second sentence and choose "
            + "Divide Block from the bottom bar's ⋯.",

            // 13u4 UNIT E3 (her ruling R-13u4-3, core-side so the phone
            // flips with the Mac): this promised a sentence cut restored
            // exactly, which merge no longer does.
            "The two halves are both blocks now, each free to grow its own "
            + "takes. Merge is the road back: the seam becomes a line break "
            + "inside the merged block, so a paragraph you divided comes "
            + "back exactly as you wrote it.",

            "Two more knives live on the SELECTION menu — select some words "
            + "and look: Extract Selection lifts a run at a block's start or "
            + "end into its own block (the source keeps the rest, its takes "
            + "untouched), and Make Block from Selection carves a middle "
            + "span out as its own block. Both settle onto word edges, like "
            + "divide's cut.",
        ])

        let fannedDivide = try lesson(structure, "divide with takes", [
            "Dividing a block that has several takes follows one simple "
            + "rule on the phone: the take you're READING is cut in two, "
            + "and every other take rides along whole — copied onto both "
            + "halves, so nothing needs a matching cut and nothing is lost.",

            "The extra copies are quick to delete where you don't want "
            + "them — quicker than hunting for a lost take ever was. The "
            + "original block keeps everything, off-stage, in lineage.",

            "The ferry crossed at dawn. Nobody on board spoke about the "
            + "storm.",

            "Try it: swipe that block to the take you want cut, put the "
            + "cursor mid-sentence, and Divide Block. The peeked take is "
            + "the one that divides — the cut follows what you see.",
        ])
        try take(on: fannedDivide.blocks[2],
            "At dawn the ferry crossed. The storm stayed in everyone's "
            + "coat pockets, unmentioned.")

        let merging = try lesson(structure, "merge", [
            // 13u4 UNIT E3 (R-13u4-3) — see the divide lesson above.
            "Merge is divide's opposite: the block you're in joins the one "
            + "above it. The seam between them becomes a line break inside the "
            + "merged block, so the page reads exactly as it did — divide at a "
            + "paragraph break and merge it back and you get precisely what "
            + "you started with.",

            "These two short blocks are really one thought.",

            "They have been waiting for a merge since the day they were "
            + "seeded.",

            "Put the cursor in the second one and choose Merge with "
            + "Previous from ⋯. When either block holds other takes, they "
            + "all ride along: the two takes you can see join into one, "
            + "and every other take lands whole on the merged block — "
            + "quick to delete if you don't want them, never lost. The "
            + "block below carries a spare take, so merging it upward "
            + "shows you the ride.",

            // The staged cursor-instruction block the STRUCTURE WALK cuts
            // (PB1-3's sanctioned coupling class — the walk asserts this
            // text rides the join): reword WITH the walk or not at all.
            "This block has a spare take, so a merge here carries it "
            + "along whole.",
        ])
        try take(on: merging.blocks[4],
            "the spare take that rides the merge whole.")

        // —————————————————————— the library of things ——————————————————————

        let commentsCallouts = try lesson(library, "comments & callouts", [
            "A COMMENT is a working note on a block — about the writing, "
            + "not in it. This block carries one; the ●1 at its edge says "
            + "so. Open ⋯ and Comments to read, add, edit, or delete them — "
            + "deleted ones stay listed and can come back.",

            "A CALLOUT is a colored frame that says \u{201C}this one is "
            + "different\u{201D}: an aside, a goal, a warning. This block wears "
            + "one. ⋯ and Callout toggles the frame, sets a leading emoji, "
            + "or removes it — presentation only; the text itself is "
            + "untouched.",

            "Comments and callouts both survive the knife: divide or merge "
            + "a block that carries them and they ride onto the successors.",
        ])
        _ = try ops.addBlockComment(
            to: commentsCallouts.blocks[0].block.id,
            text: "a comment lives beside the block — about it, never inside its text")
        try ops.setBlockPresentation(
            commentsCallouts.blocks[1].block.id,
            BlockPresentation(color: "blue", emoji: "\u{1F4A1}"))

        let sealed = try lesson(library, "the seal", [
            "This note is SEALED — marked complete. Everything under a "
            + "sealed note refuses to change: typing, takes, dividing, all "
            + "of it, until you unlock.",

            "Try it: tap into this text and type, or open ⋯ and Divide "
            + "Block — each answer arrives in plain words: the note is "
            + "locked, unlock it to go on. A door that can't act tells you "
            + "why.",

            "The lock lives on the masthead, up by the title: one tap "
            + "unlocks, one tap seals again. Sealing quietly commits "
            + "any unsaved take first — the guard insures "
            + "exactly what it protects.",
        ])
        try ops.lockPost(sealed.post.id)

        _ = try lesson(library, "the voice switch", [
            "The app speaks in two voices. TERMINAL is monospace and "
            + "lowercase, with the › and the blinking block cursor; STUDY "
            + "is serif and bookish, warm paper instead of cool glass. "
            + "Settings — on the shelf's top line — is where you switch.",

            "Switch and come back: every word of this book is exactly "
            + "where it was. The voice restyles every face of the app and "
            + "touches no text at all — what a note says and how the app "
            + "dresses are different things, and only you change either.",
        ])

        // ———————————————————————— keeping & letting go ————————————————————
        // PR22 (§69.8): the five-places map and the two exits, re-taught in
        // phone grammar. Nothing here names a Mac door or a chord.

        _ = try lesson(keeping, "the five places", [
            "Everything you have ever written here is in exactly ONE of five "
            + "places. When something isn't where you left it, this is the "
            + "list to walk — and the point of the list is that it is short "
            + "and it is complete.",

            "1 — WHERE YOU LEFT IT: in its note, in the books that hold it, "
            + "in the Library. Most of the time that is the whole answer.",

            "2 — ARCHIVED: kept out of the way, forever, with no countdown. "
            + "Whole NOTES have their own room, the Archived row at the end "
            + "of the Library's list. A single BLOCK you set aside stays with "
            + "its note — tap blocks on the masthead, then the archived "
            + "segment. Archive Block, in the bottom bar's ⋯, is how one "
            + "gets there, and Put back is how it comes home.",

            "3 — THE TRASH: what is leaving. Notes, books and blocks, each "
            + "with \(TrashWindow.days) days on a countdown you can see and "
            + "Put back on every row; the 🗑 sits on the Library's top line "
            + "and on the Shelf's. Delete Now, in the Trash, ends the days "
            + "early — and asks first, every single time.",

            "4 — THIS NOTE'S VERSIONS: the moments you saved of the whole "
            + "note. ⋯ up by the title, then Versions… — read one, restore "
            + "it, or promote it into a note of its own.",

            // **THE GUIDE'S ONLY ROAD to the came-from and deleted-takes
            // regions**, so a wrong sentence here is worse than a dead
            // door — it is a TAUGHT road that cannot act (P-2's own
            // class). Batch 9 moved the face off the block ⋯ and onto
            // each take's; the road below is composed from the door that
            // now carries it.
            "5 — THIS BLOCK'S HISTORY: one block's whole time. ⑂ on the "
            + "bottom bar opens this block's takes; each take's own ⋯ carries "
            + "\(MobileTakesBrowserController.historyTitle) — every take's saved "
            + "moments, the takes this block archived or deleted, and the "
            + "block it came out of.",

            "TAKES are the one thing that never rows in the Trash: a take on "
            + "its own is too small to make sense of out of context. It has "
            + "two homes instead — its block's History, and its note's "
            + "blocks ▸ leaving, which lists every deleted take of every "
            + "block in this note and is the only place a take can be ended "
            + "early.",
        ])

        let exits = try lesson(keeping, "the two exits", [
            "There are exactly TWO ways a thing leaves the page, and they "
            + "are not the same thing. Telling them apart is most of knowing "
            + "where to look.",

            "DELETION GOES TO THE TRASH. Delete a block, a note or a book "
            + "and nothing is destroyed: it is marked, given "
            + "\(TrashWindow.days) days, and listed where you can see the "
            + "clock run. Put back is on the row for the whole window.",

            "TRANSFORMATION GOES TO LINEAGE. Divide a block and the original "
            + "is kept WHOLE and set aside — it was never deleted, so it is "
            + "not in the Trash and wears no countdown. Merge two blocks and "
            + "both originals are kept the same way. They wait in Block "
            + "History ▸ Came from, with Bring back.",

            "Both exits, on the block below. First: ⋯ ▸ Delete Block, then "
            + "tap blocks on the masthead and the leaving segment — its row "
            + "is there with its days, and Put back returns it. Then put the "
            + "cursor mid-sentence and ⋯ ▸ Divide Block, and open Block "
            + "History ▸ Came from on either half: the block you just cut is "
            + "standing there whole.",

            "Delete me and put me back, then cut me in two. Nothing you do "
            + "to this paragraph can lose it.",
        ])
        // The lesson's last block is the one it asks her to act on; a take
        // on it makes the divide the second half teaches the fanned kind,
        // whose original is exactly what "Came from" holds.
        try take(on: exits.blocks[4], "Delete me, put me back, then cut me in two.")

        // ————————————————————————— keeping it private ————————————————————
        //
        // pre-13x 5a — copy §7's SHORT chapter in the phone's one-lesson
        // edition: both lessons' paragraphs VERBATIM from the copy constants
        // (`PostureCopy.swift`), the phone's nouns riding the interpolation
        // (iPhone · Face ID), under the copy's first title. The 13p dials
        // lesson retired with the presets and the reset door it described.

        _ = try lesson(privacy, ProtectionCopy.privacyLessonOneTitle,
                       ProtectionCopy.privacyLessonOneParagraphs
                       + ProtectionCopy.privacyLessonTwoParagraphs)

        // The bookless practice note ("getting around" points at it):
        // the Library's bookless filter — the Pool's phone home — gets a
        // tutorial object of its own to show. Tagged, so the restore's
        // cleanup finds it; in NO book, which is the whole point.
        let loose = try ops.createPost(title: looseNoteTitle, profile: .generic)
        try ops.applyTag(tagID, toPost: loose.id)
        _ = try ops.newBlock(
            in: loose.id,
            text: "A note in no book yet — the Library's bookless filter is "
            + "where drafts like me wait.",
            at: .end)

        return book.id
    }
}
