import Foundation

// The host's decisions, as pure rules so they can be pinned headlessly. The AppKit host only feeds them
// readings (HID idle, the claim, the display) and acts on the answer.

/// Rail 5: real input ends the ambient. Input is READ from the HID system's idle time; nothing is posted.
public enum InputRule {
    /// Without a gate, input in the first moments after launch is ignored (a hand-typed `on`'s own
    /// key-up can land after launch).
    public static let launchGrace = 0.75

    /// How far back an event counts as input: since `Tools/ambient on`'s idle gate when it passed one
    /// (anyone who touched the Mac while the ambient was coming up has arrived), else since launch plus
    /// the grace. A gate older than a minute before launch is not trusted.
    public static func watching(uptime: Double, gateAge: Double?) -> Double {
        if let gateAge, gateAge.isFinite, gateAge >= 0, gateAge <= uptime + 60 { return gateAge }
        return uptime - launchGrace
    }

    /// Input arrived when the last HID event is newer than the start of the watch.
    public static func inputArrived(watching: Double, idle: Double) -> Bool {
        guard watching.isFinite, idle.isFinite else { return false }
        return idle < watching
    }
}

/// Rail 2, over time: a foreign claim ends the ambient at once. A lock without its claim file, or a claim
/// file without its fields, is most likely a claim mid-write (`Tools/stage` truncates and rewrites the
/// file on every claim and renew, the coordinator's own included), so it is given a short grace before
/// it counts.
public struct StageWatch {
    public static let midWriteGrace = 0.5
    private var unsettledSince: Double?

    public init() {}

    /// Feed every poll. Returns true when the ambient must go.
    public mutating func mustGo(after verdict: StageVerdict, at now: Double) -> Bool {
        switch verdict {
        case .free, .hold, .allowed:
            unsettledSince = nil
            return false
        case .foreign:
            return true
        case .pending, .unreadable:
            guard let since = unsettledSince else {
                unsettledSince = now
                return false
            }
            return now - since >= Self.midWriteGrace
        }
    }
}

/// Whether the ambient may come up at all.
public enum LaunchRule {
    public struct Refusal: Equatable, Sendable {
        public let reason: String
        public let exitCode: Int32
    }

    /// A display that is already asleep is refused too: nobody can see it, and waking the display takes
    /// input, which ends the ambient anyway.
    public static func refusal(stage: StageVerdict, screenLocked: Bool, displayAsleep: Bool) -> Refusal? {
        if !stage.permitsAmbient { return Refusal(reason: "stage \(stage.summary)", exitCode: 3) }
        if screenLocked { return Refusal(reason: "screen locked", exitCode: 4) }
        if displayAsleep { return Refusal(reason: "display asleep", exitCode: 7) }
        return nil
    }
}
