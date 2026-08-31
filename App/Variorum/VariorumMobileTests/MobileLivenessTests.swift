//
//  MobileLivenessTests.swift
//  VariorumMobileTests
//
//  Mobile S3 ladder, round-1 fix pass — the liveness authority's pins:
//  the BLOCKER's text-loss round trip (one per-post coordinator + one
//  live editor anywhere), MAJOR 1's background-flush arms (the
//  registration set, never a single slot), MAJOR 2's arrival focus (the
//  window-hosted S2 pattern), and MINOR 2's two-editor voice flip.
//

import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// **THE SEAM THE INTERIOR-ARM PINS RIDE.** `AutosaveCoordinator` notifies
/// its settle observers SYNCHRONOUSLY at the tail of `flushNow`, so a
/// closure installed here runs while `takeLiveness` is still inside its
/// `await` — before the guard that follows it. That is a deterministic
/// stand-in for "a second tab tap landed mid-flight", and it is the only
/// honest one available: a real second tap would be a timing race, and a
/// pin about ordering must not itself depend on timing.
///
/// `at` counts settles within one grant: 1 is `takeLiveness`'s own flush,
/// 2 is the flush `refreshTakesFromStore` opens with.
@MainActor
private final class SupersedeOnSettle {
    private let at: Int
    private let editors: MobileLivenessAuthority
    private var seen = 0
    private(set) var fired = false

    init(at: Int, editors: MobileLivenessAuthority) {
        self.at = at
        self.editors = editors
    }

    func fire() {
        seen += 1
        guard seen == at, !fired else { return }
        fired = true
        editors.beginHandoff()
    }
}

/// Two editors on one post, one per tab — the alive-stacks shape every
/// liveness pin needs. The library editor registers last, so it holds the
/// pen when the world is handed back.
@MainActor
private func twoTabWorld(
    _ session: AppSession
) async throws -> (
    editors: MobileLivenessAuthority,
    shelf: MobileEditorViewModel, shelfStorage: NSTextStorage,
    library: MobileEditorViewModel
) {
    let post = try await session.runner.run { ops in
        try ops.createPost(title: "two tabs", profile: .blog)
    }
    _ = try await session.runner.run { ops in
        try ops.newBlock(in: post.id, text: "Base.", at: .end)
    }
    let (shelf, shelfStorage) = makeEditor(session, postID: post.id)
    let (library, _) = makeEditor(session, postID: post.id)
    let editors = MobileLivenessAuthority()
    await editors.register(shelf, tab: .shelf)
    await shelf.loadOnce()
    await editors.register(library, tab: .library)
    await library.loadOnce()
    return (editors, shelf, shelfStorage, library)
}

@MainActor
@Suite("Mobile liveness — the authority (S3 ladder fix)")
struct MobileLivenessTests {

    // MARK: The fix round — the architectural review's MAJOR 2

    /// **THE LAST REQUESTED TAB WINS, NOT THE LAST COMPLETED TASK.**
    ///
    /// The shell assigns `tab` synchronously at the tap and hands the
    /// liveness handoff to an unstructured `Task` that suspends twice on
    /// database work (a pending flush, then a fresh read). Two quick taps —
    /// Shelf → Library → Shelf — therefore left two independent tasks in
    /// the air, each carrying the tab it captured at spawn, with nothing
    /// capturing an order: whichever finished LAST installed the liveness
    /// that stood.
    ///
    /// This drives exactly that shape: two handoffs REQUESTED in order, the
    /// stale one COMPLETING last (which is what a slow flush on the leaving
    /// editor produces). Ordering is expressed through the tokens rather
    /// than by racing a real database, deliberately — a pin about ordering
    /// must not itself depend on timing to fail.
    ///
    /// Both wrong end states the review traced are held here: the visible
    /// editor stood down (*"I tap into my note and it won't let me type"*),
    /// and a HIDDEN editor holding the pen — which is the exact law this
    /// authority's own header says it exists to enforce.
    @Test func theLastRequestedTabWinsEvenWhenTheStaleHandoffLandsLast() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "two tabs", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (shelfEditor, shelfStorage) = makeEditor(session, postID: post.id)
            let (libraryEditor, libraryStorage) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(shelfEditor, tab: .shelf)
            await editors.register(libraryEditor, tab: .library)
            await shelfEditor.loadOnce()
            await libraryEditor.loadOnce()

            // Two taps, in this order: to Library, then straight back to
            // Shelf. The tokens are minted at the taps, synchronously, the
            // way the tab door mints them.
            let toLibrary = editors.beginHandoff()
            let toShelf = editors.beginHandoff()

            // The SHELF handoff completes first; the stale LIBRARY one
            // completes last — the ordering a stalled flush produces.
            await editors.tabDidBecomeVisible(.shelf, handoff: toShelf)
            await editors.tabDidBecomeVisible(.library, handoff: toLibrary)

            #expect(editors.live === shelfEditor,
                    "liveness follows the last REQUESTED tab")
            #expect(shelfEditor.isLive)
            #expect(!libraryEditor.isLive,
                    "the hidden stack's editor must not hold the pen")

            // The user-visible half, driven through the real gate: she taps
            // into the note she is LOOKING at and types.
            #expect(
                typeEdit(
                    shelfEditor, shelfStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the visible editor must accept a keystroke")
            #expect(
                !typeEdit(
                    libraryEditor, libraryStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the hidden editor's gate must refuse")
        }
    }

    /// The mirror, so neither direction is a coincidence: the same two
    /// requests with the SHELF one stale still ends with Library live.
    @Test func theMirrorHoldsToo_libraryRequestedLastKeepsThePen() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "two tabs", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (shelfEditor, _) = makeEditor(session, postID: post.id)
            let (libraryEditor, _) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(shelfEditor, tab: .shelf)
            await editors.register(libraryEditor, tab: .library)
            await shelfEditor.loadOnce()
            await libraryEditor.loadOnce()

            let toShelf = editors.beginHandoff()
            let toLibrary = editors.beginHandoff()
            await editors.tabDidBecomeVisible(.library, handoff: toLibrary)
            await editors.tabDidBecomeVisible(.shelf, handoff: toShelf)

            #expect(editors.live === libraryEditor)
            #expect(libraryEditor.isLive)
            #expect(!shelfEditor.isLive)
        }
    }

    // MARK: The INTERIOR arms (the Fable sweep's finding 7)

    /// **A GRANT SUPERSEDED WHILE IT IS SUSPENDED INSTALLS NOTHING.**
    ///
    /// The two pins above drive the AT-ENTRY `isCurrent` check: they mint
    /// both tokens up front and run the grants sequentially, so no newer
    /// request ever arrives mid-flight. The sweep's finding 7 named that
    /// honestly — the record says the token is *"checked at entry AND after
    /// every suspension"* and only the entry half was pinned. These two pins
    /// close the other half, one arm each.
    ///
    /// **Ordering is expressed through a SEAM, never a timing race** (the
    /// A2 pins' own discipline, applied to a harder shape). The seam is the
    /// coordinator's `onSettled`, which fires SYNCHRONOUSLY at the tail of
    /// `flushNow` — i.e. while `takeLiveness` is still inside its `await`
    /// and has not reached the guard that follows it. Bumping the generation
    /// from there is exactly "a second `beginHandoff` landed mid-flight",
    /// with nothing left to chance: no sleeps, no yields, no assumption
    /// about how long a database write takes.
    ///
    /// This one drives the arm after the FLUSH (`MobileLivenessAuthority`'s
    /// first post-suspension guard). The superseded grant must not hand the
    /// pen over — the second wrong end state the authority's header forbids,
    /// a HIDDEN editor holding it, is exactly what an unguarded resume
    /// produces here.
    ///
    /// **Red-on-old:** remove the two post-suspension `guard isCurrent`
    /// lines and the abandoned grant calls `noteLivenessGranted()`.
    @Test func aGrantSupersededDuringItsFlushInstallsNothing() async throws {
        try await withEditorWorld { session, _ in
            let world = try await twoTabWorld(session)
            let editors = world.editors
            #expect(!world.shelf.isLive && world.library.isLive,
                    "the library editor holds the pen before the grant")

            // The shelf's grant is requested…
            let token = editors.beginHandoff()
            // …and a NEWER request lands while it is suspended at its flush.
            let bump = SupersedeOnSettle(at: 1, editors: editors)
            let observer = world.shelf.autosave.observe(onSettled: bump.fire)
            defer { world.shelf.autosave.stopObserving(observer) }

            await editors.takeLiveness(world.shelf, refresh: true, handoff: token)

            #expect(bump.fired, "the seam really fired — this pin proves nothing otherwise")
            #expect(!world.shelf.isLive,
                    "the superseded grant must not hand the pen to the tab she left")
            #expect(!world.library.isLive,
                    "and the stood-down editor stays down — at most one is the law")
            #expect(
                !typeEdit(
                    world.shelf, world.shelfStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the abandoned grant's editor gate refuses, as a stood-down surface must")
        }
    }

    /// The SECOND interior arm: superseded during the REFRESH, after the
    /// flush guard has already passed. `refreshTakesFromStore` opens with a
    /// `flushNow` of its own, so the same seam fires a second time — inside
    /// the refresh, between the two guards. Bumping there exercises the arm
    /// the first pin cannot reach.
    ///
    /// **Red-on-old:** the same two lines.
    @Test func aGrantSupersededDuringItsRefreshInstallsNothing() async throws {
        try await withEditorWorld { session, _ in
            let world = try await twoTabWorld(session)
            let editors = world.editors

            let token = editors.beginHandoff()
            let bump = SupersedeOnSettle(at: 2, editors: editors)
            let observer = world.shelf.autosave.observe(onSettled: bump.fire)
            defer { world.shelf.autosave.stopObserving(observer) }

            await editors.takeLiveness(world.shelf, refresh: true, handoff: token)

            #expect(bump.fired,
                    "the refresh's own flush settled — the second seam really fired")
            #expect(!world.shelf.isLive,
                    "a grant superseded after its refresh installs nothing either")
            #expect(!world.library.isLive)
        }
    }

    // MARK: The BLOCKER pin — the adjudicated loss script

    /// Type in A → tab-switch inside the debounce → type in B (a second
    /// editor on the SAME post, the alive-stacks shape) → NOTHING lost.
    /// On the pre-fix mechanism (per-VM coordinators; liveness taken
    /// without the flush) B reads a stale photograph, builds on it, and
    /// its flush permanently clobbers A's typing.
    @Test func typingSurvivesTheTabSwitchRoundTrip_nothingLost() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "both tabs", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }

            // Editor A on the shelf stack.
            let (a, storageA) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(a, tab: .shelf)
            await a.loadOnce()

            // Typed in A; the debounce is held open (the harness clock
            // never fires) — exactly the state at a quick tab switch.
            typeEdit(
                a, storageA,
                range: NSRange(location: ("Base." as NSString).length, length: 0),
                replacement: " Typed-in-A.")
            #expect(a.autosave.isDirty)

            // The tab switch: no editor on the library stack yet — A
            // stands down (read-tier; its gate's liveness belt refuses).
            await editors.tabDidBecomeVisible(.library)
            #expect(!a.isLive)
            #expect(editors.live == nil)
            let refused = typeEdit(
                a, storageA,
                range: NSRange(location: 0, length: 0), replacement: "x")
            #expect(!refused, "a stood-down surface's gate refuses")
            #expect(a.statusMessage != nil, "the liveness refusal speaks")

            // Editor B opens the SAME post from the Library listing.
            // Registration takes liveness: the shared per-post coordinator
            // flushes A's pending text BEFORE B reads.
            let (b, storageB) = makeEditor(session, postID: post.id)
            #expect(b.autosave === a.autosave,
                    "one post, ONE coordinator — the N3 boundary on the phone")
            await editors.register(b, tab: .library)
            await b.loadOnce()
            #expect(storageB.string.contains("Typed-in-A."),
                    "B's surface builds on A's typing, never a stale photograph")

            // Type in B, flush — the store holds BOTH edits.
            typeEdit(
                b, storageB,
                range: NSRange(location: storageB.length, length: 0),
                replacement: " Typed-in-B.")
            await b.autosave.flushNow()
            #expect(try await storedText(db, variantID: minted.variant.id)
                    == "Base. Typed-in-A. Typed-in-B.",
                    "NOTHING typed is ever lost — the forbidden outcome refused")
        }
    }

    /// Tab re-entry (the round trip's other half): returning to a stack
    /// whose editor went stale while the other tab edited the same post
    /// re-reads fresh BEFORE granting the pen.
    @Test func tabReEntryRefreshesTheStaleSurfaceBeforeThePen() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "re-entry", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (a, storageA) = makeEditor(session, postID: post.id)
            let (b, storageB) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(a, tab: .shelf)
            await a.loadOnce()
            await editors.register(b, tab: .library)
            await b.loadOnce()

            // B edits (live); A's surface is now a stale photograph.
            typeEdit(
                b, storageB,
                range: NSRange(location: ("Base." as NSString).length, length: 0),
                replacement: " Typed-in-B.")
            #expect(storageA.string == "Base.")

            // Back to the shelf tab: A takes liveness WITH the refresh.
            await editors.tabDidBecomeVisible(.shelf)
            #expect(a.isLive)
            #expect(!b.isLive)
            #expect(storageA.string.contains("Typed-in-B."),
                    "re-entry lands the sibling's text before the next keystroke")
            _ = db
        }
    }

    // MARK: MAJOR 1 — the background flush covers every registered editor

    @Test func theBackgroundFlushCoversEveryRegisteredEditor_bothArms() async throws {
        try await withEditorWorld { session, db in
            // Two posts, one editor each — registration order A then B, so
            // a single-slot mechanism would cover only B.
            let postA = try await session.runner.run { ops in
                try ops.createPost(title: "shelf note", profile: .blog)
            }
            let mintedA = try await session.runner.run { ops in
                try ops.newBlock(in: postA.id, text: "A", at: .end)
            }
            let postB = try await session.runner.run { ops in
                try ops.createPost(title: "library note", profile: .blog)
            }
            let mintedB = try await session.runner.run { ops in
                try ops.newBlock(in: postB.id, text: "B", at: .end)
            }

            let (a, storageA) = makeEditor(session, postID: postA.id)
            let editors = MobileLivenessAuthority()
            await editors.register(a, tab: .shelf)
            await a.loadOnce()
            typeEdit(
                a, storageA,
                range: NSRange(location: 1, length: 0), replacement: " typed")
            #expect(a.autosave.isDirty)

            // Arm (a): a second editor registered LATER — the earlier one
            // must still be a flush target.
            let (b, storageB) = makeEditor(session, postID: postB.id)
            await editors.register(b, tab: .library)
            await b.loadOnce()
            typeEdit(
                b, storageB,
                range: NSRange(location: 1, length: 0), replacement: " typed")

            await performBackgroundFlush(editors: editors, sync: nil)
            #expect(try await storedText(db, variantID: mintedA.variant.id) == "A typed",
                    "arm (a): the EARLIER-registered editor's burst lands too")
            #expect(try await storedText(db, variantID: mintedB.variant.id) == "B typed")

            // Arm (b): pop the later editor — the survivor is still
            // covered (a single slot would be nil here and flush nothing).
            editors.deregister(b)
            await editors.tabDidBecomeVisible(.shelf)
            typeEdit(
                a, storageA,
                range: NSRange(location: ("A typed" as NSString).length, length: 0),
                replacement: " more")
            #expect(a.autosave.isDirty)
            await performBackgroundFlush(editors: editors, sync: nil)
            #expect(try await storedText(db, variantID: mintedA.variant.id) == "A typed more",
                    "arm (b): a pop never empties the flush coverage")
        }
    }

    // MARK: MAJOR 2 — arrival raises focus (wiring before the infinite loops)

    /// The Today door's "cold launch → typing in two taps", made true and
    /// pinned (window-hosted — the S2 focus-pin pattern): `arrive` returns
    /// with focus risen; the observation loops start AFTER it, so the
    /// raise can never sit behind a `start()` that never returns.
    @Test func arrivalRaisesFocusBeforeTheObservationLoops() async throws {
        try await withEditorWorld { session, _ in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-08-03")
            }
            let model = MobileEditorViewModel(
                session: session, postID: entry.container.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }

            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            window.addSubview(surface)
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            model.attach(textView: surface.textView)

            // The screen's exact wiring order: arrive first, loops after.
            // The wait is BOUNDED (the house pattern) so the pre-fix
            // mechanism — focus sequenced after a start() that never
            // returns — fails red instead of hanging.
            let arrival = Task { await model.arrive(focus: true) }
            var rose = false
            for _ in 0..<400 where !rose {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
                rose = surface.textView.isFirstResponder
            }
            arrival.cancel()
            #expect(rose, "arrival raises the keyboard — two taps to typing")
        }
    }

    // MARK: MINOR 2 — the voice flip reaches every registered editor

    @Test func aVoiceFlipReachesEveryRegisteredEditor() async throws {
        try await withEditorWorld { session, _ in
            let suite = "MobileLivenessTests-voice-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer {
                defaults.removePersistentDomain(forName: suite)
                MobileEditorStyle.voice = .terminal
            }
            let postA = try await session.runner.run { ops in
                try ops.createPost(title: "voiced A", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: postA.id, text: "Voiced A.", at: .end)
            }
            let postB = try await session.runner.run { ops in
                try ops.createPost(title: "voiced B", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: postB.id, text: "Voiced B.", at: .end)
            }
            let (a, storageA) = makeEditor(session, postID: postA.id)
            let (b, storageB) = makeEditor(session, postID: postB.id)
            let router = MobileShellRouter(defaults: defaults)
            await router.editors.register(a, tab: .shelf)
            await a.loadOnce()
            await router.editors.register(b, tab: .library)
            await b.loadOnce()
            #expect(!a.isLive && b.isLive, "exactly one live editor anywhere")

            // The flip window: synchronous end to end (the S1 MINOR-2
            // discipline — no suspension point between flip and asserts).
            router.setVoice(.study)
            let fontA = storageA.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            let fontB = storageB.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(fontA == MobileEditorStyle.studyFace.body,
                    "the STOOD-DOWN editor's storage follows the flip too")
            #expect(fontB == MobileEditorStyle.studyFace.body)
            router.setVoice(.terminal)
            let backA = storageA.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            let backB = storageB.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(backA == MobileEditorStyle.terminalFace.body)
            #expect(backB == MobileEditorStyle.terminalFace.body)
        }
    }
}
