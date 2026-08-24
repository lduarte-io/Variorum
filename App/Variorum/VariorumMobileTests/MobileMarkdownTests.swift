//
//  MobileMarkdownTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 1, batch 2 (M11's first half) — the markdown vocabulary on
//  the phone: render (display == stored, attributes only), the typing
//  behaviors through the ONE shared brain (⏎ continuation, Tab/⇧Tab, the
//  actKeepsIndent law), the checkbox tap-toggle as an ordinary policed
//  edit, and the keyboard bar's six live acts. Byte expectations are the
//  Mac law's letter (the shared `MarkdownEditing`/`MarkdownSyntax`, whose
//  Mac pins pin the same outcomes) — a diverging stored byte here is the
//  two-brains drift this batch exists to make impossible.
//
//  Doors are driven through the REAL `MobileEditorTextView` (the walk
//  pattern): `insertText` for ⏎, the view's Tab handlers, the bar
//  controller's selectors, and the tap door with laid-out geometry.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// A model attached to the REAL surface view (clocks disabled), loaded.
@MainActor
func makeSurfaceEditor(
    _ session: AppSession, postID: String
) async -> (model: MobileEditorViewModel, surface: MobileWriteSurfaceView) {
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    model.attach(textView: surface.textView)
    await model.loadOnce()
    return (model, surface)
}

/// A blog post whose blocks are pre-minted (no crystallization noise).
@MainActor
func makePost(
    _ session: AppSession, blocks: [String], locked: Bool = false
) async throws -> String {
    let post = try await session.runner.run { ops in
        let post = try ops.createPost(title: "md", profile: .blog)
        for text in blocks {
            _ = try ops.newBlock(in: post.id, text: text, at: .end)
        }
        if locked { try ops.lockPost(post.id) }
        return post
    }
    return post.id
}

@MainActor
@Suite("Mobile markdown — render (display == stored; S1 batch 2)")
struct MobileMarkdownRenderTests {
    @Test func faceStylesWithoutTouchingStoredBytes() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(
                session, blocks: ["# Head", "**bold** and `code`"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage

            // DISPLAY == STORED, byte for byte.
            #expect(storage.string == "# Head\n**bold** and `code`")

            // The heading content wears the scaled bold face…
            let headingFont = storage.attribute(.font, at: 2, effectiveRange: nil) as? UIFont
            #expect((headingFont?.pointSize ?? 0) > MobileEditorStyle.baseFont.pointSize)
            // …its marker is dimmed and face-marked…
            let markerColor = storage.attribute(
                .foregroundColor, at: 0, effectiveRange: nil) as? UIColor
            #expect(markerColor == MobileEditorStyle.markdownPalette.marker)
            #expect(storage.attribute(MarkdownFace.faceAttribute, at: 0, effectiveRange: nil) != nil)

            // …bold content is bold…
            let boldIndex = ("# Head\n**".utf16.count)
            let boldFont = storage.attribute(.font, at: boldIndex, effectiveRange: nil) as? UIFont
            #expect(boldFont?.fontDescriptor.symbolicTraits.contains(.traitBold) == true)

            // …and the code chip hugs the WHOLE span, backticks included
            // (13k K10).
            let codeStart = ("# Head\n**bold** and ".utf16.count)
            let chipAtTick = storage.attribute(
                .backgroundColor, at: codeStart, effectiveRange: nil) as? UIColor
            #expect(chipAtTick == MobileEditorStyle.markdownPalette.codeTint)

            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func restyleFollowsTheKeystrokeAndClearsGhosts() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["plain words here"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage

            // Wrap "words" by typing markers around it (policed edits).
            typeEdit(model, storage, range: NSRange(location: 6, length: 0), replacement: "**")
            typeEdit(model, storage, range: NSRange(location: 13, length: 0), replacement: "**")
            #expect(storage.string == "plain **words** here")
            let contentFont = storage.attribute(.font, at: 9, effectiveRange: nil) as? UIFont
            #expect(contentFont?.fontDescriptor.symbolicTraits.contains(.traitBold) == true)

            // Delete one star — the emphasis unreads; no face ghost stays.
            typeEdit(model, storage, range: NSRange(location: 13, length: 1), replacement: "")
            #expect(storage.string == "plain **words* here")
            let plainFont = storage.attribute(.font, at: 9, effectiveRange: nil) as? UIFont
            #expect(plainFont?.fontDescriptor.symbolicTraits.contains(.traitBold) != true)
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func indentedHeadingStaysPlainText() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["  # not a heading"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage
            #expect(storage.string == "  # not a heading")
            // The 13k law: the column-0 widening is LIST-ONLY — an indented
            // heading is prose, so no scaled font anywhere on the line.
            for offset in [0, 4, 8] {
                let font = storage.attribute(.font, at: offset, effectiveRange: nil) as? UIFont
                #expect((font?.pointSize ?? 0) <= MobileEditorStyle.baseFont.pointSize)
            }
        }
    }

    @Test func perEditRescanIsLineScoped() async throws {
        try await withEditorWorld { session, _ in
            let long = String(repeating: "prose sentence again and again. ", count: 200)
            let postID = try await makePost(session, blocks: [long, "- item"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage

            // One keystroke inside the LIST line: the scan must walk that
            // line, never the 6k-char neighbor (P1's letter, the
            // MarkdownScanCount pin — the Mac's discipline on the phone).
            let itemStart = (long as NSString).length + 1
            MarkdownScanCount.reset()
            typeEdit(
                model, storage,
                range: NSRange(location: itemStart + 6, length: 0), replacement: "s")
            #expect(MarkdownScanCount.current > 0)
            #expect(MarkdownScanCount.current < 100)
        }
    }
}

@MainActor
@Suite("Mobile markdown — the ⏎ door (K5/K8; S1 batch 2)")
struct MobileMarkdownReturnTests {
    @Test func textedBulletLineContinuesWithItsLead() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- milk", "prose"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView

            view.selectedRange = NSRange(location: 6, length: 0) // end of "- milk"
            view.insertText("\n")
            #expect(view.textStorage.string == "- milk\n- \nprose")
            #expect(view.selectedRange == NSRange(location: 9, length: 0))

            await model.autosave.flushNow()
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }

    @Test func checkedCheckboxContinuesUnchecked() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- [x] done", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 10, length: 0)
            view.insertText("\n")
            // A continued checkbox is born UNCHECKED (K5's letter).
            #expect(view.textStorage.string == "- [x] done\n- [ ] \nprose")
        }
    }

    @Test func nestedItemContinuesAtItsOwnLevel() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["  - deep", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 8, length: 0)
            view.insertText("\n")
            // K8: the lead CARRIES THE INDENT.
            #expect(view.textStorage.string == "  - deep\n  - \nprose")
        }
    }

    @Test func midLineReturnIsOrdinary() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- milk", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 3, length: 0)
            view.insertText("\n")
            // No lead — the conservative mid-item reading, the Mac's letter.
            #expect(view.textStorage.string == "- m\nilk\nprose")
        }
    }

    @Test func headingNeverContinues() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["# Head", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 6, length: 0)
            view.insertText("\n")
            #expect(view.textStorage.string == "# Head\n\nprose")
        }
    }

    @Test func emptyItemAtLevelZeroExitsTheList() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- ", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 2, length: 0)
            view.insertText("\n")
            // The lead goes; NO newline is inserted (the consumed keystroke).
            #expect(view.textStorage.string == "\nprose")
            #expect(view.selectedRange == NSRange(location: 0, length: 0))
        }
    }

    @Test func emptyNestedItemOutdentsFirstThenExits() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["  - ", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 4, length: 0)
            view.insertText("\n")
            // K8: outdent FIRST — one unit off, still a list item.
            #expect(view.textStorage.string == "- \nprose")
            #expect(view.selectedRange == NSRange(location: 2, length: 0))
            view.insertText("\n")
            // At the margin, K5's exit — byte-identical to her ruling.
            #expect(view.textStorage.string == "\nprose")
        }
    }

    @Test func selectionsReturnIsOrdinary() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- milk", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 2, length: 4) // "milk"
            view.insertText("\n")
            #expect(view.textStorage.string == "- \n\nprose")
        }
    }

    @Test func tailCrystallizationKeepsAListLinesIndent_adjudicationPin() async throws {
        // THE TRIM-LAW ADJUDICATION PIN (S1 batch 3 — the batch-2 recorded
        // finding `tailCrystallizationTrimsLeadingIndent_recordedFinding`
        // FLIPPED, exactly as that documentation test said a deliberate fix
        // should). The architect's ruling: the Phase-2 trim aligns to 13k
        // K8's own boundary — a segmented line whose form is a LIST LEAD
        // per the shared `MarkdownSyntax` law KEEPS its leading horizontal
        // whitespace (the indent is meaningful nesting content); every
        // other line trims exactly as before. The batch-2 asymmetry is
        // gone: the ⏎ continuation's lead kept the indent (K8's letter)
        // and now the minted line keeps its own too. SHARED core law — the
        // Mac's tail path inherits the same fix (its delta is enumerated
        // in the batch-3 record).
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "trim", profile: .blog)
            }
            let (model, surface) = await makeSurfaceEditor(session, postID: post.id)
            let view = surface.textView
            view.insertText("  - deep")
            view.insertText("\n")
            await model.awaitMintSettle()
            #expect(view.textStorage.string == "  - deep\n  - ")
            #expect(try await storedBlockTexts(db, postID: post.id) == ["  - deep"])
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func pastedNestedListKeepsItsIndent_adjudicationPin() async throws {
        // The adjudication's second red-on-old duty: the BULK door. A
        // pasted nested list used to flatten (every piece lost its lead at
        // `bulkSegments`' Phase-2 trim); under the K8 alignment the stored
        // bytes are the paste's own — space and tab indents, checkbox
        // included — and the surface reproduces them exactly.
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "paste list", profile: .blog)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            typeAtEnd(model, storage, "- milk\n  - eggs\n    - [ ] flour", isPaste: true)
            await model.awaitMintSettle()
            #expect(try await storedBlockTexts(db, postID: post.id)
                    == ["- milk", "  - eggs", "    - [ ] flour"])
            #expect(storage.string == "- milk\n  - eggs\n    - [ ] flour")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func sealedNoteRefusesTheContinuation() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- milk"], locked: true)
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 6, length: 0)
            view.insertText("\n")
            // The pre-gate refused; nothing landed and the refusal spoke.
            #expect(view.textStorage.string == "- milk")
            #expect(model.statusMessage != nil)
        }
    }
}

@MainActor
@Suite("Mobile markdown — Tab, ⇧Tab and the acts (K8/M11; S1 batch 2)")
struct MobileMarkdownActsTests {
    @Test func tabIndentsAListLineByOneUnit() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- a", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 3, length: 0)
            view.performTabKey()
            #expect(view.textStorage.string == "  - a\nprose")
            view.performShiftTabKey()
            #expect(view.textStorage.string == "- a\nprose")
        }
    }

    @Test func tabOutsideAListIsTheOrdinaryKey() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 5, length: 0)
            view.performTabKey()
            #expect(view.textStorage.string == "prose\t")
            // ⇧Tab has no ordinary character — nothing happens.
            view.performShiftTabKey()
            #expect(view.textStorage.string == "prose\t")
        }
    }

    @Test func mixedIndentRunOutdentsByTheOneSharedUnit() async throws {
        try await withEditorWorld { session, _ in
            // " \t" is ONE drawn level; the 13k MINOR-1 rule takes the whole
            // run's unit, never just the space (one rule, all doors).
            let postID = try await makePost(session, blocks: [" \t- a", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 5, length: 0)
            view.performShiftTabKey()
            #expect(view.textStorage.string == "- a\nprose")
        }
    }

    @Test func multiLineSelectionIndentsOnlyListLines() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["pre\n- a\npost"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 0, length: 12)
            view.performTabKey()
            #expect(view.textStorage.string == "pre\n  - a\npost")
        }
    }

    @Test func boldTogglesAndLandsInTheStore() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["hello world"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 6, length: 5) // "world"
            #expect(MobileMarkdownActs.apply(.bold, to: view))
            #expect(view.textStorage.string == "hello **world**")

            // An act is an ORDINARY edit: autosave routed it to the store.
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID) == ["hello **world**"])

            // The toggle rule: applying again unwraps.
            #expect(MobileMarkdownActs.apply(.bold, to: view))
            #expect(view.textStorage.string == "hello world")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID) == ["hello world"])
            #expect(model.identityAuditFailures == 0)
        }
    }

    /// The C4b arrivals (strike · code · link) land through the SAME
    /// shared brain and the same ordinary policed input path as the
    /// standing six — the doors are the bar controller's own selectors
    /// (exactly what the strip's buttons target), the bytes land in the
    /// store, and the link act leaves the caret inside its empty parens
    /// (the law's own contract: the text is written, the ADDRESS is
    /// what she is about to supply).
    @Test func strikethroughCodeAndLinkLandInTheStore() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["hello world"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            let bar = MobileKeyboardBarController(textView: view)

            // Strikethrough wraps and toggles back off.
            view.selectedRange = NSRange(location: 6, length: 5) // "world"
            bar.fireStrikethrough()
            #expect(view.textStorage.string == "hello ~~world~~")
            bar.fireStrikethrough()
            #expect(view.textStorage.string == "hello world")

            // Inline code, the same toggle rule.
            view.selectedRange = NSRange(location: 6, length: 5)
            bar.fireCode()
            #expect(view.textStorage.string == "hello `world`")
            bar.fireCode()
            #expect(view.textStorage.string == "hello world")

            // Add link: `[world](|)` — the caret sits inside the parens.
            view.selectedRange = NSRange(location: 6, length: 5)
            bar.fireLink()
            #expect(view.textStorage.string == "hello [world]()")
            #expect(view.selectedRange == NSRange(location: 14, length: 0))

            // Ordinary edits: autosave routed the bytes to the store.
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["hello [world]()"])
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func emptySelectionBoldIsTheCaretGesture() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["hello "])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 6, length: 0)
            #expect(MobileMarkdownActs.apply(.bold, to: view))
            #expect(view.textStorage.string == "hello ****")
            // The caret sits between the markers, ready for the next word.
            #expect(view.selectedRange == NSRange(location: 8, length: 0))
        }
    }

    @Test func headingCycleClimbsThenClears() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["title"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            let bar = MobileKeyboardBarController(textView: view)
            view.selectedRange = NSRange(location: 3, length: 0)

            bar.fireHeading()
            #expect(view.textStorage.string == "# title")
            bar.fireHeading()
            #expect(view.textStorage.string == "## title")
            bar.fireHeading()
            #expect(view.textStorage.string == "### title")
            bar.fireHeading()
            #expect(view.textStorage.string == "title")
        }
    }

    /// P5 (parity A3, her ruled flip): "# tap still cycles; LONG-PRESS
    /// opens a direct H1/H2/H3/clear picker." The picker's rows are the
    /// Mac heading submenu's own toggle acts (picking a line's own level
    /// clears it — one vocabulary) plus her clear row; titles voice-case
    /// (P26/P43); the tap's cycle is byte-unchanged (the standing pin
    /// above still covers it).
    @Test func headingLongPressPicksDirectlyAndClearClears() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["title"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            let bar = MobileKeyboardBarController(textView: view)
            view.selectedRange = NSRange(location: 3, length: 0)

            // The rows, voice-cased (the world runs terminal).
            let titles = bar.headingPickerElements().compactMap { ($0 as? UIAction)?.title }
            #expect(titles == ["heading 1", "heading 2", "heading 3", "clear heading"])

            // Direct picks jump levels — no cycling through.
            bar.applyHeadingPick(level: 2)
            #expect(view.textStorage.string == "## title")
            bar.applyHeadingPick(level: 3)
            #expect(view.textStorage.string == "### title")

            // Clear clears ANY level in one act…
            bar.applyHeadingClear()
            #expect(view.textStorage.string == "title")
            // …and no-ops where no heading exists (nothing to clear).
            bar.applyHeadingClear()
            #expect(view.textStorage.string == "title")

            // Picking the line's own level is the shared toggle (the Mac
            // submenu's exact semantics — deliberately not special-cased).
            bar.applyHeadingPick(level: 1)
            #expect(view.textStorage.string == "# title")
            bar.applyHeadingPick(level: 1)
            #expect(view.textStorage.string == "title")

            // The wiring: the strip's # is a button whose menu is NOT the
            // primary action — tap keeps the cycle, long-press reveals
            // the picker (UIKit's own behavior for exactly this config).
            // The # lives behind the Aa door since the ruling — expand
            // first (the in-place swap).
            guard let toolbar = bar.makeBar() as? UIToolbar else {
                Issue.record("the bar is not a toolbar")
                return
            }
            bar.toggleFormattingDoor()
            // (Since C4b the capsule holds two ROW stacks — the lookup
            // descends a level; the wiring itself is byte-identical.)
            let headingButton = try #require((toolbar.items ?? [])
                .compactMap { $0.customView as? UIStackView }
                .first { $0.accessibilityIdentifier == "kbar.formattingStrip" }?
                .arrangedSubviews
                .flatMap { ($0 as? UIStackView)?.arrangedSubviews ?? [$0] }
                .compactMap { $0 as? UIButton }
                .first { $0.accessibilityIdentifier == "kbar.heading" })
            #expect(headingButton.menu != nil)
            #expect(!headingButton.showsMenuAsPrimaryAction)
        }
    }

    @Test func headingActAtDepthMintsAWorkingColumnZeroHeading() async throws {
        try await withEditorWorld { session, _ in
            // The 13k round-1 MAJOR's law (actKeepsIndent): a heading act on
            // a NESTED list item replaces the WHOLE lead — indent included —
            // because an indented heading would be neither a heading nor a
            // list (#49(b)'s letter).
            let postID = try await makePost(session, blocks: ["  - [ ] eggs", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 10, length: 0)
            #expect(MobileMarkdownActs.apply(.heading(level: 1), to: view))
            #expect(view.textStorage.string == "# eggs\nprose")
        }
    }

    @Test func listLeadsKeepTheIndentWhenRelead() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["  - eggs", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 6, length: 0)
            // Bullet → checklist keeps nesting (actKeepsIndent's other arm).
            #expect(MobileMarkdownActs.apply(.checkbox, to: view))
            #expect(view.textStorage.string == "  - [ ] eggs\nprose")
        }
    }

    @Test func actsRefuseOnASealedNote() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["hello world"], locked: true)
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            view.selectedRange = NSRange(location: 0, length: 5)
            #expect(!MobileMarkdownActs.apply(.bold, to: view))
            #expect(view.textStorage.string == "hello world")
            #expect(model.statusMessage != nil)
        }
    }

    @Test func aWidenedAttributeFixReportNeverPoisonsTheSeparator() async throws {
        // THE BATCH-2 RE-STAMP FIX'S PIN (red-on-old: on the pre-fix code
        // this run DIES at the DEBUG identity audit). Mechanism, traced
        // with diagnostic evidence in walk3: iOS attribute fixing WIDENED
        // the `didProcessEditing` report for a 2-char insert at a block's
        // line start to the whole edited paragraph INCLUDING its
        // terminating newline — the block SEPARATOR — and the re-stamp,
        // taking its extent from the report, gave the separator an owner
        // (entries len 6/len 8; runs `[7,+9]`). The fix
        // (`restampProjection`) takes the extent from the INDEX, the one
        // authority, so a widened report can only re-stamp what is true.
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "widen", profile: .blog)
            }
            let (model, surface) = await makeSurfaceEditor(session, postID: post.id)
            let view = surface.textView
            view.insertText("- milk")
            view.insertText("\n")
            view.insertText("eggs")
            view.insertText("\n")
            await model.awaitMintSettle()
            view.insertText("\n") // exit the empty item (K5)
            #expect(view.textStorage.string == "- milk\n- eggs\n")

            // The trigger: an indent INTO a block whose line terminator is
            // the separator (the walk3 Tab step, minimally).
            view.selectedRange = NSRange(location: 13, length: 0)
            view.performTabKey()
            #expect(view.textStorage.string == "- milk\n  - eggs\n")

            // Neither separator wears an owner; the audit stayed clean.
            #expect(EditorDocument.blockID(at: 6, in: view.textStorage) == nil)
            #expect(EditorDocument.blockID(at: 15, in: view.textStorage) == nil)
            #expect(model.identityAuditFailures == 0)
        }
    }

    /// The Aa condensation's pin set (parity A3 item 1 — HER RULING on
    /// the propose-first fork: the expanding row): the bar RESTS on
    /// three doors (Aa · ⑂ · ⋯); Aa expands the formatting strip
    /// (× · B · I · S · ⟨⟩ · 🔗 · # · • · ☑ · ⇥ · ⇤ since her R22 + M26
    /// — LK8's relative order intact inside it) IN PLACE on the same
    /// toolbar; × collapses back (round-trip); a fresh keyboard
    /// presentation resets to collapsed (the keyboard-hide mechanism,
    /// posted deterministically — the A1 notification precedent). The
    /// acts fire byte-identically from the strip — the act pins
    /// throughout this file drive the controller's own selectors, which
    /// are exactly what the strip's buttons target. (This pin's earlier
    /// flat-bar forms recorded LK8's arrivals; the condensation is the
    /// ruled supersession.)
    @Test func theBarRestsOnThreeDoorsAndAaExpandsTheStripInPlace() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["x"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let bar = MobileKeyboardBarController(textView: surface.textView)
            guard let toolbar = bar.makeBar() as? UIToolbar else {
                Issue.record("the bar is not a toolbar")
                return
            }
            // Since FIX-5 the expanded acts ride ONE strip container
            // (seven separate items overflowed the bar). The capsule
            // holds ROW stacks — one row since her R22, two before it —
            // so labels flatten row by row and keep reading in door
            // order however the strip is split.
            func labels() -> [String] {
                (toolbar.items ?? []).flatMap { item -> [String] in
                    if let strip = item.customView as? UIStackView,
                       strip.accessibilityIdentifier == "kbar.formattingStrip" {
                        return strip.arrangedSubviews.flatMap { child -> [String] in
                            if let row = child as? UIStackView {
                                return row.arrangedSubviews.compactMap { $0.accessibilityLabel }
                            }
                            return [child.accessibilityLabel].compactMap { $0 }
                        }
                    }
                    if let label = item.accessibilityLabel
                        ?? (item.customView as? UIButton)?.accessibilityLabel {
                        return [label]
                    }
                    return []
                }
            }

            // At rest: the three doors, in order — on the one bar height.
            #expect(!bar.isFormattingExpanded)
            #expect(labels() == MobileKeyboardBarController.restingActLabels)
            #expect(MobileKeyboardBarController.restingActLabels
                    == ["Formatting", "Takes", "Block"])
            #expect(toolbar.frame.height == MobileKeyboardBarController.barHeight)

            // Aa expands IN PLACE (same toolbar instance, items swapped).
            // The HEIGHT no longer moves with the state (round 2 batch 2,
            // M4 ≡ R7): this pin used to assert a taller expanded bar, and
            // that assertion was green over wiring that never reached a
            // pixel — an installed `inputAccessoryView` keeps the height
            // it was presented at (proven: a 160 pt expanded height
            // captured pixel-identical to 104). One height hosts both
            // states, and `barHeight` clears the two-row capsule.
            bar.toggleFormattingDoor()
            #expect(bar.isFormattingExpanded)
            #expect(labels() == MobileKeyboardBarController.formattingActLabels)
            // ELEVEN acts on ONE row since her R22 + M26 — the two former
            // rows flattened IN PLACE (so LK8's relative order of the
            // standing seven and C4b's after-Italic placement of
            // strike/code/link both survive untouched) with ⇤ landing
            // beside the ⇥ it mirrors. The order is pinned so a later
            // session cannot re-shuffle her strip by accident.
            #expect(MobileKeyboardBarController.formattingActLabels
                    == ["Hide Formatting", "Bold", "Italic", "Strikethrough",
                        "Inline Code", "Add Link",
                        "Heading", "Bullet List", "Checklist", "Indent",
                        "Outdent"])
            #expect(toolbar.frame.height == MobileKeyboardBarController.barHeight)

            // × collapses back — the round-trip, height included.
            bar.toggleFormattingDoor()
            #expect(!bar.isFormattingExpanded)
            #expect(labels() == MobileKeyboardBarController.restingActLabels)
            #expect(toolbar.frame.height == MobileKeyboardBarController.barHeight)

            // Reset-per-presentation: an expanded strip collapses when
            // the keyboard goes away, so the next raise starts calm.
            bar.toggleFormattingDoor()
            #expect(bar.isFormattingExpanded)
            NotificationCenter.default.post(
                name: UIResponder.keyboardDidHideNotification, object: nil)
            #expect(!bar.isFormattingExpanded)
            #expect(labels() == MobileKeyboardBarController.restingActLabels)
        }
    }

    // **THE BAR'S GEOMETRY PINS MOVED OUT — 2026-08-22, sub-batch 4.5d.**
    // `theBarClearsEveryGlassCellWithAirBeneathIt` and
    // `allElevenStripActsSitFullyVisibleAndTappableInsideTheBar` lived
    // here and could not see the defect they guarded: the first reduced
    // to `air >= air` (every term a constant the bar computes from the
    // others), and the second compared the strip to a literal 375-derived
    // number while its own toolbar was 320 pt wide — so a strip hanging
    // 9 pt off each edge of a Display-Zoom bar measured green. They are
    // rebuilt against MEASURED frames from a hosted toolbar, at every
    // width the app can be shown at, in
    // `MobileKeyboardBarGeometryTests.swift`. The bar's DOOR and ACT pins
    // stay here, where the rest of the markdown vocabulary lives.

    /// **M26 ≡ R21 — the visible ⇤, driven as a TAP on the real button.**
    /// Her words: *"i think an indent to the left button should be added
    /// to the set of formatting buttons though - there's an indent in
    /// but not an un-indent."* Outdent already existed, was tested, and
    /// was documented — as a LONG-PRESS on ⇥, which is invisible, and a
    /// VoiceOver hint, which is not an affordance for sighted use. She
    /// looked and reasonably concluded it did not exist.
    ///
    /// So this pin deliberately does NOT call `fireOutdent()`. It finds
    /// the ⇤ button inside the REAL expanded strip and sends it the
    /// touch-up the finger sends, which is the whole content of the
    /// finding: **the act was never missing, the DOOR was.** A pin on
    /// the selector would have been green throughout the months she
    /// could not find it (§26's rule, and §34's correction — drive the
    /// real surface, and verify the path you drove is the path you
    /// meant: `sendActions` is exactly UIKit's own tap dispatch for a
    /// target-action button, not an API that bypasses it).
    ///
    /// It then asserts the OTHER half of the ruling — that ⇥'s
    /// long-press survives — through the same shared brain, so the two
    /// doors are proven to be one act.
    @Test func theVisibleOutdentButtonUnindentsOnAPlainTap() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["- milk", "  - eggs"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let view = surface.textView
            let bar = MobileKeyboardBarController(textView: view)
            guard let toolbar = bar.makeBar() as? UIToolbar else {
                Issue.record("the bar is not a toolbar")
                return
            }
            bar.toggleFormattingDoor()

            let buttons = (toolbar.items ?? [])
                .compactMap { $0.customView as? UIStackView }
                .first { $0.accessibilityIdentifier == "kbar.formattingStrip" }?
                .arrangedSubviews
                .flatMap { ($0 as? UIStackView)?.arrangedSubviews ?? [$0] }
                .compactMap { $0 as? UIButton } ?? []

            // The door exists, is labelled with the capability
            // registry's own verb, and speaks for VoiceOver.
            let outdent = try #require(
                buttons.first { $0.accessibilityIdentifier == "kbar.outdent" })
            #expect(outdent.accessibilityLabel == "Outdent")
            #expect(outdent.accessibilityHint == "Moves the line out one level")
            #expect(outdent.currentTitle == "⇤")

            // A TAP — UIKit's own dispatch — un-indents the caret's line
            // through the ordinary policed input path…
            view.selectedRange = NSRange(location: 12, length: 0) // in "eggs"
            outdent.sendActions(for: .touchUpInside)
            #expect(view.textStorage.string == "- milk\n- eggs")
            // …and it is an ORDINARY edit, so the store has it.
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["- milk", "- eggs"])
            #expect(model.identityAuditFailures == 0)

            // ⇥'s long-press SURVIVES (four doors, one act): indent back
            // in, then out again through the older door.
            let indent = try #require(
                buttons.first { $0.accessibilityIdentifier == "kbar.indent" })
            #expect(indent.accessibilityHint == "Long-press to outdent")
            #expect(indent.gestureRecognizers?
                .contains { $0 is UILongPressGestureRecognizer } == true)
            view.selectedRange = NSRange(location: 10, length: 0)
            indent.sendActions(for: .touchUpInside)
            #expect(view.textStorage.string == "- milk\n  - eggs")
            bar.fireOutdent()
            #expect(view.textStorage.string == "- milk\n- eggs")
        }
    }
}

@MainActor
@Suite("Mobile markdown — the checkbox tap (L9's phone twin; S1 batch 2)")
struct MobileCheckboxTapTests {
    /// The midpoint of the box's glyph rect, through real laid-out geometry.
    private func boxPoint(
        in view: MobileEditorTextView, boxRange: NSRange
    ) -> CGPoint? {
        guard let start = view.position(from: view.beginningOfDocument, offset: boxRange.location + 1),
              let end = view.position(from: view.beginningOfDocument, offset: boxRange.location + 2),
              let range = view.textRange(from: start, to: end)
        else { return nil }
        let rect = view.firstRect(for: range)
        guard !rect.isNull, !rect.isEmpty else { return nil }
        return CGPoint(x: rect.midX, y: rect.midY)
    }

    @Test func tapInsideTheBoxTogglesBothWaysPreservingTheCaret() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["- [ ] milk", "prose"])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            surface.layoutIfNeeded()
            let view = surface.textView
            view.selectedRange = NSRange(location: 9, length: 0)

            let point = try #require(boxPoint(in: view, boxRange: NSRange(location: 2, length: 3)))
            #expect(MobileMarkdownActs.toggleCheckbox(at: point, in: view))
            #expect(view.textStorage.string == "- [x] milk\nprose")
            // Three characters for three: the caret never moved.
            #expect(view.selectedRange == NSRange(location: 9, length: 0))

            // An ordinary policed edit: it lands in the store.
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID) == ["- [x] milk", "prose"])

            #expect(MobileMarkdownActs.toggleCheckbox(at: point, in: view))
            #expect(view.textStorage.string == "- [ ] milk\nprose")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func tapOutsideTheBoxIsNeverConsumed() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- [ ] milk", "prose"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            surface.layoutIfNeeded()
            let view = surface.textView

            // A point over the item's TEXT — strictly outside the box.
            guard let start = view.position(from: view.beginningOfDocument, offset: 7),
                  let end = view.position(from: view.beginningOfDocument, offset: 9),
                  let range = view.textRange(from: start, to: end)
            else {
                Issue.record("no laid-out geometry for the text run")
                return
            }
            let rect = view.firstRect(for: range)
            let point = CGPoint(x: rect.midX, y: rect.midY)
            #expect(!MobileMarkdownActs.toggleCheckbox(at: point, in: view))
            #expect(view.textStorage.string == "- [ ] milk\nprose")
        }
    }

    @Test func sealedNoteConsumesTheTapButRefusesTheEdit() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["- [ ] milk"], locked: true)
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            surface.layoutIfNeeded()
            let view = surface.textView
            let point = try #require(boxPoint(in: view, boxRange: NSRange(location: 2, length: 3)))
            // Consumed (it landed on a box — the Mac's posture), but the
            // gate refused and spoke; not a byte moved.
            #expect(MobileMarkdownActs.toggleCheckbox(at: point, in: view))
            #expect(view.textStorage.string == "- [ ] milk")
            #expect(model.statusMessage != nil)
        }
    }
}
