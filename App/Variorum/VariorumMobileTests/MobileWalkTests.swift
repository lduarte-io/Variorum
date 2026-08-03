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
            // gutter; the fanless one wears and reserves nothing.
            #expect(chrome.badgeView(for: seed.blockA) != nil)
            #expect(view.textContainer.exclusionPaths.count == 1)
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
}
