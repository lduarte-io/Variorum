import Testing

@testable import VariorumMCP

// VX-951 (the VX-981 run, batch 3 — the record
// `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 3 — RECORD): THE
// ANNOUNCE GATE's rule, pure — her R-981-3, "Ready or first request" (the shape
// memo's (b′)). A NEW contract (the type is new), pinned here exactly; the wire
// pins that are red on the old door are `MCPAnnounceOrderServerTests`.

@Suite("VX-951 — the announce gate's rule (pure)")
struct MCPAnnounceGateTests {
    /// Shut from birth: an announce is remembered, never sent — once, however
    /// many arrive — and the gate's opening releases exactly ONE.
    @Test func whileShutAnnouncesAreRememberedAndTheOpeningReleasesExactlyOne() {
        var gate = MCPAnnounceGate()
        #expect(!gate.isOpen)
        #expect(gate.announce() == false, "shut: remembered, not sent")
        #expect(gate.announce() == false)
        #expect(gate.announce() == false)
        #expect(gate.hear(.initializeAnswered) == false, "the answer alone opens nothing")
        #expect(gate.hear(.clientInitialized) == true, "opened with announces remembered: ONE catch-up")
        #expect(gate.isOpen && !gate.held)
        #expect(gate.announce() == true, "open: every announce goes as it comes")
        #expect(gate.hear(.clientInitialized) == false, "an event heard again releases nothing")
        #expect(gate.hear(.clientRequest) == false)
    }

    /// Nothing remembered: the opening releases nothing.
    @Test func anOpeningWithNothingRememberedReleasesNothing() {
        var gate = MCPAnnounceGate()
        #expect(gate.hear(.initializeAnswered) == false)
        #expect(gate.hear(.clientInitialized) == false)
        #expect(gate.isOpen && !gate.held)
    }

    /// (b′): a client's first served request opens it as `initialized` does —
    /// whichever comes first.
    @Test func aFirstRequestOpensItAsInitializedDoes() {
        var gate = MCPAnnounceGate()
        #expect(gate.hear(.initializeAnswered) == false)
        #expect(gate.announce() == false)
        #expect(gate.hear(.clientRequest) == true, "the first request: ONE catch-up")
        #expect(gate.hear(.clientInitialized) == false, "the later initialized releases nothing more")
        #expect(gate.isOpen)
    }

    /// The `initialize` answer's write is required whatever the client says
    /// first: a client that pipelines `initialized` (or a request) ahead of
    /// reading its answer leaves the gate shut until that answer is written —
    /// so nothing of the door's ever precedes it.
    @Test(arguments: [MCPAnnounceGate.Event.clientInitialized, .clientRequest])
    func readyBeforeTheAnswerIsWrittenStillWaitsForIt(_ ready: MCPAnnounceGate.Event) {
        var gate = MCPAnnounceGate()
        #expect(gate.hear(ready) == false)
        #expect(!gate.isOpen, "ready, but the answer is not written yet")
        #expect(gate.announce() == false, "remembered")
        #expect(gate.hear(.initializeAnswered) == true, "the answer written: the gate opens and releases ONE")
        #expect(gate.isOpen)
    }
}
