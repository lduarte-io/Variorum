//
//  ShellActions.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (the T3 routing slice, app half): the menu bar's and
//  palette's ACTIONS, out of the Commands struct into a testable executor.
//  Every body routes through the CommandRouter / operations and reports
//  through the StatusCenter — mode-independent by construction, which is
//  exactly N4's fix (⌥⌘Z used to report into a nil Write editor) and N5's
//  (⌘S used to call into nil outside Write while the Takes bar advertised
//  it).
//

import AppKit
import Foundation
import VariorumCore

@MainActor
struct ShellActions {
    let session: AppSession
    let shell: ShellRouter

    private var router: CommandRouter { session.commandRouter }
    private var status: StatusCenter { session.status }

    // MARK: - Enablement (registry-driven — the menu reads this)

    func isEnabled(_ id: CapabilityID) -> Bool {
        router.isEnabled(id)
    }

    // MARK: - Routed surface commands

    func dispatch(_ command: RoutedCommand) {
        router.dispatch(command)
    }

    func requestMode(_ mode: PostMode) {
        router.requestMode(mode)
    }

    /// ⌘S (N5): acts wherever advertised — the mounted surface commits its
    /// focused/caret take through the one authority; where genuinely no
    /// target exists the registry's honest note speaks (and the menu item
    /// was disabled anyway).
    func commitTake() {
        router.dispatch(.commit)
    }

    /// The seal door (palette + routed): the mounted surface runs its own
    /// teardown contract (Write finalizes the open tail first); with no
    /// surface handler but an open post, flush-and-toggle directly. The
    /// dispatch is QUIET (round-1 MINOR-1): in handler-less modes
    /// (Compare/Outline/Blocks; Canvas falls through) the fallback below
    /// ACTS, so the unhandled note — "open a post first", with a post open
    /// — was a factually wrong refusal flashing right before "Sealed.".
    /// Where the fallback genuinely can't act, IT speaks the honest note.
    func toggleSeal() {
        if router.dispatch(.toggleSeal, speakingWhenUnhandled: false) { return }
        guard let postID = router.activePostID else {
            status.speak(CapabilityRegistry.capability(.sealPost).unavailableNote)
            return
        }
        Task { @MainActor in
            do {
                let sealed = try await session.database.read { db in
                    try Queries.containerHeader(db, containerID: postID)?.locked == true
                }
                await session.autosave(forPost: postID).flushNow()
                try await session.runner.run { ops in
                    if sealed {
                        try ops.unlockPost(postID)
                    } else {
                        try ops.lockPost(postID)
                    }
                }
                status.speak(sealed ? "Unsealed." : "Sealed — the post is read-only until unsealed.")
            } catch {
                status.speak(OpsRefusalCopy.message(for: error))
            }
        }
    }

    /// ⌥⌘Z (N4): the structural undo executes AND reports through the
    /// mode-independent status surface — never into a nil editor.
    func structuralUndo() {
        let undoStack = session.undoStack  // Sendable; the closure must not capture the session
        Task { @MainActor in
            do {
                let label = try await session.runner.run { ops in
                    try undoStack.undo(with: ops)
                }
                status.speak(label.map { "Undid: \($0)" } ?? "No structural change to undo.")
            } catch {
                // A failed inverse stays on the stack (UndoStack doctrine);
                // the user resolves (e.g. unseals the post) and retries.
                status.speak("Undo failed: \(error)")
            }
        }
    }

    // MARK: - App-scope acts (⌘N / ⌘J / import / export / seams)

    func newPost() {
        Task { @MainActor in
            do {
                let post = try await session.runner.run { ops in
                    try ops.createPost(title: "Untitled")
                }
                shell.pendingSelection = .post(post.id)
            } catch {
                status.speak("New post failed: \(error)")
            }
        }
    }

    func todaysEntry() {
        Task { @MainActor in
            do {
                // The R50 door: create-or-open + the daily-book membership.
                let outcome = try await JournalBooks.openToday(session: session)
                shell.pendingSelection = .post(outcome.postID)
                if let note = outcome.note {
                    status.speak(note)
                }
            } catch {
                status.speak("Today's entry failed: \(error)")
            }
        }
    }

    func importFiles() {
        let urls = ImportPanels.chooseFiles()
        guard !urls.isEmpty else { return }
        Task { @MainActor in
            let importer = ImportModel(session: session)
            await importer.importFiles(urls, into: .library)
            status.speak(
                importer.lastError.map { "Import failed: \($0)" }
                    ?? importer.lastReport ?? "Import finished.")
        }
    }

    func exportLibrary() {
        guard let folder = ExportPanels.chooseFolder(prompt: "Export Library") else { return }
        Task { @MainActor in
            let exporter = ExportModel(session: session)
            // Readings ride ALWAYS-ON at this face (Phase 11b recorded call).
            await exporter.writeBulkExport(to: folder)
            status.speak(
                exporter.lastError.map { "Export failed: \($0)" }
                    ?? exporter.lastReport ?? "Export finished.")
        }
    }

    func exportCaretBlock() {
        // Round-1 MINOR-3: the guard SPEAKS — enablement is attachment-
        // level (the registry), so a caret outside any block (the open
        // tail) reaches here and must never be a silent no-op.
        guard let editor = session.editorRouter.active,
              let blockID = editor.caretBlockID else {
            status.speak(CapabilityRegistry.capability(.exportCaretBlock).unavailableNote)
            return
        }
        let postID = editor.postID
        Task { @MainActor in
            // Default filename from the block's read-time HANDLE (name else
            // first sentence — the A6 tocHandle, one brain).
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
            status.speak(
                exporter.lastError.map { "Export failed: \($0)" }
                    ?? exporter.lastReport ?? "Export finished.")
        }
    }

    // MARK: - The tutorial doors (13b Stage 2, R113)

    /// Help ▸ Restore Tutorial… — fire-and-DO: replace the tutorial book
    /// wholesale (after a spoken confirm when one exists), then OPEN the
    /// fresh copy. `confirm` is the injectable seam over the modal alert.
    func restoreTutorial(confirm: (() -> Bool)? = nil) {
        Task { @MainActor in
            if await TutorialSeeder.existingBookID(session: session) != nil {
                let confirmed = confirm?() ?? Self.confirmTutorialReplace()
                guard confirmed else { return }
            }
            do {
                let bookID = try await TutorialSeeder.restore(session: session)
                shell.pendingSelection = .reading(bookID)
                status.speak("The tutorial is fresh — “\(TutorialSeeder.bookName)” is on your shelf.")
            } catch {
                status.speak("Restore Tutorial failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    /// The open entrance (⌘K row, Library door): an existing book opens;
    /// none ⇒ seed one first. Fire-and-DO — never a lecture.
    func openTutorial() {
        Task { @MainActor in
            do {
                let bookID = try await TutorialSeeder.findOrSeed(session: session)
                shell.pendingSelection = .reading(bookID)
            } catch {
                status.speak("Opening the tutorial failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    /// The spoken confirm (brief decision 6): plain words, exact scope.
    @MainActor
    private static func confirmTutorialReplace() -> Bool {
        let alert = NSAlert()
        alert.messageText = TutorialSeeder.replaceQuestion
        alert.informativeText = TutorialSeeder.replaceDetail
        alert.addButton(withTitle: "Replace")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    /// Flip the global seam setting (R42 — a synced document setting).
    func toggleSeams() {
        Task { @MainActor in
            do {
                let current = try await session.database.read { db in
                    try Queries.themeSettings(db).seamsVisible
                }
                try await session.runner.run { ops in
                    try ops.setSeamsVisible(!current)
                }
            } catch {
                status.speak("Seam toggle failed: \(error)")
            }
        }
    }

    // MARK: - The ⌘K palette's registry rows (R15's promise, made true)

    /// The palette-doored ACT capabilities this builder wires — asserted
    /// against the registry's palette door set by the walk test. Navigation
    /// rows (go-to, settings, voices) stay the shell's own.
    static let paletteActs: [CapabilityID] = [
        .newPost, .todaysEntry, .importFiles, .exportLibrary,
        .commitTake, .structuralUndo, .sealPost,
        .divide, .extract, .makeBlock, .merge, .addBlockAtEnd,
        .showTakes, .newTake, .blankTake, .chooseTake,
        .saveChoicesAsLens, .toggleSeams, .restoreTutorial,
    ]

    /// Palette rows for the act capabilities: title = the registry verb,
    /// action = the same routed body as the menu door (fire-and-DO — an
    /// act that can't work HERE speaks its honest note).
    func paletteEntries() -> [(title: String, action: @MainActor () -> Void)] {
        Self.paletteActs.map { id in
            (CapabilityRegistry.capability(id).verb, paletteAction(for: id))
        }
    }

    private func paletteAction(for id: CapabilityID) -> @MainActor () -> Void {
        switch id {
        case .newPost: return { newPost() }
        case .todaysEntry: return { todaysEntry() }
        case .importFiles: return { importFiles() }
        case .exportLibrary: return { exportLibrary() }
        case .commitTake: return { commitTake() }
        case .structuralUndo: return { structuralUndo() }
        case .sealPost: return { toggleSeal() }
        case .divide: return { dispatch(.structural(.divide)) }
        case .extract: return { dispatch(.structural(.extract)) }
        case .makeBlock: return { dispatch(.structural(.makeBlock)) }
        case .merge: return { dispatch(.structural(.merge)) }
        case .addBlockAtEnd: return { dispatch(.addBlockAtEnd) }
        case .showTakes: return { dispatch(.takes(.toggleFan)) }
        case .newTake: return { dispatch(.takes(.branch)) }
        case .blankTake: return { dispatch(.takes(.blank)) }
        case .chooseTake: return { dispatch(.takes(.choose)) }
        case .saveChoicesAsLens: return { dispatch(.takes(.saveLens)) }
        case .toggleSeams: return { toggleSeams() }
        case .restoreTutorial: return { restoreTutorial() }
        default:
            // NIT-1 (Stage 1 ladder): a future `paletteActs` entry without
            // a wired case must never compile into a silent no-op row —
            // loud in DEBUG, an honest sentence in release.
            let status = self.status
            return {
                assertionFailure("palette act \(id) has no wired action")
                status.speak("That command isn't wired to the palette yet.")
            }
        }
    }
}
