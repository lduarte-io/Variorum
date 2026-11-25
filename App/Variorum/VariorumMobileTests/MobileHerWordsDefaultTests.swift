//
//  MobileHerWordsDefaultTests.swift
//  VariorumMobileTests
//
//  VM-254 (the VM-260 run, batch 3) — **HER WORDS ONE NOTCH SMALLER BY DEFAULT.**
//  Her pick at kickoff (R-260-2): "Setting + smaller default" — a text-size row in
//  Settings ▸ Look scaling her words only, AND the default one notch under today's
//  set; the chrome where batch 2 left it, the 13 pt floor standing. The note's
//  title already took its notch at VM-272 (24 → 20 — the batch-2 flag, A-260-9),
//  so it keeps 20.
//
//  The traced road: her words are roles in ONE table (`PhoneType.swift`) — the
//  note's body, a note's and a screen's title, a row's title and its preview — and
//  the editor's face builds the note's body from the same table's `noteBody`
//  (`MobileEditorStyle.Face`). Today's set: 17 · 20 · 20 · 17 · 15 (Study; Terminal
//  two under).
//
//  THE PINS (RED ON OLD — the pre-fix tree is this file's own commit; only symbols
//  both trees declare):
//  · the table's her-words roles read one notch under today's set, the note's title
//    kept, Terminal two under and never under the floor, the chrome unmoved;
//  · the editor's note body — the face the open note wears — takes the smaller
//    body and its line, in both voices.
//

import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-254 — her words one notch under today's set, by default")
struct MobileHerWordsDefaultTests {
    /// **RED ON OLD** (17 · 20 · 17 · 15 — the note's body, a screen's title, a
    /// row's title and its preview). One notch under today's: the note's body
    /// 16 / 25, a screen's title 19 / 24, a row's title 16 / 21, its preview
    /// 14 / 19 — the pre-wave-1 phone's body (Iowan 16, the Mac's own) — the
    /// note's title kept at 20 / 25 (its notch taken at VM-272). Terminal two
    /// under, never under the floor (a row's preview holds 13 / 18 there). The
    /// chrome where batch 2 left it, one notch under her words still.
    @Test func herWordsSitOneNotchUnderTodaysSet() {
        func study(_ role: PhoneTypeRole) -> PhoneTypeSpec { PhoneType.spec(role, voice: .study) }
        func terminal(_ role: PhoneTypeRole) -> PhoneTypeSpec { PhoneType.spec(role, voice: .terminal) }
        let expected: [(PhoneTypeRole, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            // role, Study size / pitch, Terminal size / pitch
            (.noteBody, 16, 25, 14, 23),
            (.noteTitle, 20, 25, 18, 23),
            (.screenTitle, 19, 24, 17, 22),
            (.rowTitle, 16, 21, 14, 19),
            (.rowPreview, 14, 19, 13, 18),
        ]
        for (role, size, pitch, monoSize, monoPitch) in expected {
            #expect(study(role).size == size && study(role).lineHeight == pitch,
                    "\(role) in Study: \(study(role).size) / \(study(role).lineHeight)")
            #expect(terminal(role).size == monoSize && terminal(role).lineHeight == monoPitch,
                    "\(role) in Terminal: \(terminal(role).size) / \(terminal(role).lineHeight)")
        }
        // The chrome is batch 2's (P-260-2a) — unmoved, and still under her words.
        #expect(study(.control).size == 15 && study(.chip).size == 13
                && study(.controlInline).size == 13 && study(.tab).size == 17
                && study(.meta).size == 13 && study(.sectionHeader).size == 13)
        #expect(study(.control).size < study(.noteBody).size
                && study(.chip).size < study(.rowPreview).size)
        // The twelve words are not hers to size (the Protection screen's mono).
        #expect(study(.mono).size == 17)
    }

    /// **RED ON OLD** (Iowan 17 on 27; SF Mono 15 on 25). The face the open note
    /// wears builds its body from the table: Study Iowan 16 on a 25 pt line,
    /// Terminal SF Mono 14 on 23 — at the default text size, where
    /// `UIFontMetrics` is the identity.
    @Test func theNoteInWriteTakesTheSmallerBody() {
        MobileEditorStyle.adopt(Queries.ThemeSettings())
        defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
        #expect(MobileEditorStyle.terminalFace.body.pointSize == 14,
                "Terminal's note body: \(MobileEditorStyle.terminalFace.body.pointSize)")
        #expect(MobileEditorStyle.studyFace.body.pointSize == 16,
                "Study's note body: \(MobileEditorStyle.studyFace.body.pointSize)")
        let terminalPitch = MobileEditorStyle.baseFont.lineHeight
            + MobileEditorStyle.baseParagraphStyle.lineSpacing
        #expect(abs(terminalPitch - 23) <= 0.5, "Terminal's line: \(terminalPitch)")
        MobileEditorStyle.voice = .study
        let studyPitch = MobileEditorStyle.baseFont.lineHeight
            + MobileEditorStyle.baseParagraphStyle.lineSpacing
        #expect(abs(studyPitch - 25) <= 0.5, "Study's line: \(studyPitch)")
    }
}
