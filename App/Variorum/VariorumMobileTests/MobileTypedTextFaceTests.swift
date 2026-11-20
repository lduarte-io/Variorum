//
//  MobileTypedTextFaceTests.swift
//  VariorumMobileTests
//
//  **VM-243 — text typed after a dash line is in full ink** (the record
//  `notes/plans/vm-24-unwarned-edit-routing.md`, §4.4–§4.5 and batch B; her
//  words: "after I use a dash, the rest of the text after that is also in a
//  faint wash and sometimes it doesn't go away for the rest of the note,
//  sometimes it does").
//
//  THE PIN AS THE CONFIRM (batch B, half 1). The mechanism was traced only by
//  reading (§4.4, SPECULATIVE until this pin is red):
//    1. the markdown face marks every run it styles (`MarkdownFace.
//       faceAttribute`), and a restyle clears only runs that carry the mark;
//    2. a dash line's `"- "` is the bullet's marker, written in the marker's
//       muted ink WITH the mark, and the item's words are never written;
//    3. on iOS a typed character takes UIKit's typing attributes, derived
//       from the character before the caret — font and ink ride, the custom
//       mark does not (the Stage 0 spike, `carryCustomKeyAtMidBlockCaret=NO`,
//       `keys=NSColor,NSFont`) — so the first word typed after `"- "` lands in
//       the marker's ink WITHOUT the mark;
//    4. nothing clears it, and every next character inherits from the one
//       before it, through the Return, into the next paragraph, until a write
//       with the base attributes lands there (a re-open is one).
//  Each test is one of the batch's readings (a)–(e); every reading PRINTS what
//  it found (`VM243|…` lines: offsets, the fixture's own characters, the ink
//  and the font of each run by name), so a result that differs from §4.4's
//  prediction can still be read from the log.
//
//  THE ROAD: her keyboard's (the fence suite's `keyboardType` — the gate is
//  asked first and the key inserted only on a yes, TEXTKIT2 §3's rule for a
//  pin that types), hosted in the posture her phone types in, one run-loop
//  turn between keystrokes as her keys arrive. Every edit here is ARMED, so
//  it binds however far iOS widens its report: the routing cannot decide the
//  outcome, and nothing here depends on what an earlier suite left behind.
//  The fixture types inside block 0 of a two-block note (`"After."` stands
//  after it), so no open tail, no crystallization and no programmatic
//  normalizing write ever touches the typed text.
//
//  STUDY VOICE, where the marker's ink and the prose ink differ (a premise
//  each test asserts). Colours are compared RESOLVED under one fixed light
//  trait collection, never by object identity, so a dynamic colour object
//  another surface made is still read for what it draws.
//
//  RED ON OLD is not decided here: §4.4 predicts it, and the record's batch B
//  closeout tables the prediction per expectation line. A red at a PREMISE
//  line is not the predicted red. These pins use ONLY API that exists on the
//  tree before VM-243's fix, so this file builds against it unchanged.
//

import Dependencies
import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The posture, the road and the assertion seam (the fence suite's, file-local)

/// The posture her phone types in (the fence suite's and the caret suite's
/// `host`): the surface in the foreground scene's key window, any responder
/// an earlier suite left holding the keyboard resigned first, the Write text
/// view first responder.
@MainActor
private func host(_ surface: MobileWriteSurfaceView) throws -> UIWindow {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = try #require(
        scenes.first { $0.activationState == .foregroundActive } ?? scenes.first,
        "the test host has a window scene to type in")
    let window = UIWindow(windowScene: scene)
    window.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    let controller = UIViewController()
    controller.view.addSubview(surface)
    window.rootViewController = controller
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    window.makeKeyAndVisible()
    _ = surface.textView.becomeFirstResponder()
    return window
}

/// The teardown: the text view resigns BEFORE the window hides, so no first
/// responder outlives the pin.
@MainActor
private func dismiss(_ window: UIWindow, _ surface: MobileWriteSurfaceView) {
    _ = surface.textView.resignFirstResponder()
    window.isHidden = true
    window.rootViewController = nil
}

/// The editor's debug assertion RECORDED as a failing issue instead of
/// stopping the host (the fence suite's `withDesyncsRecorded`). It never makes
/// a pin green.
@MainActor
private func withDesyncsRecorded<T>(_ body: () async throws -> T) async rethrows -> T {
    try await EditorAssertionSeam.$handler.withValue({ message, file, line in
        Issue.record("the editor's debug assertion fired: \(message) (\(file):\(line))")
    }) {
        try await body()
    }
}

/// **A typed key, the way HER keyboard types it** (the fence suite's
/// `keyboardType`): the gate is asked first and the key inserted only on a
/// yes. A `"\n"` goes on through the editor's ⏎ door
/// (`MobileEditorTextView.insertText` → `MobileMarkdownActs.handleReturnKey`),
/// exactly as her Return key does.
@MainActor
@discardableResult
private func keyboardType(_ textView: UITextView, _ text: String) -> Bool {
    let range = textView.selectedRange
    guard textView.delegate?.textView?(
        textView, shouldChangeTextIn: range, replacementText: text) ?? true
    else { return false }
    textView.insertText(text)
    return true
}

/// One run-loop turn, as between two of her keystrokes: queued main-actor
/// work runs and the run loop cycles once. It decides nothing about the face
/// (no clock runs in these worlds); it only keeps the pin from typing faster
/// than any keyboard can.
@MainActor
private func betweenKeystrokes() async {
    await Task.yield()
    try? await Task.sleep(for: .milliseconds(1))
}

// MARK: - Reading the face

/// What the storage's characters WEAR, named: the ink (resolved under one
/// fixed light trait collection and named against the Study face's own
/// colours) and the font (its PostScript name and size). Prints and compares;
/// writes nothing.
@MainActor
private struct FaceReading {
    let storage: NSTextStorage
    /// One fixed appearance for every comparison, so the reading never
    /// depends on the host's appearance.
    private let traits = UITraitCollection(userInterfaceStyle: .light)

    init(_ storage: NSTextStorage) { self.storage = storage }

    private func rgba(_ color: UIColor) -> [CGFloat] {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.resolvedColor(with: traits).getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r, g, b, a]
    }

    func drawSame(_ a: UIColor, _ b: UIColor) -> Bool {
        zip(rgba(a), rgba(b)).allSatisfy { abs($0 - $1) < 0.002 }
    }

    private func hex(_ color: UIColor) -> String {
        let c = rgba(color).map { Int(($0 * 255).rounded()) }
        let rgb = String(format: "#%02X%02X%02X", c[0], c[1], c[2])
        return c[3] == 255 ? rgb : rgb + "/\(c[3])"
    }

    /// The face's own colours, by name, in naming order.
    private var named: [(String, UIColor)] {
        let face = MobileEditorStyle.face
        let palette = MobileEditorStyle.markdownPalette
        return [
            ("ink", face.ink), ("prose-ink", palette.prose), ("marker", palette.marker),
            ("link", palette.link), ("phone-muted", face.muted),
        ]
    }

    func ink(at offset: Int) -> UIColor? {
        storage.attribute(.foregroundColor, at: offset, effectiveRange: nil) as? UIColor
    }

    func font(at offset: Int) -> UIFont? {
        storage.attribute(.font, at: offset, effectiveRange: nil) as? UIFont
    }

    /// `ink` for the face's own object, `≈ink` for another object that draws
    /// the same, else the resolved value alone; always with its resolved hex.
    func inkName(_ color: UIColor?) -> String {
        guard let color else { return "none" }
        if let same = named.first(where: { $0.1 === color }) {
            return "\(same.0) \(hex(color))"
        }
        if let alike = named.first(where: { drawSame($0.1, color) }) {
            return "≈\(alike.0) \(hex(color))"
        }
        return "rgba \(hex(color))"
    }

    func fontName(_ font: UIFont?) -> String {
        guard let font else { return "none" }
        let base = MobileEditorStyle.baseFont
        let tag = isBase(font) ? " (base)" : font.pointSize > base.pointSize ? " (larger)" : ""
        return "\(font.fontName) \(font.pointSize)\(tag)"
    }

    private func isBase(_ font: UIFont) -> Bool {
        let base = MobileEditorStyle.baseFont
        return font.fontName == base.fontName && abs(font.pointSize - base.pointSize) < 0.01
    }

    func isFullInk(_ range: NSRange) -> Bool {
        let prose = MobileEditorStyle.face.ink
        return range.length > 0 && (range.location..<range.upperBound).allSatisfy { offset in
            self.ink(at: offset).map { drawSame($0, prose) } ?? false
        }
    }

    func isMarkerInk(_ range: NSRange) -> Bool {
        let marker = MobileEditorStyle.markdownPalette.marker
        return range.length > 0 && (range.location..<range.upperBound).allSatisfy { offset in
            self.ink(at: offset).map { drawSame($0, marker) } ?? false
        }
    }

    func isBaseFont(_ range: NSRange) -> Bool {
        range.length > 0 && (range.location..<range.upperBound).allSatisfy { offset in
            font(at: offset).map(isBase) ?? false
        }
    }

    func isFaced(_ range: NSRange) -> Bool {
        range.length > 0 && (range.location..<range.upperBound).allSatisfy { offset in
            storage.attribute(MarkdownFace.faceAttribute, at: offset, effectiveRange: nil) != nil
        }
    }

    /// One character's whole reading.
    func describe(at offset: Int) -> String {
        var line = "ink=\(inkName(ink(at: offset))) font=\(fontName(font(at: offset)))"
        if storage.attribute(MarkdownFace.faceAttribute, at: offset, effectiveRange: nil) != nil {
            line += " faced"
        }
        if storage.attribute(.strikethroughStyle, at: offset, effectiveRange: nil) != nil {
            line += " struck"
        }
        if storage.attribute(.backgroundColor, at: offset, effectiveRange: nil) != nil {
            line += " chip"
        }
        return line
    }

    /// The range's runs, coalesced by reading: `[start..<end) “chars” …`. The
    /// characters are the test's own fixture; a newline prints as `⏎`.
    func runs(_ range: NSRange) -> String {
        let string = storage.string as NSString
        let upper = min(range.upperBound, storage.length)
        guard range.location < upper else { return "(empty)" }
        var out: [String] = []
        var start = range.location
        var current = describe(at: start)
        func close(_ end: Int) {
            let chars = string.substring(with: NSRange(location: start, length: end - start))
                .replacingOccurrences(of: "\n", with: "⏎")
            out.append("[\(start)..<\(end)) “\(chars)” \(current)")
        }
        if range.location + 1 < upper {
            for offset in (range.location + 1)..<upper {
                let next = describe(at: offset)
                if next != current {
                    close(offset)
                    start = offset
                    current = next
                }
            }
        }
        close(upper)
        return out.joined(separator: " · ")
    }

    /// Prints the reading to the log, tagged for `grep 'VM243|'`.
    func report(_ reading: String, _ what: String, _ range: NSRange) {
        print("VM243|\(reading)|\(what)|\(runs(range))")
    }
}

// MARK: - The world every reading types in

/// A Study note `["Intro.", "After."]`, hosted in her posture, the caret at
/// the end of `"Intro."` and one Return typed there — so every reading starts
/// on a fresh line inside block 0, below a line in full ink, with a block
/// after it. Hands the body the model, the surface, the world and the post.
@MainActor
private func onAFreshLine(
    _ reading: String,
    _ body: @MainActor (MobileEditorViewModel, MobileWriteSurfaceView, AppSession, AppDatabase, String)
        async throws -> Void
) async throws {
    try await withDesyncsRecorded { try await withEditorWorld { session, db in
        MobileEditorStyle.voice = .study
        defer { MobileEditorStyle.voice = .terminal }
        let postID = try await makePost(session, blocks: ["Intro.", "After."])
        let (model, surface) = await makeSurfaceEditor(session, postID: postID)
        let window = try host(surface)
        defer { dismiss(window, surface) }
        let view = surface.textView
        let face = FaceReading(view.textStorage)

        try #require(MobileEditorStyle.voice == .study, "\(reading) PREMISE: the Study voice")
        try #require(
            !face.drawSame(MobileEditorStyle.face.ink, MobileEditorStyle.markdownPalette.marker),
            "\(reading) PREMISE: in Study the marker's ink differs from the prose ink, so the pin can tell them apart")
        try #require(view.textStorage.string == "Intro.\nAfter.", "\(reading) PREMISE: the fixture")
        #expect(face.isFullInk(NSRange(location: 0, length: 6)) && face.isBaseFont(NSRange(location: 0, length: 6)),
                "\(reading) PREMISE: the materialized page is in full ink and the base font — found \(face.runs(NSRange(location: 0, length: 6)))")
        face.report(reading, "fixture", NSRange(location: 0, length: view.textStorage.length))

        view.selectedRange = NSRange(location: 6, length: 0)  // "Intro.|"
        await betweenKeystrokes()
        try #require(keyboardType(view, "\n"), "\(reading) PREMISE: the gate approved the Return after “Intro.”")
        await betweenKeystrokes()
        try #require(view.textStorage.string == "Intro.\n\nAfter.",
                     "\(reading) PREMISE: the Return is content inside block 0")
        try await body(model, surface, session, db, postID)
    } }
}

/// Types `text` one key at a time on her keyboard's road, a turn between
/// keys, printing what each key landed wearing.
@MainActor
private func typeKeys(_ view: UITextView, _ text: String, reading: String) async {
    let face = FaceReading(view.textStorage)
    for character in text {
        let key = String(character)
        let at = view.selectedRange.location
        #expect(keyboardType(view, key),
                "\(reading) PREMISE: the gate approved “\(key == "\n" ? "⏎" : key)” at \(at)")
        await betweenKeystrokes()
        let landed = key == "\n" ? "⏎" : key
        let caret = view.selectedRange.location
        let reported = caret > 0 ? face.describe(at: caret - 1) : "(nothing before the caret)"
        print("VM243|\(reading)|key “\(landed)” at \(at) → caret \(caret); the character before it: \(reported)")
    }
}

/// The page stayed in step and the store holds what was typed.
@MainActor
private func expectTypedAndStored(
    _ model: MobileEditorViewModel, _ view: UITextView, _ db: AppDatabase, _ postID: String,
    block0: String, reading: String
) async throws {
    #expect(view.textStorage.string == block0 + "\nAfter.",
            "\(reading) PREMISE: the page holds what was typed")
    #expect(model.desyncRecoveryCount == 0, "\(reading) PREMISE: every key routed — no desync")
    #expect(model.identityAuditFailures == 0, "\(reading) PREMISE: the identity audit stayed quiet")
    await model.autosave.flushNow()
    #expect(try await storedBlockTexts(db, postID: postID) == [block0, "After."],
            "\(reading) PREMISE: the store holds it in block 0's take")
}

// MARK: - The readings

@MainActor
@Suite("VM-243 — text typed after a markdown marker wears the prose face", .serialized)
struct MobileTypedTextFaceTests {
    /// **(a) `- one`, typed a character at a time.** The dash and its space
    /// are the bullet's marker (the marker's ink, faced); the item's words
    /// are prose and must read in full ink.
    ///
    /// §4.4 PREDICTS ON THE TREE BEFORE THE FIX: "one" in the marker's ink
    /// (it inherits the `" "` before it, mark stripped), in the base font.
    @Test func aDashLinesWordsAreTypedInFullInk() async throws {
        try await onAFreshLine("(a)") { model, surface, _, db, postID in
            let view = surface.textView
            let face = FaceReading(view.textStorage)
            await typeKeys(view, "- one", reading: "(a)")
            try await expectTypedAndStored(
                model, view, db, postID, block0: "Intro.\n- one", reading: "(a)")

            let marker = NSRange(location: 7, length: 2)   // "- "
            let words = NSRange(location: 9, length: 3)    // "one"
            face.report("(a)", "the dash line", NSRange(location: 7, length: 5))
            #expect(face.isMarkerInk(marker) && face.isFaced(marker),
                    "(a) PREMISE: the dash is the bullet's marker — the marker's ink, faced — found \(face.runs(marker))")
            #expect(face.isFullInk(words),
                    "(a) OUTCOME: “one” is typed in full ink — found \(face.runs(words))")
            #expect(face.isBaseFont(words),
                    "(a) OUTCOME: “one” wears the base font — found \(face.runs(words))")
        }
    }

    /// **(b) Return twice, then `two`.** The first Return continues the list
    /// (a new `"- "` lead), the second ends it (the lead goes, no newline —
    /// K5's exit), and `two` is typed on the line after the dash line: plain
    /// prose, which must read in full ink.
    ///
    /// §4.4 PREDICTS ON THE TREE BEFORE THE FIX: "two" in the marker's ink
    /// (it inherits the Return typed after "one", which inherited "one"'s), in
    /// the base font.
    @Test func theParagraphAfterADashLineIsTypedInFullInk() async throws {
        try await onAFreshLine("(b)") { model, surface, _, db, postID in
            let view = surface.textView
            let face = FaceReading(view.textStorage)
            await typeKeys(view, "- one", reading: "(b)")
            await typeKeys(view, "\n", reading: "(b)")
            #expect(view.textStorage.string == "Intro.\n- one\n- \nAfter.",
                    "(b) PREMISE: the first Return continued the list")
            await typeKeys(view, "\n", reading: "(b)")
            #expect(view.textStorage.string == "Intro.\n- one\n\nAfter.",
                    "(b) PREMISE: the second Return ended the list (the lead gone, no newline)")
            #expect(view.selectedRange == NSRange(location: 13, length: 0),
                    "(b) PREMISE: the caret stands at the start of the line after the dash line")
            await typeKeys(view, "two", reading: "(b)")
            try await expectTypedAndStored(
                model, view, db, postID, block0: "Intro.\n- one\ntwo", reading: "(b)")

            let words = NSRange(location: 13, length: 3)   // "two"
            face.report("(b)", "the dash line and the line after it", NSRange(location: 7, length: 9))
            #expect(face.isFullInk(words),
                    "(b) OUTCOME: “two”, on the line after the dash line, is in full ink — found \(face.runs(words))")
            #expect(face.isBaseFont(words),
                    "(b) OUTCOME: “two” wears the base font — found \(face.runs(words))")
        }
    }

    /// **(c) On a new line, `*a* b`.** The words typed right after a CLOSING
    /// marker are prose and must read in full ink.
    ///
    /// §4.4 PREDICTS ON THE TREE BEFORE THE FIX: " b" in the marker's ink (it
    /// inherits the closing star, mark stripped), in the base font (a marker
    /// is written in the base font).
    @Test func wordsTypedAfterAClosingMarkerAreInFullInk() async throws {
        try await onAFreshLine("(c)") { model, surface, _, db, postID in
            let view = surface.textView
            let face = FaceReading(view.textStorage)
            await typeKeys(view, "*a* b", reading: "(c)")
            try await expectTypedAndStored(
                model, view, db, postID, block0: "Intro.\n*a* b", reading: "(c)")

            let opener = NSRange(location: 7, length: 1)
            let content = NSRange(location: 8, length: 1)
            let closer = NSRange(location: 9, length: 1)
            let after = NSRange(location: 10, length: 2)   // " b"
            face.report("(c)", "the line", NSRange(location: 7, length: 5))
            #expect(face.isMarkerInk(opener) && face.isFaced(opener)
                        && face.isMarkerInk(closer) && face.isFaced(closer),
                    "(c) PREMISE: the stars are the italic's markers — the marker's ink, faced — found \(face.runs(NSRange(location: 7, length: 3)))")
            #expect(face.font(at: content.location)?.fontDescriptor.symbolicTraits
                        .contains(.traitItalic) == true,
                    "(c) PREMISE: “a” reads italic — found \(face.runs(content))")
            #expect(face.isFullInk(after),
                    "(c) OUTCOME: “ b”, typed after the closing star, is in full ink — found \(face.runs(after))")
            #expect(face.isBaseFont(after),
                    "(c) OUTCOME: “ b” wears the base font — found \(face.runs(after))")
        }
    }

    /// **(d) A heading line, Return, a word.** The line after a heading is
    /// prose: full ink and the base font.
    ///
    /// §4.4 leaves (d) TO BE READ, NOT ASSUMED ("text typed on the line after
    /// a heading may keep the heading's font"). The same mechanism, extended
    /// by reading: a heading's content is written with its font and NO ink,
    /// so the last character typed keeps the ink it inherited until the next
    /// restyle clears it; the Return typed after "Head" inherits the heading's
    /// font and that ink, and "word" inherits the Return's.
    @Test func theLineTypedAfterAHeadingWearsTheProseFace() async throws {
        try await onAFreshLine("(d)") { model, surface, _, db, postID in
            let view = surface.textView
            let face = FaceReading(view.textStorage)
            await typeKeys(view, "# Head", reading: "(d)")
            await typeKeys(view, "\n", reading: "(d)")
            #expect(view.textStorage.string == "Intro.\n# Head\n\nAfter.",
                    "(d) PREMISE: a heading's Return is ordinary (it never continues)")
            await typeKeys(view, "word", reading: "(d)")
            try await expectTypedAndStored(
                model, view, db, postID, block0: "Intro.\n# Head\nword", reading: "(d)")

            let heading = NSRange(location: 9, length: 4)  // "Head"
            let words = NSRange(location: 14, length: 4)   // "word"
            face.report("(d)", "the heading line and the line after it", NSRange(location: 7, length: 11))
            #expect((face.font(at: heading.location)?.pointSize ?? 0)
                        > MobileEditorStyle.baseFont.pointSize,
                    "(d) PREMISE: “Head” reads as a heading (a larger font) — found \(face.runs(heading))")
            #expect(face.isFullInk(words),
                    "(d) OUTCOME: “word”, on the line after the heading, is in full ink — found \(face.runs(words))")
            #expect(face.isBaseFont(words),
                    "(d) OUTCOME: “word” wears the base font, not the heading's — found \(face.runs(words))")
        }
    }

    /// **(e) The note re-opened.** What (a) and (b) typed, flushed, the editor
    /// finished and a fresh one opened over the same note: the materialized
    /// page is in full ink but for the marker — the face's attributes are
    /// never stored, so a re-open draws from the base.
    ///
    /// §4.4 PREDICTS ON BOTH TREES: full ink and the base font for every
    /// typed word (a re-open clears it). A control: green before the fix too.
    @Test func aReopenedNoteDrawsWhatWasTypedInFullInk() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            let postID = try await makePost(session, blocks: ["Intro.", "After."])
            let block0 = "Intro.\n- one\ntwo"

            // The typing — (a) then (b)'s road, in the first editor.
            do {
                let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                let window = try host(surface)
                defer { dismiss(window, surface) }
                let view = surface.textView
                let face = FaceReading(view.textStorage)
                try #require(
                    !face.drawSame(MobileEditorStyle.face.ink, MobileEditorStyle.markdownPalette.marker),
                    "(e) PREMISE: in Study the marker's ink differs from the prose ink")
                view.selectedRange = NSRange(location: 6, length: 0)
                await betweenKeystrokes()
                await typeKeys(view, "\n- one\n\ntwo", reading: "(e)")
                try await expectTypedAndStored(model, view, db, postID, block0: block0, reading: "(e)")
                face.report("(e)", "before the re-open (the first editor's page)", NSRange(location: 0, length: 16))
                await model.finish()
            }

            // The re-open: a fresh editor over the same note.
            let (reopened, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let view = surface.textView
            let face = FaceReading(view.textStorage)
            #expect(view.textStorage.string == block0 + "\nAfter.",
                    "(e) PREMISE: the re-opened page holds what was typed")
            #expect(reopened.desyncRecoveryCount == 0 && reopened.identityAuditFailures == 0,
                    "(e) PREMISE: the re-opened editor is in step")
            face.report("(e)", "after the re-open", NSRange(location: 0, length: 16))

            let marker = NSRange(location: 7, length: 2)   // "- "
            let one = NSRange(location: 9, length: 3)
            let two = NSRange(location: 13, length: 3)
            #expect(face.isMarkerInk(marker) && face.isFaced(marker),
                    "(e) PREMISE: the re-opened face draws the dash as the marker — found \(face.runs(marker))")
            #expect(face.isFullInk(one) && face.isFullInk(two),
                    "(e) OUTCOME: after the re-open “one” and “two” are in full ink — found \(face.runs(one)) / \(face.runs(two))")
            #expect(face.isBaseFont(one) && face.isBaseFont(two),
                    "(e) OUTCOME: after the re-open “one” and “two” wear the base font — found \(face.runs(one)) / \(face.runs(two))")
        } }
    }
}
