//
//  MobileProtectionSurfaceTests.swift
//  VariorumMobileTests
//
//  **17f/P47's mobile twin (the pre-13u round's Act 5).** The finding named
//  three surfaces with no pin at all — `ProtectionPane`, `StoreLockView` and
//  `MobileStoreLockView`; the first two got theirs in
//  `VariorumTests/ProtectionSurfaceRenderTests.swift`, and this is the phone's.
//
//  Same reason: 13p's dead-end sentence was pinned at the CONSTANT only, so
//  deleting the `Text` from the phone's locked lobby left every suite green
//  while the lobby rendered an empty room. Same mechanism as the Mac's, and it
//  is deliberately the SAME brain on both sides — `StoreLobby.deadEndMessage`
//  is Shared, so what these two pin is that each platform's face actually shows
//  what that brain says.
//
//  Reading the surface: `dump` over the real `body`. An untaken
//  `_ConditionalContent` branch is absent from it (pinned below), which is what
//  makes this a composition pin rather than a source-text grep; `dump` escapes
//  non-ASCII, so sentences are matched through `String(reflecting:)`.
//
//  **THE ROAD'S OWN LIMIT** (added 2026-08-31, the midpoint review's n1 — the
//  Mac twin's header carries the same paragraph): a composition dump proves a
//  `Text` is **COMPOSED**, not that it is **VISIBLE**. `.opacity(0)`,
//  `.hidden()`, a zero or clipped frame, or a colour matching the ground all
//  keep these pins green. What it DOES close is the hole it was built for — the
//  whole `Text` deleted, or a branch that never takes. Anything finer is a
//  screenshot question and belongs to the visual review (13s).
//
//  And one boundary this target has an answer for that the Mac does not: a
//  sentence composed inside a `GeometryReader`'s content closure is absent from
//  the dump entirely (the closure runs at layout time). The phone has a LIVE
//  accessibility tree on a hosted surface, so such a surface gets a MOUNTED pin
//  instead — `MobileEmptyStoreTests.theEmptyShelfSurfaceNamesBothRoads` is the
//  worked example, and it is the stronger measurement of the two.
//

import Foundation
import SwiftUI
import Testing

@testable import VariorumMobile
import VariorumCore

@MainActor
@Suite("13p — the phone's locked lobby shows its sentences (17f/P47)")
struct MobileProtectionSurfaceTests {
    private func composition<V: View>(of view: V) -> String {
        var out = ""
        dump(view, to: &out, maxDepth: 120)
        return out
    }

    private func carries(_ sentence: String, in composition: String) -> Bool {
        composition.contains(String(reflecting: sentence))
    }

    private func lobby(roads: Bool, unreadable: Bool = false) -> StoreLobby {
        StoreLobby(
            demand: .passphrase, biometryOffered: false, passphraseOffered: roads,
            recoveryOffered: roads, envelopeUnreadable: unreadable,
            gatedRoad: { nil },
            envelopeRoad: { _ in .failure(.init(message: "not it")) },
            complete: { _ in })
    }

    @Test func theLockedLobbyShowsItsDeadEndSentence() {
        let dead = lobby(roads: false)
        #expect(dead.noRoadExists)
        let shown = composition(
            of: MobileStoreLockView(lobby: dead, tokens: .terminalLight).body)
        #expect(carries(ProtectionCopy.deadEnd(.passphrase), in: shown),
                "the phone's locked lobby shows no dead-end sentence — an empty room")
    }

    @Test func anUnreadableSidecarShowsTheTrueCauseNotTheAbsentOne() {
        let shown = composition(
            of: MobileStoreLockView(
                lobby: lobby(roads: false, unreadable: true), tokens: .terminalLight).body)
        #expect(carries(ProtectionCopy.message(for: StoreKeyEnvelopeError.unreadable("")),
                        in: shown),
                "the unreadable-sidecar cause is computed but never reaches the phone's screen")
        #expect(!carries(ProtectionCopy.deadEnd(.passphrase), in: shown),
                "…and the false absent-wraps cause stays off it")
    }

    /// The complement — what stops the two above from passing on a face that
    /// shows nothing at all.
    @Test func theLobbyShowsItsUnlockRoadsWhenTheyExistAndNoDeadEnd() {
        let open = lobby(roads: true)
        #expect(!open.noRoadExists)
        let shown = composition(
            of: MobileStoreLockView(lobby: open, tokens: .terminalLight).body)
        #expect(carries(ProtectionCopy.lobbyPrompt(.passphrase), in: shown))
        #expect(!carries(ProtectionCopy.deadEnd(.passphrase), in: shown),
                "a library WITH a passphrase road must never show the dead end")
    }
}
