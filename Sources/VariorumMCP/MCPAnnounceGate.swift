import Foundation

/// **THE ANNOUNCE GATE** (VX-951 — the VX-981 run, batch 3; her ruling R-981-3,
/// "Ready or first request": the shape memo's option (b′); the record
/// `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 3 — RECORD).
///
/// One connection's `notifications/tools/list_changed` waits until the
/// connection is READY to hear it. MCP's lifecycle has the client say so with
/// its `initialized` notification ("After successful initialization, the client
/// MUST send an `initialized` notification to indicate it is ready to begin
/// normal operations"), and the server speak only once it has; a client that
/// lists or calls a tool without ever sending it has plainly finished
/// initializing too, so its first such request opens the gate as well —
/// whichever comes first. And the gate never opens before the connection's
/// `initialize` answer has been WRITTEN: no frame of the door's ever precedes
/// that answer, whatever a client pipelines behind its `initialize`.
///
/// While the gate is shut an announce is REMEMBERED — one flag, never a count,
/// never sent; when it opens, exactly ONE announce goes out if any was
/// remembered, none otherwise (the catch-up: the client re-lists once and reads
/// the rows as they stand). Once open it stays open, and every announce goes
/// out as it comes.
///
/// Pure — the session holds one under its lock and acts on what it answers;
/// pinned by `MCPAnnounceGateTests`.
struct MCPAnnounceGate: Equatable, Sendable {
    /// What the session hears on its way to ready.
    enum Event: Equatable, Sendable {
        /// The connection's `initialize` answer has been written (the
        /// transport's report — `MCPSocketTransport`'s `onOpeningAnswered`).
        case initializeAnswered
        /// The client's `notifications/initialized`.
        case clientInitialized
        /// The client's first request after `initialize` that the door serves
        /// (`tools/list`, `tools/call` — PROVISIONAL P-981-B3-2).
        case clientRequest
    }

    /// The `initialize` answer has been written.
    private(set) var answered = false
    /// The client is ready (its `initialized`, or a first request).
    private(set) var ready = false
    /// An announce arrived while the gate was shut.
    private(set) var held = false

    var isOpen: Bool { answered && ready }

    /// An announce: true — send it now; false — the gate is shut, so it is
    /// remembered (once, however many arrive) and nothing is sent.
    mutating func announce() -> Bool {
        if isOpen { return true }
        held = true
        return false
    }

    /// Hear `event`: true exactly when this event OPENS the gate with an
    /// announce remembered — the caller then sends the one catch-up. An event
    /// heard again, or after the gate opened, changes nothing.
    mutating func hear(_ event: Event) -> Bool {
        let wasOpen = isOpen
        switch event {
        case .initializeAnswered: answered = true
        case .clientInitialized, .clientRequest: ready = true
        }
        guard !wasOpen, isOpen, held else { return false }
        held = false
        return true
    }
}
