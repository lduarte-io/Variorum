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

import CryptoKit
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
    /// pre-13x 2d (decision 35): whether this store's per-store SYNC
    /// CUSTODY exists on this device — the silent item readable or the
    /// gated item's non-prompting probe — read by PRESENCE at the route
    /// (no session object, no network there). "Enrolled" at the route IS
    /// this; an enrolled library's posture is INDETERMINATE until the
    /// vault answers, and the route opens it through the custody shape it
    /// has. Defaulted inert for the scripted worlds that never enroll.
    var syncCustodyPresent: @Sendable (_ scope: String, _ storeID: String) -> Bool = { _, _ in false }

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
        setStamp: { ProtectionDefaults.setDate($0, $1, scope: $2, in: .standard) },
        // pre-13x 2d: the per-store sync custody's presence — the silent
        // item's non-prompting read, else the gated item's probe.
        syncCustodyPresent: { scope, storeID in
            let custody = SyncCustodyScope(scope: scope, storeID: storeID)
            return E2EEKeychainStorage.load(scope: custody) != nil
                || E2EEKeychainStorage.gatedItemExists(scope: custody)
        })

    /// A scripted gate for tests: fixed dials + an in-memory guard + an
    /// in-memory envelope box.
    static func scripted(
        dials: ProtectionDials,
        backing: InMemoryStoreKeyGuardBacking,
        envelope: StoreKeyEnvelope? = nil,
        legacyMode: StoreAtOpenMode? = nil,
        appleKey: InMemoryAppleKeyBacking = InMemoryAppleKeyBacking(),
        syncCustodyPresent: (@Sendable (_ scope: String, _ storeID: String) -> Bool)? = nil
    ) -> StoreLaunchGate {
        scripted(
            dials: ScriptedDialsBox(dials, legacyMode: legacyMode), backing: backing,
            envelope: ScriptedEnvelopeBox(envelope), appleKey: appleKey,
            syncCustodyPresent: syncCustodyPresent)
    }

    /// The fully-scripted form: live boxes so tests observe writes.
    static func scripted(
        dials: ScriptedDialsBox,
        backing: InMemoryStoreKeyGuardBacking,
        envelope: ScriptedEnvelopeBox,
        stamps: ScriptedStampsBox = ScriptedStampsBox(),
        appleKey: InMemoryAppleKeyBacking = InMemoryAppleKeyBacking(),
        syncCustodyPresent: (@Sendable (_ scope: String, _ storeID: String) -> Bool)? = nil
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
            setStamp: { date, leaf, _ in stamps.value[leaf] = date },
            // pre-13x 2d: the scripted sync custody presence (nil = never
            // enrolled — the pre-2d worlds' reading, unchanged).
            syncCustodyPresent: syncCustodyPresent ?? { _, _ in false })
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
    /// replaces 13p's PROVISIONAL reset-to-Auto route, whose silent Auto
    /// reset + fresh mint was the same-machine bypass the design closes
    /// (KnownIssues, the Castle-bypass row).
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
    /// pre-13x 2b (corner 45): where the raw library key sits — read by
    /// presence at the route (the silent item's non-prompting read, the
    /// gated item's non-prompting probe); `.unknown` where a caller cannot
    /// read custody.
    var rawKeyCustody: RawKeyCustody = .unknown
    /// pre-13x 2d (decision 35): whether the per-store sync custody EXISTS
    /// — the route's reading of "enrolled". REQUIRED: every site decides.
    var enrolled: Bool

    /// The reading (no vault word exists at the route): an enrolled
    /// library is INDETERMINATE and acts as its custody shape; a
    /// local-only one is the legacy mode's or the key file's.
    var reading: PostureReading {
        Posture.derive(
            legacyMode: legacyMode, vaultHasAppleHeldCopy: nil, keyFile: keyFile,
            rawKeyCustody: rawKeyCustody, enrolled: enrolled)
    }

    /// What the route ACTS as.
    var posture: Posture { reading.acting }
}

nonisolated extension StoreLaunchGate {
    /// The effective gate at the route, from the gate's own reads: the
    /// legacy mode (the read-through), the key file (posture), the raw
    /// key's custody SHAPE (corner 45 — presence only, never an unlock) and
    /// the dials (style). An UNREADABLE key file reads as no key file for
    /// the posture (a demanded gate still routes to its lobby through the
    /// legacy mode while it survives; after §11 an unreadable file opens
    /// the Standard road, where the open refuses typed — P1/P11's honesty
    /// is the lobby's and the controller's, never a silent mint).
    ///
    /// pre-13x 2b item (0): the route TRIES THE APPLE LANDING BEFORE IT
    /// DERIVES — a Standard-waiting key file (no `apple` copy, the raw key
    /// in the silent item) whose A is readable now gets its copy landed
    /// here, so the one route between a refused landing and the next
    /// ready reads Standard by the copy itself, not only by the shape.
    ///
    /// pre-13x 2d (decision 35): an ENROLLED library — its per-store sync
    /// custody present — is INDETERMINATE at the route (no vault word can
    /// exist here) and opens through the custody shape it has; the
    /// landing above is a posture-driven WRITE, so it is skipped for it.
    func effectiveGate(scope: String, storeID: String?, storeURL: URL?) -> StoreAtOpenMode {
        let guardSeam = guardFor(scope)
        let custody = rawKeyCustody(guardSeam: guardSeam)
        let enrolled = storeID.map { syncCustodyPresent(scope, $0) } ?? false
        var reading = readEnvelope(storeURL)
        if !enrolled, custody == .silent, let storeURL, let envelope = reading.envelope,
           envelope.apple == nil, envelope.passphrase != nil,
           let key = guardSeam.loadAuto(), envelope.belongs(to: key),
           let apple = appleKeyFor(scope).read() {
            var landed = envelope
            if (try? landed.setAppleWrappedCopy(key: key, under: apple.symmetricKey, appleKeyID: apple.id)) != nil,
               (try? saveEnvelope(landed, storeURL)) != nil {
                reading = .loaded(landed)
            }
        }
        let facts = RoutePostureFacts(
            legacyMode: legacyMode(scope, storeID),
            keyFile: reading.envelope,
            rawKeyCustody: custody,
            enrolled: enrolled)
        return StoreAtOpenMode.effective(reading: facts.reading, dials: dials(scope, storeID))
    }

    /// The raw key's custody shape by PRESENCE (corner 45): the silent
    /// item releases on a non-prompting read; the gated item answers a
    /// non-prompting probe; neither ⇒ nowhere (Always ask, or never
    /// minted). Never an unlock.
    func rawKeyCustody(guardSeam: StoreKeyGuard) -> RawKeyCustody {
        if guardSeam.loadAuto() != nil { return .silent }
        return .gatedOrNone
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

    /// pre-13x 4a (§3.6): what the lobby is doing while busy — the faces
    /// render the line (*Unlocking… / Checking your account…*); the vault
    /// road reports `.checkingAccount` only when it is actually awaited
    /// (after a local refusal, signed in).
    nonisolated enum Phase: Equatable, Sendable {
        case idle
        case unlocking
        case checkingAccount
    }
    private(set) var phase: Phase = .idle
    /// The progress row shows from ~200 ms into a submit (`progressDelay`),
    /// never at once — a local unlock is usually under that.
    private(set) var showsProgress = false
    /// pre-13x 4a (copy §3's offline note): rendered small beneath the
    /// roads AFTER a submit in this lobby whose vault read failed with a
    /// transport error (or ran past the ceiling) — the lobby knows it is
    /// offline only by trying; never before a submit. Cleared by the next
    /// submit.
    private(set) var showsOfflineNote = false
    private let progressDelay: Duration
    @ObservationIgnored private var progressTask: Task<Void, Never>?

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
    /// The envelope road with its PHASE report (pre-13x 4a): the road calls
    /// the report when it starts awaiting the vault; the lobby renders it.
    private let envelopeRoad: @Sendable (Secret, @escaping @Sendable (Phase) -> Void) async -> Result<StoreKey, StoreLobby.Refusal>
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

    /// A worded refusal (the roads never surface raw errors). pre-13x 4a:
    /// `offline` — the vault road could not be reached (a transport error
    /// or the ceiling), so copy §3's offline note is honest.
    nonisolated struct Refusal: Error, Sendable {
        let message: String
        var offline: Bool = false
    }

    convenience init(
        kind: Kind = .castle,
        demand: StoreAtOpenMode,
        biometryOffered: Bool,
        passphraseOffered: Bool,
        recoveryOffered: Bool,
        envelopeUnreadable: Bool = false,
        gatedRoad: @escaping @Sendable () async -> StoreKey?,
        envelopeRoad: @escaping @Sendable (Secret) async -> Result<StoreKey, StoreLobby.Refusal>,
        appleRoad: (@Sendable () async -> StoreKey?)? = nil,
        progressDelay: Duration = .milliseconds(200),
        complete: @escaping @MainActor (StoreKey) -> Void
    ) {
        self.init(
            kind: kind, demand: demand, biometryOffered: biometryOffered,
            passphraseOffered: passphraseOffered, recoveryOffered: recoveryOffered,
            envelopeUnreadable: envelopeUnreadable, gatedRoad: gatedRoad,
            phasedRoad: { secret, _ in await envelopeRoad(secret) },
            appleRoad: appleRoad, progressDelay: progressDelay, complete: complete)
    }

    /// pre-13x 4a: the road that REPORTS its phase (the vault road's
    /// *Checking your account…*) — the bootstrap's composition.
    init(
        kind: Kind = .castle,
        demand: StoreAtOpenMode,
        biometryOffered: Bool,
        passphraseOffered: Bool,
        recoveryOffered: Bool,
        envelopeUnreadable: Bool = false,
        gatedRoad: @escaping @Sendable () async -> StoreKey?,
        phasedRoad: @escaping @Sendable (Secret, @escaping @Sendable (Phase) -> Void) async -> Result<StoreKey, StoreLobby.Refusal>,
        appleRoad: (@Sendable () async -> StoreKey?)? = nil,
        progressDelay: Duration = .milliseconds(200),
        complete: @escaping @MainActor (StoreKey) -> Void
    ) {
        self.kind = kind
        self.demand = demand
        self.biometryOffered = biometryOffered
        self.passphraseOffered = passphraseOffered
        self.recoveryOffered = recoveryOffered
        self.envelopeUnreadable = envelopeUnreadable
        self.gatedRoad = gatedRoad
        self.envelopeRoad = phasedRoad
        self.appleRoad = appleRoad
        self.progressDelay = progressDelay
        self.complete = complete
    }

    /// pre-13x 4a (§3.5 / §3.6): a secret road exists when its LOCAL copy
    /// does — or when the key file carries a master-wrapped copy of the
    /// library key, which the vault road opens by the account's copy of
    /// that secret (the twelve words open a library whose local W copy
    /// never landed; the current passphrase opens an old backup online).
    nonisolated static func passphraseRoadExists(_ envelope: StoreKeyEnvelope?) -> Bool {
        envelope?.passphrase != nil || envelope?.master != nil
    }
    nonisolated static func recoveryRoadExists(_ envelope: StoreKeyEnvelope?) -> Bool {
        envelope?.recovery != nil || envelope?.master != nil
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

    /// 13x F1 (ladder R1-M4): the adoption flow SUSPENDS the standing
    /// lobby BEFORE its work — the re-probe must not open the pool over
    /// a departing store (a probe firing between the flow's wal check
    /// and the move left two bindings over two files). Stopping the
    /// polling task alone is not enough: a probe already awaiting the
    /// Apple road completes AFTER the cancel, so `probeAppleRoad` also
    /// re-checks the flag past its await. The typed roads need a user
    /// and the adoption sheet stands over the lobby's fields — recorded,
    /// not guarded.
    private(set) var suspendedForAdoption = false

    func suspendForAdoption() {
        suspendedForAdoption = true
        stopWaiting()
    }

    /// A FAILED non-ready adoption resumes the lobby (the flow shows its
    /// refusal; the lobby must go back to waiting rather than wait dead
    /// until a relaunch).
    func resumeAfterAdoption(every interval: Duration = .seconds(5)) {
        suspendedForAdoption = false
        if isWaitingForICloudKeychain { beginWaiting(every: interval) }
    }

    /// One probe: true when the key arrived and the open began.
    @discardableResult
    func probeAppleRoad() async -> Bool {
        guard let appleRoad, !busy, !suspendedForAdoption else { return false }
        appleProbes += 1
        guard let key = await appleRoad() else { return false }
        // R1-M4: the in-flight re-check — a suspension that landed while
        // this probe awaited the road completes NOTHING.
        guard !suspendedForAdoption else { return false }
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
            // pre-13x 5a: copy §3's line (the device's gate word); the no-road
            // arm has no copy line (listed in copy §11).
            lastError = passphraseOffered
                ? ProtectionCopy.lobbyBiometryFailed
                : "\(ProtectionCopy.biometryName) didn't go through. Try again."
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
        showsOfflineNote = false
        phase = .unlocking
        beginProgressTimer()
        defer {
            busy = false
            phase = .idle
            progressTask?.cancel()
            progressTask = nil
            showsProgress = false
        }
        let result = await envelopeRoad(secret) { [weak self] reported in
            Task { @MainActor [weak self] in
                guard let self, self.busy else { return }
                self.phase = reported
            }
        }
        switch result {
        case .success(let key):
            stopWaiting()
            complete(key)
        case .failure(let refusal):
            lastError = refusal.message
            showsOfflineNote = refusal.offline
        }
    }

    /// The progress row from ~`progressDelay` into a submit.
    private func beginProgressTimer() {
        progressTask?.cancel()
        let delay = progressDelay
        progressTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled, let self, self.busy else { return }
            self.showsProgress = true
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

    /// Builds the envelope road for a store at `storeURL` — the LOCAL
    /// copies only (no vault road): the sidecar loaded, the heavy unwrap
    /// OFF the main actor (the Argon2id derivation), every refusal worded.
    /// Kept for the compositions and pins that want the local road alone;
    /// the bootstrap composes the phased road below with the vault road.
    nonisolated static func envelopeRoad(
        storeURL: URL, gate: StoreLaunchGate, session: SyncCustodySession = .shared
    ) -> @Sendable (Secret) async -> Result<StoreKey, StoreLobby.Refusal> {
        let phased = envelopeRoad(storeURL: storeURL, gate: gate, session: session, vaultRoad: nil)
        return { secret in await phased(secret) { _ in } }
    }

    /// pre-13x 4a — THE ENVELOPE ROAD WITH THE VAULT ROAD (design §3.6;
    /// ledger 10). The two secret roads try the LOCAL copy first, then — on
    /// a refusal, signed in and online — the vault: derive per the vault's
    /// descriptor → unwrap the master → the key file's master-wrapped copy
    /// of the library key → L → a fresh local copy under the typed word
    /// with the vault's descriptor (+ the reconciliation recorded) — written
    /// only AFTER the vault unwrap and the master-copy unwrap succeeded, so
    /// a typo writes nothing. The vault READ starts concurrently with the
    /// local derivation (`async let`-shaped: a detached task) and is
    /// cancelled when the local copy opens; a local refusal awaits it under
    /// `ceiling` (~10 s), past which the local verdict stands with the
    /// offline note. The derivation runs ONCE when the local wrap's
    /// descriptor equals the vault's (the derived key is reused). The
    /// derived key of the SUCCESSFUL road is held for the session under
    /// ITS descriptor — the vault's when the vault opened — so the ready
    /// reconcile's derived-key rule lands custody with no second entry.
    /// `derive` is injectable so a pin can count derivations.
    nonisolated static func envelopeRoad(
        storeURL: URL, gate: StoreLaunchGate, session: SyncCustodySession = .shared,
        vaultRoad: LobbyVaultRoad?, ceiling: Duration = .seconds(10),
        derive: @escaping @Sendable (String, PassphraseKDF.Descriptor) throws -> SymmetricKey = {
            try PassphraseKDF.deriveKey(passphrase: $0, descriptor: $1)
        }
    ) -> @Sendable (Secret, @escaping @Sendable (Phase) -> Void) async -> Result<StoreKey, StoreLobby.Refusal> {
        { secret, report in
            await Task.detached(priority: .userInitiated) {
                await Self.runEnvelopeRoad(
                    secret: secret, storeURL: storeURL, gate: gate, session: session,
                    vaultRoad: vaultRoad, ceiling: ceiling, derive: derive, report: report)
            }.value
        }
    }

    /// The vault read ran past the ceiling.
    nonisolated struct VaultReadTimedOut: Error {}

    private nonisolated static func runEnvelopeRoad(
        secret: Secret, storeURL: URL, gate: StoreLaunchGate, session: SyncCustodySession,
        vaultRoad: LobbyVaultRoad?, ceiling: Duration,
        derive: @Sendable (String, PassphraseKDF.Descriptor) throws -> SymmetricKey,
        report: @Sendable (Phase) -> Void
    ) async -> Result<StoreKey, StoreLobby.Refusal> {
        // 1. The key file — the one thing every road needs.
        let envelope: StoreKeyEnvelope
        do {
            guard let loaded = try gate.loadEnvelope(storeURL) else {
                return .failure(Refusal(message: ProtectionCopy.message(for: StoreKeyEnvelopeError.noPassphraseWrap)))
            }
            envelope = loaded
        } catch {
            return .failure(Refusal(message: ProtectionCopy.message(for: error)))
        }
        // 2. The vault read, started NOW — concurrently with the local
        //    derivation (corner 17: the ONE pre-unlock network contact).
        //    Only a key file carrying a master-wrapped copy has any use for
        //    it; a road without one never touches the network.
        var vaultFetch: Task<KeyVaultFormat?, Error>?
        if let vaultRoad, envelope.master != nil {
            vaultFetch = Task.detached(priority: .userInitiated) { try await vaultRoad.fetch() }
        }

        switch secret {
        case .passphrase(let typed):
            // 3. THE LOCAL COPY FIRST.
            var local: (key: SymmetricKey, kdf: PassphraseKDF.Descriptor)?
            let localRefusal: any Error
            do {
                guard let wrap = envelope.passphrase else { throw StoreKeyEnvelopeError.noPassphraseWrap }
                // The floor BEFORE the derivation (3b — a tampered key file
                // cannot make the KDF cheap).
                try wrap.kdf.validateFloor(PassphraseKDF.floor)
                let derived = try derive(typed, wrap.kdf)
                local = (derived, wrap.kdf)
                let key = try envelope.unwrapKey(passphraseKey: derived)
                vaultFetch?.cancel()
                // pre-13x 2c (decision 10's Always-ask exception): the
                // DERIVED wrapping key — never the typed word — is held in
                // session memory with its descriptor (§3.6 — derive once when
                // the recorded descriptor equals the vault's); a relock
                // drops it (1a's pin).
                session.holdDerivedWrappingKey(derived, kdf: wrap.kdf)
                return .success(key)
            } catch {
                localRefusal = error
            }
            // 4. THE VAULT ROAD — signed in and online.
            let localMessage = ProtectionCopy.message(
                for: vaultFetch != nil && isAbsentWrap(localRefusal) ? StoreKeyEnvelopeError.wrongPassphrase : localRefusal)
            guard let vaultFetch else { return .failure(Refusal(message: localMessage)) }
            report(.checkingAccount)
            let format: KeyVaultFormat?
            do {
                format = try await awaitWithin(ceiling, vaultFetch)
            } catch {
                // A transport failure or the ceiling: the local verdict, and
                // copy §3's offline note (the lobby knows only by trying).
                return .failure(Refusal(message: localMessage, offline: true))
            }
            guard let format else { return .failure(Refusal(message: localMessage)) }  // signed out / no vault
            // Derive ONCE when the local wrap's descriptor is the vault's
            // (the key already in hand IS the vault's derivation).
            let derivedVault: SymmetricKey
            do {
                if let local, local.kdf == format.kdf {
                    derivedVault = local.key
                } else {
                    derivedVault = try derive(typed, format.kdf)
                }
            } catch {
                return .failure(Refusal(message: localMessage))
            }
            guard let master = try? format.unwrapMaster(withPassphraseKey: derivedVault) else {
                // The vault refused too. RETIRED (copy §3) only when the key
                // file's recorded descriptor is no longer the vault's — a
                // change happened elsewhere, and the typed word is neither
                // the old (it would have opened locally) nor the new.
                let retired = envelope.vaultKDF != nil && envelope.vaultKDF != format.kdf
                return .failure(Refusal(message: retired ? ProtectionCopy.lobbyRetiredPassphrase : localMessage))
            }
            guard let key = try? envelope.unwrapKey(master: master) else {
                // The vault opened but the key file's master-wrapped copy is
                // not under this account's master (§3.6's owner distinction —
                // another account's vault): this library is not opened by
                // that word.
                return .failure(Refusal(message: localMessage))
            }
            // 5. THE FRESH LOCAL COPY — after the vault unwrap AND the
            //    master-copy unwrap succeeded, never before (a typo writes
            //    nothing). The next open by this word is LOCAL: one derivation.
            var updated = envelope
            if let wrap = try? StoreKeyEnvelope.makePassphraseWrap(key: key, passphraseKey: derivedVault, kdf: format.kdf) {
                do {
                    try updated.adoptPassphraseWrap(wrap, key: key)
                    try updated.recordVaultReconciliation(
                        kdf: format.kdf, corpusKeyID: format.classKey(for: .corpus)?.keyID,
                        recoveryWrapDigest: format.recoveryWrapDigest)
                    try gate.saveEnvelope(updated, storeURL)
                } catch {
                    // The open stands; the next open by this word derives twice
                    // (the ready reconcile's landing re-wraps it).
                }
            }
            session.holdDerivedWrappingKey(derivedVault, kdf: format.kdf)
            return .success(key)

        case .recoveryText(let text):
            let words = EncryptionSession.words(from: text)
            // A malformed phrase (checksum, unknown word, the count) is the
            // phrase's own refusal — no copy and no vault can change it.
            let recoveryKey: SymmetricKey
            do {
                recoveryKey = try RecoveryPhrase.recoveryWrapKey(words: words)
            } catch {
                vaultFetch?.cancel()
                return .failure(Refusal(message: ProtectionCopy.message(for: error)))
            }
            let localRefusal: any Error
            do {
                let key = try envelope.unwrapKey(recoveryWords: words)
                vaultFetch?.cancel()
                return .success(key)
            } catch {
                localRefusal = error
            }
            let localMessage = ProtectionCopy.message(
                for: vaultFetch != nil && isAbsentWrap(localRefusal) ? StoreKeyEnvelopeError.wrongRecoveryPhrase : localRefusal)
            guard let vaultFetch else { return .failure(Refusal(message: localMessage)) }
            report(.checkingAccount)
            let format: KeyVaultFormat?
            do {
                format = try await awaitWithin(ceiling, vaultFetch)
            } catch {
                return .failure(Refusal(message: localMessage, offline: true))
            }
            guard let format,
                  let master = try? format.unwrapMaster(withRecoveryKey: recoveryKey),
                  let key = try? envelope.unwrapKey(master: master)
            else { return .failure(Refusal(message: localMessage)) }
            // The W copy landed locally (§12: the twelve words open a library
            // whose local W copy was never landed) + the vault's wrap digest;
            // the P copy's record is untouched (a passphrase change elsewhere
            // still speaks at ready).
            var updated = envelope
            do {
                try updated.setRecoveryWrap(key: key, words: words)
                try updated.recordVaultRecoveryWrapDigest(format.recoveryWrapDigest)
                try gate.saveEnvelope(updated, storeURL)
            } catch {
                // The open stands; the copy lands at the next words entry.
            }
            return .success(key)
        }
    }

    private nonisolated static func isAbsentWrap(_ error: any Error) -> Bool {
        switch error {
        case StoreKeyEnvelopeError.noPassphraseWrap, StoreKeyEnvelopeError.noRecoveryWrap: return true
        default: return false
        }
    }

    /// The vault read under the ceiling: the first of the two to finish
    /// wins; past the ceiling the read is cancelled and the caller keeps the
    /// local verdict (the vault road is online by nature).
    private nonisolated static func awaitWithin(
        _ ceiling: Duration, _ fetch: Task<KeyVaultFormat?, Error>
    ) async throws -> KeyVaultFormat? {
        try await withThrowingTaskGroup(of: KeyVaultFormat?.self) { group in
            group.addTask { try await fetch.value }
            group.addTask {
                try await Task.sleep(for: ceiling)
                throw VaultReadTimedOut()
            }
            do {
                let first = try await group.next() ?? nil
                group.cancelAll()
                return first
            } catch {
                fetch.cancel()
                group.cancelAll()
                throw error
            }
        }
    }
}
