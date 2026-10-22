//
//  KeychainCustody.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 13p-fix — the rules every keychain family obeys, each stated
//  ONCE (VX-329 U1: today's custody choreographies — the gated save and the
//  three-step handover — left with today's custody; the protection road's
//  keychain family, `ProtectionKeychain`, reads the two kept here). Both were learned the same day, from the same
//  incident, and both exist because a comment three files away is not a
//  mechanism. The pre-13u round added the THIRD rule below
//  (`KeychainTestTripwire`) after the second lesson of that same day:
//  the rule that WAS only a comment failed exactly as this header
//  predicts.
//

import Foundation
import Security
import VariorumCore

/// A TEST PROCESS NEVER MUTATES A REAL-SCOPE E2EE CUSTODY ITEM — the rule,
/// made structural (pre-13u Act 9, F4; pre-13x 1a: per store, so the
/// guard names the REAL scopes rather than fixed accounts).
///
/// `E2EEKeychainStorage`'s accounts WERE fixed (`device-keys` /
/// `device-keys-biometric`): there was no scope parameter, so ANY
/// write/delete that reached its leaves from a test process landed on the
/// author's live custody. The 13p-fix plan's environment-traps section
/// states exactly that — and on 2026-08-30 the sentence failed anyway
/// (R3-1): a revert drill removed an injected seam's USE, the fake-driven
/// pins fell through to the real leaves, and the author's live E2EE
/// custody was overwritten with test material. A plan-file sentence is
/// not a mechanism; this is the mechanism.
///
/// DEBUG-only by construction (release builds carry no XCTest and the
/// probe compiles to `false`), armed by detecting the test harness in the
/// process. The HOSTED app (booted as the suite's host) is armed too, and
/// deliberately: its launch path never writes E2EE custody (enrollment
/// and the gate toggle are user acts), so anything that trips here IS a
/// test reaching real custody — the R3-1 shape, refused before any
/// SecItem call. Scoped families (`StoreKeyGuard`'s `scope:`,
/// `StoreKeyCustody`) stay unguarded: throwaway scopes are their safety,
/// and the fact suite's probes ride their own throwaway service.
///
/// READS stay open (they are how pins observe the world and they damage
/// nothing); `unlockGatedItem` — a read that PROMPTS — is deliberately
/// not guarded either: a test reaching it hangs visibly, which is loud,
/// and guarding reads would let a pin silently pass over real state.
nonisolated enum KeychainTestTripwire {
    #if DEBUG
    /// Computed once: the XCTest session environment or the loaded XCTest
    /// runtime marks a test process (Swift Testing runs inside the same
    /// harness).
    static let armed: Bool = {
        let env = ProcessInfo.processInfo.environment
        return env["XCTestConfigurationFilePath"] != nil
            || env["XCTestSessionIdentifier"] != nil
            || env["XCTestBundlePath"] != nil
            || NSClassFromString("XCTestCase") != nil
    }()
    #else
    static let armed = false
    #endif

    private static let tripLock = NSLock()
    nonisolated(unsafe) private static var trips = 0
    nonisolated(unsafe) private static var refusedNames: [String] = []

    /// Observable for the pin: how many mutations have been refused.
    static var tripCount: Int {
        tripLock.lock()
        defer { tripLock.unlock() }
        return trips
    }

    /// 17h (R3-4's leaf-mapping pin): WHICH leaves refused, in order. A
    /// test calls one `E2EECustodyLeaves.live` closure and asserts the
    /// delta names the leaf it expects — so a leaves struct that lies
    /// about its mapping (`deletePlain` wired to `deleteGatedItem`) goes
    /// red without one byte of Keychain traffic. Append-only within a
    /// process; concurrent suites can only ADD names, so a containment
    /// assertion over a delta never false-fails.
    static var refusedLeafNames: [String] {
        tripLock.lock()
        defer { tripLock.unlock() }
        return refusedNames
    }

    /// pre-13x 1a: the E2EE family is per store now (`<scope>-<storeID>-…`),
    /// so what a test process must never mutate is an item under one of
    /// the REAL scopes — the store variants' raw values (`Variorum`,
    /// `Variorum-dev`) — and the legacy fixed accounts. A throwaway scope is
    /// exactly that, and the per-store pins write under one (the store-key
    /// family's own precedent).
    static let realScopes: Set<String> = Set(AppDatabase.StoreVariant.allCases.map(\.rawValue)).union(["legacy"])

    /// Consulted FIRST by every E2EE write/delete leaf: true = refuse,
    /// recorded. Never fires in production. A REFUSAL rather than a trap,
    /// deliberately: the leaf's `false`/no-op is observable (the pin
    /// exercises the leaves themselves), while a trap would kill the very
    /// run that proves the guard — the refused mutation is already
    /// harmless by construction.
    static func refusesRealScopeMutation(_ scope: String, leaf: String) -> Bool {
        guard armed, realScopes.contains(scope) else { return false }
        tripLock.lock()
        trips += 1
        refusedNames.append(leaf)
        tripLock.unlock()
        NSLog("KeychainTestTripwire: refused E2EEKeychainStorage.%@ under the REAL scope %@ from a test process (the 13p-fix R3-1 class) — drive the injected seams or a throwaway scope instead", leaf, scope)
        return true
    }
}

/// WHICH KEYCHAIN a family lives in — the decision, named.
///
/// macOS has two keychain implementations. `SecItem` defaults to the
/// FILE-BASED one; an item carrying an access-control (biometry) ACL or
/// `kSecAttrSynchronizable` can only live in the DATA-PROTECTION one, and
/// writes carrying either are routed there automatically. Reads are NOT:
/// a query without this flag searches the file-based keychain and cannot
/// see the item that was just written. Measured in the signed host
/// (2026-08-30): add `0` · read-without `-25300` (itemNotFound) ·
/// read-with `-25308` (interactionNotAllowed — present, needs auth).
///
/// So every query in a data-protection-resident family — add, read,
/// delete and probe alike — merges this. Apple's guidance is the same:
/// set it everywhere in the family, so the family can never disagree with
/// itself. It is a documented no-op on iOS, which has only the
/// data-protection keychain.
///
/// **Every custody family merges it since pre-13x 1a** — the store key's
/// silent item since #82 (R-pre13u-3: core's `StoreKeyKeychain` runs the
/// TN3137 read→re-add-with-flag→delete-old migration), and now the E2EE
/// sync custody (`E2EEKeychainStorage`, per store) and the session tokens
/// (`KeychainAuthStorage`, device-bound) by the same road — the postures
/// design's §1.13: custody items per store id, session tokens device-bound,
/// nothing usable in a Migration-Assistant or Time-Machine copy.
nonisolated enum KeychainPartition {
    /// Computed, not stored: `[String: Any]` is not `Sendable`, and a
    /// fresh dictionary per call costs nothing beside a Keychain round
    /// trip.
    static var dataProtection: [String: Any] {
        [kSecUseDataProtectionKeychain as String: true]
    }
}
