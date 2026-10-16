import Foundation

// VX-305 — THE GUARDS THE MUTATION PINS SWITCH OFF (the phase plan §2: "Guards
// the mutation pins switch off live in one `ProtectionGuards` value whose
// off-switches exist only under `#if DEBUG`"). A Release build carries no
// stored switch at all — every `…On` answer is a constant `true` there — so
// the mutation pins run in the Debug configuration and nothing a Release build
// does can ever turn a guard off.
//
// U2 holds the guards in `assess`, the route finder and retention; U3 adds the
// executor's (one value, one place to look). (U1's model guards — the two
// homes, the hardware marker, the family tree's two homes, the anchor's two —
// and U4's `libraryFileLosesToMemory` left with VX-378 U1, rules 4, 21, 23;
// U2's `rekeyAtEveryCrossing` left with rule 16.)

public struct ProtectionGuards: Equatable, Sendable {
    /// Every guard on — the only value production code ever passes.
    public static let all = ProtectionGuards()

    public init() {}

    #if DEBUG
    // U2 — the guards in `assess`, the route finder and retention.
    /// RETENTION PER LIBRARY PER MAC (§3.7, VX-302): only this Mac's copies
    /// of this library are ever pruned. Off: today's whole-folder prune.
    public var pruneOwnCopiesOnly = true
    /// NO REPAIR MAKES A TOUCH ID ITEM (§3.3, §3.10): one is made only at a
    /// press. Off: a Touch ID choice with no item behind it owes a repair
    /// that makes one.
    public var noRepairMakesTouchID = true
    /// NO RE-ARM QUESTION WITHOUT AN EXISTING ITEM (§3.10): the question
    /// follows only a press that failed on an item that exists. Off: a Touch
    /// ID choice with no item asks it.
    public var noRearmWithoutItem = true
    /// DELETE ON SIGHT BY RECORDED ID ONLY (§3.5): in Castle, only an Apple
    /// key this Mac's section lists as retired is deleted. Off: every Apple
    /// key this Mac can see and doesn't use is deleted (another Mac's own
    /// key among them).
    public var deleteOnSightByIDOnly = true
    /// EVERY OWN APPLE KEY RETIRED AT ENTERING CASTLE (§3.5): every id this
    /// Mac's section lists as its own for the library. Off: only the one the
    /// live key file's Apple wrap names.
    public var everyOwnKeyRetiredAtCastle = true
    /// NOTHING DESTRUCTIVE ON A STANDARD RECORD's WORD ALONE (§3.3, §3.6).
    /// Off: Standard's record drives deletes.
    public var standardRecordNoDestructiveRepair = true
    /// DECISION 35: a synced library writes nothing Apple-reachable without a
    /// fresh vault read for its account. Off: it writes on the record's word.
    public var freshVaultBeforeAppleWrite = true

    // U3 — the guards in the executor (it also reads U2's
    // `everyOwnKeyRetiredAtCastle`, `freshVaultBeforeAppleWrite`,
    // `standardRecordNoDestructiveRepair` and
    // `deleteOnSightByIDOnly` where it acts on the same rule).
    /// A PLAN RESUMES ONLY WHEN THIS MAC'S SECTION NAMES IT (§3.6, VX-313):
    /// a plan the section doesn't name — planted, or replayed from an earlier
    /// act — is ignored. Off: any plan that verifies resumes.
    public var planNamedBySection = true
    /// EVERY REPAIR'S PRECONDITION VERIFIED BEFORE A DELETE (§3.3: "every
    /// delete comes after its replacement has verified"). Off: a delete runs on
    /// the assessment's word.
    public var repairPreconditionsVerified = true
    /// THE EXECUTOR NEVER MAKES A TOUCH ID ITEM FOR A REPAIR (§3.3, §3.10):
    /// one is made only at a person's press. Off: `.makeTouchIDItem` runs.
    public var repairNeverMakesTouchIDItem = true
    /// PREPARE-THEN-COMMIT (§3.4, VX-235): the new key's custody item and key
    /// file exist before the library is re-encrypted. Off: the swap runs
    /// first and the key file after it.
    public var prepareBeforeCommit = true
    /// THE EXPORT-OFF STEP (§3.9, §3.12): entering Castle — by Use Castle or a
    /// follow — turns this device's scheduled Markdown export off. Off: it
    /// stays on.
    public var exportOffAtCastle = true
    // (U4's `libraryFileLosesToMemory` left with VX-378 U1 — rule 21.)
    #endif

    public var pruneOwnCopiesOnlyOn: Bool {
        #if DEBUG
        return pruneOwnCopiesOnly
        #else
        return true
        #endif
    }

    public var noRepairMakesTouchIDOn: Bool {
        #if DEBUG
        return noRepairMakesTouchID
        #else
        return true
        #endif
    }

    public var noRearmWithoutItemOn: Bool {
        #if DEBUG
        return noRearmWithoutItem
        #else
        return true
        #endif
    }

    public var deleteOnSightByIDOnlyOn: Bool {
        #if DEBUG
        return deleteOnSightByIDOnly
        #else
        return true
        #endif
    }

    public var everyOwnKeyRetiredAtCastleOn: Bool {
        #if DEBUG
        return everyOwnKeyRetiredAtCastle
        #else
        return true
        #endif
    }

    public var standardRecordNoDestructiveRepairOn: Bool {
        #if DEBUG
        return standardRecordNoDestructiveRepair
        #else
        return true
        #endif
    }

    public var freshVaultBeforeAppleWriteOn: Bool {
        #if DEBUG
        return freshVaultBeforeAppleWrite
        #else
        return true
        #endif
    }

    public var planNamedBySectionOn: Bool {
        #if DEBUG
        return planNamedBySection
        #else
        return true
        #endif
    }

    public var repairPreconditionsVerifiedOn: Bool {
        #if DEBUG
        return repairPreconditionsVerified
        #else
        return true
        #endif
    }

    public var repairNeverMakesTouchIDItemOn: Bool {
        #if DEBUG
        return repairNeverMakesTouchIDItem
        #else
        return true
        #endif
    }

    public var prepareBeforeCommitOn: Bool {
        #if DEBUG
        return prepareBeforeCommit
        #else
        return true
        #endif
    }

    public var exportOffAtCastleOn: Bool {
        #if DEBUG
        return exportOffAtCastle
        #else
        return true
        #endif
    }

}
