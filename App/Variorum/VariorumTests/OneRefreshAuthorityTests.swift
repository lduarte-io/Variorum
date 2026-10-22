//
//  OneRefreshAuthorityTests.swift
//  VariorumTests
//
//  VX-329 U3 — VX-423: ONE REFRESH AUTHORITY PER PROCESS (the plan's §6b brief; the U3 RECORD carries the trace and
//  every red-on-old). The account's refresh token ROTATES: every refresh spends the token it presents and hands back a
//  new one, and GoTrue's reuse detection answers a spent token with `refresh_token_already_used` and revokes the whole
//  family. Two `AuthSession` actors over ONE stored session — the services' (sync, the account doors) and the protection
//  road's vault leaf's — each read the stored token once and refreshed on their own, so the second to refresh presented
//  a token the first had already spent, and sync stopped until she signed in again. The process now holds ONE
//  `AuthSession`, the bootstrap's, and hands it to both.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The composition (source)

/// THE COMPOSITION, read from the product's own sources: the process mints its session in ONE place, the bootstrap, and
/// every consumer is handed that one. Red on the pre-fix tree by construction — two mints (the services' default in
/// `AppServices.init`, the vault leaf's `FollowingSessionProvider` `make`), neither in the bootstrap.
@Suite("VX-423 — the process's one refresh authority: the composition (source)")
struct OneRefreshAuthorityCompositionTests {
    /// `App/Variorum/` — through the symlink a headless harness reads this file by, when there is one.
    static let appRoot = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
        .deletingLastPathComponent()  // VariorumTests
        .deletingLastPathComponent()  // App/Variorum

    /// Every product source of both apps (the shared brains and faces, the Mac's, the phone's) — never a test's.
    static func productSources() -> [URL] {
        ["Shared", "Variorum", "VariorumMobile"].flatMap { folder -> [URL] in
            let root = appRoot.appendingPathComponent(folder, isDirectory: true)
            guard let walk = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else { return [] }
            return walk.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        }
    }

    /// A source's CODE — every line with its `//` comment cut off (a history comment may name what left; only code
    /// counts).
    static func code(_ url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
            .joined(separator: "\n")
    }

    static func code(_ relative: String) throws -> String {
        try code(appRoot.appendingPathComponent(relative))
    }

    /// `AuthSession(` as a construction — never `AuthSessionError(` or another name ending in it.
    static func constructions(in text: String) -> Int {
        text.ranges(of: "AuthSession(").filter { range in
            guard range.lowerBound > text.startIndex else { return true }
            let before = text[text.index(before: range.lowerBound)]
            return !(before.isLetter || before.isNumber || before == "_")
        }.count
    }

    @Test func theProductMintsItsSessionOnceInTheBootstrapAndNowhereElse() throws {
        let sources = Self.productSources()
        #expect(sources.count > 100, "the walk reads the product's sources (\(sources.count) found)")
        var mints: [String: Int] = [:]
        for url in sources {
            let count = Self.constructions(in: try Self.code(url))
            if count > 0 { mints[url.lastPathComponent, default: 0] += count }
        }
        #expect(mints == ["AppBootstrap.swift": 1],
                "ONE AuthSession per process, minted by the bootstrap — found \(mints)")
    }

    @Test func bothRootsHandTheBootstrapsAuthorityToTheServices() throws {
        for root in ["Variorum/VariorumApp.swift", "VariorumMobile/VariorumMobileApp.swift"] {
            let text = try Self.code(root)
            #expect(text.contains("AppServices("), "\(root) composes the services")
            #expect(text.contains("auth: bootstrap.auth"), "\(root) hands the services the bootstrap's one authority")
        }
    }

    @Test func theProtectionRoadIsComposedOverTheSameAuthority() throws {
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        #expect(bootstrap.contains("RoadInputs.live(variant: variant, auth: auth)"),
                "the production road's every composed system rides the bootstrap's authority")
        let road = try Self.code("Shared/Protection/ProtectionOpenRoad.swift")
        #expect(road.contains("ProtectionSystem.live(variant: variant, session: auth)"))
        let system = try Self.code("Shared/Protection/ProtectionSystem.swift")
        #expect(system.contains("WireVaultLeaf.live(deviceName: deviceName, session: session)"),
                "the system's vault leaf is served by the session it is handed")
    }

    @Test func theVaultLeafNoLongerFollowsTheStoredSessionOnItsOwn() throws {
        let leftovers = try Self.productSources().filter { url in
            let named = url.lastPathComponent == "FollowingSessionProvider.swift"
            return try named || Self.code(url).contains("FollowingSessionProvider")
        }
        #expect(leftovers.isEmpty, "the leaf's own session provider is gone — \(leftovers.map(\.lastPathComponent))")
    }
}
