# VX-623 — Ladder round 1 (cold review, fresh `fable-reviewer`, 2026-10-27)

Target: the whole diff of `vx-623-walk-self-reset` against merge-base `6f4e1f14c` (22 commits, Tools + this
record only — no app code, no `Sources/`, no schema, confirmed by the diff stat). REVIEW_PROMPT run verbatim;
the run record (this file's sibling) is the review anchor; no "Review foci" section exists in it.
Reviewer's own verification runs (headless, fixtures only, per the round's environment constraints):
walk `--self-test` **64/64 green** · helper `--self-test` **85/85 green** · D-7 pin **0/11 failing on this
branch, 6/11 failing against the merge-base's guard.sh** (red-on-old confirmed by my own run) · `zsh -n`
clean on all four zsh scripts, `bash -n` clean on release.sh. No production, stage, GUI or container act.

## Findings (severity-ranked)

**[MAJOR] · Tools/WalkKit/words-guard.swift:30–41 (consumed at Tools/WalkKit/first-run-walk.sh:474) · the
words guard is fail-OPEN exactly where it is load-bearing: a pid whose AX tree cannot be read, and a tree
larger than its 30,000-node cap, both print `ok` (exit 0) · Evidence (traced):**
`AXUIElementCreateApplication(pid)` always returns an element; for a dead, hung or AX-unresponsive app,
`attr(app, kAXWindowsAttribute)` returns a non-`.success` error → nil → `queue` starts EMPTY → the while
loop never runs → the tool prints `ok` and exits 0 having inspected nothing. `capture()` treats exit 0 as
go-ahead, and `walk-cap` needs no AX (CGWindowList + screen recording), so it would still shoot every
on-screen window of that pid. The realistic path is precisely the one the guard exists for: a hung app
mid-P5 (AX calls time out ≈6 s and return `.cannotComplete` while the windows stay on screen) → a step
times out → `stop()` → `capture stopped` → the twelve-words look is captured. Same class: `seen` reaching
30,000 with `queue` non-empty falls out of the loop and prints `ok` on a partially-scanned tree (the BFS
also has no visited-set, so the cap is what terminates a cyclic tree — and it terminates it fail-open).
The walk's own comment (first-run-walk.sh:471, "a failed guard withholds too: fail-closed") holds only for
non-zero exits; this case exits 0. The record's claim and the self-test case name — "a pid it cannot read →
withheld" — actually test a NON-NUMERIC argument (`notapid`, the usage guard, exit 2), not an unreadable
pid; the claim overstates the coverage. · **Pin (red-on-old, headless):** spawn a non-GUI process (e.g.
`sleep 5 &`), run `words-guard <its pid>`: today it prints `ok`/exit 0; fixed it must print
`withheld (…)`/exit 1. A truncation case can pin the cap the same way once the cap's verdict is a named
withhold. · **Fix:** in the pid mode, treat a failed `kAXWindowsAttribute` read (error ≠ .success —
distinguish it from an empty-but-successful list) as `withheld (the pid's windows could not be read)`,
and exiting the loop with `queue` non-empty as `withheld (the tree was not fully scanned)`; rename or
extend the self-test case so its name matches what it proves.

**[MINOR] · Tools/prod-reset-test-account.sh:393 (the walk's pre-existing twin: first-run-walk.sh:636–638) ·
check-to-use gap in the production-WRITING helper: the EMAIL actually used is a SECOND read of the
allowlist, and only plain-ness is re-checked at the splice — R1's vxtest-marker and listed guarantees do
not bind the value that resolves the account · Evidence (traced):** `guard_allowlist $ALLOW $ACCOUNT`
(:391) reads the file once; :393 re-reads it (`EMAIL=$(… source $ALLOW …)`); `id_sql` re-checks only
`plain_address`. A file whose content changes between the two reads (her own concurrent edit mid-run — no
adversary exists on this machine) can supply a plain, NON-vxtest address; R3's byte-equal check compares
against that same second read, so it would pass, and the reset would target whatever account that address
resolves to. The helper's whole safety story is "the guard here is the fence that makes a narrow allow
rule safe" (:9); the fence has a seam between check and use. The walk has carried the identical shape
since VX-510 (its act is reads + GUI, which is why it was acceptable there); the helper is NEW and writes.
· **Pin:** factor the re-read + re-check into a pure function over a file fixture (as `guard_allowlist`
already is); a self-test case feeding it a listed-but-unmarked address must refuse — red on today's code,
where only `plain_address` gates it. · **Fix (one line each):** after the re-read, re-assert
`[[ $EMAIL == *vxtest* ]]` (or re-run `guard_allowlist` and take the email from the SAME read); mirror in
the walk's P3 for the twin's sake (the byte-identical-twin pin covers `guard_allowlist` only, so the
P3-side line is free-standing).

**[MINOR] · Tools/Release/release.sh:323–330 (the HANDOFF step-0 text) · "Arms one at a time: --arm setup |
--arm join." offers a sequential decomposition the cleanup leg forbids · Evidence (traced):** a lone
`--arm setup` PASS ends at E3's reset — the account is vaultless; a following `--arm join` then STOPs at
J5 (`join_ready`: "the account holds no vault — the set-up arm makes it (run --arm both)",
first-run-walk.sh:206). `--arm join` works only after a `both` run that stopped IN the join arm (the walk's
own header says so, :22–23). The refusal is named and self-correcting, so this is doc-level — but a release
checklist that names a road which refuses by design costs the operator a cycle. · **Fix:** reword the last
sentence, e.g. "`--arm join` resumes a `both` run that stopped in the join arm; `--arm setup` alone still
ends with the cleanup reset." No pin (document text).

**[NIT] · Tools/prod-reset-test-account.sh:380 · Tools/WalkKit/first-run-walk.sh:380 · `${2:?…}` on a
missing `--log`/`--app` value exits 1 via zsh's own error, outside the documented exit grammar (0/4/5
refused-with-nothing-written) · Evidence:** `prod-reset-test-account.sh std --log` → zsh's "--log needs a
file", exit 1 — not the `refuse` shape (exit 5). Harmless in composition (the walk's `reset_account` stops
on ANY non-zero), visible only to a hand invocation. · **Fix:** route through `refuse`
(`[[ -n ${2:-} ]] || refuse "--log needs a file"`), or leave as accepted cosmetics.

**[NIT] · Tools/WalkKit/first-run-walk.sh:716 · `launch_on_road $RUN/app-join.log J3 J3` names two distinct
steps (the launch and the road/frame check) with one name · Evidence:** the function's own defaults are P1
and P2 — two steps; the join path logs and prefixes captures for both as `J3` (visible in the live
walk.log). · **Fix:** `J3 J3b` (or similar) — log clarity only.

## Dispositions of the record's flagged items (the reviewer's read)

- **R-U1-1…R-U1-5 (adjudicated APPROVED by the orchestrator):** each mechanism independently re-traced and
  CONCURRED. In particular R-U1-1's premise holds in the server source — the purge's `kp:` delete is
  wrapped best-effort (`13_phase13i_wings.sql:888–901`) because its uuid dies, while
  `VARIORUM_KEY_PROOF_ALREADY_ENROLLED` fires on a surviving secret (`12_phase13y_tenant_seq.sql:611–615`),
  so the reset's strict in-statement delete is right; R-U1-4's premise holds — `sync_challenge` is
  session-gated with NO vault requirement (`12_phase13y_tenant_seq.sql:524–536`), so a signed-in app would
  re-dirty the account after the reset.
- **The unpinned P7 prefix-match fix:** correct and within the house rule — `firstRoundBlocked` renders
  "Sync hasn't run yet: ‹sentence›." (`ProtectionWords.swift:1053`), so the old exact match could never
  fire; the fix changes only which STOP message prints (message-path, not bug-class).

## Clean bill (checked and found solid)

- **The reset helper's write-safety spine:** R1 is the walk's G1/G2 verbatim (pinned byte-identical by its
  own self-test, which I ran); R3 resolves the id by a byte-equal email with a lowercase-UUID shape check
  re-applied at :399; the id is the ONLY value any statement splices, re-validated inside `counts_sql` and
  `reset_sql` (`UUID_SHAPE`), and the email splice in `id_sql` is regex-fenced against quotes/newlines/
  uppercase (F-R1-5's rule, self-tested 11 ways). The one write is a single data-modifying CTE (no
  semicolon, pinned), scoped per-table to `owner_id/user_id = '<uuid>'` and `name = 'kp:<uuid>'` — it
  cannot reach another tenant's rows; `auth.users` and `entitlement` are never named (pinned). Postgres
  runs data-modifying CTEs exactly once each inside the one statement's implicit transaction — the
  atomicity claim is real.
- **The DRIFT pin:** the family is derived from and pinned to `account_purge()`'s latest body — I read
  `13_phase13i_wings.sql:851–903` myself: 21 data tables + the five server deletes + the `kp:` secret +
  `key_vault`; the reset's lists match exactly, minus the auth user and entitlement by design.
- **Fail-closed verdicts:** the before/after reads parse whole or refuse (R4 × 13); the after-read runs
  ALWAYS and is the truth (exit 4 names the state, both reads logged); `after_verdict` demands the auth
  user kept, the entitlement unchanged, kp 0, family 0. The write path never prints a server error body
  (`PY_LIB` names the class only) and never puts the token in argv (`-H @-` on stdin).
- **Her-account unreachability (the standing ruling's fence):** account ∈ {std, castle, del} only; every
  listed entry vxtest-marked; mode 600, never a link; the one gap found is the check-to-use seam above
  (MINOR), which needs her own mid-run edit of her own 600-mode file to open.
- **Fence 1 (never reset after a STOP):** `stop()` exits 4 immediately (:479–483); the pre-step runs only
  before the set-up arm, the cleanup only at E3 after every arm's PASS, behind E1 sign-out + E2 quit
  (R-U1-4's reason verified in server SQL). Fence 3: P8's and J8's reads are logged before E1 runs.
- **Fence 2 (guard rigor):** both self-tests run by my own hand, 64/64 and 85/85 green, every refusal
  shown firing over fixtures; the tripwire arm proves the helper's self-test never reaches the network.
- **D-7 (VX-536):** the mechanism is real (an absent gitignored `wl2` answered "" and matched no refusal
  arm — `GUARD OK` on a window never looked at); the fix compiles-or-refuses with exit 8 before the
  frontmost read, refuses any answer that is neither `offscreen` nor `onscreen X Y W H`, and leaves
  `--author` helper-free. The pin is genuinely headless (PATH shims verified to shadow before any case)
  and RED ON OLD by my own run: 6/11 failing against the merge-base guard, 0/11 on this branch.
- **D-4:** the frame key filter is `re.fullmatch` over `NSWindow Frame variorum-main-AppWindow-[0-9]+` in
  the DEBUG domain only (never her app's domain), deletes only at zero instances (G5/J1 both verified
  before `frame_reset` runs), proves none remain, restores nothing; `rect_inside` is fail-closed on empty
  geometry (self-tested 12 ways); the JXA display read converts Cocoa→Quartz correctly (flip against
  screens[0].frame.height).
- **D-5:** `walk-cap` stays `screencapture -l <window id>` per window — window-scoped always, never
  full-screen; the two-argument layer-0 behaviour is unchanged for existing callers; `--every-layer` is
  opt-in with the 48-pt sliver skip. The capture path runs the words guard first and treats ANY non-zero
  exit (withheld, usage, crash) as withheld — the one fail-open residue is the MAJOR above, inside the
  Swift tool itself.
- **D-2/D-3 composition:** the arms compose factored legs byte-faithful to the proven VX-510 setup arm
  (I diffed old vs new: P1–P8 preserved; P8 gained the revision read only). `--arm join` deliberately
  skips the pre-step (it would delete the vault the join needs). The between-arms aside moves ONLY a
  provably-own folder: absent at G7 + key file naming the library this run's set-up enrolled (the
  `road: turnOnSync — library <id8> now names account` line verified against
  `ProtectionAccountActs.swift:388–391`), one same-volume whole-folder `mv -n` proven by inode, every
  doubt STOPping with the exact `mv` named (self-tested 13 ways). The dev store's HELD library is never
  this script's to touch; G7 refuses a occupied slot before anything runs.
- **Join evidence:** `join_verdict` demands cursors exactly +1 with mode AND revision unmoved, refusing
  partial reads, booleans and error answers (self-tested 7 ways); a missing before-read fails closed at
  J8 (late but closed).
- **Labels from the CURRENT code:** every walk string checked against today's source by my own grep —
  `notOnYetLabel` (SyncStatusViews.swift:707), `joinSyncDoor`/`joinSyncTitle`/`joinSyncButton`
  (ProtectionWords.swift:1061–1065), `joinPassphraseField` (:870), `joinWordsNotShown` lead (:894) and
  its OK (:898, rendered RoadAccountSheet.swift:212/218), `firstRoundSetUpLanded` (:1047),
  `firstRoundJoinLanded` (:1048), `firstRoundBlocked` (:1053); the words-guard markers match
  `wordsLookShow` (:679), `wordsLookWrittenDown` (:694), `wordsLookWarning` (:696). `VIS_AX_PREFIX` is a
  real vis-ax switch (vis-ax.swift:18–20).
- **Hygiene:** all 22 branch commits trailer-free; `DerivedData/`, `Tools/WalkKit/wl2` and `.env.*.local`
  gitignored (the run logs, the compiled helpers and the walker's symlink deviation all land under
  ignores); `prod-read.sh`'s SELECT-only fence is intact and the helper's counts read is pinned against
  the fence's own regex, read from the file.
- **Unit 2's evidence exists where the record says:** the run folder
  `App/Variorum/DerivedData/first-run-walk/run-20261028T005847Z-std/` holds walk.log (PASS line, E3's
  at-rest read verbatim as quoted), the 28 captures and both reset logs — the record's narrative matches
  the artifacts I read.
- **Scope:** no app code, no `Sources/`, no schema, no `Sync/`, no custody line in the diff; the canon
  delta for her standing ruling is correctly deferred to closeout (LEDGER row 6), not smuggled into the
  loaded files by this diff.

## Verdict

No BLOCKER. One MAJOR (the words guard's fail-open seam — a real hole in a privacy guard this diff
itself made load-bearing), two MINOR, two NIT. The run's substance — the guarded reset, the two arms,
the self-test lattice, the D-7 pin — is solid, carefully built, and verified end to end.
