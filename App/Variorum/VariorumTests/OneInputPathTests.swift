//
//  OneInputPathTests.swift
//  VariorumTests
//
//  **Phase 13u1, UNIT 1 — item 7's guarantee, made checkable.**
//
//  The editor's two-phase protocol arms a verdict at `shouldChangeText` and
//  consumes it at `storageDidEdit`. Written as two statements the pair is
//  separable, and `EditorViewModel.storageDidEdit`'s own comment named the
//  hazard by name since mobile round 2: any of the arm-then-hand-off sites
//  *"is one refactor away from separating an arming from its
//  `replaceCharacters`"*. Item 7 closed that by making the separation
//  unexpressible — `OrdinaryInputEdit.apply` is the one door, and the gate
//  cannot be called without the mutation following it.
//
//  A rule like that lasts exactly as long as someone remembers it, so this
//  is the grep pin that remembers for us — the form `NoLiteralColourTests`
//  established at 18j, allow-list and all: **an entry is cheap to add and
//  impossible to add silently**, which is the whole point.
//
//  THE RULE: AppKit's `shouldChangeText(in:replacementString:)` is called in
//  exactly ONE file of the Mac app.
//

import Foundation
import Testing

@Suite("One input path for the Mac's text edits (13u1 UNIT 1)")
struct OneInputPathTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The ONE door. Nothing else may call AppKit's gate directly.
    ///
    /// There is deliberately no second entry. The two disciplines that used
    /// to justify their own call sites are PARAMETERS of the door now —
    /// `followingCaret` (the checkbox click's Act 10 item 11 carve) and
    /// `underFindReplace` (the find bar's `withFindReplace` bracket) —
    /// because an exemption that lives in an allow-list is a rule with a
    /// footnote, and a parameter is a rule without one.
    private static let allowed: Set<String> = [
        "Variorum/Features/Editor/OrdinaryInputEdit.swift",
    ]

    /// AppKit's own gate, in its call form. Deliberately matched by its
    /// `replacementString:` label so the pin cannot catch either of the two
    /// things that merely read alike: the DELEGATE method
    /// `textView(_:shouldChangeTextIn:replacementString:)` (the other side
    /// of the same protocol — `EditorView` and `PaneSurface` implement it,
    /// which is how the verdict is computed at all), and
    /// `EditorViewModel.shouldChangeText(in:replacement:)`, the model's own
    /// answer that the delegate forwards to.
    private static let gate = try! NSRegularExpression(
        pattern: #"shouldChangeText\(\s*in:[\s\S]{0,300}?replacementString:"#)

    /// The three SOURCE roots — never the whole app folder, which also
    /// holds `DerivedData` (a checked-out package there is not our code and
    /// one of them is a *directory* named `sqlcipher.swift`, which the first
    /// draft of this pin tried to read). Test targets are outside the rule
    /// by the same choice: a pin may drive the gate directly to prove what
    /// the gate itself does.
    private static let roots = ["Shared", "Variorum", "VariorumMobile"]

    @Test func appKitsTextGateIsCalledInExactlyOnePlace() throws {
        let root = Self.appRoot.resolvingSymlinksInPath()
        var urls: [URL] = []
        for source in Self.roots {
            let enumerator = try #require(FileManager.default.enumerator(
                at: root.appendingPathComponent(source), includingPropertiesForKeys: nil))
            for case let url as URL in enumerator where url.pathExtension == "swift" {
                urls.append(url)
            }
        }
        var offenders: [String] = []
        var doorFound = false

        for url in urls {
            // Relative BY COMPONENTS, never by string subtraction: `#filePath`
            // and an enumerated URL can disagree about `/private` on a
            // worktree, which made the first draft's offender list read
            // "/privateVariorum/…".
            let path = url.resolvingSymlinksInPath().pathComponents
                .suffix(from: root.pathComponents.count).joined(separator: "/")
            let source = try String(contentsOf: url, encoding: .utf8)
            let hits = Self.gate.numberOfMatches(
                in: source, range: NSRange(source.startIndex..., in: source))
            guard hits > 0 else { continue }
            if Self.allowed.contains(path) {
                doorFound = true
            } else {
                offenders.append("\(path) (\(hits))")
            }
        }

        #expect(offenders.isEmpty, """
            AppKit's text gate is called outside the one input-path door: \
            \(offenders.sorted().joined(separator: ", ")). \
            Route the edit through `OrdinaryInputEdit.apply` instead — an \
            arming without its mutation is the class item 7 closed.
            """)
        #expect(doorFound, "the door itself moved or was renamed — update the allow-list")
    }
}
