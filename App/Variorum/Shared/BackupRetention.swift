//
//  BackupRetention.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, like StoreBackup)
//
//  Phase 13l, Act 4 (ledger row 11) — the SECOND destination's retention
//  rule, as a pure function.
//
//  The in-container destination (Phase 8's A1) keeps a flat "newest 14",
//  which is right for a folder that only ever receives one copy a day and
//  only ever exists on this disk. The picked folder is a different thing:
//  it is the copy that survives the disk, so its window wants to be LONGER
//  than fourteen days without holding fourteen more files. Her ruling at the
//  13l kickoff (proposed default, unobjected): **14 dailies + 4 weeklies**
//  — about six weeks of reach for eighteen files.
//
//  Two things this rule is deliberately NOT:
//  - It is not "files younger than 14 days". It keeps the fourteen most
//    recent DAYS THAT HAVE A FILE, so a fortnight away from the machine
//    costs no history at all (the app only backs up while it runs, and the
//    gaps in the author's own Backups/ folder are the proof that matters).
//  - It is not a rotation schedule. Nothing is promoted or renamed; a file
//    is simply kept or pruned. That is why it can be a pure function over
//    (url, date) pairs with no state anywhere.
//
//  The retention window is ALSO the oops-recovery horizon past the Trash's
//  30 days, and — the other direction — the length of time a purged thing
//  stays readable inside a backup file (M6). Both are stated in
//  `notes/DataSafetyRunbook.md`; the number lives here.
//

import Foundation

nonisolated enum BackupRetention {
    nonisolated struct Policy: Sendable, Equatable {
        /// The most recent N days that have a file. Their newest file each.
        var dailies: Int
        /// Beyond those, the most recent N weeks that still have a file.
        var weeklies: Int

        /// Her unobjected default at the 13l kickoff sitting.
        static let secondDestination = Policy(dailies: 14, weeklies: 4)
    }

    /// A file the rule reasons about. `date` comes from the A1 filename
    /// stamp (UTC), never from the filesystem — a copy's mtime moves when it
    /// is copied, and the stamp is the moment the SNAPSHOT was taken.
    nonisolated struct Candidate: Sendable, Equatable, Hashable {
        var url: URL
        var date: Date

        init(url: URL, date: Date) {
            self.url = url
            self.date = date
        }
    }

    /// Whole days since the epoch, UTC — the same grain the filenames carry.
    static func dayIndex(_ date: Date) -> Int {
        Int(floor(date.timeIntervalSince1970 / 86_400))
    }

    /// Whole weeks since the epoch, Monday-aligned (1970-01-01 was a
    /// Thursday, so +3 lands day 0 in the week that began Monday
    /// 1969-12-29). The alignment matters only for consistency — the rule
    /// keeps "one per week", never "the Sunday one".
    static func weekIndex(_ date: Date) -> Int {
        Int(floor(Double(dayIndex(date) + 3) / 7.0))
    }

    /// The files to KEEP, by the 14+4 rule.
    ///
    /// Order of decisions, and each is deliberate:
    /// 1. Newest first. Within one day, the newest file represents the day —
    ///    a manual "Back Up Now" beside the automatic one never costs a day
    ///    its slot, it just wins it.
    /// 2. The `dailies` most recent represented days are kept.
    /// 3. Of what remains, the `weeklies` most recent NOT-YET-COVERED weeks
    ///    are kept — one file each, again the newest.
    ///
    /// That last word is load bearing and was caught by its own test rather
    /// than reasoned out: without it, a day that got a second copy (the
    /// automatic one plus a "Back Up Now") pushed its own older twin into the
    /// remainder, where the twin then claimed a WEEKLY slot for a week the
    /// dailies already covered. The result was fifteen files and no extra
    /// reach — the weeklies exist to reach FURTHER BACK, never to keep a
    /// second copy of a week you already have.
    static func keep(_ candidates: [Candidate], policy: Policy) -> Set<URL> {
        let newestFirst = candidates.sorted {
            ($0.date, $0.url.lastPathComponent) > ($1.date, $1.url.lastPathComponent)
        }

        var keptDays: [Int] = []
        var coveredWeeks: Set<Int> = []
        var kept: Set<URL> = []
        var remainder: [Candidate] = []
        for candidate in newestFirst {
            let day = dayIndex(candidate.date)
            if keptDays.contains(day) {
                remainder.append(candidate)
            } else if keptDays.count < policy.dailies {
                keptDays.append(day)
                coveredWeeks.insert(weekIndex(candidate.date))
                kept.insert(candidate.url)
            } else {
                remainder.append(candidate)
            }
        }

        var weeksAdded = 0
        for candidate in remainder {
            let week = weekIndex(candidate.date)
            guard !coveredWeeks.contains(week) else { continue }
            guard weeksAdded < policy.weeklies else { break }
            coveredWeeks.insert(week)
            weeksAdded += 1
            kept.insert(candidate.url)
        }
        return kept
    }

    /// The complement — what a sweep removes. Separate so the caller reads
    /// as what it does, and so a test can assert both halves partition the
    /// input exactly.
    static func prune(_ candidates: [Candidate], policy: Policy) -> [URL] {
        let kept = keep(candidates, policy: policy)
        return candidates.map(\.url).filter { !kept.contains($0) }
    }

    /// **VX-338 — the sweep over THIS Mac's own copies, and nothing else.**
    /// A candidate whose name is not in `own` (another Mac's copy in a shared
    /// folder, or any copy written before the fix) is never counted against
    /// the rule and never returned — so the result is always a subset of the
    /// own candidates, whatever else the folder holds. The rule itself is
    /// unchanged: `prune` over the own set.
    static func prune(_ candidates: [Candidate], policy: Policy, ownedBy own: Set<String>) -> [URL] {
        prune(candidates.filter { own.contains($0.url.lastPathComponent) }, policy: policy)
    }

    /// How far back the kept set actually reaches — the honest number the
    /// Data Safety face shows, because "14 dailies + 4 weeklies" is a rule
    /// and "your oldest copy is from 5 August" is an answer.
    static func oldestKept(_ candidates: [Candidate], policy: Policy) -> Date? {
        let kept = keep(candidates, policy: policy)
        return candidates.filter { kept.contains($0.url) }.map(\.date).min()
    }
}
