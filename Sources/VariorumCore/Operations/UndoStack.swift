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
    private var changeObserver: (@Sendable () -> Void)?
    /// Non-nil while a compound registration is collecting (Phase 9's
    /// composed Make Block gesture): registrations land here instead of the
    /// stack, then fold into ONE entry.
    private var compoundCollector: [Entry]?

    public init() {}

    public var depth: Int {
        lock.withLock { entries.count }
    }

    public var topLabel: String? {
        lock.withLock { entries.last?.label }
    }

    /// Fires after every stack mutation (a registration, a completed undo,
    /// a removeAll) — outside the lock, on the mutating thread. The app
    /// wires menu invalidation here so the Edit menu can show per-op
    /// "Undo Divide"-style labels (Phase 9; the KnownIssues labels entry).
    public func setChangeObserver(_ observer: (@Sendable () -> Void)?) {
        lock.withLock { changeObserver = observer }
    }

    private func notifyChange() {
        let observer = lock.withLock { changeObserver }
        observer?()
    }

    func register(label: String, inverse: @escaping (Operations) throws -> Void) {
        let collected: Bool = lock.withLock {
            nextID += 1
            let entry = Entry(id: nextID, label: label, inverse: inverse)
            if compoundCollector != nil {
                compoundCollector?.append(entry)
                return true
            }
            entries.append(entry)
            return false
        }
        if !collected { notifyChange() }
    }

    /// Runs `body` with registrations COLLECTED into one compound entry
    /// (Phase 9, the composed middle-span gesture — AppSpec §14's ratified
    /// "two divides as ONE undoable action"). Composition only: the
    /// compound's inverse runs the collected inverses newest-first, exactly
    /// as separate undos would; no new inverse logic exists. Compounds
    /// don't nest (nothing needs to; debug asserts via precondition).
    ///
    /// If `body` throws after some of its operations landed, the compound
    /// stays atomic: the already-collected inverses run immediately
    /// (newest-first) to un-apply the partial work, and the original error
    /// rethrows. Should an un-apply itself fail (e.g. a seal landing
    /// mid-gesture from a sync apply), the not-yet-run inverses are pushed
    /// as ordinary entries so the partial work stays reachable by undo —
    /// never stranded.
    ///
    /// A compound entry whose inverse fails partway stays on the stack for
    /// retry like any entry; the inverses it already ran are idempotent
    /// (revert operations skip already-reverted rows), so a retry is safe.
    public func withCompound<T>(
        label: String, operations: Operations, _ body: () throws -> T
    ) throws -> T {
        lock.withLock {
            precondition(compoundCollector == nil, "compound undo entries don't nest")
            compoundCollector = []
        }
        func drainCollector() -> [Entry] {
            lock.withLock {
                let collected = compoundCollector ?? []
                compoundCollector = nil
                return collected
            }
        }
        do {
            let result = try body()
            let collected = drainCollector()
            if !collected.isEmpty {
                register(label: label) { ops in
                    for entry in collected.reversed() {
                        try entry.inverse(ops)
                    }
                }
            }
            return result
        } catch {
            var remaining = drainCollector()
            while let entry = remaining.last {
                if (try? entry.inverse(operations)) == nil { break }
                remaining.removeLast()
            }
            if !remaining.isEmpty {
                lock.withLock { entries.append(contentsOf: remaining) }
                notifyChange()
            }
            throw error
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
        notifyChange()
        return entry.label
    }

    public func removeAll() {
        lock.withLock { entries.removeAll() }
        notifyChange()
    }
}
