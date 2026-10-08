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
import os
import VariorumCore

@MainActor
struct ShellActions {
    let session: AppSession
    let shell: ShellRouter
    /// F3 (MINOR-N3): the tutorial door's one quiet line when its silent
    /// ensure declines — silence on a screen, never silence in the log.
    private static let log = Logger(subsystem: "io.lduarte.Variorum", category: "tutorial")

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

    /// **⌘⇧I — tag this note** (the Act 10 correction round, row 15): opens
    /// the mounted detail's inline tag field through the router's seam; with
    /// no note under it the registry's honest note speaks (P-2).
    func tagNote() {
        if !session.commandRouter.requestTagField() {
            status.refuse(CapabilityRegistry.capability(.tagNote).unavailableNote)
        }
    }

    /// ⌘S (N5): acts wherever advertised — the mounted surface commits its
    /// focused/caret take through the one authority; where genuinely no
    /// target exists the registry's honest note speaks (and the menu item
    /// was disabled anyway).
    func commitTake() {
        router.dispatch(.commit)
    }

    /// **⌘⇧S — save a version of the whole note** (the post-13l polish round,
    /// ledger rows 16/23; V5's chord, verified free at the kickoff). It is the
    /// deliberate twin of ⌘S one grain up, and the pairing is itself the
    /// teaching: this TAKE's moment · this NOTE's moment.
    ///
    /// It routes like ⌘S so the note it saves is always the one on screen; a
    /// surface that cannot answer lets the registry's honest note speak (P-2).
    func saveNoteVersion() {
        router.dispatch(.saveNoteVersion)
    }

    /// **The ⌘K "Block History" row** (the Act 10 correction round, batch G
    /// — row 86(d); `toggleSeal`'s shape). The mounted surface's handler
    /// opens the pane for its caret/ring block (Write, Takes, Lenses); where
    /// NO surface handles it — Read's faces and Blocks report a current
    /// block (row 39) but register no command handler — the router opens it
    /// for the FOCUSED block; only with no block in hand does the registry's
    /// honest note speak. The dispatch is QUIET for the seal's reason: the
    /// fallback ACTS, so the "put the caret in a block" refusal that used to
    /// flash — with a block selected on screen — was factually wrong.
    func showBlockHistory() {
        if router.dispatch(.showBlockHistory, speakingWhenUnhandled: false) { return }
        if router.requestBlockHistoryForFocusedBlock() { return }
        status.refuse(CapabilityRegistry.capability(.showBlockHistory).unavailableNote)
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
            status.refuse(CapabilityRegistry.capability(.sealPost).unavailableNote)
            return
        }
        Task { @MainActor in
            do {
                let sealed = try await session.database.read { db in
                    try Queries.containerHeader(db, containerID: postID)?.locked == true
                }
                // 18k C1: FLUSH, never mint — an open post's entry is held by
                // its surface, so this reaches the same coordinator; where no
                // surface holds one there is nothing pending by construction,
                // and a mint here was a holder nobody would ever release.
                await session.flushExistingAutosave(forPost: postID)
                try await session.runner.run { ops in
                    if sealed {
                        try ops.unlockPost(postID)
                    } else {
                        try ops.lockPost(postID)
                    }
                }
                status.receipt(
                    sealed ? "Unsealed." : "Sealed — the note is read-only until unsealed.")
            } catch {
                status.refuse(OpsRefusalCopy.message(for: error))
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
    ///
    /// **One flight at a time (18k C5, 17e P33 — the phone's rule).** The
    /// warning and the undo are two runner submissions that each read the
    /// stack's top, so a second press inside the first's flight used to
    /// queue warn, warn, undo, undo: both warnings described E while the
    /// second press undid E−1, skipping A12's confirm when E−1 was the one
    /// in the insurance class. The latch is taken at PRESS time, before any
    /// await, and a press that finds it held refuses in the phone's words.
    /// It is SHARED with ⇧⌥⌘Z (`structuralRedo`), as the phone's is: a redo
    /// landing inside this gap is the same crossing one door over.
    func structuralUndo(confirm: ((UndoStack.PendingUndoWarning) -> Bool)? = nil) {
        guard session.beginStructuralUndoDoor() else {
            status.refuse(StructuralUndoCopy.anotherIsLanding)
            return
        }
        let undoStack = session.undoStack  // Sendable; the closure must not capture the session
        Task { @MainActor in
            defer { session.endStructuralUndoDoor() }
            do {
                let warning = try await session.runner.run { ops in
                    undoStack.pendingUndoWarning(with: ops)
                }
                if let warning {
                    let approved = confirm?(warning) ?? Self.confirmDiscardingUndo(warning)
                    guard approved else {
                        status.refuse(StructuralUndoCopy.undoCancelled)
                        return
                    }
                }
                let label = try await session.runner.run { ops in
                    try undoStack.undo(with: ops)
                }
                // 18i: an act that came back is a RECEIPT; "nothing to
                // undo" is a refusal and keeps the toast.
                if let label {
                    status.receipt(StructuralUndoCopy.undone(label))
                } else {
                    status.refuse(StructuralUndoCopy.nothingToUndo)
                }
            } catch {
                // A failed inverse stays on the stack (UndoStack doctrine);
                // the user resolves (e.g. unseals the post) and retries.
                status.refuse(StructuralUndoCopy.undoFailed(
                    OpsRefusalCopy.message(for: error)))
            }
        }
    }

    /// ⇧⌥⌘Z (13c 1B — A10): the undo door's exact mirror. Same
    /// mode-independent execution and reporting; a refused re-apply stays
    /// on the redo stack for retry, like a refused inverse.
    ///
    /// 18k C5 (P33): it holds the undo door's ONE latch — a redo inside an
    /// undo's warn→act gap would re-apply the entry that undo then takes,
    /// after the confirm she answered described a different one. Its own
    /// single submission reads and pops atomically, so two REDO presses were
    /// never the defect; the shared latch is the phone's rule, whole.
    func structuralRedo() {
        guard session.beginStructuralUndoDoor() else {
            status.refuse(StructuralUndoCopy.anotherIsLanding)
            return
        }
        let undoStack = session.undoStack  // Sendable; never capture the session
        Task { @MainActor in
            defer { session.endStructuralUndoDoor() }
            do {
                let label = try await session.runner.run { ops in
                    try undoStack.redo(with: ops)
                }
                if let label {
                    status.receipt(StructuralUndoCopy.redone(label))
                } else {
                    status.refuse(StructuralUndoCopy.nothingToRedo)
                }
            } catch {
                status.refuse(StructuralUndoCopy.redoFailed(
                    OpsRefusalCopy.message(for: error)))
            }
        }
    }

    // MARK: - App-scope acts (⌘N / ⌘J / import / export / seams)

    func newPost() {
        // 13i-d U5: ⌘N mints in the wing she is standing in.
        let wing = session.wing.currentID
        Task { @MainActor in
            do {
                let post = try await session.runner.run { ops in
                    // 13g batch 7 (R6-3): NULL, not the placeholder — see
                    // `LibraryViewModel.createPost`.
                    try ops.createPost(title: nil, wingId: wing)
                }
                shell.pendingSelection = .post(post.id)
            } catch {
                status.refuse("New note failed: \(error)")
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
                    status.refuse(note)
                }
                // 13i-e U2 (F-U1-6's ruling): the Journal came back — a
                // RECEIPT (quiet by default; `receipt_style` governs).
                if let receipt = outcome.receipt {
                    status.receipt(receipt)
                }
            } catch {
                status.refuse("Today's entry failed: \(error)")
            }
        }
    }

    func importFiles() {
        let urls = ImportPanels.chooseFiles()
        guard !urls.isEmpty else { return }
        Task { @MainActor in
            let importer = ImportModel(session: session)
            await importer.importFiles(urls, into: .library)
            // 18i: a failure is a refusal (always shown); the report of
            // what arrived is a receipt.
            if let failure = importer.lastError {
                status.refuse("Import failed: \(failure)")
            } else {
                // J29's second member: a report that names only SKIPS says
                // nothing arrived, and a refusal always shows.
                status.say(
                    importer.lastReport ?? "Import finished.",
                    refusing: importer.lastReportIsRefusal)
            }
        }
    }

    func exportLibrary() {
        guard let folder = ExportPanels.chooseFolder(prompt: "Export Library") else { return }
        Task { @MainActor in
            let exporter = ExportModel(session: session)
            // Readings ride ALWAYS-ON at this face (Phase 11b recorded call).
            await exporter.writeBulkExport(to: folder)
            if let failure = exporter.lastError {
                status.refuse("Export failed: \(failure)")
            } else {
                // J37: "Exported 0 files." wrote nothing, so nothing landed.
                status.say(
                    exporter.lastReport ?? "Export finished.",
                    refusing: exporter.lastReportIsRefusal)
            }
        }
    }

    func exportCaretBlock() {
        // Round-1 MINOR-3: the guard SPEAKS — enablement is attachment-
        // level (the registry), so a caret outside any block (the open
        // tail) reaches here and must never be a silent no-op.
        // `editingOrActive` (the 18d ladder's MINOR-1): this door exports
        // THE BLOCK SHE IS IN, so it asks which editor she is writing in. In
        // the book's Outline `active` is the projection-less shadow, whose
        // `caretBlockID` is nil — the door spoke "unavailable" over a note
        // she was typing in.
        guard let editor = session.editorRouter.editingOrActive,
              let blockID = editor.caretBlockID else {
            status.refuse(CapabilityRegistry.capability(.exportCaretBlock).unavailableNote)
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
            if let failure = exporter.lastError {
                status.refuse("Export failed: \(failure)")
            } else {
                // J37: "Exported 0 files." wrote nothing, so nothing landed.
                status.say(
                    exporter.lastReport ?? "Export finished.",
                    refusing: exporter.lastReportIsRefusal)
            }
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
                    let confirmed: Bool
                    if let confirm { confirmed = confirm() }
                    else { confirmed = await askToReplaceTutorial() }
                    guard confirmed else { return }
                }
                let bookID = try await TutorialSeeder.restore(session: session, existing: existing)
                // 13i-d U7: a RESTORE door — the Welcome arrangement rides it
                // (the guide onto Welcome, and the classics lesson put back
                // where missing). Never a silent retrofit: only a door she
                // pressed arranges an existing store.
                let arranged = await Self.arrangeWelcome(session: session)
                shell.pendingSelection = .reading(bookID)
                status.receipt(WelcomeDoorCopy.tutorialRestored(
                    guide: TutorialSeeder.bookName, shelf: arranged?.welcome.shelf.name))
            } catch {
                status.refuse("Restore Tutorial failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    /// **Help ▸ Restore the Sample Library** (pre-13u Act 10 — the
    /// tenth-wave ruling: *"Restore door - yes, let's do it"*; Sherlock is
    /// field-guide-class seeded content, and the field guide has restore).
    ///
    /// Deliberately UNLIKE the tutorial's replace: `SampleLibrarySeeder`'s
    /// seed is RESUMABLE — it mints only what is MISSING (a deleted book
    /// comes back whole; a half-deleted one gets its missing stories back;
    /// her own edits to surviving copies are untouched) — so nothing of
    /// hers can be destroyed and no confirm gates the door. Fire-and-DO:
    /// it restores AND opens the book; failures speak.
    func restoreSampleLibrary() { restoreSeededBook(.sherlock) }

    // (Help ▸ Restore “Encryption Explained” — pre-13x 5a — REMOVED at
    // 13s-b U1b, R-13s-37, her word: "encryption explained not present and
    // not restorable". The book's content stays in `Book.all` as the
    // dedupe facts' vocabulary for the installed base; no door mints it.)

    /// 18l-c U6 (R-18l-11) — **Help ▸ Restore “the strange case of dr
    /// jekyll and mr hyde”** (the title lowercased at 13s-b U1b, R-13s-38 —
    /// one casing, the seed's style): the takemania book through the same
    /// door. Like the others it mints only what is MISSING — so a deleted
    /// takemania note comes back fresh, its whole scripted history with it
    /// (the front matter's R-18l-12 promise), while a takemania she is
    /// still playing with is never touched.
    func restoreJekyllBook() { restoreSeededBook(.jekyllAndHyde) }

    /// 13s-b U1b (R-13s-37, her word: "classics restorable") — **Help ▸
    /// Restore the “classics” Gathering** (the menu title is the
    /// implementer's, PROVISIONAL P-U1b-3): the gathering left the fresh
    /// seed (R-13s-5), so this door is its one road back. It composes the
    /// Welcome arrangement first (the classic books' shipped notes tagged
    /// `#classics`, Welcome adopted or minted), then ADOPTS a live Home
    /// gathering wearing the rule or the reserved name, else MINTS one on
    /// Welcome from the `#classics` tag — the retired arrangement step's
    /// exact shape. Fire-and-DO; an adopted gathering is a refusal (the
    /// door changed nothing), a minted one a receipt.
    func restoreClassicsGathering() {
        Task { @MainActor in
            do {
                let arranged = await Self.arrangeWelcome(session: session)
                let name = SampleLibraryWelcome.classicsGatheringName
                let (gatheringID, minted) = try await session.runner.run { _ in
                    try SampleLibraryWelcome.restoreClassicsGathering(
                        ops: Operations(undoStack: nil))
                }
                shell.pendingSelection = .reading(gatheringID)
                if minted {
                    status.receipt(
                        "Restored the \u{201C}\(name)\u{201D} gathering — it shows everything "
                        + "tagged #\(SampleLibrarySeeder.classicsTagPath)."
                        + WelcomeDoorCopy.onTheShelfSuffix(shelf: arranged?.welcome.shelf.name))
                } else if let arranged, arranged.didAnything {
                    // U1b ladder round 1, MINOR-1 — the sibling's ruled
                    // voice (18i J33 + 13i-d U7): the gathering was only
                    // ADOPTED, but the arrangement this door composed just
                    // WROTE (Welcome made, a book shelved, Sherlock owned,
                    // notes tagged), so the door ACTED and a receipt says
                    // what — never a "did nothing" refusal over real writes.
                    status.receipt(WelcomeDoorCopy.alreadyWholeArranged(
                        book: name, shelf: arranged.welcome.shelf.name))
                } else {
                    status.refuse(
                        "A \u{201C}\(name)\u{201D} gathering is already on your Bookcase.")
                }
            } catch {
                Self.log.error("restore classics gathering failed: \(String(describing: error), privacy: .public)")
                status.refuse(
                    "Restoring the \u{201C}\(SampleLibraryWelcome.classicsGatheringName)\u{201D} "
                    + "gathering failed: " + SeededBookRestore.failureLine(for: error))
            }
        }
    }

    /// ONE road for every seeded book (pre-13x 5a generalized Sherlock's):
    /// mint what is missing, open the book, speak the outcome. The noun in
    /// the receipt is the book's ("stories" for Sherlock, "chapters" for the
    /// encryption book).
    private func restoreSeededBook(_ book: SampleLibrarySeeder.Book) {
        let noun = book == .sherlock ? "story" : "chapter"
        Task { @MainActor in
            do {
                // F2 (MINOR-8): the brain hoisted to `SeededBookRestore`
                // (Shared) — the phone's restore row and the tutorial door's
                // ensure ride the same road; this face composes the receipt.
                let restored = try await SeededBookRestore.restore(session: session, book: book)
                // 13i-d U7: every seeded-book restore composes the ONE Welcome
                // arrangement after it (Welcome adopted or minted; the seeded
                // books onto it if unshelved; the classics lesson put back
                // where missing) — the road an EXISTING store takes to it.
                let arranged = await Self.arrangeWelcome(session: session)
                switch restored {
                case .alreadyWhole(let bookID):
                    shell.pendingSelection = .reading(bookID)
                    // 18i ladder round 1, J33: nothing was minted, so this is
                    // a REFUSAL's voice and always shows — the same reading
                    // `SplitAtNewlinesCopy.acted` gives "already one
                    // paragraph", and the same split undo/redo already has.
                    // The shelf selection moving is navigation, not the act
                    // the sentence reports; the rule is NOT widened to cover
                    // it, because "or the shell moved" would reclassify the
                    // daily-entry note and blur every navigating door.
                    // 13i-d U7: …unless the arrangement WROTE something —
                    // then the door acted, and a receipt says what.
                    if let arranged, arranged.didAnything {
                        status.receipt(WelcomeDoorCopy.alreadyWholeArranged(
                            book: book.name, shelf: arranged.welcome.shelf.name))
                    } else {
                        status.refuse(
                            "\u{201C}\(book.name)\u{201D} is already whole — it's on your Bookcase.")
                    }
                case .restored(let readingID, let minted):
                    shell.pendingSelection = .reading(readingID)
                    status.receipt(
                        "Restored \u{201C}\(book.name)\u{201D} — "
                        + "\(minted) \(minted == 1 ? noun : noun + "s") came back."
                        + WelcomeDoorCopy.onTheShelfSuffix(shelf: arranged?.welcome.shelf.name))
                }
            } catch {
                // F3 (NIT-N6): the road's own words on the face; the raw
                // error in the log.
                Self.log.error("restore \(book.name, privacy: .public) failed: \(String(describing: error), privacy: .public)")
                status.refuse(
                    "Restoring \u{201C}\(book.name)\u{201D} failed: "
                    + SeededBookRestore.failureLine(for: error))
            }
        }
    }

    /// **13i-d U7 — the Welcome arrangement, as every restore door composes
    /// it** (`SampleLibraryWelcome.arrange` — the shared brain; the field
    /// guide named because it is the Mac's own seeded book). Furniture never
    /// breaks the door that carried it: a failure is LOGGED and answered nil,
    /// so the door's own receipt stands without the shelf clause.
    @discardableResult
    static func arrangeWelcome(session: AppSession) async -> SampleLibraryWelcome.Arrangement? {
        do {
            return try await SampleLibraryWelcome.arrange(
                session: session, guideName: TutorialSeeder.bookName)
        } catch {
            log.error("welcome arrangement failed: \(String(describing: error), privacy: .public)")
            return nil
        }
    }

    // (The tutorial door's silent ensure of *Encryption Explained* —
    // pre-13x F2/F3 — RETIRED at 13s-b U1b with the book's doors,
    // R-13s-37: the privacy chapter no longer points at the book, so the
    // door has no sentence to make true, and "not restorable" is her word.)

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
                guard let found = try await TutorialSeeder.findOrSeedReporting(
                    session: session,
                    confirmReplace: {
                        if let confirm { confirm() } else { await askToReplaceTutorial() }
                    })
                else {
                    // 13b 3F (Stage 2 round-2 note b): findOrSeed's one nil
                    // path is a DECLINED confirm — the user asked to OPEN
                    // and nothing opened; say why instead of going quiet.
                    status.refuse(
                        "Nothing opened — re-seeding the tutorial would replace the "
                        + "tutorial residue on this store, and you cancelled. Everything stays as it is.")
                    return
                }
                shell.pendingSelection = .reading(found.bookID)
                // 13i-d U7: when this door SEEDED the guide it took the
                // restore road, so the Welcome arrangement rides it (the
                // guide onto the Welcome shelf). An existing guide that
                // simply opened arranges nothing. (The *Encryption
                // Explained* ensure that ran here — pre-13x F2 — retired at
                // 13s-b U1b with the book's doors, R-13s-37.)
                if found.seeded { await Self.arrangeWelcome(session: session) }
            } catch {
                status.refuse("Opening the tutorial failed: \(OpsRefusalCopy.message(for: error))")
            }
        }
    }

    /// A12's dialog: it names what would be SET ASIDE and says where it
    /// goes. Plain words, exact scope — the tutorial confirm's shape.
    /// (Copy is static and pure so a pin can read it without a window.)
    nonisolated static func discardingUndoQuestion(
        _ warning: UndoStack.PendingUndoWarning
    ) -> String {
        // Round 2 batch 4 (mobile): the QUESTION is shared — the phone's
        // undo door asks the same one. The DETAIL below stays here because
        // its sentence names ⌘S, and a chord is a platform fact.
        StructuralUndoCopy.discardingUndoQuestion(warning)
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
    /// **The tutorial's replace confirm — 13u4 UNIT S3, KnownIssues row 67.**
    ///
    /// It was an app-modal `NSAlert.runModal()`: the ONE confirm in the app
    /// that did not use the SwiftUI `.alert` grammar its siblings use, and an
    /// app-modal AppKit alert swallows input in ways that cost a walk an hour
    /// (the WalkKit README's own new fact — the walker cannot answer it the
    /// way it answers every other confirm in this app).
    ///
    /// The act holds no view, which is why the alert lived here. So it ASKS
    /// the shell and the window presents — `pendingSelection`'s own shape and
    /// P-4's: the door names what it wants, the window decides what that
    /// means. The injectable `confirm:` seam above is untouched, so every
    /// pin that answers this question headlessly rides unmodified.
    private func askToReplaceTutorial() async -> Bool {
        await shell.ask(
            question: TutorialSeeder.replaceQuestion,
            detail: TutorialSeeder.replaceDetail,
            verb: "Replace", destructive: true)
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
            status.refuse(CapabilityRegistry.capability(.toggleStar).unavailableNote)
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
                status.refuse(OpsRefusalCopy.message(for: error))
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
                status.refuse("Seam toggle failed: \(error)")
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
        // pre-13u Act 10: the sample library's restore, typeable like the
        // tutorial's. (The Encryption Explained row left at 13s-b U1b —
        // R-13s-37: not restorable.)
        .restoreSampleLibrary,
        // 18l-c U6: the takemania book's restore, typeable like the others.
        .restoreJekyllBook,
        // 13s-b U1b (R-13s-37): the classics gathering's restore.
        .restoreClassicsGathering,
        // The Act 10 correction round (row 15): TAG NOTE, typeable — ⌘⇧I's
        // act (the fold it used to toggle retired with the masthead's second
        // door).
        .tagNote,
        // 13f batch 6 (W4): her ruling's "+ ⌘K by name" half.
        .toggleStar,
        // 13f batch 6 (W5): the quick note, typeable like every other door.
        .quickNote,
        // 13j J3 (sitting round 4): the lineage door, typeable — a palette is
        // summoned, not chrome, so it sits inside her not-daily-chrome
        // criterion (the architect's call at the sitting, hers to strike).
        .showOriginBlock,
        // The post-13l polish round: the Block History pane (ledger row 17)
        // and — the architect's adjudication 1 — the note's TRAY, whose ⌘K
        // row is what gives a book spread's inline note a way in at all.
        .showBlockHistory, .showNoteTray,
        // …and the note's own two time controls (ledger rows 16/23): saving a
        // whole moment, and the list of the moments it has.
        .saveNoteVersion, .showNoteVersions,
        // 13j J4/J4b (sitting round 4): the two ceremony doors, typeable —
        // her binding is "the Block menu, the block context menu, AND the
        // ⌘K palette; never only a buried item".
        .divideWithCeremony, .mergeWithCeremony,
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
        case .divideWithCeremony: return { dispatch(.structural(.divideWithCeremony)) }
        case .mergeWithCeremony: return { dispatch(.structural(.mergeWithCeremony)) }
        case .addBlockAtEnd: return { dispatch(.addBlockAtEnd) }
        case .insertBlockBelow: return { dispatch(.insertBlockBelow) }
        case .deleteBlock: return { dispatch(.deleteBlock) }
        case .showTakes: return { dispatch(.takes(.toggleFan)) }
        case .newTake: return { dispatch(.takes(.branch)) }
        case .blankTake: return { dispatch(.takes(.blank)) }
        case .chooseTake: return { dispatch(.takes(.choose)) }
        case .saveChoicesAsLens: return { dispatch(.takes(.saveLens)) }
        case .toggleSeams: return { toggleSeams() }
        case .tagNote: return { tagNote() }
        case .toggleStar: return { toggleStarForCurrent() }
        case .quickNote: return { shell.quickNoteRequested = true }
        case .showOriginBlock: return { dispatch(.showOriginBlock) }
        case .showBlockHistory: return { showBlockHistory() }
        case .showNoteTray: return { dispatch(.showNoteTray) }
        case .saveNoteVersion: return { saveNoteVersion() }
        case .showNoteVersions: return { dispatch(.showNoteVersions) }
        case .restoreTutorial: return { restoreTutorial() }
        case .restoreSampleLibrary: return { restoreSampleLibrary() }
        case .restoreJekyllBook: return { restoreJekyllBook() }
        case .restoreClassicsGathering: return { restoreClassicsGathering() }
        default:
            // NIT-1 (Stage 1 ladder): a future `paletteActs` entry without
            // a wired case must never compile into a silent no-op row —
            // loud in DEBUG, an honest sentence in release.
            let status = self.status
            return {
                assertionFailure("palette act \(id) has no wired action")
                status.refuse("That command isn't wired to the palette yet.")
            }
        }
    }
}

// MARK: - 13i-d U7 — the restore doors' Welcome words

/// What the restore doors SAY about the Welcome arrangement they composed
/// (PROVISIONAL wording, 13s-revoicable). The shelf is named by its REAL
/// name — she may have renamed Welcome, and the receipt must stay true.
/// Pure, so a pin reads the sentences without a window.
enum WelcomeDoorCopy {
    /// Help ▸ Restore Tutorial's receipt: where the fresh guide now sits.
    static func tutorialRestored(guide: String, shelf: String?) -> String {
        guard let shelf else {
            return "The tutorial is fresh \u{2014} \u{201C}\(guide)\u{201D} is on your Bookcase."
        }
        return "The tutorial is fresh \u{2014} \u{201C}\(guide)\u{201D} is on your Bookcase, "
            + "on the \u{201C}\(shelf)\u{201D} shelf."
    }

    /// A seeded book that was already whole, when the arrangement still WROTE
    /// something (Welcome made, a book shelved, Sherlock owned, the classics
    /// gathering or the seeded quick note put back) — a receipt, not a refusal.
    static func alreadyWholeArranged(book: String, shelf: String) -> String {
        "\u{201C}\(book)\u{201D} is already whole \u{2014} and the \u{201C}\(shelf)\u{201D} "
            + "shelf is set up again."
    }

    /// The tail a "Restored …" receipt gains: where the book now sits.
    static func onTheShelfSuffix(shelf: String?) -> String {
        guard let shelf else { return "" }
        return " It's on the \u{201C}\(shelf)\u{201D} shelf."
    }
}
