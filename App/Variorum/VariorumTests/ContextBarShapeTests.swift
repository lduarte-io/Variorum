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

import Foundation
import Testing
import VariorumCore

@testable import Variorum

@Suite("The context bar's icon row (13k K11)")
struct ContextBarDoorsTests {
    /// **THE CONSTANT ROW.** Four doors for a note, in her screenshot's
    /// order, whatever the state is; two for a place, because the other
    /// two could never act there (P-2).
    ///
    /// DISCRIMINATING REVERT: return `[.back, .book, .forward]` for a note
    /// (i.e. hide the tag door when there are no tags, the shape the
    /// pre-13k bar had for its own halves) — the first expectation fails.
    @Test func theRowIsFourDoorsForANoteAndTwoForAPlace() {
        #expect(ContextBarDoors.iconRow(isNote: true) == [.back, .book, .tags, .forward])
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

    /// The ＃ carries the count only when the cards are hidden — unfolded,
    /// a number would repeat what is right beside it.
    @Test func theTagsDoorCarriesTheCountOnlyWhenFolded() {
        #expect(ContextBarDoors.tagsDoorCount(folded: true, tagCount: 3) == 3)
        #expect(ContextBarDoors.tagsDoorCount(folded: true, tagCount: 0) == nil,
                "a folded door on an untagged note says ＃, not ＃0")
        #expect(ContextBarDoors.tagsDoorCount(folded: false, tagCount: 3) == nil)
    }

    /// The bar renders when the pane has anything to say — and a pane that
    /// has only gone BACK now qualifies, because the › is a door.
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
@Suite("The forward door's destination (13k K11)")
struct ForwardDestinationTests {
    /// `next` is `origin`'s mirror — what ⌘] would open, and therefore what
    /// the › names in its tooltip.
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
                "the › names the book it lands on, so the book's title is resolved")
    }
}
