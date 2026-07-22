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
    /// Phase 13 (B2): the shell routing channel — ⌘N/⌘J/⌘K land in
    /// RootView through this.
    let router: ShellRouter

    private var session: AppSession? {
        if case .ready(let session) = bootstrap.state { return session }
        return nil
    }

    private var actions: ShellActions? {
        session.map { ShellActions(session: $0, shell: router) }
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
        .importFiles, .exportLibrary, .exportCaretBlock,
        .structuralUndo,
        .divide, .extract, .makeBlock, .merge, .deleteInEveryTake,
        .addBlockAtEnd, .insertBlockBelow, .showTakes,
        .newTake, .blankTake, .blankTakeAsChosen, .chooseTake,
        .previousTake, .nextTake, .archiveTake, .saveChoicesAsLens,
        .closeAllTakes, .pageFanBack, .pageFanForward,
        .previousBlock, .nextBlock, .blockComments, .callout,
        .toggleSeams, .switchMode, .helper, .restoreTutorial,
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
        case .insertBlockBelow: ("n", [.command, .option])
        case .divide: ("d", [.command, .shift])
        case .extract: ("e", [.command, .shift])
        case .makeBlock: ("k", [.command, .shift])
        case .merge: ("m", [.command, .shift])
        case .showTakes: ("t", [.command, .shift])
        case .newTake: ("t", .command)
        case .blankTake: ("t", [.command, .option])
        case .blankTakeAsChosen: ("t", [.command, .option, .shift])
        case .chooseTake: (.return, .command)
        case .previousTake: (.leftArrow, [.command, .control])
        case .nextTake: (.rightArrow, [.command, .control])
        case .archiveTake: ("a", [.command, .shift])
        case .saveChoicesAsLens: ("l", [.command, .shift])
        case .pageFanBack: (.leftArrow, [.command, .option])
        case .pageFanForward: (.rightArrow, [.command, .option])
        case .previousBlock: (.upArrow, [.command, .control])
        case .nextBlock: (.downArrow, [.command, .control])
        case .blockComments: ("'", [.command, .shift])
        case .toggleSeams: ("b", [.command, .shift])
        case .helper: ("/", .command)
        case .switchMode: nil  // ⌘1–⌘6, wired per mode below
        default: nil
        }
    }

    var body: some Commands {
        // Phase 13 (B2): ⌘N = New Post (R41) + the dated home's shortcut.
        CommandGroup(replacing: .newItem) {
            Button(verb(.newPost)) { actions?.newPost() }
                .keyboardShortcut("n", modifiers: .command)
                .disabled(session == nil)
            Button(verb(.todaysEntry)) { actions?.todaysEntry() }
                .keyboardShortcut("j", modifiers: .command)
                .disabled(session == nil)
        }
        // ⌘K (R15, ratified): find anything — posts, books, commands.
        CommandGroup(after: .sidebar) {
            Button(verb(.findAnything)) { router.paletteRequested = true }
                .keyboardShortcut("k", modifiers: .command)
                .disabled(session == nil)
        }
        CommandGroup(after: .saveItem) {
            // N5 (13b 1b): ⌘S acts wherever advertised — the mounted
            // surface commits its focused/caret take; where truly nothing
            // can commit, the item is honestly grey (it used to be an
            // always-enabled call into a nil editor).
            Button(verb(.commitTake)) { actions?.commitTake() }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(!enabled(.commitTake))
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
                .keyboardShortcut("n", modifiers: [.command, .option])
                .disabled(!enabled(.insertBlockBelow))

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

            Divider()

            // R73's block navigation pair (Write's caret). Enablement is
            // ATTACHMENT-level (round-1 MINOR-3): enabled ⇒ the editor the
            // action chains into exists — never enabled-but-silent while
            // Write is still mounting.
            Button(verb(.previousBlock)) {
                session?.editorRouter.active?.jumpToAdjacentBlock(-1)
            }
            .keyboardShortcut(.upArrow, modifiers: [.command, .control])
            .disabled(!enabled(.previousBlock))
            Button(verb(.nextBlock)) {
                session?.editorRouter.active?.jumpToAdjacentBlock(1)
            }
            .keyboardShortcut(.downArrow, modifiers: [.command, .control])
            .disabled(!enabled(.nextBlock))

            // The caret block's comments (Phase 13 C1, R7; routed 13b 1b —
            // the boards open their target block's panel, so ⌘⇧' works
            // where the bars' block menu already offered the door).
            Button(verb(.blockComments)) { actions?.dispatch(.comments) }
                .keyboardShortcut("'", modifiers: [.command, .shift])
                .disabled(!enabled(.blockComments))

            // The callout frame (R16/R27).
            Menu(verb(.callout)) {
                ForEach(CalloutPalette.names, id: \.self) { name in
                    Button(name.capitalized) {
                        let editor = session?.editorRouter.active
                        Task { await editor?.setCaretCallout(color: name) }
                    }
                }
                Divider()
                Button("Emoji…") { promptCalloutEmoji() }
                Button("Remove Callout") {
                    let editor = session?.editorRouter.active
                    Task { await editor?.setCaretCallout(color: nil) }
                }
            }
            // Round-1 MINOR-3: the ONE enablement idiom — the registry's
            // attachment-level rule (same truth the old ad-hoc nil check
            // read, now declared once as data).
            .disabled(!enabled(.callout))

            Divider()

            // Phase 13 C1 (R6/R42): dotted seams on the GLOBAL setting.
            Button(verb(.toggleSeams)) { actions?.toggleSeams() }
                .keyboardShortcut("b", modifiers: [.command, .shift])
                .disabled(session == nil)
        }
        // ⌘1–⌘6 — the post modes (routed 13b 1b: composition, not a
        // broadcast — with no post open the items are honestly grey; a
        // routed request that finds no detail SPEAKS instead of vanishing).
        CommandGroup(before: .toolbar) {
            ForEach(Array(PostMode.allCases.enumerated()), id: \.offset) { i, mode in
                Button(mode.rawValue) { actions?.requestMode(mode) }
                    .keyboardShortcut(KeyEquivalent(Character("\(i + 1)")), modifiers: .command)
                    .disabled(!enabled(.switchMode))
            }
            Divider()
        }
        // ⌘/ — the shortcut helper + dictionary (Sitting 9, R73/R91).
        // 13b Stage 2 (R113): the tutorial's Help-menu doors — open the
        // field guide, and Restore Tutorial… (replace-wholesale after a
        // spoken confirm; fire-and-DO — it seeds AND opens).
        CommandGroup(after: .help) {
            Button(verb(.helper)) { openWindow(id: "variorum-helper") }
                .keyboardShortcut("/", modifiers: .command)
            Divider()
            Button("Open the Tutorial") { actions?.openTutorial() }
                .disabled(session == nil)
            Button(verb(.restoreTutorial)) { actions?.restoreTutorial() }
                .disabled(session == nil)
        }
    }

    @Environment(\.openWindow) private var openWindow

    /// The callout emoji prompt (her sitting-3 reference wore "💡").
    private func promptCalloutEmoji() {
        // Round-2 NIT-R2-3: the file's last silent return speaks (the
        // editor detaching between menu-open and click). A nil session
        // has no status surface to speak to — nothing exists yet.
        guard let session, let editor = session.editorRouter.active else {
            if case .ready(let session) = bootstrap.state {
                session.status.speak(CapabilityRegistry.capability(.callout).unavailableNote)
            }
            return
        }
        let alert = NSAlert()
        alert.messageText = "Callout Emoji"
        alert.informativeText = "A leading glyph for this callout (leave empty for none)."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = field
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            let emoji = field.stringValue
            Task { await editor.setCaretCalloutEmoji(emoji) }
        }
    }

    /// Pure label derivation, tested directly ("Undo Divide", "Undo
    /// Extract", … — generic when the stack is empty).
    static func undoMenuTitle(for topLabel: String?) -> String {
        topLabel.map { "Undo \($0)" } ?? "Undo Structural Change"
    }
}
