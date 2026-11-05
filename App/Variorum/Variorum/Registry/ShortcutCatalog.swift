//
//  ShortcutCatalog.swift
//  Variorum (Mac)
//
//  **VX-572 (the VX-677 run, batch 4) — the ⌘/ helper's shortcut list, ON
//  THE REGISTRY (P-1).** Her 10-21 note, verbatim: *"I NEED the ability to
//  search shortcuts, I need shortcuts to be defined helpfully by their
//  headings and default to not being expanded, I need the positioning of
//  shortcuts to work better so that they're actually legible."* — and her
//  10-28 pass: correct the spacing; the description in the voice's face;
//  line wraps must stop confusing (a long chord name like "Format ▸
//  Strikethrough" broke mid-name; long descriptions wrapped into the
//  neighbouring rhythm); collapsible group headers; "it must be easy to see
//  which chord does what".
//
//  **What moved, and why.** `HelperView.groups` was a HAND-KEPT list: every
//  chord typed a second time beside the registry that already declared it,
//  held to it only by a string-match drift guard (13g L1). This catalog keeps
//  the list's WORDS and ORDER — prose in her voice, which a generated table
//  would lose — but every chord it shows is READ from the declaration it
//  names (`shortcutLabel`, `alternateShortcutLabel`, `systemShortcutLabel`,
//  or a keyless act's menu path built from its `verb`), so a re-picked key
//  moves in the registry alone. A row names the acts it teaches by ID, which
//  is what the registry walk now checks (every declared chord is SHOWN by a
//  row citing its act — never matched by string). The few keys that are no
//  act's declared chord — ⌘Z (NSTextView's), ⎋, ⌘, (the system's Settings
//  item), a ⌘-click, Tab in a list, a capture box's keys, a bar's door by its
//  name — are declared here as GESTURES, each with the acts it reaches.
//
//  The helper's Shortcuts tab, Settings ▸ Shortcuts and Settings' search all
//  render from here (through `HelperView.groups`, kept as their projection).
//
//  Pure Swift, no AppKit/SwiftUI: the grouping, the filter and the chord
//  reading are pinned without mounting anything (`ShortcutCatalogTests`).
//

import Foundation

nonisolated enum ShortcutCatalog {
    // MARK: - The headings (PROVISIONAL P-572-1)

    /// The helper's headings, in their DECLARED order — the grouping the
    /// registry carries. Her nine titles as they shipped; the order is the
    /// writing day's (writing first, the AI door last) and each heading
    /// says in one line what it holds, so a collapsed list still tells her
    /// where to look. PROVISIONAL (P-572-1 — the order and the lines).
    enum Group: String, CaseIterable, Identifiable, Sendable {
        case writing, formatting, structure, takes, find, navigation, windows, bars, mcp

        var id: String { rawValue }

        /// The heading, as it shipped (Terminal lowercases it as chrome).
        var title: String {
            switch self {
            case .writing: "Writing"
            case .formatting: "Formatting"
            case .structure: "Structure"
            case .takes: "Takes"
            case .find: "Find in a note"
            case .navigation: "Navigation"
            case .windows: "Windows & panes"
            case .bars: "The note's bars"
            case .mcp: "MCP"
            }
        }

        /// The heading's one line — what is inside (PROVISIONAL words,
        /// P-572-1; VX-234's copy pass).
        var line: String {
            switch self {
            case .writing: "commit, versions, undo, comments, callouts, spelling"
            case .formatting: "bold, italic, headings, lists, links"
            case .structure: "divide, extract, merge, a new block"
            case .takes: "a block's takes \u{2014} new, choose, step, archive"
            case .find: "find, replace, the next match"
            case .navigation: "modes, find anything, new notes, wings"
            case .windows: "the Open list, back and forward, splits, the quick note"
            case .bars: "the bottom bar's menus and the masthead's tags"
            case .mcp: "an AI client's asks, shares and changes"
            }
        }
    }

    // MARK: - A row

    /// Where a row's chord column comes from.
    enum Keys: Sendable {
        /// The acts' declared in-app chords, in order ("⌃⌘← / ⌃⌘→").
        case chords([CapabilityID])
        /// The acts' declared ALTERNATE chords (VX-560 / VX-563's keys).
        case alternates([CapabilityID])
        /// The act's SYSTEM chord (13e E14's — reaches her from any app).
        case system(CapabilityID)
        /// A keyless act by its menu path: "‹menu› ▸ ‹verb›".
        case menu(String, CapabilityID)
        /// A key or a door that is no act's declared chord, said in its own
        /// tokens, with the acts it reaches (none for ⌘Z, ⎋'s blooms aside).
        case gesture([String], acts: [CapabilityID])
    }

    struct Row: Identifiable, Sendable {
        let group: Group
        let keys: Keys
        /// What it does — her prose, kept verbatim from the hand-kept list.
        let words: String

        /// The chord column's tokens, each drawn whole (never broken).
        var tokens: [String] {
            switch keys {
            case .chords(let ids):
                ids.compactMap { CapabilityRegistry.capability($0).shortcutLabel }
            case .alternates(let ids):
                ids.compactMap { CapabilityRegistry.capability($0).alternateShortcutLabel }
            case .system(let id):
                [CapabilityRegistry.capability(id).systemShortcutLabel].compactMap { $0 }
            case .menu(let menu, let id):
                ["\(menu) \u{25B8} \(CapabilityRegistry.capability(id).verb)"]
            case .gesture(let tokens, _):
                tokens
            }
        }

        /// The acts this row teaches — the registry walk's ID-level check.
        var acts: [CapabilityID] {
            switch keys {
            case .chords(let ids), .alternates(let ids): ids
            case .system(let id), .menu(_, let id): [id]
            case .gesture(_, let acts): acts
            }
        }

        /// The chord column as one string ("⌘G / ⇧⌘G") — the shape the
        /// Settings pane and the older pins read (`HelperView.groups`).
        var keysText: String { tokens.joined(separator: " / ") }

        var id: String { group.rawValue + "|" + keysText }
    }

    static func rows(in group: Group) -> [Row] {
        rows.filter { $0.group == group }
    }

    // MARK: - THE ROWS (her words, the hand-kept list's, verbatim but where noted)

    static let rows: [Row] = writing + formatting + structure + takes + find + navigation
        + windows + bars + mcp

    private static let writing: [Row] = [
        // 13u3 UNIT D (item 14) · 13s-b U4 (R-13s-31) · VX-347 (P-VX347-4):
        // every way out of the field but ⎋ commits.
        Row(group: .writing, keys: .chords([.commitTake]),
            words: "commit \u{2014} an immutable saved moment of the take you're in; "
                + "name it or press \u{23CE} \u{2014} any way out of the field but \u{238B} commits it"),
        // The post-13l polish round (rows 16/23): this take's moment, and this note's.
        Row(group: .writing, keys: .chords([.saveNoteVersion]),
            words: "save a version \u{2014} the whole note as it is, in Versions"),
        // VX-125: the third grain — the note OUT, as a file.
        Row(group: .writing, keys: .chords([.exportNote]),
            words: "export this note as a Markdown file in the Variorum simple "
                + "format \u{2014} exactly what Copy full text copies, takes and tags included, "
                + "so File \u{25B8} Import\u{2026} reads it back"),
        // NSTextView's own undo — no act declares it.
        Row(group: .writing, keys: .gesture(["\u{2318}Z"], acts: []),
            words: "text undo (typing only)"),
        Row(group: .writing, keys: .chords([.structuralUndo]),
            words: "structural undo (splits, merges, moves \u{2014} never text)"),
        Row(group: .writing, keys: .chords([.structuralRedo]),
            words: "structural redo \u{2014} puts back what \u{2325}\u{2318}Z undid"),
        Row(group: .writing, keys: .chords([.previousBlock, .nextBlock]),
            words: "jump to the previous / next block"),
        Row(group: .writing, keys: .chords([.blockComments]),
            words: "the block's comments"),
        Row(group: .writing, keys: .chords([.callout]),
            words: "callout frame on this block (again to remove it)"),
        Row(group: .writing, keys: .chords([.toggleSeams]),
            words: "toggle block seams (dotted lines between blocks)"),
        // VX-798 (the VX-828 run, batch E): Edit ▸ Spelling and Grammar's
        // pair — the one-shot check, and the panel. Neither turns checking as
        // you type on; the words say where that lives.
        Row(group: .writing, keys: .chords([.checkSpelling]),
            words: "check spelling once \u{2014} selects the next misspelled word after the "
                + "cursor (again for the one after); checking as you type stays a setting "
                + "(Settings \u{25B8} Editor \u{25B8} Spellchecking)"),
        Row(group: .writing, keys: .chords([.showSpellingPanel]),
            words: "the Spelling and Grammar panel \u{2014} the word, its guesses, Change, "
                + "Ignore and Learn"),
    ]

    // 13g batch 3 (L8): the two chords her ruling named, plus the menu-first
    // doors by their MENU PATH — the framing line ("every shortcut here is
    // also a menu item") has to read both ways.
    private static let formatting: [Row] = [
        Row(group: .formatting, keys: .chords([.formatBold]),
            words: "bold \u{2014} wraps the selection in ** ** (again to take it off)"),
        Row(group: .formatting, keys: .chords([.formatItalic]),
            words: "italic \u{2014} the same, with * *"),
        Row(group: .formatting, keys: .menu("Format", .formatStrikethrough),
            words: "~~like this~~"),
        Row(group: .formatting, keys: .menu("Format", .formatCode),
            words: "`like this`"),
        Row(group: .formatting, keys: .menu("Format", .formatHeading),
            words: "heading 1, 2 or 3 \u{2014} the line gains #, ## or ###"),
        Row(group: .formatting, keys: .menu("Format", .formatBulletList),
            words: "the line becomes \"- item\""),
        Row(group: .formatting, keys: .menu("Format", .formatChecklist),
            words: "the line becomes \"- [ ] item\" \u{2014} click the box to tick it"),
        // 13g batch 4 (L10): the link act and BOTH of its click rules.
        Row(group: .formatting, keys: .menu("Format", .formatAddLink),
            words: "[text](address) around the selection, cursor in the "
                + "parentheses ready for the address"),
        Row(group: .formatting, keys: .gesture(["\u{2318}-click a link"], acts: []),
            words: "opens it \u{2014} in a writing surface, where a plain click "
                + "places the cursor; in Read a plain click opens it"),
        // 13k K7: the toolbar is a THIRD door onto the same eight acts.
        Row(group: .formatting, keys: .gesture(["the bottom bar"], acts: [
            .formatBold, .formatItalic, .formatStrikethrough, .formatCode, .formatAddLink,
            .formatHeading, .formatBulletList, .formatChecklist,
        ]),
            words: "B \u{B7} I \u{B7} S \u{B7} ` \u{B7} link \u{B7} H \u{B7} \u{2022} \u{B7} \u{2610} \u{2014} the same eight acts "
                + "as the Format menu, on the text you're writing in"),
        // 13k K8: Tab is never a menu key equivalent, so its row is a gesture.
        // VX-572 (re-keyed): the keys alone in the chord column, "in a list"
        // moved to the words — the column never wraps a name.
        Row(group: .formatting, keys: .gesture(["Tab", "\u{21E7}Tab"], acts: [.formatIndent, .formatOutdent]),
            words: "in a list: indent / outdent the list item you're in "
                + "(Format \u{25B8} Indent and Format \u{25B8} Outdent do the same); "
                + "outside a list, Tab is the key it always was"),
        // 13u4 UNIT S1 (her item 5 — her own word is UNINDENT; the row says both).
        Row(group: .formatting, keys: .chords([.formatIndent, .formatOutdent]),
            words: "indent / outdent \u{2014} unindent, if that's your word for it \u{2014} "
                + "the list item you're in; the same act as Tab / \u{21E7}Tab, on keys the "
                + "Format menu can show you"),
    ]

    private static let structure: [Row] = [
        Row(group: .structure, keys: .chords([.divide]),
            words: "divide the block at the cursor \u{2014} a block with takes cuts "
                + "the take you're in and leaves the others whole on the first block"),
        Row(group: .structure, keys: .chords([.divideWithCeremony]),
            words: "divide choosing takes \u{2014} pick where the other takes go, "
                + "or place each cut by hand"),
        Row(group: .structure, keys: .chords([.extract]),
            words: "extract the selection into its own block"),
        Row(group: .structure, keys: .chords([.makeBlock]),
            words: "make a block from the selection"),
        Row(group: .structure, keys: .chords([.merge]),
            words: "merge blocks \u{2014} every take comes along"),
        Row(group: .structure, keys: .chords([.mergeWithCeremony]),
            words: "merge choosing takes \u{2014} bring every take, only the shown "
                + "ones, or pair them by hand"),
        Row(group: .structure, keys: .chords([.insertBlockBelow]),
            words: "new block below the one you're in (Write and Takes alike)"),
    ]

    private static let takes: [Row] = [
        Row(group: .takes, keys: .chords([.showTakes]),
            words: "open/close takes at the block you're in"),
        // ⎋ is not a menu key equivalent — Close All Takes says it in its verb.
        Row(group: .takes, keys: .gesture(["\u{238B}"], acts: [.closeAllTakes]),
            words: "close all takes \u{2014} back to the plain page"),
        Row(group: .takes, keys: .chords([.newTake]),
            words: "new take (starts as a copy of what's shown)"),
        Row(group: .takes, keys: .chords([.blankTake]),
            words: "new blank take (not chosen until you \u{2713} it)"),
        Row(group: .takes, keys: .chords([.blankTakeAsChosen]),
            words: "new blank take AND choose it \u{2014} the power gesture"),
        Row(group: .takes, keys: .chords([.chooseTake]),
            words: "choose the take you're in (the note shows it)"),
        Row(group: .takes, keys: .chords([.previousTake, .nextTake]),
            words: "step through a block's takes"),
        Row(group: .takes, keys: .chords([.archiveTake]),
            words: "archive the take you're in"),
        Row(group: .takes, keys: .chords([.saveChoicesAsLens]),
            words: "save current choices as a lens"),
        Row(group: .takes, keys: .chords([.pageFanBack, .pageFanForward]),
            words: "previous / next page of takes (on the Takes board)"),
        // 13e E6 (A21's clipboard half).
        Row(group: .takes, keys: .chords([.copyAllTakes]),
            words: "copy this block's takes \u{2014} the shown one, then its alternates "
                + "(\u{2318}C is still ordinary copy)"),
        // 13e batch 3 (A20/A21's second half): both lines name where the
        // ORIGINAL goes.
        Row(group: .takes, keys: .chords([.takeToBlockBelow]),
            words: "move the take you're in into its own block below \u{2014} the "
                + "original is archived on this block"),
        Row(group: .takes, keys: .chords([.takesToBlocks]),
            words: "turn ALL of this block's takes into blocks below it \u{2014} the "
                + "block keeps showing what it showed; the originals are archived on it"),
    ]

    // QoL batch 3 (L6): deliberately its own group, worded against ⌘K's row —
    // one searches the library, the other the note you are in.
    private static let find: [Row] = [
        Row(group: .find, keys: .chords([.findInPost]),
            words: "find text in the note you're in (the chosen takes)"),
        Row(group: .find, keys: .chords([.findAndReplace]),
            words: "find and replace in this note"),
        Row(group: .find, keys: .chords([.findNext, .findPrevious]),
            words: "next / previous match"),
        Row(group: .find, keys: .chords([.useSelectionForFind]),
            words: "search for whatever is selected"),
    ]

    private static let navigation: [Row] = [
        // 17y B2 (p): the BUILD's row — Canvas is Debug-only (the declaration
        // reads `PostMode`'s one seam).
        Row(group: .navigation, keys: .chords([.switchMode]),
            words: "note modes: " + PostMode.modeList()),
        Row(group: .navigation, keys: .chords([.findAnything]),
            words: "find anything \u{2014} notes, books, blocks, commands (not body text)"),
        Row(group: .navigation, keys: .chords([.newPost]),
            words: "new note"),
        // VX-570: the book's own "+ new note", from the keys.
        Row(group: .navigation, keys: .chords([.newNoteInBook]),
            words: "new note inside the book you have open \u{2014} the book's own "
                + "+ new note (an entry in a journal book; in a gathering, a note wearing what its "
                + "rule asks)"),
        // VX-563 (A-648-6): the step's keys are the registry's alternates.
        Row(group: .navigation, keys: .alternates([.previousNoteInBook, .nextNoteInBook]),
            words: "the note before / after the one you're reading, in a "
                + "book's Outline, Read or Book \u{2014} except while you're typing in text, where "
                + "they keep going to the start and the end"),
        Row(group: .navigation, keys: .chords([.todaysEntry]),
            words: "today's journal entry"),
        // 13n-c U4 — VX-157 (her ratified chord); VX-644: the label's door.
        Row(group: .navigation, keys: .chords([.switchWing]),
            words: "switch wing \u{2014} type a few letters and \u{23CE}, or hold \u{2318} "
                + "and tap L to step, release to go; clicking the wing's name in the "
                + "Bookcase or Library masthead steps to the next one"
                + ", and clicking \u{201C}in \u{2039}wing\u{203A}\u{201D} at the top of the sidebar "
                + "opens this switcher; every switch lands on that wing's Bookcase"),
        // VX-824 (the VX-828 run, batch B): the per-wing chord — the
        // registry's alternate (no menu item: the mode row owns ⌘1–⌘7 inside a
        // note), shown here so it is findable (13g L1).
        Row(group: .navigation, keys: .alternates([.goToWing]),
            words: "go to a wing by its place in the switcher (Home is \u{2318}1) and land on its "
                + "Bookcase \u{2014} whenever you're not in a note or writing in one; inside a note "
                + "these keys are its modes"),
        // VX-632 (her #245 RB-6 ruling): ⌘L's two ⌥ variants.
        Row(group: .navigation, keys: .chords([.moveNoteToWing]),
            words: "move the note or book you're in to another wing \u{2014} "
                + "type a few letters of the wing and \u{23CE}"),
        Row(group: .navigation, keys: .chords([.copyNoteToWing]),
            words: "copy the note you're in to another wing, the same way"),
        // The system's Settings item — no act declares it.
        Row(group: .navigation, keys: .gesture(["\u{2318},"], acts: []),
            words: "settings (voice, seams, takes options, tags)"),
        Row(group: .navigation, keys: .chords([.helper]),
            words: "this helper"),
    ]

    // 13g L1 (WT-1): the WORKSPACE — the keyless doors named by their MENU
    // PATH, because a door with no key is still a door.
    private static let windows: [Row] = [
        Row(group: .windows, keys: .chords([.openNote]),
            words: "jump to the 1st\u{2013}9th note in the sidebar's Open list"),
        // VX-287: her chord, and her reason for the landing.
        Row(group: .windows, keys: .chords([.closeNote]),
            words: "close the note you're in \u{2014} its row leaves the Open list and the "
                + "pane moves on to the next note, so pressing it again closes the next "
                + "(\u{2318}W still closes the window)"),
        Row(group: .windows, keys: .menu("View", .closeAllNotes),
            words: "empty the Open list \u{2014} also on any Open row's "
                + "right-click; the notes themselves are untouched"),
        Row(group: .windows, keys: .chords([.toggleSidebar]),
            words: "show or hide the sidebar (the leading toolbar button is the same door)"),
        // VX-329 U1 (P-VX329-U1-7 words).
        Row(group: .windows, keys: .chords([.lockLibraryNow]),
            words: "lock the library now \u{2014} in Castle, where it can lock; it closes and forgets its key "
                + "until you unlock it again"),
        // 13k round 2 (R2-1): the glyphs INTERPOLATED from the bar's own constants.
        Row(group: .windows, keys: .chords([.navigateBack, .navigateForward]),
            words: "back / forward, in the pane you're in \u{2014} the "
                + "\(ContextBarDoors.backGlyph) and \(ContextBarDoors.forwardGlyph) "
                + "on the context bar are the same two doors"),
        // VX-560 (A-439-12): the browser's keys — the registry's alternates.
        Row(group: .windows, keys: .alternates([.navigateBack, .navigateForward]),
            words: "back / forward too, like a browser \u{2014} anywhere except while you're typing "
                + "in text, where they keep going to the start and the end of the line"),
        // The Act 10 correction round (row 15).
        Row(group: .windows, keys: .chords([.tagNote]),
            words: "tag this note \u{2014} the field slides out in the masthead with the cursor "
                + "in it (the \u{FF03} beside the tag cards is the same door)"),
        Row(group: .windows, keys: .chords([.quickNote]),
            words: "the quick note \u{2014} a floating pad, from anywhere in Variorum"),
        // 13e E14 (W26): the SYSTEM chord, its own promise.
        Row(group: .windows, keys: .system(.quickNote),
            words: "the quick note from ANY app \u{2014} Variorum need not be in front "
                + "(the menu-bar \u{25FB} does the same with a click)"),
        // 13u3 UNIT C (her R-13u-4): the two keys INSIDE a capture box.
        // VX-572 (re-keyed): the keys alone in the chord column; where they
        // work leads the words.
        Row(group: .windows, keys: .gesture(["\u{23CE}", "\u{21E7}\u{23CE}"], acts: []),
            words: "in a capture box: \u{23CE} files what you have written \u{2014} the quick note keeps it and "
                + "closes; the new-note box on the Bookcase files it and opens it. "
                + "\u{21E7}\u{23CE} adds another paragraph instead, so a capture can be "
                + "as long as the thought is"),
        Row(group: .windows, keys: .menu("View", .openBeside),
            words: "put a second note beside this one (right-click a "
                + "note row for that note; the menu takes the most recent other one)"),
        Row(group: .windows, keys: .menu("View", .closeSplit),
            words: "fold the window back to one pane"),
        // File ▸ New Window is the system's item — no act declares it.
        Row(group: .windows, keys: .gesture(["File \u{25B8} New Window"], acts: [.openInNewWindow]),
            words: "a second full window; right-click a note row \u{25B8} "
                + "Open in New Window for a note on its own"),
        // The final round's finding 2: the right-click rows wear StarCopy.starRow;
        // ONLY the ⌘K act wears StarCopy.verb.
        Row(group: .windows, keys: .gesture(["right-click \u{25B8} \(StarCopy.starRow)"], acts: [.toggleStar]),
            words: "star a note or book \u{2014} the Starred "
                + "section sits at the sidebar's top; \u{2318}K's "
                + "\u{201C}\(StarCopy.verb)\u{201D} is the same act"),
    ]

    // 13g batch 7 (R6-1/R6-2): the doors that MOVED get their rows.
    private static let bars: [Row] = [
        Row(group: .bars, keys: .gesture(["tag cards (masthead)"], acts: [.tagNote]),
            words: "a note's tags live in the masthead's right edge "
                + "as coloured cards: the \u{FF03} (or \u{2318}\u{21E7}I) opens the tag "
                + "field with the cursor in it \u{2014} type a path (\u{201C}/\u{201D} nests), "
                + "\u{23CE} applies; \u{2715} on a card takes it off"),
        Row(group: .bars, keys: .gesture(["block \u{25BE} (bottom bar)"], acts: [
            .divide, .extract, .makeBlock, .merge, .insertBlockBelow, .deleteBlock,
        ]),
            words: "divide \u{B7} extract \u{B7} make block \u{B7} merge \u{B7} "
                + "\u{FF0B} new block below \u{B7} \u{2212} delete this block"),
        // 13s-b U4 round 2: Block History is the BLOCK's, beside commit.
        Row(group: .bars, keys: .gesture(["\(BlockHistoryPath.doorLabel) (bottom bar)"], acts: [.showBlockHistory]),
            words: "\(BlockHistoryPath.name), beside "
                + "commit: everything the block you're in has been \u{2014} each take's "
                + "commits, the takes it set aside or deleted, and the block it came out of"),
        // 13s-b U4 round 1 (MINOR-2): the menu's own doors, each from its constant.
        Row(group: .bars, keys: .gesture(["note \u{25BE} (bottom bar)"], acts: [
            .saveNoteVersion, .showNoteVersions, .splitEveryNewlineIntoBlocks, .sealPost, .deleteNote,
        ]),
            words: "\(VersionsPath.saveVerb.lowercased()) \u{B7} "
                + "\(VersionsPath.menuLabel.lowercased()) \u{B7} "
                + "\(SplitAtNewlinesCopy.noteDoor.lowercased()) \u{B7} seal / unseal \u{B7} "
                + "the note's date \u{B7} \(RecoveryCopy.deleteNoteTitle.lowercased())"),
    ]

    // 13n-c U4: every chord the MCP door answers to, together, in the order
    // she meets them.
    private static let mcp: [Row] = [
        Row(group: .mcp, keys: .chords([.mcpSettings]),
            words: "MCP settings \u{2014} opens at Waiting when a client's ask waits "
                + "for your answer"),
        // 13n-c U3 (the brief §4, D1): the share chord.
        Row(group: .mcp, keys: .chords([.mcpShareThisNote]),
            words: "share the note you're in with the client you granted last \u{2014} "
                + "until it disconnects if it's connected, else once (never always)"),
        // 13n-b U4 (AF-11 F-2): the offer door's keyboard road.
        Row(group: .mcp, keys: .chords([.showLastAIChange]),
            words: "show the AI's last change (what a connected client last wrote)"),
        // 13n-c O-4: the Edit menu's words in their PLACEHOLDER form.
        Row(group: .mcp, keys: .chords([.structuralUndo]),
            words: "undo a client's change \u{2014} the Edit menu names the client "
                + "(\u{201C}Undo \u{2039}name\u{203A}'s take\u{201D})"),
        // 13n-c U4 (arrival X) + Stage B (O-3): the mark is named by its ROLE.
        // VX-572 (re-keyed): "a small mark" in the chord column, where it is
        // in the words — the column never carries a sentence.
        Row(group: .mcp, keys: .gesture(["a small mark"], acts: [.mcpOpenAsk]),
            words: "beside a note, book or wing: a client's ask waits there \u{2014} "
                + "hover to see who and what, press to answer it (nothing ever pops up "
                + "by itself)"),
    ]
}

// MARK: - THE FILTER (her "I NEED the ability to search shortcuts")

/// **The helper's one filter rule** — pure, pinned (`ShortcutCatalogTests`).
///
/// - **At rest** every heading shows, and a group shows its rows only when
///   SHE opened it — collapsed by default (her "default to not being
///   expanded").
/// - **Searching** a word: the case- and accent-blind terms are ANDed over a
///   row's chords, its words, its heading and the VERBS of the acts it names
///   (the registry's own names — "callout" finds ⌥⌘C); matching rows show in
///   their groups, every such group OPEN (the search auto-expands); a group
///   with no match hides. A heading she folds while searching folds for this
///   query only.
/// - **Searching a chord by name** (PROVISIONAL P-572-3): "cmd shift d",
///   "opt cmd c", "⌘⇧D" pasted — a query made only of modifiers and at most
///   one key matches the chords with EXACTLY those modifiers and that key;
///   modifiers alone ("cmd") match every chord carrying them.
nonisolated enum ShortcutCatalogFilter {
    struct Section: Identifiable, Sendable {
        let group: ShortcutCatalog.Group
        /// The rows the open section shows: all of the group's at rest, the
        /// matches while searching.
        let rows: [ShortcutCatalog.Row]
        /// The group's whole count (the heading's "of N").
        let total: Int
        let isExpanded: Bool
        let isSearching: Bool
        var id: String { group.rawValue }
    }

    static func isSearching(_ query: String) -> Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func sections(
        _ rows: [ShortcutCatalog.Row] = ShortcutCatalog.rows,
        query: String,
        expanded: Set<ShortcutCatalog.Group>,
        searchCollapsed: Set<ShortcutCatalog.Group> = []
    ) -> [Section] {
        let searching = isSearching(query)
        let chord = searching ? ShortcutChord.query(query) : nil
        let terms = searching ? Self.terms(query) : []
        var out: [Section] = []
        for group in ShortcutCatalog.Group.allCases {
            let all = rows.filter { $0.group == group }
            guard !all.isEmpty else { continue }
            if !searching {
                out.append(Section(
                    group: group, rows: all, total: all.count,
                    isExpanded: expanded.contains(group), isSearching: false))
                continue
            }
            let hits = all.filter { row in
                if let chord { return chord.matchesAny(row.tokens) }
                return matches(row, terms: terms)
            }
            guard !hits.isEmpty else { continue }
            out.append(Section(
                group: group, rows: hits, total: all.count,
                isExpanded: !searchCollapsed.contains(group), isSearching: true))
        }
        return out
    }

    static func terms(_ query: String) -> [String] {
        fold(query).split(whereSeparator: \.isWhitespace).map(String.init)
    }

    /// Every term somewhere in the row's chords, words, heading or its acts'
    /// verbs (the registry's names).
    static func matches(_ row: ShortcutCatalog.Row, terms: [String]) -> Bool {
        let haystack = fold(
            ([row.keysText, row.words, row.group.title]
                + row.acts.map { CapabilityRegistry.capability($0).verb })
                .joined(separator: "\n"))
        return terms.allSatisfy { haystack.contains($0) }
    }

    static func fold(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}

/// **A chord, read** — its modifiers and its key (PROVISIONAL P-572-3: the
/// chord-by-name search). One reader for both sides: a row's token ("⇧⌥⌘T",
/// "⌘⇧1–9", "Tab") and the query she types ("shift opt cmd t").
nonisolated struct ShortcutChord: Equatable, Sendable {
    /// ⌃ ⌥ ⇧ ⌘, as a set — a label's order ("⌘⇧D" vs "⇧⌘G") never matters.
    var modifiers: Set<Character>
    /// The key, uppercased ("D", "⏎", "TAB", "1–9"); nil = modifiers only.
    var key: String?

    static let modifierGlyphs: Set<Character> = ["\u{2303}", "\u{2325}", "\u{21E7}", "\u{2318}"]

    /// The words she might type for a modifier.
    static let modifierWords: [String: Character] = [
        "cmd": "\u{2318}", "command": "\u{2318}",
        "shift": "\u{21E7}",
        "opt": "\u{2325}", "option": "\u{2325}", "alt": "\u{2325}",
        "ctrl": "\u{2303}", "control": "\u{2303}",
    ]

    /// The words she might type for a named key, as the labels spell it.
    static let keyWords: [String: String] = [
        "return": "\u{23CE}", "enter": "\u{23CE}",
        "esc": "\u{238B}", "escape": "\u{238B}",
        "tab": "TAB",
        "up": "\u{2191}", "down": "\u{2193}", "left": "\u{2190}", "right": "\u{2192}",
        "comma": ",", "slash": "/",
    ]

    /// A row's token, read: its leading modifier glyphs (any order), then the
    /// rest as the key. A token with no modifier reads with an empty set.
    static func token(_ token: String) -> ShortcutChord {
        var mods = Set<Character>()
        var rest = Substring(token)
        while let first = rest.first, modifierGlyphs.contains(first) {
            mods.insert(first)
            rest = rest.dropFirst()
        }
        let key = rest.isEmpty ? nil : rest.uppercased()
        return ShortcutChord(modifiers: mods, key: key)
    }

    /// The query, read as a chord — or nil when it is not one: every part
    /// must be a modifier (a word or a glyph) or the ONE key, and at least
    /// one modifier must be there (a lone "d" is a word search).
    static func query(_ query: String) -> ShortcutChord? {
        let parts = query.lowercased()
            .split { $0.isWhitespace || $0 == "+" }
            .map(String.init)
        guard !parts.isEmpty else { return nil }
        var mods = Set<Character>()
        var key: String?
        for part in parts {
            if let mod = modifierWords[part] {
                mods.insert(mod)
                continue
            }
            // Glyphs typed or pasted ("⌘⇧d", "⌥⌘"): the leading modifiers,
            // then (maybe) a key.
            var rest = Substring(part)
            var sawGlyph = false
            while let first = rest.first, modifierGlyphs.contains(first) {
                mods.insert(first)
                sawGlyph = true
                rest = rest.dropFirst()
            }
            if rest.isEmpty { continue }
            let candidate = keyWords[String(rest)] ?? (rest.count == 1 || sawGlyph ? rest.uppercased() : nil)
            guard let candidate, key == nil else { return nil }
            key = candidate
        }
        guard !mods.isEmpty else { return nil }
        return ShortcutChord(modifiers: mods, key: key)
    }

    /// Whether this QUERY chord names one of a row's tokens: modifiers alone
    /// match any token carrying them all; with a key, the modifiers must be
    /// exactly the token's and the key its own (a digit falls inside a
    /// "1–9" span — ⌘⇧1–9, the modes' ⌘1–7).
    func matchesAny(_ tokens: [String]) -> Bool {
        tokens.contains { matches(ShortcutChord.token($0)) }
    }

    func matches(_ token: ShortcutChord) -> Bool {
        guard !token.modifiers.isEmpty else { return false }
        guard let key else { return token.modifiers.isSuperset(of: modifiers) }
        guard token.modifiers == modifiers, let tokenKey = token.key else { return false }
        if tokenKey == key { return true }
        return Self.span(tokenKey, contains: key)
    }

    /// "1–9" contains "3" (an en-dash span of single digits).
    static func span(_ span: String, contains key: String) -> Bool {
        let ends = span.split(separator: "\u{2013}")
        guard ends.count == 2, let low = Int(ends[0]), let high = Int(ends[1]),
              let value = Int(key) else { return false }
        return (low...high).contains(value)
    }
}
