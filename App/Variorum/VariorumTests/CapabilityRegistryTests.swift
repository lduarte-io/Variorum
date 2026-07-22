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
        contexts.append(CapabilityContext(mode: nil, undoAvailable: true))
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
        let exempt: Set<CapabilityID> = [
            .previousBlock, .nextBlock, .callout, .exportCaretBlock, .switchMode,
            .renameLens,
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
        let takes = CapabilityContext(mode: .takes, undoAvailable: true)
        let write = CapabilityContext(
            mode: .write, writeEditorAttached: true, undoAvailable: true)
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

    @Test func theContextMenusRenderExactlyTheDeclaredContextDoors() {
        let rendered = Set(EditorViewModel.contextMenuCapabilities)
            .union(TakesCellView.contextMenuCapabilities)
            .union(LensesBoardView.columnMenuCapabilities)  // 13b 3D: renameLens
        #expect(rendered == CapabilityRegistry.doored(.contextMenu))
    }

    /// 13b Stage 3 (3D): the `.surface` door — acts rendered INLINE on a
    /// board/panel (the archived listing's Unarchive) declare themselves in
    /// per-surface statics, walk-asserted like the routed door tables.
    @Test func theSurfacesRenderExactlyTheDeclaredSurfaceActs() {
        let rendered = Set(TakesBoardView.surfaceCapabilities)
            .union(WriteTakesPanel.surfaceCapabilities)
        #expect(rendered == CapabilityRegistry.doored(.surface))
    }

    @Test func everyShortcutLabelHasExactlyOneKeyWiring() {
        for capability in CapabilityRegistry.all {
            guard capability.doors.contains(.menuBar), capability.shortcutLabel != nil,
                  capability.id != .switchMode  // ⌘1–⌘6, wired per mode
            else { continue }
            #expect(EditorCommands.keyEquivalent(for: capability.id) != nil,
                    "\(capability.id) declares \(capability.shortcutLabel!) and the menu wires it")
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
            .toggleSeal, .comments,
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
        for id in [CapabilityID.divide, .extract, .makeBlock, .merge, .deleteInEveryTake] {
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext(mode: .takes))
                    == .actElsewhere(.write), "\(id) acts from Takes (D3)")
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext(mode: .lenses))
                    == .actElsewhere(.write), "\(id) acts from Lenses")
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext(mode: nil))
                    == .unavailable, "\(id) is honestly grey with no post open")
        }
    }

    @Test func commitActsWhereverAdvertisedAndNowhereElse() {
        #expect(CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: .takes)))
        #expect(CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: .lenses)))
        #expect(CapabilityRegistry.isEnabled(
            .commitTake, in: CapabilityContext(mode: .write, writeEditorAttached: true)))
        // N5's silent half is structurally impossible: where nothing can
        // commit, the door is DISABLED (it used to be enabled-into-nil).
        #expect(!CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: nil)))
        #expect(!CapabilityRegistry.isEnabled(.commitTake, in: CapabilityContext(mode: .compare)))
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
        for id in [CapabilityID.previousBlock, .nextBlock, .callout, .exportCaretBlock] {
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
