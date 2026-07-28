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

    private struct ShortcutGroup: Identifiable {
        let title: String
        let items: [(keys: String, does: String)]
        var id: String { title }
    }

    private static let groups: [ShortcutGroup] = [
        ShortcutGroup(title: "Takes", items: [
            ("⌘⇧T", "open/close takes at the block you're in"),
            ("⎋", "close all takes — back to the plain page"),
            ("⌘T", "new take (starts as a copy of what's shown)"),
            ("⌥⌘T", "new blank take (not chosen until you ✓ it)"),
            ("⇧⌥⌘T", "new blank take AND choose it — the power gesture"),
            ("⌘⏎", "choose the take you're in (the post shows it)"),
            ("⌃⌘← / ⌃⌘→", "step through a block's takes"),
            ("⌘⇧A", "archive the take you're in"),
            ("⌘⇧L", "save current choices as a lens"),
        ]),
        ShortcutGroup(title: "Writing", items: [
            ("⌘S", "commit — an immutable savepoint of the take you're in"),
            ("⌘Z", "text undo (typing only)"),
            ("⌥⌘Z", "structural undo (splits, merges, moves — never text)"),
            ("⌃⌘↑ / ⌃⌘↓", "jump to the previous / next block"),
            ("⌘⇧'", "the block's comments"),
            ("⌘⇧B", "toggle block seams (dotted lines between blocks)"),
        ]),
        ShortcutGroup(title: "Structure", items: [
            ("⌘⇧D", "divide the block at the cursor"),
            ("⌘⇧E", "extract the selection into its own block"),
            ("⌘⇧K", "make a block from the selection"),
            ("⌘⇧M", "merge blocks"),
            ("⌘⇧⏎", "new block below the one you're in (Write and Takes alike)"),
        ]),
        ShortcutGroup(title: "Navigation", items: [
            ("⌘1 – ⌘6", "post modes: Write · Takes · Lenses · Compare · Blocks · Canvas"),
            ("⌘K", "find anything — posts, books, blocks, commands"),
            ("⌘N", "new post"),
            ("⌘J", "today's journal entry"),
            ("⌘,", "settings (voice, seams, takes options, tags)"),
            ("⌘/", "this helper"),
        ]),
    ]

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

    private static let entries: [(term: String, definition: String)] = [
        ("block",
         "The atomic unit — a paragraph-sized piece of writing with permanent identity. "
         + "Nothing owns blocks; posts and books just point at them."),
        ("take",
         "One alternative text for a block. A block can hold many takes side by side — "
         + "the fan. Most blocks live with exactly one."),
        ("chosen",
         "The take the post actually uses. \"Chosen is what the post is.\" Everything "
         + "else is a way of looking. ✓ is the one gesture that moves it."),
        ("fan / bloom",
         "A block's set of takes (the fan); opening it on screen is a bloom. "
         + "⌘⇧T opens and closes; ⎋ closes them all."),
        ("lens",
         "A saved way of LOOKING at a post: for each block, which take to show. A lens "
         + "never changes the post — ✓ (adopt) and ⧉ (promote) are the only doors out. "
         + "Unnamed lenses (\"Lens 1\") are the ones you haven't kept yet."),
        ("arranging vs writing",
         "Two ways to start a lens column: ARRANGE picks among takes that already exist "
         + "(mints nothing); WRITE mints a fresh take on every block — a full rewrite "
         + "pass beside the original."),
        ("adopt (✓ make this the post)",
         "The post's chosen takes become what this lens/column shows. Adopting SWAPS, "
         + "never destroys: the old chosen is auto-saved as a lens named "
         + "\"chosen until <date>\", so you can always swap back."),
        ("promote (⧉ make this a post)",
         "A new post minted from a lens or column, linked to the original as a version. "
         + "\"Promote is the bridge\" from a way of looking to a thing of its own."),
        ("version",
         "A different POST related to this one. Two gestures share the word, and they do "
         + "different things: MARK AS VERSIONS is a CONNECTION ONLY — it draws a link "
         + "between two posts that already exist; nothing is copied, neither post changes; "
         + "the link just lets Compare pair them. DUPLICATE AS VERSION is a COPY — it mints "
         + "a whole new post (takes and all) and draws that same link in one gesture. "
         + "Rule of thumb: mark = connect, duplicate = copy + connect. UNMARK deletes only "
         + "the connection — both posts stay exactly as they are."),
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
         + "blocks — find them under Library → Archived & Deleted → Unplaced blocks, "
         + "or ⌥⌘Z brings everything straight back."),
        ("extract / make block",
         "Extract (⌘⇧E) pulls a selected span at a block's edge into its own block; "
         + "Make Block (⌘⇧K) does the same for a middle span. Both work from Takes — "
         + "select in your take, and the app carries the selection to Write and acts."),
        ("commit",
         "An immutable savepoint of one take (⌘S). Commits are append-only — "
         + "restoring one never erases another."),
        ("seal",
         "A post marked complete: everything under it refuses edits until unsealed. "
         + "Reversible; nothing is ever locked away for good."),
        ("seam",
         "The dotted line between blocks (⌘⇧B). Off by default — at rest a post reads "
         + "as seamless prose."),
        ("callout",
         "A block wearing a colored frame (Block ▸ Callout). Presentation only — "
         + "exports as a quote block; the text is untouched."),
        ("comment",
         "A working note on a BLOCK (never on a single take): \"take 1 is better but "
         + "take 2's ending…\". Margin cards by default; deleted comments stay "
         + "recoverable."),
        ("pool / scraps",
         "The Pool holds posts that belong to no book yet. Blocks (scraps) holds loose "
         + "pieces — drag one into a draft and it lands as a copy with lineage."),
        ("book / reading",
         "An ordered collection of posts (curated by hand, or smart — collected by "
         + "tags). A post can live in many books at once; membership is not ownership."),
        ("canvas",
         "A spatial VIEW on a post — arrange its blocks like sticky notes. The ‹ › "
         + "switcher just changes what a card shows; choosing is a separate, deliberate "
         + "gesture."),
    ]

    private var dictionaryTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Her ratified sentence — the map everything else hangs off.
                Text("Visible is what you're looking at; chosen is what the post is; "
                    + "a lens is a saved way of looking; a version is a different post.")
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
