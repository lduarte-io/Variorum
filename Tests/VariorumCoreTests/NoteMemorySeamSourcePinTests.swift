import Foundation
import Testing

/// **VX-926 U4 — the per-note memories' ONE defaults domain, fenced at the source**
/// (VX-97 · VX-666 · VX-695; `notes/plans/fixes/vx-926-test-flakes.md`, "## U4 record").
///
/// The Mac app keeps ten per-note view-memory key families in a defaults domain (surface
/// sizes, the current block, the mode, Read's face, the Takes board's columns and slot
/// heights, the Canvas's view memory, the book Index's grouping). Its test host IS the dev
/// app, so every one of them used to persist test fixtures' memories into the dev app's REAL
/// domain, where later suites could read them back (VX-695's band test went red machine-wide
/// on the accumulated domain — 2,622 such keys of its 2,731 — and green after the 10-28 scrub
/// removed exactly them: a cause shown by subtraction only, its road inside the test not yet
/// traced, VX-695 PENDING its legs A/A′/B). The fix is ONE seam, `NoteMemoryDefaults.store`
/// (`App/Variorum/Variorum/Core/Views/NoteMemoryDefaults.swift`): the app's own domain in the
/// app, a suite of the host's own under a test runner. Its behaviour is pinned in the app
/// target (`NoteMemoryDefaultsTests`, run at the stage); THIS file is the headless fence that
/// keeps it the ONE seam:
///
/// - every home names the seam and none names `UserDefaults.standard` (a default argument, a
///   stored default or a bare write);
/// - no app line reads or writes one of the families on `UserDefaults.standard` directly;
/// - the read tier's takes-first question is always ASKED with the seam (its own default is
///   the read tier's — the editor-seam class — and stays untouched);
/// - no test plants, reads or clears one of the families on `UserDefaults.standard` (a plant
///   there would no longer be read, and every write there is the dev app's real domain).
///
/// RED ON OLD: the pre-U4 tree (`1ff75d356`) fails all four (the named revert R-U4-S in the
/// record — the homes, `RootView` and the 35 migrated suites checked out from it).
@Suite("VX-926 U4 — every per-note memory names the one seam, never UserDefaults.standard")
struct NoteMemorySeamSourcePinTests {
    /// `…/Tests/VariorumCoreTests/<this file>` → the repo root.
    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumCoreTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo
    }

    /// The homes — the record's "The writers" table (row 5's memory is built by the model).
    static let homes = [
        "App/Variorum/Variorum/Core/Views/SurfaceSizeMemory.swift",
        "App/Variorum/Variorum/Registry/CurrentBlockMemory.swift",
        "App/Variorum/Variorum/Features/Takes/PostDetailView.swift",
        "App/Variorum/Variorum/Features/ReadMode/ReadModeView.swift",
        "App/Variorum/Variorum/Features/Takes/TakesModels.swift",
        "App/Variorum/Variorum/Features/Takes/TakesViewModel.swift",
        "App/Variorum/Variorum/Features/Takes/TakesBoardLayout.swift",
        "App/Variorum/Variorum/Features/Canvas/CanvasViewModel.swift",
        "App/Variorum/Variorum/Features/BookView/BookIndexGrouping.swift",
    ]

    /// A token every reader or writer of one of the families names.
    static let familyTokens = [
        "\"postMode.", "\"currentBlock.", "CurrentBlockMemory.key(", "\"surfaceSize.",
        "SurfaceSizeMemory.key(", "\"readFace.", "faceKey(", "\"takesViewMemory.",
        "TakesViewMemory.defaultsKeyPrefix", "\"takesSlotHeights.", "slotHeightsKeyPrefix",
        "\"canvasBankOpen.", "\"canvasSizeMemory.", "\"canvasViewMemory.", "\"bookIndex.grouping.",
        "rememberedMode(", "rememberedFace(", "holdsTakes(", "forgetPersisted(",
    ]

    /// The spellings of the app's own domain as a defaults store.
    static let appDomainSpellings = ["UserDefaults.standard", "UserDefaults = .standard", "defaults: .standard"]

    /// Test files that name the app's domain beside a family ON PURPOSE, each with its reason.
    static let allowedTestFiles: [String: String] = [
        "NoteMemoryDefaultsTests.swift":
            "the seam's own app pins: they READ the real domain's absence of a random key, and "
            + "their defer removes what only a revert (R-U4-H) could have written there",
    ]

    private static func source(_ relative: String) throws -> [String] {
        try String(contentsOf: repoRoot.appendingPathComponent(relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    }

    private static func isComment(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("//") || trimmed.hasPrefix("*")
    }

    /// Every non-comment line under `root` that names the app's domain with a family token on
    /// it or on the next two lines (a call split across lines, a `let defaults = …` above its
    /// key).
    private static func appDomainBesideAFamily(under root: String) throws -> [String] {
        let base = repoRoot.appendingPathComponent(root)
        guard let walker = FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil)
        else { return ["(no such directory: \(root))"] }
        var found: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            if allowedTestFiles[file.lastPathComponent] != nil { continue }
            let relative = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
            let lines = try source(relative)
            for (index, line) in lines.enumerated()
            where !isComment(line) && line.contains("UserDefaults.standard") {
                let window = lines[index..<min(index + 3, lines.count)].filter { !isComment($0) }
                if window.contains(where: { text in familyTokens.contains { text.contains($0) } }) {
                    found.append("\(relative):\(index + 1)")
                }
            }
        }
        return found
    }

    /// **Every home names the seam, and none names the app's domain.**
    @Test func everyHomeNamesTheSeamAndNeverTheAppsDomain() throws {
        for home in Self.homes {
            let lines = try Self.source(home)
            let code = lines.filter { !Self.isComment($0) }
            #expect(code.contains { $0.contains("NoteMemoryDefaults.store") },
                    "\(home) names the seam")
            let offenders = lines.indices.filter { index in
                !Self.isComment(lines[index])
                    && Self.appDomainSpellings.contains { lines[index].contains($0) }
            }
            #expect(offenders.isEmpty,
                    "\(home) names the app's domain at line(s) \(offenders.map { $0 + 1 })")
        }
    }

    /// **No app line reads or writes a family on the app's domain directly** — a new reader
    /// or writer outside the homes would re-open the leak beside the seam.
    @Test func noAppLineTouchesAFamilyOnTheAppsDomain() throws {
        var found: [String] = []
        for root in ["App/Variorum/Variorum", "App/Variorum/Shared"] {
            found += try Self.appDomainBesideAFamily(under: root)
        }
        #expect(found.isEmpty, "a per-note memory on UserDefaults.standard: \(found)")
    }

    /// **The read tier's takes-first question is always asked WITH the seam.** Its declared
    /// default stays the read tier's own (`Features/ReadTier/` is the editor-seam class), so
    /// every call site hands the seam in.
    @Test func theReadTiersTakesFirstQuestionIsAskedWithTheSeam() throws {
        var calls: [String] = []
        var bare: [String] = []
        let base = Self.repoRoot.appendingPathComponent("App/Variorum/Variorum")
        let walker = try #require(FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil))
        for case let file as URL in walker where file.pathExtension == "swift" {
            let relative = file.path.replacingOccurrences(of: Self.repoRoot.path + "/", with: "")
            for (index, line) in try Self.source(relative).enumerated()
            where !Self.isComment(line) && line.contains("holdsTakes(")
                && !line.contains("static func holdsTakes(") {
                calls.append("\(relative):\(index + 1)")
                if !line.contains("defaults: NoteMemoryDefaults.store") { bare.append("\(relative):\(index + 1)") }
            }
        }
        #expect(!calls.isEmpty, "non-vacuity: the app asks the question somewhere")
        #expect(bare.isEmpty, "asked without the seam (it would read the app's domain): \(bare)")
    }

    /// **No test plants, reads or clears a family on the app's domain** — the product reads
    /// the seam, so such a plant would never be read, and every write there lands in the dev
    /// app's real domain (VX-695's class).
    @Test func noTestTouchesAFamilyOnTheAppsDomain() throws {
        let found = try Self.appDomainBesideAFamily(under: "App/Variorum/VariorumTests")
        #expect(found.isEmpty, "a test on UserDefaults.standard for a per-note memory: \(found)")
    }
}
