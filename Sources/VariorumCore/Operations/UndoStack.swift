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
///
/// REDO (Phase 13c, batch 1B — author item A10: "a 'redo' command to be
/// able to undo my structural undos for when that was an accident").
/// Structural redo ONLY: ⌘Z stays NSTextView's per-buffer text undo and the
/// two stacks never interleave (AppSpec §9, ratified). Session-scoped and
/// in-memory like the undo stack — never persisted. The shape:
///
/// - every entry carries BOTH halves — the `inverse` undo runs and the
///   `redo` re-apply that puts back exactly what the inverse un-did, from
///   the SAME do-time pre-images. So an entry MOVES between the two stacks
///   and undo↔redo ping-pongs indefinitely without re-deriving anything;
/// - the re-applies are exact-row like the inverses (tombstone flips,
///   pre-image restores — never fresh rows), so do → undo → redo round-trips
///   to the post-do row state, IDs included;
/// - redo emits ordinary operations, exactly as undo does, so sync never
///   learns redo exists either;
/// - **any new structural act clears the redo stack** — the standard
///   discipline: once the timeline forks, the abandoned future is gone.
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
        /// The RE-APPLY half (13c 1B): puts back exactly what `inverse`
        /// un-did. Nil ⇒ this entry is not redoable, and undoing it CLEARS
        /// the redo stack — redo is strictly LIFO, so an entry that cannot
        /// be re-applied is never skipped over.
        let redo: ((Operations) throws -> Void)?
        /// The buffer pre-images this entry's inverse would RESTORE (13d
        /// batch 5 — A12). The same values the inverse passes to
        /// `revertStructural`, carried as DATA so the warning can be asked
        /// before the act. Empty for every entry that restores no buffer
        /// (deleteBlock, moveBlock, reorder, merge, the W…): those can
        /// discard nothing, so they are silent by construction rather than
        /// by a per-site decision.
        let insuring: [Operations.TextPreImage]
    }

    /// What the NEXT undo would set aside — A12's whole input (author
    /// ruling, 13d sitting: warn ONLY on the insurance class).
    public struct PendingUndoWarning: Equatable, Sendable {
        /// The entry's label ("Divide"), for the dialog's question.
        public let label: String
        /// How many buffers carry text edited since the operation.
        public let bufferCount: Int

        public init(label: String, bufferCount: Int) {
            self.label = label
            self.bufferCount = bufferCount
        }
    }

    private let lock = NSLock()
    private var entries: [Entry] = []
    /// Entries undone and re-appliable, oldest-undone first (so `last` is
    /// the next redo — LIFO, the mirror of `entries`).
    private var redoEntries: [Entry] = []
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

    public var redoDepth: Int {
        lock.withLock { redoEntries.count }
    }

    /// The next redo's label ("Divide") — the Edit menu's "Redo Divide".
    public var topRedoLabel: String? {
        lock.withLock { redoEntries.last?.label }
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

    /// Registers one forward operation's two halves. `redo` is REQUIRED
    /// (never defaulted): a new registration site must decide how its act
    /// is re-applied rather than silently shipping a hole in redo — pass
    /// `nil` deliberately, and undoing past it clears the redo stack.
    ///
    /// Registering is a NEW structural act, so it clears the redo stack
    /// (including during a compound's collection — the compound as a whole
    /// is the new act). The inverses and re-applies themselves never
    /// register, so undo and redo cannot clear it from under themselves;
    /// `UndoStackTests` pins that.
    func register(
        label: String,
        inverse: @escaping (Operations) throws -> Void,
        redo: ((Operations) throws -> Void)?,
        insuring: [Operations.TextPreImage] = []
    ) {
        let collected: Bool = lock.withLock {
            nextID += 1
            let entry = Entry(
                id: nextID, label: label, inverse: inverse, redo: redo, insuring: insuring)
            redoEntries.removeAll()
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
    /// **Recorded behaviour, deliberate (13c Stage 1 ladder, R1-10): a
    /// compound that throws mid-body still DESTROYS the redo future**, even
    /// though its partial work rolls back. Each collected leg's own
    /// `register` clears `redoEntries` as it lands, and the rollback does
    /// not restore them. This is "any new structural act clears the future"
    /// applied to an act that then failed — defensible (the author DID
    /// invoke a new structural act, and a redo stack that survives a
    /// half-applied-then-rolled-back gesture is the subtler surprise), and
    /// cheap to reach only through a refusal landing mid-gesture. Stated
    /// rather than silently true.
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
                // The compound's REDO mirrors its inverse: the collected
                // re-applies run OLDEST-FIRST (forward order), exactly as
                // the original operations ran. A compound is redoable only
                // when EVERY leg is — a half-re-applied compound is not a
                // state the model should ever be able to reach.
                let redos = collected.map(\.redo)
                let compoundRedo: ((Operations) throws -> Void)? =
                    redos.allSatisfy { $0 != nil }
                    ? { ops in
                        for entry in collected {
                            try entry.redo?(ops)
                        }
                    }
                    : nil
                register(
                    label: label,
                    inverse: { ops in
                        for entry in collected.reversed() {
                            try entry.inverse(ops)
                        }
                    },
                    redo: compoundRedo,
                    // A12: a compound insures whatever its legs would — the
                    // composed Make Block gesture's two divides are one act
                    // to her, so its warning must speak for both.
                    insuring: collected.flatMap(\.insuring))
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

    /// **A12 (author ruling, 13d sitting 2026-07-28): what the next undo
    /// would DISCARD** — nil when it would discard nothing, which is every
    /// case but one. The one: an undo whose buffer restore would overwrite
    /// text edited since the operation (the fourth quiet auto-commit
    /// occasion's own condition, `Operations.wouldInsure`). Her ruling was
    /// exactly this class and no wider: *"every other structural undo stays
    /// silent"*.
    ///
    /// Asked at the door, against the store as it is NOW — an entry sitting
    /// on the stack becomes warnable the moment she edits the buffer and
    /// stops being warnable the moment she commits it, and neither event
    /// touches the stack. Never throws (`insuranceTargets` degrades to "no
    /// warning"): the confirm is a courtesy, and the insurance commit that
    /// makes the discard recoverable rides inside the undo's own
    /// transaction, not here.
    public func pendingUndoWarning(with operations: Operations) -> PendingUndoWarning? {
        guard let entry = lock.withLock({ entries.last }), !entry.insuring.isEmpty
        else { return nil }
        let targets = operations.insuranceTargets(entry.insuring)
        guard !targets.isEmpty else { return nil }
        return PendingUndoWarning(label: entry.label, bufferCount: targets.count)
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
        lock.withLock {
            entries.removeAll { $0.id == entry.id }
            if entry.redo != nil {
                redoEntries.append(entry)
            } else {
                // Redo is strictly LIFO: an entry that cannot be re-applied
                // is never skipped over, so its undo ends the redo future.
                redoEntries.removeAll()
            }
        }
        notifyChange()
        return entry.label
    }

    /// Re-applies the most recently undone entry (13c 1B — A10) and moves
    /// it back onto the undo stack, so undo↔redo ping-pongs on the same
    /// captured pre-images. Returns the redone entry's label, or nil when
    /// there is nothing to redo. Mirrors `undo` exactly: the re-apply runs
    /// OUTSIDE the lock (it is a DB write), a failure leaves the entry on
    /// the redo stack for retry (resolve the refusal — an unsealed post,
    /// say — and press again), and removal is by entry id.
    @discardableResult
    public func redo(with operations: Operations) throws -> String? {
        guard let entry = lock.withLock({ redoEntries.last }),
              let reapply = entry.redo
        else { return nil }
        try reapply(operations)
        lock.withLock {
            redoEntries.removeAll { $0.id == entry.id }
            entries.append(entry)
        }
        notifyChange()
        return entry.label
    }

    public func removeAll() {
        lock.withLock {
            entries.removeAll()
            redoEntries.removeAll()
        }
        notifyChange()
    }
}
