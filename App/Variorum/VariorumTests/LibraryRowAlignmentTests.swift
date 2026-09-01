//
//  LibraryRowAlignmentTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch A — rows 10 + 11: **a Library row's
//  title, chips, ＋ and kind label sit on ONE text baseline.** Her reports:
//  *"the tags are also misaligned from the text"* (image 4) · *"the word
//  book is misaligned"* (image 5).
//
//  The pin mounts each row LINE alone in a hosted window and reads the
//  DEBUG `BaselineProbe` — every probed text's absolute baseline in the
//  line's own coordinate space — then asserts they agree within 1 pt.
//
//  Red-on-old (two mechanisms, both reproduced by the reverts named in the
//  batch record): the book row's HStack had NO baseline alignment, so the
//  small kind label centered against the title and its baseline sat ~2 pt
//  lower; the note row's chips handed the stack a symbol image's bottom
//  edge as their "baseline" (a `.center` chip stack whose first-baseline
//  guide resolved to the ✕ image), so the chip text sat under the title's
//  line by about the same.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Library rows sit on one baseline (correction round, rows 10/11)", .serialized)
struct LibraryRowAlignmentTests {
    private func tag(_ path: String) -> VariorumCore.Tag {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return VariorumCore.Tag(id: path, name: path, path: path, createdAt: now, updatedAt: now)
    }

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Mounts `content` in a window and lets it lay out.
    private func mount<V: View>(_ content: V) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 700, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: content.padding(12).frame(width: 700, height: 80, alignment: .leading))
        hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 80)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<12 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
        }
        return window
    }

    private func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.close()
    }

    @Test func aNoteRowsTitleChipsAndPlusShareOneBaselineInBothVoices() throws {
        for tokens in [VoiceTokens.terminalLight, VoiceTokens.studyLight] {
            #if DEBUG
            BaselineProbe.reset()
            #endif
            let window = mount(CatalogNoteLine(
                tokens: tokens, title: "three ways of working", date: nil,
                tags: [tag("tutorial"), tag("life/goals")], allTags: [],
                onTitleTap: {}, onApply: { _ in }, onRemove: { _ in }))
            defer { close(window) }
            #if DEBUG
            let title = try #require(BaselineProbe.baseline("note.title"), "the title reported")
            let chip = try #require(BaselineProbe.baseline("note.chip"), "the first chip's text reported")
            let plus = try #require(BaselineProbe.baseline("note.plus"), "the ＋ reported")
            #expect(abs(title - chip) <= 1,
                    "the chip text's baseline (\(chip)) sits on the title's (\(title)) within 1 pt")
            #expect(abs(title - plus) <= 1,
                    "the ＋'s baseline (\(plus)) sits on the title's (\(title)) within 1 pt")
            #endif
        }
    }

    @Test func aBookRowsTitleAndKindLabelShareOneBaselineInBothVoices() throws {
        for tokens in [VoiceTokens.terminalLight, VoiceTokens.studyLight] {
            #if DEBUG
            BaselineProbe.reset()
            #endif
            let window = mount(CatalogBookLine(
                tokens: tokens, title: "the field guide", detail: "book", onTitleTap: {}))
            defer { close(window) }
            #if DEBUG
            let title = try #require(BaselineProbe.baseline("book.title"), "the title reported")
            let kind = try #require(BaselineProbe.baseline("book.kind"), "the kind label reported")
            #expect(abs(title - kind) <= 1,
                    "the kind label's baseline (\(kind)) sits on the title's (\(title)) within 1 pt")
            #endif
        }
    }
}
