//
//  ProtectionWalkProjectTests.swift
//  VariorumTests — VX-308 U1 piece 0: THE WALK'S DOOR (PROVISIONAL P-VX308-U1-0). A DEBUG launch with BOTH
//  `VARIORUM_WALK_PROJECT_URL` and `VARIORUM_WALK_ANON_KEY` set points `ProjectConfig`'s coordinates at that project
//  for the launch (the account arms' walk against a throwaway project); one alone, a blank value or a non-https URL
//  names nothing. The rule is pure (also runs headless in the implementer's SwiftPM harness); the fence — the override
//  is read only under `#if DEBUG`, and Release keeps the production coordinates — is source-pinned.
//

import Foundation
import Testing

@testable import Variorum

@Suite("VX-308 U1 — the walk's project coordinates (DEBUG walk machinery)")
struct ProtectionWalkProjectTests {
    static let url = "https://walkproject.example.test"
    static let key = "sb_publishable_walk"

    @Test func bothSetNameTheWalkProject() throws {
        let project = try #require(ProtectionWalkSwitch.projectOverride(environment: [
            ProtectionWalkSwitch.projectURLKey: " \(Self.url) ", ProtectionWalkSwitch.projectKeyKey: "\(Self.key)\n",
        ]))
        #expect(project.url == URL(string: Self.url))
        #expect(project.apiKey == Self.key, "trimmed")
    }

    @Test func oneAloneBlankOrNotHTTPSNamesNothing() {
        #expect(ProtectionWalkSwitch.projectOverride(environment: [:]) == nil)
        #expect(ProtectionWalkSwitch.projectOverride(environment: [ProtectionWalkSwitch.projectURLKey: Self.url]) == nil)
        #expect(ProtectionWalkSwitch.projectOverride(environment: [ProtectionWalkSwitch.projectKeyKey: Self.key]) == nil)
        #expect(ProtectionWalkSwitch.projectOverride(environment: [
            ProtectionWalkSwitch.projectURLKey: "  ", ProtectionWalkSwitch.projectKeyKey: Self.key,
        ]) == nil)
        #expect(ProtectionWalkSwitch.projectOverride(environment: [
            ProtectionWalkSwitch.projectURLKey: Self.url, ProtectionWalkSwitch.projectKeyKey: " ",
        ]) == nil)
        #expect(ProtectionWalkSwitch.projectOverride(environment: [
            ProtectionWalkSwitch.projectURLKey: "http://walkproject.example.test", ProtectionWalkSwitch.projectKeyKey: Self.key,
        ]) == nil, "never a plain-http project")
        #expect(ProtectionWalkSwitch.projectOverride(environment: [
            ProtectionWalkSwitch.projectURLKey: "walkproject", ProtectionWalkSwitch.projectKeyKey: Self.key,
        ]) == nil)
    }

    /// THE FENCE (source pin): `ProjectConfig` reads the override ONLY inside `#if DEBUG`, and its Release arm is the
    /// production coordinates alone — no environment read, no override, in a Release build.
    @Test func theOverrideIsReadOnlyInDebug() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Shared/ProjectConfig.swift"),
            encoding: .utf8)
        let debug = try #require(source.range(of: "#if DEBUG"))
        let release = try #require(source.range(of: "#else", range: debug.upperBound..<source.endIndex))
        let end = try #require(source.range(of: "#endif", range: release.upperBound..<source.endIndex))
        let debugArm = source[debug.upperBound..<release.lowerBound]
        let releaseArm = source[release.upperBound..<end.lowerBound]
        #expect(debugArm.contains("ProtectionWalkSwitch.projectOverrideForThisLaunch"))
        #expect(!releaseArm.contains("ProtectionWalkSwitch") && !releaseArm.contains("ProcessInfo"))
        #expect(releaseArm.contains("static let variorumProjectURL = productionProjectURL"))
        #expect(releaseArm.contains("static let variorumPublishableKey = productionPublishableKey"))
        // Nowhere else in the file reads the environment or the override.
        let outside = String(source[..<debug.lowerBound]) + String(source[end.upperBound...])
        #expect(!outside.contains("ProcessInfo") && !outside.contains("projectOverride"))
        #expect(source.components(separatedBy: "#if DEBUG").count == 2, "one fence")
    }
}
