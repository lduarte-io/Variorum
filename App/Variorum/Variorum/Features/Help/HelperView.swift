//
//  HelperView.swift
//  Variorum
//
//  Taste-checkpoint fix round (Sitting 9, R73/R91): "a little keyboard
//  shortcut helper … and a dictionary tab" — the legibility mandate's
//  concrete face (§14 item 11). Two tabs: SHORTCUTS (grouped, complete —
//  every shortcut is also a menu item, R93) and DICTIONARY (every word the
//  app uses, one or two plain sentences each, her ratified vocabulary
//  sentence at the top as the map). Reached via ⌘/, the Help menu, and the
//  "?" in the status bars (hover = the quick cheat sheet).
//

import SwiftUI
import VariorumCore

struct HelperView: View {
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        TabView {
            shortcutsTab
                .tabItem { Text("Shortcuts") }
            dictionaryTab
                .tabItem { Text("Dictionary") }
        }
        .frame(minWidth: 640, minHeight: 480)
        .background(tokens.surface)
    }

    // MARK: - Shortcuts

    struct ShortcutGroup: Identifiable {
        let title: String
        let items: [(keys: String, does: String)]
        var id: String { title }
    }

    /// **13g L1 (WT-1).** This list is HAND-MAINTAINED, and that is exactly
    /// how the whole 13f workspace shipped invisible: the registry declared
    /// every act (P-1 held), and no discoverability surface was extended, so
    /// ⌘⇧1–9, ⌘[ / ⌘], ⌘⇧I and ⌘⇧N — plus ⇧⌥⌘Z, ⌥⌘C and the take-page keys
    /// before them — existed and could not be found. Her report, verbatim:
    /// *"i don't even konw how to get to any of the things that built last
    /// phase."*
    ///
    /// It stays hand-maintained on purpose (the words are prose, in her
    /// voice — a generated list would read like a key table), and
    /// `HelperCoverageTests` is the drift guard that makes hand-maintenance
    /// safe: every `shortcutLabel` the registry declares must appear here,
    /// so an invisible shortcut is now a red test rather than a phase's
    /// silent omission. A row may pair keys with " / " — the guard splits
    /// on it and matches each token exactly.
    static let groups: [ShortcutGroup] = [
        ShortcutGroup(title: "Takes", items: [
            ("⌘⇧T", "open/close takes at the block you're in"),
            ("⎋", "close all takes — back to the plain page"),
            ("⌘T", "new take (starts as a copy of what's shown)"),
            ("⌥⌘T", "new blank take (not chosen until you ✓ it)"),
            ("⇧⌥⌘T", "new blank take AND choose it — the power gesture"),
            ("⌘⏎", "choose the take you're in (the note shows it)"),
            ("⌃⌘← / ⌃⌘→", "step through a block's takes"),
            ("⌘⇧A", "archive the take you're in"),
            ("⌘⇧L", "save current choices as a lens"),
            ("⌥⌘← / ⌥⌘→", "previous / next page of takes (on the Takes board)"),
        ]),
        ShortcutGroup(title: "Writing", items: [
            ("⌘S", "commit — an immutable savepoint of the take you're in"),
            ("⌘Z", "text undo (typing only)"),
            ("⌥⌘Z", "structural undo (splits, merges, moves — never text)"),
            ("⇧⌥⌘Z", "structural redo — puts back what ⌥⌘Z undid"),
            ("⌃⌘↑ / ⌃⌘↓", "jump to the previous / next block"),
            ("⌘⇧'", "the block's comments"),
            ("⌥⌘C", "callout frame on this block (again to remove it)"),
            ("⌘⇧B", "toggle block seams (dotted lines between blocks)"),
        ]),
        ShortcutGroup(title: "Structure", items: [
            ("⌘⇧D", "divide the block at the cursor"),
            ("⌘⇧E", "extract the selection into its own block"),
            ("⌘⇧K", "make a block from the selection"),
            ("⌘⇧M", "merge blocks"),
            ("⌘⇧⏎", "new block below the one you're in (Write and Takes alike)"),
        ]),
        // 13g batch 3 (L8): the formatting acts. The two chords her ruling
        // named, plus the five menu-first doors by their MENU PATH — the
        // group's framing line ("every shortcut here is also a menu item")
        // has to read both ways, and these are doors with no key.
        ShortcutGroup(title: "Formatting", items: [
            ("⌘B", "bold — wraps the selection in ** ** (again to take it off)"),
            ("⌘I", "italic — the same, with * *"),
            ("Format ▸ Strikethrough", "~~like this~~"),
            ("Format ▸ Inline Code", "`like this`"),
            ("Format ▸ Heading", "heading 1, 2 or 3 — the line gains #, ## or ###"),
            ("Format ▸ Bullet List", "the line becomes \"- item\""),
            ("Format ▸ Checklist", "the line becomes \"- [ ] item\" — click the box to tick it"),
            // 13g batch 4 (L10): the link act and BOTH of its click rules,
            // which differ by surface and so have to be written down.
            ("Format ▸ Add Link", "[text](address) around the selection, cursor in the "
                + "parentheses ready for the address"),
            ("⌘-click a link", "opens it — in a writing surface, where a plain click "
                + "places the cursor; in Read a plain click opens it"),
        ]),
        // QoL batch 3 (L6): the in-post find family. Deliberately its own
        // group and deliberately worded against ⌘K's row below — one searches
        // the library, the other searches the post you are in.
        ShortcutGroup(title: "Find in a note", items: [
            ("⌘F", "find text in the note you're in (the chosen takes)"),
            ("⌥⌘F", "find and replace in this note"),
            ("⌘G / ⇧⌘G", "next / previous match"),
            ("⌘E", "search for whatever is selected"),
        ]),
        ShortcutGroup(title: "Navigation", items: [
            ("⌘1–6", "note modes: Write · Takes · Lenses · Compare · Blocks · Canvas"),
            ("⌘K", "find anything — notes, books, blocks, commands (not body text)"),
            ("⌘N", "new note"),
            ("⌘J", "today's journal entry"),
            ("⌘,", "settings (voice, seams, takes options, tags)"),
            ("⌘/", "this helper"),
        ]),
        // 13g L1 (WT-1): the WORKSPACE — everything Phase 13f built, which
        // until now had no entry on any surface she could read. The rows
        // WITHOUT a chord are named by their MENU PATH, because the group's
        // framing line above ("every shortcut here is also a menu item")
        // means the reverse has to be findable too: a door with no key is
        // still a door, and this is where she looks for it.
        ShortcutGroup(title: "Windows & panes", items: [
            ("⌘⇧1–9", "jump to the 1st–9th note in the sidebar's Open list"),
            ("⌘[ / ⌘]", "back / forward, in the pane you're in"),
            ("⌘⇧I", "show or fold the context bar (← where you came from · the book it's in)"),
            ("⌘⇧N", "the quick note — a floating pad, from anywhere"),
            ("View ▸ Open Beside", "put a second note beside this one (right-click a "
                + "note row for that note; the menu takes the most recent other one)"),
            ("View ▸ Close Split", "fold the window back to one pane"),
            ("File ▸ New Window", "a second full window; right-click a note row ▸ "
                + "Open in New Window for a note on its own"),
            ("right-click ▸ \(StarCopy.verb)", "star a note or book — the Starred "
                + "section sits at the sidebar's top (up to five); \u{2318}K has the "
                + "same row"),
        ]),
        // 13g batch 7 (R6-1/R6-2): the two things that MOVED. Her round-1
        // finding was that a door which moves without a line here is a door
        // she cannot find — so the tag chips and the bar's two groups get
        // their rows the same day they ship.
        ShortcutGroup(title: "The note's bars", items: [
            ("tag cards (top bar)", "a note's tags live on the context bar as coloured "
                + "cards: \u{FF0B} adds one (type it — \u{201C}/\u{201D} nests), \u{2715} takes it "
                + "off. Folded (\u{2318}\u{21E7}I) they become one \u{FF03} door with the count"),
            ("block \u{25BE} (bottom bar)", "divide · extract · make block · merge · "
                + "\u{FF0B} new block below · \u{2212} delete this block"),
            ("note \u{25BE} (bottom bar)", "history (savepoints) · seal / unseal · the "
                + "note's date"),
        ]),
    ]

    /// The keys this helper actually shows, as single tokens — a row may
    /// pair two with `" / "`. The drift guard (13g L1) reads this.
    ///
    /// The separator is SPACE-slash-SPACE, not a bare slash: ⌘/ is itself a
    /// shortcut (this helper's own), and a bare split turned it into "⌘" and
    /// "" — caught by the guard on its first run, which is the guard doing
    /// its job on the way in.
    static var shortcutKeysShown: Set<String> {
        Set(groups.flatMap(\.items).flatMap { item in
            item.keys.components(separatedBy: " / ").map {
                $0.trimmingCharacters(in: .whitespaces)
            }
        })
    }

    private var shortcutsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Every shortcut here is also a menu item — the menus are the map.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                ForEach(Self.groups) { group in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.title.lowercased())
                            .font(tokens.small.weight(.bold))
                            .foregroundStyle(tokens.accent)
                        ForEach(group.items, id: \.keys) { item in
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                Text(item.keys)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(width: 130, alignment: .leading)
                                Text(item.does)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Dictionary (the app's words, in hers)

    /// Non-private for the same reason `groups` is: the drift pins read it
    /// (13g cold review R1-2 — a dictionary entry that teaches a landing
    /// the code no longer performs is the WT-1 class in prose form).
    static let entries: [(term: String, definition: String)] = [
        ("block",
         "The atomic unit — a paragraph-sized piece of writing with permanent identity. "
         + "Nothing owns blocks; notes and books just point at them."),
        ("take",
         "One alternative text for a block. A block can hold many takes side by side — "
         + "the fan. Most blocks live with exactly one."),
        ("chosen",
         "The take the note actually uses. \"Chosen is what the note is.\" Everything "
         + "else is a way of looking. ✓ is the one gesture that moves it."),
        ("fan / bloom",
         "A block's set of takes (the fan); opening it on screen is a bloom. "
         + "⌘⇧T opens and closes; ⎋ closes them all."),
        ("lens",
         "A saved way of LOOKING at a note: for each block, which take to show. A lens "
         + "never changes the note — ✓ (adopt) and ⧉ (promote) are the only doors out. "
         + "Unnamed lenses (\"Lens 1\") are the ones you haven't kept yet."),
        ("arranging vs writing",
         "Two ways to start a lens column: ARRANGE picks among takes that already exist "
         + "(mints nothing); WRITE mints a fresh take on every block — a full rewrite "
         + "pass beside the original."),
        ("adopt (✓ make this the note)",
         "The note's chosen takes become what this lens/column shows. Adopting SWAPS, "
         + "never destroys: the old chosen is auto-saved as a lens named "
         + "\"chosen until <date>\", so you can always swap back."),
        ("promote (⧉ make this a note)",
         "A new note minted from a lens or column, linked to the original as a version. "
         + "\"Promote is the bridge\" from a way of looking to a thing of its own."),
        ("version",
         "A different NOTE related to this one. Two gestures share the word, and they do "
         + "different things: MARK AS VERSIONS is a CONNECTION ONLY — it draws a link "
         + "between two notes that already exist; nothing is copied, neither note changes; "
         + "the link just lets Compare pair them. DUPLICATE AS VERSION is a COPY — it mints "
         + "a whole new note (takes and all) and draws that same link in one gesture. "
         + "Rule of thumb: mark = connect, duplicate = copy + connect. UNMARK deletes only "
         + "the connection — both notes stay exactly as they are."),
        ("divide / the take ceremony",
         "Divide cuts a block in two at your cursor (⌘⇧D — works from Takes too; the "
         + "app carries you to Write and cuts). When the block has SEVERAL takes, each "
         + "take needs its own cut — the \"Divide into takes\" sheet lists every take, "
         + "you place each cut, and confirm. Unchecked takes stay with the original; "
         + "⌥⌘Z puts everything back."),
        ("merge",
         "Join neighboring blocks into one (⌘⇧M): cursor at the seam, or a selection "
         + "across the run. From Takes it joins your block with the one above. The "
         + "merged text is what you were LOOKING at; other takes stay with the released "
         + "blocks — find them under \(RecoveryPath.unplacedBlocks), "
         + "or ⌥⌘Z brings everything straight back."),
        ("extract / make block",
         "Extract (⌘⇧E) pulls a selected span at a block's edge into its own block; "
         + "Make Block (⌘⇧K) does the same for a middle span. Both work from Takes — "
         + "select in your take, and the app carries the selection to Write and acts."),
        ("commit",
         "An immutable savepoint of one take (⌘S). Commits are append-only — "
         + "restoring one never erases another."),
        ("seal",
         "A note marked complete: everything under it refuses edits until unsealed. "
         + "Reversible; nothing is ever locked away for good."),
        ("seam",
         "The dotted line between blocks (⌘⇧B). Off by default — at rest a note reads "
         + "as seamless prose."),
        ("callout",
         "A block wearing a colored frame (Block ▸ Callout). Presentation only — "
         + "exports as a quote block; the text is untouched."),
        ("comment",
         "A working remark on a BLOCK (never on a single take): \"take 1 is better but "
         + "take 2's ending…\". Margin cards by default; deleted comments stay "
         + "recoverable."),
        ("pool / scraps",
         "The Pool holds notes that belong to no book yet. Snippets (scraps) holds loose "
         + "pieces — drag one into a draft and it lands as a copy with lineage."),
        ("book / reading",
         "An ordered collection of notes (curated by hand, or smart — collected by "
         + "tags). A note can live in many books at once; membership is not ownership."),
        // 13g batch 7 (R6-1): the word for the cards she asked for.
        ("tag",
         "A hierarchical label (life/goals/2024) applied to a note or a block — never a "
         + "place, so tagging moves nothing. On a note they show as coloured cards on "
         + "the context bar; \u{FF0B} adds, \u{2715} removes, and a tag keeps its colour "
         + "everywhere. Settings (\u{2318},) manages the whole taxonomy and can promote "
         + "a tag into a smart book."),
        // 13g batch 7 (R6-4): quick notes now file themselves.
        ("quicknote (the tag)",
         "Every quick note is tagged \u{201C}quicknote\u{201D}, and the smart book "
         + "\u{201C}Quicknotes\u{201D} collects the tag — so take the tag off and the note "
         + "leaves that book, because smart membership is just the tag."),
        ("canvas",
         "A spatial VIEW on a note — arrange its blocks like sticky notes. The ‹ › "
         + "switcher just changes what a card shows; choosing is a separate, deliberate "
         + "gesture."),
        // 13g L1 (WT-1): the 13f vocabulary. Her report was that she could
        // not find any of it — a word she cannot look up is a feature she
        // cannot ask for.
        ("pane / the split",
         "A window can show TWO notes side by side. Right-click a note row ▸ Open "
         + "Beside puts that note in a second pane; View ▸ Open Beside takes the most "
         + "recently opened other note. Drag the seam to resize; View ▸ Close Split "
         + "folds back to one. Only ONE pane is live at a time — the one you clicked "
         + "into is the one you type in, and the other reads quietly beside it. A "
         + "split never shows one note twice; for that, use Lenses or Compare."),
        ("window",
         "Two kinds. File ▸ New Window opens another FULL window — its own sidebar, "
         + "its own Open list, its own back trail. Right-click a note row ▸ Open in "
         + "New Window opens just that note, with no sidebar. Every window shows the "
         + "same store; the one you're in is the one that writes."),
        ("the Open list",
         "The sidebar's list of notes this window has open, in the order you opened "
         + "them — ⌘⇧1 through ⌘⇧9 jump to them. Drag rows to rearrange; ✕ closes a "
         + "ROW and nothing else (the note is untouched and comes back the next time "
         + "you open it)."),
        ("context bar",
         "The thin line above a pane saying where you are: ← where you came from, and "
         + "the book this note sits in (click it to open the book right at this note). "
         + "It starts folded to its two glyphs; ⌘⇧I — or the chevron — unfolds it."),
        ("star",
         "A shortcut to a note or a book, pinned at the sidebar's top under "
         + "\u{201C}\(StarCopy.sectionHeader)\u{201D}. Right-click anything ▸ "
         + "\(StarCopy.verb), or the same row in ⌘K. Up to five: stars are meant to be "
         + "the few things you're in right now, not a filing system."),
        // 13g batch 3 (L8/L9): the formatting vocabulary. Storage is
        // markdown-as-content (F-1), so the words she needs are the ones the
        // TEXT uses — not a set of hidden styles.
        ("markdown",
         "How formatting is STORED: as ordinary characters in your text. "
         + "**bold** is really two stars, a heading really starts with #. The "
         + "editor styles them and dims the markers, but what you see is "
         + "exactly what is saved — which is why an export is already "
         + "markdown, and why nothing about a formatted note is locked in."),
        ("checkbox",
         "A line starting \"- [ ] \" — a to-do. CLICK the box to tick it "
         + "(\"- [x] \"); that is an ordinary edit, so ⌘Z takes it back and a "
         + "sealed note refuses it. Format ▸ Checklist makes one from the "
         + "line you're on."),
        // 13g batch 4 (L10/L11): the link, and the one place the app shows
        // you something other than exactly what is stored.
        ("link",
         "Written in the text as [words](address) — Format \u{25B8} Add Link puts the "
         + "brackets around your selection. While you're WRITING you see the whole "
         + "thing and \u{2318}-click follows it (a plain click has to place the cursor). "
         + "In a book's READ mode there is nothing to type, so the markers are hidden, "
         + "the words read as a link, and a plain click opens it."),
        // 13g cold review R1-2: the landing changed at batch 7 (R6-4) and
        // this entry was the surface the sweep missed — it taught the Pool
        // while the pad's own placeholder already said Quicknotes.
        ("quick note",
         "A small floating pad for catching a thought — ⌘⇧N, File ▸ Quick Note, or the "
         + "✏︎ in the system menu bar (which reaches you from any app). Return makes a "
         + "new line, not a new note; closing it (or ⌘⏎) keeps what you wrote as a new "
         + "note, tagged \u{201C}quicknote\u{201D} — the smart Quicknotes book on the "
         + "shelf collects it, and taking the tag off sends it back to the Pool."),
    ]

    private var dictionaryTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Her ratified sentence — the map everything else hangs off.
                Text("Visible is what you're looking at; chosen is what the note is; "
                    + "a lens is a saved way of looking; a version is a different note.")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(tokens.accent)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(Self.entries, id: \.term) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.term)
                            .font(tokens.small.weight(.bold))
                        Text(entry.definition)
                            .font(.callout)
                            .foregroundStyle(tokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

enum HelperCheatSheet {
    /// The hover cheat sheet (the "?" buttons' tooltip) — the takes family
    /// in one glance; the full map lives in the helper (⌘/).
    static let summary = """
        ⌘⇧T open/close takes · ⎋ close all
        ⌘T new take · ⌥⌘T blank · ⇧⌥⌘T blank & choose
        ⌘⏎ choose · ⌃⌘←/→ step takes · ⌘⇧A archive
        ⌘⇧L save as lens · ⌘S commit · ⌘/ full list + dictionary
        """
}
