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

import CryptoKit
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
    /// pre-13x 2c — THE FOLLOW's facts (design §7): the vault's CURRENT
    /// corpus key id (custody's must agree — else the account's keys were
    /// rotated); the row's `updated_at` and `updated_by_device` (decision
    /// 34 — *[device] on [day]* on every notice); the signed-in user id (the
    /// owner distinction, §3.6 — the rows' `owner_id` stamp must be this);
    /// whether a recovery wrap exists; and the fetched FORMAT (wrapped
    /// copies only) so an Always-ask device's held derived key can open the
    /// master copy without a second derivation.
    var corpusKeyID: String? = nil
    var updatedAt: String? = nil
    var updatedByDevice: String? = nil
    var signedInUserID: String? = nil
    var hasRecoveryWrap: Bool = false
    var format: KeyVaultFormat? = nil
    /// pre-13x 4a (ledger 53): the vault's recovery-wrap digest — the key
    /// file's recorded one must agree, else the words were regenerated
    /// elsewhere (the change notice's words twin).
    var recoveryWrapDigest: String? = nil
}

/// pre-13x 3a — what a vault flow hands the key file once M is in custody:
/// the material, the vault's descriptor, and the secret(s) typed or minted
/// in the act (nil = not typed here; their local copies land when they are).
nonisolated struct VaultLanding: Sendable {
    var material: DeviceKeyMaterial
    var kdf: PassphraseKDF.Descriptor
    var passphrase: String?
    var recoveryWords: [String]?
    /// pre-13x 4a (ledger 53): the fetched vault's recovery-wrap digest,
    /// recorded with the descriptor and the corpus key id (nil = the vault
    /// carries no wrap, or the flow had no fetched vault in hand).
    var recoveryWrapDigest: String? = nil
}

/// pre-13x 3a — ENROLL's four directions (design §5's Enroll row; copy §2d):
/// what a signed-in library with NO sync custody learns at ready from the
/// vault's word, the library's OWN posture (the key-file rule) and the
/// iCloud key. The Encryption tab renders its face from these; the silent
/// Standard road (a) needs no face and lands at the reconcile itself.
nonisolated struct EnrollFacts: Equatable, Sendable {
    enum AppleState: Equatable, Sendable {
        /// A readable and the vault's copy is under it — the silent road.
        case matched
        /// A not (yet) readable — copy §2d's waiting face.
        case absent
        /// A readable but the vault's copy is under another Apple ID's.
        case differentAppleID
        /// The account is Castle — no Apple road exists.
        case notApplicable
    }
    var accountPosture: Posture
    var libraryPosture: Posture
    var appleState: AppleState

    /// (c): a Standard-born library joining a CASTLE account re-keys as it
    /// joins — the follow's road with the secret just typed.
    var standardBornJoinsCastle: Bool { accountPosture == .castle && libraryPosture == .standard }
    /// (d): a Castle-born library joining a STANDARD account drops its gate
    /// behind one consent sentence.
    var castleBornJoinsStandard: Bool { accountPosture == .standard && libraryPosture == .castle }
}

/// pre-13x 2c — what a device learns at ready about a change made
/// ELSEWHERE, and the words its notice renders (copy §5).
nonisolated struct FollowNotice: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        /// The account entered Castle on another device; this library was
        /// Standard-shaped — enter the passphrase once (the follow).
        case movedToCastle
        /// pre-13x 2d (decision 35): the account IS Castle and this
        /// library still opens the old way — the keys unchanged; the
        /// passphrase moves the key behind the gate and re-keys the
        /// library (the no-rotation follow). Copy §5's own sentence.
        case castleStillOpensOldWay
        /// 13x F1 (ladder R1-BLOCKER): the account IS Castle and the key
        /// ids agree, but the LIVE key file carries an `apple` copy — a
        /// Standard-era snapshot pair adopted on this Mac (the same-Mac
        /// older-key restore). Whatever gate custody wears, the FILE is
        /// the exposure (§3.4's Castle row: wrapped under P, W, M only;
        /// `retireOldKeyFiles`' own doc names it) — and every later
        /// snapshot copies it. The same no-rotation follow re-keys the
        /// library and retires the file.
        case castleKeyFileAppleOpenable
        /// The account's keys were replaced elsewhere (Replace All Keys, or
        /// Castle entered while this library was already Castle-shaped).
        case keysReplaced
        /// The account left Castle elsewhere — this device followed
        /// silently; one-time, dismissed with OK.
        case movedToStandard
        /// Decision 10's exception: an Always-ask device opened with a
        /// word since changed elsewhere — reads and edits, sync waits.
        case alwaysAskRetiredWord
        /// pre-13x 3a (decision 17; §3.6; copy §3): the rows' owner is not
        /// the signed-in account — a different vault. The typed secret
        /// unwraps THIS account's master and the library is ADOPTED (every
        /// row re-stamped, sync re-initialized, the whole library uploads).
        /// Never a follow; the third door is Cancel, not Later.
        case connectLibrary
        /// pre-13x 4a (ledger 33's lobby half; copy §5's first line): the
        /// passphrase was CHANGED on another device — a convenience act; this
        /// device keeps syncing and its old word still opens it; *Enter It
        /// Now…* lands the new word's local copy. Dismissable per open.
        case passphraseChangedElsewhere
        /// pre-13x 4a (ledger 53): the twelve words were REGENERATED on
        /// another device (the vault's recovery-wrap digest moved) — *Enter
        /// It Now…* lands the new words' local copy. Dismissable per open.
        case wordsRegeneratedElsewhere
    }
    var kind: Kind
    /// The device that acted (`updated_by_device`), or "another device".
    var device: String
    /// The day (`updated_at`), rendered.
    var day: String
    /// The vault's descriptor + corpus key id at the reading — the
    /// Always-ask pickup re-wraps the local copy under them.
    var vaultKDF: PassphraseKDF.Descriptor? = nil
    var corpusKeyID: String? = nil

    var body: String {
        switch kind {
        case .movedToCastle: return ProtectionCopy.followMovedToCastle(device: device, day: day)
        case .castleStillOpensOldWay: return ProtectionCopy.followCastleStillOpensOldWay
        case .castleKeyFileAppleOpenable: return ProtectionCopy.followCastleKeyFileAppleOpenable
        case .keysReplaced: return ProtectionCopy.followKeysReplaced(device: device, day: day)
        case .movedToStandard: return ProtectionCopy.followMovedToStandard(device: device, day: day)
        case .alwaysAskRetiredWord: return ProtectionCopy.alwaysAskRetiredWord(device: device, day: day)
        case .connectLibrary: return ProtectionCopy.keysDontMatchThisLibrary
        case .passphraseChangedElsewhere: return ProtectionCopy.passphraseChangedElsewhere(device: device, day: day)
        case .wordsRegeneratedElsewhere: return ProtectionCopy.wordsRegeneratedElsewhere(device: device, day: day)
        }
    }
    /// pre-13x 4a: the change notices (a convenience change) and the
    /// words-typed door.
    var isChangeNotice: Bool { kind == .passphraseChangedElsewhere || kind == .wordsRegeneratedElsewhere }
    /// The third door under the notice: *Later* for a follow (the
    /// un-followed state is a legal end), *Cancel* for a Connect (nothing
    /// is owed — the library stays as it was).
    var dismissDoor: String {
        if kind == .connectLibrary { return ProtectionCopy.connectCancelDoor }
        if isChangeNotice { return ProtectionCopy.changeDismissDoor }
        return ProtectionCopy.followLaterDoor
    }
    /// The persistent banner after *Later*. The two mismatch kinds render
    /// their own sentence again: no keys were replaced and sync is not
    /// paused, so copy §5's waiting line would be untrue for them (recorded).
    var waitingBody: String {
        switch kind {
        case .castleStillOpensOldWay: return ProtectionCopy.followCastleStillOpensOldWay
        case .castleKeyFileAppleOpenable: return ProtectionCopy.followCastleKeyFileAppleOpenable
        default: return ProtectionCopy.followWaiting(device: device, day: day)
        }
    }
    /// The notice's sub-line under its doors (copy §5, per kind). The
    /// adopted-pair kind shares the mismatch's sub-line — the same fact:
    /// writing made after *Later* stays under the old, Apple-openable key
    /// until the follow (ledger 50(b)'s precision).
    var laterSubline: String {
        kind == .castleStillOpensOldWay || kind == .castleKeyFileAppleOpenable
            ? ProtectionCopy.followCastleStillOpensLaterSubline
            : ProtectionCopy.followLaterSubline
    }
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
    /// pre-13x 4a: the session memory this controller reads (the lobby's
    /// road holds the derived key in it; a relock drops it).
    var syncCustodySession: SyncCustodySession { configuration.syncCustodySession }
    private let guardSeam: StoreKeyGuard
    private let appleKeys: AppleKeyLeaves
    private let logger = Logger(subsystem: "io.lduarte.Variorum", category: "protection")
    private var gate: StoreLaunchGate { configuration.gate }
    private var scope: String { configuration.scope }

    /// Castle's two switches, projected for the pane (writes persist).
    private(set) var dials: ProtectionDials
    /// THE POSTURE (derived — never written): `refreshPosture` re-derives
    /// it from the legacy mode, the vault's last reading and the key file.
    /// pre-13x 2d: the posture the device ACTS as — under an indeterminate
    /// reading (decision 35), its custody shape's.
    private(set) var posture: Posture = .standard
    /// pre-13x 2d (decision 35): THE READING — determined, or
    /// INDETERMINATE for an enrolled library whose vault has not answered.
    /// Every posture-driven WRITE consults `postureReading.determined`;
    /// the faces may say so.
    private(set) var postureReading: PostureReading = .determined(.standard)
    var postureIndeterminate: Bool { postureReading.isIndeterminate }
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
    /// pre-13x ladder round 1, F2 (MAJOR-3 as refined): the Apple arm is
    /// WAITING — the account's vault names an iCloud key this device cannot
    /// read yet and this device holds no master, so nothing is minted (a
    /// mint here would duplicate A under propagation lag); the enroll
    /// road's waiting face (`EnrollFacts.AppleState.absent`) speaks, and
    /// the next ready re-reads. Distinct from `appleKeyLandingFailed`: no
    /// write was refused.
    private(set) var appleKeyWaiting = false

    /// R-pre13u-4: the ONE nudge brain's inputs, projected (both
    /// platforms' faces read THIS; the tier can never diverge).
    var legs: ProtectionLegs {
        ProtectionLegs(
            hasPassphraseWrap: hasPassphraseWrap,
            hasRecoveryWrap: hasRecoveryWrap,
            appleKeyVerified: appleKeyVerified,
            storeCustodyGated: effectiveGate == .biometric,
            factsUnknown: envelopeUnreadable,
            appleKeyWaiting: appleKeyWaiting)
    }

    /// The resident key under the DEMANDED gates (adopted at unlock,
    /// dropped at lock). Under Standard the Keychain releases on demand
    /// and nothing is cached here.
    @ObservationIgnored private var residentKey: StoreKey?

    /// Wired by AppBootstrap: the lock act (Castle only; the callee
    /// re-checks).
    @ObservationIgnored var performLock: (@MainActor () async -> Void)?
    /// pre-13x 2a: the vault's posture reading (AppServices wires the
    /// fetch: signed in + a vault row ⇒ the reading; else nil). Consulted
    /// by the reconcile — the READ half of "an enrolled library's key file
    /// must agree with the vault"; the acts on a disagreement are 2c's
    /// (the follow) and batch 3's (the adopt).
    @ObservationIgnored var readVaultPosture: (@Sendable () async -> VaultPostureReading?)?
    /// pre-13x 2d (decision 35): whether a signed-in session exists
    /// (AppServices wires `auth.currentUserID != nil`) — with the sync
    /// custody's presence, what makes a library ENROLLED at ready. nil =
    /// no auth composed (the reading falls to custody alone).
    @ObservationIgnored var isSignedIn: (@Sendable () async -> Bool)?
    /// The enrollment facts as read at the last reconcile (a session
    /// restored or a custody item landing changes them at the NEXT ready).
    @ObservationIgnored private var signedInAtReady = false
    @ObservationIgnored private var syncCustodyPresentAtReady = false
    /// ENROLLED (decision 35): signed in, or sync custody held — the
    /// session's record (a Castle unlock), the silent item, or the gated
    /// item's presence as read at the last reconcile.
    var enrolled: Bool {
        signedInAtReady || syncCustodyPresentAtReady
            || configuration.syncCustodySession.record != nil
    }
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
        /// pre-13x 2c (§7): the account changed elsewhere — enter the
        /// passphrase or the words once (the modal notice; *Later* allowed).
        case follow(FollowNotice)
        /// pre-13x 2c: *Later* was taken — the PERSISTENT banner (copy §5
        /// "Waiting for your passphrase"); the notice returns at every open.
        case followWaiting(FollowNotice)
        /// pre-13x 2c: the silent follow into Standard ran — one-time, OK.
        case movedToStandard(FollowNotice)
        /// pre-13x 2c (decision 10's exception): the Always-ask banner
        /// variant — the old word opened this device, sync waits.
        case alwaysAskRetiredWord(FollowNotice)
        /// pre-13x 2c (§3.6, copy §3): the rows' owner is NOT the signed-in
        /// account — a different vault; the adopt road is batch 3's, so the
        /// doors that act today are Sign out and the Account sheet.
        case differentOwner
        /// pre-13x 4a (copy §5's first two lines): the passphrase was changed
        /// / the words were regenerated elsewhere — a dismissable banner at
        /// every open until the new word has been used here. Never a
        /// follow: sync keeps running.
        case changedElsewhere(FollowNotice)
    }

    private(set) var notice: Notice?

    // MARK: - pre-13x 2c: THE FOLLOW's state (§7)

    /// The follow owed by this device (nil = none): set by the reconcile
    /// when the vault's corpus key id ≠ custody's under the SAME owner;
    /// cleared when the follow lands (the next reconcile finds them equal).
    private(set) var followNotice: FollowNotice?
    /// *Later*: the modal notice hides for THIS launch and the persistent
    /// banner speaks instead; a new launch asks again.
    @ObservationIgnored private var followDeferredThisLaunch = false
    /// The silent follow into Standard ran this launch — its one-time OK.
    private(set) var movedToStandardNotice: FollowNotice?
    /// The Always-ask banner variant (decision 10's exception).
    private(set) var alwaysAskRetiredNotice: FollowNotice?
    /// The rows' owner is not the signed-in account (copy §3's sentence).
    private(set) var differentOwner = false
    /// pre-13x 4a: the change notice owed by this device (nil = none) — the
    /// key file's recorded descriptor ≠ the vault's (the passphrase kind),
    /// else its recorded recovery-wrap digest ≠ the vault's (the words
    /// kind); cleared when the new word's copy lands. Separate from
    /// `followNotice`: `followPending` stays false — a convenience change
    /// pauses nothing.
    private(set) var changeNotice: FollowNotice?
    /// The change notice's dismissal — per OPEN (a relock + unlock asks
    /// again; a NEW change re-asks at once).
    @ObservationIgnored private var changeNoticeDismissedThisOpen = false
    /// True while a follow is owed — every key door shows *Pick up your new
    /// keys first* instead of acting (the design's un-followed state).
    var followPending: Bool { followNotice != nil }
    /// THE FOLLOW IN PROGRESS, held here like the ceremony so it survives
    /// the re-key's reopen.
    private(set) var activeFollow: PostureFollowModel?
    /// pre-13x 3a — THE EXACT FOREIGN-OWNER READ (`Queries.foreignOwnerExists`
    /// — ANY owner-carrying row non-NULL and ≠ the signed-in id; a mixed
    /// library reads foreign), wired by the bootstrap at ready over the
    /// store; nil = no store read wired (no verdict). Replaces the 2c
    /// first-row `stampedOwnerID` read in the verdict.
    @ObservationIgnored var foreignOwner: (@Sendable (_ signedInUserID: String) async -> Bool)?
    /// pre-13x 3a — ENROLL's facts as read at the last reconcile (nil = not
    /// a signed-in, custody-less library, or the silent road landed).
    private(set) var enrollReading: EnrollFacts?
    /// pre-13x 3a — the silent Standard road's landing (`EncryptionSession
    /// .adoptEnrolledMaterial` — custody under the current shape + the key
    /// file through the landing hook + the refresh), wired by the roots;
    /// nil = the reconcile records the facts and lands nothing.
    @ObservationIgnored var landEnrollment: (@MainActor (DeviceKeyMaterial, PassphraseKDF.Descriptor) async -> Bool)?
    /// pre-13x ladder round 1, F2 (MAJOR-3 (c) — THE HEAL): re-land the
    /// vault's Apple-held copy of the master under the iCloud key this
    /// device NOW reads, in one proof-authorized write (`leaveCastle`'s
    /// shape; production `EncryptionSession.relandAppleHeldCopy`). Called
    /// ONLY on proof of a same-account duplicate — this device's own key
    /// file records the vault's `apple_key_id` AND iCloud Keychain now
    /// hands back a different id: only the same Apple account can replace
    /// the key this device minted. Returns whether the vault write landed;
    /// on false the key file's copy is left under the recorded id so the
    /// proof survives for the next ready.
    @ObservationIgnored var healAppleHeldCopy: (@MainActor (AppleKey) async -> Bool)?
    /// pre-13x 3a — THE ADOPT ROAD's act (`AppServices.connectLibrary`:
    /// the typed secret unwraps this account's master, every row is
    /// re-stamped, sync re-initialized, custody + the key file landed),
    /// wired by the composition root; nil = the Connect door does not act.
    @ObservationIgnored var connectAct: (@MainActor (_ passphrase: String?, _ recoveryWords: [String]?) async throws -> Void)?
    /// The silent follow into Standard's act — the runner's
    /// `followIntoStandard()`, wired by the composition root; nil = no
    /// runner (the reconcile only records the reading).
    @ObservationIgnored var followIntoStandardAct: (@MainActor () async throws -> Void)?
    /// 13x F1 (ladder R1-M1 — P-R1-1): does a RESTORE HOLD stand on this
    /// library (round 3's landing state)? Wired by the composition root
    /// to the same marker projection the sync gate reads; nil = never
    /// held (every existing composition unchanged). The two ROTATION
    /// ceremonies' door consults it and refuses with one sentence.
    @ObservationIgnored var restoreHoldStands: (@MainActor () -> Bool)?

    func openFollow() {
        guard activeFollow == nil else { return }
        let notice = followNotice ?? alwaysAskRetiredNotice
        guard let notice, let switchRunner else { return }
        activeFollow = PostureFollowModel(notice: notice, runner: switchRunner, controller: self)
    }

    /// pre-13x 4a: the change notice's *Enter It Now…* door — the follow
    /// model over the change kind (the passphrase field or the words field
    /// by kind; the vault verifies the NEW word; the local copy lands).
    func openChangeNotice() {
        guard activeFollow == nil, let changeNotice, let switchRunner else { return }
        activeFollow = PostureFollowModel(notice: changeNotice, runner: switchRunner, controller: self)
    }

    /// The change notice's dismiss — for this OPEN; the notice returns at
    /// the next open until the new word has been used here.
    func dismissChangeNotice() {
        changeNoticeDismissedThisOpen = true
        refreshNotices()
    }

    /// The new word's copy landed (the model calls this): the record now
    /// agrees with the vault; the next reconcile finds nothing to say.
    func changeNoticeLanded() {
        changeNotice = nil
        changeNoticeDismissedThisOpen = false
        refreshEnvelopeFacts()
        refreshNotices()
    }

    /// pre-13x 4a (the 2c adjudication's item 1 — `Later` is per OPEN): the
    /// lock road resets every per-open deferral — the follow's *Later*, the
    /// migration confirm's *Later*, the change notice's dismissal — so a
    /// relock + unlock asks again exactly as a launch does.
    func resetPerOpenDeferrals() {
        followDeferredThisLaunch = false
        migrationConfirmDeferredThisLaunch = false
        changeNoticeDismissedThisOpen = false
    }

    /// pre-13x 4a (ledger 54): the derived wrapping key the lobby held for
    /// this session IF it was derived under `kdf` (the vault's descriptor)
    /// — the follow runs from it without a second entry; nil otherwise (a
    /// Touch ID / Face ID open held none; a stale descriptor asks).
    func heldDerivedWrappingKey(under kdf: PassphraseKDF.Descriptor?) -> SymmetricKey? {
        guard let kdf, let key = configuration.syncCustodySession.derivedWrappingKey,
              configuration.syncCustodySession.derivedWrappingKDF == kdf else { return nil }
        return key
    }

    /// **RUN A batch A2, row 10 (her ruling on QUESTIONS #90 (2), ledger
    /// 54): will the follow this notice describes ASK for anything?** ONE
    /// predicate, two readers — `PostureFollowModel.canFollowFromHeldKey`
    /// (which has a model) and the doors that render a label BEFORE a model
    /// exists (the notice bar, the Encryption tab). The door's word comes
    /// from `ProtectionCopy.followEnterDoorLabel(asksNothing:)`, so a door
    /// that will run at once never promises a field.
    func followAsksNothing(for notice: FollowNotice) -> Bool {
        guard notice.kind != .connectLibrary, notice.kind != .alwaysAskRetiredWord,
              !notice.isChangeNotice
        else { return false }
        return heldDerivedWrappingKey(under: notice.vaultKDF) != nil
    }

    /// The same question for the notice currently standing (no model yet).
    var pendingFollowAsksNothing: Bool {
        followNotice.map(followAsksNothing(for:)) ?? false
    }

    /// pre-13x 3a: the Connect door (copy §3's *Connect…*) — the same
    /// follow model and sheets over the `.connectLibrary` kind; opens only
    /// while the rows' owner is not the signed-in account and an act is
    /// wired (P-2: a door that acts).
    func openConnect() {
        guard activeFollow == nil, differentOwner, let switchRunner, connectAct != nil else { return }
        let notice = FollowNotice(
            kind: .connectLibrary,
            device: vaultReading?.updatedByDevice ?? ProtectionCopy.anotherDevice,
            day: ProtectionCopy.day(from: vaultReading?.updatedAt),
            vaultKDF: vaultReading?.passphraseKDF, corpusKeyID: vaultReading?.corpusKeyID)
        activeFollow = PostureFollowModel(notice: notice, runner: switchRunner, controller: self)
    }

    /// The adopt landed (the model calls this): the rows are this
    /// account's now; the next reconcile reads the same owner.
    func connectLanded() {
        differentOwner = false
        refreshEnvelopeFacts()
        refreshNotices()
    }

    func closeFollow() {
        activeFollow = nil
        refreshEnvelopeFacts()
        refreshNotices()
    }

    /// *Later* — the modal notice hides for this launch; the persistent
    /// banner stands; the notice returns at the next open.
    func deferFollow() {
        followDeferredThisLaunch = true
        refreshNotices()
    }

    func dismissMovedToStandard() {
        movedToStandardNotice = nil
        refreshNotices()
    }

    /// The follow landed (the model calls this): the owed follow is gone
    /// until the next reconcile says otherwise.
    func followLanded() {
        followNotice = nil
        alwaysAskRetiredNotice = nil
        followDeferredThisLaunch = false
        refreshEnvelopeFacts()
        refreshNotices()
    }

    /// The material this device holds for its sync — the session's (Castle,
    /// unlocked) or the silent item's (Standard); nil = none in hand.
    private func heldSyncMaterial() -> DeviceKeyMaterial? {
        configuration.syncCustodySession.record?.material
            ?? configuration.resolvedSyncLeaves()?.loadPlain()?.material
    }

    /// THE FOLLOW's DETECTION (§7 / §3.6 — the reconcile's READ half made
    /// into a verdict): from the vault's word and this device's custody.
    private func reconcileFollow(_ reading: VaultPostureReading?) async {
        guard let reading, let vaultKeyID = reading.corpusKeyID else {
            differentOwner = false
            enrollReading = nil
            return
        }
        // THE OWNER DISTINCTION (§3.6; pre-13x 3a — the EXACT read): any
        // owner-carrying row stamped by another account ⇒ a different vault
        // ⇒ copy §3's sentence with the Connect door; never a follow
        // (following would land another account's keys over this library),
        // and never a write — a change on another account can never lock a
        // device out of its own library (pinned).
        if let user = reading.signedInUserID, await foreignOwner?(user) == true {
            differentOwner = true
            followNotice = nil
            alwaysAskRetiredNotice = nil
            changeNotice = nil
            logger.notice("follow: the rows' owner is not the signed-in account — a different vault; the Connect door adopts (decision 17)")
            return
        }
        differentOwner = false
        let device = reading.updatedByDevice ?? ProtectionCopy.anotherDevice
        let day = ProtectionCopy.day(from: reading.updatedAt)
        let keyFile = loadEnvelope()
        if let custody = heldSyncMaterial() {
            alwaysAskRetiredNotice = nil
            let previous = followNotice
            func owe(_ kind: FollowNotice.Kind) {
                if previous?.kind != kind || previous?.corpusKeyID != vaultKeyID {
                    followDeferredThisLaunch = false
                }
                followNotice = FollowNotice(
                    kind: kind, device: device, day: day,
                    vaultKDF: reading.passphraseKDF, corpusKeyID: vaultKeyID)
            }
            if custody.corpusKeyID != vaultKeyID {
                // ROTATED, same owner ⇒ the follow. Castle entered elsewhere
                // and this library still Standard-shaped ⇒ "moved to Castle";
                // otherwise the keys were replaced.
                let kind: FollowNotice.Kind = (!reading.hasAppleHeldCopy && keyFile?.apple != nil)
                    ? .movedToCastle : .keysReplaced
                changeNotice = nil
                owe(kind)
                logger.notice("follow: the account's keys were rotated elsewhere (\(kind == .movedToCastle ? "Castle entered" : "keys replaced", privacy: .public)) — the follow is owed")
                return
            }
            // pre-13x 2d (decision 35) — THE POSTURE MISMATCH: the key ids
            // agree, but the custody SHAPE disagrees with the account's
            // posture. Castle in the vault + the SILENT shape ⇒ the follow
            // into Castle (the runner's no-rotation road: custody behind the
            // gate, a new library key, a new key file with no Apple copy,
            // the old one removed) — the window's phone. Never mid-switch:
            // the re-key's reopen re-runs this reconcile with custody still
            // on its way.
            let shape = libraryKeyCustodyShape
            if !reading.hasAppleHeldCopy, shape == .silent, !switchInProgress {
                changeNotice = nil
                owe(.castleStillOpensOldWay)
                logger.notice("follow: the account is Castle and this library's custody is silent — the follow into Castle is owed (the keys unchanged)")
                return
            }
            // 13x F1 (ladder R1-BLOCKER) — THE ADOPTED STANDARD-ERA PAIR:
            // the account is Castle and the ids agree, but the LIVE key
            // file carries an `apple` copy — a pre-Castle snapshot pair
            // landed by the adoption door on the Mac the library lives on
            // (the same-Mac older-key restore; custody is GATED, so the
            // silent arm above never fires). The posture law (§3.4's
            // Castle row: the library key wrapped under P, W, M only) is
            // violated by the FILE itself, and every later snapshot
            // copies it (`writeSnapshotKeyFile`), so the no-rotation
            // follow is owed: it re-keys the library and
            // `retireOldKeyFiles` removes the apple-carrying file. The
            // verdict writes nothing — the act is the follow's.
            if !reading.hasAppleHeldCopy, keyFile?.apple != nil, !switchInProgress {
                changeNotice = nil
                owe(.castleKeyFileAppleOpenable)
                logger.notice("follow: the account is Castle and the live key file carries an Apple-account copy (an adopted Standard-era pair) — the follow is owed to re-key and retire it")
                return
            }
            followNotice = nil
            // pre-13x 4a (§7 steps 2–3; ledger 33 · 53): THE CHANGE NOTICES —
            // the keys agree and no posture is owed, but a SECRET changed
            // elsewhere: the key file's recorded descriptor ≠ the vault's
            // (the passphrase), else its recorded recovery-wrap digest ≠ the
            // vault's (the words). A device that opened by the NEW word
            // through the lobby's vault road recorded the vault's on the
            // way in and owes nothing; a nil record is unknown and owes
            // nothing. A NEW change (a different notice) re-asks at once
            // even after a dismissal.
            let owedChange = Self.changeElsewhere(keyFile: keyFile, reading: reading, device: device, day: day)
            if owedChange != changeNotice { changeNoticeDismissedThisOpen = false }
            changeNotice = owedChange
            if let owedChange {
                logger.notice("change elsewhere: \(owedChange.kind == .passphraseChangedElsewhere ? "the passphrase was changed" : "the twelve words were regenerated", privacy: .public) on another device — the notice speaks; sync keeps running")
            }
            // THE FOLLOW INTO STANDARD (silent): the vault carries an Apple-held
            // copy under the SAME key id and this library carries no Apple copy
            // (2c) — or, pre-13x 2d, its custody is GATED or nowhere (the
            // shape's mismatch: decision 1's "never a stricter gate under a
            // Standard account").
            if reading.hasAppleHeldCopy, keyFile?.apple == nil || shape == .gatedOrNone, !switchInProgress,
               let act = followIntoStandardAct {
                do {
                    try await act()
                    movedToStandardNotice = FollowNotice(kind: .movedToStandard, device: device, day: day)
                    logger.notice("follow: the account is back in Standard — followed silently")
                } catch {
                    logger.notice("follow into Standard refused: \(String(describing: error), privacy: .public) — the next ready retries")
                }
            }
            return
        }
        // NO MATERIAL IN HAND (pre-13x 3b, ledger 52 — the orchestrator's
        // correction of 3a's "never enrolled" discriminator, which excluded
        // the class the design names in §3.8, §6 and §7: a RESTORED or
        // COPIED library — a master copy and a recorded corpus id in its key
        // file, no custody on this machine — must enroll like any other).
        // THE THREE RULES, in order:
        //  (iii) THE DERIVED-KEY FILL, ANY GATE: the lobby's passphrase road
        //        holds the DERIVED key on every passphrase unlock; when its
        //        descriptor equals the vault's and the recorded corpus id is
        //        nil or the vault's, the vault's master copy opens and the
        //        material lands under the CURRENT shape through the wired
        //        `landEnrollment` (a Touch ID / Face ID device's gated item +
        //        the identity-only plain item + the session; Always ask keeps
        //        the session-only hold) — a Castle copy opened by the
        //        passphrase enrolls with the word just typed, no second entry.
        //        A composition with no landing wired keeps 2c's session hold.
        //   (b)  decision 10's exception: a derived key held under ANOTHER
        //        descriptor while the recorded id IS the vault's ⇒ the word
        //        was changed elsewhere ⇒ the retired-word banner (reads and
        //        edits; sync waits for the new word).
        //   (i)  ENROLL's four directions for ANY library with no custody
        //        material in hand whose recorded id is nil or the vault's —
        //        the silent Standard road (A opens the vault's master; custody
        //        and the key file land through the session's adopt, nothing
        //        typed) or the FACTS for the Encryption tab.
        //  (ii)  a STALE recorded id with no material ⇒ the FOLLOW's notice
        //        for ANY device (the keys were rotated since the snapshot; the
        //        follow's road with the typed secret re-keys the library).
        changeNotice = nil
        let recorded = keyFile?.vaultCorpusKeyID
        let recordedIsCurrent = recorded == nil || recorded == vaultKeyID
        let session = configuration.syncCustodySession
        if recordedIsCurrent, let format = reading.format,
           let derived = session.derivedWrappingKey, session.derivedWrappingKDF == format.kdf,
           let master = try? format.unwrapMaster(withPassphraseKey: derived),
           let material = try? CorpusRotation.materialFollowing(format, master: master) {
            alwaysAskRetiredNotice = nil
            followNotice = nil
            enrollReading = nil
            if let landEnrollment {
                if await landEnrollment(material, format.kdf) {
                    syncCustodyPresentAtReady = true
                    logger.notice("enroll: the typed passphrase's derived key opened the vault's master copy — custody and the key file landed under the current shape, nothing typed again")
                    return
                }
                logger.notice("enroll: custody refused the derived-key landing — the sync keys are held for this session; the next ready retries")
            }
            let identity = configuration.resolvedSyncLeaves()?.loadPlain()?.deviceID
                ?? UUID().uuidString.lowercased()
            session.hold(SyncCustodyRecord(deviceID: identity, material: material))
            logger.notice("follow: the session's derived key opened the vault — sync keys held for the session")
            return
        }
        if let recorded, recorded == vaultKeyID, let format = reading.format,
           session.derivedWrappingKey != nil, session.derivedWrappingKDF != format.kdf {
            enrollReading = nil
            followNotice = nil
            alwaysAskRetiredNotice = FollowNotice(
                kind: .alwaysAskRetiredWord, device: device, day: day,
                vaultKDF: reading.passphraseKDF, corpusKeyID: vaultKeyID)
            logger.notice("follow: the passphrase was changed elsewhere — this device's copy is under the retired word; the banner speaks")
            return
        }
        if recordedIsCurrent, !syncCustodyPresentAtReady, reading.signedInUserID != nil, let format = reading.format {
            alwaysAskRetiredNotice = nil
            followNotice = nil
            let library = libraryOwnPosture
            let account: Posture = reading.hasAppleHeldCopy ? .standard : .castle
            var appleState: EnrollFacts.AppleState = .notApplicable
            var apple: AppleKey?
            if account == .standard {
                apple = appleKeys.read()
                appleState = apple == nil ? .absent : (apple?.id == reading.appleKeyID ? .matched : .differentAppleID)
            }
            if library == .standard, account == .standard, appleState == .matched, let apple, let landEnrollment,
               let master = try? format.unwrapMaster(withAppleKey: apple.symmetricKey),
               let material = try? CorpusRotation.materialFollowing(format, master: master) {
                if await landEnrollment(material, format.kdf) {
                    syncCustodyPresentAtReady = true
                    enrollReading = nil
                    logger.notice("enroll: the Standard road — the iCloud key opened the vault's master copy; custody and the key file landed, nothing typed")
                    return
                }
                logger.notice("enroll: the Standard road — custody refused the keys; the next ready retries")
            }
            enrollReading = EnrollFacts(accountPosture: account, libraryPosture: library, appleState: appleState)
            logger.notice("enroll: owed — account \(account == .standard ? "Standard" : "Castle", privacy: .public), library \(library == .standard ? "Standard" : "Castle", privacy: .public), Apple key \(String(describing: appleState), privacy: .public)")
            return
        }
        enrollReading = nil
        if let recorded, recorded != vaultKeyID {
            let kind: FollowNotice.Kind = (!reading.hasAppleHeldCopy && keyFile?.apple != nil)
                ? .movedToCastle : .keysReplaced
            followNotice = FollowNotice(kind: kind, device: device, day: day,
                                        vaultKDF: reading.passphraseKDF, corpusKeyID: vaultKeyID)
            alwaysAskRetiredNotice = nil
            logger.notice("follow: this library's recorded corpus key id is stale and no custody is in hand — the follow is owed (\(kind == .movedToCastle ? "Castle entered" : "keys replaced", privacy: .public))")
        }
    }
    /// pre-13x 4a — THE CHANGE DETECTION (one rule, both platforms): the
    /// passphrase kind when the key file's recorded descriptor exists and is
    /// not the vault's; else the words kind when both digests exist and
    /// differ; else nothing (an unknown record owes no notice).
    nonisolated static func changeElsewhere(
        keyFile: StoreKeyEnvelope?, reading: VaultPostureReading, device: String, day: String
    ) -> FollowNotice? {
        guard let keyFile else { return nil }
        if let recorded = keyFile.vaultKDF, let vaultKDF = reading.passphraseKDF, recorded != vaultKDF {
            return FollowNotice(kind: .passphraseChangedElsewhere, device: device, day: day,
                                vaultKDF: vaultKDF, corpusKeyID: reading.corpusKeyID)
        }
        if let recordedDigest = keyFile.vaultRecoveryWrapDigest, let vaultDigest = reading.recoveryWrapDigest,
           recordedDigest != vaultDigest {
            return FollowNotice(kind: .wordsRegeneratedElsewhere, device: device, day: day,
                                vaultKDF: reading.passphraseKDF, corpusKeyID: reading.corpusKeyID)
        }
        return nil
    }

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

    /// pre-13x 2b: the same reading for the posture-switch runner (the
    /// library key the re-key starts from).
    func keyInHand() -> StoreKey? { currentKey() }

    // MARK: - pre-13x 2b: the two switches' runner + the pending switch

    /// The posture-switch runner (wired by the composition root; nil ⇒
    /// the choose doors do not render — P-2).
    @ObservationIgnored var switchRunner: PostureSwitchRunner?
    /// True while a switch RUNS on this controller's library — the
    /// reconcile's Apple arm must not land a copy on the NEW key file
    /// between the swap and the custody move (the file is Standard-shaped
    /// for an instant; Castle is what is being entered).
    var switchInProgress = false
    /// The persisted marker's read (a switch that crashed mid-road and is
    /// pending its resume) — the same guard across a relaunch; wired by the
    /// bootstrap at ready.
    @ObservationIgnored var readSwitchPending: (@Sendable () async -> Bool)?
    /// THE CEREMONY IN PROGRESS, held HERE so it survives the re-key's
    /// reopen (the `.ready` tree — the pane and its sheet state with it —
    /// is rebuilt across the pool swap; the controller is not). The pane
    /// presents it as a sheet whenever non-nil.
    private(set) var activeSwitch: PostureSwitchModel?

    // MARK: - Who presents the ceremony (RUN A batch A2, row 11 — 17l item 4 / KnownIssues 40)

    /// **WHERE a ceremony is shown.** Until this row the Mac had exactly ONE
    /// presenter of `activeSwitch` — Settings ▸ Protection — so the Account
    /// sheet's Encryption tab, reached from the main window's bottom bar,
    /// set a model that nothing ever put on screen: the author pressed
    /// *Replace All Keys* and got **a standalone button, no checkbox, no
    /// opportunity to type her existing words**, and a second press was a
    /// no-op behind `openSwitch`'s own `activeSwitch == nil` guard. (The
    /// FOLLOW never had this hole — `ProtectionNoticeBar` has always
    /// presented `activeFollow` — which is exactly why only the ceremony
    /// moves here.)
    ///
    /// Two presenters, one model, and **double presentation impossible by
    /// construction**: the host is decided ONCE, when the ceremony opens,
    /// and each presenter renders only what it owns. Deciding at open time
    /// rather than per-frame is what keeps a Settings window opened DURING a
    /// root-hosted ceremony from tearing the sheet out of the main window
    /// and re-presenting it somewhere else.
    enum CeremonyHost: Equatable { case pane, root }

    /// How many Protection panes are on screen (the Settings scene may be
    /// closed and reopened; a count, never a flag).
    private(set) var mountedProtectionPanes = 0
    private(set) var ceremonyHost: CeremonyHost = .root

    func protectionPaneAppeared() { mountedProtectionPanes += 1 }
    func protectionPaneDisappeared() {
        mountedProtectionPanes = max(0, mountedProtectionPanes - 1)
    }

    /// What `host` should present — nil for the host that does not own the
    /// ceremony in progress. Both presenters bind through this.
    func ceremony(for host: CeremonyHost) -> PostureSwitchModel? {
        ceremonyHost == host ? activeSwitch : nil
    }

    /// Open a ceremony (Use Castle… · Use Standard · the resume door).
    /// nil runner ⇒ nothing opens (the doors do not render — P-2).
    /// pre-13x 3b: `passphraseInHand` / `wordsInHand` — the secrets a key
    /// door hands to Replace All Keys through its checkbox (the screens
    /// that would ask again are skipped).
    func openSwitch(
        _ mode: PostureSwitchModel.Mode, vaultTie: VaultTie?,
        passphraseInHand: String? = nil, wordsInHand: [String]? = nil
    ) {
        guard let switchRunner, activeSwitch == nil else { return }
        // Row 11: the host, decided here and not looked up again.
        ceremonyHost = mountedProtectionPanes > 0 ? .pane : .root
        activeSwitch = PostureSwitchModel(
            mode: mode, runner: switchRunner, controller: self, vaultTie: vaultTie,
            passphraseInHand: passphraseInHand, wordsInHand: wordsInHand)
    }

    func closeSwitch() {
        activeSwitch = nil
        refreshEnvelopeFacts()
        refreshNotices()
    }

    // MARK: - VX-206 — a ceremony opened from Settings ▸ Protection ends there

    /// **A REQUEST that Settings adopts (its pane → Protection)** — the twin of
    /// `MCPDoor.settingsRequest`, the one programmatic open-at-pane road (the
    /// VX-214 machinery ruling). The re-key's reopen rebuilds the `.ready`
    /// tree, and the Settings window's content with it, at its default pane
    /// (General): a ceremony hosted by the pane kept running with no pane to
    /// present its sheet, and its Done waited until she found Protection by
    /// hand. A counter, so every ask is fresh; the window's "seen" mark rides
    /// beside it HERE, because this controller outlives the re-key (the
    /// bootstrap's own) and the Settings view does not.
    private(set) var settingsRequest = 0
    @ObservationIgnored var settingsRequestAdopted = 0

    /// Ask Settings for Protection — only while the ceremony in progress is
    /// the pane's (`ceremonyHost`, decided once when it opened). The re-key's
    /// reopen asks (the During screen comes back where it was) and the road's
    /// return asks (the Done, or the refusal, is on screen where she acted); a
    /// ceremony the main window hosts asks nothing, so General's default and
    /// wherever she left Settings stand.
    func requestProtectionPaneForCeremony() {
        guard activeSwitch != nil, ceremonyHost == .pane else { return }
        settingsRequest += 1
    }

    /// The biometric confirmation (leaving Castle's Touch ID road) —
    /// PROMPTS in production; scripted in tests.
    func confirmPresence(_ reason: String) async -> Bool {
        await guardSeam.confirmPresence(reason)
    }

    /// The words on file, checked against THIS library's key file (the
    /// local-only ceremony's road for "Type My Words…").
    func verifyRecoveryWordsAgainstStore(_ text: String) async -> Bool? {
        guard let envelope = loadEnvelope(), envelope.recovery != nil else { return nil }
        return await Task.detached(priority: .userInitiated) {
            (try? envelope.unwrapKey(recoveryWords: EncryptionSession.words(from: text))) != nil
        }.value
    }

    func refreshEnvelopeFacts() {
        let reading = readEnvelope()
        envelopeUnreadable = reading.isUnreadable
        hasPassphraseWrap = reading.envelope?.passphrase != nil
        hasRecoveryWrap = reading.envelope?.recovery != nil
        keyFileHasMasterCopy = reading.envelope?.master != nil
        keyFileVaultKDF = reading.envelope?.vaultKDF
        keyFileVaultCorpusKeyID = reading.envelope?.vaultCorpusKeyID
        refreshPosture(keyFile: reading.envelope)
    }

    /// pre-13x 2d: the key file's master copy (the migration's leg 5 — or a
    /// follow / switch — wrote it) and the vault descriptor it last
    /// reconciled against (nil = never; the confirm's derived gate).
    @ObservationIgnored private var keyFileHasMasterCopy = false
    @ObservationIgnored private var keyFileVaultKDF: PassphraseKDF.Descriptor?
    /// pre-13x 3b: the vault corpus key id the key file last reconciled
    /// against (nil = never) — Replace All Keys' stale-master front check
    /// reads it against the vault's (§5's row; decision 30's "holding the
    /// CURRENT master").
    @ObservationIgnored private(set) var keyFileVaultCorpusKeyID: String?
    /// pre-13x 3b: the descriptor the key file's passphrase copy was last
    /// reconciled against (nil = never) — the change-passphrase door reads
    /// it against the vault's to word a RETIRED passphrase (copy §5).
    var keyFileRecordedVaultKDF: PassphraseKDF.Descriptor? { keyFileVaultKDF }

    /// THE DERIVED CONFIRM GATE (pre-13x 2d — the brief's item 3): an
    /// ENROLLED library whose key file carries the MASTER copy but NO
    /// recorded vault descriptor — the migration ran while the vault was
    /// unreachable (her Mac at the window: "vault descriptor: next online
    /// ready", which never came) — owes the one-time confirm whether or
    /// not the migration's mark was set: only a TYPED passphrase can land
    /// the descriptor (the local copy re-wraps under it). Typing it lands
    /// `vaultKDF` + the reconciled copy (`reconcilePassphraseWrap`), which
    /// closes this by itself. NOT every enrolled library with a nil
    /// descriptor: a 14c-era Encryption-tab enrollee carries no master copy
    /// and copy §9's sentence is her migration's, not its.
    var migrationConfirmOwedByDerivation: Bool {
        enrolled && keyFileHasMasterCopy && keyFileVaultKDF == nil && !envelopeUnreadable
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
        postureReading = Posture.derive(
            legacyMode: gate.legacyMode(scope, configuration.resolvedStoreID()),
            vaultHasAppleHeldCopy: vaultReading?.hasAppleHeldCopy,
            keyFile: keyFile,
            rawKeyCustody: libraryKeyCustodyShape,
            enrolled: enrolled)
        posture = postureReading.acting
    }

    /// pre-13x 3a — THE LIBRARY's OWN posture (corner 26/27: before sync
    /// each library's posture is its key file's): the local rule alone —
    /// the Apple copy, the wraps, the raw key's custody shape — never the
    /// vault's word and never the enrolled/indeterminate reading. What the
    /// setup ceremony speaks from (the first device gives the vault its
    /// shape) and what enroll's four directions compare against the
    /// account's.
    var libraryOwnPosture: Posture {
        Posture.derive(
            legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: loadEnvelope(),
            rawKeyCustody: libraryKeyCustodyShape, enrolled: false).acting
    }

    /// pre-13x 3a: the iCloud key as this device can READ it (never minted
    /// here — enrollment needs the one the vault's copy is under).
    nonisolated func readAppleKey() -> AppleKey? { appleKeys.read() }
    /// pre-13x 3a: sync setup's A — read, else minted (decision 3: the
    /// first Standard library on this iCloud); nil = the Keychain refused.
    nonisolated func readOrMintAppleKey() -> AppleKey? { appleKeys.readOrMint() }
    /// The key file's passphrase-wrap descriptor (the vault is born under
    /// it — §3.6's derive-once); nil = no wrap on file.
    var currentPassphraseKDF: PassphraseKDF.Descriptor? { loadEnvelope()?.passphrase?.kdf }

    /// The library key's custody SHAPE as this controller knows it without
    /// a Keychain hop (corner 45): after adoption, a resident ⇒ the gated
    /// item or nowhere, none ⇒ the silent item; before adoption, unknown.
    var libraryKeyCustodyShape: RawKeyCustody {
        guard residentAdopted else { return .unknown }
        return residentKey != nil ? .gatedOrNone : .silent
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

    /// ONE SECRET, the guarding direction: does `passphrase` unwrap the
    /// STORE wrap? nil = no wrap exists (nothing to guard); the vault
    /// setup uses this to refuse minting a SECOND passphrase.
    func verifyPassphraseAgainstStore(_ passphrase: String) async -> Bool? {
        guard let envelope = loadEnvelope(), envelope.passphrase != nil else { return nil }
        return await Task.detached(priority: .userInitiated) {
            (try? envelope.unwrapKey(passphrase: passphrase)) != nil
        }.value
    }

    // pre-13x 3b (§13): THE RESET DOOR (R13p-9) MERGED into change
    // passphrase's forgot road — `KeyDoorModel` (Shared): Standard's plain
    // confirm / Castle's Touch ID / Face ID confirm authorize
    // `EncryptionSession.rewrapPassphrase` from the HELD material, and the
    // key file's copy follows under the vault's new descriptor.

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
    /// pre-13x 4a (ledger 53): `recoveryWrapDigest` — the VAULT's wrap's
    /// digest as fetched after the land (nil = no vault in hand) — is
    /// recorded beside the copy, so the device that regenerated its own
    /// words never owes itself the words-regenerated notice.
    @discardableResult
    func landRecoveryWrap(words: [String], recoveryWrapDigest: String?) async -> String? {
        guard let key = currentKey() else { return Self.keyUnavailable }
        do {
            var envelope = try ensuredEnvelope(for: key).envelope
            try envelope.setRecoveryWrap(key: key, words: words)
            if let recoveryWrapDigest { try envelope.recordVaultRecoveryWrapDigest(recoveryWrapDigest) }
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

    /// 13p ladder R1-M3's re-landing (the bootstrap's ready arm): a PROVEN
    /// key back into the silent item. VX-202: on the custody queue — the
    /// save is enqueued at the call, so it runs before any custody move
    /// enqueued after it and can never land behind that move's delete.
    func relandSilentItem(_ key: StoreKey) async -> Bool {
        let guardSeam = self.guardSeam
        return await Self.onCustodyQueue { guardSeam.saveAuto(key) }
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
        // pre-13x 2d (decision 35): ENROLLED? — the session (when an auth
        // is composed) and the per-store sync custody's presence, read
        // ONCE per ready, off the main actor (the silent item's
        // non-prompting read; the gated item's probe).
        signedInAtReady = await isSignedIn?() ?? false
        let leaves = configuration.resolvedSyncLeaves()
        syncCustodyPresentAtReady = await Task.detached(priority: .userInitiated) {
            guard let leaves else { return false }
            return leaves.loadPlain()?.material != nil || leaves.gatedExists()
        }.value
        // The vault's word (decision 8) — one authenticated read, when a
        // vault is reachable; nil leaves the last reading standing.
        var freshReading: VaultPostureReading?
        if let readVaultPosture, let reading = await readVaultPosture() {
            vaultReading = reading
            freshReading = reading
        }
        // VX-202 (belt b): before the posture is re-derived — a lingering
        // silent item is never read as the posture.
        await sweepLingeringSilentItem()
        refreshEnvelopeFacts()
        // pre-13x 2c (§7): the follow's verdict from the vault's word and
        // this device's custody — the notice, the silent follow into
        // Standard, the Always-ask session's fill, the owner distinction.
        await reconcileFollow(freshReading)
        refreshEnvelopeFacts()
        // pre-13x 2b: never land an Apple copy while a switch is in
        // progress or pending its resume — the key file mid-road is
        // Standard-shaped for an instant, and Castle is what is being
        // entered.
        let markerPending = await readSwitchPending?() ?? false
        if !switchInProgress && !markerPending {
            await reconcileAppleKey()
        }
        refreshNotices(now: now)
    }

    /// VX-202 (belt b) — THE AT-READY SWEEP. A silent copy of the library
    /// key beside the GATED item, on a library whose posture — read with
    /// the gated item as the custody shape, never the silent one — is
    /// Castle, breaks the custody law (Touch ID ⇒ the silent item
    /// DELETED): the late R1-M3 save §O.3 traced, or a copy an older build
    /// left. Deleted (the guard's DP-flagged delete), never read as the
    /// posture. Without a gated item the silent item IS the shape (corner
    /// 45's Standard-waiting, a never-followed device) and nothing is
    /// touched. Bounds: after the bootstrap adopted (the shape is known);
    /// a DETERMINED Castle (indeterminate writes nothing — decision 35);
    /// no switch in flight or pending (the runner owns custody then); and
    /// never the only road in — the silent key either opens nothing
    /// current (the key this ready opened with is another) or the live key
    /// file carries a passphrase or twelve-words copy of it. A silent item
    /// that WAS the open's key stays in hand as the resident (the demanded
    /// shape's law).
    private func sweepLingeringSilentItem() async {
        guard residentAdopted, !switchInProgress else { return }
        let pending = await readSwitchPending?() ?? false
        guard !pending, !switchInProgress else { return }
        let guardSeam = self.guardSeam
        let gate = self.gate
        let storeURL = configuration.storeURL
        let found = await Self.onCustodyQueue { () -> (silent: StoreKey?, gated: Bool, keyFile: StoreKeyEnvelope?) in
            let silent = guardSeam.loadAuto()
            guard silent != nil else { return (nil, false, nil) }
            return (silent, guardSeam.gatedItemExists(), gate.readEnvelope(storeURL).envelope)
        }
        guard let silent = found.silent, found.gated else { return }
        let reading = Posture.derive(
            legacyMode: gate.legacyMode(scope, configuration.resolvedStoreID()),
            vaultHasAppleHeldCopy: vaultReading?.hasAppleHeldCopy,
            keyFile: found.keyFile,
            rawKeyCustody: .gatedOrNone,
            enrolled: enrolled)
        guard reading.determined == .castle else { return }
        let opensNothingCurrent = residentKey.map { $0 != silent } ?? false
        let typedRoadRemains = found.keyFile.map {
            $0.keyFingerprint == StoreKeyEnvelope.fingerprint(of: silent)
                && ($0.passphrase != nil || $0.recovery != nil)
        } ?? false
        guard opensNothingCurrent || typedRoadRemains else {
            logger.notice("custody sweep: a silent copy of the library key sits beside the gated item, but no passphrase or twelve-words copy of it is on file — left in place (it may be the only road in)")
            return
        }
        guard await Self.onCustodyQueue({ guardSeam.deleteAuto() }) else {
            logger.notice("custody sweep: the Keychain refused to release the lingering silent item — the next ready retries")
            return
        }
        if residentKey == nil { residentKey = silent }
        logger.notice("custody sweep: a silent copy of the library key beside the gated item on a Castle library was removed (\(opensNothingCurrent ? "a stale key" : "the current key — kept in hand", privacy: .public))")
    }

    /// THE APPLE ARM (§3.8 / the brief's item 2): under Standard with the
    /// key in hand — read A, else mint it; land the key file's `apple`
    /// copy under A's id when absent or under another id; VERIFY the copy
    /// unwraps to the key in hand. Under Castle: no copy opens with A, and
    /// A is never touched (§14.5). Off-main (the guard-seam and Keychain
    /// work); the projections land back on the MainActor.
    ///
    /// pre-13x ladder round 1, F2 (MAJOR-3 AS REFINED — the orchestrator's
    /// rules, which need no iCloud-account identity):
    ///  (a) MINT only from a device that HOLDS M. A signed-in library whose
    ///      vault names an `apple_key_id` this device cannot read, with no
    ///      sync custody in hand, WAITS (`appleKeyWaiting`; the enroll
    ///      road's waiting face) — before F2 it minted A₂ beside the
    ///      account's A₁ under propagation lag, iCloud kept one, and the
    ///      vault's copy stayed under the other forever. A device holding
    ///      M (the first Standard device at sync setup; a device that
    ///      enrolled by a typed secret and still reads no A; a device
    ///      leaving Castle) mints and lands ITS OWN FILE's copy — never
    ///      the vault's (a different Apple ID's device keeps the account's
    ///      vault under the first Apple ID's A — corner 34).
    ///  (c) HEAL only on proof of a same-account duplicate: the key file's
    ///      recorded `appleKeyID` EQUALS the vault's AND `read()` returns
    ///      a DIFFERENT id ⇒ this device's own iCloud Keychain replaced
    ///      the key it minted, which only the same Apple account can do
    ///      ⇒ holding M, the vault's copy is re-landed under the readable
    ///      A FIRST (one proof-authorized write, `healAppleHeldCopy`), then
    ///      the file's copy. A device whose recorded id is not the vault's
    ///      never writes the vault — it re-lands its own file copy under
    ///      what it reads, as before.
    ///      pre-13x ladder round 2, F3 (MINOR-N1 — option A, the rule's
    ///      LETTER): the proof is a key READ, never a key MINTED. A device
    ///      holding M whose file records the vault's id and whose Keychain
    ///      reads NOTHING (a same-account Keychain reset — or the device
    ///      signed into ANOTHER Apple ID, which the client cannot tell
    ///      apart) mints A′ for ITS OWN file only; the vault's copy stays
    ///      under the recorded id (orphaned after a reset until sync setup,
    ///      leaving Castle or a Standard Replace All Keys re-lands it — the
    ///      deliberate re-link door is hers, QUESTIONS #90). Before F3 the
    ///      heal was handed `readOrMint()`'s result, so a mint re-homed the
    ///      account's Apple-held copy silently under whatever Apple account
    ///      this device now held.
    private func reconcileAppleKey() async {
        // pre-13x 2d (decision 35): INDETERMINATE writes nothing — no A
        // read or minted, no copy landed; `appleKeyVerified` stays what it
        // was (the probe's honest unknown). The next ready retries.
        guard let determined = postureReading.determined else {
            logger.notice("apple key reconcile: the posture is indeterminate (enrolled, the vault unread) — nothing written; the next ready retries")
            return
        }
        guard determined == .standard else {
            appleKeyVerified = false
            appleKeyLandingFailed = false
            appleKeyWaiting = false
            return
        }
        // VX-110 (corner 6 — "consent at enrollment"): a Standard reading that
        // is the ACCOUNT's word over a library that is Castle by its OWN key
        // file and custody (the key behind the gate, no sync custody here) is
        // the join the consent asks about — landing the Apple copy would BE
        // that join, silently. Nothing is written until Join (whose follow
        // into Standard lands the copy itself). Keyed on the library's own
        // shape, never on `enrollReading`, which a nil vault read clears while
        // the last reading still says Standard.
        if !syncCustodyPresentAtReady, libraryKeyCustodyShape == .gatedOrNone, libraryOwnPosture == .castle {
            appleKeyVerified = false
            appleKeyLandingFailed = false
            appleKeyWaiting = false
            logger.notice("apple key reconcile: the account reads Standard but this library is Castle and not joined here — nothing lands before the consent")
            return
        }
        let resident = residentKey
        let gate = self.gate
        let guardSeam = self.guardSeam
        let appleKeys = self.appleKeys
        let storeURL = configuration.storeURL
        // F2 (MAJOR-3 a): the account's Apple-held copy names an id; this
        // device holds the master iff sync custody is in hand at this ready.
        let vaultAppleKeyID = vaultReading?.appleKeyID
        let holdsMaster = syncCustodyPresentAtReady
        let mintAllowed = vaultAppleKeyID == nil || holdsMaster
        let read = await Task.detached(priority: .userInitiated) {
            Self.readAppleKeyForReconcile(
                residentKey: resident, gate: gate, guardSeam: guardSeam,
                appleKeys: appleKeys, storeURL: storeURL, mintAllowed: mintAllowed)
        }.value
        guard let read else { return }
        guard let apple = read.apple else {
            appleKeyVerified = false
            if read.waiting {
                appleKeyLandingFailed = false
                appleKeyWaiting = true
                logger.notice("apple key reconcile: the account's iCloud key (\(vaultAppleKeyID?.prefix(8) ?? "?", privacy: .public)) is not readable here and this device holds no master — nothing minted; waiting (the passphrase door acts)")
            } else {
                appleKeyLandingFailed = true
                appleKeyWaiting = false
                logger.info("apple key reconcile: verified false · wrote this pass: false · landing failed: true")
            }
            refreshEnvelopeFacts()
            return
        }
        appleKeyWaiting = false
        // F2 (MAJOR-3 c): the proof of a same-account duplicate, read from
        // the key file BEFORE anything re-lands it. F3 (MINOR-N1): a key
        // MINTED this pass is no proof — the heal keys on a READ alone.
        if let vaultAppleKeyID, holdsMaster, read.minted, read.envelope.appleKeyID == vaultAppleKeyID {
            logger.notice("apple key reconcile: iCloud Keychain read no key; this device holds the master and minted \(apple.id.prefix(8), privacy: .public) for ITS OWN key file — the vault's Apple-held copy stays under the recorded \(vaultAppleKeyID.prefix(8), privacy: .public) (a mint proves no same-account duplicate; sync setup, leaving Castle or a Standard Replace All Keys re-lands it)")
        }
        if let vaultAppleKeyID, holdsMaster, !read.minted,
           read.envelope.appleKeyID == vaultAppleKeyID, apple.id != vaultAppleKeyID {
            logger.notice("apple key reconcile: this device's key file records the vault's iCloud key (\(vaultAppleKeyID.prefix(8), privacy: .public)) but iCloud Keychain now READS \(apple.id.prefix(8), privacy: .public) — the key this device minted was replaced under it, which only the same Apple account can do; re-landing the vault's copy first")
            guard let healAppleHeldCopy, await healAppleHeldCopy(apple) else {
                // The vault write did not land (offline; no road wired):
                // the file's copy stays under the recorded id so the proof
                // survives for the next ready; this A opens no copy yet.
                appleKeyVerified = false
                appleKeyLandingFailed = false
                logger.notice("apple key reconcile: the vault's Apple-held copy could not be re-landed — the key file's copy is left as recorded; the next ready retries")
                refreshEnvelopeFacts()
                return
            }
        }
        let outcome = await Task.detached(priority: .userInitiated) {
            Self.landAppleCopyOffMain(
                key: read.key, envelope: read.envelope, apple: apple, gate: gate, storeURL: storeURL)
        }.value
        appleKeyVerified = outcome.verified
        appleKeyLandingFailed = outcome.landingFailed
        logger.info("apple key reconcile: verified \(String(describing: outcome.verified), privacy: .public) · wrote this pass: \(outcome.wrotePass, privacy: .public) · landing failed: \(outcome.landingFailed, privacy: .public)")
        // The arm can mint/save the envelope; the projection follows the
        // disk it just changed (the P2 doctrine).
        refreshEnvelopeFacts()
    }

    nonisolated struct AppleKeyReconcileOutcome: Sendable {
        var verified: Bool?
        var landingFailed: Bool
        var wrotePass: Bool = false
    }

    /// F2: what the off-main read learned — the key in hand, the key file,
    /// the iCloud key as read (or minted, when minting is allowed), and
    /// whether a nil A means WAITING (minting disallowed) rather than a
    /// refused write. F3 (MINOR-N1): whether `apple` was MINTED this pass
    /// — a mint lands this device's FILE copy only, never the vault's.
    nonisolated struct AppleKeyReconcileRead: Sendable {
        var key: StoreKey
        var envelope: StoreKeyEnvelope
        var apple: AppleKey?
        var waiting: Bool
        var minted: Bool = false
    }

    nonisolated private static func readAppleKeyForReconcile(
        residentKey: StoreKey?, gate: StoreLaunchGate, guardSeam: StoreKeyGuard,
        appleKeys: AppleKeyLeaves, storeURL: URL?, mintAllowed: Bool
    ) -> AppleKeyReconcileRead? {
        guard let key = residentKey ?? guardSeam.loadAuto() else { return nil }
        // P1: an unreadable sidecar SKIPS the arm whole — nothing is ever
        // written over a file that may hold intact wraps.
        guard let ensured = try? ensuredEnvelope(for: key, gate: gate, storeURL: storeURL)
        else { return nil }
        // A: read — or minted, ONLY when this device may (the first
        // Standard library on this iCloud; a device holding the master).
        // F3 (MINOR-N1): the read and the mint are told apart — the heal
        // keys on a READ alone (a mint proves nothing about the account's
        // copy), so `readOrMint` runs only after `read` answered nil.
        let readBack = appleKeys.read()
        let apple = readBack ?? (mintAllowed ? appleKeys.readOrMint() : nil)
        return AppleKeyReconcileRead(
            key: key, envelope: ensured.envelope, apple: apple,
            waiting: apple == nil && !mintAllowed,
            minted: readBack == nil && apple != nil)
    }

    nonisolated private static func landAppleCopyOffMain(
        key: StoreKey, envelope: StoreKeyEnvelope, apple: AppleKey, gate: StoreLaunchGate, storeURL: URL?
    ) -> AppleKeyReconcileOutcome {
        var envelope = envelope
        // The steady state: the copy is under THIS A and opens.
        if envelope.appleKeyID == apple.id,
           (try? envelope.unwrapKey(apple: apple.symmetricKey)) == key {
            return AppleKeyReconcileOutcome(verified: true, landingFailed: false)
        }
        do {
            try envelope.setAppleWrappedCopy(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
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
        passphrase: String, vaultKDF: PassphraseKDF.Descriptor, corpusKeyID: String,
        recoveryWrapDigest: String?
    ) async -> String? {
        guard !passphrase.isEmpty else { return "Type the passphrase first." }
        guard let key = currentKey() else { return Self.keyUnavailable }
        do {
            let wrap = try await Task.detached(priority: .userInitiated) {
                try StoreKeyEnvelope.makePassphraseWrap(key: key, passphrase: passphrase, kdf: vaultKDF)
            }.value
            var envelope = try ensuredEnvelope(for: key).envelope
            try envelope.adoptPassphraseWrap(wrap, key: key)
            try envelope.recordVaultReconciliation(
                kdf: vaultKDF, corpusKeyID: corpusKeyID, recoveryWrapDigest: recoveryWrapDigest)
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

    /// pre-13x 3a — THE VAULT MATERIAL's LANDING on the key file (§3.5; the
    /// 2d hand-forward: a master copy without `vaultKDF` reads as the
    /// migrated-without-descriptor class): after sync setup, an enroll or
    /// a Connect lands M in custody, the key file gains L under M (the
    /// master copy — what makes the local secret copies caches) and records
    /// the vault's descriptor + corpus key id; when the PASSPHRASE was
    /// typed, the local P copy is re-wrapped under the VAULT's descriptor
    /// (corner 27 — the account's passphrase becomes the library's; §3.6's
    /// derive-once) unless it already is; when the WORDS were typed or
    /// generated here, the W copy lands. Returns the worded refusal.
    @discardableResult
    func landVaultMaterial(_ landing: VaultLanding) async -> String? {
        guard let key = currentKey() else { return Self.keyUnavailable }
        if let passphrase = landing.passphrase, !passphrase.isEmpty,
           loadEnvelope()?.passphrase?.kdf != landing.kdf {
            if let refusal = await reconcilePassphraseWrap(
                passphrase: passphrase, vaultKDF: landing.kdf,
                corpusKeyID: landing.material.corpusKeyID,
                recoveryWrapDigest: landing.recoveryWrapDigest) {
                return refusal
            }
        }
        do {
            var envelope = try ensuredEnvelope(for: key).envelope
            try envelope.setMasterWrappedCopy(key: key, under: landing.material.masterSymmetricKey)
            try envelope.recordVaultReconciliation(
                kdf: landing.kdf, corpusKeyID: landing.material.corpusKeyID,
                recoveryWrapDigest: landing.recoveryWrapDigest)
            if let words = landing.recoveryWords, !words.isEmpty {
                try envelope.setRecoveryWrap(key: key, words: words)
            }
            try saveEnvelope(envelope)
            clearMigrationConfirmPending?()
            migrationConfirmPending = false
            refreshEnvelopeFacts()
            refreshNotices()
            logger.notice("vault material landed on the key file: the master copy + the vault's descriptor and corpus key id\(landing.passphrase != nil ? " + the passphrase copy" : "")\(landing.recoveryWords != nil ? " + the twelve words' copy" : "")")
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
        // pre-13x 2d: the mark (the migration's leg 6) OR the derivation
        // (the already-migrated class whose descriptor never landed).
        migrationConfirmPending = (readMigrationConfirmPending?() ?? false) || migrationConfirmOwedByDerivation
        // pre-13x 2c (§7): the follow family outranks the reminder and the
        // nudge — a device whose sync is paused says so first. pre-13x 2d:
        // it outranks the migration confirm too — a follow's new key file
        // lands the descriptor the confirm exists to land (revert batch B
        // showed the two competing on a follow-owing library).
        if differentOwner {
            notice = .differentOwner
            return
        }
        if let follow = followNotice {
            notice = followDeferredThisLaunch ? .followWaiting(follow) : .follow(follow)
            return
        }
        if let retired = alwaysAskRetiredNotice {
            notice = .alwaysAskRetiredWord(retired)
            return
        }
        if let moved = movedToStandardNotice {
            notice = .movedToStandard(moved)
            return
        }
        // pre-13x 4a: the change notices — after the follow family, before
        // the migration confirm; dismissable per open.
        if let change = changeNotice, !changeNoticeDismissedThisOpen {
            notice = .changedElsewhere(change)
            return
        }
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
        // pre-13x 2d (decision 35): the exposed nudge is a DETERMINED
        // Standard's — an enrolled library whose vault has not answered is
        // not "only this device can open your work".
        if !envelopeUnreadable, postureReading.determined == .standard, StandardNudgePolicy.isEligible(
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
    // pre-13x 4a (ledger 53): the vault's recovery-wrap digest rides the
    // landing so the acting device records the words it just regenerated.
    encryption.onRecoveryPhraseLanded = { words, digest in
        _ = await protection.landRecoveryWrap(words: words, recoveryWrapDigest: digest)
    }
    encryption.storePassphraseGuard = { passphrase in
        await protection.verifyPassphraseAgainstStore(passphrase)
    }
    // pre-13x 3a: the vault material's landing on the key file — the master
    // copy + the vault's descriptor and corpus key id (+ the typed secret's
    // copy) after setup / enroll / Connect; enroll's facts for the tab's
    // face; the iCloud key as this device reads it (the (d) join's road).
    encryption.onVaultMaterialLanded = { landing in
        _ = await protection.landVaultMaterial(landing)
    }
    encryption.enrollFacts = { protection.enrollReading }
    encryption.readAppleKey = { protection.readAppleKey() }
    encryption.readOrMintAppleKey = { protection.readOrMintAppleKey() }
    encryption.libraryPosture = { protection.libraryOwnPosture }
    // pre-13x 3a: the store tie the setup ceremony composes (copy §2a).
    encryption.storeTie = StoreTie(
        libraryPosture: { protection.libraryOwnPosture },
        hasPassphrase: { protection.hasPassphraseWrap },
        hasRecoveryWords: { protection.hasRecoveryWrap },
        verifyPassphrase: { await protection.verifyPassphraseAgainstStore($0) },
        setPassphrase: { await protection.setPassphrase($0) },
        verifyRecoveryWords: { await protection.verifyRecoveryWordsAgainstStore($0) },
        passphraseKDF: { protection.currentPassphraseKDF })
    protection.landEnrollment = { material, kdf in
        await encryption.adoptEnrolledMaterial(
            material, kdf: kdf, recoveryWrapDigest: protection.vaultReading?.recoveryWrapDigest)
    }
    // pre-13x ladder round 1, F2 (MAJOR-3 c): the heal's vault write — the
    // session holds the client and this device's custody (M).
    protection.healAppleHeldCopy = { apple in
        await encryption.relandAppleHeldCopy(under: apple)
    }
    // pre-13x 3b: the two re-wrap doors' facts (copy §4; the reset door's
    // merge — the forgot road reads the posture and gate here).
    encryption.keyDoorFacts = KeyDoorFacts(
        posture: { protection.posture },
        gate: { protection.effectiveGate },
        biometryAvailable: { protection.biometryAvailable },
        keyFileVaultKDF: { protection.keyFileRecordedVaultKDF },
        confirmPresence: { await protection.confirmPresence($0) },
        verifyLocalPassphrase: { await protection.verifyPassphraseAgainstStore($0) },
        verifyLocalWords: { await protection.verifyRecoveryWordsAgainstStore($0) },
        setLocalPassphrase: { await protection.setPassphrase($0) })
    // pre-13x 2d (decision 35): signed in ⇒ ENROLLED at ready — the vault's
    // word is then the only thing that can make the library Standard.
    protection.isSignedIn = { await auth.currentUserID != nil }
    if let vault = keyVault {
        protection.readVaultPosture = {
            guard let userID = await auth.currentUserID else { return nil }
            guard let fetched = try? await vault.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID,
                passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true,
                // pre-13x 2c: the follow's facts (§7; decision 34).
                corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt,
                updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: userID,
                hasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil,
                format: fetched.format,
                recoveryWrapDigest: fetched.format.recoveryWrapDigest)
        }
    } else {
        // Totality (ladder R3-n1): "re-wired per session" must hold for the
        // long-lived controller hooks too — a vault-less composition clears
        // any prior session's closures.
        protection.readVaultPosture = nil
    }
}
