//
//  PaneOutsideWriteRuleTests.swift
//  VariorumTests
//
//  VX-664 (the VX-677 run, batch 1 — the record `notes/plans/fixes/
//  vx-677-editor-panes-ai-door.md`, BATCH 1 RECORD): THE RULE, as tests. Her
//  ruling (option (a), scoped): the ring ends ONLY when an outside write lands
//  on the live pane's OWN take; P-3's buffer authority never bends; no
//  clean-buffer adoption. The architect's A-677-1: the store's own delivery is
//  the signal, and ONE pure rule in `PaneTextAuthority` decides —
//  `settle(isPending:liveIncoming:)` names the live pane as a SUSPECT when the
//  delivered stored words of its take differ from what it holds while nothing
//  of hers is pending; `confirmsOutsideWrite` decides again against a fresh
//  read.
//
//  RED ON OLD (`rev664` — the rule neutralized): the pins marked so. The rest
//  are guards (green on both sides): the cases the rule must NOT fire on —
//  her own typing, her pending typing, her own NUL paste, a delivery that does
//  not carry the take, nothing live, a photograph the fresh read dispels.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-664 — the outside-write rule (A-677-1)")
struct PaneOutsideWriteRuleTests {
    private let pane = PaneTextAuthority.PaneKey(columnID: "main", blockID: "b1", variantID: "v1")
    private let other = PaneTextAuthority.PaneKey(columnID: "fan", blockID: "b1", variantID: "v2")
    private let nothingPending: (String) -> Bool = { _ in false }

    /// **RED ON OLD — an outside write on the live pane's own take is
    /// suspected**, and the fresh read confirms it.
    @Test func anOutsideWriteOnTheLiveTakeIsSuspectedAndConfirmed() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "Her words as the pane showed them.")
        let suspect = authority.settle(
            isPending: nothingPending, liveIncoming: "An AI's edit of the take.")
        #expect(suspect == pane, "RED ON OLD: the delivery's stored words moved under the ring")
        #expect(authority.confirmsOutsideWrite(
            pane, storedText: "An AI's edit of the take.", isPending: nothingPending),
                "RED ON OLD: the fresh read confirms it")
    }

    /// **RED ON OLD — her typing, then an outside write that landed after her
    /// autosave**: what the pane holds is her last keystroke, and the store
    /// now holds somebody else's words.
    @Test func anOutsideWriteAfterHerLandedTypingIsSuspected() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "Before.")
        authority.bufferEdited(variantID: "v1", text: "Before. She typed.")
        let suspect = authority.settle(
            isPending: nothingPending, liveIncoming: "A restore from Block History.")
        #expect(suspect == pane, "RED ON OLD")
    }

    /// GUARD — her own landed typing is never somebody else's write: the echo
    /// carries exactly the words her pane holds.
    @Test func herOwnLandedTypingIsNeverSuspected() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "Before.")
        authority.bufferEdited(variantID: "v1", text: "Before. She typed.")
        #expect(authority.settle(isPending: nothingPending, liveIncoming: "Before. She typed.") == nil)
        #expect(authority.buffers.isEmpty, "the settle half still drops the landed buffer")
        // …and the next delivery of the same words, buffer gone, still holds.
        #expect(authority.settle(isPending: nothingPending, liveIncoming: "Before. She typed.") == nil)
    }

    /// GUARD — while her typing on the take is PENDING the buffer is
    /// authoritative: nothing is judged (the flush-first rule and the bracket
    /// savepoints insure the roads that meet it; VX-683 is the one that can't).
    @Test func aPendingTakeIsNeverSuspected() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "Before.")
        authority.bufferEdited(variantID: "v1", text: "Before. Still typing")
        let suspect = authority.settle(
            isPending: { $0 == "v1" }, liveIncoming: "Somebody else's words.")
        #expect(suspect == nil)
        #expect(authority.buffers["v1"] == "Before. Still typing", "the pending buffer stays")
    }

    /// GUARD — her own pasted U+0000: the autosave stores the text without
    /// it (`StoredText.stripped`), and that echo is still hers.
    @Test func herOwnNullCharacterPasteIsNeverSuspected() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "Before.")
        authority.bufferEdited(variantID: "v1", text: "Before.\u{0000} Pasted.")
        #expect(authority.settle(isPending: nothingPending, liveIncoming: "Before. Pasted.") == nil)
    }

    /// GUARD — a delivery that does not carry the live take judges nothing,
    /// and nothing live judges nothing.
    @Test func aDeliveryWithoutTheTakeOrWithNothingLiveJudgesNothing() {
        var authority = PaneTextAuthority()
        #expect(authority.settle(isPending: nothingPending, liveIncoming: "anything") == nil)
        authority.focus(pane, showing: "Before.")
        #expect(authority.settle(isPending: nothingPending, liveIncoming: nil) == nil)
        authority.blur()
        #expect(authority.settle(isPending: nothingPending, liveIncoming: "Changed.") == nil)
    }

    /// GUARD — a focus that passed nothing knows nothing: the first delivery
    /// is the BASELINE, never a verdict; the next one is judged against it.
    @Test func aFocusWithNoTextTakesTheFirstDeliveryAsItsBaseline() {
        var authority = PaneTextAuthority()
        authority.focus(pane)
        #expect(authority.settle(isPending: nothingPending, liveIncoming: "As stored.") == nil)
        #expect(authority.liveHeld == "As stored.")
        #expect(authority.settle(isPending: nothingPending, liveIncoming: "Changed.") == pane)
    }

    /// GUARD — a PHOTOGRAPH fetched before her own write landed (the 13e E15
    /// class) can be suspected, and the fresh read dispels it: her ring is
    /// never ended on stale words.
    @Test func aPhotographFromBeforeHerWriteIsDispelledByTheFreshRead() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "Before.")
        authority.bufferEdited(variantID: "v1", text: "Before. She typed.")
        let suspect = authority.settle(isPending: nothingPending, liveIncoming: "Before.")
        #expect(suspect == pane, "a stale photograph reads as a change")
        #expect(!authority.confirmsOutsideWrite(
            pane, storedText: "Before. She typed.", isPending: nothingPending),
                "the fresh read holds her words — no ring ends")
    }

    /// GUARD — the confirmation is about THIS pane, still live, still clean: a
    /// ring that moved, a blur, or her typing in the gap each decline it.
    @Test func theConfirmationDeclinesAMovedRingABlurOrHerTypingInTheGap() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "Before.")
        let suspect = authority.settle(isPending: nothingPending, liveIncoming: "Changed.")
        #expect(suspect == pane)
        #expect(!authority.confirmsOutsideWrite(pane, storedText: "Changed.", isPending: { $0 == "v1" }),
                "her keystroke in the gap: the buffer is authoritative again")
        authority.focus(other, showing: "The other take.")
        #expect(!authority.confirmsOutsideWrite(pane, storedText: "Changed.", isPending: nothingPending),
                "the ring moved on")
        authority.blur()
        #expect(!authority.confirmsOutsideWrite(other, storedText: "Changed.", isPending: nothingPending),
                "nothing is live")
    }

    /// GUARD — what the pane holds is the LIVE pane's: a migration re-bases
    /// it, a re-focus of the live pane keeps it, a blur forgets it, and a
    /// read pane's buffer never moves it.
    @Test func whatThePaneHoldsFollowsTheRingOnly() {
        var authority = PaneTextAuthority()
        authority.focus(pane, showing: "First take.")
        authority.bufferEdited(variantID: "v1", text: "First take, typed.")
        #expect(authority.focus(pane, showing: "ignored") == .unchanged)
        #expect(authority.liveHeld == "First take, typed.")
        authority.bufferEdited(variantID: "v9", text: "a buffer that is not the live take's")
        #expect(authority.liveHeld == "First take, typed.")
        authority.focus(other, showing: "Second take.")
        #expect(authority.liveHeld == "Second take.")
        authority.blur()
        #expect(authority.liveHeld == nil)
    }
}
