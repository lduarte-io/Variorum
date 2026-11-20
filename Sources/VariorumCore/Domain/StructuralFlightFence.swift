import Foundation

/// **VM-2 — the keystroke fence around a structural flight** (the phone's
/// live editor; the record `notes/plans/fixes/vm-64-timing-and-lags.md`,
/// batch 2).
///
/// A structural door (divide, merge, extract, make block, the block deletes,
/// the cross-block compound, the structural undo and redo) flushes, then
/// SUSPENDS — the fan read, the operation on the runner, the settle's own
/// read — while the surface still shows the note as it was before the
/// operation. An edit that lands in that window is routed against the old
/// tiling, and its autosave records the WHOLE old block text; written after
/// the operation, that text resurrects a divided half, duplicates an
/// extracted span, or lands prose in a merge's released source. The Mac
/// closes the window in `runStructural`; this is the phone's rule as a pure
/// brain, so the face can be thin and the rule can be pinned without a
/// simulator.
///
/// **The window** runs from the moment a door raises its flight latch to the
/// moment the surface holds the store as the operation left it — usually the
/// door's own settle, occasionally later (a settle deferred behind an
/// in-flight mint, or a forced re-render still owed). Hence three phases:
/// `open`, `flying` (a latch is up), `settling` (the latch is down, the
/// surface not yet re-read).
///
/// **REFUSE AND SAY — why the phone does not defer and replay as the Mac
/// does.** The phone's keyboard asks the page's gate BEFORE it inserts a
/// key, and inserts only on a yes (her device's E1 trace: a gate consult
/// before every typed key, autocorrections included); a consult does not
/// promise an edit (the same trace counts several consults before one), so
/// a key cannot honestly be held at the gate — a held consult that never
/// became an edit would replay text she never typed. So while the fence is
/// up:
///   - **any edit the gate is asked about** — a typed key, ⌫, a paste, a
///     formatting act, an autocorrection — is REFUSED;
///   - **an edit that reaches the text with no gate consult** (the system's
///     own rewrites — dictation, a composition commit, a programmatic
///     replace) is WITHHELD: the page keeps its tiling coherent, nothing of it
///     is written toward the store, and the surface is re-read from the store
///     before the fence drops;
///   - anything refused or withheld leaves one debt: the fence's sentence is
///     said once, when it drops, so nothing leaves her page silently.
///
/// It holds no text, logs nothing and persists nothing.
public struct StructuralFlightFence: Equatable, Sendable {
    public enum Phase: Equatable, Sendable {
        /// No flight: every edit routes as it always has.
        case open
        /// A structural door holds its latch.
        case flying
        /// The latch is down but the surface does not yet hold the store as
        /// the operation left it.
        case settling
    }

    /// What a landing asks of the face.
    public enum Landing: Equatable, Sendable {
        /// Lower the fence now (`drain()`).
        case drain
        /// Keep the fence up and re-read the surface first; `surfaceSettled()`
        /// says when to drain.
        case awaitSettle
    }

    public private(set) var phase: Phase = .open
    /// Something was refused or withheld since the fence last dropped.
    public private(set) var owesSentence = false

    public init() {}

    /// Up while a flight holds its latch AND until its surface has settled.
    public var isUp: Bool { phase != .open }

    // MARK: The flight

    /// A door raised its latch. A flight that starts while the previous one
    /// is still settling simply takes over: its own landing settles both.
    public mutating func flightBegan() {
        phase = .flying
    }

    /// The last fencing latch dropped. `surfaceSettled` is the face's reading
    /// of `surfaceHoldsTheStore`; when the surface is not there yet the fence
    /// stays up, in `settling`, until the face says it is.
    public mutating func flightLanded(surfaceSettled: Bool) -> Landing {
        if surfaceSettled { return .drain }
        phase = .settling
        return .awaitSettle
    }

    /// A QUERY, asked once the face has re-read the surface and found it holds
    /// the store: is a drain owed now? True when the fence was settling; false
    /// when there was nothing to wait for. It changes nothing — the fence
    /// stays up until the drain actually runs.
    public func surfaceSettled() -> Bool {
        phase == .settling
    }

    /// **THE SETTLE RULE**: the surface holds the store as the operation left
    /// it exactly when no forced re-render and no deferred projection is still
    /// outstanding. A forced render is owed when a withheld edit put bytes on
    /// the page the store never saw (or a heal asked for one); a deferred
    /// projection means the door's own post-operation read was parked behind
    /// a mint or a dirty buffer. Either way the page still shows something
    /// other than the store, and a key typed into it would build on that.
    public static func surfaceHoldsTheStore(
        forcedRenderOwed: Bool, projectionDeferred: Bool
    ) -> Bool {
        !forcedRenderOwed && !projectionDeferred
    }

    /// Lowers the fence. True when the fence's sentence is owed (something
    /// was refused or withheld while it was up) — said once, here.
    public mutating func drain() -> Bool {
        phase = .open
        let speak = owesSentence
        owesSentence = false
        return speak
    }

    // MARK: The two kinds of edit

    /// The page's gate was asked about an edit. True = refuse it.
    public mutating func refusesPolicedEdit() -> Bool {
        guard isUp else { return false }
        owesSentence = true
        return true
    }

    /// An edit reached the text with no gate consult. True = withhold it:
    /// keep the page's tiling coherent, write nothing toward the store, and
    /// re-read the surface before the fence drops.
    public mutating func withholdsSystemEdit() -> Bool {
        guard isUp else { return false }
        owesSentence = true
        return true
    }
}
