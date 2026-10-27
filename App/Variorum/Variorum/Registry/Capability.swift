//
//  Capability.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (P-1): the capability model — every user-facing act
//  the interaction layer routes is declared EXACTLY ONCE (verb, scope,
//  doors, per-context availability, Takes access per R118). Surfaces render
//  their doors FROM these declarations; gating is data, never per-view
//  if-statements. The declarations themselves live in
//  `CapabilityRegistry.swift`; this file is the pure model plus the routed
//  command vocabulary.
//
//  Pure Swift (no AppKit/SwiftUI): the registry walk test evaluates
//  availability over synthesized contexts without mounting anything.
//

import Foundation

// MARK: - The routed command vocabulary

/// The take lifecycle's keyboard family (Sitting 9, R73). Formerly rode the
/// `.variorumTakesCommand` notification (four hand-kept observer switches,
/// silently dropped wherever none was mounted — the Stage 0 broadcast-
/// without-listener class); Stage 1b routes it through `CommandRouter`
/// instead: registered handlers, and an unhandled command SPEAKS.
nonisolated enum TakesCommand: String, Sendable {
    case toggleFan      // ⌘⇧T — open/close takes at the block you're in
    case closeAll       // ⎋ / menu — back to the plain page
    case branch         // ⌘T — new take (branch from shown)
    case blank          // ⌥⌘T — new blank take (never chooses — R90)
    case blankChoose    // ⇧⌥⌘T — the power variant: blank AND chosen
    case choose         // ⌘⏎ — choose the take you're in
    case stepPrev       // ⌃⌘← — previous take (ring / column pick)
    case stepNext       // ⌃⌘→ — next take
    case archive        // ⌘⇧A — archive the take you're in
    case saveLens       // ⌘⇧L — save current choices as a lens
}

/// The structural verbs, registry-side. The Editor feature maps these onto
/// its `StructuralGesturePlanner.Command` — the registry never imports the
/// planner (layering: features consume the shared layer, never the
/// reverse).
nonisolated enum StructuralAct: String, Sendable, CaseIterable {
    case divide, extract, makeBlock, merge
    /// 13j J4/J4b — **the two DELIBERATE ceremony doors.** Her 2026-08-03
    /// and 2026-08-09 rulings flipped the fanned defaults to the duplicating
    /// divide and the carry-all merge; the ceremonies survive as summoned
    /// options with a keybind of their own ("never only a buried menu
    /// item"). They are their own ACTS rather than a flag on the two above,
    /// for the find/formatting families' reason: each carries its own key,
    /// its own verb and its own honest refusal, and a mode hidden inside
    /// another act's implementation is exactly what P-1 forbids. Both plan
    /// through their twin's planner command — the plan SHAPE is identical
    /// and only the execution differs.
    case divideWithCeremony, mergeWithCeremony
}

/// The callout frame's edits (13c Stage 1 ladder, R2-2 — her A13(a):
/// *"callouts … in Takes/Compare/Lenses + a shortcut"*). One payload, so
/// every surface's door applies the SAME transform to the stored frame
/// (`CalloutEditRule`) rather than each re-deriving read-modify-write
/// semantics. `.toggle` is the shortcut's single act — a frame is one
/// thing you either have or don't, so ⌥⌘C is honest as a toggle where a
/// colour submenu could never be a key.
nonisolated enum CalloutEdit: Equatable, Sendable {
    /// Set the frame to this palette-token name; `nil` REMOVES the frame.
    case color(String?)
    /// Set (or, with `nil`, clear) the emoji, keeping the colour — minting
    /// the default colour when the block has no frame yet.
    case emoji(String?)
    /// Frame it if it is plain, un-frame it if it is a callout.
    case toggle
}

/// The in-post FIND family (QoL round 2026-07-29, batch 3 — her L6:
/// *"we need to ship some kind of text find and replace … at least of the
/// chosen text, because i noticed myself reaching for that and not having
/// it"*). Registry-side, in the app's own vocabulary: the Editor feature maps
/// these onto `NSTextFinder.Action`, and the registry never imports AppKit —
/// the `StructuralAct` → `StructuralGesturePlanner.Command` layering, same
/// reason (features consume the shared layer, never the reverse).
///
/// Deliberately distinct from `findAnything` (⌘K, the palette): that searches
/// the LIBRARY's titles and names; this searches the TEXT of the post you are
/// in, over its chosen takes. *(13e E9: the takes-aware REPLACE half is now
/// built — `replaceAllInEveryTake` below. Whole-library body search remains
/// future scope, and its owner is the master plan's own **Whole-library text
/// search** row, not this family.)*
nonisolated enum FindAction: String, Sendable, CaseIterable {
    case show          // ⌘F — the find bar
    case showReplace   // ⌥⌘F — the find bar with its replace field
    case next          // ⌘G
    case previous      // ⇧⌘G
    case useSelection  // ⌘E — search for what's selected
    /// 13e E9 — the takes-aware half (the KnownIssues row *"Find & replace —
    /// the takes-aware half"*, owner 13e). Deliberately a SCOPE EXTENSION of
    /// the shipped bar rather than a second find surface: it takes the find
    /// bar's own two strings and its own matches, and carries each one into
    /// every OTHER live take of the blocks the matches touch — the
    /// Delete-in-Every-Take apply-and-report shape, one act over.
    case replaceAllInEveryTake
}

/// Everything the menu bar / palette / bars route to "whichever post
/// surface is mounted". One channel, exhaustively typed — a surface handler
/// switches over this and the compiler keeps the four handlers complete.
nonisolated enum RoutedCommand: Equatable, Sendable {
    case find(FindAction)  // QoL batch 3 (L6)
    case takes(TakesCommand)
    case structural(StructuralAct)
    case deleteInEveryTake
    case commit          // ⌘S — commit the focused/caret take
    case addBlockAtEnd   // D3's third leg: a new block at the post's end
    case insertBlockBelow  // 13b 4D (N28/S4-13): a new block BELOW the caret/focused block
    case deleteBlock     // 13c 1B (A8): delete the caret/focused block
    /// 13j (her round-7 ruling): set the caret/focused block ASIDE, kept —
    /// the third verb beside delete (30 days) and move-to-scraps.
    case archiveBlock
    case toggleSeal
    case comments        // ⌘⇧' — the target block's comments panel
    case callout(CalloutEdit)  // 13c R2-2 (A13(a)): the target block's frame
    case pageFan(Int)    // ⌥⌘←/→ — page the focused block's take cards
    case copyAllTakes    // 13e E6 (A21): the target block's whole fan → the clipboard
    case takeToBlockBelow  // 13e E5 (A20): the take you're in becomes the block below
    case takesToBlocks     // 13e E6b (A21/A45): every other take becomes its own block
    /// 13j J3: peek at the released original behind the caret/focused block.
    /// Routed because the ⌘K row has no target in hand — the surface names
    /// the block it is standing in, exactly as `.deleteBlock` does, and
    /// speaks the honest note where the block has no original (P-2).
    ///
    /// **The post-13l polish round (ledger row 17) changed WHERE IT LANDS,
    /// not what it means:** the act opens the block's History pane at its
    /// came-from region — which shows ALL of a merge's originals rather than
    /// the first (the 13l walk's P-3) — instead of a peek sheet of its own.
    case showOriginBlock
    /// The post-13l polish round (ledger row 17, G2): the caret/focused
    /// block's **History pane**. Routed for `.showOriginBlock`'s reason
    /// exactly — the bar's door and the ⌘K row both have to ask whichever
    /// surface is mounted which block she is standing in.
    case showBlockHistory
    /// The post-13l polish round (ledger rows 16/23) — the note's **VERSIONS**.
    /// Routed for the same reason its two neighbours are: a bar door and a ⌘K
    /// row both have to ask whichever surface is mounted which note it is
    /// showing, and the panel lives in the post detail's inspector.
    case showNoteVersions
    /// …and **⌘⇧S**, the save door. Routed rather than acted directly so the
    /// note it saves is always the one on screen — the same address ⌘S uses
    /// one grain down (the pairing IS the teaching: this take's moment ·
    /// this note's moment).
    case saveNoteVersion
    /// …and the note's TRAY, routed (adjudication 1). Its NAMED door is the
    /// masthead icon, which needs no routing; this is the ⌘K row, and it is
    /// what gives a book spread's inline note a way in at all — that pane
    /// mounts an editor with no post detail around it, so it has no masthead
    /// to carry the icon (batch 3's one recorded discoverability cost).
    case showNoteTray
}

// MARK: - Choreography intents (the ONE mode-switch choreography's payloads)

/// A fire-and-DO landing in Write (move-and-execute, R115/R118): where the
/// caret/selection lands, and what runs once the editor is live. One-shot —
/// parked on the `CommandRouter`, consumed by the arriving editor's first
/// render. Cross-mode text safety rides the per-post AutosaveCoordinator
/// (Stage 1a): the leaving surface's pending text and the arriving
/// surface's flushes serialize on one instance.
///
/// Staleness discipline (Stage 1 ladder, the round-1 MAJOR): the intent is
/// STAMPED with its post and valid for exactly the round that parked it —
/// the parker clears it when the mode switch refuses (`requestMode` false),
/// the router clears it when the detail changes post or unmounts, and the
/// consuming editor takes it ONLY for its own post. This is the machinery
/// that can run a structural gesture without a user gesture at the moment
/// of execution — it must never fire from a stale parking.
nonisolated struct WriteIntent: Equatable, Sendable {
    enum FollowUp: Equatable, Sendable {
        case structural(StructuralAct)
        case deleteInEveryTake
    }

    /// The post the intent was parked FOR — the consumption gate: an
    /// editor consumes only an intent stamped with its own post.
    var postID: String
    /// The block to land in (nil ⇒ use `caretAtDocumentEnd` / start).
    var blockID: String?
    /// UTF-16 offset within the block (clamped on landing).
    var offsetInBlock: Int = 0
    /// A carried selection's length (0 = caret only).
    var selectionLength: Int = 0
    /// Land at the document's end (the add-block-at-end landing in Write).
    var caretAtDocumentEnd = false
    /// What runs after the caret lands — the "and-execute" half. The
    /// follow-up plans against the REAL landed selection, so its refusal
    /// (if any) is the operation's own, spoken — never a lecture.
    var followUp: FollowUp?
}

/// A fire-and-DO landing in Takes (e.g. Lenses' ⌘⇧T: blooms live in Takes —
/// so GO there and bloom, visibly). Same staleness discipline as
/// `WriteIntent` (post-stamped, one round): a stale landing consumed by an
/// unrelated board would bloom a foreign block AND eat that board's N9
/// landing focus.
nonisolated enum TakesLanding: Equatable, Sendable {
    case bloom(postID: String, blockID: String)

    var postID: String {
        switch self {
        case .bloom(let postID, _): postID
        }
    }
}

/// **A Lenses-board landing** (13n-b U4 — `show_in_app`'s lens target and
/// a receipt's "Open ›" on a saved lens; AF-11 F-3): show THIS saved lens on
/// the arriving (or mounted) Lenses board — its column if one shows it, else
/// a new column (her "+ Column → lens" door), else, with the board's four
/// columns full, the LAST column swapped for it (her R83 replace-in-place
/// door — PROVISIONAL). Post-stamped and one round, `TakesLanding`'s
/// discipline.
nonisolated struct LensLanding: Equatable, Sendable {
    let postID: String
    let lensID: String
}

// MARK: - Availability context

/// The pure context availability rules read. Assembled by `CommandRouter`
/// from its registrations; synthesized freely by tests.
nonisolated struct CapabilityContext: Equatable, Sendable {
    /// The mounted post detail's mode (nil = no post open in the detail —
    /// shelf, library, book view, pool, …).
    var mode: PostMode? = nil
    /// A full-document Write editor is attached somewhere (the detail
    /// editor, the book view's inline editor, or a pool's scraps editor) —
    /// structural gestures can act directly.
    var writeEditorAttached = false
    /// The attached Write editor owns ITS OWN scroll view — i.e. it is the
    /// post detail's full-document editor, not the book/spread/pool inline
    /// one (QoL batch 3, L6).
    ///
    /// Why this is a separate fact from `writeEditorAttached` and not a
    /// refinement of it: the inline editors have no scroll view of their own,
    /// but they are mounted INSIDE SwiftUI `ScrollView`s, which are
    /// `NSScrollView`-backed and conform to `NSTextFinderBarContainer` — so
    /// "there is no find bar there" is something that has to be ENFORCED, not
    /// assumed. Without this field the find doors would render enabled over a
    /// book page and either do nothing or mount a bar above every post on the
    /// spread (the enabled-into-nil class the registry exists to kill).
    ///
    /// Exactly the shape and the reason of 13c 2B's `takesBoardAttached`:
    /// enablement must track the surface that actually acts, never the
    /// container it used to live in.
    var writeEditorOwnsScrollView = false
    /// A TAKES BOARD is mounted somewhere (13c 2B). Inside a post detail
    /// `mode == .takes` already says this; the BOOK SPREAD's takes page
    /// mounts the same board with no detail around it, so the board reports
    /// its own attachment — the `writeEditorAttached` shape, for the other
    /// editable surface kind. Without it the take family would be greyed out
    /// over a mounted, fully working board (the N5 class: Stage 4 lesson 2's
    /// "a new editable surface joins the availability AND registers a
    /// handler" — the handler half the board already had).
    var takesBoardAttached = false
    /// READ's `edit` face is on screen (the Act 10 correction round,
    /// R-cor-7): the one tab named Read hosts an EDITABLE index surface
    /// behind its in-place `edit · read` switch, and a read-only page behind
    /// the other. The mode alone cannot say which face shows, so the host
    /// reports the editable one exactly as a takes board reports its
    /// attachment — and the editing families are honestly available in
    /// `edit` and honestly grey in `read` (the enabled-into-nil class the
    /// registry exists to kill, from both sides).
    var readEditAttached = false
    /// **Write's take panel is up** (VX-154, the VX-282 run). The panel is a
    /// sheet over Write showing ONE block's takes; while it is up, the verbs
    /// that cut, join or add blocks where she writes cannot act from it —
    /// their results land on blocks the panel never shows — so they are grey
    /// by this fact rather than live doors that fall through to Write's caret
    /// beneath the sheet. Reported by the panel itself, the takes board's
    /// attachment shape (a set of tokens on the router).
    var writeTakesPanelAttached = false
    /// 13n-b U4 (AF-11 F-2): a connected AI client's write landed this
    /// session and has somewhere to show — "Show the AI's Last Change" acts.
    var aiLastChangeAvailable = false
    /// The structural undo stack has an entry.
    var undoAvailable = false
    /// The structural REDO stack has an entry (13c 1B — A10).
    var redoAvailable = false
    /// How many notes the window has OPEN (13f batch 3 — W3/A27). The
    /// `undoAvailable` shape: an app-scope act gated on a stack, not on a
    /// mode. Zero ⇒ the Open Notes menu is honestly grey, because ⌘⇧1 with
    /// nothing open can only ever be a dead key.
    var openNoteCount = 0
    /// The active pane has somewhere to go back to (13f batch 3 — W16).
    var canNavigateBack = false
    /// …and somewhere to go forward to.
    var canNavigateForward = false
    /// How many panes the window shows (13f batch 4 — W1/A25). >1 ⇒ a
    /// split exists, which is exactly when Close Split can act.
    var paneCount = 1
    /// There is a note the split could put beside the current one — the
    /// most recently opened note no pane shows. False ⇒ Open Beside is
    /// honestly grey rather than a menu item that can only refuse.
    var canOpenBeside = false
    /// The focused pane is showing a NOTE or a BOOK — i.e. a thing a star
    /// can point at (13f batch 6 — W4). The shelf, the library, the pool
    /// and the recovery surface are places, so ⌘K's Toggle Star is honestly
    /// grey there. Only the ⌘K door reads this: the ROW doors carry their
    /// own target and apply the per-target condition themselves (the
    /// `.diffAgainstChosen` / `.showOriginBlock` split, P-2).
    var canStarCurrent = false
    /// 13e E11: the pane's note is in at least one book — i.e. the ascent has
    /// somewhere to go. The `canStarCurrent` family (a fact about what the
    /// pane is SHOWING, never a stack depth), and the honest shape of what
    /// the bar has always done: her ruled #55(b)/(g) face renders the book
    /// icon GREY with a tooltip on a bookless note, which is exactly what
    /// `.unavailable` means in this registry.
    var canAscendToBook = false
    /// **The focused pane is showing a NOTE** (VX-287, the VX-283 run) — a
    /// `.post`, the kind the Open list tracks — i.e. Close Note (⌘⇧W) has a
    /// note to close. The `canStarCurrent` family: a fact about what the
    /// pane is SHOWING. A book, a place or a scraps container is not a note
    /// the Open list holds, so the key is honestly grey there.
    var focusedPaneShowsNote = false
    /// **The focused pane is showing a BOOK** (VX-570, the VX-439 run) — a
    /// `.reading`, in any book mode — i.e. ⌥⌘N "New Note in This Book" has a
    /// book to mint into. The `focusedPaneShowsNote` family: a fact about what
    /// the KEY window's focused pane is SHOWING. A note open in its own pane
    /// is not a book context (C-570-1 — which of its books would it mean?).
    var focusedPaneShowsBook = false
    /// **The KEY window's kind** (18o U1 — 17e (12)); nil while no window has
    /// registered. The sidebar toggle's gate — only a FULL window has a
    /// sidebar — lived as a per-view if-statement on its View-menu item while
    /// the registry declared the act `always`: a gate the walk could not see
    /// (P-1: gating is data, never per-view if-statements). The `paneCount`
    /// family: a fact about the window she is in, wired by the shell to the
    /// window registry through `CommandRouter.windowKind`.
    var windowKind: WindowRegistry.Kind? = nil
    /// **13n-c Stage B R1 B6 — how many wings the library has** (Home
    /// included). ⌘L's gate: with ONE wing the switcher can only close, so
    /// "Switch Wing…" is honestly grey (P-2) — the `openNoteCount` family, a
    /// fact about the library, wired through `WingState`.
    var wingCount = 1
}

// MARK: - The capability declaration

nonisolated struct Capability: Identifiable, Sendable {
    enum Scope: Sendable { case block, take, post, book, app }

    /// Where the act's doors are rendered. The registry walk asserts every
    /// declared door is rendered by its surface and every rendered door is
    /// declared.
    ///
    /// `.surface` (13b Stage 3, 3D): rendered INLINE on a board/panel
    /// surface — an act whose target is pointed at directly (an archived
    /// take's own card) rather than routed by context. Surfaces that render
    /// surface-doored acts declare them in a `surfaceCapabilities` static,
    /// and the walk asserts declared ⇔ rendered exactly like the four
    /// routed door tables.
    enum Door: Sendable, Hashable, CaseIterable {
        case menuBar, contextMenu, bottomBar, palette, surface
        /// 13f batch 6 (W5): the MENU-BAR EXTRA — the status-item door
        /// that reaches her whatever app is frontmost (her round-14.1
        /// ruling). Deliberately distinct from `.menuBar`, which is the
        /// app's own menu bar and only exists while Variorum is
        /// frontmost; the walk asserts declared ⇔ rendered for this one
        /// too, so a second row appearing in the extra later cannot go
        /// undeclared.
        case menuBarExtra
        /// 13e E14 (W26): the SYSTEM HOT KEY — a chord the system hands us
        /// while any app is frontmost (`RegisterEventHotKey`). Its own case
        /// for the `.menuBarExtra` reason, one step further out: `.menuBar`
        /// exists only while Variorum is frontmost, the extra exists
        /// whatever is frontmost but must be clicked, and this one needs
        /// neither. The walk asserts declared ⇔ registered
        /// (`GlobalHotKeyCenter.registered`), so a chord asked of the system
        /// can never go undeclared — and a declared one can never go
        /// unregistered, which would be a key she reads about and presses to
        /// no effect.
        case systemHotKey
    }

    /// R118 — TAKES PARITY, part of the declaration: how the Takes surface
    /// reaches an EDITING capability. `native` = acts right there;
    /// `moveAndExecute` = the one mode-switch choreography performs it.
    /// Write is never the privileged surface.
    enum TakesAccess: Sendable { case native, moveAndExecute }

    enum Availability: Equatable, Sendable {
        /// Acts in this context (natively).
        case act
        /// Acts via the fire-and-DO choreography, landing in this mode.
        case actElsewhere(PostMode)
        /// Genuinely inapplicable here — the door disables (grey), it is
        /// never rendered enabled-but-void.
        case unavailable
    }

    let id: CapabilityID
    /// The act in the app's own vocabulary (menu titles, palette rows).
    let verb: String
    let scope: Scope
    let doors: Set<Door>
    /// Display shortcut ("⌘⇧D") — nil for unshortcut acts. The SwiftUI key
    /// wiring lives with the menu (`EditorCommands.keyEquivalent`); the
    /// walk asserts every shortcut label has a key mapping.
    let shortcutLabel: String?
    /// R118 parity — non-nil for every editing capability.
    let takesAccess: TakesAccess?
    /// What invoking answers where nothing can act (honest, ops-shaped
    /// copy — the router speaks this for an unhandled dispatch).
    let unavailableNote: String
    let availability: @Sendable (CapabilityContext) -> Availability
    /// 13e E14 (W26): the SYSTEM chord — the one a `.systemHotKey`-doored act
    /// wears while any app is frontmost ("⌃⌥⌘N").
    ///
    /// Separate from `shortcutLabel` because they are separate keys reaching
    /// separate mechanisms: `shortcutLabel` is the in-app chord SwiftUI wires
    /// (⌘⇧N for the quick note), this is the chord Carbon registers with the
    /// system, and an act can honestly wear both. It is the ONE source for
    /// the system registration — `GlobalHotKeyChord` parses it into the pair
    /// `RegisterEventHotKey` takes — so the words in the helper and the keys
    /// the system grabs cannot drift.
    ///
    /// `var` with a default, deliberately: a `let` with a default is omitted
    /// from the memberwise initializer entirely, and the point of the default
    /// is that ~130 declarations that own no system chord say nothing at all.
    var systemShortcutLabel: String? = nil
    /// **VX-560 (the VX-439 run, A-439-12) — a second key for the same act**,
    /// reached by its own door rather than a menu key equivalent ("⌘←" on
    /// Back — `BrowserNavKeyMonitor`, live only while no text holds the
    /// keyboard). The MENU keeps showing `shortcutLabel`; this is the
    /// registry's record of the alternate, and the helper (⌘/) shows it.
    var alternateShortcutLabel: String? = nil

    /// **A door's label with its DECLARED chord appended** — "Copy All Takes
    /// (⌘⇧C)" — and the ONE formatter that composes the two, so a key she
    /// re-picks moves in the registry alone.
    ///
    /// Ladder round A (A-4): the take card's context rows typed their chord
    /// suffixes by hand beside a registry that already declared them, which
    /// AR-1(e) makes concretely expensive — the ruling leaves ⌥⌘⏎ / ⇧⌥⌘⏎
    /// hers to re-pick, and a re-pick had three homes to visit (the registry,
    /// the menu row, the helper list) with nothing making them agree. Now the
    /// declaration is the source and `TakeCardMenuCopy`'s pin is the guard.
    ///
    /// `title` overrides the verb where a door speaks in its own words (the
    /// card's "＋ New take — branch of this one" is a sentence, not a menu
    /// verb); an unshortcut act renders its words unchanged.
    func menuTitle(_ title: String? = nil) -> String {
        let base = title ?? verb
        guard let shortcutLabel else { return base }
        return "\(base) (\(shortcutLabel))"
    }
}

nonisolated enum CapabilityID: String, CaseIterable, Sendable {
    // Structural (block scope)
    case divide, extract, makeBlock, merge, deleteInEveryTake, addBlockAtEnd
    // 13j J4/J4b — the two ceremony doors, declared beside the verbs whose
    // defaults they used to BE (her sitting round-4 ruling: the Block menu,
    // the block context menu AND ⌘K, with ⌥⌘⇧D / ⌥⌘⇧M — the plain chord
    // plus ⌥, the same "deliberate variant" modifier the ⌥⌘Z family wears).
    case divideWithCeremony, mergeWithCeremony
    case insertBlockBelow  // 13b 4D (N28's second half; S4-13: native in BOTH editors)
    case deleteBlock       // 13c 1B (A8): the delete door where she writes
    // 13j, her round-7 ruling ("do you think that we should add block level
    // archive? I think that it might be worthwhile"): block ARCHIVE — kept
    // forever in this note's tray, no clock. Two doors, both summoned: the
    // Block menu and the block's own context menu.
    case archiveBlock
    // The take family (take scope)
    case showTakes, newTake, blankTake, blankTakeAsChosen, chooseTake
    case previousTake, nextTake, archiveTake, saveChoicesAsLens, closeAllTakes
    case pageFanBack, pageFanForward
    case divergeHere, diffAgainstChosen
    // 13f W10b: the lineage door back to a RELEASED original (block scope,
    // rendered only where one exists — P-2)
    case showOriginBlock
    // 13j J2: the per-note TRAY — what this note has deleted, and what a
    // divide/merge preserved whole (post scope; two doors, one act)
    case showNoteTray
    // The post-13l polish round (ledger row 17, G2) — **THE BLOCK HISTORY
    // PANE**, her second-sitting ruling: the door sits in the bottom chrome
    // beside Commit, because *"history is quite similar to commit, it's the
    // natural pair to commit"*.
    case showBlockHistory
    // The post-13l polish round (ledger rows 16/23, G1 + the V-family) — **THE
    // WHOLE-NOTE VERSIONS DOOR**, her ruling: *"an easy door would be to make
    // a copy of the note, archive it, and then let you look through the
    // archived copies made at points in time."* Two acts, post scope: saving a
    // moment (⌘⇧S) and opening the listing of them.
    case saveNoteVersion
    case showNoteVersions
    // VX-372 (VX-383 U1 — D-C-2): DUPLICATE A NOTE, declared at last — her
    // ticket, *"a direct duplicate door, with tags / without tags; a duplicate
    // with tags counts as tagging"*. TWO acts (one verb each, P-C-1's words):
    // the copy WEARS the note's tags, applied so books that collect a tag hear
    // it (`Operations.DuplicateTags.applied`), or wears none. The old inline
    // "Duplicate as Version" rows (never declared) route to the first.
    case duplicateNoteWithTags
    case duplicateNoteWithoutTags
    // 13l Act 2 (ledger item 3) — DELETE NOTE, at last. Her report at 13j's
    // close was that she could not find a way to delete the note she was
    // standing in; the Library and the Pool had a door and neither asked
    // anything first. ONE act, four renderers: both bottom bars' `note ▾`
    // menus and the two note-row lists.
    case deleteNote
    // …and its bulk twin, over the Library's ⌘-click selection (her ruling's
    // third clause). Its own declaration rather than a mode on `.deleteNote`,
    // for the `.moveTakeEarlier`/`.moveTakeLater` reason: it is its own door
    // on its own surface with its own enablement (a selection exists), and one
    // declaration could not say that.
    case deleteSelectedNotes
    // The post-13l polish round (ledger row 25 — the review pass's
    // FOUND-ITEM 2: *"the archive-a-note door's home has never been
    // walked"*). ARCHIVE THIS NOTE: the third verb on a note row, beside
    // delete and open, and until now the only one of the three nobody had
    // declared. It shipped as an undeclared inline button in two row menus,
    // acting in silence — which on a list that then drops the row reads
    // exactly like a deletion. Declared so the door-set is checkable the way
    // `.deleteNote`'s is, and so the receipt (`RecoveryCopy
    // .archivedNoteReceipt`) names where the note went.
    case archiveNote
    // VX-425 (the VX-439 run, A-439-16) — RENAME A NOTE, declared at last: her
    // ask (2026-10-18) plus a beta tester's — "two-finger click on an Open row
    // … gets a menu: Rename, Delete note, Close". The Library's row has carried
    // an undeclared "Rename…" since 9d; the sidebar's note rows are its second
    // renderer, so the act is declared once and both read its verb.
    case renameNote
    // 13j batch 6b (J1 — her round-3 rider, verbatim: "have a delete now
    // option WITHIN the trash (not from within the normal note) … but never
    // accidental full delete from within a note, but an option for full
    // delete without waiting"). TWO `.surface` acts rendered by the Trash
    // surface ALONE — no other renderer may ever carry them, which the
    // surface-walk union enforces by construction. Both confirm: Delete Now
    // EVERY time (round 10 — no session-scoped don't-ask), Empty Trash once
    // naming the FULL count by kind (round 8 — "everything, always").
    case deleteNow, emptyTrash
    // 13u4 UNIT C2 — her 13u3 morning addition, item 9, verbatim: *"Having a
    // command where you could highlight part of a block and move it into a
    // take on that block (out of the take it's currently in) would be a nice
    // time saver."* Its semantics were hers and she ruled them at the 13u4
    // kickoff sitting (R-13u4-4): MOVE alone, with the quiet savepoint of the
    // take it left as her cover for the stay case.
    //
    // Its own declaration rather than a mode on `.extract`: extract mints a
    // BLOCK beside this one from a boundary-adjacent span, this mints a TAKE
    // on this one from any span, and one declaration could not say that (the
    // `.moveTakeEarlier`/`.moveTakeLater` grounds).
    case moveSelectionToTake
    // Takes lifecycle completeness (13b Stage 3, 3D — T5/N1/N6)
    case unarchiveTake, labelTake, renameLens
    // The post-13l polish round (ledger row 14 / F1 — the take-card grammar
    // made uniform): a take's LOCK and its DELETE. Both have been rendered
    // since Phase 7 — Write's takes panel carries them on every card's ⋯ —
    // and neither was ever declared, so the one grammar rule (Archive · Label
    // · Lock · Delete) had nothing to hold it and the Takes board's cards
    // quietly carried two of the four.
    case lockTake, deleteTake
    // 13j, sitting round 5 — DELETED takes get a door at last. The sweep at
    // the sitting found there was no `restoreVariant` op and no deleted-take
    // query anywhere: a deleted take was unreachable forever, while the
    // phase's own bar names takes ("deleting things — blocks, notes, takes —
    // and getting them back is obvious, honest, and calm"). A `.surface`
    // act, the `.unarchiveTake` class exactly: the target is the ROW you
    // point at in the History face, so no routed context command could name
    // it without guessing which take she meant.
    case restoreTake
    // 13e E4 (her A19: "Reorder takes"). TWO declarations rather than one
    // "reorder" act, for the find/formatting families' reason: each is its own
    // door on the card, each renders its own enablement (the first card cannot
    // move earlier), and one declaration could not say that. `.surface` acts —
    // the target is the CARD you point at, which is the archived-card class
    // (3D's precedent), not a routed context command.
    case moveTakeEarlier, moveTakeLater
    // 13e E3 (her A18: "⌘-click in Takes to select blocks to merge; merge
    // several when they have no takes"). ONE act with two door families: the
    // article cell's context menu, and the selection banner the board raises
    // while a selection exists. The SELECTION gesture itself (⌘-click) is not
    // a door — it is how the act's target is named, like a text selection in
    // Write.
    case mergeSelectedBlocks
    // 13e E2 (her A17, verbatim: "delete several blocks at the same time
    // from a post - highlighting all of the blocks perhaps? block highlight
    // instead of text highlight across blocks?"). ONE act over the SAME
    // block selection `.mergeSelectedBlocks` reads — hosted by both post
    // surfaces that can carry one (Write's editor, the Takes board), which
    // is why its availability is the take family's rather than the board's.
    case deleteSelectedBlocks
    // 18c batch 3 (her U-6, 2026-09-06, verbatim: "a 'make all newlines
    // blocks' button… that automatically just leaves any take at the top
    // paragraph of its block"). THREE acts, not one flag, for the
    // `deleteBlock` / `deleteSelectedBlocks` reason — they address three
    // different things and each must be able to say so: the whole NOTE, the
    // block you are standing in, and the blocks you picked.
    case splitEveryNewlineIntoBlocks
    case splitBlockAtNewlines
    case splitSelectedBlocksAtNewlines
    // 13e E6 (her A21, verbatim: "keyboard shortcut for copying all takes
    // together to clipboard, or turning all takes into their own blocks").
    // The CLIPBOARD half: the block's whole fan as text, in the app's OWN
    // ratified export shape (the shown take, then its labeled "Alternates"
    // section — literally the format her 2026-07-25 intake note was exported
    // in). Reads only; writes no row.
    case copyAllTakes
    // 13e batch 3 (her A20: "shortcut for moving a take into being a new
    // block beneath the current block"; her A21's second half: "or turning
    // all takes into their own blocks" — the A45 repair tool). TWO
    // declarations, not one "convert" act: one addresses a TAKE and one
    // addresses a whole FAN, each carries its own key, and one declaration
    // could not say that (the find/formatting families' reason). Built under
    // architect ruling AR-1: mint-copy, the source take ARCHIVED.
    case takeToBlockBelow, takesToBlocks
    // Scrap tagging (13b 4D — N32(c)/S4-15: the one canvas-only door grows
    // registry-declared siblings on the scrap rows)
    case tagBlock
    // Scrap DELETION (the post-13l polish round, ledger row 4(b) — her A4
    // ruling): "Tags…" was the only row a scrap's own context menu offered,
    // so getting rid of a line you can see meant opening the scraps editor.
    // Its own act rather than a door on `.deleteBlock` for `.tagBlock`'s
    // reason — the target is the row you right-clicked, never a caret in an
    // open note. See the registry's declaration for the whole argument.
    case deleteScrap
    // The post-13l polish round (ledger row 14 / F1, her *"archive rides
    // beside delete"*): the scrap row's third verb, declared exactly like
    // its harsher twin above and for the same reason — the target is the
    // row you right-clicked.
    case archiveScrap
    // NOTE tagging (13e E8 — her 13f round-11 ask, both halves): the chips'
    // ＋ / ✕ doors, wherever they are rendered — the context bar (R6-1) and
    // the Library's note rows. ONE act, its renderers enumerated, on the
    // `.tagBlock` pattern one scope up.
    case tagNote
    // The canvas BANK (13e E7 — her sitting Round 2 pick): the strip's own
    // toggle, and the card door that sends a placed card back to it.
    case toggleCanvasBank, returnCardToBank
    // Commit + undo/redo (13c 1B — A10 adds the redo half)
    case commitTake, structuralUndo, structuralRedo
    /// 13n-b U4 (R-13nb-23 (a), AF-11 F-2): the offer door's KEYBOARD road —
    /// "Show the AI's Last Change" (⌥⌘O), session-scoped.
    case showLastAIChange
    // Post scope
    case sealPost
    // Write-editor-scoped doors the menu renders
    case previousBlock, nextBlock, blockComments, callout, exportCaretBlock
    // VX-183 (the VX-282 run, U5 — VX-179 U1's O-2): THE COMMENTS PANEL'S
    // DOORS, declared at last. `blockComments` above is the door INTO the
    // panel; these six are the acts the panel renders inline on its own rows
    // (`.surface` — each acts on the comment it sits beside, never a routed
    // context): the composer's Add; a live comment's Save and Revert (only
    // while it holds unsaved changes) and Delete; a deleted comment's Restore
    // and Delete forever… (the fold is a trash surface — the evolved purge
    // rule). P-1's grow-as-touched letter: undeclared since 13u3 A2, they join
    // as the panel's own work (VX-257) touches it. Which row renders which is
    // the pure `CommentsPanelDoors` rule — gating as data.
    case addComment, saveComment, revertComment, deleteComment
    case restoreComment, deleteCommentForever
    // In-post find & replace (QoL batch 3 — L6). FIVE declarations rather
    // than one submenu-owning act: four of the five carry a KEY, and four
    // undeclared keys sitting in the one place keys are declared is exactly
    // P-1's collision-drift class.
    case findInPost, findNext, findPrevious, findAndReplace, useSelectionForFind
    // 13e E9: the SIXTH member of that family — the takes-aware replace. Its
    // own declaration for the family's own reason: it is a distinct act with
    // a distinct verb and its own honest refusal, and a scope hidden inside
    // another act's implementation is exactly what P-1 forbids.
    case replaceAllInEveryTake
    // 13g batch 3 (L8/L9) — the FORMATTING acts over markdown-as-content
    // (her rulings F-1…F-3). SEVEN declarations rather than one submenu-owning
    // act, for the find family's reason: two of them carry a KEY, and an
    // undeclared key in the one place keys are declared is P-1's collision-
    // drift class. `.formatHeading` alone owns a submenu (Heading 1/2/3) —
    // the `.callout` shape, where the sizes are the act's shades and only the
    // act itself is a capability.
    case formatBold, formatItalic, formatStrikethrough, formatCode
    case formatHeading, formatBulletList, formatChecklist
    // 13g batch 4 (L10): links were ruled IN at the sitting (F-5) and shipped
    // in batch 2 with a face but no DOOR — the only way to make one was to
    // type the brackets. This is the door.
    case formatAddLink
    // 13k K8: nesting. Her ruling gave Tab the indent; sitting Q3 gave ⇧Tab
    // and these two menu rows the way back. Declared like the keyless five,
    // and deliberately WITHOUT a `shortcutLabel`: Tab is not a menu key
    // equivalent and must never become one (⇥ as a menu chord would steal
    // Tab from every control in the app), so the keys live where ⏎'s does —
    // in the surfaces' own `insertTab`/`insertBacktab` overrides.
    case formatIndent, formatOutdent
    // Modes + app scope
    case switchMode
    // 13f batch 3 — the NAVIGATION core (her W3/A27 + W16 rulings): the
    // window's open notes and the pane's back/forward. `openNote` is ONE
    // declaration for the whole ⌘⇧1…⌘⇧9 family, exactly as `switchMode` is
    // one declaration for ⌘1–⌘6 — a family of ordinal keys wired per index
    // by the menu, with every one of them a menu item (R73/R91/R93).
    case openNote, navigateBack, navigateForward
    // VX-287 / VX-289 (the VX-283 run, U1) — CLOSING from the keyboard and the
    // menu, her ruling (2026-10-13): *"for command W - can we do shift
    // command W? i like that better than control, it's more natural to type.
    // i think landing in the next note on the list is perfect-that way you
    // can close them all quickly."* — and, for Close All, *"close all now is
    // good"* (her VX-283 triage). TWO declarations on the
    // `.moveTakeEarlier`/`.moveTakeLater` grounds: each its own door, words
    // and enablement (one needs a note in the pane, the other an open row).
    // Both are VIEW-ONLY — a row and a pane are view state; no note is
    // touched.
    case closeNote, closeAllNotes
    // (13f batch 5's `toggleTagChips` — W20(b)'s fold, repointed by 13k
    // K11/K12 at the tag cards — RETIRED at the Act 10 correction round,
    // row 15: the masthead has ONE tag door, and ⌘⇧I now belongs to
    // `.tagNote`, the act itself.)
    // The Act 10 correction round, batch A (row 2) — the SIDEBAR's own
    // show/hide. It was the system split view's undeclared toolbar button;
    // the flat `ShellSplit` makes it ours, so it is declared like every
    // other door: a toolbar door and a View-menu item on the platform's own
    // ⌃⌘S. App scope; only a full window has a sidebar (the menu's gate
    // reads the window kind, not this table).
    case toggleSidebar
    // 13f batch 4 — the SPLIT (her W1/A25 ruling, two panes in v1). Both
    // are app-scope stack gates like the navigation family: one needs a
    // note to put beside, the other needs a split to close.
    case openBeside, closeSplit
    // 13f batch 5b — W2/A26's second window kind (her round-2 ruling: *File
    // ▸ New Window = a full app window; "Open in New Window" on a note = a
    // lightweight note-only window*). ONE declaration on the note-row
    // family, exactly as `.openBeside` is — the Open strip, the Library
    // catalog and the Pool all render it from here. `File ▸ New Window`
    // deliberately has NO declaration: it is a system-standard File item
    // and nothing else in this registry duplicates one (the ruled reason).
    case openInNewWindow
    // 13f batch 6 — W4's STARS (her round-3 ruling). ONE act, two door
    // families: the note-row menu (the `.openBeside` family — the Open
    // strip, the Library catalog, the Pool), the shelf's book rows, and
    // ⌘K by name. No key: her ruling named a menu and the palette, and an
    // invented chord would owe a collision sweep no ruling asked for.
    case toggleStar
    // 13f batch 6 — W5's QUICK NOTE (her round-3 ruling, and round 14's
    // four edges). ONE declaration behind three doors: the menu-bar extra
    // (her round-14.1 — the summon-from-anywhere door, permission-free),
    // ⌘⇧N, and a File-menu item. The TRUE system-wide hotkey is out of v1
    // by her ruling (round 14.4 — ledger row W26).
    case quickNote
    // The peer column's open door in Compare (her W16 second half: *"in
    // compare … you should be able to click on the post you're comparing
    // it with"*). A `.surface` act — its target is the column you point at.
    case openPeerPost
    // 13f batch 5 — W23's DIVERGE FOR THIS BOOK (her round-10 item 4). A
    // `.surface` act for the same reason `.openPeerPost` is one: its target
    // is the BOOK ROW you point at in the membership chip, so no routed
    // context command could name it without guessing which book she meant.
    case divergeForBook
    // 13e E11 — THE BOOK ASCENT, declared at last. It has WORKED since Phase
    // 13 (the membership chip's book rows) and 13k K11 (the context bar's
    // book icon) and was never in this catalog; #55(i) recorded the omission
    // and she ratified it with the declare-it alternative left open ("13e's
    // if ever wanted"), then asked for it directly: *"the registry should be
    // kept up to date, and keeping the registry up to date should be part of
    // the plan."* ONE act, two door families — nothing user-visible changes.
    case openBookAtNote
    // 13i-b U2 — THE ARRIVALS FACE's two judgment doors (the 13i-b plan §3;
    // the sitting record §4: Add · Dismiss — the copy-in arm is 13i-c's).
    // TWO declarations, on the `.moveTakeEarlier`/`.moveTakeLater` grounds:
    // each is its own door on the row with its own refusal, and one
    // declaration could not say that. Both are `.surface` acts whose target
    // is the ARRIVAL ROW you point at on the line — the `.archiveNote` class.
    case seatArrival, dismissArrival
    // 13i-b U3 — THE RULE EDITOR's door (the 13i-b plan §4 item 1): one
    // act on a shelf row's menu, for a gathering's rule and a book's intake.
    case editRule
    // 13i-b U3 — THE TWO STRENGTHENING DOORS (the sitting record §3: "two
    // doors"), visibly different: BIND makes the gathering's own row a book
    // in place (§19.6; it keeps collecting, §14.6) — the door 13c 2D shipped
    // as the smart→curated conversion, now declared — and SPAWN seeds a
    // sibling book from the rule. Two declarations on the
    // `.moveTakeEarlier`/`.moveTakeLater` grounds: each its own door with its
    // own words, and one declaration could not say that.
    case bindIntoBook, makeBookFromGathering
    // 13i-c U3 — THE BOOK'S STATE DOORS (the sitting record §5, §6; the
    // 13i-c plan §5, R-13ic-3). Six declarations, three PAIRS, on the
    // `.moveTakeEarlier`/`.moveTakeLater` grounds: each is its own door with
    // its own words and its own confirm (or none), and one declaration could
    // not say that. Which of each pair a book renders is DATA
    // (`BookStateDoorSet`), never a per-view if. Finish/Reopen were the
    // shelf's own vocabulary until now ("never registry acts"); they join
    // here because the settings sheet renders them too — one act, two
    // surfaces, one declaration.
    case finishBook, reopenBook, sealBook, unsealBook, ownBook, unownBook
    // 13i-c U3 — DELETE A BOOK (or a gathering) to the Trash: declared here
    // because R-13ic-4's face renders it on the rule editor ("Delete this
    // gathering…"); the shelf's "Delete Book" is its other renderer (the
    // owned-book two-choice confirm and the settings sheet's door are U4's,
    // which extend THIS declaration — one act, never a second id).
    case deleteBook
    // 13i-c U4 — THE MEMBERSHIP CHOICE's two ceremonies (the sitting record
    // §6: "copy in (original keeps its lives) or move in (other memberships
    // severed, listed)"; the 13i-c plan §3/§4 rows 14–19). Two declarations
    // on the `.moveTakeEarlier`/`.moveTakeLater` grounds — each its own door
    // with its own words and its own refusal. Both are `.surface` acts whose
    // target is the choice sheet's pair or the ARRIVAL ROW you point at.
    case copyIn, moveIn
    // 13i-c U4 — THE REMOVE/RELEASE DOOR (the sitting record §20): ONE act
    // whose verb is a per-target function ("Remove from This Book", "Release
    // from This Book" on an owned book — `RemoveFromBookCopy.verb(owned:)`),
    // rendered by the book's note-row menus, the note box's book context, the
    // membership chip's rows and Manage Notes…. A gathering holds no
    // membership, so its honest door is a SECOND act — `.removeRuleTag`
    // ("Remove the #tag", `removeTag`), the chip's — on the
    // `.moveTakeEarlier`/`.moveTakeLater` grounds: a different op, different
    // words, a different refusal.
    case removeFromBook, removeRuleTag
    // 13i-c U4 — DUPLICATE BOOK… (the sitting record §6; the plan §6): the
    // shelf row's menu. ONE act whose verb follows the book ("Duplicate with
    // Copies…" on an owned book — `DuplicateBookCopy.verb(owned:)`).
    case duplicateBook
    // 13i-d U1 — THE BOOKCASE'S doors (the sitting record §7, §19–§24). The
    // shelf name's right-click carries six acts (§7: "Rename · Set Glyph ·
    // Make Default · Delete", §24: "+ Move to Start / Move to End"); the
    // "+ shelf" word is the one `.surface` door; a book row gains three (Move
    // to Shelf ▸, and my order's Send to Top / Send to Bottom — §20). Ten
    // declarations on the `.moveTakeEarlier`/`.moveTakeLater` grounds: each
    // its own door with its own words and its own enablement. The view-local
    // controls (the strip's solo, the № census, order ▾, details, a header's
    // collapse) are NOT acts — they change what she sees, never the store —
    // exactly as the Library's `sort ▾` and day filter are undeclared.
    case newShelf, renameShelf, setShelfGlyph, makeDefaultShelf
    case moveShelfToStart, moveShelfToEnd, deleteShelf
    case moveBookToShelf, sendBookToTop, sendBookToBottom
    // 13i-d U2 — THE BOOK PANEL (the sitting record §15's 13i-d line; her
    // design, the identity brief's round 5: *"a book table of contents kind
    // of view with chapters + notes … in the right side pane"*). ONE
    // `.surface` door opens it — the note masthead's book icon, drawn only
    // while the note is a member of a book (P-2). Five `.contextMenu` acts
    // are its structure doors, each the MENU TWIN of a drag inside the panel
    // (every drag keeps a menu twin for discoverability and AX; U1's
    // "synthetic drags never commit" reason was F-B2-1's undeclared-type
    // defect, fixed in 17y B2), all composed over the EXISTING ops (`assignPostToSection`,
    // `reorderReadingPost`, `reorderSection` — no new semantics). Separate
    // declarations on the `.moveTakeEarlier`/`.moveTakeLater` grounds: each
    // its own door with its own words and its own enablement (Move Up hides
    // on a chapter's first note). The panel's other doors are declared
    // already: the click-through is `.openBookAtNote`, the remove door
    // `.removeFromBook`, a gathering's untag offer `.removeRuleTag`.
    case showBookPanel
    case fileNoteInChapter, moveNoteUpInBook, moveNoteDownInBook
    case moveChapterUpInBook, moveChapterDownInBook
    // 13i-d U3 — THE COLLECTING PANE'S DOORS and THE FILTER BAR's one write
    // (the sitting record §4: the settings sheet "reachable from the book's ⋯
    // menu and the Bookcase row's context menu"; §10: the journal-trait row
    // "one sentence in the Collecting pane's sheet"; §18.1: "the 'Save this
    // filter as a gathering' door"). Three declarations on the
    // `.moveTakeEarlier`/`.moveTakeLater` grounds — three different acts with
    // their own words and refusals. Opening the sheet is declared for the
    // `.showBookPanel` reason (a door onto a surface IS a user-facing act);
    // the grouped-by control and the filter's terms are NOT acts — they
    // change what she sees, never the store (the Library `sort ▾` precedent).
    case openBookSettings, setJournalTrait, saveFilterAsGathering
    // 13o U3 — SEARCH WITHIN A BOOK (her R-13o-14: the masthead's
    // magnifying glass, "only expand it when clicked on"; the architect's F1:
    // the answer sheet's small sibling in place of the book's content). The
    // glyph is a door onto a surface — declared for the `.openBookSettings` /
    // `.showBookPanel` reason; the field's words and its chips are not acts
    // (they change what she sees, never the store — the Library band's
    // class, U2's registry record).
    case searchThisBook
    // VX-217 (2026-10-13 — her "make sure that new note button exists on
    // gatherings … the bottom of a book and the bottom of a gathering should
    // look the same"; option (A) + R-VX214-3/4, the run record): a NEW NOTE
    // BORN INSIDE A GATHERING — minted wearing what the rule needs
    // (`Operations.newPostInGathering`). Its own act beside the book's
    // undeclared surface door, on the `.removeFromBook`/`.removeRuleTag`
    // grounds: different words, different refusals. `.surface` — the
    // gathering's navigator foot and the Outline flow's end, both drawn
    // ALWAYS and greyed with the reason where the act can't land
    // (R-VX214-3), never hidden.
    case newNoteInGathering
    // VX-570 (the VX-439 run, A-439-4 + C-570-1) — her 10-21 note: "command
    // for new note within a book". ⌥⌘N mints a member of the book the focused
    // pane shows, through the SAME act the book's own foot door runs (a note,
    // an entry on a journal-trait book, the planner's note on a gathering);
    // the foot's and the Outline flow's "+ new note"/"+ new entry" are its
    // `.surface` renderers.
    case newNoteInBook
    // 13i-d U4 — A BOOK'S ARCHIVED LINE (her #169(a)(1) ruling — the 13i-d
    // plan item 9): its two row doors are **Unarchive** (NEW — the archived
    // line is its one declared renderer; the Library's Archived view carries
    // an older inline twin, undeclared — a finding for that surface's touch)
    // and the shared `.removeFromBook` (declared already). And the F-U3-5
    // rider (the adjudication after U3): a GATHERING's hide-owned chips in the
    // settings sheet (13i-c U3's three-state row, `setReadingHideOwned`)
    // were an undeclared act — declared here, rendered by the sheet.
    case unarchiveNote, setReadingHideOwned
    // 13i-d U5 — WINGS (the sitting record §9; §21 Direction C; R-13id-2).
    // The switcher's three acts are its menu's `.surface` doors (the Bookcase
    // masthead — `WingSwitcherMenu`); SWITCHING is a view choice (a local
    // memory, never the store) and stays undeclared, the Library `sort ▾`
    // precedent. The two note doors join the NOTE-ROW grammar
    // (`SidebarView.contextMenuCapabilities` — the Library's and the Pool's
    // rows render them; the Open strip does not, `.deleteNote`'s reason).
    case newWing, renameWing, deleteWing
    case moveNoteToWing, copyNoteToWing
    // 13i-d U5b — THE BOOK-MOVE HALF (R-13id-6 item 9, the U5 RECORD's
    // proposal ruled whole): the Bookcase book row's "Move to Wing ▸"
    // (`.contextMenu`, books AND gatherings, never the daily Journal) and the
    // switcher's "Move Everything to Another Wing ▸" (`.surface`, additional
    // wings only — her R-13id-4 backdoor).
    case moveBookToWing, moveWingContents
    // 13i-e U2 — BOOK ARCHIVE (her kickoff rulings R-13ie-1…4: a book — or a
    // gathering — put away under Archived, kept forever, out of the
    // Bookcase). Two declarations on the `.moveTakeEarlier`/`.moveTakeLater`
    // grounds: each its own door with its own words (Archive may ask on an
    // OWNED book — the delete confirm's twin; Unarchive never asks). WHICH of
    // Archive · Unarchive · Delete a book renders is DATA
    // (`BookArchiveDoorSet`): the daily Journal never renders Delete (P-2 —
    // the op refuses it, `dailyJournalCannotBeDeleted`).
    case archiveBook, unarchiveBook
    // `.importFiles` — 13n-a: File ▸ Import… is the VARIORUM DOCUMENT
    // FORMAT's door (a file, or a folder that becomes a book — R-13n-8), and
    // its second renderer is the Bookcase's drop (`.surface`).
    case newPost, todaysEntry, findAnything, importFiles, exportLibrary
    /// 13n-a (R-13n-11 — the push gesture, her rider "be sent some document /
    /// info as context for a question"): the note in the Variorum document
    /// format onto the clipboard, for any chat anywhere. Post scope; the two
    /// `note ▾` menus and ⌘K render it. Reads only.
    case copyForAI
    /// VX-125 (the VX-439 run, A-439-1): Copy full text's text as a `.md`
    /// FILE — File ▸ Export Note… (⌥⌘S), ⌘K and both `note ▾` menus. Post
    /// scope; reads only.
    case exportNote
    case toggleSeams, helper
    case restoreTutorial
    /// pre-13u Act 10 (the tenth wave's ruling — "Restore door - yes,
    /// let's do it"): the sample library's tutorial-style restore. Unlike
    /// the tutorial's replace, this door only MINTS WHAT IS MISSING
    /// (`SampleLibrarySeeder`'s resumable seed) — nothing of hers is ever
    /// deleted, so no confirm gates it.
    case restoreSampleLibrary
    // (`restoreEncryptionBook` — pre-13x 5a — RETIRED at 13s-b U1b,
    // R-13s-37: "encryption explained not present and not restorable".)
    /// 18l-c U6 (R-18l-11): the Jekyll book's restore — the same
    /// mint-what's-missing door, for the book that holds takemania (its
    /// title lowercased at 13s-b U1b, R-13s-38). A deleted takemania note
    /// comes back FRESH, history and all (the front matter's R-18l-12
    /// promise).
    case restoreJekyllBook
    /// 13s-b U1b (R-13s-37, "classics restorable"): the classics
    /// GATHERING's restore — adopt-or-mint on Welcome from the `#classics`
    /// tag, the retired arrangement step's shape behind an explicit door.
    case restoreClassicsGathering
    /// 13s-b U1a (R-13s-2/6/13): **the tour's ONE entry** — the first-open
    /// offer line's "yes" (`.surface`) and Help ▸ Take the Tour (`.menuBar`,
    /// piece 5). App scope; always available as an act — it starts the U2
    /// tour engine at step 1 (Q12: a mid-tour request starts over; no
    /// resume state exists).
    case takeTour
    // 13l Act 4 (ledger rows 11–12) — Settings ▸ Data Safety's three acts.
    // `.surface` for the `.deleteNow` reason: their target is the pane you
    // are looking at, and their per-gesture conditions (is a folder set? is a
    // run already going?) are that pane's own state, not app-scope context —
    // the `.deleteSelectedNotes` precedent, which declined to push a
    // surface's own selection into `CapabilityContext`.
    //
    // Three declarations rather than one, on the `.moveTakeEarlier` /
    // `.moveTakeLater` grounds: each is its own button with its own
    // enablement (you cannot stop copying to a folder you never picked), and
    // one declaration could not say that.
    //
    // Deliberately NOT `.palette` or `.menuBar`: the automatic job is the
    // mechanism and the freshness face is the evidence — advertising a
    // manual button in ⌘K would promote the one road the design demotes
    // ("I forgot to press it for a month" is the failure this phase exists
    // to kill). Recorded so the omission reads as a decision, not a gap.
    case backUpNow, chooseBackupFolder, forgetBackupFolder
    /// pre-13x 3b (the postures design decision 15; copy §4): the decrypted
    /// `.sqlite` export — the one deliberate unencrypted escape besides the
    /// `.md` export; behind the passphrase (Castle, or Standard with one
    /// set); a user-chosen destination, never the backups folder, never
    /// scheduled. `.surface` like its three siblings above, for the same
    /// reasons — and never a palette door: an act that writes the whole
    /// library readable is not one to reach by a keystroke.
    case exportPlaintextLibrary
    /// 13x F1 (ladder R1-MAJOR; the 13x row's deliverable 1): the HAND-OFF
    /// act — ONE folder ("Variorum Library — <date>") holding a sealed
    /// snapshot of the open library and its key file's copy (the kickoff
    /// ruling QC's pair), produced somewhere findable and AirDroppable,
    /// revealed in Finder at completion. `.menuBar` (File's door) +
    /// `.surface` (Data Safety's twin) — one act, two faces. Deliberately
    /// NOT `.palette`, on its Data Safety siblings' grounds: an act that
    /// writes a travelling copy of the whole library is not one to reach
    /// by a keystroke.
    case handOffLibrary
    /// 13r U3-B (R-13r-5) — Settings ▸ Diagnostics' two acts on a RECEIVED
    /// crash report, `.surface` on the Data Safety precedent above: their
    /// target is the report card she is looking at, and the per-gesture
    /// condition (is this report text Variorum showed verbatim?) is that
    /// card's own. Send Report… is the support door's mail draft with the
    /// report attached — it OPENS A DRAFT, and never sends. Deliberately NOT
    /// `.palette` or `.menuBar`: a report is sent from where it was read,
    /// never by a keystroke from elsewhere — the verbatim-first promise
    /// would otherwise have a door that skips the reading.
    case sendCrashReport, deleteCrashReport
    /// VX-221 (2026-10-13) — SETTINGS ▸ TAGS' delete, declared at last (the
    /// registry walk recorded the tag manager's acts as an unclosed gap; this
    /// one closes as work touches it — create and rename stay the gap). ONE
    /// act, TWO doors: the row's visible trash (`.surface`, her "more obvious
    /// delete tag button rather than just two finger click") and the row's
    /// context menu (`.contextMenu`) — both open ONE confirm naming the
    /// consequence (the phone's sentence, hoisted — `TagDeletion`), because
    /// the delete is unrecoverable (the confirmation-consistency principle;
    /// VX-238 holds the missing restore road). Deliberately NOT `.palette`:
    /// a taxonomy delete is decided where the taxonomy is shown.
    case deleteTag
    /// 13n-b U1 — SETTINGS ▸ MCP's acts (R-13n-4/5; R-13nb-5), `.surface`
    /// on the Data Safety / Diagnostics precedent: each acts on the row she
    /// is looking at (a connection request, a client, a grant) or the pane's
    /// one command, and the MCP pane is their ONLY renderer. Approve… /
    /// Change… open the grant sheet, whose confirm is `.mcpGrantAccess`;
    /// Revoke on a client is a deny (P-13nb-U1-5). Deliberately NOT
    /// `.palette` or `.menuBar`: who may read the library is decided where
    /// the grants are shown, never by a keystroke from elsewhere.
    /// VX-515 (the VX-548 run): `mcpChangeClientAccess` — the client row's
    /// ADDING door, "Share a place…" (the id kept; it read "Change…");
    /// `mcpShareAnotherPlace` — Shared with AI's own add door, "Share another
    /// place…" (the sheet asking WHO, nothing replaced).
    case mcpApproveClient, mcpDenyClient, mcpChangeClientAccess, mcpRevokeClient
    case mcpRevokeGrant, mcpCopySetupCommand, mcpGrantAccess
    case mcpShareAnotherPlace
    /// 13n-b U2 — THE JUST-IN-TIME ASK's answer (AF-6; mockup §4), `.surface`
    /// on the MCP family's precedent: rendered ONLY by the ask sheet, which
    /// carries the one ask it answers (once · while connected · always ·
    /// don't allow — the durations the ask may offer).
    case mcpAnswerAsk
    /// 13n-b U2 — THE PRIVATE MARK (R-13nb-4): "Private — never shared with
    /// AI". The note's row lives in the note ▾ menu of both bottom bars
    /// (`.bottomBar`, beside Copy full text); the book's in the Book Settings
    /// sheet's State section (`.surface`). Gatherings and scraps never render
    /// it (the operations refuse them — P-2).
    case markNotePrivate, markBookPrivate
    /// 13n-b U3 — "ALLOW AI HERE" (R-13n-11's connected push gesture; AF-8,
    /// AF-10 (e)): the note ▾ menu's submenu of approved clients, each
    /// sharing THIS note read · once. Rendered beside the Private row in both
    /// bars (`.bottomBar`), NOTE contexts only, and only when a client is
    /// there to offer (P-2).
    case mcpAllowHere
    /// 13n-c U3 — GRANT FROM WHERE YOU ARE (VX-156 items 2/3; VX-270 · VX-271 · VX-164 · VX-272).
    /// Every one renders ONLY while an approved client exists (VX-272 — the
    /// window's `MCPShareRoad.canShare`; with none, no door, and the
    /// zero-state lives in Settings ▸ MCP). `mcpShareHere` — "Share with AI…"
    /// on a note row's and a book row's menu (`.contextMenu`, the row it is
    /// on); `mcpShareNotes` — the Library bulk bar's "Share N notes with AI…"
    /// (`.surface`, the ⌘-click pick); `mcpShareBook` — Book Settings' grant
    /// row's Share… (`.surface`); `mcpShareThisNote` — ⌥⌘A, the Edit menu
    /// (`.menuBar`); `mcpShowSharing` — the ONE shared icon (VX-271) on a
    /// Bookcase row and in the note's indicator (VX-164), whose click shows
    /// the permission; `mcpChangeGrant` — that popover's Change…, which
    /// REPLACES the grant it names (T-U3-8) while the place confirmed is that
    /// grant's own (VX-516 — another place confirmed is a new grant);
    /// `mcpChangeClientAccess` stays the client row's ADDING door ("Share a
    /// place…" since VX-515).
    case mcpShareHere, mcpShareNotes, mcpShareBook, mcpShareThisNote
    case mcpShowSharing, mcpChangeGrant
    /// 13n-c U4 — ASKS WAIT QUIETLY + THE KEYBOARD (VX-156 items 4/5, VX-157;
    /// VX-271 · VX-157). `mcpOpenAsk` — the pending-ask GLYPH's press (on the thing
    /// an ask names) and Settings ▸ MCP ▸ Waiting's Answer…, each opening THAT
    /// ask's sheet (`.surface` — it carries its ask; arrival X: an ask never
    /// opens itself). `mcpSettings` — ⌥⌘, "MCP Settings…" in the app menu
    /// (`.menuBar`): Settings at MCP, at Waiting when an ask waits.
    /// `switchWing` — ⌘L "Switch Wing…" (`.menuBar`, app-wide — the type-to-
    /// filter switcher with held-⌘ L cycling) and the masthead's wing word
    /// (`.surface` — a click without typing CYCLES to the next wing, her
    /// VX-157). The 13i-d note that switching "stays undeclared" held for
    /// the in-menu picker (a view choice); a CHORD and a cycling door are
    /// doors, and P-1 declares doors.
    case mcpOpenAsk, mcpSettings, switchWing
    /// VX-258 (VX-246 U1b) — A SETUP WAITING FOR HER OK: a connection that
    /// presented, under the name of a client she approved, a setup key not
    /// copied for that client waits in Settings ▸ MCP ▸ Waiting (admitted with
    /// no reach). `mcpAllowRebind` — Allow: the name, its approval and grants
    /// untouched, moves to the new setup (`allowMCPRebind`);
    /// `mcpDeclineRebind` — Don't allow: the key forgotten
    /// (`declineMCPRebind`). `.surface` on the MCP family's precedent — the
    /// row carries its ask, and the pane is their only renderer.
    case mcpAllowRebind, mcpDeclineRebind
    /// VX-309 U1c — VX-451 (F-U4-1's option (a)): LOCK LIBRARY NOW, declared at last — ONE act, TWO doors: the File menu's
    /// item (`.menuBar`, ⌃⌘L — rendered only where the library can lock: Castle — `AppBootstrap.canLock`)
    /// and the new road's Protection pane, in the Castle-only "On this Mac" section beside the idle dial (`.surface` —
    /// `RoadCrossingsSection`). VX-329 U1 — P-VX309-U1c-4 (b): with today's road gone, the chord is the declaration's
    /// `shortcutLabel` (⌃⌘L), its key wired in `EditorCommands.keyEquivalent(for:)` and its row in the ⌘/ helper (the
    /// discoverability guard's demand, now met). Never `.palette`: locking is not a find-anything row.
    case lockLibraryNow
}
