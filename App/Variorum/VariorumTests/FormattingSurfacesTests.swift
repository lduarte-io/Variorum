//
//  FormattingSurfacesTests.swift
//  VariorumTests
//
//  Phase 13k, batch 2 — the three ruled formatting-surface rows:
//
//    * **K7** the formatting TOOLBAR in the bottom bar (her ruling: *"i think
//      the formatting toolbar should be added to the bottom"*) — the claim
//      being that it is a DOOR onto the existing acts and not a second brain;
//    * **K9** the callout FRAME in Take mode (her instruction: *"callouts are
//      supposed to be added to take mode as well"*; sitting Q4 ruled ONE
//      frame around the block's whole takes region);
//    * **K10** the inline-code CHIP (sitting Q2 ruled a faint per-voice tint
//      hugging exactly the span, never block-wide) — on the dimmed-marker
//      editing face AND on both of Read's rendered faces.
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
@Suite("Formatting surfaces — toolbar, take frames, code chip (13k batch 2)")
struct FormattingSurfacesTests {

    private static let allFormatting: [CapabilityID] = [
        .formatBold, .formatItalic, .formatStrikethrough, .formatCode, .formatAddLink,
        .formatHeading, .formatBulletList, .formatChecklist,
    ]

    private static func window() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
        window.makeKeyAndOrderFront(nil)
        return window
    }

    // MARK: - K7: the toolbar is a door onto the acts, not a copy of them

    /// The toolbar renders EVERY declared formatting act, in the declared
    /// order, from the one table the two menus already render — so a ninth
    /// act cannot appear in a menu and be missing from the bar.
    ///
    /// DISCRIMINATING REVERT: return a hand-written subset from
    /// `FormatBar.renderedCapabilities` (say the first four) and this fails
    /// on the list comparison — and the registry walk
    /// (`theBottomBarsRenderExactlyTheDeclaredBarDoors`) fails with it,
    /// because four of the eight declared bar doors would go unrendered.
    @Test func theToolbarRendersEveryDeclaredFormattingActInOrder() {
        #expect(FormatBar.renderedCapabilities == Self.allFormatting)
        for id in Self.allFormatting {
            #expect(CapabilityRegistry.capability(id).doors.contains(.bottomBar),
                    "\(id) declares the bar door it is rendered in (P-1)")
        }
        // BOTH bars carry it — the acts are `takesAccess: .native`, so a
        // toolbar in Write's bar alone would privilege Write exactly where
        // R118 says it must not (13k K7's stated reason for the second wire).
        for id in Self.allFormatting {
            #expect(CommitBar.renderedCapabilities.contains(id))
            #expect(TakesBottomBar.renderedCapabilities.contains(id))
        }
    }

    /// **The one-brain claim, as behaviour.** A toolbar button fires
    /// `MarkdownActs.fire` — the same call `ShellActions.applyFormat` makes
    /// for the menu bar — so it acts on whichever of our surfaces holds the
    /// keyboard, and where there is none it SPEAKS instead of being a dead
    /// button (P-2).
    ///
    /// DISCRIMINATING REVERT: drop the `guard let textView … else { speak }`
    /// from `MarkdownActs.fire` and the stranger half fails — the door goes
    /// silent, which is the exact failure the fire-and-DO rule exists to
    /// forbid.
    @Test func theToolbarsButtonFiresTheMenusOwnDoorAndSpeaksWhenItCannot() {
        let window = Self.window()
        defer { window.close() }
        let status = StatusCenter()

        let pane = PaneTextView.makeTakeSurface()
        pane.frame = NSRect(x: 0, y: 0, width: 300, height: 40)
        window.contentView?.addSubview(pane)
        pane.string = "say this now"
        pane.isEditable = true
        window.makeFirstResponder(pane)
        pane.setSelectedRange((pane.string as NSString).range(of: "this"))

        MarkdownActs.fire(.bold, status: status, in: window)
        #expect(pane.string == "say **this** now",
                "the bar's button and the menu's row are the same act")
        #expect(status.spoken == nil, "an act that acted says nothing")

        // A field editor is an editable NSTextView too, and must never take
        // `****` from a toolbar button any more than from a menu key.
        let stranger = NSTextView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
        stranger.isEditable = true
        stranger.string = "a rename field"
        window.contentView?.addSubview(stranger)
        window.makeFirstResponder(stranger)
        MarkdownActs.fire(.bold, status: status, in: window)
        #expect(stranger.string == "a rename field", "untouched")
        #expect(status.current?.text == MarkdownActs.noTargetNote,
                "the door speaks its declared note rather than doing nothing")
    }

    // MARK: - K9: one frame around the block's whole takes region

    /// DISCRIMINATING REVERT: drop the `presentation.kind == calloutKind`
    /// check from `TakesViewModel.calloutFrame` and the foreign-kind
    /// expectation fails — a future presentation kind would be drawn as a
    /// callout, which is the fail-open rule the editor's overlay keeps.
    @Test func aFramedBlocksTakesRegionWearsItsFrameAndAPlainBlocksDoesNot() async throws {
        try await withTakesModel { session, model, post, framedID, plainID in
            try session.operations.setBlockPresentation(
                framedID, BlockPresentation(color: "violet", emoji: "★"))
            model.adopt(try session.database.read {
                try Queries.takesProjection($0, post: post)
            })

            let frame = try #require(model.calloutFrame(framedID))
            #expect(frame.color == "violet")
            #expect(frame.emoji == "★")
            #expect(model.calloutFrame(plainID) == nil,
                    "a plain block's region is drawn exactly as it was")

            // A presentation of some OTHER kind draws nothing here — the same
            // fail-open posture `BlockDecorOverlayController` takes in Write.
            try session.operations.setBlockPresentation(
                framedID, BlockPresentation(kind: "someFutureKind", color: "violet"))
            model.adopt(try session.database.read {
                try Queries.takesProjection($0, post: post)
            })
            #expect(model.calloutFrame(framedID) == nil)
        }
    }

    /// The frame is the BLOCK's and its takes SHARE it (R16/R27) — which is
    /// exactly why it is asked per BLOCK and never per take. Branching a
    /// second take must not change the answer, and the door that sets it
    /// from a take card must reach the same frame.
    @Test func everyTakeOfAFramedBlockIsInsideTheSameOneFrame() async throws {
        try await withTakesModel { session, model, post, framedID, _ in
            let before: Queries.TakesProjection = try await session.database.read {
                try Queries.takesProjection($0, post: post)
            }
            let chosen = try #require(before.slots.first { $0.blockID == framedID }?.variantID)
            _ = try session.operations.branchVariant(framedID, from: chosen)

            await model.applyCallout(.color("green"), blockID: framedID)
            let after: Queries.TakesProjection = try await session.database.read {
                try Queries.takesProjection($0, post: post)
            }
            model.adopt(after)
            let projection = model.projection
            #expect(projection.fans[framedID]?.count == 2, "a real fan")
            #expect(model.calloutFrame(framedID)?.color == "green",
                    "ONE frame — asked of the block, whatever its takes do")
        }
    }

    // MARK: - K10: the code chip

    /// The chip hugs exactly the SPAN — backticks included, because they are
    /// part of the thing she typed and a chip stopping short of them would
    /// leave two dimmed ticks outside their own tint. And it is never
    /// block-wide: the prose on either side carries no background at all,
    /// which is what keeps it visibly distinct from a callout frame.
    ///
    /// DISCRIMINATING REVERT: drop the `.backgroundColor` write from
    /// `MarkdownStyling.apply`'s `.code` branch and every chip expectation
    /// fails while the font/marker ones stay green.
    @Test func aCodeSpanCarriesTheChipAndTheProseAroundItCarriesNone() {
        withVoicePalette(.terminal) {
            let source = "say `let x = 1` now"
            let storage = NSMutableAttributedString(string: source)
            #expect(MarkdownStyling.style(storage))
            #expect(storage.string == source, "attributes only — display == stored")

            let ns = source as NSString
            let open = ns.range(of: "`").location
            let close = ns.range(of: "`", options: .backwards).location
            let inside = ns.range(of: "let x").location
            for offset in [open, inside, close] {
                #expect(background(storage, at: offset) == MarkdownStyling.palette.codeTint,
                        "the chip covers the whole span, markers included (offset \(offset))")
            }
            #expect(background(storage, at: 0) == nil, "prose before it is untinted")
            #expect(background(storage, at: ns.length - 1) == nil, "and after it")
        }
    }

    /// DISCRIMINATING REVERT: drop `removeAttribute(.backgroundColor, …)`
    /// from `restyle`'s clear loop and this fails — deleting a backtick
    /// leaves a tinted ghost over text that is no longer code.
    @Test func removingTheBackticksClearsTheChip() {
        withVoicePalette(.terminal) {
            let storage = NSMutableAttributedString(string: "say `code` now")
            #expect(MarkdownStyling.style(storage))
            #expect(background(storage, at: 5) != nil)

            // The edit a keystroke makes, then the keystroke's own restyle.
            let closing = ("say `code` now" as NSString).range(of: "`", options: .backwards)
            storage.replaceCharacters(in: closing, with: "")
            #expect(MarkdownStyling.restyle(
                storage, range: NSRange(location: closing.location, length: 0)))
            #expect(storage.string == "say `code now")
            for offset in 0..<storage.length {
                #expect(background(storage, at: offset) == nil,
                        "no code span, no chip anywhere (offset \(offset))")
            }
        }
    }

    /// Read hides the markers (F-5), so on a reading surface the RUN is the
    /// span — which is why the paged reader tints the run and the editing
    /// face tints the span.
    ///
    /// DISCRIMINATING REVERT: drop the paginator's `.backgroundColor` write
    /// and the composed page's chip expectation fails while its monospaced
    /// font expectation stays green.
    @Test func readsPagedFaceTintsTheCodeRunAndNothingElse() {
        let tint = NSColor(ReadingPageTokens.light.codeTint)
        let composed = PageComposer.compose(
            slots: [slot("b", text: "say `code` now")],
            presentations: [:], title: nil, chapter: nil,
            typography: .standard, ink: .black, chapterInk: .gray, codeTint: tint)
        let text = composed.attributed
        let ns = text.string as NSString
        #expect(!ns.contains("`"), "Read hides the markers")
        let code = ns.range(of: "code")
        #expect(text.attribute(.backgroundColor, at: code.location, effectiveRange: nil)
                as? NSColor == tint)
        #expect(text.attribute(.backgroundColor, at: 0, effectiveRange: nil) == nil,
                "the words around it are the page's plain paper")
    }

    @Test func readsFlowFaceTintsTheCodeRunToo() throws {
        let tint = ReadingPageTokens.light.codeTint
        let paragraph = try #require(
            FlowParagraph.paragraphs(of: "say `code` now", codeTint: tint).first)
        let runs = paragraph.text.runs.filter { $0.backgroundColor != nil }
        #expect(runs.count == 1)
        #expect(runs.first?.backgroundColor == tint)
        #expect(String(paragraph.text.characters) == "say code now")
    }

    /// The swatches exist for every voice AND for the reading page, and each
    /// is genuinely a tint on its own surface rather than the surface itself
    /// (a "faint" chip that equals the paper is an invisible chip — the
    /// batch-2 look finding this row exists to fix, where the terminal
    /// voice's monospaced prose left code indistinguishable).
    @Test func everyVoiceAndTheReadingPageDeclareACodeTint() {
        for voice in [ThemeVoice.terminal, .study] {
            for dark in [false, true] {
                let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
                #expect(tokens.codeTint != tokens.surface,
                        "\(voice)/\(dark ? "dark" : "light"): a chip you can see")
                #expect(tokens.codeTint != tokens.room)
            }
        }
        #expect(ReadingPageTokens.light.codeTint != ReadingPageTokens.light.paper)
        #expect(ReadingPageTokens.dark.codeTint != ReadingPageTokens.dark.paper)
    }

    // MARK: - Helpers

    private func background(_ text: NSAttributedString, at offset: Int) -> NSColor? {
        text.attribute(.backgroundColor, at: offset, effectiveRange: nil) as? NSColor
    }

    private func slot(_ id: String, text: String) -> Queries.RenderedBlock {
        Queries.RenderedBlock(
            blockID: id, placementID: "p-\(id)", position: "a", variantID: "v-\(id)",
            text: text, activeVariantCount: 1, liveVariantCount: 1, commentCount: 0,
            variantLocked: false)
    }

    private func withVoicePalette<T>(_ voice: ThemeVoice, _ body: () throws -> T) rethrows -> T {
        let saved = MarkdownStyling.palette
        defer { MarkdownStyling.palette = saved }
        MarkdownStyling.palette = MarkdownStyling.Palette(
            tokens: VoiceTokens.resolve(voice: voice, dark: false))
        return try body()
    }

    /// A takes model over a two-block post: one block to frame, one to leave
    /// plain.
    private func withTakesModel<T>(
        _ body: @MainActor (
            _ session: AppSession, _ model: TakesViewModel,
            _ postID: String, _ framedBlockID: String, _ plainBlockID: String
        ) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "frames")
            let framed = try session.operations.newBlock(in: post.id, text: "A warning.")
            let plain = try session.operations.newBlock(in: post.id, text: "Ordinary.")
            let model = TakesViewModel(session: session, postID: post.id)
            defer { model.teardown() }
            return try await body(session, model, post.id, framed.block.id, plain.block.id)
        }
    }
}
