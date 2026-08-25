//
//  SyncSafetyFace.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 13l, Act 5 (ledger row 17) — "did my writing reach the mirror?",
//  answerable at a glance. THIS FILE IS THE BRAIN; the words are the Mac's
//  (`Features/Settings/SyncSafetyWords.swift`) and the phone writes its own.
//
//  WHY THE SPLIT, and it was not a guess: the sentences started here and the
//  mobile no-redirect sweep (parity C5) failed on them within the hour,
//  because every one of them says "this Mac" — a phone that imported them
//  would talk about a machine it is not running on. That is the same lesson
//  `DataSafetyCopy` learned at Act 4, and the same rule: `Shared/` means BOTH
//  platforms compile it, so a face's words belong to a platform and a face's
//  FACTS belong here. The phone's twin is then a rendering job — the read
//  below and the shape of the answer are already done.
//
//  Her kickoff ruling 2 put this candidate IN, and ruling 3 gave it a home:
//  the Data Safety section's own line, beside the backup evidence. The
//  question it answers is a DATA-SAFETY question, which is why it lives
//  there and not only on the sync row in the main window: that row answers
//  "is sync working right now"; this answers "is anything I have written
//  still only on this device".
//
//  READ-SIDE ONLY, and that is a hard boundary this phase drew: the facts
//  are the outbox's row count and the pull cursor, both read straight from
//  the local store, plus the scheduler's own in-memory status. **Zero engine
//  lines** — nothing here triggers, configures, schedules, or observes a
//  round.
//
//  WHY THE READ IS RAW SQL AND NOT A `Queries` ROAD. `sync_outbox` and
//  `sync_state` are local-only sync MACHINERY (SyncSpec §3: never synced, no
//  domain semantics, no rows a view ever traverses). `Queries` is the domain
//  read layer, and putting the outbox in it would give every future reader
//  the impression that a dirty-row set is a thing views read. The app
//  already reads the outbox count exactly this way in `SyncSession`'s settle
//  observation; this keeps that precedent and puts the read in ONE named,
//  testable place instead of a view model body.
//

import Foundation
import GRDB
import VariorumCore

/// What the face knows. Every field is a FACT; the sentences are the
/// platform's, so the state can be pinned without rendering anything.
nonisolated struct SyncSafetyFacts: Sendable, Equatable {
    /// False for a dev-store session (the A4 fence) — it will never sync,
    /// and saying so is honest rather than alarming.
    var allowsSync: Bool
    /// A transport chain is composed (signed in and adopted).
    var isConfigured: Bool
    var signedIn: Bool
    /// Rows the outbox still owes the server, read from the store.
    var pending: Int
    /// The pull cursor (`sync_state.last_server_seq`) — nil when this store
    /// has never received anything from the account. The one piece of sync
    /// evidence that SURVIVES relaunch, which is why it is here beside the
    /// in-memory stamp below.
    var cursor: Int64?
    /// The last round that completed cleanly IN THIS LAUNCH (the scheduler's
    /// status is in-memory and starts empty every time — the words say so).
    var lastSuccessAt: Date?

    /// The local read: the outbox's size and the pull cursor, in one
    /// transaction so the two facts describe the same instant.
    static func read(_ db: Database) throws -> (pending: Int, cursor: Int64?) {
        let pending = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
        let cursor = try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        return (pending, cursor.flatMap(Int64.init))
    }

    /// Which of the five things is true — the SHAPE of the answer, decided
    /// once here so both platforms tell the same story in their own words.
    var standing: SyncSafetyStanding {
        guard allowsSync else { return .devStore }
        guard isConfigured else { return signedIn ? .signedInNotSyncing : .localOnly }
        return pending == 0 ? .allSent : .waiting(pending)
    }
}

/// The five standings. A platform's words render one of these; nobody
/// re-derives the rule.
nonisolated enum SyncSafetyStanding: Equatable, Sendable {
    /// The A4 fence: a development build never syncs.
    case devStore
    /// Not signed in. A complete, normal state — never a setup step owed.
    case localOnly
    /// Signed in, but no transport chain right now (a stale session, or an
    /// adoption that did not complete).
    case signedInNotSyncing
    case allSent
    case waiting(Int)

    /// True when this standing should be worn quietly rather than in a
    /// colour that asks for attention. Only a real backlog asks.
    var isCalm: Bool {
        if case .waiting = self { return false }
        return true
    }

    /// **How the line is PAINTED** (the post-13l polish round, ledger row 31
    /// — her words: *"a gentle green on fully synced might look nice"*).
    ///
    /// `isCalm` was a two-way answer, and her ruling asks for three: the
    /// settled state wants a gentle positive, a backlog wants attention, and
    /// **signed-out stays quiet** (her #75(d) ratification — being local-only
    /// is a complete, normal state, never a setup step owed). So the tone is
    /// the standing's own decision, decided once here, and each platform
    /// renders it through its voice vocabulary — never a literal colour.
    ///
    /// `isCalm` survives unchanged as the "does this ask for attention?"
    /// question its own pins ask; this is the finer answer beside it.
    enum Tone: Equatable, Sendable {
        /// Nothing to say — the ordinary voice.
        case quiet
        /// Everything this device has written has reached the account.
        case settled
        /// A real backlog: worth noticing.
        case attention
    }

    var tone: Tone {
        switch self {
        case .allSent: return .settled
        case .waiting: return .attention
        case .devStore, .localOnly, .signedInNotSyncing: return .quiet
        }
    }
}
