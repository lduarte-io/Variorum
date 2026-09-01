//
//  TrayPanelMoveTests.swift
//  VariorumTests
//
//  **THE POST-13L POLISH ROUND, BATCH 3** — ledger rows 9 (C1) and 20 (G5).
//
//  Her C1 ruling, verbatim: *"the note tray should move to being an icon next
//  to the scraps and reference icon and open in the side bar, with preserved
//  originals separated from deleted… if it opened in a pane to the right, it
//  would have the space to let you scroll through them at a more reasonable
//  size and would keep the top bar from being crowded."*
//
//  Her G5 ruling, verbatim: *"the tray of a note should have an honest trash
//  section with everything being deleted, so it's never a surprise — and
//  takes can be shown in that per note trash, albeit maybe not shown by
//  default, so you can always see a list of what will be deleted"* — with the
//  fourth-sitting addition that those take rows carry a **Delete Now** *"to
//  keep the capability"*.
//
//  The door move's pins DRIVE THE REAL SURFACE (the 13l lesson): the mounted
//  `PostDetailView`, the real `CommandRouter` seam, the real acts.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The tray moves to the side panel (post-13l polish round, C1/G5)", .serialized)
struct TrayPanelMoveTests {
    // MARK: - Row 9: the door, declared and rendered

    /// **ONE act, THREE doors, all of them `.surface`** — and the bars have
    /// none. Her ruling moved the named door to the masthead icon and said
    /// *"the note ▾ menu item and ⌫ badge choreography follow the move"*.
    @Test func theTrayIsDeclaredWithSurfaceDoorsOnlyAndTheBarsLostTheirItem() {
        let act = CapabilityRegistry.capability(.showNoteTray)
        // **A JUSTIFIED EDIT** (the architect's adjudication 1, batch 4): ⌘K
        // joins the surfaces. The claim this pin was written for is the one
        // it still makes — the `note ▾` item is GONE and neither bar carries
        // it (asserted below) — and the palette row exists for the ONE place
        // batch 3 recorded as the move's cost: a book spread's inline note,
        // which mounts an editor with no masthead and no context bar.
        #expect(act.doors == [.surface, .palette],
                "the `note ▾` item is gone; the icon is the named door, ⌘K the fallback")
        #expect(ShellActions.paletteActs.contains(.showNoteTray))
        #expect(act.verb == TrayPath.menuLabel)
        #expect(act.takesAccess == .native, "R118: not a Write privilege")
        // The three renderers, each naming it for itself (P-1's walk unions
        // them; these are the claims the walk cannot make about WHICH).
        #expect(PostDetailView.surfaceCapabilities.contains(.showNoteTray),
                "the masthead icon — the NAMED door")
        #expect(ContextBar.surfaceCapabilities.contains(.showNoteTray),
                "the ⌫ badge — the glance, opening the same panel")
        #expect(PoolDetailView.surfaceCapabilities.contains(.showNoteTray),
                "the scraps area's own tray")
        #expect(!CommitBar.renderedCapabilities.contains(.showNoteTray))
        #expect(!TakesBottomBar.renderedCapabilities.contains(.showNoteTray))
    }

    /// The icon sits WITH scraps and references — her words — and the table
    /// the masthead iterates is the render source, so this is a claim about
    /// what she sees rather than about a comment.
    @Test func theMastheadCarriesTheTrayIconBesideScrapsAndReferences() {
        let doors = PostDetailView.inspectorDoors
        #expect(doors.map(\.panel) == [
            .tray(revealBlockID: nil), .scraps, .references,
        ])
        let tray = try? #require(doors.first)
        #expect(tray?.title == TrayPath.menuLabel)
        #expect(tray?.symbol == "tray")
        #expect(doors.allSatisfy { !$0.help.isEmpty }, "every icon says what it opens")
    }

    /// **WALK-DRIVEN: the real mounted detail opens the real panel.**
    ///
    /// The detail registers a tray seam with the router on appear, so the
    /// badge (which lives ABOVE the detail, on the pane's context bar) and
    /// every other door reach ONE panel by composition — never a broadcast
    /// (P-4), and never the handler stack, whose LIFO order would hand the
    /// request to the editor's own sheet instead.
    @Test func theMountedDetailOpensTheTrayInItsRealSidePanel() async throws {
        try await mounted { session, post, window, hosting in
            #expect(session.commandRouter.activePostID == post,
                    "the detail registered")
            // At rest the detail is the page and nothing else: no inspector
            // column. (The signal is the REAL view tree — SwiftUI's
            // inspector mounts a pane hosted under `InspectorStyleContext`.
            // AppKit's accessibility tree is not populated in a headless
            // test host, so the class names are the honest evidence
            // available here. The panel's INTERIOR stopped being a `List`
            // at Act 10 item 1 — the calm-card scroll rebuild — so the old
            // OutlineList/ListTableHeaderView anchors are gone WITH the
            // clipping mechanism they belonged to; the panel's own
            // composition is `TrayPanelShapeTests`' pin now, over a seeded
            // store.)
            let atRest = Self.classNames(hosting)
            #expect(!atRest.contains { $0.contains("InspectorStyleContext") },
                    "the side panel is not on screen at rest")
            #expect(atRest.contains("EditorTextView"), "the page itself IS mounted")

            #expect(session.commandRouter.requestNoteTray(TrayRequest(postID: post)),
                    "the seam is registered — the request ACTED (P-2)")
            await Self.settle(window, hosting) {
                Self.classNames(hosting).contains { $0.contains("InspectorStyleContext") }
            }
            let open = Self.classNames(hosting)
            #expect(open.contains { $0.contains("InspectorStyleContext") },
                    "the inspector column really opened — her \"pane to the right\"")
            #expect(open.contains("EditorTextView"),
                    "beside the page, never instead of it (it is a panel, not a sheet)")
        }
    }

    /// A request for a post that is NOT mounted is refused rather than lost:
    /// the router says no, and the caller's own fallback (a bar's sheet)
    /// takes it. The badge is the one caller that parks instead, because it
    /// has just focused a pane and knows a detail is arriving.
    @Test func aTrayRequestForAnUnmountedPostIsRefusedAndCanBeParked() async throws {
        try await mounted { session, post, _, _ in
            let router = session.commandRouter
            #expect(!router.requestNoteTray(TrayRequest(postID: "some-other-note")),
                    "a stale target never opens a panel on the wrong note")
            #expect(router.pendingTrayRequest == nil,
                    "and it does not park itself — the caller decides")
            // The badge's road: park, and the ARRIVING detail consumes it.
            router.pendingTrayRequest = TrayRequest(postID: post)
            let token = router.registerDetail(
                postID: post, mode: .write, applyMode: { _ in },
                showTray: { _ in })
            #expect(router.pendingTrayRequest == nil, "consumed on arrival")
            router.unregisterDetail(token)
            // A park stamped for ANOTHER note is dropped, never fired at the
            // note that happens to mount next (`pendingWriteIntent`'s rule).
            router.pendingTrayRequest = TrayRequest(postID: "elsewhere")
            let second = router.registerDetail(
                postID: post, mode: .write, applyMode: { _ in }, showTray: { _ in })
            #expect(router.pendingTrayRequest == nil, "dropped, not fired")
            router.unregisterDetail(second)
        }
    }

    // MARK: - Row 9: the walk's P-1 squeeze

    /// **The preview no longer shares a line box with its metadata.**
    ///
    /// The walk's mechanism: the row was one `HStack`, and the flexible
    /// `Text` is what SwiftUI compresses first — so a 90-character preview
    /// rendered as `"The sea took t…"` while the stamp and the countdown kept
    /// their room. The row stacks now, and the metadata is a VALUE, which is
    /// what makes "they are not competing" assertable at all.
    @Test func theRowsPreviewNeverSharesALineWithItsMetadata() {
        let stamp = "2026-08-24T10:00:00.000Z"
        let deleted = TrayRowFace.meta(
            note: nil, stamp: stamp, when: "deleted", clock: 12, forever: false)
        #expect(deleted.count == 2, "when it went, and how long it has — no preview")
        #expect(deleted.last == TrayPath.daysLeftLabel(12))
        #expect(deleted.allSatisfy { !$0.contains("The sea took") })

        let archived = TrayRowFace.meta(
            note: nil, stamp: stamp, when: "archived", clock: nil, forever: true)
        #expect(archived.last == TrayPath.archivedForever,
                "the clock, or the promise of no clock — never both, never neither")

        let stranded = TrayRowFace.meta(
            note: TrayPath.goesWithItsFamily, stamp: stamp, when: "goes",
            clock: 3, forever: false)
        #expect(stranded.first == TrayPath.goesWithItsFamily)
        #expect(stranded.count == 3)

        // Nothing to say ⇒ nothing rendered: a row never wears a separator
        // around an empty piece.
        #expect(TrayRowFace.meta(
            note: nil, stamp: nil, when: "deleted", clock: nil, forever: false).isEmpty)
    }

    /// **Row 63 (the Act 10 correction round): the clock is its OWN slot and
    /// the stamp is DATE-ONLY.** The walk met "· 30…" and "· k…" at every
    /// width in Terminal — the one joined line truncated tail-first beside
    /// the Put back button, and the clock (the section's whole point) was
    /// what went. The lead truncates; the clock never does; `meta` is
    /// DERIVED from the pair so the pinned value and the rendered pair
    /// cannot drift. RED ON OLD by behavioral revert: the time-of-day stamp
    /// and the joined clock put back in place fail the date-only and
    /// composition halves.
    @Test func theClockIsItsOwnSlotAndTheStampCarriesNoTimeOfDay() throws {
        let stamp = "2026-08-24T10:00:00.000Z"
        let date = try #require(DateFormatter.variorumISO8601.date(from: stamp))
        let lead = TrayRowFace.lead(note: nil, stamp: stamp, when: "deleted")
        #expect(lead == ["deleted \(date.formatted(date: .abbreviated, time: .omitted))"],
                "date-only — the OriginPeek ruling: with a time in it, the clock fell off the end")
        #expect(TrayRowFace.clockSlot(clock: 12, forever: false) == TrayPath.daysLeftLabel(12))
        #expect(TrayRowFace.clockSlot(clock: nil, forever: true) == TrayPath.archivedForever)
        #expect(TrayRowFace.clockSlot(clock: nil, forever: false) == nil)
        #expect(TrayRowFace.meta(
            note: nil, stamp: stamp, when: "deleted", clock: 12, forever: false)
            == lead + [TrayPath.daysLeftLabel(12)],
            "meta derives from the pair — the pinned value IS the rendered pair")

        // The take row: same split, same date-only rule.
        let take = Queries.TrayTake(
            variantID: "v1", blockID: "b1",
            deletedAt: DateFormatter.variorumISO8601.string(from: harnessNow),
            label: nil, text: "Another way of saying it.",
            blockName: nil, blockText: "The sea took the boat.")
        let takeLead = TrayTakeFace.lead(take)
        #expect(takeLead.count == 2)
        #expect(takeLead[1] == "deleted \(harnessNow.formatted(date: .abbreviated, time: .omitted))")
        #expect(TrayTakeFace.clockSlot(take, now: harnessNow)
            == TrayPath.daysLeftLabel(TrashWindow.days))
        #expect(TrayTakeFace.meta(take, now: harnessNow)
            == takeLead + [TrayPath.daysLeftLabel(TrashWindow.days)])
    }

    // MARK: - Row 20: the leaving section

    /// A take row NAMES ITS BLOCK (her A3 discipline at the note grain) and
    /// wears its own clock — the audit's whole point is that nothing on it is
    /// a surprise.
    @Test func aTakeRowNamesItsBlockItsStampAndItsClock() {
        let take = Queries.TrayTake(
            variantID: "v1", blockID: "b1",
            deletedAt: DateFormatter.variorumISO8601.string(from: harnessNow),
            label: nil, text: "Another way of saying it.",
            blockName: nil, blockText: "The sea took the boat. It came back.")
        #expect(TrayTakeFace.label(take) == "Another way of saying it.")
        let meta = TrayTakeFace.meta(take, now: harnessNow)
        #expect(meta.first == RecoveryCopy.trayTakeInBlock("The sea took the boat."),
                "the ONE block-naming rule — its first sentence, derived at read time")
        #expect(meta.last == TrayPath.daysLeftLabel(TrashWindow.days))
        // A labelled take says its label; an empty one says TAKE, never
        // "block" (the `BlockPastCopy.emptyTake` lesson).
        var labelled = take
        labelled = Queries.TrayTake(
            variantID: "v1", blockID: "b1", deletedAt: take.deletedAt,
            label: "the plain one", text: "", blockName: "chapter open")
        #expect(TrayTakeFace.label(labelled) == "the plain one")
        let empty = Queries.TrayTake(
            variantID: "v2", blockID: "b1", deletedAt: take.deletedAt, text: "")
        #expect(TrayTakeFace.label(empty) == RecoveryCopy.emptyTakeLabel)
        #expect(!TrayTakeFace.label(empty).contains("block"))
        #expect(RecoveryCopy.trayTakesDisclosure(1) == "1 deleted take")
        #expect(RecoveryCopy.trayTakesDisclosure(3) == "3 deleted takes")
    }

    /// **Put back, on the take row, through the real op** — and the receipt
    /// reads the op's OWN answer, so a take that was archived when it was
    /// deleted is not told it is back in the fan.
    @Test func theLeavingSectionPutsATakeBack() async throws {
        try await withTray { session, postID, model, blockID, chosen in
            let ops = session.operations
            let second = try ops.branchVariant(blockID, from: chosen)
            try ops.autosave(second.id, text: "Another way.", charDelta: 0)
            try ops.deleteVariant(second.id)
            // The REAL observation, not the read-straight seam: the panel's
            // own `start()` is what has to carry the takes arm, and a test
            // that only calls `adopt` would leave that wiring uncovered.
            let watching = Task { await model.start() }
            defer { watching.cancel() }
            for _ in 0..<200 where model.takes.isEmpty {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(model.takes.map(\.variantID) == [second.id],
                    "the panel's own observation delivers the note's deleted takes")
            #expect(!model.nothingIsLeaving)

            await model.putBackTake(second.id)
            #expect(model.status == .receipt(RecoveryCopy.takeRestoredReceipt(.active)))
            try Self.reload(model, session: session, postID: postID)
            #expect(model.takes.isEmpty, "it left the audit by coming back")
        }
    }

    /// **DELETE NOW, HERE — and it confirms EVERY time** (her round-10
    /// ruling: no don't-ask state exists anywhere, and none may be added).
    ///
    /// The confirm's value RIDES INTO the act (13l Act 2's rule): the door
    /// is born with the fix that four shipped confirm doors were found
    /// missing, because a continuation that reads the pending value back
    /// loses a race with SwiftUI's synchronous dismissal write.
    @Test func theLeavingSectionsDeleteNowConfirmsThenPurgesForGood() async throws {
        try await withTray { session, postID, model, blockID, chosen in
            let ops = session.operations
            let second = try ops.branchVariant(blockID, from: chosen)
            try ops.deleteVariant(second.id)
            try Self.reload(model, session: session, postID: postID)
            let take = try #require(model.takes.first)

            #expect(model.pendingPurge == nil)
            model.requestDeleteNowTake(take)
            let confirm = try #require(model.pendingPurge)
            #expect(confirm.message == RecoveryCopy.deleteNowConfirm(.take))
            #expect(confirm.message.contains("no putting it back"))

            // **The read-back hazard, driven** (13l Act 2's rule): SwiftUI
            // writes `isPresented = false` synchronously inside the button's
            // own click handling, BEFORE the action's `Task` can resume — so
            // the pending value is already gone when the continuation runs.
            // This line stands in for that write. A continuation that opened
            // by reading `pendingPurge` back would return here having done
            // nothing, which is exactly how four confirm doors were found
            // dead across the two apps.
            model.cancelPendingPurge()
            await model.confirmPendingPurge(confirm)
            #expect(model.pendingPurge == nil)
            #expect(model.status?.isRefusal == false, "the act happened: \(model.status as Any)")
            // The intent really landed: the row has left every surface.
            let intents = try await session.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM purge_intent WHERE row_id = ?",
                    arguments: [second.id])
            }
            #expect(intents == 1)
            try Self.reload(model, session: session, postID: postID)
            #expect(model.takes.isEmpty)
            // …and asking again asks again — every time.
            let third = try ops.branchVariant(blockID, from: chosen)
            try ops.deleteVariant(third.id)
            try Self.reload(model, session: session, postID: postID)
            model.requestDeleteNowTake(try #require(model.takes.first))
            #expect(model.pendingPurge != nil, "no don't-ask state, ever")
        }
    }

    /// **The purge door renders on TRASH SURFACES ONLY** — the evolved rule
    /// her G5 ruling put in place of 13j's "never a note, ever": the global
    /// Trash and the note-level trash section, never the writing flow.
    @Test func thePurgeDoorRendersOnTrashSurfacesAndNowhereElse() {
        #expect(TrayPanel.surfaceCapabilities.contains(.deleteNow))
        #expect(RecoveryView.surfaceCapabilities.contains(.deleteNow))
        // No OTHER kind of door exists for it: not a bar, not a context menu,
        // not the menu bar, not the palette.
        let act = CapabilityRegistry.capability(.deleteNow)
        #expect(act.doors == [.surface])
        for table in [
            CommitBar.renderedCapabilities, TakesBottomBar.renderedCapabilities,
            EditorViewModel.contextMenuCapabilities, TakesCellView.contextMenuCapabilities,
            EditorCommands.menuRendered, ShellActions.paletteActs,
        ] {
            #expect(!table.contains(.deleteNow), "no purge door in the writing flow")
        }
        // Empty Trash stays GLOBAL — it is the door that takes what the Trash
        // rows, and a note's tray rows something else (G6's own letter).
        #expect(!TrayPanel.surfaceCapabilities.contains(.emptyTrash))
    }

    // MARK: - Batch 1's two deferred items

    /// **The archive receipt names the door that MOVED** — and it may never
    /// name the badge, which counts deleted blocks only and would be off
    /// screen for a note that had only archived something.
    @Test func theArchiveReceiptNamesTheTrayIconAndNotTheOldMenu() {
        let note = BlockSelectionCopy.archivedNote
        #expect(note.contains(TrayPath.menuLabel))
        #expect(note.contains(TrayPath.doorPhrase(for: .post)))
        #expect(!note.contains("the note menu"), "the item it named is gone")
        #expect(!note.contains(TrayPath.doorGlyph),
                "never the badge: archive does not raise it")
        #expect(note.contains("no countdown"), "archive's difference, in the same breath")
    }

    /// …and on the SCRAPS area the same receipt says the scraps area's own
    /// tray, because a pool is not a note (batch 1's deferred item (b); the
    /// 13l row-26 kind machinery, applied to the door's name).
    @Test func theScrapsAreaCallsItsTrayItsOwn() {
        #expect(TrayPath.menuLabel(for: .post) == "This Note's Tray")
        #expect(TrayPath.menuLabel(for: .pool) == "This Scraps Area's Tray")
        let scrap = BlockSelectionCopy.archivedNote(home: .pool)
        #expect(scrap.contains("This Scraps Area's Tray"))
        #expect(!scrap.contains("This Note's Tray"))
        #expect(scrap.contains(TrayPath.doorPhrase(for: .pool)))
        #expect(TrayPath.doorPhrase(for: .pool).contains("scraps area"))
        // The door is declared and rendered there too.
        #expect(PoolDetailView.surfaceCapabilities == [.showNoteTray])
        // …and the PANEL'S OWN sentences take the kind with them, or the
        // scraps area would open a panel calling itself a note in four
        // places (13l row 26's rule, kept by this whole family).
        for (post, pool) in [
            (RecoveryCopy.trayLeavingExplainer(.post), RecoveryCopy.trayLeavingExplainer(.pool)),
            (RecoveryCopy.trayNothingArchived(.post), RecoveryCopy.trayNothingArchived(.pool)),
            (RecoveryCopy.trayNothingLeaving(.post), RecoveryCopy.trayNothingLeaving(.pool)),
            (RecoveryCopy.trayRevealMissing(.post), RecoveryCopy.trayRevealMissing(.pool)),
        ] {
            #expect(post.contains("note") && !post.contains("scraps"))
            #expect(pool.contains("scraps") && !pool.contains(" note"))
        }
    }

    // MARK: - Harness

    /// A tray model over a real store with one block, ready to be handed
    /// snapshots read straight from the queries (the panel's observation
    /// path without the observation's timing — `TrayViewModel.adopt`'s own
    /// test seam).
    private func withTray(
        _ body: @escaping (AppSession, String, TrayViewModel, String, String) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the leaving section")
            let minted = try session.operations.newBlock(in: post.id, text: "The sea took the boat.")
            let model = TrayViewModel(session: session, postID: post.id)
            try await body(session, post.id, model, minted.block.id, minted.variant.id)
        }
    }

    /// Reads the panel's four listings straight and hands them over.
    private static func reload(
        _ model: TrayViewModel, session: AppSession, postID: String
    ) throws {
        let now = session.now
        model.adopt(try session.database.read { db in
            TrayViewModel.Snapshot(
                deleted: try Queries.trayBlocks(db, postID: postID, now: now),
                archived: try Queries.archivedBlocks(db, postID: postID),
                originals: try Queries.preservedOriginals(db, postID: postID),
                strandedFates: try Queries.originFamilyClocks(db, postID: postID, now: now),
                takes: try Queries.trayTakes(db, postID: postID, now: now))
        })
    }

    /// Mounts the REAL `PostDetailView` in a real window (the
    /// `PostDetailRoutingTests` harness, which is where the "drive the real
    /// surface" discipline for this view already lives).
    private func mounted(
        _ body: @escaping (AppSession, String, NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the panel")
            _ = try session.operations.newBlock(in: post.id, text: "A block, so the page has one.")
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await Self.settle(window, hosting) {
                session.commandRouter.activePostID == post.id
            }
            try await body(session, post.id, window, hosting)
        }
    }

    /// Every AppKit class in the mounted subtree — the honest "what is really
    /// on screen" probe in a headless host, where the accessibility tree is
    /// not populated (measured, not assumed).
    static func classNames(_ view: NSView) -> Set<String> {
        var found: Set<String> = [String(describing: type(of: view))]
        for sub in view.subviews { found.formUnion(classNames(sub)) }
        return found
    }

    private static func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView,
        maxTurns: Int = 60, until predicate: () -> Bool
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

}
