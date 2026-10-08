//
//  TourOfferLine.swift
//  Variorum
//
//  13s-b U1a, piece 2 — THE FIRST-OPEN TOUR OFFER (her rulings R-13s-2, -6
//  and -13; mockup v5's "first open" and "not now" frames,
//  `notes/plans/13s-mockups/onboarding-tour.html`).
//
//  Her words: *"calm open, there can be a small helpful badge … offering a
//  tutorial. it can be on the main screen without being a popup"* (R-13s-2) ·
//  *"Welcome to Variorum. Take the tour? and then a yes or not now. if they
//  choose not now, the same popup should briefly change text to show 'run it
//  at any time from help -> tutorial'"* (R-13s-6) · *"i think the tour offer
//  just shouldn't come back - they can find it under help"* (R-13s-13).
//
//  One quiet line on the Bookcase, above the bottom bar, on the right, the
//  small V leading it. No popup, no dim, nothing moves. The RULE is the
//  core's (`Domain/TourOffer`, pinned headless); this file holds the device's
//  one record, the help-road timer, the words and the face.
//
//  Composition (CLAUDE.md's cross-feature rule): the app delegate owns the
//  ONE model (one per process, every window's Bookcase reads it); `RootView`
//  builds the line and hands the Bookcase a view to RENDER, so the Shelf
//  feature never holds this feature's model — the sidebar note box's road.
//

import AppKit
import Observation
import SwiftUI
import VariorumCore

/// The offer's words, in one place so a pin reads the sentence rather than a
/// rendering of it. Sentence case, her words (R-13s-6), no emphasis caps.
nonisolated enum TourOfferCopy {
    static let offer = "Welcome to Variorum. Take the tour?"
    static let yes = "yes"
    static let notNow = "not now"
    /// **The Help menu's door for the tour** (piece 5 renders it). Her
    /// sentence named "Help ▸ Tutorial", but Help already carries "Open the
    /// Tutorial" — the field guide's door — so a second item called Tutorial
    /// would be two doors with one name. The U1a brief's ruled fallback:
    /// name it "Take the Tour", and let the help-road sentence follow
    /// (PROVISIONAL — the U1a RECORD carries it).
    static let menuTitle = "Take the Tour"
    /// The few seconds after "not now": where the tour lives from now on.
    /// Derived from the menu's name, so the two can never disagree.
    static var helpRoad: String { "Run it any time from Help \u{25B8} \(menuTitle)." }
    /// The small V's image asset (piece 4 supplies it; until it exists the
    /// line simply leads with its words).
    static let markAssetName = "VariorumMark"
    /// **U1a STUB — U2 replaces it.** The tour door's honest answer while the
    /// engine does not exist yet: a door that did nothing says so (18i).
    static let stubRefusal = "The tour isn't in this build yet."
}

/// **The offer's model: the device's one record, the phase, the timer.**
///
/// The record is a LOCAL preference (`UserDefaults`), never the store's —
/// the offer is chrome, not document state, so it does not sync
/// (PROVISIONAL, the U1a RECORD). The app delegate holds the one instance;
/// pins build their own over a throwaway suite, because the test host IS the
/// dev-store app and shares its real defaults.
@MainActor
@Observable
final class TourOfferModel {
    /// The local preference's key. Its value is a `TourOffer.Record` raw value.
    nonisolated static let recordKey = "variorum.tour.offer"
    /// **How long the help-road sentence stays** ("briefly", R-13s-6) —
    /// PROVISIONAL, 4 s: long enough to read eight words twice.
    nonisolated static let helpRoadDuration: Duration = .seconds(4)

    private(set) var phase: TourOffer.Phase
    /// **Whether the line keeps a ROW on the Bookcase in this process.**
    /// True from launch when there is anything to offer, and it STAYS true
    /// after the line retires: the row keeps its height, empty, until the
    /// app quits, so the line's leaving moves nothing — the quick-entry box
    /// right above it holds the caret, and a box that jumps as she types is
    /// exactly the movement R-13s-2/12 rule out. At the next launch a retired
    /// offer has no row at all. PROVISIONAL (the U1a RECORD).
    let holdsRow: Bool

    var line: TourOffer.Line? { TourOffer.line(in: phase) }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let helpRoadFor: Duration
    @ObservationIgnored private var helpRoadTimer: Task<Void, Never>?

    init(defaults: UserDefaults, helpRoadDuration: Duration = TourOfferModel.helpRoadDuration) {
        self.defaults = defaults
        self.helpRoadFor = helpRoadDuration
        let atLaunch = TourOffer.phase(atLaunch: defaults.string(forKey: Self.recordKey))
        self.phase = atLaunch
        self.holdsRow = atLaunch != .retired
    }

    /// The app's own model (the app delegate holds the one instance).
    static func forThisApp() -> TourOfferModel {
        TourOfferModel(defaults: .standard)
    }

    /// The line's "not now".
    func notNow() { apply(.notNow) }

    /// The tour began — the line's "yes" or the Help menu's door. The line
    /// steps aside; nothing is remembered until the tour ends.
    func tourStarted() { apply(.tourStarted) }

    /// **U2's hook:** the tour finished or was ended part-way. Either retires
    /// the offer for good on this device.
    func tourEnded(completed: Bool) { apply(.tourEnded(completed: completed)) }

    private func apply(_ event: TourOffer.Event) {
        let step = TourOffer.next(phase, on: event)
        if let record = step.record {
            defaults.set(record.rawValue, forKey: Self.recordKey)
        }
        phase = step.phase
        if phase == .helpRoad {
            if helpRoadTimer == nil {
                let duration = helpRoadFor
                helpRoadTimer = Task { [weak self] in
                    try? await Task.sleep(for: duration)
                    guard !Task.isCancelled else { return }
                    self?.apply(.helpRoadElapsed)
                }
            }
        } else {
            helpRoadTimer?.cancel()
            helpRoadTimer = nil
        }
    }
}

/// **The line itself** — rendered by the Bookcase from the slot `RootView`
/// fills, between the quick-entry box and the bottom bar, right-aligned.
struct TourOfferLine: View {
    /// The `.surface` act this line renders (P-1's declared ⇔ rendered walk):
    /// its "yes" is the tour's inline door. "not now" is a view choice about
    /// this chrome, never an act on the library — undeclared, the Bookcase
    /// strip's own "details" precedent.
    static let surfaceCapabilities: [CapabilityID] = [.takeTour]

    /// The row's one height, whatever it says (or doesn't): the offer, the
    /// help-road sentence and the emptied row all take exactly this, so no
    /// phase change moves the box above it.
    static let rowHeight: CGFloat = 24
    /// The small V's size (the mockup's 17 px mark).
    static let markSize: CGFloat = 16

    let model: TourOfferModel
    let onTakeTour: () -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            content
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    TourOfferLineOracle.contentFrame = $0
                }
                #endif
        }
        .frame(height: Self.rowHeight)
        .padding(.horizontal, 28)
        .animation(.easeOut(duration: 0.5), value: model.line)
        #if DEBUG
        .onAppear { TourOfferLineOracle.drawn = model.line }
        .onChange(of: model.line) { _, now in TourOfferLineOracle.drawn = now }
        .onDisappear { TourOfferLineOracle.forget() }
        #endif
    }

    @ViewBuilder
    private var content: some View {
        switch model.line {
        case .offer:
            HStack(alignment: .center, spacing: 6) {
                mark
                Text(tokens.chromeLabel(TourOfferCopy.offer))
                    .font(tokens.navigation)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Button(tokens.chromeLabel(TourOfferCopy.yes)) { onTakeTour() }
                    .buttonStyle(VoicedButtonStyle(
                        tokens: tokens, role: .primary,
                        font: tokens.navigation.weight(.semibold)))
                Text("\u{00B7}")
                    .font(tokens.navigation)
                    .foregroundStyle(tokens.faint)
                Button(tokens.chromeLabel(TourOfferCopy.notNow)) { model.notNow() }
                    .buttonStyle(VoicedButtonStyle(
                        tokens: tokens, role: .quiet, font: tokens.navigation))
            }
            .transition(.opacity)
        case .helpRoad:
            Text(tokens.chromeLabel(TourOfferCopy.helpRoad))
                .font(tokens.navigation)
                .italic()
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .transition(.opacity)
        case nil:
            EmptyView()
        }
    }

    /// The small V (R-13s-24/25 — the faithful two-tone edition), when its
    /// asset is in the bundle.
    @ViewBuilder
    private var mark: some View {
        if let image = NSImage(named: TourOfferCopy.markAssetName) {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .frame(width: Self.markSize, height: Self.markSize)
                .accessibilityHidden(true)
        }
    }
}

#if DEBUG
/// What the offer line last DREW and where its words sat (`.global`) — the
/// chrome pins' oracle (`TourOfferLineTests`). One line per process.
@MainActor
enum TourOfferLineOracle {
    static var drawn: TourOffer.Line?
    static var contentFrame: CGRect?

    static func forget() {
        drawn = nil
        contentFrame = nil
    }
}
#endif
