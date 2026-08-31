//
//  ContextBarShapeTests.swift
//  VariorumTests
//
//  Phase 13k, batch 3 — K11 (the bar becomes the compact icon row, with a
//  real forward door and the book icon as the ascent's chooser) and K12
//  (the tag cards are visible by default; ＃ folds them, and the choice
//  sticks).
//
//  The bar's SHAPE claims are pinned on the pure decisions the view
//  iterates (`ContextBarDoors`), not on a rendered picture: her ruling is
//  that the row does not change with the state, and that is arithmetic.
//  The view's own greys are pinned through `ContextBar`'s computed
//  properties in `ContextBarTests` (BookAscentTests).
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@Suite("The context bar's icon row (13k K11)")
struct ContextBarDoorsTests {
    /// **THE CONSTANT ROW.** Three doors for a note, whatever the state
    /// is; two for a place, because the book door could never act there
    /// (P-2). *(Act 10 item 5 SUPERSEDED the four-door row: her ruling
    /// moved the ＃ and the cards to the masthead's right edge —
    /// `MastheadTagCluster` — so `.tags` left the row. The constancy claim
    /// itself is unchanged and still pinned here.)*
    @Test func theRowIsThreeDoorsForANoteAndTwoForAPlace() {
        #expect(ContextBarDoors.iconRow(isNote: true) == [.back, .book, .forward])
        #expect(ContextBarDoors.iconRow(isNote: false) == [.back, .forward])
    }

    /// Her ruling's three arities: *"click = the book when exactly one"*,
    /// *"command click … lets you see the list of books (or there's a
    /// dropdown if there's several)"*, and grey with none.
    ///
    /// DISCRIMINATING REVERT: drop the `bookCount > 1` disjunct so several
    /// books open the top pick — the fourth expectation fails.
    @Test func oneBookOpensSeveralListAndCommandAlwaysLists() {
        #expect(ContextBarDoors.bookClick(bookCount: 0, commandHeld: false) == .none)
        #expect(ContextBarDoors.bookClick(bookCount: 0, commandHeld: true) == .none,
                "⌘-click cannot list books that aren't there")
        #expect(ContextBarDoors.bookClick(bookCount: 1, commandHeld: false) == .open)
        #expect(ContextBarDoors.bookClick(bookCount: 3, commandHeld: false) == .list)
        #expect(ContextBarDoors.bookClick(bookCount: 1, commandHeld: true) == .list,
                "her second door: ⌘-click sees it listed even when there is one")
        #expect(ContextBarDoors.bookClick(bookCount: 3, commandHeld: true) == .list)
    }

    /// **R4-1 — the two navigation glyphs are a MIRRORED PAIR.** Her
    /// round-4 ruling: the forward chevron *"kind of looks like it's
    /// expanding the tags… it should just be replaced with an arrow like
    /// the back one"*. Sitting beside the ＃, a `›` is the universal
    /// unfold glyph, so it read as the tag door's twin instead of ←'s.
    ///
    /// DISCRIMINATING REVERT: put `"\u{203A}"` back as `forwardGlyph` —
    /// the second and third expectations fail (it is neither the mirror
    /// nor an arrow), and the retired-chevron expectation fails by name.
    @Test func theBackAndForwardGlyphsAreAMirroredPairOfArrows() {
        #expect(ContextBarDoors.backGlyph == "\u{2190}", "←, unchanged")
        #expect(ContextBarDoors.forwardGlyph == "\u{2192}", "→, her round-4 ruling")
        #expect(ContextBarDoors.forwardGlyph != "\u{203A}",
                "the chevron is retired — it read as the ＃'s expander")
        // The mirror, stated as the relation rather than as two literals:
        // both are arrows from the same Unicode block, two code points
        // apart (U+2191 ↑ sits between them — R2-3 corrected this comment
        // to match the assertion it annotates).
        let back = ContextBarDoors.backGlyph.unicodeScalars.first!.value
        let forward = ContextBarDoors.forwardGlyph.unicodeScalars.first!.value
        #expect(forward == back + 2, "← and → are the mirrored pair of one block")
    }

    /// **R2-1's drift guard (13k round 2):** the helper's ⌘[/⌘] row now
    /// INTERPOLATES the bar's own glyph constants, so the prose and the bar
    /// cannot disagree again. RED ON THE PRE-FIX COPY: the row read "the ←
    /// and › on the context bar" — the chevron R4-1 retired — so the second
    /// expectation failed and the third found the retired glyph by name.
    @MainActor
    @Test func theHelpersHistoryRowTeachesTheBarsOwnGlyphs() {
        let row = HelperView.groups.flatMap(\.items)
            .first { $0.keys.contains("\u{2318}[") }
        #expect(row != nil, "the ⌘[ / ⌘] row exists in the helper")
        #expect(row?.does.contains(ContextBarDoors.forwardGlyph) == true,
                "the row teaches the glyph the bar actually wears")
        #expect(row?.does.contains("\u{203A}") == false,
                "…and never the retired chevron")
    }

    /// The ＃ carries the count only when the cards are hidden — unfolded,
    /// a number would repeat what is right beside it. (The door lives on
    /// the masthead cluster since Act 10 item 5; the rule moved unchanged.)
    @Test func theTagsDoorCarriesTheCountOnlyWhenFolded() {
        #expect(ContextBarDoors.tagsDoorCount(folded: true, tagCount: 3) == 3)
        #expect(ContextBarDoors.tagsDoorCount(folded: true, tagCount: 0) == nil,
                "a folded door on an untagged note says ＃, not ＃0")
        #expect(ContextBarDoors.tagsDoorCount(folded: false, tagCount: 3) == nil)
    }

    /// The bar renders when the pane has anything to say — and a pane that
    /// has only gone BACK now qualifies, because the → is a door.
    @Test func theBarRendersWheneverThePaneHasAnythingToSay() {
        #expect(!ContextBarDoors.hasContent(
            isNote: false, canBack: false, canForward: false, bookCount: 0),
            "a cold launch at the shelf keeps the chrome it always had")
        #expect(ContextBarDoors.hasContent(
            isNote: true, canBack: false, canForward: false, bookCount: 0))
        #expect(ContextBarDoors.hasContent(
            isNote: false, canBack: true, canForward: false, bookCount: 0))
        #expect(ContextBarDoors.hasContent(
            isNote: false, canBack: false, canForward: true, bookCount: 0))
        #expect(ContextBarDoors.hasContent(
            isNote: false, canBack: false, canForward: false, bookCount: 1))
    }
}

@Suite("The tag cards' sticky fold (13k K12)")
struct TagChipsFoldTests {
    private func scratch(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: "variorum.tests.\(name)")!
        defaults.removePersistentDomain(forName: "variorum.tests.\(name)")
        return defaults
    }

    /// **K12's flip, and the whole of it**: with nothing stored, the cards
    /// SHOW. (13g #52(d) shipped them folded with the rest of the bar; her
    /// ruling: *"tag cards should fold into the bar if you deliberately
    /// choose that but it should default to visible"*.)
    ///
    /// DISCRIMINATING REVERT: make `folded(in:)` return `true` when the key
    /// is absent — the first expectation fails.
    @Test func theCardsShowUntilSheDeliberatelyFoldsThem() {
        let defaults = scratch("fold-default")
        #expect(!TagChipsFold.folded(in: defaults), "visible by default — her K12 ruling")
    }

    /// …and the choice STICKS: it is written where the app's other
    /// this-Mac settings live, so it survives a quit (the whole reason a
    /// deliberate choice is not session state).
    ///
    /// DISCRIMINATING REVERT: have `toggle(in:)` return the new value
    /// without writing it — the third expectation fails (a fresh read finds
    /// the old state).
    @Test func theFoldIsWrittenDownAndSurvivesTheLaunch() {
        let defaults = scratch("fold-sticky")
        #expect(TagChipsFold.toggle(in: defaults))
        #expect(TagChipsFold.folded(in: defaults))
        #expect(defaults.bool(forKey: TagChipsFold.settingKey),
                "stored under the app's own local-settings key, never in the schema")
        #expect(!TagChipsFold.toggle(in: defaults))
        #expect(!TagChipsFold.folded(in: defaults))
    }

    /// ⌘⇧I and the ＃ icon are ONE choice, because the router writes the
    /// same preference every bar reads.
    ///
    /// DISCRIMINATING REVERT: have `ShellRouter.toggleTagChips` flip a
    /// local property instead of `TagChipsFold` — the second expectation
    /// fails (standard defaults never move).
    @MainActor
    @Test func theKeyAndTheIconMoveTheSameOneChoice() {
        let defaults = UserDefaults.standard
        let before = TagChipsFold.folded()
        defer { defaults.set(before, forKey: TagChipsFold.settingKey) }

        let router = ShellRouter()
        router.toggleTagChips()
        #expect(TagChipsFold.folded() == !before)
        router.toggleTagChips()
        #expect(TagChipsFold.folded() == before)
    }
}

@MainActor
@Suite("The tag chip's own size (13k R4-2)")
struct TagChipFitTests {
    private func tag(_ path: String) -> VariorumCore.Tag {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return VariorumCore.Tag(id: path, name: path, path: path, createdAt: now, updatedAt: now)
    }

    /// How far the chips' ink actually REACHES when the row has room to
    /// spare — which is the quantity her report was about, and the one an
    /// ideal-size measurement cannot see.
    ///
    /// **The first draft of this pin measured the ideal size and was
    /// HOLLOW** — it stayed green with the stretching frame restored, and
    /// the reason is the whole mechanism: `maxWidth` expands only under a
    /// WIDE proposal, and `ImageRenderer` proposes `nil`, under which a
    /// `maxWidth` frame returns its content's ideal width. So the symptom
    /// only exists inside a wide container, and this reproduces the bar's
    /// own layout (a wide row with a trailing `Spacer`) and then reads the
    /// rightmost non-background pixel.
    private func inkWidth(_ tags: [VariorumCore.Tag]) -> Int {
        let renderer = ImageRenderer(
            content: HStack(spacing: 0) {
                NoteTagChips(
                    tokens: .terminalLight, tags: tags, allTags: [],
                    onApply: { _ in }, onRemove: { _ in })
                Spacer(minLength: 0)
            }
            .frame(width: 400, height: 24)
            .background(Color.white))
        renderer.scale = 1
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff)
        else { return 0 }
        var rightmost = 0
        for x in 0..<rep.pixelsWide {
            for y in 0..<rep.pixelsHigh {
                guard let color = rep.colorAt(x: x, y: y) else { continue }
                // Anything meaningfully off white is chip ink (fill, border
                // or glyph).
                if color.redComponent < 0.97 || color.greenComponent < 0.97
                    || color.blueComponent < 0.97 {
                    rightmost = max(rightmost, x)
                    break
                }
            }
        }
        return rightmost
    }

    /// **R4-2, measured rather than asserted by eye.** Her report: *"i
    /// don't like how the tags have so much whitespace in them, it's like
    /// goals and just very stretched out. i think the tag chip should fit
    /// to the length of the tag."*
    ///
    /// The mechanism was `.frame(maxWidth: 150)` on the label — `maxWidth`
    /// in SwiftUI means *flexible up to*, not *capped at*, so a
    /// five-character tag claimed all 150 points. A chip that FITS is
    /// therefore one whose width TRACKS its text, and that is what this
    /// measures: a long tag must be substantially wider than a short one.
    ///
    /// DISCRIMINATING REVERT: put `.frame(maxWidth: 150, alignment:
    /// .leading)` back on the label — the two-character chip stretches past
    /// 150 points and the first expectation fails by a wide margin.
    @Test func aChipsWidthTracksItsTagRatherThanAFixedFrame() {
        let short = inkWidth([tag("ab")])
        let long = inkWidth([tag("a-considerably-longer-tag-name")])
        #expect(short < 100,
                "a two-character tag hugs its text instead of claiming a fixed frame")
        #expect(long > short + 40,
                "…and a long tag draws a wide chip, so the width TRACKS the tag")
        #expect(long < 400, "the row still fits — a long tag compresses rather than overflowing")
    }
}

@MainActor
@Suite("The forward door's destination (13k K11)")
struct ForwardDestinationTests {
    /// `next` is `origin`'s mirror — what ⌘] would open, and therefore what
    /// the → names in its tooltip.
    @Test func nextNamesWhereForwardLands() {
        var history = NavigationHistory()
        history.visit(.shelf)
        history.visit(.post("p1"))
        #expect(history.next == nil, "nothing to go forward to until you go back")
        #expect(history.goBack() == .shelf)
        #expect(history.next == .post("p1"))
        #expect(history.origin == nil, "and now nothing behind it")
        #expect(history.goForward() == .post("p1"))
        #expect(history.next == nil)
    }

    /// The forward destination's NAME has to resolve, or the tooltip reads
    /// "Untitled" for every note (`WorkspaceNaming`'s last-resort fallback,
    /// which exists for ids with no row at all).
    ///
    /// DISCRIMINATING REVERT: drop `$0.value.next` from
    /// `WorkspaceModel.titleSubjects` — the second expectation fails.
    /// Two details make this pin DISCRIMINATING rather than decorative, and
    /// both were found by running it against the revert:
    ///
    /// 1. the destination is a BOOK — a post would resolve anyway through
    ///    the Open strip, which every visited note joins;
    /// 2. the shell's ADOPTION is played out (`goBack` hands back a
    ///    destination; `RootView` selects it), because `titleSubjects` also
    ///    carries what each pane is SHOWING — so a pin that stops at
    ///    `goBack` resolves the book as the pane's own content and proves
    ///    nothing about the forward door.
    @Test func theForwardDestinationJoinsTheTitlesWeResolve() {
        let workspace = WorkspaceModel()
        workspace.select(.post("p1"))
        workspace.select(.reading("b1"))
        let back = workspace.goBack()
        #expect(back == .post("p1"))
        workspace.select(back!)  // the shell adopting it, as RootView does
        #expect(workspace.history().next == .reading("b1"))
        #expect(workspace.history().origin == nil, "nothing behind the pane now")
        #expect(workspace.titleSubjects.contains(.reading("b1")),
                "the → names the book it lands on, so the book's title is resolved")
    }
}
