//
//  BoardCommentFaceOracle.swift
//  Variorum (Mac)
//
//  **VX-770 batch 2 — the board surfaces' comment-face ORACLE** (VX-730,
//  VX-731, VX-728: the gutter contract on the Takes and Compare boards).
//
//  What a board's comment face SHOWS for a block, written by the face itself
//  at the moment it is drawn and erased the moment it leaves the board — so a
//  pin asks the same question of every tree: is there a face for this block,
//  is it a card or a one-line mark, which comments does it carry, and are
//  their lines capped? The Takes board's pre-fix face is SwiftUI text (no
//  NSView a pin can find, and in-process SwiftUI builds no accessibility
//  nodes — `ComposedSliders`' measured note), so without a report of its own
//  a pin could only say "no AppKit card here", which is true of a face that
//  drew fine and of one that drew nothing. This oracle tells the two apart.
//
//  Scoped by the mounting session (`DebugProbeScope.swift` — suites run in
//  parallel; a process-global table would let one suite's board answer
//  another's pin). Behaviour-neutral: DEBUG-only storage, a no-op modifier in
//  Release.
//

import SwiftUI

/// What one comment face shows (the oracle's row). Plain data, so it exists
/// in every configuration; only the TABLE is DEBUG.
nonisolated struct BoardCommentFace: Equatable, Sendable {
    enum Kind: String, Sendable {
        /// The margin card — the comments as text.
        case card
        /// The narrow-gutter count badge (Write's ladder's second rung).
        case badge
        /// The Takes board's pre-fix compact `//` chip.
        case chip
    }

    var kind: Kind
    /// The comment texts the face draws as entries, in order. Empty for a
    /// one-line mark.
    var entries: [String]
    /// The most lines any entry may draw — nil means uncapped (each comment
    /// wraps whole, as Write's card draws it).
    var lineCap: Int?
    /// The words a one-line face prints (a badge's count, a chip's mark), or a
    /// card's trailing "+N more"; nil where it prints none.
    var label: String?
}

#if DEBUG
@MainActor
enum BoardCommentFaceOracle {
    /// scope → blockID → the face drawn for it now.
    private static var worlds: [String: [String: BoardCommentFace]] = [:]

    static func record(_ face: BoardCommentFace, blockID: String, in scope: String) {
        worlds[scope, default: [:]][blockID] = face
    }

    static func forget(blockID: String, in scope: String) {
        worlds[scope]?[blockID] = nil
    }

    /// A pin's OWN boards — every read is this session's mounts.
    @MainActor
    struct Reader {
        let scope: String

        var faces: [String: BoardCommentFace] { BoardCommentFaceOracle.worlds[scope] ?? [:] }

        func face(_ blockID: String) -> BoardCommentFace? { faces[blockID] }

        /// Clears this scope only (the 18d ladder's MINOR-2 lesson).
        func reset() { BoardCommentFaceOracle.worlds[scope] = nil }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope) }
}

/// The record, as a modifier: written on appear and on every change of what
/// the face shows, erased on disappear — so the table holds what is DRAWN.
private struct BoardCommentFaceRecord: ViewModifier {
    let blockID: String
    let face: BoardCommentFace
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content
            .onAppear { BoardCommentFaceOracle.record(face, blockID: blockID, in: scope) }
            .onChange(of: face) { _, now in
                BoardCommentFaceOracle.record(now, blockID: blockID, in: scope)
            }
            .onDisappear { BoardCommentFaceOracle.forget(blockID: blockID, in: scope) }
    }
}
#endif

extension View {
    /// The DEBUG oracle's write: this view IS the comment face for `blockID`
    /// and shows `face`. A no-op outside DEBUG.
    @ViewBuilder
    func recordsBoardCommentFace(blockID: String, _ face: BoardCommentFace) -> some View {
        #if DEBUG
        self.modifier(BoardCommentFaceRecord(blockID: blockID, face: face))
        #else
        self
        #endif
    }
}
