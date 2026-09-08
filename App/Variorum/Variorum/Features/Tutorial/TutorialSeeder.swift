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
import VariorumCore

enum TutorialSeeder {
    // MARK: - Reserved identities (how Restore finds its own objects)

    nonisolated static let bookName = "the field guide"
    nonisolated static let tagName = "tutorial"
    nonisolated static let scrapPoolTitle = "tutorial scraps"

    /// What the confirm sheet says before a wholesale replace — plain
    /// words, exact scope (the spoken confirm, brief decision 6; the
    /// Stage 2 ladder's MINOR-D3/D4 accuracy pass: the copy discloses the
    /// EXACT tag and the PLURAL name-based scope, because cleanup deletes
    /// every same-named book and pool — a user's colliding names included,
    /// accept-and-document per the architect's recorded call).
    nonisolated static let replaceQuestion = "Restore the tutorial?"
    nonisolated static let replaceDetail =
        "This replaces the tutorial with a fresh copy: every note tagged exactly "
        + "\u{201C}\(tagName)\u{201D}, every pool named \u{201C}\(scrapPoolTitle)\u{201D}, and every book "
        + "named \u{201C}\(bookName)\u{201D} are deleted and re-seeded. Nothing else is touched."

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
        ("welcome", ["start here", "getting around", "the workspace"]),
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
        ("where things go",
         ["the five places", "saving a moment", "the two exits"]),
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
        ("ways of looking", ["read", "lenses", "compare & versions",
                             "blocks \u{B7} canvas"]),
        ("the library of things", ["comments & tags", "books & the shelf",
                                   "pool & scraps", "export — it's all yours",
                                   "the seal", "three ways of working"]),
    ]

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
        session: AppSession, confirmReplace: () -> Bool
    ) async throws -> String? {
        let existing = try await session.database.read { db in try discover(db) }
        if let bookID = existing.readingIDs.first { return bookID }
        if !existing.isEmpty, !confirmReplace() { return nil }
        return try await restore(session: session, existing: existing)
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
            name: bookName, kind: .curated, profile: "collection",
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
            "Welcome. This book is Variorum teaching itself with itself: you are "
            + "reading a note, inside a chapter, inside a book on your shelf — the "
            + "same objects everything you write will live in. Each lesson asks you "
            + "to actually do the thing it describes, right here in its own text.",

            "Everything in this book is safe to play with. Cut it up, rewrite it, "
            + "delete it — Help \u{25B8} Restore Tutorial\u{2026} replaces the whole book with a "
            + "pristine copy whenever you want one. Nothing you do here can touch "
            + "your own writing.",

            "Two companions to know from the start. When the app answers you — a "
            + "result, a refusal, an undo report — the answer appears briefly at the "
            + "bottom of the window. And \u{2318}/ opens the Shortcuts & Dictionary "
            + "helper: every key the app listens for, and every word it uses, in "
            + "plain language.",

            "The chapters of this book are listed to the left. Read in order, or "
            + "jump to what itches. When something in a lesson doesn't behave as "
            + "the words promise, that is a bug in the app, not in you.",
        ])

        _ = try lesson(welcome, "getting around", [
            "The sidebar has four places. SHELF is home: your books, and a dashed "
            + "box that reads \u{201C}new note — just start typing\u{201D} — type a first line "
            + "there and \u{23CE} mints a note and opens it. LIBRARY is everything, "
            + "searchable, with a List and a Timeline view. POOL holds notes that "
            + "belong to no book yet. SNIPPETS holds loose scraps — pieces of text "
            + "that aren't notes at all.",

            "\u{2318}K finds anything: notes, books, blocks, and commands — type a few "
            + "letters and \u{23CE} opens the hit. \u{2318}N makes a new note from anywhere. "
            + "\u{2318}J opens today's journal entry — the journal is its own daily "
            + "notebook on the shelf.",

            // 13b 4D (S4-20): the first-open default is WRITE now; the
            // per-post memory is worth teaching in the same breath.
            "A note opens into one of seven modes — the tabs read Write \u{B7} Takes \u{B7} "
            + "Read \u{B7} Lenses \u{B7} Compare \u{B7} Blocks \u{B7} Canvas, and "
            + "\u{2318}1 through \u{2318}7 "
            + "switch between them. A note opens in Write the first time — the "
            + "plain full page; after that it remembers the mode you left it in. "
            + "The rest of this book visits each mode where it earns its keep.",

            "Try it now: press \u{2318}K, type \u{201C}getting\u{201D}, and \u{23CE} back to this very "
            + "lesson. Then press \u{2318}2 for Takes and \u{2318}1 for Write, and watch the "
            + "same text wear both faces.",
        ])

        // 13g L1 (WT-1): the workspace lesson — everything Phase 13f built,
        // taught where a reader meets it. Every act named here is a shipped,
        // registry-declared door; the ⌘/ helper's "Windows & panes" group is
        // the same list in key form.
        _ = try lesson(welcome, "the workspace", [
            "One window can show TWO notes at once. Right-click any note row \u{25B8} "
            + "\u{201C}Open Beside\u{201D} and it opens in a second pane next to this one; "
            + "View \u{25B8} Open Beside does the same with the note you had open most "
            + "recently. Drag the seam between them to resize, and View \u{25B8} Close "
            + "Split folds back to one.",

            "Only ONE pane writes at a time. Click into a pane and it becomes the live "
            + "one \u{2014} its text is the text you type in; the other reads quietly "
            + "beside it. That is deliberate, and it is what keeps a note with ten "
            + "thousand words as quick as an empty one. A split never shows the same "
            + "note twice: to see ONE note two ways, that is what Lenses (\u{2318}4) and "
            + "Compare (\u{2318}5) are for.",

            "Whole WINDOWS too: File \u{25B8} New Window opens another full window, with "
            + "its own sidebar, its own Open list and its own trail. Right-click a note "
            + "row \u{25B8} \u{201C}Open in New Window\u{201D} opens just that note, sidebar-less, "
            + "for when one piece deserves its own screen.",

            "The sidebar keeps an OPEN list of the notes this window has open, in the "
            + "order you opened them \u{2014} \u{2318}\u{21E7}1 through \u{2318}\u{21E7}9 jump "
            + "straight to them, drag the rows to rearrange, and \u{2715} closes a ROW "
            + "and nothing else (the note is untouched). \u{2318}[ and \u{2318}] walk back "
            + "and forward through where this pane has been, like a browser.",

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
            "Above the page sits the CONTEXT BAR \u{2014} always the same three doors: "
            + "\u{2190} and \u{2192} walk back and forward through where this pane has "
            + "been (\u{2318}[ and \u{2318}] are the same doors), and the book glyph "
            + "opens the book this note lives in at this very note. One more thing "
            + "joins them only when there is something to say: a note that has deleted "
            + "blocks wears a quiet \u{232B} badge with the count, and it opens "
            + "that note's tray \u{2014} the deleting chapter has the whole story. "
            + "The note's TAGS live on the masthead's right edge, under the tray, "
            + "scraps and references icons: click the \u{FF03} beside the cards and a "
            + "tag field slides out with the cursor already in it \u{2014} type a "
            + "name, \u{23CE} applies it (a \u{201C}/\u{201D} nests, like life/goals), "
            + "\u{238B} puts the field away, and \u{2318}\u{21E7}I opens the same field "
            + "from anywhere in the note.",

            "Two more, for keeping and catching. Right-click any note or book \u{25B8} "
            + "\u{201C}\(StarCopy.verb)\u{201D} pins it to the sidebar's top \u{2014} up to five, "
            + "meant for what you are in right now rather than as a filing system. And "
            // 13g cold review R1-2: batch 7 (R6-4) moved the quick note's
            // landing — tagged, into the smart Quicknotes book — and this
            // sentence kept teaching the Pool. The WT-1 class, in the very
            // lesson WT-1 minted.
            + "\u{2318}\u{21E7}N pops the QUICK NOTE: a small floating pad that stays above "
            + "your writing, also reachable from the \u{270F}\u{FE0E} in the system menu bar "
            + "while you are in another app entirely. Return there makes a new line, not "
            + "a new note; close it (or \u{2318}\u{23CE}) and what you wrote is kept as a "
            + "note, tagged \u{201C}quicknote\u{201D} \u{2014} the smart Quicknotes book on "
            + "the shelf collects it, and taking the tag off sends it back to the Pool.",

            "\u{2318}/ opens the Shortcuts & Dictionary helper, and its \u{201C}Windows & "
            + "panes\u{201D} group is this whole lesson in key form \u{2014} including the "
            + "doors that have no key and live in a menu instead.",
        ])

        // ————————————————————————————— writing —————————————————————————————

        _ = try lesson(writing, "blocks & typing", [
            "Everything you write is made of BLOCKS — paragraph-sized pieces with "
            + "permanent identity. You never manage them while drafting: switch to "
            + "Write (\u{2318}1), click at the very end of this note, and type a few "
            + "paragraphs. Each paragraph quietly becomes its own block as you "
            + "type past it. No gesture, nothing to ask for.",

            // 13b 4D (N34 — S4-14): the opt-in one_block face gets a
            // sentence where crystallization is taught.
            "Return makes a block WHEREVER your cursor is: at the end of a "
            + "paragraph, a new empty block below it; in the middle of one, a "
            + "divide at the cursor. Shift-Return is the newline that stays "
            + "INSIDE a block — a blank line in the same paragraph — and a "
            + "block can hold several paragraphs that way, or by paste or "
            + "merge. Otherwise boundaries only ever change when you ask "
            + "(divide, merge, extract — the structure chapter). Prefer to "
            + "place every boundary yourself? The bottom bar's "
            + "\u{201C}newlines make blocks\u{201D} switch turns it off for one note "
            + "— then Return is just a newline again, typing and pasting stay "
            + "inside the block, and only Divide or New Block Below make new "
            + "ones.",

            "Boundaries are invisible at rest, on purpose: a note reads as calm, "
            + "seamless prose. When you want to see the seams, press \u{2318}\u{21E7}B — "
            + "dotted lines appear between blocks, everywhere, until you press it "
            + "again.",

            "The bottom bar keeps quiet count for you: which block your cursor is "
            + "in, and the word counts — the take you're in, and the whole note.",
        ])

        let shaping = try lesson(writing, "shaping blocks", [
            "Blocks mostly shape themselves as you type. This lesson is the "
            + "hand tools, and its blocks are staged for each one.",

            "The first tool needs a middle sentence. This lesson was written as "
            + "calm filler around exactly one restless line. This middle sentence "
            + "wants to be a block of its own. Select that whole sentence, press "
            + "\u{2318}\u{21E7}K (Make Block from Selection), and watch it become its own "
            + "block — from Takes, the app carries you to Write and does it there.",

            // 13b 4D (N28/S4-13): the insert-below door joins the direct asks.
            // 13g L1: the KEY was stale — 13d batch 4 (A14) superseded ⌥⌘N
            // with ⌘⇧⏎ and this lesson kept teaching the old chord. Same
            // finding class as WT-1 (a discoverability surface that drifted
            // out of the registry); the helper had already been corrected.
            "New blocks can also be asked for directly: \u{2318}\u{21E7}\u{23CE} (New Block "
            + "Below) mints an empty block right under the one you're in and "
            + "puts your cursor in it — Write and Takes alike; the block \u{25BE} "
            + "menu in the bottom bar also has \u{FF0B} New block at the end of the "
            + "note. Either way, just keep typing.",

            "A block can carry a NAME — a handle for finding it, never printed in "
            + "the prose. This block wears one: open the Blocks tab (\u{2318}6) and "
            + "you'll see \u{201C}the named block\u{201D} where every other row shows its first "
            + "sentence. Name\u{2026} on any row sets or clears one.",

            "This block is a CALLOUT — a colored frame that says \u{201C}this one is "
            + "different\u{201D}: an aside, a goal, a warning. In Write, put the cursor "
            + "here and use Block \u{25B8} Callout to change its color, set a leading "
            + "emoji, or remove the frame. Presentation only — the text itself is "
            + "untouched, and exports render it as a quote.",
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
            "Formatting in Variorum is **markdown**, and that is not a detail of "
            + "the implementation \u{2014} it is the whole design. What you see is "
            + "exactly what is saved: two stars around a word ARE the bold. The "
            + "editor styles the word and dims the stars, so the page reads "
            + "cleanly while the text stays plain characters you could open in any "
            + "editor on earth. Nothing about a formatted note is locked in, and an "
            + "export is already markdown because it was never anything else.",

            "The vocabulary is small on purpose: **bold** (\u{2318}B), *italic* "
            + "(\u{2318}I), ~~struck out~~, and `inline code`. The last two live in "
            + "the FORMAT menu, which also carries every act below \u{2014} and "
            + "right-clicking in any writing surface offers the same rows under "
            + "\u{201C}Format\u{201D}. Try it: select these three words and press "
            + "\u{2318}B. Press it again to take the bold off; the act reads what is "
            + "already there rather than blindly adding.",

            "## Headings are sizes",

            "A line that starts with #, ## or ### is a heading \u{2014} those three, "
            + "and nothing else. Put your cursor on this line and use Format "
            + "\u{25B8} Heading \u{25B8} 2 to see it happen; the line above is "
            + "already one. Setting a lead REPLACES whatever lead the line had, so "
            + "a heading becomes a bullet in one press rather than becoming a "
            + "bullet with a stray # in it.",

            "- Lists are lines that start with \"- \"",
            "- Format \u{25B8} Bullet List makes one from the line you're on",
            "- Select several lines and it makes them all into a list",

            "- [ ] And a checkbox is a list item with a box: \"- [ ] \"",
            "- [x] CLICK the box to tick it \u{2014} that is an ordinary edit, so "
            + "\u{2318}Z takes it back and a sealed note refuses it",

            "Links are written [like this](https://apple.com). Format \u{25B8} Add "
            + "Link wraps your selection in the brackets and leaves the cursor "
            + "inside the parentheses, ready for the address. In a writing surface "
            + "a plain click has to place your cursor, so \u{2318}-CLICK follows a "
            + "link instead.",

            "Now the one place the app shows you something other than what is "
            + "stored. Open this book in READ mode (the Outline \u{B7} Index "
            + "\u{B7} Book \u{B7} Read row above) and look at this lesson again: "
            + "the markers are gone, "
            + "the headings are sizes, the list has bullets, the boxes are boxes, "
            + "and a link is just the words \u{2014} a plain click opens it, because "
            + "Read has no cursor to place. Read is for reading; everywhere you can "
            + "write, you see the text exactly as it is saved.",
        ])

        // ————————————————————————————— takes ———————————————————————————————

        let firstTake = try lesson(takes, "your first take", [
            "The fan is the reason this app exists: a block can hold several "
            + "parallel TAKES — whole alternative texts — side by side, none of "
            + "them lost, as long as you like. Most blocks live with one take; "
            + "the ones you're unsure about can hold ten.",

            "The next paragraph can't decide what it wants to be. It's yours to "
            + "fan out.",

            "The lighthouse keeper counted the ships going out, and never once "
            + "the ships coming home.",

            "Click into that paragraph and press \u{2318}T (or \u{FF0B} take in the bottom "
            + "bar): a second take appears beside it, born as a copy of what you "
            + "were reading. Rewrite it freely — bolder, quieter, backwards. The "
            + "first take is untouched. \u{2325}\u{2318}T makes a BLANK take instead, for a "
            + "genuinely different attempt.",

            "Notice: exactly one pane is ever live for typing — the one with the "
            + "ring. Click any take to make it the live one. Your keystrokes only "
            + "ever land in the ring.",
        ])
        _ = firstTake

        let choosing = try lesson(takes, "choosing & the board", [
            "Takes are for trying; CHOOSING is deciding. The take with the "
            + "\u{2713} is what the note actually says — \u{201C}visible is what you're "
            + "looking at; chosen is what the note is.\u{201D} \u{2318}\u{23CE} chooses the take "
            + "you're in; nothing else changes the note.",

            "The block below carries four takes of one sentence, ready for "
            + "practice. Open its fan (\u{2318}\u{21E7}T), step through them with \u{2303}\u{2318}\u{2190} "
            + "and \u{2303}\u{2318}\u{2192}, and choose your favorite.",

            "The rain came in from the sea without an opinion about any of us.",

            // 13b 4D (S4-24(1)/N40): the scroll+pager hybrid + the fixed
            // strip — the prose keeps pace with the ruled behavior.
            "When a fan holds more takes than fit, the strip scrolls freely "
            + "sideways AND pages: \u{25C0} 1\u{2013}2 of 4 \u{25B6} — \u{2325}\u{2318}\u{2190} and \u{2325}\u{2318}\u{2192} turn "
            + "the pages from the keyboard, and the counter always agrees with "
            + "what you scrolled to. Take cards keep one steady height; a long "
            + "take scrolls inside its card. The style: menu in the board's top "
            + "line picks how fans open — stack, carousel, margin grid, or slot "
            + "split — and \u{238B} closes every fan at once.",
        ])
        let fanned = choosing.blocks[2]
        try take(on: fanned, "The rain arrived off the sea like a verdict none of us had appealed.")
        try take(on: fanned, "Sea rain, indifferent rain — it fell on the just and the unjust and the ferry schedule alike.")
        try take(on: fanned, "The rain came in from the sea, and the sea did not explain itself.")

        let keeping = try lesson(takes, "keeping takes safe", [
            "Everything autosaves, always. A COMMIT is more deliberate: \u{2318}S "
            + "keeps an immutable savepoint of the take you're in — a version you "
            + "can always come back to, no matter what you type over it. Commits "
            + "append; nothing ever overwrites one.",

            "Try it here: click into this paragraph, change a few words, press "
            + "\u{2318}S, then press history in the bottom bar, right beside "
            + "commit. Your savepoint is listed under this take; Restore loads "
            + "any savepoint back into the take — and committing again just "
            + "adds another.",

            "The block below has a spare take to practice ARCHIVING on. Click "
            + "into the second take and press \u{2318}\u{21E7}A — it leaves the board, out "
            + "of the fan but never gone.",

            "Never gone means never gone: an \u{201C}archived \u{B7} 1\u{201D} door appears "
            + "right under that block's takes. Open it and Unarchive puts the "
            + "take straight back in the fan — no leaving the board. (Write's "
            + "takes panel keeps the same archived list, if you're over there.)",

            // 13j batch 7 (the J10 content-refresh sweep): J11 gave the app
            // its own savepoint cadence and this lesson still described a
            // history with nothing in it but ⌘S. The words follow
            // `SavepointCadenceCopy` / `SavepointRuns` — the setting's own
            // home — so the lesson and the switch cannot drift apart.
            "You are not the only one keeping savepoints. LEAVING a note — "
            + "closing it, switching away, quitting — quietly saves one "
            + "savepoint for each take you changed while you were in it, and a "
            + "note you leave open gets one after about two hours. A take you "
            + "haven't changed is never saved twice. Those quiet ones are muted "
            + "and fold into a single \u{201C}N quiet savepoints \u{B7} show\u{201D} "
            + "line, so the ones you took yourself stay the ones you see. "
            + "Settings (\u{2318},) \u{25B8} Writing has the one switch — every "
            + "time you leave, only after a note sits untouched, or only when "
            + "you press \u{2318}S — and whichever you pick, the app still saves "
            + "a take right before anything could put your words out of reach.",
        ])
        try take(on: keeping.blocks[2],
            "This is the spare take — archive me: click into me, then \u{2318}\u{21E7}A.")

        // ———————————————————————————— structure ————————————————————————————

        _ = try lesson(structure, "divide", [
            // 13b 4A: the ruled cut redesign (S4-22) — cuts land between
            // any two words; sentence ends and line breaks pull gently.
            "Divide cuts a block in two at your cursor — the everyday gesture "
            + "for \u{201C}this part should stand on its own so I can work on it "
            + "separately.\u{201D} The cut can land between any two words — it snaps "
            + "to the nearest word edge, settles a little more readily onto "
            + "sentence ends and line breaks, and the app shows you where it "
            + "landed. Only a single word has nothing to divide.",

            "This block holds two thoughts and they deserve two blocks. Put your "
            + "cursor right before this second sentence and press \u{2318}\u{21E7}D.",

            // 13j J4 (her 2026-08-03 ruling): the fanned default. Stated here
            // because THIS is the lesson someone reads before their first
            // divide on a block that already has takes.
            "If the block has SEVERAL takes, \u{2318}\u{21E7}D still just cuts: the take "
            + "you're LOOKING at splits across the two new blocks, and every other "
            + "take stays WHOLE on the first block — the one you divided. Nothing "
            + "goes missing and there's nothing to hunt for. When you'd rather send "
            + "them somewhere else, or place a cut in each take by hand, that's "
            + "Divide choosing takes, \u{2325}\u{2318}\u{21E7}D, and it has the next lesson "
            + "to itself.",

            "From Takes, divide acts RIGHT THERE — press \u{2318}\u{21E7}D, or Divide "
            + "in the bottom bar's block \u{25BE} group, and the block you're in is "
            + "cut without leaving the board. (Extract, Make Block and Merge "
            + "still travel to Write and act there, visibly — that carry is a "
            + "feature, not a trick.)",

            "One \u{2325}\u{2318}Z (structural undo) puts a divided block back together. "
            + "The undo chapter has the whole story.",
        ])

        let ceremony = try lesson(structure, "divide choosing takes", [
            // 13j J4: the ceremony is SUMMONED now, not the default. Her
            // ruling flipped ⌘⇧D on a fanned block to the duplicating shape;
            // this lesson teaches the door that still asks take by take.
            "Dividing a fanned block raises a real question: each take is a "
            + "different text, so where does each one go? \u{2318}\u{21E7}D answers it the "
            + "quick way — cut the take you're looking at, leave the rest whole on "
            + "the first block. When the answer matters, ask for the choice "
            + "instead: \u{2325}\u{2318}\u{21E7}D lays every take out in one sheet and asks "
            + "where they should go.",

            // 13b 4A: the sheet shows every checked take at once, the ✂
            // drags between word edges, keyboard placement, and PARKING.
            "The block below carries three takes, staged for it. Put your cursor "
            + "mid-block and press \u{2325}\u{2318}\u{21E7}D. The sheet titled \u{201C}Divide choosing "
            + "takes\u{201D} opens on a row of four: keep the takes on the top block "
            + "(the everyday answer, already chosen), keep them on the bottom, copy "
            + "them to both — or \u{201C}Choose per take\u{2026}\u{201D}, which is the one you "
            + "really have to ask for. Pick that fourth one: every take gets a "
            + "checkbox and its text laid out with a ✂ you can place anywhere "
            + "between words — drag it, click a spot, or use \u{2190}/\u{2192} (\u{2325} jumps "
            + "by sentence, \u{21E5} moves between takes). Leave the third take "
            + "UNCHECKED before you confirm.",

            "The ferry crossed at dawn. Nobody on board spoke about the storm.",

            "Confirm makes two blocks: the first holds every checked take's "
            + "first half, the second the endings — your openings and endings "
            + "stay mix-and-matchable. A take doesn't have to split at all: "
            + "park its \u{2702} at the very end and the whole take rides into the "
            + "first block (at the very start, the second). The unchecked take "
            + "didn't vanish: it stays with the original block, preserved whole "
            + "off-stage, and \u{2325}\u{2318}Z puts the whole thing back as it was.",
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
            "Extract pulls a span at a block's EDGE out into its own block — "
            + "no fuss at all: the source block keeps its identity and all its "
            + "takes. Select from anywhere in this paragraph to its end and "
            + "press \u{2318}\u{21E7}E (the selection's edges snap to the nearest word "
            + "edge, settling gently onto sentence ends) — and this closing "
            + "line is begging to stand alone.",

            "A MIDDLE span can't extract (the two ends would be left holding "
            + "hands), so Make Block (\u{2318}\u{21E7}K) is the tool there: it runs two "
            + "divides as one undoable act. The lonely sentence in the shaping "
            + "blocks lesson was exactly this gesture.",

            "Both work from Takes: make your selection in the take you're "
            + "reading, press the key, and the app carries the selection to "
            + "Write and acts. If the block is fanned, the selection carries "
            + "approximately — the app snaps to boundaries and never cuts "
            + "silently where it isn't sure.",
        ])

        let merging = try lesson(structure, "merge", [
            "Merge is divide's opposite: neighboring blocks become one. The "
            + "joined text gets a single space at the seam — divide a sentence "
            + "and merge it back, and you get exactly the sentence you started "
            + "with.",

            "These two short blocks are really one thought.",

            "They have been waiting for your \u{2318}\u{21E7}M since the day they were "
            + "seeded.",

            "In Write, put the cursor at the boundary between them (\u{2318}\u{21E7}B shows "
            + "seams) and press \u{2318}\u{21E7}M — or select across both and merge the "
            + "whole run as one undoable act. From Takes, Merge joins the block "
            + "you're in UPWARD, into the one above.",

            // 13b 4B (S4-23) gave merge its ceremony; 13j J4b (her
            // 2026-08-09 ruling) made CARRY-ALL the default and left the
            // ceremony as the summoned door — divide's story, one gesture
            // over.
            "When either block has other takes, Merge brings them ALL along: "
            + "the two takes you were looking at join, and every other take "
            + "rides onto the merged block whole. Nothing is left behind to "
            + "hunt for, and the extra copies are quick to delete. To choose "
            + "instead, use Merge choosing takes (\u{2325}\u{2318}\u{21E7}M): it asks first — "
            + "bring every take (the everyday answer, already chosen), only the two "
            + "you were looking at, or pair by hand — which opens pre-paired with "
            + "the two takes you were looking at, so \u{23CE} still gives you "
            + "exactly the everyday join. "
            + "Pair takes with \u{FF0B} and the merged block gets one joined take "
            + "per pairing (divide a two-take block, pair 1+1 and 2+2, and it "
            + "comes back whole); check \u{201C}carry\u{201D} to ride a take over "
            + "unjoined; each pairing previews its join — space, new line, or "
            + "nothing. Takes are never multiplied combinatorially: pairing is "
            + "choosing by hand.",

            "When you pair by hand, whatever you leave unpaired stays with the "
            + "released blocks in lineage — the app names the road, and "
            + "\u{2325}\u{2318}Z brings the sources back, takes and all, from either "
            + "road. Merging THREE or more blocks at once asks the same question "
            + "with two answers only — every take, or only the shown ones — and "
            + "never opens the pairing surface. The block below carries a spare "
            + "take so you can watch both: \u{2318}\u{21E7}M brings the spare along, "
            + "\u{2325}\u{2318}\u{21E7}M asks where the takes should go.",

            "This block has a second take — merge me upward and my spare comes "
            + "along whole; with \u{2325}\u{2318}\u{21E7}M you are asked first, my takes "
            + "laid out for pairing if you want them.",
        ])
        try take(on: merging.blocks[6],
            "The spare take: I come along whole on an ordinary merge — or pair me, carry me, or leave me in lineage when you choose by hand. Undo brings me home either way.")

        _ = try lesson(structure, "the two undos", [
            "Variorum keeps two undo stacks, deliberately separate. \u{2318}Z is TEXT "
            + "undo — your typing, inside the take you're editing, as in any "
            + "editor.",

            // 13j batch 7 (the J10 content-refresh sweep): structural REDO
            // shipped at 13c (A10 — her *"i desperately need a 'redo'
            // command"*) and this lesson never learned the chord; the J7 sign
            // at the junction is 13j's, and this is where the two stacks are
            // introduced, so both belong here.
            "\u{2325}\u{2318}Z is STRUCTURAL undo — divides, merges, extracts, moves, "
            + "deletions of blocks and takes. It never touches your typing; it "
            + "restores the shape. Every structural act in this book is one "
            + "\u{2325}\u{2318}Z away from undone, and the report of what was undone lands "
            + "at the bottom of the window. \u{21E7}\u{2325}\u{2318}Z is its redo: "
            + "undo an undo, as many times as you like.",

            "The two stacks never mix, and the app helps you at the junction: "
            + "press \u{2318}Z when there is nothing left to undo in the text "
            + "and a structural change is what you actually did last, and the "
            + "status line says so and names \u{2325}\u{2318}Z. The key still does "
            + "what \u{2318}Z always does — the app only puts up a sign.",

            "If a structural undo would overwrite words you typed AFTER the "
            + "act, the app ASKS FIRST — that is the one undo that sets "
            + "writing aside, so it is the one that stops to check. Say yes "
            + "and a savepoint of your newer text is kept anyway: insurance, "
            + "so nothing typed is ever more than one restore away. Every "
            + "other structural undo stays silent. Try it: divide the block "
            + "above, type a few words into the FIRST half, press "
            + "\u{2325}\u{2318}Z, answer the question, then look in history.",
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
            + "keeping its takes and its savepoints, and it waits — first on "
            + "\u{2325}\u{2318}Z, then in this note's tray, then in the Trash for "
            + "30 days. This chapter has you delete things on purpose, so you "
            + "know exactly where each one landed.",

            "The everyday way is the way you already know: select a whole "
            + "paragraph and press \u{232B}. Triple-click the next paragraph — "
            + "or drag across it and a little past its end — then delete: the "
            + "block goes, and the note closes over it. (Select only the words "
            + "INSIDE a paragraph and delete, and you get exactly what you "
            + "asked for instead: an empty block, still there, ready to type "
            + "in.)",

            "SCRATCH ONE: this paragraph exists to be deleted. Triple-click me "
            + "and press \u{232B}.",

            "Several at once: hold \u{2318} and click each block you want "
            + "(\u{2318}\u{21E7}-click picks a whole run). A banner appears above "
            + "the page counting what you picked, with Delete N Blocks on it; "
            + "the right-click menu carries the same row. They all go under "
            + "ONE undo — a multi-delete is one mistake to reverse, not five.",

            "SCRATCH TWO: \u{2318}-click me and the paragraph below, then press "
            + "Delete 2 Blocks.",

            "SCRATCH THREE: I'm the other half of that pair.",

            "\u{2325}\u{2318}Z is the undo for all of it — one press brings back "
            + "one delete however many blocks it took, and \u{21E7}\u{2325}\u{2318}Z "
            + "deletes them again. If you reach for \u{2318}Z out of habit and "
            + "there is nothing left to undo in the text, the app says so at "
            + "the bottom of the window and names \u{2325}\u{2318}Z for you: two "
            + "undo stacks, kept separate on purpose, and a sign at the "
            + "junction.",

            "Everything you just deleted is in This Note's Tray. Open it with "
            + "the tray icon at the top of the note, beside Scraps and "
            + "References — it opens in the panel on the right, and it is "
            + "always there. A note that has deleted blocks also wears a quiet "
            + "\u{232B} badge with the count in the context bar above the page; "
            + "clicking it opens the same panel. The next two lessons live "
            + "there.",
        ])
        _ = deletingBlocks

        let trio = try lesson(deleting, "archive \u{B7} delete \u{B7} scraps", [
            "A block you don't want here has three different fates, and the "
            + "difference between them is the thing to learn once. ARCHIVE "
            + "keeps it forever — out of the note, in this note's tray, with "
            + "no countdown. DELETE starts the 30-day clock: it waits in the "
            + "Trash, and then it really is gone. MOVE OUT TO A POOL cuts the "
            + "tie to this note altogether and leaves the block as a scrap you "
            + "can drag into anything.",

            "ARCHIVE ME: I'm worth keeping and I don't belong in this note "
            + "today. Put your cursor in me and use Block \u{25B8} Archive "
            + "Block — the right-click menu has the same row. I leave the page "
            + "and wait in the tray's Archived section wearing "
            + "\u{201C}kept — no clock\u{201D}, and Put back returns me to this "
            + "exact spot.",

            "DELETE ME: I've had my day. Block \u{25B8} Delete Block, or "
            + "triple-click me and press \u{232B}. I go to the same tray's "
            + "Leaving section with a countdown on me, and to the Trash in the "
            + "Library, and in 30 days I'm gone for real.",

            "MOVE ME OUT: I'm a decent line in the wrong note. Open Blocks "
            + "(\u{2318}6), find my row, and use its \u{22EF} menu \u{25B8} Move "
            + "out to a pool (leaves this note). I become a scrap in that pool "
            + "— material for anywhere — and \u{2325}\u{2318}Z brings me back if "
            + "that wasn't what you meant.",

            "Which one? Archive when you want it kept and out of the way; "
            + "delete when you mean it; move it out when the words are fine and "
            + "the home is wrong. All three are one \u{2325}\u{2318}Z away for as "
            + "long as this session is open — and the two that leave something "
            + "behind put it somewhere you can find it.",
        ])
        _ = trio

        _ = try lesson(deleting, "the tray & the Trash", [
            "Every note keeps its own tray of what it set aside. Open it with "
            + "the tray icon at the top of the note — This Note's Tray, in the "
            + "panel on the right — or from the quiet \u{232B} badge in the "
            + "context bar above the page, which opens the same panel. The badge "
            + "counts DELETED blocks only and hides when there are none, which "
            + "is exactly why the icon is always there.",

            "The tray has two sections. Archived holds what you set aside on "
            + "purpose: kept, with no clock, forever. Leaving holds everything "
            + "of this note's that is counting down — the blocks it deleted, "
            + "the takes deleted on their own (folded away until you open "
            + "them), and any original riding a family's countdown. One verb "
            + "serves every row: Put back, and a block returns to the place it "
            + "stood in. (A block kept whole by a divide or a merge is not "
            + "leaving anything, so it is not here: it waits in the block it "
            + "became, under \(BlockHistoryPath.cameFromSection) — the next "
            + "lesson.)",

            "The Library holds the other half, in two rooms. Archived is its "
            + "own item in the sidebar: calm and clockless, whole notes you "
            + "set aside, each with Unarchive. The Trash is behind the trash "
            + "icon at the top of the Library, and it holds what is LEAVING — "
            + "notes, books and blocks, each row saying how many days it has "
            + "left and which note it came from. Filter it by kind, sort "
            + "oldest first, and Put back works on any row. (A deleted TAKE "
            + "never rows here: it waits in its own block\u{2019}s History, "
            + "where its block and its fan are there to make sense of it.)",

            // The post-13l polish round, ledger row 12 (D2): this paragraph
            // taught "no door inside a note ever deletes something for good",
            // which her G5 ruling superseded IN PART — the note's own Leaving
            // section carries Delete Now on its take rows, *"to keep the
            // capability"* after takes left the global Trash. The rule that
            // replaced it is the one the lesson teaches now: purge doors live
            // in TRASH SURFACES — the Library's Trash and this note's own
            // trash section — and never in the writing flow.
            "Ending something early is deliberate, and it lives in exactly two "
            + "kinds of place: the Trash, and the Leaving section of a note's "
            + "own tray. Delete Now ends one row's remaining days; Empty Trash "
            + "takes everything the Trash lists at once. Both ask first — "
            + "Delete Now asks every single time, there is no don't-ask to "
            + "set — and Empty Trash's question names the full count by kind "
            + "before it takes anything, and says what it leaves alone. "
            + "Nowhere you WRITE has such a door: not the page, not the block "
            + "menu, not a block's history. You have to go to where things are "
            + "leaving to end anything for good, which is why the Trash is "
            + "worth visiting once before you need it.",

            "Practice, and it is safe: go to the Library, right-click this "
            + "very lesson \u{25B8} Delete, then open the Trash and "
            + "Put back the row you find there. The lesson comes back "
            + "into this book, in this chapter, in its place. (And if you ever "
            + "lose your nerve, Help \u{25B8} Restore Tutorial\u{2026} rebuilds "
            + "the whole book.)",
        ])

        let past = try lesson(deleting, "what a block leaves behind", [
            "A block remembers more than its text. Put your cursor in one and "
            + "press history in the bottom bar — the pair to commit, and the "
            + "same door on both bars. Everything this block has been opens in "
            + "the panel on the right: every take's saved moments, the takes it "
            + "archived, the takes it deleted, and where it came from.",

            // U-2 (18c batch 1): \u{2318}\u{21E7}D keeps the other takes whole on
            // the TOP block. This lesson and its staged take taught 13j's
            // duplicate default until the 18f ladder's R3-2 (ledger row 44) —
            // the U-2 sweep reached the structure chapter's ceremony lesson
            // only, because neither text carries the word "ceremony".
            "This block has two takes. Put your cursor in the middle of it and "
            + "press \u{2318}\u{21E7}D: the take you are looking at splits across "
            + "two new blocks, and the other take stays whole on the first block. "
            + "What became of the block you cut? It was kept — whole, off to "
            + "one side, not deleted.",

            "Open history on either new block and its "
            + "\(BlockHistoryPath.cameFromSection) region shows the original "
            + "itself — \u{201C}From a divide on \u{2039}date\u{203A} — the "
            + "original is preserved\u{201D} — with Bring back beside it. "
            + "Right-clicking the block \u{25B8} See original from "
            + "divide\u{2026} and \u{2318}K land in the same place. They wait "
            + "there, with no clock, for as long as anything descended from "
            + "them is alive.",

            // The post-13l polish round, her A7 ruling: the per-merge message
            // is DECLINED (*"it's annoying to see that message every time"*)
            // and the teaching lands here instead — one sentence, in the
            // chapter about where things go when they leave a page.
            "MERGING keeps its blocks the same way, and says nothing at the "
            + "time — deliberately, because a message on every join would be "
            + "noise. Merge two blocks (or select across them and delete the "
            + "seam) and the block you get lists BOTH of the blocks it joined "
            + "in \(BlockHistoryPath.cameFromSection), each with its own "
            + "Bring back — three of them if you merged three. Nothing was "
            + "deleted, so nothing is counting down; the next chapter has you "
            + "do it and find them.",

            "Deleted TAKES wait in the same panel, under "
            + "\(BlockPastCopy.deletedTakesHeader), each with the days it has "
            + "left. This paragraph carries a spare take for the experiment: "
            + "open its takes (\u{2318}\u{21E7}T in Write), use the spare card's "
            + "\u{22EF} menu \u{25B8} Delete, then press history — the take is "
            + "listed with Put back, and it comes back with its label, its "
            + "place in the fan and its savepoints intact. (A saved lens "
            + "pointing at a take you archived or deleted says so right in its "
            + "column, with a Restore button there.)",

            "One honest thing about preserved originals, because it is the kind "
            + "of promise that should never surprise you: an original stays "
            + "permanent only while something descended from it is still alive. "
            + "Delete the last of its descendants and the original MOVES — "
            + "visibly, into the note's tray — out of lineage and onto "
            + "the family's 30-day clock, labelled \u{201C}set aside by a divide "
            + "or merge \u{2014} kept until its family goes\u{201D}. The delete "
            + "that does it "
            + "says so in its own receipt, while you are standing there.",
        ])
        try take(on: past.blocks[1],
            "The other take of the dividing block: I stay whole on the first block when you press \u{2318}\u{21E7}D, and the block we came from is kept preserved.")
        // Index 4, not 3: A7's merge sentence joined this lesson at the
        // post-13l polish round and sits between the lineage paragraph and
        // this one. (The walk's `theChapterIsStagedForItsActs` holds the
        // count of fanned blocks, and `theDeletedSpareTakeWaitsInTheBlocksPast`
        // finds this one by its prose — both caught the shift.)
        try take(on: past.blocks[4],
            "the spare take — delete me from the \u{22EF} menu, then put me back from the block's history panel.")

        // ————————————————————————— where things go ——————————————————————————
        //
        // The post-13l polish round, ledger rows 19 (G4), 26 and 27. THE MAP,
        // and the two lessons that make it usable: the pair of keys that save
        // the two sizes of moment, and the two exits a paragraph can take.
        // Every place named below is a surface this round built or verified,
        // and `TutorialWherePlacesActsTests` visits each one.

        _ = try lesson(places, "the five places", [
            "Nothing here goes anywhere you can't find. At any moment, "
            + "everything you have ever written is in exactly ONE of five "
            + "places: where you left it \u{B7} in Archive \u{B7} in the Trash "
            + "\u{B7} in this note's Versions \u{B7} in this block's History. "
            + "This lesson visits all five, and the two after it teach the "
            + "ones that are new.",

            "ONE \u{2014} WHERE YOU LEFT IT. The ordinary case, said out loud "
            + "because it is the one nobody thinks to say: a note you wrote "
            + "and did nothing else to sits in your Library exactly as you "
            + "left it, for as long as you keep it. The other four places "
            + "exist only for things you deliberately set aside, deliberately "
            + "changed, or deliberately saved.",

            "TWO \u{2014} ARCHIVE: notes, forever, no clock. Right-click any "
            + "note \u{25B8} Archive and it leaves the Library for ARCHIVED, "
            + "its own item in the sidebar, with its own search. Nothing is "
            + "counting down and nothing needs remembering \u{2014} it is "
            + "still yours, still editable, still exportable; archiving is "
            + "about your Library's attention, not about the note. Unarchive "
            + "puts it back. (Blocks and takes archive too, and each waits "
            + "where its context is: an archived block in its note's tray, an "
            + "archived take in its block's History. A thing set aside stays "
            + "next to what makes sense of it.)",

            "THREE \u{2014} THE TRASH: what is leaving, for "
            + "\(TrashWindow.days) days. Deleting a note, a book or a block "
            + "starts the clock, and all three wait it out behind the trash "
            + "icon at the top of the Library \u{2014} every row saying how "
            + "many days are left and which note it came from, and Put back "
            + "on any of them. A deleted TAKE is the one thing that never "
            + "rows there: alone, out of its block, a take is too small to "
            + "make sense of, so it waits in that block's History instead.",

            "FOUR \u{2014} THIS NOTE'S VERSIONS: moments of the WHOLE note, "
            + "saved by hand. \u{2318}\u{21E7}S saves one; note \u{25BE} "
            + "\u{25B8} \(VersionsPath.menuLabel) lists them, newest first, "
            + "each with Read, Restore and Promote. A saved version is frozen "
            + "at birth and stays out of your way \u{2014} never in the "
            + "Library, never in Archived \u{2014} because it is not another "
            + "note, it is this note's past. The next lesson is about the key.",

            "FIVE \u{2014} THIS BLOCK'S HISTORY: everything ONE block has "
            + "been. The history door sits in the bottom bar right beside "
            + "commit, and it opens the Block History panel: each live take's "
            + "saved moments, the takes this block archived, the takes it "
            + "deleted (with their clocks), and \(BlockHistoryPath.cameFromSection) "
            + "\u{2014} the blocks it came out of. Two lessons live in there, "
            + "and they are the two that follow.",

            "PRACTICE ME: I'm here to be visited. Put your cursor in me and "
            + "press history in the bottom bar to read my (empty) past \u{2014} "
            + "then come back after the next lesson and look again.",

            "A last honest word about the map: it is a map of PLACES, not of "
            + "promises about time. Archive keeps forever; the Trash keeps for "
            + "\(TrashWindow.days) days and then really does delete; a note's "
            + "Versions and a block's History keep for as long as the note or "
            + "the block does. Wherever something is, the surface it is on "
            + "tells you which of those it is \u{2014} that is the whole "
            + "design, and the reason there are five places instead of one.",
        ])

        // Row 26 + row 19's savepoint half: the grain pairing IS the lesson,
        // and the commit↔history pairing in the bottom chrome is where it is
        // taught (her: *"making it clear where commit / that particular
        // history by the take is, is also important"*).
        let saving = try lesson(places, "saving a moment", [
            "Two keys save two different SIZES of the same idea, and the pair "
            + "is worth learning together. \u{2318}S saves a moment of THIS "
            + "TAKE \u{2014} the block you're in, the take you're looking at. "
            + "\u{2318}\u{21E7}S saves a moment of THIS NOTE \u{2014} all of "
            + "it, as it stands. One grain apart, one shift key apart.",

            "\u{2318}S's moments live exactly where you'd look for them: press "
            + "history in the bottom bar, immediately beside commit. That "
            + "pairing is deliberate \u{2014} commit WRITES a moment, history "
            + "SHOWS the moments, and the two sit together so the bar reads as "
            + "the block's own time controls. Every live take of the block has "
            + "its own run in there, with the take you're in already open.",

            "PRACTICE TAKE: change a few words in me, press \u{2318}S, then "
            + "press history. I'm where your moment will be listed.",

            "Restore beside a moment loads it back into the take. It does not "
            + "overwrite anything: moments only ever append, so restoring an "
            + "old one and pressing \u{2318}S again just adds another. That is "
            + "the whole promise of a savepoint here \u{2014} you can always "
            + "come back, including from the coming back.",

            "\u{2318}\u{21E7}S is the same idea one size up. It copies the "
            + "whole note as it stands \u{2014} every block, every take "
            + "\u{2014} and keeps it under \(VersionsPath.menuLabel) in the "
            + "note \u{25BE} menu. Restore makes the note say that again, and "
            + "it saves where the note is NOW first, so it is never a one-way "
            + "door. Promote turns a moment into a note of its own, if you'd "
            + "rather work with it than go back to it.",

            "Which one to reach for? \u{2318}S when one paragraph is about to "
            + "change and you might want this wording back. \u{2318}\u{21E7}S "
            + "before a rewrite \u{2014} anything that will touch several "
            + "blocks at once. And you are not the only one saving: leaving a "
            + "note quietly saves a moment for each take you changed while you "
            + "were in it, so the \u{2318}S you forget is mostly already taken "
            + "for you.",
        ])
        _ = saving

        // Row 27, her eleventh-sitting mandate — TAUGHT BY DOING (her idea):
        // the reader deletes a whole block and finds it, then makes an edit
        // that merges two and finds the originals. Both staged blocks below
        // are single-take deliberately: a cross-block edit joins the halves
        // only where no fan hangs on the seam (the #11a ruling).
        let exits = try lesson(places, "the two exits", [
            "A paragraph can leave a page two different ways, and telling them "
            + "apart answers the question this whole chapter exists for: "
            + "\u{201C}I deleted a paragraph \u{2014} where is it?\u{201D} The "
            + "rule is four words long. DELETION GOES TO THE TRASH; "
            + "TRANSFORMATION GOES TO LINEAGE.",

            "THE FIRST EXIT \u{2014} you deleted it. Triple-click the "
            + "paragraph below and press \u{232B}. It leaves the page onto a "
            + "\(TrashWindow.days)-day clock, and it is now in TWO listings of "
            + "the same fact: \(TrayPath.menuLabel) (the tray icon at the top "
            + "of the note, Leaving section) and the Trash in the Library. Put "
            + "back in either one returns it to the place it stood in. "
            + "Deleted means LEAVING, and anything that is leaving always says "
            + "how long it has.",

            "EXIT ONE: triple-click me and press \u{232B}. I'm the deletion "
            + "\u{2014} look for me in the tray's Leaving section, and in the "
            + "Trash, and put me back from either.",

            "THE SECOND EXIT \u{2014} it became something else. Select from "
            + "the middle of the next paragraph to the middle of the one after "
            + "it and press \u{232B}. The two become ONE, quietly, the way any "
            + "editor would join them \u{2014} but the two blocks you started "
            + "with were not deleted. They were kept whole, set aside, and the "
            + "block they became remembers both.",

            "EXIT TWO, first half: select from somewhere in me all the way "
            + "into the paragraph below, and press \u{232B}.",

            "EXIT TWO, second half: and what we become will remember us both, "
            + "by name.",

            "Now look. Put your cursor in the joined paragraph and press "
            + "history: its \(BlockHistoryPath.cameFromSection) region lists "
            + "BOTH originals \u{2014} not one of them \u{2014} each with its "
            + "own text and a \(BlockHistoryPath.bringBackVerb) button that "
            + "puts it into the note again, beside what it became. Nothing "
            + "counted down. Nothing was in the Trash. Nothing announced "
            + "itself at the time, on purpose: a message on every join would "
            + "be noise, and this panel is the app keeping its side of that "
            + "bargain.",

            "So, whenever something is missing: if you DELETED it, look where "
            + "things are leaving \u{2014} the note's tray, then the Trash. If "
            + "you CHANGED it \u{2014} merged, divided \u{2014} look inside "
            + "what it became, under \(BlockHistoryPath.cameFromSection). "
            + "There is one place the two exits meet, and it is honest about "
            + "itself: a preserved original has no clock only while something "
            + "descended from it is alive, so deleting the last of those "
            + "descendants MOVES it, visibly, into the tray and onto the "
            + "family's clock \u{2014} and the delete that does it says so in "
            + "its own receipt, while you are standing there.",
        ])
        _ = exits

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
            "READ (\u{2318}3) is the note beside its own index \u{2014} and it opens "
            + "on EDIT. The column on the left is the index: markdown headings "
            + "become sections, every other block files under the one above it, "
            + "and a note with no headings lists plainly. Click a row and the "
            + "text beside it scrolls there; the \u{22EF} menu carries the block "
            + "acts. In the text, click any block and it goes live right where "
            + "it is \u{2014} one block at a time. The outline button folds the "
            + "column away and back. Read opens standing at the block you were "
            + "just in, whichever mode you came from.",

            "Switch the face to READ and the same note is a page \u{2014} the "
            + "paper a book's reading flow uses: markdown rendered, boundaries "
            + "gone, nothing to edit. Choose continuous, or pages (the book's "
            + "own leaves, \u{2190} \u{2192} turn them); Aa \u{2212} / Aa \u{FF0B} "
            + "size the type. Reading is the point \u{2014} and when a sentence "
            + "needs work, click its paragraph: the page turns to edit with "
            + "that block live.",

            "Try it: press \u{2318}3 \u{2014} the column stands at this lesson. "
            + "Click this very paragraph in the text and it goes live; type a "
            + "word. Switch to read, click this paragraph again \u{2014} the page "
            + "turns to edit with it live. Then \u{2318}1 back to Write.",
        ])

        let lenses = try lesson(looking, "lenses", [
            "A LENS is a saved way of LOOKING at a note: for each block, which "
            + "take to show. It never changes the note — \u{201C}a lens is the same "
            + "structure with different choices.\u{201D} Lenses mode (\u{2318}4) is their "
            + "home: full-text columns side by side.",

            "Both blocks of this lesson carry two takes, and a lens named "
            + "\u{201C}the other reading\u{201D} is saved beside the chosen text. In Lenses, "
            + "add its column (\u{FF0B} column \u{25B8} Open \u{201C}the other reading\u{201D}) and read "
            + "the two versions of this lesson side by side. The \u{2039} \u{203A} arrows "
            + "on any cell re-pick that block's take; \u{1F4BE} saves your current "
            + "picks as a new lens.",

            "\u{2713} Make this the note ADOPTS a column: the note's chosen takes "
            + "become what it shows. Adopting swaps, never destroys — the "
            + "outgoing chosen is auto-saved as a lens named \u{201C}chosen until "
            + "(today)\u{201D}, so you can always swap back.",
        ])
        let lensAlt1 = try take(on: lenses.blocks[0],
            "A LENS is a bookmark on your choices: it remembers, for every block, which "
            + "take you'd show — without moving the note an inch. Lenses mode (\u{2318}4) lays "
            + "such readings out as columns.")
        let lensAlt2 = try take(on: lenses.blocks[2],
            "\u{2713} Make this the note is the one door from looking to being: adopt, and the "
            + "column's picks become the note's chosen takes. The old chosen is kept as "
            + "\u{201C}chosen until (today)\u{201D} — swaps, never destroys.")
        let lens = try ops.createLens(post: lenses.post.id, name: "the other reading")
        _ = try ops.setLensChoice(lens: lens.id, block: lenses.blocks[0].block.id, variant: lensAlt1.id)
        _ = try ops.setLensChoice(lens: lens.id, block: lenses.blocks[2].block.id, variant: lensAlt2.id)

        let versions = try lesson(looking, "compare & versions", [
            "A VERSION is a different NOTE related to this one — \u{201C}a version is "
            + "a different structure.\u{201D} Two gestures share the word: MARK AS "
            + "VERSIONS just draws a link between two existing notes; DUPLICATE "
            + "AS VERSION mints a whole copy (takes and all) and draws the link "
            + "in one gesture. Mark = connect, duplicate = copy + connect.",

            "This lesson already has a version twin — it was duplicated when "
            + "the book was seeded. Open Compare (\u{2318}5): the notes sit side "
            + "by side, related blocks tied by lineage — and every pane is "
            + "EDITABLE. Click into either column and type: the edit lands in "
            + "that note, and the one live ring moves wherever you click, "
            + "across notes. Drag a block's \u{28FF} handle to reorder it — each "
            + "column reorders its own note only.",

            "Compare is honest about relationships. \u{201C}Follow this note's "
            + "order\u{201D} arranges the other columns beside their related blocks "
            + "(display only — nothing moves); lineage colors mark the "
            + "families, and rails appear only where a real relationship "
            + "exists. Compare against an unrelated note and it says \u{201C}there "
            + "is no relationship here\u{201D} — the two just sit plainly side by "
            + "side, no blanks, no colors.",

            "Compare OPENS with \u{201C}related blocks only\u{201D} on: it hides every "
            + "block lineage has nothing to say about, leaving just the "
            + "material that connects across the columns. Nothing is moved or "
            + "deleted — it is a way of LOOKING, and one click back: turn the "
            + "chip off to read the notes whole. Against an unrelated note it "
            + "tells you there is nothing to show, rather than showing you "
            + "nothing.",

            "Outlines live here too: press \u{201C}make outline note\u{201D} in "
            + "Compare's header and the app mints a linked condensation — "
            + "first sentence per block — and opens it beside this note, "
            + "registered point by point. And the Diff sheet now has "
            + "Save\u{2026} — the whole diff as a plain-text file, ready to hand "
            + "to an AI agent.",

            "Unmark deletes only the connection — both notes stay exactly as "
            + "they are. The library's right-click menu has Duplicate as "
            + "Version for any note, any time.",
        ])
        let twin = try ops.duplicateAsVersion(versions.post.id)
        // A distinct title (walk finding): the copy inherits the lesson's
        // title, and two identical rows in the ⌘K palette invite opening
        // the wrong one.
        try ops.renameContainer(twin.post.id, title: "compare & versions \u{2014} the twin")
        try ops.applyTag(tagID, toPost: twin.post.id)

        _ = try lesson(looking, "blocks \u{B7} canvas", [
            "Two more ways of looking, each a different traversal of the same "
            + "note — nothing is ever copied into a view. (Outlining lives in "
            + "Compare now: an outline is just a related note beside its "
            + "draft — the previous lesson's \u{201C}make outline note\u{201D}.)",

            // 13b 4D (N39 + N32(a)) + wave 2c (item 16, W8-1 direction C):
            // the workbench, taught where the doors live. (The old
            // table-of-contents half of this lesson lives in Read's edit
            // face now.)
            "BLOCKS (\u{2318}6) is the workbench — the note's blocks as "
            + "objects. Every row shows what it carries: takes, comments, "
            + "words, tags, a lock, when it last moved. Click a row and its "
            + "panel opens on the right — edit the text there, see its "
            + "takes, or jump onward (Write, Takes, its history). \u{2318}-click "
            + "picks several, and the bar above acts on all of them at once — "
            + "merge, tag, archive, delete, move out to snippets — one "
            + "\u{2325}\u{2318}Z takes the whole act back. Rows reorder with "
            + "\u{2191} \u{2193}, or the row's \u{22EF} menu moves by position: top, "
            + "bottom, or the number you type. Move out to snippets does what "
            + "it says: the block LEAVES this note and becomes a snippet "
            + "there (a block lives in one place; \u{2325}\u{2318}Z brings it "
            + "back).",

            // 13b 4E (N30/S4-7): the canvas package, taught whole.
            "CANVAS (\u{2318}7) scatters the blocks as sticky-note cards. They open "
            + "in a tidy grid until you arrange them; drag a card by its \u{2823} "
            + "header — arrangement is yours and is remembered, the note's order "
            + "doesn't move — and resize it from the corner grip. Click into a "
            + "card and type: edits land on the take the card is showing. The "
            + "little number in a card's corner is the block's place in the "
            + "note's current order.",

            "The canvas has one door back into order: \u{201C}order by clicking\u{201D}. "
            + "Click cards in the order the note should read — each shows its "
            + "number as you go — then Apply once: the numbered cards lead the "
            + "note and everything else keeps its relative order after them "
            + "(\u{2325}\u{2318}Z undoes; Cancel changes nothing). \u{201C}Fit all\u{201D} shows every "
            + "card at once — bigger boards open a read-only overview; click any "
            + "card to land back on it. The \u{2039} \u{203A} switcher on a card flips "
            + "which take you're viewing (\u{201C}viewing — not what the note "
            + "shows\u{201D}); choosing stays a separate, deliberate \u{2713}.",
        ])

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
            "A COMMENT is a working note on a BLOCK — about the writing, not in "
            + "it: \u{201C}take 1 is better, but take 2's ending\u{2026}\u{201D}. This block "
            + "carries one; it renders in the margin with a // prefix. Click it "
            + "to open the block's comments panel — or press \u{2318}\u{21E7}' anywhere. "
            + "The comments button sits in the bottom bar in Write and Takes "
            + "alike, and in Write, pointing at an uncommented block offers a "
            + "quiet \u{FF0B} in the left margin right where its note would sit.",

            "Comments survive the knife: divide or merge a commented block and "
            + "the note rides onto the successors. Deleted comments stay "
            + "visible in the panel and can be brought back — the feature is "
            + "deliberately never skimpy.",

            "TAGS organize notes (and blocks) without moving them: hierarchical "
            + "paths like life/goals/2024. A note wears them as little coloured "
            + "cards on the CONTEXT BAR at the top of its pane \u{2014} \u{FF0B} adds one "
            + "(type it; \u{201C}/\u{201D} nests, and a name that doesn't exist yet is "
            + "made), \u{2715} takes one off. Every tag keeps its own colour "
            + "everywhere. Fold the bar with \u{2318}\u{21E7}I and the cards become one "
            + "\u{FF03} door with the count. The tag manager lives in Settings "
            + "(\u{2318},), where a tag can also be promoted into a smart book "
            + "that collects everything wearing it.",

            "Full disclosure: every lesson note wears the \u{201C}tutorial\u{201D} tag — "
            + "that is exactly how Help \u{25B8} Restore Tutorial\u{2026} finds what to "
            + "replace. Your own notes never wear it unless you put it there; "
            + "everything else on your shelf is invisible to the restore.",
        ])
        _ = try ops.addBlockComment(
            to: commentsTags.blocks[0].block.id,
            text: "a comment lives in the margin — about the block, never inside its text")

        _ = try lesson(library, "books & the shelf", [
            "You are inside a BOOK right now: an ordered collection of notes "
            + "with real chapters. A note can live in MANY books at once — "
            + "membership is not ownership, and adding a note to a book never "
            + "moves or copies it.",

            "The chapter list on the left is workable: \u{FF0B} new chapter, "
            + "right-click a chapter to rename, move, or delete it, and drag "
            + "the \u{28FF} dots — in the list or on the page's chapter headings — "
            + "to reorder chapters. \u{FF0B} new note mints a note right inside "
            + "the book. Notes show as collapsed cards: clicking a card opens "
            + "the note in the full editor; its \u{25B8} expands it in place, "
            + "right here.",

            // 13b 4F (S4-9), rewritten at 13c 2A/2B/2C: the three modes and
            // what each is FOR. (P-6: the lesson says it, the app does it —
            // this paragraph still described the pre-2A vocabulary.)
            "Three views of a book share the toggle at the top. OUTLINE is "
            + "this scroll, and it is where a book gets WRITTEN: chapter "
            + "headings, notes you can collapse, and the same editor you "
            + "write a note in. BOOK is a two-page spread — each page is one "
            + "whole note, and the page you are in is editable as Write or "
            + "as its takes; \u{25C0} \u{25B6} turn the leaf two notes at a "
            + "time, and \u{25C1} \u{25B7} nudge by one so you can re-pair. "
            + "READ is for reading only, in two faces: SCROLL, the whole "
            + "book as one calm continuous page, and PAGES, real book pages "
            + "with the text flowing across them — turn the leaf, or scrub. "
            + "A finished book opens into Read by itself.",

            // 13b 4F (N36/N37): the per-post target + the restore door.
            "Books can be FINISHED (right-click the book on the shelf \u{25B8} "
            + "Length & Extent\u{2026}, or the \u{2713} finished face): finishing freezes "
            + "membership and order, reversibly. A book can also carry a word "
            + "target — this one wears one, so its shelf row shows progress. "
            + "A single note can wear its own target too: click the word "
            + "counts in the editor's bottom bar. Targets are a measure, "
            + "never a wall. And here is what deleting a book MEANS: the book, "
            + "its chapters, and its memberships go — **the notes stay**, in "
            + "your Library and in any other books that point at them, because "
            + "a book only ever points at notes and never owns them. The "
            // The post-13l polish round, ledger row 12: this sentence named a
            // menu her B1 ruling dissolved. The Trash has its own icon at the
            // top of the Library now, and Archived is its own sidebar item —
            // a lesson naming a door that no longer exists is a P-6
            // regression, chapters away from the one that moved it.
            + "deleted book waits \(TrashWindow.days) days in the Trash "
            + "(the trash icon at the top of the Library) with a Put back "
            + "door — chapters and membership come back with it. The only way "
            + "notes die is deleting the notes.",
        ])

        let scraps = try lesson(library, "pool & scraps", [
            "Not everything starts as a note. The POOL (sidebar) holds notes "
            + "that belong to no book yet — drafts in waiting. SNIPPETS (sidebar) "
            + "holds SCRAPS: loose blocks that aren't notes at all — "
            + "overheard lines, stray sentences, one-liners you'll want later.",

            "A pool named \u{201C}tutorial scraps\u{201D} was seeded for you with two "
            + "scraps — the Snippets area's pool menu switches between pools, so "
            + "look for it there. To drag one into a note: open any lesson in "
            + "Write (\u{2318}1) and press the scraps button in the note's top-right "
            + "corner (beside References). The scraps sit beside the page — "
            + "drag one in, and it lands as a COPY with lineage back to the "
            + "scrap, which stays in its pool. Hold \u{2325} while dragging and the "
            + "whole fan rides the copy, takes and all (the second scrap has "
            + "two, to try exactly that).",

            "The Snippets area's own dashed box mints scraps: type, \u{23CE}, and the "
            + "line is kept as a standalone block. Drag pieces out as your "
            + "drafts want them — copy out is the only direction, so the pool "
            + "never tangles with your notes.",

            // 13b 4D (N32(b)/(c) — S4-8/S4-15): scraps are individual
            // items; the pools-vs-tags distinction said plainly.
            "Each scrap is its own item and can wear TAGS: right-click a "
            + "scrap row — here, in the side panel, or on a canvas card — "
            + "and Tags\u{2026} opens its tag sheet. Worth keeping straight: a "
            + "POOL is a container (a scrap lives in exactly one; moving it "
            + "moves it), while a TAG is a label (a scrap can wear many, and "
            + "filtering by tag never moves anything).",
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
            + "book exports as one document — its chapters as headings, this "
            + "very book included — from its shelf right-click; and "
            + "File \u{25B8} Export Library\u{2026} writes the whole library as a folder "
            + "of Markdown in one gesture.",

            "Exports are honest projections: the chosen take in place, and "
            + "Markdown with Takes\u{2026} adds a labeled Alternates section for "
            + "every fanned block, so nothing you kept open is lost on paper. "
            + "Try it on the choosing lesson — its four rain takes all reach "
            + "the page.",
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

        let threeWays = try lesson(library, "three ways of working", [
            "Everything in this book comes down to three ways of working with "
            + "one piece of writing. This lesson is the map — it absorbs the "
            + "old modes tutorial.",

            "POLISH IN PLACE: just write. Most text needs no machinery — type, "
            + "autosave keeps up, \u{2318}S keeps savepoints. If your text looks like "
            + "basic text, it behaves like basic text.",

            "THREAD ONE PIECE: when one block is the question, fan it. Takes "
            + "hold the attempts side by side; \u{2713} picks what the note says; a "
            + "lens remembers a whole set of picks without touching the note. "
            + "The block below has a spare take to practice on.",

            "The keeper's logbook recorded weather, oil, and wicks — never "
            + "once the keeper.",

            "FORK THE PIECE: when the STRUCTURE should differ — a rearranged "
            + "argument, a different opening — duplicate the note as a version "
            + "and let the two grow apart, linked and comparable. \u{201C}A lens is "
            + "the same structure with different choices; a version is a "
            + "different structure; promote is the bridge.\u{201D}",
        ])
        try take(on: threeWays.blocks[3],
            "The logbook knew everything about the light and nothing about the keeping of it.")

        return book.id
    }
}
