//
//  MarkdownPaletteWritersTests.swift
//  VariorumTests
//
//  18k UNIT C4 — **the one NON-DEBUG global the health review asked to
//  guard** (post-13u review §5.2): `MarkdownStyling.palette`, the markdown
//  face's live colours, has THREE writers — the shell, the full-document
//  editor's chrome application, and a pane's `updateNSView` (`applyFace`,
//  "the third writer of that global"). One global is harmless ONLY while
//  every writer resolves the same value, and they do today because
//  appearance is app-wide (the voice and palette are synced settings; the
//  light/dark choice is `NSApp.appearance`, set in one place). The day
//  anything about the face is per-window, the three race. The invariant is
//  written at the declaration (`MarkdownStyling.palette`'s doc); this makes
//  it fail the suite — the 18j `NoLiteralColourTests` form, a walk of the
//  source itself.
//
//  No behaviour is pinned or changed here: three arms, each a fact about
//  the source that the invariant rests on.
//

import Foundation
import Testing

@Suite("MarkdownStyling.palette keeps its three writers on the one road (18k UNIT C4)")
struct MarkdownPaletteWritersTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum")
    }

    /// Every code line (comments and doc lines skipped) of every Swift file
    /// in the Mac app, with its path relative to `Variorum/`.
    private func codeLines() throws -> [(file: String, line: Int, text: String)] {
        let root = Self.appRoot
        guard let walker = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil) else { return [] }
        var lines: [(String, Int, String)] = []
        for case let url as URL in walker where url.pathExtension == "swift" {
            let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
            let source = try String(contentsOf: url, encoding: .utf8)
            for (index, raw) in source.split(
                separator: "\n", omittingEmptySubsequences: false).enumerated() {
                let text = raw.trimmingCharacters(in: .whitespaces)
                if text.hasPrefix("//") || text.hasPrefix("*") { continue }
                lines.append((relative, index + 1, text))
            }
        }
        return lines
    }

    /// ARM ONE — **exactly three writers, each writing what it wrote when
    /// the invariant was stated.** A fourth writer, or a writer whose value
    /// no longer comes from the tokens, fails here with its file and line.
    @Test func theGlobalPaletteHasExactlyItsThreeWriters() throws {
        let lines = try codeLines()
        #expect(lines.count > 10_000, "the walk read the app: \(lines.count) code lines")
        let writers = lines.filter {
            $0.text.range(of: #"MarkdownStyling\.palette\s*=[^=]"#, options: .regularExpression) != nil
                || ($0.text.contains("storedPalette =") && $0.file != "Theme/MarkdownStyling.swift")
        }
        let found = Set(writers.map { "\($0.file): \($0.text)" })
        let expected: Set<String> = [
            "RootView.swift: MarkdownStyling.palette = MarkdownStyling.Palette(tokens: theme.tokens(for: scheme))",
            "Theme/EditorTypography.swift: MarkdownStyling.palette = MarkdownStyling.Palette(tokens: chrome.tokens)",
            "Surface/PaneSurface.swift: MarkdownStyling.palette = face",
        ]
        #expect(found == expected, """
            MarkdownStyling.palette's writers changed — read its doc before adding one (a per-window \
            writer turns the global into a race). Now: \(writers.map { "\($0.file):\($0.line) \($0.text)" })
            """)
    }

    /// ARM TWO — **every palette is built on the one road.** The pane's
    /// `face` (what writer 3 writes) is built at ONE site, from the host's
    /// tokens, and handed to the ONE representable; no other construction
    /// of a `MarkdownStyling.Palette` exists outside its own file.
    @Test func everyPaletteIsBuiltFromTheTokens() throws {
        let lines = try codeLines()
        let constructions = lines.filter {
            $0.text.contains("MarkdownStyling.Palette(") || $0.text.contains("Palette(marker:")
        }
        let outsideItsFile = constructions.filter { $0.file != "Theme/MarkdownStyling.swift" }
        #expect(outsideItsFile.allSatisfy { $0.text.contains("MarkdownStyling.Palette(tokens:") },
                "a palette built some other way: \(outsideItsFile.map { "\($0.file):\($0.line) \($0.text)" })")
        let paneFaces = lines.filter {
            $0.file == "Surface/PaneSurface.swift" && $0.text.hasPrefix("face:")
        }
        #expect(paneFaces.map(\.text) == ["face: tokens.map { MarkdownStyling.Palette(tokens: $0) },"],
                "the pane's face is built from its host's tokens, at one site: \(paneFaces.map(\.text))")
        let representables = lines.filter { $0.text.contains("PaneSurfaceRepresentable(") }
        #expect(representables.map(\.file) == ["Surface/PaneSurface.swift"],
                "no composer hands a pane a face of its own: \(representables.map { "\($0.file):\($0.line)" })")
    }

    /// ARM THREE — **the precondition: appearance is app-wide.** The
    /// light/dark choice becomes an `NSAppearance` in exactly one file
    /// (`AppearanceChoice`, which sets `NSApp.appearance`), and no view
    /// overrides the colour scheme for its own subtree. Either change makes
    /// a window's `scheme` — writer 1's input — something another window's
    /// writer does not share.
    @Test func appearanceIsAppWide() throws {
        let lines = try codeLines()
        let namedAppearances = lines.filter {
            $0.text.contains("NSAppearance(named") || $0.text.contains("NSAppearance.init(named")
        }
        #expect(Set(namedAppearances.map(\.file)) == ["Theme/AppearanceChoice.swift"],
                "an appearance applied somewhere other than the app's one owner: \(namedAppearances.map { "\($0.file):\($0.line) \($0.text)" })")
        let overrides = lines.filter {
            $0.text.contains("preferredColorScheme(")
                || $0.text.range(of: #"environment\(\\\.colorScheme"#, options: .regularExpression) != nil
        }
        #expect(overrides.isEmpty,
                "a per-view colour-scheme override: \(overrides.map { "\($0.file):\($0.line) \($0.text)" })")
    }
}
