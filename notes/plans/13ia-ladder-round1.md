# 13i-a — LADDER ROUND 1 (2026-10-01; fresh fable-reviewer, REVIEW_PROMPT verbatim, zero framing)

**Verdict: 2 BLOCKER · 3 MAJOR · 4 MINOR · 1 NIT**, plus a clean bill covering the migration's
structure, all five repairs' ruled shapes, the v2 grammar's per-site v1 letters, the
classifications, the artifact and the process rows. Findings verbatim-faithful below with the
ORCHESTRATOR DISPOSITIONS (same-model flow — the orchestrator arbitrates against the spec).

## FINDINGS + DISPOSITIONS

**B-1 (BLOCKER) — `Repairs.swift` branch 1 of the reading_post dedupe promotes the KEPT row to
'member' and never enqueues it.** The reviewer's trace: asymmetric rounds leave A='arrival',
B='member', server='arrival', forever; the 8 convergence tests pass only because
`syncToQuiescence` is symmetric. **DISPOSITION: CONFIRMED — fix.** `enqueueExplicitly` on the
kept row when the promotion fires; the pin is the reviewer's own (single-client apply asserting
the outbox row; red-on-old).

**B-2 (BLOCKER) — pre-window mirror rows arrive with EXPLICIT NULL in the new NOT NULL client
columns (`container.wing_id`, `tag.wing_id`, `reading_post.status`, reading's rebuilt set);
`to_jsonb` emits present nulls; `SyncRow.apply` writes them verbatim → `SQLITE_CONSTRAINT_NOTNULL`
→ a fresh device's / resync's first pull refuses forever.** The "absent reads as default" defense
covers absence only (which Postgres never produces), and its claimed pin was never written.
**DISPOSITION: CONFIRMED — fix BOTH ends.** (1) The general client normalize: an arriving `.null`
for a column the LOCAL schema declares NOT NULL WITH a default lands as that default
(schema-introspected — covers every future event); pinned red-on-old with crafted rows. (2) The
deploy artifact BACKFILLS the three added columns (`''` / `'member'`) so pre-window rows carry
real values — belt and suspenders; the backfill rides the same transaction.

**M-1 (MAJOR) — the v1_18 upgrade-path pins the plan owes do not exist** (schema equivalence by
name only; no upTo-v1_17 seed-then-migrate suite; no recast/pins→starred/daily-stamp/v2-conversion/
enqueue-all/CAS-preservation data pins). **DISPOSITION: CONFIRMED — build the suite before the
window** (the bridge-retirement test's pattern; red-by-construction accepted for migration pins).

**M-2 (MAJOR) — the daily Journal LOSES its journal-trait faces** (both "+ new entry" doors,
the phone's "entries" unit, `ShelfOrder`'s journal group) — those sites key the trait on
`profile == "journal"` and the designated book is now `'daily'`. **DISPOSITION: CONFIRMED — fix.**
ONE shared trait predicate consumed by every site ('daily' HAS the trait by construction, sitting
record §10); pinned red-on-current.

**M-3 (MAJOR) — `setDailyJournalBook` never moves the 'daily' marker**, so re-designation leaves
a stale marker-bearer and the keeper repair can later MERGE two marker-bearing books — the F6
class re-opened through staleness. **DISPOSITION: CONFIRMED — fix in the op** (the db-level
designation write demotes every OTHER live 'daily' row to `'journal'` and stamps the live
designee `'daily'`, one transaction); pinned red-on-current via `dailyJournalBookCandidates`.

**MIN-1 (MINOR) — the migration launders a malformed v1 spec to NULL (match-all), contradicting
the write seam's own store-raw ruling.** **DISPOSITION: CONFIRMED — fix** (keep bytes raw);
asserted inside M-1's suite.

**MIN-2 (MINOR) — five stale/contradictory doc comments on the load-bearing predicates**
(`dailyJournalBookProfile`'s minting-doors claim; `isDailyJournalMintShape`'s outer three-leg
narration; `dailyJournalBookCandidates`' name-leg claim; RuleGrammar's header vs its ReadResult
doc; one repair test's inverted fixture comment). **DISPOSITION: CONFIRMED — fix (doc-only).**

**MIN-3 (MINOR) — the `status` sweep is assembly-only: the capacity gate, the shelf postCount and
the Pool's bookless exclusion read an 'arrival' as a member/home** (dormant until the repairs
mint one post-window). **DISPOSITION: CONFIRMED — fix now** (three WHERE clauses + raw-row pins;
cheaper than a parked surprise, and §4's letter — "membership rows counted" — is the spec).

**MIN-4 (MINOR · SPECULATIVE) — ruleSQL's subtree walk matches applied tags by PATH without wing
scoping; no door can create the cross-wing application today.** **DISPOSITION: RECORD-ONLY** (the
hallucination guard: unpinnable by construction today) — handed to 13i-b/c's door enumeration as
a named hardening line (constrain `applied.wing_id = root.wing_id` when cross-wing applications
become mintable); noted in the plan §9.

**NIT — the repair tests assert quiescence, not the §7-mandated outbox rows.** **DISPOSITION:
CONFIRMED — outbox asserts land with B-1's fix.**

## THE FIX SESSION
B-1 · B-2(both ends) · M-1 · M-2 · M-3 · MIN-1 · MIN-2 · MIN-3 · NIT — all with red-on-old pins
where a pin can exist; then ROUND 2 (fresh reviewer). THE WINDOW EXECUTES ONLY AFTER ROUND 2.
