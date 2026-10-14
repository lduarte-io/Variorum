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
    private func host(_ surface: MobileWriteSurfaceView) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
        let controller = UIViewController()
        controller.view.addSubview(surface)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        _ = surface.textView.becomeFirstResponder()
        return window
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
            defer { window.isHidden = true; window.rootViewController = nil }
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
            defer { window.isHidden = true; window.rootViewController = nil }
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
}
