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

/// Everything the menu bar / palette / bars route to "whichever post
/// surface is mounted". One channel, exhaustively typed — a surface handler
/// switches over this and the compiler keeps the four handlers complete.
nonisolated enum RoutedCommand: Equatable, Sendable {
    case takes(TakesCommand)
    case structural(StructuralAct)
    case deleteInEveryTake
    case commit          // ⌘S — commit the focused/caret take
    case addBlockAtEnd   // D3's third leg: a new block at the post's end
    case toggleSeal
    case comments        // ⌘⇧' — the target block's comments panel
    case pageFan(Int)    // ⌥⌘←/→ — page the focused block's take cards
}

// MARK: - Choreography intents (the ONE mode-switch choreography's payloads)

/// A fire-and-DO landing in Write (move-and-execute, R115/R118): where the
/// caret/selection lands, and what runs once the editor is live. One-shot —
/// parked on the `CommandRouter`, consumed by the arriving editor's first
/// render. Cross-mode text safety rides the per-post AutosaveCoordinator
/// (Stage 1a): the leaving surface's pending text and the arriving
/// surface's flushes serialize on one instance.
nonisolated struct WriteIntent: Equatable, Sendable {
    enum FollowUp: Equatable, Sendable {
        case structural(StructuralAct)
        case deleteInEveryTake
    }

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
/// so GO there and bloom, visibly).
nonisolated enum TakesLanding: Equatable, Sendable {
    case bloom(blockID: String)
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
    /// The structural undo stack has an entry.
    var undoAvailable = false
}

// MARK: - The capability declaration

nonisolated struct Capability: Identifiable, Sendable {
    enum Scope: Sendable { case block, take, post, book, app }

    /// Where the act's doors are rendered. The registry walk asserts every
    /// declared door is rendered by its surface and every rendered door is
    /// declared.
    enum Door: Sendable, Hashable, CaseIterable {
        case menuBar, contextMenu, bottomBar, palette
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
    // The take family (take scope)
    case showTakes, newTake, blankTake, blankTakeAsChosen, chooseTake
    case previousTake, nextTake, archiveTake, saveChoicesAsLens, closeAllTakes
    case pageFanBack, pageFanForward
    case divergeHere, diffAgainstChosen
    // Commit + undo
    case commitTake, structuralUndo
    // Post scope
    case sealPost
    // Write-editor-scoped doors the menu renders
    case previousBlock, nextBlock, blockComments, callout, exportCaretBlock
    // Modes + app scope
    case switchMode
    case newPost, todaysEntry, findAnything, importFiles, exportLibrary
    case toggleSeams, helper
}
