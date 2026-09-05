//
//  StoreLaunchGate.swift
//  Variorum (shared: Mac + Mobile — the lobby's BRAIN; the Mac's face is
//  StoreLockView this batch, the phone's arrives in Batch 4)
//
//  Phase 13p, Batch 2 — the locked lobby (THE DESIGN's keyed-stack
//  paragraph): in the demanded modes NOTHING runs before unlock — no
//  migrations, no sync round, no purge janitor. The
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
    /// pre-13x 1a: the dials are read and written PER STORE ID (the key
    /// file's; nil = no key file yet → the scope's legacy keys). See
    /// `ProtectionDefaults.dials(scope:storeID:in:)` for the read-through.
    var dials: @Sendable (_ scope: String, _ storeID: String?) -> ProtectionDials
    var saveDials: @Sendable (ProtectionDials, _ scope: String, _ storeID: String?) -> Void
    /// pre-13x 2a: the 13p-era stored at-open mode, while it survives —
    /// the posture derivation's read-through (`Posture.derive`), retired
    /// per store by §11's migration (`retireLegacyDials`). nil = none.
    var legacyMode: @Sendable (_ scope: String, _ storeID: String?) -> StoreAtOpenMode?
    /// §11 — the dial keys retired to the per-store keys.
    var retireLegacyDials: @Sendable (_ scope: String, _ storeID: String) -> Void
    var guardFor: @Sendable (_ scope: String) -> StoreKeyGuard
    /// pre-13x 2a: the iCloud key A's leaves (per scope — the dev-scope
    /// discriminator rides the account); scripted in tests.
    var appleKeyFor: @Sendable (_ scope: String) -> AppleKeyLeaves
    var loadEnvelope: @Sendable (_ storeURL: URL) throws -> StoreKeyEnvelope?
    /// Atomic write of the sidecar beside the store (the controller's
    /// wrap-landing acts ride this; the lobby never writes).
    var saveEnvelope: @Sendable (StoreKeyEnvelope, _ storeURL: URL) throws -> Void
    /// Move a FOREIGN sidecar aside (never delete — its wraps are some
    /// other library's recovery legs; see the controller's reconcile).
    var setAsideEnvelope: @Sendable (_ storeURL: URL) -> Void
    /// Reminder/nudge stamps (device-local, per scope).
    var stamp: @Sendable (_ leaf: String, _ scope: String) -> Date?
    var setStamp: @Sendable (Date?, _ leaf: String, _ scope: String) -> Void

    /// The ONE tri-state sidecar read (pre-13u Act 9, P1/P11 — 17a's
    /// shared root cause). `StoreKeyEnvelope.load` throws `.unreadable`
    /// precisely so corruption is never read as absence, and BOTH
    /// production readers used to discard it with `try?` — which let the
    /// lobby assert "no passphrase or recovery phrase is on file" over a
    /// sidecar holding both, and let the reconcile/set doors OVERWRITE an
    /// unreadable envelope with a fresh wrap-less one (destroying the
    /// passphrase and recovery wraps, and orphaning the escrow item under
    /// a new storeID). Every consumer now reads through this, and the
    /// unreadable case REFUSES rather than minting.
    func readEnvelope(_ storeURL: URL?) -> EnvelopeReading {
        do {
            guard let envelope = try loadEnvelope(
                storeURL ?? URL(fileURLWithPath: "/dev/null"))
            else { return .absent }
            return .loaded(envelope)
        } catch StoreKeyEnvelopeError.unreadable(let detail) {
            return .unreadable(detail)
        } catch {
            // Any other throw is still a file that exists-but-refused —
            // never absence (the P1/P11 rule, applied to the seam's whole
            // error surface).
            return .unreadable(String(describing: error))
        }
    }

    static let live = StoreLaunchGate(
        dials: { ProtectionDefaults.dials(scope: $0, storeID: $1, in: .standard) },
        saveDials: { ProtectionDefaults.save($0, scope: $1, storeID: $2, in: .standard) },
        legacyMode: { ProtectionDefaults.legacyMode(scope: $0, storeID: $1, in: .standard) },
        retireLegacyDials: { ProtectionDefaults.retireLegacyKeys(scope: $0, storeID: $1, in: .standard) },
        // pre-13x 1a: the guard's items are per STORE ID, read from the key
        // file beside the scope's store home at each act.
        guardFor: { scope in
            let storeURL = AppDatabase.StoreVariant(rawValue: scope)
                .flatMap { try? AppDatabase.defaultStoreURL(variant: $0) }
                ?? URL(fileURLWithPath: "/dev/null")
            return StoreKeyGuard.keychain(scope: scope, storeURL: storeURL)
        },
        appleKeyFor: { AppleKeyLeaves.live(scope: $0) },
        // pre-13x 1a: the store's CURRENT key file (fingerprint-named, else
        // the legacy name), located without the key; a write lands under the
        // envelope's own fingerprint name.
        loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
        saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
        setAsideEnvelope: { storeURL in
            guard let url = StoreKeyEnvelope.locate(besideStore: storeURL) else { return }
            let aside = url.deletingPathExtension()
                .appendingPathExtension("stale-\(Int(Date().timeIntervalSince1970)).json")
            try? FileManager.default.moveItem(at: url, to: aside)
        },
        stamp: { ProtectionDefaults.date($0, scope: $1, in: .standard) },
        setStamp: { ProtectionDefaults.setDate($0, $1, scope: $2, in: .standard) })

    /// A scripted gate for tests: fixed dials + an in-memory guard + an
    /// in-memory envelope box.
    static func scripted(
        dials: ProtectionDials,
        backing: InMemoryStoreKeyGuardBacking,
        envelope: StoreKeyEnvelope? = nil,
        legacyMode: StoreAtOpenMode? = nil,
        appleKey: InMemoryAppleKeyBacking = InMemoryAppleKeyBacking()
    ) -> StoreLaunchGate {
        scripted(
            dials: ScriptedDialsBox(dials, legacyMode: legacyMode), backing: backing,
            envelope: ScriptedEnvelopeBox(envelope), appleKey: appleKey)
    }

    /// The fully-scripted form: live boxes so tests observe writes.
    static func scripted(
        dials: ScriptedDialsBox,
        backing: InMemoryStoreKeyGuardBacking,
        envelope: ScriptedEnvelopeBox,
        stamps: ScriptedStampsBox = ScriptedStampsBox(),
        appleKey: InMemoryAppleKeyBacking = InMemoryAppleKeyBacking()
    ) -> StoreLaunchGate {
        StoreLaunchGate(
            dials: { _, storeID in dials.dials(for: storeID) },
            saveDials: { new, _, storeID in dials.save(new, for: storeID) },
            legacyMode: { _, storeID in dials.legacyMode(for: storeID) },
            retireLegacyDials: { _, storeID in dials.retireLegacy(for: storeID) },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: backing) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleKey) },
            loadEnvelope: { _ in
                // P1/P11: the scripted gate can now script UNREADABILITY —
                // the case the verifier found "entirely unexercised"
                // (every controller/lobby test drove a closure that could
                // not throw).
                if envelope.unreadable {
                    throw StoreKeyEnvelopeError.unreadable("scripted unreadable sidecar")
                }
                return envelope.value
            },
            saveEnvelope: { new, _ in envelope.value = new },
            setAsideEnvelope: { _ in
                envelope.setAsideCount += 1
                envelope.value = nil
            },
            stamp: { leaf, _ in stamps.value[leaf] },
            setStamp: { date, leaf, _ in stamps.value[leaf] = date })
    }
}

/// What a sidecar read found — absent, loaded, or PRESENT-BUT-UNREADABLE
/// (the case the `try?` swallow used to erase; P1/P11).
nonisolated enum EnvelopeReading: Sendable {
    case absent
    case loaded(StoreKeyEnvelope)
    case unreadable(String)

    var envelope: StoreKeyEnvelope? {
        if case .loaded(let envelope) = self { return envelope }
        return nil
    }

    var isUnreadable: Bool {
        if case .unreadable = self { return true }
        return false
    }
}

nonisolated final class ScriptedDialsBox: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: ProtectionDials
    private var perStore: [String: ProtectionDials] = [:]
    /// pre-13x 2a: the scripted 13p-era stored mode (the read-through) —
    /// nil for a store that never had one or whose keys §11 retired.
    private var legacyStored: StoreAtOpenMode?
    private var legacyPerStore: [String: StoreAtOpenMode] = [:]
    private var _retiredStoreIDs: [String] = []
    init(_ initial: ProtectionDials, legacyMode: StoreAtOpenMode? = nil) {
        stored = initial
        legacyStored = legacyMode
    }
    /// The scripted legacy mode read-through (production's shape: the
    /// store's own where 1a wrote one, else the scope's).
    func legacyMode(for storeID: String?) -> StoreAtOpenMode? {
        lock.lock(); defer { lock.unlock() }
        if let storeID, _retiredStoreIDs.contains(storeID) { return nil }
        return storeID.flatMap { legacyPerStore[$0] } ?? legacyStored
    }
    func setLegacyMode(_ mode: StoreAtOpenMode?, for storeID: String? = nil) {
        lock.lock(); defer { lock.unlock() }
        if let storeID { legacyPerStore[storeID] = mode } else { legacyStored = mode }
    }
    func retireLegacy(for storeID: String) {
        lock.lock(); defer { lock.unlock() }
        _retiredStoreIDs.append(storeID)
        legacyPerStore[storeID] = nil
        legacyStored = nil
    }
    var retiredStoreIDs: [String] {
        lock.lock(); defer { lock.unlock() }
        return _retiredStoreIDs
    }
    /// The LEGACY (per-scope) dials — what a store id with no keys of its
    /// own reads through to, exactly as production's read-through.
    var value: ProtectionDials {
        get { lock.lock(); defer { lock.unlock() }; return stored }
        set { lock.lock(); defer { lock.unlock() }; stored = newValue }
    }
    /// pre-13x 1a: the per-store dials, scripted like production's
    /// defaults — a store id that never saved reads the legacy value.
    func dials(for storeID: String?) -> ProtectionDials {
        lock.lock(); defer { lock.unlock() }
        return storeID.flatMap { perStore[$0] } ?? stored
    }
    func save(_ new: ProtectionDials, for storeID: String?) {
        lock.lock(); defer { lock.unlock() }
        if let storeID { perStore[storeID] = new } else { stored = new }
    }
    func perStoreDials(_ storeID: String) -> ProtectionDials? {
        lock.lock(); defer { lock.unlock() }
        return perStore[storeID]
    }
}

nonisolated final class ScriptedStampsBox: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: [String: Date] = [:]
    init() {}
    var value: [String: Date] {
        get { lock.lock(); defer { lock.unlock() }; return stored }
        set { lock.lock(); defer { lock.unlock() }; stored = newValue }
    }
}

nonisolated final class ScriptedEnvelopeBox: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: StoreKeyEnvelope?
    private var _setAsideCount = 0
    private var _unreadable = false
    init(_ initial: StoreKeyEnvelope?) { stored = initial }
    var value: StoreKeyEnvelope? {
        get { lock.lock(); defer { lock.unlock() }; return stored }
        set { lock.lock(); defer { lock.unlock() }; stored = newValue }
    }
    var setAsideCount: Int {
        get { lock.lock(); defer { lock.unlock() }; return _setAsideCount }
        set { lock.lock(); defer { lock.unlock() }; _setAsideCount = newValue }
    }
    /// P1/P11: scripts a PRESENT-but-undecodable sidecar — the gate's
    /// loadEnvelope throws `.unreadable` while this is true.
    var unreadable: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _unreadable }
        set { lock.lock(); defer { lock.unlock() }; _unreadable = newValue }
    }
}

/// Where a launch goes, decided BEFORE any store open.
nonisolated enum StoreLaunchRoute: Equatable, Sendable {
    /// The Standard road — Batch 1's open, custody and all (and, since
    /// pre-13x 2a, the Apple-key road when the bound item is missing).
    case open
    /// A demanded gate over an existing store: stop at the lobby.
    case lobby(demand: StoreAtOpenMode)
    /// pre-13x 1a (the postures design §3.7 / decision 14 — RE-RULED): a
    /// demanded mode over an ABSENT store — "your library file is missing
    /// — restore it, open an existing library, or start a new one". THE
    /// LOCK STAYS: nothing is persisted, nothing opens; starting new is a
    /// deliberate act that mints under a NEW store id (per-store custody
    /// leaves the old library's items unreachable, never deleted). This
    /// replaces 13p's PROVISIONAL `openResettingModeToAuto`, whose silent
    /// Auto reset + fresh mint was the same-machine bypass the design
    /// closes (KnownIssues, the Castle-bypass row).
    case libraryMissing(demand: StoreAtOpenMode)

    /// pre-13x 2a: the route reads the EFFECTIVE gate — derived at the
    /// route from the posture (the key file beside the store, read without
    /// the key; the 13p-era stored mode until §11 retires it) and Castle's
    /// gate style (the dials). Never a stored mode.
    static func resolve(gate: StoreAtOpenMode, presence: StoreFilePresence) -> StoreLaunchRoute {
        guard gate.isDemanded else { return .open }
        guard presence != .absent else { return .libraryMissing(demand: gate) }
        return .lobby(demand: gate)
    }
}

/// The route-time posture facts (pre-13x 2a): what can be known BEFORE
/// any store open or network contact — the 13p-era stored mode (until §11
/// retires it) and the key file beside the store. The vault's word joins
/// at ready (`ProtectionController.reconcile`).
nonisolated struct RoutePostureFacts: Sendable {
    var legacyMode: StoreAtOpenMode?
    var keyFile: StoreKeyEnvelope?

    var posture: Posture {
        Posture.derive(legacyMode: legacyMode, vaultHasAppleHeldCopy: nil, keyFile: keyFile)
    }
}

nonisolated extension StoreLaunchGate {
    /// The effective gate at the route, from the gate's own reads: the
    /// legacy mode (the read-through), the key file (posture) and the
    /// dials (style). An UNREADABLE key file reads as no key file for the
    /// posture (a demanded gate still routes to its lobby through the
    /// legacy mode while it survives; after §11 an unreadable file opens
    /// the Standard road, where the open refuses typed — P1/P11's honesty
    /// is the lobby's and the controller's, never a silent mint).
    func effectiveGate(scope: String, storeID: String?, storeURL: URL?) -> StoreAtOpenMode {
        let facts = RoutePostureFacts(
            legacyMode: legacyMode(scope, storeID),
            keyFile: readEnvelope(storeURL).envelope)
        return StoreAtOpenMode.effective(posture: facts.posture, dials: dials(scope, storeID))
    }
}

/// The lobby itself: the demanded modes' at-open state. Holds NO store —
/// only the unlock roads, injected so the phone's face (Batch 4) and the
/// tests compose the same brain.
@MainActor
@Observable
final class StoreLobby {
    /// What this lobby IS (pre-13x 2a): Castle's locked lobby, or
    /// Standard's WAITING STATE (design §3.8 — the bound item is missing
    /// and the iCloud key A has not arrived: "Getting your key from iCloud
    /// Keychain…", copy §2d, with the passphrase and the twelve words as
    /// doors that act, and a re-probe of A that opens silently the moment
    /// it lands; propagation latency is unbounded and unobservable, so the
    /// probe polls).
    nonisolated enum Kind: Equatable, Sendable {
        case castle
        /// `differentAppleID`: iCloud Keychain holds an A that is NOT the
        /// one this library's key file was written under — copy §2d's
        /// third sentence renders (the passphrase road answers once).
        case waitingForICloudKeychain(differentAppleID: Bool)
    }

    let kind: Kind
    /// `.biometric` or `.passphrase` under Castle; `.auto` under the
    /// waiting kind (no gate exists — the library is Standard).
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
    /// P11 (pre-13u Act 9): the sidecar EXISTS but could not be read —
    /// distinct from absent, so the dead end can say the TRUE cause
    /// instead of "no passphrase or recovery phrase is on file" over a
    /// file that holds both.
    let envelopeUnreadable: Bool

    private(set) var busy = false
    var lastError: String?

    /// True when no road exists at all — the honest dead-end sentence
    /// renders instead of doors (practically unreachable through the
    /// mode-transition choreography, which refuses to enter a demanded
    /// mode without a wrap; stated rather than assumed).
    var noRoadExists: Bool { !biometryOffered && !passphraseOffered && !recoveryOffered }

    /// The ONE dead-end brain both faces render (P11): an unreadable
    /// sidecar gets the sentence that already existed for it
    /// (`StoreKeyEnvelopeError.unreadable`'s arm — restore the file from
    /// a backup folder) instead of the absent-wraps cause, which is false
    /// in exactly that case.
    var deadEndMessage: String {
        envelopeUnreadable
            ? ProtectionCopy.message(for: StoreKeyEnvelopeError.unreadable(""))
            : ProtectionCopy.deadEnd(demand)
    }

    // The roads (injected).
    private let gatedRoad: @Sendable () async -> StoreKey?
    private let envelopeRoad: @Sendable (Secret) async -> Result<StoreKey, StoreLobby.Refusal>
    /// pre-13x 2a: the Apple road (the waiting kind only) — A from iCloud
    /// Keychain → the key file's Apple copy → the key; nil while A has not
    /// arrived (or is not this library's). Polled by `beginWaiting`.
    private let appleRoad: (@Sendable () async -> StoreKey?)?
    /// Fires on the MainActor with the unlocked key; the composition root
    /// (AppBootstrap) opens the store with it.
    private let complete: @MainActor (StoreKey) -> Void
    @ObservationIgnored private var waitingTask: Task<Void, Never>?
    /// How many times the Apple road has been asked (the pin's evidence
    /// that the waiting state POLLS).
    private(set) var appleProbes = 0

    nonisolated enum Secret: Sendable {
        case passphrase(String)
        case recoveryText(String)
    }

    /// A worded refusal (the roads never surface raw errors).
    nonisolated struct Refusal: Error, Sendable {
        let message: String
    }

    init(
        kind: Kind = .castle,
        demand: StoreAtOpenMode,
        biometryOffered: Bool,
        passphraseOffered: Bool,
        recoveryOffered: Bool,
        envelopeUnreadable: Bool = false,
        gatedRoad: @escaping @Sendable () async -> StoreKey?,
        envelopeRoad: @escaping @Sendable (Secret) async -> Result<StoreKey, StoreLobby.Refusal>,
        appleRoad: (@Sendable () async -> StoreKey?)? = nil,
        complete: @escaping @MainActor (StoreKey) -> Void
    ) {
        self.kind = kind
        self.demand = demand
        self.biometryOffered = biometryOffered
        self.passphraseOffered = passphraseOffered
        self.recoveryOffered = recoveryOffered
        self.envelopeUnreadable = envelopeUnreadable
        self.gatedRoad = gatedRoad
        self.envelopeRoad = envelopeRoad
        self.appleRoad = appleRoad
        self.complete = complete
    }

    /// Whether this is Standard's waiting state.
    var isWaitingForICloudKeychain: Bool {
        if case .waitingForICloudKeychain = kind { return true }
        return false
    }

    var differentAppleID: Bool {
        if case .waitingForICloudKeychain(let different) = kind { return different }
        return false
    }

    // MARK: - The waiting state's re-probe (the Apple road, polled)

    /// Ask the Apple road now, and every `interval` until it answers or the
    /// lobby is torn down. The interval is a parameter so the pin drives it
    /// fast; production polls every few seconds (the lookup's fact: no
    /// notification exists for a synchronizable item's arrival).
    func beginWaiting(every interval: Duration = .seconds(5)) {
        guard appleRoad != nil, waitingTask == nil else { return }
        waitingTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                if await self.probeAppleRoad() { return }
                try? await Task.sleep(for: interval)
            }
        }
    }

    func stopWaiting() {
        waitingTask?.cancel()
        waitingTask = nil
    }

    /// One probe: true when the key arrived and the open began.
    @discardableResult
    func probeAppleRoad() async -> Bool {
        guard let appleRoad, !busy else { return false }
        appleProbes += 1
        guard let key = await appleRoad() else { return false }
        stopWaiting()
        complete(key)
        return true
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
        // DELIBERATELY UNTRIMMED (ladder R1-n4 — the old `trimmed` name
        // claimed a trim that never happens): a passphrase may begin or end
        // with a space — the floor forbids only the EMPTY passphrase, and a
        // silent trim would refuse a secret the user really typed. The
        // recovery road below DOES trim, because a phrase is a word LIST:
        // whitespace there is a separator, never content.
        guard !passphrase.isEmpty else { return }
        await run(.passphrase(passphrase))
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
            stopWaiting()
            complete(key)
        case .failure(let refusal):
            lastError = refusal.message
        }
    }

    /// pre-13x 2a — THE APPLE ROAD's production builder (§3.8): A from
    /// this device's iCloud Keychain (the scope's family), the key file's
    /// Apple copy unwrapped with it — nil when A is absent, when the copy
    /// is under another A (the client VERIFIES the id, never adopts), or
    /// when the key file is missing/unreadable. Off-main (a Keychain read
    /// + one AES key-unwrap).
    nonisolated static func appleRoad(
        scope: String, storeURL: URL, gate: StoreLaunchGate
    ) -> @Sendable () async -> StoreKey? {
        {
            await Task.detached(priority: .userInitiated) {
                Self.openWithAppleKey(scope: scope, storeURL: storeURL, gate: gate).key
            }.value
        }
    }

    /// The Apple road's verdict, synchronous (the route consults it once
    /// before deciding on the waiting state): the key, or why not.
    nonisolated enum AppleRoadReading: Sendable {
        case opened(StoreKey)
        /// A is not on this device (not yet propagated · iCloud Keychain
        /// off · no Apple ID).
        case appleKeyAbsent
        /// A is here but the key file's copy is under ANOTHER A.
        case differentAppleID
        /// No key file, no Apple copy, or an unreadable file.
        case noAppleCopy

        var key: StoreKey? {
            if case .opened(let key) = self { return key }
            return nil
        }
    }

    nonisolated static func openWithAppleKey(
        scope: String, storeURL: URL, gate: StoreLaunchGate
    ) -> AppleRoadReading {
        guard let envelope = gate.readEnvelope(storeURL).envelope,
              envelope.apple != nil
        else { return .noAppleCopy }
        guard let apple = gate.appleKeyFor(scope).read() else { return .appleKeyAbsent }
        if let expected = envelope.appleKeyID, expected != apple.id { return .differentAppleID }
        guard let key = try? envelope.unwrapKey(apple: apple.symmetricKey) else {
            return .differentAppleID
        }
        return .opened(key)
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
