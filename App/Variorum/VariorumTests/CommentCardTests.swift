//
//  CommentCardTests.swift
//  VariorumTests
//
//  VX-179 U2 — **THE GUTTER COMMENT CARD, STACKED** (her rulings R-VX179-1/2
//  at the VX-179 kickoff, 2026-10-12: each comment its own entry, stamp-
//  ordered, thin separators, scroll INSIDE the card when they overflow; the
//  card may grow to the block's own height). Her words behind them:
//  *"sometimes a block is several paragraphs but the comment is always just
//  one line. it would be helpful if they were easier to read while on the
//  side / had a scroll inside the comments. it could be handled well when
//  there are multiple comments too."*
//
//  What is pinned here: the three PURE decisions (`CommentCardLayout` — the
//  stack's arrangement, the wheel's owner, the pool's identity reconcile) by
//  table; the mounted card's contract (stacked entries in order, labels
//  pooled and reused, no entry work on an unchanged pass, no re-measure on a
//  height-only change, one door when interactive, click-through on the read
//  tier, the strip and badge arms untouched, the hanging voice mark); and
//  the controller's road (the briefs' order reaches the card, the tooltip is
//  the shipped joined string, a card stays with its block as the page
//  scrolls). The geometry half (R-VX179-2) is `ProseGutterTests.
//  theCardGrowsToTheBlocksOwnHeightWithinTheRhythm`.
//
//  These are FEATURE pins — the stacked card is new behaviour, so every cell
//  here fails to compile on the pre-U2 tree rather than failing an
//  expectation. (Written at U2; compile + RUN PENDING the stage.)
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure decisions (tables)

@Suite("The stacked comment card's pure decisions (VX-179 U2)")
struct CommentCardLayoutTests {
    /// **THE STACK** — each entry its own frame, top-down in the order given;
    /// one hairline BETWEEN entries with the air on both sides; the document
    /// never smaller than its viewport; overflow only past the slack.
    @Test func theStackArrangesEntriesTopDownWithSeparatorsBetween() {
        let air = CommentCardLayout.entryAir
        let line = CommentCardLayout.separatorThickness
        #expect(air == 4 && line == 1, "the numbers the cells below are written in")

        // One entry: no separator, nothing to scroll.
        let one = CommentCardLayout.arrange(entryHeights: [14], width: 120, viewportHeight: 39)
        #expect(one.entryFrames == [CGRect(x: 0, y: 0, width: 120, height: 14)])
        #expect(one.separatorFrames.isEmpty)
        #expect(one.contentHeight == 14 && one.documentHeight == 39 && !one.overflows)

        // Three entries: 0 · [4 + 1 + 4] · 23 · [4 + 1 + 4] · 60 → 74.
        let three = CommentCardLayout.arrange(
            entryHeights: [14, 28, 14], width: 100, viewportHeight: 39)
        #expect(three.entryFrames == [
            CGRect(x: 0, y: 0, width: 100, height: 14),
            CGRect(x: 0, y: 23, width: 100, height: 28),
            CGRect(x: 0, y: 60, width: 100, height: 14),
        ])
        #expect(three.separatorFrames == [
            CGRect(x: 0, y: 18, width: 100, height: 1),
            CGRect(x: 0, y: 55, width: 100, height: 1),
        ])
        #expect(three.contentHeight == 74 && three.documentHeight == 74 && three.overflows)
        // Every separator sits strictly between its two entries.
        for (index, separator) in three.separatorFrames.enumerated() {
            #expect(separator.minY >= three.entryFrames[index].maxY + air)
            #expect(separator.maxY + air <= three.entryFrames[index + 1].minY)
        }

        // The slack: 37 pt of content in a 36.6 pt viewport is not an
        // overflow; in a 36.4 pt one it is.
        #expect(!CommentCardLayout.arrange(
            entryHeights: [14, 14], width: 80, viewportHeight: 36.6).overflows)
        #expect(CommentCardLayout.arrange(
            entryHeights: [14, 14], width: 80, viewportHeight: 36.4).overflows)

        // Degenerate inputs stay sane.
        let empty = CommentCardLayout.arrange(entryHeights: [], width: 80, viewportHeight: 30)
        #expect(empty.entryFrames.isEmpty && empty.separatorFrames.isEmpty)
        #expect(empty.contentHeight == 0 && empty.documentHeight == 30 && !empty.overflows)
        #expect(CommentCardLayout.arrange(
            entryHeights: [-5], width: 80, viewportHeight: 30).entryFrames[0].height == 0)
    }

    /// **THE WHEEL'S OWNER** — a card with nothing to scroll NEVER takes the
    /// page's wheel; an overflowing card takes only what it can move with.
    /// (`deltaY` > 0 reveals what is above — AppKit's content-terms delta.)
    @Test func theWheelGoesToTheCardOnlyWhenTheCardCanMoveThatWay() {
        typealias Owner = CommentCardLayout.WheelOwner
        func owner(
            content: CGFloat = 100, viewport: CGFloat = 40, offset: CGFloat,
            dx: CGFloat = 0, dy: CGFloat
        ) -> Owner {
            CommentCardLayout.wheelOwner(
                contentHeight: content, viewportHeight: viewport, offset: offset,
                deltaX: dx, deltaY: dy)
        }
        // Content that FITS: the page owns every event, whatever its shape.
        for dy in [5.0, -5, 0] as [CGFloat] {
            #expect(owner(content: 39, viewport: 39, offset: 0, dy: dy) == .page)
            #expect(owner(content: 30, viewport: 39, offset: 0, dy: dy) == .page)
        }
        // Overflowing, at rest at its TOP (offset 0; the most common state):
        #expect(owner(offset: 0, dy: 5) == .page, "pushing past the top → the page")
        #expect(owner(offset: 0, dy: -5) == .card, "more below → the card")
        #expect(owner(offset: 0, dy: 0) == .card, "a touch that has not moved yet")
        // Mid-way (max offset 60): both directions are the card's.
        #expect(owner(offset: 30, dy: 5) == .card)
        #expect(owner(offset: 30, dy: -5) == .card)
        // At its BOTTOM: pushing past it is the page's again.
        #expect(owner(offset: 60, dy: -5) == .page)
        #expect(owner(offset: 60, dy: 5) == .card)
        // The slack at both ends.
        #expect(owner(offset: 0.3, dy: 5) == .page)
        #expect(owner(offset: 59.7, dy: -5) == .page)
        // Mostly horizontal: the card has no horizontal room.
        #expect(owner(offset: 30, dx: 10, dy: 2) == .page)
        #expect(owner(offset: 30, dx: 3, dy: 0) == .page)
        #expect(owner(offset: 30, dx: 2, dy: -10) == .card)
    }

    /// **CARDS STAY WITH THEIR BLOCKS** — the pool pairs by identity, so the
    /// card holding a block's inner scroll keeps showing that block while
    /// the visible set moves under a page scroll.
    @Test func thePoolKeepsEachBlockOnTheCardAlreadyShowingIt() {
        typealias R = CommentCardLayout.Reconciled
        func plan(_ current: [String?], _ wanted: [String]) -> R {
            CommentCardLayout.reconcile(current: current, wanted: wanted)
        }
        #expect(plan([], ["a", "b"]) == R(reuse: [nil, nil], discard: []), "first render mints")
        #expect(plan(["a", "b"], ["a", "b"]) == R(reuse: [0, 1], discard: []), "a steady pass")
        // The page scrolls one block: b KEEPS card 1 (by position it would
        // have moved to card 0, mid-scroll); c takes the free card.
        #expect(plan(["a", "b"], ["b", "c"]) == R(reuse: [1, 0], discard: []))
        // The visible set shrinks: the SURVIVOR keeps its card; the other goes.
        #expect(plan(["a", "b"], ["b"]) == R(reuse: [1], discard: [0]))
        // It grows: the known block keeps its card; new ones are made.
        #expect(plan(["a"], ["a", "b", "c"]) == R(reuse: [0, nil, nil], discard: []))
        // Cards that never showed anything are simply free.
        #expect(plan([nil, nil], ["x"]) == R(reuse: [0], discard: [1]))
        // A duplicated identity is never handed out twice.
        #expect(plan(["a"], ["a", "a"]) == R(reuse: [0, nil], discard: []))
        #expect(plan(["a", "a"], ["a"]) == R(reuse: [0], discard: [1]))
    }
}

// MARK: - The mounted card

@MainActor
@Suite("The stacked comment card, mounted (VX-179 U2)", .serialized)
struct CommentCardViewTests {
    private static let ink = NSColor(srgbRed: 0.48, green: 0.44, blue: 0.27, alpha: 1)
    private static let rule = NSColor(srgbRed: 0.96, green: 0.95, blue: 0.89, alpha: 1)
    private static let hairline = NSColor(srgbRed: 0.89, green: 0.89, blue: 0.86, alpha: 1)

    private func content(_ entries: [String], prefix: String = "// ") -> CommentCardView.CardContent {
        CommentCardView.CardContent(
            entries: entries, prefix: prefix,
            // Fresh objects every call, as the render pass makes them.
            ink: NSColor(srgbRed: 0.48, green: 0.44, blue: 0.27, alpha: 1),
            rule: NSColor(srgbRed: 0.96, green: 0.95, blue: 0.89, alpha: 1),
            separator: NSColor(srgbRed: 0.89, green: 0.89, blue: 0.86, alpha: 1),
            fill: .clear,
            toolTip: prefix + entries.joined(separator: "  ·  "))
    }

    /// A card hosted in a (never shown) window, so layout and conversions are real.
    private func hosted(
        _ frame: NSRect = NSRect(x: 20, y: 20, width: 210, height: 41)
    ) -> (CommentCardView, NSWindow) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let host = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        window.contentView = host
        let card = CommentCardView(frame: frame)
        host.addSubview(card)
        return (card, window)
    }

    private func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.close()
    }

    /// The budget's comparison survives a colour handed back as a NEW
    /// object with the same components (the tokens are re-made per pass).
    @Test func cardColoursCompareByComponentsNotByObject() throws {
        let made = NSColor(srgbRed: 0.48, green: 0.44, blue: 0.27, alpha: 1)
        let remade = try #require(
            NSColor(cgColor: CGColor(srgbRed: 0.48, green: 0.44, blue: 0.27, alpha: 1)))
        #expect(CommentCardView.CardContent.sameColor(made, remade))
        #expect(!CommentCardView.CardContent.sameColor(
            made, NSColor(srgbRed: 0.48, green: 0.44, blue: 0.28, alpha: 1)))
        #expect(!CommentCardView.CardContent.sameColor(
            made, NSColor(srgbRed: 0.48, green: 0.44, blue: 0.27, alpha: 0.5)))
        // …and a whole content made twice, fresh, compares equal.
        #expect(content(["a", "b"]) == content(["a", "b"]))
        #expect(content(["a", "b"]) != content(["a", "c"]))
        #expect(content(["a"], prefix: "") != content(["a"]))
    }

    /// **R-VX179-1, the face itself**: each comment its own entry, in the
    /// order given, the voice's mark on each, a hairline between each pair,
    /// top-down in the (flipped) stack; the tooltip is the joined string.
    @Test func aCardStacksEachCommentAsItsOwnEntryInOrder() throws {
        let (card, window) = hosted()
        defer { close(window) }
        card.presentCard(content(["first", "second note", "third"]))
        card.layoutSubtreeIfNeeded()

        #expect(card.showsStackedEntries)
        #expect(card.shownEntryCount == 3)
        #expect(card.entryLabels.map(\.stringValue)
            == ["// first", "// second note", "// third"], "one entry per comment, in order")
        #expect(card.entrySeparatorCount == 2, "a hairline BETWEEN entries only")
        let ys = card.entryLabels.map(\.frame.minY)
        #expect(ys == ys.sorted() && Set(ys).count == 3, "top-down in the stack: \(ys)")
        #expect(card.entryLabels.allSatisfy { $0.frame.height > 0 }, "each measured")
        #expect(card.toolTip == "// first  ·  second note  ·  third",
                "the tooltip keeps the shipped joined string")
        // No entry is truncated: each label wraps fully (the old card cut
        // the joined string at four lines).
        #expect(card.entryLabels.allSatisfy {
            $0.maximumNumberOfLines == 0 && $0.lineBreakMode == .byWordWrapping
        })
    }

    /// **The overflow scrolls INSIDE the card** — five entries in a one-line
    /// block's 41 pt card make a document taller than the card's viewport;
    /// one short entry does not.
    @Test func entriesTallerThanTheCardScrollInsideIt() throws {
        let (card, window) = hosted()
        defer { close(window) }
        card.presentCard(content(["one", "two", "three", "four", "five"]))
        card.layoutSubtreeIfNeeded()
        let scroll = card.innerScrollView
        let document = try #require(scroll.documentView)
        #expect(document.isFlipped, "the first comment sits at the top")
        #expect(document.frame.height > scroll.contentSize.height + 0.5,
                "overflowing: \(document.frame.height) in \(scroll.contentSize.height)")

        card.presentCard(content(["one"]))
        card.layoutSubtreeIfNeeded()
        #expect(abs(document.frame.height - scroll.contentSize.height) < 0.5,
                "one short entry fits — nothing to scroll")
    }

    /// **THE BUDGET** — the decoration pass re-presents every visible card on
    /// every scroll, layout and caret move. An unchanged pass (colours made
    /// fresh, as the pass makes them) does NO entry work; a changed text
    /// does; a height-only change (her block grew a line) re-arranges
    /// without re-measuring; a width change re-measures.
    @Test func anUnchangedPassDoesNoEntryWorkAndAHeightChangeNoMeasuring() {
        let (card, window) = hosted()
        defer { close(window) }
        card.presentCard(content(["first", "second"]))
        card.layoutSubtreeIfNeeded()
        #expect(card.contentApplications == 1)
        let measured = card.measurements
        #expect(measured >= 1)

        for _ in 0..<5 { card.presentCard(content(["first", "second"])) }
        card.layoutSubtreeIfNeeded()
        #expect(card.contentApplications == 1, "an unchanged pass returns at the comparison")
        #expect(card.measurements == measured)

        card.frame.size.height = 140
        card.needsLayout = true
        card.layoutSubtreeIfNeeded()
        #expect(card.measurements == measured, "a taller card re-arranges, never re-measures")

        card.frame.size.width = 150
        card.needsLayout = true
        card.layoutSubtreeIfNeeded()
        #expect(card.measurements == measured + 1, "a new width re-measures once")

        card.presentCard(content(["first", "second, edited"]))
        card.layoutSubtreeIfNeeded()
        #expect(card.contentApplications == 2)
        #expect(card.measurements == measured + 2, "changed text re-measures")
    }

    /// **POOLED inside the card** — a changed text reuses the same labels;
    /// a grown list keeps the existing ones and adds; a shrunk one drops the
    /// surplus.
    @Test func changedEntriesReuseTheCardsLabels() {
        let (card, window) = hosted()
        defer { close(window) }
        card.presentCard(content(["a", "b"]))
        let first = card.entryLabels
        card.presentCard(content(["a, edited", "b"]))
        #expect(card.entryLabels.count == 2)
        #expect(zip(card.entryLabels, first).allSatisfy { $0 === $1 }, "the same labels, new words")
        #expect(card.entryLabels[0].stringValue == "// a, edited")
        card.presentCard(content(["a", "b", "c"]))
        #expect(card.entryLabels.count == 3 && card.entryLabels[0] === first[0]
            && card.entryLabels[1] === first[1])
        #expect(card.entrySeparatorCount == 2)
        card.presentCard(content(["a"]))
        #expect(card.entryLabels.count == 1 && card.entryLabels[0] === first[0])
        #expect(card.entrySeparatorCount == 0)
    }

    /// **ONE DOOR, and the read tier still clicks through.** An interactive
    /// card answers ITSELF over an entry (so `mouseDown` opens the panel
    /// wherever she clicks — the labels and the clip view never take it);
    /// with no door (the read tier) every point is click-through, as the
    /// round-3 MINOR pinned (`aQuietCommentCardIsClickThrough` rides
    /// unmodified for the single-string road).
    @Test func theInteractiveCardIsOneDoorAndTheReadTierClicksThrough() throws {
        let (card, window) = hosted()
        defer { close(window) }
        card.presentCard(content(["first", "second"]))
        card.layoutSubtreeIfNeeded()
        let superview = try #require(card.superview)
        let entry = try #require(card.entryLabels.first)
        let overEntry = superview.convert(
            NSPoint(x: entry.bounds.midX, y: entry.bounds.midY), from: entry)
        #expect(card.frame.contains(overEntry), "the probe is inside the card: \(overEntry)")

        #expect(card.hitTest(overEntry) == nil, "no door ⇒ click-through (the read tier)")
        var opened = 0
        card.onClick = { opened += 1 }
        let hit = card.hitTest(overEntry)
        #expect(hit === card, "the card itself, never the label: \(String(describing: hit))")
        card.mouseDown(with: try #require(NSEvent.mouseEvent(
            with: .leftMouseDown, location: .zero, modifierFlags: [], timestamp: 0,
            windowNumber: window.windowNumber, context: nil, eventNumber: 0,
            clickCount: 1, pressure: 1)))
        #expect(opened == 1, "the press opens the panel")
        // Outside the card: no hit at all.
        #expect(card.hitTest(NSPoint(x: card.frame.maxX + 20, y: card.frame.midY)) == nil)
    }

    /// **The strip and the badge keep their one shipped label** — and a card
    /// can move between the arms (a window narrowing past the card's width
    /// and back) without carrying either face's parts into the other.
    @Test func theStripAndTheBadgeKeepTheirOneLabel() {
        let (card, window) = hosted(NSRect(x: 20, y: 20, width: 32, height: 16))
        defer { close(window) }
        card.present(text: "#3", tint: Self.rule, ink: Self.ink, style: .badge)
        card.layoutSubtreeIfNeeded()
        #expect(!card.showsStackedEntries && card.shownEntryCount == 0)
        #expect(card.shownLineText == "#3" && card.toolTip == "#3")

        card.present(text: "// a  ·  b", tint: Self.rule, ink: Self.ink, style: .strip)
        #expect(!card.showsStackedEntries && card.shownLineText == "// a  ·  b")

        card.frame = NSRect(x: 20, y: 20, width: 210, height: 41)
        card.presentCard(content(["a", "b"]))
        card.layoutSubtreeIfNeeded()
        #expect(card.showsStackedEntries && card.shownEntryCount == 2)

        card.frame = NSRect(x: 20, y: 20, width: 32, height: 16)
        card.present(text: "#2", tint: Self.rule, ink: Self.ink, style: .badge)
        #expect(!card.showsStackedEntries && card.shownLineText == "#2")
        // The single-string MARGIN road (a caller with one text) is a
        // one-entry stack with no mark of its own.
        card.present(text: "note", tint: .clear, ink: Self.ink, style: .marginCard(rule: Self.rule))
        #expect(card.showsStackedEntries && card.entryLabels.map(\.stringValue) == ["note"])
    }

    /// **The voice's mark HANGS** (the panel row's idiom — PROVISIONAL, the
    /// walk decides the taste): wrapped lines align after "// ", a newline
    /// inside a comment hangs too (a LINE separator, display only), and with
    /// no mark (Study) the comment is its own text.
    @Test func theTerminalMarkHangsAndStudyHasNone() throws {
        let terminal = CommentCardView.entryString(prefix: "// ", text: "one\ntwo", ink: Self.ink)
        #expect(terminal.string == "// one\u{2028}two")
        let style = try #require(
            terminal.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)
        let markWidth = ceil(("// " as NSString).size(
            withAttributes: [.font: CommentCardView.entryFont]).width)
        #expect(style.headIndent == markWidth && style.firstLineHeadIndent == 0,
                "wrapped lines start after the mark: \(style.headIndent) vs \(markWidth)")
        let markInk = try #require(
            terminal.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor)
        #expect(abs(markInk.alphaComponent - 0.75) < 0.001, "the panel's 0.75 for the mark")

        let study = CommentCardView.entryString(prefix: "", text: "one\ntwo", ink: Self.ink)
        #expect(study.string == "one\ntwo", "no mark, the comment's own text")
        let plain = try #require(
            study.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)
        #expect(plain.headIndent == 0)
    }

    /// **A card that comes to show ANOTHER block starts at its top** — and a
    /// card that keeps its block keeps her inner scroll position.
    @Test func aNewBlockStartsAtTheTopAndTheSameBlockKeepsItsScroll() {
        let (card, window) = hosted()
        defer { close(window) }
        card.identity = "a"
        card.presentCard(content(["one", "two", "three", "four", "five", "six"]))
        card.layoutSubtreeIfNeeded()
        let clip = card.innerScrollView.contentView
        clip.scroll(to: NSPoint(x: 0, y: 20))
        #expect(clip.bounds.minY == 20, "the harness scrolled the card")

        card.identity = "a"
        #expect(clip.bounds.minY == 20, "the same block keeps its scroll")
        card.identity = "b"
        #expect(clip.bounds.minY == 0, "a different block starts at its top")
    }
}

// MARK: - The controller's road

@MainActor
@Suite("The stacked comment card through the decoration controller (VX-179 U2)", .serialized)
struct CommentCardControllerTests {
    private func surface() -> (NSTextView, NSWindow) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 1000, height: 600),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let textView = NSTextView(usingTextLayoutManager: true)
        textView.frame = NSRect(x: 0, y: 0, width: 1000, height: 600)
        window.contentView = textView
        return (textView, window)
    }

    private func state(
        _ blocks: [(id: String, y: CGFloat, comments: [String])], inline: Bool = false
    ) -> BlockDecor.State {
        var state = BlockDecor.State()
        state.textLeft = 300
        state.textRight = 980
        state.viewWidth = 1000
        state.appearance.inlineComments = inline
        state.frames = blocks.enumerated().map { index, block in
            BlockDecor.Frame(
                entryIndex: index, blockID: block.id,
                frame: CGRect(x: 300, y: block.y, width: 680, height: 34))
        }
        state.entryCount = blocks.count
        for block in blocks where !block.comments.isEmpty {
            state.comments[block.id] = block.comments.enumerated().map {
                BlockDecor.CommentBrief(id: "\(block.id)-c\($0.offset)", text: $0.element)
            }
        }
        return state
    }

    private func cards(_ textView: NSTextView) -> [CommentCardView] {
        textView.subviews.compactMap { $0 as? CommentCardView }
    }

    /// The briefs' order — the panel's `(created_at, id)`, which both
    /// suppliers deliver — reaches the card entry for entry, each wearing the
    /// voice's mark; the tooltip is the shipped joined string, byte for byte.
    @Test func aBlocksCommentsRenderAsStackedEntriesInTheBriefsOrder() throws {
        let (textView, window) = surface()
        defer { window.orderOut(nil); window.close() }
        let controller = BlockDecorOverlayController(
            textView: textView, onOpenComments: { _ in }, onMoveBlock: nil)
        defer { controller.uninstall() }
        let s = state([(id: "b", y: 40, comments: ["first", "second", "third"])])
        let prefix = s.appearance.tokens.commentPrefix
        controller.render(s)

        let card = try #require(cards(textView).first)
        #expect(cards(textView).count == 1)
        #expect(card.showsStackedEntries)
        #expect(card.entryLabels.map(\.stringValue)
            == ["first", "second", "third"].map { prefix + $0 })
        #expect(card.toolTip == prefix + "first  ·  second  ·  third")
        #expect(card.identity == "b")
        // The inline-strip setting (R7, R-13u3-5) stays the ONE line it was.
        controller.render(state([(id: "b", y: 40, comments: ["first", "second"])], inline: true))
        let strip = try #require(cards(textView).first)
        #expect(!strip.showsStackedEntries)
        #expect(strip.shownLineText == prefix + "first  ·  second")
    }

    /// **A card stays with its block as the page scrolls** — b's card is the
    /// same view (and so keeps her inner scroll) when a scrolls off and c
    /// arrives; the pool never grows past what is visible.
    @Test func aCardStaysWithItsBlockWhenThePageScrolls() throws {
        let (textView, window) = surface()
        defer { window.orderOut(nil); window.close() }
        let controller = BlockDecorOverlayController(
            textView: textView, onOpenComments: { _ in }, onMoveBlock: nil)
        defer { controller.uninstall() }
        controller.render(state([
            (id: "a", y: 0, comments: ["on a"]),
            (id: "b", y: 200, comments: ["on b", "more on b"]),
        ]))
        let bCard = try #require(cards(textView).first { $0.identity == "b" })

        controller.render(state([
            (id: "b", y: 10, comments: ["on b", "more on b"]),
            (id: "c", y: 210, comments: ["on c"]),
        ]))
        #expect(cards(textView).count == 2, "the pool holds what is visible")
        #expect(cards(textView).first { $0.identity == "b" } === bCard,
                "b keeps its card — never handed to a neighbour mid-scroll")
        #expect(cards(textView).contains { $0.identity == "c" })

        controller.render(state([(id: "b", y: 10, comments: ["on b", "more on b"])]))
        #expect(cards(textView).count == 1 && cards(textView).first === bCard,
                "the survivor keeps its card when the set shrinks")
    }

    /// The read tier's controller has no comments door: its stacked cards
    /// stay click-through (and therefore take no wheel — they show what
    /// fits, the recorded consequence).
    @Test func theReadTiersStackedCardsStayClickThrough() throws {
        let (textView, window) = surface()
        defer { window.orderOut(nil); window.close() }
        let controller = BlockDecorOverlayController(
            textView: textView, onOpenComments: nil, onMoveBlock: nil)
        defer { controller.uninstall() }
        controller.render(state([(id: "b", y: 40, comments: ["first", "second"])]))
        let card = try #require(cards(textView).first)
        #expect(card.showsStackedEntries)
        #expect(card.hitTest(NSPoint(x: card.frame.midX, y: card.frame.midY)) == nil)
    }
}
