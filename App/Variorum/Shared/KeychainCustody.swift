//
//  KeychainCustody.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 13p-fix — the two rules every keychain custody family obeys,
//  each stated ONCE. Both were learned the same day, from the same
//  incident, and both exist because a comment three files away is not a
//  mechanism. The pre-13u round added the THIRD rule below
//  (`KeychainTestTripwire`) after the second lesson of that same day:
//  the rule that WAS only a comment failed exactly as this header
//  predicts.
//

import Foundation
import Security

/// A TEST PROCESS NEVER MUTATES A FIXED-ACCOUNT CUSTODY ITEM — the rule,
/// made structural (pre-13u Act 9, F4).
///
/// `E2EEKeychainStorage`'s accounts are FIXED (`device-keys` /
/// `device-keys-biometric`): there is no scope parameter, so ANY
/// write/delete that reaches its leaves from a test process lands on the
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

    /// Consulted FIRST by every fixed-account write/delete leaf: true =
    /// refuse, recorded. Never fires in production. A REFUSAL rather than
    /// a trap, deliberately: the leaf's `false`/no-op is observable (the
    /// pin exercises the leaves themselves), while a trap would kill the
    /// very run that proves the guard — the refused mutation is already
    /// harmless by construction.
    static func refusesFixedAccountMutation(_ leaf: String) -> Bool {
        guard armed else { return false }
        tripLock.lock()
        trips += 1
        refusedNames.append(leaf)
        tripLock.unlock()
        NSLog("KeychainTestTripwire: refused E2EEKeychainStorage.%@ from a test process (the 13p-fix R3-1 class) — drive the injected seams instead", leaf)
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
/// **Two plain families deliberately do NOT merge it** (the E2EE custody
/// item, the auth tokens): those items exist in the file-based keychain
/// today, and moving them is unruled — the vault re-derives both by
/// passphrase/sign-in, so neither is the gap the store key's was. **The
/// store key's silent item DOES merge it since #82 (R-pre13u-3)** — core's
/// `StoreKeyKeychain` runs the TN3137 read→re-add-with-flag→delete-old
/// migration so the existing item moves instead of stranding, and the
/// `…ThisDeviceOnly` class is finally in force for the key to the library.
nonisolated enum KeychainPartition {
    /// Computed, not stored: `[String: Any]` is not `Sendable`, and a
    /// fresh dictionary per call costs nothing beside a Keychain round
    /// trip.
    static var dataProtection: [String: Any] {
        [kSecUseDataProtectionKeychain as String: true]
    }
}

/// RE-WRITING a gated (ACL'd) item — the probe-first rule (17h, 13p-fix
/// ladder R2-7).
///
/// A gated item cannot be updated in place: updating an ACL'd item
/// demands interactive auth, and a WRITE must never prompt — so both
/// gated families are forced into delete-then-add. That order carries a
/// window: a `SecItemAdd` that fails AFTER the forced delete leaves no
/// gated custody at all (reached from `DeviceKeyStore.save` whenever a
/// gated item already exists — a passphrase re-unwrap's re-save). The
/// KnownIssues row's swap remedy (add under a temp account → rename) is
/// unsound under the same platform rule — `SecItemUpdate` of an ACL'd
/// item's attributes is an update too — so the window is NARROWED
/// instead of state-machined: prove the keychain accepts an identical
/// ACL'd add RIGHT NOW (a probe item under a sibling account, same ACL,
/// dummy data, deleted immediately), and only then release the existing
/// item and add the real one.
///
/// The probe genuinely exercises every stable failure mode — keychain
/// identity/access group, data-protection admission, ACL acceptance,
/// biometry enrollment state, disk, securityd health — so what SURVIVES
/// is only a failure arising in the milliseconds between two identical
/// adds, plus the crash-between-syscalls window that always existed
/// (both recorded, pinned as behavior in `GatedSaveChoreographyTests`).
/// When the window does fire, the incoming material is in hand at the
/// caller and the surfaces already word the refusal; the vault
/// re-derives custody by passphrase — a re-enrollment prompt, never
/// lost writing. Probe litter from a crash is swept at the next run's
/// leading sweep.
nonisolated enum GatedSaveChoreography {
    /// `sweepProbe` deletes the probe item (leading: a crashed prior
    /// run's litter; trailing: this run's own). `releaseExisting` answers
    /// the R3-5 released-semantics — a refusal stops the save with the
    /// existing custody intact.
    static func run(
        sweepProbe: () -> Void,
        addProbe: () -> Bool,
        releaseExisting: () -> Bool,
        addIncoming: () -> Bool
    ) -> Bool {
        sweepProbe()
        guard addProbe() else { return false }  // adds don't land right now — nothing released
        sweepProbe()
        guard releaseExisting() else { return false }
        return addIncoming()
    }
}

/// MOVING custody between two items — the three-step rule.
///
/// Every mode transition that hands the key from one keychain item to
/// another does the same thing: write the incoming item, VERIFY it reads
/// back **through the production read path**, and only then delete the
/// outgoing one.
///
/// The middle step is the one this project learned the hard way. A write
/// returning success proves the item was ACCEPTED; it never proves
/// anything can find it again. On 2026-08-30 an ACL'd write succeeded
/// into the data-protection keychain while every read searched the
/// file-based one — and the delete that followed destroyed the only
/// reachable copy of the author's store key and, separately, of her E2EE
/// custody. The keychain asymmetry was one cause of that shape; it is not
/// the only possible one. The access group is part of an item's identity,
/// so a bundle-id change, a distribution profile that omits the group, or
/// any keychain-identity regression reproduces it exactly.
///
/// Refusing here costs a mode change the user can retry. Skipping it
/// costs the key.
nonisolated enum CustodyHandover {
    /// The three outcomes are distinguished because they are not equally
    /// true (13p-fix ladder R2-2): only `.writeRefused` leaves the
    /// keychain untouched. `.wroteButUnreadable` means an item DID land
    /// somewhere the read path cannot reach — the keychain-identity
    /// symptom — and a surface that says "nothing was altered" there is
    /// lying in exactly the case this rule exists to make visible.
    enum Outcome: Equatable {
        /// The incoming item is readable and the outgoing one is released.
        case done
        /// The write itself was refused — nothing changed anywhere.
        case writeRefused
        /// The write succeeded and the item could not be read back. The
        /// outgoing custody is INTACT (that is the point); the incoming
        /// write was rolled back best-effort, which may itself have been
        /// unable to reach the item — that is the failure being handled,
        /// so it is never load-bearing.
        case wroteButUnreadable
        /// 17h (13p-fix ladder R3-5): the incoming item landed and read
        /// back, but the OUTGOING one would not go — `SecItemDelete`
        /// refused. Until this case existed the delete's status was
        /// dropped at the leaves, so the custody law bound WRITES only: a
        /// gate transition could complete with the old silently-releasing
        /// item still in place (theater, R13p-14's exact prohibition), or
        /// the OFF flip could leave the gated item deciding `load()`'s
        /// behavior. The incoming write is rolled back best-effort (never
        /// load-bearing, as above) and the transition refuses whole — the
        /// state the surface reports stays the state the Keychain holds.
        case outgoingNotReleased
    }

    /// `verify` must read through the SAME path production reads through.
    /// Where identity can be checked for free (a plain item whose value is
    /// readable), verify identity — presence alone passes on a stale item
    /// left by an earlier access group. The GATED arms are the forced
    /// exception: reading an ACL'd item's DATA prompts for biometrics, and
    /// a write must never prompt, so they verify presence only.
    ///
    /// `deleteOutgoing` answers whether the outgoing item is RELEASED
    /// (deleted, or was never there) — 17h R3-5: a delete's status is
    /// evidence exactly as a write's is, and dropping it enforced the
    /// custody law in one direction only.
    static func perform(
        write: () -> Bool,
        verify: () -> Bool,
        deleteOutgoing: () -> Bool,
        rollBackIncoming: () -> Void = {}
    ) -> Outcome {
        guard write() else { return .writeRefused }
        guard verify() else {
            rollBackIncoming()
            return .wroteButUnreadable
        }
        guard deleteOutgoing() else {
            rollBackIncoming()
            return .outgoingNotReleased
        }
        return .done
    }
}
