# 13n-b U2 — ladder round 2 (cold re-review of the round-1 fix set, fable-reviewer, 2026-10-09)

**Diff reviewed:** `bb0a3d24..HEAD` (`85f2e4c4`) — the round-1 fix set whole: the reviewer's fixes
`15933ab4` (F1 — the §7 fold classifiers' Private-mark engagement legs, `Sync/` lines) and `d60c3ad6`
(F4 — once-spends-by-first-write-of-any-rung under the AF-7 amendment `d24e77b6`), the dispositions
`87236904`, the implementer responses `30f9a07e`, the sanity pass `afbfc604`, and the orchestrator's
post-sanity pair `ede179c4` (AF-9 — `best()` spends the least sufficient capability) + `85f2e4c4`
(N1 comment rewording), with the format-schema sitting prep `91370059` skimmed (prep-for-her-sitting
material inside the ruled constraint set; no canon claims — nothing to find).
*(Mid-session arrival, judged the same way: `647fc363` — 34 notes-only lines appended to the same
sitting-prep file by the orchestrator while this round ran; zero code, zero review impact.)*
**Anchor:** the round-1 record `13nb-u2-ladder-round1.md` (findings, dispositions, O1/O2, the
look-first list — each judged independently below), the plan's rulings R-13nb-1…19 + AF-1…AF-9 + THE
PRIVATE MARK addendum, **SyncSpec §7's two fold paragraphs read in my own context** (the
seeded-furniture fold's "HER ENGAGEMENT always keeps both, and any doubt keeps both"; the
sample-library matrix's "exactly one edited → the EDITED copy kept"), CLAUDE.md + the auto-loaded
canon. Fresh session; round 1 was a different reviewer.

**Verified myself, in this session (not taken from any record):**
- Every changed source and test file in the range read whole or at the changed sites in context:
  `SeededFurnitureDedupe` (the five SELECTs + both verdict functions + the candidates read),
  `SampleLibraryDedupe` (the book-shape and per-note reads + the classify roads), `MCPGrantRule`
  (the whole file at HEAD — grammar, decide, spends, decideWing, reaches, best),
  `MCPGrantAuthority` (whole), `MCPWriteTools` (onBlock/onNote/noteIntoBook/into/inWing/land/spend),
  `Operations+PrivateMark` (whole), the four F1 pins, the F4 pin changes (the flipped explicit pin,
  the sweep's restated invariant 3 — single-grant worlds, so the biconditional's binding is right),
  the AF-9 `MCPGrantSpendChoiceTests`, and the e2e `aOnceWriteNewGrantIsSpentByItsFirstWriteOfAnyRung`.
- **Every load-bearing pin re-verified red-on-old by MY OWN revert runs, in the worktree, restored
  clean after each** (`git show <pre-fix>:<file> >` swap → targeted `swift test` → `git checkout --`):
  - **F1:** both classifier files at `15933ab4^` → all four pins red, 15 issues total (the two sample
    pins 6 each — `fenceStands` red, proving the mark itself died, and the WRONG copy kept; the
    every-grain pin 2; the gathering-defense pin 1). Green on HEAD.
  - **F4:** `MCPGrantRule.swift` at `d60c3ad6^` → the explicit pin + the sweep red (34 issues: the
    sweep's invariant-3 second direction 30, matching round 1's count), AND the e2e pin red at the
    exact hole (`second.isError == true` failed — the second write LANDED under a spent-should-be
    once write-new grant); the once-SUGGEST e2e pin green on old, as it should be.
  - **AF-9 isolated:** `MCPGrantRule.swift` at `ede179c4^` (post-F4, pre-AF-9) → the two comparator
    pins red (the id-order trap picked `a-writenew`; the scope pin picked the wing grant), the
    standing-outranks-once pin green on BOTH sides as it should be. Green on HEAD.
- **The whole headless package at HEAD (end of this pass): core 2,541/292 · VariorumMCPTests 33/4 ·
  workbook 40/6 — all green**, reproducing the recorded finals exactly; only the long-standing gated
  skips. No Mac-suite run owed (zero Mac-app files in the range; no stage claim taken).
- **Hygiene:** `Sync/` touched in the range by exactly ONE commit (`15933ab4`, the round-1 Fable
  reviewer's own hands — AF-4 honored); zero attribution trailers across the range; branch in sync
  with origin; the worktree clean before my pass.

## The round-1 look-first list, each item judged

1. **F1's legs — CONFIRMED at all five sites**, each SELECT carrying `ai_private_at` and the check
   consuming that same row: the gathering candidates (:226 → `gatheringIsSeedsOwn` :351),
   `guideVerdict` (:528 → :541), `noteVerdict` (:713 → :722), the sample book-shape read (:804 →
   :819), the sample per-note read (:881 → :893). **No sixth site exists:** I enumerated every SELECT
   in both files — the remaining reads are id/plumbing reads, shelf-role reads (shelves carry no
   mark), and block/variant/child-table content reads (the mark lives on `container`/`reading` only).
   All classify roads route through these functions (one call site for `gatheringIsSeedsOwn`; the
   kill-time/revival path routes through the same `SampleCopyClassifier.classify`, so RUN B's defense
   inherits the leg). The pool grain routes through `noteVerdict` (carries the leg as defense) and
   pools are unmarkable (`wrongContainerKind`). The two families' fix shapes match their own ruled
   letters: seeded = ENGAGEMENT keeps both; sample = EDITED, so the MARKED copy is the KEEPER.
   The daily-Journal keeper repair deliberately needs no leg: it is identity convergence, not an
   engagement-gated fold, and the daily Journal's members are journal-fenced regardless (R-13nb-1's
   leg covers `'daily'`), so no disclosure regression is reachable through it.
2. **F4's shared `spends()` — CONFIRMED.** Its only callers are `decide` (:219) and `decideWing`
   (:262); the MCP layer never re-derives spending (grep: no caller outside the rule; the tools
   consume `consumesOnce`). The amended expression is AF-7-as-amended's letter exactly: a once READ
   grant spent by its first content read; a once WRITE grant by its first write of ANY rung ≥
   suggest; reads ride free under a write grant (`decide(onceWriteNew, .read)` → consumesOnce false,
   pinned). `noteIntoBook`'s two-sided spend consumes each side's `consumesOnce` with the Set dedupe.
   No surviving pin encodes the old reading (`grep -i "own rung"`: one hit, a COMMENT — R2-F1 below).
3. **The F1 fixtures isolate the mark — CONFIRMED statically** (`setNotePrivate`/`setBookPrivate`
   write `ai_private_at` + `updated_at` only, no-op-guarded; the classifiers' only `updated_at` hits
   are their own tombstone/rewrite UPDATEs, never reads; the gathering pin's raw UPDATE writes the
   mark alone) **and dynamically** (my revert runs: every marked copy folds/mis-keeps on the old
   classifiers). The "B = larger ids" keeper assertions hold by construction (`furniturePair`
   prefixes A "AA", B "BB").
4. **The record edits — all four present and accurate, read myself:** P-13nb-U2-8's sync twin (the
   plan, with the U3 `edit_take` injected-guard shape); ledger row 5 carrying that guard line;
   P-13nb-U1-2's amended form with the second amendment's "one write means one write" wording and
   the walk note; P-13nb-U1-13's books extension in the U1 round-1 record (its two claims checked:
   the `markingPrivateFencesTheVeryNextCallOfAConnectedClient` pin's last leg asserts the empty
   listing; the fenced-book never-asks guard is `MCPAsking.refusal`'s
   `!(ask.scopeKind == .book && ask.fence != nil)`).

## Round-1 dispositions and the post-sanity pair, judged

- **F1 FIXED — correct, and the keeper refinement is right.** The mechanism was real (my revert runs
  prove the mark died and the wrong copy kept); the fix is `archived_at`'s exact precedent at every
  site; the gathering leg is honest defense (ops refuse the mark there; a carrying row is a doubt,
  and doubt keeps both — the family's letter). Landed before the deploy window, Fable's hands (AF-4).
- **F4 FIXED under the AF-7 amendment — correct.** The amendment itself is sound (the first letter's
  ride-free clause genuinely authorized unlimited suggest-rung writes under a once write-new grant —
  "once" did not mean one write); the fix is the amended letter exactly, pinned both ways plus e2e.
- **F2 RECORDED as P-13nb-U2-8's sync twin + the U3 guard line — right call.** I re-read `land` and
  the decide/act split at HEAD: the trace holds, the degradation is bounded (additive PROOF-class
  writes, one in-flight call, the next call refuses), no deterministic pin exists (a sync apply
  between two transactions of one serial body is a timing flake), and the edit rung's guard line on
  ledger row 5 is the right fence for U3.
- **F3 RECORDED — right, and the sharpened trace is accurate at HEAD:** the success `try log` sits
  inside `land`'s `do` (:438), so a log throw after a landed act falls to the generic catch (:446),
  which re-logs `allowed: false` (:447) — the activity line lies on top of the client's
  retry-duplicate hazard. Same store-death race; record-only is the ladder's own rule.
- **F5 RECORDED — the books extension is in the U1 record and its exposure analysis is right.**
- **O1 (the fence's book route dropped by the OWNED-exclusivity repair) — I CONCUR with
  record-only-as-designed:** the tombstoned membership is one the ownership rules forbade; the
  book-route fence is defined over LIVE memberships; the note's OWN mark — the durable primitive —
  is untouched by every repair. A fence carried by a dead membership would be a ghost. The boundary
  as stated in the round-1 record is the right contract line; a belt would be a new ruled behavior,
  hers to ask for.
- **O2 → AF-9 (`ede179c4`) — the fix is the ruling's letter and the comparator is sound:** a strict
  weak ordering (lexicographic duration-weight desc → rung asc → scope-weight asc → id asc);
  duration primacy untouched (pinned, green on both sides of my revert run); `best()` is called only
  on sufficient sets (verified at all three call sites — lowest-rung-first can never pick an
  insufficient grant) and the open-book branch filters once grants out, so it cannot spend one.
  Two consequences of the ruled letter traced and now STATED in the AF-9 record (R2-F2 below).
- **N1 (`85f2e4c4`) — the intent was right, the execution garbled two sites and missed one** (R2-F1).

## Findings (severity-ranked; format: [severity] · where · what · evidence · fix)

### R2-F1 — [NIT, confirmed — comment-only, zero behavior] · `MCPWriteTools.swift:17`, `MCPGrantAuthority.swift:58` (garbled by `85f2e4c4`) + `MCPGrantRule.swift:190` (missed) · the N1 rewording pass doubled phrases at two sites and missed a FIFTH stale "AT ITS OWN RUNG" comment — in `decide`'s own doc, the rule file future readers consult first

**Evidence (traced):** `85f2e4c4`'s replacement produced "spent by its first write by its first
write of any rung (AF-7 as amended)" (MCPWriteTools:17) and "by its first write of any rung (AF-7 as
amended) (AF-7)" (MCPGrantAuthority:58) — mechanical doubling that reads as nonsense; and
`grep -i "own rung"` finds `MCPGrantRule.swift:190` still stating the SUPERSEDED rule ("a once grant
is spent only by such a call AT ITS OWN RUNG") directly above the amended `spends` — the one doc a
reader of the rule reads first, now contradicting the function below it. No pin owed (wording; the
behavior follows `spends()` everywhere). **FIXED in this round's pass:** the three sites reworded to
the amended letter (plus the awkward `:305` smoothed in passing); build + whole package green.

### R2-F2 — [NIT, record — confirmed, fixed as a record line] · the plan's AF-9 entry · two consequences of lowest-rung-first/narrowest-scope-first were unstated in the PROVISIONAL record her ratification reads

**Evidence (traced):** (1) the preference is PER DECISION, so `add_note_to_book` holding a once NOTE
grant beside a once BOOK/WING grant now deterministically spends BOTH (the note side picks the
narrower note grant — scope note < book/wing at equal rung; the book side has only the wide grant),
where the pre-AF-9 id coin-flip sometimes picked the wide grant for both sides and the Set dedupe
spent ONE. (2) On a content READ where a once READ grant and a once WRITE grant both reach, the read
grant is picked (lowest rung) and SPENT, though the read could have ridden free under the write
grant. Neither direction over-reaches — each spent grant authorized exactly the call made, and the
burn direction is conservative (less capability left standing) — but AF-9 is PROVISIONAL for her, so
the consequences belong in its record (F4's own precedent: an under-stated consequence is a record
finding). **FIXED:** one stated-consequences paragraph appended to the AF-9 entry in the plan.

No other findings. **No new BLOCKER or MAJOR — no round 3 owed.**

## Clean bill (load-bearing things specifically checked and found solid)

- **F1's fix honors the fold families' ruled letters exactly** (SyncSpec §7 read in my own context):
  engagement-keeps-both in the seeded family; edited-copy-is-the-keeper in the sample family; the
  five sites are the complete set (every SELECT in both files enumerated; every classify road routes
  through them, the RUN B kill-time/revival path included); the pool grain needs no leg and carries
  one anyway; the daily-Journal keeper repair needs none (journal fence covers the class). The fix
  is `Sync/`-only, Fable's hands, landed BEFORE the deploy window — marks become real synced data
  already protected.
- **The F4/AF-9 rule at HEAD is internally consistent:** `spends`' amended expression ⇔ the sweep's
  invariant 3 ⇔ the explicit pins ⇔ both e2e pins; `decideWing` and `noteIntoBook` inherit through
  the one `spends`/`consumesOnce` seam; no caller re-derives spending; `best()` only ever sees
  sufficient grants; the open-book road can never spend a once grant; a refused act never spends
  (the stamp sits after the act inside the serial body); `Rung`'s Comparable order (read < suggest <
  write_new < edit) makes `rung >= .suggest` the exact "any write" test, U3's edit rung included.
- **The AF-9 comparator is a valid strict weak ordering** and deterministic across devices (ids as
  the final leg); the id-trap pin asserts both id orders, so the answer provably does not move with
  the UUIDs.
- **All seven round-1 pin classes re-verified red-on-old by my own revert runs** (F1's four, F4's
  three) **plus AF-9's two isolated against `ede179c4^`** — none hollow; the standing-outranks-once
  pin green on both sides exactly as an invariant pin should be.
- **The records are accurate as committed:** the dispositions table matches what landed; the
  fix-pass counts reproduce (2,538/291 at `87236904`, 2,541/292 at HEAD — the +3/+1 is
  `MCPGrantSpendChoiceTests`); the sanity pass's claims each checked against the code.
- **Hygiene:** one `Sync/` commit in the range (the round-1 reviewer's, AF-4); zero trailers; zero
  custody, zero editor seam, zero Mac-app files; the deploy stays HELD (ledger row 9 untouched);
  branch pushed and in sync.

**VERDICT: CLEAN BILL on the round-1 fix set — 0 BLOCKER · 0 MAJOR · 2 NIT (R2-F1 comment garble +
the missed fifth stale comment, fixed in this pass; R2-F2 AF-9 record consequences, stated in this
pass). The U2 ladder closes at round 2.**

**This round's own pass (fable-reviewer, round 2):** R2-F1's three comment sites reworded (+ `:305`
smoothed) and R2-F2's consequences paragraph added to the AF-9 plan entry — comment/record lines
only, zero behavior, no pin owed by the ladder's own rule. Whole headless package at the end of the
pass: **core 2,541/292 · VariorumMCPTests 33/4 · workbook 40/6 — all green**, gated skips only.
