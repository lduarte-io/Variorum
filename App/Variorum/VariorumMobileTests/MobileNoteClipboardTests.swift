//
//  MobileNoteClipboardTests.swift
//  VariorumMobileTests
//
//  Round 2, batch 2 — M3 ≡ R6, the copy-the-whole-note door. Her ask,
//  verbatim: *"I also need a button added at the top that allows me to copy
//  everything i've written in a particular note."*
//
//  Every pin drives `MobileEditorViewModel.copyNote(to:)` — the exact call
//  the masthead's ⧉ makes (the view's whole body is
//  `Task { await model.copyNote() }`) — into a NAMED pasteboard, so the
//  real door runs end to end and the author's clipboard is never touched.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile copy note — the masthead's ⧉ (M3 ≡ R6)")
struct MobileNoteClipboardTests {
    /// A private board per pin, removed after use.
    private func withBoard<T>(
        _ name: String, _ body: (MobileClipboard.Destination) async throws -> T
    ) async rethrows -> T {
        let destination = MobileClipboard.Destination.named(name)
        defer { UIPasteboard.remove(withName: UIPasteboard.Name(name)) }
        return try await body(destination)
    }

    /// **The shape: the copy IS the export.** Not "like" it — byte-equal to
    /// `Queries.exportPost`, because the door calls that projection and
    /// stitches nothing of its own. The title is deliberately absent (a
    /// title is the note's handle, not something written inside it), and
    /// the blocks join through the one join brain.
    @Test func copyingANoteWritesExactlyWhatExportWrites() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["The first paragraph.", "The second one."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            try await withBoard("copy.export") { board in
                await model.copyNote(to: board)

                let exported = try await db.read { db in
                    try Queries.exportPost(db, postID: postID)
                }
                #expect(board.pasteboard.string == exported)
                #expect(board.pasteboard.string
                        == "The first paragraph.\n\nThe second one.")
                #expect(model.statusMessage
                        == MobileNoteClipboard.Outcome.copied.message)
            }
        }
    }

    /// **The defect this door must not re-open** (KnownIssues: *"Copy doors
    /// read the store past a dirty buffer"* — the Mac's 11a version-family
    /// doors). The buffer is deliberately authoritative while dirty, so a
    /// copy that reads the store without flushing hands her a note missing
    /// the last seconds of typing. Here the harness's autosave clock is
    /// disabled, so the ONLY thing that can put those keystrokes in the
    /// store is the door's own flush.
    ///
    /// **Revert-verified:** dropping `guard await flushPendingText()` from
    /// `copyNote` fails this pin — the board comes back with the pre-edit
    /// text ("Half a thought." instead of "Half a thought, then the rest.").
    @Test func theCopyTakesTheLastKeystrokesWithIt() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Half a thought."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage

            // Type into the block and DO NOT flush: the store still holds
            // the old bytes at this instant.
            let end = NSRange(location: storage.length - 1, length: 1)
            #expect(typeEdit(model, storage, range: end, replacement: ", then the rest."))
            let stored = try await db.read { db in
                try Queries.exportPost(db, postID: postID)
            }
            #expect(stored == "Half a thought.")

            try await withBoard("copy.dirty") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string == "Half a thought, then the rest.")
                #expect(model.statusMessage
                        == MobileNoteClipboard.Outcome.copied.message)
            }
        }
    }

    /// **The open tail rides too.** A paragraph she is still typing at the
    /// end has not crystallized into a block, so it exists only on the
    /// surface — and "everything i've written" includes it. It joins
    /// through the SAME brain, which is exactly the bytes it will export
    /// with once it mints.
    @Test func copyingCarriesTheParagraphStillBeingTyped() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["A finished paragraph."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage

            typeAtEnd(model, storage, "\n")
            typeAtEnd(model, storage, "Still typing this one")
            #expect(model.hasOpenTail)
            #expect(model.mintableTail)

            try await withBoard("copy.tail") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string
                        == "A finished paragraph.\n\nStill typing this one")
            }
        }
    }

    /// A tail of pure whitespace is not writing — the app's own
    /// `mintableTail` rule decides, so the copy and crystallization can
    /// never disagree about what counts as content.
    @Test func aWhitespaceOnlyTailAddsNothing() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Only this."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)

            typeAtEnd(model, surface.textView.textStorage, "\n")
            #expect(model.hasOpenTail)
            #expect(!model.mintableTail)

            try await withBoard("copy.blanktail") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string == "Only this.")
            }
        }
    }

    /// **A sealed note still copies** — the seal freezes authoring, and
    /// reading stays free under it (AppSpec §9). Nothing in the door
    /// writes a row, so there is nothing for the seal to refuse.
    @Test func aSealedNoteCopiesLikeAnyOther() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(
                session, blocks: ["Sealed prose."], locked: true)
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            #expect(model.isSealed)

            try await withBoard("copy.sealed") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string == "Sealed prose.")
                #expect(model.statusMessage
                        == MobileNoteClipboard.Outcome.copied.message)
            }
        }
    }

    /// An empty note copies NOTHING and says so — silently clearing her
    /// clipboard would be the worse of the two outcomes (P-2: a door that
    /// cannot act delivers a real refusal).
    @Test func anEmptyNoteSaysThereIsNothingToCopy() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: [])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            try await withBoard("copy.empty") { board in
                board.pasteboard.string = "something the author copied earlier"
                await model.copyNote(to: board)
                #expect(board.pasteboard.string == "something the author copied earlier")
                #expect(model.statusMessage
                        == MobileNoteClipboard.Outcome.nothingToCopy.message)
            }
        }
    }

    /// A fanned block copies its CHOSEN take — the export's own rule (the
    /// alternates section is `includeVariants`, which the copy door
    /// deliberately does not ask for: "everything i've written in a
    /// particular note" is the note, not its unchosen drafts, and the
    /// take-level copy is its own door — parity inventory R11).
    @Test func aFannedBlockCopiesTheChosenTake() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "fan", profile: .blog)
                let block = try ops.newBlock(in: post.id, text: "The chosen one.", at: .end)
                let branch = try ops.branchVariant(block.block.id, from: block.variant.id)
                try ops.autosave(branch.id, text: "The other take.", charDelta: 0)
                return post.id
            }
            let (model, _) = await makeSurfaceEditor(session, postID: seed)

            try await withBoard("copy.fan") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string == "The chosen one.")
            }
        }
    }

    // MARK: - M23 ≡ R15 — copy follows what is on the screen (batch 7)

    /// **HER RULING, PINNED:** *"copy should follow what's on the screen."*
    /// With a take PEEKED — which is also what a lens activation drives —
    /// the copy carries the DISPLAYED take, not the store's chosen.
    ///
    /// **RED ON OLD (behavioural revert):** make `displayedTextByBlock`
    /// return `[:]` unconditionally (its pre-batch-7 behaviour, i.e. the
    /// door not asking the surface at all) and the peeked half reds while
    /// every other pin in this file — including `aFannedBlockCopiesThe
    /// ChosenTake` directly above — stays green. That contrast IS the
    /// finding: nothing about the ordinary road moved.
    @Test func aPeekedTakeIsWhatTheCopyCarries() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await session.runner.run { ops -> (post: String, block: String) in
                let post = try ops.createPost(title: "m23", profile: .blog)
                let block = try ops.newBlock(in: post.id, text: "The chosen one.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "A plain neighbour.", at: .end)
                let branch = try ops.branchVariant(block.block.id, from: block.variant.id)
                try ops.autosave(branch.id, text: "The peeked one.", charDelta: 0)
                return (post.id, block.block.id)
            }
            let (model, _) = await makeSurfaceEditor(session, postID: seed.post)

            // BEFORE the peek: byte-identical to the store's export — the
            // half of the ruling that must not have moved.
            try await withBoard("copy.m23.chosen") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string
                        == "The chosen one.\n\nA plain neighbour.")
            }

            // The surface now DISPLAYS the other take.
            model.takes.flip(blockID: seed.block, forward: true)
            #expect(model.takes.isPeeking(seed.block))

            try await withBoard("copy.m23.peeked") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string
                        == "The peeked one.\n\nA plain neighbour.",
                        "copy follows the screen (R15)")
                // THE CONTROL for the fix wave's MAJOR 1 sentence: an
                // UNFRAMED note followed the screen, so its receipt is the
                // plain one and says nothing about saved takes.
                #expect(model.statusMessage
                        == MobileNoteClipboard.Outcome.copied.message)
            }

            // Flipping back to truth ENDS the peek, and the copy is the
            // store's again — the rule is "ask the surface", so it needs no
            // separate un-doing.
            model.takes.flip(blockID: seed.block, forward: false)
            #expect(!model.takes.isPeeking(seed.block))
            try await withBoard("copy.m23.back") { board in
                await model.copyNote(to: board)
                #expect(board.pasteboard.string
                        == "The chosen one.\n\nA plain neighbour.")
            }
        }
    }

    /// **The no-divergence road is the SHIPPED road, and that is structural
    /// rather than a claim.** With nothing peeked the surface hands over an
    /// empty answer and `markdown` takes `Queries.exportPost` verbatim — so
    /// "byte-identical to today" is guaranteed by which function runs, not
    /// by two projections happening to agree.
    @Test func withNothingPeekedTheCopyIsTheStoredExportVerbatim() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["One.", "Two.", "Three."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            #expect(model.displayedTextByBlock.isEmpty)

            let stored = try await db.read { db in
                try Queries.exportPost(db, postID: postID)
            }
            let composed = try await db.read { db in
                try MobileNoteClipboard.markdown(db, postID: postID, displayed: [:])
            }
            #expect(composed.text == stored)
            // …and the projection says it followed the screen, because on
            // this road there was nothing else to follow.
            #expect(!composed.usedSavedTakesInstead)
        }
    }

    /// **THE RECORDED CORNER, pinned as documented behaviour rather than
    /// left to be discovered.** A note carrying a CALLOUT frame takes the
    /// stored road even while something is peeked, because the callout →
    /// blockquote mapper (`Queries.exportMapped`) is `internal` to
    /// VariorumCore and re-implementing it here would fork a core brain
    /// (MobileSoul §3). The honest fallback is the shipped behaviour, never
    /// a document whose framed blocks silently lose their `> `.
    ///
    /// **This pin exists so that the one-word core fix (`public` on
    /// `exportMapped`) announces itself here instead of passing quietly.**
    ///
    /// ── **AND THE FALLBACK SPEAKS** (the fix wave, cold review MAJOR 1) ──
    ///
    /// The two roads' costs are not symmetrical, which is what the batch's
    /// own grading missed: a missing `> ` is VISIBLE in the pasted text,
    /// while a paragraph she did not choose reads perfectly and marks
    /// nothing — and this batch is what taught her the promise ("copy
    /// follows the screen") that the silence then breaks. So the receipt
    /// names the fallback. The sentence goes when the one word lands.
    ///
    /// **Red on old (behavioural revert):** make `copy` return `.copied`
    /// unconditionally (drop the `usedSavedTakesInstead` arm) and the
    /// receipt assertion below reds, while the peeked-unframed control in
    /// `aPeekedTakeIsWhatTheCopyCarries` stays green.
    @Test func aCalloutNoteKeepsTheStoredRoadEvenWhilePeeking() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops -> (post: String, block: String) in
                let post = try ops.createPost(title: "m23-callout", profile: .blog)
                let block = try ops.newBlock(in: post.id, text: "The chosen one.", at: .end)
                let framed = try ops.newBlock(in: post.id, text: "Framed.", at: .end)
                try ops.setBlockPresentation(
                    framed.block.id, BlockPresentation(color: "blue", emoji: nil))
                let branch = try ops.branchVariant(block.block.id, from: block.variant.id)
                try ops.autosave(branch.id, text: "The peeked one.", charDelta: 0)
                return (post.id, block.block.id)
            }
            let (model, _) = await makeSurfaceEditor(session, postID: seed.post)
            model.takes.flip(blockID: seed.block, forward: true)
            #expect(model.takes.isPeeking(seed.block))

            let stored = try await db.read { db in
                try Queries.exportPost(db, postID: seed.post)
            }
            #expect(stored.contains("> Framed."), "the frame maps in the stored road")

            try await withBoard("copy.m23.callout") { board in
                await model.copyNote(to: board)
                // DOCUMENTED: the chosen take, and the frame intact — the
                // fallback, not the ruling. When `exportMapped` becomes
                // reachable this expectation FLIPS to "The peeked one."
                #expect(board.pasteboard.string == stored)
                #expect(board.pasteboard.string?.contains("The chosen one.") == true)
                #expect(board.pasteboard.string?.contains("> Framed.") == true)

                // …AND SHE IS TOLD. The receipt names the road the copy
                // actually took, so the one outcome that cannot be seen in
                // the pasted text is the one that is said out loud.
                let spoken = try #require(model.statusMessage)
                #expect(spoken == MobileNoteClipboard.Outcome.copiedSavedTakes.message)
                #expect(spoken != MobileNoteClipboard.Outcome.copied.message)
                #expect(spoken.contains("callout"))
                #expect(spoken.contains("saved in the note"))
                // It names no chord and no other platform (the standing
                // no-redirect rule for every sentence this phone speaks).
                #expect(!spoken.contains("⌘"))
                #expect(!spoken.contains("Mac"))
            }
        }
    }
}
