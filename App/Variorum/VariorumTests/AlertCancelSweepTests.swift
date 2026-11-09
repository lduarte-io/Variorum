//
//  AlertCancelSweepTests.swift
//  VariorumTests (Mac)
//
//  VX-869 (the VX-915 run, batch 3 — the sweep VX-561 asked for). VX-561 traced
//  the Esc-dead New Book dialog to the macOS 26/27 `.alert` that carries a text
//  field and three or more buttons: it draws its buttons stacked and its
//  declared `Button("Cancel", role: .cancel)` never renders — so no Escape key
//  equivalent exists, a click away does nothing, ⌘Q is held, and creating is
//  the only way out. New Book became a SHEET (`NewBookSheet.swift`).
//
//  THE SWEEP found no other alert of that shape: every other text-field alert
//  in the Mac app carries exactly two buttons (its act and Cancel), and the one
//  three-button alert carries no field (the class-completeness table:
//  `notes/plans/fixes/vx-915-recents-sweep.md`, BATCH 3). This suite is the
//  belt that keeps the class EMPTY: a source walk over every alert the Mac app
//  can present — SwiftUI's `.alert` (and the hoisted `alert(` helpers) and
//  AppKit's `NSAlert` — refusing any that pairs a text field with three or more
//  buttons. A dialog that needs a field AND more than one act is a sheet with a
//  drawn Cancel on `.cancelAction` (`NewBookSheet`'s precedent).
//
//  RED ON OLD (evaluated by the batch's script over the scanner below): the
//  tree before `4de3b3169` held `ShelfView`'s `.alert("New Book")` — a Name
//  field and four buttons — which this walk names.
//

import Foundation
import Testing
@testable import Variorum

// SCANNER-BEGIN (the batch's headless evaluation script reads this slice verbatim)
/// What a source walk sees at one alert site.
struct AlertSite: Equatable, CustomStringConvertible {
    let file: String
    let line: Int
    /// A text field in the alert's actions (SwiftUI) or an accessory view
    /// (AppKit — the app's only accessory is the emoji field).
    let hasField: Bool
    /// Drawn buttons, Cancel included (an `NSAlert` with none draws one OK).
    let buttons: Int

    /// The VX-561 shape.
    var dropsItsCancel: Bool { hasField && buttons >= 3 }

    var description: String {
        "\(file):\(line) field=\(hasField) buttons=\(buttons)"
    }
}

enum AlertShapeScanner {
    /// Every SwiftUI alert call in `source` — `.alert(` and the bare `alert(`
    /// a `View` extension's helper calls — with its ACTIONS closure read: the
    /// first trailing closure after the call's own parentheses.
    static func swiftUISites(in source: String, file: String) -> [AlertSite] {
        let text = Array(withoutLineComments(source))
        var sites: [AlertSite] = []
        var index = 0
        while let hit = nextAlertCall(in: text, from: index) {
            index = hit + 1
            // `hit` is the index of `(` after `alert`.
            guard let close = matching(text, open: hit, opener: "(", closer: ")") else { continue }
            var cursor = close + 1
            while cursor < text.count, text[cursor].isWhitespace { cursor += 1 }
            guard cursor < text.count, text[cursor] == "{",
                  let end = matching(text, open: cursor, opener: "{", closer: "}")
            else { continue }
            let actions = String(text[cursor...end])
            sites.append(AlertSite(
                file: file, line: lineNumber(text, at: hit),
                hasField: ["TextField(", "SecureField(", "PeekableSecretField("]
                    .contains { actions.contains($0) },
                buttons: occurrences(of: "Button(", in: actions)))
        }
        return sites
    }

    /// Every AppKit `NSAlert()` built in `source`: its `addButton(withTitle:)`
    /// calls and whether it sets an accessory view, read up to the alert's
    /// `runModal()` / `beginSheetModal`.
    static func appKitSites(in source: String, file: String) -> [AlertSite] {
        let text = withoutLineComments(source)
        var sites: [AlertSite] = []
        var searchStart = text.startIndex
        while let hit = text.range(of: "NSAlert()", range: searchStart..<text.endIndex) {
            searchStart = hit.upperBound
            let rest = text[hit.upperBound...]
            let stop = [rest.range(of: "runModal()"), rest.range(of: "beginSheetModal")]
                .compactMap { $0?.lowerBound }.min() ?? rest.endIndex
            let body = String(rest[..<stop])
            let added = occurrences(of: "addButton(withTitle:", in: body)
            sites.append(AlertSite(
                file: file,
                line: text[..<hit.lowerBound].filter { $0 == "\n" }.count + 1,
                hasField: body.contains("accessoryView"),
                buttons: max(added, 1)))
        }
        return sites
    }

    // MARK: Internals

    /// Whole-line comments blanked (the doc comments that NAME `.alert`),
    /// lines kept so line numbers stay true.
    static func withoutLineComments(_ source: String) -> String {
        source.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces).hasPrefix("//") ? "" : String($0) }
            .joined(separator: "\n")
    }

    /// The index of the `(` of the next `alert(` call that is either `.alert(`
    /// or a bare `alert(` (never `wingMoveConfirm(`-style names ending in
    /// "alert" — the character before must not be an identifier character
    /// unless it is the dot).
    private static func nextAlertCall(in text: [Character], from start: Int) -> Int? {
        let needle = Array("alert(")
        var i = start
        while i + needle.count <= text.count {
            if Array(text[i..<(i + needle.count)]) == needle {
                let before: Character? = i > 0 ? text[i - 1] : nil
                let isIdentifierTail = before.map { $0.isLetter || $0.isNumber || $0 == "_" } ?? false
                if !isIdentifierTail { return i + needle.count - 1 }
            }
            i += 1
        }
        return nil
    }

    /// The index of the bracket closing the one at `open`, string literals
    /// skipped (escapes honoured; an interpolation's parentheses live inside
    /// the literal and are skipped with it).
    private static func matching(
        _ text: [Character], open: Int, opener: Character, closer: Character
    ) -> Int? {
        var depth = 0
        var i = open
        var inString = false
        while i < text.count {
            let c = text[i]
            if inString {
                if c == "\\" { i += 2; continue }
                if c == "\"" { inString = false }
            } else if c == "\"" {
                inString = true
            } else if c == opener {
                depth += 1
            } else if c == closer {
                depth -= 1
                if depth == 0 { return i }
            }
            i += 1
        }
        return nil
    }

    private static func lineNumber(_ text: [Character], at index: Int) -> Int {
        text[..<index].filter { $0 == "\n" }.count + 1
    }

    private static func occurrences(of needle: String, in haystack: String) -> Int {
        haystack.components(separatedBy: needle).count - 1
    }
}
// SCANNER-END

/// The Mac app's Swift sources — `App/Variorum/Variorum/` and the shared faces
/// it renders (`App/Variorum/Shared/`) — as (path relative to `App/Variorum/`,
/// text).
private func macAppSources() throws -> [(String, String)] {
    let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
    var found: [(String, String)] = []
    for folder in ["Variorum", "Shared"] {
        let base = root.appendingPathComponent(folder)
        guard let walker = FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil)
        else { continue }
        for case let url as URL in walker where url.pathExtension == "swift" {
            let relative = folder + "/" + url.path.dropFirst(base.path.count + 1)
            found.append((relative, try String(contentsOf: url, encoding: .utf8)))
        }
    }
    return found.sorted { $0.0 < $1.0 }
}

@Suite("VX-869 — no alert pairs a text field with three or more buttons")
struct AlertCancelSweepTests {
    /// The scanner SEES the shape: VX-561's own alert (a field, three creates
    /// and Cancel) is flagged; the app's ordinary field alert (act + Cancel) and
    /// its one three-button, field-less alert are not; a doc comment naming
    /// `.alert` is no site.
    @Test func theScannerSeesTheVX561ShapeAndOnlyIt() {
        let planted = """
            /// Presents `.alert("Documented")` — a comment, not a site.
            Text("x")
                .alert("New Book", isPresented: $shown) {
                    TextField("Name", text: $name)
                    Button("Create Book") {}
                    Button("Create Gathering\\u{2026}") { open(\\(1)) }
                    Button("Create Journal Book") {}
                    Button("Cancel", role: .cancel) {}
                } message: { Text("It lands on the shelf.") }
                .alert(
                    "Rename Shelf",
                    isPresented: Binding(get: { a != nil }, set: { if !$0 { a = nil } }),
                    presenting: a
                ) { shelf in
                    TextField("Name", text: $field)
                    Button("Rename") {}
                    Button("Cancel", role: .cancel) {}
                }
            func helper() -> some View {
                alert(title, isPresented: $asking) {
                    Button("Open in Mail") {}
                    Button("Copy Address") {}
                    Button("Cancel", role: .cancel) {}
                }
            }
            let y = badalert(1)
            """
        let sites = AlertShapeScanner.swiftUISites(in: planted, file: "planted.swift")
        #expect(sites.count == 3, "three alert calls, the comment and the look-alike name are none: \(sites)")
        #expect(sites.map(\.dropsItsCancel) == [true, false, false])
        #expect(sites.first?.buttons == 4)
        #expect(sites.first?.line == 3)

        let appKit = """
            let alert = NSAlert()
            alert.accessoryView = field
            alert.addButton(withTitle: "Set")
            alert.addButton(withTitle: "Other")
            alert.addButton(withTitle: "Cancel")
            alert.runModal()
            """
        #expect(AlertShapeScanner.appKitSites(in: appKit, file: "planted.swift").map(\.dropsItsCancel) == [true])
    }

    /// THE CLASS STAYS EMPTY: no SwiftUI alert and no `NSAlert` in the Mac app
    /// pairs a text field with three or more buttons. The walk must see the
    /// app's alerts to mean anything — the sweep counted 33 SwiftUI sites and 4
    /// AppKit ones — so a scanner that finds too few fails here rather than
    /// passing vacuously.
    @Test func noAlertInTheMacAppPairsAFieldWithThreeOrMoreButtons() throws {
        var swiftUI: [AlertSite] = []
        var appKit: [AlertSite] = []
        for (path, source) in try macAppSources() {
            swiftUI += AlertShapeScanner.swiftUISites(in: source, file: path)
            appKit += AlertShapeScanner.appKitSites(in: source, file: path)
        }
        #expect(swiftUI.count >= 30, "the walk saw the app's SwiftUI alerts (\(swiftUI.count))")
        #expect(swiftUI.contains { $0.file.hasSuffix("WingSwitcherMenu.swift") && $0.hasField },
                "a known field alert is among them")
        #expect(appKit.count >= 4, "the walk saw the app's NSAlerts (\(appKit.count))")
        let offenders = (swiftUI + appKit).filter(\.dropsItsCancel)
        #expect(offenders.isEmpty,
                "a text field with three or more buttons drops its Cancel on macOS 26/27 — make it a sheet (NewBookSheet's precedent): \(offenders)")
        // The one three-button alert carries no field (the sweep's row 33).
        #expect(swiftUI.filter { $0.buttons >= 3 }.allSatisfy { !$0.hasField })
    }
}
