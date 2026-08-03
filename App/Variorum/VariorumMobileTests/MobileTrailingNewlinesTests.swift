//
//  MobileTrailingNewlinesTests.swift
//  VariorumMobileTests
//
//  THE L9 PIN (mobile ledger row L9 — this row owns the KnownIssues "iOS
//  capture editor accrues trailing blank lines" entry): the NEW continuous
//  editor never accrues trailing blank lines BY ACCIDENT, while MEANINGFUL
//  stored spacing (the 2026-07-12 ruling: typed/pasted gaps persist as
//  trailing block content, k−1 with the separator re-creating the last)
//  round-trips byte-exactly — NEVER a blanket trim.
//
//  The Phase 8 defect's mechanism lived in the SwiftUI TextEditor
//  focus-swap surface, which this editor REPLACES rather than patches (the
//  old view layer is not headless-reproducible; recorded honestly in the
//  batch record). What this pin guards is the new editor's every
//  store-write door, both ways:
//    - the ACCRUAL direction: open/render/edit/teardown cycles never write
//      a byte the author didn't type (no invented trailing whitespace);
//    - the TRIM direction: stored trailing newlines are content (I4) and
//      survive every cycle untouched — the forbidden "fix" class (a
//      blanket trim) goes red here by construction.
//  Discrimination was revert-verified at build time (both directions
//  deliberately broken locally, observed red, restored — the batch record
//  has the exact reds).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("The L9 trailing-newlines pin (S1 batch 1)")
struct MobileTrailingNewlinesTests {
    /// The accrual half, the Phase 8 defect's shape: repeated open →
    /// render → (no typing) → teardown cycles must leave the stored bytes
    /// EXACTLY as they were — the old capture surface grew stored trailing
    /// newlines under exactly this traffic.
    @Test func openRenderCloseCyclesNeverChangeStoredBytes() async throws {
        try await withEditorWorld { session, db in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-08-03")
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: entry.container.id, text: "Today was fine.", at: .end)
            }

            for cycle in 0..<5 {
                let (model, storage) = makeEditor(session, postID: entry.container.id)
                await model.loadOnce()
                #expect(storage.string == "Today was fine.")
                await model.finish()
                let stored = try await storedText(db, variantID: minted.variant.id)
                #expect(stored == "Today was fine.",
                        "cycle \(cycle): bytes the author never typed appeared")
                #expect(model.autosave.flushCount == 0,
                        "cycle \(cycle): an editless open/close wrote to the store")
            }
        }
    }

    /// Typing appends exactly the typed bytes — no trailing whitespace is
    /// ever invented around an edit, across cycles.
    @Test func typingWritesExactlyTheTypedBytesAcrossCycles() async throws {
        try await withEditorWorld { session, db in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-08-03")
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: entry.container.id, text: "Start.", at: .end)
            }

            var expected = "Start."
            for cycle in 0..<3 {
                let (model, storage) = makeEditor(session, postID: entry.container.id)
                await model.loadOnce()
                typeAtEnd(model, storage, " More\(cycle).")
                await model.awaitMintSettle()
                await model.finish()
                expected += " More\(cycle)."
                #expect(try await storedText(db, variantID: minted.variant.id) == expected,
                        "cycle \(cycle): the store must hold exactly what was typed")
            }
        }
    }

    /// The meaningful half, typed path: deliberate trailing Enters at the
    /// document end are DURABLE CONTENT the moment they exist (the
    /// 2026-07-12 rule's letter — the leading-run attachment folds them
    /// into the preceding block), and they survive re-open and teardown
    /// untouched. A blanket trim anywhere goes red here.
    @Test func deliberateTrailingEntersPersistAsContentAndNeverTrim() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "typed gap", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // Enter opens the tail; each further Enter is tail content the
            // attachment immediately folds into the block as its trailing
            // newline (bytes never move).
            typeAtEnd(model, storage, "\n")
            typeAtEnd(model, storage, "\n")
            typeAtEnd(model, storage, "\n")
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: minted.variant.id) == "Alpha.\n\n",
                    "typed trailing gap: k Enters store k−1 newlines (the separator is the +1)")

            await model.finish()
            #expect(try await storedText(db, variantID: minted.variant.id) == "Alpha.\n\n",
                    "teardown must not trim the deliberate gap")

            // Re-open: the stored spacing renders and survives an editless
            // close — never a blanket trim.
            let (reopened, restorage) = makeEditor(session, postID: post.id)
            await reopened.loadOnce()
            #expect(restorage.string == "Alpha.\n\n")
            await reopened.finish()
            #expect(try await storedText(db, variantID: minted.variant.id) == "Alpha.\n\n")
        }
    }

    /// The meaningful half, pasted path: a pasted gap stores per the k−1
    /// rule and round-trips byte-exactly through open/close cycles.
    @Test func pastedGapsRoundTripByteExactly() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "pasted gap", profile: .blog)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            typeAtEnd(model, storage, "One\n\nTwo", isPaste: true)
            await model.awaitMintSettle()
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: post.id) == ["One\n", "Two"])

            let (reopened, restorage) = makeEditor(session, postID: post.id)
            await reopened.loadOnce()
            #expect(restorage.string == "One\n\nTwo", "the separator re-creates the pasted gap exactly")
            await reopened.finish()
            #expect(try await storedBlockTexts(db, postID: post.id) == ["One\n", "Two"],
                    "an editless round trip changes nothing")
        }
    }

    /// Editing a NEIGHBOR never touches another block's stored spacing —
    /// the trim must not hide inside an unrelated block's autosave.
    @Test func editingANeighborNeverTouchesStoredSpacing() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "neighbor", profile: .blog)
            }
            let spaced = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "First.\n\n", at: .end)
            }
            let plain = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Second.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            #expect(storage.string == "First.\n\n\nSecond.")

            // Append to block 2 (its entry starts after "First.\n\n" + sep).
            typeAtEnd(model, storage, " Edited.")
            await model.finish()

            #expect(try await storedText(db, variantID: plain.variant.id) == "Second. Edited.")
            #expect(try await storedText(db, variantID: spaced.variant.id) == "First.\n\n",
                    "the neighbor's stored spacing is byte-untouched")
        }
    }
}
