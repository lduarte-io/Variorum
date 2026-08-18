//
//  ContextBarCaptureTests.swift
//  VariorumTests
//
//  Phase 13k, batch 3 — THE VISUAL LOOP, as a capture harness rather than a
//  hand-driven walk.
//
//  The bar is small, self-contained chrome that takes its tokens as a
//  parameter, so it renders offscreen at full fidelity from a handful of
//  states — which is exactly what the batch's propose-only set needs (one
//  book · several · none, cards visible · folded, forward live · grey).
//
//  It writes into the TEST HOST'S OWN TEMP DIRECTORY and prints the path —
//  the host is sandboxed (`Variorum.entitlements` + the target's ENABLE_*
//  settings), so a write into the repo would be denied, and an env-var gate
//  would need an environment `xcodebuild` does not forward to it. Both were
//  tried before this shape; recorded so the next session does not retry
//  them. The batch record names the one `cp` that carries the PNGs out.
//
//  LIGHT ONLY, deliberately: 13g batch 2 recorded that this project's
//  offscreen DARK renders resolve the wrong appearance, so a dark capture
//  would mislead rather than inform.
//
//  What it CANNOT capture, stated rather than implied: the book icon's
//  DROPDOWN is a popover, which has no offscreen presentation — it is on the
//  batch record's hand-check list.
//

import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("Context bar captures (13k K11/K12 — the visual loop)")
struct ContextBarCaptureTests {
    private static let outputDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("variorum-13k-batch3-screens")

    private func book(_ id: String, _ name: String, _ kind: ReadingKind) -> Reading {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Reading(id: id, name: name, kind: kind, createdAt: now, updatedAt: now)
    }

    private func tag(_ path: String) -> VariorumCore.Tag {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return VariorumCore.Tag(id: path, name: path, path: path, createdAt: now, updatedAt: now)
    }

    private func bar(
        tokens: VoiceTokens, origin: String?, forward: String?, books: [Reading],
        tags: [VariorumCore.Tag]?, folded: Bool,
        // 13j J2 — the tray badge's state. Defaulted to "nothing deleted",
        // so every state this harness already captured renders EXACTLY as it
        // did before the door existed (which is itself the claim her K11
        // ruling cares about: at rest, the bar is unchanged).
        trayDeleted: Int = 0, trayPreserved: Int = 0
    ) -> ContextBar {
        ContextBar(
            tokens: tokens, originLabel: origin, forwardLabel: forward, books: books,
            tagFace: tags.map {
                .init(tags: $0, allTags: $0, onApply: { _ in }, onRemove: { _ in })
            },
            tagsFolded: folded,
            trayFace: tags == nil ? nil : .init(
                deletedCount: trayDeleted, preservedCount: trayPreserved, onOpen: {}),
            onBack: {}, onForward: {}, onOpenBook: { _ in }, onToggleTags: {})
    }

    @Test func captureTheBarsStates() throws {
        try FileManager.default.createDirectory(
            at: Self.outputDirectory, withIntermediateDirectories: true)

        let one = [book("b1", "Orbit", .curated)]
        let several = [
            book("b1", "Orbit", .curated), book("b2", "Field Notes", .curated),
            book("b3", "Dreams", .smart),
        ]
        let tags = [tag("life/goals"), tag("work"), tag("reading/2026")]

        for (voiceName, tokens) in [
            ("terminal", VoiceTokens.terminalLight), ("study", VoiceTokens.studyLight),
        ] {
            let states: [(String, ContextBar)] = [
                ("1-one-book-cards-visible",
                 bar(tokens: tokens, origin: "Orbit", forward: nil, books: one,
                     tags: tags, folded: false)),
                ("2-several-books-forward-live",
                 bar(tokens: tokens, origin: "Library", forward: "Field Notes",
                     books: several, tags: tags, folded: false)),
                ("3-no-books-nothing-visited",
                 bar(tokens: tokens, origin: nil, forward: nil, books: [],
                     tags: tags, folded: false)),
                ("4-cards-folded-with-count",
                 bar(tokens: tokens, origin: "Orbit", forward: nil, books: one,
                     tags: tags, folded: true)),
                ("5-untagged-note",
                 bar(tokens: tokens, origin: "Shelf", forward: nil, books: one,
                     tags: [], folded: false)),
                ("6-a-place-not-a-note",
                 bar(tokens: tokens, origin: "Shelf", forward: "Orbit", books: [],
                     tags: nil, folded: false)),
                // 13j J2 — the TRAY BADGE, the bar's one conditional door.
                // States 1–6 above are all "nothing deleted", so the pair
                // 1 vs 7 is the picture of what her ruling asks for: calm at
                // rest, one quiet ⌫ N once this note has deleted something.
                ("7-tray-badge-one-deleted",
                 bar(tokens: tokens, origin: "Orbit", forward: nil, books: one,
                     tags: tags, folded: false, trayDeleted: 1)),
                ("8-tray-badge-with-originals-waiting",
                 bar(tokens: tokens, origin: "Orbit", forward: nil, books: one,
                     tags: tags, folded: false, trayDeleted: 3, trayPreserved: 2)),
            ]
            for (name, state) in states {
                try write(state, tokens: tokens, to: "\(voiceName)-\(name).png")
            }
        }
        // The path, on the record, because a sandboxed host's temp directory
        // is not a place anyone guesses.
        print("13k batch 3 captures: \(Self.outputDirectory.path)")
    }

    /// **R4-3's EXPERIMENT STRIP — propose-only.** Her round-4 words: *"i
    /// want to experiment with having a boxier look around it (maybe still
    /// with rounded corners, but a little more box like)"*. The shipped
    /// default is one of these; the strip exists so picking a different one
    /// is a glance and a one-number edit (`TagChipShape.cornerRadius`).
    ///
    /// One image per voice, the SAME note in every row, so the only variable
    /// down the strip is the radius.
    @Test func captureTheChipRadiusVariants() throws {
        try FileManager.default.createDirectory(
            at: Self.outputDirectory, withIntermediateDirectories: true)
        let one = [book("b1", "Orbit", .curated)]
        let tags = [tag("life/goals"), tag("work"), tag("reading/2026")]

        for (voiceName, tokens) in [
            ("terminal", VoiceTokens.terminalLight), ("study", VoiceTokens.studyLight),
        ] {
            let strip = VStack(alignment: .leading, spacing: 10) {
                ForEach(TagChipShape.variants, id: \.self) { radius in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(
                            radius == TagChipShape.cornerRadius
                                ? "\(Int(radius))pt — SHIPPED"
                                : "\(Int(radius))pt")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(tokens.muted)
                        ContextBar(
                            tokens: tokens, originLabel: "Orbit", forwardLabel: "Field Notes",
                            books: one,
                            tagFace: .init(
                                tags: tags, allTags: tags,
                                onApply: { _ in }, onRemove: { _ in }),
                            tagsFolded: false, chipCornerRadius: radius,
                            onBack: {}, onForward: {}, onOpenBook: { _ in },
                            onToggleTags: {})
                            .frame(width: 520, alignment: .leading)
                            .background(tokens.room)
                    }
                }
            }
            .padding(10)
            .background(tokens.surface)
            try writeImage(strip, to: "\(voiceName)-R4-3-radius-variants.png")
        }
    }

    /// One state, rendered at 2× on the voice's own room so the bar sits on
    /// the colour it sits on in the app.
    private func write(_ bar: ContextBar, tokens: VoiceTokens, to name: String) throws {
        try writeImage(
            bar
                .frame(width: 520, alignment: .leading)
                .background(tokens.room)
                .padding(8)
                .background(tokens.surface),
            to: name)
    }

    private func writeImage(_ view: some View, to name: String) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:])
        else {
            Issue.record("the renderer produced no image for \(name)")
            return
        }
        try png.write(to: Self.outputDirectory.appendingPathComponent(name))
    }
}
