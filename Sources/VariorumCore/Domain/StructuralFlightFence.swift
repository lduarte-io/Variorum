import Foundation

/// **VM-2 — the keystroke fence around a structural flight** (the phone's
/// live editor; the record `notes/plans/fixes/vm-64-timing-and-lags.md`,
/// batch 2).
///
/// A structural door (divide, merge, extract, make block, insert below, the
/// block deletes, the cross-block compound) flushes, then SUSPENDS — the fan
/// read, the operation on the runner, the settle's own read — while the
/// surface still shows the note as it was before the operation. An edit that
/// lands in that window is routed against the old tiling, and its autosave
/// records the WHOLE old block text; written after the operation, that text
/// resurrects a divided half, duplicates an extracted span, or lands prose in
/// a merge's released source. The Mac closes the window in `runStructural`
/// (the view non-editable, typed keys deferred and replayed); this is the
/// same rule as a pure brain, so the phone's face can be thin and the rule
/// can be pinned without a simulator.
///
/// **The window** runs from the moment a door raises its flight latch to the
/// moment the surface holds the store as the operation left it — which is
/// usually the door's own settle, and occasionally later (a settle deferred
/// behind an in-flight mint, or a forced re-render still owed). Hence three
/// phases: `open`, `flying` (the latch is up), `settling` (the latch is down,
/// the surface not yet re-read).
///
/// **What each kind of edit gets while the fence is up:**
///   - **typed input** — a character or a delete-backward from the keyboard —
///     is DEFERRED, in order, and replayed at the landed caret when the fence
///     drops (the Mac's 18c R1-2 rule: never dropped). It is coordinate-free,
///     which is why it can wait: it acts on whatever caret it finds.
///   - **an input-method composition in progress** is never deferred: its
///     marked text is the keyboard's own state, and holding a piece of it
///     back would leave the keyboard believing in text the page lacks. It
///     falls to the two rules below.
///   - **any other edit the page's gate is asked about** (a paste, a
///     formatting act, an autocorrection that consults the gate) is REFUSED.
///   - **an edit that reaches the text with no gate consult** (the system's
///     own rewrites — dictation, a composition commit, a programmatic
///     replace) is WITHHELD: the page keeps its tiling coherent, nothing of it
///     is written toward the store, and the surface is re-read from the store
///     before the fence drops.
///   - Anything refused or withheld leaves a debt: the fence's one sentence is
///     spoken once, when it drops, so nothing leaves her page silently.
///
/// It logs nothing and persists nothing: the deferred inputs live in memory
/// for the length of one flight, and nowhere else.
public struct StructuralFlightFence: Equatable, Sendable {
    /// One deferred keystroke. Coordinate-free on purpose: it is replayed at
    /// the caret the flight lands, never at an offset into a text that the
    /// operation has since rewritten.
    public enum Input: Equatable, Sendable {
        case insert(String)
        case deleteBackward
    }

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
        /// Lower the fence now (`drain()`), replaying and speaking.
        case drain
        /// Keep the fence up and re-read the surface first; `surfaceSettled()`
        /// says when to drain.
        case awaitSettle
    }

    /// What the fence hands back as it drops.
    public struct Drain: Equatable, Sendable {
        /// The deferred inputs, oldest first.
        public let replay: [Input]
        /// Whether anything was refused or withheld while it was up.
        public let speak: Bool

        public init(replay: [Input], speak: Bool) {
            self.replay = replay
            self.speak = speak
        }
    }

    public private(set) var phase: Phase = .open
    /// Inputs waiting for the fence to drop, oldest first.
    public private(set) var deferred: [Input] = []
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

    /// The door's latch dropped. `surfaceSettled` is the face's reading of
    /// `surfaceHoldsTheStore`; when the surface is not there yet the fence
    /// stays up, in `settling`, until the face says it is.
    public mutating func flightLanded(surfaceSettled: Bool) -> Landing {
        if surfaceSettled { return .drain }
        phase = .settling
        return .awaitSettle
    }

    /// The face re-read the surface. True when a drain is now owed (the
    /// fence was settling); false when there was nothing to wait for.
    public mutating func surfaceSettled() -> Bool {
        phase == .settling
    }

    /// **THE SETTLE RULE**: the surface holds the store as the operation left
    /// it exactly when no forced re-render and no deferred projection is still
    /// outstanding. A forced render is owed when a withheld edit put bytes on
    /// the page the store never saw (or a heal asked for one); a deferred
    /// projection means the door's own post-operation read was parked behind
    /// a mint or a dirty buffer. Either way the page still shows something
    /// other than the store, and typing into it would build on that.
    public static func surfaceHoldsTheStore(
        forcedRenderOwed: Bool, projectionDeferred: Bool
    ) -> Bool {
        !forcedRenderOwed && !projectionDeferred
    }

    /// Lowers the fence and hands back what it held. The caller replays the
    /// inputs in order through the page's ordinary, policed input road; if a
    /// replayed input starts something that must finish first, the caller
    /// stops and `putBack`s the rest.
    public mutating func drain() -> Drain {
        phase = .open
        let drained = Drain(replay: deferred, speak: owesSentence)
        deferred = []
        owesSentence = false
        return drained
    }

    /// Returns inputs a stopped replay did not reach, AHEAD of anything typed
    /// since, so her keys always land in the order she pressed them.
    public mutating func putBack(_ inputs: [Input]) {
        deferred = inputs + deferred
    }

    // MARK: The three kinds of edit

    /// A typed input arrived. True = deferred (the caller must not perform
    /// it). Deferred while the fence is up — and also while earlier inputs
    /// are still waiting, so a key pressed after the fence dropped can never
    /// overtake the ones pressed before. A composition in progress is never
    /// deferred.
    public mutating func offer(_ input: Input, composing: Bool) -> Bool {
        guard !composing, isUp || !deferred.isEmpty else { return false }
        deferred.append(input)
        return true
    }

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
