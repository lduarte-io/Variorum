//
//  EditorCommands.swift
//  Variorum
//
//  Menu wiring (Phase 7 Steps 5 + 7): the commit shortcut and the
//  structural-undo item. Structural undo is DISTINCT from command-Z —
//  command-Z stays NSTextView's per-buffer text undo; the two stacks never
//  interleave (OverallModel §3). undo() runs through OperationsRunner, so
//  two concurrent invocations execute one at a time (the KnownIssues
//  serialization note).
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

    var body: some Commands {
        // Phase 13 (B2): ⌘N = New Post (R41, ruled sitting 5 — "command N
        // should be new post"; new BLOCK needs no command, blocks are born
        // by typing) + the dated home's shortcut.
        CommandGroup(replacing: .newItem) {
            Button("New Post") { newPost() }
                .keyboardShortcut("n", modifiers: .command)
                .disabled(session == nil)
            Button("Today's Entry") { todaysEntry() }
                .keyboardShortcut("j", modifiers: .command)
                .disabled(session == nil)
        }
        // ⌘K (R15, ratified): find anything — posts, books, commands.
        CommandGroup(after: .sidebar) {
            Button("Find Anything…") { router.paletteRequested = true }
                .keyboardShortcut("k", modifiers: .command)
                .disabled(session == nil)
        }
        CommandGroup(after: .saveItem) {
            Button("Commit Take") {
                session?.editorRouter.active?.commitCaretVariant()
            }
            .keyboardShortcut("s", modifiers: .command)
        }
        // Phase 11b (B1): the File-menu export doors — the bulk gesture
        // (the whole library, ONE gesture — the no-lock-in principle) and
        // the caret block's single-block export. Projections and shapes
        // live in Queries; panels are the author-visible moments.
        CommandGroup(after: .importExport) {
            // B2's panel door (the drop's keyboard-reachable twin): each
            // picked file becomes a post via the same import operation.
            Button("Import Files…") { importFiles() }
                .disabled(session == nil)
            Divider()
            Button("Export Library…") { exportLibrary() }
                .disabled(session == nil)
            Button("Export Block as Markdown…") { exportCaretBlock() }
                .disabled(session?.editorRouter.active?.caretBlockID == nil)
        }
        CommandGroup(after: .undoRedo) {
            // Per-op labels (Phase 9, KnownIssues entry): the stack's change
            // observer keeps UndoMenuState current; disabled when empty.
            Button(Self.undoMenuTitle(for: session?.undoMenuState.topLabel)) {
                structuralUndo()
            }
            .keyboardShortcut("z", modifiers: [.command, .option])
            .disabled(session?.undoMenuState.topLabel == nil)
        }
        // The structural gestures' menu-bar door (Phase 9, contract item 1:
        // two named commands). Doors fire and speak (author 2026-07-09,
        // superseding the disabled-door posture): items are enabled whenever
        // an editor is focused, invocation plans against the CURRENT
        // selection, and a refusal surfaces its copy in the status bar —
        // a refused shortcut was previously a silently dead key. The planner
        // verdict still dims the button bar (`gestureAvailability`).
        CommandMenu("Block") {
            Button("Divide Block at Cursor") {
                session?.editorRouter.active?.divideAtCursor()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            Button("Extract Selection") {
                session?.editorRouter.active?.extractSelection()
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            Button("Make Block from Selection") {
                session?.editorRouter.active?.makeBlockFromSelection()
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            Divider()

            Button("Merge Blocks") {
                session?.editorRouter.active?.mergeBlocks()
            }
            .keyboardShortcut("m", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            // #11b (author, 2026-07-13): the deliberate, NAMED command —
            // deletes the selected span from EVERY take that contains it
            // uniquely, and reports the takes it couldn't match.
            Button("Delete in Every Take") {
                let editor = session?.editorRouter.active
                Task { await editor?.deleteInEveryTake() }
            }
            .disabled(session?.editorRouter.active == nil)

            Divider()

            // The fan door (9d): ANY block, any arity — the badge stays
            // fan-only, the door does not. In the boards it TOGGLES the
            // focused block's bloom (Sitting 9, R73).
            Button("Show Takes") {
                if let editor = session?.editorRouter.active {
                    editor.openCaretFan()
                } else {
                    TakesCommand.post(.toggleFan)
                }
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
            .disabled(session == nil)

            // The take lifecycle's keyboard family (Sitting 9, R73/R90/R93
            // — every shortcut a menu item; the visible surface handles;
            // nothing is a dead key).
            Button("New Take (Branch)") { TakesCommand.post(.branch) }
                .keyboardShortcut("t", modifiers: .command)
                .disabled(session == nil)
            Button("New Blank Take") { TakesCommand.post(.blank) }
                .keyboardShortcut("t", modifiers: [.command, .option])
                .disabled(session == nil)
            Button("New Blank Take as Chosen") { TakesCommand.post(.blankChoose) }
                .keyboardShortcut("t", modifiers: [.command, .option, .shift])
                .disabled(session == nil)
            Button("Choose This Take") { TakesCommand.post(.choose) }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(session == nil)
            Button("Previous Take") { TakesCommand.post(.stepPrev) }
                .keyboardShortcut(.leftArrow, modifiers: [.command, .control])
                .disabled(session == nil)
            Button("Next Take") { TakesCommand.post(.stepNext) }
                .keyboardShortcut(.rightArrow, modifiers: [.command, .control])
                .disabled(session == nil)
            Button("Archive Take") { TakesCommand.post(.archive) }
                .keyboardShortcut("a", modifiers: [.command, .shift])
                .disabled(session == nil)
            Button("Save Choices as Lens…") { TakesCommand.post(.saveLens) }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                .disabled(session == nil)
            Button("Close All Takes (Esc)") { TakesCommand.post(.closeAll) }
                .disabled(session == nil)

            Divider()

            // R73's block navigation pair (Write's caret).
            Button("Previous Block") {
                session?.editorRouter.active?.jumpToAdjacentBlock(-1)
            }
            .keyboardShortcut(.upArrow, modifiers: [.command, .control])
            .disabled(session?.editorRouter.active == nil)
            Button("Next Block") {
                session?.editorRouter.active?.jumpToAdjacentBlock(1)
            }
            .keyboardShortcut(.downArrow, modifiers: [.command, .control])
            .disabled(session?.editorRouter.active == nil)

            // The caret block's comments (Phase 13 C1, R7 — the keyboard
            // door beside the margin/inline faces).
            Button("Comments…") {
                session?.editorRouter.active?.openCaretComments()
            }
            .keyboardShortcut("'", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            // The callout frame (R16/R27): block-level presentation —
            // takes share the frame; colors are theme-token NAMES.
            Menu("Callout") {
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
            .disabled(session?.editorRouter.active == nil)

            Divider()

            // Phase 13 C1 (R6/R42): dotted seams on the GLOBAL setting —
            // supersedes the 9d "Show Blocks" tint toggle (that look is
            // retired; this is its face now). ⌘⇧B keeps the muscle memory.
            Button("Toggle Block Seams") { toggleSeams() }
                .keyboardShortcut("b", modifiers: [.command, .shift])
                .disabled(session == nil)
        }
        // ⌘1–⌘7 — the post modes (Sitting 9, R73; PostDetailView listens).
        CommandGroup(before: .toolbar) {
            ForEach(Array(PostDetailView.Mode.allCases.enumerated()), id: \.offset) { i, mode in
                Button(mode.rawValue) {
                    NotificationCenter.default.post(
                        name: .variorumSwitchMode, object: nil,
                        userInfo: ["mode": mode.rawValue])
                }
                .keyboardShortcut(KeyEquivalent(Character("\(i + 1)")), modifiers: .command)
                .disabled(session == nil)
            }
            Divider()
        }
        // ⌘/ — the shortcut helper + dictionary (Sitting 9, R73/R91).
        CommandGroup(after: .help) {
            Button("Shortcuts & Dictionary") { openWindow(id: "variorum-helper") }
                .keyboardShortcut("/", modifiers: .command)
        }
    }

    @Environment(\.openWindow) private var openWindow

    /// Flip the global seam setting (R42 — a synced document setting, not
    /// per-window state; every editor and the Settings pane follow).
    private func toggleSeams() {
        guard let session else { return }
        Task { @MainActor in
            do {
                let current = try await session.database.read { db in
                    try Queries.themeSettings(db).seamsVisible
                }
                try await session.runner.run { ops in
                    try ops.setSeamsVisible(!current)
                }
            } catch {
                session.editorRouter.active?.showStatus("Seam toggle failed: \(error)")
            }
        }
    }

    /// The callout emoji prompt (her sitting-3 reference wore "💡").
    private func promptCalloutEmoji() {
        guard let session, let editor = session.editorRouter.active else { return }
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

    // MARK: - ⌘N / ⌘J (Phase 13, B2)

    private func newPost() {
        guard let session else { return }
        Task { @MainActor in
            do {
                let post = try await session.runner.run { ops in
                    try ops.createPost(title: "Untitled")
                }
                router.pendingSelection = .post(post.id)
            } catch {
                session.editorRouter.active?.showStatus("New post failed: \(error)")
            }
        }
    }

    private func todaysEntry() {
        guard let session else { return }
        Task { @MainActor in
            do {
                // The R50 door: create-or-open + the daily-book membership.
                let outcome = try await JournalBooks.openToday(session: session)
                router.pendingSelection = .post(outcome.postID)
                if let note = outcome.note {
                    speak(session, title: "Today's Entry", message: note)
                }
            } catch {
                speak(session, title: "Today's Entry",
                      message: "Today's entry failed: \(error)")
            }
        }
    }

    /// Fire-and-speak with no editor required (round 2, MAJOR 2: the
    /// active-editor status line is nil on the shelf — the retired silent
    /// posture; the alert fallback is the importFiles precedent).
    @MainActor
    private func speak(_ session: AppSession, title: String, message: String) {
        if let editor = session.editorRouter.active {
            editor.showStatus(message)
        } else {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.runModal()
        }
    }

    // MARK: - Import door (Phase 11b, B2)

    private func importFiles() {
        guard let session else { return }
        let urls = ImportPanels.chooseFiles()
        guard !urls.isEmpty else { return }
        Task { @MainActor in
            let importer = ImportModel(session: session)
            await importer.importFiles(urls, into: .library)
            let message = importer.lastError.map { "Import failed: \($0)" }
                ?? importer.lastReport ?? "Import finished."
            if let editor = session.editorRouter.active {
                editor.showStatus(message)
            } else {
                let alert = NSAlert()
                alert.messageText = "Import Files"
                alert.informativeText = message
                alert.runModal()
            }
        }
    }

    // MARK: - Export doors (Phase 11b, B1)

    private func exportLibrary() {
        guard let session else { return }
        guard let folder = ExportPanels.chooseFolder(prompt: "Export Library") else { return }
        Task { @MainActor in
            let exporter = ExportModel(session: session)
            // Readings ride ALWAYS-ON at this face (round 2, recorded
            // build-time call for the checkpoint walk: the ratified
            // "optional folder views" is the manifest's includeReadings
            // parameter — built and pinned; a user-facing toggle (accessory
            // checkbox on the chooser) is a product-surface choice, hers).
            await exporter.writeBulkExport(to: folder)
            let message = exporter.lastError.map { "Export failed: \($0)" }
                ?? exporter.lastReport ?? "Export finished."
            if let editor = session.editorRouter.active {
                editor.showStatus(message)
            } else {
                let alert = NSAlert()
                alert.messageText = "Export Library"
                alert.informativeText = message
                alert.runModal()
            }
        }
    }

    private func exportCaretBlock() {
        guard let session, let editor = session.editorRouter.active,
              let blockID = editor.caretBlockID else { return }
        let postID = editor.postID
        Task { @MainActor in
            // Default filename from the block's read-time HANDLE (name else
            // first sentence — the A6 tocHandle, one brain), through the
            // same sanitize rule as every other export door (review round
            // 1, NIT 2 — the literal "Block.md" was the odd one out).
            let handle: String? = try? await session.database.read { db in
                try Queries.blockTOC(db, post: postID)
                    .first { $0.blockID == blockID }
                    .map { Queries.tocHandle(name: $0.name, text: $0.text) }
            }
            guard let url = ExportPanels.saveFile(
                defaultName: ExportModel.blockExportFileName(handle: handle),
                type: .markdownFile) else { return }
            let exporter = ExportModel(session: session)
            if let markdown = await exporter.markdown(forBlock: blockID) {
                exporter.writeMarkdown(markdown, to: url)
            }
            editor.showStatus(
                exporter.lastError.map { "Export failed: \($0)" }
                    ?? exporter.lastReport ?? "Export finished.")
        }
    }

    private func structuralUndo() {
        guard let session else { return }
        let undoStack = session.undoStack // Sendable; the closure must not capture the session
        Task { @MainActor in
            do {
                let label = try await session.runner.run { ops in
                    try undoStack.undo(with: ops)
                }
                session.editorRouter.active?.showStatus(
                    label.map { "Undid: \($0)" } ?? "No structural change to undo.")
            } catch {
                // A failed inverse stays on the stack (UndoStack doctrine);
                // the user resolves (e.g. unseals the post) and retries.
                session.editorRouter.active?.showStatus("Undo failed: \(error)")
            }
        }
    }
}
