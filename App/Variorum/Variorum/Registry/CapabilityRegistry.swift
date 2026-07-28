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

    private static let always: @Sendable (CapabilityContext) -> Capability.Availability = { _ in .act }

    // MARK: - The table

    static let all: [Capability] = [
        // MARK: Structural (block scope)
        Capability(
            id: .divide, verb: "Divide Block at Cursor", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧D", takesAccess: .native,
            unavailableNote: "Dividing happens inside a post — open one first.",
            availability: divideAvailability),
        Capability(
            id: .extract, verb: "Extract Selection", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧E", takesAccess: .moveAndExecute,
            unavailableNote: "Extracting happens inside a post — open one first.",
            availability: structural),
        Capability(
            id: .makeBlock, verb: "Make Block from Selection", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧K", takesAccess: .moveAndExecute,
            unavailableNote: "Making a block happens inside a post — open one first.",
            availability: structural),
        Capability(
            id: .merge, verb: "Merge Blocks", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧M", takesAccess: .moveAndExecute,
            unavailableNote: "Merging happens inside a post — open one first.",
            availability: structural),
        Capability(
            id: .deleteInEveryTake, verb: "Delete in Every Take", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: nil, takesAccess: .moveAndExecute,
            unavailableNote: "Delete in Every Take works on a selection inside a post.",
            availability: structural),
        Capability(
            id: .addBlockAtEnd, verb: "New Block at End of Post", scope: .block,
            doors: [.menuBar, .bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Blocks are born inside a post — open one first.",
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
            unavailableNote: "Blocks are born inside a post — open one first.",
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
            unavailableNote: "Blocks live inside a post — open one first.",
            availability: takeFamily),  // the one named rule, not a copy

        // MARK: The take family (take scope)
        Capability(
            id: .showTakes, verb: "Show Takes", scope: .take,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧T", takesAccess: .native,
            unavailableNote: "Takes live inside a post — open one first.",
            availability: { ctx in
                if ctx.mode == .lenses { return .actElsewhere(.takes) }  // blooms live in Takes — GO there
                return takeFamily(ctx)
            }),
        Capability(
            id: .newTake, verb: "New Take (Branch)", scope: .take,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘T", takesAccess: .native,
            unavailableNote: "Takes grow on a block inside a post — open one first.",
            availability: takeFamily),
        Capability(
            id: .blankTake, verb: "New Blank Take", scope: .take,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌥⌘T", takesAccess: .native,
            unavailableNote: "Takes grow on a block inside a post — open one first.",
            availability: takeFamily),
        Capability(
            id: .blankTakeAsChosen, verb: "New Blank Take as Chosen", scope: .take,
            doors: [.menuBar, .bottomBar],
            shortcutLabel: "⇧⌥⌘T", takesAccess: .native,
            unavailableNote: "Takes grow on a block inside a post — open one first.",
            availability: takeFamily),
        Capability(
            id: .chooseTake, verb: "Choose This Take", scope: .take,
            doors: [.menuBar, .contextMenu, .palette],
            shortcutLabel: "⌘⏎", takesAccess: .native,
            unavailableNote: "Choosing happens among a block's takes — open a post first.",
            availability: takeFamilyPlusCanvas),
        Capability(
            id: .previousTake, verb: "Previous Take", scope: .take,
            doors: [.menuBar],
            shortcutLabel: "⌃⌘←", takesAccess: .native,
            unavailableNote: "Stepping through takes happens inside a post.",
            availability: takeFamilyPlusCanvas),
        Capability(
            id: .nextTake, verb: "Next Take", scope: .take,
            doors: [.menuBar],
            shortcutLabel: "⌃⌘→", takesAccess: .native,
            unavailableNote: "Stepping through takes happens inside a post.",
            availability: takeFamilyPlusCanvas),
        Capability(
            id: .archiveTake, verb: "Archive Take", scope: .take,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "⌘⇧A", takesAccess: .native,
            unavailableNote: "Archiving acts on the take you're in — open a post first.",
            availability: takeFamily),
        Capability(
            id: .saveChoicesAsLens, verb: "Save Choices as Lens…", scope: .post,
            doors: [.menuBar, .palette],
            shortcutLabel: "⌘⇧L", takesAccess: .native,
            unavailableNote: "Lenses save a post's choices — open a post first.",
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
        // 13b Stage 3 (3D — T5/N6): the 3B core op `setTakeLabel` gets its
        // faces — the take card's context menu and the bar's block menu.
        Capability(
            id: .labelTake, verb: "Label Take…", scope: .take,
            doors: [.contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Labels live on a take inside a post — open one first.",
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

        // MARK: Commit + undo
        Capability(
            id: .commitTake, verb: "Commit Take", scope: .take,
            doors: [.menuBar, .bottomBar, .palette],
            shortcutLabel: "⌘S", takesAccess: .native,
            unavailableNote: "Nothing to commit here — ⌘S commits a take inside a post.",
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
            id: .sealPost, verb: "Seal / Unseal Post", scope: .post,
            doors: [.bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Sealing acts on an open post — open one first.",
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
            unavailableNote: "Comments live on a block — open a post first.",
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
        Capability(
            id: .callout, verb: "Callout", scope: .block,
            doors: [.menuBar],
            shortcutLabel: "⌥⌘C", takesAccess: .native,
            unavailableNote: "Callout frames go on a block — open a post first.",
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

        // MARK: Modes + app scope
        Capability(
            id: .switchMode, verb: "Switch Mode (⌘1–⌘6)", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘1–6", takesAccess: nil,
            unavailableNote: "Open a post first — the modes live inside a post.",
            availability: { ctx in ctx.mode != nil ? .act : .unavailable }),
        Capability(
            id: .newPost, verb: "New Post", scope: .app,
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
        }
        return capability(id).unavailableNote
    }
}
