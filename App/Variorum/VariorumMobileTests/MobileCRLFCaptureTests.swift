//
//  MobileCRLFCaptureTests.swift
//  VariorumMobileTests
//
//  18o U2 — 17e P23 at the PHONE's capture door. The home-screen box mints
//  through `importPost` (A5-2: "the paste that arrived before the mint
//  segments correctly for free"), so a pre-mint paste carrying Windows line
//  endings used to mint ONE block — the whole capture — because
//  `SegmentationRules.bulkSegments` split on the `"\n"` Character only and
//  `"\r\n"` is one Character that is not it. The rule is core's
//  (`SegmentationLineEndingTests`); this pins that the phone's door rides it
//  AND that the box's ownership arithmetic survives it: `adopt` anchors the
//  owned block's STORED text inside the RAW snapshot (`frozenPrefix`), and the
//  owned last piece never carries a newline, so `text == frozenPrefix + tail`
//  still holds and continued typing grows ONLY the last block.
//
//  *Red on the old code:* one block holding the whole capture, an empty frozen
//  prefix. Verified by reverting `SegmentationRules.swift` (the U2 record).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("18o U2 — P23: a CRLF capture on the phone")
struct MobileCRLFCaptureTests {
    /// The quiet box (`MobileQuickNoteTests`' own harness shape): both clocks
    /// off, so the test mints and flushes explicitly.
    private func quietBox(_ session: AppSession) -> MobileQuickNoteModel {
        let model = MobileQuickNoteModel(session: session)
        model.sleep = { _ in throw CancellationError() }
        model.autosaveSleep = { _ in throw CancellationError() }
        return model
    }

    /// RED-ON-OLD — a CRLF pre-mint paste segments one block per paragraph,
    /// the box owns the LAST block, and typing on grows only that block.
    @Test func aCRLFPreMintPasteSegmentsAndTheBoxOwnsTheLastBlock() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "First paragraph.\r\n\r\nSecond paragraph."
            let postID = try #require(await box.mintNow())
            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["First paragraph.\n", "Second paragraph."],
                    "bulk entry segments on entry (AppSpec §7), whatever the line endings")
            #expect(box.frozenPrefix == "First paragraph.\r\n\r\n",
                    "the frozen prefix is the RAW text ahead of the owned block")

            box.text = "First paragraph.\r\n\r\nSecond paragraph. And more."
            await session.flushEveryOpenPost()
            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["First paragraph.\n", "Second paragraph. And more."],
                    "the box owns the LAST block; the one ahead of it is untouched")
        }
    }
}
