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
/// in, over its chosen takes. The takes-aware find/replace and whole-library
/// body search are recorded future scope (owner 13e), per her L6 rider.
nonisolated enum FindAction: String, Sendable, CaseIterable {
    case show          // ⌘F — the find bar
    case showReplace   // ⌥⌘F — the find bar with its replace field
    case next          // ⌘G
    case previous      // ⇧⌘G
    case useSelection  // ⌘E — search for what's selected
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
    case toggleSeal
    case comments        // ⌘⇧' — the target block's comments panel
    case callout(CalloutEdit)  // 13c R2-2 (A13(a)): the target block's frame
    case pageFan(Int)    // ⌥⌘←/→ — page the focused block's take cards
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
}

nonisolated enum CapabilityID: String, CaseIterable, Sendable {
    // Structural (block scope)
    case divide, extract, makeBlock, merge, deleteInEveryTake, addBlockAtEnd
    case insertBlockBelow  // 13b 4D (N28's second half; S4-13: native in BOTH editors)
    case deleteBlock       // 13c 1B (A8): the delete door where she writes
    // The take family (take scope)
    case showTakes, newTake, blankTake, blankTakeAsChosen, chooseTake
    case previousTake, nextTake, archiveTake, saveChoicesAsLens, closeAllTakes
    case pageFanBack, pageFanForward
    case divergeHere, diffAgainstChosen
    // 13f W10b: the lineage door back to a RELEASED original (block scope,
    // rendered only where one exists — P-2)
    case showOriginBlock
    // Takes lifecycle completeness (13b Stage 3, 3D — T5/N1/N6)
    case unarchiveTake, labelTake, renameLens
    // Scrap tagging (13b 4D — N32(c)/S4-15: the one canvas-only door grows
    // registry-declared siblings on the scrap rows)
    case tagBlock
    // Commit + undo/redo (13c 1B — A10 adds the redo half)
    case commitTake, structuralUndo, structuralRedo
    // Post scope
    case sealPost
    // Write-editor-scoped doors the menu renders
    case previousBlock, nextBlock, blockComments, callout, exportCaretBlock
    // In-post find & replace (QoL batch 3 — L6). FIVE declarations rather
    // than one submenu-owning act: four of the five carry a KEY, and four
    // undeclared keys sitting in the one place keys are declared is exactly
    // P-1's collision-drift class.
    case findInPost, findNext, findPrevious, findAndReplace, useSelectionForFind
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
    // 13f batch 5 — W20(b)'s fold. Her ruling: the ascent's in-line and the
    // back chip are ONE bar with ONE hiding mechanism, *"even if just with a
    // keyboard command"*. App scope, always available: a bar you cannot see
    // is exactly when you most want the key that brings it back.
    case toggleContextBar
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
    case newPost, todaysEntry, findAnything, importFiles, exportLibrary
    case toggleSeams, helper
    case restoreTutorial
}
