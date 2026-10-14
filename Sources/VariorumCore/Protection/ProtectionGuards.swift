import Foundation

// VX-305 — THE GUARDS THE MUTATION PINS SWITCH OFF (the phase plan §2: "Guards
// the mutation pins switch off live in one `ProtectionGuards` value whose
// off-switches exist only under `#if DEBUG`"). A Release build carries no
// stored switch at all — every `…On` answer is a constant `true` there — so
// the mutation pins run in the Debug configuration and nothing a Release build
// does can ever turn a guard off.
//
// U1 holds the guards that live in the model's own functions; U3 and U4 add
// theirs to this same value (one value, one place to look).

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
}
