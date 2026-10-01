//
//  MobileWalkTests.swift
//  VariorumMobileTests
//
//  THE MOBILE ACCEPTANCE SPINE (the execution plan's P-6 analog), BORN at
//  Stage 1 batch 1: a scripted walk over the phone's happy paths that
//  grows with every stage and rides every batch run — a broken walk step
//  is a regression by definition.
//
//  Batch 1's walk: open note → type → autosave lands → identity intact →
//  canary silent. It runs against the REAL `MobileEditorTextView` (the
//  TK2-explicit view, canary armed, storage delegate live) — typing goes
//  through the view's own `insertText` input path, so the walk exercises
//  the genuine UIKit editing machinery this simulator run can reach (the
//  full touch/keyboard pipeline stays the device round's, per the memo's
//  obligation 6).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile walk — the acceptance spine (S1 batch 1)")
struct MobileWalkTests {
    /// Walk step 1: today's entry, opened and written in the continuous
    /// editor, lands in the store with identity intact and the canary
    /// silent.
    @Test func walk1_openTypeAutosaveIdentityCanary() async throws {
        try await withEditorWorld { session, db in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-08-03")
            }
            let model = MobileEditorViewModel(
                session: session, postID: entry.container.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }

            // The REAL surface: TK2-explicit view in the keyboard-avoiding
            // container, canary armed at attach.
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            #expect(surface.textView.textLayoutManager != nil, "TK2-explicit construction holds")

            await model.loadOnce()

            // TYPE through the view's own input path.
            surface.textView.insertText("Walked and wrote.")
            await model.awaitMintSettle()
            await model.autosave.flushNow()

            // The autosave landed (one-block journal semantics).
            #expect(try await storedBlockTexts(db, postID: entry.container.id)
                    == ["Walked and wrote."])

            // Typing continues into the minted block.
            surface.textView.insertText(" Then more.")
            await model.awaitMintSettle()
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: entry.container.id)
                    == ["Walked and wrote. Then more."])
            let blockCount = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block") ?? -1
            }
            #expect(blockCount == 1, "a journal entry is ONE block")

            // Identity intact: the projection agrees with the index
            // authority everywhere (the obligation-1 audit ran after every
            // edit), and the surface never desynced.
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(EditorDocument.blockID(at: 0, in: surface.textView.textStorage) != nil)

            // Canary silent: TK2 never fell back across the whole walk.
            #expect(!surface.textView.canaryFired)
            #expect(model.canaryMessage == nil)

            // No refusal spoke during the happy path.
            #expect(model.statusMessage == nil)

            // Teardown lands everything; the store holds exactly the walk's
            // bytes (the L9 contract riding the spine).
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: entry.container.id)
                    == ["Walked and wrote. Then more."])
        }
    }

    /// Walk step 2: a multi-block note — typing past a paragraph
    /// crystallizes it; the walk's bytes are byte-stable through teardown.
    @Test func walk2_freshNoteCrystallizesWhileTyping() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "walk note", profile: .blog)
            }
            let model = MobileEditorViewModel(
                session: session, postID: post.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()

            surface.textView.insertText("First thought.\n")
            surface.textView.insertText("Second thought begins")
            await model.awaitMintSettle()

            // The completed paragraph crystallized; the trailing one is the
            // open tail until teardown.
            #expect(try await storedBlockTexts(db, postID: post.id) == ["First thought."])
            #expect(surface.textView.textStorage.string == "First thought.\nSecond thought begins")

            await model.finish()
            #expect(try await storedBlockTexts(db, postID: post.id)
                    == ["First thought.", "Second thought begins"])
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!surface.textView.canaryFired)
        }
    }

    /// Walk step 3 (S1 batch 2): the markdown vocabulary — type a list, ⏎
    /// continues it, Tab nests, the bar re-leads, a tap toggles the box, a
    /// heading act at depth mints a working column-0 heading — and the
    /// STORED BYTES are byte-checked against the shared brain's law (the
    /// Mac's own outcomes, per the one-brain rule).
    @Test func walk3_markdownVocabularyByteStable() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "walk md", profile: .blog)
            }
            let model = MobileEditorViewModel(
                session: session, postID: post.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()
            let view = surface.textView
            let bar = MobileKeyboardBarController(textView: view)

            // A list is born; ⏎ continues it with the lead, twice; the
            // second item crystallizes as she types past it.
            view.insertText("- milk")
            view.insertText("\n")
            view.insertText("eggs")
            view.insertText("\n")
            await model.awaitMintSettle()
            #expect(view.textStorage.string == "- milk\n- eggs\n- ")

            // ⏎ on the EMPTY item exits the list (K5's letter — the
            // consumed keystroke; the lead goes, no newline lands).
            view.insertText("\n")
            #expect(view.textStorage.string == "- milk\n- eggs\n")

            // Tab nests the MINTED item (K8's two-space unit) — an
            // ordinary in-block policed edit, as on the Mac.
            view.selectedRange = NSRange(location: 13, length: 0) // end of "- eggs"
            view.performTabKey()
            #expect(view.textStorage.string == "- milk\n  - eggs\n")

            // The bar re-leads it as a checklist — nesting survives
            // (actKeepsIndent), and the born box is UNCHECKED.
            bar.fireChecklist()
            #expect(view.textStorage.string == "- milk\n  - [ ] eggs\n")

            // A tap strictly inside the box checks it; the caret stays put.
            surface.layoutIfNeeded()
            let boxStart = ("- milk\n  - ".utf16.count)
            guard let from = view.position(from: view.beginningOfDocument, offset: boxStart + 1),
                  let to = view.position(from: view.beginningOfDocument, offset: boxStart + 2),
                  let boxRange = view.textRange(from: from, to: to)
            else {
                Issue.record("no laid-out geometry for the box")
                return
            }
            let rect = view.firstRect(for: boxRange)
            #expect(MobileMarkdownActs.toggleCheckbox(
                at: CGPoint(x: rect.midX, y: rect.midY), in: view))
            #expect(view.textStorage.string == "- milk\n  - [x] eggs\n")

            // ⏎ at the checked item's end continues at its own LEVEL,
            // unchecked (K5+K8) — inside the block, a content newline (I4).
            view.selectedRange = NSRange(location: 19, length: 0)
            view.insertText("\n")
            #expect(view.textStorage.string == "- milk\n  - [x] eggs\n  - [ ] \n")

            // The heading act on the NESTED empty item mints a working
            // COLUMN-0 heading (the 13k MAJOR's actKeepsIndent law).
            bar.fireHeading()
            #expect(view.textStorage.string == "- milk\n  - [x] eggs\n# \n")
            view.insertText("Title")

            // Teardown: the stored bytes are the law's, exactly (the
            // nested continuation + heading were content edits of the
            // second block; the trailing "\n" is the open empty tail's
            // separator — a render artifact, stored nowhere).
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: post.id)
                    == ["- milk", "  - [x] eggs\n# Title"])
            #expect(view.textStorage.string == "- milk\n  - [x] eggs\n# Title\n")

            // Identity intact, canary silent, no refusal spoke.
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!view.canaryFired)
            #expect(model.statusMessage == nil)
        }
    }

    /// Walk step 4 (S1 batch 3 — the brief's scope item 5): the LK2 voice
    /// switch restyles the OPEN surface while every byte stays exactly
    /// where it was — display == stored holds through the switch in both
    /// directions, identity stays intact, and the face provably changes
    /// (fonts and palette follow the voice).
    @Test func walk4_voiceSwitchRestylesWithoutTouchingBytes() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "walk voice", profile: .blog)
            }
            let model = MobileEditorViewModel(
                session: session, postID: post.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()
            let view = surface.textView
            let storage = view.textStorage

            // A voiced document: heading, nested list (the trim law's kept
            // indent riding the spine), inline code — pasted as bulk.
            typeEdit(
                model, storage,
                range: NSRange(location: 0, length: 0),
                replacement: "# Head\n\n- milk\n  - [ ] eggs\n\nwith `code` inline",
                isPaste: true)
            await model.awaitMintSettle()
            await model.autosave.flushNow()
            let surfaceBytes = storage.string
            #expect(surfaceBytes == "# Head\n\n- milk\n  - [ ] eggs\n\nwith `code` inline")
            let storedBytes = try await storedBlockTexts(db, postID: post.id)
            #expect(storedBytes == ["# Head\n", "- milk", "  - [ ] eggs\n", "with `code` inline"])

            let proseAt = (storage.string as NSString).range(of: "with").location
            let terminalProse = storage.attribute(.font, at: proseAt, effectiveRange: nil) as? UIFont
            #expect(terminalProse?.fontDescriptor.symbolicTraits.contains(.traitMonoSpace) == true)

            // THE SWITCH → study. Attributes only; bytes byte-identical.
            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            model.applyVoiceChange()
            #expect(storage.string == surfaceBytes)

            // The face followed: study serif prose, the study palette's
            // dimmed marker and code chip, study typing attributes.
            let studyProse = storage.attribute(.font, at: proseAt, effectiveRange: nil) as? UIFont
            #expect(studyProse?.familyName == "Iowan Old Style")
            let marker = storage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
            #expect(marker == MobileEditorStyle.studyFace.palette.marker)
            let tickAt = (storage.string as NSString).range(of: "`code`").location
            let chip = storage.attribute(.backgroundColor, at: tickAt, effectiveRange: nil) as? UIColor
            #expect(chip == MobileEditorStyle.studyFace.palette.codeTint)
            let typingFont = view.typingAttributes[.font] as? UIFont
            #expect(typingFont?.familyName == "Iowan Old Style")

            // And BACK — byte-identical again, the terminal face restored.
            MobileEditorStyle.voice = .terminal
            model.applyVoiceChange()
            #expect(storage.string == surfaceBytes)
            // Round-1 MINOR-2 fix: the flush rides AFTER the round-trip so
            // the `.study` window holds NO suspension point — the process-
            // global voice flip is MainActor-atomic against every other
            // @MainActor test. Store damage from either switch still lands
            // here, discriminated against the pre-switch storedBytes.
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: post.id) == storedBytes)
            let backProse = storage.attribute(.font, at: proseAt, effectiveRange: nil) as? UIFont
            #expect(backProse?.fontDescriptor.symbolicTraits.contains(.traitMonoSpace) == true)
            #expect(storage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
                    == MobileEditorStyle.terminalFace.palette.marker)

            // Identity intact, canary silent, no refusal spoke — the
            // switch is invisible to everything but the face.
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!view.canaryFired)
            #expect(model.statusMessage == nil)
        }
    }

    /// Walk step 5 (S2 batch 1 — the brief's scope item 6): takes on the
    /// phone. A fanned block wears the ⑂ badge with its LK10 gutter; the
    /// flip PEEKS in place with the store's bytes untouched; the marker
    /// shows; typing edits the PEEKED take; ✓ chooses (the store's
    /// chosen_variant changes — the Mac would follow); identity audit
    /// clean, canary silent.
    @Test func walk5_takesBadgePeekAndChoose() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops in
                let post = try ops.createPost(title: "walk takes", profile: .blog)
                let a = try ops.newBlock(in: post.id, text: "The chosen opening.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "A fanless second block.", at: .end)
                let take = try ops.branchVariant(a.block.id, from: a.variant.id)
                try ops.autosave(take.id, text: "The braver opening.", charDelta: 6)
                return (postID: post.id, blockA: a.block.id, a1: a.variant.id, a2: take.id)
            }
            let model = MobileEditorViewModel(
                session: session, postID: seed.postID,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()
            surface.layoutIfNeeded()
            let view = surface.textView
            guard let chrome = view.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }

            // The fanned block wears ⑂ (count-free) and reserves its
            // gutter (B3's paragraph-tail reservation; the container
            // carries no exclusion paths — FB2-1); the fanless one wears
            // and reserves nothing.
            #expect(chrome.badgeView(for: seed.blockA) != nil)
            let styleA = try #require(model.rangeOfBlock(seed.blockA)).location
            #expect((view.textStorage.attribute(
                .paragraphStyle, at: styleA, effectiveRange: nil)
                as? NSParagraphStyle)?.tailIndent
                    == -MobileTakesChromeController.gutterWidth)
            #expect(view.textContainer.exclusionPaths.isEmpty)
            let storeBytesBefore = try await storedBlockTexts(db, postID: seed.postID)
            #expect(storeBytesBefore == ["The chosen opening.", "A fanless second block."])

            // SWIPE (the gesture's act): the peek flips in place — bytes
            // in store untouched, the marker shows, ✓ offered.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(view.textStorage.string
                    == "The braver opening.\nA fanless second block.")
            #expect(try await storedBlockTexts(db, postID: seed.postID) == storeBytesBefore)
            #expect(try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [seed.blockA])
            } == seed.a1)
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(chrome.markerView(for: seed.blockA) != nil)
            #expect(chrome.pillIsShowing)

            // Typing edits the PEEKED take (everything visible in an
            // editing surface is editable — R8/R23).
            view.selectedRange = NSRange(
                location: ("The braver opening." as NSString).length, length: 0)
            view.insertText(" Braver still.")
            await model.awaitMintSettle()
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: seed.a2)
                    == "The braver opening. Braver still.")
            #expect(try await storedText(db, variantID: seed.a1) == "The chosen opening.")

            // ✓ CHOOSES — the one committing act; the store's pointer
            // moves and the peek ends (the display is truth now).
            await model.takes.chooseDisplayed(blockID: seed.blockA)
            #expect(try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [seed.blockA])
            } == seed.a2)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(chrome.markerView(for: seed.blockA) == nil)

            // Identity intact, canary silent, no refusal spoke; teardown
            // lands the walk's bytes exactly.
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!view.canaryFired)
            #expect(model.statusMessage == nil)
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                    == ["The braver opening. Braver still.", "A fanless second block."])
        }
    }

    /// Walk step 6 (S2 batch 2 — the brief's scope item 6): the takes
    /// BROWSER. Badge → the sheet opens over the dimmed page → a blank
    /// take minted → edited in the sheet → ✓ chosen → the OLD takes
    /// archived → store rows byte-checked at every step → the I10 refusal
    /// on the last live take SPEAKS → Done → the page shows the new
    /// chosen text → identity audit clean, canary silent.
    @Test func walk6_takesBrowserFourVerbs() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops in
                let post = try ops.createPost(title: "walk browser", profile: .blog)
                let a = try ops.newBlock(in: post.id, text: "The first way.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "A steady second block.", at: .end)
                let take = try ops.branchVariant(a.block.id, from: a.variant.id)
                try ops.autosave(take.id, text: "The second way.", charDelta: 4)
                return (postID: post.id, blockA: a.block.id, a1: a.variant.id, a2: take.id)
            }
            let model = MobileEditorViewModel(
                session: session, postID: seed.postID,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()
            surface.layoutIfNeeded()
            let view = surface.textView
            guard let chrome = view.takesChrome,
                  let browserView = view.takesBrowserView
            else {
                Issue.record("takes chrome/browser not installed")
                return
            }

            // BADGE → the browser opens: the sheet over the page, the
            // in-page editor stands down, both cards render, nothing in
            // the store moved.
            chrome.badgeTapped(seed.blockA)
            #expect(model.takesBrowser.openBlockID == seed.blockA)
            #expect(!browserView.isHidden)
            #expect(!view.isEditable)
            #expect(browserView.cardViews.count == 2)
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                    == ["The first way.", "A steady second block."])

            // BLANK TAKE MINTED — at the fan's end, chosen untouched
            // (minting never chooses), the minted card LIVE for editing.
            let mint = await model.takesBrowser.newBlank()
            guard let mint else {
                Issue.record("the blank mint failed")
                return
            }
            #expect(model.takesBrowser.editingVariantID == mint.id)
            #expect(try await storedText(db, variantID: mint.id) == "")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [seed.blockA])
            } == seed.a1)

            // EDITED IN THE SHEET — through the one card editor's own
            // input path; the edit routes to the MINTED take only.
            let editor = browserView.cardEditor
            #expect(editor.superview === browserView.cardViews[mint.id])
            editor.insertText("A third way.")
            browserView.textViewDidChange(editor)
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: mint.id) == "A third way.")
            #expect(try await storedText(db, variantID: seed.a1) == "The first way.")
            #expect(try await storedText(db, variantID: seed.a2) == "The second way.")

            // ✓ CHOSEN — the store's pointer moves to the mint (the Mac
            // would follow).
            await model.takesBrowser.choose(variantID: mint.id)
            #expect(try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [seed.blockA])
            } == mint.id)
            #expect(model.statusMessage == nil)

            // THE OLD TAKES ARCHIVED — out of the fan, kept in history.
            await model.takesBrowser.archive(variantID: seed.a1)
            await model.takesBrowser.archive(variantID: seed.a2)
            #expect(model.statusMessage == nil)
            let statuses = try await db.read { db in
                try Row.fetchAll(
                    db,
                    sql: """
                        SELECT id, status FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL ORDER BY id
                        """,
                    arguments: [seed.blockA]
                ).reduce(into: [String: String]()) { $0[$1["id"]] = $1["status"] }
            }
            #expect(statuses[seed.a1] == "archived")
            #expect(statuses[seed.a2] == "archived")
            #expect(statuses[mint.id] == "active")
            #expect(model.takesBrowser.cards().map(\.variantID) == [mint.id])

            // THE I10 REFUSAL on the last live take SPEAKS — through the
            // op's own guard; the take stays. (Delete on a last take that
            // is ALSO the chosen one speaks the ops' chosen-slot guard
            // instead — it runs FIRST in `deleteVariant`, the op's real
            // order, heard here too.)
            let i10Copy = "This is the block's only take — a block always keeps one. "
                + "To remove it all, use Delete Block in the \u{22EF} menu."
            await model.takesBrowser.archive(variantID: mint.id)
            #expect(model.statusMessage == i10Copy)
            model.report(nil)
            await model.takesBrowser.delete(variantID: mint.id)
            #expect(model.statusMessage
                    == "This take is what the note shows — choose another take first, "
                    + "then delete this one.")
            #expect(try await storedText(db, variantID: mint.id) == "A third way.")

            // DONE — the sheet closes, the page editor returns, and the
            // page shows the NEW CHOSEN text.
            await model.takesBrowser.close()
            #expect(browserView.isHidden)
            #expect(view.isEditable)
            #expect(view.textStorage.string == "A third way.\nA steady second block.")

            // Identity intact, canary silent; teardown lands the walk's
            // bytes exactly.
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!view.canaryFired)
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                    == ["A third way.", "A steady second block."])
        }
    }

    /// Walk step 7 (S3 batch 1 — the brief's scope item 7): the app
    /// shape. Cold launch → the shelf renders (LK5 faces BYTE-CHECKED in
    /// the live voice) → Today → type in the REAL editor → the entry
    /// lands AND shelves into the daily book → Library search finds it →
    /// back → the note reopens in the editor with the typed bytes.
    @Test func walk7_shelfTodayLibraryColdLaunch() async throws {
        try await withEditorWorld { session, db in
            // The shelf she'd cold-launch onto: a tagged essays book, a
            // finished book, a smart collector.
            let seed = try await session.runner.run { ops -> (essays: String, poems: String) in
                let essays = try ops.createReading(name: "Essays", kind: .book)
                let life = try ops.createTag(name: "life")
                let goals = try ops.createTag(parent: life.id, name: "goals")
                for index in 1...2 {
                    let post = try ops.createPost(title: "essay \(index)")
                    _ = try ops.addPostToReading(post.id, to: essays.id)
                    _ = try ops.applyTag(goals.id, toPost: post.id)
                }
                let poems = try ops.createReading(name: "Poems", kind: .book)
                try ops.lockReading(poems.id)
                // 13i-a: rules resolve paths to tag IDs at the write (§19),
                // so the tag exists first — the doors' own flow.
                _ = try ops.createTag(name: "books")
                _ = try ops.createReading(
                    name: "reading notes", kind: .gathering,
                    querySpec: #"{"tags":["books"]}"#)
                return (essays.id, poems.id)
            }

            // COLD LAUNCH: the shelf home observes and renders.
            let shelf = MobileShelfViewModel(session: session)
            let shelfObservation = Task { await shelf.start() }
            defer { shelfObservation.cancel() }
            for _ in 0..<2000 where shelf.books.count < 3 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            await shelf.refreshTags()

            // LK5 faces, byte-checked in the LIVE voice (terminal — the
            // harness default; chrome casing is the view's tokens).
            let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
            let essays = try #require(shelf.books.first { $0.reading.id == seed.essays })
            #expect(tokens.chromeLabel(shelf.rowName(for: essays)) == "essays")
            #expect(tokens.chromeLabel(shelf.rowMeta(for: essays)) == "2 notes · #goals",
                    "LK5: note count + tags lead")
            let poems = try #require(shelf.books.first { $0.reading.id == seed.poems })
            #expect(tokens.chromeLabel(shelf.rowName(for: poems)) == "poems ✓",
                    "✓ finished is a STATE on the name")
            let smart = try #require(shelf.books.first { $0.reading.kind == .gathering })
            #expect(tokens.chromeLabel(shelf.rowMeta(for: smart)) == "smart · #books")

            // TODAY: create-or-open + the shared daily-book shelving door.
            let todayID = try #require(await shelf.openToday(day: "2026-08-03"))
            #expect(shelf.lastReport == nil, "a clean shelving says nothing")
            let journalMembers = try await db.read { db in
                try String.fetchAll(db, sql: """
                    SELECT rp.post_id FROM reading_post rp
                    JOIN reading r ON r.id = rp.reading_id AND r.profile = 'daily'
                    WHERE rp.deleted_at IS NULL
                    """)
            }
            #expect(journalMembers == [todayID],
                    "the day's entry shelved into the (created-and-pinned) daily book")

            // TYPE in the REAL editor (the walk-1 surface).
            let model = MobileEditorViewModel(
                session: session, postID: todayID,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()
            surface.textView.insertText("Dear diary, the shelf works.")
            await model.awaitMintSettle()
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: todayID)
                    == ["Dear diary, the shelf works."])
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!surface.textView.canaryFired)

            // LIBRARY: the listing carries it; search finds it by its day
            // (the one display brain names it).
            let library = MobileLibraryViewModel(session: session)
            let libraryObservation = Task { await library.startAll() }
            defer { libraryObservation.cancel() }
            for _ in 0..<2000 where !library.all.contains(where: { $0.postID == todayID }) {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(library.all.first?.postID == todayID, "newest first")
            await library.search("2026-08-03")
            let hit = try #require(library.hits?.first { $0.kind == .post && $0.id == todayID })
            #expect(hit.title == "2026-08-03")
            #expect(MobileLibraryViewModel.destination(for: hit)
                    == .note(todayID, focus: false))

            // BACK: the note reopens in a fresh editor with the bytes.
            let (reopened, storage) = makeEditor(session, postID: todayID)
            await reopened.loadOnce()
            #expect(storage.string == "Dear diary, the shelf works.")
        }
    }

    /// Walk step 8 (S4 batch 1 — the brief's scope item 7): open a book →
    /// Read renders (chapters, paper strings) → tap into a note → add a
    /// comment (marker appears) → set a callout (frame renders) → divide
    /// the block (store rows checked) → merge back → bytes byte-checked →
    /// identity audit clean, canary silent.
    @Test func walk8_readCommentsCalloutDivideMerge() async throws {
        try await withEditorWorld { session, db in
            // A chaptered book: two chapters, three notes.
            let seed = try await session.runner.run { ops -> (bookID: String, noteID: String) in
                let book = try ops.createReading(name: "The Long Field", kind: .book)
                let one = try ops.createSection(in: book.id, name: "Openings")
                let two = try ops.createSection(in: book.id, name: "Middles")
                let n1 = try ops.createPost(title: "What the rain kept")
                _ = try ops.newBlock(
                    in: n1.id, text: "First sentence. Second sentence.", at: .end)
                let n2 = try ops.createPost(title: "The letter")
                _ = try ops.newBlock(in: n2.id, text: "A page can hold its breath.", at: .end)
                let n3 = try ops.createPost(title: "The pause")
                _ = try ops.newBlock(in: n3.id, text: "How long a person can live.", at: .end)
                for id in [n1.id, n2.id, n3.id] {
                    _ = try ops.addPostToReading(id, to: book.id)
                }
                try ops.assignPostToSection(n1.id, in: book.id, section: one.id)
                try ops.assignPostToSection(n2.id, in: book.id, section: one.id)
                try ops.assignPostToSection(n3.id, in: book.id, section: two.id)
                return (book.id, n1.id)
            }

            // OPEN THE BOOK: the Read column's shape from the book's own
            // observation + the pure page brains (LK9 byte-checked).
            let book = MobileBookViewModel(session: session, readingID: seed.bookID)
            let observation = Task { await book.start() }
            defer { observation.cancel() }
            for _ in 0..<2000 where book.entries.count < 3 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            let chapters = MobileReadPage.assemble(book.groupedRows)
            #expect(chapters.map(\.caption) == ["I · OPENINGS", "II · MIDDLES"])
            let slots = chapters.flatMap(\.notes)
            #expect(slots.map(\.ordinal) == [1, 2, 3])
            #expect(slots[0].entry.displayTitle == "What the rain kept")
            #expect(MobileReadPage.pageMeta(
                ordinal: slots[2].ordinal, total: book.entries.count,
                chapterIndex: slots[2].chapterIndex) == "note 3 of 3 · ii")
            // The page's rendered text — the Mac flow's exact read.
            let rendered: String? = try await db.read { [id = seed.noteID] db in
                let noteSlots = try Queries.renderPost(db, containerID: id)
                return Queries.joinRenderedTexts(noteSlots.compactMap(\.text))
            }
            let paragraphs = MobileReadPage.paragraphs(of: rendered ?? "")
            #expect(paragraphs.map { String($0.text.characters) }
                == ["First sentence. Second sentence."])

            // TAP INTO THE NOTE: the real TK2 editor (the walk-1 surface).
            let model = MobileEditorViewModel(
                session: session, postID: seed.noteID,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()
            surface.layoutIfNeeded()
            let blockID = try #require(model.index.entries.first?.blockID)

            // ADD A COMMENT: the sheet's verb; the ●n marker appears.
            model.openComments(blockID: blockID)
            await model.comments.add("Keep the pause unspoken.")
            #expect(model.comments.comments.map(\.text) == ["Keep the pause unspoken."])
            #expect(model.slot(for: blockID)?.commentCount == 1)
            model.comments.close()
            surface.layoutIfNeeded()
            surface.textView.refreshChrome()
            let mark = try #require(
                surface.textView.blockDecor?.commentMark(for: blockID) as? UIButton)
            #expect(mark.title(for: .normal) == "●1")

            // SET A CALLOUT: the ⋯ menu's verb; the frame renders.
            await model.blockMenu.applyCallout(blockID: blockID, edit: .toggle)
            #expect(model.presentations[blockID]?.color == "blue")
            surface.textView.refreshChrome()
            #expect(surface.textView.blockDecor?.frameView(for: blockID) != nil)

            // DIVIDE at the sentence cut (store rows checked).
            await model.structural.divide(atSurfaceCaret: 16)
            #expect(model.statusMessage == nil)
            #expect(try await storedBlockTexts(db, postID: seed.noteID)
                == ["First sentence.", "Second sentence."])
            #expect(model.index.entries.count == 2)
            // The comment copied and the frame inherited (the op's travel).
            let successorID = try #require(model.index.entries.last?.blockID)
            #expect(model.slot(for: successorID)?.commentCount == 1)
            #expect(model.presentations[successorID]?.color == "blue")

            // MERGE BACK: a sentence cut restores EXACTLY (the canon
            // join's own promise — bytes byte-checked).
            // R-13u4-3 (13u4 E3): merge DOORS take the RENDERING join — the page reads
            // byte-identical, the seam a newline. These three pins were rewritten to the
            // ruling at the 13u4 closeout (they asserted the superseded 2026-07-06 space
            // join; E3's mobile sweep covered the merge suites — this walk pin sat outside).
            let successorRange = try #require(model.rangeOfBlock(successorID))
            await model.structural.mergeWithPrevious(
                atSurfaceCaret: successorRange.location + 2)
            #expect(model.statusMessage == nil)
            #expect(try await storedBlockTexts(db, postID: seed.noteID)
                == ["First sentence.\nSecond sentence."])
            #expect(model.index.entries.count == 1)
            #expect(surface.textView.textStorage.string == "First sentence.\nSecond sentence.")

            // Identity intact, canary silent; teardown lands the bytes.
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!surface.textView.canaryFired)
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: seed.noteID)
                == ["First sentence.\nSecond sentence."])
        }
    }
}
