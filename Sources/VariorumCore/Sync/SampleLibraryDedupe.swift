import Foundation
import GRDB

/// **The sample-library dedupe's injected facts** (pre-13u Act 0,
/// R-pre13u-8) — everything the engine needs to recognise and classify a
/// seeded sample-library copy, and nothing else.
///
/// ── WHY INJECTED ──────────────────────────────────────────────────────
/// The identity predicate and the per-note manifest live with the seeder in
/// `App/Variorum/Shared/SampleLibrary/` — app-target code this module
/// cannot see. The engine therefore takes the facts the way it takes its
/// E2EE keys (`keyProvider`): a value handed in at wiring by the app layer,
/// with a nil default that leaves the repair INERT — an engine nobody wired
/// facts into cannot misidentify a book, which is the safe failure shape.
/// Both platforms wire it at the ONE shared composition site
/// (`SyncSession.configure`), so the two apps cannot drift.
///
/// ── WHY THE HASH RECIPE RIDES ALONG ───────────────────────────────────
/// The manifest's stored hashes and the repair's freshly-computed ones must
/// be the SAME recipe or every comparison silently fails. The recipe is
/// core's own public `BridgeHash.body` (SHA-256 hex of the UTF-8 bytes —
/// chosen at the Opus half precisely because both sides can name it), and
/// it travels here as a function reference so the wiring site hands the
/// pair — hashes and recipe — from one place. A drift would make every
/// note read as edited, which fails SAFE: both copies survive; an edited
/// copy is never retired by a recipe bug.
public struct SampleLibraryDedupeFacts: Sendable {
    /// The reserved book name — the seeder's own `discover` rule: EXACT,
    /// case-sensitive match on a live reading's name. Deliberately not
    /// folded: a copy she renamed stops matching, reads as her own book,
    /// and is left alone (a rename is engagement).
    public var bookName: String
    /// The reserved tag path. A live application pointing at any OTHER tag
    /// is engagement (she organised the copy).
    public var tagPath: String
    /// note title → hash of the text the seed stores for it. A closure
    /// because building it parses the bundled resource (~0.5 MB) — the
    /// repair calls it only when two same-name copies actually meet, which
    /// happens at most about once in a store's life.
    public var loadNoteHashes: @Sendable () throws -> [String: String]
    /// The recipe the stored hashes were built with.
    public var hash: @Sendable (String) -> String
    /// **13i-d U7's classics seed (F-U7-1, the architect's Sync/ half):**
    /// paths of SEED-AUTHORED tags beyond the reserved one — the seeder
    /// applies them to the shipped notes itself (`classics` on Sherlock's
    /// stories), so a live application of one is the SEED's hands, never
    /// hers, and must not mark a fresh copy EDITED (two fresh devices
    /// seeding before their first sync would otherwise keep two Sherlock
    /// books forever — both-edited's letter misfiring on the seed's own
    /// act). Empty = inert, the facts' standing nil-inert precedent; every
    /// pre-13i-d call site compiles and behaves byte-identically. The
    /// DOCUMENTED RESIDUAL this skip accepts (the err-toward-EDITED letter
    /// bent for a declared set only): her own RE-tag of a shipped note with
    /// exactly a listed path — or her UNTAG of one — is invisible to the
    /// classifier, so a copy touched ONLY that way can be retired at a
    /// dedupe meeting; it duplicates/removes what the seed ships, both
    /// copies carry the seed's own applications, and the window needs two
    /// devices seeding before first sync — the recorded engagement-chunk
    /// residual's class (KnownIssues, the 18a row).
    ///
    /// A SECOND residual, same class (13i-d ladder B round 1's MINOR 1,
    /// ruled record-as-residual): the Welcome ARRANGEMENT is the Mac's
    /// alone (P-13id-U7-14), so a meeting can pair an ARRANGED copy with a
    /// RAW one (a phone seed, a pre-U7 build's) — both read pristine, and
    /// when the raw copy holds the smaller id the arranged copy's demo
    /// state (its seed-tag applications; the owned flag and shelf pointer
    /// this classifier deliberately never reads) retires with its family.
    /// Nothing of hers is lost and a restore door re-arranges. Pinned as
    /// documented behaviour (`SampleLibraryDedupeRepairTests`'s
    /// `documentedResidual_…`); closed by the phone's arrangement catch-up
    /// (its KnownIssues row); the remedy alternatives — a keeper-preference
    /// arm (a change to the ruled R-pre13u-8 matrix) or arranging in the
    /// shared seeder (phone seed content) — are the author's, QUESTIONS #178.
    public var seedTagPaths: [String]

    public init(
        bookName: String,
        tagPath: String,
        loadNoteHashes: @escaping @Sendable () throws -> [String: String],
        hash: @escaping @Sendable (String) -> String,
        seedTagPaths: [String] = []
    ) {
        self.bookName = bookName
        self.tagPath = tagPath
        self.loadNoteHashes = loadNoteHashes
        self.hash = hash
        self.seedTagPaths = seedTagPaths
    }
}

/// **The sample-library pristine-copy dedupe** (pre-13u Act 0, R-pre13u-8)
/// — the SyncSpec §7 class applied to seeded demo content: two devices each
/// correctly decided "no sample library exists yet", both seeded, and the
/// pair met under sync. Her ruled resolution:
///
///   - both PRISTINE → deterministic keeper (smaller id); the other's
///     whole family retires — nothing lost, the copies are byte-identical;
///   - exactly one EDITED → the EDITED copy is kept, the pristine retired;
///   - both EDITED → BOTH survive (the documented concurrent-divide class
///     — **an edited copy is NEVER silently retired**).
///
/// A copy is PRISTINE when its live notes are exactly the manifest's titles
/// with matching per-note rendered-text hashes AND it shows no other sign
/// of her hands (a fanned, archived or LOCKED take, a manual savepoint, a
/// comment, a tag, a membership in another book, a seal, floating notes, a
/// reference, a block NAME or callout frame, the book's sort, a chapter or
/// note REORDERED — all invisible to the rendered text, all her writing or
/// her acts, and the whole point of the rule is that her work is never the
/// copy retired). Every extension of the ruled hash rule errs in ONE
/// direction only: toward classifying EDITED, which keeps copies, never
/// retires them.
///
/// ── THE SEED SHAPE THE CLASSIFIER ASSUMES (the contract the Mac's
/// `theShippedSeedSatisfiesTheDedupesPristineContract` guards) ──────────
/// A freshly seeded copy is: a curated book at the schema's default sort
/// (`manual`/`asc`), unlocked, no extents, no grouping tag; ONE chapter per
/// note, minted in note order, each note's membership assigned to its own
/// chapter, both appended — so memberships in book order name exactly the
/// live chapters in chapter order; every note tagged with the reserved
/// path; every block one active take, unlocked, unnamed, unframed; no
/// manual savepoint, comment, block tag, reference, or other membership.
/// The chapters' NAMES are deliberately NOT read (the front-matter chapter
/// is not named after its note, and the facts carry note titles only) — a
/// chapter RENAME is the one act of hers this classifier cannot see, and
/// is recorded as such (the ladder's R2-5).
///
/// A copy whose rows are still in flight (a membership's post not yet
/// arrived, a block without any variant row — the SyncSpec §5 straggler
/// class) is INDETERMINATE, and any indeterminate copy defers the WHOLE
/// pass: acting on partial data could retire the wrong copy on one device
/// and a different one on another. Deferring is free — a later batch
/// completes the picture and every device then computes the same verdicts.
///
/// ── WHEN THE PASS RUNS, AND WHAT A DEFERRAL WAITS FOR (the ladder's F2,
/// then round 2's R2-1/R2-3/R2-6) ────────────────────────────────────────
/// The pass fires ONLY under a PULL (`TouchedRows.isPullBatch`) — never
/// from a push chunk's reject-merge transaction — on three occasions:
///   1. the batch applied a `reading` row (the F2 occasion);
///   2. the ONE-SHOT local marker left by occasion 1's own deferral: a
///      copy whose book arrived THIS batch is indeterminate for the pass,
///      because its engagement rows sort after `reading_post` in the push
///      order and can still be in the pusher's next chunk; the marker
///      re-fires the pass at the next pull — an empty window included,
///      that being the head-reached moment — and is spent the instant a
///      pass runs, whatever it decides (R2-3);
///   3. a `post_tag` row for the RESERVED path applied in this batch: the
///      evidence the reserved-tag completeness guard waits for.
/// The guard (`SampleCopyClassifier.classify`, R2-1): every live member post of a
/// seeded copy carries the reserved tag, and `post_tag` is the FIRST
/// engagement table in the push order — so a member with NO `post_tag`
/// row for the reserved path (live or dead; any tag row wearing the path,
/// live or dead — a collision-retired duplicate counts) proves the
/// pusher's tag chunk has not landed, and the copy is INDETERMINATE. That
/// deferral re-arms nothing: it is re-examined at the apply that lands
/// the reserved-path applications (occasion 3), which is exactly when its
/// evidence can first exist. What the guard cannot see: an engagement row
/// in a table AFTER `post_tag` (`block_tag`, `reference`, `block_comment`)
/// travelling in a chunk of its own behind a landed tag chunk — the
/// recorded residual (its KnownIssues row, owner 13y).
///
/// The classifier's ONE body lives in `SampleCopyClassifier` below (RUN B
/// B2 row 8 — R3-2): public, so the Mac's seed-shape drift guard invokes
/// the REAL classifier over the real shipped seed instead of mirroring its
/// SQL; the engine's pass calls the same body.

/// One copy's classification (RUN B B2 row 8 — the pre-13u ladder's R3-2:
/// PUBLIC, so the Mac's seed-shape drift guard INVOKES the real classifier
/// over the real shipped seed instead of hand-mirroring its SQL — a
/// classifier leg the mirror lacked left the guard green while the real
/// classifier read the seed EDITED, the silent both-survive failure the
/// guard exists to announce).
public enum SampleCopyVerdict: Equatable, Sendable {
    case pristine
    case edited
    case indeterminate
}

/// The classifier itself, ONE body (row 8's letter: "invokes the real
/// classifier — never a second copy"): the engine's pass and the Mac guard
/// both call through here.
public enum SampleCopyClassifier {
    /// The guard's door: derives the manifest and the reserved tag id from
    /// the injected facts exactly as the engine's pass does, then runs the
    /// one classifier body.
    public static func classify(
        _ db: Database, copyID: String, facts: SampleLibraryDedupeFacts
    ) throws -> SampleCopyVerdict {
        let manifest = try facts.loadNoteHashes()
        let reservedTagID = try String.fetchOne(
            db, sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
            arguments: [facts.tagPath])
        return try classify(
            db, copyID: copyID, manifest: manifest,
            reservedTagID: reservedTagID, reservedTagPath: facts.tagPath,
            seedTagIDs: seedTagIDs(db, facts: facts), hash: facts.hash)
    }

    /// Every LIVE tag id at a declared seed path (all wings — strictly
    /// wider than one wing's twin, and safe: the copy's notes live in Home
    /// and `applyTag` is same-wing-only since 13i-d U5, so only Home's row
    /// can carry an application on a shipped note anyway; resolving all
    /// live twins just keeps the skip immune to the fetchOne-across-wings
    /// looseness the reserved resolution has carried since 13i-a).
    static func seedTagIDs(
        _ db: Database, facts: SampleLibraryDedupeFacts
    ) throws -> Set<String> {
        guard !facts.seedTagPaths.isEmpty else { return [] }
        return try Set(String.fetchAll(
            db,
            sql: """
                SELECT id FROM tag
                WHERE deleted_at IS NULL
                  AND path IN (SELECT value FROM json_each(?))
                """,
            arguments: [jsonArrayLiteral(facts.seedTagPaths)]))
    }

    /// A JSON array literal for `json_each` binding (the engine's own
    /// `jsonArray` is engine-internal; this door is also the Mac guard's).
    private static func jsonArrayLiteral(_ values: [String]) -> String {
        let data = try? JSONSerialization.data(withJSONObject: values)
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}

extension SyncEngine {
    /// Whether this batch is one of the pass's three occasions (above).
    /// Pull-only by construction; cost: two flag reads, one local-only
    /// marker read, and — only when the batch applied `post_tag` rows —
    /// one indexed lookup of their tag ids against the reserved path.
    func sampleDedupeOccasion(_ db: Database, touched: TouchedRows) throws -> Bool {
        guard touched.isPullBatch, !sampleLibraryFacts.isEmpty else { return false }
        if !touched.readingIDs.isEmpty { return true }
        if try sampleDedupePending(db) { return true }
        guard !touched.appliedPostTagTagIDs.isEmpty else { return false }
        // pre-13x 5a: ANY seeded book's reserved path among the applied
        // applications is the occasion (one indexed lookup over the list).
        return try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM tag
                               WHERE path IN (SELECT value FROM json_each(?))
                                 AND id IN (SELECT value FROM json_each(?)))
                """,
            arguments: [jsonArray(Set(sampleLibraryFacts.map(\.tagPath))),
                        jsonArray(touched.appliedPostTagTagIDs)]) ?? false
    }

    /// The pass. Fires from `runPostApplyRepairs` on the occasions above;
    /// the candidate scan is one indexed read PER SEEDED BOOK, and the
    /// expensive work (manifest load + per-note classification) runs only
    /// when two live same-name copies actually coexist.
    ///
    /// pre-13x 5a: the facts are a LIST (one entry per seeded book). The
    /// one-shot marker is spent ONCE for the pass, then every book's copies
    /// are examined by today's rules unchanged; a deferral by any book
    /// re-arms the marker (its own line below), so the next pull re-runs
    /// the pass for every book — the deferring book decides then, and a
    /// book that already decided finds one live copy and returns 0.
    func dedupeSampleLibraryCopies(_ db: Database, touched: TouchedRows) throws -> Int {
        guard !sampleLibraryFacts.isEmpty else { return 0 }
        // ONE-SHOT, spent FIRST (the ladder's R2-3): a pass that runs
        // consumes the marker before it decides anything — including the
        // common convergence, where the other device's retirement arrives
        // and only one live copy is left. Clearing after the count guard
        // leaked the marker forever on exactly that road: every empty pull
        // then opened an apply-mode transaction and every push chunk re-ran
        // the pass, for the life of the store.
        try setSampleDedupePending(db, false)
        var repairs = 0
        for facts in sampleLibraryFacts {
            repairs += try dedupeSampleLibraryCopies(db, facts: facts, touched: touched)
        }
        return repairs
    }

    /// ONE book's pass — the pre-5a body, the facts a parameter.
    private func dedupeSampleLibraryCopies(
        _ db: Database, facts: SampleLibraryDedupeFacts, touched: TouchedRows
    ) throws -> Int {
        // The seeder's own `discover` rule: EXACT live-name match.
        let copies = try String.fetchAll(
            db,
            sql: "SELECT id FROM reading WHERE name = ? AND deleted_at IS NULL ORDER BY id",
            arguments: [facts.bookName])
        if copies.count == 1 {
            return try retireSignedOutCopyIfOutranked(
                db, facts: facts, liveCopyID: copies[0], touched: touched)
        }
        guard copies.count > 1 else { return 0 }
        // The ladder's F2: a copy whose `reading` row arrived in THIS batch
        // is indeterminate for the pass. Its engagement signals — post_tag,
        // block_tag, reference, block_comment — sort AFTER reading_post in
        // the push order and can still be in the pusher's next chunk, so a
        // pull landing between the chunks would read an edited-by-comment
        // copy as pristine and retire it. Classify only copies quiescent
        // since a prior batch; the deferral re-arms the ONE-SHOT marker so
        // the next PULL (an empty window included) re-runs the pass instead
        // of waiting for another book to change. This is the only line
        // that arms it.
        if copies.contains(where: touched.readingIDs.contains) {
            try setSampleDedupePending(db, true)
            return 0
        }
        let manifest = try facts.loadNoteHashes()
        let reservedTagID = try String.fetchOne(
            db, sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
            arguments: [facts.tagPath])
        let seedTagIDs = try SampleCopyClassifier.seedTagIDs(db, facts: facts)

        var pristine: [String] = []
        var edited: [String] = []
        for copyID in copies {
            switch try SampleCopyClassifier.classify(
                db, copyID: copyID, manifest: manifest,
                reservedTagID: reservedTagID, reservedTagPath: facts.tagPath,
                seedTagIDs: seedTagIDs, hash: facts.hash) {
            case .pristine: pristine.append(copyID)
            case .edited: edited.append(copyID)
            case .indeterminate: return 0  // defer the whole pass
            }
        }
        // Survivors: every edited copy; plus, when none is edited, the
        // smallest-id pristine one. (Three-plus copies generalize the ruled
        // pair rules: pristine copies are redundant beside ANY survivor.)
        let retired = edited.isEmpty ? Array(pristine.dropFirst()) : pristine
        var repairs = 0
        for copyID in retired {
            repairs += try retireSampleCopy(
                db, copyID: copyID, arrivingDead: touched.arrivingDeadIDs)
        }
        return repairs
    }

    /// **18o U6 — the SIGNED-OUT-FIRST retirement (QUESTIONS #146,
    /// PROVISIONAL — hers to overturn).** The account's deletion wins over
    /// an UNTOUCHED local copy, and never over a touched one. The live-copy
    /// pass above cannot see this shape (it meets two LIVE copies; here one
    /// copy is live and the account's is DEAD), so this leg fires when the
    /// live same-name count is EXACTLY ONE and a same-name reading arrived
    /// DEAD in this batch (`arrivingDeadIDs` — a row this store never saw
    /// live — plus the live→dead `tombstonedParents` arm for completeness).
    ///
    /// **The later-intent guard is SyncSpec §3's own seq rule, at its
    /// NARROWEST true reading:** retire only when the live copy has NEVER
    /// been server-accepted (`knownSeq == 0`) and the arriving dead row
    /// has (`> 0`) — the ruling's own words, "at the device's first sync".
    /// The first cut compared seqs (`deadSeq > liveSeq`) and the EXISTING
    /// convergence suites caught it wide: a two-copy meeting's retired
    /// LOSER arrives dead with a seq above the pushed KEEPER's, and the
    /// wide comparator killed the keeper (measured — 9 issues across the
    /// pristine-pair scenarios; the narrowing is their fix). A meeting's
    /// keeper has ALWAYS pushed by the time any retirement tombstone can
    /// arrive (a retirement postdates the copy being seen), so never-
    /// accepted separates her scenario from every convergence shape. The
    /// corners: the signed-out phone (never accepted → fires) · a copy she
    /// deliberately RESTORED after the deletion (on the restoring device no
    /// dead row ever arrives again; on a from-scratch device the restored
    /// copy arrives ACCEPTED → declines) · the A5-band crossing (the copy
    /// pushed before the hidden tombstone arrived → accepted → declines —
    /// the ruling's alternative-(i) outcome, seconds-wide, recorded).
    ///
    /// **Classification is the ONE existing body** (err toward EDITED, every
    /// indeterminate leg intact): `.pristine` retires through
    /// `retireSampleCopy` UNCHANGED (family-complete ordinary tombstones,
    /// explicit outbox rows, Trash-listed — Put back real); `.edited` keeps
    /// (her words outrank a sample book); `.indeterminate` DECLINES —
    /// err toward keeping, no marker machinery for a state a locally-seeded
    /// copy can barely reach. A copy that itself ARRIVED this batch IS
    /// reachable on this road (the F2 quiescence arm sits after the
    /// count==1 early return, so it never runs here — the ladder's R1-1
    /// correction); its shield is the never-accepted guard alone: every
    /// pull-applied row gets `recordSeq` inside the same apply, so an
    /// arrived copy always ranks `> 0` and the guard below declines.
    /// A self-retirement never records kill evidence
    /// (`writeResolvedRow` is not on this road), so the #143(b) defense
    /// cannot revive what this leg retires — by construction.
    private func retireSignedOutCopyIfOutranked(
        _ db: Database, facts: SampleLibraryDedupeFacts, liveCopyID: String,
        touched: TouchedRows
    ) throws -> Int {
        var deadThisBatch = touched.arrivingDeadIDs["reading"] ?? []
        for parent in touched.tombstonedParents where parent.table == "reading" {
            deadThisBatch.insert(parent.rowID)
        }
        guard !deadThisBatch.isEmpty else { return 0 }
        let deadSameName = try String.fetchAll(
            db,
            sql: """
                SELECT id FROM reading
                WHERE name = ? AND deleted_at IS NOT NULL
                  AND id IN (SELECT value FROM json_each(?))
                """,
            arguments: [facts.bookName, jsonArray(deadThisBatch)])
        guard !deadSameName.isEmpty else { return 0 }
        guard try knownSeq(db, table: "reading", rowID: liveCopyID) == 0 else { return 0 }
        guard try deadSameName.contains(where: { deadID in
            try knownSeq(db, table: "reading", rowID: deadID) > 0
        }) else { return 0 }
        switch try SampleCopyClassifier.classify(db, copyID: liveCopyID, facts: facts) {
        case .edited, .indeterminate:
            return 0
        case .pristine:
            return try retireSampleCopy(
                db, copyID: liveCopyID, arrivingDead: touched.arrivingDeadIDs)
        }
    }

    /// The F2 marker: LOCAL-ONLY (`sync_state`, never synced — it names a
    /// fact about this device's apply history, not about the corpus). Read
    /// by `sampleDedupeOccasion` as the pass's second firing occasion and by
    /// `pull` at an empty window; never by the push path (R2-1).
    static let sampleDedupePendingKey = "sample_dedupe_pending"

    func sampleDedupePending(_ db: Database) throws -> Bool {
        try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM sync_state WHERE key = ?)",
            arguments: [Self.sampleDedupePendingKey]) ?? false
    }

    private func setSampleDedupePending(_ db: Database, _ pending: Bool) throws {
        if pending {
            try db.execute(
                sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, '1')",
                arguments: [Self.sampleDedupePendingKey])
        } else {
            try db.execute(
                sql: "DELETE FROM sync_state WHERE key = ?",
                arguments: [Self.sampleDedupePendingKey])
        }
    }

    /// **RUN B B2 row 15 Part 2 — THE DEFENSE LEG** (F-1, the
    /// double-retirement race; the orchestrator's row-15 ruling): a
    /// same-name sample copy killed by an ARRIVING retirement in the
    /// two-copy meeting context revives, exact-stamp and enqueued, when
    /// the ruled matrix says it must survive ("an edited copy is NEVER
    /// silently retired" — R-pre13u-8; err toward EDITED). ONE evidence
    /// arm — **the kill-time verdict**: the REAL classifier, read at the
    /// moment the retirement's first family death landed (the copy's rows
    /// still whole — `TouchedRows.sampleCopyKills` carries the verdict),
    /// says EDITED. This is the ruled classification itself, so the
    /// both-edited row of the matrix is reachable even when this device's
    /// edit already pushed — and the ruling's constraint ("repair
    /// bookkeeping can NEVER self-justify a revival") holds BY
    /// CONSTRUCTION: the classifier reads domain rows and never the
    /// outbox. An INDETERMINATE verdict never defends (deferring to the
    /// retiring side's complete evidence is loop-free; revive-on-doubt
    /// could ping-pong against the other device's pass forever).
    ///
    /// **The ruled PRE-BATCH-DIRT arm is deliberately ABSENT — its
    /// unsoundness is pin-proven, recorded for the orchestrator:** the
    /// batch-start snapshot excludes in-apply enqueues (the constraint's
    /// letter) but NOT a PRIOR batch's repair enqueues, which are the
    /// same bookkeeping one pull earlier — in
    /// `theMarkerIsSpentWhenTheOtherDevicesRetirementLands` (both copies
    /// PRISTINE), the tag-collision repair's re-pointed applications of
    /// the arriving copy's own notes sat in the snapshot and revived the
    /// correctly-retired copy: the constraint's exact degradation
    /// scenario, by the ruled mechanism itself. The classifier arm is
    /// STRICTLY stronger against that scenario (no outbox evidence at
    /// all) and the classifier-blind residual (a chapter rename) remains
    /// exactly the pre-existing R2-5 declined-leg class, unchanged.
    ///
    /// A device's OWN pass can never trip the defense: self-retirements
    /// write directly and never pass through `writeResolvedRow`, so no
    /// kill is recorded for them — the constraint's degradation scenario
    /// (reviving the copy the device just correctly retired) is dead by
    /// construction, and the ordinary both-pristine convergence keeps its
    /// pinned 3-round cadence (`p5c…`).
    /// The kill-time recorder (`writeResolvedRow`'s hook body): resolves
    /// the arriving tombstone to a LIVE same-name copy — a `reading` row
    /// directly, a `container` row through its live membership — checks
    /// the two-copy meeting context, and records ONE verdict per copy per
    /// batch, read by the REAL classifier while the copy is still whole
    /// (the first family death is the last such moment). Nothing is
    /// decided or written here.
    func recordSampleCopyKillEvidence(
        _ db: Database, arriving row: SyncRow, stamp: String, touched: inout TouchedRows
    ) throws {
        let copyID: String?
        if row.table == "reading" {
            copyID = row.rowID
        } else {
            // LADDER R1 F-R6 (the cleanliness half; the defect half was
            // pin-dismissed as hollow — a full retirement's reading row
            // resolves directly, so evidence is never wholly missed): the
            // resolution filters to readings wearing an injected facts
            // NAME and orders deterministically. Correctness must not
            // ride SQLite's plan — a post also living in a personal
            // collection resolved to an ARBITRARY reading under the bare
            // `LIMIT 1`, and under F-R3's persisted first-death verdict a
            // wrong batch-1 resolution would skip the marker and re-open
            // the split-revival it closes.
            copyID = try String.fetchOne(
                db,
                sql: """
                    SELECT r.id FROM reading r
                    JOIN reading_post rp ON rp.reading_id = r.id AND rp.deleted_at IS NULL
                    WHERE rp.post_id = ? AND r.deleted_at IS NULL
                      AND r.name IN (SELECT value FROM json_each(?))
                      AND EXISTS (SELECT 1 FROM container c
                                  WHERE c.id = rp.post_id AND c.deleted_at IS NULL)
                    ORDER BY r.id
                    LIMIT 1
                    """,
                arguments: [row.rowID, jsonArray(Set(sampleLibraryFacts.map(\.bookName)))])
        }
        guard let copyID,
              !touched.sampleCopyKills.contains(where: { $0.copyID == copyID }),
              let copy = try Reading.fetchOne(db, key: copyID), copy.deletedAt == nil
        else { return }
        for facts in sampleLibraryFacts where copy.name == facts.bookName {
            guard try meetingStands(db, bookName: facts.bookName, copyID: copyID, killStamp: stamp)
            else { continue }
            touched.sampleCopyKills.append((
                copyID: copyID, stamp: stamp,
                verdict: try SampleCopyClassifier.classify(db, copyID: copyID, facts: facts)))
            return
        }
    }

    /// **The meeting context, BOUNDED (LADDER R1 F-R2).** The first predicate
    /// counted DEAD readings — so a retired loser's tombstone kept the
    /// "meeting" open for its whole tombstone lifetime (30-day window +
    /// horizon), and a deliberate cross-device delete of the kept,
    /// ever-engaged copy was REVIVED for a month after any meeting: the
    /// row-15 ruling's own premise ("can never fire outside the
    /// once-per-store-life meeting window") falsified, and a resurrected
    /// deliberate delete is exactly the class the row-17 ruling rejected
    /// Shape C over. The meeting now stands only under one of three arms,
    /// each strictly NARROWER than the old any-row-any-age predicate —
    /// this bound can only ever suppress a revival, never widen one:
    ///
    ///  1. another same-name copy's reading row is LIVE here — the true
    ///     two-copy state (carries both-edited: the peer kept its own copy);
    ///  2. another same-name copy is dead AND its reading row still sits in
    ///     THIS device's outbox — my own retirement not yet acked: the
    ///     meeting is unsettled from this device's standpoint whatever the
    ///     stamps say (carries the delayed-push crossing, offline gaps
    ///     included);
    ///  3. another same-name copy died within the SETTLE WINDOW of the
    ///     arriving kill — |kill stamp − loser's deleted_at| ≤ 1 h, two
    ///     EVENT stamps minted at their acts (receipt time never enters;
    ///     wall stamps are display/domain data and this is a bounded-window
    ///     heuristic, never an ordering authority — the 30-day Trash window's
    ///     own idiom). The crossing's two pass stamps are bounded by delayed
    ///     pushes + the A5 band + round cadence (seconds-to-minutes real);
    ///     an hour covers generously; the month-scale tombstone lifetime is
    ///     three orders beyond. An unparseable stamp reads as OUTSIDE the
    ///     window — the narrow direction.
    ///
    /// Residual, stated: a deliberate delete INSIDE a real meeting's settle
    /// window still defends — that is QUESTIONS #143(b)'s accepted corner,
    /// now actually bounded the way the ruling believed it was.
    private static let meetingSettleWindow: TimeInterval = 3600
    private func meetingStands(
        _ db: Database, bookName: String, copyID: String, killStamp: String
    ) throws -> Bool {
        let others = try Row.fetchAll(
            db,
            sql: "SELECT id, deleted_at FROM reading WHERE name = ? AND id <> ?",
            arguments: [bookName, copyID])
        guard !others.isEmpty else { return false }
        if others.contains(where: { ($0["deleted_at"] as String?) == nil }) { return true }
        let killDate = DateFormatter.variorumISO8601.date(from: killStamp)
        for other in others {
            let otherID: String = other["id"]
            if try isEnqueued(db, table: "reading", rowID: otherID) { return true }
            if let killDate,
               let stamp = other["deleted_at"] as String?,
               let otherDate = DateFormatter.variorumISO8601.date(from: stamp),
               abs(killDate.timeIntervalSince(otherDate)) <= Self.meetingSettleWindow {
                return true
            }
        }
        return false
    }

    func defendEditedSampleCopies(_ db: Database, touched: TouchedRows) throws -> Int {
        var repairs = 0
        var defended: Set<String> = []
        for kill in touched.sampleCopyKills where !defended.contains(kill.copyID) {
            // The copy's READING must itself have died, under the recorded
            // retirement stamp: a lone member-note deletion records
            // evidence at its first death but is an ordinary delete — the
            // book stands, nothing is defended.
            guard try String.fetchOne(
                db, sql: "SELECT deleted_at FROM reading WHERE id = ?",
                arguments: [kill.copyID]) == kill.stamp
            else {
                // LADDER R1 F-R3: the first-death fence was per-batch, but
                // ONE retirement can reach this device in TWO applies (a
                // chunk boundary between the member containers and the
                // reading row, crossed by the A5 band or a mid-drain cut).
                // Discarding this batch's verdict re-opened the exact
                // hazard the fence exists for: the NEXT batch's verdict,
                // taken at the reading's own tombstone, reads a
                // HALF-KILLED copy (dead members = "her pruning" = EDITED)
                // and revives a correctly-retired pristine copy. The
                // verdict therefore becomes DURABLE across the split — a
                // local-only one-shot (the R2-3 marker idiom; sync_state,
                // never synced, written inside the apply transaction so a
                // rollback unwinds it) keyed copy+stamp, consumed when the
                // reading's death arrives. INSERT OR IGNORE keeps the
                // FIRST verdict — the earliest death saw the wholest copy.
                // A verdict for a retirement whose reading never dies (a
                // lone member-note deletion) lingers inert, bounded by
                // meeting-context kill events, and is cleared whenever a
                // later kill of the same copy consumes.
                try persistKillVerdict(
                    db, copyID: kill.copyID, stamp: kill.stamp, verdict: kill.verdict)
                continue
            }
            // F-R3's consumption: a persisted first-death verdict for this
            // exact (copy, stamp) OUTRANKS the current batch's re-read —
            // the earlier moment saw the copy whole; this batch may be
            // seeing it half-killed. INDETERMINATE consumes literally
            // (deferring to the retiring side's complete evidence stays
            // loop-free — never revive-on-doubt).
            let verdict = try consumeKillVerdict(
                db, copyID: kill.copyID, stamp: kill.stamp) ?? kill.verdict
            guard verdict == .edited else { continue }
            defended.insert(kill.copyID)
            repairs += try reviveSampleCopy(db, copyID: kill.copyID, stamp: kill.stamp)
        }
        return repairs
    }

    /// F-R3's one-shot verdict marker (local-only; `sync_state`).
    static func killVerdictKey(copyID: String, stamp: String) -> String {
        "sample_kill_verdict:\(copyID):\(stamp)"
    }

    private func persistKillVerdict(
        _ db: Database, copyID: String, stamp: String, verdict: SampleCopyVerdict
    ) throws {
        let raw: String
        switch verdict {
        case .pristine: raw = "pristine"
        case .edited: raw = "edited"
        case .indeterminate: raw = "indeterminate"
        }
        try db.execute(
            sql: "INSERT OR IGNORE INTO sync_state (key, value) VALUES (?, ?)",
            arguments: [Self.killVerdictKey(copyID: copyID, stamp: stamp), raw])
    }

    /// Reads-and-spends the persisted verdict for (copy, stamp) — and
    /// clears EVERY lingering verdict for the copy while it is at it (the
    /// reading died: any other stamp's marker is stale bookkeeping).
    private func consumeKillVerdict(
        _ db: Database, copyID: String, stamp: String
    ) throws -> SampleCopyVerdict? {
        let value = try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = ?",
            arguments: [Self.killVerdictKey(copyID: copyID, stamp: stamp)])
        try db.execute(
            sql: "DELETE FROM sync_state WHERE key LIKE ?",
            arguments: ["sample_kill_verdict:\(copyID):%"])
        switch value {
        case "pristine": return .pristine
        case "edited": return .edited
        case "indeterminate": return .indeterminate
        default: return nil
        }
    }

    /// The exact-stamp revival: flips `deleted_at` back to NULL on every
    /// family row carrying the retirement's stamp — the retirement was
    /// tombstones-only, so the flip alone restores the copy as it stood —
    /// and enqueues every flipped row explicitly (SyncSpec §7: the
    /// revival must PUSH, or the defending device diverges silently).
    /// Rows with a different stamp (an earlier delete's own clock) are
    /// never touched. Purge intents naming revived rows are deliberately
    /// NOT voided here: none exist on this road by construction, and the
    /// sweep-time staleness net (`familyVerdict` → `.stale`) is the
    /// designed second net for revives that cannot void (the standing
    /// note at `voidPurgeIntents`).
    private func reviveSampleCopy(
        _ db: Database, copyID: String, stamp: String
    ) throws -> Int {
        var repairs = 0
        func flip(
            _ table: String, where clause: String, _ args: [String]
        ) throws -> [String] {
            let ids = try String.fetchAll(
                db,
                sql: "SELECT id FROM \(table) WHERE \(clause) AND deleted_at = ?",
                arguments: StatementArguments(args + [stamp]))
            for id in ids {
                try db.execute(
                    sql: "UPDATE \(table) SET deleted_at = NULL WHERE id = ?",
                    arguments: [id])
                try enqueueExplicitly(db, table: table, rowID: id)
                repairs += 1
            }
            return ids
        }
        _ = try flip("reading", where: "id = ?", [copyID])
        _ = try flip("reading_section", where: "reading_id = ?", [copyID])
        _ = try flip("reading_post", where: "reading_id = ?", [copyID])
        let posts = try String.fetchAll(
            db,
            sql: "SELECT post_id FROM reading_post WHERE reading_id = ?",
            arguments: [copyID])
        for postID in posts {
            _ = try flip("container", where: "id = ?", [postID])
            let placements = try flip("container_block", where: "container_id = ?", [postID])
            if !placements.isEmpty {
                let blocks = try String.fetchAll(
                    db,
                    sql: """
                        SELECT DISTINCT block_id FROM container_block
                        WHERE container_id = ?
                        """,
                    arguments: [postID])
                for blockID in blocks {
                    _ = try flip("block", where: "id = ?", [blockID])
                    _ = try flip("variant", where: "block_id = ?", [blockID])
                    _ = try flip("block_comment", where: "block_id = ?", [blockID])
                    _ = try flip("block_tag", where: "block_id = ?", [blockID])
                    _ = try flip("canvas_layout", where: "block_id = ?", [blockID])
                    _ = try flip("lens_choice", where: "block_id = ?", [blockID])
                    _ = try flip(
                        "edge", where: "(source_block_id = ? OR target_block_id = ?)",
                        [blockID, blockID])
                }
            }
            _ = try flip("post_tag", where: "post_id = ?", [postID])
            _ = try flip("reference", where: "container_id = ?", [postID])
            _ = try flip("canvas_layout", where: "container_id = ?", [postID])
            let lenses = try flip("lens", where: "container_id = ?", [postID])
            for lensID in lenses {
                _ = try flip("lens_choice", where: "lens_id = ?", [lensID])
            }
        }
        return repairs
    }

    /// Retires one copy, family-complete: the book (its cascade takes the
    /// memberships and chapters at this exact stamp), then each member note
    /// (the container cascade takes placements, blocks, variants, tags,
    /// references). Ordinary tombstones — the Trash lists them — and every
    /// write reaches the outbox: the direct writes explicitly, the cascades
    /// via the victim sweep (SyncSpec §7).
    ///
    /// **Put back, honestly** (the ladder's F4): this family shape — a book
    /// AND its member notes under ONE stamp — is one no ordinary op mints,
    /// and `restoreReading` revives only stamp-matched MEMBERSHIPS, never
    /// containers. Putting the retired BOOK back therefore yields a book
    /// whose members are still in the Trash; each note's own Put back
    /// revives it (and its membership, by the stamp). Fourteen rows in a
    /// Trash she never asked to fill, and a fourteen-step road out — both
    /// recorded for her at QUESTIONS #85(e); widening the recovery door is
    /// an op-semantics call, not this repair's.
    /// (INTERNAL since 17y B-DEDUPE: the seeded-furniture fold's book grain
    /// retires a guide copy through this same family-complete shape — one
    /// body, two callers, the F4 Put-back story identical.)
    func retireSampleCopy(
        _ db: Database, copyID: String, arrivingDead: [String: Set<String>]
    ) throws -> Int {
        var repairs = 0
        let stamp = nowStamp()
        let memberPosts = try String.fetchAll(
            db,
            sql: "SELECT post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL ORDER BY post_id",
            arguments: [copyID])
        try db.execute(
            sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
            arguments: [stamp, stamp, copyID])
        try enqueueExplicitly(db, table: "reading", rowID: copyID)
        repairs += 1
        repairs += try enqueueSuppressedCascadeVictims(
            db, parent: ("reading", copyID, stamp), arrivingDead: arrivingDead)
        for postID in memberPosts {
            try db.execute(
                sql: "UPDATE container SET deleted_at = ?, updated_at = ? WHERE id = ? AND deleted_at IS NULL",
                arguments: [stamp, stamp, postID])
            try enqueueExplicitly(db, table: "container", rowID: postID)
            repairs += 1
            repairs += try enqueueSuppressedCascadeVictims(
                db, parent: ("container", postID, stamp), arrivingDead: arrivingDead)
        }
        return repairs
    }
}

extension SampleCopyClassifier {
    /// One copy's verdict, computed from SYNCED rows only — the same answer
    /// on every device once the rows have converged, which is what makes
    /// the keeper choice deterministic. ONE body, two callers: the engine's
    /// pass and the Mac seed-shape drift guard (row 8 — R3-2).
    static func classify(
        _ db: Database, copyID: String, manifest: [String: String],
        reservedTagID: String?, reservedTagPath: String,
        seedTagIDs: Set<String> = [], hash: (String) -> String
    ) throws -> SampleCopyVerdict {
        // Book-level acts: a finish, an extent, a grouping — and the book's
        // SORT moved off the schema default the seed minted at (R2-5).
        guard let reading = try Row.fetchOne(
            db,
            sql: """
                SELECT locked, word_target, max_posts, grouping_tag_id, sort_field, sort_dir,
                       ai_private_at
                FROM reading WHERE id = ?
                """,
            arguments: [copyID])
        else { return .indeterminate }
        if (reading["locked"] as Int? ?? 0) != 0
            || (reading["word_target"] as Int?) != nil
            || (reading["max_posts"] as Int?) != nil
            || (reading["grouping_tag_id"] as String?) != nil
            || (reading["sort_field"] as String?) != SortField.manual.rawValue
            || (reading["sort_dir"] as String?) != SortDirection.asc.rawValue
            // 13n-b U2 ladder F1 (R-13nb-4, v1_25): her Private mark is her
            // hand on the copy — EDITED, so the marked copy is the keeper
            // and the fence is never retired to an unmarked twin.
            || (reading["ai_private_at"] as String?) != nil {
            return .edited
        }

        let memberships = try Row.fetchAll(
            db, sql: "SELECT post_id, deleted_at FROM reading_post WHERE reading_id = ?",
            arguments: [copyID])
        // No membership rows AT ALL: a straggling copy (its memberships are
        // in flight) — a copy she emptied would carry tombstones. Defer.
        guard !memberships.isEmpty else { return .indeterminate }
        let livePostIDs = memberships
            .filter { ($0["deleted_at"] as String?) == nil }
            .map { $0["post_id"] as String }
        let deadMemberships = memberships.count - livePostIDs.count
        // Fewer live notes than shipped with no tombstone evidence: rows
        // may still be in flight — defer, never guess. (A pruned copy shows
        // its tombstones; a purge that removed them leaves the copy
        // indeterminate forever, which fails safe: both copies survive.)
        if livePostIDs.count < manifest.count && deadMemberships == 0 {
            return .indeterminate
        }

        // Her hands on the CHAPTERS (R2-5): the seed mints one chapter per
        // note in note order and assigns each membership to its own
        // chapter, both appended — so a pristine copy's memberships, in
        // book order, name exactly its live chapters in chapter order. A
        // reordered chapter or note, an extra chapter, an unassigned note,
        // a deleted chapter (its dead row still named): hers. Completeness
        // first — a membership naming a chapter this store has not seen is
        // a straggler (chapters precede memberships in the push order, so
        // only a cross-drain gap reaches here), never a verdict.
        let assignments = try Row.fetchAll(
            db,
            sql: """
                SELECT section_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                """,
            arguments: [copyID])
        var assignedChapters: [String] = []
        for assignment in assignments {
            guard let sectionID = assignment["section_id"] as String? else { return .edited }
            guard let chapter = try Row.fetchOne(
                db, sql: "SELECT deleted_at FROM reading_section WHERE id = ?",
                arguments: [sectionID])
            else { return .indeterminate }
            if (chapter["deleted_at"] as String?) != nil { return .edited }
            assignedChapters.append(sectionID)
        }
        let liveChapters = try String.fetchAll(
            db,
            sql: """
                SELECT id FROM reading_section
                WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                """,
            arguments: [copyID])
        if assignedChapters != liveChapters { return .edited }

        var titles = Set<String>()
        for postID in livePostIDs.sorted() {
            guard let post = try Row.fetchOne(
                db,
                sql: """
                    SELECT title, locked, archived_at, entry_date, floating_notes, deleted_at,
                           ai_private_at
                    FROM container WHERE id = ?
                    """,
                arguments: [postID])
            else { return .indeterminate }  // the post has not arrived yet
            if (post["deleted_at"] as String?) != nil { return .edited }
            if (post["locked"] as Int? ?? 0) != 0
                || (post["archived_at"] as String?) != nil
                || (post["entry_date"] as String?) != nil
                // 13n-b U2 ladder F1 (R-13nb-4, v1_25): a member note's own
                // Private mark is her hand on the copy — EDITED.
                || (post["ai_private_at"] as String?) != nil {
                return .edited
            }
            if let notes = post["floating_notes"] as String?, !notes.isEmpty { return .edited }
            // A cleared title, a title the manifest does not know, or a
            // duplicated one: her act, or her note — never pristine.
            guard let title = post["title"] as String?,
                  manifest[title] != nil,
                  titles.insert(title).inserted
            else { return .edited }

            // The reserved-tag COMPLETENESS guard (the ladder's R2-1): the
            // seed tags every note it mints, and `post_tag` is the first
            // engagement table in the push order — a shipped note with no
            // application of the reserved path at all (any liveness, any
            // tag row wearing the path: a collision-retired duplicate's
            // dead application counts) means the pusher's tag chunk has
            // not landed, and the engagement rows behind it cannot have
            // either. Indeterminate — re-examined when those applications
            // arrive (the third occasion), never guessed pristine. After
            // the title check on purpose: a note SHE added carries no
            // reserved tag and is already `.edited` above.
            let reservedTagLanded = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM post_tag pt
                                   JOIN tag t ON t.id = pt.tag_id
                                   WHERE pt.post_id = ? AND t.path = ?)
                    """,
                arguments: [postID, reservedTagPath]) ?? false
            guard reservedTagLanded else { return .indeterminate }

            // Structural completeness (stragglers defer) + fan shape (a
            // fanned or archived take is engagement the render cannot see).
            let placements = try Row.fetchAll(
                db,
                sql: "SELECT block_id, deleted_at FROM container_block WHERE container_id = ?",
                arguments: [postID])
            guard !placements.isEmpty else { return .indeterminate }
            let liveBlocks = placements
                .filter { ($0["deleted_at"] as String?) == nil }
                .map { $0["block_id"] as String }
            for blockID in liveBlocks {
                // The block's own metadata is hers too (R2-5): a NAME or a
                // callout FRAME never changes the rendered text.
                guard let block = try Row.fetchOne(
                    db, sql: "SELECT name, presentation FROM block WHERE id = ?",
                    arguments: [blockID])
                else { return .indeterminate }
                if let name = block["name"] as String?, !name.isEmpty { return .edited }
                if (block["presentation"] as String?) != nil { return .edited }
                // …and so is a LOCKED take (R2-5): pre-F5 the lock's
                // insurance auto-commit counted by accident; `kind =
                // 'manual'` removed that and nothing read `locked`.
                guard let shape = try Row.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) AS total,
                          COALESCE(SUM(CASE WHEN deleted_at IS NULL AND status = 'active'
                                            THEN 1 ELSE 0 END), 0) AS active,
                          COALESCE(SUM(CASE WHEN deleted_at IS NULL AND status = 'archived'
                                            THEN 1 ELSE 0 END), 0) AS archived,
                          COALESCE(SUM(CASE WHEN locked = 1 THEN 1 ELSE 0 END), 0) AS locked
                        FROM variant WHERE block_id = ?
                        """,
                    arguments: [blockID])
                else { return .indeterminate }
                guard (shape["total"] as Int? ?? 0) > 0 else { return .indeterminate }
                if (shape["active"] as Int? ?? 0) != 1 || (shape["archived"] as Int? ?? 0) != 0
                    || (shape["locked"] as Int? ?? 0) != 0 {
                    return .edited
                }
            }

            // Engagement the seed never produces: another book's membership,
            // a tag beyond the reserved one, a block tag, a comment, a
            // MANUAL savepoint, a reference. `kind = 'manual'` is
            // load-bearing (the ladder's F5): the six quiet AUTO occasions
            // (OverallModel §3 — leaving a note, the idle backstop, the
            // seals, …) are insurance the system mints on its own, and
            // `isDirty` reads a never-committed seeded take as dirty, so
            // merely opening a story and leaving stamps it `'auto'` — on
            // every device, since commit_point syncs. Counting those made
            // "both pristine" unreachable in any real store (two Sherlock
            // books forever, silently). Only her deliberate ⌘S is her hand.
            // 13i-d U7 (F-U7-1): applications of the reserved path AND of
            // the declared seed paths are the SEEDER's hands — everything
            // else on a shipped note is hers (the field's doc carries the
            // accepted residual).
            let seedAuthoredIDs = ([reservedTagID ?? ""] + seedTagIDs.sorted())
            let seedAuthoredJSON = (try? JSONSerialization.data(withJSONObject: seedAuthoredIDs))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
            let engagement = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM reading_post
                                   WHERE post_id = ?1 AND reading_id <> ?2 AND deleted_at IS NULL)
                        OR EXISTS (SELECT 1 FROM post_tag
                                   WHERE post_id = ?1 AND deleted_at IS NULL
                                     AND tag_id NOT IN (SELECT value FROM json_each(?3)))
                        OR EXISTS (SELECT 1 FROM block_tag bt
                                   JOIN container_block cb ON cb.block_id = bt.block_id
                                   WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                     AND bt.deleted_at IS NULL)
                        OR EXISTS (SELECT 1 FROM block_comment bc
                                   JOIN container_block cb ON cb.block_id = bc.block_id
                                   WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                     AND bc.deleted_at IS NULL)
                        OR EXISTS (SELECT 1 FROM commit_point cp
                                   JOIN variant v ON v.id = cp.variant_id
                                   JOIN container_block cb ON cb.block_id = v.block_id
                                   WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                     AND cp.kind = 'manual')
                        OR EXISTS (SELECT 1 FROM reference
                                   WHERE container_id = ?1 AND deleted_at IS NULL)
                    """,
                arguments: [postID, copyID, seedAuthoredJSON]) ?? false
            if engagement { return .edited }

            // The ruled per-note rule itself, last: byte-identity of the
            // rendered text against the shipped manifest.
            let rendered = try Queries.renderedText(db, containerID: postID)
            guard manifest[title] == hash(rendered) else { return .edited }
        }
        // Every live note pristine — but only the EXACT shipped set is a
        // pristine COPY: fewer titles with tombstone evidence is a pruning,
        // and any dead membership at all records an act of hers. Reaching
        // here with fewer titles MEANS tombstone evidence exists (the
        // no-evidence case deferred above), so both legs read EDITED — the
        // ladder's F3 found the second leg returning `.indeterminate`, which
        // deferred the whole pass forever and kept both copies instead of
        // the ruled "edited kept, pristine retired".
        guard titles.count == manifest.count, deadMemberships == 0 else {
            return .edited
        }
        return .pristine
    }

}
