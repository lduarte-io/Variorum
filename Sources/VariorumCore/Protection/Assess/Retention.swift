import Foundation

// VX-305 U2 — RETENTION, PER LIBRARY PER MAC (design §3.7, VX-302: "copies
// belong to a library and a Mac"). Retention acts ONLY on this Mac's copies
// of this library — its `Backups/<library8>/<mac8>/` pairs: 14 in the
// container, 14 daily plus 4 weekly in the far folder. Everything else in a
// shared folder is someone else's and is never pruned here: another Mac's
// copies, another library's, a copy whose key file doesn't read,
// `Previous Libraries/` (kept), and the adoption's safety copy (it lasts until
// its open finishes — the open's own plan removes it). (Today's flat files and
// their never-prune arm left with rule 26 — VX-378 U1.)
//
// The far folder's 14 + 4 rule is today's `BackupRetention.keep`
// (App/Variorum/Shared/BackupRetention.swift — her 13l ruling), restated
// here byte for byte in its decisions so the core owns the one rule; the
// container's is today's newest-14 (`StoreBackup.prune`). Pure: the catalog
// in, the copies to prune out; the caller removes each with its pair (VX-309 U1a: the app's pair road runs it after
// every pair it lands — `ProtectionBackupHook.takePair` — through the backups leaf; the predicate lives in `OwnCopies`).

public enum Retention {
    public struct Policy: Equatable, Sendable {
        /// The container's newest-N (Phase 8's A1: 14).
        public var containerKeep: Int
        /// The far folder's most recent N days that have a copy.
        public var dailies: Int
        /// Beyond those, the most recent N weeks that still have one.
        public var weeklies: Int

        public init(containerKeep: Int, dailies: Int, weeklies: Int) {
            self.containerKeep = containerKeep
            self.dailies = dailies
            self.weeklies = weeklies
        }

        /// Today's numbers: 14 in the container; 14 dailies + 4 weeklies in
        /// the far folder (her 13l kickoff default).
        public static let standard = Policy(containerKeep: 14, dailies: 14, weeklies: 4)
    }

    public struct Outcome: Equatable, Sendable {
        /// This Mac's copies of this library past the policy — the executor
        /// removes each with its own pair.
        public var prune: [String]
        /// This Mac's copies of this library the policy keeps.
        public var keep: [String]
    }

    /// **The plan for one library on one Mac.** `now` feeds the trusted-stamp
    /// rule (18o U1, `OwnCopies.stampIsTrusted`): a copy stamped ahead of the
    /// clock claims NO slot — kept like an undated copy, never counted among
    /// the container's 14 or the far dailies and weeklies, never pruned — so
    /// the fresh pair a due-check just wrote (the due-check rightly distrusts
    /// a future stamp) is never pruned in the future copy's favour (the
    /// write-then-delete churn the VX-309 U1a Mac batch caught live).
    public static func plan(
        catalog: Catalog, libraryID: String, thisMac deviceID: String,
        policy: Policy = .standard, now: Date, guards: ProtectionGuards = .all
    ) -> Outcome {
        // VX-309 U1a: the one predicate, shared with every new-road read of the copies (`OwnCopies` — the far
        // folder's due-check, Data Safety's counts), moved there verbatim.
        func isThisMacsCopyOfThisLibrary(_ copy: CatalogCopy) -> Bool {
            OwnCopies.isThisMacsCopyOfThisLibrary(copy, libraryID: libraryID, thisMac: deviceID)
        }
        var prune: [String] = []
        var keep: [String] = []
        for place in CatalogPlace.allCases {
            let candidates: [CatalogCopy]
            if guards.pruneOwnCopiesOnlyOn {
                candidates = catalog.copies.filter { $0.place == place && isThisMacsCopyOfThisLibrary($0) }
            } else {
                // Guard off (DEBUG mutation pins only): today's VX-302 shape —
                // every snapshot in the folder counted and pruned by its stamp,
                // whoever's it is.
                candidates = catalog.copies.filter { $0.place == place && $0.kind == .backup }
            }
            let dated = candidates.compactMap { copy in copy.stamp.map { (id: copy.id, date: $0) } }
            let trusted = dated.filter { OwnCopies.stampIsTrusted($0.date, now: now) }
            let kept: Set<String>
            switch place {
            case .container:
                kept = Set(trusted.sorted { ($0.date, $0.id) > ($1.date, $1.id) }.prefix(policy.containerKeep).map(\.id))
            case .farFolder:
                kept = keepDailiesAndWeeklies(trusted, dailies: policy.dailies, weeklies: policy.weeklies)
            }
            // An undated copy (no stamp to reason about) — and one stamped
            // ahead of the clock (a real snapshot with a wrong date is never
            // this rule's to delete, 18o U1) — is never pruned and claims no
            // slot.
            let trustedIDs = Set(trusted.map(\.id))
            keep += candidates.map(\.id).filter { kept.contains($0) || !trustedIDs.contains($0) }
            prune += trusted.map(\.id).filter { !kept.contains($0) }
        }
        return Outcome(prune: prune.sorted(), keep: keep.sorted())
    }

    // MARK: - Today's 14 + 4 rule (BackupRetention.keep, restated)

    /// Whole days since the epoch, UTC — the grain the names carry.
    static func dayIndex(_ date: Date) -> Int { Int(floor(date.timeIntervalSince1970 / 86_400)) }

    /// Whole weeks since the epoch, Monday-aligned (1970-01-01 was a Thursday).
    static func weekIndex(_ date: Date) -> Int { Int(floor(Double(dayIndex(date) + 3) / 7.0)) }

    /// The ids to KEEP: newest first, the newest file of each of the
    /// `dailies` most recent represented days; then, of what remains, one per
    /// `weeklies` most recent NOT-YET-COVERED weeks (a day's second copy never
    /// claims a weekly slot for a week the dailies already cover — the rule's
    /// own test-found word).
    static func keepDailiesAndWeeklies(_ candidates: [(id: String, date: Date)], dailies: Int, weeklies: Int) -> Set<String> {
        let newestFirst = candidates.sorted { ($0.date, $0.id) > ($1.date, $1.id) }
        var keptDays: [Int] = []
        var coveredWeeks: Set<Int> = []
        var kept: Set<String> = []
        var remainder: [(id: String, date: Date)] = []
        for candidate in newestFirst {
            let day = dayIndex(candidate.date)
            if keptDays.contains(day) {
                remainder.append(candidate)
            } else if keptDays.count < dailies {
                keptDays.append(day)
                coveredWeeks.insert(weekIndex(candidate.date))
                kept.insert(candidate.id)
            } else {
                remainder.append(candidate)
            }
        }
        var weeksAdded = 0
        for candidate in remainder {
            let week = weekIndex(candidate.date)
            guard !coveredWeeks.contains(week) else { continue }
            guard weeksAdded < weeklies else { break }
            coveredWeeks.insert(week)
            weeksAdded += 1
            kept.insert(candidate.id)
        }
        return kept
    }
}
