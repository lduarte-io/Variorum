import Dependencies
import Foundation
import GRDB

/// The Fragments journal bridge (Phase 9b). Variorum is the journal's HOME
/// and TRUTH; Fragments' `journal_entries` satellite is a co-writer
/// projection surface holding one plain-text body per calendar day. The
/// user-set `entry_date` IS the join key on both sides.
///
/// The two halves, run pull-first (the A3 order — reconcile before
/// projecting; also what makes first contact safe: every Fragments-known day
/// has bridge state before any push decision):
///
/// - **Pull + land:** keyset-pull `journal_entries`; land every incoming
///   body through ORDINARY Variorum operations — never a direct row write —
///   so S5's conflict-as-variant doctrine guards the truth side. Every
///   landing path ends in a live row, a labeled variant, or a commit:
///   nothing typed in Fragments can be lost by the bridge.
/// - **Push:** for each single-entry journal day whose rendered text differs
///   from the AGREED hash, upsert `renderedText` under the deterministic id.
///   Unchanged text never pushes (the mirror of Fragments' own clobber
///   guard — a pointless `updated_at` bump would LWW-beat a real Fragments
///   edit). A duplicate day (the documented offline race) pushes NOTHING,
///   visibly, until the author hand-merges — Fragments is DB-unique per
///   (user, date), so a slipped push would LWW-OVERWRITE one text with the
///   other there, the one forbidden outcome.
///
/// State (local-only, v1_4): `bridge_day.last_synced_hash` is the hash of
/// the last body BOTH surfaces agreed on — recorded on push-accept and on
/// every landing. It is simultaneously push's change detection, landing's
/// echo/replay skip, and the "who changed since agreement" classifier.
///
/// **Change detection is a hash sweep, deliberately** (Phase 9b design
/// call): correctness rides the rendered-text hash, never a stamp filter —
/// traced concretely, `chooseVariant`/`deleteBlock`/`deleteVariant` change
/// rendered text without stamping the container, so any stamp-based dirty
/// filter silently misses classes of change (a silent stale projection is
/// this bridge's worst failure shape). Cost is ∝ live journal days per
/// round, at round cadence, off-main; the scale note is recorded in
/// KnownIssues (owner: Phase 12) with the remedy sketch.
public struct BridgeEngine: Sendable {
    @Dependency(\.database) var database
    @Dependency(\.date) var date

    public let transport: any FragmentsBridgeTransport
    public let configuration: FragmentsBridgeConfiguration
    /// Pull window size (keyset pages).
    public var pullLimit: Int
    /// Push batch size per transport call.
    public var pushBatchSize: Int

    public init(
        transport: any FragmentsBridgeTransport,
        configuration: FragmentsBridgeConfiguration,
        pullLimit: Int = 200,
        pushBatchSize: Int = 100
    ) {
        self.transport = transport
        self.configuration = configuration
        self.pullLimit = pullLimit
        self.pushBatchSize = pushBatchSize
    }

    // MARK: - Reports

    public struct LandingReport: Equatable, Sendable {
        /// Entries minted (`createOrOpenJournalEntry` + `newBlock`).
        public var created = 0
        /// Bodies landed into the entry's single block (`autosave`, incl.
        /// deletion-emptied), each behind the fifth-occasion auto-commit.
        public var updated = 0
        /// Both-changed landings: the body became a `'fragments'` variant.
        public var conflictVariants = 0
        /// Graduated/sealed/locked landings rescued as `'fragments'` variants.
        public var rescuedVariants = 0
        /// Echoes, replays, already-converged, and deliberate skips.
        public var skipped = 0
        /// Rows that could not land THIS round (transient store states —
        /// e.g. a sync-race gap slot): the cursor holds before them and the
        /// next round retries, exactly the pull straggler posture.
        public var deferred = 0
        public var stalled = false
        public var notes: [String] = []
        public init() {}
    }

    public struct PushReport: Equatable, Sendable {
        public var pushed = 0
        /// LWW-stale outcomes: the server row is newer; the pull reconciles.
        public var stale = 0
        public var rejected = 0
        /// Days holding two or more live entries — pushed NOTHING, visibly,
        /// until the author hand-merges (never newest-wins).
        public var pausedDays: [String] = []
        public var notes: [String] = []
        public init() {}
    }

    public struct RoundReport: Equatable, Sendable {
        public var landing = LandingReport()
        public var push = PushReport()
        public init() {}
    }

    /// One bridge round: pull → land, then push.
    @discardableResult
    public func run() async throws -> RoundReport {
        var report = RoundReport()
        report.landing = try await pullAndLand()
        report.push = try await push()
        return report
    }

    // MARK: - Pull + landing (the doctrine's edge)

    @discardableResult
    public func pullAndLand() async throws -> LandingReport {
        var report = LandingReport()
        fetchLoop: while true {
            let cursor = try await database.read { try Self.cursor($0) }
            let window = try await transport.pull(after: cursor, limit: pullLimit)
            guard !window.isEmpty else { break }
            for entry in window {
                guard let serverStamp = entry.serverUpdatedAt else {
                    // A pulled row without a keyset stamp cannot advance the
                    // cursor — refuse the round rather than loop or guess.
                    throw FragmentsTransportError.malformedResult(
                        "pulled row \(entry.id) lacks server_updated_at")
                }
                let outcome = try await land(entry)
                if case .deferred(let note) = outcome {
                    // Straggler posture: the cursor holds BEFORE this row;
                    // the next round retries when the store state heals.
                    report.deferred += 1
                    report.stalled = true
                    report.notes.append(note)
                    break fetchLoop
                }
                try await database.write { db in
                    if let record = outcome.bookkeeping {
                        try Self.recordDay(
                            db, dayKey: record.day, hash: record.hash,
                            remoteStamp: record.remoteStamp)
                    }
                    try Self.setCursor(
                        db, FragmentsPullCursor(serverUpdatedAt: serverStamp, id: entry.id))
                }
                switch outcome {
                case .created: report.created += 1
                case .updated: report.updated += 1
                case .conflictVariant: report.conflictVariants += 1
                case .rescuedVariant: report.rescuedVariants += 1
                case .skipped(let note, _):
                    report.skipped += 1
                    if let note { report.notes.append(note) }
                case .deferred: break  // handled above
                }
            }
        }
        return report
    }

    /// Day bookkeeping a landing commits atomically with its cursor
    /// advance. `hash == nil` updates only the remote LWW stamp (the
    /// deletion-raced-an-edit case: no agreement, but the re-projection
    /// push still must outrank the tombstone's stamp).
    struct DayBookkeeping {
        let day: String
        let hash: String?
        let remoteStamp: String?
    }

    /// One incoming entry's disposition.
    private enum LandOutcome {
        case created(DayBookkeeping)
        case updated(DayBookkeeping)
        case conflictVariant(DayBookkeeping)
        case rescuedVariant(DayBookkeeping)
        case skipped(note: String?, record: DayBookkeeping?)
        case deferred(note: String)

        var bookkeeping: DayBookkeeping? {
            switch self {
            case .created(let record), .updated(let record),
                 .conflictVariant(let record), .rescuedVariant(let record):
                return record
            case .skipped(_, let record):
                return record
            case .deferred:
                return nil
            }
        }
    }

    /// The landing classifier — the 9b brief's rules, verbatim in code.
    ///
    /// Check-then-act honesty (same class as Phase 9 round 3's documented
    /// residual): classification reads and the operation calls are separate
    /// transactions, so a local edit can land in the ms-wide window between
    /// them. The fifth-occasion auto-commit runs AFTER any such edit
    /// (writes serialize at the store), so the raced text is committed
    /// before the landing overwrites — recoverable by construction, which
    /// is the doctrine's bar. Op-level expected-text preconditions would be
    /// a core change without cause.
    private func land(_ entry: FragmentsEntry) async throws -> LandOutcome {
        // Not ours / not joinable: consumed with a note, never a crash.
        guard entry.userID == configuration.userID else {
            return .skipped(note: "foreign user_id row \(entry.id) ignored", record: nil)
        }
        let day = entry.date
        guard JournalDay.isValid(day) else {
            return .skipped(note: "malformed day '\(day)' from Fragments ignored", record: nil)
        }
        let effectiveBody = entry.isTombstoned ? "" : entry.body
        let incomingHash = BridgeHash.body(effectiveBody)
        let agreed = DayBookkeeping(
            day: day, hash: incomingHash, remoteStamp: entry.updatedAt)

        var context = try await readDayContext(day: day)

        // Echo / replay: the surfaces already agreed on exactly this body
        // (our own push coming back on the feed; a re-served row after a
        // partial round). Nothing to do.
        if incomingHash == context.state {
            return .skipped(note: nil, record: agreed)
        }

        let ops = Operations()

        // No live entry for the date → create-or-open, never blind create
        // (the notebook rule). An incoming tombstone/empty body creates
        // nothing — there is nothing to land.
        if context.target == nil {
            if effectiveBody.isEmpty {
                return .skipped(note: nil, record: agreed)
            }
            _ = try ops.createOrOpenJournalEntry(entryDate: day)
            context = try await readDayContext(day: day)
            guard context.target != nil else {
                return .deferred(note: "entry for \(day) vanished mid-landing")
            }
        }
        let target = context.target!

        // Empty entry (no blocks yet): the body becomes THE block.
        if context.slots.isEmpty {
            if effectiveBody.isEmpty {
                return .skipped(note: nil, record: agreed)
            }
            do {
                _ = try ops.newBlock(in: target.id, text: entry.body, at: .end)
                return .created(agreed)
            } catch OperationError.lockedPost {
                // Sealed EMPTY entry: no block exists to carry a rescue
                // variant, and the seal refuses the mint. Documented
                // residual (closeout): the row is consumed with a note —
                // the body stays safe in Fragments; no state is recorded,
                // so no push can overwrite it with emptiness.
                return .skipped(
                    note: "sealed empty entry \(day): landing refused by the seal; body remains in Fragments",
                    record: nil)
            }
        }

        // A gap slot (block/variant rows mid-sync-race) can neither be
        // edited nor carry a rescue variant — stall, retry next round.
        if context.slots.contains(where: \.isGap) {
            return .deferred(note: "day \(day) has a gap slot (sync race); retrying next round")
        }

        let rendered = context.renderedText
        // Already converged (state was stale — e.g. a crash between ops and
        // the state write): record the agreement, write nothing.
        if effectiveBody == rendered {
            return .skipped(note: nil, record: agreed)
        }

        let isGraduated = context.slots.count > 1
            || context.slots.contains { $0.activeVariantCount > 1 }
        let firstSlot = context.slots[0]
        let firstVariantID = firstSlot.variantID!  // non-gap guaranteed above

        // The graduated-entry policy (RATIFIED): push-only; ANY incoming
        // edit lands as a 'fragments' variant on the FIRST block — never
        // diff-mapped back across blocks (OverallModel §8).
        if isGraduated {
            if entry.isTombstoned {
                // A projection-side deletion of a graduated day: a blank
                // card is noise; recording the agreed-empty state makes the
                // next push re-project the rendered truth (un-tombstoning
                // under their strictly-newer rule). Nothing incoming is lost.
                return .skipped(
                    note: "Fragments deletion of graduated day \(day): truth re-projects",
                    record: agreed)
            }
            if try await hasLiveVariant(blockID: firstSlot.blockID, text: entry.body) {
                return .skipped(note: nil, record: agreed)  // replay dedupe
            }
            _ = try ops.resolveSyncConflict(
                firstVariantID, losingText: entry.body, label: "fragments")
            return .rescuedVariant(agreed)
        }

        // Single unfanned block — the two-way regime.
        // Sealed post / locked variant: autosave would refuse, and refusing
        // the landing would strand the body — the S5-outranks-the-seal
        // posture (AppSpec §14, 2026-07-06) lands it as a variant instead.
        if context.containerLocked || firstSlot.variantLocked {
            if effectiveBody.isEmpty {
                return .skipped(
                    note: "Fragments deletion of sealed/locked day \(day): truth re-projects",
                    record: agreed)
            }
            if try await hasLiveVariant(blockID: firstSlot.blockID, text: entry.body) {
                return .skipped(note: nil, record: agreed)
            }
            _ = try ops.resolveSyncConflict(
                firstVariantID, losingText: entry.body, label: "fragments")
            return .rescuedVariant(agreed)
        }

        let onlyFragmentsChanged = BridgeHash.body(rendered) == context.state

        if onlyFragmentsChanged {
            // The fifth quiet auto-commit occasion (author, 2026-07-07) +
            // insurance of the LANDED BODY itself, composed in ONE
            // transaction (review round 1, MAJOR 1): the pre-image is
            // committed if dirty (already-committed-identical takes no
            // double commit), the body overwrites, and the non-empty body
            // is then committed too — so even the open editor's
            // keep-pending flush (seconds later) cannot make the Fragments
            // text unreachable while the next push replaces it server-side.
            // Landings are pull-cadence, so both commits stay bounded.
            _ = try ops.applyBridgeLanding(
                firstVariantID, in: target.id, body: effectiveBody)
            return .updated(agreed)
        }

        // Both changed since the last agreement.
        if entry.isTombstoned {
            // A deletion racing a Variorum edit: the edit outranks a
            // projection-side deletion of STALE text (the tombstone-rescue
            // doctrine's shape, SyncSpec §6). No hash is recorded — the
            // push half re-projects the live text — but the tombstone's LWW
            // stamp is, so the re-projection outranks it.
            return .skipped(
                note: "Fragments deletion of \(day) raced a Variorum edit: the edit survives, truth re-projects",
                record: DayBookkeeping(day: day, hash: nil, remoteStamp: entry.updatedAt))
        }
        if try await hasLiveVariant(blockID: firstSlot.blockID, text: entry.body) {
            return .skipped(note: nil, record: agreed)  // replay dedupe
        }
        // Conflict-as-variant, second writer: Variorum keeps BOTH texts —
        // the entry's own text stays live, the Fragments body becomes a
        // 'fragments' card. Recording the incoming hash as the agreed state
        // makes the next push re-project Variorum's truth (Fragments is
        // momentarily behind — the brief's edit-war asymmetry).
        _ = try ops.resolveSyncConflict(
            firstVariantID, losingText: entry.body, label: "fragments")
        return .conflictVariant(agreed)
    }

    // MARK: - Push (the projection half)

    @discardableResult
    public func push() async throws -> PushReport {
        var report = PushReport()
        let now = DateFormatter.variorumISO8601.string(from: date.now)

        struct Candidate: Sendable {
            let day: String
            let body: String
            let hash: String
            /// The last landed row's client-LWW stamp for this day: the
            /// push must outrank it or truth's re-projection is forever
            /// `.stale` under a clock ahead of ours.
            let remoteStamp: String?
        }
        let scan: (candidates: [Candidate], paused: [String], notes: [String]) =
            try await database.read { db in
                var candidates: [Candidate] = []
                var paused: [String] = []
                var notes: [String] = []
                // Live journal entries, day-grouped, in the notebook rule's
                // preference order within each day.
                let rows = try Row.fetchAll(
                    db,
                    sql: """
                        SELECT id, entry_date FROM container
                        WHERE kind = 'post' AND profile = 'journal'
                          AND entry_date IS NOT NULL AND deleted_at IS NULL
                        ORDER BY entry_date ASC,
                                 (archived_at IS NOT NULL) ASC, created_at ASC, id ASC
                        """)
                var byDay: [String: [String]] = [:]
                var dayOrder: [String] = []
                for row in rows {
                    let day: String = row["entry_date"]
                    if byDay[day] == nil { dayOrder.append(day) }
                    byDay[day, default: []].append(row["id"])
                }
                for day in dayOrder {
                    let entryIDs = byDay[day]!
                    guard JournalDay.isValid(day) else {
                        notes.append("entry \(entryIDs[0]) has malformed entry_date '\(day)'; not bridged")
                        continue
                    }
                    guard entryIDs.count == 1 else {
                        // The duplicate-day pause: never newest-wins — a
                        // slipped push would LWW-overwrite one text with
                        // the other on the Fragments side.
                        paused.append(day)
                        continue
                    }
                    let rendered = try Queries.renderedText(db, containerID: entryIDs[0])
                    let hash = BridgeHash.body(rendered)
                    let state = try Self.dayRow(db, dayKey: day)
                    let agreedHash = state?.hash ?? nil  // nil row OR stamp-only row
                    if hash == agreedHash { continue }  // unchanged never pushes
                    if rendered.isEmpty && agreedHash == nil {
                        // Never a FIRST push of emptiness: it could only
                        // LWW-blank a Fragments body the bridge has not
                        // landed (the pull, run first, normally prevents
                        // the state from being nil for Fragments-known
                        // days — this guards the residual corners).
                        continue
                    }
                    candidates.append(Candidate(
                        day: day, body: rendered, hash: hash,
                        remoteStamp: state?.remoteStamp ?? nil))
                }
                return (candidates, paused, notes)
            }
        report.pausedDays = scan.paused
        report.notes = scan.notes

        var index = 0
        while index < scan.candidates.count {
            let chunk = Array(scan.candidates[index..<min(index + pushBatchSize, scan.candidates.count)])
            index += chunk.count
            let entries = chunk.map { candidate in
                let stamp = Self.pushStamp(now: now, outranking: candidate.remoteStamp)
                return FragmentsEntry(
                    id: configuration.entryID(dayKey: candidate.day)!,  // validity checked in the scan
                    userID: configuration.userID,
                    date: candidate.day,
                    body: candidate.body,
                    createdAt: stamp,
                    updatedAt: stamp,
                    deletedAt: nil)
            }
            let outcomes = try await transport.push(entries)
            guard outcomes.count == chunk.count else {
                throw FragmentsTransportError.mismatchedResultCount(
                    pushed: chunk.count, returned: outcomes.count)
            }
            var accepted: [(day: String, hash: String)] = []
            for (candidate, outcome) in zip(chunk, outcomes) {
                switch outcome {
                case .applied:
                    accepted.append((candidate.day, candidate.hash))
                    report.pushed += 1
                case .stale:
                    // The server row is newer (a Fragments edit won LWW):
                    // record nothing; the next pull lands their text and
                    // re-classifies.
                    report.stale += 1
                case .rejected(let reason):
                    report.rejected += 1
                    report.notes.append("push of \(candidate.day) rejected: \(reason)")
                }
            }
            if !accepted.isEmpty {
                let records = accepted
                try await database.write { db in
                    for record in records {
                        try Self.recordDay(
                            db, dayKey: record.day, hash: record.hash, remoteStamp: nil)
                    }
                }
            }
        }
        return report
    }

    // MARK: - Day context (classification reads)

    private struct DayContext: Sendable {
        var state: String?
        var target: Container?
        var slots: [Queries.RenderedBlock]
        var renderedText: String
        var containerLocked: Bool
    }

    private func readDayContext(day: String) async throws -> DayContext {
        try await database.read { db in
            let state = try Self.dayState(db, dayKey: day)
            // The notebook rule's preference order — the same entry
            // `createOrOpenJournalEntry` would open (duplicate-day landings
            // go to the day's canonical entry while push pauses).
            guard let target = try Container.fetchOne(
                db,
                sql: """
                    SELECT * FROM container
                    WHERE kind = 'post' AND profile = 'journal'
                      AND entry_date = ? AND deleted_at IS NULL
                    ORDER BY (archived_at IS NOT NULL) ASC, created_at ASC, id ASC
                    LIMIT 1
                    """,
                arguments: [day])
            else {
                return DayContext(
                    state: state, target: nil, slots: [], renderedText: "",
                    containerLocked: false)
            }
            let slots = try Queries.renderPost(db, containerID: target.id)
            let rendered = try Queries.renderedText(db, containerID: target.id)
            return DayContext(
                state: state, target: target, slots: slots,
                renderedText: rendered, containerLocked: target.locked)
        }
    }

    /// Replay dedupe: a live variant already carrying exactly this text on
    /// the block means a prior (crashed-before-state-write) landing already
    /// rescued it — a second card would be a duplicate, not insurance.
    private func hasLiveVariant(blockID: String, text: String) async throws -> Bool {
        try await database.read { db in
            try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (
                      SELECT 1 FROM variant
                      WHERE block_id = ? AND deleted_at IS NULL AND working_text = ?
                    )
                    """,
                arguments: [blockID, text]) ?? false
        }
    }

    // MARK: - Local bridge state (v1_4; local-only, never synced)

    static func cursor(_ db: Database) throws -> FragmentsPullCursor? {
        guard
            let stamp = try String.fetchOne(
                db, sql: "SELECT value FROM bridge_state WHERE key = 'cursor_server_updated_at'"),
            let id = try String.fetchOne(
                db, sql: "SELECT value FROM bridge_state WHERE key = 'cursor_id'")
        else { return nil }
        return FragmentsPullCursor(serverUpdatedAt: stamp, id: id)
    }

    static func setCursor(_ db: Database, _ cursor: FragmentsPullCursor) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO bridge_state (key, value) VALUES ('cursor_server_updated_at', ?), ('cursor_id', ?)",
            arguments: [cursor.serverUpdatedAt, cursor.id])
    }

    static func dayState(_ db: Database, dayKey: String) throws -> String? {
        try dayRow(db, dayKey: dayKey)?.hash ?? nil
    }

    static func dayRow(
        _ db: Database, dayKey: String
    ) throws -> (hash: String?, remoteStamp: String?)? {
        guard let row = try Row.fetchOne(
            db,
            sql: "SELECT last_synced_hash, last_remote_stamp FROM bridge_day WHERE day_key = ?",
            arguments: [dayKey])
        else { return nil }
        return (row["last_synced_hash"], row["last_remote_stamp"])
    }

    /// `hash == nil` records the remote stamp WITHOUT an agreement — the
    /// hash column stays whatever it was (NULL for a virgin day: review
    /// round 1, MINOR 3 — the old UPDATE-only form silently no-opped on
    /// days with no row, losing the stamp and re-opening the `.stale`
    /// wedge). A nil `remoteStamp` never clobbers a recorded one
    /// (push-accepts know no remote stamp).
    static func recordDay(
        _ db: Database, dayKey: String, hash: String?, remoteStamp: String?
    ) throws {
        if let hash {
            try db.execute(
                sql: """
                    INSERT INTO bridge_day (day_key, last_synced_hash, last_remote_stamp)
                    VALUES (?, ?, ?)
                    ON CONFLICT(day_key) DO UPDATE SET
                      last_synced_hash = excluded.last_synced_hash,
                      last_remote_stamp = COALESCE(excluded.last_remote_stamp, bridge_day.last_remote_stamp)
                    """,
                arguments: [dayKey, hash, remoteStamp])
        } else if let remoteStamp {
            try db.execute(
                sql: """
                    INSERT INTO bridge_day (day_key, last_synced_hash, last_remote_stamp)
                    VALUES (?, NULL, ?)
                    ON CONFLICT(day_key) DO UPDATE SET
                      last_remote_stamp = excluded.last_remote_stamp
                    """,
                arguments: [dayKey, remoteStamp])
        }
    }

    // MARK: - Push stamps (client LWW)

    /// The push's client-LWW `updated_at`: now, bumped past the last landed
    /// remote stamp when that stamp is ahead of us — a re-projection is a
    /// LATER editorial event than the row it answers, and without the bump
    /// a clock ahead of ours (her phone) leaves truth's re-projection
    /// permanently `.stale` under strict row-LWW. Unparseable remote stamps
    /// fall back to now (the wedge then self-heals with real clocks; ask
    /// filed for their exact stamp format).
    static func pushStamp(now: String, outranking remoteStamp: String?) -> String {
        guard let remoteStamp,
              let remote = parseStamp(remoteStamp),
              let local = parseStamp(now),
              remote >= local
        else { return now }
        return DateFormatter.variorumISO8601.string(from: remote.addingTimeInterval(1))
    }

    static func parseStamp(_ stamp: String) -> Date? {
        if let date = DateFormatter.variorumISO8601.date(from: stamp) { return date }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: stamp) { return date }
        iso.formatOptions = [.withInternetDateTime]
        return iso.date(from: stamp)
    }
}
