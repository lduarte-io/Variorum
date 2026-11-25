//
//  MobileTextSizeTests.swift
//  VariorumMobileTests
//
//  VM-254 (the VM-260 run, batch 3) — **HER WORDS ARE HERS TO SIZE.** Her pick
//  R-260-2: "Setting + smaller default" — a text-size row in Settings ▸ Look
//  scaling her words only; the chrome fixed; the 13 pt floor standing. The
//  default's red-on-old pin is `MobileHerWordsDefaultTests`. These pin the
//  setting itself — new behaviour, so GUARDS on the tip (the symbols are new):
//  · the five steps scale exactly the roles that follow the text size, size and
//    pitch alike, and nothing else; the note's body in Study reads 14 · 15 · 16 ·
//    17 · 18; Terminal's prose two under Study's at every step (ladder round 1,
//    R1-9 — red on its own old tree, the commit that adds it); nothing anywhere
//    under 13, at any step, any system text size, in either voice and either form;
//  · the step reaches a mounted her-words line through the environment, and a
//    chrome line beside it does not move;
//  · the editor face takes the step on the note's body and its UIKit roles,
//    sharing every colour object, and an OPEN note re-bases on it — with no
//    `setting` row written.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-254 — her words' size: five steps, her words only", .serialized)
struct MobileTextSizeTests {
    private static let everySetting: [UIContentSizeCategory] = [
        .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge,
        .extraExtraExtraLarge, .accessibilityMedium, .accessibilityLarge,
        .accessibilityExtraLarge, .accessibilityExtraExtraLarge,
        .accessibilityExtraExtraExtraLarge,
    ]

    /// **The five steps, her words only.** At each step a role that follows the
    /// text size takes the step's scale on Study's size — rounded to a whole point
    /// (MOVED with the batch-3 reconcile: UIKit's scaled fonts do not keep a
    /// fraction) — and its pitch moves with the size (never under the floor);
    /// Terminal's is Study's step two under, size and pitch alike, never under the
    /// floor (MOVED with ladder round 1's R1-9: Terminal derives FROM Study's
    /// rounded step, so its own table scaled and rounded no longer stands in for
    /// it); every other role — the chrome, the twelve words — is its table spec
    /// exactly. The note's body in Study: 14 · 15 · 16 · 17 · 18; "Large" is wave
    /// 1's 17 back.
    @Test func theFiveStepsScaleHerWordsOnly() {
        #expect(MobileTextSize.allCases == [.smaller, .small, .standard, .large, .larger])
        #expect(MobileTextSize.standard.wordsScale == 1, "the default is the table itself")
        let bodies: [MobileTextSize: CGFloat] = [.smaller: 14, .small: 15, .standard: 16, .large: 17, .larger: 18]
        for (step, body) in bodies {
            #expect(PhoneType.spec(.noteBody, voice: .study, wordsScale: step.wordsScale).size == body,
                    "Study's note body at \(step)")
        }
        let follows: Set<PhoneTypeRole> = [.noteBody, .noteTitle, .screenTitle, .rowTitle, .rowPreview]
        for role in PhoneTypeRole.allCases {
            #expect(role.followsTextSize == follows.contains(role), "\(role)")
        }
        for step in MobileTextSize.allCases {
            for voice in ThemeVoice.allCases {
                for role in PhoneTypeRole.allCases {
                    let table = PhoneType.spec(role, voice: voice)
                    let scaled = PhoneType.spec(role, voice: voice, wordsScale: step.wordsScale)
                    if role.followsTextSize {
                        // Study's step: its table × the step, a whole point, the floor under it.
                        let studyTable = PhoneType.spec(role, voice: .study)
                        let studySize = max(PhoneType.floorSize, (studyTable.size * step.wordsScale).rounded())
                        let studyPitch = studyTable.lineHeight * studySize / studyTable.size
                        // Terminal's: that step two under, the pitch with it (the default's own rule).
                        let size = voice == .terminal ? max(PhoneType.floorSize, studySize - 2) : studySize
                        let pitch = studyPitch - (studySize - size)
                        #expect(abs(scaled.size - size) < 0.001, "\(role) \(voice) at \(step): \(scaled.size)")
                        #expect(abs(scaled.lineHeight - pitch) < 0.001,
                                "\(role) \(voice) at \(step): pitch \(scaled.lineHeight), not \(pitch)")
                        #expect(scaled.family == table.family && scaled.anchor == table.anchor
                                && scaled.scaling == table.scaling && scaled.weight == table.weight)
                    } else {
                        #expect(scaled == table, "\(role) \(voice) does not move at \(step)")
                    }
                }
            }
        }
    }

    /// **R1-9 (ladder round 1) — Terminal's prose stays two under Study's at
    /// every step**, the floor still binding: the type layer's own claim ("its
    /// prose roles two points under Study's … never under the floor"), held at
    /// every step and every role that follows the text size — not only at the
    /// default. RED ON OLD (Terminal's own table scaled and rounded drifted off
    /// Study's rounded step): the note's title at Larger (Study 23, Terminal 20 —
    /// three under), and the row's preview at Large and Larger (Study 15 · 16,
    /// Terminal 14 · 15 — one under; the floor holds it at 13 · 14).
    @Test func terminalsProseStaysTwoUnderStudysAtEveryStep() {
        var off: [String] = []
        for step in MobileTextSize.allCases {
            for role in PhoneTypeRole.allCases where role.followsTextSize {
                let study = PhoneType.spec(role, voice: .study, wordsScale: step.wordsScale).size
                let terminal = PhoneType.spec(role, voice: .terminal, wordsScale: step.wordsScale).size
                let twoUnder = max(PhoneType.floorSize, study - 2)
                if terminal != twoUnder { off.append("\(role) \(step) Study \(study) Terminal \(terminal)") }
                #expect(terminal == twoUnder,
                        "\(role) at \(step): Terminal \(terminal), two under Study's \(study) is \(twoUnder)")
            }
        }
        print("PERF[sim] VM-260 R1-9 Terminal off two-under — \(off.count): \(off.joined(separator: " · "))")
    }

    /// **Nothing under 13, at any step** — in the SwiftUI rule and the UIKit
    /// form, at every system text size, both voices, every role.
    @Test func nothingIsEverBelowThirteenPointsAtAnyStep() {
        for step in MobileTextSize.allCases {
            for voice in ThemeVoice.allCases {
                for role in PhoneTypeRole.allCases {
                    let spec = PhoneType.spec(role, voice: voice, wordsScale: step.wordsScale)
                    #expect(spec.size >= PhoneType.floorSize, "\(role) \(voice) \(step) table size")
                    for setting in Self.everySetting {
                        #expect(PhoneType.pointSize(spec, at: setting) >= PhoneType.floorSize,
                                "\(role) \(voice) \(step) at \(setting.rawValue)")
                        let font = PhoneType.uiFont(
                            role, voice: voice,
                            compatibleWith: UITraitCollection(preferredContentSizeCategory: setting),
                            wordsScale: step.wordsScale)
                        #expect(font.pointSize >= PhoneType.floorSize,
                                "\(role) \(voice) \(step) UIKit at \(setting.rawValue): \(font.pointSize)")
                    }
                }
            }
        }
    }

    /// **The step reaches a mounted line of her words, and not the chrome beside
    /// it** — through the type layer's one environment value: a row's title grows
    /// by the step's share while a control's word stays exactly where it was.
    @Test func aStepReachesHerWordsOnAMountedScreenAndNotTheChrome() async throws {
        let tokens = VoiceTokens.resolve(voice: .study, dark: false)
        @MainActor func heights(_ scale: CGFloat) async throws -> (words: CGFloat, chrome: CGFloat) {
            let view = VStack(alignment: .leading, spacing: 8) {
                Text("Her words").phoneType(.rowTitle, tokens).accessibilityLabel("words line")
                Text("Done").phoneType(.control, tokens).accessibilityLabel("chrome line")
            }
            .fixedSize()
            .environment(\.phoneWordsScale, scale)
            return try await withHostedSurface(view, size: CGSize(width: 402, height: 300)) { surface in
                await surface.settle(10)
                let words = try #require(surface.element(labeled: "words line")?.accessibilityFrame)
                let chrome = try #require(surface.element(labeled: "chrome line")?.accessibilityFrame)
                return (words.height, chrome.height)
            }
        }
        let standard = try await heights(MobileTextSize.standard.wordsScale)
        let larger = try await heights(MobileTextSize.larger.wordsScale)
        let smaller = try await heights(MobileTextSize.smaller.wordsScale)
        print("PERF[sim] VM-254 mounted lines — words \(smaller.words) / \(standard.words) / \(larger.words), "
              + "chrome \(smaller.chrome) / \(standard.chrome) / \(larger.chrome)")
        #expect(larger.words > standard.words + 1, "a row's title grows at Larger: \(standard.words) → \(larger.words)")
        #expect(smaller.words < standard.words - 1, "and shrinks at Smaller: \(standard.words) → \(smaller.words)")
        #expect(abs(larger.chrome - standard.chrome) < 0.5 && abs(smaller.chrome - standard.chrome) < 0.5,
                "the chrome never moves with her words' size")
    }

    /// **RECONCILE — every step is a whole point** (the final evidence window's red;
    /// the trace is the record's batch-3 RECONCILE): a role's size at every step, in
    /// both voices, is a whole number of points — the kind every size in the sheet
    /// is, and the kind UIKit's `UIFontMetrics.scaledFont` keeps unchanged at the
    /// default text size. RED ON THE PRE-FIX TREE (27 issues: Study's note title and
    /// screen title at four steps each and its row preview at three; Terminal's note
    /// body, row title at three, note title and screen title at four, row preview at
    /// two).
    @Test func everyStepIsAWholePoint() {
        var fractional: [String] = []
        for step in MobileTextSize.allCases {
            for voice in ThemeVoice.allCases {
                for role in PhoneTypeRole.allCases where role.followsTextSize {
                    let size = PhoneType.spec(role, voice: voice, wordsScale: step.wordsScale).size
                    if size != size.rounded() { fractional.append("\(role) \(voice) \(step) \(size)") }
                    #expect(size == size.rounded(), "\(role) \(voice) at \(step): \(size)")
                }
            }
        }
        print("PERF[sim] VM-254 fractional step sizes — \(fractional.count): \(fractional.joined(separator: " · "))")
    }

    /// **RECONCILE — the two forms agree at every step** (the window's red, at its
    /// root): at the default text size, a role's UIKit font (`PhoneType.uiFont` —
    /// the editor face's roles, the comments sheet's draft, the take browser's and
    /// History's titles) is the same size as its SwiftUI form (`PhoneType.pointSize`
    /// — every `phoneType` line), at every step, both voices, every role that follows
    /// the text size. RED ON THE PRE-FIX TREE at every fractional size — 27 if UIKit
    /// snaps to a whole point, 25 if to a half (Study's note title at 17.5 and 22.5
    /// would then agree); the printed list says which grid. (Away from the default
    /// text size the two forms keep VM-47's measured third-of-a-point gap — not this
    /// pin's, unchanged.)
    @Test func theTwoFormsAgreeAtEveryStep() {
        let large = UITraitCollection(preferredContentSizeCategory: .large)
        var disagreements: [String] = []
        for step in MobileTextSize.allCases {
            for voice in ThemeVoice.allCases {
                for role in PhoneTypeRole.allCases where role.followsTextSize {
                    let spec = PhoneType.spec(role, voice: voice, wordsScale: step.wordsScale)
                    let swiftUI = PhoneType.pointSize(spec, at: .large)
                    let uiKit = PhoneType.uiFont(
                        role, voice: voice, compatibleWith: large, wordsScale: step.wordsScale).pointSize
                    if abs(swiftUI - uiKit) >= 0.01 {
                        disagreements.append("\(role) \(voice) \(step) SwiftUI \(swiftUI) UIKit \(uiKit)")
                    }
                    #expect(abs(swiftUI - uiKit) < 0.01,
                            "\(role) \(voice) at \(step): SwiftUI \(swiftUI), UIKit \(uiKit)")
                }
            }
        }
        print("PERF[sim] VM-254 the two forms at the default text size — \(disagreements.count) disagree: "
              + disagreements.joined(separator: " · "))
    }

    /// **The editor face takes the step** on the note's body and every UIKit role
    /// that follows the text size — the chrome's UIKit roles unmoved — sharing
    /// every colour object with the voice's face; a step already worn moves
    /// nothing.
    @Test func theEditorFaceTakesTheStep() {
        defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
        var study = Queries.ThemeSettings()
        study.voice = .study
        MobileEditorStyle.adopt(study)
        let standardControl = MobileEditorStyle.face.font(.control).pointSize
        #expect(MobileEditorStyle.adopt(study, wordsScale: MobileTextSize.larger.wordsScale),
                "a step moves the face")
        #expect(!MobileEditorStyle.adopt(study, wordsScale: MobileTextSize.larger.wordsScale),
                "the same step again moves nothing")
        #expect(abs(MobileEditorStyle.baseFont.pointSize - 18) < 0.01, "the note's body at Larger")
        #expect(MobileEditorStyle.baseFont.familyName == "Iowan Old Style")
        // RECONCILE (the final evidence window's red, 0.25 off 15.75 — the trace is the
        // record's batch-3 RECONCILE): the face's UIKit row preview at Larger is the
        // SAME size as the role's SwiftUI form at the default text size, and a whole
        // point (14 × 18/16 = 15.75 rounds to 16). The size it read is printed, so a
        // red says it.
        let preview = MobileEditorStyle.face.font(.rowPreview).pointSize
        let previewSpec = PhoneType.spec(.rowPreview, voice: .study, wordsScale: MobileTextSize.larger.wordsScale)
        let previewSwiftUI = PhoneType.pointSize(previewSpec, at: .large)
        print("PERF[sim] VM-254 the face's row preview at Larger — UIKit \(preview), SwiftUI \(previewSwiftUI), "
              + "the step's spec \(previewSpec.size)")
        #expect(abs(preview - previewSwiftUI) < 0.01,
                "a UIKit row preview takes the step at the SwiftUI form's size: UIKit \(preview), SwiftUI \(previewSwiftUI)")
        #expect(abs(preview - 16) < 0.01, "the row preview at Larger is a whole point, 16: \(preview)")
        #expect(abs(MobileEditorStyle.face.font(.control).pointSize - standardControl) < 0.01,
                "a UIKit control's word does not")
        #expect(MobileEditorStyle.face.ink === MobileEditorStyle.studyFace.ink, "the voice's colours, shared")
        #expect(MobileEditorStyle.face.surface === MobileEditorStyle.studyFace.surface)
        let pitch = MobileEditorStyle.baseFont.lineHeight + MobileEditorStyle.baseParagraphStyle.lineSpacing
        #expect(abs(pitch - 25 * 1.125) <= 0.5, "the line moves with the body: \(pitch)")
        MobileEditorStyle.adopt(study, wordsScale: MobileTextSize.smaller.wordsScale)
        #expect(abs(MobileEditorStyle.baseFont.pointSize - 14) < 0.01, "the note's body at Smaller")
        MobileEditorStyle.adopt(study)
        #expect(MobileEditorStyle.baseFont == MobileEditorStyle.studyFace.body, "the default is the voice's face")
    }

    /// **A step chosen on the phone re-bases an OPEN note** (the flip road —
    /// attributes only, never a character) and writes no `setting` row.
    @Test func aStepChosenOnThePhoneRebasesAnOpenNote() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "sized", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Sized text.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            let router = MobileShellRouter()
            router.bindTheme(session: session)
            let theme = try #require(router.theme)
            let held = Task { await theme.start() }
            defer { held.cancel() }
            await router.editors.register(model, tab: .shelf)
            try await untilLanded { MobileEditorStyle.voice == .study }
            let text = storage.string
            let rows = try await session.database.read { db in
                try Row.fetchAll(db, sql: "SELECT key, value FROM setting ORDER BY key")
                    .map { "\($0["key"] as String)=\($0["value"] as String)" }
            }

            router.look.setTextSize(.larger)
            let larger = storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(abs((larger?.pointSize ?? 0) - 18) < 0.01, "the open note at Larger: \(String(describing: larger))")
            router.look.setTextSize(.standard)
            let back = storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(back == MobileEditorStyle.studyFace.body, "and back at the default")
            #expect(storage.string == text, "attributes only — never a character")
            let after = try await session.database.read { db in
                try Row.fetchAll(db, sql: "SELECT key, value FROM setting ORDER BY key")
                    .map { "\($0["key"] as String)=\($0["value"] as String)" }
            }
            #expect(after == rows, "her words' size is the device's, never a library setting")
        }
    }
}
