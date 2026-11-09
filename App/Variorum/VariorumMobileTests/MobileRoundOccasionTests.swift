//
//  MobileRoundOccasionTests.swift
//  VariorumMobileTests
//
//  P-849-2 (the VX-849 run, batch 2 — the record `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 2 RECORD; batch 1's
//  adjudication item 3): THE PHONE'S OCCASION BEFORE EVERY ROUND. The phone's page, takes browser and quick note record
//  into the same autosave registry as the Mac's surfaces, so batch 1's flush occasion (VX-683 A — her pending typing lands
//  before the round's pull) is the same one line on the phone's composition (`AppServices.init`). VX-544's typed-unlock
//  retry stays the Mac's: the phone's occasion runs no retry, whatever the roads say (D-544's phone posture).
//
//  RED ON OLD: on the pre-fix tree the phone composed no occasion (`beforeRound` nil — the `#require` fails: behavior-red),
//  and the roads' type does not exist (the file is compile-red as a whole); the record's revert re-fences the phone's line.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("P-849-2 — the phone's occasion before every round: her typing lands first, no typed-unlock retry")
struct MobileRoundOccasionTests {
    @Test func thePhonesOccasionLandsPendingTypingAndRunsNoRetry() async throws {
        try await withEditorWorld { session, db in
            let auth = AuthSession(
                configuration: AuthConfiguration(projectURL: URL(string: "https://p8492.invalid")!, apiKey: "k"),
                store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
            let services = AppServices(
                session: session, storeVariant: .real, backupEnabled: false, auth: auth,
                makeSyncKeyProvider: { UnenrolledKeyProvider() }, legacyCleanup: {})
            let post = try session.operations.createPost(title: "phone typing")
            let made = try session.operations.newBlock(in: post.id, text: "Base.", registeringUndo: false)
            let coordinator = session.autosave(forPost: post.id, sleep: { _ in throw CancellationError() })
            coordinator.record(variantID: made.variant.id, text: "Base. Typed.", charDelta: 7, basedOn: "Base.")
            #expect(coordinator.isDirty, "fixture: typing is pending")
            let retries = LockIsolated(0)
            services.typedUnlockSyncKeys = TypedUnlockSyncKeysRoads(
                isPending: { true }, retry: { retries.withValue { $0 += 1 } }, clear: {}, letGo: {})

            let occasion = try #require(services.sync.beforeRound, "the phone composes the typing occasion (P-849-2)")
            await occasion()

            #expect(!coordinator.isDirty, "her typing landed before the round")
            #expect(try await storedText(db, variantID: made.variant.id) == "Base. Typed.")
            #expect(retries.value == 0, "the phone's typed-unlock retry stays unwired")
            services.stop()
        }
    }
}
