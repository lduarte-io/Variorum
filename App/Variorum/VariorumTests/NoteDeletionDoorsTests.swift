//
//  NoteDeletionDoorsTests.swift
//  VariorumTests
//
//  **THE NOTE-DELETION DOOR SET** (13l Act 2, ledger item 3). Her report at
//  13j's close — *"how do i even delete a note? I'm within a note I want to
//  delete right now and I don't see how to delete it"* — and the ruling it
//  became: *"include delete note in the note menu with confirmation, … add a
//  confirmation for the library door of deletion, and … allow for command
//  clicking to select multiple items and deleting all of them."*
//
//  What is asserted, and which half is new behaviour vs a fixed defect:
//
//  · **The door exists at all** — NEW. `.deleteNote` had no declaration, no
//    id and no renderer; every pin here about the `note ▾` menu is red on the
//    pre-13l tree by construction (the case would not compile).
//  · **The Library's door asks first** — a FIXED DEFECT. It shipped as a bare
//    `Button("Delete", role: .destructive)` straight into `deleteContainer`:
//    one click, a whole note with its blocks, takes, tags and memberships
//    tombstoned, and nothing said where it went.
//  · **Every pane and window leaves** — a FIXED DEFECT, and the sharper one.
//    Nothing anywhere reacted to a note being deleted, so a pane showing it
//    kept its detail mounted over a tombstone and the Open strip kept a row
//    that ⌘⇧n would happily re-open.
//
//  **The confirm pins press the REAL alert's REAL button**, mounting the
//  SHIPPING modifier — seat 1's standard from `TrashConfirmEdgeTests`, and
//  for its reason: the item-2 defect was a dead confirm→act edge that every
//  view-model-level pin in the repo stayed green over.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The declarations (P-1's walk, at this act's own doors)

@MainActor
@Suite("The note-deletion doors are declared where they are rendered (13l item 3)")
struct NoteDeletionDeclarationTests {
    /// The door she went looking for, in both bars — R118's letter (Write is
    /// never the privileged surface) and R6-2's one `note ▾` grammar.
    @Test func deleteNoteIsDeclaredOnceAndRenderedByEveryBarAndRowList() {
        let capability = CapabilityRegistry.capability(.deleteNote)
        // 13i-d U7 rider (F-U6-4), a JUSTIFIED EDIT: the Archived view's inline
        // Delete Note… is a third renderer, declared on the `.surface` door.
        #expect(capability.doors == [.bottomBar, .contextMenu, .surface])
        #expect(ArchivedView.surfaceCapabilities.contains(.deleteNote))
        #expect(capability.scope == .post)
        #expect(capability.takesAccess == .native)
        #expect(capability.verb == RecoveryCopy.deleteNoteTitle)
        #expect(CommitBar.renderedCapabilities.contains(.deleteNote))
        #expect(TakesBottomBar.renderedCapabilities.contains(.deleteNote))
        #expect(SidebarView.contextMenuCapabilities.contains(.deleteNote))
    }

    /// The bulk twin's shape: a `.surface` act on the Library's own list, the
    /// `.deleteNow` precedent — its per-gesture condition (a selection exists)
    /// is the surface's, because the selection is that list's own state.
    @Test func deleteSelectedNotesIsASurfaceActOnTheLibrarysList() {
        let capability = CapabilityRegistry.capability(.deleteSelectedNotes)
        #expect(capability.doors == [.surface])
        #expect(capability.scope == .app)
        #expect(LibraryCatalogView.surfaceCapabilities.contains(.deleteSelectedNotes))
        // Reachable everywhere the registry looks, exactly like the purge
        // doors — the greying is the list's, not a context rule's.
        #expect(capability.availability(CapabilityContext()) == .act)
    }

    /// **The round-3 rider, pinned where it can be broken:** Delete Now never
    /// appears in a note context. Its only legal renderer is the Trash, and
    /// the note-scoped door sets must never name it.
    @Test func noPurgeDoorLeaksIntoTheNoteDeletionDoorSet() {
        for purge in [CapabilityID.deleteNow, .emptyTrash] {
            #expect(!CommitBar.renderedCapabilities.contains(purge))
            #expect(!TakesBottomBar.renderedCapabilities.contains(purge))
            #expect(!SidebarView.contextMenuCapabilities.contains(purge))
            #expect(!LibraryCatalogView.surfaceCapabilities.contains(purge))
        }
    }

    /// **The confirmation-consistency principle, as an assertion rather than
    /// only a comment** (§8's last bullet, written at the registry's deletion
    /// acts): notes confirm, blocks and takes do not, and the two purge doors
    /// always do. The middle clause is the one worth a pin — a future session
    /// adding a confirm to `.deleteBlock` would be undoing J9, whose whole
    /// point was to unfriction paragraph deletion.
    @Test func theBlockAndTakeDeletionActsCarryNoConfirmVocabulary() {
        // No block/take-scoped deletion act names a confirmation anywhere in
        // its declaration: their honest notes point at recovery, never at a
        // question.
        for id in [CapabilityID.deleteBlock, .deleteSelectedBlocks, .archiveTake] {
            let note = CapabilityRegistry.capability(id).unavailableNote
            #expect(!note.lowercased().contains("are you sure"))
        }
        // …and the note doors DO carry one, naming the Trash and its clock.
        #expect(RecoveryCopy.deleteNoteConfirmDetail.contains(RecoveryCopy.trashSection))
        #expect(RecoveryCopy.deleteNoteConfirmDetail.contains("\(TrashWindow.days) days"))
    }

    /// One vocabulary, both platforms (MobileSoul §3). The phone owned these
    /// three words and the Mac could not import them; they are shared now and
    /// the phone forwards.
    @Test func theDeleteNoteWordsAreTheSharedOnes() {
        #expect(RecoveryCopy.deleteNoteTitle == "Delete Note\u{2026}")
        #expect(RecoveryCopy.deleteNoteConfirmDetail
            == RecoveryCopy.moveToTrashDetail(.note))
        // The plural forms her ruling asked for.
        #expect(RecoveryCopy.deleteNotesConfirmTitle(5) == "Delete 5 notes?")
        #expect(RecoveryCopy.deleteNotesConfirmTitle(1)
            == RecoveryCopy.deleteNoteConfirmTitle,
                "one note is asked in the singular, not 'Delete 1 notes?'")
        #expect(RecoveryCopy.deleteNotesConfirmDetail(5).contains("The 5 notes"))
        #expect(RecoveryCopy.movedToTrashReceipt(notes: 5)
            == "5 notes moved to the Trash — 30 days to put them back.")
        #expect(RecoveryCopy.movedToTrashReceipt(notes: 1)
            == RecoveryCopy.movedToTrashReceipt(.note))
    }

    /// **ONE NOUN FOR ONE ROAD** (the post-13l polish round, ledger row 5 —
    /// her A5 ruling on the 13l walk's P-9: *"should be fixed"*).
    ///
    /// The shipped confirm read *"The note goes to the **Trash** for 30 days.
    /// You can put it back from **Archived & Deleted** until then."* Both
    /// names were real — the Trash IS a section inside that surface — so
    /// nothing was false; what it asked was that the reader hold two nouns
    /// for one road, in the sentence she reads while deciding whether to
    /// delete her writing. The place is named once now and the second clause
    /// points back at it ("from there").
    ///
    /// The pin covers every member of the family, not just the note's, so a
    /// future sentence cannot re-introduce the shape one kind at a time.
    @Test func theMoveToTrashConfirmsNameTheRoadExactlyOnce() {
        for detail in [
            RecoveryCopy.deleteNoteConfirmDetail,
            RecoveryCopy.deleteNotesConfirmDetail(5),
            RecoveryCopy.moveToTrashDetail(.block),
            RecoveryCopy.moveToTrashDetail(.book),
            RecoveryCopy.moveToTrashDetail(.take),
        ] {
            #expect(detail.contains(RecoveryCopy.trashSection),
                    "the road is named: \(detail)")
            #expect(!detail.contains(RecoveryCopy.surfaceName),
                    "one road, ONE noun: \(detail)")
        }
    }
}

// MARK: - The act

@MainActor
@Suite("Deleting a note: the act, the receipt, the flush (13l item 3)")
struct NoteDeletionActTests {
    @Test func deletingANoteTombstonesItAndSaysWhereItWent() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let receipt = try await NoteDeletion.run(
                session: editor.session, postIDs: [editor.postID])
            #expect(receipt == RecoveryCopy.movedToTrashReceipt(.note))
            #expect(receipt.contains(RecoveryCopy.trashSection))
            #expect(receipt.contains("\(TrashWindow.days) days"),
                    "the receipt names the clock, so the road back is readable")
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(rows.contains { $0.kind == .note && $0.id == editor.postID })
        }
    }

    /// **FLUSH FIRST, and it is not tidiness.** `deleteContainer` cascades to
    /// the note's blocks and their takes; keystrokes still inside the autosave
    /// debounce would be tombstoned along with the row they never reached, so
    /// Put back would return the note WITHOUT the sentence she typed last.
    ///
    /// **Red on old** (behavioural revert): drop the `flushNow` loop from
    /// `NoteDeletion.run` and the restored text is the pre-typing one.
    @Test func aDirtyBufferLandsBeforeTheTombstoneSoPutBackReturnsIt() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            editor.type(" And the last thought.", at: 10)
            #expect(editor.model.autosave.isDirty, "the debounce has not fired")

            _ = try await NoteDeletion.run(
                session: editor.session, postIDs: [editor.postID])
            try await editor.session.runner.run { (ops: Operations) in
                try ops.restoreContainer(editor.postID)
            }
            #expect(try editor.storeSlots().map(\.text)
                == ["Alpha one. And the last thought."],
                    "the keystrokes rode into the row before it was tombstoned")
        }
    }

    /// **…AND IT FLUSHES WITHOUT MINTING** (13l, the end-of-phase ladder's
    /// LR-MINOR-2 — the L-d growth class, reintroduced one act later by the
    /// doors most likely to name a never-opened note).
    ///
    /// Traced: `autosave(forPost:)` MINTS on a miss — a `Hold` with
    /// `holders: 1` and, on the Mac, a `quitFinalize` closure. `NoteDeletion`
    /// never releases (it cannot: the note is gone), so every deleted Library
    /// row left a permanent entry for `flushEveryOpenPost` to walk and a quit
    /// closure for a tombstone. Fifty rows under ⌘-click multi-select, fifty
    /// of each. The flush itself bought nothing there: a post no surface has
    /// opened has nothing pending, by construction.
    ///
    /// **Red on old** (behavioural revert): restore
    /// `await session.autosave(forPost: id).flushNow()` and both counts move
    /// by three.
    @Test func deletingANeverOpenedNoteMintsNothing() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let entriesBefore = editor.session.openAutosaveCount
            let quitBefore = editor.session.quitFinalize.count

            // Three notes this session has never opened — the Library-row
            // case, and the multi-select case.
            let strangers = try await editor.session.runner.run {
                (ops: Operations) -> [String] in
                try (0..<3).map { try ops.createPost(title: "row \($0)").id }
            }
            let receipt = try await NoteDeletion.run(
                session: editor.session, postIDs: strangers)
            #expect(receipt == RecoveryCopy.movedToTrashReceipt(notes: 3),
                    "they really were deleted — the pin is about the cost, not a no-op")

            #expect(editor.session.openAutosaveCount == entriesBefore,
                    "no coordinator was minted for a note nothing ever opened")
            #expect(editor.session.quitFinalize.count == quitBefore,
                    "and no ⌘Q closure was left behind for a tombstone")
        }
    }

    /// The double-press and the racing-second-window: a note already gone is
    /// SKIPPED, never fatal, and the receipt counts what actually went.
    @Test func aNoteThatIsAlreadyGoneIsSkippedRatherThanRefusingTheWholeGesture()
        async throws
    {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let (live, dead) = try await editor.session.runner.run {
                (ops: Operations) -> (String, String) in
                let live = try ops.createPost(title: "still here")
                let dead = try ops.createPost(title: "gone elsewhere")
                try ops.deleteContainer(dead.id)
                return (live.id, dead.id)
            }
            let receipt = try await NoteDeletion.run(
                session: editor.session, postIDs: [dead, live])
            #expect(receipt == RecoveryCopy.movedToTrashReceipt(notes: 1),
                    "one really went, and the receipt says one")
            let liveHeader: Queries.ContainerHeader? = try await editor.database.read { db in
                try Queries.containerHeader(db, containerID: live)
            }
            #expect(liveHeader == nil, "the live one is tombstoned")

            // …and a gesture where EVERY row had already gone says so instead
            // of claiming a deletion.
            let nothing = try await NoteDeletion.run(
                session: editor.session, postIDs: [dead])
            #expect(nothing == RecoveryCopy.notesAlreadyGone(1))
        }
    }

    /// **NO UNDO ENTRY — 13j's doctrine, pinned so a future session sees it
    /// is a ruling rather than a gap.** The Trash is the recovery door for a
    /// note; whether `deleteContainer` should be undoable at all is a product
    /// call and it is the author's (the standing KnownIssues row).
    @Test func deletingNotesRegistersNothingOnTheStructuralStack() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            #expect(editor.session.undoStack.topLabel == nil)
            _ = try await NoteDeletion.run(
                session: editor.session, postIDs: [editor.postID])
            #expect(editor.session.undoStack.topLabel == nil,
                    "the Trash is the road back, not ⌥⌘Z")
        }
    }

    /// The bulk gesture: ONE receipt naming the count (her ruling's letter),
    /// and every named note in the Trash.
    @Test func deletingSeveralNotesReceiptsOnceAndNamesTheCount() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let ids = try await editor.session.runner.run {
                (ops: Operations) -> [String] in
                try (0..<3).map { try ops.createPost(title: "note \($0)").id }
            }
            let receipt = try await NoteDeletion.run(session: editor.session, postIDs: ids)
            #expect(receipt == RecoveryCopy.movedToTrashReceipt(notes: 3))
            #expect(receipt.contains("3 notes"))
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(Set(rows.filter { $0.kind == .note }.map(\.id)) == Set(ids))
        }
    }

    /// A sealed note deletes — AppSpec §9's letter (the seal is content-level:
    /// a sealed note "may still be … deleted (recoverable via
    /// restoreContainer)"). Pinned because a future guard here would look like
    /// tidiness and would be a product change.
    /// **THE SCRAPS AREA IS NOT A NOTE** (13l Act 7 — the 8d walk's find, and
    /// the worst thing it found).
    ///
    /// The walk fired this act from the scraps editor's own `note ▾` menu —
    /// `CommitBar` hands it `model.postID`, which for that pane is the POOL's
    /// id — confirmed the promise (*"The note goes to the Trash for 30 days.
    /// You can put it back from Archived & Deleted until then"*), and watched
    /// the container tombstone with the receipt *"Note moved to the Trash — 30
    /// days to put it back."* Then: `Queries.trash`'s note arm is fenced to
    /// `kind = 'post'` so no row appeared; the pool's 29 blocks were cascade
    /// victims, which that listing deliberately never shows; and nothing in
    /// either app calls `restoreContainer` on a pool. The Snippets surface
    /// simply went from 30 scraps to 2.
    ///
    /// This pin holds the fence AND the invariant Act 2's own
    /// `noDoorPutsAPoolContainerInTheTrash` asserted — an invariant that was
    /// TRUE when it was written and that item 3 of the same batch silently
    /// invalidated by giving four new doors a road to `deleteContainer`.
    ///
    /// **Red on old** (behavioural revert): delete the kind fence from
    /// `NoteDeletion.run` and the pool tombstones, exactly as the walk saw.
    @Test func theScrapsAreaCannotBeDeletedThroughTheNoteDoor() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let pool = try editor.session.operations.createPool(title: "scraps")
            let receipt = try await NoteDeletion.run(
                session: editor.session, postIDs: [pool.id])
            #expect(receipt == RecoveryCopy.notADeletableNote)
            // **Her #77(a) ruling** (the post-13l polish round, ledger row
            // 32): the refusal NAMES THE ROAD instead of only refusing. A
            // JUSTIFIED, STRENGTHENING edit to a shipped pin — the claim it
            // held (this door cannot tombstone the pool) is untouched and
            // asserted above; what is added is the property her ruling asks
            // for, which the constant alone could not carry.
            #expect(receipt.contains("delete the scraps themselves"),
                    "a refusal with no next step leaves her nowhere: \(receipt)")
            #expect(!receipt.contains("can't go to the Trash"),
                    "the refusal-only shape is retired")
            let state = try await editor.database.read { db in
                (live: try Queries.containerHeader(db, containerID: pool.id) != nil,
                 trash: try Queries.trash(db, now: harnessNow).map(\.id))
            }
            #expect(state.live, "the scraps area stays — it has no road back")
            #expect(!state.trash.contains(pool.id),
                    "and the Trash could not have listed it anyway")

            // A MIXED pick deletes the notes and leaves the pool standing:
            // one bad id must not cost her the gesture.
            let mixed = try await NoteDeletion.run(
                session: editor.session, postIDs: [pool.id, editor.postID])
            #expect(mixed == RecoveryCopy.movedToTrashReceipt(notes: 1))
            let after = try await editor.database.read { db in
                try Queries.containerHeader(db, containerID: pool.id) != nil
            }
            #expect(after)
        }
    }

    @Test func aSealedNoteStillDeletes() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            try await editor.session.runner.run { [postID = editor.postID] ops in
                try ops.lockPost(postID)
            }
            let receipt = try await NoteDeletion.run(
                session: editor.session, postIDs: [editor.postID])
            #expect(receipt == RecoveryCopy.movedToTrashReceipt(.note))
        }
    }
}

// MARK: - The navigate-away

@MainActor
@Suite("A deleted note leaves every pane and the Open strip (13l item 3)")
struct NoteDeletionNavigateAwayTests {
    /// **Her ruling's letter:** *"navigate-away covers EVERY pane/window
    /// showing the note."*
    ///
    /// **Red on old** (behavioural revert): remove the `notesDeleted` call
    /// from `RootView`'s listener — or the listener itself — and both panes
    /// stay pointed at the tombstoned note while the strip keeps its row.
    @Test func everyPaneShowingADeletedNoteLeavesAndTheStripForgetsIt() {
        let workspace = WorkspaceModel()
        workspace.select(.post("doomed"))
        workspace.openBeside(.post("survivor"))
        #expect(workspace.panes.count == 2)
        #expect(workspace.openNotes.ids.contains("doomed"))

        workspace.notesDeleted(["doomed"])

        #expect(!workspace.panes.contains { workspace.selections[$0] == .post("doomed") },
                "no pane is left standing on the tombstone")
        #expect(workspace.panes.contains { workspace.selections[$0] == .post("survivor") },
                "and the other pane is untouched")
        #expect(!workspace.openNotes.ids.contains("doomed"),
                "the Open row goes too — otherwise ⌘⇧n re-opens a tombstone")
        #expect(workspace.selections[.primary] == .library,
                "it lands in the room that holds the Trash's door")
    }

    /// BOTH panes leave when a multi-delete names both — the case a
    /// history-walk landing would have got wrong (back from one deleted note
    /// is frequently the other one).
    @Test func aMultiDeleteEmptiesBothPanesRatherThanWalkingBackIntoATombstone() {
        let workspace = WorkspaceModel()
        workspace.select(.post("a"))
        workspace.openBeside(.post("b"))
        workspace.notesDeleted(["a", "b"])
        for pane in workspace.panes {
            #expect(workspace.selections[pane] == .library)
        }
        #expect(workspace.openNotes.ids.isEmpty)
    }

    /// **VX-246's ruling 2 (the orchestrator's, provisional under her
    /// overnight delegation): A NAVIGATE-AWAY NEVER TAKES HER FOCUS.** She
    /// types in pane 1; the note open in pane 2 is deleted (a client's
    /// `delete_note` on the wire, or her own Delete from pane 1). Pane 2
    /// leaves the tombstone for the Library IN PLACE. Her focus, and the one
    /// live surface `PaneMount` gives the focused pane, stay in pane 1, and no
    /// focused-subject change is announced, because nothing she is looking at
    /// changed.
    ///
    /// **RED on old:** `notesDeleted` went through `select(.library, in:)`,
    /// which also wrote `focusedPane = pane` (`WorkspaceModel.select`). So the
    /// focus jumped to pane 2 and her note dropped to the read tier (U3 STAGE
    /// RUN's finding A, live).
    ///
    /// The second arm is unchanged by the ruling ("only a pane that is itself
    /// focused stays focused, as now"): the FOCUSED pane on a dead note lands
    /// on the Library, keeps the focus, and announces its new subject once.
    @Test func aNavigateAwayNeverTakesHerFocus() throws {
        let workspace = WorkspaceModel()
        var announced: [SidebarSelection?] = []
        workspace.onFocusedSubjectChanged = { announced.append($0) }
        workspace.select(.post("hers"))
        workspace.openBeside(.post("doomed"))
        workspace.focus(.primary)
        let other = try #require(workspace.panes.first { $0 != .primary })
        #expect(workspace.focusedPane == .primary, "premise: her caret's pane is focused")
        #expect(workspace.selections[other] == .post("doomed"), "premise: the other pane shows the doomed note")
        announced.removeAll()

        #expect(workspace.notesDeleted(["doomed"]))

        #expect(workspace.focusedPane == .primary,
                "the focus stays where she is — the navigate-away never takes it")
        #expect(workspace.selections[.primary] == .post("hers"), "her pane still shows her note")
        #expect(workspace.selections[other] == .library,
                "the pane that showed the tombstone went to the Library, in place")
        #expect(announced.isEmpty,
                "no focused-subject change is announced: what she looks at did not change (\(announced))")

        // As now: the focused pane itself on a dead note.
        #expect(workspace.notesDeleted(["hers"]))
        #expect(workspace.focusedPane == .primary, "a focused pane on a dead note keeps the focus")
        #expect(workspace.selections[.primary] == .library)
        #expect(announced == [.library], "and its new subject is announced once (\(announced))")
    }

    /// A window showing none of them is inert — the signal reaches every
    /// window, so "does nothing here" has to be true, not merely likely.
    @Test func aWindowShowingNoneOfThemIsUntouched() {
        let workspace = WorkspaceModel()
        workspace.select(.post("mine"))
        #expect(workspace.notesDeleted(["someone-elses"]) == false)
        #expect(workspace.selections[.primary] == .post("mine"))
        #expect(workspace.openNotes.ids == ["mine"])
    }

    /// The act POSTS the signal, which is what makes the two halves above
    /// reachable from a door at all.
    @Test func theActAnnouncesWhatItDeleted() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let heard = LockIsolated<[String]>([])
            let token = NotificationCenter.default.addObserver(
                forName: .variorumNotesDeleted, object: nil, queue: .main
            ) { note in
                heard.withValue { $0 = (note.userInfo?["postIDs"] as? [String]) ?? [] }
            }
            defer { NotificationCenter.default.removeObserver(token) }
            _ = try await NoteDeletion.run(
                session: editor.session, postIDs: [editor.postID])
            #expect(heard.value == [editor.postID])
        }
    }
}

// MARK: - The confirm, through the real dialog

/// **THE CONFIRM PRESSES THE REAL BUTTON** — seat 1's technique from
/// `TrashConfirmEdgeTests`, over this act's own host. Mounting the SHIPPING
/// modifier is the point: a pin over `NoteDeletion.run` alone would have
/// stayed green over exactly the defect item 2 found one file away, where a
/// perfectly good act was never reached because the dialog's dismissal beat
/// its action's continuation.
@MainActor
@Suite("The note-delete confirm's real button (13l item 3)", .serialized)
struct NoteDeleteConfirmEdgeTests {
    /// The shipping modifier over state the test owns, in a `List` row —
    /// where `LibraryCatalogView` applies it.
    private struct Host: View {
        @Binding var pending: NoteDeleteConfirm?
        let onConfirm: (NoteDeleteConfirm) -> Void

        var body: some View {
            List {
                Section("Library") {
                    HStack { Text("rows") }
                        .deleteNoteConfirmDialog($pending, onConfirm: onConfirm)
                }
            }
            .frame(width: 480, height: 320)
        }
    }

    /// A tiny observable box so the SwiftUI binding and the test share state.
    @Observable
    final class Box {
        var pending: NoteDeleteConfirm?
    }

    private func pump(_ seconds: TimeInterval = 0.3) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private static func buttons(in view: NSView?) -> [NSButton] {
        guard let view else { return [] }
        var found: [NSButton] = []
        if let button = view as? NSButton { found.append(button) }
        for sub in view.subviews { found.append(contentsOf: buttons(in: sub)) }
        return found
    }

    /// Raises the ask, presses the REAL button with `title`, and lets the
    /// handler run. Returns the dialog's own title where one presented — nil
    /// when none did, which is itself a finding.
    private func press(
        _ title: String, ask: NoteDeleteConfirm,
        onConfirm: @escaping @Sendable ([String]) -> Void
    ) async -> String? {
        let box = Box()
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 520, height: 380),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        @Bindable var bindable = box
        window.contentView = NSHostingView(
            rootView: Host(
                pending: $bindable.pending,
                onConfirm: { onConfirm($0.postIDs) }))
        window.orderFrontRegardless()
        pump(0.4)
        for _ in 0..<20 { await Task.yield() }

        box.pending = ask
        pump(0.4)
        for _ in 0..<20 { await Task.yield() }
        pump(0.2)

        guard let sheet = window.attachedSheet else { return nil }
        let shown = sheet.title
        guard let button = Self.buttons(in: sheet.contentView)
            .first(where: { $0.title == title })
        else { return nil }
        button.performClick(nil)
        pump(0.3)
        for _ in 0..<40 { await Task.yield() }
        return shown.isEmpty ? ask.title : shown
    }

    @Test func pressingDeleteInTheRealDialogRunsTheDeletion() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let fired = LockIsolated<[String]>([])
            let presented = await press(
                "Delete", ask: NoteDeleteConfirm(postIDs: [editor.postID])
            ) { picked in
                fired.withValue { $0 = picked }
            }
            #expect(presented != nil, "the confirm must present — her ruling's first half")
            #expect(fired.value == [editor.postID],
                    "and the press must reach the act (the item-2 edge, one act over)")
        }
    }

    /// Cancel is the other half of the same edge, and the guard against a
    /// hollow pin: it must write nothing at all.
    @Test func pressingCancelInTheRealDialogDeletesNothing() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let fired = LockIsolated(false)
            let presented = await press(
                "Cancel", ask: NoteDeleteConfirm(postIDs: [editor.postID])
            ) { _ in fired.setValue(true) }
            #expect(presented != nil)
            #expect(fired.value == false)
            let header: Queries.ContainerHeader? = try await editor.database.read { db in
                try Queries.containerHeader(db, containerID: editor.postID)
            }
            #expect(header != nil, "the note is untouched")
        }
    }

    /// **The bulk ask is ONE ask** (her ruling): the whole pick rides into
    /// the handler as a single confirm carrying every id.
    @Test func theBulkAskCarriesEveryPickedNoteInOnePress() async throws {
        let ids = ["n1", "n2", "n3", "n4", "n5"]
        let fired = LockIsolated<[String]>([])
        let presented = await press("Delete", ask: NoteDeleteConfirm(postIDs: ids)) {
            picked in fired.withValue { $0 = picked }
        }
        #expect(presented != nil)
        #expect(fired.value == ids, "one press, one gesture, every note")
    }
}
