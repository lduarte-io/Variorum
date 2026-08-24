//
//  CommentsAndTagsTests.swift
//  VariorumTests
//
//  Phase 13e, batch 6 — E7-comments + E8.
//
//  E7 (her sitting Round 2: the margin-hover comment grammar, and *"comments
//  need to be on the left instead of the right"*):
//
//   1. Hovering an UNCOMMENTED block offers "+ //" exactly where that
//      block's comment card would read — in the LEFT margin, clear of the
//      drag-handle lane, and only where a card would fit at all.
//   2. Every comment FACE the live surface draws — card, badge, and now the
//      hover chip — is left of the text (the sweep, as a pin).
//   3. A CALM page grows the geometry its hover faces need. This is the
//      batch's one real bug: the decoration walk is skipped when nothing is
//      decorated, so on a plain post the hovered block could never resolve
//      and the drag handle (13b 4D, S4-19) revealed NOTHING — working
//      exactly as built, invisible in the state it was built for.
//
//  E8 (her 13f round-11 ask: *"a quick and intuitive area where you can see
//  the posts at a high level and remove / add them"*):
//
//   4. The listing carries whole tags, so a row can take one OFF — the half
//      that did not exist. Adding rides the shipped type-to-create door.
//   5. Bulk untag offers exactly the tags the selection wears.
//   6. Note tagging is ONE declared act, with every renderer naming it.
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
private func withTagSession<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

// MARK: - The margin's comment faces (13e E7's card/badge; 13l retired its ＋)

@MainActor
@Suite("The margin's comment faces (13e E7 · 13l 8c)", .serialized)
struct MarginHoverCommentTests {
    /// **THE REMOVAL, PINNED** (13l, her 8c rider: *"I need the comment +
    /// on the left removed … it's too crowded and I don't like the look of
    /// seeing it there"*).
    ///
    /// **RED ON OLD** by construction: 13e E7's three pins asserted the
    /// opposite of every line here — that hovering an uncommented block
    /// rendered a chip at `leftAddChipRect`, that clicking it opened that
    /// block's comments, and that it was withheld in exactly three cases.
    /// Those pins are gone with the door; this one stands where they stood,
    /// so the invitation cannot come back unnoticed.
    ///
    /// It asserts the two halves of "removal only" together: nothing appears
    /// on hover over an uncommented block, and everything that was NOT
    /// removed still does — the commented block's CARD (itself the door)
    /// and the drag handle's own hover reveal, which shared the tracking.
    @Test func hoveringAnUncommentedBlockOffersNoMarginPlus() async throws {
        try await withEditor(seedBlocks: ["Alpha.", "Beta."]) { h in
            var opened: [String] = []
            let controller = BlockDecorOverlayController(
                textView: h.textView,
                onOpenComments: { opened.append($0) },
                onMoveBlock: { _, _ in })
            defer { controller.uninstall() }
            var state = BlockDecor.State()
            state.frames = [
                .init(entryIndex: 0, blockID: "b0",
                      frame: CGRect(x: 300, y: 0, width: 340, height: 30)),
                .init(entryIndex: 1, blockID: "b1",
                      frame: CGRect(x: 300, y: 40, width: 340, height: 30)),
            ]
            state.entryCount = 2
            state.viewWidth = 900
            state.textLeft = 300
            state.textRight = 640
            state.comments["b1"] = [.init(id: "c1", text: "a note")]
            controller.render(state)

            @MainActor func faces() -> [CommentCardView] {
                h.textView.subviews.compactMap { $0 as? CommentCardView }
            }
            // b1's CARD is the only comment face on the surface, at rest…
            #expect(faces().count == 1, "the commented block's card — untouched")

            // …and hovering the UNCOMMENTED block adds nothing to it.
            controller.noteHover(atY: 15)
            #expect(controller.hoveredBlockID == "b0", "hover still resolves")
            #expect(faces().count == 1,
                    "no ＋ in the margin — her 8c ruling, and the card is unmoved")
            #expect(opened.isEmpty, "there is no invitation left to click")

            // The handle's reveal shared that tracking and must survive it.
            #expect(h.textView.subviews.compactMap { $0 as? DragHandleView }.count == 1,
                    "S4-19's hover handle still reveals — only the ＋ went")

            // Hovering the COMMENTED block leaves its card alone too.
            controller.noteHover(atY: 55)
            #expect(faces().count == 1)
            controller.noteHover(atY: nil)
            #expect(faces().count == 1, "the card is not a hover face")
        }
    }

    /// **THE SWEEP, AS A PIN** (the constitution's closing form for a fixed
    /// class): every comment face the live surface draws sits LEFT of the
    /// text. 13g R5-3 moved the card and the badge; E7's chip is born there.
    @Test func everyMarginCommentFaceSitsLeftOfTheText() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            let controller = BlockDecorOverlayController(
                textView: h.textView, onOpenComments: { _ in }, onMoveBlock: { _, _ in })
            defer { controller.uninstall() }
            @MainActor func faces() -> [CommentCardView] {
                h.textView.subviews.compactMap { $0 as? CommentCardView }
            }
            var wide = BlockDecor.State()
            wide.frames = [
                .init(entryIndex: 0, blockID: "b0",
                      frame: CGRect(x: 300, y: 0, width: 340, height: 30)),
            ]
            wide.entryCount = 1
            wide.viewWidth = 900
            wide.textLeft = 300
            wide.textRight = 640
            wide.comments["b0"] = [.init(id: "c1", text: "a note")]

            // 1 — the CARD.
            controller.render(wide)
            #expect(faces().allSatisfy { $0.frame.maxX <= wide.textLeft },
                    "the margin card reads on the left")

            // 2 — the BADGE (narrow gutter).
            var narrow = wide
            narrow.textLeft = 60
            narrow.frames = [
                .init(entryIndex: 0, blockID: "b0",
                      frame: CGRect(x: 60, y: 0, width: 340, height: 30)),
            ]
            controller.render(narrow)
            #expect(faces().allSatisfy { $0.frame.maxX <= narrow.textLeft },
                    "the count badge stands in on the same side")

            // (13l, her 8c rider: the third face — E7's hover ＋ — is gone;
            // its removal is pinned in `MarginHoverCommentTests` above.)
        }
    }
}

// MARK: - E7: the calm page's hover geometry (the batch's bug fix)

@MainActor
@Suite("A calm page reveals its hover faces (13e E7)", .serialized)
struct CalmPageHoverTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// **RED ON OLD** (behavioral revert: remove the `|| pointerInEditor`
    /// arm from `refreshDecorations`' gate). The traced mechanism: the walk
    /// is skipped when nothing is decorated, `noteHover` resolves the
    /// hovered block against `state.frames`, and with no frames NOTHING can
    /// resolve — so on a plain post (seams off, indicator off, no callouts,
    /// no comments, nothing picked) hovering revealed neither the drag
    /// handle (13b 4D's S4-19 promise) nor E7's comment invitation.
    ///
    /// Driven end to end: the controller's own hover input reports the
    /// pointer to the model, the model walks, the sink delivers, and the
    /// SAME call resolves the block — which is exactly the production path.
    @Test func aCalmPageRevealsItsHoverFacesInsteadOfNothing() async throws {
        try await withEditor(seedBlocks: ["alpha block", "beta block"]) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()

            h.model.appearance = EditorAppearance()  // THE CALM DEFAULT
            let controller = BlockDecorOverlayController(model: h.model, textView: h.textView)
            defer { controller.uninstall() }
            pump()
            #expect(!h.model.pointerInEditor)

            var captured: BlockDecor.State?
            h.model.decorSink = { [weak controller] state in
                captured = state
                controller?.render(state)
            }
            h.model.pushDecorationsToSink()
            pump()
            #expect(captured?.frames.isEmpty != false,
                    "at rest the calm page still costs nothing")

            // The pointer arrives over the first block.
            let y = h.textView.textContainerOrigin.y + 4
            controller.noteHover(atY: y)
            pump()
            #expect(h.model.pointerInEditor, "the surface tells the model the pointer is here")
            #expect(captured?.frames.isEmpty == false,
                    "geometry exists exactly while she is pointing at the page")
            #expect(controller.hoveredBlockID != nil, "the hovered block resolves")
            // (13l, her 8c rider: E7's comment invitation rode this same
            // geometry and is retired; the drag handle — 4D's S4-19 promise,
            // which is the bug this pin was written for — still rides it.)
            let handles = h.textView.subviews.compactMap { $0 as? DragHandleView }
            #expect(handles.count == 1, "the drag handle reveals too — S4-19's promise, kept")

            // The pointer leaves: the page goes back to costing nothing.
            controller.noteHover(atY: nil)
            pump()
            #expect(!h.model.pointerInEditor)
            #expect(captured?.frames.isEmpty == true)
            #expect(h.textView.subviews.compactMap { $0 as? DragHandleView }.isEmpty,
                    "…and the handle goes with it")
        }
    }
}

// MARK: - E8: the high-level tags face

@MainActor
@Suite("The listing's tag doors (13e E8)", .serialized)
struct LibraryTagFaceTests {
    /// The half her round-11 ask named and the surface did not have: a row
    /// can take a tag OFF. (A FEATURE pin, not a bug pin — the door is new,
    /// so no red-on-old is owed; what it guards is the chips' contract.)
    @Test func aRowCarriesWholeTagsAndCanTakeOneOff() async throws {
        try await withTagSession { session, _ in
            let (postID, tagID) = try await session.runner.run { ops -> (String, String) in
                let tag = try ops.createTag(parent: nil, name: "ideas")
                let post = try ops.createPost(title: "a note", profile: .generic)
                _ = try ops.applyTag(tag.id, toPost: post.id)
                return (post.id, tag.id)
            }
            let model = LibraryCatalogModel(session: session)
            await model.search()
            let chips = try #require(model.postTags[postID])
            #expect(chips.map(\.path) == ["ideas"])
            #expect(chips.map(\.id) == [tagID],
                    "the chip carries the tag's identity, which is what removing needs")

            await model.removeTag(tagID, from: [postID])
            #expect(model.postTags[postID] == nil || model.postTags[postID]?.isEmpty == true,
                    "the tag is off the note")
            let applied = try await session.database.read { db in
                try Queries.postTags(db, postID: postID)
            }
            #expect(applied.isEmpty, "…in the store, not just on screen")
            #expect(model.lastError == nil)

            // Batch semantics, the `applyTag` mirror: removing what is
            // already off is done, not an error.
            await model.removeTag(tagID, from: [postID])
            #expect(model.lastError == nil)
        }
    }

    /// Adding rides the SHIPPED type-to-create door (13b 3D's N24 — the
    /// context bar's `＋`), so a path that does not exist yet is created on
    /// the way in and the hierarchy is walked by one implementation.
    @Test func typingAPathOnARowCreatesTheTagAndAppliesIt() async throws {
        try await withTagSession { session, _ in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "a note", profile: .generic).id
            }
            let model = LibraryCatalogModel(session: session)
            await model.search()
            #expect(model.postTags[postID] == nil)

            await model.applyTypedPath("life/goals", to: [postID])
            #expect(model.postTags[postID]?.map(\.path) == ["life/goals"])
            let taxonomy = try await session.database.read { try Queries.allTags($0) }
            #expect(taxonomy.map(\.path).sorted() == ["life", "life/goals"],
                    "every missing segment was created, once")
            #expect(model.lastError == nil)

            // Typing it again is a polite no-op, not a refusal.
            await model.applyTypedPath("life/goals", to: [postID])
            #expect(model.postTags[postID]?.map(\.path) == ["life/goals"])
            #expect(model.lastError == nil)
        }
    }

    /// **Ladder round B (B-2) — red-on-old.** The bulk apply used to BREAK
    /// on the first refusal in Set order, so a vanished post's turn
    /// silently cost every post after it. The forgiving-batch shape now
    /// (the REMOVE sibling's recorded choice): deterministic order, every
    /// post gets its turn, partiality REPORTED. Staged so the vanished
    /// post sorts FIRST — on the pre-fix code the live post deterministically
    /// got nothing.
    @Test func aVanishedPostSkipsAndTheRestStillGetTheTag() async throws {
        try await withTagSession { session, _ in
            let (goneID, liveID) = try await session.runner.run { ops -> (String, String) in
                let gone = try ops.createPost(title: "a gone", profile: .generic)
                let live = try ops.createPost(title: "b live", profile: .generic)
                try ops.deleteContainer(gone.id)
                return (gone.id, live.id)
            }
            let ordered = [goneID, liveID].sorted()
            let model = LibraryCatalogModel(session: session)
            await model.search()

            await model.applyTypedPath("swept", to: ordered)

            #expect(model.postTags[liveID]?.map(\.path) == ["swept"],
                    "the live post is tagged even when the vanished one takes its turn first")
            #expect(model.lastError?.contains("1 of 2") == true,
                    "partiality is reported, never silent")
        }
    }

    /// A typed path applied to a SELECTION mints the tag once and wears it
    /// everywhere (the bulk add half).
    @Test func aTypedPathReachesEverySelectedNoteAndMintsOnce() async throws {
        try await withTagSession { session, _ in
            let ids = try await session.runner.run { ops -> [String] in
                try (0..<3).map { try ops.createPost(title: "note \($0)", profile: .generic).id }
            }
            let model = LibraryCatalogModel(session: session)
            await model.search()
            await model.applyTypedPath("work", to: ids)
            for id in ids {
                #expect(model.postTags[id]?.map(\.path) == ["work"])
            }
            let taxonomy = try await session.database.read { try Queries.allTags($0) }
            #expect(taxonomy.count == 1, "one tag, not one per note")
        }
    }

    /// The bulk UNTAG menu offers exactly what the selection wears — never
    /// a row that would do nothing (P-2).
    @Test func theBulkUntagMenuOffersOnlyTheTagsTheSelectionWears() async throws {
        try await withTagSession { session, _ in
            let (a, b, c) = try await session.runner.run {
                ops -> (String, String, String) in
                let ideas = try ops.createTag(parent: nil, name: "ideas")
                let work = try ops.createTag(parent: nil, name: "work")
                _ = try ops.createTag(parent: nil, name: "unused")
                let a = try ops.createPost(title: "a", profile: .generic)
                let b = try ops.createPost(title: "b", profile: .generic)
                let c = try ops.createPost(title: "c", profile: .generic)
                _ = try ops.applyTag(ideas.id, toPost: a.id)
                _ = try ops.applyTag(work.id, toPost: b.id)
                _ = try ops.applyTag(ideas.id, toPost: b.id)
                return (a.id, b.id, c.id)
            }
            let model = LibraryCatalogModel(session: session)
            await model.search()
            #expect(model.tagsOn([a, b]).map(\.path) == ["ideas", "work"],
                    "each worn tag once, in path order — never the taxonomy")
            #expect(model.tagsOn([c]).isEmpty, "an untagged selection offers no menu at all")
            #expect(model.tagsOn([a]).map(\.path) == ["ideas"])

            // …and the act it fronts reaches every selected note.
            let ideas = try #require(model.tagsOn([a, b]).first)
            await model.removeTag(ideas.id, from: [a, b])
            #expect(model.postTags[a]?.isEmpty != false)
            #expect(model.postTags[b]?.map(\.path) == ["work"],
                    "only the named tag came off")
        }
    }

    /// The pool's rows are the same surface family (R46's other half), so
    /// they carry the same two doors rather than a second grammar.
    @Test func thePoolsRowsCarryTheSameTwoDoors() async throws {
        try await withTagSession { session, _ in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "floating", profile: .generic).id
            }
            let model = PoolPostsModel(session: session)
            let started = Task { await model.start() }
            defer { started.cancel() }
            for _ in 0..<200 where model.posts.isEmpty {
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(model.posts.contains { $0.postID == postID })

            await model.applyTypedPath("scraps", to: postID)
            let chip = try #require(model.postTags[postID]?.first)
            #expect(chip.path == "scraps")
            await model.removeTag(chip.id, from: postID)
            #expect(model.postTags[postID]?.isEmpty != false)
            #expect(model.lastError == nil)
        }
    }
}

// MARK: - E8: the declaration (P-1)

@MainActor
@Suite("Note tagging is one declared act (13e E8)")
struct NoteTagDeclarationTests {
    @Test func theActIsDeclaredOnceAndEveryRendererNamesIt() {
        let capability = CapabilityRegistry.capability(.tagNote)
        #expect(capability.scope == .post)
        #expect(capability.doors == [.surface])
        #expect(capability.shortcutLabel == nil, "no chord — the doors are the chips")
        #expect(!capability.unavailableNote.isEmpty, "a written refusal, like every act")
        #expect(capability.availability(CapabilityContext()) == .act,
                "both doors point at a note directly, so a rendered one can always act")
        #expect(CapabilityRegistry.doored(.surface).contains(.tagNote))
        // Every renderer of the ONE act names it (the walk asserts the
        // union equals the declared set; this states the three by name).
        #expect(ContextBar.surfaceCapabilities.contains(.tagNote))
        #expect(LibraryCatalogView.surfaceCapabilities.contains(.tagNote))
        #expect(PoolPostsView.surfaceCapabilities.contains(.tagNote))
    }

    /// The listing row stays quiet where quietness was the point: a note
    /// card with no tags reserves nothing until the pointer arrives, while
    /// the List mode's column always shows its `＋`.
    @Test func theQuietRowIsQuietUntilPointedAt() {
        let hidden = NoteTagsRow(
            tokens: .fallback(for: .light), tags: [], allTags: [],
            onApply: { _ in }, onRemove: { _ in }, revealsOnHover: true)
        #expect(hidden.revealsOnHover)
        let always = NoteTagsRow(
            tokens: .fallback(for: .light), tags: [], allTags: [],
            onApply: { _ in }, onRemove: { _ in })
        #expect(!always.revealsOnHover, "the column's default is to show")
        #expect(NoteTagsRow.reservedHeight > 0,
                "the quiet row still holds its room, so a card never jumps")
    }
}
