# VX-827 — ladder round 2 (cold review, fable-reviewer, 2026-11-06)

**Under review:** the R1 fix leg — commits 429218982 (R1-F1: the flush gap), 5d7f5499c (the revert
recipe), 3678c658a (R1-F5: the `mcpShownTake` → `shownTake` rename) — against round 1's findings
(`notes/plans/fixes/vx-827-ladder-round1.md`), the dispositions and the two R1-F1 fix-shape rulings
in `notes/plans/fixes/vx-827-lineage.md`. Whole-leg code diff re-derived myself
(`git diff d015fc324..HEAD -- ':!notes'`): exactly five files, the three commits above, nothing else.

Findings land here incrementally. Format: `[severity] · file:line · what · evidence · fix`.

## FINDINGS

**[NIT] · notes/plans/fixes/vx-827-lineage.md (U3b END's "PROVISIONAL list for #264 (P-U3b-1…13)"
vs the dispositions' P-U3a-5b and P-U3b-14) · The two ladder-born P-lines live only in the
dispositions section; the unit's END still says the #264 list is P-U3b-1…13.** Evidence: grep —
`P-U3a-5b` and `P-U3b-14` appear only at the dispositions (record lines ~1964–1968); the END
section's bundle line was written before the ladder and not amended. A closeout session bundling
#264 from the END's list alone would drop the two rulings the ladder minted. Fix: one line at the
END (or in the closeout checklist) saying the ladder added P-U3a-5b and P-U3b-14 — mechanical.

*(No BLOCKER, no MAJOR, no new MINOR. Clean bill below.)*

## CLEAN BILL (round 2's duties, each checked myself)

- **R1-F1 matches its finding and dispositions exactly.** The finding's fix shape (flush the
  `.take` source's placed note in `LineageBringBack.run`; relative-role `start()` flushes the
  relative's placed note when placed and ≠ postID) is built line for line
  (CommitsFaceModel.swift:851–856 and :243–249); the orchestrator's ruling (1) — consult-and-refuse
  on the COPY road with the standing sentence — is built as `!(flushExistingAutosave) → throw
  Refusal.unsavedChanges`, `sentence` forwarding to `OpsRefusalCopy.unsavedChanges` (the one
  shared literal, OpsRefusalTable.swift:463). The `.commit` arm is untouched (immutable, I5);
  an unplaced source skips the flush (nothing can be pending — every door flushes before releasing
  a block, `NoteDeletion`/the merge doors). Both `LineageBringBack.run` callers — and only two
  exist (grep) — catch the new `Refusal` and speak it as a refusal
  (CommitsFaceModel.bringBackFromLineage:754, LineageFaceModel.bringBack:276); the pane-foot road
  (`bringBackSelected` on a relative, `.now → .take`) routes through the same fenced run, so the
  finding's both arms (header act + foot's "now" row) are covered.
- **The consult-and-refuse arm is faithful to the flush road's contract, read myself.**
  `AppSession.flushExistingAutosave` (AppSession.swift:347–382): returns whether the buffer is
  CLEAN after the flush; "a caller whose act READS or COPIES the store … must consult it, or it
  acts on a store missing her last words while reporting success (`VersionActs`)". The bring-back
  COPIES → consults and refuses, exactly `VersionActs.save/restore`'s `guard … else throw
  Refusal.unsavedChanges` shape (VersionActs.swift:46/63). `flushBeforeReading` deliberately does
  not consult — a pane read is not an act reporting success, and the pre-existing read posture
  (CommitsFaceModel.start(), LineageFaceModel.start():172) has never consulted; the new doc says so
  in place. Consistent, no new behavior beyond the ruling.
- **The revert patches revert exactly the fix.** Read both: Revert A deletes precisely the
  five-line `.take` flush guard in `run`; Revert B deletes precisely the relative branch of
  `flushBeforeReading`, keeping the own-note flush. `git apply --check` clean at HEAD (both), AND
  from `App/Variorum` — the recipe's own cwd — where I also round-tripped A (apply → reverse-check
  → `apply -R` → tree restored clean), so the recipe's exact commands work cold. Neither patch
  removes anything but the fix lines (the helpers/enum left unused compile — unused internal
  members are warnings at most). Caveat for the window, not a finding: any FURTHER commit touching
  `CommitsFaceModel.swift` near those regions should re-run `git apply --check` (the rename commit
  already landed after the patches were cut and both still apply — verified).
- **The deferred pins' expected reds are correctly stated.** Traced through the fixture
  (`pendingRelative`: extract span 11..<26 of "Kept part. Extracted part." = exactly
  "Extracted part."; the extracted block moved to "Elsewhere"; typing recorded on Elsewhere's
  coordinator at 30 s debounce — written by nothing but a flush, `AutosaveCoordinator.record/
  flushNow` read myself): under Revert A nothing flushes Elsewhere on the bring-back road (the
  headless harness never runs `start()`; `select` mints the node without starting it), so the op
  copies stored → `minted?.workingText == "Extracted part, retyped."` fails exactly as stated,
  while the read-half pin stays green (its `flushBeforeReading` is untouched by A); under Revert B
  the read-half pin fails at `stored ==` exactly as stated while the bring-back pin stays green
  (run flushes on its own). `Queries.blockFan` orders `(fan_position, id)` so `.last` is the
  minted take; the suite is 12 @Tests, matching the recipe's count; the `-only-testing` target
  name matches the file's target. Deferral itself is the orchestrator's recorded ruling (2) with
  conditions met (recipe landed, mechanical, in the record).
- **R1-F5 changed no behavior and missed no call site.** The rename diff is three lines + a doc
  note; repo-wide grep: zero `mcpShownTake` references left in code (one deliberate doc-comment
  mention of the old name); exactly two `Queries.shownTake` call sites — CommitsFaceModel.read:215
  and the MCP `divide` tool (MCPWriteTools+Edit.swift:256, the authorized sweep's one VariorumMCP
  line, byte-identical call semantics — no wire shape, no op change, MCPSpec untouched). No name
  collision (the `shownTake` in MCPReadShapeServerTests is a local JSON test helper; CommitRail's
  `shownTakeIDs` private). No pin names the query.
- **Suites, re-run myself on the fix-leg tree (headless):** `LineageBringBackTests` 12/12
  (the op the fix feeds, untouched by the leg — confirmed via the code diff);
  `MCPEditServerTests` 10/10 (the renamed divide call site, end to end); and
  `xcodebuild … build-for-testing` (Mac, Debug) **re-run green by this reviewer at review head**
  (`** TEST BUILD SUCCEEDED **`) — the two F1 pins compile on the final tree, so the recipe is
  runnable. (The two commits after the fix leg, b384fc012 and 757828bf6, are record-only — the
  code diff at review head is still exactly the five files.)
- **Nothing new entered with the fix leg.** The leg touches no `Sync/`, no custody, no DDL, no
  editor-seam file (the five files re-checked by name); the new SQL helpers are two indexed
  single-row reads (`uq_cblock_ownership`) — P1 ∝ one block; the scraps arm works through the same
  coordinator key (pool container id — `SnippetsSurface.deleteGroup` flushes the same key); raw
  SQL in the app model matches the feature's existing pattern (LineageFaceModel.read's wing-name
  read, seen by round 1). Commit messages carry no trailers (the 2026-09-04 rule).
- **The other dispositions landed as ruled:** R1-F2 recorded as the dangling-wing ticket join
  (filed at closeout — tracked at record :1958–1961 beside the liveTagIDs born-ticket candidate);
  R1-F3's D-U3-1/-2 drafted and checked against the build (D-U3-2's refusal list matches the op —
  archived/locked source allowed, dead/sealed target and out-of-lineage refused; the §12 mode row
  correctly owes nothing); R1-F4's two P-lines exist (the NIT above is only about where).

**Standing condition, unchanged from round 1:** the two F1 pins are compiled, not yet run; the fix
is not "landed" until the closing window's red-on-old → green run by the recipe, before the walk —
already the record's own condition and nov5's queue.

**FINDER-FIXES: none. No round 3 owed** — no new BLOCKER or MAJOR.
