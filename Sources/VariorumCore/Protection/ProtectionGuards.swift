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
    /// THE ANCHOR CARRIED BY EVERY RE-KEY (§3.4): a re-key within a mode
    /// carries the Castle anchor unchanged. Off: it is dropped.
    public var anchorCarriedByEveryRekey = true
    /// THE ANCHOR WRITTEN FIRST (§3.4, §3.9): leaving Castle refuses unless
    /// the anchor is already written into the outgoing key file. Off: the leave
    /// builds its new key file with no anchor in the outgoing one.
    public var anchorWrittenFirst = true

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
    /// THE FAMILY TREE's OWN-LINE CHECK (§3.7): "is it ours?" reads the
    /// tree. Off: it reads the live key file's history (after a leave, this
    /// library's own Castle-era copies read as another library's).
    public var ownLineByFamilyTree = true
    /// OPENING A COPY NEVER LOWERS THE MODE (§3.7, VX-209). Off: the copy's
    /// own mode wins.
    public var neverLowerOnOpen = true
    /// THE DOOR-TIME VAULT CHECK (§3.5 point 4): a vault this device can
    /// read, or the record's account while signed out, still on the old
    /// shared key stops Use Castle at its door. Off: the door opens.
    public var doorTimeVaultCheck = true
    /// DELETE ON SIGHT BY RECORDED ID ONLY (§3.5): in Castle, only an Apple
    /// key this Mac's section lists as retired is deleted. Off: every Apple
    /// key this Mac can see and doesn't use is deleted (another Mac's own
    /// key among them).
    public var deleteOnSightByIDOnly = true
    /// EVERY OWN APPLE KEY RETIRED AT ENTERING CASTLE (§3.5): every id this
    /// Mac's section lists as its own for the library. Off: only the one the
    /// live key file's Apple wrap names.
    public var everyOwnKeyRetiredAtCastle = true
    /// THE LEAVE'S ID GATES ITS COMPLETION (§3.9): a vault whose rotation
    /// names an Apple key id with no wrap is completed only by a device that
    /// reads that key. Off: any device completes it.
    public var leaveIDGatesCompletion = true
    /// CASTLE-KIND CUSTODY THROUGH A LEAVE'S ROTATION (§3.2, §3.9): the sync
    /// keys stay the Castle way while the previous corpus key stands. Off:
    /// they go silent as soon as the vault reads a leave.
    public var castleKindCustodyThroughLeave = true
    /// GIFTS ONLY FOR THIS MAC'S COPIES (§3.5 point 2): the move gives a key
    /// file of this Mac's own only to libraries whose copies the catalog
    /// attributes to this Mac. Off: to every library in the catalog.
    public var giftsOnlyForThisMacsCopies = true
    /// AN UNCONFIRMED MODE RUNS NO CUSTODY REPAIR (§3.3, §3.13). Off: the
    /// recorded-but-unconfirmed mode's repairs run.
    public var unconfirmedModeNoCustodyRepair = true
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
    // `everyOwnKeyRetiredAtCastle`, `leaveIDGatesCompletion`,
    // `castleKindCustodyThroughLeave`, `freshVaultBeforeAppleWrite`,
    // `rekeyAtEveryCrossing`, `doorTimeVaultCheck`,
    // `standardRecordNoDestructiveRepair` and `deleteOnSightByIDOnly` where
    // it acts on the same rule).
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
    /// A FOLLOWER'S ANCHOR LOCKED UNDER THE SECRET TYPED AT ITS FOLLOW
    /// (§3.4, her 2026-10-14 confirm). Off: only the outgoing key and its
    /// copied locks.
    public var followerAnchorTypedLock = true
    /// THE OLD-NAME ITEM DELETED ONLY BY ITS RECORDED ID (§3.5 point 5):
    /// a new old-name item an older build minted later is left alone. Off:
    /// whatever id the item carries now.
    public var oldSharedKeyDeletedByRecordedID = true
    /// A COPY'S ACT IN FLIGHT IS CLEARED WHENEVER IT'S OPENED (§3.6, §3.7).
    /// Off: the copy's sections keep their acts.
    public var copyActClearedOnOpen = true
    /// THE MOVE KEEPS THE OLD WRAP (§3.5 point 2): a key of this Mac's own
    /// beside the old shared key's wrap, never instead of it. Off: the old
    /// wrap is dropped.
    public var moveKeepsOldWrap = true
    /// THE RETIREMENT RE-RUNS THE MOVES (§3.5 point 4) before the old key
    /// goes. Off: it goes with no move first.
    public var retirementRerunsMoves = true
    /// THE FRESH PAIR AFTER THE MOVE (§3.5 point 2): the move ends with a
    /// fresh backup pair of the live library. Off: none.
    public var freshPairAfterMove = true

    // U4 — the guards the scenario world's bugs added.
    /// A LIBRARY FILE REPLAYED ALONE LOSES TO THE MEMORY (§3.6, promise 10 —
    /// VX-305 U4, found by the scenario world): a library file older than what
    /// this Mac remembers (the memory names a newer key, the live key file is
    /// that key's and its history holds the file's) is re-encrypted under the
    /// current key and takes the memory's facts. Off: the replayed record wins
    /// — its mode, its account, its key.
    public var libraryFileLosesToMemory = true
    #endif

    public var libraryFileLosesToMemoryOn: Bool {
        #if DEBUG
        return libraryFileLosesToMemory
        #else
        return true
        #endif
    }

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

    public var anchorCarriedByEveryRekeyOn: Bool {
        #if DEBUG
        return anchorCarriedByEveryRekey
        #else
        return true
        #endif
    }

    public var anchorWrittenFirstOn: Bool {
        #if DEBUG
        return anchorWrittenFirst
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

    public var ownLineByFamilyTreeOn: Bool {
        #if DEBUG
        return ownLineByFamilyTree
        #else
        return true
        #endif
    }

    public var neverLowerOnOpenOn: Bool {
        #if DEBUG
        return neverLowerOnOpen
        #else
        return true
        #endif
    }

    public var doorTimeVaultCheckOn: Bool {
        #if DEBUG
        return doorTimeVaultCheck
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

    public var leaveIDGatesCompletionOn: Bool {
        #if DEBUG
        return leaveIDGatesCompletion
        #else
        return true
        #endif
    }

    public var castleKindCustodyThroughLeaveOn: Bool {
        #if DEBUG
        return castleKindCustodyThroughLeave
        #else
        return true
        #endif
    }

    public var giftsOnlyForThisMacsCopiesOn: Bool {
        #if DEBUG
        return giftsOnlyForThisMacsCopies
        #else
        return true
        #endif
    }

    public var unconfirmedModeNoCustodyRepairOn: Bool {
        #if DEBUG
        return unconfirmedModeNoCustodyRepair
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

    public var followerAnchorTypedLockOn: Bool {
        #if DEBUG
        return followerAnchorTypedLock
        #else
        return true
        #endif
    }

    public var oldSharedKeyDeletedByRecordedIDOn: Bool {
        #if DEBUG
        return oldSharedKeyDeletedByRecordedID
        #else
        return true
        #endif
    }

    public var copyActClearedOnOpenOn: Bool {
        #if DEBUG
        return copyActClearedOnOpen
        #else
        return true
        #endif
    }

    public var moveKeepsOldWrapOn: Bool {
        #if DEBUG
        return moveKeepsOldWrap
        #else
        return true
        #endif
    }

    public var retirementRerunsMovesOn: Bool {
        #if DEBUG
        return retirementRerunsMoves
        #else
        return true
        #endif
    }

    public var freshPairAfterMoveOn: Bool {
        #if DEBUG
        return freshPairAfterMove
        #else
        return true
        #endif
    }
}
