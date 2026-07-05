import Foundation

/// Session-scoped, in-memory undo for STRUCTURAL operations only (AppSpec §9,
/// author decision 2026-07-04). Registered this phase: deleteBlock,
/// deleteVariant, archiveVariant, moveBlock, reorder; Phase 3 registers
/// divide/merge/extract/poolDragCopy. Excluded by design: text editing
/// (command-Z stays NSTextView's per-buffer undo, never interleaved),
/// commits (append-only; restore IS the feature), locks and tags (trivially
/// re-toggled). Never persisted — the deliberate cheap/nightmare line.
///
/// Each forward operation registers its inverse when it runs, capturing
/// pre-images (positions, default pointers) at do-time. Undo emits ordinary
/// operations — writes flow through the ops layer and the outbox like any
/// other, so sync never knows undo exists.
public final class UndoStack: @unchecked Sendable {
    public struct Entry {
        /// Registration-order token so a completed undo removes exactly the
        /// entry it ran, even if a registration landed while the inverse was
        /// executing outside the lock.
        let id: Int
        /// Human-readable operation name ("Delete Block") — Phase 7 wires
        /// "Undo Divide"-style menu labeling from this.
        public let label: String
        let inverse: (Operations) throws -> Void
    }

    private let lock = NSLock()
    private var entries: [Entry] = []
    private var nextID = 0

    public init() {}

    public var depth: Int {
        lock.withLock { entries.count }
    }

    public var topLabel: String? {
        lock.withLock { entries.last?.label }
    }

    func register(label: String, inverse: @escaping (Operations) throws -> Void) {
        lock.withLock {
            nextID += 1
            entries.append(Entry(id: nextID, label: label, inverse: inverse))
        }
    }

    /// Runs the newest inverse (LIFO) and removes it on success; a failed
    /// inverse (e.g. the post was locked after the fact) stays on the stack
    /// so the user can resolve and retry. Returns the undone entry's label,
    /// or nil when there is nothing to undo. The inverse runs outside the
    /// lock (it is a DB write); removal is by entry id, so a registration
    /// racing the inverse can never make undo pop someone else's entry.
    @discardableResult
    public func undo(with operations: Operations) throws -> String? {
        guard let entry = lock.withLock({ entries.last }) else { return nil }
        try entry.inverse(operations)
        lock.withLock { entries.removeAll { $0.id == entry.id } }
        return entry.label
    }

    public func removeAll() {
        lock.withLock { entries.removeAll() }
    }
}
