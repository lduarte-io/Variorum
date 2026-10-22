import Foundation
import GRDB

// Phase 13p, Batch 2 — the re-lock substrate (THE DESIGN's keyed-stack
// paragraph: "tear down observations, close the pool, drop key material;
// reopening rebuilds the stack through the composition root").
//
// WHY A BINDING EXISTS AT ALL: `AppDatabase.install` wires the opened
// store as the process-global `\.database` dependency EXACTLY ONCE
// (prepareDependencies), and ambient holders — Operations, the sync
// engine, the purge janitor — read it per access. A re-lock must CLOSE
// that pool and a later unlock must open a FRESH one, so the installed
// value has to be an indirection: the composition root installs the
// binding's VIEW once, then locks/adopts through the binding forever
// after. Nothing downstream changes a line; an access that lands while
// locked gets the typed `StoreLockedError`, never a stale pool and never
// a crash.
//
// WHAT "DROP KEY MATERIAL" MEANS HERE, precisely: the pool's
// `Configuration` holds the keying `prepareDatabase` closure (the raw-key
// pragma captures the key's hex form), so dropping the pool REFERENCE is
// part of dropping the key — `lock()` closes the connections AND releases
// the pool object and the `StoreKey` value. What lock() cannot do is
// scrub already-freed pages of process memory; that is the same honesty
// class as the migration's SSD-remnant footnote and is recorded, not
// claimed away.

/// A refused access on a locked store — typed, so surfaces can word it
/// (and racing tasks can end quietly) instead of crashing.
public struct StoreLockedError: Error, Equatable, Sendable {
    public init() {}
}

/// The lock/adopt handle the composition root keeps beside the installed
/// ambient view. Thread-safe; `lock()` is blocking (GRDB's `close()`
/// waits for in-flight accesses) — callers hop off the main thread.
public final class StoreBinding: @unchecked Sendable {
    private let mutex = NSLock()
    private var writer: (any DatabaseWriter)?
    private var key: StoreKey?

    init(writer: any DatabaseWriter, key: StoreKey?) {
        self.writer = writer
        self.key = key
    }

    public var isLocked: Bool {
        mutex.lock()
        defer { mutex.unlock() }
        return writer == nil
    }

    func currentWriter() -> (any DatabaseWriter)? {
        mutex.lock()
        defer { mutex.unlock() }
        return writer
    }

    func currentKey() -> StoreKey? {
        mutex.lock()
        defer { mutex.unlock() }
        return key
    }

    /// The writer and key as ONE acquisition (13p ladder R1-n1). A caller
    /// composing "is it locked" and "what is the key" from two separate
    /// reads can meet a lock BETWEEN them — `isLocked` answers false, the
    /// lock lands, `currentKey()` answers nil — and conclude "unlocked,
    /// unkeyed", which for a keyed store is the silently-plain state every
    /// contract here forbids. nil = locked.
    func currentState() -> (writer: any DatabaseWriter, key: StoreKey?)? {
        mutex.lock()
        defer { mutex.unlock() }
        guard let writer else { return nil }
        return (writer, key)
    }

    /// LOCK: swap to the locked state FIRST (new accesses refuse from this
    /// instant), then close the pool outside the mutex (close blocks until
    /// in-flight accesses complete — holding the mutex through that wait
    /// would stall refusals for no gain), then let the pool and key go.
    ///
    /// A close failure is returned, not thrown, and the binding is locked
    /// EITHER WAY: the pool reference is dropped regardless (its deinit
    /// closes the connections when the last in-flight access ends), so a
    /// failed close degrades to a slightly later close — never to an
    /// unlocked store. Idempotent.
    @discardableResult
    public func lock() -> (closedCleanly: Bool, closeFailure: String?) {
        mutex.lock()
        let outgoing = writer
        writer = nil
        key = nil
        mutex.unlock()
        guard let outgoing else { return (true, nil) }
        // W-1 (the 13x closeout walk): checkpoint-truncate BEFORE the
        // close — a plain close leaves a non-empty `-wal` beside the
        // store, which 13x's adoption gate (LibraryAdoption step 2 — deleted
        // with today's road at VX-329 U1; the road's copy doors swap on the
        // same precondition) read as "pool not closed", so the ready-road
        // adoption could never act. The re-key road already pays this exact toll
        // (StoreEncryptionMigration's explicit TRUNCATE). A failed
        // checkpoint is swallowed deliberately: it degrades to the
        // gate's honest refusal, never to an unlocked store.
        _ = try? outgoing.writeWithoutTransaction { db in
            try Row.fetchOne(db, sql: "PRAGMA wal_checkpoint(TRUNCATE)")
        }
        do {
            try outgoing.close()
            return (true, nil)
        } catch {
            return (false, String(describing: error))
        }
    }

    /// UNLOCK's second half: point the binding at a freshly opened store.
    /// Takes the database's DIRECT connection — adopting a bound view
    /// (including this binding's own) is a composition error and refuses
    /// loudly, because it would alias two bindings over one pool.
    public func adopt(_ database: AppDatabase) throws {
        guard case .direct(let newWriter, let newKey) = database.storage else {
            throw StoreBindingError.cannotAdoptBoundView
        }
        mutex.lock()
        defer { mutex.unlock() }
        writer = newWriter
        key = newKey
    }
}

public enum StoreBindingError: Error, Equatable, Sendable {
    /// `adopt` was handed a bound view instead of a directly opened store.
    case cannotAdoptBoundView
}
