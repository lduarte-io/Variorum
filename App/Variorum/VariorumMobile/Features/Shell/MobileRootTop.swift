//
//  MobileRootTop.swift
//  VariorumMobile
//
//  VM-259 (the VM-260 run, batch 4a) — **THE ROOTS' TOPS GIVE WAY.** Her words
//  (the ticket): "the top row should also collapse while I'm scrolling - I'm
//  open to ideas on how that should happen… the app just feels like it's
//  fighting for space". Her pick (R-260-12, 2026-11-25, verbatim): "i also
//  choose this one: B — the slim bar (VM-148's rhyme)." — drawn in
//  `notes/plans/vm-260/vm-259-options.html` §B: scrolling down past a real
//  scroll, the Library's three rows (the wing line, the search field, the
//  filter row) condense into ONE pinned 44-pt line — the wing's name, the
//  standing filter as a word, a search glyph, the New Note glyph; an upward
//  nudge, or the search glyph, re-opens the full top; every door stays
//  reachable. Bookcase and Starred get the same line (their name and their own
//  doors). The record: `notes/plans/fixes/vm-260-phone-look.md`, BATCH 4a.
//
//  Three pieces, one file, the phone target only (nothing seam-side, nothing
//  in `Shared/` — A-260-3's procedural rule):
//  · `MobileTopGiveWay` — THE RULE, pure: when a list's own scroll condenses
//    its root's top and when it re-opens it (the wobble, the depth, the rest).
//    It reads the scroll's offset and direction and nothing else (P-4: no
//    broadcast decides it).
//  · `MobileTopGiveWayTracker` — the scroll's own memory (where it last stood,
//    how far it has run one way), held by the root that owns the list. Only the
//    slim/full fact is observed, so a root's body is asked again only when the
//    top flips — never per scrolled frame (P3), and never the listing's hold
//    (VM-68: the slim line is chrome, never a listing change).
//  · `MobileRootTopLine` — THE ONE TOP LINE every root draws, full or slim:
//    the wing's name (the wing door), on the slim line the standing word, then
//    the root's own doors; one 44 pt line under the 4 pt of air every root's
//    line has kept since VM-50; a hairline at its foot while the list runs
//    under it.
//

import Observation
import SwiftUI

// MARK: - The rule

/// **When a root's top gives way** — the mockup's own mechanics (§B's script:
/// "direction with a small hysteresis"), as a pure rule over the list's scroll.
///
/// The list's **travel** is how far it stands from its rest, clamped to its
/// real range (a rubber-band past either end is no travel, so the bounce at the
/// list's foot never re-opens the top). A **run** is the travel gone one way
/// since the last turn. The top condenses when a run DOWN passes the wobble
/// while the list is past the depth ("a real scroll, not a wobble"); it
/// re-opens when a run UP passes the wobble — any real nudge up — or the list
/// is back at its rest. Between the two thresholds nothing changes: that dead
/// band is the hysteresis, so a thumb resting on the glass never flickers it.
/// While `holdOpen` (the search field holds the keyboard) the top stays whole.
///
/// PROVISIONAL as a set (P-260-4a-1): the numbers are the mockup's, the one
/// she picked from — 24 pt either way, 60 pt deep, 8 pt of rest.
nonisolated enum MobileTopGiveWay {
    /// The scroll's own memory.
    struct State: Equatable, Sendable {
        /// The top is condensed into the slim line.
        var slim = false
        /// The travel at the last reading.
        var last: CGFloat = 0
        /// The travel gone one way since the last turn: positive down, negative up.
        var run: CGFloat = 0
    }

    /// A run shorter than this either way is a wobble.
    static let wobble: CGFloat = 24
    /// The list must stand past this before the top condenses — a scroll that
    /// has barely left the top keeps it.
    static let depth: CGFloat = 60
    /// Within this of its rest the list always wears the full top.
    static let rest: CGFloat = 8

    /// **The travel**: the offset from the list's rest, clamped to its range.
    /// `offset` is the scroll view's own content offset and the insets its
    /// adjusted insets (at rest `offset == -insetTop`); the range runs to the
    /// last point the list can stand at.
    static func travel(
        offset: CGFloat, insetTop: CGFloat, insetBottom: CGFloat, content: CGFloat, container: CGFloat
    ) -> CGFloat {
        let reach = max(0, content + insetTop + insetBottom - container)
        return min(max(offset + insetTop, 0), reach)
    }

    /// The scroll view's reading as travel.
    static func travel(of geometry: ScrollGeometry) -> CGFloat {
        travel(
            offset: geometry.contentOffset.y,
            insetTop: geometry.contentInsets.top, insetBottom: geometry.contentInsets.bottom,
            content: geometry.contentSize.height, container: geometry.containerSize.height)
    }

    /// **One reading.** The state the list's travel now leaves.
    static func next(_ state: State, travel y: CGFloat, holdOpen: Bool) -> State {
        if holdOpen || y <= rest { return State(slim: false, last: y, run: 0) }
        let dy = y - state.last
        guard dy != 0 else { return state }
        // A turn starts a fresh run; going on the same way extends it.
        let run = (state.run == 0 || (dy > 0) == (state.run > 0)) ? state.run + dy : dy
        var slim = state.slim
        if run > wobble && y > depth {
            slim = true
        } else if run < -wobble {
            slim = false
        }
        return State(slim: slim, last: y, run: run)
    }

    /// **The full top asked back by a door** (the slim line's search glyph): the
    /// top re-opens where the list stands, and the next run starts fresh — a
    /// real scroll down condenses it again.
    static func reopened(_ state: State) -> State {
        State(slim: false, last: state.last, run: 0)
    }
}

// MARK: - The scroll's own memory

/// **The scroll's own state, held by the root that owns the list.** Every
/// reading moves the memory (unobserved); only the slim/full fact is observed,
/// and it is written only when it flips — an `@Observable` setter announces a
/// write even of the same value, so the guard is what keeps a scrolled frame
/// from asking the root's body again.
@MainActor
@Observable
final class MobileTopGiveWayTracker {
    /// The top is condensed — the one fact a root's body reads.
    private(set) var slim = false
    @ObservationIgnored private var state = MobileTopGiveWay.State()

    /// The list's scroll moved.
    func observe(travel: CGFloat, holdOpen: Bool) {
        state = MobileTopGiveWay.next(state, travel: travel, holdOpen: holdOpen)
        if state.slim != slim { slim = state.slim }
    }

    /// A door asked the full top back.
    func reopen() {
        state = MobileTopGiveWay.reopened(state)
        if slim { slim = false }
    }
}

extension View {
    /// **The list's scroll, read for its root's top** (VM-259): every change
    /// of the list's travel feeds the tracker, on SwiftUI's own scroll reading
    /// (outside its view update — `StableSurface`'s note on these actions).
    func mobileTopGivesWay(_ tracker: MobileTopGiveWayTracker, holdOpen: Bool = false) -> some View {
        onScrollGeometryChange(for: CGFloat.self, of: { MobileTopGiveWay.travel(of: $0) }) { _, travel in
            tracker.observe(travel: travel, holdOpen: holdOpen)
        }
    }
}

// MARK: - The one top line

/// **A root's top line** — VM-255's line (the wing's name alone, the wing
/// door; R-260-1), one face for every root and both states since VM-259. The
/// wing door leads; on the slim line the standing word follows it (what the
/// list below shows — the Library's filter, "· All"); the root's own doors
/// trail it, each the phone's 44 × 44 icon button. ONE 44 pt line (VM-50)
/// under the 4 pt of air the roots' lines have always kept, so the line stands
/// in the same place full or slim. While the list runs under it (`edge` — the
/// slim state), a hairline in the palette's line marks its foot (the slim bar's
/// own edge in the mockup; the bar's hairline, `MobileTabBarMetrics.hairline`).
struct MobileRootTopLine<Doors: View>: View {
    let tokens: VoiceTokens
    let wing: String?
    let onWingDoor: (() -> Void)?
    /// **The slim line's standing word** — drawn voiced, spoken plain (the
    /// filter row's own rule: VoiceOver reads words, not chrome styling); nil
    /// on a full top and on a root whose list has no standing question.
    var standing: (drawn: String, spoken: String)? = nil
    /// The list runs under the line: its hairline foot.
    var edge = false
    @ViewBuilder let doors: () -> Doors

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            MobileWingPath(tokens: tokens, wing: wing, onDoor: onWingDoor)
            if let standing {
                Text(standing.drawn)
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
                    .lineLimit(1)
                    .padding(.leading, PhoneMetrics.Space.s4)
                    .accessibilityLabel(standing.spoken)
            }
            Spacer(minLength: PhoneMetrics.Space.s16)
            doors()
        }
        .frame(minHeight: PhoneMetrics.touchMinimum)
        .padding(.horizontal, PhoneMetrics.gutter)
        .padding(.top, PhoneMetrics.Space.s4)
        .overlay(alignment: .bottom) {
            if edge {
                Rectangle()
                    .fill(tokens.line)
                    .frame(height: MobileTabBarMetrics.hairline)
                    .accessibilityHidden(true)
            }
        }
    }
}

/// **The standing word** — what the slim line says the list below shows: the
/// Library's filter, as the filter row names it ("· All"; Terminal "· all").
/// PROVISIONAL with the line's words (her pass): a standing search keeps the
/// filter's word, never the typed words (the record's C-4a-3).
enum MobileStandingWord {
    static func filter(_ filter: MobileListingFilter, tokens: VoiceTokens) -> (drawn: String, spoken: String) {
        (tokens.chromeLabel("· \(filter.word)"), filter.word)
    }
}

/// **The slim line's search glyph** (VM-259): the Mac's own collapsed-search
/// symbol and word (`LibraryControlsFlow`'s 🔍 door, `LibraryCopy
/// .searchToggleLabel` — S-260-2: the Mac's symbol choices, never its views) on
/// the phone's icon button, in the accent of the doors that act. One press
/// re-opens the full top and puts the keyboard in its field — the root's own
/// act, handed in.
struct MobileSearchGlyphDoor: View {
    let tokens: VoiceTokens
    let act: () -> Void

    /// The Mac's search glyph.
    static let symbol = "magnifyingglass"
    /// The door's name — spoken, and the word the pins drive it by.
    static let spokenName = "Search"

    var body: some View {
        Button(action: act) {
            Image(systemName: Self.symbol)
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens, tone: .accent))
        .accessibilityLabel(Self.spokenName)
    }
}
