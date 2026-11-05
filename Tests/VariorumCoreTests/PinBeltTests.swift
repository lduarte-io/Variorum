import Foundation
import Testing

/// VX-781 — THE PIN BELT's static guard (ladder round 1, R1-1).
///
/// A lockfile holds the dependency set only while a resolution reads it. A pin-free resolution
/// (a missing lockfile, a package update) takes the top of every range, and the ranges GRDB,
/// swift-dependencies and the MCP SDK declare float SQLCipher to 4.20 and more. So the set is
/// enforced by EXACT declarations where each graph's ROOT reads them:
/// - `Package.swift` for the CLI graph (`swift build` / `swift test`: this package is the root);
/// - `project.pbxproj`'s `XCRemoteSwiftPackageReference` entries for the apps. In the Xcode
///   workspace this package is a LOCAL DEPENDENCY and SwiftPM prunes its unused declarations,
///   so only its direct, USED requirements count there (record E10).
///
/// These tests read the four files and fail when a declaration goes missing, floats, or
/// disagrees with the lockfiles. That covers a reference deleted as "unused", a one-sided bump,
/// and lockfiles that disagree. No network, no build; the deep, networked proof is
/// `Tools/pins-belt-check`. Record: notes/plans/fixes/vx-781-lockfile-pins.md.
@Suite("VX-781 — the pin belt: every resolved package is declared EXACT where its graph's root reads it (no network)")
struct PinBeltTests {
    struct Pin: Equatable, CustomStringConvertible {
        let location: String
        let version: String
        let revision: String
        var description: String { "\(version) (\(revision.prefix(7)))" }
    }

    static let repo = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // Tests/VariorumCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // repo root
    static let rootLockfile = "Package.resolved"
    static let workspaceLockfile =
        "App/Variorum/Variorum.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    static let pbxproj = "App/Variorum/Variorum.xcodeproj/project.pbxproj"

    static func read(_ relative: String) throws -> String {
        try String(contentsOf: repo.appendingPathComponent(relative), encoding: .utf8)
    }

    /// identity → pin, from a Package.resolved (v2/v3 shape: `pins[].identity/location/state`).
    static func pins(_ relative: String) throws -> [String: Pin] {
        let data = Data(try read(relative).utf8)
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let list = try #require(object["pins"] as? [[String: Any]])
        var out: [String: Pin] = [:]
        for entry in list {
            let identity = try #require(entry["identity"] as? String)
            let state = try #require(entry["state"] as? [String: Any])
            out[identity] = Pin(
                location: entry["location"] as? String ?? "",
                version: state["version"] as? String ?? "(no version)",
                revision: state["revision"] as? String ?? "")
        }
        return out
    }

    /// SwiftPM's identity for a remote URL: the last path component, minus `.git`, lowercased.
    static func identity(ofURL url: String) -> String {
        var last = url.split(separator: "/").last.map(String.init) ?? url
        if last.hasSuffix(".git") { last.removeLast(4) }
        return last.lowercased()
    }

    static func matches(_ pattern: String, in text: String) throws -> [[String]] {
        let regex = try NSRegularExpression(pattern: pattern)
        return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).map { m in
            (0..<m.numberOfRanges).map { i in
                Range(m.range(at: i), in: text).map { String(text[$0]) } ?? ""
            }
        }
    }

    /// Package.swift's remote requirements: identity → the `exact:` version, every line that is
    /// NOT `exact:` (a range or a branch floats), and every identity it names at all.
    static func manifestRequirements() throws -> (exact: [String: String], floating: [String], named: Set<String>) {
        let manifest = try read("Package.swift")
        var exact: [String: String] = [:]
        var floating: [String] = []
        var named: Set<String> = []
        for m in try matches(#"\.package\(\s*url:\s*"([^"]+)"\s*,\s*([^)]*)\)"#, in: manifest) {
            let requirement = m[2].trimmingCharacters(in: .whitespacesAndNewlines)
            named.insert(identity(ofURL: m[1]))
            if let v = try matches(#"^exact:\s*"([^"]+)"$"#, in: requirement).first {
                exact[identity(ofURL: m[1])] = v[1]
            } else {
                floating.append("\(m[1]) — \(requirement)")
            }
        }
        return (exact, floating, named)
    }

    /// Packages a Package.swift TARGET uses (`.product(name:package:)`): the only declarations
    /// of this package that the Xcode graph does not prune.
    static func manifestUsedPackages() throws -> Set<String> {
        let manifest = try read("Package.swift")
        let used = try matches(#"\.product\(\s*name:\s*"[^"]+"\s*,\s*package:\s*"([^"]+)"\s*\)"#,
                               in: manifest)
        return Set(used.map { $0[1].lowercased() })
    }

    /// The project's remote package references: identity → (requirement kind, version).
    static func projectReferences() throws -> (refs: [String: (kind: String, version: String)], count: Int) {
        let project = try read(pbxproj)
        var refs: [String: (kind: String, version: String)] = [:]
        let blocks = try matches(
            #"isa = XCRemoteSwiftPackageReference;\s*repositoryURL = "([^"]+)";\s*requirement = \{([^}]*)\};"#,
            in: project)
        for b in blocks {
            let kind = try matches(#"kind = (\w+);"#, in: b[2]).first?[1] ?? "(none)"
            let version = try matches(#"\bversion = ([^;]+);"#, in: b[2]).first?[1] ?? "(none)"
            refs[identity(ofURL: b[1])] = (kind, version)
        }
        let count = try matches(#"isa = XCRemoteSwiftPackageReference;"#, in: project).count
        return (refs, count)
    }

    @Test("(1) every CLI-graph pin is declared exact in Package.swift, and nothing there floats")
    func everyRootPinIsDeclaredExactInPackageSwift() throws {
        let (exact, floating, _) = try Self.manifestRequirements()
        #expect(floating.isEmpty, "Package.swift requirements that FLOAT (a pin-free resolution moves them): \(floating)")
        var problems: [String] = []
        for (identity, pin) in try Self.pins(Self.rootLockfile).sorted(by: { $0.key < $1.key }) {
            switch exact[identity] {
            case nil: problems.append("\(identity) \(pin): no `exact:` line in Package.swift")
            case let v? where v != pin.version: problems.append("\(identity): Package.swift exact \(v) ≠ root lockfile \(pin)")
            default: break
            }
        }
        #expect(problems.isEmpty, "the CLI belt is broken: \(problems)")
    }

    @Test("(2) every app-graph pin is declared exact where Xcode reads it: a project reference, or a direct requirement a target uses")
    func everyAppPinIsDeclaredExactWhereXcodeReadsIt() throws {
        let (refs, blockCount) = try Self.projectReferences()
        #expect(refs.count == blockCount,
                "project.pbxproj has \(blockCount) XCRemoteSwiftPackageReference entries but only \(refs.count) read as repositoryURL + requirement")
        let floatingRefs = refs.filter { $0.value.kind != "exactVersion" }.map { "\($0.key) — \($0.value.kind)" }
        #expect(floatingRefs.isEmpty, "project package references that are not exactVersion: \(floatingRefs)")
        let (exact, _, _) = try Self.manifestRequirements()
        let used = try Self.manifestUsedPackages()
        var problems: [String] = []
        for (identity, pin) in try Self.pins(Self.workspaceLockfile).sorted(by: { $0.key < $1.key }) {
            if let ref = refs[identity] {
                if ref.kind != "exactVersion" || ref.version != pin.version {
                    problems.append("\(identity): project reference \(ref.kind) \(ref.version) ≠ workspace lockfile \(pin)")
                }
            } else if used.contains(identity), let v = exact[identity] {
                if v != pin.version {
                    problems.append("\(identity): Package.swift exact \(v) ≠ workspace lockfile \(pin)")
                }
            } else {
                problems.append("\(identity) \(pin): no exact project reference, and not a used direct exact requirement — Xcode would let it float")
            }
        }
        #expect(problems.isEmpty, "the app belt is broken: \(problems)")
    }

    @Test("(3) the two lockfiles hold ONE set: the CLI pins are the app pins minus the project-only references")
    func theTwoLockfilesHoldOneSet() throws {
        let rootPins = try Self.pins(Self.rootLockfile)
        let appPins = try Self.pins(Self.workspaceLockfile)
        let projectOnly = Set(try Self.projectReferences().refs.keys)
            .subtracting(try Self.manifestRequirements().named)
        var problems: [String] = []
        for (identity, pin) in appPins.sorted(by: { $0.key < $1.key }) where !projectOnly.contains(identity) {
            if let r = rootPins[identity] {
                if r != pin { problems.append("\(identity): root \(r) ≠ workspace \(pin)") }
            } else {
                problems.append("\(identity): in the workspace lockfile (\(pin)) but not the root one")
            }
        }
        for identity in rootPins.keys.sorted() where appPins[identity] == nil {
            problems.append("\(identity): in the root lockfile but not the workspace one")
        }
        #expect(problems.isEmpty, "the lockfiles disagree (project-only, not expected in the root: \(projectOnly.sorted())): \(problems)")
    }
}
