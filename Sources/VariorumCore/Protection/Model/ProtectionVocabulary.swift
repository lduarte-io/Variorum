import Foundation

// VX-305 U1 — THE PROTECTION MODEL's vocabulary (the binding design:
// `notes/plans/vx-266-castle-backups-prelaunch.md` §3.2). Plain values only:
// nothing in `Protection/Model/` reads a Keychain, a file or the network, and
// nothing in it decides — `assess` (U2) decides and the executor (U3) writes.

/// **A key's kind for life, and the library's mode.** A key is born Castle or
/// Standard and keeps that kind for life (design §3.4); the library's mode is
/// its CURRENT key's kind (§3.2). One enum serves both readings because they
/// are one fact seen from two sides.
public enum ProtectionMode: String, Codable, Sendable, CaseIterable {
    case castle
    case standard
}

/// **The acts the executor runs as sealed plans** (design §3.9; the phase
/// plan's §2 list, one case per act file). A device section names the act in
/// flight with one of these; a plan carries the same. The raw values are a
/// stored FORMAT: renaming a case orphans every plan and record written under
/// the old name.
public enum ProtectionAct: String, Codable, Sendable, CaseIterable {
    case enterCastle = "enter_castle"
    case leaveCastle = "leave_castle"
    case replaceAllKeys = "replace_all_keys"
    case follow
    /// Make this my library (rule 17): a copy takes the live place as a NEW
    /// library. (Look inside writes nothing, so it is no act.)
    case makeMine = "make_mine"
    case sendLibrary = "send_library"
    case createLibrary = "create_library"
    case setUpSync = "set_up_sync"
    case enroll
    case move
    case thisMacOnly = "this_mac_only"
    case stopSyncingHere = "stop_syncing_here"
    case deleteAccountHere = "delete_account_here"
    case changePassphrase = "change_passphrase"
    case resetPassphrase = "reset_passphrase"
    case regenerateWords = "regenerate_words"
    case deviceSettings = "device_settings"
    case touchIDRearm = "touch_id_rearm"
    case offerDelete = "offer_delete"
    case plaintextExport = "plaintext_export"
}

/// **The gate style — Touch ID or Always ask** (design §3.10): stored per
/// device, in this Mac's facts, never in UserDefaults (§3.15 retires the
/// Castle settings there).
public enum GateStyle: String, Codable, Sendable, CaseIterable {
    case touchID = "touch_id"
    case alwaysAsk = "always_ask"
}
