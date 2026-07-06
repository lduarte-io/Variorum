// TK2Spike — the TK2->TK1 silent-fallback canary (TEXTKIT2_NOTES §4.3; throwaway; Phase 6).
//
// Subscribes to willSwitchToNSLayoutManager / didSwitchToNSLayoutManager for ALL text
// views. Any firing is recorded with the action in flight and logged loudly; with
// TK2SPIKE_STRICT=1 it is a hard assertionFailure. Default is record-and-continue so a
// mid-run fallback still yields the full Step 2 trigger inventory.

import AppKit

final class FallbackCanary {
    static let shared = FallbackCanary()

    struct Event {
        let phase: String   // "WILL" | "DID"
        let action: String
        let at: Double
    }

    private var tokens: [NSObjectProtocol] = []
    private(set) var events: [Event] = []
    /// The scenario sets this before each exercised action so a firing is attributable.
    var currentAction: String = "idle"

    func arm() {
        guard tokens.isEmpty else { return }
        let pairs: [(Notification.Name, String)] = [
            (NSTextView.willSwitchToNSLayoutManagerNotification, "WILL"),
            (NSTextView.didSwitchToNSLayoutManagerNotification, "DID"),
        ]
        for (name, phase) in pairs {
            tokens.append(NotificationCenter.default.addObserver(
                forName: name, object: nil, queue: nil
            ) { [weak self] _ in
                guard let self else { return }
                let event = Event(phase: phase, action: self.currentAction, at: nowMS())
                self.events.append(event)
                FileHandle.standardError.write(
                    "*** CANARY FIRED: \(phase) switch to NSLayoutManager during action '\(event.action)' ***\n"
                        .data(using: .utf8)!)
                if ProcessInfo.processInfo.environment["TK2SPIKE_STRICT"] == "1" {
                    assertionFailure("TK2->TK1 fallback during '\(event.action)'")
                }
            })
        }
    }

    /// Number of events recorded so far — snapshot before an action, compare after.
    var eventCount: Int { events.count }
}
