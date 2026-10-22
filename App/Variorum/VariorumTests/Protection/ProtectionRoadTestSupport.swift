//
//  ProtectionRoadTestSupport.swift
//  VariorumTests — VX-306 U1b: a new-road world for the route and the backup hook — a temp slot, a THROWAWAY
//  keychain scope (`vx306-<uuid>`, purged by the test's `defer`), the real custody and memory leaves, an
//  in-memory Apple leaf (the real one is the opt-in suite's), no biometry, the fast KDF; and the bootstrap's
//  test harness (the keyed opener over the temp slot).
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
final class RoadWorld {
    let slot = TempSlot()
    let scope = ThrowawayScope()
    let apple = InMemoryAppleKeysLeaf()
    var custody: (any CustodyLeaf)?
    var biometry = FixedBiometryLeaf(.none)

    func system() -> ProtectionSystem {
        ProtectionSystem(
            scope: scope.scope, places: slot.places, deviceName: "Test Mac", floor: .relaxedForTests,
            custody: custody, apple: apple, biometry: biometry, ids: FastIDsLeaf())
    }

    func context(writes: Bool = true) -> RoadContext {
        RoadContext(system: system(), session: .signedOut, writes: writes)
    }

    var slotURL: URL { slot.places.slot }

    func harness(writes: Bool = true) -> ProtectionRoadTestHarness {
        let url = slotURL
        return ProtectionRoadTestHarness(system: system(), writes: writes, open: { key in
            Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                .mapError { $0 as? AppDatabase.StoreOpenError
                    ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
        })
    }

    /// A new-road bootstrap over this world (today's opener is never taken on the new road).
    func bootstrap(writes: Bool = true) -> AppBootstrap {
        AppBootstrap(
            testStoreURL: slotURL,
            protectionRoad: harness(writes: writes))
    }

    /// A library created on the new road, its session and its twelve words.
    func created() async throws -> (session: ProtectionRoadSession, words: [String]) {
        guard case .created(let session, let words) = await ProtectionOpenRoad.create(context(), setAsideLiveKeyFile: false)
        else { throw RoadWorldError.notCreated }
        return (session, words.words)
    }

    enum RoadWorldError: Error { case notCreated }
}

/// The `.ready` arm builds an `AppSession`, which reads the injected clock (the 13p lobby suites' pattern).
@MainActor
func withRoadDependencies<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
    try await withDependencies {
        $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        $0.uuid = .incrementing
    } operation: { @MainActor in
        try await body()
    }
}
