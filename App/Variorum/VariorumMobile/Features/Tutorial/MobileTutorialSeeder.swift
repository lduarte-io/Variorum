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
//  is NON-JOURNAL (`.generic`, no entry dates — R57: the Fragments
//  bridge sweeps journal days only, and no tutorial text may ever reach
//  it). Seeding runs through a QUIET Operations facade (undoStack: nil,
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
        ("takes", ["your first take", "swipe & choose", "the browser"]),
        ("structure", ["divide", "divide with takes", "merge"]),
        ("the library of things", ["comments & callouts", "the seal", "the voice switch"]),
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
            name: bookName, kind: .curated, profile: "collection")
        // The shelf's pin face, taught by wearing it (pinned books sit
        // first — the guide leads the shelf so it is findable on a fresh
        // dev store; "getting around" says so).
        try ops.setShelfPinned(book.id, pinned: true)

        // Chapters, in reading order.
        let welcome = try ops.createSection(in: book.id, name: "welcome")
        let writing = try ops.createSection(in: book.id, name: "writing")
        let takes = try ops.createSection(in: book.id, name: "takes")
        let structure = try ops.createSection(in: book.id, name: "structure")
        let library = try ops.createSection(in: book.id, name: "the library of things")

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
            "The SHELF is home: your books, with this one pinned to the top — "
            + "pinned books always sit first, and a long press on a book row "
            + "pins or unpins it. ✎ Today's Entry opens today's journal page, "
            + "making it if the day hasn't started. + new note starts a "
            + "bookless note and drops you straight into writing; + new book, "
            + "at the list's end, starts a fresh book — hand-picked, a dated "
            + "journal, or a smart book collecting by tags. A long press "
            + "also STARS a note or a book (up to five) — starred things "
            + "sit above everything at the shelf's very top, and the same "
            + "press takes the star back off.",

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
            + "diverging is how one book gets its own.",

            "The masthead's second line is the note's tags and its "
            + "sources: tap the tags to tag the note — type a tag and ⏎ "
            + "applies it, creating it if it's new (“/” nests: life/goals "
            + "makes the whole path), or tap a suggestion; ✕ takes one "
            + "off. Chips show a nested tag's last piece; the full path "
            + "lives in the sheet. more info, beside the tags, keeps "
            + "links and files with the note — tap a link to open it, or "
            + "add one; a file listed there stays on the device where it "
            + "was added, and only its name travels.",

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
            + "savepoints, a new block below, divide, merge, delete.",

            "Your writing is always autosaved; a SAVEPOINT is the "
            + "deliberate extra. Commit Take, in ⋯, keeps the exact text "
            + "of the take you're in, forever — and Take History… lists "
            + "every savepoint, newest first, with restore to bring one "
            + "back into the take. A savepoint from before a divide says "
            + "so, and asks first: restoring it brings back the whole "
            + "pre-split text.",

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
            + "Aa on the bottom bar opens the strip — two rows of it now — "
            + "and B or I wraps whatever you've selected. Press the same "
            + "button again and it takes the marks off; the act reads what "
            + "is already there rather than blindly adding.",

            "The first row's other three: S strikes a selection through, "
            + "⟨⟩ marks it as inline code, and the link glyph wraps it as "
            + "[text]() with the caret waiting between the parentheses for "
            + "the address. Same toggle rule, same plain characters.",

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

            "⇥ nudges a list line deeper; press and hold it to come back "
            + "out. And when you open this book through read, the markers "
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
            + "changes quietly keeps a savepoint first, so the guard "
            + "insures exactly what it protects.",

            "A LABEL is a short name on a take's card — \u{201C}bolder "
            + "opening\u{201D}, \u{201C}the calm one\u{201D} — set from the same ⋯. "
            + "It names the take wherever its card appears, archived "
            + "included, and is never printed in the prose.",
        ])
        try take(on: browser.blocks[2],
            "the spare take — archive me from my card's ⋯.")

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

            "The two halves are both blocks now, each free to grow its own "
            + "takes. Divide a sentence at its seam and merge it back, and "
            + "you get exactly the sentence you started with — merge is the "
            + "road back.",
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
            "Merge is divide's opposite: the block you're in joins the one "
            + "above it. The joined text gets a single space at the seam — "
            + "divide a sentence and merge it back, and you get exactly the "
            + "sentence you started with.",

            "These two short blocks are really one thought.",

            "They have been waiting for a merge since the day they were "
            + "seeded.",

            "Put the cursor in the second one and choose Merge with "
            + "Previous from ⋯. When either block holds other takes, the "
            + "phone steps back and says so: pairing takes into a merge is "
            + "the Mac's merge ceremony, and quietly dropping your options "
            + "is exactly what it refuses to do. The block below carries a "
            + "second take, so merging it upward shows you that answer.",

            "This block has a spare take, so a merge here steps back to "
            + "the ceremony.",
        ])
        try take(on: merging.blocks[4],
            "the spare take that makes the merge step back.")

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
            + "unlocks, one tap seals again. Sealing quietly keeps a "
            + "savepoint of any unsaved take first — the guard insures "
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
