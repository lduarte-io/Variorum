//
//  EditorCommands.swift
//  Variorum
//
//  The menu bar (rewired Phase 13b, Stage 1b — P-1/P-2): items render FROM
//  the capability registry (titles = the declared verbs; enablement = the
//  declared availability over the router's live context) and route through
//  ShellActions → CommandRouter — never directly into a maybe-nil editor.
//  The three Stage 0 routing regimes are gone: no item is ever
//  enabled-but-void (the silent-⌘S class), no shortcut is a dead key where
//  its act can work (the D3 class — Takes/Lenses fire-and-DO), and an act
//  that can't work here is honestly grey. Structural undo stays DISTINCT
//  from command-Z (OverallModel §3) and reports through the StatusCenter
//  on every surface (N4).
//

import AppKit
import SwiftUI
import VariorumCore

struct EditorCommands: Commands {
    let bootstrap: AppBootstrap
    /// 13f batch 5b (W2/A26): the menu bar is attached to the SCENE, not to
    /// a window, so it cannot hold one window's router any more — it asks
    /// the registry which window is key. Every door below that touches a
    /// workspace (⌥⌘[, ⌥⌘], ⌘⇧1–9, Open Beside, Close Split, the context-bar
    /// fold) therefore acts on the window she is actually in.
    let windows: WindowRegistry
    /// 13r U2: the app's update channel (Sparkle). Only its door's
    /// rendering and enablement are read here; the act is the channel's.
    let updates: UpdateChannel
    /// 13x U2 row 6: the main scene's adoption-door presenter — File ▸
    /// Open Library… drives the same one flow the lobby faces do.
    let openDoor: LibraryOpenPresenter
    /// 13x F1 (ladder R1-MAJOR): the hand-off door's presenter — File ▸
    /// Send Library to Another Mac… (deliverable 1's menu face).
    let handOffDoor: LibraryHandOffPresenter
    /// 13n-b U4 (AF-11 F-2): the MCP door — "Show the AI's Last Change".
    let mcp: MCPDoor

    /// The key window's routing channel — nil only before any window has
    /// registered (the first frames), where every door is already disabled
    /// on `session == nil` or its registry gate.
    private var router: ShellRouter? { windows.activeRouter }

    private var session: AppSession? {
        if case .ready(let session) = bootstrap.state { return session }
        return nil
    }

    private var actions: ShellActions? {
        guard let session, let router else { return nil }
        return ShellActions(session: session, shell: router)
    }

    /// **The CREATION/palette acts' executor** (13f cold review, R1-3):
    /// ⌘N, ⌘J, the tutorial doors and ⌘K land on the window that can SHOW
    /// their result (`WindowRegistry.creationRouter()` — the
    /// `navigationTargetID` precedent, raised), never on a note-only or
    /// quick-note window's router, which has no consumer for a
    /// `pendingSelection` or a palette request. A method, not a property:
    /// `creationRouter()` raises, and only a chosen act may do that.
    private func creationActions() -> ShellActions? {
        guard let session, let router = windows.creationRouter() else { return nil }
        return ShellActions(session: session, shell: router)
    }

    /// The trio's honest grey: false only when NO full window exists —
    /// nothing could ever show the act's result there (P-2's letter; the
    /// note-only-key case stays ENABLED and lands via `creationActions()`).
    private var canReachCreationTarget: Bool {
        session != nil && windows.hasNavigationTarget
    }

    /// Registry-driven enablement (P-1: gating is data). Reads the
    /// router's observable context, so the menu tracks mode/editor/undo
    /// changes.
    private func enabled(_ id: CapabilityID) -> Bool {
        session?.commandRouter.isEnabled(id) ?? false
    }

    private func verb(_ id: CapabilityID) -> String {
        CapabilityRegistry.capability(id).verb
    }

    /// The menu bar's rendered capability set — asserted equal to the
    /// registry's menuBar door set by the registry walk test (declared ⇔
    /// rendered).
    static let menuRendered: [CapabilityID] = [
        .newPost, .todaysEntry, .findAnything, .commitTake,
        // 13x F1 (R1-MAJOR): the hand-off act's File door.
        .handOffLibrary,
        // The post-13l polish round (rows 16/23): ⌘⇧S, beside ⌘S in the File
        // menu — the two moments, one grain apart.
        .saveNoteVersion,
        // VX-372 (VX-383 U1 — D-C-2): the two duplicates, beside the version
        // door — a duplicate is a version you write on.
        .duplicateNoteWithTags, .duplicateNoteWithoutTags,
        .importFiles, .exportLibrary, .exportCaretBlock,
        .structuralUndo, .structuralRedo,
        // 13n-b U4: the offer door's keyboard road, beside its veto.
        .showLastAIChange,
        // 13n-c U3: ⌥⌘A — share the note you're in, beside the AI pair.
        .mcpShareThisNote,
        // 13n-c U4: ⌥⌘, — MCP Settings… (the app menu, under Settings…) and
        // ⌘L — Switch Wing… (the View menu, beside ⌘K).
        .mcpSettings, .switchWing,
        .divide, .extract, .makeBlock, .merge, .deleteInEveryTake,
        // 13j J4/J4b: the two ceremony doors, beside the verbs they used to
        // be the default of.
        .divideWithCeremony, .mergeWithCeremony,
        .addBlockAtEnd, .insertBlockBelow, .deleteBlock,
        // 13j (her round-7 ruling): block ARCHIVE — kept, no clock.
        .archiveBlock, .showTakes,
        .newTake, .blankTake, .blankTakeAsChosen, .chooseTake,
        .previousTake, .nextTake, .archiveTake, .saveChoicesAsLens,
        .closeAllTakes, .pageFanBack, .pageFanForward,
        // 13e E6 (A21): copy all takes.
        .copyAllTakes,
        // 13e batch 3 (A20/A21): the take↔block pair.
        .takeToBlockBelow, .takesToBlocks,
        .previousBlock, .nextBlock, .blockComments, .callout,
        .findInPost, .findAndReplace, .findNext, .findPrevious, .useSelectionForFind,
        // 13e E9: the find family's takes-aware sixth.
        .replaceAllInEveryTake,
        // 13g batch 3 (L8): the Format menu.
        .formatBold, .formatItalic, .formatStrikethrough, .formatCode,
        // 13g batch 4 (L10): the Add Link door.
        .formatAddLink,
        .formatHeading, .formatBulletList, .formatChecklist,
        // 13k K8: the nesting rows (Tab / ⇧Tab's menu twins).
        .formatIndent, .formatOutdent,
        .toggleSeams, .switchMode, .helper, .restoreTutorial,
        // 13s-b U1a, piece 5: Help ▸ Take the Tour.
        .takeTour,
        // pre-13u Act 10: the sample library's restore, beside the
        // tutorial's (the tenth-wave ruling). (Encryption Explained's left
        // at 13s-b U1b — R-13s-37: not restorable.)
        .restoreSampleLibrary,
        // 18l-c U6: the takemania book's restore, beside Sherlock's.
        .restoreJekyllBook,
        // 13s-b U1b (R-13s-37): the classics gathering's restore.
        .restoreClassicsGathering,
        // 13f batch 3 (W3/A27 + W16): the navigation core's menu doors.
        .openNote, .navigateBack, .navigateForward,
        // VX-287 / VX-289 (the VX-283 run): closing — ⌘⇧W and its sibling,
        // under the Open Notes submenu.
        .closeNote, .closeAllNotes,
        // 13f batch 4 (W1/A25): the split's.
        .openBeside, .closeSplit,
        // The Act 10 correction round (row 15): ⌘⇧I is TAG NOTE — the
        // masthead's inline field; the fold it used to toggle is retired.
        .tagNote,
        // 13f batch 6 (W5): the quick note's File-menu door.
        .quickNote,
        // The Act 10 correction round, batch A (row 2): the sidebar toggle,
        // ours now that the split view is.
        .toggleSidebar,
        // VX-309 U1c (VX-451): Lock Library Now, declared — the File menu's
        // item renders the registry's verb (the pane's Castle section is its
        // `.surface` twin).
        .lockLibraryNow,
    ]

    /// The SwiftUI key wiring per shortcut-labeled capability — the walk
    /// asserts every declared shortcut label has a mapping here (and only
    /// here: one place to collide).
    static func keyEquivalent(for id: CapabilityID) -> (KeyEquivalent, EventModifiers)? {
        switch id {
        case .newPost: ("n", .command)
        case .todaysEntry: ("j", .command)
        case .findAnything: ("k", .command)
        case .commitTake: ("s", .command)
        case .structuralUndo: ("z", [.command, .option])
        case .structuralRedo: ("z", [.command, .option, .shift])
        // 13n-b U4 (AF-11 F-2, ⌥⌘O approved subject to this sweep). THE
        // COLLISION SWEEP'S RESULT — ⌥⌘O is FREE:
        //   · this table: no `o` chord of any modifier set;
        //   · every `.keyboardShortcut(` call site in `Variorum/` and
        //     `Shared/`: no "o" at all (not even ⌘O — the app has no Open…);
        //   · every `NSMenuItem` keyEquivalent: none set;
        //   · the key overrides (`performKeyEquivalent`'s ⌘S + the ⌘Z/⌘⇧Z
        //     hint arm; the Tab/Return `keyDown` pair): no `o`;
        //   · the system's global chords (Spotlight ⌘Space, ⌥⌘Space, ⌥⌘D,
        //     ⌥⌘Esc, ⌥⌘H, ⌥⌘M, ⌥⌘W) and the Cocoa text system's default
        //     bindings: no ⌥⌘O (Finder's ⌥⌘O is Finder's own, app-scoped).
        case .showLastAIChange: ("o", [.command, .option])
        // 13n-c U3 (the VX-156 brief §4/§13; her round-2 nod to ⌥⌘A). THE
        // COLLISION SWEEP, RE-RUN AT THE TIP (2026-10-11, on `cbdef1fc`) —
        // ⌥⌘A is FREE:
        //   · this table: the only `a` chord is ⇧⌘A (Archive Take);
        //   · every `.keyboardShortcut(` call site in `Variorum/` and
        //     `Shared/`: the only "a" is that same ⇧⌘A (the Takes menu);
        //   · every `NSMenuItem` keyEquivalent: none set (all "");
        //   · the one `performKeyEquivalent` override (`EditorTextView` — ⌘S,
        //     plus the non-consuming ⌘Z/⇧⌘Z hint arm): no `a`;
        //   · the local key monitors (`PageTurnKeys` — unmodified ←/→;
        //     `CommentsPanel` — ⌘⏎, ⎋; `DivideWSheet` — refuses any ⌘/⌃
        //     event; `CalmAsks` — observes, never consumes): no ⌥⌘A;
        //   · the system hot key table (`GlobalHotKeyCenter.registered` =
        //     [.quickNote], ⇧⌘N) and the registry's declared labels: no ⌥⌘A;
        //   · the platform: ⌘A (Select All) is the system's; ⌥⌘A is not
        //     reserved by macOS (the brief §13's reserved list).
        case .mcpShareThisNote: ("a", [.command, .option])
        // 13n-c U4 (the VX-156 brief §6/§13; ⌥⌘, recommended and nodded at her
        // round 2; ⌘L her VX-157, "i like Command L"). THE COLLISION SWEEP,
        // RE-RUN AT THE TIP (2026-10-11, on `a41efc1b` — the U4 record's
        // sweep, verbatim in kind) — ⌥⌘, AND BARE ⌘L ARE FREE:
        //   · this table: the only `l` chord is ⇧⌘L (Save Choices as Lens); no
        //     `,` chord at all;
        //   · every `.keyboardShortcut(` call site in `Variorum/` and
        //     `Shared/`: `l` only as ⇧⌘L and ⌃⌘L (Lock Library Now); `,`
        //     nowhere (⌘, is SwiftUI's own Settings item, untouched);
        //   · every `NSMenuItem` keyEquivalent: none set (all "");
        //   · the overrides: `EditorTextView.performKeyEquivalent` (⌘S + the
        //     non-consuming ⌘Z/⇧⌘Z hint arm) and the `keyDown` trio (⇧⏎; the
        //     capture box's ⏎/⇧⏎; the flight's deferral) — no `l`, no `,`;
        //   · the local monitors: `PageTurnKeys` (unmodified ←/→),
        //     `CommentsPanel` (⌘⏎, ⎋), `DivideWSheet` (passes every ⌘/⌃
        //     event), `CalmAsks` / `ProtectionController` (observe only),
        //     `PressReporter` / `PaneFocusCatcher` (mouse) — and U4's own
        //     `WingSwitcherKeyCatcher`, which takes ⌘L ONLY in the switcher
        //     sheet's own window while it is up (the held-⌘ cycle);
        //   · the system hot keys ([.quickNote], ⌃⌥⌘N) and the registry's
        //     declared labels (⌘⇧L only): no ⌘L, no ⌥⌘,;
        //   · the platform: neither is reserved (the brief §13's list).
        case .mcpSettings: (",", [.command, .option])
        case .switchWing: ("l", .command)
        // 13d batch 4 (A14, her row verbatim: "⌘⇧Enter = new block").
        // ⌘⇧⏎ SUPERSEDES the 13b-4D ⌥⌘N: one act declares one key (P-1),
        // every shortcut is a menu item (R73/R91/R93), and the sweep found
        // ⌘⇧⏎ free. It reads beside A15: ⇧⏎ stays in the block, ⌘⇧⏎ makes
        // a new one — the Enter-flavoured pair her intake describes.
        case .insertBlockBelow: (.return, [.command, .shift])
        case .divide: ("d", [.command, .shift])
        case .extract: ("e", [.command, .shift])
        case .makeBlock: ("k", [.command, .shift])
        case .merge: ("m", [.command, .shift])
        // 13j J4/J4b (her sitting round-4 ruling: the plain chord + ⌥, "the
        // same 'deliberate variant' modifier the ⌥⌘Z family carries").
        // THE COLLISION SWEEP'S RESULT: ⌥⌘⇧D and ⌥⌘⇧M are FREE — swept
        // across this table, every `.keyboardShortcut(` call site in
        // `Variorum/` and `Shared/`, every `NSMenuItem` keyEquivalent (there
        // are none) and the one `performKeyEquivalent` override (⌘S, plus
        // J7's non-consuming ⌘Z/⌘⇧Z hint arm). No `d` or `m` chord anywhere
        // in the app carries ⌥; the only ones are ⌘⇧D and ⌘⇧M themselves.
        case .divideWithCeremony: ("d", [.command, .option, .shift])
        case .mergeWithCeremony: ("m", [.command, .option, .shift])
        case .showTakes: ("t", [.command, .shift])
        case .newTake: ("t", .command)
        case .blankTake: ("t", [.command, .option])
        case .blankTakeAsChosen: ("t", [.command, .option, .shift])
        case .chooseTake: (.return, .command)
        case .previousTake: (.leftArrow, [.command, .control])
        case .nextTake: (.rightArrow, [.command, .control])
        case .archiveTake: ("a", [.command, .shift])
        // 13e E6 (A21's clipboard half). THE COLLISION SWEEP'S RESULT: ⌘⇧C is
        // FREE — no `c` chord is bound anywhere in the app but ⌥⌘C (callout),
        // swept across this table, every `keyboardShortcut(` call site in
        // `Variorum/` and `Shared/`, every `NSMenuItem` keyEquivalent (all
        // empty strings) and both key overrides (⌘S; the Tab/Return pair).
        // ⌘C is the system's Copy and stays untouched.
        case .copyAllTakes: ("c", [.command, .shift])
        // 13e batch 3 (A20/A21). THE COLLISION SWEEP'S RESULT: the Return
        // family's only bound chords are ⌘⏎ (Choose Take) and ⌘⇧⏎ (New Block
        // Below) — the same five places swept as ⌘⇧C was. ⌥⌘⏎ and ⇧⌥⌘⏎ are
        // free, and they read as that family's other two members.
        case .takeToBlockBelow: (.return, [.command, .option])
        case .takesToBlocks: (.return, [.command, .option, .shift])
        case .saveChoicesAsLens: ("l", [.command, .shift])
        case .pageFanBack: (.leftArrow, [.command, .option])
        case .pageFanForward: (.rightArrow, [.command, .option])
        case .previousBlock: (.upArrow, [.command, .control])
        case .nextBlock: (.downArrow, [.command, .control])
        case .blockComments: ("'", [.command, .shift])
        // 13c R2-2 (A13(a)'s second half): the shortcut is the TOGGLE —
        // a frame is one thing you either have or don't, and a colour
        // submenu could never be a key.
        case .callout: ("c", [.command, .option])
        case .toggleSeams: ("b", [.command, .shift])
        // QoL batch 3 (L6): the standard Find family, whole. The collision
        // sweep over every `keyboardShortcut(` in the app found all five free
        // (nearest neighbours: ⌘⇧E extract, ⌘K find anything, ⌘⇧K make block).
        case .findInPost: ("f", .command)
        case .findAndReplace: ("f", [.command, .option])
        case .findNext: ("g", .command)
        case .findPrevious: ("g", [.command, .shift])
        case .useSelectionForFind: ("e", .command)
        // 13g batch 3 (L8). THE COLLISION SWEEP'S RESULT: ⌘B and ⌘I are FREE
        // (the same five places swept as ⌘[/⌘], ⌘⇧I and ⌘⇧N were, plus the
        // one `keyDown` override). They are the platform's own emphasis keys,
        // and their shifted neighbours — ⌘⇧B block seams, ⌘⇧I context bar —
        // read as the heavier gesture on the same letter rather than against
        // it. The other five formatting acts ship menu-first (see the
        // registry's declaration comment for why).
        case .formatBold: ("b", .command)
        case .formatItalic: ("i", .command)
        // The post-13l polish round (rows 16/23). THE COLLISION SWEEP'S
        // RESULT: ⌘⇧S is FREE — the only `s` chord anywhere in the app is
        // ⌘S itself (swept across this table, every `.keyboardShortcut(` call
        // site in `Variorum/` and `Shared/`, every `NSMenuItem` keyEquivalent
        // and the one `performKeyEquivalent` override). It is the platform's
        // own save-as chord, which is exactly what saving a whole moment is.
        case .saveNoteVersion: ("s", [.command, .shift])
        case .helper: ("/", .command)
        // 13f batch 3 (W16) minted ⌘[ / ⌘] here, on the stated reason that
        // *"they are the platform's own back/forward idiom"* — which the
        // 13u4 UNIT S1 audit measured as true of navigation CHROME (Finder,
        // Safari) and false of the app category this app is in: ⌘[ / ⌘] are
        // **outdent / indent** in Apple Notes, Pages, Xcode and VS Code, and
        // no HIG rule names them either way. Her item 5 is that collision,
        // felt: *"command [ is moving me between my different open notes ?
        // … I thought it unindented things."*
        //
        // **13u4 UNIT S1 — the chords swap, PROVISIONAL (QUESTIONS #130),
        // on Apple Notes' OWN resolution of the same collision:** plain
        // brackets change the list level, ⌥ brackets navigate. THE
        // COLLISION SWEEP'S RESULT: ⌥⌘[ and ⌥⌘] are FREE — swept across
        // this table, every `.keyboardShortcut(` call site in `Variorum/`
        // and `Shared/` (the only bracket chords in the app were the two
        // below), every `NSMenuItem` keyEquivalent (all empty strings) and
        // both `performKeyEquivalent` overrides (⌘S; J7's non-consuming
        // ⌘Z/⌘⇧Z hint arm). No bracket anywhere carries ⌥.
        case .navigateBack: ("[", [.command, .option])
        case .navigateForward: ("]", [.command, .option])
        // VX-287 (the VX-283 run) — her ruling: *"can we do shift command W? i
        // like that better than control, it's more natural to type."* ⌘W is
        // NOT ours (the system's File ▸ Close — it still closes the window).
        // THE COLLISION SWEEP'S RESULT is in the registry row and the U1
        // record's P0: ⌘⇧W is free across this table, every
        // `.keyboardShortcut(` call site, every `NSMenuItem` keyEquivalent, the
        // key overrides and the local monitors.
        case .closeNote: ("w", [.command, .shift])
        // 13k K8's pair, keyed at 13u4 UNIT S1. ⇥ / ⇧⇥ remain the primary
        // door and are deliberately NOT menu key equivalents (binding ⇥
        // would take Tab from every control in the app); these are the
        // menu's own keys, so the act is findable at all.
        case .formatOutdent: ("[", .command)
        case .formatIndent: ("]", .command)
        // 13f batch 5 (W20 b) minted ⌘⇧I (the sweep found it free); 13k K12
        // repointed it at the tag cards' fold; the Act 10 correction round
        // (row 15) repoints it once more, at the act itself — the masthead's
        // inline tag field. Same chord, same collision sweep.
        case .tagNote: ("i", [.command, .shift])
        // 13f batch 6 (W5). THE COLLISION SWEEP'S RESULT: ⌘⇧N is FREE (the
        // same five places swept as ⌘[/⌘] and ⌘⇧I were). It reads beside
        // its neighbour rather than against it: ⌘N makes a note, ⌘⇧N pops
        // the quick-note pad.
        case .quickNote: ("n", [.command, .shift])
        // The Act 10 correction round, batch A (row 2). THE COLLISION
        // SWEEP'S RESULT: ⌃⌘S is FREE (see the registry row) — and it is the
        // platform's own Toggle Sidebar chord.
        case .toggleSidebar: ("s", [.command, .control])
        // VX-329 U1 — P-VX309-U1c-4 (b): Lock Library Now's chord, declared. The collision sweep is the File menu call
        // site's own (⌃⌘L is free: the `l` chords are ⌘L Switch Wing and ⌘⇧L Save Choices as Lens; ⌃⌘Q, the system's
        // Lock Screen, untouched) — re-run at this tip: this table and every `.keyboardShortcut(` call site carry no
        // other ⌃⌘L.
        case .lockLibraryNow: ("l", [.command, .control])
        case .switchMode: nil  // ⌘1–⌘6, wired per mode below
        case .openNote: nil  // ⌘⇧1–⌘⇧9, wired per ordinal below
        default: nil
        }
    }

    /// ⌥⌘A's act: the mounted detail's note, the door's derivation, and THE
    /// grant sheet in the key window when the chord cannot guess.
    private func shareThisNote() {
        guard let session else { return }
        guard let postID = session.commandRouter.activePostID else {
            session.status.refuse(CapabilityRegistry.capability(.mcpShareThisNote).unavailableNote)
            return
        }
        let windows = windows
        Task { @MainActor in
            await mcp.shareThisNote(postID) { opening in
                windows.activeRouter?.mcpGrantRequest = opening
            }
        }
    }

    var body: some Commands {
        // 13s-b U1a, piece 4 (R-13s-24/25 — the logo's About placement, Q19
        // closed): the app menu's About item opens OUR window, which carries
        // the mark and the lowercase serif wordmark the system panel cannot
        // set (`AboutView`). UNDECLARED in the capability registry, on the
        // Check for Updates / Lock Library Now / New Window precedent below:
        // an app-menu standard with no block/take/post/book scope — the same
        // door the system drew, now ours.
        CommandGroup(replacing: .appInfo) {
            Button(AboutCopy.menuTitle) { openWindow(id: AboutCopy.windowID) }
        }
        // VX-220 (her word, 2026-10-13 — the app menu's Services submenu is
        // clutter: "open in finder, change to chinese, system trace, etc."):
        // Variorum registers no services of its own (no `NSServices` in its
        // Info.plist), so every entry there was another app's provider. The
        // placement stays and is EMPTY — which drops the submenu while MCP
        // Settings…'s `before: .systemServices` anchor below keeps working.
        // PROVISIONAL (the run's brief): in every configuration — a Debug-only
        // keep would be one `#if !DEBUG` around this group.
        CommandGroup(replacing: .systemServices) {}
        // 13r U2 — Variorum ▸ Check for Updates…, under About: the platform's
        // own place for this act. UNDECLARED in the capability registry, on
        // the Lock Library Now / New Window precedent. It is an app-menu
        // standard, conditionally rendered and app-scoped, and has no
        // block/take/post/book scope or mode rule to declare. P-2 holds: the
        // door renders ONLY where it can act (a live channel, so never in
        // DEBUG — R-13r-7), and it greys while Sparkle already runs a session.
        CommandGroup(after: .appInfo) {
            if updates.isLive {
                Button(UpdateChannel.checkForUpdatesTitle) { updates.checkForUpdates() }
                    .disabled(!updates.canCheckNow)
            }
        }
        // 13n-c U4 — ⌥⌘, "MCP Settings…" (the VX-156 brief §6, mockup §5):
        // under Settings…, Settings opened at MCP — at its Waiting list when
        // an ask waits (`MCPDoor.requestSettings`, adopted by Settings and
        // answered by the pane). Always acts: the pane is always there.
        // 13n-c UX walk W-UX-18 (T-2): `after: .appSettings` drew it ABOVE
        // Settings… (the Settings scene's item is not in that group on this
        // macOS — AX read in both walks); before the Services group puts it
        // BELOW Settings…, where U4's brief placed it.
        CommandGroup(before: .systemServices) {
            Button(verb(.mcpSettings)) {
                mcp.requestSettings()
                openSettings()
            }
            .keyboardShortcut(",", modifiers: [.command, .option])
            // (Its own `Divider()` stood here so it never read as part of
            // Services below — retired with Services at VX-220, vx-184's OK:
            // the system's group separator already sets Hide… apart, and the
            // two side by side were a doubled separator in the menu model.)
        }
        // Phase 13 (B2): ⌘N = New Post (R41) + the dated home's shortcut.
        CommandGroup(replacing: .newItem) {
            // 13f cold review R1-3: the creation acts land on the window
            // that can SHOW what they mint (raised) — with a note-only or
            // quick-note window key, `actions` used to mint into a router
            // nobody watches (a silent store write behind an enabled key).
            Button(verb(.newPost)) { creationActions()?.newPost() }
                .keyboardShortcut("n", modifiers: .command)
                .disabled(!canReachCreationTarget)
            Button(verb(.todaysEntry)) { creationActions()?.todaysEntry() }
                .keyboardShortcut("j", modifiers: .command)
                .disabled(!canReachCreationTarget)
            Divider()
            // 13x U2 row 6 (QB) — *File ▸ Open Library…*: the adoption
            // door's menu home. UNDECLARED like New Window (a standard
            // File item; nothing in the registry duplicates it) and with
            // NO key equivalent for the same recorded reason (inventing a
            // chord owes a collision sweep no ruling asked for). Enabled
            // at `.ready` only — the lobby faces carry their own doors
            // (P-2), and the flow's teardown needs the composed root.
            Button(LibraryOpenCopy.openLibraryDoor) {
                openDoor.openPanel(bootstrap: bootstrap)
            }
            .disabled(session == nil)
            // 13x F1 (ladder R1-MAJOR; the 13x row's deliverable 1) — the
            // HAND-OFF ACT's menu face: the travelling folder pair (QC),
            // produced where she can find and AirDrop it, revealed in
            // Finder. DECLARED (`.handOffLibrary` — the registry walk's
            // letter; the Open Library… sibling above stays the undeclared
            // standard-item class it was recorded as). Enabled at `.ready`
            // only: the producer's input is the OPEN keyed store.
            Button(verb(.handOffLibrary)) {
                handOffDoor.openPanel(session: session, bootstrap: bootstrap)
            }
            .disabled(session == nil)
            Divider()
            // 13f batch 5b (W2/A26) — File ▸ New Window, the full-app kind.
            //
            // The architect's ruling (e) is that this rides `WindowGroup`'s
            // system-standard item, undeclared. **MEASURED at build time
            // (macOS 26.5.2, the running Debug app's File menu enumerated
            // through System Events): that item is NOT there** — this very
            // group is `replacing: .newItem`, which is the group SwiftUI
            // places its automatic New Window item in, and ⌘N was taken for
            // New Post here since R41. So the standard item is restored
            // explicitly, in the place it belongs, and still UNDECLARED —
            // the ruled reason (nothing in the registry duplicates a
            // standard File item) is honored exactly. No key equivalent:
            // ⌘N is New Post's, and inventing a chord would owe a collision
            // sweep no ruling asked for (batch 4's precedent).
            Button("New Window") { openWindow(id: Self.mainWindowGroupID) }
                .disabled(session == nil)
            // 13f batch 6 (W5) — the quick note's File-menu door, one of the
            // three her round-14.1 ruling names (the menu-bar extra and
            // ⌘⇧N are the others). ONE declaration renders all three.
            // 13e E14: through the ONE summon line the other three doors use.
            Button(verb(.quickNote)) { QuickNoteSummon.summon { openWindow(id: $0) } }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .disabled(session == nil)
        }
        // ⌘K (R15, ratified): find anything — posts, books, commands.
        // 13f cold review R1-3: the palette opens in the window that HAS
        // one (raised) — a note-only or quick-note window's router had no
        // palette to open, so ⌘K there was an enabled dead key.
        CommandGroup(after: .sidebar) {
            // The Act 10 correction round, batch A (row 2): the sidebar is
            // ours (`ShellSplit`), so its toggle is a declared door here, on
            // the platform's own chord, grey while a note-only window is key
            // (nothing there has a sidebar to show). 18o U1 (17e (12)): that
            // grey is the REGISTRY's answer now (`.toggleSidebar` declares the
            // key window's kind), never re-derived here.
            Button(verb(.toggleSidebar)) { windows.activeRouter?.sidebarShown.toggle() }
                .keyboardShortcut("s", modifiers: [.command, .control])
                .disabled(!enabled(.toggleSidebar))
            Button(verb(.findAnything)) { windows.creationRouter()?.paletteRequested = true }
                .keyboardShortcut("k", modifiers: .command)
                .disabled(!canReachCreationTarget)
            // 13n-c U4 — ⌘L, THE WING SWITCHER (VX-157): ⌘K's twin in
            // where it opens (the window that can show it, raised) and how
            // (a request the window adopts). While the switcher is up, a
            // held-⌘ L is the switcher's own (its monitor cycles it); a
            // request that reaches the window anyway cycles too.
            // 13n-c Stage B R1 B6: grey with ONE wing (the registry's answer —
            // P-2: the switcher could only close).
            // 13n-c UX walk W-UX-6: grey with one wing (her ruling), but never
            // silent — ⌘L then SPEAKS the note (`OneWingChord`, the app's
            // monitor). The grey item itself carries no help: macOS draws no
            // tooltip on a disabled menu item (the verify leg's finding), so a
            // `.help` here was dead and is gone (UX-fix ladder UXR1-5).
            Button(verb(.switchWing)) { windows.creationRouter()?.wingSwitcherRequested = true }
                .keyboardShortcut("l", modifiers: .command)
                .disabled(!canReachCreationTarget || !enabled(.switchWing))
        }
        // Row 67 (the Act 10 correction round): this group was anchored
        // `after: .saveItem` — and a non-document WindowGroup's File menu
        // carries NO save anchor on macOS 26, so the whole group rendered in
        // NO menu: no Commit/Save-a-Version/Lock items anywhere, ⌘⇧S dead
        // app-wide (the note ▾ menu door worked; the chord did nothing), and
        // ⌘S surviving only through the editor's own performKeyEquivalent
        // override (Write mode only). Measured by AX menu enumeration before
        // and after — a unit pin cannot reach the app's main menu (the test
        // host owns its own), so the walk's listing is the evidence.
        // `.newItem` is an anchor this scene really has (the group above
        // replaces it), and File's save items belong right after creation.
        CommandGroup(after: .newItem) {
            // N5 (13b 1b): ⌘S acts wherever advertised — the mounted
            // surface commits its focused/caret take; where truly nothing
            // can commit, the item is honestly grey (it used to be an
            // always-enabled call into a nil editor).
            Button(verb(.commitTake)) { actions?.commitTake() }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(!enabled(.commitTake))
            // The post-13l polish round (ledger rows 16/23) — **⌘⇧S, the
            // whole-note version door.** The Mac's save-as chord, semantically
            // exact, beside ⌘S's take-commit; the collision sweep at the
            // kickoff found it free (the only `s` chord in the app is ⌘S).
            Button(verb(.saveNoteVersion)) { actions?.saveNoteVersion() }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                .disabled(!enabled(.saveNoteVersion))
            // VX-372 (VX-383 U1 — D-C-2): her two duplicate doors, beside the
            // version door, on the note on screen (no chord — none asked).
            Button(verb(.duplicateNoteWithTags)) { actions?.duplicateNote(tags: .applied) }
                .disabled(!enabled(.duplicateNoteWithTags))
            Button(verb(.duplicateNoteWithoutTags)) { actions?.duplicateNote(tags: .none) }
                .disabled(!enabled(.duplicateNoteWithoutTags))
            // Phase 13p Batch 2 — the manual Lock Now act (THE DESIGN:
            // demanded modes ONLY; under Auto the key auto-releases at the
            // next open, so a lock there is theater and no theater ships,
            // R13p-14). P-2: the door renders only where it acts.
            // COLLISION SWEEP: ⌃⌘L is free — the other `l` chords are ⌘L
            // (Switch Wing) and ⌘⇧L (Save Choices as Lens); ⌃⌘Q (the
            // system's own Lock Screen) is untouched.
            if bootstrap.canLock {
                Divider()
                Button(verb(.lockLibraryNow)) {
                    Task { await bootstrap.lock() }
                }
                .keyboardShortcut("l", modifiers: [.command, .control])
            }
        }
        // Phase 11b (B1): the File-menu export doors.
        CommandGroup(after: .importExport) {
            Button(verb(.importFiles)) { actions?.importFiles() }
                .disabled(session == nil)
            Divider()
            Button(verb(.exportLibrary)) { actions?.exportLibrary() }
                .disabled(session == nil)
            // Round-1 MINOR-3: the ONE enablement idiom (the registry) —
            // attachment-level; a caret outside any block speaks in
            // ShellActions instead of silently returning.
            Button(verb(.exportCaretBlock)) { actions?.exportCaretBlock() }
                .disabled(!enabled(.exportCaretBlock))
        }
        CommandGroup(after: .undoRedo) {
            // Per-op labels (Phase 9); N4 (13b 1b): the outcome reports
            // through the StatusCenter — visible on EVERY surface, never
            // into a nil editor.
            Button(Self.undoMenuTitle(for: session?.undoMenuState.topLabel)) {
                actions?.structuralUndo()
            }
            .keyboardShortcut("z", modifiers: [.command, .option])
            .disabled(session?.undoMenuState.topLabel == nil)
            // 13c 1B (A10): the redo half, right beside its undo — same
            // per-op labelling, same mode-independent reporting. Distinct
            // from ⌘⇧Z (NSTextView's text redo): the two stacks never
            // interleave, so their doors never share a key either.
            Button(Self.redoMenuTitle(for: session?.undoMenuState.topRedoLabel)) {
                actions?.structuralRedo()
            }
            .keyboardShortcut("z", modifiers: [.command, .option, .shift])
            .disabled(session?.undoMenuState.topRedoLabel == nil)
            // 13n-b U4 (R-13nb-23 (a), AF-11 F-2): the offer door's keyboard
            // road — the AI's most recent change this session, shown.
            Button(verb(.showLastAIChange)) { mcp.showLastChange() }
                .keyboardShortcut("o", modifiers: [.command, .option])
                .disabled(!enabled(.showLastAIChange))
            // 13n-c U3 — ⌥⌘A (the VX-156 brief §4, D1): share the note you're
            // in with the client you granted last, at that rung — while
            // connected if it is connected, else once; never always by a key.
            // VX-272: rendered ONLY while an approved client exists (no
            // door, never a dead one — the zero-state is Settings ▸ MCP's).
            if mcp.hasApprovedClient {
                Button(verb(.mcpShareThisNote)) { shareThisNote() }
                    .keyboardShortcut("a", modifiers: [.command, .option])
                    .disabled(!enabled(.mcpShareThisNote))
            }
        }
        // QoL batch 3 (her L6): the standard Edit ▸ Find submenu — the one
        // slot in this file's menu map that was empty. Deliberately NOT ⌘K's
        // neighbour: "Find Anything…" searches the library's titles and
        // names, this searches the TEXT of the post you are in.
        //
        // Every item is registry-declared with its own key (P-1), and every
        // one of them is honestly grey wherever no full-document Write editor
        // owns a scroll view — which is every surface except the post
        // detail's own editor (the book/spread/pool inline editors have no
        // bar of their own to show).
        CommandGroup(after: .pasteboard) {
            // **13u2 item 11 — her QoL ask, verbatim:** *"i want a way to
            // paste without new lines (some kind of command shift v or
            // command option v or whatever isn't taken, but it's a quality
            // of life issue)."*
            //
            // **THE CHORD: ⇧⌘V**, and the reason is measurement rather than
            // convention — a grep of the whole app finds NO `keyboardShortcut`
            // on "v" at all, and macOS's own "Paste and Match Style" is
            // ⌥⇧⌘V, so ⇧⌘V is genuinely free here. Her named alternative
            // ⌥⌘V is one modifier away if she prefers it.
            //
            // **It is NOT registry-declared, deliberately, and this is the
            // reason** (P-1 asks for one, so an exception is stated rather
            // than taken): Cut, Copy and Paste are not declared either —
            // they are AppKit's standard Edit menu, validated by the
            // RESPONDER CHAIN, and this is a member of that family. Its
            // availability is "a text view has the keyboard", which
            // `CapabilityContext` cannot see and the responder chain answers
            // exactly. So it goes down the chain like its siblings, and P-2
            // is honoured the way a menu item can honour it: `sendAction`
            // reports whether anything took it, and where nothing did the
            // door says so instead of failing silently.
            Button("Paste Without Line Breaks") {
                let took = NSApp.sendAction(
                    #selector(EditorTextView.pasteWithoutNewlines(_:)), to: nil, from: nil)
                if !took {
                    session?.status.say(
                        "Click into some text first — this pastes into a note you are writing in.",
                        refusing: true)
                }
            }
            .keyboardShortcut("v", modifiers: [.command, .shift])
            Menu("Find") {
                Button(verb(.findInPost)) { actions?.dispatch(.find(.show)) }
                    .keyboardShortcut("f", modifiers: .command)
                    .disabled(!enabled(.findInPost))
                Button(verb(.findAndReplace)) { actions?.dispatch(.find(.showReplace)) }
                    .keyboardShortcut("f", modifiers: [.command, .option])
                    .disabled(!enabled(.findAndReplace))
                Divider()
                Button(verb(.findNext)) { actions?.dispatch(.find(.next)) }
                    .keyboardShortcut("g", modifiers: .command)
                    .disabled(!enabled(.findNext))
                Button(verb(.findPrevious)) { actions?.dispatch(.find(.previous)) }
                    .keyboardShortcut("g", modifiers: [.command, .shift])
                    .disabled(!enabled(.findPrevious))
                Divider()
                Button(verb(.useSelectionForFind)) { actions?.dispatch(.find(.useSelection)) }
                    .keyboardShortcut("e", modifiers: .command)
                    .disabled(!enabled(.useSelectionForFind))
                Divider()
                // 13e E9 — the takes-aware half, as a SCOPE EXTENSION of the
                // bar above it rather than a second find surface: it uses the
                // find bar's own two strings and its own matches, and carries
                // each into every OTHER live take of the blocks they touch.
                // Keyless deliberately (#63(f)) — an act that edits takes she
                // cannot see is one to choose, not to hit.
                Button(verb(.replaceAllInEveryTake)) {
                    actions?.dispatch(.find(.replaceAllInEveryTake))
                }
                .disabled(!enabled(.replaceAllInEveryTake))
            }
        }
        // The structural gestures' menu-bar door (Phase 9, contract item 1;
        // rewired 13b 1b): enablement is the REGISTRY's — in Write the
        // planner speaks per-invocation as before; in Takes/Lenses the same
        // items now FIRE-AND-DO (the one mode-switch choreography lands the
        // caret and runs the gesture); where nothing can act they are grey.
        CommandMenu("Block") {
            Button(verb(.divide)) { actions?.dispatch(.structural(.divide)) }
                .keyboardShortcut("d", modifiers: [.command, .shift])
                .disabled(!enabled(.divide))

            // 13j J4: the ceremony, summoned deliberately. On a fanned block
            // ⌘⇧D now duplicates (her Q-M2 shape) and THIS opens the sheet.
            Button(verb(.divideWithCeremony)) {
                actions?.dispatch(.structural(.divideWithCeremony))
            }
            .keyboardShortcut("d", modifiers: [.command, .option, .shift])
            .disabled(!enabled(.divideWithCeremony))

            Button(verb(.extract)) { actions?.dispatch(.structural(.extract)) }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .disabled(!enabled(.extract))

            Button(verb(.makeBlock)) { actions?.dispatch(.structural(.makeBlock)) }
                .keyboardShortcut("k", modifiers: [.command, .shift])
                .disabled(!enabled(.makeBlock))

            Divider()

            Button(verb(.merge)) { actions?.dispatch(.structural(.merge)) }
                .keyboardShortcut("m", modifiers: [.command, .shift])
                .disabled(!enabled(.merge))

            // 13j J4b: the pairing ceremony's own door — ⌘⇧M now carries
            // every take along (her 2026-08-09 ruling) and THIS pairs them.
            Button(verb(.mergeWithCeremony)) {
                actions?.dispatch(.structural(.mergeWithCeremony))
            }
            .keyboardShortcut("m", modifiers: [.command, .option, .shift])
            .disabled(!enabled(.mergeWithCeremony))

            // #11b (author, 2026-07-13): the deliberate, NAMED command.
            Button(verb(.deleteInEveryTake)) { actions?.dispatch(.deleteInEveryTake) }
                .disabled(!enabled(.deleteInEveryTake))

            // D3's third leg (13b 1b): the add-block door — native on the
            // boards (an empty block mints and its pane goes live), caret
            //-to-end in Write (typing there births blocks).
            Button(verb(.addBlockAtEnd)) { actions?.dispatch(.addBlockAtEnd) }
                .disabled(!enabled(.addBlockAtEnd))

            // 13b 4D (N28/S4-13): insert-below — an empty block mints right
            // under the caret/focused block, NATIVE in Write and Takes
            // alike (her editor-parity ruling); the caret/ring lands in it.
            Button(verb(.insertBlockBelow)) { actions?.dispatch(.insertBlockBelow) }
                .keyboardShortcut(.return, modifiers: [.command, .shift])
                .disabled(!enabled(.insertBlockBelow))

            // 13c 1B (A8): the delete door where she writes — `deleteBlock`
            // has been an operation since Phase 2 with exactly one face
            // (the block TOC's row menu). Undoable AND redoable; the block
            // lands in the post's tray either way.
            Button(verb(.deleteBlock)) { actions?.dispatch(.deleteBlock) }
                .disabled(!enabled(.deleteBlock))

            // 13j (her round-7 ruling): the third verb. Archive sets the
            // block aside KEPT — it leaves the note, waits in the note's
            // tray with no countdown, and Put back returns it where it
            // stood. Deliberately next to Delete, because the difference
            // between them is the thing to learn.
            Button(verb(.archiveBlock)) { actions?.dispatch(.archiveBlock) }
                .disabled(!enabled(.archiveBlock))

            Divider()

            // The fan door (9d): ANY block, any arity. In Lenses the door
            // fire-and-DOes: blooms live in Takes, so it GOES there.
            Button(verb(.showTakes)) { actions?.dispatch(.takes(.toggleFan)) }
                .keyboardShortcut("t", modifiers: [.command, .shift])
                .disabled(!enabled(.showTakes))

            // The take lifecycle's keyboard family (Sitting 9, R73/R90/R93;
            // routed 13b 1b — a registered surface handles or the router
            // speaks; nothing is a dead key where the act can work).
            Button(verb(.newTake)) { actions?.dispatch(.takes(.branch)) }
                .keyboardShortcut("t", modifiers: .command)
                .disabled(!enabled(.newTake))
            Button(verb(.blankTake)) { actions?.dispatch(.takes(.blank)) }
                .keyboardShortcut("t", modifiers: [.command, .option])
                .disabled(!enabled(.blankTake))
            Button(verb(.blankTakeAsChosen)) { actions?.dispatch(.takes(.blankChoose)) }
                .keyboardShortcut("t", modifiers: [.command, .option, .shift])
                .disabled(!enabled(.blankTakeAsChosen))
            Button(verb(.chooseTake)) { actions?.dispatch(.takes(.choose)) }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(!enabled(.chooseTake))
            Button(verb(.previousTake)) { actions?.dispatch(.takes(.stepPrev)) }
                .keyboardShortcut(.leftArrow, modifiers: [.command, .control])
                .disabled(!enabled(.previousTake))
            Button(verb(.nextTake)) { actions?.dispatch(.takes(.stepNext)) }
                .keyboardShortcut(.rightArrow, modifiers: [.command, .control])
                .disabled(!enabled(.nextTake))
            Button(verb(.archiveTake)) { actions?.dispatch(.takes(.archive)) }
                .keyboardShortcut("a", modifiers: [.command, .shift])
                .disabled(!enabled(.archiveTake))
            Button(verb(.saveChoicesAsLens)) { actions?.dispatch(.takes(.saveLens)) }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                .disabled(!enabled(.saveChoicesAsLens))
            Button(verb(.closeAllTakes)) { actions?.dispatch(.takes(.closeAll)) }
                .disabled(!enabled(.closeAllTakes))
            // AD-2's companion (13b 1b): the paged fan rail, keyboard-able.
            Button(verb(.pageFanBack)) { actions?.dispatch(.pageFan(-1)) }
                .keyboardShortcut(.leftArrow, modifiers: [.command, .option])
                .disabled(!enabled(.pageFanBack))
            Button(verb(.pageFanForward)) { actions?.dispatch(.pageFan(1)) }
                .keyboardShortcut(.rightArrow, modifiers: [.command, .option])
                .disabled(!enabled(.pageFanForward))

            // 13e E6 (her A21's clipboard half): the block's whole fan as
            // text, in the app's own ratified export shape. ⌘⇧C — ⌘C stays
            // the system's Copy.
            Button(verb(.copyAllTakes)) { actions?.dispatch(.copyAllTakes) }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .disabled(!enabled(.copyAllTakes))

            // 13e batch 3 (her A20/A21's second half — AR-1): the take↔block
            // pair, in the Return family with New Block Below above them.
            Button(verb(.takeToBlockBelow)) { actions?.dispatch(.takeToBlockBelow) }
                .keyboardShortcut(.return, modifiers: [.command, .option])
                .disabled(!enabled(.takeToBlockBelow))
            Button(verb(.takesToBlocks)) { actions?.dispatch(.takesToBlocks) }
                .keyboardShortcut(.return, modifiers: [.command, .option, .shift])
                .disabled(!enabled(.takesToBlocks))

            Divider()

            // R73's block navigation pair (Write's caret). Enablement is
            // ATTACHMENT-level (round-1 MINOR-3): enabled ⇒ the editor the
            // action chains into exists — never enabled-but-silent while
            // Write is still mounting.
            //
            // **`editingOrActive`, not `active` (the 18d ladder's MINOR-1).**
            // These act on the CARET, and in the book's Outline `active` is
            // the projection-less shadow (`EditorRouter`'s own comment): the
            // items were enabled and the act did nothing, which is a straight
            // P-2 break — a rendered door performs the act or delivers a real
            // refusal.
            Button(verb(.previousBlock)) {
                session?.editorRouter.editingOrActive?.jumpToAdjacentBlock(-1)
            }
            .keyboardShortcut(.upArrow, modifiers: [.command, .control])
            .disabled(!enabled(.previousBlock))
            Button(verb(.nextBlock)) {
                session?.editorRouter.editingOrActive?.jumpToAdjacentBlock(1)
            }
            .keyboardShortcut(.downArrow, modifiers: [.command, .control])
            .disabled(!enabled(.nextBlock))

            // The caret block's comments (Phase 13 C1, R7; routed 13b 1b —
            // the boards open their target block's panel, so ⌘⇧' works
            // where the bars' block menu already offered the door).
            Button(verb(.blockComments)) { actions?.dispatch(.comments) }
                .keyboardShortcut("'", modifiers: [.command, .shift])
                .disabled(!enabled(.blockComments))

            // The callout frame (R16/R27). 13c R2-2 (A13(a)): every item
            // ROUTES now — the frame is the block's, so Takes, Lenses and
            // Compare set it where she is, instead of the door reaching
            // into Write's editor and silently doing nothing anywhere
            // else. ⌥⌘C toggles.
            // 13k K6: the rows come from `CalloutMenu` now, so the menu bar,
            // the editor's right-click and a take pane's right-click cannot
            // offer different words (P-1's one-declaration rule; the
            // `MarkdownActs.headingRows` precedent).
            Menu(CalloutMenu.title) {
                ForEach(Array(CalloutMenu.rows.enumerated()), id: \.offset) { index, row in
                    if row.isSeparator {
                        Divider()
                    } else if row.promptsForEmoji {
                        Button(row.title) { promptCalloutEmoji() }
                    } else if let edit = row.edit {
                        Button {
                            actions?.dispatch(.callout(edit))
                        } label: {
                            // 13e E1: the swatch rides the LABEL where the row
                            // carries a colour token — the same
                            // `CalloutMenu.swatchImage` the two NSMenu doors
                            // draw. `.renderingMode(.original)` and the
                            // image's own `isTemplate = false` are both needed:
                            // a menu label's image is tinted by default, which
                            // is the one thing a colour chip must not be.
                            if let swatch = row.swatch {
                                Label {
                                    Text(row.title)
                                } icon: {
                                    Image(nsImage: CalloutMenu.swatchImage(for: swatch))
                                        .renderingMode(.original)
                                }
                            } else {
                                Text(row.title)
                            }
                        }
                            // ⌥⌘C rides the toggle row, exactly as before.
                            .keyboardShortcut(
                                edit == .toggle
                                    ? KeyboardShortcut("c", modifiers: [.command, .option])
                                    : nil)
                    }
                }
            }
            // Round-1 MINOR-3: the ONE enablement idiom — the registry's
            // declared availability (now the take family plus Compare).
            .disabled(!enabled(.callout))

            Divider()

            // Phase 13 C1 (R6/R42): dotted seams on the GLOBAL setting.
            Button(verb(.toggleSeams)) { actions?.toggleSeams() }
                .keyboardShortcut("b", modifiers: [.command, .shift])
                .disabled(session == nil)
        }
        // 13g batch 3 (L8) — the FORMAT menu, her rulings F-1…F-3. Every item
        // inserts or removes ordinary SYNTAX CHARACTERS through the ordinary
        // input path (`MarkdownActs`), on whichever surface holds the
        // keyboard; nothing here writes a row. Honestly grey where no note is
        // open, and honest-speaking where one is open but nothing editable
        // holds the keyboard.
        CommandMenu("Format") {
            Button(verb(.formatBold)) { actions?.applyFormat(.bold) }
                .keyboardShortcut("b", modifiers: .command)
                .disabled(!enabled(.formatBold))
            Button(verb(.formatItalic)) { actions?.applyFormat(.italic) }
                .keyboardShortcut("i", modifiers: .command)
                .disabled(!enabled(.formatItalic))
            Button(verb(.formatStrikethrough)) { actions?.applyFormat(.strikethrough) }
                .disabled(!enabled(.formatStrikethrough))
            Button(verb(.formatCode)) { actions?.applyFormat(.code) }
                .disabled(!enabled(.formatCode))
            // 13g batch 4 (L10): the insertion door for the links F-5 ruled
            // in. Keyless by the sweep's verdict (⌘K is Find Anything).
            Button(verb(.formatAddLink)) { actions?.applyFormat(.link) }
                .disabled(!enabled(.formatAddLink))

            Divider()

            // The three sizes are shades of ONE act (F-3: headings ARE the
            // sizes markdown can express), so they live in a submenu under
            // one declaration — the callout menu's shape.
            Menu(verb(.formatHeading)) {
                ForEach(MarkdownActs.headingRows, id: \.title) { row in
                    Button(row.title) { actions?.applyFormat(row.act) }
                }
            }
            .disabled(!enabled(.formatHeading))
            Button(verb(.formatBulletList)) { actions?.applyFormat(.bullet) }
                .disabled(!enabled(.formatBulletList))
            Button(verb(.formatChecklist)) { actions?.applyFormat(.checkbox) }
                .disabled(!enabled(.formatChecklist))
            Divider()
            // 13k K8 (her ruling + sitting Q3): the nesting rows. TAB and
            // ⇧TAB remain the primary door and are still deliberately NOT
            // menu key equivalents (binding ⇥ would steal Tab from every
            // control in the app), so they stay in the surfaces' own
            // `insertTab`/`insertBacktab`.
            // 13u4 UNIT S1 (her item 5 — *"how are things unindented?"*):
            // the rows now WEAR keys, so the act is findable from the menu
            // that holds it. ⌘] / ⌘[ are Apple Notes' and Pages' own list-
            // level chords; back/forward moved to ⌥⌘[ / ⌥⌘], which is where
            // Apple Notes puts them too. PROVISIONAL — QUESTIONS #130.
            Button(verb(.formatIndent)) { actions?.applyFormat(.indent) }
                .keyboardShortcut("]", modifiers: .command)
                .disabled(!enabled(.formatIndent))
            Button(verb(.formatOutdent)) { actions?.applyFormat(.outdent) }
                .keyboardShortcut("[", modifiers: .command)
                .disabled(!enabled(.formatOutdent))
        }
        // ⌘1–⌘6 — the post modes (routed 13b 1b: composition, not a
        // broadcast — with no post open the items are honestly grey; a
        // routed request that finds no detail SPEAKS instead of vanishing).
        CommandGroup(before: .toolbar) {
            // One digit per mode: `PostMode` is a CLOSED enum of seven, so
            // "\(i + 1)" is always one character (18o U3 — the Open strip's
            // row-ten trap cannot happen here; `OpenStripMenuTests.
            // theModeKeysCanNeverReachTen` is the cap).
            ForEach(Array(PostMode.allCases.enumerated()), id: \.offset) { i, mode in
                Button(mode.rawValue) { actions?.requestMode(mode) }
                    .keyboardShortcut(KeyEquivalent(Character("\(i + 1)")), modifiers: .command)
                    .disabled(!enabled(.switchMode))
            }
            Divider()
            // 13f batch 3 (W16 — her ruling): the pane's back/forward.
            // Every door in this file is honestly grey where it cannot act:
            // at the shelf, with nothing visited yet, Back is grey rather
            // than a key that does nothing.
            // 13u4 UNIT S1 (her item 5): the KEYS moved to ⌥⌘[ / ⌥⌘] — the
            // acts, the doors and the context bar's ← → are unchanged. See
            // `keyEquivalent(for:)` for the measurement and the sweep.
            Button(verb(.navigateBack)) { router?.goBack() }
                .keyboardShortcut("[", modifiers: [.command, .option])
                .disabled(!enabled(.navigateBack))
            Button(verb(.navigateForward)) { router?.goForward() }
                .keyboardShortcut("]", modifiers: [.command, .option])
                .disabled(!enabled(.navigateForward))
            // The Act 10 correction round (row 15): ⌘⇧I tags the note — it
            // opens the masthead's inline field, grey with no note open.
            Button(verb(.tagNote)) { actions?.tagNote() }
                .keyboardShortcut("i", modifiers: [.command, .shift])
                .disabled(!enabled(.tagNote))
            Divider()
            // 13f batch 3 (W3/A27): the Open strip's keys. ONE submenu
            // holding the window's open notes BY NAME, each with its
            // ordinal key — so every shortcut is a menu item (R73/R91/R93)
            // and the keys and the sidebar rows can never disagree: both
            // read `workspace.openNotes.shown`, in the same order.
            Menu(verb(.openNote)) {
                // 18o U3 (KnownIssues row 73): the rows ARE the strip's menu
                // table — title, key and act all read the row. ⌘⇧1…⌘⇧9 on
                // the first nine; rows past nine render keyless and still
                // open the note they name.
                ForEach(router?.workspace.openNotes.menuRows ?? [], id: \.noteID) { row in
                    Button(router?.workspace.label(for: .post(row.noteID)) ?? "") {
                        router?.openStripRow(row)
                    }
                    .keyboardShortcut(row.keyboardShortcut)
                }
            }
            .disabled(!enabled(.openNote))
            // VX-287 (the VX-283 run): ⌘⇧W — the note you're in leaves the
            // Open list and the pane moves on to the next one. Grey with no
            // note in the pane, and in a note-only or quick-note window (the
            // registry's gate — only a full window has an Open list).
            Button(verb(.closeNote)) { if let router { Self.closeNote(in: router) } }
                .keyboardShortcut("w", modifiers: [.command, .shift])
                .disabled(!enabled(.closeNote))
            // VX-289: the Open list's right-click twin — every row closes.
            Button(verb(.closeAllNotes)) { if let router { Self.closeAllNotes(in: router) } }
                .disabled(!enabled(.closeAllNotes))
            Divider()
            // 13f batch 4 (W1/A25 — her two-panes ruling): the split's
            // keyboard-reachable doors. Open Beside from here means "put
            // the most recently opened OTHER note beside this one", which
            // is what a split is FOR after coming from somewhere; the row
            // doors put the row you point at. Both refuse in one voice
            // when the note is already showing (round 7.3).
            Button(verb(.openBeside)) { router?.openBesideMostRecent() }
                .disabled(!enabled(.openBeside))
            Button(verb(.closeSplit)) { router?.closeSplit() }
                .disabled(!enabled(.closeSplit))
            // VX-359: no trailing `Divider()` — SwiftUI separates command
            // groups itself, so one here drew a second hairline beside the
            // group boundary's (`ViewMenuSeparatorTests`).
        }
        // ⌘/ — the shortcut helper + dictionary (Sitting 9, R73/R91).
        // 13b Stage 2 (R113): the tutorial's Help-menu doors — open the
        // field guide, and Restore Tutorial… (replace-wholesale after a
        // spoken confirm; fire-and-DO — it seeds AND opens).
        CommandGroup(after: .help) {
            Button(verb(.helper)) { openWindow(id: "variorum-helper") }
                .keyboardShortcut("/", modifiers: .command)
            Divider()
            // 13f cold review R1-3: both tutorial doors navigate via
            // `pendingSelection`, so they land where a shell can adopt it —
            // the ruling named Open the Tutorial; Restore is the identical
            // class one line below (the batch-7 follow-on discipline:
            // applied with the class, flagged so it can be reversed).
            Button("Open the Tutorial") { creationActions()?.openTutorial() }
                .disabled(!canReachCreationTarget)
            // 13s-b U1a, piece 5 (R-13s-6/13 — "they can find it under
            // help"): the tour's standing door, beside the field guide's. Its
            // name is the registry's verb, which the offer line's help-road
            // sentence reads too (`TourOfferCopy.menuTitle`): "Tutorial" is
            // taken by the field guide's door one line up, so the tour's is
            // "Take the Tour" (PROVISIONAL P-U1a-9). A request the window
            // adopts, the What's New road (the tour runs over a window).
            Button(verb(.takeTour)) { windows.creationRouter()?.tourRequested = true }
                .disabled(!canReachCreationTarget)
            // 13r U3-A: Help ▸ What's New — this version's release notes
            // (the ONE source the appcast also carries), on demand. A
            // request the window adopts, on the creation router (the sheet
            // needs a full window), so it lands where it can show (P-2).
            // UNDECLARED in the capability registry on the "Open the
            // Tutorial" precedent one line up — an app-scope Help door with
            // no block/take/post/book scope; flagged for the ladder as a P-1
            // reading, not a product call.
            Button(WhatsNewCopy.menuTitle) { windows.creationRouter()?.whatsNewRequested = true }
                .disabled(!canReachCreationTarget)
            Button(verb(.restoreTutorial)) { creationActions()?.restoreTutorial() }
                .disabled(!canReachCreationTarget)
            Button(verb(.restoreSampleLibrary)) {
                creationActions()?.restoreSampleLibrary()
            }
            .disabled(!canReachCreationTarget)
            // (The Encryption Explained restore sat here — pre-13x 5a —
            // RETIRED at 13s-b U1b, R-13s-37: not restorable.)
            // 18l-c U6: the takemania book's restore, beside Sherlock's.
            Button(verb(.restoreJekyllBook)) {
                creationActions()?.restoreJekyllBook()
            }
            .disabled(!canReachCreationTarget)
            // 13s-b U1b (R-13s-37): the classics gathering's restore.
            Button(verb(.restoreClassicsGathering)) {
                creationActions()?.restoreClassicsGathering()
            }
            .disabled(!canReachCreationTarget)
            // (The pre-13x batch 0 DEBUG keychain probe door lived here —
            // deleted at batch 2a with the real Apple-key item, row 12.)
            // 13r U3-B — R-13r-3/9: Help ▸ Send Feedback…, THE SUPPORT DOOR.
            // A mail draft to support@stargazing.tech, pre-filled with the app
            // and OS versions and nothing else, opened ON SCREEN in her own
            // mail app; it goes only when she presses that app's Send. 19f:
            // before the draft it asks — "Open in Mail" or "Copy the address"
            // (her #181 (i) ruling; `sendFeedback()` below). It
            // needs no window and no store, so it is always enabled. UNDECLARED
            // in the capability registry on the What's New / Open the Tutorial
            // precedent above — an app-scope Help door with no block/take/
            // post/book scope; flagged for the ladder as a P-1 reading, as
            // U3-A flagged its own. Its own group at the end: it talks to the
            // author, where the doors above act on the library.
            Divider()
            Button(SupportCopy.feedbackMenuTitle) { sendFeedback() }
        }
    }

    /// 13r U3-B: the support door's act. **19f (her #181 (i) ruling): it
    /// ASKS FIRST** — "Open in Mail" or "Copy the address" — and no draft
    /// opens before her answer. The question is asked of the window (the
    /// shell's `supportChoice`, presented as a SwiftUI `.alert` like every
    /// confirm in the app; a full window behind Settings or a note window is
    /// raised to ask it); with NO window to ask in — the library not open,
    /// or every window closed — this always-enabled door asks through an
    /// app-modal alert, its own no-window voice. "Open in Mail" is the U3-B
    /// act, unchanged: the draft opens in her default mail app (`mailto:` —
    /// `SupportMail`); if nothing could open it, the door says so (P-2) —
    /// through the status seam when a store is open, and otherwise in a
    /// plain alert, since a door that did nothing must speak. "Copy the
    /// address" needs no mail app: the address onto the clipboard, and a
    /// receipt where a store is open.
    private func sendFeedback() {
        let choose: SupportChooser
        if let window = windows.creationRouter()?.supportChoice {
            choose = { await window.ask($0) }
        } else {
            choose = { SupportChoiceModal.ask($0) }
        }
        Task { @MainActor in
            let answer = await SupportMail.ask(.feedback, choose: choose) {
                SupportMail.open(.feedback(.thisMac())) { refusal in
                    if case .ready(let session) = bootstrap.state {
                        session.status.refuse(refusal)
                    } else {
                        let alert = NSAlert()
                        alert.messageText = refusal
                        alert.runModal()
                    }
                }
            }
            if case .copiedAddress = answer, case .ready(let session) = bootstrap.state {
                session.status.receipt(SupportCopy.copiedAddress)
            }
        }
    }

    @Environment(\.openWindow) private var openWindow
    /// 13n-c U4: ⌥⌘, opens the Settings window (at MCP).
    @Environment(\.openSettings) private var openSettings

    /// The two `WindowGroup` ids the app opens by name (13f batch 5b).
    static let mainWindowGroupID = "variorum-main"
    static let noteWindowGroupID = "variorum-note"
    /// 13f batch 6 (W5): the floating quick-note pad — a SINGLETON window
    /// (`Window`, not `WindowGroup`), because there is one pad.
    static let quickNoteWindowGroupID = "variorum-quicknote"

    /// The callout emoji prompt (her sitting-3 reference wore "💡").
    /// 13c R2-2: the prompt gathers the glyph and the ROUTER delivers it,
    /// so it works on every surface the door is now declared for — it no
    /// longer needs a Write editor to exist.
    private func promptCalloutEmoji() {
        // Round-2 NIT-R2-3: the file's last silent return speaks. A nil
        // session has no status surface to speak to — nothing exists yet.
        guard let actions else {
            if case .ready(let session) = bootstrap.state {
                session.status.refuse(CapabilityRegistry.capability(.callout).unavailableNote)
            }
            return
        }
        // 13k K6: the alert itself moved to `CalloutMenu`, so the right-click
        // door and this one ask the same question.
        guard let glyph = CalloutMenu.promptEmoji() else { return }
        actions.dispatch(.callout(.emoji(glyph)))
    }

    /// **⌘⇧W's act** (VX-287): the workspace closes the focused pane's note
    /// and names where the pane lands; the landing takes the shell's EXISTING
    /// open-note road — `pendingSelection`, adopted by `RootView` exactly as
    /// ⌘⇧1–9 and View ▸ Open Note's rows are — never a new landing authority.
    static func closeNote(in router: ShellRouter) {
        if let landing = router.workspace.closeFocusedNote() {
            router.pendingSelection = landing
        }
    }

    /// **View ▸ Close All Notes** (VX-289): every row closes; the focused
    /// pane's landing takes the same road as ⌘⇧W's.
    static func closeAllNotes(in router: ShellRouter) {
        if let landing = router.workspace.closeAllNotes() {
            router.pendingSelection = landing
        }
    }

    /// Pure label derivation, tested directly ("Undo Divide", "Undo
    /// Extract", … — generic when the stack is empty).
    static func undoMenuTitle(for topLabel: String?) -> String {
        topLabel.map { "Undo \($0)" } ?? "Undo Structural Change"
    }

    /// The redo half's twin (13c 1B — A10): "Redo Divide", generic when
    /// the redo stack is empty.
    static func redoMenuTitle(for topRedoLabel: String?) -> String {
        topRedoLabel.map { "Redo \($0)" } ?? "Redo Structural Change"
    }
}

extension OpenStripMenuRow {
    /// The row's ⌘⇧ key as the menu wears it — the ONE place the table's key
    /// text becomes a `Character` (18o U3 — KnownIssues row 73). nil = the
    /// row renders with no shortcut.
    var keyboardShortcut: KeyboardShortcut? {
        keyText.map { KeyboardShortcut(KeyEquivalent(Character($0)), modifiers: [.command, .shift]) }
    }
}
