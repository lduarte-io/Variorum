//
//  VersionSchemeTests.swift
//  VariorumTests
//
//  Phase 13r U3-A — R-13r-6, the version scheme: 0.9.x for the friends
//  beta (1.0.0 is reserved for the launch — the launch shipped 1.0, so the
//  line is 1.x now; VX-779 reshaped the pins), and the BUILD NUMBER stamped on
//  EVERY build — `git rev-list --count HEAD` into CFBundleVersion by the Mac
//  target's "Stamp Build Number" phase, which runs after the Info.plist is
//  processed and before code signing, in every configuration.
//
//  Why it is pinned and not just built: R-13r-7's premise (her hand-copied
//  daily drive always outranks the appcast, so Sparkle offers it nothing)
//  rests on every build carrying the count. A build that slipped back to
//  the old constant `1` would be OFFERED every public release — the hazard
//  U2 handed forward. These run in the Debug test host, so they read a real
//  stamped bundle; the release pipeline's `verify-export.sh --expect-build`
//  asserts the same number on the shipped bytes.
//

import Foundation
import Testing

@Suite("The version scheme (13r U3-A — R-13r-6's stamped build number + the launched line)")
struct VersionSchemeTests {
    /// The commit count at which the stamping phase first ran (U3-A piece 1).
    /// Commit counts only rise, so every later build reads at least this.
    static let stampFloor = 4879

    @Test func everyBuildCarriesTheCommitCountAsItsBuildNumber() {
        let raw = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let number = raw.flatMap { Int($0) }
        #expect(number != nil, "CFBundleVersion must be the commit count, read '\(raw ?? "nil")'")
        #expect((number ?? 0) >= Self.stampFloor,
                "the old constant build number 1 would be offered every public release")
    }

    @Test func theMarketingVersionIsTheLaunchedLine() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let major = version?.split(separator: ".").first.flatMap { Int($0) }
        #expect((major ?? 0) >= 1,
                "R-13r-6 reserved 1.0 for her public launch, and the launch shipped 1.0: the project's line is 1.x or later — a 0.x here is a skipped release bump (VX-779; read '\(version ?? "nil")')")
    }

    /// The phase's SHAPE, read from the project file: it is the Mac target's
    /// LAST build phase (after Resources — so after the Info.plist is
    /// processed; signing always runs after every phase), it is always run,
    /// it names the processed Info.plist as its input, and the Mac target —
    /// and ONLY the Mac target — turns script sandboxing off (git must read
    /// `.git`, which no input list can name).
    @Test func theStampPhaseIsTheMacTargetsLastPhaseAndAlwaysRuns() throws {
        let appDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        let project = try String(
            contentsOf: appDir.appendingPathComponent("Variorum.xcodeproj/project.pbxproj"),
            encoding: .utf8)
        // 13n-b U1 embedded the MCP shim as its own copy phase after
        // Resources; the stamp stays the LAST phase (the design intent —
        // after the Info.plist is processed), now after the embed too.
        #expect(project.contains("""
            \t\t\t\tE1C271862FFC2F420084BEA6 /* Resources */,
            \t\t\t\tE1AC00082F0000000000CC08 /* Embed MCP Shim */,
            \t\t\t\tE1B5A0102F0000000000AA10 /* Stamp Build Number */,
            \t\t\t);
            """), "the stamp is the Mac target's last phase (after Resources and the shim embed)")
        #expect(project.contains("alwaysOutOfDate = 1;"))
        #expect(project.contains("\"$(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)\","))
        #expect(project.contains("shellScript = \"\\\"${SRCROOT}/StampBuildNumber.sh\\\"\\n\";"))
        #expect(project.components(separatedBy: "ENABLE_USER_SCRIPT_SANDBOXING = NO;").count - 1 == 2,
                "exactly the Mac target's Debug and Release configurations")
        // R-13r-6's ADJUDICATED reading (the plan's LIVE STATUS): the repo's
        // MARKETING_VERSION increments WITH each beta release, so this pin
        // holds the SHAPE, never a literal release number (the original
        // "0.9.0;" literal went red at c4974c4a's 0.9.1 bump — repaired at
        // the ladder's fix pass; the "0.9." prefix went red at b59c68592's
        // 0.10 bump, her release word — widened to the pre-1.0 line at
        // VX-489). The letter holds: the Mac target's TWO configurations
        // carry the SAME line — the one the running test host was built as.
        // VX-779 (the launch's 1.0 is spent; the bump had been skipped from
        // 0.10.5 to 1.0.1): the two are found by their bundle identifiers,
        // no longer by the pre-1.0 prefix, because past the launch the test
        // bundles' and the mobile targets' template 1.0 share the "1." prefix
        // (the mobile app's version is its own project's). The headless
        // `Tools/Release/version-guard.sh` holds the same pair to the newest
        // release notes, and release.sh's preflight to the release's version.
        let builtVersion = try #require(
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        let configurations = project.components(separatedBy: "isa = XCBuildConfiguration;").dropFirst()
        func marketingLines(ofConfigurationFor bundleID: String) -> [String] {
            configurations
                .filter { $0.contains("PRODUCT_BUNDLE_IDENTIFIER = \(bundleID);") }
                .compactMap { configuration in
                    configuration.components(separatedBy: "\n")
                        .first { $0.contains("MARKETING_VERSION = ") }?
                        .trimmingCharacters(in: .whitespaces)
                }
        }
        let expected = ["MARKETING_VERSION = \(builtVersion);"]
        let debugLines = marketingLines(ofConfigurationFor: "io.lduarte.Variorum.debug")
        let releaseLines = marketingLines(ofConfigurationFor: "io.lduarte.Variorum")
        #expect(debugLines == expected,
                "the Mac target's Debug configuration carries the version this host was built as (read \(debugLines))")
        #expect(releaseLines == expected,
                "the Mac target's Release configuration carries the same version (read \(releaseLines))")
        let script = try String(
            contentsOf: appDir.appendingPathComponent("StampBuildNumber.sh"), encoding: .utf8)
        #expect(script.contains("git -C \"${SRCROOT}\" rev-list --count HEAD"))
        #expect(script.contains("Set :CFBundleVersion"))
    }
}
