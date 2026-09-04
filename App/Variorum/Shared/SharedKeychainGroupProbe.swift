//
//  SharedKeychainGroupProbe.swift
//  Variorum (shared: Mac + Mobile) — DEBUG ONLY; compiled out of Release
//
//  pre-13x batch 0 (design §3.7 / §17b Q2 · Q3 · Q5; 2026-09-04): the ONE
//  measurement brain behind the SHARED keychain access group
//  (`TEAMID.io.lduarte.Variorum.shared`, the second entry both targets'
//  entitlements now carry). Three DEBUG doors drive it — the Mac test suite
//  (DISABLED by default; Q2/Q5), the Mac Help-menu item and the phone's
//  Settings row (the cross-device leg, Q3). It exists to ANSWER QUESTIONS,
//  never to hold custody:
//
//  · THE SERVICE IS THROWAWAY (`…pre13x-shared-group-probe`) — never the
//    store-key, escrow or E2EE custody services. Nothing production reads
//    or writes it; deleting every item under it loses nothing. That is
//    exactly why the cross-device leg may use a FIXED account name: the
//    tripwire's law (`KeychainTestTripwire`) protects FIXED-ACCOUNT CUSTODY
//    items, and this is not one — the reading device must be able to find
//    what the OTHER device wrote, so the name is shared by construction.
//  · The LOCAL leg uses a timestamped throwaway account and deletes it at
//    the end (and sweeps again if a must-hold step failed midway).
//  · Every write names the shared group EXPLICITLY (`kSecAttrAccessGroup`)
//    — the design's rule for every iCloud-synchronizable item (§3.7).
//  · `kSecUseDataProtectionKeychain` rides every query (the 13p-fix
//    partition rule; a documented no-op on iOS) and `kSecAttrSynchronizable`
//    rides every query of the synchronizable item — a search without it does
//    not match synchronizable items (the escrow family's own note), which Q5
//    MEASURES rather than assumes.
//
//  What it does NOT do: touch any production Keychain item, any store, any
//  `Sync/` code. The design's real synchronizable item (the Apple key A) is
//  batch 2's; this file is deleted when that lands.
//

#if DEBUG

import Foundation
import Security

nonisolated enum SharedKeychainGroupProbe {
    /// The throwaway probe SERVICE — never a production custody service.
    static let probeService = "io.lduarte.Variorum.pre13x-shared-group-probe"
    /// The team prefix `$(AppIdentifierPrefix)` resolves to (public: it is
    /// in the project file and in every signed entitlement dump).
    static let teamPrefix = "<apple-team-id>."
    static let sharedGroupSuffix = "io.lduarte.Variorum.shared"
    static var sharedGroup: String { teamPrefix + sharedGroupSuffix }
    /// The cross-device leg's FIXED account (see the header for why fixed is
    /// legal here). The payload names the writing device and the moment.
    static let crossDeviceAccount = "cross-device"

    /// The Mac suite's gate: DISABLED unless the environment says so
    /// (`TEST_RUNNER_VARIORUM_SHARED_GROUP_PROBE=1 xcodebuild test …`), so
    /// no ordinary suite run ever writes a synchronizable item.
    static var probeRequested: Bool {
        ProcessInfo.processInfo.environment["VARIORUM_SHARED_GROUP_PROBE"] == "1"
    }

    /// How a query speaks about `kSecAttrSynchronizable`.
    enum SynchronizableMatch: Sendable {
        /// `true` — matches synchronizable items only (the family's default).
        case set
        /// `kSecAttrSynchronizableAny` — matches both kinds.
        case any
        /// Not set at all — the platform default, which matches only
        /// NON-synchronizable items (Q5 measures this).
        case omitted
    }

    /// One `SecItemCopyMatching` answer, with what the item says about
    /// itself (the group it LANDED in, its synchronizable flag).
    struct Match: Sendable, Equatable {
        var status: OSStatus
        var payload: String?
        var accessGroup: String?
        var synchronizable: Bool?

        var summary: String {
            var s = SharedKeychainGroupProbe.describe(status)
            if let payload { s += " payload=\"\(payload)\"" }
            if let accessGroup { s += " group=\(accessGroup)" }
            if let synchronizable { s += " synchronizable=\(synchronizable)" }
            return s
        }
    }

    /// A status code with Security's own words beside it.
    static func describe(_ status: OSStatus) -> String {
        let words = (SecCopyErrorMessageString(status, nil) as String?) ?? "?"
        return "\(status) (\(words))"
    }

    // MARK: - The query family (one builder; every leg composes it)

    static func query(
        account: String,
        group: String?,
        synchronizable: SynchronizableMatch = .set
    ) -> [String: Any] {
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: probeService,
            kSecAttrAccount as String: account,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
        switch synchronizable {
        case .set: q[kSecAttrSynchronizable as String] = true
        case .any: q[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        case .omitted: break
        }
        if let group { q[kSecAttrAccessGroup as String] = group }
        return q
    }

    /// Add (or, on a duplicate, update) a SYNCHRONIZABLE item under `group`
    /// — the escrow shape: `AfterFirstUnlock`, no access control.
    static func write(account: String, payload: String, group: String?) -> OSStatus {
        var attributes = query(account: account, group: group)
        attributes[kSecValueData as String] = Data(payload.utf8)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: Data(payload.utf8)]
            return SecItemUpdate(
                query(account: account, group: group) as CFDictionary, update as CFDictionary)
        }
        return status
    }

    static func read(
        account: String,
        group: String?,
        synchronizable: SynchronizableMatch = .set
    ) -> Match {
        var q = query(account: account, group: group, synchronizable: synchronizable)
        q[kSecReturnData as String] = true
        q[kSecReturnAttributes as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        let status = SecItemCopyMatching(q as CFDictionary, &result)
        let attributes = result as? [String: Any]
        let data = attributes?[kSecValueData as String] as? Data
        return Match(
            status: status,
            payload: data.flatMap { String(data: $0, encoding: .utf8) },
            accessGroup: attributes?[kSecAttrAccessGroup as String] as? String,
            synchronizable: (attributes?[kSecAttrSynchronizable as String] as? NSNumber)?.boolValue)
    }

    static func delete(
        account: String,
        group: String?,
        synchronizable: SynchronizableMatch = .set
    ) -> OSStatus {
        SecItemDelete(query(account: account, group: group, synchronizable: synchronizable) as CFDictionary)
    }

    /// Which group an item lands in when NONE is named — the FIRST group of
    /// the entitlement (Q1's runtime confirmation on each target; on iOS the
    /// only road, `SecTask` being unavailable there). A NON-synchronizable
    /// `ThisDeviceOnly` throwaway item, added and deleted here.
    static func defaultAccessGroup() -> (status: OSStatus, group: String?) {
        let account = "default-group-\(timestamp())-\(UUID().uuidString.prefix(8))"
        var attributes = query(account: account, group: nil, synchronizable: .omitted)
        attributes[kSecValueData as String] = Data("probe".utf8)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        attributes[kSecReturnAttributes as String] = true
        var result: AnyObject?
        let status = SecItemAdd(attributes as CFDictionary, &result)
        defer { SecItemDelete(query(account: account, group: nil, synchronizable: .omitted) as CFDictionary) }
        let group = (result as? [String: Any])?[kSecAttrAccessGroup as String] as? String
        return (status, group)
    }

    static func timestamp() -> String {
        ISO8601DateFormatter().string(from: Date())
    }

    static func throwawayAccount() -> String {
        "local-\(timestamp())-\(UUID().uuidString.prefix(8))"
    }

    // MARK: - The local round trip (Q2 + Q5), as recorded lines

    struct Report: Sendable {
        var lines: [String] = []
        var failures: [String] = []
        var passed: Bool { failures.isEmpty }

        mutating func note(_ text: String) { lines.append(text) }
        /// A measured fact with no must-hold attached.
        mutating func fact(_ label: String, got: String) { lines.append("  ·  \(label): \(got)") }
        /// A must-hold: recorded either way, counted when it fails.
        mutating func check(_ label: String, got: String, pass: Bool) {
            lines.append("\(pass ? " ok " : "FAIL") \(label): \(got)")
            if !pass { failures.append(label) }
        }
    }

    /// Write → read (five ways) → delete (two ways) → read, every status
    /// recorded, the must-holds counted. Leaves nothing behind.
    static func runLocalRoundTrip(deviceName: String) -> Report {
        var report = Report()
        let account = throwawayAccount()
        let payload = "\(deviceName) @ \(timestamp())"
        report.note("service \(probeService) · account \(account)")
        report.note("shared group \(sharedGroup)")

        let (defaultStatus, defaultGroup) = defaultAccessGroup()
        report.check(
            "Q1 an item written with NO group lands in the target's own (first) group",
            got: "\(describe(defaultStatus)) group=\(defaultGroup ?? "nil")",
            pass: defaultStatus == errSecSuccess && defaultGroup != nil && defaultGroup != sharedGroup)

        let add = write(account: account, payload: payload, group: sharedGroup)
        report.check(
            "Q2 add (shared group · synchronizable · AfterFirstUnlock · no ACL)",
            got: describe(add), pass: add == errSecSuccess)

        let named = read(account: account, group: sharedGroup)
        report.check(
            "Q2 read (shared group named · synchronizable=true) — payload and landing group",
            got: named.summary,
            pass: named.status == errSecSuccess && named.payload == payload
                && named.accessGroup == sharedGroup && named.synchronizable == true)

        let unnamed = read(account: account, group: nil)
        report.fact(
            "Q5 read (NO group named · synchronizable=true) — the same app searches ALL its groups",
            got: unnamed.summary)

        if let defaultGroup {
            let other = read(account: account, group: defaultGroup)
            report.check(
                "Q5 read (the DEFAULT group named) — another group must NOT see it",
                got: other.summary, pass: other.status == errSecItemNotFound)
        }

        let flagless = read(account: account, group: sharedGroup, synchronizable: .omitted)
        report.check(
            "Q5 read (shared group · synchronizable OMITTED) — a flagless search must not match",
            got: flagless.summary, pass: flagless.status == errSecItemNotFound)

        let any = read(account: account, group: sharedGroup, synchronizable: .any)
        report.check(
            "Q5 read (shared group · kSecAttrSynchronizableAny)",
            got: any.summary, pass: any.status == errSecSuccess)

        let flaglessDelete = delete(account: account, group: sharedGroup, synchronizable: .omitted)
        report.fact("Q5 delete (shared group · synchronizable OMITTED)", got: describe(flaglessDelete))
        let stillThere = read(account: account, group: sharedGroup)
        report.check(
            "Q5 read after the flagless delete — the item must still be there",
            got: stillThere.summary, pass: stillThere.status == errSecSuccess)

        let flaggedDelete = delete(account: account, group: sharedGroup, synchronizable: .set)
        report.check(
            "Q5 delete (shared group · synchronizable=true) — MUST match",
            got: describe(flaggedDelete), pass: flaggedDelete == errSecSuccess)
        let gone = read(account: account, group: sharedGroup)
        report.check(
            "Q5 read after the flagged delete — gone",
            got: gone.summary, pass: gone.status == errSecItemNotFound)
        let goneAny = read(account: account, group: sharedGroup, synchronizable: .any)
        report.check(
            "Q5 read (Any) after the delete — gone",
            got: goneAny.summary, pass: goneAny.status == errSecItemNotFound)

        // The belt: never leave the throwaway item behind, whatever failed.
        if gone.status != errSecItemNotFound || goneAny.status != errSecItemNotFound {
            _ = delete(account: account, group: sharedGroup, synchronizable: .any)
            _ = delete(account: account, group: nil, synchronizable: .any)
        }
        return report
    }

    // MARK: - The cross-device leg (Q3): write here, read there

    static func writeCrossDevice(deviceName: String) -> OSStatus {
        write(account: crossDeviceAccount, payload: "\(deviceName) @ \(timestamp())", group: sharedGroup)
    }

    static func readCrossDevice() -> Match {
        read(account: crossDeviceAccount, group: sharedGroup)
    }

    static func deleteCrossDevice() -> OSStatus {
        delete(account: crossDeviceAccount, group: sharedGroup, synchronizable: .any)
    }
}

#endif
