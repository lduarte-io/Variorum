//
//  TourOfferCard.swift
//  Variorum
//
//  13s-b U1a, piece 2 — THE FIRST-OPEN TOUR OFFER (her rulings R-13s-2, -6
//  and -13; mockup v5's "first open" and "not now" frames,
//  `notes/plans/13s-mockups/onboarding-tour.html`), REBUILT AS A CARD at
//  VX-292 U4 (VX-559; her rulings R-292-5 and R-292-12,
//  `notes/plans/vx-292-onboarding.md`).
//
//  Her words: *"calm open, there can be a small helpful badge … offering a
//  tutorial. it can be on the main screen without being a popup"* (R-13s-2) ·
//  *"i think the tour offer just shouldn't come back - they can find it under
//  help"* (R-13s-13) · *"rather than yes / not now, I wanted it to be yes or
//  no, and if they choose no, just show 'this can always be started via
//  help'"* (R-292-5) · the doors are yes · no ONLY: no ✕, no snooze; no
//  shows the Help road briefly and the card retires forever (R-292-12). The
//  ticket's why (VX-559): beta testers never saw the quiet line.
//
//  One card in the Bookcase's band — between the shelf listing and the quick
//  entry, the main column's full width, the words card's idiom
//  (`WordsBandCard`) — never a popup, no dim. When the words card also
//  stands, this card sits ABOVE it (PROVISIONAL P-292-13, the U4 RECORD):
//  the band's top card is the one whose leaving moves nothing under it. The
//  RULE is the core's (`Domain/TourOffer`, pinned headless, unchanged by the
//  card); this file holds the device's one record, the help-road timer, the
//  words and the face.
//
//  Composition (CLAUDE.md's cross-feature rule): the app delegate owns the
//  ONE model (one per process, every window's Bookcase reads it); `RootView`
//  builds the card and hands the Bookcase a view to RENDER, so the Shelf
//  feature never holds this feature's model — the sidebar note box's road.
//

import AppKit
import Observation
import SwiftUI
import VariorumCore

/// The offer's words, in one place so a pin reads the sentence rather than a
/// rendering of it. Sentence case, her register, no emphasis caps, no em dash.
nonisolated enum TourOfferCopy {
    /// The card's title (VX-292 U4, the brief's words).
    static let title = "Welcome to Variorum."
    /// The card's one sentence (VX-292 U4, the brief's words).
    static let sentence = "A short tour shows you around: books, notes, and takes."
    /// The two doors (R-292-5, R-292-12: yes · no, nothing else).
    static let yes = "yes"
    static let no = "no"
    /// **The Help menu's door for the tour.** Her sentence at 13s named
    /// "Help ▸ Tutorial", but Help already carried the field guide's door, so
    /// the U1a brief's ruled fallback named it "Take the Tour"; **VX-602 (the
    /// VX-439 run, A-439-9 — her words: "take the tour should be the
    /// onboarding tutorial still. it's just confusing.")** names it for what
    /// it is, the ONBOARDING tutorial, and the field guide's doors say "field
    /// guide" (`.restoreTutorial`, Help ▸ Open the Field Guide) — so
    /// "tutorial" names one thing on the Help menu, never two. The registry's
    /// `.takeTour` row reads this constant as its verb.
    static let menuTitle = "Take the Onboarding Tutorial"
    /// The few seconds after "no": where the tour lives from now on (R-292-5:
    /// *"this can always be started via help"*, in the brief's shape). The
    /// door's name is read from the REGISTRY's `.takeTour` verb — the very
    /// words the Help menu draws (`EditorCommands`' `verb(.takeTour)`) — so
    /// the sentence and the menu can never disagree.
    static var helpRoad: String {
        "This can always be started from Help \u{25B8} \(CapabilityRegistry.capability(.takeTour).verb)."
    }
    /// The small mark's image asset — the sea-glass cards (VX-177/VX-192; the
    /// brand logo since VX-993), the ONE mark About draws too (13s-b U1a
    /// piece 4; `notes/brand/tools/appicon.py` writes it; `AppMarkTests` pins it).
    static let markAssetName = "VariorumMark"
}

/// **The offer's model: the device's one record, the phase, the timer.**
///
/// The record is a LOCAL preference (`UserDefaults`), never the store's —
/// the offer is chrome, not document state, so it does not sync
/// (PROVISIONAL, the 13s-b U1a RECORD). The app delegate holds the one
/// instance; pins build their own over a throwaway suite, because the test
/// host IS the dev-store app and shares its real defaults.
@MainActor
@Observable
final class TourOfferModel {
    /// The local preference's key. Its value is a `TourOffer.Record` raw
    /// value — the SAME values the quiet line wrote (VX-292 U4 changed the
    /// face, never the record), so every device's earlier answer holds.
    nonisolated static let recordKey = "variorum.tour.offer"
    /// **How long the help-road sentence stays** ("briefly", R-13s-6 and
    /// R-292-12) — PROVISIONAL since 13s-b U1a, 4 s: long enough to read the
    /// sentence twice.
    nonisolated static let helpRoadDuration: Duration = .seconds(4)

    private(set) var phase: TourOffer.Phase

    /// What the card says: the offer, the help-road sentence, or nothing (the
    /// card is not in the band at all). VX-292 U4: the line's held row is
    /// retired with the line — the card sits in the band ABOVE the quick
    /// entry, so its leaving gives its height to the shelf listing and moves
    /// nothing under it.
    var line: TourOffer.Line? { TourOffer.line(in: phase) }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let helpRoadFor: Duration
    @ObservationIgnored private var helpRoadTimer: Task<Void, Never>?

    init(defaults: UserDefaults, helpRoadDuration: Duration = TourOfferModel.helpRoadDuration) {
        self.defaults = defaults
        self.helpRoadFor = helpRoadDuration
        self.phase = TourOffer.phase(atLaunch: defaults.string(forKey: Self.recordKey))
    }

    /// The app's own model (the app delegate holds the one instance).
    static func forThisApp() -> TourOfferModel {
        TourOfferModel(defaults: .standard)
    }

    /// **The card's "no"** (R-292-5/12). The rule's event keeps its old
    /// name, `.notNow` — its face's word changed, the record it writes
    /// (`declined`) did not.
    func decline() { apply(.notNow) }

    /// The tour began — the card's "yes" or the Help menu's door. The card
    /// steps aside; nothing is remembered until the tour ends.
    func tourStarted() { apply(.tourStarted) }

    /// The tour finished or was ended part-way (the engine's doors,
    /// `RootView.tourDoors`). Either retires the offer for good on this
    /// device.
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

/// **The card itself** — rendered by the Bookcase from the band slot
/// `RootView` fills (`ShelfView.offerCard`), above the words card and the
/// quick entry. It draws itself only while it has something to say (the
/// words card's idiom): the offer, then — after "no" — the help-road
/// sentence in the SAME frame, then nothing, and the band closes over it.
struct TourOfferCard: View {
    /// The `.surface` act this card renders (P-1's declared ⇔ rendered walk):
    /// its "yes" is the tour's inline door, the line's precedent. "no" is a
    /// view choice about this chrome, never an act on the library —
    /// undeclared, the Bookcase strip's own "details" precedent.
    static let surfaceCapabilities: [CapabilityID] = [.takeTour]

    /// **The card's doors, in drawing order — yes · no and nothing else**
    /// (R-292-12: no ✕, no snooze). The face draws exactly this table.
    enum Door: CaseIterable, Hashable {
        case yes
        case no

        var word: String {
            switch self {
            case .yes: TourOfferCopy.yes
            case .no: TourOfferCopy.no
            }
        }
    }

    /// The small cards mark's size beside the card's two lines (the line drew
    /// it at 16 pt beside one).
    static let markSize: CGFloat = 20

    let model: TourOfferModel
    let onTakeTour: () -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    #if DEBUG
    /// This card's own name in its oracle (the 18k C4 rule: the registrant
    /// names itself, and its teardown clears only what it still owns).
    @State private var oracleOwner = UUID()
    #endif

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// **What a door does** — the buttons call exactly this, so a pin can
    /// press a door without a pointer. "yes" is the tour's one entry
    /// (`RootView.startTour`, which steps the card aside through
    /// `tourStarted()`); "no" is the model's `decline()`.
    func press(_ door: Door) {
        switch door {
        case .yes: onTakeTour()
        case .no: model.decline()
        }
    }

    var body: some View {
        // The container persists so the card's ARRIVAL and LEAVING animate
        // (a transition needs an animated parent); with no line it is empty
        // and takes no height in the band.
        VStack(spacing: 0) {
            if let line = model.line {
                card(line)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.5), value: model.line)
    }

    /// The card's paper: the words card's idiom exactly (padding, card fill,
    /// hairline, radius, the board's gutter) so the band reads as one family.
    private func card(_ line: TourOffer.Line) -> some View {
        HStack(alignment: .center, spacing: 12) {
            mark
            // The offer's content is always LAID OUT, so the help-road
            // sentence takes over the same frame: the swap moves nothing.
            offer
                .opacity(line == .offer ? 1 : 0)
                .allowsHitTesting(line == .offer)
                .disabled(line != .offer)
                .accessibilityHidden(line != .offer)
                .overlay(alignment: .leading) {
                    helpRoad
                        .opacity(line == .helpRoad ? 1 : 0)
                        .accessibilityHidden(line != .helpRoad)
                }
                .animation(.easeOut(duration: 0.3), value: line)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
        #if DEBUG
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            TourOfferCardOracle.recordFrame($0, for: model, owner: oracleOwner)
        }
        .onAppear { TourOfferCardOracle.record(line, for: model, owner: oracleOwner) }
        .onChange(of: line) { _, now in TourOfferCardOracle.record(now, for: model, owner: oracleOwner) }
        .onDisappear { TourOfferCardOracle.release(owner: oracleOwner) }
        #endif
        // The board's own gutter (the shelf listing's and the words card's).
        .padding(.horizontal, 28)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var offer: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(TourOfferCopy.title)
                    .font(tokens.body.weight(.semibold))
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(TourOfferCopy.sentence)
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            ForEach(Door.allCases, id: \.self) { door in
                Button(tokens.chromeLabel(door.word)) { press(door) }
                    .buttonStyle(CalmButtonStyle(
                        tokens: tokens, role: door == .yes ? .primary : .ordinary))
            }
        }
    }

    private var helpRoad: some View {
        Text(TourOfferCopy.helpRoad)
            .font(tokens.body)
            .italic()
            .foregroundStyle(tokens.muted)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// The small cards mark — the app's one mark (the sea-glass cards,
    /// VX-177/VX-192; the brand logo since VX-993), the asset About draws too
    /// (`TourOfferCopy.markAssetName`; `AppMarkTests` holds the two
    /// placements to one asset).
    private var mark: some View {
        Image(TourOfferCopy.markAssetName)
            .resizable()
            .interpolation(.high)
            .frame(width: Self.markSize, height: Self.markSize)
            .accessibilityHidden(true)
    }
}

#if DEBUG
/// What the offer card last DREW and where its paper sat (`.global`) — the
/// chrome pins' oracle (`TourOfferCardTests`, `TourEntryTests`).
///
/// **Scoped by the card's MODEL, owned by the card** (VX-292 U4, the U4 stage
/// window's finding): the test host IS the dev-store app, and its own window
/// draws the app delegate's card on its own Bookcase whenever the dev store's
/// record is unset — a process-global slot would let that live card answer a
/// pin's read. A pin builds its own `TourOfferModel`, which no other world can
/// share (the 13u2 UNIT E rule — scope by an object the pin holds), and reads
/// by it; within a model the C4 rule stands (the most recent card answers,
/// and a card's teardown takes only its own entry).
@MainActor
enum TourOfferCardOracle {
    private static var drawnStore = OwnedRegistrations<ObjectIdentifier, TourOffer.Line>()
    private static var frameStore = OwnedRegistrations<ObjectIdentifier, CGRect>()

    /// What `model`'s card is drawing now (nil: no card of `model` in a band).
    static func drawn(for model: TourOfferModel) -> TourOffer.Line? {
        drawnStore[ObjectIdentifier(model)]
    }

    /// Where `model`'s card's paper sits (nil: no card of `model` in a band).
    static func cardFrame(for model: TourOfferModel) -> CGRect? {
        frameStore[ObjectIdentifier(model)]
    }

    static func record(_ line: TourOffer.Line, for model: TourOfferModel, owner: UUID) {
        drawnStore.publish(line, for: ObjectIdentifier(model), owner: owner)
    }

    static func recordFrame(_ frame: CGRect, for model: TourOfferModel, owner: UUID) {
        frameStore.publish(frame, for: ObjectIdentifier(model), owner: owner)
    }

    static func release(owner: UUID) {
        drawnStore.release(owner: owner)
        frameStore.release(owner: owner)
    }

    /// A pin's door: start from empty.
    static func forgetAll() {
        drawnStore.forgetAll()
        frameStore.forgetAll()
    }
}
#endif
