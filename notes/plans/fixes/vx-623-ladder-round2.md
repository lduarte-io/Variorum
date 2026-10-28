# VX-623 — Ladder round 2 (fresh cold reviewer re-checking round 1's fixes, 2026-10-27)

**STATUS: COMPLETE, 2026-10-27. NO FINDINGS — all five round-1 fixes verified against the final
call's binding shapes, every pin re-run and genuinely red-on-old, both recorded deviations verified,
the gate green fresh at the tip, nothing new introduced. The ladder closes at round 2 with a clean
bill (the verdict at the end of this file).** The round ran across a pause at her word: findings
1–2 are the opening reviewer's (`79c8734a9`); findings 3–5, the pending ticks and the gate below
are the resumed closing reviewer's (`d7fb66192`…`27e03a95f`); the opening reviewer, resumed in
parallel, ALSO verified findings 3–5 and the gate independently with agreeing results (the
corroboration section near the end), and wrote the sweep, clean bill and verdict.

Target: the round 1 fix set (five findings, the final call's binding shapes, commits `a57bb863c` ·
`761461712` · `33de94d33` · `e50ea8fb6` · `bcac53925`) on branch `vx-623-walk-self-reset` at
`94e9fcb4f`, re-checked against the code as it stands. REVIEW_PROMPT run verbatim; environment
constraints honored throughout: headless only — pins, `--self-check`, fixtures, `git show`, syntax
checks; AX reads only of processes this session spawned (`sleep`, a reaped pid); no production, no
stage, no GUI, no containers.

## Finding 1 · [MAJOR] words-guard fail-open — FIX VERIFIED, matches the binding shape

- **Shape:** `Tools/WalkKit/words-guard.swift` rewritten to the final call's three classes exactly —
  `ax()` classifies PRESENT / ABSENT (`.noValue` · `.attributeUnsupported` · `.notImplemented` · a
  `.success` of another type) / UNREADABLE (default arm, every other code). One generic `scan()`
  (words-guard.swift:43) serves the pid mode (:140) and `--self-check` (:88) — the same code path, as
  required. The windows read must be a present list, an EMPTY one stays ok (:45–49, :112); any
  unreadable read mid-scan withholds at once (:58, :64 — the texts sequence is lazy, so no chain of
  timeouts); the cap with elements still queued withholds (:52), which also terminates a cyclic tree
  (verified by my own trace: a self-child node grows the queue by one per element read, so head
  reaches the cap). Boundary arithmetic checked: exactly-cap trees read whole (cap check precedes the
  read at head≥cap). Exit grammar 0/1/2 unchanged; `--classify`, `twelve`, `markers` and `verdict`
  are BYTE-UNCHANGED from `14ad4a09c` (diffed myself). The pid mode prints `ok (<n> elements read)`
  and `capture()` logs it on the captured line (first-run-walk.sh, capture()). The walk's
  `--self-test` gained the three cases and RENAMED the overclaiming case to "a non-numeric argument →
  usage, withheld (exit 2)" — all as the final call required. The CG-vs-AX cross-check stays NOT
  DONE with the final call's reason recorded — correct disposition.
- **P-1 red-on-old, MY OWN RUNS:** current source → **0 failing of 6**; against
  `git show 14ad4a09c:Tools/WalkKit/words-guard.swift` → **3 failing of 6** (the live sleep pid
  `ok`/0, the reaped pid `ok`/0, `--self-check` exit 2 no-such-mode) — exactly as recorded.
- **P-2 mutation-red, MY OWN RUN:** I rebuilt the fold-back mutant myself (windows absent/unreadable
  → `queue = []`, cap → `break`, mid-scan unreadables → `break`) and ran `--self-check`:
  **6 verdict(s) wrong** (cap+1, cycle, windows unreadable, windows absent, children mid-scan, string
  mid-scan) — red exactly as recorded; the fix holds every verdict (ran clean inside P-1's run).
- **The 496-count deviation HOLDS:** the clean tree is 1 root + 99 kids + 99×4 grandkids = 496,
  asserted via `read: 496` (words-guard.swift:124–126); my mutant run printed `ok (496 elements
  read)` for that case. The phase-1 answer's "500" was the estimate, 496 the built truth — recorded
  honestly, no issue.
- **Nothing new introduced** in this commit's walk/README hunks (read whole): capture() still treats
  ANY non-zero exit as withheld; the self-test's sleep is killed and reaped.

## Finding 2 · [MINOR] allowlist check-to-use seam — FIX VERIFIED so far (self-test runs pending)

- **Shape (the final call's five conditions):** (a) `guard_allowlist` success line is
  `print -r -- "$email"` in BOTH twins, byte-identically — the helper's twin pin (sed over
  `guard_allowlist() {` … `}`) still compares the whole body, so it keeps proving it. (b) Contract
  pin in both self-tests (walk :294–295, helper :270–271) plus the walk's refusal-text companion.
  (c) Structural pin in both (walk :298, helper :274) via `outside_reads` — awk strips the guard's
  body and `allowlist_value`'s line, then counts `source $` lines. (d) The `plain_address` belts
  stay: helper `id_sql` and walk P3 :678. (e) The stale "allowlist changed since R1/G2?" refusal
  wording replaced in both (helper :419, walk :678). All five met.
- **Mechanism verified in the current files, my own grep:** every remaining `source $` sits inside
  `guard_allowlist` (walk :113–114, helper :70–71) or `allowlist_value` (walk :125, exempt per the
  final call); the main paths have NO re-read. `EMAIL` is assigned once at the guard (walk :429,
  helper :417), used at the splice (walk :678–679, helper :419–421), then unset — no intervening
  assignment exists (grepped every `EMAIL` mention in both files).
- **Red-on-old, MY OWN RUNS:** (structural) `outside_reads` over `14ad4a09c`'s files → helper 1,
  walk 1; over the current files → 0 and 0. (contract) the OLD `guard_allowlist`, extracted verbatim
  from `14ad4a09c` and run over a 600-mode fixture → `rc=0 output=''` — prints NOTHING on accept, so
  the new contract case is red on old. Both pins genuinely red-on-old.
- **A residual seam, noted and judged NOT a finding:** the guard itself reads the file twice
  internally (`list` then `email`, walk :113–114) — but every check (vxtest marker, plain, listed)
  binds the HANDED value, so an unmarked or non-plain address can never be handed back; round 1's
  reviewer cited these two sourcings and scoped the finding to the third, uncheck-bound read. The
  fence "her account can never pass" holds on the handed value itself.
- **Pending at the pause:** the walk's and helper's `--self-test` full runs (70+2 / 88+2 expected
  green), and the helper `expect`'s accept-path email-hiding line (read, looks right — walk's expect
  has the same `[[ $got == refuse ]] || why=` line, verified at :266).

*(Resumed 2026-10-27 by the round's closing reviewer at tip `79c8734a9`; findings 1–2's verdicts
above stand as committed.)*

## Finding 3 · [MINOR] release.sh "Arms one at a time" — FIX VERIFIED (`33de94d33`)

- **The sentence is the final call's verbatim minus backticks** (release.sh:329–330): "--arm join
  alone resumes a both run that stopped in the join arm (it needs that run's Standard vault);
  --arm setup alone also ends with the cleanup reset." — compared word for word against the binding
  text; the only delta is the dropped code marks.
- **The deviation reason HOLDS, checked mechanically:** the HANDOFF block is `cat <<EOF` at
  release.sh:319 — UNQUOTED, and necessarily so (it expands `${VERSION}`, `${BUILD}`, `${FEED}`,
  `${DMG_SHA}` at :320/:332–342). In an unquoted heredoc a backtick runs as command substitution,
  so dropping the marks is correct, not cosmetic. I counted backticks over both heredocs
  (:319–343, :346–352): **0**.
- **The premise still stands at the tip:** the lone-`--arm join` road refuses as described —
  `join_ready`'s "the account holds no vault — the set-up arm makes it (run --arm both)"
  (first-run-walk.sh:208).
- **`bash -n` on release.sh: clean** (my own run at the tip).
- No pin — document text, per the final call. Correct disposition.

## Finding 4 · [NIT] `--log`/`--app` exit grammar — FIX VERIFIED, pin's fences real, old exit 1 demonstrated by my own run (`e50ea8fb6`)

- **The refuse-shaped fix is in BOTH files at the tip:** helper :406
  `--log) [[ -n ${2:-} ]] || refuse "--log needs a file"; LOG=$2; shift ;;` and walk :418
  `--app) [[ -n ${2:-} ]] || refuse "--app needs a path"; APP=$2; shift ;;`. `refuse` is exit 5
  with the named reason in both (helper :59, walk :94) — the documented shape.
- **The pin's three fences, present at the tip in BOTH self-tests** (helper :390–394, walk
  :405–409): `HOME=$T/nohome` (an empty temp dir — no allowlist can exist, so even a regressed
  parse refuses at R1/G1 before any read) · `zsh -f` (no startup files) · exit-99 PATH shims
  (helper: curl; walk: curl + open + osascript + cliclick — a superset of the final call's third
  belt). Each self-test runs a fence-holds case FIRST, proving every shim shadows the real tool
  and no allowlist exists under the fenced HOME.
- **The OLD exit-1 behavior, demonstrated under the fence BY MY OWN RUN:** both pre-fix scripts
  extracted via `git show 33de94d33:…` into a scratch copy and run under the identical triple
  fence — helper `std --log` → `…:393: 2: --log needs a file`, **exit 1**; walk `std --app` →
  `…:406: 2: --app needs a path`, **exit 1**. Both outside the 0/4/5 grammar, exactly as the
  finding traced. **The CURRENT scripts under the same fence:** helper →
  `prod-reset-test-account REFUSES: --log needs a file`, **exit 5**; walk →
  `first-run-walk REFUSES: --app needs a path`, **exit 5**. Red-on-old genuine, both sides mine.
- Safety note: the fenced runs die at the arg parse, before any guard, read or launch; nothing
  but function definitions and assignments precedes the parse in either script (read myself).

## Finding 5 · [NIT] `J3 J3` — FIX VERIFIED (`bcac53925`)

- **The call site:** first-run-walk.sh:756 is `launch_on_road $RUN/app-join.log J3 J3b` —
  checked against the function (:581–610): arg 2 names the LAUNCH step (`step ${2:-P1}`, :583),
  arg 3 the ROAD/window/bounds step (`step ${3:-P2}`, :596), so the join's two distinct steps now
  log under two names, exactly launch_on_road's P1/P2 twins.
- **The dry-run plan line** (:489): "J3b the road: the process's environment and the app's ARMED
  line · the main window's bounds (P2's checks)" — present, in the join branch of the plan.
- **No collateral:** the setup arm's call (:673) passes no names and keeps the P1/P2 defaults;
  the line-50 header comment "Every launch (P1, J3)…" stays TRUE under the rename, since the
  launch halves remain P1 and J3 (J3b is the road check, and `frame_reset` runs in the launch
  half, :584). No pin — log naming, per the final call. Correct disposition.

## Finding 2 — the two pending ticks, now CLOSED (finding 2 FIX VERIFIED whole)

- **The email-hiding line on accept, BOTH expects read myself:** helper :241 and walk :266 carry
  the same `[[ $got == refuse ]] || why=` — on accept the guard's printed email (captured into
  `why`) is cleared before the case line prints, so no self-test output ever shows an address;
  on refuse `why` is the refusal text, as intended.
- **The full self-test runs, MY OWN, at the tip:** walk `--self-test` → **72 ok cases, "every
  guard fired as expected", exit 0 (72/72)**; helper `--self-test` → **"every guard fired as
  expected (90 cases)", exit 0 (90/90)**. Both match the fix record's claims. No stray `sleep`
  left behind (checked).

## The after-fix gate — RE-RUN FRESH at the tip, all MY OWN runs, ALL GREEN

The Tools/ files are byte-identical to `bcac53925`'s (`git diff bcac53925..HEAD -- Tools/` is
empty — only record files moved since), so these runs gate the fix set exactly.

- Walk `--self-test`: **72/72 green**, exit 0.
- Helper `--self-test`: **90/90 green**, exit 0.
- D-7 pin (`Tools/WalkKit/pins/guard-space-helper.zsh`): **0 failing of 11**.
- P-1 pin (`Tools/WalkKit/pins/words-guard-fail-closed.zsh`): **0 failing of 6** (its last case
  runs the guard's `--self-check` — P-2's synthetic trees — green inside it).
- `zsh -n` clean on all five: first-run-walk.sh · prod-reset-test-account.sh ·
  pins/words-guard-fail-closed.zsh · guard.sh · pins/guard-space-helper.zsh.
- `bash -n` clean on Tools/Release/release.sh.
- `swiftc` compiles words-guard.swift, capture-windows.swift and wl2.swift (into a scratch dir).

Environment constraints honored: fixtures and pins only; the one AX-adjacent act was the
self-tests' own spawned-and-reaped sleep; no production, stage, GUI, container, dry-run or live
mode was touched.

## Corroboration — findings 3–5 and the gate, independently verified by the opening reviewer (resumed)

The opening reviewer's own runs, made before reading the closing reviewer's sections above, agree on
every point, from distinct baselines:

- **Finding 3:** sentence word-for-word the final call's minus code marks (release.sh:329–330); the
  HANDOFF confirmed an unquoted `cat <<EOF` (it expands `${VERSION}`/`${FEED}`); my own count via awk
  over the file's `cat <<EOF`…`EOF` regions: **0 backticks**; `bash -n` clean. The deviation holds.
- **Finding 4:** fix shape and the triple fence re-read in both files; red-on-old demonstrated from
  the OTHER old baseline — the `14ad4a09c` scripts, fenced identically (`HOME` empty · `zsh -f` ·
  exit-99 shims): helper `std --log` → `…:380: 2: --log needs a file` **exit 1**, walk `std --app` →
  `…:380: 2: --app needs a path` **exit 1**; the current scripts under the same fence → **exit 5**
  with the named refusals. (The closing reviewer's `:393`/`:406` are the same lines in the
  pieces-A–C tree — same mechanism, both red.)
- **Finding 5:** `J3 J3b` at :756 against `launch_on_road`'s `${2:-P1}`/`${3:-P2}` grammar, the
  dry-run plan's J3b line at :489 — verified.
- **The gate, my own runs:** walk `--self-test` **72 ok cases counted**, exit 0; helper **"every
  guard fired as expected (90 cases)"**, exit 0; D-7 pin **0/11 exit 0** and, against `b090395e4`'s
  guard.sh, **6/11 exit 1** — still red-on-old; P-1 **0/6** (and **3/6** on `14ad4a09c`'s guard);
  P-2 **every verdict held** (and **6 wrong** on my own rebuilt fold-back mutant); `zsh -n` ×5,
  `bash -n`, `swiftc` ×3 all clean.
- **One datum beyond the sections above — the present-path positive control, verdict-only:** the
  fixed guard run on Finder → `ok (32 elements read)`, exit 0 — the `v as? [AXUIElement]` cast
  works on a real AX tree, matching the implementer's recorded control byte for byte.

## The whole-diff sweep for anything new

- The only CODE commits since round 1's review tip (`14ad4a09c`) are the five fix commits — each
  read whole, each scoped exactly to its finding; `git diff bcac53925..HEAD -- Tools/ Server/
  Sources/ App/` is EMPTY, so every later commit is record-only (stat-checked one by one:
  `33830fedf` · `065396b8f` · `f85717274` · `94e9fcb4f` · `79c8734a9` · `d7fb66192` · `e24dd5459`
  · `abd933ac6` · `27e03a95f`). Every commit since `14ad4a09c` is trailer-free (checked `%b` for
  `Co-Authored-By`/`Claude-Session` across the range).
- **No new BLOCKER or MAJOR — and no new MINOR or NIT either.** The one behavioral consequence
  worth naming (accepted by the final call): the guard is now strictly fail-closed, so a transient
  AX failure withholds a capture; `capture()` logs and continues, never stalls — captures are
  evidence, not gates — and the next live walk's `ok (<n> elements read)` lines are the
  over-withhold proof, as the final call stated.

## Clean bill (what round 2 specifically checked and found solid)

- The three-class taxonomy's boundaries: exactly-cap trees read whole; cap+1 withholds; a cycle
  terminates withheld; absent answers continue the scan (words beyond an absent node still found —
  self-check case 11); an empty windows list stays ok; the texts sequence is lazy, so an unreadable
  answer withholds at once with no timeout chain.
- The matcher's immutability across the rewrite: `verdict`/`twelve`/`markers`/`--classify`
  byte-identical old→new, so every pre-existing D-5 `--classify` case still proves the same thing.
- The same-read plumbing end to end: one guard call, one `EMAIL` (assigned at the guard, used at
  the splice, unset, no intervening assignment), no re-read anywhere (`source $` exists only inside
  `guard_allowlist` and the exempt `allowlist_value`), belts kept, twins byte-identical under the
  standing twin pin; the structural pin's awk correctly exempts only the guard's body and
  `allowlist_value`'s one-liner, and its own grep line is split so it never counts itself.
- The guard's internal two reads (`list`, then `email`) — noted and judged NOT a finding: every
  check (vxtest marker, plain, listed) binds the HANDED value, so an unmarked or non-plain address
  can never be handed back; the fence "her account can never pass" holds on the handed value.
- The fenced-subprocess pin's safety: under `HOME=<empty>` + `zsh -f` + shims, both scripts die at
  the arg parse or refuse at R1/G1 before any read — verified by running them myself; the pin can
  never reach the network, the GUI or an allowlist. Its assertion demands the NAMED refusal, not
  merely exit 5, so a parse regression falling through to a different guard still fails the case.
- The release.sh HANDOFF heredocs carry zero backticks; the new sentence is operationally accurate
  against the walk's arm composition as currently coded (a lone `--arm setup` runs THE END with
  E3's cleanup; `--arm join` skips the pre-step and `join_ready` stops on a vaultless account).
- The 496-element deviation: 1 root + 99 kids + 99×4 grandkids = 496, asserted in the self-check —
  the phase-1 "500" was the estimate, 496 the built truth, recorded honestly.
- Commit hygiene: no trailers anywhere in the range; records repo-first per piece; `.env`/logs/
  compiled helpers all under ignores (unchanged since round 1's clean bill).

## Verdict

**The round 1 fix set is sound and complete.** Every fix matches its binding final-call shape;
every pin is real and red-on-old — re-run on both sides by this round's reviewers' own hands, from
two independent old baselines; the two recorded deviations (release.sh's dropped code marks, the
496-element tree) both hold up; the gate is green fresh at the tip; nothing new was introduced
anywhere in the diff. **No findings. The VX-623 ladder closes at round 2 with a clean bill.**
