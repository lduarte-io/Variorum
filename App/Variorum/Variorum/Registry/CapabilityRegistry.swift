//
//  CapabilityRegistry.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (P-1): THE capability table — every routed act
//  declared once. This is what kills the Stage 0 matrix's bad-cell classes
//  structurally: an act's doors, availability, and refusal copy are data
//  here, and the surfaces (menu bar, bottom bars, take-card context menu,
//  ⌘K palette) render FROM it. The registry walk test asserts declared ⇔
//  rendered, that no act is unavailable in every mode, and the R118 parity
//  table (every editing capability reaches Takes natively or via
//  move-and-execute — Write is never privileged).
//

import Foundation

nonisolated enum CapabilityRegistry {
    // MARK: - Availability rules (pure, shared by families)

    /// Structural gestures: act where a Write editor is attached (detail,
    /// inline book editor, pool scraps); fire-and-DO from Takes/Lenses via
    /// the one choreography (R115/R118 — the D3 lecture's replacement);
    /// genuinely inapplicable elsewhere.
    private static let structural: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        if ctx.writeEditorAttached { return .act }
        switch ctx.mode {
        case .write: return .act  // the editor is mounting
        case .takes, .lenses: return .actElsewhere(.write)
        default: return .unavailable
        }
    }

    /// DIVIDE, alone among the structural verbs, acts NATIVELY on the
    /// takes/lenses boards since 13d Batch 3 (her A9: *"i desperately need
    /// divide in takes mode"*). The block it cuts and the take it seeds
    /// from are both things a board knows, and the ceremony mounts there —
    /// so there is nothing left for the choreography to carry. Extract,
    /// Make Block and Merge keep `structural` unchanged: they are span
    /// gestures over a whole document's tiling, which a board does not
    /// have (scope is divide-only, by the batch's own brief).
    private static let divideAvailability: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        if ctx.writeEditorAttached || ctx.takesBoardAttached { return .act }
        switch ctx.mode {
        case .write, .takes, .lenses: return .act
        default: return .unavailable
        }
    }

    /// The take family: native wherever takes are editable (Write's caret
    /// block, the Takes/Lenses boards, any attached editor — pool scraps
    /// included).
    ///
    /// 13c 2B: `mode == .takes` was the PROXY for "a takes board is
    /// mounted", and the proxy stopped being true the moment a board could
    /// mount outside a post detail (the book spread's takes page). The
    /// attachment itself is now the condition — same shape as
    /// `writeEditorAttached`, same reason: enablement must track the surface
    /// that actually acts, never the container it used to live in.
    private static let takeFamily: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        if ctx.writeEditorAttached || ctx.takesBoardAttached { return .act }
        switch ctx.mode {
        case .write, .takes, .lenses: return .act
        default: return .unavailable
        }
    }

    /// The TAKES BOARD's own surface acts (13e E3/E4): the card and slot
    /// doors that exist only where the cards are drawn. `closeAllTakes` and
    /// the fan pagers already gate on `mode == .takes`; this adds the
    /// attachment half those two predate (13c 2B's lesson: a board can mount
    /// outside a post detail, and enablement must track the surface that
    /// actually acts).
    private static let takesBoard: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        (ctx.takesBoardAttached || ctx.mode == .takes) ? .act : .unavailable
    }

    /// Step/choose additionally act in Canvas (the ‹ › switcher's keys).
    private static let takeFamilyPlusCanvas: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        if ctx.mode == .canvas { return .act }
        return takeFamily(ctx)
    }

    /// Commit additionally acts in COMPARE (13b 4D — the 4C handoff:
    /// compare panes are fully editable since 4C, and its board registers
    /// the `.commit` handler; ⌘S commits the focused pane's take — the N5
    /// letter extended to the new editable surface) and in CANVAS (13b 4E,
    /// the Phase-1 ruling's (c)(2): canvas cards edit through the one
    /// authority since 4E, and its handler consumes `.commit` the same
    /// way — the N5 class closed on its third surface).
    private static let takeFamilyPlusEditableBoards: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        if ctx.mode == .compare || ctx.mode == .canvas { return .act }
        return takeFamily(ctx)
    }

    /// The callout frame's reach (13c Stage 1 ladder, R2-2 — her A13(a)
    /// verbatim: callouts *"in Takes/Compare/Lenses"*). Exactly the four
    /// surfaces she named, no more: the take family plus COMPARE, whose
    /// panes have carried a live block since 4C. CANVAS is deliberately
    /// out — it is not in her ask, and P-2 says a door that can't act in a
    /// context isn't rendered enabled there; adding it is one line plus a
    /// handler if she wants it (recorded for the Design & UI review row).
    private static let takeFamilyPlusCompare: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        if ctx.mode == .compare { return .act }
        return takeFamily(ctx)
    }

    /// Write-editor-scoped doors (caret acts): ATTACHMENT ONLY (round-1
    /// MINOR-3). These acts call the attached editor directly — enablement
    /// must never outrun the actual editor ("Write mode, editor still
    /// mounting" was an enabled-but-silent window, the enabled-into-nil
    /// class the registry exists to kill).
    private static let writeEditor: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        ctx.writeEditorAttached ? .act : .unavailable
    }

    /// The FIND family (QoL batch 3 — L6): the post detail's full-document
    /// Write editor, which is the one surface that owns a scroll view for the
    /// bar to live in. Strictly narrower than `writeEditor` above — see
    /// `CapabilityContext.writeEditorOwnsScrollView` for why the inline
    /// book/spread/pool editors must be excluded by a fact rather than by
    /// hope. Takes/Lenses/read surfaces are deliberately out of v1: a find
    /// ACROSS the post has no meaning on a per-take pane, and the takes-aware
    /// find/replace is her L6 rider's recorded future scope (owner 13e).
    private static let findFamily: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        ctx.writeEditorOwnsScrollView ? .act : .unavailable
    }

    /// The FORMATTING family (13g batch 3 — L8): wherever text is edited.
    ///
    /// Broader than the take family on purpose, and the breadth is a fact
    /// rather than a hope: every post mode hosts a live editable surface —
    /// Write's editor, the Takes/Lenses/Compare boards' panes (4C/4D),
    /// Canvas's cards (4E) and the Blocks TOC's expanded row — and the
    /// attached-editor / attached-board arms cover the book-inline, spread and
    /// pool editors that carry no mode at all. Whatever surface holds the
    /// keyboard is a surface ⌘B can act on, which is exactly why the door
    /// should not be grey there.
    private static let editableText: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        ctx.writeEditorAttached || ctx.takesBoardAttached || ctx.mode != nil
            ? .act : .unavailable
    }

    private static let always: @Sendable (CapabilityContext) -> Capability.Availability = { _ in .act }

    // MARK: - The table

    static let all: [Capability] = [
        // MARK: Structural (block scope)
        Capability(
            id: .divide, verb: "Divide Block at Cursor", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧D", takesAccess: .native,
            unavailableNote: "Dividing happens inside a note — open one first.",
            availability: divideAvailability),
        Capability(
            id: .extract, verb: "Extract Selection", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧E", takesAccess: .moveAndExecute,
            unavailableNote: "Extracting happens inside a note — open one first.",
            availability: structural),
        Capability(
            id: .makeBlock, verb: "Make Block from Selection", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧K", takesAccess: .moveAndExecute,
            unavailableNote: "Making a block happens inside a note — open one first.",
            availability: structural),
        Capability(
            id: .merge, verb: "Merge Blocks", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧M", takesAccess: .moveAndExecute,
            unavailableNote: "Merging happens inside a note — open one first.",
            availability: structural),
        Capability(
            id: .deleteInEveryTake, verb: "Delete in Every Take", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: nil, takesAccess: .moveAndExecute,
            unavailableNote: "Delete in Every Take works on a selection inside a note.",
            availability: structural),
        Capability(
            id: .addBlockAtEnd, verb: "New Block at End of Note", scope: .block,
            doors: [.menuBar, .bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Blocks are born inside a note — open one first.",
            availability: takeFamily),  // NIT-3: the one named rule, not a copy
        // 13b 4D (N28's second half — the Takes trap's insert door; S4-13:
        // editor parity, native in BOTH Write and Takes by construction).
        // The minted block is EMPTY (its one live variant, empty text — I10
        // holds; blank takes render as the kept line); the caret/ring lands
        // in it. Sealed posts refuse through the op, spoken.
        Capability(
            id: .insertBlockBelow, verb: "New Block Below", scope: .block,
            doors: [.menuBar, .bottomBar, .palette],
            // 13d batch 4 (A14): ⌘⇧⏎, superseding 13b 4D's ⌥⌘N. Her row is
            // "⌘⇧Enter = new block"; the collision sweep found the chord
            // free (⌘⏎ is Choose Take; nothing else binds Return with a
            // modifier). One act, one declared key — the registry has no
            // alias concept, and giving one act two keys would mean either
            // a duplicate menu row or an undeclared key, both of which the
            // legibility mandate refuses.
            shortcutLabel: "⌘⇧⏎", takesAccess: .native,
            unavailableNote: "Blocks are born inside a note — open one first.",
            availability: takeFamily),  // the one named rule, not a copy
        // 13c 1B (A8 — her item: "I don't seem to have the ability to
        // delete / archive empty blocks?"). `deleteBlock` has existed in
        // Operations since Phase 2 and had exactly ONE face app-wide (the
        // block TOC's row menu); this is its door where she writes. It is
        // deliberately NOT restricted to empty blocks — the operation is
        // not, the TOC door never was, and a restriction nobody ruled
        // would be invented product behavior. Undoable (⌥⌘Z) and, since
        // A10, redoable; the deleted block also lands in the post's tray.
        // The destructive-action WARNING is her A12 and stays 13d — it is
        // cheap precisely once redo makes the mistake recoverable.
        Capability(
            id: .deleteBlock, verb: "Delete Block", scope: .block,
            doors: [.menuBar, .bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Blocks live inside a note — open one first.",
            availability: takeFamily),  // the one named rule, not a copy

        // MARK: The take family (take scope)
        Capability(
            id: .showTakes, verb: "Show Takes", scope: .take,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧T", takesAccess: .native,
            unavailableNote: "Takes live inside a note — open one first.",
            availability: { ctx in
                if ctx.mode == .lenses { return .actElsewhere(.takes) }  // blooms live in Takes — GO there
                return takeFamily(ctx)
            }),
        Capability(
            id: .newTake, verb: "New Take (Branch)", scope: .take,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘T", takesAccess: .native,
            unavailableNote: "Takes grow on a block inside a note — open one first.",
            availability: takeFamily),
        Capability(
            id: .blankTake, verb: "New Blank Take", scope: .take,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌥⌘T", takesAccess: .native,
            unavailableNote: "Takes grow on a block inside a note — open one first.",
            availability: takeFamily),
        Capability(
            id: .blankTakeAsChosen, verb: "New Blank Take as Chosen", scope: .take,
            doors: [.menuBar, .bottomBar],
            shortcutLabel: "⇧⌥⌘T", takesAccess: .native,
            unavailableNote: "Takes grow on a block inside a note — open one first.",
            availability: takeFamily),
        Capability(
            id: .chooseTake, verb: "Choose This Take", scope: .take,
            doors: [.menuBar, .contextMenu, .palette],
            shortcutLabel: "⌘⏎", takesAccess: .native,
            unavailableNote: "Choosing happens among a block's takes — open a note first.",
            availability: takeFamilyPlusCanvas),
        Capability(
            id: .previousTake, verb: "Previous Take", scope: .take,
            doors: [.menuBar],
            shortcutLabel: "⌃⌘←", takesAccess: .native,
            unavailableNote: "Stepping through takes happens inside a note.",
            availability: takeFamilyPlusCanvas),
        Capability(
            id: .nextTake, verb: "Next Take", scope: .take,
            doors: [.menuBar],
            shortcutLabel: "⌃⌘→", takesAccess: .native,
            unavailableNote: "Stepping through takes happens inside a note.",
            availability: takeFamilyPlusCanvas),
        Capability(
            id: .archiveTake, verb: "Archive Take", scope: .take,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "⌘⇧A", takesAccess: .native,
            unavailableNote: "Archiving acts on the take you're in — open a note first.",
            availability: takeFamily),
        Capability(
            id: .saveChoicesAsLens, verb: "Save Choices as Lens…", scope: .post,
            doors: [.menuBar, .palette],
            shortcutLabel: "⌘⇧L", takesAccess: .native,
            unavailableNote: "Lenses save a note's choices — open a note first.",
            availability: takeFamily),
        Capability(
            id: .closeAllTakes, verb: "Close All Takes (Esc)", scope: .take,
            doors: [.menuBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Takes bloom on the Takes board (⌘2) — close-all acts there.",
            // NIT-2: blooms exist ONLY on the Takes board — Write and
            // Lenses consumed the command with a silent `break` while the
            // menu item rendered enabled (the enabled-but-void class).
            availability: { ctx in ctx.mode == .takes ? .act : .unavailable }),
        Capability(
            id: .pageFanBack, verb: "Previous Page of Takes", scope: .take,
            doors: [.menuBar],
            shortcutLabel: "⌥⌘←", takesAccess: .native,
            unavailableNote: "Take pages live on the Takes board (⌘2).",
            availability: { ctx in ctx.mode == .takes ? .act : .unavailable }),
        Capability(
            id: .pageFanForward, verb: "Next Page of Takes", scope: .take,
            doors: [.menuBar],
            shortcutLabel: "⌥⌘→", takesAccess: .native,
            unavailableNote: "Take pages live on the Takes board (⌘2).",
            availability: { ctx in ctx.mode == .takes ? .act : .unavailable }),
        // 13b Stage 3 (3D — T5/N1): the road BACK from an archive lives in
        // Takes too (R118), as the archived listing's own card door. A
        // `.surface` act: its target is the archived card itself, so no
        // routed context command exists (an archived take can never hold
        // the ring).
        Capability(
            id: .unarchiveTake, verb: "Unarchive Take", scope: .take,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Unarchiving acts on an archived take — open its block's takes first.",
            availability: takeFamily),
        // 13e E4 (her A19: *"Reorder takes"*): the fan becomes rearrangeable,
        // and the doors are the take card's own ◀ ▶ (▲ ▼ in the stack style) —
        // `.surface` acts, because the target is the card you point at (the
        // `.unarchiveTake` class). Board-only by nature: the cards exist on the
        // Takes board, so the rule is the board's ATTACHMENT (13c 2B's shape —
        // the book spread mounts the same board with no post detail around it)
        // rather than a mode name. Keyless deliberately: her ruling named no
        // chord, and an invented one would owe a collision sweep nobody asked
        // for (the `.toggleStar` precedent).
        Capability(
            id: .moveTakeEarlier, verb: "Move Take Earlier", scope: .take,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Takes are rearranged on their cards, on the Takes board (⌘2).",
            availability: takesBoard),
        Capability(
            id: .moveTakeLater, verb: "Move Take Later", scope: .take,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Takes are rearranged on their cards, on the Takes board (⌘2).",
            availability: takesBoard),
        // 13e E3 (her A18: *"⌘-click in Takes to select blocks to merge; merge
        // several when they have no takes"*). BLOCK scope — it joins blocks —
        // with two doors: the article cell's context menu and the selection
        // banner. Native on the board: a ⌘-click selection names the blocks
        // directly, so a fanless run merges right here; a fanned PAIR reaches
        // the ruled ceremony by the one visible choreography (P-2), which is
        // performing the act, not redirecting away from it.
        Capability(
            id: .mergeSelectedBlocks, verb: "Merge Selected Blocks", scope: .block,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "⌘-click blocks on the Takes board (⌘2) to pick what merges.",
            availability: takesBoard),
        // 13e E6 (her A21's clipboard half, verbatim: *"keyboard shortcut for
        // copying all takes together to clipboard"*). TAKE scope, native
        // wherever takes are: the target is the block you are in (the caret
        // block in Write, the focused card's block on a board) and the text is
        // the app's OWN ratified export shape — the shown take, then the
        // labeled Alternates section (`Queries.blockTakes`, one rule shared
        // with export, so the confirmation's count and the text agree).
        // Reads only — no row is written, which is why the seal never refuses
        // it. ⌘⇧C: her ask names a shortcut, and the collision sweep found no
        // `c` chord bound anywhere but ⌥⌘C (callout) — swept across
        // `EditorCommands.keyEquivalent`, every `keyboardShortcut(` call site
        // in `Variorum/` and `Shared/`, every `NSMenuItem` keyEquivalent (all
        // empty strings), and both `keyDown`/`performKeyEquivalent` overrides.
        // ⌘C itself is untouched — it stays the system's Copy.
        Capability(
            id: .copyAllTakes, verb: "Copy All Takes", scope: .take,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "⌘⇧C", takesAccess: .native,
            unavailableNote: "Takes live inside a note — open one first.",
            availability: takeFamily),
        // 13e batch 3 (her A20/A21 — the take↔block pair, architect ruling
        // AR-1). Native wherever takes are: both acts are decided INSIDE the
        // operation (fan arity, blank takes, the seal, I10), so the doors
        // never gate on a projection — they fire and the op's own refusal
        // speaks (P-2). ⌥⌘⏎ / ⇧⌥⌘⏎: her A20/A21 words ask for shortcuts, and
        // the collision sweep found the Return family's only bound chords to
        // be ⌘⏎ (Choose Take) and ⌘⇧⏎ (New Block Below) — swept across
        // `EditorCommands.keyEquivalent`, every `keyboardShortcut(` call site
        // in `Variorum/` and `Shared/`, every `NSMenuItem` keyEquivalent (all
        // empty strings), and both key overrides. The pair reads as a family
        // with its neighbours: ⌘⇧⏎ makes an empty block below, ⌥⌘⏎ makes one
        // out of the take you're in, ⇧⌥⌘⏎ makes one out of every take.
        Capability(
            id: .takeToBlockBelow, verb: "Move Take into a Block Below", scope: .take,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "⌥⌘⏎", takesAccess: .native,
            unavailableNote: "Takes become blocks inside a note — open one first.",
            availability: takeFamily),
        Capability(
            id: .takesToBlocks, verb: "Turn All Takes into Blocks", scope: .take,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "⇧⌥⌘⏎", takesAccess: .native,
            unavailableNote: "Takes become blocks inside a note — open one first.",
            availability: takeFamily),
        // 13b Stage 3 (3D — T5/N6): the 3B core op `setTakeLabel` gets its
        // faces — the take card's context menu and the bar's block menu.
        Capability(
            id: .labelTake, verb: "Label Take…", scope: .take,
            doors: [.contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Labels live on a take inside a note — open one first.",
            availability: takeFamily),
        // 13b Stage 3 (3D — T5/N6): `renameLens` (core since 11a) gets its
        // door on the Lenses column header. Lens machinery's ONE home is
        // the Lenses tab (R65/R86), so the act is deliberately
        // Lenses-scoped — the R118 parity table exempts it by that ruling
        // (Write has no lens door either; no surface is privileged).
        Capability(
            id: .renameLens, verb: "Rename Lens…", scope: .post,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Lenses are renamed from their column header in Lenses (⌘3).",
            availability: { ctx in ctx.mode == .lenses ? .act : .unavailable }),
        // 13b 4D (N32(c) — S4-15's trace made right): block TAGGING gets
        // doors where scraps live. `BlockTagAssignmentSheet` (11a A8) was
        // mounted in EXACTLY ONE place app-wide — the canvas card's menu;
        // now the Blocks-area rows and the ScrapsPanel rows carry the same
        // door, all declared as ONE `.surface` act (the target is pointed
        // at directly — the archived-card class; each surface declares it
        // in its `surfaceCapabilities` static and the walk asserts).
        // R118 exemption, recorded: scraps live OUTSIDE the post-mode row
        // (Blocks area / panel / canvas) — no editing mode is privileged
        // over another, so the parity table exempts it like `renameLens`.
        Capability(
            id: .tagBlock, verb: "Tag Block…", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Tags go on a block where you see it — scrap rows and canvas cards carry the door.",
            availability: always),
        Capability(
            id: .divergeHere, verb: "Diverge here (new take, this thread)", scope: .take,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Diverging acts on a pane in Takes or Lenses.",
            availability: { ctx in
                switch ctx.mode {
                case .takes, .lenses: return .act
                default: return .unavailable
                }
            }),
        Capability(
            id: .diffAgainstChosen, verb: "Diff against chosen", scope: .take,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Diffing compares a take against the chosen one, in Takes or Lenses.",
            availability: { ctx in
                switch ctx.mode {
                case .takes, .lenses: return .act
                default: return .unavailable
                }
            }),
        // 13f W10b (her sitting question: *"how do I even see the original
        // one?"*). A divide-W preserves block A whole and RELEASES it; a
        // merge releases both sources. The successors carry a `derived_from`
        // edge straight at them, and nothing in the app had ever walked it —
        // the only road back was knowing that Library → Archived & Deleted
        // lists unplaced blocks. This is that edge, as a door.
        //
        // Like `.diffAgainstChosen`, the CONTEXT rule is a mode rule and the
        // per-target condition is the surface's: the menu item renders only
        // on a block whose origin is live and unplaced (P-2 — a door that
        // could never act is not rendered, not rendered-and-grey).
        Capability(
            id: .showOriginBlock, verb: "Show Original Block", scope: .block,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Released originals are listed under Library → Archived & Deleted.",
            availability: takeFamily),

        // MARK: Commit + undo
        Capability(
            id: .commitTake, verb: "Commit Take", scope: .take,
            doors: [.menuBar, .bottomBar, .palette],
            shortcutLabel: "⌘S", takesAccess: .native,
            unavailableNote: "Nothing to commit here — ⌘S commits a take inside a note.",
            availability: takeFamilyPlusEditableBoards),  // 13b 4D: + compare; 4E: + canvas
        Capability(
            id: .structuralUndo, verb: "Undo Structural Change", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: "⌥⌘Z", takesAccess: .native,
            unavailableNote: "No structural change to undo.",
            availability: { ctx in ctx.undoAvailable ? .act : .unavailable }),
        // 13c 1B (A10 — "i desperately need a 'redo' command to be able to
        // undo my structural undos for when that was an accident"). The
        // exact mirror of the undo door, gated on the redo stack: same
        // app scope (structural undo/redo is never a mode's property),
        // same two doors, ⇧⌥⌘Z beside ⌥⌘Z. STRUCTURAL only — ⌘⇧Z stays
        // NSTextView's text redo and the two never interleave.
        Capability(
            id: .structuralRedo, verb: "Redo Structural Change", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: "⇧⌥⌘Z", takesAccess: .native,
            unavailableNote: "No structural change to redo.",
            availability: { ctx in ctx.redoAvailable ? .act : .unavailable }),

        // MARK: Post scope
        Capability(
            id: .sealPost, verb: "Seal / Unseal Note", scope: .post,
            doors: [.bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Sealing acts on an open note — open one first.",
            // Round-1 MINOR-1: the attached-editor arm — a book-inline or
            // pool editor (mode nil, editor attached) seals through its
            // own routed handler; the rule must say so.
            availability: { ctx in
                ctx.writeEditorAttached || ctx.mode != nil ? .act : .unavailable
            }),

        // MARK: Write-editor-scoped menu doors (declared so the menu's
        // rendered set is fully covered by the registry walk)
        Capability(
            id: .previousBlock, verb: "Previous Block", scope: .block,
            doors: [.menuBar],
            shortcutLabel: "⌃⌘↑", takesAccess: nil,
            unavailableNote: "Block-to-block caret jumps live in Write.",
            availability: writeEditor),
        Capability(
            id: .nextBlock, verb: "Next Block", scope: .block,
            doors: [.menuBar],
            shortcutLabel: "⌃⌘↓", takesAccess: nil,
            unavailableNote: "Block-to-block caret jumps live in Write.",
            availability: writeEditor),
        Capability(
            id: .blockComments, verb: "Comments…", scope: .block,
            doors: [.menuBar, .bottomBar],
            shortcutLabel: "⌘⇧'", takesAccess: .native,
            unavailableNote: "Comments live on a block — open a note first.",
            // The bars' block menus carry the door in Write/Takes/Lenses.
            availability: takeFamily),  // NIT-3: the one named rule, not a copy
        // 13c Stage 1 ladder, R2-2 — her A13(a), ruled into the friction
        // batch by K2 and built here: "callouts (a) in Takes/Compare/Lenses
        // + a shortcut". Both halves were ONE declaration edit plus the
        // fire-and-DO wiring 13b built for exactly this class — the frame
        // is the BLOCK's (takes share it, R16/R27), so every surface that
        // knows which block you are in can set it, and Write was privileged
        // only by an accident of where the door was first hung (R118).
        // ⌥⌘C toggles; the submenu's colours/emoji/remove route the same
        // way. `takesAccess: .native` — Takes sets the frame right there.
        // 13k K6 — the RIGHT-CLICK door joins them. Her report, 2026-08-01:
        // she went looking for callouts in the context menu and they were
        // not there. One declaration edit plus the rows `CalloutMenu`
        // already owns; the transform is unchanged (13c R2-2's letter).
        Capability(
            id: .callout, verb: "Callout", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "⌥⌘C", takesAccess: .native,
            unavailableNote: "Callout frames go on a block — open a note first.",
            availability: takeFamilyPlusCompare),
        Capability(
            id: .exportCaretBlock, verb: "Export Block as Markdown…", scope: .block,
            doors: [.menuBar],
            shortcutLabel: nil, takesAccess: nil,
            // Round-2 NIT-R2-3 copy: the note's ONE speaking site is the
            // caret-outside-any-block case (attached editor, open tail) —
            // so it says exactly that.
            unavailableNote: "Put the caret in a block to export it.",
            availability: writeEditor),

        // MARK: In-post find & replace (QoL batch 3 — her L6)
        //
        // `takesAccess: nil` and a named place in the registry-walk exemption
        // set, beside `.previousBlock`/`.nextBlock`/`.exportCaretBlock`: these
        // are full-document SURFACE acts, and Takes is not "behind Write"
        // here — the takes-aware act does not exist yet anywhere (13e's
        // recorded future scope, her own L6 rider). The verbs say "in Post"
        // so nothing reads as a rival to ⌘K's "Find Anything…", which
        // searches the library's titles and names and never body text.
        Capability(
            id: .findInPost, verb: "Find in Note…", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘F", takesAccess: nil,
            unavailableNote: "Find works in the note editor — open a note in Write (⌘1).",
            availability: findFamily),
        Capability(
            id: .findAndReplace, verb: "Find and Replace…", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌥⌘F", takesAccess: nil,
            unavailableNote: "Find works in the note editor — open a note in Write (⌘1).",
            availability: findFamily),
        Capability(
            id: .findNext, verb: "Find Next", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘G", takesAccess: nil,
            unavailableNote: "Find works in the note editor — open a note in Write (⌘1).",
            availability: findFamily),
        Capability(
            id: .findPrevious, verb: "Find Previous", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⇧⌘G", takesAccess: nil,
            unavailableNote: "Find works in the note editor — open a note in Write (⌘1).",
            availability: findFamily),
        Capability(
            id: .useSelectionForFind, verb: "Use Selection for Find", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘E", takesAccess: nil,
            unavailableNote: "Find works in the note editor — open a note in Write (⌘1).",
            availability: findFamily),

        // MARK: Formatting (13g batch 3 — L8, her rulings F-1…F-3)
        //
        // Markdown-as-content: these acts insert and remove SYNTAX
        // CHARACTERS in the ordinary text, through the ordinary input path.
        // There is no operation behind them and no schema — under F-1 the
        // markers ARE the text — so their refusals are the editor pipeline's
        // own (a seal, a locked take), spoken where they are found.
        //
        // `takesAccess: .native` and it is literally true: the act runs on
        // whichever surface holds the keyboard, so Takes formats right there
        // and Write is not privileged (R118).
        //
        // **THE COLLISION SWEEP'S RESULT (13g batch 3):** ⌘B and ⌘I are FREE
        // — swept across `EditorCommands.keyEquivalent` (41 chords), every
        // `.keyboardShortcut(` call site in `Variorum/` and `Shared/`, every
        // `NSMenuItem` key equivalent (all empty strings), the one
        // `performKeyEquivalent` override (⌘S) and the one `keyDown` override
        // (⇧⏎). No bare-⌘ letter chord binds `b` or `i`; their shifted
        // neighbours ⌘⇧B (block seams) and ⌘⇧I (context bar) are the right
        // neighbours to have — the same letter, the plainer gesture. The
        // other five ship MENU-FIRST, deliberately: her ruling named bold and
        // italic, no platform chord for strikethrough/code/headings/lists is
        // standard enough to be obvious, and an invented chord would owe a
        // sweep no ruling asked for (13f batch 4's precedent).
        //
        // **13k K7 — the `.bottomBar` door** (her ruling: *"i think the
        // formatting toolbar should be added to the bottom … i think other
        // users would need it though"*). All EIGHT carry it, rendered by
        // `FormatBar` in BOTH bottom bars: the acts are `takesAccess:
        // .native`, so a toolbar in Write's bar and not in the boards' would
        // privilege Write exactly where R118 says it must not be.
        Capability(
            id: .formatBold, verb: "Bold", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: "⌘B", takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        Capability(
            id: .formatItalic, verb: "Italic", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: "⌘I", takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        Capability(
            id: .formatStrikethrough, verb: "Strikethrough", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        Capability(
            id: .formatCode, verb: "Inline Code", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        // 13g batch 4 (L10). MENU-FIRST, and the sweep is why: the platform's
        // own "add link" chord is ⌘K, which this app has bound to Find
        // Anything since Phase 13 (R15) — the one chord a reader would guess
        // is the one chord that is taken, and re-pointing ⌘K to serve a text
        // act would break the app's most-used door. No second candidate is
        // standard enough to be obvious, so it ships beside the other five
        // keyless acts (QUESTIONS #50 offers her one).
        Capability(
            id: .formatAddLink, verb: "Add Link", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        // ONE declaration owning a submenu of three sizes — the `.callout`
        // shape. Headings ARE sizes (F-3: arbitrary per-span sizes are not
        // markdown-expressible), so 1/2/3 are shades of one act rather than
        // three acts, and none of them could honestly carry a key.
        Capability(
            id: .formatHeading, verb: "Heading", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        Capability(
            id: .formatBulletList, verb: "Bullet List", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        Capability(
            id: .formatChecklist, verb: "Checklist", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        // **13k K8 — nesting** (her ruling: *"we should allow indented lists
        // and it should happen when you click tab"*; sitting Q3: ⇧Tab + these
        // two rows). NO `.bottomBar` door, deliberately: Tab and ⇧Tab are the
        // primary door and K7's toolbar is already eight wide. NO
        // `shortcutLabel`, also deliberately: the walk would then require a
        // menu key equivalent (`everyShortcutLabelHasExactlyOneKeyWiring`),
        // and binding ⇥ as one would steal Tab app-wide — so the keys live in
        // the surfaces' `insertTab`/`insertBacktab`, where ⏎'s lives, and the
        // ⌘/ helper carries both doors in prose instead.
        Capability(
            id: .formatIndent, verb: "Indent", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        Capability(
            id: .formatOutdent, verb: "Outdent", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),

        // MARK: Modes + app scope
        Capability(
            id: .switchMode, verb: "Switch Mode (⌘1–⌘6)", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘1–6", takesAccess: nil,
            unavailableNote: "Open a note first — the modes live inside a note.",
            availability: { ctx in ctx.mode != nil ? .act : .unavailable }),
        // MARK: The navigation core (13f batch 3 — W3/A27 + W16)
        //
        // Her two rulings, as registry facts. The strip lives in the
        // SIDEBAR (*"i'd use the free space that's underneath 'library /
        // shelf / pool / blocks' for now"*) and the keys reach it; back and
        // forward walk the pane's own history.
        //
        // App scope, `takesAccess: nil`: these are WORKSPACE acts, not
        // editing acts — no surface is behind another, exactly as `newPost`
        // and `findAnything` are nobody's mode's property. Their gates are
        // STACK gates (the `structuralUndo`/`structuralRedo` shape), never
        // mode gates: a door that could only be a dead key is grey.
        Capability(
            id: .openNote, verb: "Open Notes (\u{2318}\u{21e7}1\u{2013}9)", scope: .app,
            doors: [.menuBar],
            // One label for the family; the menu wires a key per ordinal
            // (the `switchMode` precedent, and the same walk exemption).
            shortcutLabel: "\u{2318}\u{21e7}1\u{2013}9", takesAccess: nil,
            unavailableNote: "No notes are open yet — open one and it joins the Open list.",
            availability: { ctx in ctx.openNoteCount > 0 ? .act : .unavailable }),
        // 13k K11: both gain a `.surface` door — the context bar's ← and →.
        // The ← has been on the bar since 13f (as a spelled-out chip) and
        // was never declared there; the → is new with her ruling (*"after
        // you just went back, i feel like you should be able to go
        // forward"*). Declaring both is what puts the bar's own doors under
        // the walk (`ContextBar.surfaceCapabilities`).
        Capability(
            id: .navigateBack, verb: "Back", scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: "\u{2318}[", takesAccess: nil,
            unavailableNote: "Nothing to go back to — this is where you started.",
            availability: { ctx in ctx.canNavigateBack ? .act : .unavailable }),
        Capability(
            id: .navigateForward, verb: "Forward", scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: "\u{2318}]", takesAccess: nil,
            unavailableNote: "Nothing to go forward to — you haven't gone back.",
            availability: { ctx in ctx.canNavigateForward ? .act : .unavailable }),
        // 13f batch 4 — the SPLIT (her W1/A25 ruling). The menu door puts
        // the most recently opened OTHER note beside this one; the row
        // doors (`.contextMenu`) put the row you point at. Both refuse the
        // same way when the note is already showing, because her round-7.3
        // rule is one rule with one voice: a split never shows one note
        // twice, and Lenses/Compare are the same-note surfaces.
        Capability(
            id: .openBeside, verb: WorkspaceNaming.openBesideVerb, scope: .app,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "There's no other open note to put beside this one yet — "
                + "open a second note and it can sit alongside.",
            availability: { ctx in ctx.canOpenBeside ? .act : .unavailable }),
        // 13f batch 5 (W20 b) — the fold, REPOINTED by 13k K11/K12. It hid
        // the whole context bar; her 13k ruling retired that (*"the
        // collapsing and growing in that bar is a little annoying to me"*)
        // and kept exactly one fold — the TAG CARDS, visible by default,
        // folded only if she deliberately chooses it. So this act is now
        // the ＃ icon's keyboard twin, with the same key, and the bar's own
        // door is declared alongside (`.surface`).
        //
        // `always`, deliberately and for the unchanged reason: the door's
        // whole job is to bring back something that is not on screen, so
        // greying it where the cards are hidden would fail in the one state
        // it exists for.
        Capability(
            id: .toggleTagChips, verb: WorkspaceNaming.tagChipsVerb, scope: .app,
            doors: [.menuBar, .palette, .surface],
            // THE COLLISION SWEEP'S RESULT (13f batch 5): ⌘⇧I is FREE —
            // swept across `EditorCommands.keyEquivalent`, every
            // `.keyboardShortcut(` call site in `Variorum/` and `Shared/`,
            // every `NSMenuItem` key equivalent (all empty strings) and the
            // one `performKeyEquivalent` override (⌘S). No `i` chord of any
            // modifier combination is bound anywhere in the app.
            shortcutLabel: "\u{2318}\u{21e7}I", takesAccess: nil,
            unavailableNote: "", availability: always),
        Capability(
            id: .closeSplit, verb: "Close Split", scope: .app,
            doors: [.menuBar],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "There's no split to close — this window shows one note.",
            availability: { ctx in ctx.paneCount > 1 ? .act : .unavailable }),
        // 13f batch 5b — the note-only window (her round-2 ruling: both
        // window kinds). `always`, and that is the honest declaration
        // rather than a missing gate: the door is rendered ONLY on a note
        // ROW, so its target always exists, and a window can always be
        // opened. The CONTEXT rule is trivial here and the per-TARGET
        // condition is the row's — the `.diffAgainstChosen` /
        // `.showOriginBlock` split (P-2), stated so nobody later reads the
        // `always` as an oversight.
        Capability(
            id: .openInNewWindow, verb: "Open in New Window", scope: .app,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),
        // 13f batch 6 — W5's QUICK NOTE. `always`, and honestly so: a pad
        // can be summoned from anywhere at any time — that is the whole
        // feature. It takes no target and reads no context.
        Capability(
            id: .quickNote, verb: QuickNoteCopy.verb, scope: .app,
            doors: [.menuBar, .menuBarExtra, .palette],
            // THE COLLISION SWEEP'S RESULT (13f batch 6): ⌘⇧N is FREE —
            // swept across `EditorCommands.keyEquivalent` (36 chords),
            // every `.keyboardShortcut(` call site in `Variorum/` and
            // `Shared/`, every `NSMenuItem` key equivalent (all empty
            // strings) and the one `performKeyEquivalent` override (⌘S).
            // No `n` chord carries shift; the nearest neighbour is ⌘N New
            // Post, which is exactly the right neighbour — ⌘N makes a
            // note, ⌘⇧N pops the pad.
            shortcutLabel: "\u{2318}\u{21e7}N", takesAccess: nil,
            unavailableNote: "", availability: always),
        // 13f batch 6 — W4's STARS (her round-3 ruling: *"up to 5 notes or
        // books, star/unstar via context menu + ⌘K, section at the
        // sidebar's top"*). The gate governs the ⌘K door ONLY: at the shelf
        // or the library there is nothing to star, so a palette row there
        // could only refuse. The ROW doors are not gated by it — a row
        // carries its own target, which is the standing
        // `.diffAgainstChosen` / `.showOriginBlock` split (the CONTEXT rule
        // is the registry's; the per-TARGET condition is the surface's).
        Capability(
            id: .toggleStar, verb: StarCopy.verb, scope: .app,
            doors: [.contextMenu, .palette],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: StarCopy.unavailableNote,
            availability: { ctx in ctx.canStarCurrent ? .act : .unavailable }),
        // Her W16 second half. A `.surface` door on the peer column's own
        // header — the `.unarchiveTake` class: the target is the thing you
        // are pointing at, so no routed context command exists. The CONTEXT
        // rule is Compare's (the board is the only place a peer column
        // exists); the per-column condition — a peer is actually picked —
        // is the surface's, the `.diffAgainstChosen` split (P-2).
        Capability(
            id: .openPeerPost, verb: "Open", scope: .post,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Peer columns live on the Compare board (\u{2318}4).",
            availability: { ctx in ctx.mode == .compare ? .act : .unavailable }),
        // 13f batch 5 — W23. Her round-10 item 4: *"'duplicate as version'
        // should be a button you can click, not just an FYI … that nicely
        // duplicates it as version and deletes the original for you all in
        // one go."* A `.surface` act on the membership chip's BOOK ROW: the
        // target is the book you point at, which is what makes "this book"
        // unambiguous where a routed menu command would have had to guess.
        // The CONTEXT rule is "a post is open" (the chip lives in its
        // masthead); the per-ROW condition is the surface's — the
        // `.diffAgainstChosen` / `.showOriginBlock` split (P-2).
        // R118 parity is `.native` and it is LITERALLY true rather than an
        // exemption: the chip lives in the post detail's MASTHEAD, which
        // renders above every mode — so Takes reaches this door without a
        // mode switch, exactly as Write does. Write is not privileged here
        // because no mode owns the masthead.
        Capability(
            id: .divergeForBook, verb: DivergeCopy.verb, scope: .post,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Diverging happens inside a note — open one first.",
            availability: { ctx in ctx.mode != nil ? .act : .unavailable }),

        // 13e E11 — THE BOOK ASCENT ("open this book, at this note"). Two
        // `.surface` door families for ONE act: the context bar's book icon
        // (13k K11 — one book opens, several list) and the membership chip's
        // book rows (Phase 13, wired 13f W20(a)). Both point AT a book, which
        // is what makes them `.surface` rather than routed — the
        // `.divergeForBook` reason, and the reason the chip's own rows need no
        // context gate: a row exists only where its book does.
        //
        // The gate is the BAR's case: her #55(b)/(g) ruling renders the icon
        // grey with a tooltip on a bookless note, and grey is what
        // `.unavailable` draws. So declaring changes nothing she can see —
        // which is E11's whole letter (the walk's coverage IS the deliverable).
        //
        // `takesAccess: nil` and EXEMPT from the R118 parity table, exactly as
        // `.openPeerPost` is and for the identical reason: this is a
        // NAVIGATION act, not an editing one — no surface is "behind Write"
        // because no surface edits anything here. (Literally so, twice over:
        // the bar sits ABOVE the pane and the chip lives in the masthead, so
        // both doors render over every mode.)
        Capability(
            id: .openBookAtNote, verb: "Open Book at This Note", scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: WorkspaceNaming.ascentUnavailableNote,
            availability: { ctx in ctx.canAscendToBook ? .act : .unavailable }),

        Capability(
            id: .newPost, verb: "New Note", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: "⌘N", takesAccess: nil,
            unavailableNote: "", availability: always),
        Capability(
            id: .todaysEntry, verb: "Today's Entry", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: "⌘J", takesAccess: nil,
            unavailableNote: "", availability: always),
        Capability(
            id: .findAnything, verb: "Find Anything…", scope: .app,
            doors: [.menuBar],
            shortcutLabel: "⌘K", takesAccess: nil,
            unavailableNote: "", availability: always),
        Capability(
            id: .importFiles, verb: "Import Files…", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),
        Capability(
            id: .exportLibrary, verb: "Export Library…", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),
        Capability(
            id: .toggleSeams, verb: "Toggle Block Seams", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: "⌘⇧B", takesAccess: nil,
            unavailableNote: "", availability: always),
        Capability(
            id: .helper, verb: "Shortcuts & Dictionary", scope: .app,
            doors: [.menuBar],
            shortcutLabel: "⌘/", takesAccess: nil,
            unavailableNote: "", availability: always),
        // Phase 13b Stage 2 (R113): the tutorial's product door — replace
        // wholesale after a spoken confirm; idempotent; fire-and-DO (it
        // seeds AND opens the fresh book).
        Capability(
            id: .restoreTutorial, verb: "Restore Tutorial…", scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),
    ]

    // MARK: - Lookup

    private static let byID: [CapabilityID: Capability] =
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func capability(_ id: CapabilityID) -> Capability {
        guard let capability = byID[id] else {
            preconditionFailure("undeclared capability \(id)")  // CaseIterable walk pins totality
        }
        return capability
    }

    static func availability(
        _ id: CapabilityID, in context: CapabilityContext
    ) -> Capability.Availability {
        capability(id).availability(context)
    }

    /// Menu/bar enablement: anything but `.unavailable` (an `.actElsewhere`
    /// door is enabled — invoking performs the choreography).
    static func isEnabled(_ id: CapabilityID, in context: CapabilityContext) -> Bool {
        availability(id, in: context) != .unavailable
    }

    static func doored(_ door: Capability.Door) -> Set<CapabilityID> {
        Set(all.filter { $0.doors.contains(door) }.map(\.id))
    }

    // MARK: - The router's honest fallback speech

    /// What an unhandled dispatch says (no surface consumed the command in
    /// this context). Sourced from the capability's declared note — real
    /// refusals, never invented per-site.
    static func unhandledNote(for command: RoutedCommand, context: CapabilityContext) -> String {
        let id: CapabilityID
        switch command {
        case .takes(let takes):
            switch takes {
            case .toggleFan: id = .showTakes
            case .closeAll: id = .closeAllTakes
            case .branch: id = .newTake
            case .blank: id = .blankTake
            case .blankChoose: id = .blankTakeAsChosen
            case .choose: id = .chooseTake
            case .stepPrev: id = .previousTake
            case .stepNext: id = .nextTake
            case .archive: id = .archiveTake
            case .saveLens: id = .saveChoicesAsLens
            }
        case .structural(let act):
            switch act {
            case .divide: id = .divide
            case .extract: id = .extract
            case .makeBlock: id = .makeBlock
            case .merge: id = .merge
            }
        case .deleteInEveryTake: id = .deleteInEveryTake
        case .commit: id = .commitTake
        case .addBlockAtEnd: id = .addBlockAtEnd
        case .insertBlockBelow: id = .insertBlockBelow
        case .deleteBlock: id = .deleteBlock
        case .toggleSeal: id = .sealPost
        case .comments: id = .blockComments
        case .callout: id = .callout
        case .pageFan: id = .pageFanBack
        case .copyAllTakes: id = .copyAllTakes
        case .takeToBlockBelow: id = .takeToBlockBelow
        case .takesToBlocks: id = .takesToBlocks
        case .find(let action):
            switch action {
            case .show: id = .findInPost
            case .showReplace: id = .findAndReplace
            case .next: id = .findNext
            case .previous: id = .findPrevious
            case .useSelection: id = .useSelectionForFind
            }
        }
        return capability(id).unavailableNote
    }
}
