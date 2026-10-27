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

    /// **18l-c U7 — THE FIND ITSELF reaches the Takes board** (her R-18l-6:
    /// *"I think that we should add a search in takes mode, yes that will be
    /// this phase"*). ⌘F, ⌘G and ⇧⌘G act on the post detail's full-document
    /// editor (the family's rule above) AND on a mounted Takes board, which
    /// hosts its own find bar (`TakesFindBar` — a board of panes has no
    /// `NSTextFinder` to host, so the board's bar is its own, in the shipped
    /// bar's grammar). The board's condition is `takesBoard`'s exactly —
    /// the attachment, or the takes mode that mounts one — so the book
    /// spread's takes page finds too. The REPLACE half and ⌘E stay on
    /// `findFamily`: find-only v1 (her R-18l-9 — *"replace stays Write's"*).
    private static let findInNote: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        ctx.writeEditorOwnsScrollView || ctx.takesBoardAttached || ctx.mode == .takes
            ? .act : .unavailable
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
    /// Wave 2c made READ the one mode with NO editable surface; the Act 10
    /// correction round (R-cor-5/7) folded the Index tab INTO Read as its
    /// `edit` face, so the mode alone no longer says: Read is editable while
    /// its `edit` face is attached (`readEditAttached`, reported by the host
    /// like a takes board) and the projection tier while `read` shows — the
    /// family greys there honestly rather than rendering enabled over
    /// nothing (the enabled-into-nil class).
    private static let editableText: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        ctx.writeEditorAttached || ctx.takesBoardAttached || ctx.readEditAttached
            || (ctx.mode != nil && ctx.mode != .read)
            ? .act : .unavailable
    }

    /// **NOTE-SCOPED READING** (13j J2 — the tray). Wherever a note is on
    /// screen, "what has this note deleted" is a question with an answer:
    /// every post mode, plus the attached-editor/attached-board arms that
    /// cover the book-inline, spread and pool surfaces carrying no mode
    /// (`editableText`'s reach, for its reason — but this act edits nothing,
    /// so it wears its own name rather than borrowing that one's).
    private static let noteScoped: @Sendable (CapabilityContext) -> Capability.Availability = { ctx in
        ctx.writeEditorAttached || ctx.takesBoardAttached || ctx.mode != nil
            ? .act : .unavailable
    }

    private static let always: @Sendable (CapabilityContext) -> Capability.Availability = { _ in .act }

    /// **VX-154 (the VX-282 run) — the verbs that act where she writes are
    /// GREY while Write's take panel is up.** The panel is a sheet over Write
    /// showing ONE block's takes. Cutting, joining or adding blocks lands on
    /// blocks it never shows; the Takes board carries most of these to Write by
    /// a mode switch, which a sheet over Write cannot make; and the board's
    /// native insert/divide hand the ring to a block the panel does not render.
    /// So while the panel is up these doors are not live (P-2: a door that can
    /// never act in its context isn't rendered) — and the panel consumes any
    /// dispatch that still reaches it, so none falls to Write's caret beneath
    /// the sheet. The rule wraps each verb's own rule: with the panel down,
    /// nothing changes.
    private static func outsideWritesTakesPanel(
        _ rule: @escaping @Sendable (CapabilityContext) -> Capability.Availability
    ) -> @Sendable (CapabilityContext) -> Capability.Availability {
        { ctx in ctx.writeTakesPanelAttached ? .unavailable : rule(ctx) }
    }

    /// 18l-c U7: what ⌘F / ⌘G / ⇧⌘G answer where nothing can find. The find
    /// acts in Write AND on the Takes board now, so the note names both — a
    /// refusal must be true (P-2). (The replace half keeps its own note: it is
    /// still Write's alone.)
    static let findInNoteNote =
        "Find works in a note's Write or Takes mode — open one there (⌘1 or ⌘2)."

    // MARK: - The table

    static let all: [Capability] = [
        // MARK: Structural (block scope)
        Capability(
            id: .divide, verb: "Divide Block at Cursor", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧D", takesAccess: .native,
            unavailableNote: "Dividing happens inside a note — open one first.",
            availability: outsideWritesTakesPanel(divideAvailability)),
        // 13j J4 — **the divide CEREMONY's own door** (her sitting round-4
        // ruling). The default flipped to the duplicating divide, so the W
        // ceremony needs a summonable name and a key of its own; it keeps
        // divide's own availability rule because it mounts on exactly the
        // surfaces divide acts on (Write's editor AND both boards — the
        // sheet has mounted there since 13d Batch 3, which is why this is
        // `.native` rather than a carry). The FANNED precondition is the
        // ACT's, not the context's: the registry cannot see a block's arity,
        // so an unfanned target gets the operation-shaped refusal at the
        // door (`FannedDefaultsCopy.divideCeremonyNeedsAFan`) — the
        // `.showOriginBlock` split, P-2.
        // 18f batch 1 (her U-4, verbatim: *"'divide choosing takes' should
        // replace 'divide ceremony', since it's clearer. same with merge -
        // should be a BUTTON, not just a shortcut"*): the two summoned doors
        // join their plain twins in the bottom bar's block ▾ group, and the
        // merge one joins the two bulk bars' `.surface` rows beside Merge
        // Selected Blocks. A door she can only reach by remembering a
        // four-key chord is the discoverability class 13g's helper guard was
        // built for; this is the same lesson one level down.
        Capability(
            id: .divideWithCeremony, verb: "Divide choosing takes…", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌥⌘⇧D", takesAccess: .native,
            unavailableNote: "Dividing happens inside a note — open one first.",
            availability: outsideWritesTakesPanel(divideAvailability)),
        Capability(
            id: .extract, verb: "Extract Selection", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧E", takesAccess: .moveAndExecute,
            unavailableNote: "Extracting happens inside a note — open one first.",
            availability: outsideWritesTakesPanel(structural)),
        Capability(
            id: .makeBlock, verb: "Make Block from Selection", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧K", takesAccess: .moveAndExecute,
            unavailableNote: "Making a block happens inside a note — open one first.",
            availability: outsideWritesTakesPanel(structural)),
        Capability(
            id: .merge, verb: "Merge Blocks", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .palette],
            shortcutLabel: "⌘⇧M", takesAccess: .moveAndExecute,
            unavailableNote: "Merging happens inside a note — open one first.",
            availability: outsideWritesTakesPanel(structural)),
        // 13j J4b — **the merge CEREMONY's own door** (same ruling, same
        // shape). It keeps `merge`'s availability and `moveAndExecute`
        // access: the PAIRING sheet mounts in Write alone, so summoning it
        // from a board carries the pair there exactly as ⌘⇧M always has.
        Capability(
            id: .mergeWithCeremony, verb: "Merge choosing takes…", scope: .block,
            doors: [.menuBar, .contextMenu, .bottomBar, .surface, .palette],
            shortcutLabel: "⌥⌘⇧M", takesAccess: .moveAndExecute,
            unavailableNote: "Merging happens inside a note — open one first.",
            availability: outsideWritesTakesPanel(structural)),
        Capability(
            id: .deleteInEveryTake, verb: "Delete in Every Take", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: nil, takesAccess: .moveAndExecute,
            unavailableNote: "Delete in Every Take works on a selection inside a note.",
            availability: outsideWritesTakesPanel(structural)),
        // 13u4 UNIT C2 — her item 9, ruled R-13u4-4: the selected span leaves
        // the take it is in and becomes a take of its own on the same block,
        // with the quiet savepoint of the take it left as her cover for the
        // stay case.
        //
        // **TWO DOORS, both Write's, and both rendered CONDITIONALLY** (P-2):
        // the selection context menu and the bar's `block ▾` row appear only
        // where the selection lies inside ONE block — a cross-block span is
        // Make Block from Selection's population, not this act's, and a row
        // offering a gesture that could only refuse is what P-2 forbids. The
        // per-selection verdict is `SpanToTakeGesture.plan`'s (the act's own
        // brain, which also decides whether to render); this table's rule is
        // the CONTEXT half, and it is `writeEditor` — attachment only, the
        // `.previousBlock` family's rule, because the act calls the attached
        // full-document editor directly and enablement must never outrun it.
        //
        // **NO CHORD, and the sweep is recorded rather than implied**
        // (13u4 UNIT C2's record): the Take family's keys are all spoken for
        // (⌘T · ⌥⌘T · ⇧⌥⌘T · ⌘⇧T), the span family's are ⌘⇧E and ⌘⇧K, and the
        // free neighbours that remain (⌥⌘E, say) read as a VARIANT OF EXTRACT
        // rather than as this act — which is the collision the ⌥-means-the-
        // deliberate-variant convention exists to avoid. A chord would also
        // owe a `.menuBar` door and a helper row (the walk asserts both), so
        // it would be a third door this unit was not asked to build. Two
        // discoverable menu doors, no key.
        //
        // **TakesAccess is nil and the exemption is NAMED** — see the
        // registry walk's `exempt` set: a Takes-side shape for this gesture
        // is a product call nobody has made (QUESTIONS #128), not a door this
        // unit declined to wire.
        Capability(
            id: .moveSelectionToTake, verb: "Move Selection into a New Take", scope: .block,
            doors: [.contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote:
                "Moving a selection into a take happens where you write — open a note first.",
            availability: writeEditor),
        Capability(
            id: .addBlockAtEnd, verb: "New Block at End of Note", scope: .block,
            doors: [.menuBar, .bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Blocks are born inside a note — open one first.",
            availability: outsideWritesTakesPanel(takeFamily)),  // NIT-3: the one named rule, not a copy
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
            availability: outsideWritesTakesPanel(takeFamily)),  // the one named rule, not a copy
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
        // **The post-13l polish round, ledger row 4(c)** — her A4 ruling on
        // the 13l walk's P-8: the block's own CONTEXT menu had no way to
        // delete a block, while it carried **Archive Block** two rows down.
        // Those are the two verbs that must be told apart (one starts a
        // 30-day clock, one keeps the block forever), and only one of them
        // was where you right-click. The Block ▾ menu and the menu bar
        // carried both; the context menu carried half.
        Capability(
            id: .deleteBlock, verb: "Delete Block", scope: .block,
            // `.surface` = Blocks mode's row menu (the post-13l polish round,
            // ledger row 14 / F1): the door has been there since 13c and
            // undeclared the whole time; the pass that gave that row its
            // ARCHIVE twin declares them both.
            doors: [.menuBar, .bottomBar, .palette, .contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Blocks live inside a note — open one first.",
            availability: takeFamily),  // the one named rule, not a copy
        // 13j (her round-7 ruling — her own question: "do you think that we
        // should add block level archive? I think that it might be
        // worthwhile"). The third verb: ARCHIVE keeps the block forever in
        // this note's tray with no clock, where DELETE starts the Trash's
        // 30-day countdown and MOVE TO SCRAPS cuts the tie to the note. Two
        // SUMMONED doors — the Block menu and the block's context menu — and
        // deliberately no shortcut and no bar button: it is a deliberate,
        // occasional act, and the bars are daily chrome (her not-daily-chrome
        // criterion, round 4, applied one act over).
        //
        // **THE `.bottomBar` DOOR JOINS THEM** (the post-13l polish round,
        // ledger row 14 / F1 — her second morning report, softened to a
        // verification pass: *"no, I see archive there too"*). The pass found
        // exactly one class of straggler, and it is this one: both bars'
        // `block ▾` menus carried *"− Delete this block"* with no archive
        // beside it, so the two verbs that exist to be TOLD APART appeared
        // together in the menu bar and the context menu and separately in the
        // door she actually uses while writing. The not-daily-chrome argument
        // above still holds for a bar BUTTON, and this is not one — it is a
        // row inside a summoned menu, exactly where its twin already is.
        Capability(
            id: .archiveBlock, verb: "Archive Block", scope: .block,
        // **The `.surface` door is Blocks mode's row menu** (the same round,
        // the same pass): that menu has offered *"Delete block"* since 13c and
        // never declared it — a listing of this note's blocks with one of the
        // two verbs on it and neither in the registry. The pass that gives it
        // the other verb declares them both.
            doors: [.menuBar, .contextMenu, .bottomBar, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Blocks live inside a note — open one first.",
            availability: takeFamily),

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
            // `.surface` = Write's takes-panel card ⋯ (the post-13l polish
            // round, ledger row 14 / F1): the panel has rendered this row on
            // every card since Phase 7 and declared nothing, which is why the
            // grammar drift the pass went looking for was invisible.
            doors: [.menuBar, .contextMenu, .surface],
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
        // **THE TAKE-CARD GRAMMAR'S OTHER TWO** (the post-13l polish round,
        // ledger row 14 / F1). Her rule for this pass is that the card ⋯
        // menus MATCH — Write's panel carries Archive · Label · Lock ·
        // Delete, and Takes mode's cards must too. The pass found the Takes
        // board's cards carrying Archive and Label only, and found the reason
        // the drift was invisible: LOCK and DELETE had no declaration at all,
        // so no walk could see that one surface rendered them and the other
        // did not.
        //
        // Both are `.surface` + `.contextMenu` acts for `.unarchiveTake`'s
        // reason: the target is the CARD you pointed at, never a routed
        // context (a right-click never moves the keyboard — 13k K6's lesson).
        // `.deleteTake` is the take grain of the confirmation-consistency
        // principle's second clause: **takes do not confirm** — ⌥⌘Z is right
        // there and the block's History lists what went (13j's recorded
        // rule, and 13J's own comment above says so in as many words).
        Capability(
            id: .lockTake, verb: "Lock Take", scope: .take,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A take's lock is on its own card — open a block's takes.",
            availability: takeFamily),
        Capability(
            id: .deleteTake, verb: "Delete Take", scope: .take,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A take is deleted on its own card — open a block's takes.",
            availability: takeFamily),
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
        // 13e E2 (her A17: *"delete several blocks at the same time from a
        // post - highlighting all of the blocks perhaps? block highlight
        // instead of text highlight across blocks?"*). BLOCK scope, two door
        // families like its merge sibling: the surface banner each host
        // raises while a selection exists, and the block's own context menu.
        //
        // Its availability is `takeFamily`, NOT `takesBoard`, and the
        // difference is the whole shape of E2: her words name the surface
        // where text highlight across blocks is the alternative — Write —
        // and R118 then forbids leaving the board behind, so BOTH post
        // surfaces host the selection and both render the door. No chord:
        // the obvious key is ⌫, which belongs to the caret in the very
        // surface this act lives in, and a delete key that means two things
        // depending on invisible state is the class P-2 retired
        // (QUESTIONS #59(d)).
        Capability(
            id: .deleteSelectedBlocks, verb: "Delete Selected Blocks", scope: .block,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BlockSelectionCopy.nothingPicked,
            availability: takeFamily),
        // 18c batch 3 — **HER U-6**, verbatim: *"a 'make all newlines blocks'
        // button… that automatically just leaves any take at the top
        // paragraph of its block (aka, if you had a multi paragraph block now
        // the top paragraph is a block with all the takes)."* Her reason: a
        // note written with the newlines chip OFF meant *"a lot of divides to
        // run."*
        //
        // THREE declarations rather than one act with a target flag, the
        // `deleteBlock` / `deleteSelectedBlocks` split for its reason: the
        // whole NOTE, the block you stand in, and the blocks you picked are
        // three different things to point at, and one declaration could not
        // carry three unavailable-notes. No shortcut on any of them: this is
        // a deliberate repair, not daily chrome (her not-daily-chrome
        // criterion, 13j round 4).
        Capability(
            id: .splitEveryNewlineIntoBlocks, verb: "Make Every Newline a Block",
            scope: .post,
            doors: [.bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Open a note first — this repairs the note you're in.",
            availability: noteScoped),
        Capability(
            id: .splitBlockAtNewlines, verb: "Split This Block at Its Newlines",
            scope: .block,
            doors: [.bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Blocks live inside a note — open one first.",
            availability: takeFamily),  // the one named rule, not a copy
        Capability(
            id: .splitSelectedBlocksAtNewlines, verb: "Split at Newlines",
            scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BlockSelectionCopy.nothingPicked,
            availability: takeFamily),  // `deleteSelectedBlocks`' own rule
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
            // `.surface` = Write's takes-panel card ⋯ (row 14 / F1), the same
            // undeclared-since-Phase-7 renderer as `.archiveTake` above.
            doors: [.contextMenu, .bottomBar, .surface],
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
            unavailableNote: "Lenses are renamed from their column header in Lenses (⌘5).",
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
        // **The post-13l polish round, ledger row 4(b)** — her A4 ruling on
        // the 13l walk's P-8: *"I'd fix whatever this is"*. The walk
        // right-clicked a scrap in the Snippets list and found exactly one
        // row, "Tags…": every other listing of a thing in this app offers a
        // way to get rid of it, and the scrap's only delete door was inside
        // the scraps EDITOR's bottom bar — which means opening the editor to
        // throw away a line you can already see.
        //
        // It is its own act rather than a `.surface` door on `.deleteBlock`
        // for the reason `.tagBlock` is its own act: `.deleteBlock`'s
        // availability is the take family's (it needs an open note), and a
        // scrap row is POINTED AT DIRECTLY — the target is the row you
        // right-clicked, so there is no context in which a rendered door
        // cannot act. Same operation underneath (`deleteBlock`); the scrap
        // lands in the Trash for its 30 days like every other deletion, and
        // the receipt names that road.
        //
        // R118 exemption, recorded: the Snippets area sits OUTSIDE the
        // post-mode row entirely, exactly as `.tagBlock`'s doors do — no
        // editing mode is privileged over another, so Takes cannot be
        // "behind Write" where Write has no door either.
        //
        // **The #77 fence is untouched by construction:** this deletes a
        // BLOCK (`deleteBlock`), never the pool container — no door in this
        // app may tombstone the scraps area, and this one has no road to.
        Capability(
            id: .deleteScrap, verb: "Delete Scrap", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Scraps are deleted where you see them — the Snippets rows carry the door.",
            availability: always),
        // …and its THIRD VERB (the post-13l polish round, ledger row 14 /
        // F1). Her rule is that archive rides beside delete at every block
        // door, and a scrap is a block: `archiveBlock` keeps it forever with
        // no clock, and batch 3 already built the room it lands in — the
        // scraps area's own tray has an Archived section, reached by the same
        // icon a note's is. Declared like `.deleteScrap` and for its reason
        // (the target is the row you right-clicked, so `availability: always`),
        // and it inherits that act's R118 exemption for the same reason: the
        // Snippets area sits outside the post-mode row entirely.
        Capability(
            id: .archiveScrap, verb: "Archive Scrap", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Scraps are set aside where you see them — the Snippets rows carry the door.",
            availability: always),
        // 13e E8 — NOTE tagging, declared (P-1's "the registry grows to
        // cover a surface door as work touches it"; her 2026-08-02 word:
        // *"the registry should be kept up to date"*). The act is the
        // chips' ＋ / ✕ — one act with two renderers, the context bar
        // (13g R6-1 / 13k K12) and the Library's note rows (13e E8) — and
        // its availability is `always` for `.tagBlock`'s own reason: both
        // doors point at a note directly (the one this bar belongs to, the
        // one this row is), so there is no context in which a RENDERED
        // door cannot act. Nothing about the shipped faces changes; what
        // they gain is a catalog row, a written refusal, and walk coverage.
        Capability(
            id: .tagNote, verb: "Tag Note", scope: .post,
            // The Act 10 correction round (row 15): the act gained ⌘⇧I (the
            // retired fold's chord), a View-menu row and a ⌘K row — all
            // three open the masthead's ONE inline tag field; the Library's
            // rows keep their ＋ as the act's listing renderer.
            doors: [.menuBar, .palette, .surface],
            shortcutLabel: "\u{2318}\u{21e7}I", takesAccess: nil,
            unavailableNote: "Open a note to tag it — the \u{FF03} in its masthead opens the tag field.",
            availability: noteScoped),
        // 13e E7 — the canvas BANK (her sitting Round 2 pick; the 4E fork
        // she preserved, built as the FACE that ruling named). Both doors
        // are canvas-surface doors on the `.tagBlock` pattern: the target
        // is pointed at directly (the strip you can see, the card you
        // right-clicked), so availability is `always` and the R118 parity
        // table exempts them for the reason it exempts `.tagBlock` — the
        // canvas sits OUTSIDE the post-mode row, and no editing mode is
        // privileged over another.
        Capability(
            id: .toggleCanvasBank, verb: "Bank", scope: .post,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "The bank is the canvas's parking strip — open a canvas to see it.",
            availability: always),
        Capability(
            id: .returnCardToBank, verb: "Return to Bank", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "A card returns to the bank from the canvas it sits on.",
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
        //
        // **13j J3 gave the door its final grammar** (sitting rounds 4 + 5).
        // Three summoned doors, no ambient chrome: the block's right-click
        // menu (its row speaks the op — "See original from divide…" — through
        // `OriginPeekCopy.doorVerb`), ⌘K, and the History face's quiet
        // lineage row (`.surface`; the round-5 amendment, *"since it is
        // lineage"*). The VERB here is the target-less form the palette shows,
        // because a palette row has no block in hand to name the act that
        // released the original.
        Capability(
            id: .showOriginBlock, verb: OriginPeekCopy.genericVerb, scope: .block,
            // **The `.surface` door is GONE** (the post-13l polish round,
            // ledger row 17): it was the quiet lineage ROW inside the History
            // face, and the History face is now the Block History PANE, whose
            // came-from region is where this act LANDS rather than a door onto
            // it. Two doors remain, both summoned, exactly as her round-4
            // criterion asked ("not part of the daily chrome, just accessible
            // if needed").
            doors: [.contextMenu, .palette],
            shortcutLabel: nil, takesAccess: .native,
            // 13j J6: the global "Unplaced blocks" listing this note used to
            // name is GONE (her round-2 ruling). Released originals live in
            // the note's own tray now, and that is where this door lands.
            unavailableNote: "Released originals wait in \(TrayPath.menuLabel) — "
                + "\(TrayPath.doorPhrase).",
            availability: takeFamily),
        // 13j, sitting round 5 — the deleted take's way back. A `.surface`
        // act on the History face's own row (the `.unarchiveTake` shape): the
        // target is the row she points at. The note names the ROAD rather
        // than the state, because the one place this can be read with nothing
        // to act on is a context with no block in reach.
        Capability(
            id: .restoreTake, verb: "Put Back Take", scope: .take,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A deleted take waits in its block's History — "
                + "open a note and a block's History lists what it has deleted.",
            availability: takeFamily),
        // 13j J2 — **THE PER-NOTE TRAY.** Her words: *"you need to be able to
        // see the archived blocks (or deleted blocks) that are associated
        // with a particular post, because just going to the library you get a
        // little lost."*
        //
        // THREE doors for ONE act, all of them `.surface` since her C1 ruling
        // (the post-13l polish round, ledger row 9): *"the note tray should
        // move to being an icon next to the scraps and reference icon and open
        // in the side bar."* So the NAMED door is the post detail masthead's
        // tray icon; the context bar's quiet `⌫ N` badge is the glance signal
        // and opens the same panel (calm at rest — sitting round 1); the
        // scraps area's own header carries the third, because it composes the
        // same editor over a pool and its tray is the scraps area's.
        //
        // **The `note ▾` menu's `.bottomBar` item is GONE**, by her ruling:
        // *"the note ▾ menu item and ⌫ badge choreography follow the move"*.
        // Both bars lost it in the same commit — a removal is where R6-2's
        // one-grammar rule matters most.
        Capability(
            id: .showNoteTray, verb: TrayPath.menuLabel, scope: .post,
            // **The `.palette` door** (the post-13l polish round, the
            // architect's adjudication 1 of batch 3's flagged item): a book
            // spread's inline note mounts an editor with NO post detail
            // around it, so it has no masthead to carry the icon and no
            // context bar to carry the badge — the tray was unreachable
            // there. ⌘K is the standing universal fallback (R15) and costs
            // zero new surface; the icon stays the NAMED door.
            doors: [.surface, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Open a note and its tray lists what it has deleted.",
            availability: noteScoped),

        // **THE BLOCK HISTORY PANE** (the post-13l polish round, ledger row
        // 17 — G2). Her second-sitting ruling, verbatim: *"I know I just ruled
        // that history should go in the block menu, but I think I'm changing
        // my mind and it should be in the bottom chrome — my reasoning is that
        // history is quite similar to commit, it's the natural pair to
        // commit."*
        //
        // So the door is a `.bottomBar` one, beside `.commitTake`, and the
        // pairing is the point: ⌘S writes a moment, this shows the moments.
        // The ⌘K row rides beside it (a palette is summoned, not chrome).
        //
        // **It is BLOCK-scoped, and that is the defect it fixes.** Her F2
        // report: *"it's unclear that history is under Note, that makes it
        // seem like the Note's history."* The two faces this replaces were
        // reached through a `note ▾` menu and showed one take's savepoints;
        // this one is named for what it is and shows the whole block's time.
        Capability(
            id: .showBlockHistory, verb: BlockHistoryPath.name, scope: .block,
            doors: [.bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Put the caret in a block and its History shows "
                + "that block's saved moments, its archived and deleted takes, "
                + "and where it came from.",
            availability: takeFamily),

        // **THE WHOLE-NOTE VERSIONS DOOR** (the post-13l polish round, ledger
        // rows 16 and 23 — G1 and the V-family). Her ruling, verbatim: *"an
        // easy door would be to make a copy of the note, archive it, and then
        // let you look through the archived copies made at points in time —
        // not automated, but an easy door for people who want to save the
        // whole note as it is."*
        //
        // **TWO acts, and they are two on purpose.** Saving a moment is an
        // instant, keyable thing (⌘⇧S, the Mac's save-as chord, semantically
        // exact); opening the list of them is a panel. One declaration could
        // not carry both a key and a surface, and the pairing that teaches is
        // ⌘S↔⌘⇧S — this TAKE's moment beside this NOTE's — not save↔list.
        //
        // Both are POST-scoped and available wherever a note is: unlike the
        // block family, neither needs a caret. Where no note is reachable at
        // all they SPEAK the note below (P-2), never sit grey.
        Capability(
            id: .saveNoteVersion, verb: VersionsPath.saveVerb, scope: .post,
            doors: [.menuBar, .bottomBar, .palette],
            shortcutLabel: "\u{2318}\u{21E7}S", takesAccess: .native,
            unavailableNote: "Saving a version acts on the note you have open "
                + "— open one first.",
            availability: noteScoped),
        Capability(
            id: .showNoteVersions, verb: VersionsPath.name, scope: .post,
            doors: [.bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A note's saved moments live with the note — "
                + "open one and its \(VersionsPath.name) lists them.",
            availability: noteScoped),

        // **VX-372 (VX-383 U1 — D-C-2): DUPLICATE A NOTE, TWO ACTS, DECLARED
        // ONCE.** Her ticket: *"a direct duplicate door, with tags / without
        // tags; a duplicate with tags counts as tagging."* The verbs are hers
        // (P-C-1, PROVISIONAL for her VX-234 wording pass — "Duplicate as
        // Version" retires as a label; the versions machinery and the
        // `version_of` edge are unchanged), read from the ONE source the undo
        // entry's label reads (`Operations.DuplicateTags.verb`).
        //
        // Doors — the note-scoped neighbours' grammar, every place a note is
        // the target: the File menu beside Save a Version (`.menuBar`), ⌘K
        // (`.palette`), both bars' `note ▾` menus (`.bottomBar` — R6-2's one
        // grammar), and the note-row menus the Library and the Pool share
        // (`.contextMenu`, `SidebarView.contextMenuCapabilities`). WITH TAGS
        // is also the act the three shipped inline doors now run
        // (`.surface`): the Takes board's `note actions`, the Lenses board's
        // Chosen column, the book chip — they keep working, under its verb.
        //
        // The CONTEXT rule (`noteScoped`) governs the menu-bar, palette and bar
        // doors, which carry no target of their own; the ROW and INLINE doors
        // carry theirs (`.deleteNote`'s stated split). No chord (none asked —
        // and a key that mints a whole note is `.deleteNote`'s no-chord reason
        // in the other direction). A version-history note is never a target
        // (no door renders over one) and a scraps group is never one (the bars
        // gate on the note kind; the op's own refusal stands behind them).
        Capability(
            id: .duplicateNoteWithTags, verb: DuplicateCopy.withTagsVerb, scope: .post,
            doors: [.menuBar, .contextMenu, .palette, .bottomBar, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: DuplicateCopy.unavailableNote,
            availability: noteScoped),
        Capability(
            id: .duplicateNoteWithoutTags, verb: DuplicateCopy.withoutTagsVerb, scope: .post,
            doors: [.menuBar, .contextMenu, .palette, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: DuplicateCopy.unavailableNote,
            availability: noteScoped),

        // MARK: The deletion acts, and THE RULE THEY ALL INHERIT
        //
        // **THE CONFIRMATION-CONSISTENCY PRINCIPLE** (13j's close-of-day
        // deletion audit; written down here at 13l Act 2 so a future door
        // inherits it instead of re-deciding it):
        //
        //   · **NOTES CONFIRM.** A note is container-scale — it takes its
        //     blocks, their takes, its tags and its book memberships with it —
        //     and deleting one is a deliberate act, never a keystroke's side
        //     effect. `.deleteNote` and `.deleteSelectedNotes` ask, and the
        //     ask NAMES the Trash and its clock so the promise is readable
        //     before the press, not only after it. Books ask for the same
        //     reason (and add `deleteBookKeepsItsNotes`, because the scale
        //     there is the thing people get wrong).
        //   · **BLOCKS AND TAKES DO NOT.** They are in-flow acts inside the
        //     writing gesture — ⌥⌘Z is right there, and the note's own tray
        //     and the block's History list what went. J9 exists precisely to
        //     UNFRICTION paragraph deletion; a confirm on it would put the
        //     friction back where the ruling took it out.
        //   · **DELETE NOW AND EMPTY TRASH ALWAYS CONFIRM**, every time, with
        //     no don't-ask state anywhere in the code and none to be added
        //     (her round-10 ruling). They are the only unrecoverable acts in
        //     the app, which is the whole distinction: everything above is a
        //     tombstone with a road back, and these two are not.
        //
        // The line the principle draws is RECOVERABILITY × SCALE, not
        // destructiveness — every act named here is destructive.
        //
        // 13l Act 2 (ledger item 3) — **DELETE NOTE.** Her report at 13j's
        // close: *"how do i even delete a note? I'm within a note I want to
        // delete right now and I don't see how to delete it."* Four renderers
        // of ONE act: the `note ▾` menu in both bottom bars (the door she was
        // looking for, beside the tray item — R6-2's one grammar), and the
        // note-row context menu the Library and the Pool share.
        //
        // The CONTEXT rule (`noteScoped`) governs the BAR door, which has no
        // target of its own; the ROW doors carry theirs and apply their own
        // per-target condition — the standing `.toggleStar` / `.openInNewWindow`
        // split, stated so the reach is not read as an oversight.
        Capability(
            id: .deleteNote, verb: RecoveryCopy.deleteNoteTitle, scope: .post,
            // 13i-d U7 rider (F-U6-4): `.surface` — the Archived view's inline
            // "Delete Note…" on each row is a third renderer of this act.
            doors: [.bottomBar, .contextMenu, .surface],
            // NO CHORD, deliberately. The obvious candidate is ⌘⌫, and a key
            // that tombstones a whole note one finger-slip from ⌫ is exactly
            // the class P-2 retired at #59(d) — her ruling named menus, and
            // an invented chord would owe a collision sweep no ruling asked
            // for. It confirms either way; that is not a reason to add a key.
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Deleting a note acts on an open one — open one, "
                + "or use a note's row in the Library.",
            availability: noteScoped),
        // …and the BULK door (her ruling's third clause: *"allow for command
        // clicking to select multiple items and deleting all of them"*). A
        // `.surface` act on the Library's own list, the `.deleteNow` shape
        // exactly: app scope, `always`, and the per-gesture condition — a
        // selection exists — is the SURFACE's, because the selection is that
        // list's `@State` and pushing it into the app-scope router would be
        // wrong the moment a second window opens a second Library.
        Capability(
            id: .deleteSelectedNotes, verb: "Delete Selected Notes", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "\u{2318}-click notes in the Library to pick what goes.",
            availability: always),
        // The post-13l polish round (ledger row 25 — FOUND-ITEM 2). The THIRD
        // verb on a note row, declared at last. It is `always` for
        // `.deleteSelectedNotes`' exact reason: the target is the row she
        // right-clicked, carried by the door, not derived from whatever mode a
        // pane happens to be in — so `takesAccess: .native` is honest rather
        // than an exemption (Takes is not behind Write where neither owns the
        // row). Its two renderers are the Library's note rows and the Pool's,
        // exactly the pair `.deleteNote` reaches.
        Capability(
            id: .archiveNote, verb: "Archive", scope: .post,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Archiving acts on a note's row \u{2014} "
                + "right-click one in the Library. \(RecoveryPath.archivedSurface) keeps it, "
                + "with no countdown.",
            availability: always),
        // 13j batch 6b (J1 — the purge doors). `.surface` acts on the Trash's
        // own rows and header; app scope because a Trash row can be any kind,
        // and the surface itself is app chrome, not a mode. Both back onto ONE
        // op (`requestPurge` — the intent write); the janitor takes the
        // bytes when the horizon allows, and the receipts say exactly that
        // split (the J8 honesty bar).
        //
        // **THE IN-TRASH-ONLY RULE, EVOLVED** (the post-13l polish round,
        // ledger row 20 — her G5 fourth-sitting addition). 13j's round-3 rider
        // read *"inside the Trash only — never a door in a note or the editor,
        // ever"*; takes then LEFT the global Trash by her D1 ruling, which
        // would have left the capability with no door at all, so she placed
        // one on the take rows in the note's own leaving section *"to keep the
        // capability"*. The rule in its place, recorded for the closeout's
        // delta: **purge doors live in TRASH SURFACES — the global Trash and
        // the note-level trash section — and never in the writing flow.**
        // `.emptyTrash` is untouched: it is the global door and stays global.
        Capability(
            id: .deleteNow, verb: "Delete Now", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Delete Now lives where things are already "
                + "deleted — \(RecoveryPath.surface), and the Leaving section "
                + "of a note's own tray. Never in the writing itself.",
            availability: { _ in .act }),
        Capability(
            id: .emptyTrash, verb: "Empty Trash", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Empty Trash lives in the Trash — "
                + "\(RecoveryPath.surface) holds it, never a note.",
            availability: { _ in .act }),

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
        // 13n-b U4 — THE OFFER DOOR's KEYBOARD ROAD (R-13nb-23 (a), her
        // words: "which opening that needs a keyboard shortcut too"; AF-11
        // F-2). Every AI write receipt carries "Open ›"; this act opens the
        // most recent one's target THIS SESSION — alive after the line fades
        // and under receipt_style off (a chord racing a 6-second fade would
        // be a lying road). App scope, beside its veto (⌥⌘Z) in the Edit
        // menu; grey until an AI write has landed this session. ⌥⌘O: THE
        // COLLISION SWEEP is recorded at `EditorCommands.keyEquivalent`.
        Capability(
            id: .showLastAIChange, verb: "Show the AI\u{2019}s Last Change", scope: .app,
            doors: [.menuBar],
            shortcutLabel: "⌥⌘O", takesAccess: nil,
            unavailableNote: "No AI change to show yet — nothing a connected client wrote has landed this session.",
            availability: { ctx in ctx.aiLastChangeAvailable ? .act : .unavailable }),

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
        // VX-183 (the VX-282 run, U5 — VX-179 U1's O-2): THE PANEL'S OWN SIX
        // DOORS. `.surface` acts — each sits on the row whose comment it acts
        // on (the `.restoreTake` / `.deleteNow` shape), so no menu, bar or
        // palette door exists and none may grow without a ruling. The verbs
        // ARE the panel's words (sentence case, her no-shouty-caps rule — the
        // panel renders `verb`, so a word changed here changes there and
        // nowhere else). Available wherever the panel is open: the panel IS
        // the context (`always`, the `.deleteNow` posture); which row shows
        // which door is `CommentsPanelDoors` — per-row state, as data. Every
        // write refuses in the operations' own words (the seal, a race), the
        // panel speaking them (P-2). Keys: ⌘⏎ and ⎋ are the panel's local
        // monitor's (Add/Save and the ⎋ ladder), not menu keys — the
        // composer's hint line says them, so no `shortcutLabel` is declared.
        Capability(
            id: .addComment, verb: "Add", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A comment is added in its block's comments panel — Comments… (⌘⇧') opens it.",
            availability: always),
        Capability(
            id: .saveComment, verb: "Save", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A comment is saved where it is edited — its block's comments panel.",
            availability: always),
        Capability(
            id: .revertComment, verb: "Revert", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Revert puts an edited comment back — in its block's comments panel.",
            availability: always),
        Capability(
            id: .deleteComment, verb: "Delete", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A comment is deleted from its block's comments panel — it waits under Deleted there.",
            availability: always),
        Capability(
            id: .restoreComment, verb: "Restore", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "A deleted comment waits under Deleted in its block's comments panel.",
            availability: always),
        // The comment's PURGE door — the evolved rule's letter: purge doors
        // live in trash surfaces, never in the writing flow, and the panel's
        // deleted fold is one (it lists only what is already deleted — her
        // R-VX179-3 placement). Confirms every time (the Delete Now posture).
        Capability(
            id: .deleteCommentForever, verb: "Delete forever\u{2026}", scope: .block,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Delete forever lives under Deleted in a block's comments panel — "
                + "only for a comment already deleted, and it asks first.",
            availability: always),
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
        // *(18l-c U7 — that exemption's expiry clause, met for the FIND half:
        // the Takes board hosts its own find, so ⌘F · ⌘G · ⇧⌘G declare
        // `.native` below and leave the exemption; the replace half and ⌘E
        // keep it — R-18l-9, find-only v1.)*
        // 18l-c U7 (her R-18l-6): the FIND itself — ⌘F, ⌘G, ⇧⌘G — acts
        // natively on a mounted Takes board too (`findInNote`), so the three
        // leave the parity exemption and declare `takesAccess: .native`; the
        // replace half and ⌘E stay Write's (R-18l-9, find-only v1).
        Capability(
            id: .findInPost, verb: "Find in Note…", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘F", takesAccess: .native,
            unavailableNote: Self.findInNoteNote,
            availability: findInNote),
        Capability(
            id: .findAndReplace, verb: "Find and Replace…", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌥⌘F", takesAccess: nil,
            unavailableNote: "Find works in the note editor — open a note in Write (⌘1).",
            availability: findFamily),
        Capability(
            id: .findNext, verb: "Find Next", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘G", takesAccess: .native,
            unavailableNote: Self.findInNoteNote,
            availability: findInNote),
        Capability(
            id: .findPrevious, verb: "Find Previous", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⇧⌘G", takesAccess: .native,
            unavailableNote: Self.findInNoteNote,
            availability: findInNote),
        Capability(
            id: .useSelectionForFind, verb: "Use Selection for Find", scope: .post,
            doors: [.menuBar],
            shortcutLabel: "⌘E", takesAccess: nil,
            unavailableNote: "Find works in the note editor — open a note in Write (⌘1).",
            availability: findFamily),
        // 13e E9 — the takes-aware half. KEYLESS by the collision sweep's
        // verdict and by choice: the Find family's own keys are taken
        // (⌘F/⌥⌘F/⌘G/⇧⌘G/⌘E), and an act that edits takes she cannot see is
        // one to pick deliberately from a menu, not to hit by muscle memory
        // (#63(f)). It uses the find bar's OWN two strings, so its
        // availability is the family's — where there is no bar there is
        // nothing to replace with.
        Capability(
            id: .replaceAllInEveryTake, verb: "Replace All in Every Take", scope: .post,
            doors: [.menuBar],
            shortcutLabel: nil, takesAccess: nil,
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
        // primary door and K7's toolbar is already eight wide.
        //
        // **13u4 UNIT S1 (her item 5) — THESE TWO GAINED ⌘] / ⌘[, PROVISIONAL
        // (QUESTIONS #130).** Her report: *"command [ is moving me between my
        // different open notes ? is that supposed to do that? I thought it
        // unindented things. related - how are things unindented?"* Both
        // halves were true: ⌘[ WAS `.navigateBack` (13f W16), and unindent
        // was reachable only by ⇧Tab or a Format-menu row with no key.
        //
        // The measured ground for the swap (the unit record's audit 1): ⌘[/⌘]
        // are **outdent/indent in Apple Notes and in Pages** — Apple's own
        // writing apps, documented in their own shortcut guides — and in
        // Xcode and VS Code; they are **back/forward in Finder and Safari**.
        // There is no HIG rule naming them, so 13f W16's stated reason
        // (*"the platform's own back/forward idiom"*) is true of navigation
        // CHROME and false of the app category this app is in. **Apple Notes
        // resolves the same collision the same way:** ⌘[/⌘] change the list
        // level, and ⌥⌘[/⌥⌘] are its link back/forward — which is exactly
        // where `.navigateBack`/`.navigateForward` moved below.
        //
        // The Tab pair is UNCHANGED and is still the primary door: ⇥ is not
        // a menu key equivalent and must never become one (it would be taken
        // from every control in the app), so it stays in the surfaces'
        // `insertTab`/`insertBacktab` where ⏎'s lives. What these labels add
        // is a key the menu can WEAR — which is what makes the act findable
        // at all, and is the half of her report a tab of settings cannot fix.
        Capability(
            id: .formatIndent, verb: "Indent", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "\u{2318}]", takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),
        Capability(
            id: .formatOutdent, verb: "Outdent", scope: .block,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: "\u{2318}[", takesAccess: .native,
            unavailableNote: "Formatting acts on the text you're writing — open a note first.",
            availability: editableText),

        // MARK: Modes + app scope
        Capability(
            // 17y B2 (p): the span is the BUILD's row (⌘1–⌘6 in Release,
            // where Canvas is gone) — from `PostMode`'s one seam.
            id: .switchMode, verb: "Switch Mode (\(PostMode.keySpan()))", scope: .post,
            doors: [.menuBar],
            shortcutLabel: PostMode.keyLabel(), takesAccess: nil,
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
        // **13u4 UNIT S1 (her item 5) — THE CHORDS MOVED TO ⌥⌘[ / ⌥⌘],
        // PROVISIONAL (QUESTIONS #130).** The acts, their doors, their
        // availability and the context bar's ← → are byte-unchanged; only
        // the keys moved, onto the pair **Apple Notes itself uses for
        // back/forward** while its plain brackets change the list level.
        // The collision sweep's result: ⌥⌘[ and ⌥⌘] are FREE — swept across
        // `EditorCommands.keyEquivalent`, every `.keyboardShortcut(` call
        // site in `Variorum/` and `Shared/` (the ONLY bracket chords in the
        // app were these two), every `NSMenuItem` keyEquivalent (all empty
        // strings) and both `performKeyEquivalent` overrides (⌘S, plus J7's
        // non-consuming ⌘Z/⌘⇧Z hint arm) — no bracket anywhere carries ⌥.
        Capability(
            id: .navigateBack, verb: "Back", scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: "\u{2325}\u{2318}[", takesAccess: nil,
            unavailableNote: "Nothing to go back to — this is where you started.",
            availability: { ctx in ctx.canNavigateBack ? .act : .unavailable }),
        Capability(
            id: .navigateForward, verb: "Forward", scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: "\u{2325}\u{2318}]", takesAccess: nil,
            unavailableNote: "Nothing to go forward to — you haven't gone back.",
            availability: { ctx in ctx.canNavigateForward ? .act : .unavailable }),
        // VX-287 (the VX-283 run, U1) — **CLOSE NOTE**, her ruling verbatim:
        // *"for command W - can we do shift command W? i like that better than
        // control, it's more natural to type. i think landing in the next note
        // on the list is perfect-that way you can close them all quickly."*
        // The focused pane's note leaves the Open list AND the pane moves on —
        // to the next row, else the previous one, else the Library
        // (`WorkspaceModel.closeFocusedNote`; the fallbacks PROVISIONAL, the
        // ticket's). VIEW-ONLY: the note itself is untouched. ⌘W is not ours
        // and stays the system's File ▸ Close (it closes the window).
        //
        // THE COLLISION SWEEP (2026-10-14, on `a2a27a10` — the U1 record's P0):
        // ⌘⇧W is FREE in the app — no `w` chord in `EditorCommands.keyEquivalent`,
        // no "w" at any `.keyboardShortcut(` call site in `Variorum/` and
        // `Shared/`, every `NSMenuItem` keyEquivalent "", no `w` in the one
        // `performKeyEquivalent` override (⌘S + the ⌘Z/⇧⌘Z hint arm) or any
        // local key monitor, the system hot keys [.quickNote] only; the
        // note-only and quick-note windows bind no W, and the gate below greys
        // the key there (only a FULL window has an Open list). The system half
        // (AppKit's own File-menu items under window tabbing) is the record's
        // measured check.
        //
        // App scope, `takesAccess: nil`: a workspace act like its neighbours.
        Capability(
            id: .closeNote, verb: "Close Note", scope: .app,
            doors: [.menuBar],
            shortcutLabel: "\u{2318}\u{21e7}W", takesAccess: nil,
            unavailableNote: "There's no note in this pane to close — open one and "
                + "\u{2318}\u{21e7}W closes it and moves on to the next.",
            availability: { ctx in
                ctx.windowKind == .full && ctx.focusedPaneShowsNote ? .act : .unavailable
            }),
        // VX-289 (the VX-283 run, U1) — **CLOSE ALL NOTES**, her triage word
        // (2026-10-14): *"close all now is good"* (the selection half is VX-344).
        // Every Open row closes; a pane showing a note lands by Close Note's
        // rule — with the list empty, the Library. Two doors: the Open list's
        // right-click (`SidebarView.openListMenuCapabilities`) and the View
        // menu's twin. Keyless — the ruling named the doors, not a chord.
        // VIEW-ONLY like its sibling. The verb says "Notes" because the bare
        // "Close All" is the system's own File-menu word for closing WINDOWS.
        Capability(
            id: .closeAllNotes, verb: "Close All Notes", scope: .app,
            doors: [.menuBar, .contextMenu],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "No notes are open in this window — the Open list is already empty.",
            availability: { ctx in
                ctx.windowKind == .full && ctx.openNoteCount > 0 ? .act : .unavailable
            }),
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
        // The Act 10 correction round, batch A (row 2): the sidebar toggle,
        // declared. THE COLLISION SWEEP'S RESULT: ⌃⌘S is FREE — the only `s`
        // chords in the app are ⌘S (commit) and ⌘⇧S (save a version), and
        // the control-command family holds ⌃⌘L and the four take/block
        // arrows; ⌃⌘S is the platform's own Toggle Sidebar chord.
        Capability(
            id: .toggleSidebar, verb: WorkspaceNaming.toggleSidebarVerb, scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: "\u{2303}\u{2318}S", takesAccess: nil,
            unavailableNote: "Only a full window has a sidebar — this one shows a single note.",
            // 18o U1 (17e (12)): the grey the View-menu item always applied,
            // declared HERE — it used to be `always` with the real gate living
            // as a per-view if-statement on the menu item (P-1: gating is
            // data). The toolbar door needs no gate: only a full window
            // renders it.
            availability: { ctx in ctx.windowKind == .full ? .act : .unavailable }),
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
        // 13e E14 (W26, her kickoff-sitting Round 5): a FOURTH door on the
        // SAME act — the system hot key ⌃⌥⌘N, which reaches the pad while
        // any app is frontmost and needs no click. It is another door here
        // rather than a second capability because it is the same summon of
        // the same pad (P-1: every act declared exactly once), and it wears
        // its own label because it is its own key on its own mechanism —
        // ⌘⇧N is SwiftUI's, ⌃⌥⌘N is Carbon's.
        Capability(
            id: .quickNote, verb: QuickNoteCopy.verb, scope: .app,
            doors: [.menuBar, .menuBarExtra, .palette, .systemHotKey],
            // THE COLLISION SWEEP'S RESULT (13f batch 6): ⌘⇧N is FREE —
            // swept across `EditorCommands.keyEquivalent` (36 chords),
            // every `.keyboardShortcut(` call site in `Variorum/` and
            // `Shared/`, every `NSMenuItem` key equivalent (all empty
            // strings) and the one `performKeyEquivalent` override (⌘S).
            // No `n` chord carries shift; the nearest neighbour is ⌘N New
            // Post, which is exactly the right neighbour — ⌘N makes a
            // note, ⌘⇧N pops the pad.
            shortcutLabel: "\u{2318}\u{21e7}N", takesAccess: nil,
            unavailableNote: "", availability: always,
            // 13e E14's COLLISION SWEEP: ⌃⌥⌘N is free in the app's own table
            // (no `n` chord carries control or option — ⌘N is New Post and
            // ⌘⇧N is this pad's in-app door), and it is free of the system's
            // own reserved combinations. Registered with Carbon, so it also
            // must not SHADOW an in-app chord — pinned by
            // `noSystemChordShadowsAnInAppOneOrAnother`. FB15168205's reported sandbox
            // regression class is ⌥-only and ⌥⇧ chords; this one carries ⌃
            // and ⌘ and sits outside it (and the sitting's live probe fired
            // it three times with no prompt).
            systemShortcutLabel: "\u{2303}\u{2325}\u{2318}N"),
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
            unavailableNote: "Peer columns live on the Compare board (\u{2318}6).",
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

        // 13i-b U2 — THE ARRIVALS FACE (the 13i-b plan §3; the sitting record
        // §4). Two `.surface` acts on the Arrivals line's own rows
        // (`BookArrivalsList` — their ONE renderer, the masthead door's popover since 17y (h)), book scope. `always` for
        // `.archiveNote`'s exact reason: the target is the arrival row the
        // door carries, never derived from whatever mode a pane is in — so
        // `takesAccess: .native` is honest rather than an exemption (Takes is
        // not behind Write where neither owns the row). No key and no palette
        // row: her ruling placed the judgment ON the line, and an invented
        // chord would owe a collision sweep no ruling asked for. The per-row
        // conditions — capacity, a finished book, a row already judged — are
        // the operation's own refusals, spoken on the status seam (P-2).
        Capability(
            id: .seatArrival, verb: ArrivalsCopy.addVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: ArrivalsCopy.unavailableNote,
            availability: always),
        Capability(
            id: .dismissArrival, verb: ArrivalsCopy.dismissVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: ArrivalsCopy.unavailableNote,
            availability: always),

        // 13i-b U3 — THE RULE EDITOR (the 13i-b plan §4 item 1). One door on
        // the shelf row's menu, for gatherings AND books (a book's rule IS its
        // intake), replacing the retired v1 "Edit Filter…" sheet. Book scope,
        // `always`, `takesAccess: .native` for the arrival doors' exact
        // reason: the row carries its target, never a mode. No key and no
        // palette row — no ruling asked for one (13i-d re-homes the face
        // into the Collecting pane and its own doors).
        // 13i-c U3: + `.surface` — the Book Settings sheet's Collecting
        // section renders this act as its "Edit…" door (her post-close
        // ruling 2, the discoverability report: the rule editor had NO door
        // from inside the book). Same act, a second door family.
        Capability(
            id: .editRule, verb: RuleEditorCopy.editVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: RuleEditorCopy.unavailableNote,
            availability: always),
        // 13i-b U3 — THE TWO STRENGTHENING DOORS (the sitting record §3). Both
        // on the shelf row's menu of a GATHERING, `always` for `.editRule`'s
        // reason (the row carries its target). Bind's other two roads open
        // the SAME confirm and are not doors of their own in this table: the
        // book navigator's "+ new chapter" on a gathering is the chapter
        // act's choreography (P-2), and the teaching moment is an OFFER on
        // the status seam (18i), the kind the `.divergeForBook` toast
        // precedent never declared as a door. The per-target condition — a
        // finished gathering refuses a bind — is the op's, and the menu hides
        // the door there (P-2).
        Capability(
            id: .bindIntoBook, verb: BindCopy.bindVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BindCopy.bindUnavailable,
            availability: always),
        Capability(
            id: .makeBookFromGathering, verb: BindCopy.spawnVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BindCopy.spawnUnavailable,
            availability: always),

        // 13i-c U3 — THE BOOK'S STATE DOORS (the sitting record §5, §6, §24;
        // the 13i-c plan §5, R-13ic-3). Two door families per act: the shelf
        // row's menu (`.contextMenu`) and the Book Settings sheet's STATE
        // section (`.surface` — the sheet points at its own book). `always`
        // for `.editRule`'s exact reason: the row and the sheet each carry
        // their target, never a mode — so `takesAccess: .native` is honest
        // rather than an exemption. WHICH of each pair renders for a given
        // book is DATA, `BookStateDoorSet.rendered(for:)` (finished ⇒ Reopen,
        // sealed ⇒ Unseal and no Reopen, owned ⇒ Stop Owning, a gathering ⇒
        // the finish pair only — Seal and Own refuse a gathering, P-2). The
        // per-target refusals that remain (owning a finished or sealed book)
        // are the operation's own, spoken in `BookStateCopy.refusal`.
        Capability(
            id: .finishBook, verb: BookStateCopy.finishVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        Capability(
            id: .reopenBook, verb: BookStateCopy.reopenVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        Capability(
            id: .sealBook, verb: BookStateCopy.sealVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        Capability(
            id: .unsealBook, verb: BookStateCopy.unsealVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        Capability(
            id: .ownBook, verb: BookStateCopy.ownVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        Capability(
            id: .unownBook, verb: BookStateCopy.unownVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        // 13i-c U3 — DELETE A BOOK to the Trash (R-13ic-4's face). Its
        // renderers: the shelf row's menu (the shipped "Delete Book", now
        // drawn from here) and the rule editor's gathering gate ("Delete this
        // gathering…" — the `.surface` door, its target the sheet's own
        // gathering). U4's two-choice confirm and the settings sheet's door
        // extend THIS declaration. `always`, the row/sheet carries its target.
        Capability(
            id: .deleteBook, verb: BookStateCopy.deleteVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        // 13i-e U2 — BOOK ARCHIVE (R-13ie-1…4). Archive: the Bookcase row's
        // menu (`.contextMenu`) and the Book Settings sheet's State section
        // (`.surface`). Unarchive: the Archived surface's book rows and the
        // sheet (`.surface` — an archived book is never on the Bookcase).
        // `always` for `.editRule`'s reason (every renderer carries its
        // book); WHICH renders is DATA — `BookArchiveDoorSet` (archived ⇒
        // Unarchive, else Archive; the daily Journal never offers Delete).
        // The archive acts' own refusals (already archived / not archived)
        // are the operations', spoken through the shared table.
        Capability(
            id: .archiveBook, verb: BookStateCopy.archiveVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        Capability(
            id: .unarchiveBook, verb: BookStateCopy.unarchiveVerb, scope: .book,
            // 17y B3 item (l): + `.contextMenu` — the book row menu beyond
            // the Bookcase (`BookRowMenu`) renders it on an archived book
            // (the Archived surface's rows, an archived starred book).
            doors: [.surface, .contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookStateCopy.unavailableNote,
            availability: always),
        // 13i-c U4 — THE MEMBERSHIP CHOICE (the sitting record §6; the plan
        // §3/§4 rows 14–19). Two `.surface` acts, two renderers each: the
        // ONE choice sheet (`MembershipChoiceSheet` — hosted by the chip's
        // Add, the Pool's add, the shelf row's drop, Manage Notes…) and the
        // Arrivals rows (`BookArrivalsList` — the judgment arms on an
        // owned book's or an owned-elsewhere note's bell). `always` for
        // `.seatArrival`'s reason: the sheet and the row carry their pair,
        // never a mode — so `takesAccess: .native` is honest. The per-pair
        // refusals (a finished target, a finished book Move would leave, a
        // full book) are the operations' own, spoken on the status seam.
        Capability(
            id: .copyIn, verb: MembershipChoiceCopy.copyInVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: MembershipChoiceCopy.unavailableNote,
            availability: always),
        Capability(
            id: .moveIn, verb: MembershipChoiceCopy.moveInVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: MembershipChoiceCopy.unavailableNote,
            availability: always),
        // 13i-c U4 — THE REMOVE/RELEASE DOOR (the sitting record §20). Two
        // door families: the book's note-row CONTEXT menus (the navigator's
        // and Outline's rows — `BookView`) and the sidebar note box's book
        // context (`SidebarNoteBox`), and the `.surface` rows that carry their
        // book (the chip's rows, the Index row's ⋯ menu, Manage Notes…).
        // `always`: every renderer carries its note AND its book; the per-pair
        // refusals (a finished or sealed book) are the op's, named for the
        // book with its road (`BookStateCopy.refusal`). The verb is the plain
        // book's; an owned book's renderers say `RemoveFromBookCopy.verb`.
        Capability(
            id: .removeFromBook, verb: RemoveFromBookCopy.removeVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: RemoveFromBookCopy.unavailableNote,
            availability: always),
        // 13i-c U4 — DUPLICATE BOOK… (§6): the shelf row's menu, books only
        // (a gathering has no duplicate op — the menu hides it, P-2). `always`
        // for `.editRule`'s reason (the row carries its target); the per-book
        // shape (owned ⇒ with copies only) is the door's word and its sheet's
        // fixed checkbox; a taken name is E13's refusal, said in the sheet.
        Capability(
            id: .duplicateBook, verb: DuplicateBookCopy.verb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: DuplicateBookCopy.unavailableNote,
            availability: always),
        // 13i-d U1 — THE BOOKCASE (the sitting record §7, §19–§24). Every act
        // below carries its target on the thing she points at (a shelf name,
        // a section header, a book row), so `always` is honest for
        // `.editRule`'s reason; the per-target conditions are DATA the menus
        // read (Move to Start hides on the first shelf, Send to Top/Bottom
        // render only in "my order" — the placing mode, §24), never a mode of
        // this table. The strip's renderers declare them in
        // `BookcaseStrip.contextMenuCapabilities` / `.surfaceCapabilities`;
        // the book row's in `ShelfView.contextMenuCapabilities`.
        Capability(
            id: .newShelf, verb: BookcaseCopy.newShelfVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .renameShelf, verb: BookcaseCopy.renameShelfVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .setShelfGlyph, verb: BookcaseCopy.setGlyphVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .makeDefaultShelf, verb: BookcaseCopy.makeDefaultVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .moveShelfToStart, verb: BookcaseCopy.moveToStartVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .moveShelfToEnd, verb: BookcaseCopy.moveToEndVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .deleteShelf, verb: BookcaseCopy.deleteShelfVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .moveBookToShelf, verb: BookcaseCopy.moveToShelfVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.unavailableNote,
            availability: always),
        Capability(
            id: .sendBookToTop, verb: BookcaseCopy.sendToTopVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.placingUnavailableNote,
            availability: always),
        Capability(
            id: .sendBookToBottom, verb: BookcaseCopy.sendToBottomVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookcaseCopy.placingUnavailableNote,
            availability: always),
        // 13i-d U2 — THE BOOK PANEL. Its door is the note masthead's book
        // icon (`.surface`, the inspector cluster beside the tray, scraps and
        // references — the panel's own declaration in `PostDetailView`);
        // `noteScoped` for the tray's reason (a note must be open). The five
        // structure doors are the panel's row menus (`BookPanelView`) — the
        // menu twins of its drags — `always` for `.editRule`'s reason (each
        // row carries its note, its chapter and its book); the per-target
        // conditions (a chapter's first note has no Move Up; a book read in a
        // stamp order shows no hand position) are DATA the menu reads
        // (`BookPanelBrain`), and a finished book's refusal is the op's own,
        // spoken with its road (#25(b)'s precedent).
        Capability(
            id: .showBookPanel, verb: BookPanelCopy.showVerb, scope: .post,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookPanelCopy.unavailableNote,
            availability: noteScoped),
        // 13i-d U3 (F-U2-3): + `.surface` — the book Index row's ⋯ menu
        // renders it too (that menu's doors are `.surface`, the remove door's
        // precedent); the navigator's and Outline's rows are `.contextMenu`.
        Capability(
            id: .fileNoteInChapter, verb: BookPanelCopy.fileInChapterVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookPanelCopy.structureUnavailableNote,
            availability: always),
        Capability(
            id: .moveNoteUpInBook, verb: BookPanelCopy.moveNoteUpVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookPanelCopy.structureUnavailableNote,
            availability: always),
        Capability(
            id: .moveNoteDownInBook, verb: BookPanelCopy.moveNoteDownVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookPanelCopy.structureUnavailableNote,
            availability: always),
        Capability(
            id: .moveChapterUpInBook, verb: BookPanelCopy.moveChapterUpVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookPanelCopy.structureUnavailableNote,
            availability: always),
        Capability(
            id: .moveChapterDownInBook, verb: BookPanelCopy.moveChapterDownVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookPanelCopy.structureUnavailableNote,
            availability: always),
        // The gathering's honest door (§20): "Remove the #tag" — the chip's
        // gathering rows, one per rule tag the note wears.
        Capability(
            id: .removeRuleTag, verb: RemoveFromBookCopy.removeTagVerb(path: "tag"),
            scope: .post,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: RemoveFromBookCopy.removeTagUnavailableNote,
            availability: always),
        // 13i-d U3 — THE COLLECTING PANE'S DOORS (the sitting record §4, §10)
        // and THE FILTER BAR's save (§18.1). `.openBookSettings`: two door
        // families — the Bookcase row's menu (`.contextMenu`, the road §4
        // names) and the book masthead's gear (`.surface`, the book's own
        // door; its target is the book on screen). `.setJournalTrait`: the
        // sheet's Collecting row (`.surface`). `.saveFilterAsGathering`: the
        // Index filter bar's word (`.surface`). All `always` for `.editRule`'s
        // reason — each renderer carries its book, never a mode; the per-book
        // refusals (the daily Journal's constitutive trait, a finished book,
        // a malformed gathering rule) are the operations' own, spoken.
        Capability(
            id: .openBookSettings, verb: CollectingCopy.openVerb, scope: .book,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: CollectingCopy.openUnavailableNote,
            availability: always),
        // 13o U3 — the book masthead's 🔍 (R-13o-14), its one renderer.
        Capability(
            id: .searchThisBook, verb: "Search This Book\u{2026}", scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "", availability: always),
        // VX-217 — a new note born inside a gathering: the navigator foot and
        // the Outline flow's end (`.surface`). `always` for `.editRule`'s
        // reason — each renderer carries its gathering; where the act can't
        // land the door GREYS and says why (R-VX214-3), and the op refuses
        // with the same words (`GatheringMint.Blocker.reason`).
        Capability(
            id: .newNoteInGathering, verb: GatheringNoteDoorCopy.verb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: GatheringNoteDoorCopy.unavailableNote, availability: always),
        // VX-570 (the VX-439 run — A-439-4 + C-570-1; her 10-21 note:
        // "command for new note within a book"): ⌥⌘N mints a member of the
        // book the KEY window's focused pane shows, in any book mode (Index
        // included), through the ONE act that book's own foot door runs —
        // "+ new note" (`newPostInReading`), "+ new entry" on a journal-trait
        // book (`newEntry`), and on a gathering the planner's note
        // (`.newNoteInGathering`'s act, `newPostInGathering`). Its refusals
        // are those doors' own, the operations layer's words on the book's
        // line (a finished book, a full one, a rule a new note can't match).
        // Doors: the File menu beside New Note (`.menuBar`), ⌘K (`.palette`),
        // and the book foot's and Outline flow's "+ new note"/"+ new entry"
        // (`.surface` — `BookView.surfaceCapabilities`; undeclared until now).
        // Grey wherever the focused pane shows no book (P-2) — a note in its
        // own pane is not a book context.
        //
        // `takesAccess: nil`, EXEMPT from the R118 parity table for
        // `.openBookAtNote`'s reason, one step over: a BOOK-surface act. Its
        // context is the book view, which carries no post mode, so no note
        // mode can be "behind" another here — Write is as grey as Takes.
        //
        // **⌥⌘N — THE COLLISION SWEEP (2026-10-27, on `9637e5be2`).**
        // `EditorCommands.keyEquivalent`'s `n` chords are ⌘N (New Note) and
        // ⌘⇧N (the quick note); 13b 4D's old ⌥⌘N (New Block Below) moved to
        // ⌘⇧⏎ at 13d batch 4 and no table, `.keyboardShortcut(` call site or
        // key override carries it since; the system hot key is ⌃⌥⌘N (Carbon,
        // a different chord — `noSystemChordShadowsAnInAppOneOrAnother` holds
        // the pair apart); macOS reserves no ⌥⌘N. It reads as the ⌥
        // "deliberate variant" of ⌘N: a new note, placed somewhere chosen.
        Capability(
            id: .newNoteInBook, verb: "New Note in This Book", scope: .book,
            doors: [.menuBar, .palette, .surface],
            shortcutLabel: "\u{2325}\u{2318}N", takesAccess: nil,
            unavailableNote: "New Note in This Book makes a note inside the book you have open "
                + "\u{2014} open a book first.",
            availability: { ctx in ctx.focusedPaneShowsBook ? .act : .unavailable }),
        Capability(
            id: .setJournalTrait, verb: CollectingCopy.journalTraitVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: CollectingCopy.openUnavailableNote,
            availability: always),
        Capability(
            id: .saveFilterAsGathering, verb: BookFilterCopy.saveVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: BookFilterCopy.unavailableNote,
            availability: always),
        // 13i-d U4 — the archived line's Unarchive (the target is the row the
        // door carries — `.archiveNote`'s `.native` precedent; 13i-d U6: the
        // Library's Archived view's row is its second renderer, F-U4-4), and the
        // F-U3-5 rider: a gathering's hide-owned row (book scope — the sheet
        // carries its target).
        Capability(
            id: .unarchiveNote, verb: ArchivedLineCopy.unarchiveVerb, scope: .post,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: ArchivedLineCopy.unavailableNote,
            availability: always),
        Capability(
            id: .setReadingHideOwned, verb: CollectingCopy.hideOwnedVerb, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: CollectingCopy.openUnavailableNote,
            availability: always),
        // 13i-d U5 — WINGS. The switcher's acts carry their target (the
        // current wing — Rename/Delete render only on an ADDITIONAL wing,
        // DATA the menu reads, never a mode of this table), so `always` is
        // honest for `.editRule`'s reason; app scope (a wing is above every
        // book and note). The note doors carry their row (`.archiveNote`'s
        // `.native` precedent) and render only while another wing exists
        // (P-2 — a door that can never act is not drawn).
        Capability(
            id: .newWing, verb: WingCopy.newWingVerb, scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: WingCopy.unavailableNote,
            availability: always),
        Capability(
            id: .renameWing, verb: WingCopy.renameWingVerb, scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: WingCopy.unavailableNote,
            availability: always),
        Capability(
            id: .deleteWing, verb: WingCopy.deleteWingVerb, scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: WingCopy.unavailableNote,
            availability: always),
        Capability(
            id: .moveNoteToWing, verb: WingCopy.moveToWingVerb, scope: .post,
            // 13i-d U6 (k): + the note ▾ menu in both bars (R6-2's grammar).
            doors: [.contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: WingCopy.noteUnavailableNote,
            availability: always),
        Capability(
            id: .copyNoteToWing, verb: WingCopy.copyToWingVerb, scope: .post,
            // 13i-d U6 (k): + the note ▾ menu in both bars (R6-2's grammar).
            doors: [.contextMenu, .bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: WingCopy.noteUnavailableNote,
            availability: always),
        // 13i-d U5b — the book-move half (R-13id-6 item 9). The book door
        // carries its row (the note doors' `.native` precedent) and renders
        // only while another wing exists and never on the daily Journal
        // (`WingBookMoveDoor.drawn` — DATA, P-2); the bulk door carries the
        // current wing and renders only on an ADDITIONAL one.
        Capability(
            id: .moveBookToWing, verb: WingCopy.moveToWingVerb, scope: .book,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: WingCopy.bookUnavailableNote,
            availability: always),
        Capability(
            id: .moveWingContents, verb: WingCopy.moveEverythingVerb, scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: WingCopy.unavailableNote,
            availability: always),

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
        // 13n-a — THE IMPORT DOOR of the Variorum document format (R-13n-8):
        // a file becomes a note in the Pool, a FOLDER becomes a book (its
        // folders its chapters), one press of ⌥⌘Z undoes the lot (R-13n-6).
        // Its verb lost "Files" because a folder is the point now. Three
        // renderers of ONE act: File ▸ Import…, ⌘K, and the Bookcase's drop
        // (`.surface` — `ShelfView.surfaceCapabilities`), which lights only
        // while a drag carries files (§12's false-offer rule).
        Capability(
            id: .importFiles, verb: "Import\u{2026}", scope: .app,
            doors: [.menuBar, .palette, .surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),
        // 13n-a — COPY FOR AI (R-13n-11): the note in the document format,
        // onto the clipboard. Post-scoped and available wherever a note is
        // (`noteScoped`); with none in reach the palette row speaks the note
        // below (P-2). Reads only — the export pin.
        Capability(
            // Her rename at the 13n-a review (2026-10-09, verbatim: "I'd
            // rather not have 'for AI' on a button" — other people will
            // find it useful too); the internal id keeps its minting name.
            id: .copyForAI, verb: "Copy full text", scope: .post,
            doors: [.bottomBar, .palette],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: "Copy full text copies the note you have open \u{2014} open one first.",
            availability: noteScoped),
        // VX-125 (the VX-439 run — A-439-1, her ask: "a per note export in
        // markdown with variorum simple format"; the chord C-125-1): Copy full
        // text's text written to a `.md` file through the ONE serializer
        // (`NoteExport`). Its doors are Copy full text's grammar plus the File
        // menu beside Export Library…: File ▸ Export Note… (`.menuBar`), ⌘K
        // (`.palette`) and both `note ▾` menus (`.bottomBar` — R6-2); VX-425
        // adds the sidebar's note rows. `noteScoped` — Copy full text's own rule.
        //
        // **⌥⌘S — THE COLLISION SWEEP (C-125-1, 2026-10-27, on `47802c610`).**
        // The ruled ⇧⌘E is TAKEN (Extract Selection). ⌥⌘E and ⇧⌥⌘E would read
        // as the ⌥ "deliberate variant" of ⌘E (Use Selection for Find) and of
        // ⌘⇧E (Extract) — the reading `.moveSelectionToTake`'s sweep already
        // refused. ⌥⌘S is her own words' chord ("keyboard shortcut for saving
        // note") and the ⌥ variant of ⌘S: save this note OUT, as a file. FREE:
        // `EditorCommands.keyEquivalent`'s only `s` chords are ⌘S, ⌘⇧S and
        // ⌃⌘S; no `.keyboardShortcut(` call site in `Variorum/` or `Shared/`
        // carries ⌥⌘S; `EditorTextView.performKeyEquivalent` matches bare ⌘S
        // only (the exact modifier set); the system hot keys are [.quickNote]
        // (⌃⌥⌘N); macOS reserves no ⌥⌘S.
        Capability(
            id: .exportNote, verb: "Export Note\u{2026}", scope: .post,
            doors: [.menuBar, .palette, .bottomBar],
            shortcutLabel: "\u{2325}\u{2318}S", takesAccess: .native,
            unavailableNote: "Export Note writes the note you have open to a file \u{2014} open one first.",
            availability: noteScoped),
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
        // pre-13u Act 10 (the tenth-wave ruling): the sample library's
        // restore — mint-what's-missing, never a replace, so no confirm.
        Capability(
            id: .restoreSampleLibrary, verb: "Restore the Sample Library",
            scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),
        // (The Encryption Explained restore — pre-13x 5a — RETIRED at
        // 13s-b U1b, R-13s-37: not restorable.)
        // 18l-c U6 (R-18l-11): the takemania book's restore — the same
        // mint-what's-missing road (its title lowercased at 13s-b U1b,
        // R-13s-38 — the verb follows the one name constant).
        Capability(
            id: .restoreJekyllBook,
            verb: "Restore \u{201C}\(SampleLibraryJekyllBook.name)\u{201D}",
            scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),
        // 13s-b U1b (R-13s-37, "classics restorable"): the classics
        // gathering's restore — adopt-or-mint on Welcome; the verb's
        // wording is the implementer's (PROVISIONAL P-U1b-3).
        Capability(
            id: .restoreClassicsGathering,
            verb: "Restore the \u{201C}\(SampleLibraryWelcome.classicsGatheringName)\u{201D} Gathering",
            scope: .app,
            doors: [.menuBar, .palette],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),

        // 13s-b U1a (R-13s-2/6/13): the tour's one entry. Its verb IS the
        // Help menu's name for it (`TourOfferCopy.menuTitle` — the help-road
        // sentence reads the same constant, so the three can never drift).
        // Doors: the offer line's "yes" (`.surface`) and Help ▸ Take the Tour
        // (`.menuBar`, piece 5) — both run `RootView.startTour()`, which is
        // the U2 engine's real entry (step 1, no resume — Q12). No palette
        // row: the palette's acts are `ShellActions`', and the tour's entry
        // deliberately stays the shell's two doors.
        Capability(
            id: .takeTour, verb: TourOfferCopy.menuTitle, scope: .app,
            doors: [.surface, .menuBar],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "", availability: always),

        // MARK: Data safety (13l Act 4 — Settings ▸ Data Safety)
        // The `.deleteNow` shape exactly: `.surface`, app scope, always
        // available as an ACT, with the per-gesture condition living on the
        // pane. See the declaration comments in `Capability.swift` for why
        // there are three and why none of them wears a palette door.
        Capability(
            id: .backUpNow, verb: "Back Up Now…", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Backing up lives in Settings ▸ Data Safety.",
            availability: always),
        Capability(
            id: .chooseBackupFolder, verb: "Choose Folder…", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "The backup folder is picked in Settings ▸ Data Safety.",
            availability: always),
        Capability(
            id: .forgetBackupFolder, verb: "Stop Copying There", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "There is no second backup folder to stop copying to.",
            availability: always),
        // pre-13x 3b (decision 15; copy §4): the decrypted export — the
        // passphrase (Castle, or Standard with one set) and a chosen
        // destination are the pane's own conditions.
        Capability(
            id: .exportPlaintextLibrary, verb: "Choose Where…", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "The unencrypted export lives in Settings ▸ Data Safety.",
            availability: always),
        // 13x F1 (ladder R1-MAJOR; the 13x row's deliverable 1): the
        // travelling folder pair (the kickoff ruling QC) — File's door and
        // Data Safety's twin render the ONE act; reveal-in-Finder at
        // completion. The verb IS `LibraryOpenCopy.handOffDoor` (13x F2,
        // ladder R2-2: both faces render THIS declaration, so the copy
        // constant is the one source of truth and a 13s re-voicing of it
        // reaches the File menu and Data Safety alike — the old duplicated
        // literal left the constant dead and the no-drift claim enforced
        // by nothing; the equality pin in CapabilityRegistryTests is the
        // enforcement now).
        Capability(
            id: .handOffLibrary, verb: LibraryOpenCopy.handOffDoor, scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "The travelling copy is made while your library is open — "
                + "File ▸ Send Library to Another Mac…, or Settings ▸ Data Safety.",
            availability: always),

        // MARK: Diagnostics (13r U3-B — Settings ▸ Diagnostics, R-13r-5)
        // The Data Safety shape: `.surface`, app scope, always available as
        // an ACT, the per-report condition living on the card. See the
        // declaration comment in `Capability.swift` for why neither wears a
        // palette or menu door.
        Capability(
            id: .sendCrashReport, verb: "Send Report\u{2026}", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Crash reports are sent from Settings \u{25B8} Diagnostics, "
                + "where you can read them first.",
            availability: always),
        Capability(
            id: .deleteCrashReport, verb: "Delete Report", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Crash reports are deleted from Settings \u{25B8} Diagnostics.",
            availability: always),
        // VX-221 — Settings ▸ Tags' delete: the row's trash + its context
        // row, ONE confirm (`TagDeletion`). `takesAccess: nil` on the
        // Diagnostics precedent (not an editing act).
        Capability(
            id: .deleteTag, verb: "Delete Tag\u{2026}", scope: .app,
            doors: [.contextMenu, .surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Tags are deleted from Settings \u{25B8} Tags.",
            availability: always),

        // MARK: The MCP door (13n-b U1 — Settings ▸ MCP, R-13n-4/5, R-13nb-5)
        // The Diagnostics shape: `.surface`, app scope, always available as
        // an ACT, each acting on the row it sits on. See the declaration
        // comment in `Capability.swift` for why none wears a palette or menu
        // door. The words are the pane's register (direct and technical —
        // R-13n-5); "Copy setup command" is her R-13nb-5.
        Capability(
            id: .mcpApproveClient, verb: "Approve\u{2026}", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Connection requests are approved in Settings \u{25B8} MCP.",
            availability: always),
        Capability(
            id: .mcpDenyClient, verb: "Deny", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Connection requests are denied in Settings \u{25B8} MCP.",
            availability: always),
        Capability(
            id: .mcpChangeClientAccess, verb: "Change\u{2026}", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "A client's access is changed in Settings \u{25B8} MCP.",
            availability: always),
        Capability(
            // 13n-c UX walk W-UX-4: its OWN verb — the act is a deny (the
            // client shut out AND every grant it holds revoked, P-13nb-U1-5),
            // never the grant row's "Revoke"; the ellipsis because it asks
            // first. PROVISIONAL, her copy pass.
            id: .mcpRevokeClient, verb: "Deny\u{2026}", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "A client is denied in Settings \u{25B8} MCP.",
            availability: always),
        Capability(
            id: .mcpRevokeGrant, verb: "Revoke", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Sharing with AI is revoked in Settings \u{25B8} MCP.",
            availability: always),
        // 13n-c U5 (VX-274): ONE act still — the pane's setup menu
        // (Claude Code · Codex · Any MCP client, `MCPSetupClient`) chooses
        // WHAT it copies; choosing is view state, never a second act.
        Capability(
            id: .mcpCopySetupCommand, verb: "Copy setup command", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "The setup command is in Settings \u{25B8} MCP.",
            availability: always),
        Capability(
            id: .mcpGrantAccess, verb: "Grant", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "Access is granted from Settings \u{25B8} MCP.",
            availability: always),
        // 13n-b U2 (AF-6): the ask sheet's answer — its one renderer is the
        // sheet, which carries the ask it answers.
        Capability(
            id: .mcpAnswerAsk, verb: "Answer", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            // 13n-c U4 (arrival X): the sheet no longer arrives by itself.
            unavailableNote: "A client's ask is answered on its own sheet \u{2014} open it from the ask's "
                + "icon, or from Settings \u{25B8} MCP \u{25B8} Waiting.",
            availability: always),
        // 13n-b U2 — THE PRIVATE MARK (R-13nb-4). The note's row: post-scoped
        // and available wherever a note is (`noteScoped` — Copy full text's
        // own rule; the bars render it in NOTE contexts only, never on a
        // scraps group). The book's: the settings sheet's State row (books
        // only — a gathering refuses `wrongReadingKind`, so it never renders).
        // 13n-c U3 (VX-164): the in-note indicator's LOCK popover renders
        // the same toggle — its `.surface` door.
        Capability(
            id: .markNotePrivate, verb: PrivateMarkCopy.rowWords, scope: .post,
            doors: [.bottomBar, .surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: PrivateMarkCopy.noNoteNote,
            availability: noteScoped),
        Capability(
            id: .markBookPrivate, verb: PrivateMarkCopy.rowWords, scope: .book,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: PrivateMarkCopy.bookSheetNote,
            availability: always),
        // 13n-b U3 — "Allow AI here" (R-13n-11; AF-8/AF-10 (e)): the Private
        // row's neighbour, the same post scope and note-only availability.
        Capability(
            id: .mcpAllowHere, verb: PrivateMarkCopy.allowHere, scope: .post,
            doors: [.bottomBar],
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: PrivateMarkCopy.allowHereNoNote,
            availability: noteScoped),
        // 13n-c U3 — GRANT FROM WHERE YOU ARE (VX-156 items 2/3; VX-270 · VX-271 ·
        // VX-164 · VX-272 — the case's own comment carries the family). The row and
        // surface doors carry their TARGET (the row, the pick, the book, the
        // place the icon sits on), so their availability is `always`; their
        // render gate is VX-272's (an approved client exists — the window's
        // road), applied where they render (P-2: no door, never a dead one).
        Capability(
            id: .mcpShareHere, verb: MCPShareCopy.shareVerb, scope: .app,
            doors: [.contextMenu],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: MCPShareCopy.zeroState,
            availability: always),
        Capability(
            id: .mcpShareNotes, verb: "Share Selected Notes with AI\u{2026}", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "\u{2318}-click notes in the Library to pick what to share.",
            availability: always),
        Capability(
            id: .mcpShareBook, verb: MCPShareCopy.shareButton, scope: .book,
            doors: [.surface],
            // R118: Book Settings is the same sheet from every mode — Takes is
            // never behind Write here (`.markBookPrivate`'s declaration).
            shortcutLabel: nil, takesAccess: .native,
            unavailableNote: MCPShareCopy.zeroState,
            availability: always),
        // ⌥⌘A — the note the mounted detail holds (`CommandRouter
        // .activePostID`, set with `activeMode`): available wherever a post
        // detail is mounted, natively in Takes (R118). THE COLLISION SWEEP is
        // recorded at `EditorCommands.keyEquivalent`.
        Capability(
            id: .mcpShareThisNote, verb: MCPShareCopy.shareThisNote, scope: .post,
            doors: [.menuBar],
            shortcutLabel: "\u{2325}\u{2318}A", takesAccess: .native,
            unavailableNote: MCPShareCopy.shareThisNoteUnavailable,
            availability: { ctx in ctx.mode != nil ? .act : .unavailable }),
        Capability(
            id: .mcpShowSharing, verb: MCPShareCopy.showSharingVerb, scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: MCPShareCopy.zeroState,
            availability: always),
        Capability(
            id: .mcpChangeGrant, verb: MCPShareCopy.change, scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "A grant is changed from the place it reaches, or in Settings \u{25B8} MCP.",
            availability: always),
        // 13n-c U4 — ASKS WAIT QUIETLY (arrival X). The glyph and Waiting's
        // row each carry their ask, so `always` is honest; the glyph renders
        // only while that ask waits (P-2 — a calm target draws nothing).
        // VX-258 (VX-246 U1b): Waiting's re-bind row. Each row carries its
        // waiting setup, so `always` is honest; the row renders only while
        // the setup waits (P-2). "Don't allow" is the ask sheet's own word
        // (`MCPAskCopy.dontAllow`), one source. PROVISIONAL words (VX-234).
        Capability(
            id: .mcpAllowRebind, verb: "Allow", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "A client's new setup waits for you in Settings \u{25B8} MCP \u{25B8} Waiting.",
            availability: always),
        Capability(
            id: .mcpDeclineRebind, verb: MCPAskCopy.dontAllow, scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "A client's new setup waits for you in Settings \u{25B8} MCP \u{25B8} Waiting.",
            availability: always),
        Capability(
            id: .mcpOpenAsk, verb: "Answer\u{2026}", scope: .app,
            doors: [.surface],
            shortcutLabel: nil, takesAccess: nil,
            unavailableNote: "A client's ask waits at its icon on the thing it names, and in "
                + "Settings \u{25B8} MCP \u{25B8} Waiting.",
            availability: always),
        // ⌥⌘, — the MCP room's chord (the brief §6, recommended and nodded):
        // Settings' own chord with the ⌥ "deliberate variant" her ceremony
        // chords carry. Always acts (the pane is always there to open). THE
        // COLLISION SWEEP is recorded at `EditorCommands.keyEquivalent`.
        Capability(
            id: .mcpSettings, verb: "MCP Settings\u{2026}", scope: .app,
            doors: [.menuBar],
            shortcutLabel: "\u{2325}\u{2318},", takesAccess: nil,
            unavailableNote: "", availability: always),
        // ⌘L — THE WING SWITCHER (VX-157, ratified: "i like Command L").
        // App-wide like ⌘K (it opens in the window that can show it); the
        // masthead word's cycling click is its `.surface` door. THE COLLISION
        // SWEEP is recorded at `EditorCommands.keyEquivalent`.
        //
        // 13n-c Stage B R1 B6 (P-2, PROVISIONAL P-13nc-SB-2): with ONE wing the
        // switcher's only outcome is closing it, so the act is unavailable —
        // grey on the View menu — and the note says where another wing comes
        // from (the masthead already applies P-2 to that case: with one wing
        // the word does not cycle).
        Capability(
            id: .switchWing, verb: WingCopy.switchWingVerb, scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: "\u{2318}L", takesAccess: nil,
            unavailableNote: WingCopy.switchWingUnavailable,
            availability: { ctx in ctx.wingCount > 1 ? .act : .unavailable }),
        // VX-309 U1c — VX-451: Lock Library Now — the File menu's item and the road's Protection pane render THIS
        // declaration (the verb is the one constant, so both faces say the same words). The per-gesture condition (only
        // where the library can lock — Castle) is each door's own (`canLock`; the Castle-only section): `always` as an act,
        // the Data Safety precedent. VX-329 U1 — P-VX309-U1c-4 (b): the chord ⌃⌘L is DECLARED here, with its row in the
        // ⌘/ helper (today's road, which a helper row would have reached in Release, is gone). The note is EMPTY (VX-309
        // ladder round 1, F-R4): the act is `always` and no router dispatch reaches it — both doors call the lock directly —
        // so a note here could never be spoken; the registry's own idiom for a directly-wired door (`.mcpSettings`,
        // `.newPost`, `.findAnything`).
        Capability(
            id: .lockLibraryNow, verb: ProtectionCopy.lockNowLabel, scope: .app,
            doors: [.menuBar, .surface],
            shortcutLabel: "\u{2303}\u{2318}L", takesAccess: nil,
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
            // 13j J4/J4b: the ceremony doors speak their own note.
            case .divideWithCeremony: id = .divideWithCeremony
            case .mergeWithCeremony: id = .mergeWithCeremony
            }
        case .deleteInEveryTake: id = .deleteInEveryTake
        case .commit: id = .commitTake
        case .addBlockAtEnd: id = .addBlockAtEnd
        case .insertBlockBelow: id = .insertBlockBelow
        case .deleteBlock: id = .deleteBlock
        case .archiveBlock: id = .archiveBlock
        case .toggleSeal: id = .sealPost
        case .comments: id = .blockComments
        case .callout: id = .callout
        case .pageFan: id = .pageFanBack
        case .copyAllTakes: id = .copyAllTakes
        case .takeToBlockBelow: id = .takeToBlockBelow
        case .takesToBlocks: id = .takesToBlocks
        case .showOriginBlock: id = .showOriginBlock
        case .showBlockHistory: id = .showBlockHistory
        case .showNoteVersions: id = .showNoteVersions
        case .saveNoteVersion: id = .saveNoteVersion
        case .showNoteTray: id = .showNoteTray
        case .find(let action):
            switch action {
            case .show: id = .findInPost
            case .showReplace: id = .findAndReplace
            case .next: id = .findNext
            case .previous: id = .findPrevious
            case .useSelection: id = .useSelectionForFind
            case .replaceAllInEveryTake: id = .replaceAllInEveryTake
            }
        }
        return capability(id).unavailableNote
    }
}
