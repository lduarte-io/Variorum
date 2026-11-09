import Foundation
import Testing

/// VX-852 — THE RELEASE ROAD READS THE PIN BELT (VX-915 batch 5; the wiring proposed in
/// `notes/plans/fixes/vx-781-lockfile-pins.md`, §THE release.sh WIRING).
///
/// `Tools/verify-pins` (VX-781) is the guard that a build resolved exactly the committed package
/// set. Before VX-852 the release pipeline never ran it. Two verification-only hooks now do, with
/// no change to the publish flow:
/// - **the preflight hook**: after the clean-tree refusal (a release is one commit's build), the
///   no-argument guard over the two lockfiles a build is about to read; a drift refuses (exit 3);
/// - **the post-archive hook**: after `archive-and-export.sh` succeeds and BEFORE anything is
///   notarized, the guard over the archive's own `${BUILD_DIR}/DerivedData` (the graph it
///   ACTUALLY built against — every road a pre-build check cannot see), its report kept as
///   `verify-pins.txt`; a drift prints it and refuses (exit 5). It must run before the hygiene
///   sweep removes that DerivedData.
/// - **retention**: a release's durable record (`Releases/<version>/`) keeps `verify-pins.txt`
///   beside `RELEASE-INFO.txt`, so the pins check is release provenance like the dSYMs.
///
/// The release road is the author's: these pins READ `Tools/Release/release.sh` (a source walk —
/// nothing here runs it), so the hooks cannot be dropped, reordered past the steps they guard, or
/// lose their refusals without a red. The guard itself is pinned by `PinBeltTests` and VX-781/853's
/// records.
@Suite("VX-852 — release.sh runs the pins guard before the build and over the archive's own graph, and keeps its report")
struct ReleasePinsWiringTests {
    static let repo = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // Tests/VariorumCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // repo root

    /// release.sh as lines, comments stripped of nothing (a hook must be a COMMAND line, so a
    /// commented-out hook never satisfies these pins — `commandLine` below skips `#` lines).
    static func releaseLines() throws -> [String] {
        try String(contentsOf: repo.appendingPathComponent("Tools/Release/release.sh"), encoding: .utf8)
            .components(separatedBy: "\n")
    }

    /// The index of the one COMMAND line (not a comment) containing `needle`; records an issue
    /// when it is missing or appears more than once.
    static func commandLine(
        _ needle: String, in lines: [String], sourceLocation: SourceLocation = #_sourceLocation
    ) -> Int? {
        let hits = lines.indices.filter { i in
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            return !line.hasPrefix("#") && line.contains(needle)
        }
        #expect(hits.count == 1, "release.sh: expected exactly one command line with \(needle), found \(hits.count)",
                sourceLocation: sourceLocation)
        return hits.count == 1 ? hits[0] : nil
    }

    @Test("the preflight hook: the no-argument guard runs after the clean-tree refusal and before the archive, and refuses on a drift")
    func thePreflightHookGuardsTheLockfilesBeforeTheBuild() throws {
        let lines = try Self.releaseLines()
        let cleanTree = try #require(Self.commandLine(#"[ "$DIRTY" = "0" ] || refuse"#, in: lines))
        let hook = try #require(Self.commandLine(#""${REPO}/Tools/verify-pins" > /dev/null"#, in: lines))
        let archive = try #require(Self.commandLine(#""${HERE}/archive-and-export.sh""#, in: lines))
        #expect(cleanTree < hook && hook < archive,
                "the preflight hook sits after the clean-tree refusal (:\(cleanTree + 1)) and before the archive (:\(archive + 1)); it is at :\(hook + 1)")
        #expect(lines[hook].contains("|| refuse"), "a drift REFUSES the release (preflight, exit 3): \(lines[hook])")
        #expect(lines[hook].contains("Tools/verify-pins (VX-781)"), "the refusal names the road to see the drift: \(lines[hook])")
    }

    @Test("the post-archive hook: the guard reads the archive's own DerivedData before anything is notarized, keeps its report, and refuses on a drift")
    func thePostArchiveHookReadsTheArchivesOwnGraphBeforeNotarization() throws {
        let lines = try Self.releaseLines()
        let archiveOK = try #require(Self.commandLine(#"[ "$AE" -eq 0 ] ||"#, in: lines))
        let buildDir = try #require(Self.commandLine(#"BUILD_DIR="${OUT}/build.noindex""#, in: lines))
        let hook = try #require(Self.commandLine(
            #""${REPO}/Tools/verify-pins" "${BUILD_DIR}/DerivedData" > "${BUILD_DIR}/verify-pins.txt""#, in: lines))
        let firstNotarize = try #require(Self.commandLine(#"notarize "${OUT}/Variorum-app-for-notary.zip" app"#, in: lines))
        let sweep = try #require(Self.commandLine(#"rm -rf "${BUILD_DIR}/DerivedData""#, in: lines))
        #expect(buildDir < hook && archiveOK < hook,
                "the hook runs only after the archive succeeded (:\(archiveOK + 1)); it is at :\(hook + 1)")
        #expect(hook < firstNotarize, "the archive's graph is checked BEFORE anything is notarized (:\(firstNotarize + 1))")
        #expect(hook < sweep, "the hook reads the DerivedData before the hygiene sweep removes it (:\(sweep + 1))")
        // The refusal: the next line (the hook's continuation) prints the report and exits 5.
        let refusal = lines[hook + 1]
        #expect(lines[hook].hasSuffix("\\") && refusal.contains(#"cat "${BUILD_DIR}/verify-pins.txt" >&2"#)
                && refusal.contains("exit 5"),
                "a drift prints the report and refuses (exit 5): \(lines[hook]) / \(refusal)")
        #expect(refusal.contains("the archive resolved packages other than the committed pins (VX-781)"))
    }

    @Test("retention: a release's durable record keeps verify-pins.txt beside RELEASE-INFO.txt")
    func aReleasesDurableRecordKeepsThePinsReport() throws {
        let lines = try Self.releaseLines()
        let record = try #require(Self.commandLine(#"RECORD="${RELEASES}/${VERSION}""#, in: lines))
        let retained = try #require(Self.commandLine(#""${BUILD_DIR}/verify-pins.txt""#, in: lines.enumerated().map {
            // Only the retention copy counts here, never the hook itself (which also names the file).
            $0.offset > record ? $0.element : ""
        }))
        let line = lines[retained]
        #expect(line.contains("cp -p") && line.contains(#""${OUT}/RELEASE-INFO.txt""#) && line.hasSuffix(#""$RECORD/""#),
                "the report is copied into Releases/<version>/ beside RELEASE-INFO.txt: \(line)")
        // Inside the release-mode block (the durable record is a release's alone).
        let releaseBlock = try #require(lines[..<record].lastIndex { $0.contains(#"if [ "$MODE" = release ]; then"#) })
        let blockEnd = try #require(lines[record...].firstIndex { $0.trimmingCharacters(in: .whitespaces) == "fi" })
        #expect(releaseBlock < retained && retained < blockEnd, "the copy rides the release-mode record block")
    }

    @Test("the guard the hooks call exists and is executable")
    func theGuardTheHooksCallIsThere() throws {
        let path = Self.repo.appendingPathComponent("Tools/verify-pins").path
        #expect(FileManager.default.isExecutableFile(atPath: path), "Tools/verify-pins must be executable: \(path)")
    }
}
