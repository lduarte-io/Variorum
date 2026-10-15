import Foundation

// VX-305 U1 — PLANS (design §3.2, §3.6; VX-235's class, VX-313): one per
// library at a time, `variorum-plan.json` beside the library, excluded from
// backups, SEALED (purpose `plan`) under the key in hand and NAMED BY THE ACT
// IN FLIGHT — the device section carries the act with its sequence number,
// and a plan resumes only if its seal covers that number. A plan the section
// doesn't name is ignored (and reported); a missing or unmatched plan never
// blocks — the act rolls back before its commit point and finishes from the
// record after (that is the executor's, U3). A plan never holds a secret.
//
// The step vocabulary is the executor's (U3): a step is a name and whether it
// is done, so a resume starts from the first unfinished one.

public struct PlanStep: Codable, Equatable, Sendable {
    public var name: String
    public var done: Bool

    public init(name: String, done: Bool = false) {
        self.name = name
        self.done = done
    }
}

/// **The act's non-secret parameters a resume needs** (VX-305 U3, a recorded
/// refinement of U1's plan: a plan "carries every fact a resume needs" — §3.9's
/// follow — and never a secret, so what the press chose that is NOT a secret
/// rides here, sealed with the plan). Every field is optional; each act reads
/// its own.
public struct ActParameters: Codable, Equatable, Sendable {
    /// A new Castle key's gate, chosen at THIS press: Touch ID (an item made
    /// at this press) or Always ask (none) — §3.10.
    public var gate: GateStyle?
    /// The act runs on the account (a vault write, a rotation).
    public var synced: Bool?
    /// The account the act writes the vault of.
    public var accountID: String?
    /// VX-109: the vault revision the door read — a rotation's first write
    /// takes it, never a re-fetch.
    public var doorRevision: Int?
    /// The descriptor the typed passphrase is derived under: the door's
    /// (reused by a re-key and the anchor), or a NEW passphrase's fresh one.
    public var passphraseKDF: PassphraseKDF.Descriptor?
    public var passphraseIsNew: Bool?
    public var wordsAreNew: Bool?
    /// Which secret a follow typed — "passphrase" or "words".
    public var typedSecret: String?
    /// A follow's kind — `FollowKind`'s name.
    public var follow: String?
    /// The new library key's kind.
    public var newKind: ProtectionMode?
    /// The library's account after the act (leaves: none; joins: the new one).
    public var targetAccount: String?
    /// Whether `targetAccount` is to be set (a leave clears it).
    public var changesAccount: Bool?
    /// A mode the act confirms or moves to.
    public var targetMode: ProtectionMode?
    /// The account Apple key a leave minted (its id is the vault's mark).
    public var accountAppleKeyID: String?
    /// This Mac's own Apple key the act minted for the library.
    public var ownAppleKeyID: String?
    /// Copies and folders.
    public var copyID: String?
    public var copyIDs: [String]?
    public var destination: String?
    /// Key files an act works through (Re-link's library arm).
    public var keyFileIDs: [String]?
    /// Device settings an act writes.
    public var settings: DeviceSettings?
    /// The account's corpus key id when the act began, and the new one a
    /// rotation's first write carries — stamped in the plan BEFORE the write,
    /// so a resume tells its own landed write from another device's rotation.
    public var oldCorpusKeyID: String?
    public var newCorpusKeyID: String?
    /// This Mac's own Apple key the outgoing key file named at the door.
    public var outgoingAppleKeyID: String?
    /// The account's Apple key a rotation into Castle retires once it completes.
    public var retiringAccountAppleKeyID: String?
    /// Replace All Keys on an account still on the old shared key re-links
    /// it first (§3.5 point 7).
    public var relinksFirst: Bool?
    /// A follower's anchor carries the master's road (false when the vault's
    /// master is still the Castle-era one — §3.4).
    public var includeMasterRoad: Bool?
    /// Finishing a leave a lost device started (§3.9): the press stopped
    /// waiting for the named key — a fresh account key is minted (the vault's
    /// CAS keeps one).
    public var mintsFreshAccountKey: Bool?
    /// The library's key kind before the act (the account family's crossing).
    public var fromKind: ProtectionMode?
    /// Whether the act re-keys the library (every leave does — §3.8).
    public var rekeys: Bool?
    /// The account this Mac stops using (its sync keys forgotten).
    public var forgetsAccount: String?
    /// Resume Sync after a landing: the secret made new there — "passphrase"
    /// or "words" — becomes the account's (§3.7).
    public var adoptsMadeNewSecret: String?
    /// A vault write of a re-key act that carries no corpus key stamp (Re-link
    /// first, inside Replace All Keys) — stamped in the plan BEFORE the write,
    /// like `newCorpusKeyID`, so a resume that can't reach the vault knows the
    /// write may have landed and never rolls back over it.
    public var accountWriteBegun: Bool?

    public init(
        gate: GateStyle? = nil, synced: Bool? = nil, accountID: String? = nil, doorRevision: Int? = nil,
        passphraseKDF: PassphraseKDF.Descriptor? = nil, passphraseIsNew: Bool? = nil, wordsAreNew: Bool? = nil,
        typedSecret: String? = nil, follow: String? = nil, newKind: ProtectionMode? = nil,
        targetAccount: String? = nil, changesAccount: Bool? = nil, targetMode: ProtectionMode? = nil,
        accountAppleKeyID: String? = nil, ownAppleKeyID: String? = nil, copyID: String? = nil,
        copyIDs: [String]? = nil, destination: String? = nil, keyFileIDs: [String]? = nil,
        settings: DeviceSettings? = nil, oldCorpusKeyID: String? = nil, newCorpusKeyID: String? = nil,
        outgoingAppleKeyID: String? = nil, retiringAccountAppleKeyID: String? = nil
    ) {
        self.gate = gate
        self.synced = synced
        self.accountID = accountID
        self.doorRevision = doorRevision
        self.passphraseKDF = passphraseKDF
        self.passphraseIsNew = passphraseIsNew
        self.wordsAreNew = wordsAreNew
        self.typedSecret = typedSecret
        self.follow = follow
        self.newKind = newKind
        self.targetAccount = targetAccount
        self.changesAccount = changesAccount
        self.targetMode = targetMode
        self.accountAppleKeyID = accountAppleKeyID
        self.ownAppleKeyID = ownAppleKeyID
        self.copyID = copyID
        self.copyIDs = copyIDs
        self.destination = destination
        self.keyFileIDs = keyFileIDs
        self.settings = settings
        self.oldCorpusKeyID = oldCorpusKeyID
        self.newCorpusKeyID = newCorpusKeyID
        self.outgoingAppleKeyID = outgoingAppleKeyID
        self.retiringAccountAppleKeyID = retiringAccountAppleKeyID
    }
}

public struct ProtectionPlan: Codable, Equatable, Sendable {
    public static let currentFormat = 1

    public var format: Int
    public var libraryID: String
    /// The device whose section names this plan's act.
    public var deviceID: String
    /// The act sequence number the plan is for — what its seal covers.
    public var sequence: Int
    public var act: ProtectionAct
    public var fromFingerprint: String?
    public var toFingerprint: String?
    public var steps: [PlanStep]
    public var createdAt: Date
    /// What the press chose that a resume needs — never a secret (U3).
    public var parameters: ActParameters?

    public init(
        format: Int = ProtectionPlan.currentFormat, libraryID: String, deviceID: String,
        sequence: Int, act: ProtectionAct, fromFingerprint: String? = nil,
        toFingerprint: String? = nil, steps: [PlanStep], createdAt: Date, parameters: ActParameters? = nil
    ) {
        self.format = format
        self.libraryID = libraryID
        self.deviceID = deviceID
        self.sequence = sequence
        self.act = act
        self.fromFingerprint = fromFingerprint
        self.toFingerprint = toFingerprint
        self.steps = steps
        self.createdAt = createdAt
        self.parameters = parameters
    }

    /// The first step not yet done — where a resume starts; nil when all are.
    public var firstUnfinishedStep: Int? { steps.firstIndex { !$0.done } }

    /// **Past the act's commit point** (§3.6, VX-235's class): the library
    /// already under the act's new key; an act that re-keys nothing (the
    /// plan-less rule's "committed" — its remaining steps finish); or the
    /// account's first vault write begun — its stamp written into the plan
    /// before the write (her ruling 2026-10-14/15: a synced act crashed past
    /// the rotation's first write WAITS for the vault, named; one crashed
    /// before it still rolls back). One function, so the executor's choice and
    /// the scenario world's promise 6 read the same line.
    public func pastCommitPoint(libraryFingerprint: String) -> Bool {
        guard let to = toFingerprint else { return true }
        if libraryFingerprint == to { return true }
        return parameters?.newCorpusKeyID != nil || parameters?.accountWriteBegun == true
    }

    /// Does `section` (this Mac's, at open) name this plan? The device, the
    /// sequence number, the act and its keys must all agree.
    public func isNamed(by section: DeviceSection?) -> Bool {
        guard let section, let inFlight = section.actInFlight else { return false }
        return section.deviceID == deviceID
            && inFlight.sequence == sequence
            && inFlight.act == act
            && inFlight.fromFingerprint == fromFingerprint
            && inFlight.toFingerprint == toFingerprint
    }

    public func sealed(under key: StoreKey) throws -> Sealed<ProtectionPlan> {
        try Sealed.sealing(self, purpose: .plan, libraryID: libraryID, key: key)
    }

    /// Why a plan on disk is not the one to resume.
    public enum Refusal: Error, Equatable, Sendable {
        /// Its seal fails (planted, edited, another library's, or under a key
        /// no road reaches).
        case unsealed
        /// It verifies but this Mac's section doesn't name it (a replayed plan
        /// from an earlier act, another device's, or no act in flight).
        case notNamed
    }

    /// The plan to resume, or why not: verified with a key `reach` finds (the
    /// key in hand, or through the history when its own act has re-keyed),
    /// then named by `section`.
    public static func resumable(
        _ sealed: Sealed<ProtectionPlan>, libraryID: String, section: DeviceSection?,
        reach: (String) -> StoreKey?
    ) -> Result<ProtectionPlan, Refusal> {
        guard let plan = try? sealed.open(purpose: .plan, libraryID: libraryID, reach: reach),
              plan.libraryID == libraryID
        else { return .failure(.unsealed) }
        guard plan.isNamed(by: section) else { return .failure(.notNamed) }
        return .success(plan)
    }
}
