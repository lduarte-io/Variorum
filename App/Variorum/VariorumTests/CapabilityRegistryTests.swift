//
//  CapabilityRegistryTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1b — the REGISTRY WALK (P-1): every declared door is
//  rendered by its surface and every rendered door is declared; no act is
//  unavailable in every context; the R118 parity table holds (every editing
//  capability reaches Takes natively or via move-and-execute — Write is
//  never the privileged surface). This is what keeps the capability matrix
//  green BY CONSTRUCTION instead of by audit.
//

import Foundation
import SwiftUI  // 13c R2-2: the shortcut pin reads KeyEquivalent/EventModifiers
import Testing
@testable import Variorum

@MainActor
@Suite("Capability registry walk (13b 1b, P-1)")
struct CapabilityRegistryTests {
    /// The sampled context space: every mode (editor attached and not),
    /// plus the no-post surfaces, with and without undo.
    private static var sampledContexts: [CapabilityContext] {
        var contexts: [CapabilityContext] = []
        for mode in PostMode.allCases {
            for attached in [false, true] {
                contexts.append(CapabilityContext(
                    mode: mode, writeEditorAttached: attached, undoAvailable: false))
            }
        }
        contexts.append(CapabilityContext(mode: nil))
        contexts.append(CapabilityContext(mode: nil, writeEditorAttached: true))  // book/pool editor
        // QoL batch 3 (L6): the post detail's own editor — the one surface
        // that owns a scroll view, and therefore the only one the find family
        // can act on. Without this context the walk's
        // `noActIsUnavailableInEveryContext` could never see them act.
        contexts.append(CapabilityContext(
            mode: .write, writeEditorAttached: true, writeEditorOwnsScrollView: true))
        // 13c 2B: a takes board mounted OUTSIDE a post detail (the book
        // spread's takes page) — the context in which `mode` says nothing
        // and the board's own attachment is the truth.
        contexts.append(CapabilityContext(mode: nil, takesBoardAttached: true))
        contexts.append(CapabilityContext(mode: nil, undoAvailable: true))
        // 13c 1B (A10): the redo stack is the second app-scope gate.
        contexts.append(CapabilityContext(mode: nil, redoAvailable: true))
        // 13f batch 3 (W3/A27 + W16): the WORKSPACE gates — the third
        // family of app-scope stack gates, beside undo and redo. Without
        // this context the navigation core would be `.unavailable`
        // everywhere the walk looks, exactly as the find family was before
        // its own context joined.
        contexts.append(CapabilityContext(
            mode: nil, openNoteCount: 3, canNavigateBack: true, canNavigateForward: true))
        // 13f batch 4 (W1/A25): the SPLIT's gates, the same family — one
        // needs a note to put beside, the other needs a split to close.
        contexts.append(CapabilityContext(
            mode: nil, openNoteCount: 2, paneCount: 2, canOpenBeside: true))
        // 13f batch 6 (W4): the STAR gate. Its own context rather than a
        // field on one of the three above, because it is not a stack gate:
        // it asks what the focused pane is SHOWING (a note or a book), and
        // the three workspace gates ask how deep a stack is. Without it
        // `.toggleStar` would read `.unavailable` everywhere the walk looks
        // — the same hole the find family and the navigation core each
        // opened before their own contexts joined.
        contexts.append(CapabilityContext(mode: nil, canStarCurrent: true))
        // 13e E11 (the ASCENT): its own context, the `canStarCurrent` family —
        // a fact about what the pane is SHOWING (this note is in a book), not
        // a stack depth. Without it `.openBookAtNote` would read
        // `.unavailable` everywhere the walk looks, the same hole the find
        // family, the navigation core and the star door each opened before
        // their own contexts joined.
        contexts.append(CapabilityContext(mode: nil, canAscendToBook: true))
        return contexts
    }

    @Test func everyCapabilityIsDeclaredExactlyOnceWithAVerbAndADoor() {
        #expect(CapabilityRegistry.all.count == CapabilityID.allCases.count,
                "every id has exactly one declaration")
        #expect(Set(CapabilityRegistry.all.map(\.id)).count == CapabilityID.allCases.count)
        for capability in CapabilityRegistry.all {
            #expect(!capability.verb.isEmpty, "\(capability.id) has a verb")
            #expect(!capability.doors.isEmpty, "\(capability.id) has at least one door")
        }
    }

    @Test func noActIsUnavailableInEveryContext() {
        for capability in CapabilityRegistry.all {
            let reachable = Self.sampledContexts.contains {
                capability.availability($0) != .unavailable
            }
            #expect(reachable, "\(capability.id) can act SOMEWHERE")
        }
    }

    // MARK: - R118: the Takes parity table

    @Test func everyEditingCapabilityDeclaresItsTakesAccess() {
        // Editing capabilities = block/take/post scopes. App-scope acts and
        // the Write-caret navigation/identity doors are exempt by
        // declaration (takesAccess nil), and that exemption is EXPLICIT.
        // `.renameLens` (13b 3D): lens machinery's ONE home is the Lenses
        // tab (R65/R86) — the act is Lenses-scoped by ruling, so Takes
        // parity doesn't apply (Write has no lens door either; no surface
        // is privileged over another).
        // `.tagBlock` (13b 4D — N32(c)): scraps live OUTSIDE the post-mode
        // row (Blocks area / ScrapsPanel / canvas cards) — no editing mode
        // is privileged over another, the renameLens class.
        // 13c R2-2 (A13(a)): `.callout` LEFT this list — the frame is the
        // BLOCK's and takes share it (R16/R27), so it declares
        // `takesAccess: .native` like every other block-scoped editing act.
        // QoL batch 3 (L6) — a NAMED parity exception, ruled at the batch's
        // proposal gate. The find family joins the `.previousBlock` family:
        // these are FULL-DOCUMENT surface acts, and Takes is not "behind
        // Write" here because the takes-aware find/replace does not exist on
        // ANY surface — it is her L6 rider's recorded future scope (owner
        // 13e). The moment it is built, these declarations gain a real
        // `takesAccess` and leave this list.
        // 13f batch 3 (W16): `.openPeerPost` joins the `.switchMode` half of
        // this list — a NAVIGATION act, not an editing one. It opens a post;
        // no surface is behind another because no surface edits anything
        // here. (Its two siblings, `.openNote` and the back/forward pair,
        // are app-scoped and never reach this loop at all.)
        let exempt: Set<CapabilityID> = [
            .previousBlock, .nextBlock, .exportCaretBlock, .switchMode,
            .renameLens, .tagBlock,
            .findInPost, .findAndReplace, .findNext, .findPrevious, .useSelectionForFind,
            .openPeerPost,
            // 13e E11: `.openBookAtNote` joins `.openPeerPost` — the same
            // kind and the same reason, stated rather than assumed. It is a
            // NAVIGATION act (it opens a book at a note); nothing is edited,
            // so no surface can be "behind Write". And literally so, twice
            // over: its two doors are the context BAR, which sits above the
            // pane, and the membership CHIP in the masthead — both render
            // over every mode, so Takes reaches them without a mode switch,
            // exactly as `.divergeForBook` does.
            .openBookAtNote,
        ]
        for capability in CapabilityRegistry.all
        where capability.scope != .app && !exempt.contains(capability.id) {
            #expect(capability.takesAccess != nil,
                    "\(capability.id) declares how Takes reaches it (R118)")
        }
    }

    @Test func takesIsNeverBehindWrite() {
        // The parity letter: for every capability with a declared Takes
        // access, the TAKES context can act — natively for `.native`,
        // via the one choreography for `.moveAndExecute`. And nothing
        // available in Write is unavailable in Takes.
        // Mode parity, with the non-mode gates satisfied (undo's stack
        // gate applies identically everywhere — it is not a mode rule).
        let takes = CapabilityContext(mode: .takes, undoAvailable: true, redoAvailable: true)
        let write = CapabilityContext(
            mode: .write, writeEditorAttached: true,
            undoAvailable: true, redoAvailable: true)
        for capability in CapabilityRegistry.all {
            guard let access = capability.takesAccess else { continue }
            let inTakes = capability.availability(takes)
            switch access {
            case .native:
                #expect(inTakes == .act, "\(capability.id) acts natively in Takes")
            case .moveAndExecute:
                #expect(inTakes == .actElsewhere(.write),
                        "\(capability.id) fire-and-DOes from Takes")
            }
            if capability.availability(write) != .unavailable {
                #expect(inTakes != .unavailable,
                        "\(capability.id): Write is never privileged over Takes (R118)")
            }
        }
    }

    // MARK: - Declared ⇔ rendered (the door tables)

    @Test func theMenuBarRendersExactlyTheDeclaredMenuDoors() {
        #expect(Set(EditorCommands.menuRendered) == CapabilityRegistry.doored(.menuBar))
    }

    @Test func thePaletteRendersExactlyTheDeclaredPaletteDoors() {
        // findAnything IS the palette; it needs no row inside itself.
        #expect(Set(ShellActions.paletteActs) == CapabilityRegistry.doored(.palette))
    }

    @Test func theBottomBarsRenderExactlyTheDeclaredBarDoors() {
        let rendered = Set(TakesBottomBar.renderedCapabilities)
            .union(CommitBar.renderedCapabilities)
        #expect(rendered == CapabilityRegistry.doored(.bottomBar))
    }

    /// 13f batch 6 (W5): the MENU-BAR EXTRA's door table — the status item
    /// that reaches her from any app (her round-14.1 ruling). Same
    /// declared ⇔ rendered assertion as the four routed tables, so a row
    /// added to the extra later cannot go undeclared.
    @Test func theMenuBarExtraRendersExactlyTheDeclaredExtraDoors() {
        #expect(Set(QuickNoteMenuBarContent.menuBarExtraCapabilities)
                == CapabilityRegistry.doored(.menuBarExtra))
    }

    @Test func theContextMenusRenderExactlyTheDeclaredContextDoors() {
        let rendered = Set(EditorViewModel.contextMenuCapabilities)
            .union(TakesCellView.contextMenuCapabilities)
            .union(LensesBoardView.columnMenuCapabilities)  // 13b 3D: renameLens
            .union(SidebarView.contextMenuCapabilities)  // 13f batch 4: the note rows
            // 13f batch 6 (W4): the shelf's BOOK rows render the star door
            // from their own declaration — the fourth renderer of one act.
            .union(ShelfView.contextMenuCapabilities)
            // 13g batch 3 (L8): the Format submenu, built ONCE and inserted
            // by both text-surface kinds — so the declaration lives with the
            // builder rather than in each surface.
            .union(MarkdownActs.contextMenuCapabilities)
        #expect(rendered == CapabilityRegistry.doored(.contextMenu))
    }

    /// 13b Stage 3 (3D): the `.surface` door — acts rendered INLINE on a
    /// board/panel (the archived listing's Unarchive) declare themselves in
    /// per-surface statics, walk-asserted like the routed door tables.
    @Test func theSurfacesRenderExactlyTheDeclaredSurfaceActs() {
        let rendered = Set(TakesBoardView.surfaceCapabilities)
            .union(WriteTakesPanel.surfaceCapabilities)
            // 13b 4D (N32(c)): the scrap tag door's three surfaces.
            .union(BlocksAreaView.surfaceCapabilities)
            .union(ScrapsPanel.surfaceCapabilities)
            .union(CanvasView.surfaceCapabilities)
            // 13f batch 3 (W16): Compare's peer-column open door.
            .union(CompareBoardView.surfaceCapabilities)
            // 13f batch 5 (W23): the membership chip's per-book diverge door.
            .union(MembershipChip.surfaceCapabilities)
            // 13k K11/K12: the context bar's own icon row — ← and → (the
            // ⌘[ / ⌘] acts, wearing their faces) and the ＃ tag fold.
            .union(ContextBar.surfaceCapabilities)
        #expect(rendered == CapabilityRegistry.doored(.surface))
    }

    @Test func everyShortcutLabelHasExactlyOneKeyWiring() {
        // The two ORDINAL FAMILIES declare one label and wire a key per
        // index in the menu (⌘1–⌘6 per mode; 13f batch 3's ⌘⇧1–9 per open
        // note). Their per-index wiring is pinned by
        // `theOpenNoteKeysCoverExactlyTheShownRows` and the mode row itself.
        let ordinalFamilies: Set<CapabilityID> = [.switchMode, .openNote]
        for capability in CapabilityRegistry.all {
            guard capability.doors.contains(.menuBar), capability.shortcutLabel != nil,
                  !ordinalFamilies.contains(capability.id)
            else { continue }
            #expect(EditorCommands.keyEquivalent(for: capability.id) != nil,
                    "\(capability.id) declares \(capability.shortcutLabel!) and the menu wires it")
        }
    }

    // MARK: - THE DISCOVERABILITY GUARD (13g L1 — WT-1)

    /// **Every shortcut the registry declares is findable in the helper.**
    ///
    /// The finding this pins closed (her 13f walkthrough, verbatim: *"i
    /// don't even konw how to get to any of the things that built last
    /// phase"*): Phase 13f declared its whole workspace in the registry —
    /// P-1 held, every door existed and worked — and extended NEITHER
    /// discoverability surface. ⌘⇧1–9, ⌘[ / ⌘], ⌘⇧I and ⌘⇧N were real keys
    /// with no entry anywhere she could read, and so were ⇧⌥⌘Z, ⌥⌘C and the
    /// take-page keys from earlier phases. The registry walk could not see
    /// it, because the helper's list is hand-written prose and nothing tied
    /// the two together.
    ///
    /// This is that tie. It is RED on the pre-13g helper by construction —
    /// exactly ten declared labels were missing from it — and it makes the
    /// legibility mandate (R73/R91/R93) a property of the build rather than
    /// a thing each phase has to remember.
    ///
    /// One-directional on purpose: the helper may hold rows the registry has
    /// no capability for (⌘Z is NSTextView's, ⎋ closes blooms, ⌘, is the
    /// system's Settings item), and those are exactly the keys she most
    /// needs written down.
    @Test func everyDeclaredShortcutIsFindableInTheHelper() {
        let shown = HelperView.shortcutKeysShown
        for capability in CapabilityRegistry.all {
            guard let label = capability.shortcutLabel else { continue }
            #expect(shown.contains(label),
                    "\(capability.id) declares \(label) — the helper (⌘/) must show it")
        }
    }

    /// The rows without a chord are doors too, and the helper's own framing
    /// line ("every shortcut here is also a menu item") only tells half the
    /// truth unless the keyless doors are reachable from here as well. These
    /// four are the 13f workspace's keyless doors — the ones she looked for
    /// and could not find.
    @Test func theKeylessWorkspaceDoorsAreNamedInTheHelper() {
        let rows = HelperView.groups.flatMap(\.items)
        for door in [
            WorkspaceNaming.openBesideVerb, "Close Split", "New Window", StarCopy.verb,
        ] {
            #expect(rows.contains { $0.keys.contains(door) || $0.does.contains(door) },
                    "the helper names the \(door) door")
        }
    }

    // MARK: - The routed fallback speech is honest copy

    @Test func everyRoutedCommandHasAnUnhandledNote() {
        let commands: [RoutedCommand] = [
            .takes(.toggleFan), .takes(.closeAll), .takes(.branch), .takes(.blank),
            .takes(.blankChoose), .takes(.choose), .takes(.stepPrev), .takes(.stepNext),
            .takes(.archive), .takes(.saveLens),
            .structural(.divide), .structural(.extract), .structural(.makeBlock),
            .structural(.merge),
            .deleteInEveryTake, .commit, .addBlockAtEnd, .insertBlockBelow,
            .deleteBlock,  // 13c 1B (A8)
            .toggleSeal, .comments,
            .callout(.toggle),  // 13c R2-2 (A13(a))
            .pageFan(1),
        ]
        for command in commands {
            let note = CapabilityRegistry.unhandledNote(
                for: command, context: CapabilityContext())
            #expect(!note.isEmpty, "\(command) speaks when nothing handles it")
        }
    }

    // MARK: - The named D3/N5 cells, as availability facts

    @Test func structuralActsFireAndDoFromTakesAndLenses() {
        // 13d Batch 3 (A9): DIVIDE left this list — it acts NATIVELY on
        // both boards now, so asserting the carry here would assert a
        // retired flow. A RULED CHANGE (her #41), not a bug fix; the
        // native cell is pinned in `TakesDivideTests`. The other four are
        // untouched — scope was divide only.
        for id in [CapabilityID.extract, .makeBlock, .merge, .deleteInEveryTake] {
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext(mode: .takes))
                    == .actElsewhere(.write), "\(id) acts from Takes (D3)")
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext(mode: .lenses))
                    == .actElsewhere(.write), "\(id) acts from Lenses")
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext(mode: nil))
                    == .unavailable, "\(id) is honestly grey with no post open")
        }
        // Divide's own cell, stated here too so this table stays the one
        // place a reader learns what each structural verb does in Takes.
        #expect(CapabilityRegistry.availability(.divide, in: CapabilityContext(mode: .takes))
                == .act, "divide acts natively in Takes (A9)")
        #expect(CapabilityRegistry.availability(.divide, in: CapabilityContext(mode: .lenses))
                == .act, "…and in Lenses — the shared-model precedent")
        #expect(CapabilityRegistry.availability(.divide, in: CapabilityContext(mode: nil))
                == .unavailable, "divide is honestly grey with no post open")
    }

    @Test func commitActsWhereverAdvertisedAndNowhereElse() {
        #expect(CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: .takes)))
        #expect(CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: .lenses)))
        #expect(CapabilityRegistry.isEnabled(
            .commitTake, in: CapabilityContext(mode: .write, writeEditorAttached: true)))
        // N5's silent half is structurally impossible: where nothing can
        // commit, the door is DISABLED (it used to be enabled-into-nil).
        #expect(!CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: nil)))
        // 13b 4D (JUSTIFIED EDIT — the 4C handoff, judgment call 4's
        // recorded upgrade): compare is an EDITABLE surface since 4C and
        // its board registers the `.commit` handler now, so the door is
        // enabled there — the old `!isEnabled(compare)` line pinned the
        // pre-4C read-only shape. This flipped expectation is the change's
        // red-on-old proof (old registry: takeFamily ⇒ unavailable).
        #expect(CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: .compare)),
                "⌘S commits the focused compare pane (the N5 letter, extended)")
        // 13b 4E (the Phase-1 ruling's (c)(2) — the 4D precedent, third
        // surface): canvas cards edit through the one authority since 4E
        // and the canvas handler consumes `.commit` now. Red-on-old by
        // construction: the pre-4E registry resolved canvas through
        // takeFamily ⇒ unavailable — this line fails on that code.
        #expect(CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: .canvas)),
                "⌘S commits the live canvas pane's take (the N5 class, third surface)")
    }

    @Test func addBlockAtEndIsNativeInTakes() {
        #expect(CapabilityRegistry.availability(
            .addBlockAtEnd, in: CapabilityContext(mode: .takes)) == .act,
            "D3's third leg: the add-block door is native where takes live")
    }

    /// 13b 4D (N28/S4-13): insert-below is NATIVE in BOTH editors by
    /// construction — her editor-parity ruling ("write should also gain
    /// 'insert new block below'"), as a registry fact.
    @Test func insertBlockBelowIsNativeInBothEditors() {
        #expect(CapabilityRegistry.availability(
            .insertBlockBelow, in: CapabilityContext(mode: .takes)) == .act)
        #expect(CapabilityRegistry.availability(
            .insertBlockBelow,
            in: CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
        #expect(CapabilityRegistry.availability(
            .insertBlockBelow, in: CapabilityContext(mode: .lenses)) == .act)
        #expect(!CapabilityRegistry.isEnabled(
            .insertBlockBelow, in: CapabilityContext(mode: nil)),
            "honestly grey with no post open")
    }

    // MARK: - Stage 1 ladder, round-1 registry-fact pins

    /// Round-1 MINOR-3: the Write-editor-scoped acts call the attached
    /// editor DIRECTLY, so enablement is attachment-level — "Write mode,
    /// editor still mounting" was an enabled-but-silent window (the
    /// enabled-into-nil class).
    @Test func writeEditorScopedActsAreEnabledOnlyWithARealEditor() {
        let mountingWrite = CapabilityContext(mode: .write, writeEditorAttached: false)
        let attached = CapabilityContext(mode: .write, writeEditorAttached: true)
        let inlineAttached = CapabilityContext(mode: nil, writeEditorAttached: true)
        // 13c R2-2 (A13(a)) — JUSTIFIED EDIT, called out so a reviewer
        // checks it rather than assuming: `.callout` LEFT this list. It was
        // here because the door reached into `session.editorRouter.active`;
        // it now ROUTES like `.comments`, so attachment is no longer its
        // truth and the take family is. The pin below replaces the claim.
        for id in [CapabilityID.previousBlock, .nextBlock, .exportCaretBlock] {
            #expect(!CapabilityRegistry.isEnabled(id, in: mountingWrite),
                    "\(id): never enabled before the editor it chains into exists")
            #expect(CapabilityRegistry.isEnabled(id, in: attached))
            #expect(CapabilityRegistry.isEnabled(id, in: inlineAttached),
                    "\(id): a book-inline/pool editor counts — attachment is the truth")
        }
    }

    /// Round-1 MINOR-1 (the related half): sealing works wherever a post
    /// is open OR an editor is attached — the book-inline/pool contexts
    /// (mode nil, editor attached) seal through their routed handler.
    @Test func sealPostIsAvailableWhereverItActuallyWorks() {
        #expect(CapabilityRegistry.isEnabled(
            .sealPost, in: CapabilityContext(mode: nil, writeEditorAttached: true)),
            "an attached book-inline/pool editor can seal")
        #expect(CapabilityRegistry.isEnabled(.sealPost, in: CapabilityContext(mode: .compare)))
        #expect(!CapabilityRegistry.isEnabled(.sealPost, in: CapabilityContext(mode: nil)),
                "no post, no editor — honestly grey")
    }

    // MARK: - Stage 1 ladder, round-2: A13(a) as registry facts (R2-2)

    /// Her A13(a), verbatim: *"Callouts (a) in Takes/Compare/Lenses + a
    /// shortcut"* — ruled into the friction batch by K2 and, at round 2,
    /// found never built. Both halves are registry facts now.
    ///
    /// **Red on the old registry by construction:** `.callout` declared
    /// `availability: writeEditor`, so every line below that asks for
    /// Takes/Lenses/Compare resolved `.unavailable`, and `shortcutLabel`
    /// was `nil` with no key mapping.
    @Test func theCalloutDoorReachesEverySurfaceSheNamed() {
        for mode in [PostMode.takes, .lenses, .compare] {
            #expect(CapabilityRegistry.availability(
                .callout, in: CapabilityContext(mode: mode)) == .act,
                "the frame is the BLOCK's — \(mode) sets it right there (A13(a))")
        }
        #expect(CapabilityRegistry.availability(
            .callout, in: CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
        #expect(CapabilityRegistry.capability(.callout).takesAccess == .native,
                "native, not move-and-execute — nothing needs to relocate to frame a block")
        // …and honestly grey where nothing can act. CANVAS is deliberately
        // out (not in her ask; one rule line + one handler if she wants it).
        #expect(!CapabilityRegistry.isEnabled(.callout, in: CapabilityContext(mode: nil)))
        #expect(!CapabilityRegistry.isEnabled(.callout, in: CapabilityContext(mode: .canvas)))
    }

    @Test func theCalloutDoorHasItsShortcut() {
        #expect(CapabilityRegistry.capability(.callout).shortcutLabel == "⌥⌘C",
                "A13(a)'s second half")
        let key = EditorCommands.keyEquivalent(for: .callout)
        #expect(key?.0 == "c")
        #expect(key?.1 == [.command, .option])
    }

    /// Round-1 NIT-2: blooms exist only on the Takes board — Write and
    /// Lenses consumed `.closeAll` with a silent `break` while the menu
    /// item rendered enabled.
    @Test func closeAllTakesIsScopedToTheTakesBoard() {
        #expect(CapabilityRegistry.isEnabled(
            .closeAllTakes, in: CapabilityContext(mode: .takes)))
        #expect(!CapabilityRegistry.isEnabled(
            .closeAllTakes, in: CapabilityContext(mode: .write, writeEditorAttached: true)))
        #expect(!CapabilityRegistry.isEnabled(
            .closeAllTakes, in: CapabilityContext(mode: .lenses)))
    }
}
