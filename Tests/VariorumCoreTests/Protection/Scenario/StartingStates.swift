//
//  StartingStates.swift
//  VariorumCoreTests — VX-378 U1: THE STARTING STATES, made by the app's own
//  doors. Rule 26 (`notes/CastleRules.md`: "we don't migrate stores from before
//  this design, and we don't handle them") took today's shapes and the older
//  build with it, so every world here begins the way a person's would: a
//  library created on this build, then — where the state says so — Use Castle,
//  sync turned on, a second device joining. The builders run the world's own
//  actions (`apply`), so the truth bookkeeping is the acts' own, and close every
//  app at the end (a starting state is a closed app).
//
//  U1's list is the cut's stand-in; U4 rewrites it to the rules' shapes ("a
//  fresh library; Standard with and without a passphrase; Castle Touch ID and
//  Always ask; synced variants; a Castle backup after a leave; a lagging
//  device" — the corrector plan §4).
//

import CryptoKit
import Foundation

@testable import VariorumCore

/// A builder step refused or crashed.
struct StartingStateRefused: Error, CustomStringConvertible {
    var description: String
}

extension SWorld {
    /// One builder step: applied, and it must be done.
    func build(_ action: Action) async throws {
        let result = await apply(action)
        guard result == .done else { throw StartingStateRefused(description: "\(action) → \(result)") }
    }

    /// A library created on `device` by the app's own door — always with twelve
    /// words (rule 2), with a passphrase unless `passphrase: false` (rule 3's
    /// "until a passphrase exists") — then, in Castle, Use Castle with `gate`,
    /// and that choice recorded in this Mac's settings by a Settings press
    /// (Use Castle's own press records no gate style — a gap in the kept
    /// machinery the today-shaped states hid by presetting it; VX-378 U1's
    /// record hands it forward). Its app is closed at the end.
    func fresh(on device: SDevice, mode: ProtectionMode = .standard, gate: GateStyle = .touchID, passphrase: Bool = true) async throws {
        let p = passphrase ? newPassphrase() : nil
        let executor = newExecutor(device, libraryID: "")
        let created = try executor.createLibrary(passphrase: p)
        let library = created.library, w = created.words
        device.executor = executor
        device.library = library
        setKnown(holder(device, account: nil, libraryID: library.record!.libraryID), passphrase: p, words: w)
        if mode == .castle {
            try await build(.useCastle(device.name, gate, newWords: false))
            if device.library?.section.settings.gateStyle != gate { try await build(.setGate(device.name, gate)) }
        }
        lock(device)
    }

    /// An account in `mode` with `devices` each holding its own library: the
    /// first turns sync on (the account takes its library's pair — rule 7) and,
    /// in Castle, enters it; each other device creates its library and joins
    /// (in Castle, the join is its entry). iCloud Keychain settled, every app
    /// closed at the end.
    func freshAccount(_ account: String, mode: ProtectionMode, devices: [SDevice], gate: GateStyle = .touchID) async throws {
        guard let first = devices.first else { return }
        try await fresh(on: first)
        try await build(.signIn(first.name, account: account))
        try await build(.turnOnSync(first.name))
        if mode == .castle {
            try await build(.useCastle(first.name, gate, newWords: false))
            if first.library?.section.settings.gateStyle != gate { try await build(.setGate(first.name, gate)) }
        }
        propagateAll()
        for device in devices.dropFirst() {
            try await fresh(on: device)
            try await build(.signIn(device.name, account: account))
            try await build(.turnOnSync(device.name))
            if mode == .castle, device.library?.section.settings.gateStyle != gate { try await build(.setGate(device.name, gate)) }
        }
        propagateAll()
        for device in devices { lock(device) }
    }

    /// The account's master, through the passphrase she knows for it.
    func accountMaster(_ account: String) -> SymmetricKey? {
        guard let vault = server.snapshot(account), let p = known(account).passphrase,
              let pk = passphraseKey(p, vault.vault.kdf) else { return nil }
        return vault.vault.master(passphrase: pk, words: nil)
    }
}

/// A starting state: a name and how the world is built.
struct StartingState: CustomStringConvertible, Sendable {
    var name: String
    var build: @Sendable (SWorld) async throws -> Void
    var description: String { name }

    /// U1's new-system shapes (U4 rewrites the list to the rules).
    static let all: [StartingState] = [
        StartingState(name: "a fresh Standard library") { w in try await w.fresh(on: w.macA) },
        StartingState(name: "a fresh Standard library with no passphrase") { w in try await w.fresh(on: w.macA, passphrase: false) },
        StartingState(name: "Castle with Touch ID") { w in try await w.fresh(on: w.macA, mode: .castle, gate: .touchID) },
        StartingState(name: "Castle, Always ask") { w in try await w.fresh(on: w.macA, mode: .castle, gate: .alwaysAsk) },
        StartingState(name: "a synced Standard account on two Macs") { w in
            try await w.freshAccount(w.rng.uuid(), mode: .standard, devices: [w.macA, w.macB])
        },
        StartingState(name: "a synced Castle account on two Macs and the phone") { w in
            try await w.freshAccount(w.rng.uuid(), mode: .castle, devices: [w.macA, w.macB, w.phone], gate: .alwaysAsk)
        },
        StartingState(name: "two Macs sharing an iCloud Drive backup folder") { w in
            try await w.fresh(on: w.macA)
            try await w.fresh(on: w.macB, mode: .castle, gate: .touchID)
            w.macA.farFolderAccount = SWorld.appleA
            w.macB.farFolderAccount = SWorld.appleA
        },
    ]
}
