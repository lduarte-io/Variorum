//
//  ChromeLineLimitTests.swift
//  VariorumTests
//
//  13u4 UNIT S3 — **R-13u4-5's grep pin, on the 18j literal-colour pin's
//  own form.** The constitution's P-8 says *"Chrome `fixedSize` texts
//  always carry a `lineLimit`"*, with no exception; the 17o c/d/e ladder
//  measured the tree against it and found 27 of 35 sites carrying none
//  (KnownIssues row 44). Her ruling was to SWEEP rather than to narrow the
//  rule — and a sweep with no pin behind it is enforced *"at whatever rate
//  a ladder happens to grep"*, which is the reviewer's own words for why
//  the row existed. This makes the class fail the suite instead.
//
//  **The hazard the rule is made of** (b6dae25, the wedged window, and the
//  reason the sweep is worth the noise): a text with no line limit measures
//  ONE CHARACTER PER LINE under a window's near-zero-width minimum-size
//  probe — ~140 characters of guidance measured 1693 pt — and a
//  `fixedSize` hands that ideal straight to the layout. That number became
//  the window's own minimum: taller than the screen, pinned to the menu
//  bar, undraggable, every bottom bar below the fold.
//
//  **THE RULE, exactly:** every BARE `.fixedSize()` in the Mac app's own
//  sources states a line policy within the four lines above it or on its
//  own line. `.lineLimit(1)` is the usual answer (a chrome label is one
//  line); `.lineLimit(nil)` is the deliberate UNLIMITED answer and satisfies
//  this pin on purpose — it says *"prose whose point must not fall off the
//  end"* out loud, which is the thing the rule actually wants (UNIT S1's
//  four `nil`s with their reasons at the line are the precedent).
//
//  **SCOPE, stated so the next reader does not mistake it for wider:** the
//  BARE `.fixedSize()` — the 35-site class the ladder counted and the 27 the
//  row named. The `fixedSize(horizontal:vertical:)` form — which is the
//  b6dae25 defect's own spelling — is deliberately NOT swept here: it is the
//  WRAPPING form, the one a paragraph of prose wants, and a blanket limit on
//  it would truncate sentences (`CalmSectionHeader`'s own note is the
//  precedent). That form keeps the defence it already has: `ErrorCauseNote`'s
//  load-bearing limits and `ChromeMinHeightTests`, which probes the real
//  non-scrolling window chrome at width 1. The honest remainder is recorded
//  in the UNIT S3 RECORD's conformance list rather than implied closed here.
//

import Foundation
import Testing

@Suite("Chrome fixedSize sites state a line policy (P-8, R-13u4-5)")
struct ChromeLineLimitTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The Mac app's own sources. `Shared/` is the phone's too and its
    /// `fixedSize` sites are all the wrapping form (the auth/encryption
    /// pages' prose), which this pin's scope note excludes by construction.
    private static let scannedRoots = ["Variorum"]

    /// How far above a site a policy may be stated. Four lines — the ladder's
    /// own measuring window, kept so this pin and the finding that produced
    /// it are answering the same question.
    private static let window = 4

    private func swiftFiles(under root: URL) -> [URL] {
        guard let walker = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil) else { return [] }
        return walker.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    /// A line is code (not a comment) for this pin's purpose — the literal-
    /// colour pin's own helper, and it matters here because this file and
    /// several swept sites QUOTE `.fixedSize()` in their prose.
    private func isCode(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return !trimmed.hasPrefix("//") && !trimmed.hasPrefix("///") && !trimmed.hasPrefix("*")
    }

    @Test func everyBareFixedSizeStatesItsLinePolicy() throws {
        var offenders: [String] = []
        var sites = 0
        for rootName in Self.scannedRoots {
            let root = Self.appRoot.appendingPathComponent(rootName)
            #expect(FileManager.default.fileExists(atPath: root.path), "root missing: \(rootName)")
            for file in swiftFiles(under: root) {
                let relative = file.path.replacingOccurrences(of: root.path + "/", with: "")
                let source = try String(contentsOf: file, encoding: .utf8)
                let lines = source.split(separator: "\n", omittingEmptySubsequences: false)
                    .map(String.init)
                for (index, line) in lines.enumerated()
                where isCode(line) && line.contains(".fixedSize()") {
                    sites += 1
                    let from = max(0, index - Self.window)
                    let stated = lines[from...index].contains { $0.contains("lineLimit(") }
                    if !stated {
                        offenders.append(
                            "\(relative):\(index + 1) — \(line.trimmingCharacters(in: .whitespaces))")
                    }
                }
            }
        }
        // The walk must actually reach the app's chrome: the swept class was
        // 45 sites on the day it was swept, and a number that collapses means
        // the walk broke, not that the app stopped using `fixedSize`.
        #expect(sites > 30, "the walk must reach the app's chrome (\(sites) sites)")
        #expect(offenders.isEmpty, """
            P-8: a chrome `fixedSize` text always carries a `lineLimit`. \
            With no limit the text's IDEAL size is measured under whatever \
            width the layout is probing — one character per line at a \
            window's minimum-size probe — and `fixedSize` hands that ideal \
            straight through (b6dae25: a 1693-pt window minimum, taller than \
            the screen). Add `.lineLimit(1)` for a label, or `.lineLimit(nil)` \
            WITH the reason at the line where the text is prose whose point \
            must not fall off the end.
            \(offenders.joined(separator: "\n"))
            """)
    }
}
