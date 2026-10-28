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

## ROUND 1 — THE IMPLEMENTER'S ANSWERS (the Opus ladder-fix implementer, 2026-10-27 — phase 1, agree/dispute)

**Nothing is applied yet:** this section is the answer only; no fix lands before the reviewer's final call. Every trace
below is my own (headless — no production, stage, GUI, Variorum launch or container write; the only probes were AX reads
of a backgrounded `sleep` and of Finder, codes and counts only, never a string). **Five AGREE, no DISPUTE**; on the
MAJOR and the first MINOR I propose a fix one step wider than the sketch, with the sketch kept as the fallback.

**1 · [MAJOR] words guard fail-open — AGREE.** My trace: `words-guard.swift:31` folds every non-`.success` answer of the
windows read into `?? []`; the loop at :33 never runs; :41 prints `ok`, exit 0; `capture()` (`first-run-walk.sh:474`)
reads exit 0 as go-ahead, and `walk-cap` lists by `CGWindowListCopyWindowInfo` (`capture-windows.swift:14`), no AX, so it
shoots the pid's windows regardless. **Reproduced:** the current guard compiled from this tip, run on a backgrounded
`sleep 30` → `'ok' exit 0`; the windows read there answers **-25204 (`kAXErrorCannotComplete`) in 0.01 s** (my shell is AX-
trusted; a nonexistent pid, 999999, answers -25204 too) — the same code a hung app returns after AX's ≈6 s timeout, which is the
reviewer's stop()-mid-P5 road (`stop()` :480 → `capture stopped`). Two more holes of the same class, beyond the sketch:
(a) mid-scan, a children or string read that fails (`.cannotComplete` — the app hung after the windows answered) is also
folded into `nil`/`[]` at :36 and :39, so the subtree is silently skipped and the scan still ends `ok`; and each further
read waits out its own ≈6 s timeout, so a hang mid-scan also stalls the walk for minutes before the fail-open `ok`.
(b) The cap exit at :33 → :41 with the queue non-empty, exactly as the reviewer traced. And the self-test case at
`first-run-walk.sh:298` proves only the usage guard (`notapid` → exit 2), as stated.
- **The fix (exact):** one reader classifies every AX answer three ways — **present** (`.success` with the expected type),
  **absent** (`.noValue`, `.attributeUnsupported`, `.notImplemented` — the element has no such attribute; a `.success`
  of another type, e.g. a slider's number, is absent too), **unreadable** (every other code: `.cannotComplete`,
  `.apiDisabled`, `.failure`, `.illegalArgument`, `.invalidUIElement` — fail-closed; the last one rare at rest, and a
  withheld capture during churn is cheap). The scan becomes ONE generic function over the node type, so the same code
  runs in the pid mode and over synthetic trees; its verdicts: the windows read not present (anything but a `.success`
  array — an empty array stays legal, zero windows) → `withheld (the pid's windows could not be read — AXError <n>)`;
  any unreadable read mid-scan → `withheld (the pid stopped answering mid-scan — AXError <n>)`, at once (no chain of
  timeouts); the cap reached with the queue non-empty → `withheld (the tree was not fully scanned — more than 30000
  elements)` (this also terminates a cyclic tree fail-closed). All exit 1. The pid mode's success line becomes
  `ok (<n> elements read)` and `capture()` logs it on its "captured" line, so every live capture shows the guard read a
  real tree (the old `ok` on an empty queue was indistinguishable from a full scan). Exit grammar unchanged (0 ok · 1
  withheld · 2 usage); `--classify` unchanged.
- **Why the stricter taxonomy will not over-withhold:** Finder's whole tree at rest (32 elements) answered only 0,
  -25212 (noValue) and -25205 (attributeUnsupported); and the live gate's captures (`run-20261028T005847Z-std/walk.log`)
  each logged within about a second of the line before it (seconds resolution — J3's frame line, its capture and J4's
  capture all at 19:00:34), guard and shoot together — far from a 30,000-element scan of ~120,000 AX calls — so the cap's
  new verdict will not bite at the walk's scale. The next live walk's `ok (<n> elements read)` lines are the proof.
- **Pins:** (P-1, the reviewer's, behavioural red-on-old) `Tools/WalkKit/pins/words-guard-fail-closed.zsh [<source>]`
  (the D-7 pin's shape — compiles the given `words-guard.swift`, default the repo's, into a temp dir): a backgrounded
  non-GUI pid → `withheld (…)`/1 · a reaped (dead) pid → withheld/1 · `notapid` → usage/2 · `--classify` twelve words → 1 and the
  join's landed line → 0 · `--self-check` → 0. **Against `git show 14ad4a09c:Tools/WalkKit/words-guard.swift`:** the two
  pid cases FAIL (`ok`/0, already seen above) and `--self-check` FAILS (no such mode — usage/2); against the fix, all pass.
  (P-2, the cap and the mid-scan class) `words-guard --self-check` drives the generic scan over synthetic trees: a
  30,001-node tree → withheld (not fully scanned) · a node that is its own child → withheld, terminates · a children read
  unreadable mid-scan → withheld · a string read unreadable → withheld · the windows read unreadable → withheld · twelve
  words at depth 40 → withheld · a clean 500-node tree with absent attributes throughout → ok. **Red by mutation** (a temp
  copy with the cap verdict and the unreadable verdicts reduced to the old `continue`/`?? []`): the cap, cycle and
  mid-scan cases go `ok` — red. The walk's `--self-test` gains the sleep-pid case, the reaped-pid case, the
  `--self-check` case, and the misnamed case renamed to "a non-numeric argument → usage, withheld (exit 2)".
- **Considered and not done (one line, the reviewer's to weigh):** a guard that also counts the pid's CG windows and
  withholds when AX answers an EMPTY windows list while CG shows windows on screen — an AX-bug state, not the hung road,
  and outside this finding.

**2 · [MINOR] the helper's check-to-use seam — AGREE.** My trace: `prod-reset-test-account.sh:391` checks the file
(inside `guard_allowlist`, two sourcings at :69–70); :393 sources it a THIRD time, with no type/mode/marker re-check,
and that value is the one spliced (:394 `id_sql` re-checks only `plain_address`) and compared byte-equal at :396 — so
the byte-equal R3 check compares the resolved user against the unchecked value, not against what R1 approved. The
walk's :636–638 is the same shape (its own grep of `source $` shows these two main-path re-reads are the ONLY ones in
either file). Opening it needs her own mid-run edit of her own 600-mode file; the fix is still owed because the fence
is stated as absolute.
- **The fix (exact — the "same read" form, closing the marker, listed and file-type seams at once):** `guard_allowlist`
  prints the CHECKED email on success (its one stdout line; the refusal text on failure, as now), in BOTH twins byte-
  identically (the twin pin keeps them so); the helper takes `EMAIL=$(guard_allowlist $ALLOW $ACCOUNT) || refuse "R1 —
  $EMAIL"` and deletes the :393 re-read; the walk takes its G1/G2 the same way and deletes the :636 re-read, P3 using
  G2's value; `id_sql`'s and P3's `plain_address` re-checks stay as belts. No other value moves (the launch's
  `allowlist_value` list re-read is the app's to re-guard — every entry marked, per-account admission — and not a reset
  path). **Fallback if the reviewer prefers not to touch the pinned twin:** the sketch's one-liner,
  `[[ $EMAIL == *vxtest* ]] || refuse …` after each re-read (closes the marker seam; leaves listed/file-type).
- **Pins:** (a) structural, red-on-old: in each self-test, "the allowlist is sourced only inside `guard_allowlist`
  (and the walk's `allowlist_value`) — the main path never re-reads it" — old: 1 offending line in each file (helper :393,
  walk :636) → FAIL; fixed: 0. (b) the contract, red-on-old: "on accept, `guard_allowlist` prints exactly the fixture's
  email" (old prints nothing) — in both self-tests. (c) the mechanism, demonstrated once and recorded (a scratch
  harness, not landed): the OLD :393–394 lines, extracted verbatim by `git show 14ad4a09c:…`, run after a passing
  `guard_allowlist` over a fixture rewritten in between to a plain UNMARKED address → they build `select id, email from
  auth.users where email = 'her@x.test'`; the fixed main path has no line that can.

**3 · [MINOR] release.sh "Arms one at a time" — AGREE.** My trace: `--arm setup` runs P1–P8 then THE END (E1 sign-out,
E2 quit, E3 `reset_account cleanup` — `first-run-walk.sh:776–788`), leaving the account vaultless; a following `--arm
join` skips the pre-step, reaches J5 and `join_ready` (:204–209) stops on "the account holds no vault — the set-up arm
makes it (run --arm both)". So the offered sequence refuses by construction; `--arm join` works only after a `both` run
stopped inside the join arm (a STOP never resets). **Fix:** release.sh:329's sentence becomes "`--arm join` alone resumes
a `both` run that stopped in the join arm (it needs that run's Standard vault); `--arm setup` alone also ends with the
cleanup reset." The README's line (345, "`--arm join` alone needs the account's Standard vault") is already true; left.
No pin (document text) — `bash -n` re-run.

**4 · [NIT] `${2:?…}` outside the exit grammar — AGREE.** Reproduced: `LOG=${2:?--log needs a file}` with no value →
zsh's own `2: --log needs a file`, **exit 1** (a one-line scratch script). Same at `first-run-walk.sh:380` (`--app`).
**Fix:** `--log) [[ -n ${2:-} ]] || refuse "--log needs a file"; LOG=$2; shift ;;` and the walk's `--app` twin (`refuse
"--app needs a path"`) — exit 5, the documented shape. **Pin (offered; the orchestrator may rule it out):** each
self-test runs its own script as a FENCED subprocess — `HOME=$T/nohome` (no allowlist can exist, so even a regressed
parse refuses at R1/G1 before any read), `PATH=$T/shim:$PATH` with a `curl` that exits 99 (a third belt) — `std --log`
/ `std --app` → exit 5 naming the missing value; old → exit 1. If a subprocess of the script's main path is outside
"self-tests over fixtures", the NIT lands unpinned as a message path.

**5 · [NIT] `J3 J3` — AGREE.** `launch_on_road`'s defaults are P1 (launch) and P2 (road, window, frame) — two steps; the
join passes `J3 J3`, and the live walk.log shows the launch, the road and `captured 'launched'` all under J3 (line 62).
**Fix:** `launch_on_road $RUN/app-join.log J3 J3b`, and the dry-run plan's J3 line names J3b (the road armed, the
window's bounds). No pin (log naming).

## ROUND 1 — THE REVIEWER'S FINAL CALL (the round-1 fable-reviewer, 2026-10-27 — binding; the implementer applies exactly this)

Before ruling I reproduced the MAJOR's live repro with my own hands: the branch's words-guard compiled fresh,
run on a backgrounded `sleep` pid → `'ok' exit 0` — the fail-open confirmed first-hand, not taken from the
answer. All five findings: the implementer AGREES with traces that are sound and, on findings 1 and 2,
sharper than my sketches. No finding is marked FINDER-FIXES; nothing touches `Sync/` — the implementer
applies every fix below.

**1 · [MAJOR] — CONFIRMED; the implementer's broadened three-class fix LANDS as specified, with P-1 and
P-2.** The present/absent/unreadable taxonomy is the right scoping: "absent" (`.noValue`,
`.attributeUnsupported`, `.notImplemented`, a `.success` of the wrong type) continuing the scan is correct —
those are answers, not failures — and everything else withholding at once also closes the two holes the
implementer found beyond my sketch (the mid-scan unreadable read silently skipped, and the timeout-chain
stall before the wrong `ok`). The windows read's rule — anything but a `.success` array withholds, an EMPTY
success array stays `ok` — matches my scoping exactly (zero AX windows = nothing walk-cap's privacy rule
needs guarding beyond what CG shoots; see the out-of-scope note below). `ok (<n> elements read)` logged by
`capture()` is accepted and welcome: it makes every live capture's guard legible, and the next live walk's
lines are the over-withhold proof the implementer promised. Exit grammar and `--classify` unchanged —
required, so the existing D-5 cases stand. P-1 red against `14ad4a09c`'s words-guard (the sleep pid and the
reaped pid both `ok`/0 on old — the sleep case verified by my own run above) and P-2's mutation-red
`--self-check` over synthetic trees (cap · cycle · unreadable children/string/windows · deep words · clean)
together pin both classes; the walk's `--self-test` gains the three cases and the RENAMED non-numeric-
argument case (required — the old name overclaimed, which was part of the finding). **The "considered and
not done" CG-vs-AX empty-list cross-check stays NOT DONE, with the reason recorded:** the only moment an
empty-success AX answer could coexist with real CG windows is launch-time AX warm-up, and every capture
near the words look is preceded by successful vis-ax AX presses (the look only exists after P5's press
chain), so the exotic state cannot coincide with the words on screen. Out of this finding's scope; no
ticket owed.

**2 · [MINOR] — CONFIRMED; the implementer's SAME-READ form lands (the fallback one-liner is retired).**
`guard_allowlist` printing the CHECKED email on success closes the marker, listed, mode and file-type seams
in one move by deleting the unchecked re-read entirely — a patched gap stays a gap; a removed read cannot
reopen. Conditions, all from the implementer's own proposal, now binding: (a) BOTH twins change
byte-identically and the helper's twin pin keeps proving it; (b) the printed-email contract is pinned in
both self-tests ("on accept, prints exactly the fixture's email" — red on old, which prints nothing);
(c) the structural pin lands in both self-tests ("the allowlist is sourced only inside `guard_allowlist`
and the walk's `allowlist_value`" — red on old: helper :393, walk :636); (d) the `plain_address` belts at
the splices STAY; (e) the helper's now-obsolete ":393 re-read" refusal wording ("the allowlist changed
since R1?") is updated to match the new shape. The `allowlist_value` launch-list read stays as-is —
accepted scoping: it is not a reset path, is never spliced, and the app re-guards every entry at connect
(F-B1-1). Emails are no secret (they ride `ps eww`), so the success-print is hygiene-clean. The mechanism
demonstration (c in the implementer's pin list) is recorded once in this file's round-2 evidence, not
landed as a test — fine.

**3 · [MINOR] — CONFIRMED; the proposed release.sh:329 sentence lands verbatim** ("`--arm join` alone
resumes a `both` run that stopped in the join arm (it needs that run's Standard vault); `--arm setup`
alone also ends with the cleanup reset."). README line 345 already true — agreed, left. `bash -n` after.
No pin (document text).

**4 · [NIT] — CONFIRMED, WITH the offered pin.** The refuse-shaped fix lands in both files (`--log`,
`--app` → exit 5 naming the missing value). The pin DESERVES to land: the 0/4/5 grammar is a documented,
composition-bearing contract (the walk's `reset_account` keys off exit classes), the pin is expressible,
and the orchestrator has ruled the triple-fenced subprocess shape allowed — pin-before-fix binds where a
pin is expressible, so it is taken: `HOME` at an empty temp dir (R1/G1 refuses before any read), the
`curl`-exits-99 shim as the third belt, `std --log` / `std --app` → 5 on the fix, 1 on old.

**5 · [NIT] — CONFIRMED as proposed** (`J3 J3b`, and the dry-run plan naming J3b for the road/bounds
line). No pin (log naming).

**After the fixes:** both `--self-test` suites re-run green (the walk's with its new cases), P-1/P-2 and
the NIT-4 pin shown red-on-old in the fix commits' messages or this file, `zsh -n` on every touched zsh
script and `bash -n` on release.sh — then round 2's fresh reviewer re-checks the fixes per the ladder.

## ROUND 1 — THE FIXES (the implementer, phase 2 — applied exactly as the final call states; for round 2's reviewer)

Headless throughout: no production, stage, GUI, Variorum launch or container write. The AX reads are of the pins' own
`sleep`/reaped pids, plus one positive control on Finder (the verdict line only — `ok (32 elements read)`).
Every pin was written BEFORE its fix and shown red on the pre-fix tree.

**1 · [MAJOR] — FIXED** (the piece-A commit). `Tools/WalkKit/words-guard.swift` rewritten to the three classes: one
reader `ax()` classes each answer PRESENT / ABSENT (`.noValue` · `.attributeUnsupported` · `.notImplemented` · a
`.success` of another type) / UNREADABLE (every other code). A generic `scan()` is the ONE code path for both the pid
mode and `--self-check`. The windows read must be a present list (an empty one is ok, zero windows). An unreadable
read mid-scan withholds at once, and so does the 30,000 cap with elements still queued (this also ends a cycle). The
queue is index-walked, never `removeFirst`. Exit grammar (0/1/2) and `--classify` unchanged. The pid mode's success
line is `ok (<n> elements read)`, logged on `capture()`'s captured line (`first-run-walk.sh` `capture()`). The README's
words-guard line was updated. The walk's `--self-test`: the misnamed case was renamed "a non-numeric argument → usage,
withheld (exit 2)", and three cases were added (a live non-GUI sleep pid → withheld/1 · a reaped pid → withheld/1 ·
the guard's own `--self-check`).
- **P-1** `Tools/WalkKit/pins/words-guard-fail-closed.zsh [<source>]` — **RED ON OLD** (`git show
  14ad4a09c:Tools/WalkKit/words-guard.swift`): **3 failing of 6** — `a live non-GUI pid … exit 0 (want 1): ok` ·
  `a reaped pid … exit 0 (want 1): ok` · `--self-check … exit 2 (want 0)` (no such mode). **GREEN ON THE FIX: 0 failing of
  6** — both pids `withheld (the pid's windows could not be read — AXError -25204)`. The walk's new cases were also
  run before the fix: `SELF-TEST: 3 case(s) wrong` (sleep, reaped, --self-check); after it, green.
- **P-2** `words-guard --self-check`, 12 synthetic cases: cap + 1 → withheld · exactly cap → ok (30000 read) · a self-
  child cycle → withheld · windows unreadable → withheld · windows absent → withheld · an EMPTY window list → ok ·
  children unreadable mid-scan → withheld · a string unreadable mid-scan → withheld · twelve words 40 deep → withheld ·
  the look's marker deep → withheld · words BEYOND an absent node still found → withheld · a clean 496-element tree →
  ok, all 496 read. (The phase-1 answer said "500"; the tree built is exactly 496 and the count is asserted.)
  **RED BY MUTATION** (a temp copy with the four new verdicts reduced to the old fold-into-nothing — the cap `break`, the
  mid-scan unreadables `continue`, the windows' absent/unreadable `queue = []`): **6 verdict(s) wrong** — cap + 1, the
  cycle, both windows cases, both mid-scan cases all `ok`. **GREEN ON THE FIX: every verdict held.**
- **The CG-vs-AX empty-list cross-check — NOT DONE**, the final call's reason: an empty-success AX answer could coexist
  with real CG windows only at launch-time AX warm-up, and every capture near the words look comes after successful
  vis-ax AX presses (the look exists only after P5's press chain). No ticket.

**2 · [MINOR] — FIXED, the SAME-READ form** (the piece-B commit). The final call's conditions, met one by one:
- **(a)** `guard_allowlist`'s success line is now `print -r -- "$email"` (was `return 0`), changed byte-identically in both
  twins; the helper's twin pin `R1 the guard is first-run-walk.sh's G1/G2, byte for byte` stays green.
- **(b)** The contract pin lands in BOTH self-tests: "on accept prints exactly the CHECKED email". The walk's self-test
  also gains a companion: "on a refusal prints the reason, never an address".
- **(c)** The structural pin lands in BOTH: "the allowlist is sourced only inside `guard_allowlist` (and the walk's
  `allowlist_value`, exempt) — the main path never re-reads it".
- **(d)** The `plain_address` belts stay: `id_sql`'s, and P3's before the walk's SELECT.
- **(e)** The stale refusal wording is replaced. The helper now says "R3 — the '‹account›' email R1 checked failed the
  splice's plain-address re-check (a belt — R1 checks the same rule)", and the walk's P3 stop has the same shape.

The helper's R1 line takes `EMAIL=$(guard_allowlist $ALLOW $ACCOUNT) || refuse "R1 — $EMAIL"`, and the old :393 re-read
is deleted. The walk's G1/G2 takes it the same way, its :636 re-read is deleted, and P3 uses G2's value. Both headers
say so. The helper's `expect` no longer shows the email on accept.
- **RED ON OLD** (both pins written into the self-tests BEFORE the fix, run on the pre-fix code): walk **2 case(s) wrong**
  (the contract and structural cases FAIL; the refusal-text case passes, as expected, on both sides); helper **2 of 88
  case(s) wrong**, the same two. **GREEN ON THE FIX:** walk 70/70 · helper 88/88.
- **The mechanism, demonstrated once (a scratch harness, not landed — the final call's (c)):** the OLD helper's :61–85
  (`PLAIN_ADDRESS` · `plain_address` · `guard_allowlist` · `id_sql`) and :393–394, extracted verbatim by `git show
  14ad4a09c:Tools/prod-reset-test-account.sh`, run with R1 passing over a marked fixture that is then rewritten to a
  plain UNMARKED address before the re-read → `the OLD :393-394 built: select id, email from auth.users where email =
  'her@x.test'`. The fixed main path has no re-read left to do that: `grep -nF 'source $'` over both files now finds only
  the guard's two reads and `allowlist_value`.

**3 · [MINOR] — PENDING** (piece C). **4 · [NIT] — PENDING** (piece D). **5 · [NIT] — PENDING** (piece E).
