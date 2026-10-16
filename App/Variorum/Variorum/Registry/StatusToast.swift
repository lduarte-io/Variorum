//
//  StatusToast.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (AD-14): the ONE status presentation — a quiet
//  voiced toast at the shell's bottom, mode- and surface-independent.
//  Refusals are READABLE (R93: wrapping, selectable, never truncated to
//  nothing) and the line limit is LOAD-BEARING (the b6dae25 chrome class:
//  an unlimited fixedSize text never sits in non-scrolling window chrome).
//
//  VX-121 (the VX-283 run, U3 — PROVISIONAL P-U3-1, the orchestrator's
//  ruling): **WHERE the toast sits is a RULE its host reads**, never a
//  per-toast offset. The shell's toast rested 46 pt above the pane row's foot
//  — squarely ON the Bookcase's quick-entry box (13s-b's foot: the box
//  directly above the bottom bar), so ANY toast over the Bookcase covered the
//  capture row (13n-a W7's capture). A band that must stay clear says so
//  (`statusToastKeepClear()` — the quick-entry bar does, wherever it is
//  drawn), and the host lifts the toast ABOVE every such band, at the same
//  horizontal centre (`StatusToastPlacement`, pure).
//

import SwiftUI

/// **THE TOAST'S PLACEMENT RULE** (VX-121). Pure, so the pin reads exactly
/// what the host does.
nonisolated enum StatusToastPlacement {
    /// The shell's resting inset — the 46 pt the toast has always sat above
    /// the pane row's foot (13b 1b, AD-14), kept wherever nothing asks for
    /// clearance.
    static let shellRestingInset: CGFloat = 46
    /// The air between a lifted toast and the top of the band it clears.
    static let clearance: CGFloat = 8

    /// The toast's bottom inset in a host `hostHeight` tall, given the TOPS
    /// (in the host's own space, y down) of every band it must keep clear of:
    /// the resting inset, or — when a band reaches higher — just above the
    /// highest band. Never lower than resting.
    static func bottomInset(
        hostHeight: CGFloat, keepClearTops: [CGFloat], resting: CGFloat = shellRestingInset
    ) -> CGFloat {
        guard let highest = keepClearTops.min() else { return resting }
        return max(resting, hostHeight - highest + clearance)
    }
}

/// The bands the toast keeps clear of, as the host's subtree reports them.
struct StatusToastKeepClearKey: PreferenceKey {
    static let defaultValue: [Anchor<CGRect>] = []
    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value += nextValue()
    }
}

extension View {
    /// **A band the status toast never covers** (VX-121) — the quick-entry
    /// bar marks itself, so the Bookcase's box and the Library's are both
    /// kept clear by construction.
    func statusToastKeepClear() -> some View {
        #if DEBUG
        anchorPreference(key: StatusToastKeepClearKey.self, value: .bounds) { [$0] }
            .modifier(StatusToastKeepClearProbe())
        #else
        anchorPreference(key: StatusToastKeepClearKey.self, value: .bounds) { [$0] }
        #endif
    }

    /// **The ONE status presentation's host** (13b 1b, AD-14 — every
    /// transient outcome renders here), placed by `StatusToastPlacement`
    /// over this view's own bands. `resting` is the host's inset when no
    /// band asks for clearance.
    func statusToastHost(
        _ status: StatusCenter, tokens: VoiceTokens,
        resting: CGFloat = StatusToastPlacement.shellRestingInset
    ) -> some View {
        overlayPreferenceValue(StatusToastKeepClearKey.self) { bands in
            StatusToastLayer(status: status, tokens: tokens, resting: resting, bands: bands)
        }
    }
}

/// The host's layer: the toast, when one is showing, lifted by the rule. Its
/// own view so only IT re-renders as toasts come and go.
private struct StatusToastLayer: View {
    let status: StatusCenter
    let tokens: VoiceTokens
    let resting: CGFloat
    let bands: [Anchor<CGRect>]

    var body: some View {
        if let item = status.current {
            GeometryReader { proxy in
                StatusToast(item: item, tokens: tokens, onDismiss: { status.clear() })
                    .padding(.bottom, StatusToastPlacement.bottomInset(
                        hostHeight: proxy.size.height,
                        keepClearTops: bands.map { proxy[$0].minY },
                        resting: resting))
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
            }
        }
    }
}

struct StatusToast: View {
    let item: StatusCenter.Item
    let tokens: VoiceTokens
    let onDismiss: () -> Void
    #if DEBUG
    /// This toast's name in the DEBUG oracle (the 18k C4 rule).
    @State private var oracleOwner = UUID()
    #endif

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(item.text)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(4)  // LOAD-BEARING (b6dae25 class)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            // 13f batch 5 (W23 / her round-10 item 4): a note that names a
            // door can BE the door. The button dismisses as it acts — an
            // offer that stays on screen after it is taken reads as a
            // question that was never answered.
            // 13r U3-A (R-13r-12): an offer's second door — the decline
            // (Not Now), quieter than the act and before it, the platform's
            // order for a cancel beside a default. It dismisses as it acts.
            if let secondary = item.secondary {
                Button(secondary.label) {
                    onDismiss()
                    secondary.perform()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .lineLimit(1)
                .fixedSize()
            }
            if let action = item.action {
                Button(action.label) {
                    onDismiss()
                    action.perform()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
                // states its own line policy, so its IDEAL width can never be a
                // wrapped one (the b6dae25 class's window-sizing hazard).
                // The toast's own message above is deliberately UNLIMITED (its
                // `fixedSize(h:false,v:true)` wraps a sentence); the ACTION is a
                // verb and takes one line.
                .lineLimit(1)
                .fixedSize()
            }
            Button("✕", action: onDismiss)
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .help("Dismiss")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(tokens.card)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
        #if DEBUG
        // VX-121: where the CARD sits, in its window (`.global`) — the
        // placement pin reads it against the quick-entry box's own frame.
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            StatusToastOracle.record($0, owner: oracleOwner)
        }
        .onDisappear { StatusToastOracle.release(owner: oracleOwner) }
        #endif
        .shadow(color: .black.opacity(0.18), radius: 8, y: 2)
        .frame(maxWidth: 560)
    }
}

#if DEBUG
/// **VX-121 — where the toast's card last sat, and where every kept-clear
/// band sits** (`.global` both), owner-keyed by the view that drew each (the
/// 18k C4 rule: a teardown clears only its own). The placement pin reads the
/// card against the bands.
@MainActor
enum StatusToastOracle {
    private static var slot = OwnedSlot<CGRect>()
    private static var bandFrames = OwnedRegistrations<UUID, CGRect>()

    static var frame: CGRect? { slot.value }

    /// Every kept-clear band standing now (the quick-entry bars on screen).
    static var bands: [CGRect] { Array(bandFrames.current.values) }

    static func record(_ frame: CGRect, owner: UUID) {
        slot.publish(frame, owner: owner)
    }

    static func release(owner: UUID) { slot.release(owner: owner) }

    static func recordBand(_ frame: CGRect, owner: UUID) {
        bandFrames.publish(frame, for: owner, owner: owner)
    }

    static func releaseBand(owner: UUID) { bandFrames.release(owner: owner) }

    /// A pin's door: start from empty.
    static func forget() {
        slot.forget()
        bandFrames.forgetAll()
    }
}

/// A kept-clear band's own report of where it sits (DEBUG only).
private struct StatusToastKeepClearProbe: ViewModifier {
    @State private var owner = UUID()

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                StatusToastOracle.recordBand($0, owner: owner)
            }
            .onDisappear { StatusToastOracle.releaseBand(owner: owner) }
    }
}
#endif
