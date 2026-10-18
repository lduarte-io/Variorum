import Foundation

/// **A NEW NOTE BORN INSIDE A GATHERING** (VX-217 — her ruling 2026-10-13:
/// "the bottom of a book and the bottom of a gathering should look the same";
/// the architect's option (A) + her two rulings R-VX214-3/4, the run record
/// `notes/plans/fixes/vx-214-settings-launch-polish.md`).
///
/// A gathering holds nothing (§1 of the 13i sitting record), so a note "in" a
/// gathering is a note its RULE matches. R98 already says what adding a note
/// to a gathering means — the add IS applying what the rule needs — and this
/// is R98 composed with the book door's refuse-before-mint doctrine: the
/// mint and the rule-satisfying walk happen in ONE transaction, and a rule a
/// fresh note can't be made to match unwinds whole (no stray note).
///
/// Her R-VX214-4 widens R98's walk for a MINT: a star term is satisfiable at
/// creation ("i don't see why you couldn't autostar a note at creation for a
/// gathering based on being starred"). R98's collect-EXISTING door is
/// untouched (its ★ refusal stands — the asymmetry is flagged for her).
///
/// THE ONE AUTHORITY (the architect's rider 2): this pure planner decides
/// both what the op writes and whether the door can act — the book view's
/// render-time read and the op's in-transaction re-check both call
/// `Queries.gatheringMintOutcome`, which calls this. Never a second
/// derivation.
public enum GatheringMint {
    /// What a fresh note must wear for the rule to match it: the tags to
    /// apply (rule order, deduplicated) and whether to star it.
    public struct Plan: Equatable, Sendable {
        public let tagIDs: [String]
        public let star: Bool

        public init(tagIDs: [String], star: Bool) {
            self.tagIDs = tagIDs
            self.star = star
        }
    }

    /// Why a new note can't land here — her R-VX214-3: the door GREYS and
    /// says this on hover; the op refuses with the same words.
    public enum Blocker: Equatable, Sendable {
        /// An archived gathering assembles EMPTY everywhere (13i-e), so a
        /// note minted for it would show nowhere.
        case archived
        /// A legacy finished gathering (13i-d made `lockReading` refuse a
        /// gathering; rows finished before it may remain). R98 refuses here
        /// too.
        case finished
        /// No rule (a Trash restoree's state — R-13ic-4).
        case noRule
        case malformedRule
        /// A tag term whose tag is dead or of another wing; the path when
        /// any row (even a tombstone) still knows it.
        case deadTag(path: String?)
        /// A legacy entry-date term — a fresh note has no entry date.
        case datedRule
        /// A legacy profile term — a fresh note has no profile.
        case kindRule
        /// A NOT that contradicts what the note must wear (VX-250 (3): a NOT
        /// a fresh note meets is allowed), an empty any-of group or one with
        /// a nested group or legacy term, or another shape a fresh note
        /// can't be made to match by tagging and starring.
        case unreachableTerm

        /// The whole sentence the greyed door's hover says — and the op's
        /// refusal, word for word. ONE home for the words.
        ///
        /// VX-250 (2) — her SHORTER register (QUESTIONS #217, verbatim for
        /// three of them): "Archived — unarchive it to add notes." · "Its rule
        /// needs #essays, which no longer exists." · "Its rule can't match a
        /// new note." — and, when no row knows the dead tag's path (purged, or
        /// a sync gap), "Its rule needs a tag that no longer exists." The
        /// rest are drafted into the same register (PROVISIONAL, the run
        /// record): finished, no rule, an unreadable rule, the legacy
        /// date/kind terms. The old "This gathering can't take a new note: …"
        /// frame is retired with the long fragments it carried.
        public var reason: String {
            switch self {
            case .archived:
                "Archived \u{2014} unarchive it to add notes."
            case .finished:
                "Finished \u{2014} reopen it to add notes."
            case .noRule:
                "No rule yet \u{2014} give it one to add notes."
            case .malformedRule:
                "Its rule can't be read \u{2014} edit it to add notes."
            case .deadTag(let path?):
                "Its rule needs #\(path), which no longer exists."
            case .deadTag(nil):
                "Its rule needs a tag that no longer exists."
            case .datedRule:
                "Its rule needs an entry date, which a new note doesn't have."
            case .kindRule:
                "Its rule needs a kind of note, which a new note doesn't have."
            case .unreachableTerm:
                "Its rule can't match a new note."
            }
        }
    }

    public enum Outcome: Equatable, Sendable {
        case plan(Plan)
        case blocked(Blocker)
    }

    /// The reason the op's belt speaks if a plan ever fails the assembly's
    /// own probe (the probe is the authority on matching; the planner only
    /// proposes). Unreachable for every shape the planner admits — and it
    /// says what the greyed door would have: her "Its rule can't match a new
    /// note." (VX-250 (2)).
    public static let unmatchedReason = Blocker.unreachableTerm.reason

    /// **THE PLANNER** — pure over the gathering's state, its rule and the
    /// liveness of the tags the rule names.
    ///
    /// The walk is R98's (the TOP-LEVEL conjuncts of the rule; an any-of
    /// group contributes ONE option) with two mint-shaped changes, both
    /// recorded in the batch record:
    /// - a STAR term is satisfiable — the note is starred (R-VX214-4);
    /// - an any-of group takes its first SATISFIABLE option (a star, or a
    ///   live tag), where R98 takes its first and refuses when that one is
    ///   dead — a determinism device either way, and a dead first option
    ///   need not grey a door another option can open.
    /// Nested AND groups flatten (a conjunction of conjunctions is one
    /// conjunction).
    ///
    /// **NOT TERMS (VX-250 (3) — her answer to P-VX217-d, QUESTIONS #217:
    /// "ALLOW NOT terms").** A fresh note wears only what the plan gives it,
    /// so it meets `NOT #x` by not wearing #x. A NOT conjunct, and an any-of
    /// group with a NOT option, are therefore DEFERRED: once the positive
    /// walk has made the plan, a deferred group not already met takes its
    /// first satisfiable positive option, and then EVERY conjunct is checked
    /// against the note the plan makes (`freshNoteMatches` — the assembly's
    /// own predicate, `ruleSQL`, evaluated for that note). A NOT that
    /// contradicts something the plan must apply — `#a AND NOT #a`, or a
    /// planned tag inside the NOT's subtree (`tagCovers`) — still greys. The
    /// in-transaction `matchesRule` belt is untouched.
    ///
    /// What still blocks: legacy date/profile terms, an empty any-of group,
    /// an any-of group with a nested group or a legacy term among its
    /// options — the remainder of her ruling's unsatisfiable class.
    ///
    /// `tagCovers(ruleTag, wornTag)` answers whether a note wearing `wornTag`
    /// matches the rule's `ruleTag` term — the same tag or one inside its
    /// subtree (§19's subtree matching; both live in the gathering's wing).
    /// The default knows identity only.
    public static func outcome(
        archived: Bool, finished: Bool, rule: RuleGrammar.ReadResult,
        tagIsLive: (String) -> Bool, deadTagPath: (String) -> String? = { _ in nil },
        tagCovers: (_ ruleTag: String, _ wornTag: String) -> Bool = { $0 == $1 }
    ) -> Outcome {
        if archived { return .blocked(.archived) }
        if finished { return .blocked(.finished) }
        let term: RuleTerm
        switch rule {
        case .none: return .blocked(.noRule)
        case .malformed: return .blocked(.malformedRule)
        case .rule(let t): term = t
        }

        var tagIDs: [String] = []
        var star = false
        func plans(_ atom: RuleTerm) -> Bool {
            switch atom {
            case .star: star
            case .tag(let id): tagIDs.contains(id)
            default: false
            }
        }
        func take(_ atom: RuleTerm) {
            switch atom {
            case .star: star = true
            case .tag(let id): if !tagIDs.contains(id) { tagIDs.append(id) }
            default: break
            }
        }

        var conjuncts: [RuleTerm] = []
        func flatten(_ t: RuleTerm) {
            if case .and(let inner) = t {
                inner.forEach(flatten)
            } else {
                conjuncts.append(t)
            }
        }
        flatten(term)

        /// A positive option a mint can take: the star, or a live tag.
        func satisfiable(_ atom: RuleTerm) -> Bool {
            switch atom {
            case .star: true
            case .tag(let id): tagIsLive(id)
            default: false
            }
        }

        /// **The fresh note against a term — `ruleSQL`'s semantics exactly**,
        /// for the note the plan makes: it wears the planned tags and the
        /// planned star, and nothing else — no entry date, no profile (SQL
        /// NULL, so a legacy comparison is UNKNOWN: nil, three-valued as SQL
        /// is). A tag term holds when its tag is live in the wing and covers
        /// a planned tag (a dead or foreign tag matches nothing, so its NOT
        /// holds); an empty all-of holds and an empty any-of does not
        /// (`ruleSQL`'s "1"/"0").
        func freshNoteMatches(_ t: RuleTerm) -> Bool? {
            switch t {
            case .star:
                return star
            case .tag(let id):
                return tagIsLive(id) && tagIDs.contains { tagCovers(id, $0) }
            case .not(let inner):
                return freshNoteMatches(inner).map { !$0 }
            case .and(let terms):
                var result: Bool? = true
                for term in terms {
                    switch freshNoteMatches(term) {
                    case false?: return false
                    case nil: result = nil
                    case true?: break
                    }
                }
                return result
            case .or(let terms):
                var result: Bool? = false
                for term in terms {
                    switch freshNoteMatches(term) {
                    case true?: return true
                    case nil: result = nil
                    case false?: break
                    }
                }
                return result
            case .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo:
                return nil
            }
        }

        // An any-of group's pick is a CHOICE, not a must: prefer the first
        // satisfiable option that keeps every top-level NOT holding, so
        // `(#a OR #c) AND NOT #a` takes #c rather than greying a door a new
        // note could open; with none, the first satisfiable (the final check
        // then greys it honestly).
        let negations = conjuncts.filter { if case .not = $0 { true } else { false } }
        func keepsNegations(_ option: RuleTerm) -> Bool {
            let saved = (tagIDs, star)
            defer { (tagIDs, star) = saved }
            take(option)
            return negations.allSatisfy { freshNoteMatches($0) != false }
        }
        func choose(_ options: [RuleTerm]) -> RuleTerm? {
            options.first { satisfiable($0) && keepsNegations($0) }
                ?? options.first(where: satisfiable)
        }

        // The positive walk: what the note must wear. NOT conjuncts, and
        // any-of groups with a NOT option, wait for the plan (VX-250 (3)).
        var deferredGroups: [[RuleTerm]] = []
        for conjunct in conjuncts {
            switch conjunct {
            case .star:
                take(.star)
            case .tag(let id):
                guard tagIsLive(id) else { return .blocked(.deadTag(path: deadTagPath(id))) }
                take(.tag(id))
            case .or(let options):
                // An any-of group of ATOMS (tags and the star) and NOT
                // options only; an empty group, or one with a nested group
                // or a legacy term, is not something a mint can aim at.
                let aimable = options.allSatisfy {
                    switch $0 {
                    case .star, .tag, .not: true
                    default: false
                    }
                }
                guard aimable, !options.isEmpty else { return .blocked(.unreachableTerm) }
                if options.contains(where: { if case .not = $0 { true } else { false } }) {
                    deferredGroups.append(options)
                    continue
                }
                if options.contains(where: plans) { continue }  // already met
                guard let choice = choose(options) else {
                    // Every option a dead tag: name the first, as R98 does.
                    if case .tag(let id) = options[0] {
                        return .blocked(.deadTag(path: deadTagPath(id)))
                    }
                    return .blocked(.unreachableTerm)
                }
                take(choice)
            case .legacyEntryDateFrom, .legacyEntryDateTo:
                return .blocked(.datedRule)
            case .legacyProfile:
                return .blocked(.kindRule)
            case .not:
                continue  // checked against the finished plan below
            case .and:
                return .blocked(.unreachableTerm)  // unreachable: flattened above
            }
        }
        // A deferred group the note already meets as planned (a NOT option
        // it vacuously satisfies) needs nothing; otherwise it takes its
        // first satisfiable positive option, as an atoms-only group does.
        for options in deferredGroups where freshNoteMatches(.or(options)) != true {
            guard let choice = choose(options) else {
                return .blocked(.unreachableTerm)
            }
            take(choice)
        }
        // The check: the note the plan makes matches EVERY conjunct — so a
        // NOT contradicting what the plan applies greys the door here, and a
        // door never shows enabled for a press the belt would refuse.
        for conjunct in conjuncts where freshNoteMatches(conjunct) != true {
            return .blocked(.unreachableTerm)
        }
        return .plan(Plan(tagIDs: tagIDs, star: star))
    }
}
