//
//  HoldBannerNoAccountWordsTests.swift
//  VariorumTests — VX-529 unit 3, the rider VX-522 (the VX-510 walk's W-5): THE HOLD BANNER'S PROMISE ON A LIBRARY THAT
//  DOESN'T SYNC. VX-473's condition is right — the banner's account clause reads the OPEN library's record
//  (`RoadStandingModel.syncsWithAnAccount`), and Make this my library lands a library that names no account, so the root
//  takes the `hasAccount: false` arm (the walk's text is that arm, verbatim). The arm's OWN words are the defect: "Sync is
//  waiting until you press Resume. To keep something from this backup, duplicate it first — duplicates stay." promises a
//  sync that never comes (Resume's round refuses — the library names no account — and the row reads "Sync isn't on for
//  this library yet"), and the duplicate advice guards against a catch-up that cannot happen. The banner speaks sync only
//  when the library's record names an account; the moment a join binds it, VX-473's re-read flips the banner to the
//  account arm, whose catch-up and duplicate lines are true then.
//  RED on the pre-fix tree. Words PROVISIONAL, hers. Planted leaves (no keychain, no network); also runs headless in the
//  implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 3 — VX-522: the hold banner's words on a library that doesn't sync", .serialized)
@MainActor
struct HoldBannerNoAccountWordsTests {
    /// **W-5 (red on old).** A library naming no account on a SIGNED-IN Mac (what Make this my library lands there): the
    /// banner the root renders from the standing faces' fact promises no sync and no catch-up, gives no duplicate advice, and
    /// says plainly what the one door does; it still names the door it sits beside.
    @Test func aLibraryThatDoesntSyncHearsNoSyncPromise() async throws {
        let (road, _, _) = PlantedAccount.road()
        road.session = PlantedAccount.signedIn
        let (session, _) = try await road.created()
        #expect(session.library.record?.account == nil, "the landed library names no account")
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel.make(session, ledger: PassphraseReminderLedger(defaults: store.defaults))
        for day in ["October 23, 2026", nil] as [String?] {
            // The root's own read (VX-473): `hasAccount: bootstrap.roadStanding?.syncsWithAnAccount ?? true`.
            let banner = LibraryOpenCopy.holdBanner(asOfDay: day, hasAccount: standing.syncsWithAnAccount ?? true)
            #expect(!banner.contains("Sync is waiting"), "no sync is waiting on a library that doesn't sync: \(banner)")
            #expect(!banner.contains("catch up") && !banner.contains("account"), "no catch-up, no account: \(banner)")
            #expect(!banner.contains("duplicate"), "no catch-up can remove anything, so no duplicate advice: \(banner)")
            #expect(banner.contains("doesn't sync") && banner.contains("Resume"),
                    "the true fact and what the door does (PROVISIONAL, hers): \(banner)")
        }
    }

    /// The ACCOUNT arm is untouched: its catch-up clause and duplicate advice are true there (a guard).
    @Test func theAccountArmKeepsItsCatchUpAndItsAdvice() {
        let banner = LibraryOpenCopy.holdBanner(asOfDay: "October 23, 2026", hasAccount: true)
        #expect(banner == "This is your library as of October 23, 2026. Sync is waiting — Resume to catch up with your "
            + "account. Notes you deleted since will leave again; edits made since will come back. To keep something from "
            + "this backup, duplicate it first — duplicates stay.")
    }
}
