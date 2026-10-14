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
}
