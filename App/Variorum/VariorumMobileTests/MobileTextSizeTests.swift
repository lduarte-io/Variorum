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
//    17 · 18; nothing anywhere under 13, at any step, any system text size, in
//    either voice and either form;
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
    /// text size takes the step's scale on its size and its pitch (never under the
    /// floor); every other role — the chrome, the twelve words — is its table spec
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
                        let size = max(PhoneType.floorSize, table.size * step.wordsScale)
                        #expect(abs(scaled.size - size) < 0.001, "\(role) \(voice) at \(step): \(scaled.size)")
                        #expect(abs(scaled.lineHeight - table.lineHeight * size / table.size) < 0.001,
                                "\(role) \(voice) at \(step): pitch \(scaled.lineHeight)")
                        #expect(scaled.family == table.family && scaled.anchor == table.anchor
                                && scaled.scaling == table.scaling && scaled.weight == table.weight)
                    } else {
                        #expect(scaled == table, "\(role) \(voice) does not move at \(step)")
                    }
                }
            }
        }
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
        #expect(abs(MobileEditorStyle.face.font(.rowPreview).pointSize - 14 * 1.125) < 0.01,
                "a UIKit row preview takes the step")
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
