//
//  TakesFindBar.swift
//  Variorum
//
//  18l-c UNIT U7 — the Takes board's FIND BAR (the design brief's decision 1:
//  *"⌘F in Takes opens a find bar in the shipped bar's visual grammar (field ·
//  "N of M" count · next/prev with ⏎/⇧⏎ and ⌘G/⇧⌘G · Esc closes, focus
//  returns to the board, her place kept). No replace field."*). The Write
//  bar is AppKit's `NSTextFinder`, which a board of panes has no text view to
//  host — so this is the board's own bar, in the app's chrome vocabulary
//  (`Theme/VoiceControls.swift`), reading every word from the registry or
//  `TakesFindCopy`. Rendering and gestures only: every rule is the
//  controller's (`TakesFindController`).
//

import AppKit
import SwiftUI

struct TakesFindBar: View {
    let find: TakesFindController
    let tokens: VoiceTokens
    @State private var text = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(tokens.chromeLabel("find"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            TextField(TakesFindCopy.fieldPrompt, text: $text)
                .textFieldStyle(.plain)
                .font(tokens.small)
                .focused($fieldFocused)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(tokens.line, lineWidth: 1))
                .frame(maxWidth: 300)
                // ⏎ steps forward, ⇧⏎ back — the Write bar's keys. The field
                // KEEPS the keyboard, so ⏎ keeps stepping (decision 1).
                .onSubmit {
                    if NSEvent.modifierFlags.contains(.shift) { find.previous() } else { find.next() }
                }
                // Esc closes; the keyboard goes back to the live take.
                .onExitCommand { find.close() }
                .help(TakesFindCopy.fieldPrompt)
            Text(tokens.chromeLabel(find.countFace))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .monospacedDigit()
                .lineLimit(1)
            Button("◀") { find.previous() }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .disabled(find.matches.isEmpty)
                .help(Self.previousHelp)
            Button("▶") { find.next() }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .disabled(find.matches.isEmpty)
                .help(Self.nextHelp)
            // Decision 3 — her ruling's toggle, default ON (the chip grammar
            // the wash chip speaks: its state in its own words).
            VoicedChip(
                tokens: tokens, text: Self.scopeChipText(on: find.chosenOnly),
                on: find.chosenOnly
            ) { find.toggleScope() }
                .help(Self.scopeHelp)
            Spacer(minLength: 0)
            Button(tokens.chromeLabel("done")) { find.close() }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Close the find bar (Esc) — back to the take you're in")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 4)
        .background(tokens.wash)
        .onAppear {
            text = find.query
            fieldFocused = true
        }
        .onChange(of: text) { _, new in find.setQuery(new) }
        .onChange(of: fieldFocused, initial: true) { _, focused in find.fieldFocusChanged(focused) }
        // ⌘F while the bar is open takes the field again.
        .onChange(of: find.fieldFocusRequests) { _, _ in fieldFocused = true }
        .recordTakesFindBar(
            count: find.countFace, chosenOnly: find.chosenOnly,
            chip: Self.scopeChipText(on: find.chosenOnly),
            currentOffScope: find.currentMatch.map { !$0.onShownTake } ?? false)
    }

    // MARK: - The bar's words (registry-sourced where the registry speaks)

    static var nextHelp: String {
        CapabilityRegistry.capability(.findNext).menuTitle() + " — or ⏎ in the field"
    }

    static var previousHelp: String {
        CapabilityRegistry.capability(.findPrevious).menuTitle() + " — or ⇧⏎ in the field"
    }

    static func scopeChipText(on: Bool) -> String {
        TakesFindCopy.scopeChip + (on ? ": on" : ": off")
    }

    static let scopeHelp = "On: each block's chosen take only. Off: every take on the "
        + "board — a block whose other takes match says so, and stepping to one opens its fan."
}

// MARK: - The off-scope marker (R-18l-10's first half)

/// With "only chosen takes" OFF, a block whose OTHER takes hold matches says
/// so — in the margin beside its fan badge (the badge vocabulary, VoiceTokens
/// only), never over the prose (her R-Q2: nothing is drawn over a take's
/// pane). Nothing expands until she steps there.
struct TakesFindOffScopeMarker: View {
    let blockID: String
    let count: Int
    let tokens: VoiceTokens

    var body: some View {
        Text(tokens.chromeLabel(TakesFindCopy.offScopeMarker(count)))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            // P-8: a chrome `fixedSize` text always carries a `lineLimit`.
            .lineLimit(1)
            .fixedSize()
            .help("Matches on takes this block isn't showing — step to one (⌘G) to open its fan")
            .recordTakesFindMarker(blockID: blockID, words: TakesFindCopy.offScopeMarker(count))
    }
}

// MARK: - DEBUG oracles (what the bar and the markers actually rendered)

#if DEBUG
/// A hosted board builds no accessibility tree in the test host (measured at
/// 17p batch a), and SwiftUI `Text` is drawn rather than mounted — so the bar
/// and the markers DECLARE what they render, and the face pins read the
/// declaration (the `TakesCellChrome` pattern). Not DEBUG-scoped per session:
/// the find is one board at a time in every pin that reads it, and each pin
/// resets first.
@MainActor
enum TakesFindFaces {
    struct Bar: Equatable {
        var count: String
        var chosenOnly: Bool
        var chip: String
        /// The current match sits on a take its block is not showing.
        var currentOffScope = false
    }

    static var bar: Bar?
    static var markers: [String: String] = [:]
    /// Where each marker is drawn, in window space (SwiftUI's `.global`) — the
    /// pin that holds it OUT of the prose (her R-Q2) reads the x.
    static var markerFrames: [String: CGRect] = [:]

    static func reset() {
        bar = nil
        markers = [:]
        markerFrames = [:]
    }
}
#endif

extension View {
    @ViewBuilder
    func recordTakesFindBar(
        count: String, chosenOnly: Bool, chip: String, currentOffScope: Bool
    ) -> some View {
        #if DEBUG
        self.onChange(
            of: TakesFindFacesKey(
                count: count, chosenOnly: chosenOnly, chip: chip, currentOffScope: currentOffScope),
            initial: true
        ) { _, face in
            TakesFindFaces.bar = .init(
                count: face.count, chosenOnly: face.chosenOnly, chip: face.chip,
                currentOffScope: face.currentOffScope)
        }
        .onDisappear { TakesFindFaces.bar = nil }
        #else
        self
        #endif
    }

    @ViewBuilder
    func recordTakesFindMarker(blockID: String, words: String) -> some View {
        #if DEBUG
        self.onChange(of: words, initial: true) { _, words in
            TakesFindFaces.markers[blockID] = words
        }
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
            TakesFindFaces.markerFrames[blockID] = frame
        }
        .onDisappear {
            TakesFindFaces.markers[blockID] = nil
            TakesFindFaces.markerFrames[blockID] = nil
        }
        #else
        self
        #endif
    }
}

/// The bar oracle's change key (Equatable, so the record moves only when a
/// rendered word does).
private struct TakesFindFacesKey: Equatable {
    let count: String
    let chosenOnly: Bool
    let chip: String
    let currentOffScope: Bool
}
