//
//  ProtectionController.swift
//  Variorum (shared: Mac + Mobile — the custody choreography's one brain;
//  the Mac's pane and the phone's sheet compose it)
//
//  Phase 13p, Batch 2 — everything that CHANGES protection state: the
//  at-open custody transitions (with the custody law — see StoreKeyGuard's
//  header), setting the passphrase + landing the recovery wrap (knot 4's
//  one-moment-two-artifacts), the R13p-9 RESET door (biometric-confirmed
//  re-wrap — red-pinned: the old wrap must stop unwrapping), the launch
//  reconcile (foreign sidecars set ASIDE, never deleted — they are some
//  other library's recovery legs), the reminder/nudge notice state, and —
//  on the Mac — the re-lock monitors (sleep · screen lock · idle).
//
//  pre-13x batch 2a — POSTURE IS DERIVED, NEVER A SETTING (the postures
//  design §3.1's posture row; the BATCH 2 brief's fact i). The controller
//  projects `posture` (Standard · Castle) from what exists — the vault's
//  Apple-held copy when enrolled, the key file's `apple` copy when
//  local-only, the 13p-era stored mode until §11 retires it — and the
//  EFFECTIVE GATE from (posture, Castle's gate style); the stored three-way
//  mode, the presets, the escrow dial and its coupling copy, the re-lock and
//  reminder dials are GONE (§13). What remains adjustable is Castle's two
//  switches (Always ask · Lock after time away) and Lock Now. A gate-style
//  change moves BOTH custody items — the library key's and the sync
//  record's — in one act (§3.3: "the same item family, the same shape").
//  The launch reconcile's Apple arm replaces the escrow arm: under Standard
//  with the key in hand it reads A (else mints it), lands the key file's
//  Apple copy and VERIFIES it opens (§3.8) — the nudge's covered leg.
//
//  ONE SECRET (R13p-4) is enforced here procedurally, in both directions:
//  the vault's passphrase changes FOLLOW into the store wrap
//  (`followVaultPassphrase`, wired to EncryptionSession's hook), and the
//  reset door runs the vault half FIRST where a vault is wired, refusing
//  whole when it cannot (a store and a vault under different passphrases
//  is exactly what "no second passphrase exists anywhere" forbids).
//

import Foundation
import Observation
import os
import VariorumCore

/// What the vault says about the ACCOUNT's posture (decision 8: once a
/// vault exists, every device follows it) — read at ready by the injected
/// closure; nil = no vault reachable (signed out, no vault yet, offline).
nonisolated struct VaultPostureReading: Equatable, Sendable {
    /// An Apple-held copy of the master exists ⇒ Standard; none ⇒ Castle.
    var hasAppleHeldCopy: Bool
    /// The id of the A that copy is under (the key file's `appleKeyID`
    /// must agree — the client VERIFIES, never adopts).
    var appleKeyID: String?
    /// The vault's passphrase-KDF descriptor (the key file records what its
    /// local copy was last reconciled against — §3.6; the migration lands
    /// it) and whether a passphrase wrap exists (the confirm's gate).
    var passphraseKDF: PassphraseKDF.Descriptor? = nil
    var hasPassphraseWrap: Bool = false
}

@MainActor
@Observable
final class ProtectionController {
    nonisolated struct Configuration: Sendable {
        var scope: String
        var storeURL: URL?
        var gate: StoreLaunchGate
        /// Kept from 13p for the compositions that pass it; the 2a Apple
        /// arm runs on EVERY variant (A is per scope by construction —
        /// the dev build mints and reads its own, the spike's surprise 4).
        var isRealVariant: Bool
        /// The KDF parameters a fresh wrap mints (tests inject small ones;
        /// production takes the v1 default per set).
        var makeKDF: @Sendable () -> PassphraseKDF.Descriptor = {
            .v1(salt: PassphraseKDF.randomSalt())
        }
        /// pre-13x 1a: the store id the dials are keyed by — read from the
        /// key file beside `storeURL` at each dials read/write (it CHANGES
        /// when a new library is started over an absent store). nil ⇒
        /// the scope's legacy keys. Injectable for tests; the default
        /// resolves from `storeURL`.
        var storeID: (@Sendable () -> String?)? = nil
        /// pre-13x 2a: the sync record's custody leaves for the store (the
        /// gate-style transition moves them beside the library key's item);
        /// production is the Keychain per store id, tests inject recorders.
        var syncCustodyLeaves: (@Sendable (_ storeID: String) -> E2EECustodyLeaves)? = nil
        var syncCustodySession: SyncCustodySession = .shared

        func resolvedStoreID() -> String? {
            if let storeID { return storeID() }
            guard let storeURL else { return nil }
            if case .known(let id) = StoreIdentity.resolve(besideStore: storeURL) { return id }
            return nil
        }

        func resolvedSyncLeaves() -> E2EECustodyLeaves? {
            guard let storeID = resolvedStoreID() else { return nil }
            if let syncCustodyLeaves { return syncCustodyLeaves(storeID) }
            return .live(scope: SyncCustodyScope(scope: scope, storeID: storeID))
        }
    }

    private let configuration: Configuration
    private let guardSeam: StoreKeyGuard
    private let appleKeys: AppleKeyLeaves
    private let logger = Logger(subsystem: "io.lduarte.Variorum", category: "protection")
    private var gate: StoreLaunchGate { configuration.gate }
    private var scope: String { configuration.scope }

    /// Castle's two switches, projected for the pane (writes persist).
    private(set) var dials: ProtectionDials
    /// THE POSTURE (derived — never written): `refreshPosture` re-derives
    /// it from the legacy mode, the vault's last reading and the key file.
    private(set) var posture: Posture = .standard
    /// The vault's word, as last read (nil = no vault reachable).
    private(set) var vaultReading: VaultPostureReading?
    /// THE EFFECTIVE GATE — what the routes, the lobby and the custody law
    /// act on. Standard ⇒ silent; Castle ⇒ the device's style.
    var effectiveGate: StoreAtOpenMode {
        StoreAtOpenMode.effective(posture: posture, dials: dials)
    }
    /// The envelope's projected facts (the pane and the notices read these).
    private(set) var hasPassphraseWrap = false
    private(set) var hasRecoveryWrap = false
    /// P1/P11 (pre-13u Act 9): the sidecar EXISTS but could not be read.
    /// While true, both wrap facts above are UNKNOWN (held false), the
    /// nudge stays quiet (it cannot honestly claim "no passphrase"), and
    /// every door that would write the envelope refuses with the
    /// unreadable sentence instead of overwriting the file.
    private(set) var envelopeUnreadable = false
    private(set) var busy = false
    var lastError: String?
    /// The Apple-key leg, VERIFIED (pre-13x 2a — the R-pre13u-4 doctrine
    /// re-based on A): true only when the reconcile read A back AND the
    /// key file's `apple` copy unwrapped to the key in hand; false when
    /// the write could not land, A is unreadable, or the posture is
    /// Castle (no copy opens with A); nil until a reconcile with the key
    /// in hand has run this launch.
    private(set) var appleKeyVerified: Bool?
    /// Honesty about the Apple key: the last attempt to LAND it (or the
    /// key file's copy) was refused — the pane says so instead of letting
    /// the posture imply a copy that does not exist.
    private(set) var appleKeyLandingFailed = false

    /// R-pre13u-4: the ONE nudge brain's inputs, projected (both
    /// platforms' faces read THIS; the tier can never diverge).
    var legs: ProtectionLegs {
        ProtectionLegs(
            hasPassphraseWrap: hasPassphraseWrap,
            hasRecoveryWrap: hasRecoveryWrap,
            appleKeyVerified: appleKeyVerified,
            storeCustodyGated: effectiveGate == .biometric,
            factsUnknown: envelopeUnreadable)
    }

    /// The resident key under the DEMANDED gates (adopted at unlock,
    /// dropped at lock). Under Standard the Keychain releases on demand
    /// and nothing is cached here.
    @ObservationIgnored private var residentKey: StoreKey?

    /// Wired by AppBootstrap: the lock act (Castle only; the callee
    /// re-checks).
    @ObservationIgnored var performLock: (@MainActor () async -> Void)?
    /// Wired where a vault is enrolled (AppServices): re-wrap the VAULT
    /// master under a new passphrase using held material — the reset
    /// door's vault half. Throws = the reset refuses WHOLE (one secret).
    @ObservationIgnored var rewrapVaultPassphrase: ((String) async throws -> Void)?
    /// pre-13x 2a: the vault's posture reading (AppServices wires the
    /// fetch: signed in + a vault row ⇒ the reading; else nil). Consulted
    /// by the reconcile — the READ half of "an enrolled library's key file
    /// must agree with the vault"; the acts on a disagreement are 2c's
    /// (the follow) and batch 3's (the adopt).
    @ObservationIgnored var readVaultPosture: (@Sendable () async -> VaultPostureReading?)?
    /// pre-13x 2a: the idle clock's stamp — when Variorum was last USED
    /// (decision 18). The Mac's event monitor and the became-active hook
    /// stamp it; `relockIfIdle` reads it.
    @ObservationIgnored private(set) var lastUsedAt: Date?

    // MARK: - Notices (the nudge + the reminder)

    enum Notice: Equatable {
        /// Standard's two-offer nudge (knot 4's amendment).
        case nudge
        /// R13p-9's "do you still remember your passphrase?" — always on
        /// in Castle (§13: the dial is gone).
        case reminderDue
        /// pre-13x 2a (§11): her migration's one-time face (copy §9) —
        /// *"Confirm your passphrase once to finish."*
        case migrationConfirm
    }

    private(set) var notice: Notice?
    /// §11: the passphrase confirm is pending (set by the migration; read
    /// from the per-store defaults at every reconcile; cleared by the
    /// confirm). *Later* hides the face for this launch only.
    private(set) var migrationConfirmPending = false
    @ObservationIgnored private var migrationConfirmDeferredThisLaunch = false
    /// The pending read (injected by the bootstrap's composition; nil = no
    /// migration wiring).
    @ObservationIgnored var readMigrationConfirmPending: (@Sendable () -> Bool)?
    @ObservationIgnored var clearMigrationConfirmPending: (@Sendable () -> Void)?

    init(configuration: Configuration) {
        self.configuration = configuration
        self.guardSeam = configuration.gate.guardFor(configuration.scope)
        self.appleKeys = configuration.gate.appleKeyFor(configuration.scope)
        self.dials = configuration.gate.dials(configuration.scope, configuration.resolvedStoreID())
        refreshEnvelopeFacts()
    }

    var biometryAvailable: Bool { guardSeam.biometryAvailable() }

    // MARK: - Resident key custody (the bootstrap's two calls)

    func adoptResident(_ key: StoreKey?) {
        residentKey = key
        residentAdopted = true
        refreshEnvelopeFacts()
    }

    func dropResident() {
        residentKey = nil
        residentAdopted = false
    }

    /// The idle clock's stamp (decision 18): called from the Mac's event
    /// monitor and both platforms' became-active hooks.
    func noteActivity(now: Date = Date()) {
        lastUsedAt = now
    }

    /// The key in hand right now: the resident (demanded gates, unlocked)
    /// or the silent item's release. nil = no act that needs the key can
    /// run (worded by callers).
    private func currentKey() -> StoreKey? {
        residentKey ?? guardSeam.loadAuto()
    }

    private func refreshEnvelopeFacts() {
        let reading = readEnvelope()
        envelopeUnreadable = reading.isUnreadable
        hasPassphraseWrap = reading.envelope?.passphrase != nil
        hasRecoveryWrap = reading.envelope?.recovery != nil
        refreshPosture(keyFile: reading.envelope)
    }

    /// THE DERIVATION, applied: the legacy mode (the read-through, until
    /// §11), the vault's last reading, the key file — and (corner 45,
    /// pre-13x 2b) the raw key's custody shape as this controller knows
    /// it without a Keychain hop: a RESIDENT key exists only under a
    /// demanded gate (the lobby adopted it), so after the bootstrap has
    /// adopted, resident ⇒ gated-or-nowhere and no resident ⇒ the silent
    /// item; before adoption the shape is unknown (the route derives with
    /// the real presence reads).
    private func refreshPosture(keyFile: StoreKeyEnvelope?) {
        let custody: RawKeyCustody
        if residentAdopted {
            custody = residentKey != nil ? .gatedOrNone : .silent
        } else {
            custody = .unknown
        }
        posture = Posture.derive(
            legacyMode: gate.legacyMode(scope, configuration.resolvedStoreID()),
            vaultHasAppleHeldCopy: vaultReading?.hasAppleHeldCopy,
            keyFile: keyFile,
            rawKeyCustody: custody)
    }

    /// Set once the bootstrap has handed the unlocked key over (nil under
    /// Standard — the silent item releases on demand): from then on the
    /// resident's presence is the custody shape (corner 45).
    @ObservationIgnored private var residentAdopted = false

    private func loadEnvelope() -> StoreKeyEnvelope? {
        readEnvelope().envelope
    }

    private func readEnvelope() -> EnvelopeReading {
        gate.readEnvelope(configuration.storeURL)
    }

    private func saveEnvelope(_ envelope: StoreKeyEnvelope) throws {
        try gate.saveEnvelope(
            envelope, configuration.storeURL ?? URL(fileURLWithPath: "/dev/null"))
    }

    /// Load-or-create the envelope FOR `key`. A sidecar whose fingerprint
    /// contradicts the key is FOREIGN (copied from another library, or
    /// left behind by a deleted store) — it is set ASIDE, never deleted:
    /// its wraps are somebody's recovery legs. `onDisk` says whether the
    /// returned envelope is the one already sitting beside the store.
    ///
    /// THROWS `.unreadable` on a present-but-undecodable sidecar (P1/P11):
    /// foreign is a MOVE; unreadable is a REFUSAL; only true absence mints.
    private func ensuredEnvelope(for key: StoreKey) throws
        -> (envelope: StoreKeyEnvelope, onDisk: Bool) {
        try Self.ensuredEnvelope(for: key, gate: gate, storeURL: configuration.storeURL)
    }

    nonisolated private static func ensuredEnvelope(
        for key: StoreKey, gate: StoreLaunchGate, storeURL: URL?
    ) throws -> (envelope: StoreKeyEnvelope, onDisk: Bool) {
        switch gate.readEnvelope(storeURL) {
        case .loaded(let existing):
            if existing.belongs(to: key) { return (existing, true) }
            gate.setAsideEnvelope(storeURL ?? URL(fileURLWithPath: "/dev/null"))
            return (StoreKeyEnvelope(), false)
        case .absent:
            return (StoreKeyEnvelope(), false)
        case .unreadable(let detail):
            throw StoreKeyEnvelopeError.unreadable(detail)
        }
    }

    // MARK: - The passphrase (set · follow · reset)

    /// Land the passphrase wrap (the set-screen's act). The heavy KDF
    /// runs off the main actor. Returns the worded refusal, nil = landed.
    @discardableResult
    func setPassphrase(_ passphrase: String) async -> String? {
        guard !passphrase.isEmpty else { return "Type a passphrase first." }
        guard let key = currentKey() else { return Self.keyUnavailable }
        let kdf = configuration.makeKDF()
        do {
            // P10 (pre-13u Act 9): the heavy KDF derives the WRAP first,
            // envelope-free — the envelope is read FRESH after the
            // derivation returns, and the read→write pair below is
            // awaitless on the MainActor, so a wrap landed during the
            // derivation is never clobbered.
            let wrap = try await Task.detached(priority: .userInitiated) {
                try StoreKeyEnvelope.makePassphraseWrap(
                    key: key, passphrase: passphrase, kdf: kdf)
            }.value
            var envelope = try ensuredEnvelope(for: key).envelope
            try envelope.adoptPassphraseWrap(wrap, key: key)
            try saveEnvelope(envelope)
            gate.setStamp(Date(), Self.passphraseSetAtStamp, scope)
            refreshEnvelopeFacts()
            refreshNotices()
            return nil
        } catch {
            return ProtectionCopy.message(for: error)
        }
    }

    /// ONE SECRET, the following direction: the vault's passphrase was
    /// set/enrolled/changed with `passphrase` — the store wrap follows so
    /// the two can never diverge. Quiet (a hook, not a surface); a
    /// failure leaves the old wrap standing and the next hook retries.
    func followVaultPassphrase(_ passphrase: String) async {
        _ = await setPassphrase(passphrase)
    }

    /// ONE SECRET, the guarding direction: does `passphrase` unwrap the
    /// STORE wrap? nil = no wrap exists (nothing to guard); the vault
    /// setup uses this to refuse minting a SECOND passphrase.
    func verifyPassphraseAgainstStore(_ passphrase: String) async -> Bool? {
        guard let envelope = loadEnvelope(), envelope.passphrase != nil else { return nil }
        return await Task.detached(priority: .userInitiated) {
            (try? envelope.unwrapKey(passphrase: passphrase)) != nil
        }.value
    }

    /// THE RESET DOOR (R13p-9): forgot the passphrase — any enrolled
    /// device re-wraps under a new one after BIOMETRIC confirmation, no
    /// old passphrase needed. The vault half runs FIRST where wired (one
    /// secret). Returns the worded refusal, nil = reset landed. (Batch 5
    /// merges this door into change-passphrase per §13.)
    @discardableResult
    func resetPassphrase(to newPassphrase: String) async -> String? {
        guard !newPassphrase.isEmpty else { return "Type the new passphrase first." }
        // P2 (pre-13x 2a): the door authorizes from the DISK, never the
        // cached projection — an unreadable sidecar is named as such even
        // when the projection last read it whole.
        refreshEnvelopeFacts()
        if envelopeUnreadable {
            return ProtectionCopy.message(for: StoreKeyEnvelopeError.unreadable(""))
        }
        guard hasPassphraseWrap else {
            return "No passphrase is set yet — use Set a Passphrase instead."
        }
        guard biometryAvailable else {
            return "Resetting needs \(ProtectionCopy.biometryName) to confirm it's "
                + "you. Without it, use your recovery phrase: checking it here proves "
                + "it still works, and the change-passphrase door accepts it."
        }
        guard await guardSeam.confirmPresence(
            "Confirm it's you to reset your encryption passphrase") else {
            return "Not confirmed — nothing was changed."
        }
        if let rewrapVaultPassphrase {
            do {
                try await rewrapVaultPassphrase(newPassphrase)
            } catch {
                return "Your account's vault couldn't be moved to the new passphrase "
                    + "(\(EncryptionSession.message(for: error))) — nothing was changed: "
                    + "one passphrase serves both, so the reset waits until it can do both."
            }
        }
        return await setPassphrase(newPassphrase)
    }

    // MARK: - The recovery phrase (knot 4: generated and shown at the set-screen)

    /// Mint the twelve words, wrap the store key under them, land the
    /// wrap, and hand the words back FOR DISPLAY. nil = refused (worded
    /// in `lastError`).
    func generateAndLandRecoveryPhrase() async -> [String]? {
        guard let key = currentKey() else {
            lastError = Self.keyUnavailable
            return nil
        }
        do {
            let words = try RecoveryPhrase.generate()
            var envelope = try ensuredEnvelope(for: key).envelope
            try envelope.setRecoveryWrap(key: key, words: words)
            try saveEnvelope(envelope)
            refreshEnvelopeFacts()
            refreshNotices()
            return words
        } catch {
            lastError = ProtectionCopy.message(for: error)
            return nil
        }
    }

    /// Land TYPED words as the store's recovery wrap — the road for a
    /// vault-enrolled user whose twelve words already exist (one secret).
    @discardableResult
    func landRecoveryWrap(words: [String]) async -> String? {
        guard let key = currentKey() else { return Self.keyUnavailable }
        do {
            var envelope = try ensuredEnvelope(for: key).envelope
            try envelope.setRecoveryWrap(key: key, words: words)
            try saveEnvelope(envelope)
            refreshEnvelopeFacts()
            refreshNotices()
            return nil
        } catch {
            return ProtectionCopy.message(for: error)
        }
    }

    // MARK: - Castle's gate style (the custody law, both items)

    enum ModeChangeOutcome: Equatable {
        case changed
        /// The demanded gates need a passphrase first (the fallback IS the
        /// passphrase) — the pane summons the set-screen, then retries.
        case needsPassphrase
        case refused(String)
    }

    /// **Always ask for the passphrase** (copy §1) — Castle's first
    /// switch. Moves the library key's custody between the Touch ID item
    /// and nowhere AND the sync record between the gated item and the
    /// session, in ONE act; persists the dial only when both moved.
    @discardableResult
    func setAlwaysAsk(_ on: Bool) async -> ModeChangeOutcome {
        guard posture == .castle else {
            return .refused("Always ask is a Castle switch — in Standard the library opens silently.")
        }
        let target: StoreAtOpenMode = on ? .passphrase : .biometric
        guard target != effectiveGate else { return .changed }
        let outcome = await moveCustody(to: target)
        guard outcome == .changed else { return outcome }
        dials.alwaysAsk = on
        persistDials()
        return .changed
    }

    /// The move as a Bool (the migration's leaf calls it from a nonisolated
    /// closure — `ModeChangeOutcome`'s conformance is MainActor-isolated).
    func moveCustodyChanged(to target: StoreAtOpenMode) async -> Bool {
        await moveCustody(to: target) == .changed
    }

    /// THE CUSTODY MOVE, both items (pre-13x 2a; 2b's posture switches
    /// call it for `.auto` ↔ a demanded gate): the library key's item by
    /// the 13p `CustodyHandover` choreography, then the sync record's by
    /// its twin; a refused sync move reverses the library key's move so
    /// the two families never disagree about the shape.
    func moveCustody(to target: StoreAtOpenMode) async -> ModeChangeOutcome {
        if target.isDemanded {
            // P2 (pre-13u Act 9): the authorization reads the DISK at the
            // act, never the cached projection (a stale `true` once
            // authorized deleting both Keychain items over a wrap-less
            // envelope — a permanently unopenable library).
            refreshEnvelopeFacts()
            if envelopeUnreadable {
                return .refused(
                    ProtectionCopy.message(for: StoreKeyEnvelopeError.unreadable("")))
            }
            guard hasPassphraseWrap else { return .needsPassphrase }
        }
        // 17h (13p-fix ladder R3-6): the SecItem work hops OFF the main
        // actor on a SERIAL queue — byte-identical custody semantics.
        let resident = residentKey
        let guardSeam = self.guardSeam
        let outgoing = effectiveGate
        let transition = await Self.onCustodyQueue {
            Self.transitionCustody(
                to: target, residentKey: resident, guardSeam: guardSeam)
        }
        guard transition.outcome == .changed, let key = transition.key else {
            return transition.outcome
        }
        // The sync record follows (§3.3): the same shape, the same act.
        let leaves = configuration.resolvedSyncLeaves()
        let session = configuration.syncCustodySession
        let syncOutcome: CustodyHandover.Outcome = await Self.onCustodyQueue {
            guard let leaves else { return .done }  // no store id ⇒ no custody exists
            return SyncCustodyTransition.move(
                to: SyncCustodyShape(mode: target), leaves: leaves, session: session)
        }
        if syncOutcome != .done {
            // Reverse the library key's move — the two families move together
            // or not at all.
            _ = await Self.onCustodyQueue {
                Self.transitionCustody(to: outgoing, residentKey: key, guardSeam: guardSeam)
            }
            switch syncOutcome {
            case .done: break
            case .writeRefused:
                return .refused("The Keychain refused the sync keys' item — nothing was altered.")
            case .wroteButUnreadable:
                return .refused(ProtectionCopy.syncKeysWroteButUnreadable)
            case .outgoingNotReleased:
                return .refused(ProtectionCopy.syncKeysOutgoingNotReleased)
            }
        }
        // The key stays IN HAND across a mid-session transition (ladder
        // R1-m1): the session that just held the key keeps it as the
        // resident under a demanded gate; `lock()` drops it as always.
        residentKey = target.isDemanded ? key : nil
        return .changed
    }

    /// 17h R3-6 — the serial off-main custody hop.
    nonisolated private static let custodyQueue = DispatchQueue(
        label: "io.lduarte.Variorum.store-custody", qos: .userInitiated)

    nonisolated private static func onCustodyQueue<T: Sendable>(
        _ body: @escaping @Sendable () -> T
    ) async -> T {
        await withCheckedContinuation { continuation in
            custodyQueue.async { continuation.resume(returning: body()) }
        }
    }

    /// The library key's custody choreography (13p, off-main since 17h
    /// R3-6). Returns the outcome and — on `.changed` — the key in hand.
    nonisolated private static func transitionCustody(
        to newMode: StoreAtOpenMode, residentKey: StoreKey?, guardSeam: StoreKeyGuard
    ) -> (outcome: ModeChangeOutcome, key: StoreKey?) {
        guard let key = residentKey ?? guardSeam.loadAuto() else {
            return (.refused(Self.keyUnavailable), nil)
        }
        switch newMode {
        case .auto:
            // 13p-fix R1-1: verify the incoming item READS BACK before the
            // outgoing one goes (see `CustodyHandover`).
            switch CustodyHandover.perform(
                write: { guardSeam.saveAuto(key) },
                // Identity, not presence (R2-4): a stale item under the
                // same service/account would pass `!= nil`.
                verify: { guardSeam.loadAuto() == key },
                deleteOutgoing: { guardSeam.deleteGated() },
                rollBackIncoming: { _ = guardSeam.deleteAuto() }) {
            case .done: break
            case .writeRefused:
                return (.refused("The Keychain refused the change — nothing was altered."), nil)
            case .wroteButUnreadable:
                return (.refused(ProtectionCopy.wroteButUnreadable), nil)
            case .outgoingNotReleased:
                return (.refused(ProtectionCopy.outgoingCustodyNotReleased), nil)
            }
        case .biometric:
            guard guardSeam.biometryAvailable() else {
                return (.refused("This \(ProtectionCopy.deviceName) has no "
                    + "\(ProtectionCopy.biometryName) to gate the key with — use "
                    + "Always ask instead."), nil)
            }
            // The gated item lands FIRST; only then does the silent item
            // go (never a keyless moment, never a silent one either).
            switch CustodyHandover.perform(
                write: { guardSeam.saveGated(key) },
                // Presence only — reading an ACL'd item's DATA prompts, and
                // a write must never prompt (R2-4's stated exception).
                verify: { guardSeam.gatedItemExists() },
                deleteOutgoing: { guardSeam.deleteAuto() },
                rollBackIncoming: { _ = guardSeam.deleteGated() }) {
            case .done: break
            case .writeRefused:
                return (.refused("The Keychain refused the gated item — nothing was altered."), nil)
            case .wroteButUnreadable:
                return (.refused(ProtectionCopy.wroteButUnreadable), nil)
            case .outgoingNotReleased:
                return (.refused(ProtectionCopy.outgoingCustodyNotReleased), nil)
            }
        case .passphrase:
            // 17h R3-5's second shape: this arm's law is "NEITHER item
            // exists", each release verified; gated goes FIRST.
            guard guardSeam.deleteGated() else {
                return (.refused(ProtectionCopy.outgoingCustodyNotReleased), nil)
            }
            guard guardSeam.deleteAuto() else {
                return (.refused(ProtectionCopy.outgoingCustodyNotReleased), nil)
            }
        }
        return (.changed, key)
    }

    // MARK: - Castle's idle dial

    /// **Lock after time away** (copy §1): 5 · 10 · 30 · never; the
    /// clock is time since Variorum was last used.
    func setRelockIdleMinutes(_ minutes: Int?) {
        dials.relockAfterIdleMinutes = minutes
        persistDials()
    }

    private func persistDials() {
        gate.saveDials(dials, scope, configuration.resolvedStoreID())
    }

    // MARK: - The launch reconcile

    /// Idempotent launch housekeeping, called once the store is READY
    /// (never before unlock): re-read the dials, stamp first use, read the
    /// vault's posture word, re-derive the posture, run the Apple arm
    /// (Standard: A read or minted, the key file's Apple copy landed and
    /// VERIFIED), and refresh the notice state.
    func reconcile(now: Date = Date()) async {
        // Re-read the persisted dials FIRST (ladder R1-m2's corner): the
        // launch road can write the stored dials WITHOUT this controller.
        dials = gate.dials(scope, configuration.resolvedStoreID())
        if gate.stamp(Self.firstUseStamp, scope) == nil {
            gate.setStamp(now, Self.firstUseStamp, scope)
        }
        // The vault's word (decision 8) — one authenticated read, when a
        // vault is reachable; nil leaves the last reading standing.
        if let readVaultPosture, let reading = await readVaultPosture() {
            vaultReading = reading
        }
        refreshEnvelopeFacts()
        await reconcileAppleKey()
        refreshNotices(now: now)
    }

    /// THE APPLE ARM (§3.8 / the brief's item 2): under Standard with the
    /// key in hand — read A, else mint it; land the key file's `apple`
    /// copy under A's id when absent or under another id; VERIFY the copy
    /// unwraps to the key in hand. Under Castle: no copy opens with A, and
    /// A is never touched (§14.5). Off-main (the guard-seam and Keychain
    /// work); the projections land back on the MainActor.
    private func reconcileAppleKey() async {
        guard posture == .standard else {
            appleKeyVerified = false
            appleKeyLandingFailed = false
            return
        }
        let resident = residentKey
        let gate = self.gate
        let guardSeam = self.guardSeam
        let appleKeys = self.appleKeys
        let storeURL = configuration.storeURL
        let outcome = await Task.detached(priority: .userInitiated) {
            Self.reconcileAppleKeyOffMain(
                residentKey: resident, gate: gate, guardSeam: guardSeam,
                appleKeys: appleKeys, storeURL: storeURL)
        }.value
        if let outcome {
            appleKeyVerified = outcome.verified
            appleKeyLandingFailed = outcome.landingFailed
            logger.info("apple key reconcile: verified \(String(describing: outcome.verified), privacy: .public) · wrote this pass: \(outcome.wrotePass, privacy: .public) · landing failed: \(outcome.landingFailed, privacy: .public)")
        }
        // The arm can mint/save the envelope; the projection follows the
        // disk it just changed (the P2 doctrine).
        refreshEnvelopeFacts()
    }

    nonisolated struct AppleKeyReconcileOutcome: Sendable {
        var verified: Bool?
        var landingFailed: Bool
        var wrotePass: Bool = false
    }

    nonisolated private static func reconcileAppleKeyOffMain(
        residentKey: StoreKey?, gate: StoreLaunchGate, guardSeam: StoreKeyGuard,
        appleKeys: AppleKeyLeaves, storeURL: URL?
    ) -> AppleKeyReconcileOutcome? {
        guard let key = residentKey ?? guardSeam.loadAuto() else { return nil }
        // P1: an unreadable sidecar SKIPS the arm whole — nothing is ever
        // written over a file that may hold intact wraps.
        guard let ensured = try? ensuredEnvelope(for: key, gate: gate, storeURL: storeURL)
        else { return nil }
        var envelope = ensured.envelope
        // A: read, else minted (the first Standard library on this iCloud).
        guard let apple = appleKeys.readOrMint() else {
            return AppleKeyReconcileOutcome(verified: false, landingFailed: true)
        }
        // The steady state: the copy is under THIS A and opens.
        if envelope.appleKeyID == apple.id,
           (try? envelope.unwrapKey(apple: apple.symmetricKey)) == key {
            return AppleKeyReconcileOutcome(verified: true, landingFailed: false)
        }
        do {
            try envelope.appleBox(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
            try gate.saveEnvelope(envelope, storeURL ?? URL(fileURLWithPath: "/dev/null"))
        } catch {
            return AppleKeyReconcileOutcome(verified: false, landingFailed: true, wrotePass: true)
        }
        // VERIFIED means the fresh copy READS BACK and opens — never the
        // write's own word for it.
        let readBack = gate.readEnvelope(storeURL).envelope
        let verified = readBack?.appleKeyID == apple.id
            && (try? readBack?.unwrapKey(apple: apple.symmetricKey)) == key
        return AppleKeyReconcileOutcome(
            verified: verified, landingFailed: !verified, wrotePass: true)
    }

    // MARK: - The migration's one-time confirm (§11; copy §9)

    /// The confirm's act: the typed word already unwrapped the VAULT's
    /// master (the model verified it); re-wrap the local passphrase copy
    /// under the vault's descriptor and record the reconciliation — the
    /// lobby's vault road then derives once. Returns the worded refusal.
    @discardableResult
    func reconcilePassphraseWrap(
        passphrase: String, vaultKDF: PassphraseKDF.Descriptor, corpusKeyID: String
    ) async -> String? {
        guard !passphrase.isEmpty else { return "Type the passphrase first." }
        guard let key = currentKey() else { return Self.keyUnavailable }
        do {
            let wrap = try await Task.detached(priority: .userInitiated) {
                try StoreKeyEnvelope.makePassphraseWrap(key: key, passphrase: passphrase, kdf: vaultKDF)
            }.value
            var envelope = try ensuredEnvelope(for: key).envelope
            try envelope.adoptPassphraseWrap(wrap, key: key)
            try envelope.recordVaultReconciliation(kdf: vaultKDF, corpusKeyID: corpusKeyID)
            try saveEnvelope(envelope)
            clearMigrationConfirmPending?()
            migrationConfirmPending = false
            refreshEnvelopeFacts()
            refreshNotices()
            return nil
        } catch {
            return ProtectionCopy.message(for: error)
        }
    }

    /// *Later* — the face is hidden for this launch; the mark stays.
    func deferMigrationConfirm() {
        migrationConfirmDeferredThisLaunch = true
        refreshNotices()
    }

    // MARK: - Notices

    func refreshNotices(now: Date = Date()) {
        migrationConfirmPending = readMigrationConfirmPending?() ?? false
        if migrationConfirmPending, !migrationConfirmDeferredThisLaunch {
            notice = .migrationConfirm
            return
        }
        // The reminder: always on in Castle (§13 — the dial is gone; the
        // Standard nudge covers the no-passphrase state).
        if ReminderCheckPolicy.isDue(
            now: now,
            enabled: posture == .castle,
            passphraseSetAt: gate.stamp(Self.passphraseSetAtStamp, scope),
            lastConfirmedAt: gate.stamp(Self.reminderConfirmedStamp, scope),
            lastDismissedAt: gate.stamp(Self.reminderDismissedStamp, scope)) {
            notice = .reminderDue
            return
        }
        // P1/P11: while the sidecar is unreadable the wrap facts are
        // UNKNOWN — a nudge claiming "no passphrase" would be a false steer.
        if !envelopeUnreadable, posture == .standard, StandardNudgePolicy.isEligible(
            now: now,
            firstUseAt: gate.stamp(Self.firstUseStamp, scope),
            dismissedForever: gate.stamp(Self.nudgeDismissedStamp, scope) != nil,
            snoozedUntil: gate.stamp(Self.nudgeSnoozeStamp, scope),
            hasPassphraseWrap: hasPassphraseWrap,
            hasRecoveryWrap: hasRecoveryWrap) {
            notice = .nudge
            return
        }
        notice = nil
    }

    func snoozeNudge(now: Date = Date()) {
        gate.setStamp(now.addingTimeInterval(StandardNudgePolicy.snooze),
                      Self.nudgeSnoozeStamp, scope)
        refreshNotices(now: now)
    }

    func dismissNudgeForever(now: Date = Date()) {
        gate.setStamp(now, Self.nudgeDismissedStamp, scope)
        refreshNotices(now: now)
    }

    /// The reminder's outcomes: a CONFIRMED check resets the cadence; a
    /// dismissal snoozes one full cadence (the policy's letter).
    func recordReminderConfirmed(now: Date = Date()) {
        gate.setStamp(now, Self.reminderConfirmedStamp, scope)
        refreshNotices(now: now)
    }

    func dismissReminder(now: Date = Date()) {
        gate.setStamp(now, Self.reminderDismissedStamp, scope)
        refreshNotices(now: now)
    }

    /// The reminder face's local check road (SecretCheckModel's
    /// `storeCheck`): the REAL unwrap against the sidecar, off-main,
    /// result discarded.
    func makeStoreSecretCheck() -> @Sendable (SecretCheckModel.Secret, String) async
        -> SecretCheckModel.LocalOutcome {
        let gate = gate
        let storeURL = configuration.storeURL
        return { secret, entry in
            let outcome: SecretCheckModel.LocalOutcome = await Task.detached(
                priority: .userInitiated
            ) {
                do {
                    guard let envelope = try gate.loadEnvelope(
                        storeURL ?? URL(fileURLWithPath: "/dev/null")) else {
                        return .couldNotCheck(
                            "This library has no passphrase or recovery phrase on file yet.")
                    }
                    switch secret {
                    case .passphrase:
                        _ = try envelope.unwrapKey(passphrase: entry)
                    case .recoveryPhrase:
                        _ = try envelope.unwrapKey(
                            recoveryWords: EncryptionSession.words(from: entry))
                    }
                    return .correct
                } catch StoreKeyEnvelopeError.wrongPassphrase {
                    return .wrong
                } catch StoreKeyEnvelopeError.wrongRecoveryPhrase {
                    return .wrong
                } catch {
                    return .couldNotCheck(ProtectionCopy.message(for: error))
                }
            }.value
            return outcome
        }
    }

    // MARK: - Re-lock monitors (Mac — sleep · screen lock · idle)

    #if os(macOS)
    @ObservationIgnored private var workspaceTokens: [NSObjectProtocol] = []
    @ObservationIgnored private var distributedTokens: [NSObjectProtocol] = []
    @ObservationIgnored private var idleTask: Task<Void, Never>?
    @ObservationIgnored private var activityMonitor: Any?

    /// Started by the production bootstrap only (never test instances):
    /// each trigger re-checks the derived gate at FIRE time. pre-13x 2a:
    /// re-lock on sleep / screen lock is ALWAYS ON in Castle (decision
    /// 18), and the idle clock is Variorum's own activity — the local
    /// event monitor stamps it (never the system's idle clock, which any
    /// app resets: "switching to another app doesn't lock it; time away
    /// does").
    func startRelockMonitors() {
        stopRelockMonitors()
        let workspace = NSWorkspace.shared.notificationCenter
        workspaceTokens.append(workspace.addObserver(
            forName: NSWorkspace.willSleepNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in await self?.relockIfPolicySays() }
        })
        distributedTokens.append(DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.screenIsLocked"),
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in await self?.relockIfPolicySays() }
        })
        activityMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown,
                       .scrollWheel, .magnify, .swipe]
        ) { [weak self] event in
            Task { @MainActor [weak self] in self?.noteActivity() }
            return event
        }
        noteActivity()
        idleTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                await self?.relockIfIdle()
            }
        }
    }

    func stopRelockMonitors() {
        let workspace = NSWorkspace.shared.notificationCenter
        for token in workspaceTokens { workspace.removeObserver(token) }
        for token in distributedTokens {
            DistributedNotificationCenter.default().removeObserver(token)
        }
        workspaceTokens = []
        distributedTokens = []
        if let activityMonitor { NSEvent.removeMonitor(activityMonitor) }
        activityMonitor = nil
        idleTask?.cancel()
        idleTask = nil
    }

    private func relockIfPolicySays() async {
        guard effectiveGate.isDemanded else { return }
        await performLock?()
    }

    private func relockIfIdle() async {
        guard effectiveGate.isDemanded else { return }
        guard IdleLockClock.isDue(
            now: Date(), lastUsedAt: lastUsedAt, minutes: dials.relockAfterIdleMinutes)
        else { return }
        await performLock?()
    }
    #endif

    // MARK: - Stamps & wording

    static let firstUseStamp = "firstUseAt"
    static let passphraseSetAtStamp = "passphraseSetAt"
    static let reminderConfirmedStamp = "reminderConfirmedAt"
    static let reminderDismissedStamp = "reminderDismissedAt"
    static let nudgeSnoozeStamp = "nudgeSnoozedUntil"
    static let nudgeDismissedStamp = "nudgeDismissedForever"

    // Nonisolated since 17h R3-6: read from the off-main transition hop.
    nonisolated static let keyUnavailable =
        "This library's key isn't in hand right now — unlock the library first."
}

#if os(macOS)
import AppKit
#endif

/// The reset door's vault half, refused because this device's key
/// material is locked or absent — worded through
/// `EncryptionSession.message(for:)`'s describing arm.
nonisolated struct VaultRewrapNeedsUnlockedKeys: Error, CustomStringConvertible {
    var description: String {
        "this device's keys are locked — unlock them under Settings ▸ Encryption "
        + "and try again"
    }
}

// MARK: - The one-secret wiring (R13p-4 — ladder R2-M1, the shared factory)

/// THE FOUR ONE-SECRET HOOKS, as ONE factory both compositions call
/// (ladder R2-M1; the `mobileWillLock` precedent — production's own
/// composition drivable by a scripted pin). pre-13x 2a adds the fifth
/// wire: the vault's POSTURE reading (`readVaultPosture`) — signed in and
/// a vault row ⇒ the account's word; else nil.
@MainActor
func wireOneSecretHooks(
    protection: ProtectionController,
    encryption: EncryptionSession,
    keyVault: KeyVaultClient?,
    auth: AuthSession
) {
    encryption.onPassphraseChanged = { passphrase in
        await protection.followVaultPassphrase(passphrase)
    }
    encryption.onRecoveryPhraseLanded = { words in
        _ = await protection.landRecoveryWrap(words: words)
    }
    encryption.storePassphraseGuard = { passphrase in
        await protection.verifyPassphraseAgainstStore(passphrase)
    }
    if let vault = keyVault {
        protection.rewrapVaultPassphrase = { newPassphrase in
            // Signed out / no vault row ⇒ no vault half.
            guard await auth.currentUserID != nil else { return }
            guard try await vault.fetchVault() != nil else { return }
            guard let material = await encryption.heldMaterial() else {
                throw VaultRewrapNeedsUnlockedKeys()
            }
            try await VaultEnrollment(client: vault).rewrapPassphrase(
                material: material, newPassphrase: newPassphrase)
        }
        protection.readVaultPosture = {
            guard await auth.currentUserID != nil else { return nil }
            guard let fetched = try? await vault.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID,
                passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true)
        }
    } else {
        // Totality (ladder R3-n1): "re-wired per session" must hold for the
        // long-lived controller hooks too — a vault-less composition clears
        // any prior session's closures.
        protection.rewrapVaultPassphrase = nil
        protection.readVaultPosture = nil
    }
}
