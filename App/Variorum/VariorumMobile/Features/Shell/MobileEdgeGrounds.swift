//
//  MobileEdgeGrounds.swift
//  VariorumMobile
//
//  VM-47 (the walk's W-A1, REDONE) — **THE SCREEN'S TWO EDGE STRIPS, PAINTED
//  BY THE SHELL.** The phone's band (`MobileShellView.body`) is laid out in the
//  safe area and clipped there (`.clipped()`, main's line): nothing inside it —
//  her words, a scroll view's content, the editor — ever draws past its top or
//  its bottom. That clip is what the editor's keyboard reveal answers to (the
//  walk's W-E4: with the band's clip opened up and down, a mid-note tap no
//  longer moved the note above the rising keyboard), it keeps her prose from
//  showing through the keyboard bar's glass (W-E3), and it keeps a scrolled
//  page's words out from under the status bar (W-F1).
//
//  The strips beyond the band — the status bar's above, the home indicator's
//  below, and with a keyboard up everything behind the keyboard and its bar —
//  are therefore not any page's: the SHELL paints them, in a layer behind the
//  band (`MobileEdgeGroundsLayer`), so they show the page's ground and never the
//  window's bare white or black (W-A1: "the grounds stop at the safe area").
//
//  WHO DECIDES THE COLOURS. Each page DECLARES its two edge grounds
//  (`.mobileEdgeGrounds(top:bottom:)` in its own body — a page knows its
//  ground; the shell never guesses one from the route). The declaration rides
//  an environment board the shell holds, not a SwiftUI preference: a
//  preference's reduce sees every mounted page of all three stacks — both band
//  neighbours, and a root still mounted under a pushed screen — with no order
//  SwiftUI documents between a stack's root and its destinations, so "the page
//  showing" cannot be read from it. The board keeps the order itself.
//
//  WHICH DECLARATION WINS (`MobileEdgeGroundsBoard.showing`):
//  · only the CURRENT band page's stack counts (the shell's `tab`) — a band
//    neighbour, one width away, never colours a strip;
//  · while that stack stands at its root, the root's declaration;
//  · otherwise the NEWEST pushed screen still on the stack (a push declares
//    from its first appearance; a pop withdraws at its disappearance, and the
//    path's emptying hands the strips back to the root at once); until a
//    freshly pushed screen has declared, the root's still stands;
//  · nothing declared: the room (the shell's fallback).
//  And the BOTTOM strip is the bar's own ground — the room — wherever a bar
//  stands at the foot (`barGround`): the bar draws its room down to the band's
//  edge and the painted strip continues it, one colour, so there is no seam and
//  only the bar's own hairline.
//
//  DURING A TRANSITION the two strips are one colour each across the width —
//  never a neighbour's, never the window's, never a page no longer on the
//  stack; while a push or a pop slides, they wear the arriving page's (a push)
//  or the root's (a pop to the root) from its first frame. A band swipe moves
//  between two roots, and every root declares the room at both edges.
//
//  NOTHING HERE MOVES A FRAME: the layer is a `.background` of the band (a
//  background never changes the size of the view it backs), it takes no touch
//  and no accessibility, and the declarations are appear/disappear hooks.
//

import SwiftUI

/// A page's two edge grounds: the colour the status bar's strip shows above
/// it, and the colour the home indicator's strip (and, with a keyboard up,
/// everything behind the keyboard) shows below it.
struct MobileEdgeGrounds: Equatable {
    var top: Color
    var bottom: Color
}

/// **The shell's board of edge declarations** — one per page on screen or
/// under one, per band stack, in the order they appeared.
@Observable
final class MobileEdgeGroundsBoard {
    /// One page's declaration.
    struct Declaration: Equatable {
        let id: Int
        /// The band page (its stack) the declaring page lives on.
        let stack: MobileTab
        /// Whether the declaring page is that stack's ROOT.
        let atRoot: Bool
        var grounds: MobileEdgeGrounds
    }

    private(set) var declarations: [Declaration] = []
    @ObservationIgnored private var nextID = 0

    /// A page appeared: its declaration joins the board, newest last.
    func declare(_ grounds: MobileEdgeGrounds, stack: MobileTab, atRoot: Bool) -> Int {
        nextID += 1
        declarations.append(Declaration(id: nextID, stack: stack, atRoot: atRoot, grounds: grounds))
        return nextID
    }

    /// A page's grounds changed while it stands (the Versions screen's listing
    /// and reader; a voice or palette landing).
    func revise(_ id: Int, to grounds: MobileEdgeGrounds) {
        guard let index = declarations.firstIndex(where: { $0.id == id }),
              declarations[index].grounds != grounds
        else { return }
        declarations[index].grounds = grounds
    }

    /// A page disappeared: its declaration leaves the board.
    func withdraw(_ id: Int) {
        declarations.removeAll { $0.id == id }
    }

    /// The grounds the strips show for this stack now.
    func grounds(of stack: MobileTab, atRoot: Bool) -> MobileEdgeGrounds? {
        Self.showing(declarations, stack: stack, atRoot: atRoot)
    }

    /// **The rule** (pure — the header's "which declaration wins"): the
    /// stack's root while it stands at its root; else its newest pushed
    /// screen, and the root's until a pushed screen has declared.
    static func showing(
        _ declarations: [Declaration], stack: MobileTab, atRoot: Bool
    ) -> MobileEdgeGrounds? {
        let mine = declarations.filter { $0.stack == stack }
        if !atRoot, let pushed = mine.last(where: { !$0.atRoot }) {
            return pushed.grounds
        }
        return mine.last(where: { $0.atRoot })?.grounds
    }
}

extension EnvironmentValues {
    /// The shell's board (nil outside a shell — a page's declaration is then
    /// a no-op: harness mounts and previews paint nothing beyond themselves).
    @Entry var mobileEdgeGroundsBoard: MobileEdgeGroundsBoard? = nil
    /// The band page — the stack — a view lives on (set per page by the shell).
    @Entry var mobileEdgeGroundsStack: MobileTab? = nil
    /// Whether a view is its stack's ROOT (set by the shell on the root and,
    /// explicitly false, on every pushed destination).
    @Entry var mobileEdgeGroundsAtRoot: Bool = false
}

extension View {
    /// **This page's two edge grounds**, declared to the shell for the strips
    /// beyond the band (see the file's header). A no-op outside a shell.
    func mobileEdgeGrounds(top: Color, bottom: Color) -> some View {
        modifier(MobileEdgeGroundsDeclaring(grounds: MobileEdgeGrounds(top: top, bottom: bottom)))
    }
}

/// The declaration's lifetime is the page's appearance: declared when it
/// appears (once — a repeated appear revises, never reorders), revised when
/// its grounds change, withdrawn when it disappears.
private struct MobileEdgeGroundsDeclaring: ViewModifier {
    let grounds: MobileEdgeGrounds
    @Environment(\.mobileEdgeGroundsBoard) private var board
    @Environment(\.mobileEdgeGroundsStack) private var stack
    @Environment(\.mobileEdgeGroundsAtRoot) private var atRoot
    @State private var declaration: Int?

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard let board, let stack else { return }
                if let declaration {
                    board.revise(declaration, to: grounds)
                } else {
                    declaration = board.declare(grounds, stack: stack, atRoot: atRoot)
                }
            }
            .onDisappear {
                if let declaration { board?.withdraw(declaration) }
                declaration = nil
            }
            .onChange(of: grounds) { _, new in
                if let declaration { board?.revise(declaration, to: new) }
            }
    }
}

/// **The painted strips** — the band's background, behind every page: its top
/// half the showing page's top ground carried up under the status bar, its
/// bottom half the bottom ground carried down past the home indicator and,
/// with a keyboard up, behind the keyboard and its bar. Only what lies beyond
/// the band ever shows; the band's own pages cover the rest. The halves split
/// at the band's middle, which lies inside the band at every keyboard height a
/// portrait phone shows.
struct MobileEdgeGroundsLayer: View {
    let board: MobileEdgeGroundsBoard
    /// The current band page.
    let stack: MobileTab
    /// Whether that page's stack stands at its root.
    let atRoot: Bool
    /// The bar's ground while a bar stands at the foot (nil: no bar on screen).
    let barGround: Color?
    /// Nothing declared yet: the room.
    let fallback: Color

    var body: some View {
        let declared = board.grounds(of: stack, atRoot: atRoot)
        VStack(spacing: 0) {
            (declared?.top ?? fallback)
                .ignoresSafeArea(.all, edges: .top)
            (barGround ?? declared?.bottom ?? fallback)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
