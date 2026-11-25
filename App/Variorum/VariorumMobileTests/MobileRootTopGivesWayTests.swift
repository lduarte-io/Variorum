//
//  MobileRootTopGivesWayTests.swift
//  VariorumMobileTests
//
//  VM-259 (the VM-260 run, batch 4a) — **THE LIBRARY'S TOP GIVES WAY: the slim
//  line.** Her words (the ticket): "the top row should also collapse while I'm
//  scrolling - I'm open to ideas on how that should happen… the app just feels
//  like it's fighting for space". Her pick (R-260-12, 2026-11-25, verbatim): "i
//  also choose this one: B — the slim bar (VM-148's rhyme)." — drawn in
//  `notes/plans/vm-260/vm-259-options.html` §B: scrolling DOWN past a real scroll
//  (not a wobble), the three rows (the wing line, the search field, the filter
//  row) condense into ONE pinned 44-pt line — the wing's name, the standing
//  filter as a word, a search glyph, the New Note glyph; any upward nudge, or
//  the search glyph, re-opens the full top (the glyph also focuses the field);
//  every door stays reachable, every target 44 × 44. The record:
//  `notes/plans/fixes/vm-260-phone-look.md`, BATCH 4a.
//
//  These pins drive the REAL Library the way a thumb does — mounted in a key
//  window, its listing's scroll view moved — and read only what is on screen,
//  so they compile on the pre-fix tree (literals and symbols both trees declare)
//  and are RED there: nothing on the old Library gives way, so no slim line's
//  search door ever comes on screen. The give-way RULE's own arithmetic (the
//  wobble, the depth, the rest, the clamp) is `MobileTopGiveWayRuleTests`.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// The listing's scroll view: the deepest-content `UIScrollView` under a view
/// (the Library's one `ScrollView` over its `LazyVStack` — the paging pins'
/// own finder).
@MainActor
private func listingScroll(in view: UIView) -> UIScrollView? {
    var best: UIScrollView?
    func walk(_ node: UIView) {
        if let scroll = node as? UIScrollView,
           scroll.contentSize.height > (best?.contentSize.height ?? 0) {
            best = scroll
        }
        for sub in node.subviews { walk(sub) }
    }
    walk(view)
    return best
}

@MainActor
@Suite("VM-259 — the Library's top gives way to a slim line (batch 4a)", .serialized)
struct MobileRootTopGivesWayTests {
    /// iPhone 17 Pro's points (the run's other geometry pins').
    static let size = CGSize(width: 402, height: 874)
    /// The slim line's search glyph's name — the Mac's own word for its
    /// collapsed search door (`LibraryCopy.searchToggleLabel`). A literal: the
    /// pre-fix tree declares no such door.
    static let searchDoor = "Search"
    /// The full top's filter row leads with this door (a button), and the slim
    /// line says the same word as plain text.
    static let allWord = "All"

    private nonisolated static func title(_ index: Int) -> String { String(format: "Scrolled note %02d", index) }

    /// Sixty notes: one page (the listing's page is 200), so no scroll here
    /// asks for a next page — the only reads are the listing's own.
    private func seedNotes(_ session: AppSession) async throws {
        try await session.runner.run { ops in
            for index in 0..<60 {
                let post = try ops.createPost(title: Self.title(index))
                _ = try ops.newBlock(in: post.id, text: "Words \(index).", at: .end)
            }
        }
    }

    /// The real Library, as the shell composes it (its books through a started
    /// shelf model; the shell's Settings door in the environment, so the gear
    /// stands on the line as it does on the phone).
    private func library(_ session: AppSession, tokens: VoiceTokens, shelf: MobileShelfViewModel) -> some View {
        MobileLibraryView(
            model: MobileLibraryViewModel(session: session),
            scraps: MobileScrapsModel(session: session),
            stars: MobileStarsModel(session: session),
            books: shelf, tokens: tokens, wingName: WingWords.home, onWingDoor: {},
            tabBar: { EmptyView() },
            onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            .environment(\.mobileSettingsDoor, MobileSettingsDoor {})
    }

    private func startedShelf(_ session: AppSession) async -> (MobileShelfViewModel, Task<Void, Never>) {
        let shelf = MobileShelfViewModel(session: session)
        let observing = Task { await shelf.start() }
        await shelf.refreshTags()
        return (shelf, observing)
    }

    /// The doors named `label` that are buttons (the slim line's word "All" is
    /// text; the filter row's "All" is a door).
    private func doors<V: View>(_ surface: HostedSurface<V>, _ label: String) -> [NSObject] {
        surface.visibleElements.filter {
            $0.accessibilityLabel == label && $0.accessibilityTraits.contains(.button)
        }
    }

    /// Moves the listing to `travel` points from its rest, unanimated — a
    /// thumb's scroll as the scroll view's own offset — and lets the view answer.
    private func scroll<V: View>(
        _ surface: HostedSurface<V>, to travel: CGFloat,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async throws {
        let scroll = try #require(listingScroll(in: surface.host.view),
                                  "the listing's scroll view", sourceLocation: sourceLocation)
        scroll.setContentOffset(CGPoint(x: 0, y: travel - scroll.adjustedContentInset.top), animated: false)
        await surface.settle(12)
    }

    /// The full top stands: the filter row's All door is on screen and no slim
    /// line's search door is.
    private func expectFull<V: View>(
        _ surface: HostedSurface<V>, _ moment: String, sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(!doors(surface, Self.allWord).isEmpty,
                "\(moment): the full top's filter row is back (its All door) — labels \(surface.visibleLabels)",
                sourceLocation: sourceLocation)
        #expect(doors(surface, Self.searchDoor).isEmpty,
                "\(moment): no slim line's search door while the full top stands", sourceLocation: sourceLocation)
    }

    /// Every named door answers across 44 × 44 and sits on the wing door's line.
    private func expectLineDoors<V: View>(
        _ labels: [String], on surface: HostedSurface<V>, _ moment: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let wing = try #require(doors(surface, WingWords.home).first,
                                "\(moment): the wing door — labels \(surface.visibleLabels)",
                                sourceLocation: sourceLocation).accessibilityFrame
        #expect(wing.width >= 43.5 && wing.height >= 43.5, "\(moment): the wing door answers across 44 × 44: \(wing)",
                sourceLocation: sourceLocation)
        for label in labels {
            let found = doors(surface, label)
            #expect(found.count == 1, "\(moment): one \(label) door on screen, not \(found.count)",
                    sourceLocation: sourceLocation)
            guard let frame = found.first?.accessibilityFrame else { continue }
            #expect(frame.width >= 43.5 && frame.height >= 43.5,
                    "\(moment): \(label) answers across 44 × 44: \(frame)", sourceLocation: sourceLocation)
            #expect(abs(frame.midY - wing.midY) <= 2,
                    "\(moment): \(label) is off the wing door's line: \(frame.midY) vs \(wing.midY)",
                    sourceLocation: sourceLocation)
        }
    }

    /// **A REAL SCROLL CONDENSES THE TOP; A NUDGE UP RE-OPENS IT** — in both
    /// voices, the mockup's own road: a scroll down 300 pt (past the wobble and
    /// the depth) shows the slim line — the wing door, the standing word, the
    /// search glyph and New Note, each 44 × 44 on one line at the top — and the
    /// full top's search field, filter row, trash and gear give way; a wobble of
    /// 10 pt up and 6 down keeps it; a nudge of 36 pt up re-opens the full top
    /// (its four doors 44 × 44 again); a wobble of 10 pt down keeps THAT; the
    /// listing's rest is the full top.
    ///
    /// *RED ON OLD:* nothing gives way — at 300 pt the slim line's search door is
    /// absent (the `#require`: one issue per voice, the test stops there).
    @Test(arguments: [ThemeVoice.study, .terminal])
    func aRealScrollCondensesTheTopAndANudgeReopensIt(voice: ThemeVoice) async throws {
        try await withEditorWorld { session, _ in
            try await seedNotes(session)
            let tokens = voice == .study ? VoiceTokens.studyLight : .terminalLight
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }
            try await withHostedSurface(library(session, tokens: tokens, shelf: shelf), size: Self.size) { surface in
                await surface.settle(40)
                expectFull(surface, "at rest")
                try expectLineDoors([MobileRecoveryDoors.trashLabel, "New Note", MobileSettingsGear.spokenLabel],
                                    on: surface, "at rest")

                try await scroll(surface, to: 300)
                let search = try #require(doors(surface, Self.searchDoor).first,
                                          "RED — 300 pt down, the top never gave way: no slim line's search door — labels \(surface.visibleLabels)")
                #expect(doors(surface, Self.allWord).isEmpty, "the filter row gave way (no All door)")
                #expect(doors(surface, MobileRecoveryDoors.trashLabel).isEmpty, "the trash gave way with the full top")
                #expect(doors(surface, MobileSettingsGear.spokenLabel).isEmpty, "the gear gave way with the full top")
                #expect(surface.visibleElements.contains {
                    $0.accessibilityLabel == Self.allWord && !$0.accessibilityTraits.contains(.button)
                }, "the slim line says the standing filter as a word — labels \(surface.visibleLabels)")
                try expectLineDoors([Self.searchDoor, "New Note"], on: surface, "slim")
                // ONE line, pinned at the top: the slim line sits where the full
                // top's wing line sat (the root's top plus its 4 pt of air).
                #expect(search.accessibilityFrame.minY <= surface.host.view.safeAreaInsets.top + 4.5 + 0.5,
                        "the slim line is pinned at the top: \(search.accessibilityFrame)")

                try await scroll(surface, to: 290)
                #expect(!doors(surface, Self.searchDoor).isEmpty, "a 10 pt wobble up keeps the slim line")
                try await scroll(surface, to: 296)
                #expect(!doors(surface, Self.searchDoor).isEmpty, "a 6 pt wobble down keeps the slim line")

                try await scroll(surface, to: 260)
                expectFull(surface, "a 36 pt nudge up")
                try expectLineDoors([MobileRecoveryDoors.trashLabel, "New Note", MobileSettingsGear.spokenLabel],
                                    on: surface, "re-opened")
                try await scroll(surface, to: 270)
                expectFull(surface, "a 10 pt wobble down after the re-open")

                try await scroll(surface, to: 0)
                expectFull(surface, "back at the listing's rest")
            }
        }
    }

    /// **THE SLIM LINE'S SEARCH GLYPH RE-OPENS THE TOP AND FOCUSES THE FIELD.**
    /// Condensed, the glyph's one press brings the full top back and puts the
    /// keyboard in the Library's search field (found by its placeholder, the
    /// hidden-page pin's road).
    ///
    /// *RED ON OLD:* no slim line, so no glyph to press (the `#require`: one issue).
    @Test func theSlimLinesSearchGlyphReopensTheTopAndFocusesTheField() async throws {
        try await withEditorWorld { session, _ in
            try await seedNotes(session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }
            try await withHostedSurface(library(session, tokens: .studyLight, shelf: shelf), size: Self.size) { surface in
                await surface.settle(40)
                try await scroll(surface, to: 300)
                let search = try #require(doors(surface, Self.searchDoor).first,
                                          "RED — no slim line's search door to press — labels \(surface.visibleLabels)")
                #expect(search.accessibilityActivate(), "the search glyph is a real control")
                await surface.settle(20)
                expectFull(surface, "after the search glyph")
                func views(_ view: UIView) -> [UIView] { [view] + view.subviews.flatMap(views) }
                let field = try #require(views(surface.window).compactMap { $0 as? UITextField }.first { field in
                    let words = field.attributedPlaceholder?.string ?? field.placeholder ?? ""
                    return words.range(of: "search notes", options: .caseInsensitive) != nil
                }, "the Library's search field")
                #expect(field.isFirstResponder, "the glyph put the keyboard in the search field")
                _ = field.resignFirstResponder()
                await surface.settle(10)
            }
        }
    }

    /// **CONDENSING ASKS THE LISTING NOTHING** (P1, VM-68's re-ask discipline:
    /// the slim line is chrome, never a listing change). Across a scroll that
    /// condenses the top, re-opens it, condenses it again and returns to rest,
    /// the Library's reads and landings — the process's one timing recorder,
    /// sound because this host runs its suites one after another
    /// (`MobileBoxOpenTimingTests`' header) — do not move: one page of sixty
    /// notes, so no scroll asks for another, and nothing is written.
    ///
    /// *A GUARD over the count* (zero on both trees — nothing condensed there to
    /// ask), *RED ON OLD at its premise only*: the slim line never showed (one
    /// issue). The count is the claim; the premise is what makes it mean
    /// something on the tip.
    @Test func condensingAsksTheListingNothing() async throws {
        try await withEditorWorld { session, _ in
            try await seedNotes(session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }
            try await withHostedSurface(library(session, tokens: .studyLight, shelf: shelf), size: Self.size) { surface in
                await surface.settle(40)
                AppTiming.recorder.setEnabled(true)
                let counted: [AppTimingCounter] = [.libraryFetch, .booklessFetch, .libraryDelivery, .booklessDelivery]
                let before = AppTiming.recorder.snapshot()
                var sawSlim = false
                for travel: CGFloat in [300, 260, 320, 0] {
                    try await scroll(surface, to: travel)
                    if !doors(surface, Self.searchDoor).isEmpty { sawSlim = true }
                }
                await surface.settle(20)
                let after = AppTiming.recorder.snapshot()
                for counter in counted {
                    #expect(after.counter(counter) - before.counter(counter) == 0,
                            "condensing asked the listing: \(counter) moved by \(after.counter(counter) - before.counter(counter))")
                }
                #expect(sawSlim, "the premise: the scroll condensed the top at least once")
            }
        }
    }
}
