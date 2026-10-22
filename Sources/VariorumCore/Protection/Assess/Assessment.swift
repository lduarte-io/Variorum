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

/// The vault, read (rules 14, 15): the account's posture, and how this device
/// holds its sync keys by it. (The rotation in progress, its hold and its
/// Apple-copy reading left with VX-378 U2 — no rotation is ever in progress:
/// the sync key changes in ONE write.)
public struct VaultVerdict: Equatable, Sendable {
    public var mode: ProtectionMode
    /// How this device holds the account's sync keys now.
    public var syncKeysCustody: SyncKeysCustody
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
    /// RULE 27: no road at all — the honest refusal, naming what would have
    /// worked (nil whenever anything might still open the library).
    public var noKeyFileAnywhere: NoKeyFileAnywhere?
    /// RULE 8: no quiet road to try (no silent item, no readable Apple wrap) —
    /// the lobby asks for the passphrase or the words at once. With one, it
    /// tries the quiet roads first and asks only when every one has failed.
    public var asksASecretAtOnce: Bool { silentItems.isEmpty && appleKeyID == nil }
}

/// The three homes rule 1 keeps a key file in.
public enum KeyFileHome: String, Hashable, Sendable, CaseIterable {
    case besideTheLibrary
    case insideABackup
    case thisMacsKeychain
}

/// RULE 27 ("A library whose every key-file copy and every backup are gone is
/// gone. Synced libraries are the exception: the account's passphrase or twelve
/// words recover them from the account"): the honest refusal — the copies that would have opened it, and
/// the account road when the library was (or may have been) synced. No
/// copy-less rebuild exists (§3's rule-1 row).
public struct NoKeyFileAnywhere: Hashable, Sendable {
    /// Every home of rule 1 — each empty now.
    public var wouldHaveWorked: [KeyFileHome]
    /// Rule 27's exception (rule 14's road): the account's passphrase or words
    /// bring a synced library's writing back from the account. Said when the
    /// library names an account — or, before unlock, when a session is signed in.
    public var accountRoad: Bool

    public init(wouldHaveWorked: [KeyFileHome] = KeyFileHome.allCases, accountRoad: Bool) {
        self.wouldHaveWorked = wouldHaveWorked
        self.accountRoad = accountRoad
    }
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
    /// key for the library, readable here.
    case landAppleWrap(appleKeyID: String)
    /// RULE 8, Standard: the Apple road failed and no own key of this Mac reads
    /// here — a FRESH Apple key is made and the current key wrapped under it
    /// ("quietly makes a fresh Apple road"; decision 35's fresh vault read
    /// first when synced).
    case remakeAppleRoad
    /// RULE 8, Standard: the on-device road — the silent item for the current
    /// key — is gone (a keychain reset, a new Mac): re-made with the key in
    /// hand.
    case remakeOnDeviceItem
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
    /// Standard: the Apple road failed — the live key file's own Apple key
    /// can't be read here (a changed Apple ID, a keychain reset). Reported (rule
    /// 3's "at the first launch after a quiet road has failed"); rule 8's quiet
    /// re-make (`remakeAppleRoad`) answers it at the same open.
    case appleRoadLost(keyFileID: String)
    /// The live place holds ANOTHER key's file than the record's current key
    /// (nothing in flight): reported; no repair restores over it (rule 21 —
    /// the restores from a copy left with VX-378 U1); the key-file OFFER
    /// (`OwedAct.offerKeyFile`) is the hand it needs.
    case liveKeyFileIsAnotherKeys(keyFileID: String)
    /// RULE 21 (her ruling at the U4 stop, 2026-10-17): the library in the live
    /// place is not the one this Mac last opened — the open went on and says so
    /// once (her words: `LibraryNotice.words`); reported until what this Mac
    /// remembers has followed it (`refreshMemory`). No door closes, nothing is
    /// repaired.
    case libraryNotice(LibraryNotice)
    /// RULE 27: the library opened by a quiet road, but no copy of its key file
    /// is left anywhere — no live file, no sealed mirror to write back (rule 1).
    /// Said honestly; nothing rebuilds a key file from the key (the acts that
    /// need one refuse — export a plain copy).
    case noKeyFileAnywhere(NoKeyFileAnywhere)
}

public enum FollowKind: Equatable, Sendable {
    case intoCastle
    case intoStandard
    case keysReplaced
}

/// An act owed — a press, a notice, or an act the executor runs on a plan.
public enum OwedAct: Equatable, Sendable {
    /// The account's mode or keys changed elsewhere: the follow. Into Castle,
    /// and catching up on a sync key replaced while this device lagged, it
    /// types one secret (rules 10, 12); out of Castle it is quiet — the device
    /// already holds the account's keys (rule 12: "other devices follow out
    /// quietly, with a notice").
    case follow(FollowKind, typesOneSecret: Bool)
    /// A Castle key with an Apple wrap — re-keyed.
    case rekeyForFault
    /// The re-arm question, after the passphrase opened.
    case touchIDRearmQuestion
    /// RULE 3: no passphrase exists yet, at one of the schedule's two
    /// model-side moments — the face asks (its words and the launch-counted
    /// reminders are phase 3's).
    case askPassphrase(PassphraseAsk)
    /// RULE 21 (her ruling at the U4 stop, 2026-10-17): the key file beside the
    /// library is not its own — the app looks for one that is in the places it
    /// keeps them and OFFERS what it found, naming where
    /// (`ProtectionExecutor.searchKeyFiles`); nothing is written before her yes
    /// (`useOfferedKeyFile`). An offer, never a refusal.
    case offerKeyFile
}

/// Rule 3's two moments the model owns ("always right before the first
/// backup and at the first launch after a quiet road has failed").
public enum PassphraseAsk: Equatable, Sendable {
    /// No backup of this library exists yet — asked right before the first.
    case beforeFirstBackup
    /// A quiet road failed at this launch (the Apple road lost, or the
    /// on-device item gone).
    case quietRoadFailed
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
    /// The act runs on the account (a vault read or write) — synced.
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
