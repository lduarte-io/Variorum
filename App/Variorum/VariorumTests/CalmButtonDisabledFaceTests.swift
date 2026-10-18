//
//  CalmButtonDisabledFaceTests.swift
//  VariorumTests
//
//  VX-194 (Part of VX-381) — `CalmButtonStyle` ignored the disabled state
//  app-wide (VX-179's O-U3-2): every `.disabled(true)` calm button rendered
//  pixel-for-pixel as a live one. Her ruling 2026-10-13 (QUESTIONS #217):
//  "fix it in the style".
//
//  THE MECHANISM (traced): the style's `makeBody` drew ink, border and paper
//  from its ROLE alone and dimmed only on `configuration.isPressed`; nothing
//  in it read the environment's `isEnabled`, which is the only signal
//  `.disabled` sets. So the face never changed.
//
//  THE ORACLE: the REAL style, mounted in an `NSHostingView` inside a window
//  that is never ordered in (parked off-display — the VX-179 offscreen-probe
//  rules), drawn through `cacheDisplay` and read pixel by pixel. Red on old:
//  the pre-fix style draws the enabled and the disabled button identically
//  (a scratch replay of the old body measured 0 differing pixels of 1,330
//  inked; the behavioural revert of the fix is the run record's evidence).
//

import AppKit
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("Calm buttons are honest when disabled (VX-194)")
struct CalmButtonDisabledFaceTests {
    static let size = NSSize(width: 260, height: 64)

    /// The four token sets the app renders in (both voices, both rooms).
    static let tokenSets: [(String, VoiceTokens)] = [
        ("terminal light", .terminalLight), ("terminal dark", .terminalDark),
        ("study light", .studyLight), ("study dark", .studyDark),
    ]
    static let roles: [(String, CalmButtonStyle.Role)] = [
        ("ordinary", .ordinary), ("primary", .primary), ("danger", .danger),
    ]

    /// Draws `content` on the voice's room and returns its pixels. The window
    /// is never ordered in and sits far off every display.
    static func render<V: View>(_ tokens: VoiceTokens, _ content: V) throws -> NSBitmapImageRep {
        let window = NSWindow(
            contentRect: NSRect(x: -24_000, y: -24_000, width: size.width, height: size.height),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.close() }
        let hosting = NSHostingView(rootView: AnyView(
            content
                .frame(width: size.width, height: size.height)
                .background(tokens.room)))
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        for _ in 0..<8 {
            hosting.layoutSubtreeIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        }
        let rep = try #require(hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds))
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        return rep
    }

    static func rgb(_ rep: NSBitmapImageRep, _ x: Int, _ y: Int) -> (Double, Double, Double) {
        guard let c = rep.colorAt(x: x, y: y)?.usingColorSpace(.sRGB) else { return (0, 0, 0) }
        return (Double(c.redComponent), Double(c.greenComponent), Double(c.blueComponent))
    }

    static func distance(_ a: (Double, Double, Double), _ b: (Double, Double, Double)) -> Double {
        abs(a.0 - b.0) + abs(a.1 - b.1) + abs(a.2 - b.2)
    }

    /// Pixels that differ between two renders of the same geometry.
    static func differing(_ a: NSBitmapImageRep, _ b: NSBitmapImageRep) -> Int {
        var count = 0
        for x in 0..<min(a.pixelsWide, b.pixelsWide) {
            for y in 0..<min(a.pixelsHigh, b.pixelsHigh)
            where distance(rgb(a, x, y), rgb(b, x, y)) > 0.02 {
                count += 1
            }
        }
        return count
    }

    /// The strongest ink in `columns` (pixel x range), as its distance from
    /// the room (the corner pixel) — the label's pull on the eye.
    static func strongestInk(_ rep: NSBitmapImageRep, columns: Range<Int>? = nil) -> Double {
        let room = rgb(rep, 0, 0)
        var strongest = 0.0
        for x in columns ?? 0..<rep.pixelsWide {
            for y in 0..<rep.pixelsHigh {
                strongest = max(strongest, distance(rgb(rep, x, y), room))
            }
        }
        return strongest
    }

    static func button(_ tokens: VoiceTokens, _ role: CalmButtonStyle.Role) -> some View {
        Button("merge blocks") {}
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: role))
    }

    // MARK: - Her report (RED ON OLD)

    /// A disabled calm button renders visibly distinct from the same button
    /// enabled — every role, both voices, both rooms — and its label pulls
    /// less: the strongest ink sits closer to the room than the live face's.
    @Test func aDisabledCalmButtonIsVisiblyDistinctAndQuieterInEveryVoiceAndRole() throws {
        for (voice, tokens) in Self.tokenSets {
            for (name, role) in Self.roles {
                let live = try Self.render(tokens, Self.button(tokens, role))
                let off = try Self.render(tokens, Self.button(tokens, role).disabled(true))
                let changed = Self.differing(live, off)
                #expect(changed > 200,
                        "(\(voice), \(name)) disabled must not draw as live — \(changed) pixels differ")
                let liveInk = Self.strongestInk(live)
                let offInk = Self.strongestInk(off)
                #expect(offInk < liveInk * 0.8,
                        "(\(voice), \(name)) the disabled label is quieter: \(offInk) vs live \(liveInk)")
            }
        }
    }

    /// The signal is the ENVIRONMENT, so a `.disabled` on a container above
    /// the button (the lobby rows, a whole bar) greys it exactly as on the
    /// button itself.
    @Test func aDisabledContainerGreysTheCalmButtonsInsideIt() throws {
        for (voice, tokens) in Self.tokenSets {
            let direct = try Self.render(tokens, Self.button(tokens, .primary).disabled(true))
            let viaContainer = try Self.render(
                tokens, HStack { Self.button(tokens, .primary) }.disabled(true))
            let live = try Self.render(tokens, Self.button(tokens, .primary))
            #expect(Self.differing(direct, viaContainer) == 0,
                    "(\(voice)) a container's .disabled draws the same face as the button's own")
            #expect(Self.differing(live, viaContainer) > 200,
                    "(\(voice)) …and that face is not the live one")
        }
    }

    // MARK: - R-VX381-A2: the ceremony footer's confirm (the one calm-button one-off)

    /// `CeremonySheetFooter`'s confirm carried its own `.opacity(canConfirm ?
    /// 1 : 0.45)` ON the calm style. With the style honest, that one-off would
    /// DIM TWICE. The fold: the confirm is `.disabled(!canConfirm)` and wears
    /// exactly the style's disabled face — its strongest ink matches a lone
    /// disabled primary calm button's. Red on old as well: the old footer's
    /// confirm was the full-strength primary at 0.45 opacity, the old lone
    /// "disabled" button the full-strength primary.
    @Test func theCeremonyConfirmWearsTheStylesDisabledFaceOnce() throws {
        for (voice, tokens) in Self.tokenSets {
            func footer(_ canConfirm: Bool) -> some View {
                CeremonySheetFooter(
                    tokens: tokens, blocker: nil, restingLine: "", confirmTitle: "Divide",
                    canConfirm: canConfirm, cancel: {}, confirm: {})
                    .padding(.horizontal, 8)
            }
            let open = try Self.render(tokens, footer(true))
            let shut = try Self.render(tokens, footer(false))
            // The confirm is the trailing control — the columns where the two
            // renders differ are its own.
            var columns: [Int] = []
            for x in 0..<open.pixelsWide
            where (0..<open.pixelsHigh).contains(where: {
                Self.distance(Self.rgb(open, x, $0), Self.rgb(shut, x, $0)) > 0.02
            }) {
                columns.append(x)
            }
            let first = try #require(columns.first, "(\(voice)) the confirm's face changes when it can't act")
            let last = try #require(columns.last)
            let footerInk = Self.strongestInk(shut, columns: first..<(last + 1))
            let lone = try Self.render(
                tokens,
                Button("Divide") {}
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .disabled(true))
            let loneInk = Self.strongestInk(lone)
            #expect(abs(footerInk - loneInk) < 0.08,
                    "(\(voice)) the footer's disabled confirm is the style's face, dimmed once: \(footerInk) vs \(loneInk)")
        }
    }
}
