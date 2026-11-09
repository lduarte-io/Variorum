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
    /// One board's record of one block's face, with the order it was written
    /// in (so a session-wide read can name the latest).
    private struct Entry {
        var face: BoardCommentFace
        var stamp: Int
    }

    /// scope → blockID → the BOARD that drew it (its mount token) → its face.
    ///
    /// **Attributed per board (VX-770 batch 2's reconciliation).** Keyed by
    /// the session alone, a record outlived the board that wrote it whenever
    /// that board's views never disappeared — a window closed with its
    /// hosting view still alive runs no `onDisappear` — and a later board of
    /// the same session then read the leftover as its own (the guard's red at
    /// the deletion arm, both trees). Each board root now publishes a mount
    /// token (`boardCommentFaceMount`), and a pin that mounts more than one
    /// board names the one it asks about.
    private static var worlds: [String: [String: [String: Entry]]] = [:]
    private static var writes = 0

    static func record(
        _ face: BoardCommentFace, blockID: String, mount: String, in scope: String
    ) {
        writes += 1
        worlds[scope, default: [:]][blockID, default: [:]][mount] = Entry(face: face, stamp: writes)
    }

    static func forget(blockID: String, mount: String, in scope: String) {
        worlds[scope]?[blockID]?[mount] = nil
        if worlds[scope]?[blockID]?.isEmpty == true { worlds[scope]?[blockID] = nil }
    }

    /// **A board's mount token** — the identity of the model the board root
    /// holds (`TakesBoardView`'s `TakesViewModel`, `CompareBoardView`'s
    /// `CompareViewModel`), which a pin holds too. Stable while the model is
    /// alive; a pin keeps its models alive while it reads (an object's
    /// identity can be reused only after it is gone).
    nonisolated static func mountToken(of board: AnyObject) -> String {
        "mount-\(UInt(bitPattern: ObjectIdentifier(board).hashValue))"
    }

    /// A pin's OWN boards — every read is this session's mounts; with a
    /// `mount`, ONE board's.
    @MainActor
    struct Reader {
        let scope: String
        /// nil: any board of the session (the latest record written) — honest
        /// while one board is up; a pin that mounts two names the one it means.
        let mount: String?

        var faces: [String: BoardCommentFace] {
            var result: [String: BoardCommentFace] = [:]
            for blockID in (BoardCommentFaceOracle.worlds[scope] ?? [:]).keys {
                if let face = face(blockID) { result[blockID] = face }
            }
            return result
        }

        func face(_ blockID: String) -> BoardCommentFace? {
            guard let boards = BoardCommentFaceOracle.worlds[scope]?[blockID] else { return nil }
            if let mount { return boards[mount]?.face }
            return boards.values.max { $0.stamp < $1.stamp }?.face
        }

        /// **VX-793 — is this block's comments panel OPEN on its gutter face?**
        /// (written by the face host while it can present the panel; erased
        /// when it leaves.) nil board: any of the session's boards.
        func panelOpen(_ blockID: String) -> Bool {
            guard let boards = BoardCommentFaceOracle.panels[scope]?[blockID] else { return false }
            if let mount { return boards[mount] == true }
            return boards.values.contains(true)
        }

        /// Clears this scope only (the 18d ladder's MINOR-2 lesson) — every
        /// board's records in it.
        func reset() {
            BoardCommentFaceOracle.worlds[scope] = nil
            BoardCommentFaceOracle.panels[scope] = nil
        }
    }

    /// scope → blockID → board → whether the face host shows the panel (VX-793).
    private static var panels: [String: [String: [String: Bool]]] = [:]

    static func recordPanel(open: Bool, blockID: String, mount: String, in scope: String) {
        panels[scope, default: [:]][blockID, default: [:]][mount] = open
    }

    static func forgetPanel(blockID: String, mount: String, in scope: String) {
        panels[scope]?[blockID]?[mount] = nil
        if panels[scope]?[blockID]?.isEmpty == true { panels[scope]?[blockID] = nil }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope, mount: nil) }

    /// One board's records — the board whose model is `board`.
    static func reader(_ scope: String, board: AnyObject) -> Reader {
        Reader(scope: scope, mount: mountToken(of: board))
    }
}

/// The board a face belongs to, as its root publishes it ("unmounted" for a
/// face drawn outside any board root).
struct BoardCommentFaceMountKey: EnvironmentKey {
    static let defaultValue = "unmounted"
}

extension EnvironmentValues {
    var boardCommentFaceMount: String {
        get { self[BoardCommentFaceMountKey.self] }
        set { self[BoardCommentFaceMountKey.self] = newValue }
    }
}

/// The record, as a modifier: written on appear and on every change of what
/// the face shows, erased on disappear — so the table holds what is DRAWN, by
/// the board that drew it.
private struct BoardCommentFaceRecord: ViewModifier {
    let blockID: String
    let face: BoardCommentFace
    @Environment(\.debugProbeScope) private var scope
    @Environment(\.boardCommentFaceMount) private var mount

    func body(content: Content) -> some View {
        content
            .onAppear {
                BoardCommentFaceOracle.record(face, blockID: blockID, mount: mount, in: scope)
            }
            .onChange(of: face) { _, now in
                BoardCommentFaceOracle.record(now, blockID: blockID, mount: mount, in: scope)
            }
            .onDisappear {
                BoardCommentFaceOracle.forget(blockID: blockID, mount: mount, in: scope)
            }
    }
}

/// VX-793's record: whether the face host shows the block's panel — written
/// on appear and on every change, erased on disappear.
private struct BoardCommentPanelRecord: ViewModifier {
    let blockID: String
    let open: Bool
    @Environment(\.debugProbeScope) private var scope
    @Environment(\.boardCommentFaceMount) private var mount

    func body(content: Content) -> some View {
        content
            .onAppear {
                BoardCommentFaceOracle.recordPanel(open: open, blockID: blockID, mount: mount, in: scope)
            }
            .onChange(of: open) { _, now in
                BoardCommentFaceOracle.recordPanel(open: now, blockID: blockID, mount: mount, in: scope)
            }
            .onDisappear {
                BoardCommentFaceOracle.forgetPanel(blockID: blockID, mount: mount, in: scope)
            }
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

    /// VX-793's DEBUG write: this view hosts `blockID`'s comments panel, open
    /// or not. A no-op outside DEBUG.
    @ViewBuilder
    func recordsBoardCommentPanel(blockID: String, open: Bool) -> some View {
        #if DEBUG
        self.modifier(BoardCommentPanelRecord(blockID: blockID, open: open))
        #else
        self
        #endif
    }

    /// Marks this subtree as ONE board's for the face oracle — applied at a
    /// board root beside `debugProbeScope`, with the model the board holds. A
    /// no-op outside DEBUG.
    @ViewBuilder
    func boardCommentFaceMount(_ board: AnyObject) -> some View {
        #if DEBUG
        self.environment(\.boardCommentFaceMount, BoardCommentFaceOracle.mountToken(of: board))
        #else
        self
        #endif
    }
}
