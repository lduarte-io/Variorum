//
//  MobileRoundOccasionTests.swift
//  VariorumMobileTests
//
//  THE PHONE'S OCCASION BEFORE EVERY ROUND (the VX-849 run, batch 2 — the record
//  `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 2 RECORD + BATCH 2 ADJUDICATION). The phone composes the SAME one
//  `beforeRound` closure as the Mac (`AppServices.init`):
//    - P-849-2 (batch 1's adjudication item 3): its page, takes browser and quick note record into the same autosave
//      registry, so batch 1's flush occasion (VX-683 A — her pending typing lands before the round's pull) serves it;
//    - PROVISIONAL P-849-3 (the batch 2 adjudication, RULED (c)): the shared typed-unlock load keeps the derived secret on
//      the phone too, so the phone's RETRY is wired — the held secret's consumer, run FIRST, while the provider has no keys.
//  (A JUSTIFIED EDIT of this file's first pin, `thePhonesOccasionLandsPendingTypingAndRunsNoRetry`, which asserted the
//  phone ran NO retry under the posture P-849-3 replaced.)
//
//  RED ON OLD: on the pre-fix tree the phone composed no occasion (`beforeRound` nil — the `#require` fails: behavior-red),
//  and the roads' type does not exist (the file is compile-red as a whole); the record's revert R-3g (the phone composing no
//  occasion) reds it.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("P-849-2 / P-849-3 — the phone's occasion before every round: the typed-unlock retry first, then her typing")
struct MobileRoundOccasionTests {
    @Test func thePhonesOccasionRetriesThePendingLoadThenLandsHerTyping() async throws {
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
            let log = LockIsolated<[String]>([])
            services.typedUnlockSyncKeys = TypedUnlockSyncKeysRoads(
                isPending: { true },
                retry: {
                    let typing = coordinator.isDirty ? "retry: typing pending" : "retry: typing landed"
                    log.withValue { $0.append(typing) }
                },
                clear: { log.withValue { $0.append("clear") } },
                letGo: { log.withValue { $0.append("letGo") } })

            let occasion = try #require(services.sync.beforeRound, "the phone composes the occasion")
            await occasion()

            #expect(log.value == ["retry: typing pending"], "the phone's retry ran first, keys missing — \(log.value)")
            #expect(!coordinator.isDirty, "then her typing landed before the round")
            #expect(try await storedText(db, variantID: made.variant.id) == "Base. Typed.")
            services.stop()
        }
    }
}
