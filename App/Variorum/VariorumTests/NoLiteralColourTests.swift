//
//  NoLiteralColourTests.swift
//  VariorumTests
//
//  18j (her R-Q12) — **the grep pin the dark walk earns.** A literal colour
//  in a voiced surface is the one thing that CANNOT follow an appearance,
//  a voice or a palette: it is the same value on black paper as on white.
//  Every dark defect this batch found was a colour that did not come from
//  the token layer, and the cheapest guarantee that the next one cannot
//  ship is a walk of the source itself.
//
//  P-8 already said it in words (*"feature code never holds a literal
//  color"*, `VoiceTokens`' own header). This makes it fail the suite.
//
//  THE RULE: no `Color(hex:)` and no literal system hue (`.red`, `.orange`,
//  `Color.white`, …) in the Mac app's views — with a NAMED allow-list, each
//  entry carrying the decision that put it there. An allow-list entry is
//  cheap to add and impossible to add silently, which is the point.
//

import Foundation
import Testing

@Suite("No literal colour outside the token layer (18j)")
struct NoLiteralColourTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// Files that may hold a literal colour, each with the decision that
    /// allows it. Nothing else may.
    ///
    /// 1. **The three TK2 fallback CANARY banners** (`EditorView`,
    ///    `ReadPostView`, `PaneSurface`): white on red when TextKit 2
    ///    silently downgrades — TEXTKIT2_NOTES §4's third defensive
    ///    practice. `VoiceControls`' own doc already names them: *"a
    ///    build-integrity alarm aimed at a developer, deliberately the
    ///    loudest thing the app can draw"*. Voicing them would soften a
    ///    signal whose whole job is to be impossible to miss.
    /// 2. **`SharedPageStyle`** — the phone shares it, and it carries a
    ///    recorded decision in its own text: *"Warning/error COLORS stay the
    ///    system semantic ones in both arms — the LK canon has no warning
    ///    token, and honesty outranks palette."* Not 18j's to overturn; the
    ///    system semantics are appearance-adaptive either way.
    /// 3. **`DataSafetyPane`** — its staleness warnings are that same class
    ///    (where the tone IS an alarm the pane already wears `alarmVoice()`).
    /// 4. **`VoiceControls`** — THE chrome vocabulary: where `alarmVoice()`
    ///    and its siblings are defined, and where the canary exemption is
    ///    written down.
    private static let allowed: Set<String> = [
        "Features/Editor/EditorView.swift",
        "Features/ReadTier/ReadPostView.swift",
        "Surface/PaneSurface.swift",
        "Theme/VoiceControls.swift",
        "Features/Settings/DataSafetyPane.swift",
        // 5. **`BlockDecor.swift`'s `CalloutPalette`** — the five callout
        //    names' washes, and the ONE colour home in the app outside
        //    `Shared/Theme` that is legitimately a table of values: it
        //    already carries an explicit DARK arm for every name (R51's
        //    "keep the fully-black room readable"), verified by reading at
        //    18j. Its values are component constructions, not `Color(hex:)`,
        //    so the first check above would have missed it — which is why
        //    the second check below exists and why this entry is named
        //    rather than left to a gap in the grep.
        "Features/Editor/BlockDecor.swift",
    ]

    /// `Shared/Theme/` is the token layer itself (and `SharedPageStyle`'s
    /// home) — the one place a colour VALUE belongs.
    private static let scannedRoots = ["Variorum"]

    private static let hues = [
        "white", "black", "red", "orange", "yellow", "green",
        "blue", "gray", "grey", "purple", "pink", "brown", "mint", "teal",
    ]

    private func swiftFiles(under root: URL) -> [URL] {
        guard let walker = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil) else { return [] }
        return walker.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    /// A line is code (not a comment or a doc line) for this pin's purpose.
    private func isCode(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return !trimmed.hasPrefix("//") && !trimmed.hasPrefix("///") && !trimmed.hasPrefix("*")
    }

    @Test func noViewPaintsALiteralColour() throws {
        var offenders: [String] = []
        var scanned = 0
        for rootName in Self.scannedRoots {
            let root = Self.appRoot.appendingPathComponent(rootName)
            #expect(FileManager.default.fileExists(atPath: root.path), "root missing: \(rootName)")
            for file in swiftFiles(under: root) {
                let relative = file.path.replacingOccurrences(
                    of: root.path + "/", with: "")
                if Self.allowed.contains(relative) { continue }
                scanned += 1
                let source = try String(contentsOf: file, encoding: .utf8)
                for (index, line) in source.split(
                    separator: "\n", omittingEmptySubsequences: false).enumerated()
                where isCode(String(line)) {
                    let text = String(line)
                    if text.contains("Color(hex:") {
                        offenders.append("\(relative):\(index + 1) — Color(hex:)")
                    }
                    // A colour built from COMPONENTS is the same literal
                    // wearing another spelling — and the one the first check
                    // misses (18j: `CalloutPalette` is exactly this shape).
                    for form in ["srgbRed:", "calibratedRed:", "calibratedWhite:",
                                 "NSColor(white:", "NSColor(red:", "UIColor(red:"]
                    where text.contains(form) {
                        offenders.append("\(relative):\(index + 1) — \(form)")
                    }
                    for hue in Self.hues where text.contains("Color.\(hue)") {
                        offenders.append("\(relative):\(index + 1) — Color.\(hue)")
                    }
                    // The modifier forms: `.foregroundStyle(.red)` and friends.
                    for hue in Self.hues {
                        for modifier in [
                            "foregroundStyle", "foregroundColor", "fill",
                            "background", "stroke", "tint",
                        ] where text.contains("\(modifier)(.\(hue))") {
                            offenders.append("\(relative):\(index + 1) — .\(modifier)(.\(hue))")
                        }
                    }
                }
            }
        }
        #expect(scanned > 100, "the walk must actually reach the app's views (\(scanned) files)")
        #expect(offenders.isEmpty, """
            A literal colour cannot follow an appearance, a voice or a palette — \
            it is the same value on black paper as on white (P-8; 18j's dark walk). \
            Use a `VoiceTokens` slot, or `.alarmVoice()` / `.positiveVoice()` where \
            the host holds no tokens. If the literal is genuinely right, add the \
            file to this pin's allow-list WITH the decision that allows it.
            \(offenders.joined(separator: "\n"))
            """)
    }

    /// The token layer holds the values, and it holds them in ONE place: no
    /// hex may appear in the Mac app's views even inside a comment-free
    /// helper. (Stated separately so the message is specific when it fires.)
    @Test func theHexValuesLiveOnlyInTheSharedTokenLayer() throws {
        let shared = Self.appRoot.appendingPathComponent("Shared/Theme")
        let files = swiftFiles(under: shared).map { $0.lastPathComponent }
        #expect(files.contains("VoiceTokens.swift"))
        #expect(files.contains("PaletteDerivation.swift"))
    }
}
