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
        // 18o U1 (17e (12)): the WINDOW gate — a fact about the window she is
        // in (the key window is a FULL one), not a stack depth or what a pane
        // shows. Without it `.toggleSidebar` would read `.unavailable`
        // everywhere the walk looks — the hole every gate above opened before
        // its own context joined.
        contexts.append(CapabilityContext(mode: nil, windowKind: .full))
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
        //
        // **13e E9 — that last sentence, corrected on the record.** The
        // takes-aware REPLACE is now built (`.replaceAllInEveryTake`), and
        // the family still belongs here, for a reason stated rather than
        // inherited: what stays Write-only is the FIND BAR — a
        // full-document surface affordance that only the scroll-view-owning
        // editor has, by the QoL round's own ruling ("a find ACROSS the post
        // has no meaning on a per-take pane"). The new act is driven BY that
        // bar's two strings and its own matches, so it cannot be reached
        // from a surface that has no bar; Takes is not behind Write because
        // no surface anywhere hosts a per-take find. Giving it
        // `moveAndExecute` would be worse than the exemption: moving to
        // Write and firing Replace All against whatever the bar's fields
        // happen to hold — an EMPTY replacement field deletes every match —
        // is precisely the door P-2 forbids. Logged for her at #63(g).
        // 13f batch 3 (W16): `.openPeerPost` joins the `.switchMode` half of
        // this list — a NAVIGATION act, not an editing one. It opens a post;
        // no surface is behind another because no surface edits anything
        // here. (Its two siblings, `.openNote` and the back/forward pair,
        // are app-scoped and never reach this loop at all.)
        // **18l-c U7 — the expiry clause above, MET for the find half** (her
        // R-18l-6, a RULED change named in the unit's record): the Takes board
        // hosts its own find, so ⌘F · ⌘G · ⇧⌘G declare `takesAccess:
        // .native` and LEAVE this list — `takesIsNeverBehindWrite` now holds
        // them to acting in Takes. Find and Replace, Use Selection for Find
        // and Replace All in Every Take STAY (her R-18l-9: find-only v1 —
        // replace is Write's).
        let exempt: Set<CapabilityID> = [
            .previousBlock, .nextBlock, .exportCaretBlock, .switchMode,
            .renameLens, .tagBlock,
            .findAndReplace, .useSelectionForFind,
            .replaceAllInEveryTake,
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
            // 13e E7: the canvas BANK's two doors join `.tagBlock` for its
            // exact reason, stated rather than inherited — the canvas is a
            // surface OUTSIDE the post-mode row (it opens on a post or on
            // the scraps), its doors are pointed at directly (the strip,
            // the card you right-clicked), and neither act edits text:
            // opening a strip is a view act, and returning a card to it
            // moves an ARRANGEMENT row (`canvas_layout`), which the seal
            // posture itself calls viewing rather than authoring. Takes is
            // not "behind" anything here because there is no takes-side
            // canvas for it to be behind.
            .toggleCanvasBank, .returnCardToBank,
            // The post-13l polish round (ledger row 4(b)): `.deleteScrap`
            // joins `.tagBlock` for that act's exact reason, stated rather
            // than inherited — the Snippets area is a surface OUTSIDE the
            // post-mode row, its door is pointed at directly (the scrap row
            // you right-clicked), and no editing mode owns it. Takes cannot
            // be "behind Write" where Write has no scrap rows either. The
            // in-editor block delete is a DIFFERENT act (`.deleteBlock`),
            // which is `takeFamily` and fully parity-covered.
            .deleteScrap,
            // …and its ARCHIVE twin (the post-13l polish round, ledger row 14
            // / F1 — her *"archive rides beside delete at every block door"*).
            // Same surface, same reason, same exemption.
            .archiveScrap,
            // 13e E8: `.tagNote` joins `.tagBlock` for the reason stated
            // there, one scope up — tagging is not TEXT EDITING, and its
            // two renderers sit outside the post-mode row entirely: the
            // context BAR (above the pane, over every mode — Takes reaches
            // the cards without a mode switch, exactly as it reaches the
            // book ascent) and the LIBRARY's note rows, which no editing
            // mode owns. Takes cannot be "behind Write" where Write has no
            // door of its own.
            .tagNote,
            // 13u4 UNIT C2 (her item 9, ruled R-13u4-4) — a NAMED exemption,
            // on the find family's own grounds and with the same expiry
            // clause. What this act needs is a SELECTION IN THE FULL-DOCUMENT
            // SURFACE: its whole question is "does this span lie inside one
            // block", which only the document's tiling can answer. A Takes
            // pane holds exactly ONE take, so the same words name a different
            // gesture there — with a different target discipline and its own
            // refusals — and R-13u4-4 ruled the semantics of the door she
            // asked for, not a board-side shape. Giving it `moveAndExecute`
            // would be worse than the exemption, and for `.replaceAllInEveryTake`'s
            // exact reason: no board door exists to carry a selection, so the
            // declaration would promise a reachability nothing delivers.
            // Takes is not "behind Write" here because no surface anywhere
            // hosts a per-take version of this act. The moment one is ruled
            // (QUESTIONS #128) this declaration gains a real `takesAccess`
            // and leaves this list.
            .moveSelectionToTake,
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

    /// **PER BAR, not the union** (ledger row 45; the 18f ladder's R3-3).
    /// The walk above asserts the UNION of the two bars, so `CommitBar`
    /// alone satisfied `.bottomBar` on both ceremonies while the boards'
    /// `block \u{25BE}` group rendered neither — U-4's *"a button, not just
    /// a shortcut"* was half-delivered and no test could see it. The guard
    /// is exhaustive over the act enum rather than a hand-listed set, so a
    /// future structural act cannot repeat the omission: **every**
    /// `StructuralAct` has a row in the board's group.
    @Test func theBoardsStructuralGroupRendersEveryStructuralAct() {
        #expect(Set(TakesBottomBar.structuralBar.map(\.act))
                == Set(StructuralAct.allCases))
        #expect(Set(TakesBottomBar.renderedCapabilities)
                .isSuperset(of: [.divideWithCeremony, .mergeWithCeremony]),
                "declared where they are rendered")
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
            // 13i-c U4 (the remove/release door, §20): the book's note-row
            // menus and the sidebar note box's book context.
            .union(BookView.contextMenuCapabilities)
            .union(SidebarNoteBox.contextMenuCapabilities)
            // 13i-d U1 (A JUSTIFIED EDIT, the E2/E8 class — a new renderer is
            // a new line): the Bookcase's SHELF menu (Rename · Set Glyph ·
            // Make Default · Move to Start/End · Delete), one builder the
            // strip's names, the ⋯ panel's rows and All's headers render.
            .union(BookcaseStrip.contextMenuCapabilities)
            // 13i-d U2 (A JUSTIFIED EDIT, the same class — a new renderer is
            // a new line): the BOOK PANEL's row menus — the five structure
            // doors (each a drag's menu twin) and the remove/release door.
            .union(BookPanelView.contextMenuCapabilities)
            // 17y B3 item (l) (A JUSTIFIED EDIT, the same class — a new
            // renderer is a new line): the BOOK ROW MENU beyond the Bookcase
            // (the Library's book rows, the Starred section's, the Archived
            // books group's) — its acts, one of them (Unarchive) newly doored.
            .union(BookRowMenu.contextMenuCapabilities)
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
            // ⌘[ / ⌘] acts, wearing their faces).
            .union(ContextBar.surfaceCapabilities)
            // Act 10 item 5 (A JUSTIFIED EDIT, the E2/E8 convention): the
            // tag cards, their ＋ and the ＃ fold moved to the masthead's
            // right edge — the acts moved WITH their renderer, so the
            // cluster is a new line here and the union stays exact.
            .union(MastheadTagCluster.surfaceCapabilities)
            // The Act 10 correction round, batch A (A JUSTIFIED EDIT, the
            // E2/E8 convention): the shell's sidebar toggle is OURS now —
            // `ShellSplit` replaced the system split view, whose toolbar
            // button was undeclared chrome — so the shell renders one
            // `.surface` door and joins the walk as a new line here.
            .union(RootView.surfaceCapabilities)
            // 13e E2 (A17): Write's block-selection banner — the SECOND
            // renderer of the one delete-selected act (the board's banner is
            // the first). A JUSTIFIED EDIT to this pin: E2 adds a surface
            // that renders a `.surface` door, and the union names every
            // renderer by construction, so a new renderer is a new line
            // here. Without it the walk fails, which is the pin working.
            .union(EditorView.surfaceCapabilities)
            // 13e E8 (A JUSTIFIED EDIT, called out like E2's above): note
            // TAGGING is declared now, and it has TWO renderers — the
            // context bar's cards (shipped 13g R6-1, never declared) and
            // the Library's note rows, which E8 gave the same grammar. The
            // union names every renderer by construction, so the Library
            // joining the walk is a new line here.
            .union(LibraryCatalogView.surfaceCapabilities)
            .union(PoolPostsView.surfaceCapabilities)
            // 13j batch 3 (A JUSTIFIED EDIT, called out like E2's and E8's
            // above): the block's PAST region inside the History face renders
            // two `.surface` acts — the lineage row (J3, her round-5
            // amendment) and the deleted take's Put back (the round-5
            // ruling). The declaration lives with the BUILDER rather than in
            // each of the two history hosts (the `MarkdownActs` precedent),
            // so both faces are covered by construction. The union names
            // every renderer, so a new builder is a new line here.
            // The post-13l polish round, batch 4 (the same JUSTIFIED-EDIT
            // class): `BlockPastSection` is GONE — its two hosts were the two
            // history faces her G2 ruling absorbed — and the acts it rendered
            // are the Block History pane's rows now. `.showOriginBlock` is no
            // longer among them: the pane is where that act LANDS, not a door
            // onto it, so it left the `.surface` door set entirely.
            .union(BlockHistoryPane.surfaceCapabilities)
            // 13j batch 6b (A JUSTIFIED EDIT, the E2/E8/batch-3 class): the
            // TRASH surface renders the two purge doors — Delete Now per
            // row and Empty Trash — and it is their ONLY legal renderer,
            // forever (her round-3 rider: "never accidental full delete
            // from within a note"). The union names every renderer by
            // construction, so a purge door leaking into any note context
            // is a new line here — which is exactly the review this walk
            // exists to force.
            .union(RecoveryView.surfaceCapabilities)
            // 13l Act 4 (A JUSTIFIED EDIT, the E2/E8/batch-3/6b class):
            // Settings ▸ Data Safety renders three acts — Back Up Now, Choose
            // Folder and Stop Copying There. It is the FIRST Settings pane to
            // declare anything, and that is worth naming rather than blending
            // in: the Appearance and Tags panes have never declared their
            // acts, so this is a new precedent, not a completion. It was
            // taken here because these three touch her DATA (one copies the
            // library, two decide where copies go), which is exactly what a
            // registry of acts is for; the tag manager's create/rename/delete
            // is the same class and is recorded as an unclosed gap rather
            // than swept in silently by this act.
            .union(DataSafetyPane.surfaceCapabilities)
            // The post-13l polish round, batch 3 (A JUSTIFIED EDIT, the
            // E2/E8/batch-3/6b class — and the most consequential one of
            // them, because it changes WHERE A PURGE DOOR MAY LIVE):
            //
            // · `PostDetailView` renders the tray's NAMED door, the masthead
            //   icon her C1 ruling moved it to (the `note ▾` item that used
            //   to carry it was a `.bottomBar` door and is gone);
            // · `PoolDetailView` renders the same act for the scraps area,
            //   whose tray is its own;
            // · `TrayPanel` renders `.restoreTake` on its take rows and —
            //   the line to read twice — **`.deleteNow`**, which 13j
            //   declared in-Trash-only forever. Her G5 fourth-sitting ruling
            //   supersedes that IN PART: takes left the global Trash (D1), so
            //   the capability would have had no door at all, and she placed
            //   one on the note's leaving section *"to keep the
            //   capability"*. The rule in its place: purge doors live in
            //   TRASH SURFACES — the global Trash and the note-level trash
            //   section — never in the writing flow. That is exactly the
            //   review this walk exists to force, and it is why the two
            //   surfaces are named here one line apart.
            .union(PostDetailView.surfaceCapabilities)
            .union(PoolDetailView.surfaceCapabilities)
            .union(TrayPanel.surfaceCapabilities)
            // The post-13l polish round, batch 4 (ledger row 14 / F1 — the
            // same JUSTIFIED-EDIT class): Blocks mode's ROW MENU joins the
            // walk. It has offered "Delete block" since 13c and declared
            // nothing; the pass that gave it the Archive twin her rule asks
            // for declared the pair, which is what a registry of acts is for.
            // (Re-anchored at pre-13u Act 10 wave 2c: the TOC page grew into
            // the workbench + Index — both declare, both walked.)
            .union(BlocksWorkbenchView.surfaceCapabilities)
            .union(IndexModeView.surfaceCapabilities)
            // 13i-b U2 (A JUSTIFIED EDIT, the E2/E8/batch-3/6b class): the
            // ARRIVALS LINE atop a book's Index and Book surfaces renders the
            // two judgment doors — Add (`seatArrival`) and Dismiss
            // (`dismissArrival`) — on each waiting row. Its ONLY renderer, so
            // the declaration lives with the builder and the union names it
            // here; a judgment door leaking onto any other surface is a new
            // line, which is the review this walk exists to force.
            .union(BookArrivalsLine.surfaceCapabilities)
            // 13i-c U3 (A JUSTIFIED EDIT, the E2/E8/batch-3/6b class): the
            // BOOK SETTINGS sheet renders the six STATE doors (Finish/Reopen ·
            // Seal…/Unseal · Own Its Notes…/Stop Owning — which of each pair,
            // `BookStateDoorSet`) and the rule editor's "Edit…" door in its
            // Collecting section. A new renderer is a new line here.
            .union(BookSettingsSheet.surfaceCapabilities)
            // 13i-c U3 (the same class): the RULE EDITOR renders the Trash
            // door R-13ic-4's gathering gate offers ("Delete this
            // gathering…" — `.deleteBook`'s `.surface` door).
            .union(RuleEditorSheet.surfaceCapabilities)
            // 13i-c U4 (the same class): THE MEMBERSHIP CHOICE sheet renders
            // the two ownership ceremonies (Copy In · Move In) for every hand-
            // add road (§4 rows 14–18); the Arrivals line is their other
            // renderer (its own line above, grown at U4).
            .union(MembershipChoiceSheet.surfaceCapabilities)
            // 13i-c U4 (the same class): the remove/release door's `.surface`
            // rows beyond the chip — the Index row's ⋯ menu and Manage Notes….
            .union(BookIndexColumn.surfaceCapabilities)
            .union(ManageReadingPostsSheet.surfaceCapabilities)
            // 13i-c U4: the owned-by badge is the book ascent's third renderer.
            .union(OwnershipBadgeView.surfaceCapabilities)
            // 13i-d U1 (the same class): the strip's "+ shelf" word.
            .union(BookcaseStrip.surfaceCapabilities)
            // 13i-d U2 (the same class): the BOOK PANEL's inline doors — a
            // row's click (the ascent) and a gathering's "remove #tag". Its
            // own door, the masthead book icon, is `PostDetailView`'s line.
            .union(BookPanelView.surfaceCapabilities)
            // 13i-d U3 (A JUSTIFIED EDIT, the same class — a new renderer is a
            // new line): the BOOK MASTHEAD's gear, the book's own door into
            // its settings sheet (`.openBookSettings`), declared at last; and
            // the Index FILTER BAR's save word (`.saveFilterAsGathering`).
            .union(BookView.surfaceCapabilities)
            .union(BookFilterBar.surfaceCapabilities)
            // 13i-d U4 (A JUSTIFIED EDIT, the same class — a new renderer is a
            // new line): a book's ARCHIVED LINE (her #169(a)(1)) renders
            // Unarchive (`.unarchiveNote`, NEW — its one declared renderer)
            // and the shared remove door on each archived member's row.
            .union(BookArchivedLine.surfaceCapabilities)
            // 13i-d U5 (A JUSTIFIED EDIT, the same class — a new renderer is a
            // new line): the Bookcase masthead's WING SWITCHER (§21 Direction
            // C) renders New Wing… / Rename Wing… / Delete Wing….
            .union(WingSwitcherMenu.surfaceCapabilities)
            // 13i-d U6 (A JUSTIFIED EDIT, the same class — a new renderer is a
            // new line): the Library's ARCHIVED view renders `.unarchiveNote`
            // on each row (F-U4-4 — its inline door, declared at last).
            .union(ArchivedView.surfaceCapabilities)
            // 13r U3-B (A JUSTIFIED EDIT, the Data Safety class — a new
            // renderer is a new line): Settings ▸ Diagnostics renders Send
            // Report… and Delete Report on each received crash report, and is
            // their ONLY renderer — a report is sent from where it was read.
            .union(DiagnosticsPane.surfaceCapabilities)
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
            .copyAllTakes,  // 13e E6 (A21's clipboard half)
            .takeToBlockBelow, .takesToBlocks,  // 13e batch 3 (A20/A21)
            .showOriginBlock,  // 13j J3 — the ⌘K row's routed body
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

    // MARK: - 18o U1 — 17e (12): the sidebar toggle's grey is a REGISTRY fact

    /// The View-menu item greyed while a note-only (or quick-note) window was
    /// key — `.disabled(… windows.activeWindowKind != .full)`, a per-view
    /// if-statement — while the registry declared `.toggleSidebar` ALWAYS
    /// available: a gate the walk could not see (P-1: gating is data). With
    /// no key window known (the default context), there is no sidebar to
    /// toggle, exactly as the menu has always said. **RED ON OLD** (`always`).
    @Test func theSidebarToggleIsGreyWhereNoFullWindowIsKey() {
        #expect(CapabilityRegistry.availability(.toggleSidebar, in: CapabilityContext())
                == .unavailable,
                "no key window known ⇒ no sidebar to toggle — the registry says so itself")
    }

    /// …and the menu reads that fact FROM the registry rather than re-deriving
    /// it: its item is gated by `enabled(.toggleSidebar)`, and no menu item
    /// gates on the window registry's kind directly any more. **RED ON OLD.**
    @Test func theSidebarMenuItemReadsItsGreyFromTheRegistry() {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum/EditorCommands.swift")
        let file = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        #expect(!file.isEmpty, "the pin found the file it is about")
        let gatedFromTheRegistry = file.contains(
            "Button(verb(.toggleSidebar)) { windows.activeRouter?.sidebarShown.toggle() }\n"
            + "                .keyboardShortcut(\"s\", modifiers: [.command, .control])\n"
            + "                .disabled(!enabled(.toggleSidebar))")
        #expect(gatedFromTheRegistry, "the item's grey is the registry's answer")
        let gatesOnWindowKind = file.contains("activeWindowKind")
        #expect(!gatesOnWindowKind, "no menu item re-derives a window-kind gate")
    }

    /// The rule, whole (added with the fix — it names the new context field,
    /// so it cannot compile on the old tree; the two pins above are the
    /// red-on-old pair): only a FULL key window has a sidebar to toggle.
    @Test func theSidebarToggleActsOnlyInAFullWindow() {
        let kinds: [(WindowRegistry.Kind?, Capability.Availability)] = [
            (.full, .act), (.noteOnly, .unavailable), (.quickNote, .unavailable),
            (nil, .unavailable),
        ]
        for (kind, expected) in kinds {
            #expect(CapabilityRegistry.availability(
                .toggleSidebar, in: CapabilityContext(windowKind: kind)) == expected,
                    "\(String(describing: kind)) → \(expected)")
        }
        // The window gate is the sidebar's alone: a full window says nothing
        // about acts gated on a mode, an editor or a stack.
        #expect(!CapabilityRegistry.isEnabled(
            .closeAllTakes, in: CapabilityContext(windowKind: .full)))
    }

    /// The router carries the key window's kind into the context the menu
    /// reads — the plumbing the shell's `wireWorkspace` closure feeds.
    @Test func theRoutersContextCarriesTheKeyWindowsKind() {
        let router = CommandRouter()
        #expect(router.currentContext().windowKind == nil, "unwired: no window known")
        #expect(!router.isEnabled(.toggleSidebar))
        router.windowKind = { .full }
        #expect(router.currentContext().windowKind == .full)
        #expect(router.isEnabled(.toggleSidebar))
        router.windowKind = { .noteOnly }
        #expect(!router.isEnabled(.toggleSidebar), "a note-only window is key — grey")
    }
}
