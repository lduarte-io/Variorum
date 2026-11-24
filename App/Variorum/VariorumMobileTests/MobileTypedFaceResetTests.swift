//
//  MobileTypedFaceResetTests.swift
//  VariorumMobileTests
//
//  **VM-243 (D-243-1) — the typed face's reset, its rule and its gate** (the
//  record `notes/plans/vm-24-unwarned-edit-routing.md` §4.5 and batch B half
//  2). The reading pin is `MobileTypedTextFaceTests` (red on the tree before
//  the fix, readings (a)–(f)); these pin what the fix may NOT do:
//
//  · `MobileTypedFaceRuleTests` — the pure rule on a bare `NSTextStorage`,
//    counting the storage's own processing passes: base on base writes
//    nothing (zero passes); a faint run is reset in ONE attribute-only pass;
//    only the range given moves; never the paragraph style, the block
//    identity or the face's mark; strikethrough and the chip go.
//  · `MobileTypedFaceGateTests` — her keyboard's road in a hosted Study note:
//    plain prose typed in plain prose makes no face write at all (the
//    equality gate, read from the model's own count of the reset's writes),
//    and the non-vacuity twin — prose typed after a dash line does.
//
//  These use the fix's API (`MobileTypedFace`, `typedFaceResets`), so they are
//  not in the red build; the reading pin is.
//

import Dependencies
import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The rule, on a bare storage

/// Counts a storage's processing passes from its own notifications, split by
/// whether the pass changed characters.
@MainActor
private final class PassCount {
    private weak var storage: NSTextStorage?
    private var observer: NSObjectProtocol?
    private(set) var attributeOnly = 0
    private(set) var withCharacters = 0

    init(_ storage: NSTextStorage) {
        self.storage = storage
        observer = NotificationCenter.default.addObserver(
            forName: NSTextStorage.didProcessEditingNotification, object: storage, queue: nil
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.note() }
        }
    }

    private func note() {
        guard let storage else { return }
        if storage.editedMask.contains(.editedCharacters) {
            withCharacters += 1
        } else {
            attributeOnly += 1
        }
    }

    func stop() {
        if let observer { NotificationCenter.default.removeObserver(observer) }
        observer = nil
    }
}

@MainActor
@Suite("VM-243 — the typed face's reset: the rule")
struct MobileTypedFaceRuleTests {
    private let font = UIFont.systemFont(ofSize: 17)
    private let ink = UIColor.black
    private let faint = UIColor.gray
    /// A second ink listed as the base (as the face's prose ink is): a
    /// different value, so the test reads the LIST, not colour equality.
    private let prose = UIColor(red: 0.16, green: 0.14, blue: 0.11, alpha: 1)
    private let blockKey = EditorDocument.blockIDAttribute
    private let style: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 14
        return style
    }()

    /// `"- one"`: the lead in the faint ink WITH the face's mark, the words
    /// faint WITHOUT it (the VM-243 state), every character in the base font,
    /// one paragraph style object and one block identity throughout.
    private func dashLine() -> NSTextStorage {
        let storage = NSTextStorage(string: "- one", attributes: [
            .font: font, .foregroundColor: faint, .paragraphStyle: style, blockKey: "B1",
        ])
        storage.addAttribute(MarkdownFace.faceAttribute, value: ink, range: NSRange(location: 0, length: 2))
        return storage
    }

    private func reset(_ storage: NSTextStorage, _ range: NSRange) -> Bool {
        MobileTypedFace.reset(storage, range: range, font: font, ink: ink, baseInks: [ink, prose])
    }

    @Test func baseOnBaseWritesNothingAndTheStorageSeesNoEdit() {
        let storage = NSTextStorage(string: "plain words", attributes: [
            .font: font, .foregroundColor: ink, .paragraphStyle: style, blockKey: "B1",
        ])
        let passes = PassCount(storage)
        defer { passes.stop() }
        #expect(!reset(storage, NSRange(location: 6, length: 5)), "nothing to reset")
        #expect(passes.attributeOnly == 0 && passes.withCharacters == 0,
                "THE GATE: the storage processed no edit at all")
    }

    @Test func aListedBaseInkCountsAsTheBase() {
        let storage = NSTextStorage(string: "Head", attributes: [.font: font, .foregroundColor: prose])
        let passes = PassCount(storage)
        defer { passes.stop() }
        #expect(!reset(storage, NSRange(location: 0, length: 4)),
                "the face's own prose ink (a cleared face run's) is the base: no write")
        #expect(passes.attributeOnly == 0)
    }

    @Test func aFaintRunIsResetInOnePassAndNothingElseMoves() throws {
        let storage = dashLine()
        let passes = PassCount(storage)
        defer { passes.stop() }
        #expect(reset(storage, NSRange(location: 2, length: 3)), "the words were faint: reset")
        #expect(passes.attributeOnly == 1 && passes.withCharacters == 0,
                "ONE attribute-only pass, no character changed")

        for offset in 2..<5 {
            #expect(storage.attribute(.foregroundColor, at: offset, effectiveRange: nil) as? UIColor === ink)
            #expect(storage.attribute(.font, at: offset, effectiveRange: nil) as? UIFont == font)
        }
        // Only the range given: the lead keeps its face.
        for offset in 0..<2 {
            #expect(storage.attribute(.foregroundColor, at: offset, effectiveRange: nil) as? UIColor === faint,
                    "the marker outside the range is untouched")
            #expect(storage.attribute(MarkdownFace.faceAttribute, at: offset, effectiveRange: nil) != nil,
                    "the face's mark is the restyle's, never the reset's")
        }
        // Never the paragraph style, never the block identity.
        for offset in 0..<5 {
            #expect(storage.attribute(.paragraphStyle, at: offset, effectiveRange: nil) as? NSParagraphStyle === style,
                    "the paragraph style object is untouched at \(offset)")
            #expect(storage.attribute(blockKey, at: offset, effectiveRange: nil) as? String == "B1",
                    "the block identity is untouched at \(offset)")
        }
    }

    @Test func aHeadingsFontAStrikethroughAndTheChipAreCleared() {
        let heading = UIFont.boldSystemFont(ofSize: 27)
        let storage = NSTextStorage(string: "word", attributes: [
            .font: heading, .foregroundColor: ink,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .backgroundColor: faint, .paragraphStyle: style,
        ])
        #expect(reset(storage, NSRange(location: 0, length: 4)))
        let attributes = storage.attributes(at: 0, longestEffectiveRange: nil,
                                            in: NSRange(location: 0, length: 4))
        #expect(attributes[.font] as? UIFont == font, "the base font, not the heading's")
        #expect(attributes[.strikethroughStyle] == nil)
        #expect(attributes[.backgroundColor] == nil, "no chip")
        #expect(attributes[.paragraphStyle] as? NSParagraphStyle === style)
    }

    @Test func aRunWithNoInkTakesTheBaseInk() {
        let storage = NSTextStorage(string: "x", attributes: [.font: font])
        #expect(reset(storage, NSRange(location: 0, length: 1)), "no ink is not the base ink")
        #expect(storage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor === ink)
    }

    @Test func anEmptyOrOutOfBoundsRangeWritesOnlyInsideTheStorage() {
        let storage = dashLine()
        let passes = PassCount(storage)
        defer { passes.stop() }
        #expect(!reset(storage, NSRange(location: 3, length: 0)), "a deletion's landing: nothing")
        #expect(!reset(storage, NSRange(location: 9, length: 4)), "wholly past the end: nothing")
        #expect(passes.attributeOnly == 0)
        #expect(reset(storage, NSRange(location: 4, length: 10)), "clamped to the storage")
        #expect(storage.attribute(.foregroundColor, at: 4, effectiveRange: nil) as? UIColor === ink)
        #expect(storage.attribute(.foregroundColor, at: 3, effectiveRange: nil) as? UIColor === faint,
                "nothing before the range moved")
    }
}

// MARK: - The gate, on her keyboard's road (the fence suite's helpers, file-local)

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

@MainActor
private func dismiss(_ window: UIWindow, _ surface: MobileWriteSurfaceView) {
    _ = surface.textView.resignFirstResponder()
    window.isHidden = true
    window.rootViewController = nil
}

@MainActor
private func withDesyncsRecorded<T>(_ body: () async throws -> T) async rethrows -> T {
    try await EditorAssertionSeam.$handler.withValue({ message, file, line in
        Issue.record("the editor's debug assertion fired: \(message) (\(file):\(line))")
    }) {
        try await body()
    }
}

/// Her keyboard's road: the gate first, the insert only on a yes, a run-loop
/// turn after each key.
@MainActor
private func typeOnHerRoad(_ view: UITextView, _ text: String) async {
    for character in text {
        let key = String(character)
        let approved = view.delegate?.textView?(
            view, shouldChangeTextIn: view.selectedRange, replacementText: key) ?? true
        #expect(approved, "the gate approved “\(key == "\n" ? "⏎" : key)”")
        if approved { view.insertText(key) }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}

@MainActor
@Suite("VM-243 — the typed face's reset: the gate on her road", .serialized)
struct MobileTypedFaceGateTests {
    /// **THE EQUALITY GATE.** Plain prose typed in plain prose — mid-block and
    /// on a fresh line, in a block with a block after it — makes no face
    /// write at all: every typed character already wears the base it would be
    /// reset to.
    @Test func plainProseTypedInPlainProseMakesNoFaceWrite() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            let postID = try await makePost(session, blocks: ["Intro words.", "After."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let view = surface.textView

            view.selectedRange = NSRange(location: 5, length: 0)  // "Intro| words."
            await typeOnHerRoad(view, " more")
            view.selectedRange = NSRange(location: 17, length: 0)  // the block's end
            await typeOnHerRoad(view, "\nA plain line.")
            #expect(view.textStorage.string == "Intro more words.\nA plain line.\nAfter.",
                    "non-vacuity: every key landed")
            #expect(model.desyncRecoveryCount == 0)
            #expect(model.typedFaceResets == 0,
                    "THE GATE: plain prose in plain prose wrote no face attribute (\(model.typedFaceResets) resets)")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Intro more words.\nA plain line.", "After."])
        } }
    }

    /// **The gate's non-vacuity twin.** Prose typed after a dash line's lead
    /// is reset — the counter moves, and the words land in full ink.
    @Test func proseTypedAfterADashLineIsReset() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, _ in
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            let postID = try await makePost(session, blocks: ["Intro.", "After."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let view = surface.textView

            view.selectedRange = NSRange(location: 6, length: 0)
            await typeOnHerRoad(view, "\n- one")
            #expect(view.textStorage.string == "Intro.\n- one\nAfter.")
            #expect(model.typedFaceResets > 0, "the words typed after the lead were reset")
            let traits = UITraitCollection(userInterfaceStyle: .light)
            let ink = MobileEditorStyle.face.ink.resolvedColor(with: traits)
            for offset in 9..<12 {
                let color = (view.textStorage.attribute(.foregroundColor, at: offset, effectiveRange: nil)
                    as? UIColor)?.resolvedColor(with: traits)
                #expect(color == ink, "“one” at \(offset) is in full ink")
            }
            #expect(model.desyncRecoveryCount == 0 && model.identityAuditFailures == 0)
        } }
    }
}
