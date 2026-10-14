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

/// The mode — the current key's kind — confirmed or not (§3.3, §3.13).
public struct ModeVerdict: Equatable, Sendable {
    public enum Source: Equatable, Sendable {
        /// Before unlock: what this Mac remembers — a display hint that decides
        /// nothing.
        case hintOnly
        /// The record.
        case record
        /// A library with no record: today's rule, read once (§3.15).
        case legacyReader(LegacyModeVerdict)
    }

    /// nil before unlock when nothing is remembered.
    public var mode: ProtectionMode?
    public var confirmed: Bool
    public var source: Source
    /// Corner 45's ambiguous case (§3.13 step 2).
    public var corner45: Bool
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

/// How the sync keys are held — by what they can reach (§3.2, §3.9).
public enum SyncKeysCustody: Equatable, Sendable {
    /// Touch ID, or session memory under Always ask: they reach a Castle-era
    /// key (in Castle; through a leave's rotation until the previous corpus
    /// key leaves the vault).
    case castleWay
    /// A silent item: they reach nothing Castle-era.
    case silent
}

/// A leave whose acting device was lost (§3.9): another device finishes it
/// at a press — "Finish leaving Castle, started on [device] on [day]".
public struct UnfinishedLeave: Equatable, Sendable {
    public var device: String?
    public var day: Date?
    /// The account Apple key the leave named; the press waits for it, and
    /// mints a fresh one only if it never arrives.
    public var namedAppleKeyID: String
    /// This device reads it already.
    public var namedKeyReadableHere: Bool
}

/// The vault, read (§3.9).
public struct VaultVerdict: Equatable, Sendable {
    public var mode: VaultMode
    public var rotationInProgress: Bool
    /// A leave in progress whose completing write (the account's Apple wrap)
    /// this device may make: it reads the named key. A rotation with no id
    /// (Use Castle's, a Castle Replace All Keys) any device completes, and no
    /// finisher ever adds an Apple copy to it.
    public var mayCompleteLeave: Bool
    /// A rotation with no id — completed by anyone, never with an Apple copy.
    public var completesWithoutAppleCopy: Bool
    /// How this device holds the account's sync keys now.
    public var syncKeysCustody: SyncKeysCustody
    /// A follower that sees the master replaced while a rotation is in
    /// progress follows the keys but holds its library's re-key until the
    /// vault reads Standard or Castle.
    public var followHoldsLibraryRekey: Bool
    /// A leave a lost device started — the finish door's facts.
    public var unfinishedLeave: UnfinishedLeave?
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

/// The lobby's roads (§3.3): what this device has for the library. Every
/// road verifies itself; nothing here decides.
public struct LobbyRoads: Equatable, Sendable {
    /// Roads that need no person (a silent item; an Apple wrap whose key is
    /// readable here) — tried at once.
    public var automatic: [Route]
    /// The custody items enumerated, whatever fingerprint they name.
    public var custodyItems: [CustodyItemFact]
    /// What the passphrase or the words open, by the route finder (the key
    /// file beside the slot, the history, the anchor, the catalog's files).
    public var typed: OpensWith
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
    /// Castle: today's per-library-ID items the migration kept, once the
    /// history holds their key.
    case deleteLegacyItem(LegacyItemFact.Kind, fingerprint: String, precondition: RepairPrecondition)
    /// Castle: a format-1/2 key file beside the library, once the history
    /// verifiably holds its key (a key the fold couldn't reach keeps its file).
    case deleteLegacyKeyFile(keyFileID: String, precondition: RepairPrecondition)
    /// Castle: an Apple key this Mac's section lists as retired — delete on
    /// sight, by its id only.
    case deleteRetiredAppleKey(id: String)
    /// Castle: the old-name item, when this device's section recorded its
    /// retirement and it reappeared under the same id.
    case deleteRetiredOldSharedKey(id: String)
    /// Standard: the live key file's Apple wrap, under this Mac's own Apple
    /// key for the library (never minted by a repair).
    case landAppleWrap(appleKeyID: String)
    /// Always: what this Mac remembers agrees with the record (the two homes
    /// reconciled — nothing lost: newer wins, retired ids and the tree union).
    case refreshMemory
    /// Always: the record's home of this Mac's section is behind the newer
    /// home — written forward (the same reconciliation).
    case refreshRecordSection
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
    /// Apple road is lost; Re-link's library arm is offered (no repair mints).
    case appleRoadLost(keyFileID: String)
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
    /// The mode recorded but not confirmed — the vault answered, or corner
    /// 45's notice was. Confirming a mode the current key wasn't born in is a
    /// key change (Use Standard's road), never a move.
    case confirmMode(ProtectionMode, isKeyChange: Bool)
    /// Corner 45's one-time notice (floor sentence, *Export a plain copy
    /// first*, Use Standard offered as the key change).
    case corner45Notice
    /// A Castle key with an Apple wrap — re-keyed.
    case rekeyForFault
    /// Re-link's library arm: a fresh own Apple key for every Standard key
    /// file whose own key can't be read here (the live one and other
    /// libraries').
    case relinkLibraryArm(keyFileIDs: [String])
    /// A library already in Castle before this change: one calm ask — the old
    /// shared key's retirement.
    case retireOldSharedKeyAsk
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
    case relinkAccount
    case relinkLibraryArm
    case retireOldSharedKey
    case turnOnSync
    case thisMacOnly
    case stopSyncingHere
    case deleteAccountHere
    case moveToSignedInAccount
    case signOut
    case followNow
    case finishLeavingCastle
}

/// What a door asks for.
public enum SecretRequirement: Equatable, Sendable {
    /// Decision 33: both typed — the words typed or made new where
    /// `wordsMayBeNew` (Use Standard: typed, never made new).
    case passphraseAndWords(wordsMayBeNew: Bool)
    /// Standard's leave: the passphrase typed or set new (the forgot road),
    /// the words typed or made new.
    case passphraseOrSetNewAndWordsOrMadeNew
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
    /// passphrase copy re-wrapped under the account's (corner 27); an anchor
    /// untouched.
    case sameMode
    /// No vault yet: the first device gives the account its shape.
    case setsUpInLibrarysMode
}

public enum DoorRefusal: Equatable, Sendable {
    case locked
    case wrongMode(ProtectionMode)
    /// The mode isn't confirmed — corner 45's notice, or the vault, answers it.
    case modeNotConfirmed
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
    /// §3.5 point 4: a vault on the old shared key stops Use Castle — named,
    /// with the way through (that account's own Castle or Re-link).
    case vaultOnOldSharedKey(account: String)
    case notSynced
    case noAccountSignedIn
    /// Re-link reads, never mints: no Apple key readable here.
    case appleKeyUnreadable
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
    /// One sentence per door that replaces a secret while an anchor exists.
    case anchor(AnchorSentence)
    /// Use Castle's door: copies under a key this Mac can't delete.
    case copiesUnderAKeyThisMacCantDelete([String])
    /// The old shared key's sheet.
    case retirementSheet(RetirementChecks)
    /// The scheduled Markdown export turns off, with one notice.
    case scheduledExportTurnsOff
    /// Re-link's consent: the new key reaches other devices only through
    /// iCloud Keychain, which Variorum can't see.
    case relinkConsent
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
    /// The old shared key retired as the act's last step.
    public var retiresOldSharedKey: Bool
    /// The act runs on the account (a rotation) — synced.
    public var synced: Bool
    public var join: JoinPlan?
    /// Replace All Keys on an account still on the old shared key re-links
    /// it first (§3.5 point 7).
    public var relinksAccountFirst: Bool
    public var words: [Words]

    public init(
        requires: SecretRequirement, rekeys: Bool = false, retiresOwnAppleKeys: [String] = [],
        retiresOldSharedKey: Bool = false, synced: Bool = false, join: JoinPlan? = nil,
        relinksAccountFirst: Bool = false, words: [Words] = []
    ) {
        self.requires = requires
        self.rekeys = rekeys
        self.retiresOwnAppleKeys = retiresOwnAppleKeys
        self.retiresOldSharedKey = retiresOldSharedKey
        self.synced = synced
        self.join = join
        self.relinksAccountFirst = relinksAccountFirst
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

// MARK: - The old shared key (§3.5 point 2 and 4)

/// The move's subjects (§3.5 point 2): keys of this Mac's own beside the old
/// one, never instead of it.
public struct MovePlan: Equatable, Sendable {
    /// Other libraries this Mac holds copies of whose newest copy is in
    /// Standard — each gets this Mac's own key file in `Backups/<library8>/
    /// <mac8>/` under an Apple key of its own. Never for copies the catalog
    /// can't attribute to this Mac.
    public var otherLibraries: [String]
    /// The live library gains this Mac's own Apple key (confirmed Standard —
    /// decision 35).
    public var liveLibrary: Bool
}

/// The checks at Use Castle's door, before the sheet (§3.5 point 4).
public struct RetirementChecks: Equatable, Sendable {
    public var routes: RetirementRoutes
    /// Every account it can't check ("your account x@… can't be checked
    /// while you're signed out").
    public var uncheckedAccounts: [String]
    /// The vaults that stop the act at its door.
    public var doorStops: [String]
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
    public var movePlan: MovePlan
    /// The old shared key's checks, while this store still has it.
    public var retirement: RetirementChecks?
    /// One *Opens with* line per catalogued copy (the route finder's).
    public var opensWith: [String: OpensWith]
}
