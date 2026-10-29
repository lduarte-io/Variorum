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
//  VX-572 (the VX-677 run, batch 4): the Shortcuts tab is `ShortcutsTab` —
//  searchable, folded headings — over `ShortcutCatalog`, the registry's list.
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
        #if DEBUG  // F-FW-2's pin door (`HelperViewOracle`): what this body drew in
        let _ = HelperViewOracle.drew(tokens, theme: themeStore)
        #endif
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

    /// **VX-572 (the VX-677 run, batch 4) — the tab renders FROM THE REGISTRY
    /// (P-1).** The rows, their order, their headings and every chord are
    /// `ShortcutCatalog`'s (`Registry/ShortcutCatalog.swift`): the words are
    /// still hers, kept verbatim, but a chord is READ from the declaration it
    /// names, never typed a second time — the hand-kept list (13g L1's) and
    /// its string-match guard are retired into the catalog and an ID-level
    /// registry walk (`ShortcutCatalogTests`). The face is `ShortcutsTab`.
    @State private var shortcuts = ShortcutsTabModel()

    struct ShortcutGroup: Identifiable {
        let title: String
        let items: [(keys: String, does: String)]
        var id: String { title }
    }

    /// The catalog as the older readers see it — Settings ▸ Shortcuts, its
    /// search, and the pins that read rows by their keys and words. A
    /// PROJECTION of `ShortcutCatalog`, never a second list: a row's `keys`
    /// is its chord column ("⌘G / ⇧⌘G"), read from the declarations.
    static var groups: [ShortcutGroup] {
        ShortcutCatalog.Group.allCases.map { group in
            ShortcutGroup(
                title: group.title,
                items: ShortcutCatalog.rows(in: group).map { (keys: $0.keysText, does: $0.words) })
        }
    }

    /// The keys this helper actually shows, as single tokens — each row's
    /// chord-column tokens (a pair is two). The drift guards read this.
    static var shortcutKeysShown: Set<String> {
        Set(ShortcutCatalog.rows.flatMap(\.tokens))
    }

    private var shortcutsTab: some View {
        ShortcutsTab(tokens: tokens, model: shortcuts)
    }

    // MARK: - Dictionary (the app's words, in hers)

    /// Non-private for the same reason `groups` is: the drift pins read it
    /// (13g cold review R1-2 — a dictionary entry that teaches a landing
    /// the code no longer performs is the WT-1 class in prose form).
    /// 17y B2 (p): the "canvas" entry teaches a Debug-only surface, so it is
    /// shown only where the BUILD has Canvas (`PostMode`'s one seam).
    static let entries: [(term: String, definition: String)] = allEntries.filter {
        $0.term != "canvas" || PostMode.buildKeepsCanvas
    }

    private static let allEntries: [(term: String, definition: String)] = [
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
        // VX-372 (P-C-1): the copy door by its new verbs ("Duplicate as
        // Version" retired as a label), read from the registry's source.
        ("version",
         "A different NOTE related to this one. Two gestures make one, and they do "
         + "different things: MARK AS VERSIONS is a CONNECTION ONLY — it draws a link "
         + "between two notes that already exist; nothing is copied, neither note changes; "
         + "the link just lets Compare pair them. \(DuplicateCopy.withTagsVerb.uppercased()) "
         + "is a COPY — it mints a whole new note (takes and all, wearing the note's tags, so "
         + "a book that collects one hears it) and draws that same link in one gesture; "
         + "\(DuplicateCopy.withoutTagsVerb.uppercased()) leaves the tags behind. "
         + "Rule of thumb: mark = connect, duplicate = copy + connect. UNMARK deletes only "
         + "the connection — both notes stay exactly as they are."),
        ("divide / divide choosing takes",
         "Divide cuts a block in two at your cursor (⌘⇧D — works in Takes too, right "
         + "where you are). When the block has SEVERAL takes, the take you're LOOKING "
         + "at is the one that gets cut, and every other take stays WHOLE on the first "
         + "block — nothing to hunt for afterwards. Want the takes somewhere else? "
         + "⌥⌘⇧D opens \"Divide choosing takes\", which asks first: keep the takes on "
         + "the top block, keep them on the bottom, copy them to both — or choose per "
         + "take, where you check the takes to cut and place each ✂ yourself "
         + "(unchecked takes stay with the original). Either way ⌥⌘Z puts everything "
         + "back."),
        ("merge",
         "Join neighboring blocks into one (⌘⇧M): cursor at the seam, or a selection "
         + "across the run. From Takes it joins your block with the one above. The "
         + "merged text is what you were LOOKING at on each side — and every OTHER take "
         + "comes along whole onto the merged block, so nothing goes missing (extra "
         + "copies are quick to delete). To choose instead — only the takes you were "
         + "looking at, or this take paired with that one — use ⌥⌘⇧M, Merge choosing "
         + "takes. Archived takes stay behind with "
         + "the released blocks; find them under \(TrayPath.originalsPathWithDoor), "
         + "or ⌥⌘Z brings everything straight back."),
        ("extract / make block",
         "Extract (⌘⇧E) pulls a selected span at a block's edge into its own block; "
         + "Make Block (⌘⇧K) does the same for a middle span. Both work from Takes — "
         + "select in your take, and the app carries the selection to Write and acts."),
        ("commit",
         // VX-347 (PROVISIONAL words, P-VX347-4): leaving the field commits.
         "An immutable saved moment of one take (⌘S). It can carry a NAME — ⌘S "
         + "offers a field, ⏎ saves it named or not, and so does any other way out "
         + "of the field but ⎋ — and the name is editable "
         + "afterwards from Block History. Commits are append-only: restoring "
         + "one never erases another, and a name never touches the text."),
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
        // 13i-d U6 (a): the ruled nouns (the sitting record §1 — "smart"
        // retired app-wide, §14); lesson 1's three kinds, said as a glossary.
        ("book / gathering",
         "A BOOK holds its notes as members \u{2014} your order, your chapters; a note can "
         + "live in many books at once, and membership is not ownership (an OWNED book is "
         + "the one place its notes live). A GATHERING is a saved rule of tags or \u{2605} "
         + "that shows every matching note and holds none of them."),
        // 13g batch 7 (R6-1): the word for the cards she asked for.
        ("tag",
         "A hierarchical label (life/goals/2024) applied to a note or a block — never a "
         + "place, so tagging moves nothing. On a note they show as coloured cards in "
         + "the masthead; \u{FF03} adds, \u{2715} removes, and a tag keeps its colour "
         + "everywhere. Settings (\u{2318},) manages the whole taxonomy and can make a "
         + "gathering from tags."),
        // 13g batch 7 (R6-4): quick notes now file themselves.
        ("quicknote (the tag)",
         // 13s-b U1b (R-13s-36/38): the entry NAMES the default gathering,
         // so it reads the one constant (the fresh default is lowercase).
         "Every quick note is tagged \u{201C}quicknote\u{201D}, and the gathering "
         + "\u{201C}\(Operations.defaultQuicknoteBookName)\u{201D} shows the tag \u{2014} so take the tag off and the "
         + "note leaves it, because a gathering is just its rule."),
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
         + "ROW (the note is untouched and comes back the next time you open it). "
         + "Closing the note you're in — its ✕, or ⌘⇧W — moves you on to the next one; "
         + "View ▸ Close All Notes empties the list."),
        ("context bar",
         "The thin line above a pane, always the same doors: ← back, the book "
         + "this note sits in (click to open that book right at this note; ⌘-click, or "
         + "a click when it's in several, lists them), and → forward. The note's tag "
         + "cards live in the masthead's right edge, with ＃ to add one. A door with "
         + "nowhere to go is greyed, not hidden — "
         + "the row never changes shape. ⌥⌘[ / ⌥⌘] and ⌘⇧I are the same doors on the "
         + "keyboard."),
        ("star",
         "A shortcut to a note or a book, pinned at the sidebar's top under "
         + "\u{201C}\(StarCopy.sectionHeader)\u{201D}. Right-click anything ▸ "
         + "\(StarCopy.starRow), or \u{2318}K's \u{201C}\(StarCopy.verb)\u{201D} — the "
         + "same act. Stars are meant to "
         + "be the things you're in right now, not a filing system."),
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
         "A small floating pad for catching a thought — ⌘⇧N, File ▸ Quick Note, the "
         + "✏︎ in the system menu bar, or \u{2303}\u{2325}\u{2318}N, which reaches you "
         // 13u3 UNIT C (her R-13u-4): this sentence taught the model the
         // ruling replaced — "Return makes a new line, not a new note".
         + "from any app without a click. \u{23CE} files what you wrote and closes the "
         + "pad; \u{21E7}\u{23CE} adds another paragraph, so a capture can hold as many "
         + "as the thought needs; closing it (or \u{2318}\u{23CE}) files it too. What you "
         + "wrote is kept as a new note, tagged \u{201C}quicknote\u{201D} \u{2014} the "
         + "\(Operations.defaultQuicknoteBookName) gathering shows it, and taking the tag off sends it back to the "
         + "Pool."),
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
    /// **VX-426 (A-439-17) — the bottom bars' "?" door's tooltip**: its NAME
    /// first (the registry's own words for the helper — "Shortcuts &
    /// Dictionary (⌘/)"), then the cheat sheet it always showed.
    static var doorHelp: String {
        CapabilityRegistry.capability(.helper).menuTitle() + "\n" + summary
    }

    static let summary = """
        ⌘⇧T open/close takes · ⎋ close all
        ⌘T new take · ⌥⌘T blank · ⇧⌥⌘T blank & choose
        ⌘⏎ choose · ⌃⌘←/→ step takes · ⌘⇧A archive
        ⌘⇧L save as lens · ⌘S commit (⏎ saves it unnamed) · ⌘/ full list
        """
}
