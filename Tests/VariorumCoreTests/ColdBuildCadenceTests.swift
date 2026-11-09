import Foundation
import Testing

/// **VX-917 (R-940-4) — the cold-build check runs at her cadence.** `.github/workflows/cold-build-check.yml`
/// cold-builds the public repository the way BUILDING.md tells a stranger to. A full cold build is
/// heavy, so it runs only when she says: her words, "I think it should be a check every major version
/// switch or something, it's too onerous for every run." Every release is a version switch, so the
/// triggers are a PUBLISHED RELEASE and a HAND DISPATCH, and nothing else: never a push, a pull
/// request or a schedule. This suite reads the workflow's `on:` block and fails the moment another
/// trigger joins it.
///
/// It also keeps the workflow's toolchain-skew verdict honest (AppSpec §15.6: a result counts only on
/// the primary's Xcode major). The workflow names that major once (`PRIMARY_XCODE_MAJOR`); BUILDING.md
/// states it to strangers ("built and tested with Xcode NN.N"); the two must move together, or the
/// workflow would grade a run against a toolchain the project no longer uses. A runner named for an
/// Xcode image (`runs-on: xcode-NN`) must name the same major.
///
/// No YAML parser ships with Foundation, so the read is textual and deliberately strict: the trigger
/// key must be written once, in block form, at the top level. A flow-style or inline `on:` (which would
/// hide a trigger from a line read) fails with a message saying so. Record:
/// `notes/plans/fixes/vx-940-pre-oss-followups.md` (the W3 record).
@Suite("VX-917 — the cold-build check runs on a published release or a hand dispatch only, graded against BUILDING.md's Xcode")
struct ColdBuildCadenceTests {
    static let repo = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // Tests/VariorumCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // repo root
    static let workflow = ".github/workflows/cold-build-check.yml"

    static func read(_ relative: String) throws -> String {
        try String(contentsOf: repo.appendingPathComponent(relative), encoding: .utf8)
    }

    /// A line that carries YAML content: not blank, not a comment.
    static func isContent(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && !trimmed.hasPrefix("#")
    }

    static func indentation(_ line: String) -> Int {
        line.prefix(while: { $0 == " " }).count
    }

    /// A mapping line's key, quotes stripped (`  "push":` → `push`); nil for a line that is no key.
    static func key(_ line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.hasPrefix("-"), let colon = trimmed.firstIndex(of: ":") else { return nil }
        return String(trimmed[..<colon]).trimmingCharacters(in: CharacterSet(charactersIn: "\"' "))
    }

    /// The indices of the content lines nested under the line at `start` (deeper-indented, up to the
    /// next content line at its indentation or shallower).
    static func children(of start: Int, in lines: [String]) -> [Int] {
        let depth = indentation(lines[start])
        var out: [Int] = []
        for index in lines.indices where index > start && isContent(lines[index]) {
            if indentation(lines[index]) <= depth { break }
            out.append(index)
        }
        return out
    }

    /// The keys directly under a block: its lines at the block's first child's indentation.
    static func directKeys(_ block: [Int], in lines: [String]) -> [(key: String, index: Int)] {
        guard let first = block.first else { return [] }
        let depth = indentation(lines[first])
        return block.filter { indentation(lines[$0]) == depth }.compactMap { index in
            key(lines[index]).map { (key: $0, index: index) }
        }
    }

    @Test func theTriggersAreAPublishedReleaseAndAHandDispatchAndNothingElse() throws {
        let lines = try Self.read(Self.workflow).components(separatedBy: "\n")

        // The trigger key: written once, at the top level, in block form.
        let onLines = lines.indices.filter {
            Self.isContent(lines[$0]) && Self.indentation(lines[$0]) == 0 && Self.key(lines[$0]) == "on"
        }
        #expect(onLines.count == 1, "the workflow names its triggers once, under one top-level `on:` (found \(onLines.count))")
        let start = try #require(onLines.first, "the workflow has a top-level `on:`")
        let onLine = lines[start].trimmingCharacters(in: .whitespaces)
        #expect(onLine == "on:" || onLine == "\"on\":" || onLine == "'on':", """
            `on:` is written in block form with nothing after the colon (read: \(onLine)) — an inline or \
            flow-style trigger list would hide a trigger from this read
            """)

        // Exactly the two triggers her cadence allows.
        let triggers = Self.directKeys(Self.children(of: start, in: lines), in: lines)
        #expect(triggers.map(\.key).sorted() == ["release", "workflow_dispatch"], """
            the cold-build check runs on a published release or a hand dispatch ONLY (R-940-4: "it's too \
            onerous for every run") — never a push, a pull request or a schedule; the `on:` block reads \
            \(triggers.map(\.key))
            """)

        // The release trigger fires on a PUBLISHED release only.
        let release = try #require(triggers.first { $0.key == "release" }, "the `on:` block has a `release:` trigger")
        let typesLines = Self.directKeys(Self.children(of: release.index, in: lines), in: lines)
            .filter { $0.key == "types" }
        #expect(typesLines.count == 1, "the release trigger names its activity types once (found \(typesLines.count))")
        let typesAt = try #require(typesLines.first).index
        // What follows `types:` on its own line, a trailing comment cut off.
        var inline = lines[typesAt].split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            .last.map(String.init) ?? ""
        if let comment = inline.range(of: " #") { inline = String(inline[..<comment.lowerBound]) }
        inline = inline.trimmingCharacters(in: .whitespaces)
        let types: [String]
        if inline.isEmpty {
            // Block-list form: the `- item` lines under `types:`.
            types = Self.children(of: typesAt, in: lines).map {
                lines[$0].trimmingCharacters(in: CharacterSet(charactersIn: "- \"'"))
            }
        } else {
            types = inline.trimmingCharacters(in: CharacterSet(charactersIn: "[] "))
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: " \"'")) }
        }
        #expect(types == ["published"], """
            the release trigger fires when a release is PUBLISHED, and on no other release activity (read: \
            \(types))
            """)
    }

    @Test func theWorkflowGradesARunAgainstTheXcodeBuildingMdNames() throws {
        let workflow = try Self.read(Self.workflow)
        let building = try Self.read("BUILDING.md")

        let declared = try Self.majors(#"(?m)^\s*PRIMARY_XCODE_MAJOR:\s*"?(\d+)"?\s*$"#, in: workflow)
        #expect(declared.count == 1, "the workflow declares PRIMARY_XCODE_MAJOR once (found \(declared))")
        let stated = try Self.majors(#"built and tested with Xcode (\d+)\.\d+"#, in: building)
        #expect(stated.count == 1, "BUILDING.md states the Xcode it is built and tested with once (found \(stated))")

        let workflowMajor = try #require(declared.first)
        let buildingMajor = try #require(stated.first)
        #expect(workflowMajor == buildingMajor, """
            the cold-build check grades its runs against Xcode \(workflowMajor), but BUILDING.md says the \
            project is built and tested with Xcode \(buildingMajor) — change PRIMARY_XCODE_MAJOR in \
            \(Self.workflow) in the same commit (AppSpec §15.6, the toolchain-skew rule)
            """)

        // A runner named for an Xcode image (GitHub's `xcode-NN` labels) names the same major: otherwise
        // every run would be graded a mismatch by construction.
        for image in try Self.majors(#"(?m)^\s*runs-on:\s*xcode-(\d+)\s*$"#, in: workflow) {
            #expect(image == workflowMajor, """
                the workflow runs on GitHub's Xcode \(image) image but grades against Xcode \(workflowMajor) \
                — move `runs-on` with PRIMARY_XCODE_MAJOR
                """)
        }
    }

    static func majors(_ pattern: String, in text: String) throws -> [String] {
        let regex = try NSRegularExpression(pattern: pattern)
        return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap {
            Range($0.range(at: 1), in: text).map { String(text[$0]) }
        }
    }
}
