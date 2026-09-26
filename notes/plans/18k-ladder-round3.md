# 18k LADDER — ROUND 3 (Fable cold review of UNIT C8's test changes + the orchestrator-adjudication audit; opened by R-18k-9 / R-18k-10, not by a round-2 finding)

**Reviewer:** `fable-reviewer`, fresh session, zero implementation context. **Scope, per her two
rulings:** (1) a cold review of C8's diff before the install refresh (R-18k-9); (2) an audit of every
`ORCHESTRATOR ADJUDICATION` section and THE FINALS diagnosis, because the orchestrator seat ran Opus 5.5
against the standing cast (R-18k-10). **Anchor:** rounds 1–2's findings files
(`18k-ladder-round1.md` `af2a761b` · `18k-ladder-round2.md` `cfa3b7b1`) — both 0 BLOCKER / 0 MAJOR over
the combined diff; their dismissals were taken as the thread, and the code-level substance of C1–C7/C6b
was NOT re-derived blind (two genuinely-Fable passes already read every production hunk). **Diff under
review:** `e1205837..HEAD` — since the ladder closed, exactly ONE code file changed:
`App/Variorum/VariorumTests/AutosaveRegistryLifecycleTests.swift` (+30, commit `36127aee` — the
`MountedEditor` `isolated deinit`); everything else is records + her 18l input captures (verified by
`git diff --name-only`, not the record). **Canon read:** CLAUDE.md, AppSpec §7/§9/§14, OverallModel
I1–I10/P1–P3/S1–S5, SyncSpec, TEXTKIT2_NOTES §3–§5, KnownIssuesAndTechDebt, QUESTIONS; the 18k plan's
kickoff rulings, THE FINALS, the C8 BRIEF/RECORD/adjudication, and all ten adjudication sections. No
"Review foci" section exists (rounds 1–2 grep-verified; confirmed by this session's own heading scan).
Her real-store app was live throughout (pid 35345, never touched); the full Mac suite was NOT run, per
the round's own instruction — targeted suites only.

---

## PART 1 — THE C8 DIFF (the cold review)

**What I verified myself, not taken from the record:**

1. **The fix read whole, in context.** The entire leaker file re-read (both suites, all 15 tests);
   the victim suite (`MacIdentityAuditWiringTests`, `IdentityProjectionAuditTests.swift:148–298`)
   read whole; `EditorSurfaceDelegate.wire(to:)` (`EditorView.swift:717–721`) and
   `EditorViewModel.attach(textView:scrollView:)` read at the code. **The deinit's two delegate
   detachments exactly undo `wire(to:)`'s two wirings** (`textView.delegate` = the NSTextViewDelegate
   road incl. selection reports; `textStorage.delegate` = the `didProcessEditing → storageDidEdit`
   road) — there is no third edit-report road on this surface (the C2 storage-notification hop lives
   in `InlineEditorSurface`, which `MountedEditor` never mounts; the remaining textView closures
   capture the model weakly and report geometry, not edits).
2. **The mechanism re-derived independently — including why ONLY T1/T2 leak.** The trace's
   discriminator holds at the code: T1/T2 TYPE their text (so the run carries the TYPING attributes'
   paragraph-style object) and teardown's finalize crystallizes-and-stamps it as the world's FIRST
   block (`.incrementing` → the id every harness world's block 0 shares). A surviving storage of that
   exact shape is content-equal to a later victim's block-0 dictionary, so AppKit's process-wide
   attribute-dictionary uniquing hands the victim a block-0 run whose paragraph-style OBJECT equals
   the typing one — and the widening pin measures precisely that object-inequality. Ordinary
   `withEditor` worlds render their blocks via `applyProjection` (the BASE style object), so their
   dropped storages preserve the inequality — which is why hundreds of pre-18k dropped editors never
   turned the victim red, and why `withEditor` tests that DO type a tail (e.g.
   `ordinaryWritingNeverTripsTheAudit` crystallizes "a fresh paragraph") don't couple today only
   because their typed block is not block …0001. The filed KnownIssues class row (owner 12,
   "typed into and stamped under the shared `.incrementing` ids") states exactly this condition —
   verified filed in `58711670`, with an owner, per the header rule.
3. **My own run of the reproducing pair on the final tree** (zero-instance check first; her
   real-store app identified by path and left alone):
   `-only-testing:VariorumTests/AutosaveRegistryReleaseGuardTests
   -only-testing:VariorumTests/MacIdentityAuditWiringTests` →
   **`✔ Test run with 12 tests in 2 suites passed`**, the guard suite ordered before the victim —
   the reproducing order, green under my own eyes.
4. **The proof logs read (DerivedData, gitignored):** pair pre-fix RED 3/3 with exactly the
   `(spy.reports → [{2, 1}]) == [{2, 5}]` issue (`18k-c8-pair-prefix-r{1,2,3}.log`); fixed GREEN 3/3;
   behavioural revert R-C8 RED identically with the empty-out line alone disabled, restored GREEN
   (`18k-c8-R-C8{,-restored}.log`) — so the one load-bearing line is proven the load-bearing line;
   the file + `AutosaveRegistryReleaseTests` 22/22; the one-test bisect T1/T2 red, T3–T7 green
   (`18k-c8-leakT{1..7}.log`); the soak's 22 reproduction attempts all green
   (`soak-alone-x10` 30/10 · `soak-load-x6` 18/6 · `soak-guard-r{1..3}` 10/2 ×3 ·
   `soak-touched-r{1,2}` 325/50 ×2).
5. **Test semantics unweakened.** No test in the file reads the surface after `surface = nil`
   (the doc comment's claim, verified line by line); the empty-out cannot reach the DB — the
   delegates are detached first, and the savepoint/leaving roads read the store and the coordinator,
   never `NSTextStorage`; T1's exact-equality savepoint assertion
   (`== ["a paragraph she never finished"]`) would catch any stray savepoint the empty-out produced.
   Every assertion, `withRegistryWorld`, `type(_:)` and the init's wiring are byte-untouched (the
   diff is 30 added lines, zero changed).
6. **`isolated deinit` correctness.** `MountedEditor` is `@MainActor`; every current drop site
   releases on the main actor inside a test body, so the deinit runs synchronously at
   `surface = nil` — before any later suite's main-actor work — and it also covers early-throw
   paths a per-test `close()` would miss. (If a future test ever dropped the last reference
   off-actor, the deinit would be scheduled onto the main actor — still ahead of any later
   main-actor test body in this serialized world; noted, not a hazard today.)
7. **Judgment calls 1–4, each reviewed: all four ENDORSED.** (1) deinit over per-test close — also
   covers throw paths, and no future user of the helper can forget it. (2) put-back over
   id-namespacing — restores the process state rather than hiding the coupling; the class row
   records the namespace remedy for the wider family, which is its right home. (3) detach-first
   order — verified against `wire(to:)`; the R-C8 revert shows the detaches are safety, not effect,
   exactly as recorded. (4) the soak recorded-not-fixed — the pin-before-fix rule applied: with no
   reproduction there is no mechanism and no red-on-old pin, and "fixing" it would be the hollow-fix
   failure mode; the owed full run is the right adjudicator.
8. **The victim unchanged — correct under the brief's own rule.** Its residual fragility (any future
   helper that drops a typed-and-stamped FIRST block re-couples it) is real, filed, and owned
   (the class row, owner 12) — deliberately-deferred work, not a missing fix.
9. **Fences and hygiene:** zero `Sources/`, zero app code, zero `Shared/`, zero `Sync/`, zero
   schema in the round's diff; zero commit trailers on all 13 C8-window commits (grep over every
   message); every commit pushed; pathspec-limited staging throughout; the scratch instruments never
   committed (grep for `ZZC8ScratchProbe`/`C8ScratchLeakers` in the tree: absent).

**C8 diff verdict: 0 BLOCKER · 0 MAJOR · 0 MINOR · 0 NIT.** The fix is minimal, correctly placed in
the leaker, proven red-on-old by behavioural revert, and its doc comment is an accurate record of a
subtle mechanism.

---

## PART 2 — THE ADJUDICATION AUDIT (R-18k-10)

**Method.** All ten `ORCHESTRATOR ADJUDICATION` sections (C1 · C2 · C3 · C4 · C6 · C5 · the held
walks · C7 · C6b · C8) and THE FINALS diagnosis read whole in this session. The code-level substance
under C1–C7/C6b was already cold-verified twice by genuinely-Fable rounds 1–2 (their files are this
round's anchor); this audit therefore re-checked the JUDGMENTS — acceptance evidence, dismissals,
ownership filings, scope fences, and the application of her rulings — with independent spot-checks
wherever a claim was cheaply checkable, and it re-checked that every "flagged for the ladder" item
actually received a disposition somewhere.

**Audited sound (spot-checks named):**

- **C1** — accepted on red-on-old pins + the M2 mutation; the drop-through-leaving design correctly
  flagged as the run's highest-value target and duly stress-traced by round 1. Every hand-back item
  carries a disposition with an owner: the Open-strip tenth-row trap verified filed (KnownIssues,
  owner 18o); item 3 became her R-18k-6 the same night, verified filed as a RULED build row (18o).
- **C2** — "hypothesis DISPROVED honestly" is the pin-before-fix doctrine applied to a hypothesis;
  the deferral landed as hygiene with its own red-on-old pins; the shadow-editor ledger row closed
  as resolved-by `f8610cb9` matches the recorded bisect.
- **C3** — DISMISSED AS HOLLOW **by measurement** is the right verdict form for a hygiene premise
  (the S3 verdict-table precedent); the 18l carry (PaneSurface is ALL of the measured warning count)
  is recorded where 18l's kickoff will read it.
- **C4** — the parallel-suites axis honestly excluded and opt-in-fenced; the carried
  `EditorTypography.current` row verified in KnownIssues (owner 12); the mid-unit "last live writer"
  correction flagged to the ladder and covered by round 1's clean bill item 6.
- **C6** — row 65 closed with all five mechanisms; the re-assert flagged to the Fable ladder and
  traced there (round 1 clean bill item 2).
- **C5** — the closing set's 2 issues adjudicated by the paired interleaved protocol (the traps' own
  flake rule), not waved through; dispositions verified copied into the 17e entry (grep); the
  ceremony-branch residue verified filed (KnownIssues row, owner 18o). O-3 (the 0 ms synthetic
  double-press showing nothing) is correctly a recorded observation, not an unowned defect — the
  walk itself establishes the second synthetic event's delivery to the app is "not established",
  and the safety expectation held 9/9 at every real inter-press gap.
- **The held walks** — findings re-owned INTO the run (W-4/W-2 → C6b, W-3 → C7) rather than parked:
  the right call, and both units landed with red-on-old pins inside the same run. The read-only,
  names-only listing of her real `Backups/` was proportionate to a data-safety exposure and led her
  morning bundle; W-1/O-2 filed with owner 12.
- **C7** — accepted with the exposure verified in the field (her real folder's names, read-only)
  BEFORE acceptance; the face-as-defect dismissed as hollow on a both-sides-green guard, the rule's
  letter; the future-stamp residue verified filed (owner 18o).
- **C6b** — the rebuilt `ScrollAnchorTests` expectation accepted on the right grounds (its target
  defect still bites — round 1 re-verified M-inset red twice) and flagged to the ladder as promised;
  #147 PROVISIONAL in her bundle, verified in QUESTIONS.
- **C8** — the acceptance matches the evidence (Part 1); the full Mac run correctly HELD for the
  zero-instance window rather than raised over her live session, and sequenced before the closeout;
  the harness-class row verified filed with owner 12 in the acceptance commit itself.
- **THE FINALS** — the two-run reading, the pre-18k base-tree control (`3a07b875` verified =
  `1b7858eb^`), and the leak verdict for the WIDENING red all check out — C8 then proved that
  verdict's mechanism exactly. (The soak half: finding 1 below.) The base run's two
  `NoLiteralColourTests` offenders attributed to the scratch worktree's `/private` prefix were not
  re-verified here (the worktree is gone); the claim is incidental to the diagnosis and nothing
  rests on it.
- **R-18k-9 / R-18k-10 compliance** — this round is the rulings' own execution: Fable seat, C8 scope
  plus the audit, findings file as named, the refresh gated on this disposition. The
  transcript-verified model claims for rounds 1–2 (`claude-fable-5` on every call) are taken as
  recorded — I cannot re-read another session's transcript — but the round files' method and
  evidence are consistent with genuine cold passes: their verification-run logs exist in
  DerivedData with the counts they claim, and every dismissal I spot-checked traced true at the code.

---

## FINDINGS (severity-ranked)

**No BLOCKER. No MAJOR. No MINOR.** Four NITs — all records-level, none touches code, none gates the
refresh; none is a bug-class finding, so no red-on-old pin is owed by any of them.

1. `[NIT]` · plan file, THE FINALS section · **The verdict sentence attributes BOTH in-context reds
   to "a test-isolation leak INTRODUCED BY 18k"; C8 established that for the widening red only.**
   Evidence: C8's own DISPOSITION — the soak red "NOT REPRODUCED — no leaker found" after 22
   executions (alone, under load, after the leaker, after all 49 preceding touched suites), "read as
   a realization-timing race, marked as reading", adjudicated at the owed full run. THE FINALS'
   text was never amended and carries no forward pointer, so a future reader of that section alone
   inherits an over-claim about the soak. Fix: one bracketed line in THE FINALS at the closeout
   ("the soak half of this verdict did not survive C8 — see its disposition; the owed full run
   adjudicates it"). Records only.

2. `[NIT]` · plan file, LIVE STATUS (final line) + THE LEDGER table · **Records currency.** The
   trailing "NEXT: C7 → C6b → the ladder → finals → closeout → refresh → 18o" line is stale (every
   named stage is DONE in the lines above it), and the ledger table carries no C8 row — C8 exists
   only in LIVE STATUS and its own sections, though the ledger's header rule is "every row owned".
   Also half a shade: "C8 — DONE, ACCEPTED" reads one step ahead of the unit record's own first
   line ("the unit does not close here" — the full run is OWED); the parenthetical carries the
   truth. Fix at the closeout: drop the stale NEXT line; add the C8 ledger row (fix accepted;
   full run owed at the window).

3. `[NIT]` · `App/Variorum/VariorumTests/BookOutlineLandingTests.swift:108–123` + plan C7
   adjudication item 5 · **Two flagged-for-the-ladder threads never received a recorded disposition
   in rounds 1–2; audited here, one is stale and one is moot.** (i) The `writingEditor(in:)` doc
   still asserts the harness "can realize TWICE" the Outline's editor — stale since `f8610cb9` by
   C2's own bisect (C2 NOTICED item 7, carried by C3's adjudication "→ the ladder"); the helper's
   logic is harmless (C2's words) — one comment correction at the next touch of the suite.
   (ii) C7's "Castle's lock-time copy has no test of its own → the ladder" is MOOT on inspection:
   `SnapshotPairTests.theLockTimeCopyIsKeylessCiphertextPairedAndCheckedAtTheNextRun` is exactly
   that test — the write road (`performLockTimeCopyIfDue`), the keyless-ciphertext and
   no-key-bytes checks, the paired key file, the not-due arm, and the next-unlock check with the
   pending-list clear — and lock-time names carry the same `-<8 hex>` fingerprint suffix the C7
   own-names rule admits (`isFingerprintSuffix`'s own doc names "the lock-time copy write"), so
   the C7 listing change composes with the family under existing coverage. Close the flag as moot
   at the closeout — or restate it narrowly if the orchestrator meant a Castle-posture arm this
   direct-drive test does not reach. Neither item is a bug; no pin is possible or owed for either.

4. `[NIT]` · `notes/handoffs/phase-18k-handoff.md` (untracked; mtime 18:04) · **The handoff draft
   predates C8 entirely** — it knows nothing of the isolation leak, R-18k-9/R-18k-10, the ladder's
   three rounds, or her three same-evening reports (U0 · U0b · U-VIS, all now 18l's) — and sits
   uncommitted. Expected for a draft (the handoff is the closeout's LAST duty), recorded so a
   hurried closeout does not commit it as-is; the resiliency protocol also prefers drafts
   committed rather than living only in the working tree.

---

## CLEAN BILL (checked specifically in THIS session, found solid)

1. **The C8 fix** — mechanism traced and independently re-derived (including the discriminator for
   why only T1/T2 leak), scope exactly one test helper's deinit, red-on-old proven by behavioural
   revert on the single load-bearing line, semantics of every test in the file unweakened.
2. **My own green run of the reproducing pair** on the final tree (12 tests / 2 suites, the
   reproducing order).
3. **Commit hygiene across the C8 window** — 13 commits, zero trailers, pathspec-limited, all
   pushed; per-piece record flips per the resiliency protocol.
4. **The scope fences since the ladder closed** — one test file (+30) is the entire code diff;
   zero `Sources/`, zero `Sync/`, zero app code; her real store and `/Applications` untouched;
   the full Mac suite never raised over her live session.
5. **The KnownIssues header rule** — every 18k-filed row spot-checked carries a named owner
   (the Open-strip trap · R-18k-6's ruled build · the ceremony branch · the future-stamp
   silent-stop · the C8 harness class · W-1/O-2 · 17t's two rows).
6. **Records** — QUESTIONS #146–#148 filed as the adjudications claim; the 17e entry carries the
   R-18k-1 split and C5's copied dispositions; the base-tree hash checks out; the morning bundle
   leads with C7's exposure and remedy.
7. **The refresh gate order** — this disposition → her quit's zero-instance window → the owed full
   Mac run → the closeout → the refresh (A1 copy into `Backups/safety-copies/`, R-18k-8) — exactly
   as LIVE STATUS sequences it.
8. **Owed at the CLOSEOUT, restated so it cannot slip** (round 1's list + this round's additions):
   the `TEXTKIT2_NOTES.md` measured-findings paragraph — now including C8's two facts (the 13l
   widening pin measures paragraph-style OBJECT identity, which process-wide attribute-dictionary
   uniquing decides; a dropped test editor can outlive its test in the runner's long-lived
   main-thread autorelease pool) beside C2/C6/C6b's; findings 1–4 above (four records edits); the
   full Mac run's adjudication (a seed-21 soak red there is judged there, not assumed); the
   handoff rewrite; the install refresh at the zero-instance window.

---

## VERDICT

**Round 3: 0 BLOCKER · 0 MAJOR · 0 MINOR · 4 NIT** — all four records-level; the C8 diff itself is
clean and the adjudication audit PASSES (no acceptance rested on evidence that fails inspection; no
dismissal was wrong; nothing sits unowned; her rulings were each executed as ruled). **Disposition
for R-18k-9's gate: the C8 test change is APPROVED, and the install refresh may follow the owed full
Mac suite run at the zero-instance window.** Per the ladder rule no further round is owed (no new
BLOCKER/MAJOR). The four NITs are the closeout's to land as records edits — no cross-model fix flow
is required for any of them; this reviewer can land them on authorization if the orchestrator
prefers.
