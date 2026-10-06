//
//  LibraryCardFaceTests.swift
//  VariorumTests
//
//  **librarywalkpolish VR-117 — Terminal's Cards readability pass** (R-LWP-5,
//  her words: "let's fix terminal looking so impossible to read on the cards
//  somehow (we can change the font size or spacing to make it more
//  readable)"). A ruled TASTE row — her eye judges the captures at the
//  re-walk; this pin holds the two facts the ruling binds: Study's Cards do
//  not move (the shipped face, byte for byte), and Terminal's preview reads
//  larger and looser from the voice's own type slots (no new literal).
//

import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("librarywalkpolish VR-117 — Terminal's Cards readable; Study's untouched")
struct LibraryCardFaceTests {
    @Test func studyKeepsTheShippedCard() {
        for study in [VoiceTokens.studyLight, .studyDark] {
            let face = LibraryCardFace.of(study)
            #expect(face.previewFont == study.small)
            #expect(face.previewLineSpacing == 0 && face.leadToPreview == 2 && face.verticalPadding == 9,
                    "Study's Cards are the shipped face")
        }
    }

    @Test func terminalReadsLargerAndLooser() {
        for terminal in [VoiceTokens.terminalLight, .terminalDark] {
            let face = LibraryCardFace.of(terminal)
            let shipped = LibraryCardFace.shipped(terminal)
            #expect(face.previewFont == terminal.navigation, "the voice's own 13-pt register")
            #expect(face.previewFont != shipped.previewFont)
            #expect(face.previewLineSpacing > shipped.previewLineSpacing)
            #expect(face.leadToPreview > shipped.leadToPreview)
            #expect(face.verticalPadding > shipped.verticalPadding)
        }
    }
}
