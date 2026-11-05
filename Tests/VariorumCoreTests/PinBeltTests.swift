import Foundation
import Testing

/// VX-781 — THE PIN BELT's static guard (ladder round 1, R1-1).
///
/// A lockfile holds the dependency set only while a resolution reads it. A pin-free resolution
/// (a missing lockfile, a package update) takes the top of every range, and the ranges GRDB,
/// swift-dependencies and the MCP SDK declare float SQLCipher to 4.20 and more. So the set is
/// enforced by EXACT declarations where each graph's ROOT reads them:
/// - `Package.swift` for the CLI graph (`swift build` / `swift test`: this package is the root);
/// - `project.pbxproj`'s `XCRemoteSwiftPackageReference` entries for the apps: EVERY remote package
///   in the app graph. In the Xcode workspace this package is a LOCAL DEPENDENCY, and SwiftPM keeps
///   one of its declarations only when a target of a product the app links uses it (record E10;
///   ladder round 2, R2-1), so the project, the Xcode graph's root, declares them all. One rule,
///   no reachability analysis.
///
/// These tests read the four files and fail when a declaration goes missing, floats, points at
/// another repository, or disagrees with the lockfiles. That covers a reference deleted as "unused", a one-sided bump,
/// and lockfiles that disagree. No network, no build; the deep, networked proof is
/// `Tools/pins-belt-check`. Record: notes/plans/fixes/vx-781-lockfile-pins.md.
@Suite("VX-781 — the pin belt: every resolved package is declared EXACT where its graph's root reads it (no network)")
struct PinBeltTests {
    struct Pin: Equatable, CustomStringConvertible {
        let location: String
        let version: String
        let revision: String
        var description: String { "\(version) (\(revision.prefix(7))) at \(location)" }
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
    static func manifestRequirements() throws -> (exact: [String: String], floating: [String], named: [String: String]) {
        let manifest = try read("Package.swift")
        var exact: [String: String] = [:]
        var floating: [String] = []
        var named: [String: String] = [:]  // identity → URL
        for m in try matches(#"\.package\(\s*url:\s*"([^"]+)"\s*,\s*([^)]*)\)"#, in: manifest) {
            let requirement = m[2].trimmingCharacters(in: .whitespacesAndNewlines)
            named[identity(ofURL: m[1])] = m[1]
            if let v = try matches(#"^exact:\s*"([^"]+)"$"#, in: requirement).first {
                exact[identity(ofURL: m[1])] = v[1]
            } else {
                floating.append("\(m[1]) — \(requirement)")
            }
        }
        return (exact, floating, named)
    }

    /// The same repository, spelled either way: case and a trailing `.git` / `/` ignored.
    static func sameLocation(_ a: String, _ b: String) -> Bool {
        func norm(_ s: String) -> String {
            var t = s.lowercased()
            while t.hasSuffix("/") { t.removeLast() }
            if t.hasSuffix(".git") { t.removeLast(4) }
            return t
        }
        return norm(a) == norm(b)
    }

    /// The project's remote package references: identity → (requirement kind, version, URL).
    /// Xcode quotes a version with build metadata (`"7.11.1+sqlcipher.1"`); the quotes are stripped.
    static func projectReferences() throws -> (refs: [String: (kind: String, version: String, url: String)], count: Int) {
        let project = try read(pbxproj)
        var refs: [String: (kind: String, version: String, url: String)] = [:]
        let blocks = try matches(
            #"isa = XCRemoteSwiftPackageReference;\s*repositoryURL = "([^"]+)";\s*requirement = \{([^}]*)\};"#,
            in: project)
        for b in blocks {
            let kind = try matches(#"kind = (\w+);"#, in: b[2]).first?[1] ?? "(none)"
            let raw = try matches(#"\bversion = ([^;]+);"#, in: b[2]).first?[1] ?? "(none)"
            let version = raw.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            refs[identity(ofURL: b[1])] = (kind, version, b[1])
        }
        let count = try matches(#"isa = XCRemoteSwiftPackageReference;"#, in: project).count
        return (refs, count)
    }

    @Test("(1) every CLI-graph pin is declared exact in Package.swift, and nothing there floats")
    func everyRootPinIsDeclaredExactInPackageSwift() throws {
        let (exact, floating, named) = try Self.manifestRequirements()
        #expect(floating.isEmpty, "Package.swift requirements that FLOAT (a pin-free resolution moves them): \(floating)")
        let rootPins = try Self.pins(Self.rootLockfile)
        var problems: [String] = []
        for (identity, pin) in rootPins.sorted(by: { $0.key < $1.key }) {
            switch exact[identity] {
            case nil: problems.append("\(identity) \(pin): no `exact:` line in Package.swift")
            case let v? where v != pin.version: problems.append("\(identity): Package.swift exact \(v) ≠ root lockfile \(pin)")
            default: break
            }
        }
        // The other direction: every declaration resolves to a pin AT THE SAME REPOSITORY.
        for (identity, url) in named.sorted(by: { $0.key < $1.key }) {
            if let pin = rootPins[identity] {
                if !Self.sameLocation(url, pin.location) {
                    problems.append("\(identity): Package.swift points at \(url), the root lockfile at \(pin.location)")
                }
            } else {
                problems.append("\(identity): declared in Package.swift (\(url)) but not in the root lockfile")
            }
        }
        #expect(problems.isEmpty, "the CLI belt is broken: \(problems)")
    }

    @Test("(2) every app-graph pin is declared exact where Xcode reads it: an exactVersion project reference at the same repository")
    func everyAppPinIsDeclaredExactWhereXcodeReadsIt() throws {
        let (refs, blockCount) = try Self.projectReferences()
        #expect(refs.count == blockCount,
                "project.pbxproj has \(blockCount) XCRemoteSwiftPackageReference entries but only \(refs.count) read as repositoryURL + requirement")
        let floatingRefs = refs.filter { $0.value.kind != "exactVersion" }.map { "\($0.key) — \($0.value.kind)" }
        #expect(floatingRefs.isEmpty, "project package references that are not exactVersion: \(floatingRefs)")
        let appPins = try Self.pins(Self.workspaceLockfile)
        var problems: [String] = []
        for (identity, pin) in appPins.sorted(by: { $0.key < $1.key }) {
            if let ref = refs[identity] {
                if ref.kind != "exactVersion" || ref.version != pin.version {
                    problems.append("\(identity): project reference \(ref.kind) \(ref.version) ≠ workspace lockfile \(pin)")
                }
            } else {
                problems.append("\(identity) \(pin): no exactVersion project reference — Xcode would let it float")
            }
        }
        // The other direction: every reference resolves to a pin AT THE SAME REPOSITORY.
        for (identity, ref) in refs.sorted(by: { $0.key < $1.key }) {
            if let pin = appPins[identity] {
                if !Self.sameLocation(ref.url, pin.location) {
                    problems.append("\(identity): the project points at \(ref.url), the workspace lockfile at \(pin.location)")
                }
            } else {
                problems.append("\(identity): a project reference (\(ref.url)) with no workspace lockfile pin")
            }
        }
        #expect(problems.isEmpty, "the app belt is broken: \(problems)")
    }

    @Test("(3) the two lockfiles hold ONE set: the CLI pins are the app pins minus the project-only references")
    func theTwoLockfilesHoldOneSet() throws {
        let rootPins = try Self.pins(Self.rootLockfile)
        let appPins = try Self.pins(Self.workspaceLockfile)
        let projectOnly = Set(try Self.projectReferences().refs.keys)
            .subtracting(try Self.manifestRequirements().named.keys)
        var problems: [String] = []
        for (identity, pin) in appPins.sorted(by: { $0.key < $1.key }) where !projectOnly.contains(identity) {
            if let r = rootPins[identity] {
                // Version and revision exactly; the location as (1) and (2) compare it — the same
                // repository, either spelling (a `.git` or case flip is bookkeeping, VX-853).
                if r.version != pin.version || r.revision != pin.revision
                    || !Self.sameLocation(r.location, pin.location) {
                    problems.append("\(identity): root \(r) ≠ workspace \(pin)")
                }
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
