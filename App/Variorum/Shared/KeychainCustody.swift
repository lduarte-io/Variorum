//
//  KeychainCustody.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 13p-fix — the two rules every keychain custody family obeys,
//  each stated ONCE. Both were learned the same day, from the same
//  incident, and both exist because a comment three files away is not a
//  mechanism.
//

import Foundation
import Security

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
/// **The plain families deliberately do NOT merge it** (the store key's
/// silent item, the E2EE custody item, the auth tokens): those items
/// exist in the file-based keychain today, and moving them would strand
/// real data — including the key to the library. See
/// `KnownIssuesAndTechDebt.md` for the consequence that carries.
nonisolated enum KeychainPartition {
    /// Computed, not stored: `[String: Any]` is not `Sendable`, and a
    /// fresh dictionary per call costs nothing beside a Keychain round
    /// trip.
    static var dataProtection: [String: Any] {
        [kSecUseDataProtectionKeychain as String: true]
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
    /// Returns true only when the incoming custody is READABLE and the
    /// outgoing item has been released. On failure nothing is deleted;
    /// `rollBackIncoming` is a best-effort tidy of a write that landed
    /// somewhere unreadable (it may itself be unable to reach the item —
    /// that is the failure being handled, so it is never load-bearing).
    static func perform(
        write: () -> Bool,
        verify: () -> Bool,
        deleteOutgoing: () -> Void,
        rollBackIncoming: () -> Void = {}
    ) -> Bool {
        guard write() else { return false }
        guard verify() else {
            rollBackIncoming()
            return false
        }
        deleteOutgoing()
        return true
    }
}
