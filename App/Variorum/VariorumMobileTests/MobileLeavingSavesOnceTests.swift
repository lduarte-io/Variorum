//
//  MobileLeavingSavesOnceTests.swift
//  VariorumMobileTests
//
//  VM-71 (the VM-64 run, batch 7) — **LEAVING SAVES ONCE.** The record is
//  `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 7; §7 its closeout,
//  which traces every road below).
//
//  The phone asks for a leaving savepoint on every road out of a note, and a
//  Castle backgrounding asked THREE times for one leaving — each ask a write
//  transaction on the one serial runner that scanned every take of the note
//  (audit F 6C, 1D). Since VM-71 the phone asks the store first, as a read on
//  a reader, and the runner only for the takes owed. The ATTEMPT counts live
//  in `MobileHerPathsPerfTests` (it reads the process's timing recorder and
//  runs alone); this suite holds what the store itself can say, and may run in
//  company:
//
//  · **(a) every road still savepoints a note she changed — once:** the pop,
//    the tab switch (the capture box's filing — a tab switch leaves the box;
//    the note on the stack it hides stays open on that stack, as before), a
//    Standard backgrounding, a Castle backgrounding, and the lock itself;
//    each leaves exactly ONE new quiet savepoint holding her text;
//  · **(b) an earlier leaving never stands in for a later one:** she edits
//    again and leaves again, and a second savepoint is written;
//  · **(c) under Castle the savepoint is in the store before the store
//    closes** — the lock here closes a REAL pool (the bootstrap's binding,
//    `asRebindable`), after the tree comes down, so the removed screen's own
//    ask meets a closed store; nothing is lost and nothing is written after.
//    And since batch 6 r1 that removed screen's leaving ALSO gives its
//    coordinator back, after its savepoint: a key typed after the lock's flush,
//    whose landing meets the closed pool, is KEPT by that release (the phone's
//    `releaseAutosave` drops only a clean coordinator at zero holders) and
//    lands once the store is open again — never dropped;
//  · **the runner's side, RED on the pre-fix build:** on each road the
//    store's writer runs no scan of the note's takes (`closeAutoCommit`'s
//    whole-note read) — one last-savepoint read per take owed, and that is
//    all. Before VM-71 every ask scanned (the Castle road: twice before the
//    pool closed; the lock: once; the pop and Standard: once).
//
//  Every test compiles against the pre-fix tree (no VM-71 API is named), which
//  is how the red-on-old build is made.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Helpers

@MainActor
@discardableResult
private func eventually(
    _ timeout: Duration = .seconds(15), _ condition: @MainActor () -> Bool
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !condition() {
        if clock.now >= deadline { return false }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return true
}

@MainActor
@Observable
private final class LeaveGate {
    var shown = true
}

/// A note screen built INSIDE the host's body, as the shell's destination
/// builds it. **When its leaving has ended:** the screen's `onDisappear` task
/// runs teardown's flush, then the leaving savepoint, then gives the editor's
/// hold on its coordinator back (`releaseAutosaveHold` — batch 6 r1: the
/// release is the leaving's LAST act, not the editor's death, so it comes
/// while this host stays up). So the session's holder count for the note
/// falling to zero says the savepoint has run — the waits below read it, and
/// their bound is a hang guard, not a timing assumption.
private struct LeaveHost: View {
    let gate: LeaveGate
    let build: @MainActor () -> MobileWriteScreen

    var body: some View {
        if gate.shown {
            build()
        } else {
            Color.clear
        }
    }
}

@MainActor
private final class LeavingScreen {
    let gate = LeaveGate()
    let surface: HostedSurface<LeaveHost>

    init(_ build: @escaping @MainActor () -> MobileWriteScreen) {
        surface = HostedSurface(LeaveHost(gate: gate, build: build))
    }

    /// The app's leaving: the screen leaves the tree (its `onDisappear`).
    func close() { gate.shown = false }

    func tearDown() { surface.tearDown() }
}

/// A store the test can LOCK: an on-disk, encrypted pool wrapped in the
/// bootstrap's binding (`asRebindable`), so a lock here closes a real pool —
/// and `reopen` points the binding at the same file again, as an unlock does.
@MainActor
private struct LockableStore {
    let view: AppDatabase
    let binding: StoreBinding
    let url: URL
    let key: StoreKey

    func reopen() throws { try binding.adopt(try AppDatabase.onDisk(url: url, key: key)) }
}

@MainActor
private func withLockableWorld<T>(
    _ body: @MainActor (AppSession, LockableStore) async throws -> T
) async throws -> T {
    MobileEditorStyle.voice = .terminal
    let folder = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("vm71-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: folder) }
    let url = folder.appendingPathComponent("variorum.sqlite")
    let key = StoreKey.mint()
    let (view, binding) = try AppDatabase.onDisk(url: url, key: key).asRebindable()
    let store = LockableStore(view: view, binding: binding, url: url, key: key)
    defer { binding.lock() }
    return try await withDependencies {
        $0.database = view
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator { Date() }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 71))
    } operation: { @MainActor in
        try await body(AppSession(database: view), store)
    }
}

/// A one-block note ("Base."), left once before (its take savepointed), so a
/// leaving after an edit owes exactly one savepoint.
@MainActor
private func seedLeftNote(_ session: AppSession, title: String = "left before") async throws -> String {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: title, profile: .blog)
        _ = try ops.newBlock(in: post.id, text: "Base.", at: .end, registeringUndo: false)
        _ = try ops.closeAutoCommit(post.id)
        return post.id
    }
}

/// The note's quiet savepoints' texts, oldest first.
@MainActor
private func autoSavepoints(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(db, sql: """
            SELECT cp.text FROM commit_point cp
            JOIN variant v ON v.id = cp.variant_id
            JOIN container_block cb ON cb.block_id = v.block_id AND cb.container_id = ?
            WHERE cp.kind = 'auto'
            ORDER BY cp.created_at, cp.id
            """, arguments: [postID])
    }
}

/// The note's one take's stored text.
@MainActor
private func storedTakeText(_ db: AppDatabase, postID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(db, sql: """
            SELECT v.working_text FROM variant v
            JOIN container_block cb ON cb.block_id = v.block_id AND cb.container_id = ?
            WHERE v.deleted_at IS NULL
            """, arguments: [postID])
    }
}

/// Types `key` into the registered editor of the note (inside the first
/// block), scoped so the test holds no reference to the editor afterwards.
@MainActor
private func typeKey(_ key: String, into router: MobileShellRouter) throws {
    let model = try #require(router.editors.registered.last)
    let storage = try #require(model.textView?.textStorage)
    #expect(typeEdit(model, storage, range: NSRange(location: 4, length: 0), replacement: key),
            "the key was accepted")
}

/// What a leaving ran on the store's WRITER: scans of the note's takes
/// (`closeAutoCommit`'s whole-note read), and last-savepoint reads (one per
/// take a savepoint examines).
private struct WriterWork {
    let scans: Int
    let takeReads: Int

    init(_ statements: [OwnerAdoptionTrace.Statement]) {
        scans = statements.filter {
            $0.sql.contains("SELECT v.* FROM variant v") && $0.sql.contains("ORDER BY v.id")
        }.count
        takeReads = statements.filter {
            $0.sql.hasPrefix("SELECT text FROM commit_point WHERE variant_id = ?")
        }.count
    }
}

// MARK: - The suite

@MainActor
@Suite("VM-71 — leaving saves once (every road, by the store's own record)", .serialized)
struct MobileLeavingSavesOnceTests {

    // MARK: (a) + (b) — the pop

    /// **Popping a note she changed leaves ONE savepoint with her text** — and
    /// when she comes back, changes it again and leaves again, a SECOND one
    /// (an earlier leaving never stands in for a later one). On the writer:
    /// no scan of the note's takes, one last-savepoint read for the one take
    /// owed (RED on the pre-fix build: the pop's whole op scanned).
    @Test func poppingAChangedNoteLeavesOneSavepointAndAgainAfterTheNextChange() async throws {
        try await withLockableWorld { session, store in
            let postID = try await seedLeftNote(session)
            #expect(try await autoSavepoints(store.view, postID: postID) == ["Base."])

            for (round, key) in ["X", "Y"].enumerated() {
                let router = MobileShellRouter()
                let screen = LeavingScreen {
                    MobileWriteScreen(session: session, postID: postID, router: router, tab: .library)
                }
                defer { screen.tearDown() }
                #expect(await eventually { !router.editors.registered.isEmpty }, "the screen's editor arrived")
                #expect(await eventually { router.editors.registered.last?.textView?.textStorage.length ?? 0 > 0 })
                try typeKey(key, into: router)

                let log = try OwnerAdoptionTrace.start(on: store.view)
                screen.close()
                #expect(await eventually { session.autosaveHolderCount(forPost: postID) == 0 },
                        "round \(round): the leaving finished (the editor gave its coordinator back)")
                try OwnerAdoptionTrace.stop(on: store.view)
                let work = WriterWork(log.value)

                let text = try await storedTakeText(store.view, postID: postID)
                let savepoints = try await autoSavepoints(store.view, postID: postID)
                #expect(savepoints.count == round + 2, "round \(round): one new savepoint — \(savepoints)")
                #expect(savepoints.last == text, "round \(round): it holds what she typed")
                #expect(work.scans == 0, "VM-71: the pop scanned the note's takes on the writer (\(work.scans))")
                #expect(work.takeReads == 1, "VM-71: one take owed, one read — ran \(work.takeReads)")
            }
        }
    }

    // MARK: (a) — the tab switch

    /// **A tab switch leaves the capture box — its filing savepoints the box's
    /// note ONCE** (the shell's `selectPage`: `fileOnLeaving`, then the
    /// liveness handoff). The note on the stack the switch hides stays OPEN on
    /// that stack (stood down, as the liveness authority's rule has always
    /// had it), so the switch asks nothing for it — its savepoint comes when
    /// it is popped, the app is left, or the library locks. Unchanged by
    /// VM-71; pinned so the road is stated.
    @Test func aTabSwitchFilesTheBoxOnceAndLeavesTheHiddenNoteOpen() async throws {
        try await withLockableWorld { session, store in
            let postID = try await seedLeftNote(session)
            let router = MobileShellRouter()
            router.quickNote.bind(session: session)
            let screen = LeavingScreen {
                MobileWriteScreen(session: session, postID: postID, router: router, tab: .shelf)
            }
            defer { screen.tearDown() }
            #expect(await eventually { router.editors.registered.last?.textView?.textStorage.length ?? 0 > 0 })
            try typeKey("X", into: router)

            router.quickNote.text = "A thought for the box."
            #expect(await router.quickNote.mintNow() != nil, "the box minted its note")
            let boxNote = try #require(router.quickNote.postID)

            // `MobileShellView.selectPage`'s two calls, in its order.
            let handoff = router.editors.beginHandoff()
            await router.quickNote.fileOnLeaving()
            await router.editors.tabDidBecomeVisible(.library, handoff: handoff)

            #expect(try await autoSavepoints(store.view, postID: boxNote).count == 1,
                    "the box's note: one savepoint at its filing")
            await router.quickNote.fileOnLeaving()  // the next switch, an empty box
            #expect(try await autoSavepoints(store.view, postID: boxNote).count == 1, "and only one")
            try? await Task.sleep(for: .milliseconds(800))  // past the hidden note's debounce
            #expect(try await autoSavepoints(store.view, postID: postID) == ["Base."],
                    "the hidden stack's note is still open there — the switch did not leave it")
            #expect(router.editors.registeredPostIDs == [postID], "and its screen is still registered")
        }
    }

    // MARK: (a) + (b) — Standard backgrounding

    /// **A Standard backgrounding savepoints the open note she changed ONCE**,
    /// and the note stays open (Standard never locks); she changes it again
    /// and pops it, and that leaving writes a SECOND savepoint.
    @Test func aStandardBackgroundingLeavesOneSavepointAndThePopAfterAChangeAnother() async throws {
        try await withLockableWorld { session, store in
            let postID = try await seedLeftNote(session)
            let router = MobileShellRouter()
            let screen = LeavingScreen {
                MobileWriteScreen(session: session, postID: postID, router: router, tab: .library)
            }
            defer { screen.tearDown() }
            #expect(await eventually { router.editors.registered.last?.textView?.textStorage.length ?? 0 > 0 })
            try typeKey("X", into: router)

            let log = try OwnerAdoptionTrace.start(on: store.view)
            let work = mobileScenePhaseChanged(
                .background, editors: router.editors, sync: nil, quickNote: router.quickNote,
                savepoint: { await session.savepointOnLeaving($0) }, grant: .none, relock: nil)
            await work?.value
            try OwnerAdoptionTrace.stop(on: store.view)
            let writer = WriterWork(log.value)
            let afterBackground = try await autoSavepoints(store.view, postID: postID)
            #expect(afterBackground.count == 2, "one new savepoint — \(afterBackground)")
            #expect(afterBackground.last == "BaseX.")
            #expect(writer.scans == 0, "VM-71: the backgrounding scanned the note's takes (\(writer.scans))")
            #expect(writer.takeReads == 1, "VM-71: one take owed, one read — ran \(writer.takeReads)")

            try typeKey("Y", into: router)
            screen.close()
            #expect(await eventually { session.autosaveHolderCount(forPost: postID) == 0 })
            let afterPop = try await autoSavepoints(store.view, postID: postID)
            #expect(afterPop.count == 3, "the later leaving owed its own — \(afterPop)")
            #expect(afterPop.last == "BaseYX.")
        }
    }

    // MARK: (a) + (b) + (c) — Castle backgrounding

    /// **A Castle backgrounding savepoints the open note she changed ONCE, and
    /// the savepoint is in the store before the store closes.** The chain is
    /// the app's (`mobileScenePhaseChanged`: the flush and its savepoints, then
    /// the re-lock), and the lock stand-in is `AppBootstrap.lockOnNewRoad`'s
    /// order with a REAL pool close: the phone's `onWillLock`
    /// (`mobileWillLock`), the tree down, the pool closed — so the removed
    /// screen's own ask meets a closed store. The savepoint is read at the
    /// lock's start (the store open — hazard (c)) and after an unlock; nothing
    /// typed is lost. Then she changes it again and the app leaves again: a
    /// second savepoint (hazard (b)). On the writer, before the pool closed: no
    /// scan of the note's takes, one last-savepoint read in all — RED on the
    /// pre-fix build (two scans: the flush's ask and the lock's teardown's).
    @Test func aCastleBackgroundingSavepointsOnceBeforeTheStoreCloses() async throws {
        try await withLockableWorld { session, store in
            let postID = try await seedLeftNote(session)

            for (round, key) in ["X", "Y"].enumerated() {
                let router = MobileShellRouter()
                let screen = LeavingScreen {
                    MobileWriteScreen(session: session, postID: postID, router: router, tab: .library)
                }
                defer { screen.tearDown() }
                #expect(await eventually { router.editors.registered.last?.textView?.textStorage.length ?? 0 > 0 })
                try typeKey(key, into: router)
                let typed = ["BaseX.", "BaseYX."][round]  // a key at offset 4, each round

                let log = try OwnerAdoptionTrace.start(on: store.view)
                let atTheLock = LockIsolatedBox<[String]?>(nil)
                let relock = MobileRelockCoordinator(
                    policy: { RoadRelockPolicy(idleMinutes: 10) },
                    lock: {
                        atTheLock.value = try? await autoSavepoints(store.view, postID: postID)
                        await mobileWillLock(session: session, editors: router.editors, stopServices: {})()
                        screen.close()
                        store.binding.lock()
                    })
                let work = mobileScenePhaseChanged(
                    .background, editors: router.editors, sync: nil, quickNote: router.quickNote,
                    savepoint: { await session.savepointOnLeaving($0) }, grant: .none, relock: relock)
                await work?.value
                #expect(await eventually { session.autosaveHolderCount(forPost: postID) == 0 },
                        "round \(round): the removed screen's leaving finished against the closed store")
                let writer = WriterWork(log.value)

                #expect(store.binding.isLocked)
                try store.reopen()  // the unlock
                let savepoints = try await autoSavepoints(store.view, postID: postID)
                #expect(savepoints.count == round + 2, "round \(round): one new savepoint — \(savepoints)")
                #expect(savepoints.last == typed, "round \(round): it holds what she typed")
                #expect(atTheLock.value == savepoints,
                        "round \(round): the savepoint was in the store BEFORE the lock began — nothing written after")
                #expect(try await storedTakeText(store.view, postID: postID) == typed, "nothing typed was lost")
                #expect(writer.scans == 0,
                        "VM-71: the Castle leaving scanned the note's takes on the writer \(writer.scans) times")
                #expect(writer.takeReads == 1, "VM-71: one take owed, one read in all — ran \(writer.takeReads)")
            }
        }
    }

    // MARK: (a) + (b) + (c) — the lock itself

    /// **The lock itself (Lock now; a crossing's teardown) savepoints the open
    /// note she changed ONCE, before the store closes** — `mobileWillLock`,
    /// the tree down, the pool closed; the removed screen's ask meets the
    /// closed store. Twice, with a change between (b). RED on the pre-fix
    /// build on the writer (the teardown's ask scanned the note's takes).
    @Test func theLockSavepointsOnceBeforeTheStoreCloses() async throws {
        try await withLockableWorld { session, store in
            let postID = try await seedLeftNote(session)

            for (round, key) in ["X", "Y"].enumerated() {
                let router = MobileShellRouter()
                let screen = LeavingScreen {
                    MobileWriteScreen(session: session, postID: postID, router: router, tab: .shelf)
                }
                defer { screen.tearDown() }
                #expect(await eventually { router.editors.registered.last?.textView?.textStorage.length ?? 0 > 0 })
                try typeKey(key, into: router)
                let typed = ["BaseX.", "BaseYX."][round]  // a key at offset 4, each round

                let log = try OwnerAdoptionTrace.start(on: store.view)
                await mobileWillLock(session: session, editors: router.editors, stopServices: {})()
                let beforeTheClose = try await autoSavepoints(store.view, postID: postID)
                screen.close()
                store.binding.lock()
                #expect(await eventually { session.autosaveHolderCount(forPost: postID) == 0 })
                let writer = WriterWork(log.value)

                try store.reopen()
                let savepoints = try await autoSavepoints(store.view, postID: postID)
                #expect(savepoints.count == round + 2, "round \(round): one new savepoint — \(savepoints)")
                #expect(savepoints.last == typed)
                #expect(beforeTheClose == savepoints, "round \(round): made before the pool closed, none after")
                #expect(writer.scans == 0, "VM-71: the lock scanned the note's takes on the writer (\(writer.scans))")
                #expect(writer.takeReads == 1, "VM-71: one take owed, one read — ran \(writer.takeReads)")
            }
        }
    }

    // MARK: (c), under batch 6 r1 — the release after a closed store keeps what did not land

    /// **A release racing the pool close never drops unsaved text.** Since
    /// batch 6 r1 the removed screen's leaving gives its coordinator back as its
    /// last act — after its flush and its savepoint, in one task. Here a key
    /// arrives AFTER the lock's own flush and savepoint (the lock is async; the
    /// page stays live through its awaits) and the pool closes before the
    /// screen's leaving can land it: the leaving's flush is refused, the
    /// savepoint's read meets the closed store, and the release finds the
    /// coordinator DIRTY — so the phone's `releaseAutosave` keeps the entry (it
    /// drops one only at zero holders AND clean), the key stays reachable to
    /// every flush walk, and it lands once the store is open again. The lock's
    /// savepoint holds what had landed before it. A guard on both builds (the
    /// release is batch 6's, the same on each).
    @Test func aKeyThatMeetsTheClosedStoreIsKeptByTheReleaseNotDropped() async throws {
        try await withLockableWorld { session, store in
            let postID = try await seedLeftNote(session)
            let start = session.openAutosaveCount
            let router = MobileShellRouter()
            let screen = LeavingScreen {
                MobileWriteScreen(session: session, postID: postID, router: router, tab: .shelf)
            }
            defer { screen.tearDown() }
            #expect(await eventually { router.editors.registered.last?.textView?.textStorage.length ?? 0 > 0 })
            try typeKey("X", into: router)

            // The lock's teardown lands "X" and savepoints it…
            await mobileWillLock(session: session, editors: router.editors, stopServices: {})()
            // …and one more key arrives before the tree comes down.
            try typeKey("Y", into: router)
            #expect(session.hasPendingAutosave, "the late key waits in the debounce")
            screen.close()
            store.binding.lock()
            #expect(await eventually { session.autosaveHolderCount(forPost: postID) == 0 },
                    "the removed screen's leaving ended — its hold given back")
            #expect(session.openAutosaveCount == start + 1,
                    "the release KEPT the dirty coordinator — nothing pending is ever dropped")
            #expect(session.hasPendingAutosave, "the late key is still held, reachable to every flush walk")

            try store.reopen()  // the unlock
            await session.flushEveryOpenPost()
            #expect(try await storedTakeText(store.view, postID: postID) == "BaseYX.",
                    "the late key landed once the store was open again")
            #expect(try await autoSavepoints(store.view, postID: postID) == ["Base.", "BaseX."],
                    "the lock's savepoint holds what had landed before it closed the store")
        }
    }

    // MARK: Nothing owed, nothing asked

    /// **Leaving a note she only read asks the runner for nothing** — the
    /// store already holds a savepoint of every take, so the read finds
    /// nothing owed: no new savepoint (as before — the op's own dedupe), and
    /// now no scan and no last-savepoint read on the writer either (RED on the
    /// pre-fix build: the pop's whole op scanned and read every take).
    @Test func leavingANoteSheOnlyReadAsksTheRunnerForNothing() async throws {
        try await withLockableWorld { session, store in
            let postID = try await seedLeftNote(session)
            let router = MobileShellRouter()
            let screen = LeavingScreen {
                MobileWriteScreen(session: session, postID: postID, router: router, tab: .library)
            }
            defer { screen.tearDown() }
            #expect(await eventually { router.editors.registered.last?.textView?.textStorage.length ?? 0 > 0 })

            let log = try OwnerAdoptionTrace.start(on: store.view)
            screen.close()
            #expect(await eventually { session.autosaveHolderCount(forPost: postID) == 0 })
            try OwnerAdoptionTrace.stop(on: store.view)
            let writer = WriterWork(log.value)
            #expect(try await autoSavepoints(store.view, postID: postID) == ["Base."], "nothing new")
            #expect(writer.scans == 0 && writer.takeReads == 0,
                    "VM-71: nothing owed ⇒ nothing on the writer — \(writer.scans) scans, \(writer.takeReads) reads")
        }
    }
}
