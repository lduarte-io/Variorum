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
//  NON-JOURNAL (`.generic`, no entry dates — R57: the Fragments bridge
//  sweeps journal days only, and no tutorial text may ever reach it).
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
        "This replaces the tutorial with a fresh copy: every post tagged exactly "
        + "\u{201C}\(tagName)\u{201D}, every pool named \u{201C}\(scrapPoolTitle)\u{201D}, and every book "
        + "named \u{201C}\(bookName)\u{201D} are deleted and re-seeded. Nothing else is touched."

    // MARK: - The lesson plan (the coverage CONTRACT, walk-asserted)

    /// Chapters and lessons, in book order. `TutorialWalkTests` asserts the
    /// seeded book matches this exactly — a lesson that drifts out of the
    /// seed (or a seed that drifts out of the plan) is a red test, and the
    /// scripted screenshot walk drives this same list.
    nonisolated static let plan: [(chapter: String, lessons: [String])] = [
        ("welcome", ["start here", "getting around"]),
        ("writing", ["blocks & typing", "shaping blocks"]),
        ("takes", ["your first take", "choosing & the board", "keeping takes safe"]),
        ("structure", ["divide", "the take ceremony", "extract & make block",
                       "merge", "the two undos"]),
        ("ways of looking", ["lenses", "compare & versions",
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
            + "reading a post, inside a chapter, inside a book on your shelf — the "
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
            + "box that reads \u{201C}new post — just start typing\u{201D} — type a first line "
            + "there and \u{23CE} mints a post and opens it. LIBRARY is everything, "
            + "searchable, with a List and a Timeline view. POOL holds posts that "
            + "belong to no book yet. BLOCKS holds loose scraps — pieces of text "
            + "that aren't posts at all.",

            "\u{2318}K finds anything: posts, books, blocks, and commands — type a few "
            + "letters and \u{23CE} opens the hit. \u{2318}N makes a new post from anywhere. "
            + "\u{2318}J opens today's journal entry — the journal is its own daily "
            + "notebook on the shelf.",

            "A post opens into one of six modes — the tabs read Write \u{B7} Takes \u{B7} "
            + "Lenses \u{B7} Compare \u{B7} Blocks \u{B7} Canvas, and \u{2318}1 through \u{2318}6 "
            + "switch between them. Takes is where a post usually opens; Write is "
            + "the plain full page. The rest of this book visits each mode where "
            + "it earns its keep.",

            "Try it now: press \u{2318}K, type \u{201C}getting\u{201D}, and \u{23CE} back to this very "
            + "lesson. Then press \u{2318}2 for Takes and \u{2318}1 for Write, and watch the "
            + "same text wear both faces.",
        ])

        // ————————————————————————————— writing —————————————————————————————

        _ = try lesson(writing, "blocks & typing", [
            "Everything you write is made of BLOCKS — paragraph-sized pieces with "
            + "permanent identity. You never manage them while drafting: switch to "
            + "Write (\u{2318}1), click at the very end of this post, and type a few "
            + "paragraphs. Each paragraph quietly becomes its own block as you "
            + "type past it. No gesture, no ceremony.",

            "Inside a block, Return is just a newline — a block can hold several "
            + "paragraphs if you paste or merge them into one. Block boundaries "
            + "only ever change when you ask (divide, merge, extract — the "
            + "structure chapter).",

            "Boundaries are invisible at rest, on purpose: a post reads as calm, "
            + "seamless prose. When you want to see the seams, press \u{2318}\u{21E7}B — "
            + "dotted lines appear between blocks, everywhere, until you press it "
            + "again.",

            "The bottom bar keeps quiet count for you: which block your cursor is "
            + "in, and the word counts — the take you're in, and the whole post.",
        ])

        let shaping = try lesson(writing, "shaping blocks", [
            "Blocks mostly shape themselves as you type. This lesson is the "
            + "hand tools, and its blocks are staged for each one.",

            "The first tool needs a middle sentence. This lesson was written as "
            + "calm filler around exactly one restless line. This middle sentence "
            + "wants to be a block of its own. Select that whole sentence, press "
            + "\u{2318}\u{21E7}K (Make Block from Selection), and watch it become its own "
            + "block — from Takes, the app carries you to Write and does it there.",

            "New blocks can also be asked for directly: the block \u{25BE} menu in the "
            + "bottom bar has \u{FF0B} New block at the end of the post. In Takes it "
            + "mints an empty block and puts your cursor in it — just keep typing.",

            "A block can carry a NAME — a handle for finding it, never printed in "
            + "the prose. This block wears one: open the Blocks tab (\u{2318}5) and "
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
            + "\u{2713} is what the post actually says — \u{201C}visible is what you're "
            + "looking at; chosen is what the post is.\u{201D} \u{2318}\u{23CE} chooses the take "
            + "you're in; nothing else changes the post.",

            "The block below carries four takes of one sentence, ready for "
            + "practice. Open its fan (\u{2318}\u{21E7}T), step through them with \u{2303}\u{2318}\u{2190} "
            + "and \u{2303}\u{2318}\u{2192}, and choose your favorite.",

            "The rain came in from the sea without an opinion about any of us.",

            "When a fan holds more takes than fit, the rail pages: \u{25C0} 1\u{2013}2 of 4 \u{25B6} "
            + "— \u{2325}\u{2318}\u{2190} and \u{2325}\u{2318}\u{2192} turn the pages from the keyboard. The "
            + "style: menu in the board's top line picks how fans open — stack, "
            + "carousel, margin grid, or slot split — and \u{238B} closes every fan at "
            + "once.",
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
            + "\u{2318}S, then press history in the bottom bar. Your savepoint is "
            + "listed; Restore loads any savepoint back into the take — and "
            + "committing again just adds another.",

            "The block below has a spare take to practice ARCHIVING on. Click "
            + "into the second take and press \u{2318}\u{21E7}A — it leaves the board, out "
            + "of the fan but never gone.",

            "Never gone means never gone: an \u{201C}archived \u{B7} 1\u{201D} door appears "
            + "right under that block's takes. Open it and Unarchive puts the "
            + "take straight back in the fan — no leaving the board. (Write's "
            + "takes panel keeps the same archived list, if you're over there.)",
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

            "From Takes, the same door WORKS — press \u{2318}\u{21E7}D there, or the Divide "
            + "button in the bottom bar, and watch the app do the carrying: it "
            + "switches to Write, lands your cursor where you were, and cuts. "
            + "That visible carry is a feature, not a trick — every structure "
            + "gesture in Takes travels the same way.",

            "One \u{2325}\u{2318}Z (structural undo) puts a divided block back together. "
            + "The undo chapter has the whole story.",
        ])

        let ceremony = try lesson(structure, "the take ceremony", [
            "When you divide a block that has SEVERAL takes, there's a real "
            + "question the app can't answer for you: each take is a different "
            + "text, so each take needs its own cut. The app asks exactly once, "
            + "in one sheet — the take ceremony.",

            // 13b 4A: the sheet shows every checked take at once, the ✂
            // drags between word edges, keyboard placement, and PARKING.
            "The block below carries three takes, staged for it. Put your cursor "
            + "mid-block and press \u{2318}\u{21E7}D. The sheet titled \u{201C}Divide into takes\u{201D} "
            + "shows every take with a checkbox, each checked take's text laid "
            + "out with a ✂ you can place anywhere between words: drag it, "
            + "click a spot, or use \u{2190}/\u{2192} (\u{2325} jumps by sentence, \u{21E5} moves "
            + "between takes). Your cut is pre-placed where it could be "
            + "matched. Leave the third take UNCHECKED before you confirm.",

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
            + "zero ceremony, the source block keeps its identity and all its "
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

            // 13b 4B (S4-23): the merge CEREMONY — fanned merges are no
            // longer a silent rule; the sheet shows the choice.
            "When either block has other takes, Merge opens a small CEREMONY "
            + "instead of deciding silently: both blocks' takes side by side, "
            + "pre-paired with the two you were looking at — press \u{23CE} and you "
            + "get exactly the everyday join. Pair takes with \u{FF0B} and the merged "
            + "block gets one joined take per pairing (divide a two-take block, "
            + "pair 1+1 and 2+2, and it comes back whole); check \u{201C}carry\u{201D} to "
            + "ride a take over unjoined; each pairing previews its join — "
            + "space, new line, or nothing. Takes are never multiplied "
            + "combinatorially: pairing is choosing by hand.",

            "Whatever you leave unpaired stays with the released blocks in "
            + "lineage — the app names the road, and \u{2325}\u{2318}Z brings the sources "
            + "back, takes and all. The block below carries a spare take so you "
            + "can watch the ceremony open when you merge it into this one.",

            "This block has a second take — merge me upward and the ceremony "
            + "will open with my takes laid out for pairing.",
        ])
        try take(on: merging.blocks[6],
            "The spare take: pair me, carry me, or leave me in lineage — the merge ceremony asks; undo brings me home.")

        _ = try lesson(structure, "the two undos", [
            "Variorum keeps two undo stacks, deliberately separate. \u{2318}Z is TEXT "
            + "undo — your typing, inside the take you're editing, as in any "
            + "editor.",

            "\u{2325}\u{2318}Z is STRUCTURAL undo — divides, merges, extracts, moves, "
            + "deletions of blocks and takes. It never touches your typing; it "
            + "restores the shape. Every structural act in this book is one "
            + "\u{2325}\u{2318}Z away from undone, and the report of what was undone lands "
            + "at the bottom of the window.",

            "If a structural undo would overwrite words you typed AFTER the "
            + "act, the app quietly keeps a savepoint of your newer text "
            + "first — insurance, so nothing typed is ever more than one "
            + "restore away. Try it: divide the block above, type a few words "
            + "into the FIRST half, press \u{2325}\u{2318}Z, then look in history.",
        ])

        // ——————————————————————————— ways of looking ———————————————————————

        let lenses = try lesson(looking, "lenses", [
            "A LENS is a saved way of LOOKING at a post: for each block, which "
            + "take to show. It never changes the post — \u{201C}a lens is the same "
            + "structure with different choices.\u{201D} Lenses mode (\u{2318}3) is their "
            + "home: full-text columns side by side.",

            "Both blocks of this lesson carry two takes, and a lens named "
            + "\u{201C}the other reading\u{201D} is saved beside the chosen text. In Lenses, "
            + "add its column (\u{FF0B} column \u{25B8} Open \u{201C}the other reading\u{201D}) and read "
            + "the two versions of this lesson side by side. The \u{2039} \u{203A} arrows "
            + "on any cell re-pick that block's take; \u{1F4BE} saves your current "
            + "picks as a new lens.",

            "\u{2713} Make this the post ADOPTS a column: the post's chosen takes "
            + "become what it shows. Adopting swaps, never destroys — the "
            + "outgoing chosen is auto-saved as a lens named \u{201C}chosen until "
            + "(today)\u{201D}, so you can always swap back.",
        ])
        let lensAlt1 = try take(on: lenses.blocks[0],
            "A LENS is a bookmark on your choices: it remembers, for every block, which "
            + "take you'd show — without moving the post an inch. Lenses mode (\u{2318}3) lays "
            + "such readings out as columns.")
        let lensAlt2 = try take(on: lenses.blocks[2],
            "\u{2713} Make this the post is the one door from looking to being: adopt, and the "
            + "column's picks become the post's chosen takes. The old chosen is kept as "
            + "\u{201C}chosen until (today)\u{201D} — swaps, never destroys.")
        let lens = try ops.createLens(post: lenses.post.id, name: "the other reading")
        _ = try ops.setLensChoice(lens: lens.id, block: lenses.blocks[0].block.id, variant: lensAlt1.id)
        _ = try ops.setLensChoice(lens: lens.id, block: lenses.blocks[2].block.id, variant: lensAlt2.id)

        let versions = try lesson(looking, "compare & versions", [
            "A VERSION is a different POST related to this one — \u{201C}a version is "
            + "a different structure.\u{201D} Two gestures share the word: MARK AS "
            + "VERSIONS just draws a link between two existing posts; DUPLICATE "
            + "AS VERSION mints a whole copy (takes and all) and draws the link "
            + "in one gesture. Mark = connect, duplicate = copy + connect.",

            "This lesson already has a version twin — it was duplicated when "
            + "the book was seeded. Open Compare (\u{2318}4): the posts sit side "
            + "by side, related blocks tied by lineage — and every pane is "
            + "EDITABLE. Click into either column and type: the edit lands in "
            + "that post, and the one live ring moves wherever you click, "
            + "across posts. Drag a block's \u{28FF} handle to reorder it — each "
            + "column reorders its own post only.",

            "Compare is honest about relationships. \u{201C}Follow this post's "
            + "order\u{201D} arranges the other columns beside their related blocks "
            + "(display only — nothing moves); lineage colors mark the "
            + "families, and rails appear only where a real relationship "
            + "exists. Compare against an unrelated post and it says \u{201C}there "
            + "is no relationship here\u{201D} — the two just sit plainly side by "
            + "side, no blanks, no colors.",

            "Outlines live here too: press \u{201C}make outline post\u{201D} in "
            + "Compare's header and the app mints a linked condensation — "
            + "first sentence per block — and opens it beside this post, "
            + "registered point by point. And the Diff sheet now has "
            + "Save\u{2026} — the whole diff as a plain-text file, ready to hand "
            + "to an AI agent.",

            "Unmark deletes only the connection — both posts stay exactly as "
            + "they are. The library's right-click menu has Duplicate as "
            + "Version for any post, any time.",
        ])
        let twin = try ops.duplicateAsVersion(versions.post.id)
        // A distinct title (walk finding): the copy inherits the lesson's
        // title, and two identical rows in the ⌘K palette invite opening
        // the wrong one.
        try ops.renameContainer(twin.post.id, title: "compare & versions \u{2014} the twin")
        try ops.applyTag(tagID, toPost: twin.post.id)

        _ = try lesson(looking, "blocks \u{B7} canvas", [
            "Two more ways of looking, each a different traversal of the same "
            + "post — nothing is ever copied into a view. (Outlining lives in "
            + "Compare now: an outline is just a related post beside its "
            + "draft — the previous lesson's \u{201C}make outline post\u{201D}.)",

            "BLOCKS (\u{2318}5) is the post as a table of contents: one row per "
            + "block, named where you set names, first sentence where you "
            + "didn't. Rows reorder with \u{2191} \u{2193}, rename with Name\u{2026}, and a row "
            + "expands to edit in place — handy in a long post.",

            "CANVAS (\u{2318}6) scatters the blocks as cards you can drag around — "
            + "arrangement is yours and is remembered, the post's order doesn't "
            + "move. The \u{2039} \u{203A} switcher on a card flips which take you're "
            + "viewing (\u{201C}viewing — not what the post shows\u{201D}); choosing stays a "
            + "separate, deliberate \u{2713}.",
        ])

        // —————————————————————————— the library of things ——————————————————

        let commentsTags = try lesson(library, "comments & tags", [
            "A COMMENT is a working note on a BLOCK — about the writing, not in "
            + "it: \u{201C}take 1 is better, but take 2's ending\u{2026}\u{201D}. This block "
            + "carries one; it renders in the margin with a // prefix. Click it "
            + "to open the block's comments panel — or press \u{2318}\u{21E7}' anywhere.",

            "Comments survive the knife: divide or merge a commented block and "
            + "the note rides onto the successors. Deleted comments stay "
            + "visible in the panel and can be brought back — the feature is "
            + "deliberately never skimpy.",

            "TAGS organize posts (and blocks) without moving them: hierarchical "
            + "paths like life/goals/2024, applied from the tags\u{2026} door in the "
            + "bottom bar. The tag manager lives in Settings (\u{2318},), where a "
            + "tag can also be promoted into a smart book that collects "
            + "everything wearing it.",

            "Full disclosure: every lesson post wears the \u{201C}tutorial\u{201D} tag — "
            + "that is exactly how Help \u{25B8} Restore Tutorial\u{2026} finds what to "
            + "replace. Your own posts never wear it unless you put it there; "
            + "everything else on your shelf is invisible to the restore.",
        ])
        _ = try ops.addBlockComment(
            to: commentsTags.blocks[0].block.id,
            text: "a comment lives in the margin — about the block, never inside its text")

        _ = try lesson(library, "books & the shelf", [
            "You are inside a BOOK right now: an ordered collection of posts "
            + "with real chapters. A post can live in MANY books at once — "
            + "membership is not ownership, and adding a post to a book never "
            + "moves or copies it.",

            "The chapter list on the left is workable: \u{FF0B} new chapter, "
            + "right-click a chapter to rename, move, or delete it, and drag "
            + "the \u{28FF} dots — in the list or on the page's chapter headings — "
            + "to reorder chapters. \u{FF0B} new post mints a post right inside "
            + "the book. Posts show as collapsed cards: clicking a card opens "
            + "the post in the full editor; its \u{25B8} expands it in place, "
            + "right here.",

            "The Book \u{B7} Read toggle at the top switches to the reading flow: "
            + "the whole book as one calm, continuous page. A finished book "
            + "opens there by itself.",

            "Books can be FINISHED (right-click the book on the shelf \u{25B8} "
            + "Length & Extent\u{2026}, or the \u{2713} finished face): finishing freezes "
            + "membership and order, reversibly. A book can also carry a word "
            + "target — this one wears one, so its shelf row shows progress. "
            + "Targets are a measure, never a wall.",
        ])

        let scraps = try lesson(library, "pool & scraps", [
            "Not everything starts as a post. The POOL (sidebar) holds posts "
            + "that belong to no book yet — drafts in waiting. BLOCKS (sidebar) "
            + "holds SCRAPS: loose blocks that aren't posts at all — "
            + "overheard lines, stray sentences, one-liners you'll want later.",

            "A pool named \u{201C}tutorial scraps\u{201D} was seeded for you with two "
            + "scraps — the Blocks area's pool menu switches between pools, so "
            + "look for it there. To drag one into a post: open any lesson in "
            + "Write (\u{2318}1) and press the scraps button in the post's top-right "
            + "corner (beside References). The scraps sit beside the page — "
            + "drag one in, and it lands as a COPY with lineage back to the "
            + "scrap, which stays in its pool. Hold \u{2325} while dragging and the "
            + "whole fan rides the copy, takes and all (the second scrap has "
            + "two, to try exactly that).",

            "The Blocks area's own dashed box mints scraps: type, \u{23CE}, and the "
            + "line is kept as a standalone block. Drag pieces out as your "
            + "drafts want them — copy out is the only direction, so the pool "
            + "never tangles with your posts.",
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
            "Your work is always yours to take out. Any post exports as "
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
            "This post is SEALED — marked complete. Everything under a sealed "
            + "post refuses to change: typing, new takes, commits, divides, "
            + "all of it, until you unseal.",

            "Try to break it. Press \u{2318}S to commit, or \u{2318}\u{21E7}D to divide — each "
            + "attempt is answered OUT LOUD at the bottom of the window: the "
            + "app tells you the post is sealed rather than doing nothing. "
            + "Typing simply finds the text read-only. A door that can't act "
            + "tells you why, never nothing.",

            "The seal is reversible and gentle: the unseal door sits right in "
            + "the bottom bar. Unseal this post, change a word, seal it again "
            + "(seal, same place). Sealing quietly commits any unsaved takes "
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
            + "hold the attempts side by side; \u{2713} picks what the post says; a "
            + "lens remembers a whole set of picks without touching the post. "
            + "The block below has a spare take to practice on.",

            "The keeper's logbook recorded weather, oil, and wicks — never "
            + "once the keeper.",

            "FORK THE PIECE: when the STRUCTURE should differ — a rearranged "
            + "argument, a different opening — duplicate the post as a version "
            + "and let the two grow apart, linked and comparable. \u{201C}A lens is "
            + "the same structure with different choices; a version is a "
            + "different structure; promote is the bridge.\u{201D}",
        ])
        try take(on: threeWays.blocks[3],
            "The logbook knew everything about the light and nothing about the keeping of it.")

        return book.id
    }
}
