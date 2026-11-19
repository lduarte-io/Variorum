//
//  MobileMessageLineFaceTests.swift
//  VariorumMobileTests
//
//  The VM-47 run, batch 6 (the re-land of VM-55) — **THE ONE MESSAGE LINE ON
//  THE PHONE LAYER.** VM-55 built the phone's one line (VM-61) in the tokens of
//  its day — the Mac's 11.5 pt caption, a 14 pt word for its Undo — and left the
//  sizes to this run ("umbrella VM-47 owns sizes"). At the re-land it wears the
//  sizing sheet's receipt line (§E): one line 44 tall, the words SF 15, the act
//  15 semibold in the accent across a 44 pt hit area; and the library's look
//  (VM-51 — the shell hands its settings road), never the voice's bare colours.
//  VM-55's words, classes and timing are unchanged; its own pins
//  (`MobileMessageLineTests.swift`) hold the placement.
//
//  RED ON THE FACE IT REPLACES (by construction, not run): the act was the
//  word's own frame, about 14 pt tall; the model took no look.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// What the look was asked (a `@MainActor` closure cannot mutate a captured
/// `var`).
@MainActor
private final class LookAsks {
    var darks: [Bool] = []
}

@MainActor
@Suite("The one message line on the phone layer (the VM-55 re-land)", .serialized)
struct MobileMessageLineFaceTests {
    /// The line in a real window of the test host's scene (the way VM-55's
    /// inset pin stands it), fed an inset and the bar's height.
    private func standing(
        _ model: MobileMessageLineModel, inset: CGFloat = 34, bar: CGFloat = 56,
        _ body: (UIWindow) async throws -> Void
    ) async throws {
        let scene = try #require(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
            "the test host has a window scene")
        let window = UIWindow(windowScene: scene)
        model.safeBottom = inset
        model.chromeInset = bar
        window.rootViewController = UIHostingController(rootView: MobileMessageLineView(model: model))
        window.isHidden = false
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }
        try await body(window)
    }

    private func drawn(_ window: UIWindow, _ model: MobileMessageLineModel) async -> CGRect? {
        for _ in 0..<300 {
            window.layoutIfNeeded()
            if let door = model.doorFrame { return door }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return model.doorFrame
    }

    /// **The receipt line's act answers across 44 × 44, and the line is 44
    /// tall** — the act's hit area IS the line's height, so the line's foot
    /// sits exactly where VM-55's placement puts it (above the bar and the
    /// inset), in both voices.
    @Test func theLinesActAnswersAcrossFortyFourOnAFortyFourLine() async throws {
        for voice in [ThemeVoice.terminal, .study] {
            try await withEditorWorld { session, _ in
                let model = MobileMessageLineModel(status: session.status, voice: { voice })
                try await standing(model) { window in
                    session.status.removal(
                        "Block deleted.", undo: .init(label: MobileLine.undoLabel, perform: {}))
                    let door = try #require(await drawn(window, model), "the line drew its door")
                    #expect(door.width >= 43.5 && door.height >= 43.5,
                            "the act answers across 44 × 44 in \(voice): \(door)")
                    #expect(door.height <= 44.5, "one 44 pt line in \(voice): \(door)")
                    let foot = window.bounds.maxY - 34 - 56
                    #expect(abs(door.maxY - foot) <= 0.5,
                            "the act fills the line to its foot (above the bar and the inset): \(door), foot \(foot)")
                    session.status.clear()
                }
            }
        }
    }

    /// **The line wears the library's look** — the shell's settings road is
    /// what the face resolves (read live, so a palette landing on the Mac
    /// reaches it); a harness with no look keeps the voice's own.
    @Test func theLineWearsTheLibrarysLook() async throws {
        try await withEditorWorld { session, _ in
            let asked = LookAsks()
            let model = MobileMessageLineModel(
                status: session.status, voice: { .study },
                look: { dark in
                    asked.darks.append(dark)
                    return VoiceTokens.resolve(voice: .study, palette: .tealAndRust, tint: PaletteTint(), dark: dark)
                })
            try await standing(model) { window in
                session.status.refuse("That couldn't be done.")
                for _ in 0..<100 where asked.darks.isEmpty {
                    window.layoutIfNeeded()
                    try? await Task.sleep(for: .milliseconds(10))
                }
                #expect(!asked.darks.isEmpty, "the face resolved its tokens through the library's look")
                session.status.clear()
            }
        }
        // The shell hands the line its own settings road.
        let shell = try MobileProtectionCompositionTests.code(
            "VariorumMobile/Features/Shell/MobileShellView.swift")
        #expect(shell.contains("look: { [router] dark in router.tokens(dark: dark) }"),
                "the shell's one line reads the library's look")
    }
}
