import Foundation

// VX-305 — THE GUARDS THE MUTATION PINS SWITCH OFF (the phase plan §2: "Guards
// the mutation pins switch off live in one `ProtectionGuards` value whose
// off-switches exist only under `#if DEBUG`"). A Release build carries no
// stored switch at all — every `…On` answer is a constant `true` there — so
// the mutation pins run in the Debug configuration and nothing a Release build
// does can ever turn a guard off.
//
// U1 holds the guards that live in the model's own functions, U2 the ones in
// `assess`, the route finder and retention; U3 and U4 add theirs to this same
// value (one value, one place to look).

public struct ProtectionGuards: Equatable, Sendable {
    /// Every guard on — the only value production code ever passes.
    public static let all = ProtectionGuards()

    public init() {}

    #if DEBUG
    /// THIS MAC'S FACTS IN TWO HOMES (§3.6): the newer version wins and the
    /// retired Apple key ids are the union. Off: the memory item wins blindly
    /// (the replay class VX-313 names).
    public var twoHomes = true
    /// THE DEVICE SECTION'S HARDWARE MARKER (§3.6, §3.13, VX-340): a memory
    /// item keeps its identity only on the hardware and login it was made on,
    /// and a Mac with no memory item adopts only a section whose marker is
    /// its own. Off: identity is trusted without the marker.
    public var hardwareMarker = true
    /// THE FAMILY TREE's TWO HOMES (§3.4, §3.6): the record's tree and the
    /// memory's mirror are unioned at open. Off: the record's tree alone (a
    /// rolled-back library file makes its own later copies look foreign).
    public var familyTreeTwoHomes = true

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
    /// THE RE-KEY AT EVERY CROSSING (§3.4, §3.8): into or out of Castle, out
    /// of an account in either mode, a different library landing. Off:
    /// leaving an account and a landing keep the key (today's behaviour).
    public var rekeyAtEveryCrossing = true

    // U3 — the guards in the executor (it also reads U2's
    // `everyOwnKeyRetiredAtCastle`, `freshVaultBeforeAppleWrite`,
    // `rekeyAtEveryCrossing`, `standardRecordNoDestructiveRepair` and
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

    public var twoHomesOn: Bool {
        #if DEBUG
        return twoHomes
        #else
        return true
        #endif
    }

    public var hardwareMarkerOn: Bool {
        #if DEBUG
        return hardwareMarker
        #else
        return true
        #endif
    }

    public var familyTreeTwoHomesOn: Bool {
        #if DEBUG
        return familyTreeTwoHomes
        #else
        return true
        #endif
    }

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

    public var rekeyAtEveryCrossingOn: Bool {
        #if DEBUG
        return rekeyAtEveryCrossing
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
