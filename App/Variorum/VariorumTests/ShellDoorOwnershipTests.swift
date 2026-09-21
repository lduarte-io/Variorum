//
//  ShellDoorOwnershipTests.swift
//  VariorumTests
//
//  13u4 UNIT S3 — **KnownIssues row 46's surviving item.** The shell's
//  block-naming DEBUG door was one bare `static var` that every `RootView`
//  mount OVERWROTE and exactly one of eight test mount sites cleared.
//
//  **The mechanism, stated as a defect rather than as untidiness** (the
//  hallucination guard's architectural arm — this is latent, so it is traced
//  and written down rather than caught by a red pin): a shell that has been
//  torn down leaves its closure standing in a process-global, and that
//  closure captured THAT shell's `router` and `session`. Anything reading
//  the global afterwards therefore drives a DEAD shell — it navigates a
//  router nobody is showing and parks a landing nobody will consume. It was
//  green only because the pin that reads it mounts its own shell LAST, so
//  the last publisher happened to be the right one; that is an ordering
//  accident, not a guarantee, and the adverse order is one test-file
//  reshuffle away.
//
//  **The fix is UNIT S2's idea at a third site** (the two stamp oracles were
//  the same shape — *a registration keyed by its subject with no record of
//  who registered it*): the registrant names itself (a `RootView` publishes
//  under its own `windowID`), and a teardown clears only what it still owns.
//  These pins hold the two rules that follow from that.
//

import Foundation
import Testing
@testable import Variorum

@Suite("The shell's DEBUG door names its owner (13u4 UNIT S3, row 46)")
@MainActor
struct ShellDoorOwnershipTests {
    private func reset() { ShellRouter.forgetBlockNamingDoors() }

    /// RULE ONE: the read answers from the most recent registrant — which is
    /// what a pin that has just mounted a shell means by "the door".
    @Test func theDoorAnswersFromTheMostRecentShell() {
        reset()
        defer { reset() }
        var spoke: [String] = []
        let first = UUID(), second = UUID()
        ShellRouter.publishBlockNamingDoor(owner: first) { _, _ in spoke.append("first") }
        ShellRouter.publishBlockNamingDoor(owner: second) { _, _ in spoke.append("second") }
        ShellRouter.blockNamingDoor?(.library, nil)
        #expect(spoke == ["second"])
    }

    /// RULE TWO, and the row's own defect: a shell LEAVING clears only its
    /// own registration. The second window's door survives the first
    /// window's teardown — and, the same fact from the other side, a
    /// torn-down shell's closure never stands over a live one.
    @Test func aDepartingShellClearsOnlyWhatItStillOwns() {
        reset()
        defer { reset() }
        var spoke: [String] = []
        let first = UUID(), second = UUID()
        ShellRouter.publishBlockNamingDoor(owner: first) { _, _ in spoke.append("first") }
        ShellRouter.publishBlockNamingDoor(owner: second) { _, _ in spoke.append("second") }

        // The SECOND window leaves: the first's door is standing again.
        ShellRouter.releaseBlockNamingDoor(owner: second)
        ShellRouter.blockNamingDoor?(.library, nil)
        #expect(spoke == ["first"])

        // The FIRST leaves too: nothing is published, and the global holds
        // no closure over a shell that is gone.
        ShellRouter.releaseBlockNamingDoor(owner: first)
        #expect(ShellRouter.blockNamingDoor == nil)
    }

    /// A release from an owner that never published, or twice from one that
    /// did, is a no-op — a teardown must never be order-sensitive.
    @Test func releasingWhatYouDoNotOwnIsANoOp() {
        reset()
        defer { reset() }
        let mine = UUID()
        ShellRouter.publishBlockNamingDoor(owner: mine) { _, _ in }
        ShellRouter.releaseBlockNamingDoor(owner: UUID())
        #expect(ShellRouter.blockNamingDoor != nil, "a stranger's teardown took nothing")
        ShellRouter.releaseBlockNamingDoor(owner: mine)
        ShellRouter.releaseBlockNamingDoor(owner: mine)
        #expect(ShellRouter.blockNamingDoor == nil)
    }

    /// Re-publishing under the SAME owner replaces rather than stacks — a
    /// shell whose body re-runs must not leave a queue of its own past
    /// selves behind the current one.
    @Test func republishingUnderOneOwnerReplacesRatherThanStacks() {
        reset()
        defer { reset() }
        var spoke: [String] = []
        let mine = UUID()
        ShellRouter.publishBlockNamingDoor(owner: mine) { _, _ in spoke.append("old") }
        ShellRouter.publishBlockNamingDoor(owner: mine) { _, _ in spoke.append("new") }
        ShellRouter.blockNamingDoor?(.library, nil)
        ShellRouter.releaseBlockNamingDoor(owner: mine)
        #expect(spoke == ["new"])
        #expect(ShellRouter.blockNamingDoor == nil, "one release, and it is gone")
    }
}
