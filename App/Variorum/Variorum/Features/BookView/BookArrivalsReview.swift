//
//  BookArrivalsReview.swift
//  Variorum
//
//  VX-821 (the VX-808 run, Unit B3) — THE ARRIVALS REVIEW AREA, ONE HOME.
//  Her pick at the design sitting (R-808-5, "Full book area, one home"): the
//  masthead Arrivals door opens the review IN the book's content area — a
//  mode-sized surface with Done to return; the popover retired. Her bar,
//  verbatim: *"the UX should be clear, spacious, not cluttered, buttons should
//  be a good size, if we need to make the 'seating' area larger or occupy the
//  full book area we can. i think the seating area probably needs more
//  space."*
//
//  The face, per the picked preview: the header "Arrivals — N waiting" with
//  Add all · Dismiss all; spacious selectable rows (`BookArrivalsList` — the
//  checkbox, the note's first words, why it waits and since when, the
//  ownership-aware arms); the bar at the foot — "N selected · Add N ·
//  Dismiss N", Done; arrows walk, ⏎ adds, ⌫ dismisses, ⌘A picks every listed
//  row, esc is Done. A row's NAME opens the note read-normal and never adds.
//
//  WHERE IT IS DRAWN: the book composes it OVER the mode's body (the book
//  search answer's precedent — an overlay, never a container: the mode's
//  layout, scroll and live editor stay exactly as they were, so Done returns
//  the book's prior mode untouched); in Index it covers the PANE, the column
//  (and its masthead's door) staying in view. It renders read-only rows (no
//  editor — P3); its cost is the listed rows' (the window), never the corpus.
//

import AppKit
import SwiftUI
import VariorumCore

struct BookArrivalsReview: View {
    /// **The review's own doors** (P-1 — declared once, `.surface`): the
    /// header's Add all · Dismiss all and the bar's Add N · Dismiss N. Their
    /// ONLY renderer, so the declaration lives with the builder; the row arms
    /// are `BookArrivalsList`'s.
    static let surfaceCapabilities: [CapabilityID] = [
        .addAllArrivals, .dismissAllArrivals, .addSelectedArrivals, .dismissSelectedArrivals,
    ]

    let model: BookArrivalsModel
    let structure: BookStructureModel
    /// Whether THIS surface hosts the quiet receipt (`BookNoteBox
    /// .quietReceiptHome` answers `.reviewBar` while the review covers the
    /// bar or page foot that would have hosted it).
    var hostsQuietReceipt: Bool = false
    /// Done (and esc): back to the book's mode.
    var onDone: () -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @FocusState private var holdsKeys: Bool
    #if DEBUG
    @State private var probeOwner = UUID()
    #endif

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The column the review reads in — spacious, never a full-width smear on
    /// a wide window.
    static let measure: CGFloat = 900

    var body: some View {
        VStack(spacing: 0) {
            header
            hairline
            content
            hairline
            bar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(tokens.surface)
        .contentShape(Rectangle())
        // The keyboard is the review's while it shows (her ruled keys).
        .focusable()
        .focusEffectDisabled()
        .focused($holdsKeys)
        .onKeyPress(phases: [.down, .repeat]) { press in handle(press) }
        // ⌘A arrives through Edit ▸ Select All's responder action.
        .onCommand(#selector(NSResponder.selectAll(_:))) { model.selectAll() }
        .onAppear { holdsKeys = true }
        .confirmationDialog(
            ArrivalsReviewCopy.dismissAllTitle(model.pendingDismissAll?.count ?? 0),
            isPresented: Binding(
                get: { model.pendingDismissAll != nil },
                set: { presented in if !presented { model.cancelDismissAll() } }),
            titleVisibility: .visible,
            presenting: model.pendingDismissAll
        ) { rows in
            Button(ArrivalsReviewCopy.dismissAllConfirm(rows.count), role: .destructive) {
                Task { await model.confirmDismissAll(rows, book: structure.reading) }
            }
            Button(ArrivalsReviewCopy.cancelVerb, role: .cancel) { model.cancelDismissAll() }
        } message: { rows in
            Text(ArrivalsReviewCopy.dismissAllMessage(rows.count))
        }
        #if DEBUG
        .onAppear { record() }
        .onChange(of: model.selection) { _, _ in record() }
        .onChange(of: model.door) { _, _ in record() }
        .onDisappear { ArrivalsReviewProbe.forget(model.readingID, owner: probeOwner) }
        #endif
    }

    private var hairline: some View {
        Rectangle().fill(tokens.line).frame(height: 1)
    }

    // MARK: The header — "Arrivals — N waiting", Add all · Dismiss all

    private var header: some View {
        HStack(spacing: 12) {
            Text(tokens.chromeLabel(ArrivalsCopy.header(count: model.door.count)))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Spacer(minLength: 12)
            if ArrivalsLineFace.isShown(model.door) {
                Button(tokens.chromeLabel(verb(.addAllArrivals))) {
                    holdsKeys = true
                    Task { await model.addAll(book: structure.reading, chaptered: structure.chaptersActive) }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .lineLimit(1)
                .fixedSize()
                .disabled(model.bulkInFlight)
                .help(ArrivalsReviewCopy.addAllHelp)
                Button(tokens.chromeLabel(verb(.dismissAllArrivals))) {
                    holdsKeys = true
                    Task { await model.requestDismissAll(book: structure.reading) }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .ordinary))
                .lineLimit(1)
                .fixedSize()
                .disabled(model.bulkInFlight)
                .help(ArrivalsReviewCopy.dismissAllHelp)
            }
        }
        .frame(maxWidth: Self.measure)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }

    // MARK: The rows — or the calm answer

    @ViewBuilder private var content: some View {
        if ArrivalsLineFace.isShown(model.door) {
            ScrollView {
                BookArrivalsList(
                    model: model, structure: structure, onInteract: { holdsKeys = true })
                    .frame(maxWidth: Self.measure)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
        } else {
            VStack {
                ChromeNotice(tokens: tokens, text: ArrivalsReviewCopy.nothingWaiting, lines: 3)
                    .frame(maxWidth: 520)
                    .padding(.top, 48)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: The bar — "N selected · Add N · Dismiss N", the receipt, Done

    private var bar: some View {
        let picked = model.selection.count
        return HStack(spacing: 12) {
            if picked > 0 {
                Text(tokens.chromeLabel(ArrivalsReviewCopy.selected(picked)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
                Button(tokens.chromeLabel(ArrivalsReviewCopy.addSelectedLabel(picked))) {
                    holdsKeys = true
                    Task {
                        await model.addSelected(
                            book: structure.reading, chaptered: structure.chaptersActive)
                    }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .lineLimit(1)
                .fixedSize()
                .disabled(model.bulkInFlight)
                .help(ArrivalsReviewCopy.addSelectedHelp)
                Button(tokens.chromeLabel(ArrivalsReviewCopy.dismissSelectedLabel(picked))) {
                    holdsKeys = true
                    Task { await model.dismissSelected(book: structure.reading) }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .ordinary))
                .lineLimit(1)
                .fixedSize()
                .disabled(model.bulkInFlight)
                .help(ArrivalsReviewCopy.dismissSelectedHelp)
            } else if ArrivalsLineFace.isShown(model.door) {
                Text(tokens.chromeLabel(ArrivalsReviewCopy.keysHint))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            Spacer(minLength: 12)
            // The quiet receipt's home while the review covers the bar or
            // the page foot that would have hosted it (one rule —
            // `BookNoteBox.quietReceiptHome`).
            if hostsQuietReceipt {
                QuietReceiptLine(status: model.session.status, tokens: tokens)
            }
            Button(tokens.chromeLabel(ArrivalsReviewCopy.doneVerb)) { onDone() }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .ordinary))
                .lineLimit(1)
                .fixedSize()
                .help(ArrivalsReviewCopy.doneHelp)
        }
        .frame(maxWidth: Self.measure)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(tokens.room)
    }

    private func verb(_ id: CapabilityID) -> String { CapabilityRegistry.capability(id).verb }

    // MARK: The keys (her ruled keyboard — `ArrivalsKey` decides)

    private func handle(_ press: KeyPress) -> KeyPress.Result {
        let key: ArrivalsKey.Key
        switch press.key {
        case .upArrow: key = .up
        case .downArrow: key = .down
        case .return: key = .returnKey
        case .delete: key = .delete
        case .escape: key = .escape
        default: return .ignored
        }
        // A held arrow keeps walking; a held ⏎ / ⌫ / esc acts ONCE (a held
        // ⌫ must never sweep the listing row by row).
        if press.phase == .repeat {
            guard key == .up || key == .down else { return .handled }
        }
        guard let act = ArrivalsKey.act(
            for: key, shift: press.modifiers.contains(.shift),
            command: press.modifiers.contains(.command),
            option: press.modifiers.contains(.option),
            control: press.modifiers.contains(.control))
        else { return .ignored }
        switch act {
        case .walk(let direction, let extend):
            model.walk(direction, extend: extend)
        case .add:
            Task { await model.addKeyTargets(book: structure.reading, chaptered: structure.chaptersActive) }
        case .dismiss:
            Task { await model.dismissKeyTargets(book: structure.reading) }
        case .done:
            onDone()
        }
        return .handled
    }

    #if DEBUG
    private func record() {
        let picked = model.selection.count
        var doors: [String] = []
        if ArrivalsLineFace.isShown(model.door) {
            doors += [verb(.addAllArrivals), verb(.dismissAllArrivals)]
        }
        if picked > 0 {
            doors += [ArrivalsReviewCopy.addSelectedLabel(picked), ArrivalsReviewCopy.dismissSelectedLabel(picked)]
        }
        doors.append(ArrivalsReviewCopy.doneVerb)
        ArrivalsReviewProbe.record(
            model.readingID, owner: probeOwner,
            header: ArrivalsCopy.header(count: model.door.count), doors: doors,
            picked: model.selection.picked, walked: model.selection.walked,
            empty: !ArrivalsLineFace.isShown(model.door))
    }
    #endif
}

#if DEBUG
/// **WHAT THE MOUNTED REVIEW DREW** (the `ArrivalsDoorProbe` pattern — a
/// hosted SwiftUI tree exposes no accessibility children in the test host):
/// its header words, the doors it drew in order, the pick and the walked row,
/// and whether it drew the calm empty answer. Owned per review instance.
/// DEBUG only.
@MainActor
enum ArrivalsReviewProbe {
    struct Drawn: Equatable {
        var owner: UUID
        var header: String
        var doors: [String]
        var picked: Set<String>
        var walked: String?
        var empty: Bool
    }

    private(set) static var drawn: [String: Drawn] = [:]

    static func reset() { drawn = [:] }

    static func record(
        _ readingID: String, owner: UUID, header: String, doors: [String],
        picked: Set<String>, walked: String?, empty: Bool
    ) {
        drawn[readingID] = Drawn(
            owner: owner, header: header, doors: doors, picked: picked, walked: walked, empty: empty)
    }

    static func forget(_ readingID: String, owner: UUID) {
        guard drawn[readingID]?.owner == owner else { return }
        drawn[readingID] = nil
    }
}
#endif
