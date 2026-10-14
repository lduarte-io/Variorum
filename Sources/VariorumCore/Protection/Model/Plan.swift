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

    public init(
        format: Int = ProtectionPlan.currentFormat, libraryID: String, deviceID: String,
        sequence: Int, act: ProtectionAct, fromFingerprint: String? = nil,
        toFingerprint: String? = nil, steps: [PlanStep], createdAt: Date
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
    }

    /// The first step not yet done — where a resume starts; nil when all are.
    public var firstUnfinishedStep: Int? { steps.firstIndex { !$0.done } }

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
