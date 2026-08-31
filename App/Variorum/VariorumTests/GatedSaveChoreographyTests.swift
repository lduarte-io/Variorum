//
//  GatedSaveChoreographyTests.swift
//  VariorumTests
//
//  17h (13p-fix ladder R2-7) — the gated save's delete-before-add window,
//  narrowed to probe width. The delete-then-add order is FORCED (updating
//  an ACL'd item demands interactive auth; a write must never prompt),
//  and pre-fix a `SecItemAdd` failing AFTER the forced delete left ZERO
//  gated custody — reached from `DeviceKeyStore.save` whenever a gated
//  item exists (a passphrase re-unwrap's re-save). The KnownIssues row's
//  swap remedy is unsound under the same never-prompt rule (renaming an
//  ACL'd item is an update too), so the fix is probe-first: prove an
//  identical ACL'd add lands RIGHT NOW, and only then release the
//  existing item.
//
//  RED-ON-OLD (behavioral revert, the R3-1 rule — revert the outcome,
//  keep the seam): with `run`'s body reverted to the pre-fix shape
//  (`_ = releaseExisting(); return addIncoming()`), the first pin reds
//  with the existing custody GONE — the traced zero-custody end state —
//  while the residual-window pin stays green (it is true on both trees,
//  which is exactly why it is documented as the surviving window and not
//  claimed as fixed).
//
//  Scripted closures only — no Keychain anywhere in this file. The real
//  leaves' end-to-end evidence is `Phase13pKeychainFactTests`' round
//  trips (throwaway scope, signed host).
//

import Foundation
import Testing

@testable import Variorum

@Suite("17h — the gated save probes before it releases (R2-7)")
struct GatedSaveChoreographyTests {
    /// A tiny scripted keychain: one existing gated item, adds that can
    /// be scripted to fail — the R2-7 world in four closures.
    private final class ItemBox: @unchecked Sendable {
        var existing: String? = "the-old-item"
        var addsSucceed = true
        var order: [String] = []
    }

    private func run(_ box: ItemBox) -> Bool {
        GatedSaveChoreography.run(
            sweepProbe: { box.order.append("sweep") },
            addProbe: { box.order.append("addProbe"); return box.addsSucceed },
            releaseExisting: {
                box.order.append("release")
                box.existing = nil
                return true
            },
            addIncoming: {
                box.order.append("addIncoming")
                guard box.addsSucceed else { return false }
                box.existing = "the-new-item"
                return true
            })
    }

    /// THE RED-ON-OLD PIN. Adds failing for a stable reason — a keychain
    /// identity regression, disk, securityd, biometry state — is exactly
    /// the failure the probe sees first. Pre-fix (delete-then-add) the
    /// release ran and the add failed: zero custody, which is the traced
    /// end state the drill reproduces. Post-fix the probe refuses before
    /// anything is released.
    @Test func anAddFailureRefusesBeforeTheOnlyCustodyIsReleased() {
        let box = ItemBox()
        box.addsSucceed = false

        #expect(run(box) == false)
        #expect(box.existing == "the-old-item",
                "the only gated custody survives the refusal")
        #expect(!box.order.contains("release"),
                "nothing is released on a keychain that refuses adds")
    }

    /// The order IS the fix: the probe strictly precedes the release, and
    /// the probe item is swept on both sides of its add (leading — a
    /// crashed prior run's litter; trailing — this run's own).
    @Test func theProbePrecedesTheReleaseAndSweepsItself() {
        let box = ItemBox()
        #expect(run(box))
        #expect(box.order == ["sweep", "addProbe", "sweep", "release", "addIncoming"])
        #expect(box.existing == "the-new-item")
    }

    /// A refused RELEASE stops the save with the existing custody intact
    /// (the R3-5 released-semantics, consulted here too — pre-17h the
    /// leaves could not even see this refusal).
    @Test func aRefusedReleaseStopsTheSaveWithCustodyIntact() {
        let box = ItemBox()
        let ok = GatedSaveChoreography.run(
            sweepProbe: {},
            addProbe: { true },
            releaseExisting: { false },
            addIncoming: {
                Issue.record("the add must not run over an unreleased item")
                return true
            })
        #expect(ok == false)
        #expect(box.existing == "the-old-item")
    }

    /// THE SURVIVING WINDOW, pinned as documented behavior — NOT a claim
    /// of fix: an add that succeeds at the probe and fails milliseconds
    /// later at the real add still strands (the existing item was
    /// released on the probe's evidence). This is the residue the entry's
    /// disposition records: a transient between two identical adds, plus
    /// the crash-between-syscalls window that always existed. When it
    /// fires, the material is in hand at the caller, the surfaces word
    /// the refusal, and the vault re-derives by passphrase.
    @Test func aFailureBetweenTheTwoAddsStillStrandsAndThatIsRecorded() {
        let box = ItemBox()
        let ok = GatedSaveChoreography.run(
            sweepProbe: {},
            addProbe: { true },
            releaseExisting: { box.existing = nil; return true },
            addIncoming: { false })  // the transient: probe landed, real add refused
        #expect(ok == false)
        #expect(box.existing == nil,
                "the residual window's end state — recorded, not claimed fixed")
    }
}
