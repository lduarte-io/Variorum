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

@MainActor
@Suite("Mobile liveness — the authority (S3 ladder fix)")
struct MobileLivenessTests {

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
