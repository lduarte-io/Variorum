//
//  BookTagsSwitchTests.swift
//  VariorumTests
//
//  **VX-1038 (T-5 / R-1036-39) — the per-book tags switch's face**: three
//  positions in the ruling's order, hidden first; each named on the chip and
//  in the menu; the chip's act chooses exactly the picked position. Pure (a
//  value and a closure), so it runs headless too. The memory per book is
//  `BookCardTagsTests`; the positions' pills are `NotePlacingTagsTests` (core).
//

import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1038 — the per-book tags switch's face")
struct BookTagsSwitchTests {
    @Test func theChipNamesThePositionInForce() {
        #expect(BookTagsSwitchCopy.chip(.hidden) == "tags: hidden")
        #expect(BookTagsSwitchCopy.chip(.otherTags) == "tags: other")
        #expect(BookTagsSwitchCopy.chip(.allTags) == "tags: all")
    }

    @Test func theMenuOffersTheRulingsThreePositionsInOrder() {
        #expect(BookTagsShown.allCases.map(BookTagsSwitchCopy.row) == ["Hidden", "Other tags", "All tags"])
    }

    @Test func everyWordIsSentenceCaseAndNamesNoPlatformDoor() {
        let words = BookTagsShown.allCases.flatMap { [BookTagsSwitchCopy.chip($0), BookTagsSwitchCopy.row($0)] }
            + [BookTagsSwitchCopy.help]
        for word in words {
            #expect(word.uppercased() != word, "no shouty caps: \(word)")
            #expect(!word.contains("TAGS") && !word.contains("ALL"), "\(word)")
        }
        #expect(BookTagsSwitchCopy.help.contains("this Mac"), "the memory's reach said plainly")
    }

    @Test func theFaceIsAValueAndAClosure() {
        var chosen: [BookTagsShown] = []
        let face = BookTagsSwitch(
            tokens: .fallback(for: .light), position: .otherTags, choose: { chosen.append($0) })
        #expect(face.position == .otherTags)
        face.choose(.allTags)
        #expect(chosen == [.allTags])
    }

    @Test func theBookViewDeclaresTheTaggingActItsHeadersRender() {
        #expect(BookView.surfaceCapabilities.contains(.tagNote),
                "the card headers' + and pills' × are the note-tagging act's book renderer (P-1)")
    }
}
