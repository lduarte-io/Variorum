//
//  MobileNoteOpenOnceTests.swift
//  VariorumMobileTests
//
//  VM-69 · VM-70 (the VM-64 run, batch 6) — **A NOTE IS READ ONCE, AND
//  RELEASED WHEN IT CLOSES.** The record is
//  `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 6; §7 its closeout,
//  which traces every mechanism below).
//
//  The open's COUNTS — one projection read per open, one editor build, no
//  registry growth per open-and-close — are asserted where they are measured,
//  in `MobileHerPathsPerfTests` (that suite reads the process's one timing
//  recorder and must run alone). This suite holds what those counts cannot:
//
//  · **the chrome once** — an open asks the projection road for ONE
//    whole-document chrome pass, not three (red on the pre-fix tree: 3);
//  · **the chips read what they show** — opening a note runs no read of every
//    book or every tag beyond what the books chip's own feed needs (red on the
//    pre-fix tree);
//  · **the batch's four hazards**, each with its traced mechanism in the
//    record: (a) a write landing between the open's one read and the live
//    updates still reaches the page; (b) a release never drops unsaved text,
//    never comes before the leaving savepoint, and never lets go of a
//    coordinator another holder still needs (red on the pre-fix tree where it
//    asks for the release); (c) a stood-down editor on another tab keeps
//    following the store, and the tab switch hands it a current page. (d) —
//    the chips' scoped reads show exactly what the full reads showed — is
//    `MobileChipScopeTests` (it names the new chip reads, so it is set aside
//    for the red-on-old build).
//
//  Every test here compiles against the pre-fix tree at the batch's
//  INSTRUMENT commit (`projectionChromePasses` is the instrument), which is
//  how the red-on-old build is made. No test reads the process-global timing
//  recorder, so this suite may run in company.
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

/// Waits on the main actor for `condition`, with plain sleeps (the run loop
/// runs as the app's does). Returns whether it came true in time.
@MainActor
@discardableResult
private func eventually(
    _ timeout: Duration = .seconds(10), _ condition: @MainActor () -> Bool
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !condition() {
        if clock.now >= deadline { return false }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return true
}

/// Async-condition twin (store reads).
@MainActor
@discardableResult
private func eventuallyAsync(
    _ timeout: Duration = .seconds(10), _ condition: @MainActor () async -> Bool
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while await !condition() {
        if clock.now >= deadline { return false }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return true
}

@MainActor
@Observable
private final class ScreenGate {
    var shown = true
}

/// **A note screen held the way the app holds one** — built INSIDE the
/// host's body, as the shell's NavigationStack destination builds it, so when
/// the gate closes nothing outside the view tree keeps the screen (or the
/// editor in its `@State`) alive. A host that stores the BUILT screen value
/// would keep the editor alive through `State(initialValue:)`'s stored value
/// for as long as the test holds the host — which is exactly the question the
/// release pins ask, so they must not.
private struct BuiltScreenHost: View {
    let gate: ScreenGate
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
private final class BuiltScreen {
    let gate = ScreenGate()
    let surface: HostedSurface<BuiltScreenHost>

    init(_ build: @escaping @MainActor () -> MobileWriteScreen) {
        surface = HostedSurface(BuiltScreenHost(gate: gate, build: build))
    }

    /// The app's leaving: the screen leaves the tree (its `onDisappear` —
    /// deregister, teardown, the leaving savepoint — runs as in the app).
    func close() { gate.shown = false }

    func tearDown() { surface.tearDown() }
}

/// A one-block note ("Base.") and its block's take.
@MainActor
private func seedNote(_ session: AppSession, title: String = "once") async throws
    -> (postID: String, variantID: String) {
    let post = try await session.runner.run { ops in
        try ops.createPost(title: title, profile: .blog)
    }
    let block = try await session.runner.run { ops in
        try ops.newBlock(in: post.id, text: "Base.", at: .end)
    }
    return (post.id, block.variant.id)
}

/// The registered editor for a tab (weakly held by the authority — the test
/// keeps it only inside the caller's scope).
@MainActor
private func editor(_ router: MobileShellRouter, at index: Int) -> MobileEditorViewModel? {
    let registered = router.editors.registered
    return registered.indices.contains(index) ? registered[index] : nil
}

/// The quiet auto savepoints on one take.
@MainActor
private func autoCommits(_ db: AppDatabase, variantID: String) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ? AND kind = 'auto'",
            arguments: [variantID]) ?? 0
    }
}

/// An on-disk, encrypted, WAL-pool store, opened the way the app opens one
/// (`openStore(at:)` — the perf suite's `DiskWorld` precedent). Hazard (a)
/// needs a POOL: only there does an observation's first read run on a reader
/// while a write holds the writer — the window GRDB's start covers.
@MainActor
private func withPoolWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    MobileEditorStyle.voice = .terminal
    let folder = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("vm69-pool-\(UUID().uuidString)", isDirectory: true)
    defer { try? FileManager.default.removeItem(at: folder) }
    let db = try AppDatabase.openStore(at: folder.appendingPathComponent("variorum.sqlite"))
    return try await withDependencies {
        $0.database = db
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator { Date() }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 69))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// Every statement the store's connection runs, by its SQL text (the perf
/// suite's `OwnerAdoptionTrace` shape). Nonisolated so the trace closure GRDB
/// calls on its own queue carries no actor isolation of the test's.
nonisolated enum OpenOnceTrace {
    static func start(on db: AppDatabase) throws -> LockIsolated<[String]> {
        let log = LockIsolated<[String]>([])
        try db.writeWithoutTransaction { connection in
            connection.trace(options: .statement) { event in
                guard case .statement(let statement) = event else { return }
                let sql = statement.sql
                log.withValue { $0.append(sql) }
            }
        }
        return log
    }

    static func stop(on db: AppDatabase) throws {
        try db.writeWithoutTransaction { $0.trace(options: .statement, nil) }
    }
}

// MARK: - The suite

@MainActor
@Suite("VM-69 · VM-70 — a note is read once, and released when it closes", .serialized)
struct MobileNoteOpenOnceTests {

    // MARK: The chrome once (VM-69)

    /// **An open asks for ONE whole-document chrome pass.** The arrival's
    /// render lays the chrome out as its last act; the pre-fix `ingest` laid
    /// it out again over the same inputs, and the live updates' first delivery
    /// (the second read) a third time — audit F §4's "the chrome is laid out
    /// three times". RED on the pre-fix tree: 3.
    ///
    /// The screen's exact wiring (arrival, then the live updates), on a laid
    /// out surface in a window. The idle after the render is longer than the
    /// pre-fix tree's first delivery takes, so a third pass would be counted.
    @Test func anOpenAsksForTheWholeDocumentChromeOnce() async throws {
        try await withEditorWorld { session, _ in
            let note = try await seedNote(session)
            let model = MobileEditorViewModel(session: session, postID: note.postID)
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let scene = try #require(
                scenes.first { $0.activationState == .foregroundActive } ?? scenes.first,
                "the test host has a window scene")
            let window = UIWindow(windowScene: scene)
            window.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            let controller = UIViewController()
            controller.view.addSubview(surface)
            window.rootViewController = controller
            window.makeKeyAndVisible()
            defer {
                window.endEditing(true)
                window.isHidden = true
                window.rootViewController = nil
            }
            model.attach(textView: surface.textView)
            #expect(model.projectionChromePasses == 0, "nothing asked before the arrival")

            let wiring = Task {
                await model.arrive(focus: false)
                await model.start()
            }
            defer { wiring.cancel() }
            #expect(await eventually { model.fullRenderCount >= 1 }, "the note rendered")
            try? await Task.sleep(for: .milliseconds(1500))
            #expect(model.projectionChromePasses == 1,
                    "VM-69: one whole-document chrome pass per open — asked \(model.projectionChromePasses)")

            // The guard on the other side: an apply that touches nothing in
            // the view still lays the chrome out — a take can arrive without
            // a byte of text moving (a new take on the block → an echo).
            let before = model.projectionChromePasses
            let blockID = try #require(model.index.entries.first?.blockID)
            _ = try await session.runner.run { ops in
                try ops.branchVariant(blockID, from: note.variantID)
            }
            #expect(await eventually { model.projectionChromePasses > before },
                    "a delivery that only moved the fan still lays the chrome out")
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }

    // MARK: The chips read what they show (VM-69)

    /// **Opening a note reads no listing of every book or every tag beyond
    /// the books chip's own feed.** The pre-fix chips ran the SHEETS' reads
    /// at every open — `Queries.readings` (every book, for "Add to a book")
    /// and `Queries.allTags` (every tag, for the suggestions) — though the
    /// masthead shows only the note's own rows. RED on the pre-fix tree: one
    /// every-book listing more than the feed's own, and one every-tag listing.
    ///
    /// Read off the store's one connection (an in-memory queue — every read
    /// and write runs there, so the statement trace sees them all). The books
    /// chip's feed (`readingsContaining`) itself lists the readings once, to
    /// test each gathering's rule (author-scale; the Mac chip's own read,
    /// byte-identical), so the assertion is relative to that feed's own leg.
    @Test func openingANoteReadsNoListingOfEveryBookOrEveryTag() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Harbor", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Base.", at: .end)
                let sea = try ops.createTag(name: "sea")
                _ = try ops.applyTag(sea.id, toPost: post.id)
                _ = try ops.createTag(name: "wind")
                _ = try ops.createTag(name: "salt")
                let essays = try ops.createReading(name: "Essays", kind: .book)
                _ = try ops.addPostToReading(post.id, to: essays.id)
                _ = try ops.createReading(name: "Spare", kind: .book)
                _ = try ops.createReading(
                    name: "By the Water", kind: .gathering, querySpec: #"{"tags":["sea"]}"#)
                return post.id
            }

            let log = try OpenOnceTrace.start(on: db)
            defer { try? OpenOnceTrace.stop(on: db) }

            let router = MobileShellRouter()
            let surface = HostedSurface(MobileWriteScreen(
                session: session, postID: postID, router: router, tab: .library))
            defer { surface.tearDown() }

            func count(_ match: (String) -> Bool) -> Int {
                log.value.filter { match($0.trimmingCharacters(in: .whitespacesAndNewlines)) }.count
            }
            let bookLeg: (String) -> Bool = { $0.contains("JOIN reading_post rp ON rp.reading_id = r.id") }
            let tagsLeg: (String) -> Bool = { $0.contains("JOIN post_tag pt ON pt.tag_id = t.id") }
            #expect(await eventually { count(bookLeg) >= 1 && count(tagsLeg) >= 1 },
                    "both chips read (the books chip's feed and the note's tags)")
            try? await Task.sleep(for: .milliseconds(500))

            let readingListings = count { $0.hasPrefix("SELECT * FROM reading WHERE deleted_at IS NULL") }
            let tagListings = count { $0.hasPrefix("SELECT * FROM tag WHERE deleted_at IS NULL") }
            #expect(tagListings == 0,
                    "VM-69: the open read every tag \(tagListings) time(s) — the tags chip shows only the note's")
            #expect(readingListings == count(bookLeg),
                    "VM-69: the open listed every book \(readingListings) time(s) for \(count(bookLeg)) chip feed(s)")
        }
    }

    // MARK: Hazard (a) — nothing falls between the one read and the live updates

    /// **A write that lands after the open's ONE read reaches the page.** The
    /// open's read is now the live observation's first value; on a pool that
    /// read runs on a READER, while the observation's tracking start waits for
    /// the WRITER. This holds the writer with a write that commits a change
    /// to the note only after the arrival has painted the old text — the
    /// widest window there is — and requires the page to end on the change:
    /// GRDB compares the first read's WAL snapshot with the writer's and
    /// reads again (`ValueConcurrentObserver`), the value waits in the stream,
    /// and `start()` takes it as a delivery (a signal → the fresh read →
    /// the page). A guard: green on both trees (the pre-fix tree's second read
    /// covered the same window the same way).
    @Test func aWriteLandingAfterTheOpensOneReadReachesThePage() async throws {
        try await withPoolWorld { session, db in
            let note = try await seedNote(session)
            let (model, storage) = makeEditor(session, postID: note.postID)

            let entered = LockIsolated(false)
            let gate = DispatchSemaphore(value: 0)
            let variantID = note.variantID
            let held = Task.detached {
                try await db.write { db in
                    entered.setValue(true)
                    gate.wait()
                    try db.execute(
                        sql: "UPDATE variant SET working_text = ? WHERE id = ?",
                        arguments: ["Remote.", variantID])
                }
            }
            var released = false
            defer { if !released { gate.signal() } }
            #expect(await eventually { entered.value }, "the writer is held")

            await model.arrive(focus: false)
            #expect(storage.string == "Base.", "the arrival painted the one read it made")

            let live = Task { await model.start() }
            defer { live.cancel() }
            released = true
            gate.signal()
            try await held.value

            #expect(await eventually { storage.string == "Remote." },
                    "the write that landed after the read reached the page — it reads \(storage.string)")
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }

    // MARK: Hazard (b) — the release never drops text, never races the savepoint, never takes a held coordinator

    /// **Closing a note lands its pending text and its savepoint, THEN gives
    /// its coordinator back.** A key typed a moment before the close is still
    /// in the debounce; the screen's leaving lands it (teardown's flush) and
    /// savepoints the take, and the session's registry is back where it was.
    /// RED on the pre-fix tree on the release (the registry kept the entry);
    /// the text and the savepoint are the guard on both trees.
    ///
    /// **r1:** the give-back IS the leaving work's last act (`onDisappear`'s
    /// task: teardown, the savepoint, `releaseAutosaveHold`), so the registry
    /// coming back is the leaving's completion, and the wait's bound is a hang
    /// guard — never a bet on when SwiftUI frees the closed screen. (r0 released
    /// at the editor's death; this host stays up, and the first window showed
    /// the editor outliving its leaving here on both builds — the trace, §5.)
    @Test func closingANoteLandsItsTextThenGivesItsCoordinatorBack() async throws {
        try await withEditorWorld { session, db in
            let note = try await seedNote(session)
            let start = session.openAutosaveCount
            let router = MobileShellRouter()
            let screen = BuiltScreen {
                MobileWriteScreen(session: session, postID: note.postID, router: router, tab: .library)
            }
            defer { screen.tearDown() }
            #expect(await eventually { (editor(router, at: 0)?.fullRenderCount ?? 0) >= 1 },
                    "the screen's editor arrived")
            #expect(session.openAutosaveCount == start + 1, "the open note holds one coordinator")

            do {
                let model = try #require(editor(router, at: 0))
                let storage = try #require(model.textView?.textStorage)
                #expect(typeEdit(model, storage, range: NSRange(location: 4, length: 0), replacement: "X"))
                #expect(model.autosave.isDirty, "the key waits in the debounce")
            }
            screen.close()

            let givenBack = await eventually { session.openAutosaveCount == start }
            #expect(givenBack, "VM-70: the closed note gave its coordinator back")
            #expect(try await storedText(db, variantID: note.variantID) == "BaseX.",
                    "the key typed before the close landed")
            #expect(try await autoCommits(db, variantID: note.variantID) >= 1,
                    "the leaving savepoint landed")
        }
    }

    /// **The release waits for the leaving savepoint.** The store's writer is
    /// held as the note closes, so the leaving work (teardown's flush, then
    /// `savepointOnLeaving`) cannot land; while it waits the note's coordinator
    /// stays in the registry — the give-back is the leaving's LAST act, after
    /// both (r1). When the writer lets go, the flush and the savepoint land and
    /// only then is the coordinator given back. RED on the pre-fix tree on the
    /// give-back; a release that ran at the close itself (before the savepoint)
    /// would be red on the hold.
    @Test func theReleaseWaitsForTheLeavingSavepoint() async throws {
        try await withEditorWorld { session, db in
            let note = try await seedNote(session)
            let start = session.openAutosaveCount
            let router = MobileShellRouter()
            let screen = BuiltScreen {
                MobileWriteScreen(session: session, postID: note.postID, router: router, tab: .library)
            }
            defer { screen.tearDown() }
            #expect(await eventually { (editor(router, at: 0)?.fullRenderCount ?? 0) >= 1 })
            do {
                let model = try #require(editor(router, at: 0))
                let storage = try #require(model.textView?.textStorage)
                #expect(typeEdit(model, storage, range: NSRange(location: 4, length: 0), replacement: "Y"))
            }

            let entered = LockIsolated(false)
            let gate = DispatchSemaphore(value: 0)
            let held = Task.detached {
                try await db.write { _ in
                    entered.setValue(true)
                    gate.wait()
                }
            }
            var released = false
            defer { if !released { gate.signal() } }
            #expect(await eventually { entered.value }, "the writer is held")

            screen.close()
            try? await Task.sleep(for: .milliseconds(600))
            #expect(session.openAutosaveCount == start + 1,
                    "while the leaving work waits, the note's coordinator is still held")

            released = true
            gate.signal()
            try await held.value
            #expect(await eventually { session.openAutosaveCount == start },
                    "VM-70: given back once the leaving work landed")
            #expect(try await storedText(db, variantID: note.variantID) == "BaseY.")
            #expect(try await autoCommits(db, variantID: note.variantID) >= 1,
                    "the leaving savepoint landed")
        }
    }

    /// **A coordinator another holder still needs is never let go.** Two tab
    /// stacks holding the same note, and the quick note's own hold (it takes
    /// and gives back through the same two calls): closing one holder leaves
    /// the entry — the remaining editor records into the very coordinator
    /// every flush walk reaches — and the entry goes only with the last. RED
    /// on the pre-fix tree (a closed editor kept its hold).
    @Test func aCoordinatorAnotherHolderNeedsIsNeverLetGo() async throws {
        try await withEditorWorld { session, db in
            let note = try await seedNote(session)
            let start = session.openAutosaveCount
            let router = MobileShellRouter()
            let shelf = BuiltScreen {
                MobileWriteScreen(session: session, postID: note.postID, router: router, tab: .shelf)
            }
            defer { shelf.tearDown() }
            #expect(await eventually { (editor(router, at: 0)?.fullRenderCount ?? 0) >= 1 })
            let library = BuiltScreen {
                MobileWriteScreen(session: session, postID: note.postID, router: router, tab: .library)
            }
            defer { library.tearDown() }
            #expect(await eventually { (editor(router, at: 1)?.fullRenderCount ?? 0) >= 1 })
            #expect(session.autosaveHolderCount(forPost: note.postID) == 2, "two tabs, two holds")

            // Close the stood-down shelf editor: the library's still holds.
            shelf.close()
            #expect(await eventually { session.autosaveHolderCount(forPost: note.postID) == 1 },
                    "VM-70: the closed tab's editor gave its hold back")
            #expect(session.openAutosaveCount == start + 1, "the entry stays for the open tab")
            do {
                let model = try #require(router.editors.registered.first)
                let storage = try #require(model.textView?.textStorage)
                #expect(typeEdit(model, storage, range: NSRange(location: 4, length: 0), replacement: "Z"))
                #expect(session.hasPendingAutosave,
                        "the open editor records into the registry's coordinator — every flush walk reaches it")
            }
            #expect(await eventuallyAsync {
                (try? await storedText(db, variantID: note.variantID)) == "BaseZ."
            }, "its typing lands")

            // The quick note's hold on the same note (its adopt / reset calls).
            _ = session.autosave(forPost: note.postID)
            #expect(session.autosaveHolderCount(forPost: note.postID) == 2)
            library.close()
            #expect(await eventually { session.autosaveHolderCount(forPost: note.postID) == 1 },
                    "VM-70: the last editor gave its hold back")
            #expect(session.openAutosaveCount == start + 1, "the quick note still holds the entry")
            #expect(session.releaseAutosave(forPost: note.postID),
                    "the quick note's release is the last, and it lets the entry go")
            #expect(session.openAutosaveCount == start)
        }
    }

    /// **An editor built and dropped without ever arriving gives its hold
    /// back** — the twin a view re-init would build (audit F 2D / audit C
    /// §2.16): it acquired in `init` and never sees a leaving, so the hold
    /// goes back at its end (`deinit` releases only what no leaving gave back).
    /// A plain model dropped on the main actor dies at once — no host is in the
    /// way. RED on the pre-fix tree (nothing released).
    @Test func anEditorThatNeverArrivedGivesItsHoldBack() async throws {
        try await withEditorWorld { session, _ in
            let note = try await seedNote(session)
            let start = session.openAutosaveCount
            do {
                let twin = MobileEditorViewModel(
                    session: session, postID: note.postID, sleep: { _ in throw CancellationError() })
                #expect(session.autosaveHolderCount(forPost: note.postID) == 1, "the twin acquired")
                _ = twin.postID
            }
            #expect(session.autosaveHolderCount(forPost: note.postID) == 0,
                    "VM-70: the dropped twin gave its hold back")
            #expect(session.openAutosaveCount == start)
        }
    }

    // MARK: The probes (RECORDED, never asserted) — when is a closed screen's editor freed?

    /// **RECORDED (r1's trace): at which point of a host's life a closed note
    /// screen's editor is actually freed.** The first window showed the editor
    /// still alive ten seconds after its leaving work ended, while the host
    /// lived. This reads a WEAK reference to the editor after each step — the
    /// close and its leaving work, a SwiftUI update in the live host, the
    /// window's teardown, the host let go — and prints one line:
    /// `VM70-PROBE|built-screen|…`. No assertion: it names the holder's
    /// lifetime for the record; the product no longer depends on it (r1).
    @Test func probeWhenAClosedScreensEditorIsFreed() async throws {
        try await withEditorWorld { session, db in
            let note = try await seedNote(session)
            let router = MobileShellRouter()
            weak var probe: MobileEditorViewModel?
            var screen: BuiltScreen? = BuiltScreen {
                MobileWriteScreen(session: session, postID: note.postID, router: router, tab: .library)
            }
            guard await eventually(.seconds(10), { (editor(router, at: 0)?.fullRenderCount ?? 0) >= 1 }) else {
                print("VM70-PROBE|built-screen|no-arrival")
                screen?.tearDown()
                return
            }
            probe = editor(router, at: 0)
            screen?.close()
            let leavingDone = await eventuallyAsync {
                guard router.editors.registered.isEmpty else { return false }
                return ((try? await autoCommits(db, variantID: note.variantID)) ?? 0) >= 1
            }
            try? await Task.sleep(for: .milliseconds(500))
            let afterClose = probe != nil
            screen?.surface.host.view.setNeedsLayout()
            screen?.surface.host.view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(500))
            let afterUpdate = probe != nil
            screen?.tearDown()
            try? await Task.sleep(for: .milliseconds(500))
            let afterTearDown = probe != nil
            screen = nil
            try? await Task.sleep(for: .milliseconds(500))
            let afterHostGone = probe != nil
            print("VM70-PROBE|built-screen|leaving-done=\(leavingDone)|alive-after-close=\(afterClose)"
                + "|after-update=\(afterUpdate)|after-teardown=\(afterTearDown)"
                + "|after-host-gone=\(afterHostGone)|holders=\(session.autosaveHolderCount(forPost: note.postID))")
        }
    }

    /// **RECORDED (r1's trace): the same question on HER road** — the real
    /// shell, a Library row's push onto the Library's NavigationStack, and the
    /// navigation bar's Back (UIKit's own button, through its accessibility
    /// activation). One line: `VM70-PROBE|shell-pop|…` — whether the pop was
    /// drivable here, whether the leaving finished, the note's holders after
    /// it, and whether the editor was freed while the shell's host lives. No
    /// assertion.
    @Test func probeAPoppedNotesEditorInTheShell() async throws {
        try await withEditorWorld { session, db in
            let note = try await seedNote(session, title: "Probe note")
            let router = MobileShellRouter()
            let shell = HostedSurface(MobileShellView(session: session, services: nil, router: router))
            defer { shell.tearDown() }
            await shell.settle(20)
            guard shell.activate("Library") else {
                print("VM70-PROBE|shell-pop|no-library-door")
                return
            }
            await shell.settle(20)
            let matches = shell.visibleElements.filter {
                $0.accessibilityLabel?.hasPrefix("Probe note") == true
            }
            guard let row = matches.first(where: { $0.accessibilityTraits.contains(.button) }) ?? matches.first,
                  row.accessibilityActivate()
            else {
                print("VM70-PROBE|shell-pop|no-row|labels=\(shell.visibleLabels.prefix(20).joined(separator: ","))")
                return
            }
            guard await eventually(.seconds(10), { (editor(router, at: 0)?.fullRenderCount ?? 0) >= 1 }) else {
                print("VM70-PROBE|shell-pop|no-arrival")
                return
            }
            weak var probe: MobileEditorViewModel?
            probe = editor(router, at: 0)
            await shell.settle(10)
            let back = shell.visibleElements.first {
                $0.accessibilityLabel == "Back" && $0.accessibilityTraits.contains(.button)
            }
            guard let back, back.accessibilityActivate() else {
                print("VM70-PROBE|shell-pop|no-back-door|labels=\(shell.visibleLabels.prefix(30).joined(separator: ","))")
                return
            }
            let leavingDone = await eventuallyAsync {
                guard router.editors.registered.isEmpty else { return false }
                return ((try? await autoCommits(db, variantID: note.variantID)) ?? 0) >= 1
            }
            try? await Task.sleep(for: .milliseconds(500))
            let aliveSoon = probe != nil
            try? await Task.sleep(for: .seconds(2))
            await shell.settle(10)
            let aliveLater = probe != nil
            print("VM70-PROBE|shell-pop|popped=true|leaving-done=\(leavingDone)"
                + "|holders=\(session.autosaveHolderCount(forPost: note.postID))"
                + "|editor-alive-0.5s=\(aliveSoon)|editor-alive-2.5s=\(aliveLater)")
        }
    }

    // MARK: Hazard (c) — a stood-down editor keeps working; the tab switch gets a current page

    /// **A stood-down editor keeps following the store, and taking the pen
    /// back hands it a current page.** Two tab stacks on one note through the
    /// real screens (each arrived through the open's one read and continued
    /// its live updates): typing on the live tab reaches the stood-down tab's
    /// page through its own live observation; the tab switch's
    /// `takeLiveness(refresh: true)` grants the pen over a current page; and
    /// the other direction holds the same. A guard: green on both trees.
    @Test func aStoodDownEditorKeepsWorkingAndTheTabSwitchGetsACurrentPage() async throws {
        try await withEditorWorld { session, db in
            let note = try await seedNote(session)
            let router = MobileShellRouter()
            let shelfScreen = BuiltScreen {
                MobileWriteScreen(session: session, postID: note.postID, router: router, tab: .shelf)
            }
            defer { shelfScreen.tearDown() }
            #expect(await eventually { (editor(router, at: 0)?.fullRenderCount ?? 0) >= 1 })
            let libraryScreen = BuiltScreen {
                MobileWriteScreen(session: session, postID: note.postID, router: router, tab: .library)
            }
            defer { libraryScreen.tearDown() }
            #expect(await eventually { (editor(router, at: 1)?.fullRenderCount ?? 0) >= 1 })

            let shelf = try #require(editor(router, at: 0))
            let library = try #require(editor(router, at: 1))
            let shelfStorage = try #require(shelf.textView?.textStorage)
            let libraryStorage = try #require(library.textView?.textStorage)
            #expect(!shelf.isLive && library.isLive, "the newcomer holds the pen; the other stood down")

            #expect(typeEdit(library, libraryStorage, range: NSRange(location: 4, length: 0), replacement: "L"))
            #expect(await eventually { shelfStorage.string == "BaseL." },
                    "the stood-down editor's page followed the store — it reads \(shelfStorage.string)")

            await router.editors.tabDidBecomeVisible(.shelf)
            #expect(shelf.isLive && !library.isLive, "the tab switch moved the pen")
            #expect(shelfStorage.string == "BaseL.", "and granted it over a current page")
            #expect(typeEdit(shelf, shelfStorage, range: NSRange(location: 1, length: 0), replacement: "S"))
            #expect(await eventuallyAsync {
                (try? await storedText(db, variantID: note.variantID)) == "BSaseL."
            }, "the shelf's typing lands")
            #expect(await eventually { libraryStorage.string == "BSaseL." },
                    "and the now stood-down library page follows it — it reads \(libraryStorage.string)")
            for model in [shelf, library] {
                #expect(model.identityAuditFailures == 0)
                #expect(model.desyncRecoveryCount == 0)
            }
        }
    }
}
