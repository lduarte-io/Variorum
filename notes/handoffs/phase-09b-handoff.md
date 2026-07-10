# Phase 9b handoff — the Fragments journal bridge (closed 2026-07-09)

A self-contained checkpoint for the author. A fresh session can answer questions about
this phase from this document + the phase plan's closeout
(`notes/plans/phase-09b-fragments-bridge.md`) — never by waking the build session.

## What you need to do next — the checklist

1. ~~Carry the contract asks to your Fragments agents~~ — **DONE (you carried them
   2026-07-09 evening; the answers are back and reconciled).** Asks 8–12 and 14
   ANSWERED (recorded verbatim-in-substance under the asks in
   `notes/fragments-bridge-contract.md`; the derivation layer confirmed end to end,
   several wire/semantics facts corrected and reconciled into code the same night —
   the phase plan's "Checkpoint reconciliation round" has the full
   confirmed-vs-corrected ledger). **The only open item from the asks is 13** (return
   the replaced body): their agents confirmed it feasible; it is NOT built and NOT
   promised — **your own pending call on the Fragments side**; the bridge assumes
   nothing. **The real-project pass is now gated on 9c's sign-in ONLY.**
2. ~~Walk QUESTIONS #13, #14, and #15 at the checkpoint~~ — **DONE (2026-07-09
   checkpoint): you RATIFIED all of it** — #13's handling (c); #14 (a)–(e) as shipped
   with both consequences acknowledged and the sealed-empty DEFER shape ratified;
   #15's hash sweep + 60 s throttle (the dirty-day remedy stays Phase 12's); and the
   two canonical-doc deltas blessed (statuses in QUESTIONS + AppSpec §14's checkpoint
   delta). Kept below for the record — originally: walk QUESTIONS #13, #14, and #15 — #13 ratifies the
   contract-gap handling; #15 ratifies the push sweep's P1 relaxation (+ the 60 s
   cadence throttle, added at the round-1 review — an author-only invariant call);
   #14 ratifies five landing/projection readings: (a) Variorum-side journal
   deletion does NOT propagate to Fragments; (b) a Fragments deletion racing a Variorum
   edit loses to the edit (truth re-projects); (c) sealed/locked entries land incoming
   bodies as `'fragments'` variants despite the seal — the sealed-EMPTY corner was
   RE-SHAPED at round 3 (its MAJOR: the old consume-the-row reading destroyed the
   body after unseal-and-type; now the feed visibly HOLDS until you unseal, then the
   body lands — shape (a) PROVISIONAL, alternative (b) day-scoped hold recorded,
   ratify the shape with this item);
   (d) after a both-changed conflict, the next push re-projects Variorum's truth over
   the Fragments row (its text is momentarily behind, preserved as a card here) —
   and the conflict card fans the block, flipping the day into the push-only
   graduated regime until the card is pruned; (e) archived entries still push, and
   they also COUNT toward the duplicate-day pause (archiving does not release it;
   delete or re-date does). Each option set + traced mechanism is in the
   closeout's PROVISIONAL section.
3. **Kick off Phase 9c** (`/run-phase 9c`) — the plan is authored and self-contained:
   `notes/plans/phase-09c-auth-alignment.md`. Note its **Step 0 is an author-assist
   spike at both Supabase dashboards** (the one-account trust route needs you), and its
   Step 6 folds in everything you deferred: the Phase 8 device rounds AND this phase's
   real-Fragments pass.
4. **Nothing to test on devices yet** — per your 2026-07-07 call, all sync/device
   testing (and daily use) waits for 9c. The bridge deliberately ships UNCONFIGURED in
   the app (the status row says "Fragments bridge off (sign-in arrives with 9c)"); no
   setup door exists by design — no paste-in successor was built, because 9c retires
   that whole mechanism.
5. **Still pending from earlier phases:** the combined Phase 7 §5 + Phase 9 feel pass
   (one sitting, post-9d build) — unchanged by this phase.

## What shipped and why it's shaped this way

**The doctrine, implemented:** Variorum is the journal's home and truth; Fragments'
`journal_entries` is a co-writer projection surface (one plain-text body per calendar
day); your user-set `entry_date` is the join key. The bridge pushes `renderedText` per
day out, and lands everything Fragments-side wrote through ORDINARY Variorum
operations — every landing path ends in a live row, a labeled variant, or a commit, so
nothing typed in either app can be lost where truth lives.

- **`Sources/VariorumCore/Bridge/`** — the contract layer (deterministic-id derivation
  with the namespace as configuration; the `sync_push`/`sync_pull`/`sync_delete`
  dialect over URLSession, wire shapes PROVISIONAL pending ask 11; the
  `FragmentsSessionProviding` auth seam 9c absorbs — user-auth per call, never the
  PAT, zero coupling to the Phase 8 paste-in), the `BridgeEngine` (pull→push rounds),
  and the `BridgeScheduler` (serialized, coalescing, offline-is-free).
- **Push:** unchanged text NEVER pushes (the mirror of Fragments' clobber guard — a
  pointless `updated_at` bump would LWW-overwrite a real Fragments edit; pinned down
  to the fake server's write counter). A **duplicate day pushes NOTHING, visibly**,
  until you hand-merge (Fragments is DB-unique per (user, date) — a slipped push
  would overwrite one text with the other there). Change detection is a per-day
  rendered-text hash sweep — deliberately not a timestamp filter, because several
  operations change rendered text without stamping the container (traced in the
  closeout); the corpus-growth note is in KnownIssues, owned by Phase 12.
- **Landing:** unknown day → create-or-open + the body as THE block (the notebook
  rule). Only-Fragments-changed → **the fifth quiet auto-commit occasion** (your
  2026-07-07 decision): the current text is committed if it differs from the last
  commit, THEN overwritten — anything edited or deleted in Fragments stays one
  restore away in the commit view. Both-changed → the Fragments body becomes a
  **`'fragments'`-labeled variant** in the fan (S5 extended to the second writer),
  and the next push re-projects your Variorum text. **Graduated entries** (multi-block
  or fanned) are push-only, exactly as you ratified: incoming bodies become
  `'fragments'` variants on the first block, never diff-mapped back across blocks.
- **The app wiring:** bridge rounds run AFTER sync rounds, never interleaved; the A4
  fence extends (dev stores never bridge; Mac-only this phase); one unstyled status
  row under the sync row shows last-bridged time and any paused days.
- **Step 6:** `setEntryDate` now refuses malformed day keys (canonical `yyyy-MM-dd`
  or error; nil still allowed) — the last permissive door to a day the bridge's join
  could never find. The mobile date picker was verified by test to produce canonical
  keys. KnownIssues row resolved.

## Verification (headless — the real pass is deferred, deliberately)

- **Core `swift test`: 513 green in 59 suites** (was 430/51). **Mac app: 235 in 43**
  (was 231/42). **Mobile: 11 in 4** (unchanged). These are the 9c baselines, after
  the FULL review ladder (three rounds, 2026-07-09, fresh reviewer each; closed at
  the hard cap) AND the same-evening checkpoint reconciliation of the Fragments
  agents' answers (asks 8–12/14 — derivation confirmed, wire shapes + tie semantics +
  created_at model corrected, the fail-closed canonical-user gate and the
  derivation-bug poison added; the 9c reviewer is directed to that diff). Round 1: 2 MAJOR / 3 MINOR / 3 NIT — the landed Fragments body now
  gets its own quiet auto-commit inside a one-transaction landing, and the push
  sweep's P1 relaxation went to your ratify list as #15 with a 60 s cadence
  throttle. Round 2: 1 MAJOR / 3 MINOR / 4 NIT — pushes now stamp minimally above
  the last SEEN remote stamp (compare-and-set style), closing the steady-state
  unseen-save loss window this handoff previously mis-scoped; `createPost` gained
  the day-key guard; `applyBridgeLanding` binds variant to container; OverallModel
  §3 + AppSpec §9 record the shipped landing mechanism (**bless these two doc
  deltas at the checkpoint**). Round 3 (final; fixes post-cap per the ladder):
  1 MAJOR / 2 MINOR / 2 NIT — the sealed-empty landing now DEFERS with the cursor
  held instead of consuming the row (the consumed body was destroyed by the first
  post-unseal push; **the shape is PROVISIONAL — ratify it with #14(c)**); gap-slot
  days never push a partial rendering; the two stale stamp-formula carriers
  corrected; the clamp interaction pinned + contract ask 14. Every disposition in
  the phase plan's three round sections; round 3 also judged the round-2 stamp fix
  SOUND and accepted the flagged error-case-reuse call.
- Every scenario in the brief's verification skeleton has a named test: both-direction
  round trips, echo/replay idempotence, the auto-commit-then-autosave landing (and its
  no-double-commit twin), conflict variants with LWW convergence, insured deletions,
  deletion-vs-edit races, graduated rescue, sealed-entry rescue, duplicate-day
  pause/release/lands-while-paused, visibility-horizon honoring, lost-ack
  reconciliation, malformed/foreign rows.
- A 3-seed randomized soak (60 interleaved actions each): at quiescence the surfaces
  converge byte-equal, a quiescent round makes ZERO server writes, and every
  `'fragments'` variant traces to a body Fragments actually wrote (nothing invented).
- The bridge ran WITH the mirror sync engine (two simulated devices + the fake
  Fragments server): Mac-authored, phone-authored, and Fragments-authored days all
  reached all three surfaces; the two Variorum stores ended byte-identical.
- **The automated suites never touch your real Fragments project** — everything runs
  against an in-process fake pinned to the contract, fact by fact, by its own test
  suite. The manual real-project pass runs at 9c Step 6(iv), after the asks land and
  the real sign-in exists.

## Findings + dispositions in brief

1. **The contract gap (the phase finding, QUESTIONS #13):** the contract lacked the
   namespace, worked examples, canonical-user form, and wire shapes. Judged
   non-core-gating (only the deferred real pass consumes them); handled as injectable
   config + RFC-pinned algorithm + stand-in golden vectors + asks 8–13. Never guessed.
2. **The LWW push-stamp discipline (round 1 found the clock-ahead wedge; round 2
   replaced the formula):** pushes stamp `last_remote_stamp + 1s` — minimally above
   the newest server-row stamp the bridge has SEEN or WRITTEN (`bridge_day` records
   landed stamps AND accepted pushes' own stamps), never the wall clock when a stamp
   is known. This both outranks a clock-ahead landed row (round 1's wedge) and goes
   `.stale` against an unseen Fragments save (round 2's loss window) — the push is a
   compare-and-set against what the bridge knows. `now` only on first contact or an
   unparseable stamp.
3. **The unseen-save overwrite window (round-2 MAJOR — was mis-scoped here as
   first-contact-only):** pre-fix, a Fragments save the same round's pull couldn't
   see (saved after it, or inside their ~2 s horizon) was overwritten by the push's
   wall-clock stamp on ANY day and lost everywhere. Fixed: pushes now stamp minimally
   above the last remote stamp the bridge has SEEN (compare-and-set style), so an
   unseen save wins LWW, survives, and lands as a conflict card next round
   (red-on-old pinned). What remains: first contact (no stamp known yet), 1 s stamp
   granularity (sharpened at reconciliation: their ties go to the PUSHER, so an
   exact-tie unseen save is overwritten, not staled), unparseable stamps — ask 13
   (return the replaced body) closes all of it; **their agents confirmed ask 13
   feasible but it is NOT built — your own pending call on the Fragments side**;
   same documented-race class as SyncSpec §7's concurrent-divide duplication.
4. **Landing readings (a)–(e)** — QUESTIONS #14, above.
5. **KnownIssues:** `setEntryDate` row resolved and removed; one row added (the push
   sweep's O(journal-days) cost, owner Phase 12, remedy sketch recorded).

## PROVISIONALs awaiting you

QUESTIONS **#13** (contract-gap handling) and **#14 (a)–(e)** (landing/projection
readings). Full options + mechanisms in the phase plan's closeout.

## Where things live

Plan + closeout: `notes/plans/phase-09b-fragments-bridge.md` · Contract + asks:
`notes/fragments-bridge-contract.md` · 9c plan: `notes/plans/phase-09c-auth-alignment.md`
· Code: `Sources/VariorumCore/Bridge/`, `App/Variorum/Shared/BridgeSession.swift` +
`BridgeStatusViews.swift` · Tests: `Tests/VariorumCoreTests/Bridge*`,
`Fragments*Tests`, `FakeFragmentsServer*`, `App/Variorum/VariorumTests/Phase9bBridgeWiringTests.swift`.
