//
//  OpenRuleTests.swift
//  VariorumCoreTests — VX-305 U2: the open rule (§3.7, VX-209) — every copy
//  kind against every library state. Is it ours? The family tree decides —
//  this library's own Castle-era copy after a leave reads as ours. A copy
//  never lowers the mode; a different library lands under a fresh key; a copy
//  with no record is worked out once by today's rule.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U2 — the open rule: every copy kind against every library state")
struct OpenRuleTests {
    /// A library this Mac remembers: born Standard (s0), into Castle (c1),
    /// out again (s2, history empty — the anchor holds c1 and s0).
    static func target(_ mode: ProtectionMode, account: String? = nil) -> (OpenTarget, [String: String]) {
        let s0 = "5000000000000000", c1 = "c100000000000000", s2 = "5200000000000000", c3 = "c300000000000000"
        var tree = FamilyTree()
            .recordingBirth(fingerprint: s0, kind: .standard, madeBy: CF.macA, madeAt: CF.stamp(0))
            .retiring(s0, at: CF.stamp(1))
            .recordingBirth(fingerprint: c1, kind: .castle, madeBy: CF.macA, madeAt: CF.stamp(1))
        let current: String
        if mode == .standard {
            tree = tree.retiring(c1, at: CF.stamp(2)).recordingBirth(fingerprint: s2, kind: .standard, madeBy: CF.macA, madeAt: CF.stamp(2))
            current = s2
        } else {
            tree = tree.recordingBirth(fingerprint: c3, kind: .castle, madeBy: CF.macA, madeAt: CF.stamp(3))
            current = c3
        }
        let target = OpenTarget(
            libraryID: CF.lib1, mode: mode, account: account, familyTree: tree,
            liveHistoryFingerprints: mode == .standard ? [s2] : [c3, c1, s0])
        return (target, ["s0": s0, "c1": c1, "s2": s2, "c3": c3, "current": current])
    }

    static let castlePair = LegacyKeyFileFacts(hasAppleWrap: false, hasPassphraseWrap: true)
    static let standardPair = LegacyKeyFileFacts(hasAppleWrap: true, hasPassphraseWrap: true)
    static let exposedPair = LegacyKeyFileFacts(hasAppleWrap: false, hasPassphraseWrap: false)

    @Test func thisLibrarysOwnCastleEraCopyAfterALeaveReadsAsOurs() {
        let (target, fp) = Self.target(.standard)
        let verdict = OpenRule.verdict(OpenFacts(
            libraryID: CF.lib1, keyFingerprint: fp["c1"], recordMode: .castle, target: target))
        #expect(verdict == .ownLine(OwnLineOpen(
            takesMode: .standard, flaggedForeign: false, castleEraIntoStandard: true, runsMoveRoad: false,
            reencryptsUnderCurrentKey: true)),
                "ours by the tree, opening with the passphrase or the words, taking the Standard mode, no raise")
    }

    @Test func aCopyNeverLowersTheMode() {
        let (castle, fp) = Self.target(.castle)
        // VX-209: a Standard-era copy of this library opened into Castle stays Castle.
        let verdict = OpenRule.verdict(OpenFacts(
            libraryID: CF.lib1, keyFingerprint: fp["s0"], recordMode: .standard, target: castle))
        guard case .ownLine(let open) = verdict else { Issue.record("\(verdict)"); return }
        #expect(open.takesMode == .castle && !open.flaggedForeign && open.reencryptsUnderCurrentKey)
        #expect(verdict.clearsActInFlight)
    }

    @Test func everyCopyKindAgainstEveryLibraryState() {
        for mode in ProtectionMode.allCases {
            let (target, fp) = Self.target(mode)
            // Its own current key, and an older key of its line: ours, the library's mode.
            for key in [fp["current"]!, fp["s0"]!] {
                let verdict = OpenRule.verdict(OpenFacts(libraryID: CF.lib1, keyFingerprint: key, recordMode: mode, target: target))
                guard case .ownLine(let open) = verdict else { Issue.record("\(mode) \(key): \(verdict)"); continue }
                #expect(open.takesMode == mode && !open.flaggedForeign)
            }
            // A pair of this library under a key the tree doesn't know: flagged
            // "made on another Mac, or not by you" — and a Castle one raises a
            // Standard library to Castle; it never lowers a Castle one.
            let foreignCastle = OpenRule.verdict(OpenFacts(libraryID: CF.lib1, keyFingerprint: "f000000000000000",
                                                           recordMode: .castle, target: target))
            let foreignStandard = OpenRule.verdict(OpenFacts(libraryID: CF.lib1, keyFingerprint: "f100000000000000",
                                                             recordMode: .standard, target: target))
            if mode == .standard {
                #expect(foreignCastle == .raisesToCastle)
            } else {
                #expect(foreignCastle == .ownLine(OwnLineOpen(takesMode: .castle, flaggedForeign: true,
                                                              castleEraIntoStandard: false, runsMoveRoad: false,
                                                              reencryptsUnderCurrentKey: true)))
            }
            guard case .ownLine(let flagged) = foreignStandard else { Issue.record("\(foreignStandard)"); continue }
            #expect(flagged.flaggedForeign && flagged.takesMode == mode)
            // A different library: its own mode, a fresh key, one secret then the other.
            for (pairMode, readable) in [(ProtectionMode.castle, false), (.standard, false), (.standard, true)] {
                let verdict = OpenRule.verdict(OpenFacts(
                    libraryID: CF.lib2, keyFingerprint: "d000000000000000", recordMode: pairMode,
                    opensThroughReadableAppleKey: readable, target: target))
                #expect(verdict == .differentLibrary(Landing(
                    mode: pairMode, freshKey: true,
                    secrets: pairMode == .standard && readable ? .noneThroughAppleKey : .oneSecretOtherTypedOrMadeNew,
                    mintsOwnAppleKey: pairMode == .standard, landsHeld: false, replacedLibraryGoesAside: true)))
            }
            // Plaintext exports.
            #expect(OpenRule.verdict(OpenFacts(libraryID: CF.lib1, keyFingerprint: nil, isPlaintextExport: true, target: target))
                == .plaintextExport(sameLibrary: true, mode: mode))
            #expect(OpenRule.verdict(OpenFacts(libraryID: CF.lib2, keyFingerprint: nil, isPlaintextExport: true, target: target))
                == .plaintextExport(sameLibrary: false, mode: .standard))
        }
    }

    @Test func aSyncedPairLandsHeld() {
        let verdict = OpenRule.verdict(OpenFacts(libraryID: CF.lib2, keyFingerprint: "d000000000000000",
                                                 recordMode: .castle, synced: true, target: nil))
        guard case .differentLibrary(let landing) = verdict else { Issue.record("\(verdict)"); return }
        #expect(landing.landsHeld && landing.freshKey)
    }

    @Test func aCopyWhoseRowsAreAnotherAccountsRunsTheMoveRoad() {
        let (target, fp) = Self.target(.castle, account: PF.id())
        let verdict = OpenRule.verdict(OpenFacts(libraryID: CF.lib1, keyFingerprint: fp["c1"], recordMode: .castle,
                                                 rowsAccount: PF.id(), target: target))
        guard case .ownLine(let open) = verdict else { Issue.record("\(verdict)"); return }
        #expect(open.runsMoveRoad)
    }

    /// A copy made before this change — no record — is worked out once by
    /// today's rule: an exposed-era Standard copy with no passphrase or words
    /// lands in Standard, never Castle.
    @Test func aCopyWithNoRecordIsWorkedOutByTodaysRule() {
        for (pair, expected) in [(Self.exposedPair, ProtectionMode.standard), (Self.standardPair, .standard),
                                 (Self.castlePair, .castle)] {
            let verdict = OpenRule.verdict(OpenFacts(libraryID: CF.lib2, keyFingerprint: "d000000000000000",
                                                     keyFileFacts: pair, target: nil))
            guard case .differentLibrary(let landing) = verdict else { Issue.record("\(verdict)"); continue }
            #expect(landing.mode == expected, "\(pair)")
        }
    }
}
