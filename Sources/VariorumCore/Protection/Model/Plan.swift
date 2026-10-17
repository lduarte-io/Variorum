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
    /// The act runs on the account (a vault write).
    public var synced: Bool?
    /// The account the act writes the vault of.
    public var accountID: String?
    /// VX-109: the vault revision the door read — the act's vault write takes
    /// it, never a re-fetch.
    public var doorRevision: Int?
    /// The descriptor the typed passphrase is derived under: the door's
    /// (reused by a re-key), or a NEW passphrase's fresh one.
    public var passphraseKDF: PassphraseKDF.Descriptor?
    public var passphraseIsNew: Bool?
    public var wordsAreNew: Bool?
    /// Which secret a follow or a join typed — "passphrase" or "words".
    public var typedSecret: String?
    /// Rule 7: a join replaced the library's twelve words with the account's
    /// (its notice is said at the act's end, a resume included).
    public var wordsReplaced: Bool?
    /// A follow's kind — `FollowKind`'s name.
    public var follow: String?
    /// The new library key's kind.
    public var newKind: ProtectionMode?
    /// The library's account after the act (leaves: none; joins: the new one).
    public var targetAccount: String?
    /// Whether `targetAccount` is to be set (a leave clears it).
    public var changesAccount: Bool?
    /// This Mac's own Apple key the act minted for the library.
    public var ownAppleKeyID: String?
    /// Copies and folders.
    public var copyID: String?
    public var copyIDs: [String]?
    public var destination: String?
    /// Device settings an act writes.
    public var settings: DeviceSettings?
    /// The account's sync key id the door read, and the new one Use Castle's
    /// one write carries — stamped in the plan BEFORE the write, so a resume
    /// tells its own landed write from another device's (rule 15).
    public var doorRowKeyID: String?
    public var newRowKeyID: String?
    /// This Mac's own Apple key the outgoing key file named at the door.
    public var outgoingAppleKeyID: String?
    /// The library's key kind before the act (the account family's crossing).
    public var fromKind: ProtectionMode?
    /// Whether the act re-keys the library (every leave does — §3.8).
    public var rekeys: Bool?
    /// The account this Mac stops using (its sync keys forgotten).
    public var forgetsAccount: String?
    /// A re-key's OUTGOING key file, as the act found it live — the same copy
    /// what this Mac remembers mirrors (sealed with the plan; a key file holds
    /// no secret). A Mac replaced mid-act whose memory item didn't come along
    /// (Migration Assistant never carries it) has only this to give the
    /// current key its own file back (VX-305 U4, the soak's seed 2).
    public var outgoingKeyFile: KeyFile?
    /// The sync key a follow (or a join) PICKED UP — stamped when it took the
    /// keys, so the record names the key it followed, never a vault that moved
    /// on before its resume finished (VX-305 U4, the soak's seed 11).
    public var followedRowKeyID: String?

    public init(
        gate: GateStyle? = nil, synced: Bool? = nil, accountID: String? = nil, doorRevision: Int? = nil,
        passphraseKDF: PassphraseKDF.Descriptor? = nil, passphraseIsNew: Bool? = nil, wordsAreNew: Bool? = nil,
        typedSecret: String? = nil, follow: String? = nil, newKind: ProtectionMode? = nil,
        targetAccount: String? = nil, changesAccount: Bool? = nil,
        ownAppleKeyID: String? = nil, copyID: String? = nil,
        copyIDs: [String]? = nil, destination: String? = nil,
        settings: DeviceSettings? = nil, doorRowKeyID: String? = nil, newRowKeyID: String? = nil,
        outgoingAppleKeyID: String? = nil
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
        self.ownAppleKeyID = ownAppleKeyID
        self.copyID = copyID
        self.copyIDs = copyIDs
        self.destination = destination
        self.settings = settings
        self.doorRowKeyID = doorRowKeyID
        self.newRowKeyID = newRowKeyID
        self.outgoingAppleKeyID = outgoingAppleKeyID
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
    /// already under the act's new key, or an act that re-keys nothing (the
    /// plan-less rule's "committed" — its remaining steps finish). Before it, a
    /// resume that can't reach its account's vault rolls back — even past its
    /// one vault write, which a follow then picks up as any device's would
    /// (VX-378 U2: no act waits on a vault — the named wait left with the
    /// multi-write rotation; rule 20's "the old state or the new one"). One
    /// function, so the executor's choice and the scenario world's promise 6
    /// read the same line.
    public func pastCommitPoint(libraryFingerprint: String) -> Bool {
        guard let to = toFingerprint else { return true }
        return libraryFingerprint == to
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
