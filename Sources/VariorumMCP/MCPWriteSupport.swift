import Foundation
import VariorumCore

/// **WHERE MCP WRITES RUN** (13n-b U2 — the orchestrator's concurrence, AF-8:
/// R-13n-6's letter, "MCP writes ARE ordinary operations"). Every write tool
/// runs its whole body — the per-call decision, the act, the once stamp, the
/// activity line — through ONE serial executor holding the SESSION's
/// `Operations` (and so its `UndoStack`). In the app that executor is the
/// session's `OperationsRunner`, the road her own gestures take: the undo
/// stack's compound collector is single (an MCP compound collecting beside one
/// of her gestures would swallow her entry), and the runner is the
/// serialization the stack requires. Reads never come here — they stay on the
/// reader pool (U1's F3).
public protocol MCPWriteExecutor: Sendable {
    func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) async throws -> T
}

/// A serial executor for a host with no app around it (tests, a headless
/// host): one body at a time over the given `Operations`.
public actor MCPSerialExecutor: MCPWriteExecutor {
    private let operations: Operations

    public init(operations: Operations) {
        self.operations = operations
    }

    public func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) throws -> T {
        try body(operations)
    }
}

/// **A JUST-IN-TIME ASK** (AF-6 — the mockup §4 sheet's input): an APPROVED
/// client asked past its grant on a target that EXISTS. The call has already
/// answered (an ask never blocks); this value is the app's to queue — deduped
/// by `id` (client · target · rung) — and to put to her one at a time. Her
/// answer mints a grant through the ordinary ops (rung = `rung`, scope =
/// `scopeKind`/`scopeID`). Never raised for a missing target (no existence
/// oracle), a fenced BOOK (never a grant scope), or a client not approved.
public struct MCPAsk: Sendable, Equatable, Identifiable {
    public let clientName: String
    public let scopeKind: MCPGrantRule.ScopeKind
    public let scopeID: String
    /// The note's title, the book's name, the wing's name.
    public let title: String
    public let rung: MCPGrantRule.Rung
    /// Why it is fenced, when it is (the sheet names the reason).
    public let fence: MCPGrantRule.Fence?

    public init(
        clientName: String, scopeKind: MCPGrantRule.ScopeKind, scopeID: String, title: String,
        rung: MCPGrantRule.Rung, fence: MCPGrantRule.Fence?
    ) {
        self.clientName = clientName
        self.scopeKind = scopeKind
        self.scopeID = scopeID
        self.title = title
        self.rung = rung
        self.fence = fence
    }

    /// A fenced target's ask never offers "always" (R-13n-4; R2-1's fix).
    public var offersAlways: Bool { fence == nil }

    public var id: String {
        [clientName, scopeKind.rawValue, scopeID, rung.rawValue].joined(separator: "\u{1F}")
    }
}

/// **What one landed MCP write did** — the app's receipt is composed from it
/// in the app's own voice (P-13n-1's boundary); a SIGNAL, never a decision
/// (P-4).
public struct MCPWriteReceipt: Sendable, Equatable {
    public let clientName: String
    public let act: Operations.MCPWriteAct
    /// The note (or book) the act landed in, for coalescing a run of acts.
    public let targetID: String?
    /// That note's title / that book's name.
    public let targetTitle: String?
    /// The lens's name, the tag's path, the new book's name.
    public let detail: String?
    /// How many rows the act minted where it is more than one (an imported
    /// book's notes).
    public let count: Int

    public init(
        clientName: String, act: Operations.MCPWriteAct, targetID: String?, targetTitle: String?,
        detail: String? = nil, count: Int = 1
    ) {
        self.clientName = clientName
        self.act = act
        self.targetID = targetID
        self.targetTitle = targetTitle
        self.detail = detail
        self.count = count
    }
}

/// The host's seams to the app around it — set before `start()`.
public struct MCPHostHooks: Sendable {
    /// The operations layer's refusal in the app's own words (the Mac's
    /// `OpsRefusalCopy`) — "every refusal speaks to the client exactly as it
    /// speaks to her". Nil words fall back to the error's description.
    public var refusalWords: @Sendable (Error) -> String?
    /// A just-in-time ask to put to her (AF-6).
    public var onAsk: (@Sendable (MCPAsk) -> Void)?
    /// A write landed (the receipt's signal).
    public var onWrite: (@Sendable (MCPWriteReceipt) -> Void)?
    /// 13n-b U4: the clock the tray's 30-day window reads (the app's is the
    /// wall clock; a test's is its world's).
    public var now: @Sendable () -> Date

    public init(
        refusalWords: @escaping @Sendable (Error) -> String? = { _ in nil },
        onAsk: (@Sendable (MCPAsk) -> Void)? = nil,
        onWrite: (@Sendable (MCPWriteReceipt) -> Void)? = nil,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.refusalWords = refusalWords
        self.onAsk = onAsk
        self.onWrite = onWrite
        self.now = now
    }
}

/// An answer that could not be written as JSON (13n-b U4 — the guard in
/// front of `JSONSerialization`, whose failure is an uncatchable exception).
struct MCPAnswerEncodingFailure: Error, CustomStringConvertible {
    var description: String { "the answer could not be encoded" }
}
