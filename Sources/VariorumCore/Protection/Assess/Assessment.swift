import Foundation

// VX-305 U2 — WHAT `assess` RETURNS (design §3.3): the mode and the account,
// each confirmed or not; the roads; every door with its reason; the repairs
// owed and the acts owed; and the words every surface shows — as TYPED
// REASONS, which later phases render (phase 4 and 5's copy, her approval at
// their walks). Values only: the executor (U3) is the one thing that writes.

/// Where a launch goes, decided before any store is opened (§3.3, §3.7 of
/// the pre-13x design kept: a missing library is missing in both modes).
public enum LaunchVerdict: Equatable, Sendable {
    /// No library and no marker: a first launch — a library is created.
    case startFresh
    /// No library, and the container's marker says one lived here: restore,
    /// open an existing library, or start a new one. The lock stays.
    case libraryMissing
    /// A library, locked: the lobby offers its roads.
    case lobby
    /// Unlocked.
    case open
}

/// The mode — the current key's kind (§3.3). (Its "confirmed or not" and
/// corner 45 left with rule 26: the record's mode is always known.)
public struct ModeVerdict: Equatable, Sendable {
    public enum Source: Equatable, Sendable {
        /// Before unlock: what this Mac remembers — a display hint that decides
        /// nothing.
        case hintOnly
        /// The record.
        case record
    }

    /// nil before unlock when nothing is remembered.
    public var mode: ProtectionMode?
    public var source: Source
}

/// §3.8's four situations.
public enum AccountSituation: Equatable, Sendable {
    /// The library has no account: local only; the Encryption tab offers to
    /// turn sync on.
    case localOnly
    /// The library's account, signed in: in sync, following its mode.
    case inSync(account: String)
    /// The library's account, nobody signed in: not syncing; the one-road
    /// This-Mac-Only screens.
    case signedOut(account: String)
    /// Another account signed in: one screen — *Move it to y@…* or *Sign
    /// out* — the same email with a different account named.
    case otherAccount(library: String, signedIn: String, sameEmail: Bool)
}

public struct AccountVerdict: Equatable, Sendable {
    public var situation: AccountSituation
    /// The record's account (none, or one id).
    public var account: String?
    /// Confirmed: the library's account, signed in, its vault read this
    /// session.
    public var confirmed: Bool
}

/// How the sync keys are held — by the account's mode (rule 15's custody).
public enum SyncKeysCustody: Equatable, Sendable {
    /// Castle: Touch ID, or session memory under Always ask.
    case castleWay
    /// Standard: a silent item.
    case silent
}

/// The vault, read (§3.9).
public struct VaultVerdict: Equatable, Sendable {
    public var mode: VaultMode
    public var rotationInProgress: Bool
    /// A rotation with no id — completed by anyone, never with an Apple copy.
    public var completesWithoutAppleCopy: Bool
    /// How this device holds the account's sync keys now.
    public var syncKeysCustody: SyncKeysCustody
    /// A follower that sees the master replaced while a rotation is in
    /// progress follows the keys but holds its library's re-key until the
    /// vault reads Standard or Castle.
    public var followHoldsLibraryRekey: Bool
}

// MARK: - Touch ID (§3.10, VX-310)

public enum TouchIDQuietLine: Equatable, Sendable {
    /// No Touch ID hardware, or no finger enrolled on this Mac.
    case notSetUpOnThisMac
    /// No Touch ID item for this library's current key.
    case notSetUpForThisLibrary
}

/// The lobby's Touch ID line and button, as data (VX-310: "there should
/// always be a button you can click to launch the touchid prompt").
public struct TouchIDAssessment: Equatable, Sendable {
    /// The *Unlock with Touch ID* button — whenever a Touch ID item for the
    /// current key exists, however many times the prompt was dismissed.
    public var button: Bool
    /// The one automatic ask, at open (this device's choice is Touch ID).
    public var autoAsk: Bool
    /// Pressing it now says why it can't, and changes nothing.
    public var pressSays: TransientUnavailability?
    /// With no button, the one quiet line saying why.
    public var quietLine: TouchIDQuietLine?
    /// After a press failed on an item that exists: *Touch ID changed since
    /// you set it up — unlock with the passphrase*.
    public var changedLine: Bool
    /// After the passphrase opens: the re-arm question — asked ONLY after a
    /// press failed on an item that exists.
    public var rearmQuestion: Bool
}

// MARK: - Roads (before unlock)

/// A typed road the live key file has.
public enum TypedRoad: String, Hashable, Sendable {
    case passphrase
    case words
}

/// The lobby's roads (§3.3): what this device has for the library. Every
/// road verifies itself; nothing here decides.
public struct LobbyRoads: Equatable, Sendable {
    /// Roads that need no person, tried at once: every silent item (whatever
    /// fingerprint it names) …
    public var silentItems: [CustodyItemFact]
    /// … and the live key file's Apple wrap, when its key is readable here.
    public var appleKeyID: String?
    /// The custody items enumerated, whatever fingerprint they name.
    public var custodyItems: [CustodyItemFact]
    /// The current passphrase or words — the live key file's typed locks
    /// (rule 4's one sentence: they open the current key and its history).
    public var typed: Set<TypedRoad>
    /// The vault road behind the typed secrets (signed in).
    public var vaultRoad: Bool
}

// MARK: - Repairs, faults, acts

/// A check the executor makes before a repair deletes anything (§3.3: "every
/// delete comes after its replacement has verified").
public enum RepairPrecondition: Hashable, Sendable {
    /// The live history verifiably holds this key (opened with the current
    /// key, its fingerprint checked).
    case historyHolds(fingerprint: String)
    /// The live key file's passphrase or words wrap verifiably opens the
    /// current key.
    case currentKeyHasTypedRoad
}

/// A repair — moves toward the record, idempotent, run by the executor
/// (§3.3). None ever makes a Touch ID item or changes a key's kind.
public enum Repair: Hashable, Sendable {
    /// Castle: no silent item for any key the library has had.
    case deleteSilentItem(fingerprint: String, precondition: RepairPrecondition)
    /// Castle: an Apple key this Mac's section lists as retired — delete on
    /// sight, by its id only.
    case deleteRetiredAppleKey(id: String)
    /// Standard: the live key file's Apple wrap, under this Mac's own Apple
    /// key for the library (never minted by a repair).
    case landAppleWrap(appleKeyID: String)
    /// Always: what this Mac remembers names the record's current key and
    /// this Mac's device ID, and its mirror is the live file of that key.
    case refreshMemory
    /// Always: the live key file is ABSENT and the sealed mirror in what this
    /// Mac remembers is the current key's — it is written back (rule 1: the
    /// mirror is the redundant copy, restored only when the live file is
    /// absent — never a repair of a stray). Never an Apple wrap: those are
    /// never re-added by a repair. (The restores from a copy and over a
    /// stray, and the older library file's re-key, left with VX-378 U1 —
    /// rule 21.)
    case restoreKeyFileFromMirror
    /// Always, synced: what this Mac remembers names no vault facts (its
    /// memory item went — a wiped keychain) while this device holds the
    /// account's sync keys silently or for the session — the held keys'
    /// corpus key id is recorded (non-secret), so the account replacing its
    /// keys later reads as a follow owed. A Touch ID item is never read for it
    /// (no repair prompts). VX-305 U4.
    case recordHeldSyncKeysFacts
    /// Castle: an Apple key this Mac's section lists as its own for the
    /// library and not retired — retired (recorded), then deleted on sight.
    /// VX-305 U4.
    case retireOwnAppleKeys(ids: [String])
    /// §3.10: this device's choice says Touch ID and no item exists — Always
    /// ask is recorded quietly (a settings write; never an item).
    case recordAlwaysAskQuietly
    /// DEBUG mutation pins only — the bug `noRepairMakesTouchID` closes.
    case makeTouchIDItem(fingerprint: String)
    /// DEBUG mutation pins only — the bug `standardRecordNoDestructiveRepair`
    /// closes (a delete on a Standard record's word alone).
    case deleteTouchIDItem(fingerprint: String)
}

/// A fault the assessment reports without a repair (Diagnostics), because
/// acting on it would break one of §3.3's guards — or it is an act's.
public enum Fault: Hashable, Sendable {
    /// A Castle key with an Apple wrap — a planted file; answered by a re-key.
    case appleWrapOnCastleKey(keyFileID: String)
    /// A silent item in Castle that is the only road to its key — left in
    /// place (it may be the only road in).
    case silentItemIsOnlyRoad(fingerprint: String)
    /// A Touch ID item while the library is in Standard (no Standard key
    /// ever has one) — not deleted on a Standard record's word alone
    /// (PROVISIONAL P-U2-1: it is reported, and goes at the next act a
    /// person presses).
    case touchIDItemInStandard(fingerprint: String)
    /// A silent sync-keys item for the library's account while its keys reach
    /// a Castle-era key (PROVISIONAL P-U2-2: reported; the acts re-file them).
    case silentSyncKeysWhileCastleWay(account: String)
    /// Standard: the live key file's own Apple key can't be read here — the
    /// Apple road is lost (no repair mints; rule 8's quiet re-make is U2's —
    /// Re-link left with VX-378 U1).
    case appleRoadLost(keyFileID: String)
    /// The live place holds ANOTHER key's file (nothing in flight): the
    /// record, what this Mac remembers and the key file don't agree (§3.3's
    /// "Always"). The current key's own file comes back by
    /// `restoreKeyFileFromCopy` (or the mirror) when one exists; with none it
    /// stays — PROVISIONAL P-R1-1 (VX-305 ladder round 1).
    case liveKeyFileIsAnotherKeys(keyFileID: String)
}

public enum FollowKind: Equatable, Sendable {
    case intoCastle
    case intoStandard
    case keysReplaced
}

/// An act owed — a press, a notice, or an act the executor runs on a plan.
public enum OwedAct: Equatable, Sendable {
    /// The account's mode or keys changed elsewhere: the follow. Every follow
    /// into or out of Castle types one secret; it holds its library re-key
    /// while a rotation is in progress.
    case follow(FollowKind, typesOneSecret: Bool, holdsLibraryRekey: Bool)
    /// A Castle key with an Apple wrap — re-keyed.
    case rekeyForFault
    /// The re-arm question, after the passphrase opened.
    case touchIDRearmQuestion
}

// MARK: - Doors

public enum Door: String, Hashable, Sendable, CaseIterable {
    case useCastle
    case useStandard
    case replaceAllKeys
    case changePassphrase
    case newWords
    case resetForgottenPassphrase
    case turnOnSync
    case thisMacOnly
    case stopSyncingHere
    case deleteAccountHere
    case moveToSignedInAccount
    case signOut
    case followNow
}

/// What a door asks for.
public enum SecretRequirement: Equatable, Sendable {
    /// Decision 33: both typed — the words typed or made new where
    /// `wordsMayBeNew` (Use Standard: typed, never made new).
    case passphraseAndWords(wordsMayBeNew: Bool)
    /// One secret (a follow; a landing).
    case oneSecret
    /// The current passphrase (verified against the vault's copy where an
    /// account constrains it).
    case currentPassphrase
    /// Castle's forgot road: Touch ID on an enrolled device, or the words.
    case touchIDOrWords
    /// Standard's forgot road: a plain confirm (this Mac holds the key).
    case plainConfirm
    case none
}

/// How joining an account plays out (§3.8).
public enum JoinPlan: Equatable, Sendable {
    /// Joining an account in Castle from Standard is entering Castle.
    case entersCastle
    /// Joining an account in Standard from Castle is leaving Castle — rule 5's
    /// sentence at the consent.
    case leavesCastle
    /// The library's own mode: the master's wrap added, the key stays, the
    /// passphrase copy re-wrapped under the account's (corner 27).
    case sameMode
    /// No vault yet: the first device gives the account its shape.
    case setsUpInLibrarysMode
}

public enum DoorRefusal: Equatable, Sendable {
    case locked
    case wrongMode(ProtectionMode)
    /// Another account is signed in: the one screen (Move or Sign out).
    case otherAccountSignedIn
    /// Signed out: the one plain road (`thisMacOnly`) stands in its place.
    case signedOutUseThisMacOnly
    /// A synced act needs the vault read fresh this session.
    case needsFreshVault
    /// Decision 32: one rotation at a time.
    case rotationInProgress(device: String?, day: Date?)
    /// The account's keys changed elsewhere: pick them up first.
    case followOwed
    case notSynced
    case noAccountSignedIn
    /// Nothing to do: the door has no subject.
    case nothingToDo
}

/// The typed words a door or notice says (phase 4/5 render them).
public enum Words: Equatable, Sendable {
    /// Rule 5, on every road into Standard.
    case ruleFive
    /// The floor: lose all three and it is gone.
    case floorSentence
    case exportAPlainCopyFirst
    /// Use Castle's door: copies under a key this Mac can't delete.
    case copiesUnderAKeyThisMacCantDelete([String])
    /// The scheduled Markdown export turns off, with one notice.
    case scheduledExportTurnsOff
    /// The account screen: the same email with a different account.
    case sameEmailDifferentAccount
}

public struct DoorSpec: Equatable, Sendable {
    public var requires: SecretRequirement
    /// A crossing: the library re-keys (§3.4).
    public var rekeys: Bool
    /// Every own Apple key this Mac's section lists for the library, retired
    /// after the switch commits (entering Castle).
    public var retiresOwnAppleKeys: [String]
    /// The act runs on the account (a rotation) — synced.
    public var synced: Bool
    public var join: JoinPlan?
    public var words: [Words]

    public init(
        requires: SecretRequirement, rekeys: Bool = false, retiresOwnAppleKeys: [String] = [],
        synced: Bool = false, join: JoinPlan? = nil, words: [Words] = []
    ) {
        self.requires = requires
        self.rekeys = rekeys
        self.retiresOwnAppleKeys = retiresOwnAppleKeys
        self.synced = synced
        self.join = join
        self.words = words
    }
}

public enum DoorState: Equatable, Sendable {
    case open(DoorSpec)
    case refused(DoorRefusal)

    public var isOpen: Bool {
        if case .open = self { return true }
        return false
    }

    public var spec: DoorSpec? {
        if case .open(let spec) = self { return spec }
        return nil
    }

    public var refusal: DoorRefusal? {
        if case .refused(let refusal) = self { return refusal }
        return nil
    }
}

// MARK: - The assessment

public struct Assessment: Equatable, Sendable {
    public var launch: LaunchVerdict
    public var mode: ModeVerdict
    public var account: AccountVerdict
    public var vault: VaultVerdict?
    public var lobby: LobbyRoads
    public var touchID: TouchIDAssessment
    public var repairs: [Repair]
    public var faults: [Fault]
    public var acts: [OwedAct]
    public var doors: [Door: DoorState]
    /// Rule 4's one sentence per catalogued copy.
    public var opensWith: [String: OpensWith]
}
