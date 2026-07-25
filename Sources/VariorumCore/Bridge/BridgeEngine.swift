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
///   nothing typed in Fragments can be lost by the bridge. A landing that
///   wrote to a day then shelves that day's entry in the designated daily
///   journal book, exactly as the Mac's ⌘J door does (A1, Phase 13c) —
///   never blocking the landing, never re-shelving what the author removed.
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
    /// Pull window size (keyset pages; Fragments' own convention is 500,
    /// paging while a page comes back full).
    public var pullLimit: Int

    public init(
        transport: any FragmentsBridgeTransport,
        configuration: FragmentsBridgeConfiguration,
        pullLimit: Int = 500
    ) {
        self.transport = transport
        self.configuration = configuration
        self.pullLimit = pullLimit
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
        /// LWW-skipped outcomes (their aggregate `skipped`): the server row
        /// is newer; the pull reconciles. (Ties go to the PUSHER under
        /// migration 7's `>=` — a skip means strictly older.)
        public var stale = 0
        /// Conflict refusals (`clock_ahead:` parks — retried as the clock
        /// catches up; `unique_violation` poisons the day permanently).
        public var rejected = 0
        /// Days holding two or more live entries — pushed NOTHING, visibly,
        /// until the author hand-merges (never newest-wins).
        public var pausedDays: [String] = []
        /// Unseen Fragments bodies destroyed by our own winning pushes and
        /// rescued as 'fragments' takes — 15.7 `replaced` receipts that
        /// survived the three discrimination rules (contract ask 13).
        public var rescuedReceipts = 0
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
            let fullPage = window.count == pullLimit
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
                            remoteStamp: record.remoteStamp,
                            remoteCreatedAt: record.remoteCreatedAt)
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
                // A1 (Phase 13c): the day's entry belongs on the shelf. This
                // runs AFTER the body is in the store and the cursor has
                // advanced, and it can only ever add a NOTE — the landing is
                // never blocked by shelving (see the helper's contract).
                if outcome.wroteToTheDay,
                   let note = await ensureDailyBookMembership(day: entry.date) {
                    report.notes.append(note)
                }
            }
            // Their paging convention: a short page is the head — stop
            // (one fewer RPC per round than loop-until-empty).
            if !fullPage { break }
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
        let remoteCreatedAt: String?
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

        /// The landing wrote to the day's entry (minted it, overwrote its
        /// text, or added a take). Echoes, replays, already-converged rows
        /// and consumed-with-a-note rows wrote NOTHING, so they trigger no
        /// shelving work.
        var wroteToTheDay: Bool {
            switch self {
            case .created, .updated, .conflictVariant, .rescuedVariant:
                return true
            case .skipped, .deferred:
                return false
            }
        }
    }

    // MARK: - The daily journal book's membership (A1, Phase 13c)

    /// **The second half of the Mac's daily door, which the bridge never
    /// had** (author report 2026-07-25: *"fragments journal did sync and
    /// appear, but not in the journal book, just appeared in the pool"*).
    /// Traced in her own store before the fix: her 2026-07-11 entry was
    /// created 17 s after the Fragments row it landed and carried no
    /// `reading_post` row at all.
    ///
    /// The RULES live once, in `Operations.shelveInDailyJournalBook` (never
    /// throws; a decided pair — live or tombstoned membership — is left
    /// alone; no designated book is reported, never invented), shared with
    /// the phone's capture door so the class cannot recur one door at a
    /// time. What is bridge-specific is only the WORDING: a landing that
    /// could not shelve says so on the round's own note surface, which the
    /// status row already renders as "needs attention".
    private func ensureDailyBookMembership(day: String) async -> String? {
        let postID: String?
        do {
            postID = try await database.read { db in
                // The notebook rule's canonical entry — the same one the
                // landing wrote to (one shared query).
                try Queries.canonicalJournalEntry(db, day: day)?.id
            }
        } catch {
            // 13c Stage 1 ladder, R1-11: a `try?` here collapsed a READ
            // FAILURE into "there is no entry for that day" — the one silent
            // path in a flow whose whole discipline is to speak. The entry is
            // already safely in the store (the landing ran first); only the
            // shelving is unknown, and the next round retries it.
            return Self.unshelvedNote(
                day: day,
                because: "the store could not be read to find that day's entry — the next bridge round retries it")
        }
        // No entry for the day is not a failure: nothing to shelve.
        guard let postID else { return nil }
        switch Operations().shelveInDailyJournalBook(postID) {
        case .shelved, .alreadyDecided:
            return nil
        case .noDailyBook:
            return Self.unshelvedNote(
                day: day,
                because: "no daily journal book is designated — open Today's Entry (⌘J), or pick one with a book's “Use as Daily Journal”")
        case .bookFinished:
            return Self.unshelvedNote(
                day: day,
                because: "the daily journal book is finished — reopen it in its settings, or pick a new daily journal")
        case .bookAtCapacity:
            return Self.unshelvedNote(
                day: day,
                because: "the daily journal book is at its post cap — extend the cap in the book's settings")
        case .wrongKind:
            return Self.unshelvedNote(
                day: day,
                because: "the designated daily journal is a SMART book, which collects by query and cannot hold memberships — pick a curated book with “Use as Daily Journal”")
        case .refused(let reason):
            return Self.unshelvedNote(day: day, because: reason)
        }
    }

    private static func unshelvedNote(day: String, because reason: String) -> String {
        "\(day) landed from Fragments but is not in the daily journal book "
            + "(find it in the Pool): \(reason)."
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
        // The row's LWW bar: updated_at for live rows; for tombstones the
        // resurrect bar is the TOMBSTONE's deleted_at (migration 7's exact
        // predicate — addendum precision), so the re-projection must
        // outrank THAT.
        let remoteLWWStamp = entry.deletedAt ?? entry.updatedAt
        let agreed = DayBookkeeping(
            day: day, hash: incomingHash, remoteStamp: remoteLWWStamp,
            remoteCreatedAt: entry.createdAt)

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
                // variant, and the seal refuses the mint. DEFER — the
                // cursor holds and the round is visibly stalled until the
                // author unseals, whereupon the held row re-serves and
                // lands normally (review round 3, MAJOR; supersedes the
                // rounds-1/2 consumed-with-a-note reading, whose "the body
                // stays safe in Fragments" was true only WHILE sealed:
                // consuming the row left the body behind the cursor with
                // no state, and the first post-unseal push — no agreed
                // hash, no remote stamp, `now` fallback — LWW-destroyed it
                // everywhere. Stalling is safe by design; guessing is the
                // forbidden move. PROVISIONAL shape (a) of two — see the
                // closeout's round-3 section and QUESTIONS #14(c)).
                return .deferred(
                    note: "sealed empty entry \(day): landing refused by the seal; the feed holds until it is unsealed")
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
                record: DayBookkeeping(
                    day: day, hash: nil, remoteStamp: remoteLWWStamp,
                    remoteCreatedAt: entry.createdAt))
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
        // Durably-preserved unrescued bodies re-surface EVERY round until
        // cleared by hand (review round 2, MAJOR — the poison-note posture:
        // the producing receipt was one-shot, so the persistence does the
        // recurring; a single ephemeral note in a replaceable tooltip was
        // not preservation).
        report.notes = try await database.read { try Self.unrescuedBodyNotes($0) }
        let now = DateFormatter.variorumISO8601.string(from: date.now)

        struct Candidate: Sendable {
            let day: String
            let body: String
            let hash: String
            /// The day's agreed hash BEFORE this push — the body the bridge
            /// last pulled or pushed; discrimination rule (i)'s input for a
            /// 15.7 `replaced` receipt riding the response.
            let agreedHash: String?
            /// The last landed row's client-LWW stamp for this day: the
            /// push must outrank it or truth's re-projection is forever
            /// `.stale` under a clock ahead of ours.
            let remoteStamp: String?
            /// The row's created_at as last pulled/pushed — echoed on every
            /// push (created_at follows the WINNING push server-side).
            let remoteCreatedAt: String?
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
                    let slots = try Queries.renderPost(db, containerID: entryIDs[0])
                    if slots.contains(where: \.isGap) {
                        // A gap slot (referenced-but-missing rows mid-sync)
                        // renders as nothing, so the day's rendered text is
                        // PARTIAL — projecting it would push a body missing
                        // a block's text (and could overwrite an unseen
                        // save the landing half just deferred on). The
                        // landing half already refuses to classify this
                        // store state; the push half now agrees (review
                        // round 3, MINOR 1). Self-heals when the gap fills.
                        notes.append("day \(day) has a gap slot (sync race); push skipped until it heals")
                        continue
                    }
                    // The ONE join brain (Phase 10, author ruling
                    // 2026-07-12 — spacing preservation): the pushed body
                    // must equal `Queries.renderedText` for the same slots,
                    // so this projects through the same conditional join
                    // (the previous inline `"\n\n"` join was a byte-level
                    // duplicate of the old renderedText; a divergence here
                    // would silently push a different body than the export
                    // and the landing half compare against). No engine
                    // logic changes — the join expression is swapped for
                    // the canonical helper it duplicated.
                    let rendered = Queries.joinRenderedTexts(
                        slots.compactMap(\.text).filter { !$0.isEmpty })
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
                        agreedHash: agreedHash,
                        remoteStamp: state?.remoteStamp ?? nil,
                        remoteCreatedAt: state?.remoteCreatedAt ?? nil))
                }
                return (candidates, paused, notes)
            }
        report.pausedDays = scan.paused
        // APPEND — the report already carries the re-surfaced unrescued
        // bodies loaded above; assignment here silently dropped them
        // (caught by the round-2 pin on first run).
        report.notes.append(contentsOf: scan.notes)

        guard !scan.candidates.isEmpty else { return report }

        // THE FAIL-CLOSED GATE (reconciliation, asks 9/10 ANSWERED): the
        // canonical-user key for id derivation is
        // `user_settings.local_user_id` — minted by Fragments' first
        // device, distinct from the auth uid by design, read from the
        // server, NEVER guessed. No row yet ⇒ the account has not synced
        // from Fragments ⇒ pushing would claim canon with a
        // Variorum-invented id: hold ALL pushes, visibly, until it exists.
        // (Re-resolved per round — their ID FREEZE makes it immutable once
        // minted, so this is one cheap RPC.)
        guard let canonicalUser = try await transport.fetchLocalUserID() else {
            report.notes.append(
                "Fragments account not yet synced (no user_settings.local_user_id) — pushes held, fail-closed")
            return report
        }

        // ONE push call PER DAY (reconciliation, ask 11 ANSWERED): the
        // response is aggregate counters — with one row per call,
        // `applied == 1` is unambiguous.
        for candidate in scan.candidates {
            if let poison = try await database.read({ try Self.poisonNote($0, dayKey: candidate.day) }) {
                // unique_violation = a mis-derived id, a DERIVATION BUG:
                // surfaced permanently, never retried (their confirmed
                // treatment — the unique index is the safety net).
                report.rejected += 1
                report.notes.append("day \(candidate.day) held (derivation bug, never retried): \(poison)")
                continue
            }
            let stamp = Self.pushStamp(now: now, outranking: candidate.remoteStamp)
            let entry = FragmentsEntry(
                id: FragmentsContract.entryID(
                    namespace: configuration.idNamespace,
                    canonicalUser: canonicalUser,
                    dayKey: candidate.day)!,  // day validity checked in the scan
                userID: configuration.userID,
                date: candidate.day,
                body: candidate.body,
                // Echo the pulled created_at; our own creation instant only
                // for a row we have never seen (ask 12 ANSWERED —
                // created_at follows the WINNING push, so echoing is what
                // preserves the original instant).
                createdAt: candidate.remoteCreatedAt ?? stamp,
                updatedAt: stamp,
                deletedAt: nil)
            let response = try await transport.push([entry])
            if response.applied == 1 {
                // The 15.7 `replaced` receipts FIRST (contract ask 13 — LIVE
                // per their 2026-07-11 deploy ping): a receipt is delivered
                // EXACTLY ONCE — an identical re-push draws no second one —
                // so it is consumed BEFORE anything else that can throw
                // (cold review, MAJOR 1: consuming after recordDay let a
                // rescue-path error drop the only copy, and the scheduler's
                // "the day hashes keep everything, the next trigger retries"
                // premise is FALSE for receipts — the recorded hash already
                // matches, so nothing re-pushes). consumeReplacedReceipt
                // never throws; every failure arm preserves the full body
                // visibly. A receipt means "this push replaced a differing
                // live body", NOT "loss" — classification is OURS, never
                // unconditional. A receipt for an id we did not push is a
                // drifting server (impossible per the verified SQL) —
                // surfaced with its body, never silently dropped (review NIT).
                for receipt in response.replaced ?? [] {
                    guard receipt.id == entry.id else {
                        // Durably, like every only-copy arm (review round 3,
                        // NIT — this belt was the one arm round 2's fix
                        // missed; in the drifting-server world it exists
                        // for, this body may be someone's only copy too).
                        report.notes.append(await preserveUnrescuedBody(
                            day: candidate.day,
                            note: "push of \(candidate.day): the server returned a receipt for a row we did not push (\(receipt.id)) — not consumed (server drift?); its body, preserved: \(receipt.previousBody)"))
                        continue
                    }
                    let outcome = await consumeReplacedReceipt(
                        receipt, day: candidate.day, pushedBody: candidate.body,
                        agreedHashBeforePush: candidate.agreedHash)
                    if outcome.rescued { report.rescuedReceipts += 1 }
                    if let note = outcome.note { report.notes.append(note) }
                }
                // Record the accepted push's own stamps (round 2's
                // companion fix + the created_at echo source). AFTER the
                // consumption above, deliberately: if THIS write throws,
                // the rescue already landed, the agreed hash stays stale,
                // and the next round re-pushes the identical body — which
                // the server applies with NO new receipt (identical-body
                // predicate) — and records then; nothing is lost either way.
                let record = (day: candidate.day, hash: candidate.hash,
                              stamp: entry.updatedAt, createdAt: entry.createdAt)
                try await database.write { db in
                    try Self.recordDay(
                        db, dayKey: record.day, hash: record.hash,
                        remoteStamp: record.stamp, remoteCreatedAt: record.createdAt)
                }
                report.pushed += 1
            } else if let conflict = response.conflicts.first {
                report.rejected += 1
                if conflict.isUniqueViolation {
                    // Poison the day: visible every round, never re-pushed.
                    let day = candidate.day
                    let note = conflict.error
                    try await database.write { db in
                        try Self.setPoisonNote(db, dayKey: day, note: note)
                    }
                    report.notes.append(
                        "push of \(candidate.day) refused (derivation bug — day held permanently): \(conflict.error)")
                } else if conflict.isClockAhead {
                    // Parked: the clamp self-heals as the wall clock
                    // catches up; surfaced every round meanwhile.
                    report.notes.append(
                        "push of \(candidate.day) parked (clock ahead — retried as the clock catches up): \(conflict.error)")
                } else {
                    report.notes.append("push of \(candidate.day) refused: \(conflict.error)")
                }
            } else {
                // skipped == 1: the server row is newer (an unseen
                // Fragments save won LWW — ties go to the PUSHER under
                // migration 7's >=, so a skip means strictly older):
                // record nothing; the next pull lands their text and
                // re-classifies.
                report.stale += 1
            }
        }
        return report
    }

    /// Contract ask 13's consumption path (Fragments 15.7, deployed —
    /// their 2026-07-11 ping; SQL verified in their repo the same day).
    /// The receipt is genuine-OVERWRITE-only, so consuming it
    /// unconditionally would self-conflict on every ordinary edit; the
    /// THREE DISCRIMINATION RULES (their recommendation, recorded in the
    /// contract) classify instead:
    ///  (i)   the destroyed body is the one the bridge last pulled/pushed
    ///        for this day → our own knowing replacement — no-op;
    ///  (ii)  it is contained in the body just pushed → a superset/merge
    ///        push (e.g. a Fragments-side inline conflicted copy we
    ///        re-projected) — no-op;
    ///  (iii) otherwise it is text the bridge NEVER SAW, destroyed
    ///        server-side by our winning push — the loss case, the only
    ///        one: rescued as a 'fragments' take through the same
    ///        conflict-as-variant door as the landing half (replay-deduped
    ///        the same way). This closes the 9b closeout's "first-push
    ///        overwrite window" residual for every in-process path (the
    ///        honest remainder: a process death between the server applying
    ///        the push and the rescue/durable-preservation write — or that
    ///        write itself failing — loses the one-shot receipt; vanishingly
    ///        narrow, recorded in the contract addendum).
    ///
    /// NEVER THROWS (cold review, MAJOR 1): the receipt is delivered
    /// exactly once, so a propagated error here would drop the only copy of
    /// the destroyed body — the scheduler's retry cannot recover it (the
    /// day hash already matches; an identical re-push draws no receipt).
    /// Every failure arm returns a note carrying the FULL body instead.
    private func consumeReplacedReceipt(
        _ receipt: FragmentsReplacedReceipt, day: String,
        pushedBody: String, agreedHashBeforePush: String?
    ) async -> (rescued: Bool, note: String?) {
        // Never emitted for an empty prior body (their SQL: prev_body <> '');
        // belt against a server that drifts.
        guard !receipt.previousBody.isEmpty else { return (false, nil) }
        // (i) — a knowing replacement of the body we already hold.
        if BridgeHash.body(receipt.previousBody) == agreedHashBeforePush {
            return (false, nil)
        }
        // (ii) — the destroyed body rode along inside what we pushed.
        if pushedBody.contains(receipt.previousBody) {
            return (false, nil)
        }
        // (iii) — rescue.
        do {
            let context = try await readDayContext(day: day)
            guard let firstSlot = context.slots.first, !firstSlot.isGap,
                  let firstVariantID = firstSlot.variantID else {
                // REACHABLE, not defensive (cold review, MAJOR 2 — the
                // shipped "defensively unreachable" claim was falsified):
                // the author empties a day and the empty re-projection —
                // designed behavior — destroys an unseen save that had won
                // inside the stamp-quantization tie window; no slot exists
                // to carry a take. Minting a block here would resurrect
                // content she just emptied — a product call deliberately
                // NOT made (option (b) in the review; hers if ever wanted).
                // The body is durably preserved instead (round 2, MAJOR).
                return (false, await preserveUnrescuedBody(
                    day: day, note: Self.unrescuedBodyNote(day: day, body: receipt.previousBody)))
            }
            if try await hasLiveVariant(blockID: firstSlot.blockID, text: receipt.previousBody) {
                return (false, nil)  // replay dedupe — a prior round already rescued it
            }
            let ops = Operations()
            _ = try ops.resolveSyncConflict(
                firstVariantID, losingText: receipt.previousBody, label: "fragments")
            return (true,
                "push of \(day) replaced an unseen Fragments body — rescued as a 'fragments' take")
        } catch {
            // The check-then-act window (a concurrent structural edit
            // between the context read and the ops call) or any DB error:
            // same posture — the body outlives the failure, durably.
            return (false, await preserveUnrescuedBody(
                day: day,
                note: Self.unrescuedBodyNote(day: day, body: receipt.previousBody, error: error)))
        }
    }

    /// Durability FIRST (review round 2, MAJOR): the in-memory report note
    /// was ephemeral — a later in-round throw discarded it with the round,
    /// and a delivered one lived a single round in a tooltip. The note is
    /// persisted to `bridge_state` before it rides the report; if even that
    /// write fails, the ephemeral note is all there is — that corner
    /// honestly merges into the recorded process-death residual, and the
    /// note says so.
    private func preserveUnrescuedBody(day: String, note: String) async -> String {
        do {
            try await database.write { db in
                try Self.recordUnrescuedBody(db, dayKey: day, note: note)
            }
            return note
        } catch {
            return note
                + "\n(WARNING: durable preservation ALSO failed (\(error)) — this"
                + " note is the only copy and will NOT re-surface; save it now)"
        }
    }

    /// The not-rescued arm's note: carries the FULL destroyed body — it is
    /// the last copy anywhere, and 80 chars of it is not a rescue.
    private static func unrescuedBodyNote(day: String, body: String, error: Error? = nil) -> String {
        let cause = error.map { " (\($0))" } ?? " (no landable block)"
        return "push of \(day) replaced an unseen Fragments body that could NOT be"
            + " rescued as a take\(cause) — what follows is the only remaining copy;"
            + " save it if wanted:\n\(body)"
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
            // The notebook rule's canonical entry — STRUCTURALLY the same
            // entry `createOrOpenJournalEntry` opens (one shared query,
            // round 2 NIT 5): duplicate-day landings go to the day's
            // canonical entry while push pauses.
            guard let target = try Queries.canonicalJournalEntry(db, day: day)
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
    ) throws -> (hash: String?, remoteStamp: String?, remoteCreatedAt: String?)? {
        guard let row = try Row.fetchOne(
            db,
            sql: "SELECT last_synced_hash, last_remote_stamp, remote_created_at FROM bridge_day WHERE day_key = ?",
            arguments: [dayKey])
        else { return nil }
        return (row["last_synced_hash"], row["last_remote_stamp"], row["remote_created_at"])
    }

    /// `hash == nil` records the remote stamp WITHOUT an agreement — the
    /// hash column stays whatever it was (NULL for a virgin day: review
    /// round 1, MINOR 3 — the old UPDATE-only form silently no-opped on
    /// days with no row, losing the stamp and re-opening the `.stale`
    /// wedge). A nil `remoteStamp` never clobbers a recorded one
    /// (push-accepts know no remote stamp).
    static func recordDay(
        _ db: Database, dayKey: String, hash: String?, remoteStamp: String?,
        remoteCreatedAt: String? = nil
    ) throws {
        if let hash {
            try db.execute(
                sql: """
                    INSERT INTO bridge_day (day_key, last_synced_hash, last_remote_stamp, remote_created_at)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT(day_key) DO UPDATE SET
                      last_synced_hash = excluded.last_synced_hash,
                      last_remote_stamp = COALESCE(excluded.last_remote_stamp, bridge_day.last_remote_stamp),
                      remote_created_at = COALESCE(excluded.remote_created_at, bridge_day.remote_created_at)
                    """,
                arguments: [dayKey, hash, remoteStamp, remoteCreatedAt])
        } else if let remoteStamp {
            try db.execute(
                sql: """
                    INSERT INTO bridge_day (day_key, last_synced_hash, last_remote_stamp, remote_created_at)
                    VALUES (?, NULL, ?, ?)
                    ON CONFLICT(day_key) DO UPDATE SET
                      last_remote_stamp = excluded.last_remote_stamp,
                      remote_created_at = COALESCE(excluded.remote_created_at, bridge_day.remote_created_at)
                    """,
                arguments: [dayKey, remoteStamp, remoteCreatedAt])
        }
    }

    // MARK: - Derivation-bug poison markers (reconciliation: a
    // unique_violation is a mis-derived id — surfaced permanently, never
    // retried; cleared only with the fix that ends the bug class)

    static func poisonNote(_ db: Database, dayKey: String) throws -> String? {
        try String.fetchOne(
            db, sql: "SELECT value FROM bridge_state WHERE key = ?",
            arguments: ["poisoned:\(dayKey)"])
    }

    static func setPoisonNote(_ db: Database, dayKey: String, note: String) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO bridge_state (key, value) VALUES (?, ?)",
            arguments: ["poisoned:\(dayKey)", note])
    }

    // MARK: - Unrescued-body preservation (review round 2, MAJOR: the
    // one-shot receipt's failure-arm note was EPHEMERAL — it lived only in
    // the round's in-memory report, so a later in-round throw discarded the
    // only copy of the destroyed body, and even a delivered note lasted one
    // round in a hover tooltip. The body now persists here, poison-note
    // style, at consumption time — durable FIRST, note second — and
    // re-surfaces every round until cleared by hand, exactly the poison
    // posture: the producing event is one-shot, so persistence does the
    // recurring.)

    static func unrescuedBodyNotes(_ db: Database) throws -> [String] {
        try String.fetchAll(
            db,
            sql: "SELECT value FROM bridge_state WHERE key LIKE 'unrescued:%' ORDER BY key")
    }

    static func recordUnrescuedBody(_ db: Database, dayKey: String, note: String) throws {
        // APPEND, never replace: a later unrescued body for the same day
        // must not overwrite an earlier one — each is someone's only copy.
        let key = "unrescued:\(dayKey)"
        let existing = try String.fetchOne(
            db, sql: "SELECT value FROM bridge_state WHERE key = ?", arguments: [key])
        let value = existing.map { $0 + "\n\n———\n\n" + note } ?? note
        try db.execute(
            sql: "INSERT OR REPLACE INTO bridge_state (key, value) VALUES (?, ?)",
            arguments: [key, value])
    }

    // MARK: - Push stamps (client LWW)

    /// The push's client-LWW `updated_at`: **minimally above the last known
    /// remote stamp** — `last_remote_stamp + 1s`, NEVER `now` when a stamp
    /// is known (review round 2, MAJOR — supersedes round 1's
    /// `max(now, …)`). The traced mechanism: `last_remote_stamp` is the
    /// newest server-row stamp this bridge has seen (landed) or written
    /// (accepted push), so stamping just above it makes the push a
    /// poor-man's compare-and-set — it outranks exactly what we KNOW and
    /// loses LWW against anything newer we haven't seen. (Reconciliation
    /// nuance: migration 7's ties go to the PUSHER (`>=`), so an unseen
    /// save stamped EXACTLY at our minimal stamp is overwritten — the 1 s
    /// quantization residual destroys on exact ties rather than staling;
    /// ask 13 remains the full closure.) Stamping `now`
    /// instead let a same-round race destroy Fragments text on a
    /// steady-state day: a save landing between the pull and the push (or
    /// inside their ~2 s visibility horizon) was LWW-replaced by our
    /// fresher wall-clock stamp and, the feed being state-based, never
    /// served again — lost everywhere. With minimal stamping the race
    /// resolves `.stale` → the next pull lands the save as a conflict card
    /// → truth re-projects: the overwrite becomes a rescue. The round-1
    /// clock-ahead requirement is preserved (a landed 2027 stamp still gets
    /// outranked by +1s). Residuals: first contact (no stamp known — falls
    /// back to `now`) and sub-second stamp granularity; unparseable stamps
    /// fall back to `now` (ask filed for their exact format).
    static func pushStamp(now: String, outranking remoteStamp: String?) -> String {
        guard let remoteStamp, let remote = parseStamp(remoteStamp)
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
