//
//  MobileMarkdownCaretTests.swift
//  VariorumMobileTests
//
//  VX-296 on the phone — the italics flicker in the phone's live Write editor
//  (the Mac's twin: her report and ruling are in the Mac suite
//  `MarkdownCaretFaceTests` and the run record). The phone's keystroke road
//  (`MobileEditorViewModel.storageDidEdit` → `MarkdownFace.restyle`) re-read
//  the edited lines caret-blind, so `*hello |*` read plain at every word
//  boundary exactly as the Mac's did; the shared face and its brain
//  (`MarkdownCaretRescue`) now honour the caret, and the gate delegate
//  settles it when UIKit reports the selection and the text change.
//
//  Driven through the REAL `MobileEditorTextView` (`insertText`, the
//  keyboard's own door), hosted in a key window with the text view first
//  responder — the posture her thumb types in. RED ON OLD where marked.
//

import Dependencies
import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VX-296 — the caret-aware face in the phone's Write editor", .serialized)
struct MobileMarkdownCaretTests {
    /// The posture her phone is always in: the editor's window is the
    /// foreground SCENE's key window and its text view the one first
    /// responder (VX-282 C-1 — a bare frame window is never the scene's key
    /// window, and a text view an earlier suite left first responder in a
    /// hidden window keeps the hardware keyboard's input session; in that
    /// polluted posture an `insertText` of a run desyncs the phone editor with
    /// or without the caret settle — VM-19 owns that gate gap).
    private func host(_ surface: MobileWriteSurfaceView) -> UIWindow {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let window = scene.map { UIWindow(windowScene: $0) }
            ?? UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
        window.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
        let controller = UIViewController()
        controller.view.addSubview(surface)
        window.rootViewController = controller
        // Whatever an earlier suite left holding the keyboard lets go first.
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        window.makeKeyAndVisible()
        _ = surface.textView.becomeFirstResponder()
        return window
    }

    /// The window's teardown: the text view resigns BEFORE the window hides,
    /// so no first responder outlives the test.
    private func dismiss(_ window: UIWindow, _ surface: MobileWriteSurfaceView) {
        _ = surface.textView.resignFirstResponder()
        window.isHidden = true
        window.rootViewController = nil
    }

    private func isItalic(_ storage: NSTextStorage, at offset: Int) -> Bool {
        (storage.attribute(.font, at: offset, effectiveRange: nil) as? UIFont)?
            .fontDescriptor.symbolicTraits.contains(.traitItalic) ?? false
    }

    private func unstyled(_ storage: NSTextStorage, _ range: Range<Int>) -> [Int] {
        range.filter { !isItalic(storage, at: $0) }
    }

    private func anyFace(_ storage: NSTextStorage, _ range: Range<Int>) -> Bool {
        range.contains {
            storage.attribute(MarkdownFace.faceAttribute, at: $0, effectiveRange: nil) != nil
        }
    }

    /// **HER PIN ON THE PHONE — RED ON OLD.** ⌘I's pair (`**`), then her
    /// words one keystroke at a time: every character typed so far reads
    /// italic after every keystroke, spaces included.
    @Test func herFlowTypingInsideAnItalicPairNeverDropsTheItalicAtASpace() async throws {
        try await withEditorWorld { session, _ in
            // Study: a face that really ships an italic (the phone's Terminal
            // face is the system monospace), so the pin cannot pass vacuously.
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            try #require(
                MarkdownFace.adding(MarkdownFace.italicTrait, to: MobileEditorStyle.baseFont)
                    != MobileEditorStyle.baseFont,
                "non-vacuity: the voice has an italic face")

            let postID = try await makePost(session, blocks: ["**", "after"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = host(surface)
            defer { dismiss(window, surface) }
            let view = surface.textView
            let storage = view.textStorage

            view.selectedRange = NSRange(location: 1, length: 0)
            var typed = ""
            var flips: [String] = []
            for character in "hello world" {
                view.insertText(String(character))
                typed.append(character)
                if !unstyled(storage, 1..<(1 + typed.utf16.count)).isEmpty { flips.append(typed) }
            }
            #expect(storage.string == "*hello world*\nafter")
            #expect(flips.isEmpty, "the italic dropped after typing: \(flips)")
            #expect(model.identityAuditFailures == 0, "the caret's restyle wrote no identity")
        }
    }

    /// **RED ON OLD (its first and third expectations).** Leaving the rescue
    /// point un-styles the span honestly; coming back brings it back.
    @Test func leavingATrailingSpaceBehindUnstylesTheSpanHonestly() async throws {
        try await withEditorWorld { session, _ in
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            let postID = try await makePost(session, blocks: ["**", "next block"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = host(surface)
            defer { dismiss(window, surface) }
            let view = surface.textView
            let storage = view.textStorage

            view.selectedRange = NSRange(location: 1, length: 0)
            view.insertText("hello ")
            #expect(storage.string == "*hello *\nnext block")
            #expect(view.selectedRange == NSRange(location: 7, length: 0))
            #expect(unstyled(storage, 1..<7).isEmpty, "her caret sits after the space: italic")

            view.selectedRange = NSRange(location: 8, length: 0)  // past the star
            #expect(!anyFace(storage, 0..<8), "the trailing space is left behind")

            view.selectedRange = NSRange(location: 7, length: 0)  // back
            #expect(unstyled(storage, 1..<7).isEmpty, "back between the space and the star: italic")

            view.selectedRange = NSRange(location: 12, length: 0)  // into the next block
            #expect(!anyFace(storage, 0..<8))
            #expect(model.identityAuditFailures == 0)
        }
    }

    // MARK: - VX-282 round 1 (R1-7, R1-3)

    /// **RED ON OLD (the round-1 review's R1-7, the phone's half).** A
    /// stood-down editor (the read tier — another tab holds the pen, a hidden
    /// stack's surface) is not editable: whatever selection it carries is not
    /// her caret, and the face must not honour it — the live pane's rule. The
    /// settle is called as the gate delegate calls it, so the pin reads the
    /// model's decision whatever UIKit reports to a resigned view.
    @Test func aStoodDownEditorHonoursNoCaret() async throws {
        try await withEditorWorld { session, _ in
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            let postID = try await makePost(session, blocks: ["*hello *", "next block"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = host(surface)
            defer { dismiss(window, surface) }
            let view = surface.textView
            let storage = view.textStorage

            view.selectedRange = NSRange(location: 7, length: 0)
            model.settleMarkdownCaret()
            #expect(unstyled(storage, 1..<7).isEmpty, "non-vacuity: a live editor honours the caret")

            model.standDown()
            #expect(!view.isEditable, "the read tier: not editable")
            view.selectedRange = NSRange(location: 0, length: 0)
            model.settleMarkdownCaret()
            view.selectedRange = NSRange(location: 7, length: 0)
            model.settleMarkdownCaret()
            #expect(!anyFace(storage, 0..<8), "RED ON OLD: a stood-down editor honours no caret")
            #expect(model.identityAuditFailures == 0)
        }
    }

    /// **PIN FIRST — the round-1 review's R1-3 (SPECULATIVE): does the
    /// settle's pending-edit guard have a window on the phone?** The guard
    /// (`MarkdownFace.settleCaret`'s `editedMask` check) is empty between
    /// `beginEditing` and the first change inside a transaction. If UIKit
    /// reports the selection inside `coordinateEditing` BEFORE the character
    /// change — the roads autocorrect, the spelling Replace and dictation take
    /// go through `UITextInput.replace(_:withText:)`, and only `insertText` was
    /// observed at U2 — a settle at a rescue point would write inside the
    /// transaction: the W2b class (the edit's report widened to the line, the
    /// armed edit unbound, the route refusing, the surface desynced). Driven
    /// through the real `replace(_:withText:)` with her caret at `*hello |*`:
    /// a same-length replacement (the review's shape), a shorter one and a
    /// longer one (the caret shifts — a selection report is certain). RED ⇒
    /// the window is real and the phone's settle gains the `pendingEdit`
    /// guard; GREEN ⇒ R1-3 is hollow and nothing is changed. Assertions are
    /// muted so a desync reads as its counter, never a crash.
    @Test(arguments: ["Hello", "hi", "hello there"])
    func aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(
        _ replacement: String
    ) async throws {
        try await withEditorAssertionsMuted {
            try await withEditorWorld { session, _ in
                MobileEditorStyle.voice = .study
                defer { MobileEditorStyle.voice = .terminal }
                let postID = try await makePost(session, blocks: ["*hello *", "next block"])
                let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                let window = host(surface)
                defer { dismiss(window, surface) }
                let view = surface.textView
                let storage = view.textStorage

                view.selectedRange = NSRange(location: 7, length: 0)
                #expect(unstyled(storage, 1..<7).isEmpty,
                        "non-vacuity: the caret is honoured before the replace")
                let start = try #require(view.position(from: view.beginningOfDocument, offset: 1))
                let end = try #require(view.position(from: start, offset: 5))
                let range = try #require(view.textRange(from: start, to: end))
                view.replace(range, withText: replacement)

                #expect(model.desyncRecoveryCount == 0,
                        "the replace never desynced the surface (R1-3's window)")
                #expect(storage.string == "*\(replacement) *\nnext block")
                #expect(model.identityAuditFailures == 0)
                // The face reads as the landed caret says: honoured exactly
                // when the caret still sits between the space and the star.
                let length = (replacement as NSString).length
                let caret = view.selectedRange
                if caret == NSRange(location: length + 2, length: 0) {
                    #expect(unstyled(storage, 1..<(length + 2)).isEmpty,
                            "the caret at the rescue point: honoured")
                } else {
                    #expect(!anyFace(storage, 0..<(length + 3)),
                            "the caret elsewhere (\(caret)): caret-blind")
                }
            }
        }
    }
}
