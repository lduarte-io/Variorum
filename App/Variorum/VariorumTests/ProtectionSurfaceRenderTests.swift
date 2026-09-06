//
//  ProtectionSurfaceRenderTests.swift
//  VariorumTests
//
//  **17f/P47 (the pre-13u round's Act 5) — the protection surfaces get pins
//  that fail when the SURFACE stops saying it, not only when the constant
//  changes.**
//
//  Before this file, a grep over both test targets returned ZERO references to
//  `ProtectionPane`, `StoreLockView` or `MobileStoreLockView`. 13p's ruled
//  disclosures were pinned as STRING CONSTANTS only — `Phase13pCopySweepTests`
//  reads `ProtectionCopy.openAppIsReadable` and asserts its words under a doc
//  comment claiming "the sentence is rendered where a mode is chosen", and
//  pins `ProtectionCopy.deadEnd(_:)` the same way (the acceptance walk's own
//  catch). So deleting `Text(ProtectionCopy.openAppIsReadable)` from the pane,
//  or the dead-end `Text` from the locked lobby, left the entire repo green
//  while the app shipped without the disclosure. A pin that cannot fail is not
//  a weak test — it is a hole in the mechanism every review here depends on.
//
//  **How these read the surface, and why it is this way.** Two measurements
//  were tried first and are recorded so nobody repeats them: the hosted view's
//  ACCESSIBILITY tree is empty in this environment (`NSHostingView` reports
//  zero subviews and zero accessibility children), and `dataWithPDF` captures
//  nothing (the hosting view is layer-backed, so nothing draws through
//  `draw(_:)`). What does work is reflecting the view's own composition:
//  `dump` walks the real `body` and every `Text`'s storage string appears in
//  it — including the fact that an UNTAKEN `_ConditionalContent` branch is
//  ABSENT (verified: a lobby with roads carries no dead-end sentence), which
//  is what makes this a composition pin rather than a source-text grep. Each
//  test ALSO hosts the real view in a real window, so a surface that cannot be
//  constructed or laid out fails here too.
//
//  One mechanical note: `dump` escapes non-ASCII, so the sentences (which carry
//  typographic apostrophes) are matched through `String(reflecting:)` — the
//  same escaping — never against the raw literal.
//
//  **THE ROAD'S OWN LIMIT, recorded beside the two rejected ones** (added
//  2026-08-31, the midpoint review's n1 — a measurement road's boundary is
//  part of the measurement, and the two roads above are recorded precisely so
//  nobody re-walks them): a composition dump proves a `Text` is **COMPOSED**,
//  not that it is **VISIBLE**. `.opacity(0)`, `.hidden()`, a zero or clipped
//  frame, a colour matching the ground, or a sentence pushed outside its
//  container all keep these pins green. What the road DOES close is the hole
//  it was built for — the whole `Text` deleted, or a branch that never takes —
//  and the hosted-window half of each pin adds "and the surface can be built
//  and laid out". Anything finer than that is a screenshot question, and it is
//  the standalone visual review's (13s), not a unit test's.
//
//  One consequence worth naming, because it is where the limit bites: a
//  sentence composed inside a `GeometryReader`'s content closure is NOT in the
//  dump at all (the closure runs at layout time), so a surface shaped that way
//  needs a mounted pin instead. The phone's twin met exactly that on its shelf
//  and records what it did — a live accessibility tree, which this environment
//  does not have.
//

import AppKit
import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum SurfaceComposition {
    /// The view's own composition, as a searchable blob.
    static func text<V: View>(of view: V) -> String {
        var out = ""
        dump(view, to: &out, maxDepth: 120)
        return out
    }

    /// True when the surface carries this exact sentence.
    static func carries(_ sentence: String, in composition: String) -> Bool {
        composition.contains(String(reflecting: sentence))
    }

    /// Builds and lays the real view out in a real window — a surface that
    /// crashes or cannot lay out fails the pin that hosts it.
    static func host<V: View>(_ view: V, size: NSSize) async {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.orderOut(nil); window.close() }
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<4 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            try? await Task.sleep(for: .milliseconds(30))
        }
    }
}

@MainActor
@Suite("13p protection surfaces — what they actually SHOW (17f/P47)", .serialized)
struct ProtectionSurfaceRenderTests {
    private func controller(dials: ProtectionDials = ProtectionDials()) -> ProtectionController {
        let backing = InMemoryStoreKeyGuardBacking(
            auto: StoreKey.mint(), biometryAvailable: true, biometricSucceeds: true)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(dials), backing: backing,
            envelope: ScriptedEnvelopeBox(nil), stamps: ScriptedStampsBox())
        return ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
    }

    private func lobby(
        demand: StoreAtOpenMode = .passphrase,
        roads: Bool, unreadable: Bool = false
    ) -> StoreLobby {
        StoreLobby(
            demand: demand, biometryOffered: false, passphraseOffered: roads,
            recoveryOffered: roads, envelopeUnreadable: unreadable,
            gatedRoad: { nil },
            envelopeRoad: { _ in .failure(.init(message: "not it")) },
            complete: { _ in })
    }

    /// **The NAMED NON-GOAL stays reachable where the mode is chosen**
    /// (R13p-16's honesty debt). **RE-ANCHORED (pre-13u Act 10 wave 2a —
    /// item 3's ?-disclosure ruling, her amended copy doctrine):** the
    /// pane's paragraph stack collapsed behind one DisclosureGroup, whose
    /// collapsed content is absent from a composition dump — so this pin
    /// now asserts BOTH halves: the pane carries the always-visible
    /// essentials + the disclosure's DOOR, and the disclosure's NAMED
    /// content view (hosted directly, as its expanded state renders it)
    /// carries the moved sentences. The pin moved with the cheese; it was
    /// never deleted.
    /// pre-13x 2a — THE POSTURE PANE renders copy §1: keystone 1 as the
    /// lead, the current-state line, BOTH posture cards (name, tag,
    /// one-line, the six rows), and keystone 4 at the bottom — the named
    /// non-goal's sentence lives there now (R13p-16's honesty debt,
    /// carried by the keystone every posture shows). RED ON OLD: the pre-2a
    /// pane rendered the presets, the picker and the escrow dial, none of
    /// these sentences.
    @Test func theSettingsPaneRendersThePostureCopy() async {
        let pane = ProtectionPane(controller: controller(), services: nil)
        await SurfaceComposition.host(pane, size: NSSize(width: 620, height: 1200))
        let shown = SurfaceComposition.text(of: pane.body)
        #expect(SurfaceComposition.carries(ProtectionCopy.keystoneOneMode, in: shown))
        #expect(SurfaceComposition.carries(ProtectionCopy.currentStateLine(.standard), in: shown))
        for posture in [Posture.standard, Posture.castle] {
            #expect(SurfaceComposition.carries(ProtectionCopy.postureName(posture), in: shown))
            #expect(SurfaceComposition.carries(ProtectionCopy.postureOneLine(posture), in: shown))
            for row in ProtectionCopy.postureCard(posture) {
                #expect(SurfaceComposition.carries(row.text, in: shown),
                        "card row missing: \(posture) — \(row.label)")
            }
        }
        #expect(SurfaceComposition.carries(ProtectionCopy.keystoneOpenMeansReadable, in: shown),
                "keystone 4 — the one line every posture shows")
        // Standard shows NO Castle switch (P-2: a switch that acts nowhere).
        #expect(!SurfaceComposition.carries(ProtectionCopy.alwaysAskLabel, in: shown))
        #expect(!SurfaceComposition.carries(ProtectionCopy.lockNowLabel, in: shown))
    }

    /// **The live checklist is the pane's centerpiece** (item 3's sixth-wave
    /// deliverable (a)): the actual legs render as rows, and T2's
    /// three-value truth governs the tier sentence.
    @Test func thePaneLeadsWithTheLiveChecklist() async {
        let pane = ProtectionPane(controller: controller(), services: nil)
        await SurfaceComposition.host(pane, size: NSSize(width: 620, height: 800))
        let shown = SurfaceComposition.text(of: pane.body)
        for row in ProtectionCopy.checklistRows(
            ProtectionLegs(
                hasPassphraseWrap: false, hasRecoveryWrap: false,
                appleKeyVerified: nil, storeCustodyGated: false),
            mode: .auto
        ) {
            #expect(SurfaceComposition.carries(row.note, in: shown),
                    "checklist row missing: \(row.name)")
        }
    }

    /// (The pre-13u explainer's keystone pin retired with the explainer at
    /// pre-13x 5a — §13; the keystones live in `ProtectionCopy` and are
    /// pinned by `ProtectionCopyTests` and the tutorial spine.)

    /// The locked lobby's DEAD END says so instead of rendering an empty room.
    @Test func theLockedLobbyShowsItsDeadEndSentence() async {
        let dead = lobby(roads: false)
        #expect(dead.noRoadExists)
        let view = StoreLockView(lobby: dead)
        await SurfaceComposition.host(view, size: NSSize(width: 520, height: 480))
        #expect(SurfaceComposition.carries(ProtectionCopy.deadEnd(.passphrase),
                                           in: SurfaceComposition.text(of: view.body)),
                "the locked lobby shows no dead-end sentence — an empty room")
    }

    /// P11's true cause reaches the screen, and the false one stays off it —
    /// the ONE `deadEndMessage` brain, pinned at the surface this time.
    @Test func anUnreadableSidecarLobbyShowsTheTrueCauseNotTheAbsentOne() async {
        let view = StoreLockView(lobby: lobby(roads: false, unreadable: true))
        await SurfaceComposition.host(view, size: NSSize(width: 520, height: 480))
        let shown = SurfaceComposition.text(of: view.body)
        #expect(SurfaceComposition.carries(
            ProtectionCopy.message(for: StoreKeyEnvelopeError.unreadable("")), in: shown),
                "the unreadable-sidecar cause is computed but never reaches the screen")
        #expect(!SurfaceComposition.carries(ProtectionCopy.deadEnd(.passphrase), in: shown),
                "…and the false absent-wraps cause stays off it")
    }

    /// The complement, which is what stops these three from passing on a view
    /// that renders nothing at all: where roads EXIST, the prompt shows and the
    /// dead end is absent from the composition (SwiftUI materializes only the
    /// taken `_ConditionalContent` branch).
    @Test func theLobbyShowsItsUnlockRoadsWhenTheyExistAndNoDeadEnd() async {
        let open = lobby(roads: true)
        #expect(!open.noRoadExists)
        let view = StoreLockView(lobby: open)
        await SurfaceComposition.host(view, size: NSSize(width: 520, height: 480))
        let shown = SurfaceComposition.text(of: view.body)
        #expect(SurfaceComposition.carries(ProtectionCopy.lobbyPrompt(.passphrase), in: shown))
        #expect(!SurfaceComposition.carries(ProtectionCopy.deadEnd(.passphrase), in: shown),
                "a library WITH a passphrase road must never show the dead end")
    }
}
