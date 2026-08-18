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
    /// (Compare/Blocks; Canvas falls through — Outline retired into
    /// Compare, 13b 4C) the fallback below
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
                status.speak(sealed ? "Unsealed." : "Sealed — the note is read-only until unsealed.")
            } catch {
                status.speak(OpsRefusalCopy.message(for: error))
            }
        }
    }

    /// ⌥⌘Z (N4): the structural undo executes AND reports through the
    /// mode-independent status surface — never into a nil editor.
    ///
    /// **A12 (author ruling, 13d sitting 2026-07-28) — the destructive-undo
    /// warning, at exactly her definition:** the confirm fires ONLY when the
    /// undo would discard text edited since the operation (the insurance
    /// class — `UndoStack.pendingUndoWarning`). Every other structural undo
    /// stays silent, and redo is untouched. `confirm` is the injectable seam
    /// (the `openTutorial` precedent) so the DECISION is pinnable without an
    /// NSAlert.
    ///
    /// **A headless caller in the insurance class MUST pass `confirm:`** —
    /// the default runs a modal alert, which in a test host waits forever
    /// (found exactly that way: the tutorial's own insurance pin hung the
    /// spine until it answered).
    func structuralUndo(confirm: ((UndoStack.PendingUndoWarning) -> Bool)? = nil) {
        let undoStack = session.undoStack  // Sendable; the closure must not capture the session
        Task { @MainActor in
            do {
                let warning = try await session.runner.run { ops in
                    undoStack.pendingUndoWarning(with: ops)
                }
                if let warning {
                    let approved = confirm?(warning) ?? Self.confirmDiscardingUndo(warning)
                    guard approved else {
                        status.speak("Undo cancelled — nothing changed.")
                        return
                    }
                }
                let label = try await session.runner.run { ops in
                    try undoStack.undo(with: ops)
                }
                status.speak(label.map { "Undid: \($0)" } ?? "No structural change to undo.")
            } catch {
                // A failed inverse stays on the stack (UndoStack doctrine);
                // the user resolves (e.g. unseals the post) and retries.
                status.speak("Undo failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    /// ⇧⌥⌘Z (13c 1B — A10): the undo door's exact mirror. Same
    /// mode-independent execution and reporting; a refused re-apply stays
    /// on the redo stack for retry, like a refused inverse.
    func structuralRedo() {
        let undoStack = session.undoStack  // Sendable; never capture the session
        Task { @MainActor in
            do {
                let label = try await session.runner.run { ops in
                    try undoStack.redo(with: ops)
                }
                status.speak(label.map { "Redid: \($0)" } ?? "No structural change to redo.")
            } catch {
                status.speak("Redo failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    // MARK: - App-scope acts (⌘N / ⌘J / import / export / seams)

    func newPost() {
        Task { @MainActor in
            do {
                let post = try await session.runner.run { ops in
                    // 13g batch 7 (R6-3): NULL, not the placeholder — see
                    // `LibraryViewModel.createPost`.
                    try ops.createPost(title: nil)
                }
                shell.pendingSelection = .post(post.id)
            } catch {
                status.speak("New note failed: \(error)")
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

    /// Help ▸ Restore Tutorial… — fire-and-DO, ONE discovery (Stage 2
    /// ladder, MAJOR-A): the spoken confirm gates on ANYTHING the replace
    /// would destroy existing (not just a live book — a bookless store can
    /// still hold tagged posts, hers included), and the SAME discovery
    /// flows into the replace, so what was confirmed is exactly what dies.
    /// `confirm` is the injectable seam over the modal alert. A
    /// double-press converges: the session latch makes the second press a
    /// synchronous no-op (NIT-6).
    func restoreTutorial(confirm: (() -> Bool)? = nil) {
        guard session.beginTutorialDoor() else { return }
        Task { @MainActor in
            defer { session.endTutorialDoor() }
            do {
                let existing = try await session.database.read { db in
                    try TutorialSeeder.discover(db)
                }
                if !existing.isEmpty {
                    let confirmed = confirm?() ?? Self.confirmTutorialReplace()
                    guard confirmed else { return }
                }
                let bookID = try await TutorialSeeder.restore(session: session, existing: existing)
                shell.pendingSelection = .reading(bookID)
                status.speak("The tutorial is fresh — “\(TutorialSeeder.bookName)” is on your shelf.")
            } catch {
                status.speak("Restore Tutorial failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    /// The open entrance (⌘K row, Library door): an existing book opens;
    /// none ⇒ seed one first — through the restore path (confirm and all)
    /// when a bookless store still holds tutorial residue (MINOR-D5).
    /// Fire-and-DO — never a lecture; failures speak. Shares the door
    /// latch with Restore (the two doors must not race each other either).
    func openTutorial(confirm: (() -> Bool)? = nil) {
        guard session.beginTutorialDoor() else { return }
        Task { @MainActor in
            defer { session.endTutorialDoor() }
            do {
                guard let bookID = try await TutorialSeeder.findOrSeed(
                    session: session,
                    confirmReplace: { confirm?() ?? Self.confirmTutorialReplace() })
                else {
                    // 13b 3F (Stage 2 round-2 note b): findOrSeed's one nil
                    // path is a DECLINED confirm — the user asked to OPEN
                    // and nothing opened; say why instead of going quiet.
                    status.speak(
                        "Nothing opened — re-seeding the tutorial would replace the "
                        + "tutorial residue on this store, and you cancelled. Everything stays as it is.")
                    return
                }
                shell.pendingSelection = .reading(bookID)
            } catch {
                status.speak("Opening the tutorial failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    /// A12's dialog: it names what would be SET ASIDE and says where it
    /// goes. Plain words, exact scope — the tutorial confirm's shape.
    /// (Copy is static and pure so a pin can read it without a window.)
    nonisolated static func discardingUndoQuestion(
        _ warning: UndoStack.PendingUndoWarning
    ) -> String {
        "Undo \(warning.label)?"
    }

    nonisolated static func discardingUndoDetail(
        _ warning: UndoStack.PendingUndoWarning
    ) -> String {
        let subject = warning.bufferCount == 1
            ? "One take has been edited since" : "\(warning.bufferCount) takes have been edited since"
        return "\(subject) — undoing puts back the text as it was BEFORE the "
            + "\(warning.label.lowercased()), so that writing is set aside. "
            + "It is committed first, so you can bring it back from the take's "
            + "history (⌘S's list) at any time."
    }

    @MainActor
    private static func confirmDiscardingUndo(_ warning: UndoStack.PendingUndoWarning) -> Bool {
        let alert = NSAlert()
        alert.messageText = discardingUndoQuestion(warning)
        alert.informativeText = discardingUndoDetail(warning)
        alert.addButton(withTitle: "Undo")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
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

    /// ⌘K's Toggle Star (13f batch 6, W4 — her ruling's "+ ⌘K by name"
    /// half): it stars the thing the FOCUSED pane is showing. The rule for
    /// what that is lives in `StarTargeting`, pure and pinned, because the
    /// palette's target is a rule and a rule inside a closure is one no
    /// test can keep.
    ///
    /// The menu/palette door is grey where nothing starrable is open (the
    /// registry's `canStarCurrent`), so the guard below is reachable only by
    /// a race — and it speaks rather than returning silently, the
    /// `exportCaretBlock` shape. Success is deliberately QUIET: the Starred
    /// section at the sidebar's top gains or loses the row, which is the
    /// same feedback every other toggle in this file gives (seams, the
    /// context bar, shelf pins).
    func toggleStarForCurrent() {
        guard let target = StarTargeting.target(for: shell.workspace.focusedSelection) else {
            status.speak(CapabilityRegistry.capability(.toggleStar).unavailableNote)
            return
        }
        Task { @MainActor in
            do {
                // Read-then-act, like every toggle here: the store is the
                // truth and the DECISION is the operation's (order, cap,
                // self-heal). A racing star from another device makes this
                // a redundant no-op at worst — `setStarred` is idempotent
                // both ways.
                let starred = try await session.database.read { db in
                    try Queries.starred(db).contains { $0.target == target }
                }
                try await session.runner.run { ops in
                    try ops.setStarred(target, starred: !starred)
                }
            } catch {
                status.speak(OpsRefusalCopy.message(for: error))
            }
        }
    }

    /// **The FORMAT menu's door (13g batch 3 — L8).** It acts on whichever of
    /// our text surfaces holds the keyboard, which is what "format what I am
    /// writing" means; `MarkdownActs.target` is the rule, and it is
    /// deliberately narrow — a rename field or the ⌘K search field is an
    /// editable `NSTextView` too, and must never receive `****` from a key.
    ///
    /// Fire-and-DO (P-2): where there is no such surface the door SPEAKS
    /// rather than being a dead key. The menu item is already grey with no
    /// note open (the registry's `editableText`), so this refusal covers the
    /// real case — a note IS open, and the keyboard is somewhere else (a
    /// sidebar row, the shelf, a read pane).
    /// 13k K7: the body moved onto `MarkdownActs.fire` so the bottom bars'
    /// formatting toolbar fires the SAME door rather than a copy of it.
    func applyFormat(_ act: MarkdownEditing.Act) {
        MarkdownActs.fire(act, status: status)
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
        .commitTake, .structuralUndo, .structuralRedo, .sealPost,
        .divide, .extract, .makeBlock, .merge, .addBlockAtEnd, .insertBlockBelow, .deleteBlock,
        .showTakes, .newTake, .blankTake, .chooseTake,
        .saveChoicesAsLens, .toggleSeams, .restoreTutorial,
        // 13f batch 5 (W20 b), repointed by 13k K12: the tag cards' fold,
        // typeable.
        .toggleTagChips,
        // 13f batch 6 (W4): her ruling's "+ ⌘K by name" half.
        .toggleStar,
        // 13f batch 6 (W5): the quick note, typeable like every other door.
        .quickNote,
        // 13j J3 (sitting round 4): the lineage door, typeable — a palette is
        // summoned, not chrome, so it sits inside her not-daily-chrome
        // criterion (the architect's call at the sitting, hers to strike).
        .showOriginBlock,
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
        case .structuralRedo: return { structuralRedo() }
        case .sealPost: return { toggleSeal() }
        case .divide: return { dispatch(.structural(.divide)) }
        case .extract: return { dispatch(.structural(.extract)) }
        case .makeBlock: return { dispatch(.structural(.makeBlock)) }
        case .merge: return { dispatch(.structural(.merge)) }
        case .addBlockAtEnd: return { dispatch(.addBlockAtEnd) }
        case .insertBlockBelow: return { dispatch(.insertBlockBelow) }
        case .deleteBlock: return { dispatch(.deleteBlock) }
        case .showTakes: return { dispatch(.takes(.toggleFan)) }
        case .newTake: return { dispatch(.takes(.branch)) }
        case .blankTake: return { dispatch(.takes(.blank)) }
        case .chooseTake: return { dispatch(.takes(.choose)) }
        case .saveChoicesAsLens: return { dispatch(.takes(.saveLens)) }
        case .toggleSeams: return { toggleSeams() }
        case .toggleTagChips: return { shell.toggleTagChips() }
        case .toggleStar: return { toggleStarForCurrent() }
        case .quickNote: return { shell.quickNoteRequested = true }
        case .showOriginBlock: return { dispatch(.showOriginBlock) }
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
