import Foundation
import VariorumCore

/// **THE LIBRARY IS LOCKED — the door's one sentence while the store is shut**
/// (VX-818, the VX-809 run — her R-818: "the reconnect is the CLIENT's; what the
/// app CAN do is never drop the connection"; A-809-20; the record
/// `notes/plans/fixes/vx-809-mcp-door-ergonomics.md` BATCH 4). While the host is
/// SUSPENDED (`MCPServerHost.suspend()` — the library locked, or briefly shut to
/// re-key) every `tools/call` on every connection — a surviving one, or one held
/// at its admission because it arrived during the lock — answers exactly these
/// bytes, checked at the call door AHEAD OF EVERYTHING: no grant decision, no
/// name or id resolved, no schema read, nothing logged, nothing spent. It names
/// no title and no count — the same sentence for every caller, every tool, every
/// argument, so it can tell nothing. PROVISIONAL P-809-4 (her copy pass).
enum MCPLockedLibrary {
    static let words = "The library is locked \u{2014} ask again once it's unlocked."

    /// **A call the lock OVERTOOK** — already past the call door when the store
    /// shut, so its read or write met the typed `StoreLockedError`. The one chain
    /// says it in the store-failure sentence's honest form, never "ask again":
    /// an act may have landed before a later write in the same call met the lock.
    /// PROVISIONAL (P-809-4's family).
    static let overtakenDetail = "the library is locked"
}

/// **The latch every session reads at its call door** (VX-818): shut by the
/// host's `suspend()` FIRST — before anything else of the suspend — so no call
/// that arrives afterwards reaches the store; opened by `resume`. Cheap: one
/// lock, no store access. Shared by reference between the host and its sessions.
final class MCPStoreLatch: @unchecked Sendable {
    private let lock = NSLock()
    private var shut = false

    var isShut: Bool { lock.withLock { shut } }

    func close() { lock.withLock { shut = true } }
    func open() { lock.withLock { shut = false } }
}

/// **THE EXECUTOR SLOT** (VX-818): the one write executor every session of a host
/// holds, forwarding to the CURRENT one. In the app the executor is the open
/// session's runner (AF-8 — her undo stack, her serial road); the unlock
/// composes a FRESH session (a fresh runner and undo stack), so a host whose
/// connections survive the lock is re-pointed at it (`resume(executor:)`) — or
/// the client's ⌥⌘Z entries would land on a dead stack, its writes off her road.
/// A call already running keeps the executor it started on.
final class MCPExecutorSlot: MCPWriteExecutor, @unchecked Sendable {
    private let lock = NSLock()
    private var current: any MCPWriteExecutor

    init(_ executor: any MCPWriteExecutor) { current = executor }

    func repoint(_ executor: any MCPWriteExecutor) { lock.withLock { current = executor } }

    func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) async throws -> T {
        let target = lock.withLock { current }
        return try await target.run(body)
    }
}
