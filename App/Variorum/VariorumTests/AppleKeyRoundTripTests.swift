//
//  AppleKeyRoundTripTests.swift
//  VariorumTests
//
//  pre-13x batch 2a — THE ICLOUD KEY'S SAME-MAC ROUND TRIP (the brief's
//  item 2 gate: "the same-Mac A round trip quoted"), in the SIGNED test
//  host, against the REAL Keychain, under a THROWAWAY ACCOUNT of the real
//  family (service `io.lduarte.Variorum.apple-key`, the shared group) —
//  the ONE exception the design allows to the never-write-a-synchronizable-
//  item rule (A's family IS synchronizable by nature), deleted with the
//  FLAGGED delete at the end.
//
//  DISABLED BY DEFAULT — the batch-0 opt-in pattern: the throwaway item
//  rides into the author's iCloud Keychain for the milliseconds between
//  add and delete (its tombstone follows), so the suite runs only when
//  the environment says so:
//
//      TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1 xcodebuild test … \
//        -only-testing:VariorumTests/AppleKeyRoundTripTests
//
//  Every status prints as an `APPLE-KEY|` line so the record quotes the
//  run verbatim. The real scopes' A (`Variorum-apple-key`,
//  `Variorum-dev-apple-key`) are NEVER read, written or deleted here.
//

import Foundation
import Security
import Testing

@testable import Variorum

nonisolated enum AppleKeyRoundTrip {
    static var requested: Bool {
        ProcessInfo.processInfo.environment["VARIORUM_APPLE_KEY_ROUND_TRIP"] == "1"
    }
}

@Suite(
    "pre-13x 2a — the iCloud key A round-trips on this Mac (opt-in; DISABLED unless VARIORUM_APPLE_KEY_ROUND_TRIP=1)",
    .enabled(
        if: AppleKeyRoundTrip.requested,
        "writes one synchronizable throwaway item under the Apple-key family (it rides into iCloud Keychain and is deleted) — run deliberately with TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1"))
struct AppleKeyRoundTripTests {
    private func describe(_ status: OSStatus) -> String {
        let words = (SecCopyErrorMessageString(status, nil) as String?) ?? "?"
        return "\(status) (\(words))"
    }

    /// Q2 + Q5 on the REAL family: mint → read back equal → mint again is
    /// a READ (idempotent) → a FLAGLESS delete is a silent no-op (the item
    /// stays) → the flagged delete releases it → gone.
    @Test func theAppleKeyMintsReadsBackAndOnlyTheFlaggedDeleteReleasesIt() {
        let account = "throwaway-\(UUID().uuidString.lowercased().prefix(8))-apple-key"
        print("APPLE-KEY| service \(AppleKeyKeychain.service) · account \(account) · group \(AppleKeyKeychain.sharedGroup)")
        defer { _ = AppleKeyKeychain.delete(account: account) }  // the belt

        #expect(AppleKeyKeychain.read(account: account) == nil, "a fresh account holds nothing")
        let minted = AppleKeyKeychain.readOrMint(account: account)
        print("APPLE-KEY| readOrMint (mint): \(minted.map { "id \($0.id), 32 bytes: \($0.key.count == 32)" } ?? "nil — REFUSED")")
        #expect(minted != nil, "the Keychain accepted the synchronizable add under the shared group")
        #expect(minted?.key.count == 32)

        let read = AppleKeyKeychain.read(account: account)
        print("APPLE-KEY| read: \(read.map { "id \($0.id) — equal: \($0 == minted)" } ?? "nil")")
        #expect(read == minted, "reads back through the family's own query")

        let again = AppleKeyKeychain.readOrMint(account: account)
        print("APPLE-KEY| readOrMint (again): equal to the first: \(again == minted)")
        #expect(again == minted, "a second readOrMint is a READ — one A per iCloud account per scope")

        // The landing group and the flag, as the item reports them.
        var query = AppleKeyKeychain.query(account: account)
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        let attributes = result as? [String: Any]
        let group = attributes?[kSecAttrAccessGroup as String] as? String
        let synchronizable = (attributes?[kSecAttrSynchronizable as String] as? NSNumber)?.boolValue
        print("APPLE-KEY| attributes: \(describe(status)) group=\(group ?? "nil") synchronizable=\(String(describing: synchronizable))")
        #expect(group == AppleKeyKeychain.sharedGroup, "landed in the SHARED group")
        #expect(synchronizable == true)

        // Q5's rule, on the real family: a FLAGLESS delete is a silent no-op.
        var flagless = AppleKeyKeychain.query(account: account)
        flagless.removeValue(forKey: kSecAttrSynchronizable as String)
        let flaglessStatus = SecItemDelete(flagless as CFDictionary)
        print("APPLE-KEY| flagless delete: \(describe(flaglessStatus)) — item still there: \(AppleKeyKeychain.read(account: account) != nil)")
        #expect(AppleKeyKeychain.read(account: account) == minted,
                "a delete without the flag never matches a synchronizable item")

        // The flagged delete releases it.
        let released = AppleKeyKeychain.delete(account: account)
        print("APPLE-KEY| flagged delete: released \(released) — gone: \(AppleKeyKeychain.read(account: account) == nil)")
        #expect(released)
        #expect(AppleKeyKeychain.read(account: account) == nil)
        #expect(AppleKeyKeychain.delete(account: account), "released = gone, or never there")
    }
}
