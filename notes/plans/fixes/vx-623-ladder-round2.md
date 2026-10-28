# VX-623 — Ladder round 2 (fresh cold reviewer re-checking round 1's fixes, 2026-10-27)

**STATUS: IN FLIGHT — PAUSED at her word (budget limit), 2026-10-27.** Written incrementally; this
checkpoint carries findings 1 and 2's verification. Remaining when resumed: finding 2's self-test
runs, findings 3–5, the after-fix gate re-run (walk 72/72 · helper 90/90 · D-7 0/11 · `zsh -n`/
`bash -n`/`swiftc`), the whole-diff sweep for any new BLOCKER/MAJOR, the clean bill, the verdict.

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
