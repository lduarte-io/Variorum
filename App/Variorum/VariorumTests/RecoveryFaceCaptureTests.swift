//
//  RecoveryFaceCaptureTests.swift
//  VariorumTests
//
//  Phase 13j, batch 3 — THE VISUAL LOOP for the one new face that CAN be
//  rendered offscreen.
//
//  Batch 2 measured the limit and it still holds: SwiftUI `List` is
//  NSTableView-backed, and `ImageRenderer` renders its unsupported-view
//  placeholder instead of the panel — so the tray panel and the J3 PEEK are
//  hand-check items, named as such in the batch record rather than faked
//  here. The `BlockPastSection` is a plain `VStack` of text and small
//  buttons, so it renders at full fidelity, and it is the chrome that most
//  needs looking at: it appears INSIDE an existing surface (the History
//  face), where "quiet" is the whole design requirement.
//
//  Same harness shape as `ContextBarCaptureTests` (13k batch 3): the test
//  host is sandboxed, so it writes into the host's own temp directory and
//  prints the path; LIGHT only, because this project's offscreen dark
//  renders resolve the wrong appearance (13g batch 2's recorded finding).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("The block-past region's capture (13j J3 — the visual loop)")
struct RecoveryFaceCaptureTests {
    private static let outputDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("variorum-13j-batch3-screens")

    private func take(_ id: String, label: String?, text: String, deletedAt: Date?) -> Variant {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Variant(
            id: id, blockId: "b", workingText: text, label: label,
            fanPosition: "a", createdAt: now, updatedAt: now, deletedAt: deletedAt)
    }

    @Test func captureTheHistoryFacesPastRegion() throws {
        try FileManager.default.createDirectory(
            at: Self.outputDirectory, withIntermediateDirectories: true)
        let db = try AppDatabase.inMemory()
        // 13j batch 6: the session now carries a READ-side clock (the 30-day
        // Trash window is a required argument everywhere it applies), and a
        // dependency read with no override is an issue in a test context by
        // design — so this synthetic world says what time it is, like every
        // other harness here.
        let session = withDependencies {
            $0.database = db
            $0.date = DateGenerator { harnessNow }
        } operation: { AppSession(database: db) }
        let deletedAt = Date(timeIntervalSince1970: 1_782_950_400)

        let states: [(String, Queries.BlockPast)] = [
            ("1-lineage-only", Queries.BlockPast(
                origins: [Queries.UnplacedOrigin(
                    blockID: "origin", originOp: "divide",
                    at: "2026-08-18T09:30:00.000Z")])),
            ("2-deleted-takes-only", Queries.BlockPast(
                deletedTakes: [
                    take("v1", label: "bolder opening", text: "A bolder run at it.",
                         deletedAt: deletedAt),
                    take("v2", label: nil,
                         text: "An unlabelled take whose first line stands in for its name.",
                         deletedAt: deletedAt),
                ])),
            ("3-both-a-merge-and-two-deleted", Queries.BlockPast(
                deletedTakes: [
                    take("v1", label: "bolder opening", text: "A bolder run at it.",
                         deletedAt: deletedAt),
                    take("v2", label: nil, text: "", deletedAt: deletedAt),
                ],
                origins: [Queries.UnplacedOrigin(
                    blockID: "origin", originOp: "merge",
                    at: "2026-08-18T09:30:00.000Z")])),
        ]

        for (voiceName, tokens) in [
            ("terminal", VoiceTokens.terminalLight), ("study", VoiceTokens.studyLight),
        ] {
            for (name, past) in states {
                let model = BlockPastModel(session: session, blockID: "b")
                model.adopt(past)
                try writeImage(
                    BlockPastSection(model: model, tokens: tokens, onSeeOrigin: { _ in })
                        .frame(width: 560, alignment: .leading)
                        .background(tokens.room)
                        .padding(8)
                        .background(tokens.surface),
                    to: "\(voiceName)-\(name).png")
            }
        }
        print("13j batch 3 captures: \(Self.outputDirectory.path)")
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
