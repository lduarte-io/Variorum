//
//  DebugOracleOwnership.swift
//  Variorum (Mac)
//
//  18k UNIT C4 — **the DEBUG oracles' OWNERSHIP rule, as one type** (the
//  post-13u health review §5.2; the record is `notes/plans/phase-18k-runtime-
//  hygiene.md`, UNIT C4 RECORD).
//
//  THE DEFECT. A DEBUG oracle is a process-global slot a mounted surface
//  writes and a pin reads. Keyed by its SUBJECT (a book, a note, a row) or
//  not keyed at all, it keeps no record of WHO wrote it, so with two windows
//  standing:
//    · a teardown that clears the slot takes the OTHER window's registration
//      with it (the cross-clear arm — `BookOutlineGeometry.focusDoors` was
//      nil with a book on screen), and
//    · a teardown that clears nothing leaves the DEPARTED window's value as
//      the answer while the window still open says something else (the
//      stale arm — the navigator, the seam, the bar, the Read face…).
//  Either way a pin reading the oracle is green or red because of the ORDER
//  mounts came and went — measured red on twelve oracles, the C4 record.
//
//  THE RULE — 13u4 UNIT S2/S3's, stated there in one line and applied at
//  `PostDetailOracle.stamp*`, `CatalogStampOracle` and
//  `ShellRouter.blockNamingDoors`: **the registrant names itself, and a
//  teardown clears only what it still owns.** Those three are hand-rolled;
//  this type is the same idea once, so the rest of the oracles do not grow a
//  fourth, fifth and twelfth copy that could drift.
//
//    · A registration is `(key, owner, value)`. Per key, the LIVE
//      registrants stand in the order they last wrote; the most recent
//      writer is the answer — exactly what the bare static answered before
//      C4 while everyone who wrote to it was still on screen, so no reader's
//      live behaviour moves (a first design kept an owner's FIRST place, and
//      the closing run showed why not: under parallel suites a later mount
//      would have shadowed an earlier pin's own surface for its whole life —
//      a new flake class for every existing reader). Re-publishing replaces
//      the owner's value (it never stacks) and makes it the newest.
//    · `withdraw` and `release` take ONLY the owner's own — so the survivor
//      of a two-window pair answers again the moment the other leaves. A
//      reverse index keeps a surface's teardown proportional to what it
//      wrote, never to the size of the oracle.
//    · `forget` / `forgetAll` are a PIN's doors and are unconditional — the
//      references' own precedent (`PostDetailOracle.resetStamp`: "a pin owns
//      nothing, and 'start from empty' is exactly what it is asking for").
//
//  WHO THE OWNER IS. The view whose code performs the write: a surface's own
//  `@State` token (MastheadStamp's `oracleOwner`, the S2 shape), or — when
//  the writes come from ROW views or probe modifiers under a surface — the
//  surface's token, handed down by environment (`debugOracleOwner`, below:
//  the `debugProbeScope` road, one level down), so a row's registration
//  lives exactly as long as the surface that drew it and no shorter. A probe
//  mounted with no owning surface above it falls back to `unowned`, which no
//  teardown ever releases — the pre-C4 behaviour, kept for that case only.
//
//  WHAT THIS DOES NOT FIX (said so nobody reads it as fixed): two LIVE
//  owners in two different TESTS on one unscoped slot. The newest registrant
//  answers, and it can be the other test's. That is the parallel-suites axis
//  13u2 UNIT E closed for six oracles by session scope (`DebugProbeScope`);
//  the references share the residual.
//
//  DEBUG only, end to end: the shipping build carries neither these types
//  nor the tokens nor the environment value.
//

import Foundation
import SwiftUI

#if DEBUG
/// Owner-keyed registrations under `Key` — the C4 rule, once.
struct OwnedRegistrations<Key: Hashable, Value> {
    private struct Standing {
        let owner: UUID
        var value: Value
    }

    /// Per key: the registrants standing on it, oldest first.
    private var standing: [Key: [Standing]] = [:]
    /// Per owner: the keys it holds — a teardown is ∝ what it wrote.
    private var keysByOwner: [UUID: Set<Key>] = [:]

    init() {}

    /// The answer for `key`: its most recent registrant's value.
    subscript(key: Key) -> Value? { standing[key]?.last?.value }

    /// Every key's answer — the dictionary the oracle used to be.
    var current: [Key: Value] { standing.compactMapValues { $0.last?.value } }

    /// This owner's OWN value under `key` (for a read-modify-write that must
    /// build on what it wrote, never on another window's).
    func value(for key: Key, owner: UUID) -> Value? {
        standing[key]?.first { $0.owner == owner }?.value
    }

    /// Register (or replace) this owner's value under `key` — it becomes
    /// the answer, as the last write always was.
    mutating func publish(_ value: Value, for key: Key, owner: UUID) {
        // The common case — a surface re-reporting a row it already answers
        // for — stays an in-place write (these arrive at geometry rate).
        if let last = standing[key]?.indices.last, standing[key]![last].owner == owner {
            standing[key]![last].value = value
            return
        }
        if let index = standing[key]?.firstIndex(where: { $0.owner == owner }) {
            standing[key]!.remove(at: index)
        } else {
            keysByOwner[owner, default: []].insert(key)
        }
        standing[key, default: []].append(Standing(owner: owner, value: value))
    }

    /// This owner stops answering for `key` — nobody else's entry moves.
    mutating func withdraw(_ key: Key, owner: UUID) {
        guard var list = standing[key],
              let index = list.firstIndex(where: { $0.owner == owner }) else { return }
        list.remove(at: index)
        standing[key] = list.isEmpty ? nil : list
        keysByOwner[owner]?.remove(key)
        if keysByOwner[owner]?.isEmpty == true { keysByOwner[owner] = nil }
    }

    /// A teardown: this owner's entries, under every key it holds, and only
    /// those. Releasing what you never published — or twice — is a no-op.
    mutating func release(owner: UUID) {
        guard let keys = keysByOwner.removeValue(forKey: owner) else { return }
        for key in keys {
            guard var list = standing[key] else { continue }
            list.removeAll { $0.owner == owner }
            standing[key] = list.isEmpty ? nil : list
        }
    }

    /// A PIN's door: forget `key` for every owner, unconditionally.
    mutating func forget(_ key: Key) {
        guard let list = standing.removeValue(forKey: key) else { return }
        for entry in list {
            keysByOwner[entry.owner]?.remove(key)
            if keysByOwner[entry.owner]?.isEmpty == true { keysByOwner[entry.owner] = nil }
        }
    }

    /// A PIN's door: forget everything, unconditionally.
    mutating func forgetAll() {
        standing = [:]
        keysByOwner = [:]
    }
}

/// An unkeyed oracle slot under the same rule — `OwnedRegistrations` with
/// one key. `Value` may itself be optional: a surface that says "nothing"
/// (`inspectorPanel` with no panel open) has REGISTERED nothing, which is a
/// different fact from not being on screen.
struct OwnedSlot<Value> {
    private var registrations = OwnedRegistrations<Bool, Value>()

    init() {}

    /// The most recent registrant's value.
    var value: Value? { registrations[true] }

    func value(owner: UUID) -> Value? { registrations.value(for: true, owner: owner) }

    mutating func publish(_ value: Value, owner: UUID) {
        registrations.publish(value, for: true, owner: owner)
    }

    mutating func withdraw(owner: UUID) { registrations.withdraw(true, owner: owner) }

    mutating func release(owner: UUID) { registrations.release(owner: owner) }

    /// A PIN's door, unconditional.
    mutating func forget() { registrations.forgetAll() }
}

/// **The bound on an append-only DEBUG log** (18k C4 — the 13u2 UNIT E
/// `TakeCardGeometry` rule, shared): a landing's trace or a preview's
/// realized-rows list used to grow for a DEBUG process's whole life, pruned
/// only by pins. Oldest out, because every question asked of these logs is
/// about the CURRENT landing or preview; big enough that no pin reaches it.
/// A log is not a registration — no owner's teardown can erase another's
/// lines — so the bound is its only change.
enum DebugOracleLog {
    static let limit = 4096

    static func bound<Element>(_ log: inout [Element]) {
        if log.count > limit { log.removeFirst(log.count - limit) }
    }
}

/// The owner a probe uses when no owning surface stands above it — never
/// released by any teardown (the pre-C4 behaviour, for that case only).
enum DebugOracleOwner {
    static let unowned = UUID(uuidString: "C4C4C4C4-0000-0000-0000-000000000000")!
}

struct DebugOracleOwnerKey: EnvironmentKey {
    static let defaultValue: UUID? = nil
}

extension EnvironmentValues {
    /// The owning surface's token, for the ROWS and probe modifiers that
    /// write its oracle (see the header). Set by the surface; nil elsewhere.
    var debugOracleOwner: UUID? {
        get { self[DebugOracleOwnerKey.self] }
        set { self[DebugOracleOwnerKey.self] = newValue }
    }
}
#endif
