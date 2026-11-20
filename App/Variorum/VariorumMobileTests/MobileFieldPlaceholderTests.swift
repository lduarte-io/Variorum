//
//  MobileFieldPlaceholderTests.swift
//  VariorumMobileTests
//
//  VM-47 (the run's one walk, finding W-A10) — **A PHONE FIELD'S PLACEHOLDER
//  IS THE CORRECTED FAINT, NEVER iOS'S OWN GREY.** The walk measured the
//  Library search field's "Search notes, books…" at #C5C5C7 on white
//  (1.72:1) and #515858 on the dark paper (2.45:1) — the system's placeholder
//  grey, under the sheet's §D floor for a placeholder (3:1), while the box's
//  hint beside it, a placeholder too, wore the corrected faint.
//
//  THE MECHANISM: `phoneField` (the phone's one field) sets the typed text's
//  role and ink, but a SwiftUI field built `TextField(title, text:)` hands its
//  title to iOS as the placeholder, drawn in the system's grey; no modifier
//  outside the field reaches it. The fix gives the placeholder as the field's
//  `prompt:` in the corrected faint — the layer's
//  `TextField(phonePlaceholder:text:tokens:)` at the sites that build a field,
//  and, for the shared secret field that builds its own two fields inside
//  (`PeekableSecretField` — every passphrase and twelve-words field on the
//  phone), the ink `phoneField` now hands down (`phoneFieldPrompt`).
//
//  THE PINS read the placeholder's rendered ink off the real field's pixels,
//  against the field's own paper: the Library's search in both voices, light
//  and dark, and a secret field under `phoneField` — each at least 3:1, red
//  on old (1.7–2.5:1). And a source rule: every phone field that wears
//  `phoneField` is built with its placeholder (red on old: the search, the tag
//  field and Create Book's name).
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// The first text field in a view tree (SwiftUI's single-line `TextField` and
/// `SecureField` render through a `UITextField`).
@MainActor
private func textField(in view: UIView) -> UITextField? {
    if let field = view as? UITextField { return field }
    for sub in view.subviews {
        if let found = textField(in: sub) { return found }
    }
    return nil
}

@MainActor
@Suite("VM-47 W-A10 — a phone field's placeholder clears 3:1 (rendered)", .serialized)
struct MobileFieldPlaceholderRenderedTests {
    /// Sheet §D's floor for a placeholder.
    static let floor = 3.0

    private func tokens(_ voice: ThemeVoice, dark: Bool) -> VoiceTokens {
        var settings = MobileShellRouter.placeholder
        settings.voice = voice
        return .resolve(settings: settings, dark: dark)
    }

    /// The placeholder's ink against the field's ground, read inside the
    /// field's own frame (its edge and its neighbours outside it).
    private func placeholderContrast<V: View>(
        _ surface: SceneHostedSurface<V>, sourceLocation: SourceLocation = #_sourceLocation
    ) throws -> (ratio: Double, ink: PixelColor, ground: PixelColor) {
        let field = try #require(textField(in: surface.host.view), "no text field was rendered",
                                 sourceLocation: sourceLocation)
        #expect((field.text ?? "").isEmpty, "the field is empty, so its placeholder shows",
                sourceLocation: sourceLocation)
        let frame = field.convert(field.bounds, to: surface.window)
        let pixels = try surface.render(sourceLocation: sourceLocation)
        let read = try #require(pixels.inkAndGround(in: frame.insetBy(dx: 1, dy: 1)),
                                "no placeholder drawn in the field (frame \(frame))",
                                sourceLocation: sourceLocation)
        return (read.ink.contrast(with: read.ground), read.ink, read.ground)
    }

    /// **The Library's search field** — the walk's own measurement.
    @Test(arguments: [ThemeVoice.study, .terminal], [false, true])
    func theLibrarySearchsPlaceholderClearsTheFloor(voice: ThemeVoice, dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let shelf = MobileShelfViewModel(session: session)
            let observing = Task { await shelf.start() }
            defer { observing.cancel() }
            let library = MobileLibraryView(
                model: MobileLibraryViewModel(session: session),
                scraps: MobileScrapsModel(session: session),
                stars: MobileStarsModel(session: session), books: shelf,
                tokens: tokens(voice, dark: dark), tabBar: { EmptyView() },
                onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            try await withSceneSurface(library, dark: dark) { surface in
                await surface.settle(30)
                let read = try placeholderContrast(surface)
                print("PERF[sim] VM-47 W-A10 search placeholder \(voice) dark \(dark): \(read.ink) on \(read.ground) = \(read.ratio)")
                #expect(read.ratio >= Self.floor,
                        "\(voice) dark \(dark): the placeholder reads \(String(format: "%.2f", read.ratio)):1 (\(read.ink) on \(read.ground))")
            }
        }
    }

    /// **A secret field** — the shared concealing field every passphrase and
    /// twelve-words entry on the phone is, under the phone's field.
    @Test(arguments: [false, true])
    func aSecretFieldsPlaceholderClearsTheFloor(dark: Bool) async throws {
        let tokens = tokens(.study, dark: dark)
        let field = PeekableSecretField(label: "Passphrase", text: .constant(""))
            .phoneField(tokens)
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(tokens.room)
        try await withSceneSurface(field, dark: dark) { surface in
            await surface.settle(20)
            let read = try placeholderContrast(surface)
            #expect(read.ratio >= Self.floor,
                    "dark \(dark): the secret field's placeholder reads \(String(format: "%.2f", read.ratio)):1 (\(read.ink) on \(read.ground))")
        }
    }
}

@Suite("VM-47 W-A10 — every phone field gives its placeholder (source rule)")
struct MobileFieldPlaceholderSourceTests {
    private static var phoneRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("VariorumMobile")
    }

    /// A `TextField(` or `SecureField(` whose chain wears `.phoneField(` within
    /// the next few lines must be built with its placeholder
    /// (`phonePlaceholder:` or an explicit `prompt:`), or iOS draws the title
    /// in its own grey.
    @Test func everyPhoneFieldIsBuiltWithItsPlaceholder() throws {
        let walker = try #require(FileManager.default.enumerator(
            at: Self.phoneRoot, includingPropertiesForKeys: nil))
        var fields = 0
        var offenders: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            let relative = file.path.replacingOccurrences(of: Self.phoneRoot.path + "/", with: "")
            if MobileSourceRuleScope.exempts(relative) { continue }  // the debug harnesses (7b.7)
            let lines = try String(contentsOf: file, encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
                .map { line -> String in
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    return trimmed.hasPrefix("//") || trimmed.hasPrefix("*") ? "" : line
                }
            for (index, line) in lines.enumerated()
            where line.contains("TextField(") || line.contains("SecureField(") {
                let chain = lines[index ..< min(index + 6, lines.count)].joined(separator: "\n")
                guard chain.contains(".phoneField(") else { continue }
                fields += 1
                if !(chain.contains("phonePlaceholder:") || chain.contains("prompt:")) {
                    offenders.append("\(relative):\(index + 1)")
                }
            }
        }
        #expect(fields >= 3, "the walk must find the phone's fields (\(fields))")
        #expect(offenders.isEmpty, """
            A phone field leaves its placeholder to iOS's own grey (sheet §D: a placeholder \
            takes the corrected faint, 3:1). Build it `TextField(phonePlaceholder:text:tokens:)`:
            \(offenders.joined(separator: "\n"))
            """)
    }

    /// **The Account sheet's seven fields** (W-A10's remainder, the walk's
    /// fixes batch 2): `Shared/AuthViews.swift` builds them with constructors
    /// the Mac shares, under `.pageFieldChrome(pageStyle)` — the phone's field
    /// on the styled arm. Each field whose chain wears that chrome is built by
    /// a helper that gives the phone its prompt in the corrected faint
    /// (`pagePlainField` / `pageSecureField`, or `emailField`, which builds
    /// through `pagePlainField`) and leaves the Mac's construction as it was.
    /// Red on old: the five raw `SecureField(` / `TextField(` sites and
    /// `emailField`'s raw `TextField(` (the two email fields).
    @Test func theAccountSheetsFieldsGiveTheirPlaceholderOnThePhone() throws {
        let url = Self.phoneRoot.deletingLastPathComponent()
            .appendingPathComponent("Shared").appendingPathComponent("AuthViews.swift")
        let lines = try String(contentsOf: url, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            .map { line -> String in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return trimmed.hasPrefix("//") || trimmed.hasPrefix("*") ? "" : line
            }
        let helpers = ["pagePlainField(", "pageSecureField(", "emailField("]
        var fields = 0
        var offenders: [String] = []
        for (index, line) in lines.enumerated() where line.contains(".pageFieldChrome(") {
            // The field this chrome wraps: the nearest constructor above it.
            guard let start = stride(from: index, through: max(index - 6, 0), by: -1).first(where: {
                lines[$0].contains("Field(") || lines[$0].contains("emailField(")
            }) else { continue }
            fields += 1
            if !helpers.contains(where: { lines[start].contains($0) }) {
                offenders.append("Shared/AuthViews.swift:\(start + 1)")
            }
        }
        let emailBody = lines.firstIndex { $0.contains("func emailField(") }.map { lines[$0 ..< min($0 + 3, lines.count)] }
        let emailBuildsThroughTheHelper = emailBody?.contains { $0.contains("pagePlainField(") } ?? false
        #expect(fields >= 7, "the Account sheet's seven fields (\(fields))")
        #expect(emailBuildsThroughTheHelper, "emailField builds through pagePlainField (its prompt on the phone)")
        #expect(offenders.isEmpty, """
            An Account sheet field leaves its placeholder to iOS's grey on the phone (sheet §D, \
            3:1). Build it with `pagePlainField` / `pageSecureField`:
            \(offenders.joined(separator: "\n"))
            """)
    }
}
