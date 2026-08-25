//
//  SyncSafetyWords.swift
//  Variorum (MAC ONLY — deliberately not in Shared/)
//
//  Phase 13l, Act 5 (ledger row 17) — the sync-status face's SENTENCES.
//
//  WHY THIS IS A SEPARATE, MAC-ONLY FILE. These words started beside their
//  facts in `Shared/SyncSafetyFace.swift`, and the mobile no-redirect sweep
//  (parity C5) failed on them immediately: every line says "this Mac", and
//  `Shared/` means the phone compiles them too. That sweep is a design
//  instrument, and what it said here is right — the FACTS are one brain
//  (`SyncSafetyFacts`, and the standing it derives), the WORDS are a face.
//  The phone's twin renders the same five standings in its own nouns; it
//  does not reimplement the read or the rule. Same split, same reason, as
//  `DataSafetyCopy` beside this file.
//
//  Voice is PROVISIONAL (13s owns the copy pass). What is fixed here is
//  MEANING, and one line of it is load-bearing: **the signed-out state reads
//  as NORMAL.** A local-only Variorum is a complete Variorum, so its line
//  must never sound like an unfinished setup or a fault to clear.
//

import Foundation

nonisolated struct SyncSafetyFace: Equatable {
    /// The state, in one sentence.
    var headline: String
    /// The evidence beneath it — zero to three quiet lines.
    var details: [String]
    /// True when the headline should be worn quietly rather than in a colour
    /// that asks for attention.
    var isCalm: Bool
    /// **How the headline is painted** (the post-13l polish round, ledger row
    /// 31 — her *"a gentle green on fully synced might look nice"*). The
    /// decision is the STANDING's, shared with the phone
    /// (`SyncSafetyStanding.tone`); this carries it to the pane so the view
    /// renders a token and never re-derives a rule.
    var tone: SyncSafetyStanding.Tone

    static func face(_ facts: SyncSafetyFacts) -> SyncSafetyFace {
        let standing = facts.standing
        switch standing {
        case .devStore:
            return SyncSafetyFace(
                headline: "Sync is off in this build (development store).",
                details: [Self.localOnlyReassurance], isCalm: standing.isCalm,
                tone: standing.tone)
        case .localOnly, .signedInNotSyncing:
            // Both mean the same thing from here — nothing is leaving this
            // Mac — and the honest difference is only WHY.
            let why = standing == .signedInNotSyncing
                ? "Signed in, but this Mac isn't syncing right now."
                : "Not syncing — this Mac keeps your library to itself."
            return SyncSafetyFace(
                headline: why,
                details: [Self.localOnlyReassurance] + Self.backlogDetail(facts),
                isCalm: standing.isCalm, tone: standing.tone)
        case .allSent:
            return SyncSafetyFace(
                headline: "Everything written on this Mac has reached your account.",
                details: Self.roundDetail(facts) + Self.cursorDetail(facts),
                isCalm: standing.isCalm, tone: standing.tone)
        case .waiting(let pending):
            return SyncSafetyFace(
                headline: pending == 1
                    ? "1 change is still waiting to go up."
                    : "\(pending) changes are still waiting to go up.",
                details: [Self.waitingReassurance] + Self.roundDetail(facts)
                    + Self.cursorDetail(facts),
                isCalm: standing.isCalm, tone: standing.tone)
        }
    }

    // MARK: - The sentences

    /// The signed-out line's second half, and the reason it exists: a
    /// local-only Variorum is a COMPLETE Variorum. Nothing here should read
    /// as a setup step she has not done yet.
    static let localOnlyReassurance =
        "Everything works: your writing is on this Mac, and the backups above are its net."

    /// The waiting line's second half — offline is a designed-for state
    /// (SyncSpec: the outbox keeps everything, the next round sends it), so
    /// a backlog is never a loss.
    static let waitingReassurance =
        "Nothing is lost while they wait — they are held on this Mac and sent when it can."

    /// Signed out with a backlog: the honest shape of "your last few days
    /// only exist here", which is exactly when the backup evidence above
    /// matters most.
    private static func backlogDetail(_ facts: SyncSafetyFacts) -> [String] {
        guard facts.pending > 0 else { return [] }
        return ["\(facts.pending) change\(facts.pending == 1 ? "" : "s") "
                + "would go up when it does."]
    }

    private static func roundDetail(_ facts: SyncSafetyFacts) -> [String] {
        guard let last = facts.lastSuccessAt else {
            // Said out loud rather than shown as a blank or a stale time:
            // the scheduler's stamp is in-memory, so "no round yet" after a
            // relaunch means exactly that and nothing worse.
            return ["No sync round has finished since Variorum opened."]
        }
        return ["Last completed round: \(last.formatted(date: .omitted, time: .shortened))."]
    }

    private static func cursorDetail(_ facts: SyncSafetyFacts) -> [String] {
        guard let cursor = facts.cursor, cursor > 0 else {
            return ["This Mac hasn't received anything from your account yet."]
        }
        return ["Received everything your account had through change #\(cursor)."]
    }
}
