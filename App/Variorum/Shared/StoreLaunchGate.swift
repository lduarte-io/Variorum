//
//  StoreLaunchGate.swift
//  Variorum (shared: Mac + Mobile — the lobby's BRAIN; the Mac's face is
//  StoreLockView this batch, the phone's arrives in Batch 4)
//
//  Phase 13p, Batch 2 — the locked lobby (THE DESIGN's keyed-stack
//  paragraph): in the demanded modes NOTHING runs before unlock — no
//  migrations, no sync round, no bridge round, no purge janitor. The
//  mechanism is structural, not a splash screen: the launch ROUTES
//  before any store file is opened, and the demanded routes stop at a
//  `StoreLobby` state that holds no store, no session, and no services —
//  everything downstream exists only inside `.ready`, which the lobby's
//  successful unlock is the only door into. The one pre-unlock file
//  contact is the 16-byte presence classification (routing needs to know
//  absent-vs-present); the migration itself is provably deferred
//  (`Phase13pLobbyTests` pins a plaintext fixture staying plaintext
//  behind a demanded route).
//

import Foundation
import Observation
import VariorumCore

/// The injectable launch-protection facts (production reads the real
/// defaults/Keychain/sidecar; tests script all three).
nonisolated struct StoreLaunchGate: Sendable {
    var dials: @Sendable (_ scope: String) -> ProtectionDials
    var saveDials: @Sendable (ProtectionDials, _ scope: String) -> Void
    var guardFor: @Sendable (_ scope: String) -> StoreKeyGuard
    var loadEnvelope: @Sendable (_ storeURL: URL) throws -> StoreKeyEnvelope?

    static let live = StoreLaunchGate(
        dials: { ProtectionDefaults.dials(scope: $0, in: .standard) },
        saveDials: { ProtectionDefaults.save($0, scope: $1, in: .standard) },
        guardFor: { StoreKeyGuard.keychain(scope: $0) },
        loadEnvelope: { try StoreKeyEnvelope.load(at: StoreKeyEnvelope.url(besideStore: $0)) })

    /// A scripted gate for tests: fixed dials + an in-memory guard + an
    /// in-memory envelope box.
    static func scripted(
        dials: ProtectionDials,
        backing: InMemoryStoreKeyGuardBacking,
        envelope: StoreKeyEnvelope? = nil
    ) -> StoreLaunchGate {
        let box = ScriptedEnvelopeBox(envelope)
        return StoreLaunchGate(
            dials: { _ in dials },
            saveDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: backing) },
            loadEnvelope: { _ in box.value })
    }
}

nonisolated final class ScriptedEnvelopeBox: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: StoreKeyEnvelope?
    init(_ initial: StoreKeyEnvelope?) { stored = initial }
    var value: StoreKeyEnvelope? {
        get { lock.lock(); defer { lock.unlock() }; return stored }
        set { lock.lock(); defer { lock.unlock() }; stored = newValue }
    }
}

/// Where a launch goes, decided BEFORE any store open.
nonisolated enum StoreLaunchRoute: Equatable, Sendable {
    /// The Auto road — Batch 1's open, custody and all.
    case open
    /// A demanded mode over an existing store: stop at the lobby.
    case lobby(demand: StoreAtOpenMode)
    /// PROVISIONAL (recorded in the run record): a demanded mode over an
    /// ABSENT store — the store was deleted out from under its gate. A
    /// gate over nothing guards nothing, and its unlock secrets reference
    /// a key whose store is gone; the route resets the mode to Auto
    /// (visibly, via the gate's saveDials) and proceeds as a fresh
    /// first launch. The alternatives (refuse outright; lobby over an
    /// empty library) are recorded with it.
    case openResettingModeToAuto

    static func resolve(dials: ProtectionDials, presence: StoreFilePresence) -> StoreLaunchRoute {
        guard dials.mode.isDemanded else { return .open }
        guard presence != .absent else { return .openResettingModeToAuto }
        return .lobby(demand: dials.mode)
    }
}

/// The lobby itself: the demanded modes' at-open state. Holds NO store —
/// only the unlock roads, injected so the phone's face (Batch 4) and the
/// tests compose the same brain.
@MainActor
@Observable
final class StoreLobby {
    /// `.biometric` or `.passphrase` — never `.auto` (no lobby exists there).
    let demand: StoreAtOpenMode
    /// Whether the biometric road renders (demand is biometric AND the
    /// gated item exists on this device).
    let biometryOffered: Bool
    /// Whether the passphrase road renders (an envelope with a passphrase
    /// wrap sits beside the store). Under Biometric demand this is the
    /// FALLBACK (R13p-5: the passphrase, never the device password).
    let passphraseOffered: Bool
    /// Whether the forgot-road renders (a recovery wrap exists).
    let recoveryOffered: Bool

    private(set) var busy = false
    var lastError: String?

    /// True when no road exists at all — the honest dead-end sentence
    /// renders instead of doors (practically unreachable through the
    /// mode-transition choreography, which refuses to enter a demanded
    /// mode without a wrap; stated rather than assumed).
    var noRoadExists: Bool { !biometryOffered && !passphraseOffered && !recoveryOffered }

    // The roads (injected).
    private let gatedRoad: @Sendable () async -> StoreKey?
    private let envelopeRoad: @Sendable (Secret) async -> Result<StoreKey, StoreLobby.Refusal>
    /// Fires on the MainActor with the unlocked key; the composition root
    /// (AppBootstrap) opens the store with it.
    private let complete: @MainActor (StoreKey) -> Void

    nonisolated enum Secret: Sendable {
        case passphrase(String)
        case recoveryText(String)
    }

    /// A worded refusal (the roads never surface raw errors).
    nonisolated struct Refusal: Error, Sendable {
        let message: String
    }

    init(
        demand: StoreAtOpenMode,
        biometryOffered: Bool,
        passphraseOffered: Bool,
        recoveryOffered: Bool,
        gatedRoad: @escaping @Sendable () async -> StoreKey?,
        envelopeRoad: @escaping @Sendable (Secret) async -> Result<StoreKey, StoreLobby.Refusal>,
        complete: @escaping @MainActor (StoreKey) -> Void
    ) {
        self.demand = demand
        self.biometryOffered = biometryOffered
        self.passphraseOffered = passphraseOffered
        self.recoveryOffered = recoveryOffered
        self.gatedRoad = gatedRoad
        self.envelopeRoad = envelopeRoad
        self.complete = complete
    }

    /// The biometric road — PROMPTS in production (the gated item's read
    /// evaluates biometrics). Failure is never a dead end: the surface
    /// offers the passphrase beside it (R13p-5's fallback ruling).
    func unlockWithBiometrics() async {
        guard !busy else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        guard let key = await gatedRoad() else {
            lastError = passphraseOffered
                ? "Biometric unlock didn't go through — enter your encryption passphrase instead."
                : "Biometric unlock didn't go through. Try again."
            return
        }
        complete(key)
    }

    func unlock(passphrase: String) async {
        let trimmed = passphrase
        guard !trimmed.isEmpty else { return }
        await run(.passphrase(trimmed))
    }

    func unlock(recoveryText: String) async {
        let trimmed = recoveryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        await run(.recoveryText(trimmed))
    }

    private func run(_ secret: Secret) async {
        guard !busy else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        switch await envelopeRoad(secret) {
        case .success(let key):
            complete(key)
        case .failure(let refusal):
            lastError = refusal.message
        }
    }

    // MARK: - The roads' production builder

    /// Builds the envelope road for a store at `storeURL`: load the
    /// sidecar, run the heavy unwrap OFF the main actor (the Argon2id
    /// derivation), word every refusal. Shared by the bootstrap and the
    /// tests that want the real road over a scripted gate.
    nonisolated static func envelopeRoad(
        storeURL: URL, gate: StoreLaunchGate
    ) -> @Sendable (Secret) async -> Result<StoreKey, StoreLobby.Refusal> {
        { secret in
            await Task.detached(priority: .userInitiated) {
                do {
                    guard let envelope = try gate.loadEnvelope(storeURL) else {
                        throw StoreKeyEnvelopeError.noPassphraseWrap
                    }
                    switch secret {
                    case .passphrase(let typed):
                        return .success(try envelope.unwrapKey(passphrase: typed))
                    case .recoveryText(let text):
                        let words = EncryptionSession.words(from: text)
                        return .success(try envelope.unwrapKey(recoveryWords: words))
                    }
                } catch {
                    return .failure(Refusal(message: ProtectionCopy.message(for: error)))
                }
            }.value
        }
    }
}
