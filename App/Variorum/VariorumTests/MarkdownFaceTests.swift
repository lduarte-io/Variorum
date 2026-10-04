//
//  MarkdownFaceTests.swift
//  VariorumTests
//
//  Phase 13g batch 2 (L7): the dimmed-marker editing face (F-2/F-5) over the
//  markdown-as-content storage (F-1).
//
//  The pins are organized around the three claims the face makes:
//    1. DISPLAY == STORED, byte for byte — on the pure materialization and
//       through the REAL NSTextView pipeline, against the store;
//    2. the face is ATTRIBUTES ONLY, and text with no markdown is written to
//       ZERO times (so prose behaves exactly as it did before this batch);
//    3. the rescan is ∝ the edited paragraph(s), never the document (P1).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withVoice<T>(
    _ voice: ThemeVoice = .terminal, _ body: () throws -> T
) rethrows -> T {
    let savedTypography = EditorTypography.current
    let savedPalette = MarkdownStyling.palette
    defer {
        EditorTypography.current = savedTypography
        MarkdownStyling.palette = savedPalette
    }
    EditorTypography.current = EditorTypography.resolve(voice: voice, inlineComments: false)
    MarkdownStyling.palette = MarkdownStyling.Palette(
        tokens: VoiceTokens.resolve(voice: voice, dark: false))
    return try body()
}

private func font(_ text: NSAttributedString, at offset: Int) -> NSFont? {
    text.attribute(.font, at: offset, effectiveRange: nil) as? NSFont
}

private func color(_ text: NSAttributedString, at offset: Int) -> NSColor? {
    text.attribute(.foregroundColor, at: offset, effectiveRange: nil) as? NSColor
}

private func isBold(_ text: NSAttributedString, at offset: Int) -> Bool {
    font(text, at: offset)?.fontDescriptor.symbolicTraits.contains(.bold) ?? false
}

@MainActor
@Suite("The markdown editing face (13g batch 2, L7)")
struct MarkdownFaceTests {

    // MARK: - 1. Display == stored

    @Test func materializationStylesWITHOUTMovingASingleByte() {
        withVoice {
            let source = "# Title\nsay **this** and `that`\n- [x] done"
            let (text, index) = EditorDocument.materialize([slot("a", text: source)])
            // THE invariant (F-2). Not "roughly" — exactly.
            #expect(text.string == source)
            #expect(text.length == (source as NSString).length)
            // And the block index still tiles the surface it was built for.
            #expect(index.range(ofEntryAt: 0)
                == NSRange(location: 0, length: (source as NSString).length))
            #expect(EditorDocument.blockID(at: 0, in: text) == "a")
            #expect(EditorDocument.blockID(at: text.length - 1, in: text) == "a")
        }
    }

    @Test func aMarkdownHeavySessionLeavesTheStoreAndTheViewIdentical() async throws {
        try await withEditor(seedBlocks: ["plain opening"]) { h in
            h.type("\n- [ ] a **task** with a [link](https://x.test/a(b))", at: 13)
            h.type(" and `code`")
            await h.flush()
            // The store holds exactly the characters the surface shows — the
            // whole point of F-1 + F-2 together.
            try expectStoreMatchesView(h)
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == [
                "plain opening\n- [ ] a **task** with a [link](https://x.test/a(b)) and `code`",
            ])
            // The face is really on (this is not a no-op test).
            let storage = try #require(h.textView.textStorage)
            let boldAt = (h.documentText as NSString).range(of: "task").location
            #expect(isBold(storage, at: boldAt))
        }
    }

    // MARK: - 2. Attributes only, and nothing at all for plain prose

    /// DISCRIMINATING REVERT: delete `MarkdownStyling.restyle`'s
    /// `guard !spans.isEmpty || !applied.isEmpty else { return false }`.
    /// Verified RED (both `== false` expectations fail; the whole rest of the
    /// suite stays green).
    @Test func proseWithNoMarkdownIsNEVERWrittenTo() {
        withVoice {
            let plain = NSTextStorage(
                string: "Just ordinary prose, with a hyphen-word and 2 * 3 arithmetic.",
                attributes: EditorDocument.baseAttributes)
            let before = NSAttributedString(attributedString: plain)
            // The face must not touch the storage of a note that carries no
            // markdown — the honest default, and what keeps the A47c
            // full-range-write class away from ordinary typing. (Measured
            // while writing this: an empty begin/endEditing pair posts no
            // `processEditing`, so the counter below is a standing property
            // rather than the discriminator — the returned `false` is.)
            let edits = LockIsolated(0)
            let token = NotificationCenter.default.addObserver(
                forName: NSTextStorage.didProcessEditingNotification,
                object: plain, queue: nil
            ) { _ in edits.withValue { $0 += 1 } }
            defer { NotificationCenter.default.removeObserver(token) }

            #expect(MarkdownStyling.style(plain) == false, "the zero-write fast path")
            #expect(plain.isEqual(to: before),
                    "not one attribute moved — prose behaves exactly as it did before 13g")

            // And on the incremental door too.
            #expect(MarkdownStyling.restyle(plain, range: NSRange(location: 5, length: 3)) == false)
            #expect(plain.isEqual(to: before))
            #expect(edits.value == 0, "no layout pass came out of prose")
        }
    }

    @Test func markersDimAndContentTakesItsFace() {
        withVoice {
            let storage = NSTextStorage(
                string: "a **bold** and *slanted* and ~~cut~~ and `mono`",
                attributes: EditorDocument.baseAttributes)
            #expect(MarkdownStyling.style(storage) == true)
            let marker = MarkdownStyling.palette.marker
            let string = storage.string as NSString

            let bold = string.range(of: "**bold**").location
            #expect(color(storage, at: bold) == marker, "the opening ** is dimmed")
            #expect(isBold(storage, at: bold + 2))
            #expect(color(storage, at: bold + 2) != marker, "the WORD is not dimmed")

            let italic = string.range(of: "*slanted*").location
            #expect(color(storage, at: italic) == marker)
            #expect(font(storage, at: italic + 1)?.fontDescriptor.symbolicTraits
                .contains(.italic) == true)

            let struck = string.range(of: "~~cut~~").location
            #expect(storage.attribute(.strikethroughStyle, at: struck + 2, effectiveRange: nil)
                as? Int == NSUnderlineStyle.single.rawValue)
            #expect(storage.attribute(.strikethroughStyle, at: struck, effectiveRange: nil) == nil,
                    "the markers themselves are not struck through")

            let code = string.range(of: "`mono`").location
            #expect(font(storage, at: code + 1)?.fontDescriptor.symbolicTraits
                .contains(.monoSpace) == true)
        }
    }

    @Test func aLinkColorsItsTextAndDimsItsURL() {
        withVoice {
            let storage = NSTextStorage(
                string: "see [the notes](https://x.test/a) now",
                attributes: EditorDocument.baseAttributes)
            #expect(MarkdownStyling.style(storage) == true)
            let string = storage.string as NSString
            let open = string.range(of: "[the notes]").location
            #expect(color(storage, at: open) == MarkdownStyling.palette.marker, "[")
            #expect(color(storage, at: open + 1) == MarkdownStyling.palette.link, "the text")
            let url = string.range(of: "https://x.test/a").location
            #expect(color(storage, at: url) == MarkdownStyling.palette.marker,
                    "F-5: text link-colored, the (url) dimmed")
        }
    }

    @Test func headingsRenderAsSizesAndComposeWithInlineFaces() {
        withVoice {
            let storage = NSTextStorage(
                string: "# A **Big** title", attributes: EditorDocument.baseAttributes)
            #expect(MarkdownStyling.style(storage) == true)
            let base = EditorDocument.baseFont
            let string = storage.string as NSString

            #expect(color(storage, at: 0) == MarkdownStyling.palette.marker, "the # is dimmed")
            #expect(font(storage, at: 0)?.pointSize == base.pointSize,
                    "the marker keeps the base size")
            let titleAt = string.range(of: "A ").location
            let headingSize = try? #require(font(storage, at: titleAt)?.pointSize)
            #expect((headingSize ?? 0) > base.pointSize, "headings ARE sizes (F-3)")

            // Composition: the bold inside the heading is bold AND still the
            // heading's size — the styler derives from what is already there.
            let boldAt = string.range(of: "Big").location
            #expect(isBold(storage, at: boldAt))
            #expect(font(storage, at: boldAt)?.pointSize == headingSize)
        }
    }

    @Test func listsAndCheckboxesDimTheirLeadAndLeaveTheItemAsProse() {
        withVoice {
            let storage = NSTextStorage(
                string: "- milk\n- [x] eggs", attributes: EditorDocument.baseAttributes)
            #expect(MarkdownStyling.style(storage) == true)
            let marker = MarkdownStyling.palette.marker
            #expect(color(storage, at: 0) == marker, "the bullet's hyphen")
            #expect(color(storage, at: 2) != marker, "the item reads as prose")
            let string = storage.string as NSString
            let box = string.range(of: "[x]").location
            #expect(color(storage, at: box) == marker)
            #expect(color(storage, at: box + 4) != marker, "eggs")
            // NSTextList is never invoked (TEXTKIT2 §1/§3) — a list is text.
            let paragraph = storage.attribute(.paragraphStyle, at: 0, effectiveRange: nil)
                as? NSParagraphStyle
            #expect(paragraph?.textLists.isEmpty ?? true)
        }
    }

    /// DISCRIMINATING REVERT: skip `MarkdownStyling.restyle`'s clear loop
    /// (`for (sub, value) in applied`). Verified RED — the stale bold and the
    /// stale marker colour survive the syntax's deletion.
    @Test func removingTheSyntaxRESTORESTheProseFaceExactly() {
        withVoice {
            // The clear half: a face applied and then un-applied must leave
            // the storage where it started, or stale bold accumulates as she
            // edits.
            let plain = "say this now"
            let pristine = NSTextStorage(
                string: plain, attributes: EditorDocument.baseAttributes)
            pristine.addAttribute(
                .foregroundColor, value: NSColor.systemBrown,
                range: NSRange(location: 0, length: pristine.length))
            let reference = NSAttributedString(attributedString: pristine)

            let storage = NSTextStorage(
                string: "say **this** now", attributes: EditorDocument.baseAttributes)
            storage.addAttribute(
                .foregroundColor, value: NSColor.systemBrown,
                range: NSRange(location: 0, length: storage.length))
            // 18j (the 18g ladder's R2-1): the face clears back to the HOST'S
            // CURRENT ink, which the host DECLARES in its palette — so a
            // surface whose prose is systemBrown says so. The round trip this
            // pin states is byte-unchanged (`isEqual(to: reference)` below);
            // what changed is the road to it, because capturing the colour
            // off the storage is precisely what left every face in the old
            // ink after a dark toggle. `withVoice`'s defer restores this.
            let voiced = MarkdownStyling.palette
            MarkdownStyling.palette = MarkdownStyling.Palette(
                marker: voiced.marker, link: voiced.link,
                codeTint: voiced.codeTint, prose: .systemBrown)
            #expect(MarkdownStyling.style(storage) == true)
            #expect(color(storage, at: 4) == MarkdownStyling.palette.marker)

            // Now the writer deletes the two marker pairs.
            storage.replaceCharacters(in: NSRange(location: 10, length: 2), with: "")
            storage.replaceCharacters(in: NSRange(location: 4, length: 2), with: "")
            #expect(storage.string == plain)
            #expect(MarkdownStyling.restyle(
                storage, range: NSRange(location: 4, length: 0)) == true)

            #expect(storage.isEqual(to: reference),
                    "the surface's own ink came back, not a guessed one")
            #expect(storage.attribute(
                MarkdownStyling.faceAttribute, at: 4, effectiveRange: nil) == nil)
        }
    }

    /// A voice SWITCH is the settings' authority landing (`ThemeStore.start`
    /// → `EditorTypography.adopt`) and the surface's chrome re-applying after
    /// it — so the pin models both halves. (The round-end Fable pass, MINOR-1:
    /// `applyVoiceChrome` no longer writes the global typography once a voice
    /// is adopted — a drawing host must not move the stamp — and any full run
    /// has adopted one by the time this suite runs, so a chrome applied with
    /// no adoption is not a switch; it was the very defect that fix closed.)
    @Test func theFaceFollowsAVoiceSwitch() {
        withVoice {
            let (text, _) = EditorDocument.materialize([slot("a", text: "a **bold** word")])
            let view = EditorTextView.makeEditor().textView
            view.textStorage?.setAttributedString(text)

            let wasAdopted = EditorTypography.isAdopted
            defer { EditorTypography.isAdopted = wasAdopted }
            EditorTypography.adopt(EditorTypography.resolve(voice: .study, inlineComments: false))
            view.applyVoiceChrome(EditorSurfaceChrome(
                voice: .study, dark: false, inlineComments: false))
            let storage = view.textStorage
            #expect(storage != nil)
            #expect(storage?.string == "a **bold** word", "still byte-identical")
            #expect(EditorDocument.baseFont.familyName == "Iowan Old Style")
            let boldAt = 4
            #expect(font(storage ?? text, at: boldAt)?.familyName == "Iowan Old Style")
            #expect(isBold(storage ?? text, at: boldAt), "re-derived, not lost to the base refresh")
            #expect(color(storage ?? text, at: 2)
                == NSColor(VoiceTokens.studyLight.muted), "the new voice's dimmed marker")
        }
    }

    /// **18j (the 18g ladder's R2-1, a pre-existing MAJOR from Phase 13g L7)
    /// — RED ON OLD.** A faced run's `.foregroundColor` was restored to the
    /// ink CAPTURED WHEN THE FACE WAS WRITTEN, so after any ink MOVE — a
    /// live dark/light toggle, a voice switch — bold, italic, heading and
    /// code came back in the OLD ink while only the link (which re-derives
    /// from the palette) was right. The second toggle left bold reading
    /// `D6DAD2` on `FBFBF7` paper: near-invisible emphasis.
    ///
    /// The sequence below IS the surface's: `textColor`'s setter writes the
    /// new ink over the ENTIRE storage, then `style` re-derives — and the
    /// clear loop's restore put the stale colour back over the ink that had
    /// just landed. `theFaceFollowsAVoiceSwitch` above never caught it
    /// because it reads the MARKER's colour, which comes from the palette.
    @Test func aFacedRunFollowsTheInkWhenTheAppearanceMoves() {
        withVoice {
            let light = NSColor(VoiceTokens.terminalLight.ink)
            let dark = NSColor(VoiceTokens.terminalDark.ink)
            let storage = NSMutableAttributedString(string: "a **bold** word")
            let whole = NSRange(location: 0, length: storage.length)
            storage.addAttribute(.foregroundColor, value: light, range: whole)
            MarkdownFace.style(
                storage, base: .systemFont(ofSize: 14),
                palette: MarkdownStyling.palette.face)
            let boldAt = 4
            #expect(color(storage, at: boldAt) == light, "the face starts in the surface's ink")

            // The appearance moves. The host's chrome does BOTH halves in
            // one gesture (`applyVoiceChrome`): `NSTextView.textColor` writes
            // the new ink over every character, and the markdown palette
            // moves to the same tokens — then the surface re-derives.
            storage.addAttribute(.foregroundColor, value: dark, range: whole)
            MarkdownFace.style(
                storage, base: .systemFont(ofSize: 14),
                palette: MarkdownStyling.Palette(tokens: .terminalDark).face)
            // 18j ladder round 1 (R1-1): compared BY RESOLUTION under the
            // dark appearance, not by `==` against the static colour — the
            // palette's prose is the voice's one DYNAMIC ink now, so the
            // cleared run holds that object; what the pin states is
            // unchanged (bold READS in the current ink), and it stays red
            // on the pre-R2-1 code, where the captured light ink came back.
            #expect(ResolvedInk.reads(color(storage, at: boldAt),
                                      as: VoiceTokens.terminalDark.ink, dark: true),
                    "bold reads in the CURRENT ink, not the one captured when the face was written")
            #expect(isBold(storage, at: boldAt), "and it is still bold")
            #expect(color(storage, at: 1) == dark, "the prose beside it too")
        }
    }

    /// **18j ladder round 1, R1-1 — RED ON OLD.** The editor's prose ink is
    /// ONE dynamic object per voice (`EditorDocument.baseAttributes`), but
    /// the Mac's face palette declared `prose` as a colour FROZEN for one
    /// appearance (`NSColor(tokens.ink)`), so every run the clear loop wrote
    /// changed KIND. A run that stays faced is re-cleared on every
    /// appearance change and hid it; a run whose face is REMOVED — a marker
    /// deleted here, or ⌘B/⌘I toggled off (the same `restyle`) — is cleared
    /// ONCE and never revisited, and read in the OLD ink after the next
    /// light/dark change. Reproduced on the Debug build (the de-faced
    /// `` `cod `` at the dark prose on the light paper). The book's inline
    /// editor shares the road; the panes wrote `textColor` on a flip and
    /// were immune until they took the same dynamic ink at this fix.
    ///
    /// On the pre-fix code the cleared run held the static DARK prose (the
    /// palette below is the dark one) and read `D6DAD2` under `.aqua`.
    @Test func aRunThatLosesItsFaceReturnsToTheVoicesDynamicInk() throws {
        try withVoice(.terminal) {
            MarkdownStyling.palette = MarkdownStyling.Palette(tokens: .terminalDark)
            let storage = NSMutableAttributedString(
                string: "a `code` word", attributes: EditorDocument.baseAttributes)
            #expect(MarkdownStyling.style(storage) == true)
            let codeAt = 3
            #expect(color(storage, at: codeAt) === EditorTypography.ink(for: .terminal),
                    "the chip's content keeps the base ink (the face colours only markers and links)")

            // The closing backtick goes — the keystroke road: bytes, then
            // the line's restyle.
            storage.replaceCharacters(in: NSRange(location: 7, length: 1), with: "")
            MarkdownStyling.restyle(storage, range: NSRange(location: 7, length: 0))
            #expect(storage.string == "a `code word", "the opening backtick stays; the span is broken")
            #expect(font(storage, at: codeAt)?.fontName == EditorDocument.baseFont.fontName,
                    "the chip's face is gone")
            let ink = try #require(color(storage, at: codeAt))
            #expect(ink === EditorTypography.ink(for: .terminal),
                    "the de-faced run returns to the voice's ONE dynamic ink, not a frozen copy")
            #expect(ResolvedInk.reads(ink, as: VoiceTokens.terminalLight.ink, dark: false),
                    "…so under the light appearance it reads in the light ink")
            #expect(ResolvedInk.reads(ink, as: VoiceTokens.terminalDark.ink, dark: true),
                    "…and under the dark appearance in the dark ink — no storage write needed")
        }
    }

    /// The other half of the same rule: a run that had NO foreground colour
    /// when the face was written must still end with none, so a surface
    /// that draws with the view's own `textColor` is not quietly given an
    /// explicit one. (This is what `NSNull` records, and it is why the fix
    /// keeps the presence/absence distinction rather than always writing.)
    @Test func aFaceOverColourlessProseLeavesItColourless() {
        withVoice {
            let storage = NSMutableAttributedString(string: "a **bold** word")
            MarkdownFace.style(
                storage, base: .systemFont(ofSize: 14),
                palette: MarkdownStyling.palette.face)
            // Delete the emphasis: the face clears and the content returns
            // to prose — with no colour of its own.
            storage.replaceCharacters(in: NSRange(location: 2, length: 2), with: "")
            storage.replaceCharacters(in: NSRange(location: 6, length: 2), with: "")
            MarkdownFace.restyle(
                storage, range: NSRange(location: 0, length: storage.length),
                base: .systemFont(ofSize: 14), palette: MarkdownStyling.palette.face)
            #expect(storage.string == "a bold word")
            #expect(color(storage, at: 3) == nil,
                    "nothing was given an explicit colour it never had")
        }
    }

    // MARK: - 3. P1 — the rescan is ∝ the edited paragraph(s)

    /// DISCRIMINATING REVERT: in `MarkdownStyling.restyle`, replace the
    /// `string.lineRange(for:)` expansion with the whole storage
    /// (`NSRange(location: 0, length: length)`). Verified RED — 15,600 units
    /// scanned per keystroke instead of 79.
    @Test func aKeystrokeRescansItsOWNLinesAndNotTheNote() async throws {
        // 400 paragraphs inside ONE block (I4: newlines are content), so the
        // surface is a genuinely long document and the edit is deep inside it.
        let line = "lorem ipsum dolor sit amet consectetur"
        let long = Array(repeating: line, count: 400).joined(separator: "\n")
        try await withEditor(seedBlocks: [long]) { h in
            let documentLength = (h.documentText as NSString).length
            #expect(documentLength > 10_000)

            let target = (line.utf16.count + 1) * 200 + 5   // inside paragraph 201
            MarkdownScanCount.reset()
            h.type("*", at: target)
            let scanned = MarkdownScanCount.current

            // The pin: one keystroke walks its own line (plus at most the
            // next, which the range widening pulls in) — never the note.
            #expect(scanned > 0, "the face really ran")
            // Exactly the edited line and the one after it (the range widening
            // pulls the follower in, so a Return inside `**bold**` restyles
            // both halves) — plus the single character just typed.
            #expect(scanned <= 2 * (line.utf16.count + 1) + 1,
                    "P1: cost ∝ the edited paragraph(s), not the document")
            #expect(scanned < documentLength / 50)
        }
    }

    @Test func theFaceRidesTheRealKeystrokePipelineAndKeepsBlockIdentity() async throws {
        try await withEditor(seedBlocks: ["one", "two"]) { h in
            h.type("**loud**", at: 3)           // end of block a
            await h.flush()
            let storage = try #require(h.textView.textStorage)
            #expect(h.documentText == "one**loud**\ntwo")
            #expect(isBold(storage, at: 5))
            // Identity survives the face: every character of block a still
            // carries a's ID, and the store agrees with the view.
            #expect(EditorDocument.blockID(at: 5, in: storage) == h.model.index.entries[0].blockID)
            try expectStoreMatchesView(h)
        }
    }

    /// DISCRIMINATING REVERT: in `MarkdownSyntax.spans(in:)`, drop
    /// `|| chars[index].isNewline` from the line walk. Verified RED — the
    /// opener in block one closes in block two and the face crosses the seam.
    @Test func aSpanCanNeverCrossABlockSEAM() async throws {
        // The editor joins blocks with a single "\n", and the tokenizer is
        // line-scoped — so an opener in one block and a closer in the next
        // can never style across the boundary. Markdown and block identity
        // cannot disagree.
        try await withEditor(seedBlocks: ["start **here", "and end** later"]) { h in
            let storage = try #require(h.textView.textStorage)
            #expect(h.documentText == "start **here\nand end** later")
            for offset in 0..<storage.length {
                #expect(storage.attribute(
                    MarkdownStyling.faceAttribute, at: offset, effectiveRange: nil) == nil,
                    "no face at \(offset) — nothing matched across the seam")
            }
        }
    }

    @Test func theFaceSurvivesAStructuralSeamEdit() async throws {
        // A divide rewrites the surface through `applySeamEdit`, which resets
        // the replaced span to base attributes — the face must be re-derived
        // there or a split note loses its formatting until the next full
        // render.
        try await withEditor(seedBlocks: ["first part. **second** part."]) { h in
            let cut = (h.documentText as NSString).range(of: "**second**").location
            _ = try h.session.operations.divide(
                h.model.index.entries[0].blockID, cut: cut)
            try h.reload()
            await h.flush()
            let storage = try #require(h.textView.textStorage)
            let boldAt = (h.documentText as NSString).range(of: "second").location
            #expect(isBold(storage, at: boldAt))
            try expectStoreMatchesView(h)
        }
    }
}
