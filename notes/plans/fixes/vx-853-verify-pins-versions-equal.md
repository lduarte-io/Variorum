# VX-853 — `Tools/verify-pins`' tree guard goes versions-equal (P-781-3 (b))

**STATUS:** ladder closed at round 2 (no new BLOCKER/MAJOR); the merge is the orchestrator's.

Branch `vx-853-verify-pins-versions-equal` (worktree `~/dev/variorum-vx-853`), cut from main at
544f41b1c. A single-ticket effort, her "micro-PR tonight" word. Implementer: opus-implementer,
2026-11-05. Cold reviews: opus-reviewer, rounds 1 and 2 (a same-model ladder; the orchestrator
arbitrates). Headless only: no xcodebuild, no stage. Scope: `Tools/verify-pins`,
`Tests/VariorumCoreTests/PinBeltTests.swift` (the orchestrator's round-1 scope ruling), pointer
lines in the closed VX-781 record, and this record.

## FOR A LATER READER

**What the guard is, and why it changed.** `Tools/verify-pins` with no argument is the pre-build
tree guard over the two committed lockfiles, the Xcode workspace's and the repo root's
`Package.resolved`. VX-781's belt keeps a floated dependency (SQLCipher above all) from shipping,
and this guard catches a lockfile in the tree that a build would adopt. As VX-781 built it, it was
byte-strict: any byte different from HEAD failed. That made the workspace lockfile's `originHash`
a standing false alarm, because it hashes the checkout's absolute path (VX-781 record T-2; survey
§3). Any resolve in another worktree rewrites that one line while every pin stays the same. Her
ruling **P-781-3 (b), VERSIONS-EQUAL** (QUESTIONS #260; the spec is
`notes/plans/vx-781-build-ergonomics-survey.md` §4) keeps every real pin change a failure and makes
a bookkeeping-only change a NOTE.

**The shape as built** (the no-argument form, per lockfile):
- missing: `DRIFT … MISSING`, exit 1.
- bytes equal to `<ref>:<file>` (default HEAD): OK.
- bytes differ: the file's pins are compared with **its own** committed copy, by identity, version
  and revision, exactly. Any difference prints `DRIFT <file>: the working-tree file differs from
  <ref> (a build ADOPTS it) — restore it with git checkout <ref> -- <file> before building` and
  exits 1. All equal prints `NOTE   <file>: differs from <ref> only in bookkeeping (pins identical)
  — harmless; restore with git checkout HEAD -- <file> before committing, never commit it.` and
  passes.
- then, always, the cross-file check: the file's pins against the committed workspace set (for the
  root lockfile, minus the project-only Sparkle).
- a lockfile listing one identity twice (compared case-insensitively) is refused, exit 2.
- the state-path, `--cli` and `--against` forms are unchanged (they were pins-based already). Under
  `--ref <rev>` the NOTE still advises HEAD, because committing is against HEAD and `git checkout
  <rev> --` would stage the rev's bytes.
- PinBeltTests (3) compares the two lockfiles' pins by version and revision exactly and by location
  through `sameLocation`, as (1) and (2) do; `Pin` is deliberately not `Equatable`.

**What still guards what ships** (survey §4, untouched): revision equality (the same commit is the
same source), the belt itself (an upgraded file fails closed or heals, VX-781 E8b), PinBeltTests in
every `swift test`, release.sh's clean-tree refusal, and VX-852's post-archive `verify-pins
<DerivedData>` once wired.

**The fix, one pointer per commit:** ad4d7c003 versions-equal (`pin_diffs` extracted from
`compare`, the byte check becomes the NOTE) · ec22812c5 the first pin, plus the VX-781 record's
superseded line · da3464d20 R1-1 decide on the file's own committed pins (+ R1-5's comment) ·
998294848 R1-4 duplicate identities refused · 31ca85d2e R1-2 PinBeltTests (3) compares locations
through `sameLocation` · eb2494803 R1-3 the VX-781 record's FOR A LATER READER and UPGRADING
pointers · 119b48ea4 R2-1 the restore advice names its source and the path · 588d2c23d R2-3 `Pin`
drops `Equatable` · this file, R2-2.

**Evidence lines** (old = 544f41b1c, the byte-strict guard; first form = ad4d7c003):
- P1, an originHash-only edit of both lockfiles: old exit 1 (two byte-DRIFT lines); now exit 0
  with two NOTEs, OK 16 / OK 15.
- P2, the workspace sqlcipher.swift version 4.18.0 → 4.20.0: exit 1 before and after, `DRIFT
  sqlcipher.swift: committed 4.18.0 (f879fff) -> resolved 4.20.0 (f879fff)`.
- R1a, `--ref 68b3d9c53` on a clean tree (the root file's own pins moved there, P-781-1): old 1,
  first form 0 (a false NOTE), now 1.
- R4, a floated duplicate sqlcipher.swift placed before the committed entry: old 1, first form 0,
  now 2 (`the pin identity sqlcipher.swift is listed more than once`).
- G1, the workspace sqlcipher location loses its `.git`: verify-pins prints the NOTE and exits 0;
  PinBeltTests (3) was red before 31ca85d2e and reads `✔ Test run with 3 tests in 1 suite passed`
  after. A version change, a revision-only change and another repository all stay red.
- PA/PB (round 2): executing the printed advice leaves the porcelain empty (`--ref 620cc9019`, and a
  staged originHash-only edit). Red on eb2494803 (`M  Package.resolved`), green on 119b48ea4.
- `swift test --filter PinBeltTests` on 588d2c23d: `✔ Test run with 3 tests in 1 suite passed`.

**Open items:** none. The probe drivers' text rides the PR body; the master plan's in-flight row
wording (R2-4) is the orchestrator's at the merge moment.

---

## The working record (verbatim; read only when reopening this fix)

### Implementation — commit messages verbatim

#### ad4d7c003

```text
VX-853: Tools/verify-pins' no-argument guard goes VERSIONS-EQUAL (her P-781-3 ruling (b))

The spec is notes/plans/vx-781-build-ergonomics-survey.md §4, adopted by her
P-781-3 ruling (QUESTIONS #260, resolved 2026-11-05).

Mechanism (survey §3, VX-781 T-2): the workspace lockfile's originHash is
sha256 over the root URLs plus the checkout's ABSOLUTE path, so any resolve
that rewrites the file in a worktree other than the one that committed it
changes that one bookkeeping line while every pin stays identical. The old
no-argument guard compared the working-tree lockfile to HEAD byte for byte
(the `text != git_show(...)` check) and reported DRIFT, exit 1, on that
harmless rewrite: shape (a), the false alarm the survey's F1-F4 rows count.

The change, the no-argument (no state argument) tree guard only:
- compare()'s identity + version + revision comparison is extracted, unchanged,
  into a pure pin_diffs(got, want, skip); compare() prints from it as before.
- bytes differ from the reference AND pin_diffs is non-empty: unchanged, the
  same "DRIFT <file>: the working-tree file differs from HEAD (a build ADOPTS
  it)" line, then compare()'s DRIFT report naming each pin; exit 1.
- bytes differ AND every pin equal: one line, the survey's wording,
  "NOTE   <file>: differs from HEAD only in bookkeeping (pins identical) —
  harmless; restore with git checkout -- before committing, never commit it."
  then compare()'s OK line; contributes exit 0. (The status column is padded
  to the script's existing 7-character OK/DRIFT column.)
- missing file: unchanged, DRIFT MISSING, exit 1. Bytes equal: unchanged, OK.
- state-path, --cli and --against forms: no code path changed (--against
  never ran the byte check). --ref with no state argument IS this tree guard
  against another revision, so it takes the same rule and its NOTE names the
  rev where the default says HEAD.
- the docstring's no-argument sentence and its exit line now say versions-equal.
One incidental ordering change: the tree lockfile is now parsed before the
byte check, so a non-JSON tree lockfile exits 2 ("not JSON") without first
printing the byte-DRIFT line; the exit code was and is 2.

The pin (probes run next, on this committed state, old = the pre-fix
544f41b1c script from a copy inside the checkout; each probe restored with
git checkout --): P1 originHash-only edit of both lockfiles (old exit 1, new
exit 0 + two NOTEs); P2 one pin's version edited (old 1, new 1 naming it);
P3 clean tree (both 0). Outputs land in the next commit's message.
```

#### ec22812c5

```text
VX-853: the pin, red-on-old and green-on-new, plus the closed VX-781 record's superseded pointer

The record touch: one "Superseded by VX-853" line after the paragraph in
notes/plans/fixes/vx-781-lockfile-pins.md (`Tools/verify-pins` — the guard)
that records the originHash-only rewrite as flagged; that record is CLOSED, so
nothing else in it is rewritten.

THE PIN, scripted (old = Tools/verify-pins at 544f41b1c, run from a copy in the
checkout's gitignored scratchpad/ so its repo_root() resolves; new = ad4d7c003;
both lockfiles restored with git checkout -- after every probe; the tree was
clean at the end, 0 porcelain lines). Reference header on every run:
"verify-pins: reference = HEAD:App/Variorum/Variorum.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved (16 pins)".
WS below = that workspace lockfile path; ROOT = Package.resolved.

P1, the false alarm: ONLY each lockfile's originHash value set to 64 zeros
(WS 5cfb2639… and ROOT 44abb1d8…; 2 files, 1 line each).
  OLD, exit 1 (RED):
    DRIFT  WS: the working-tree file differs from HEAD (a build ADOPTS it) — restore it with git checkout -- before building
    OK     WS (working tree): 16 pins match the committed set
    DRIFT  Package.resolved: the working-tree file differs from HEAD (a build ADOPTS it) — restore it with git checkout -- before building
    OK     Package.resolved (working tree, the CLI graph): 15 pins match the committed set
  NEW, exit 0 (GREEN):
    NOTE   WS: differs from HEAD only in bookkeeping (pins identical) — harmless; restore with git checkout -- before committing, never commit it.
    OK     WS (working tree): 16 pins match the committed set
    NOTE   Package.resolved: differs from HEAD only in bookkeeping (pins identical) — harmless; restore with git checkout -- before committing, never commit it.
    OK     Package.resolved (working tree, the CLI graph): 15 pins match the committed set

P2, real drift still caught: WS sqlcipher.swift "version" 4.18.0 -> 4.20.0,
revision untouched. OLD and NEW byte-identical, both exit 1:
    DRIFT  WS: the working-tree file differs from HEAD (a build ADOPTS it) — restore it with git checkout -- before building
    DRIFT  WS (working tree): 1 pin(s) differ from the committed set
      DRIFT   sqlcipher.swift: committed 4.18.0 (f879fff) -> resolved 4.20.0 (f879fff)
    OK     Package.resolved (working tree, the CLI graph): 15 pins match the committed set

P3, clean tree: OLD and NEW byte-identical, both exit 0:
    OK     WS (working tree): 16 pins match the committed set
    OK     Package.resolved (working tree, the CLI graph): 15 pins match the committed set

Supplementary, the other unchanged branches: ROOT sqlcipher.swift revision-only
edit (version still 4.18.0): OLD 1 / NEW 1, both naming
"DRIFT   sqlcipher.swift: committed 4.18.0 (f879fff) -> resolved 4.18.0 (e7415c5)";
WS lockfile deleted: OLD 1 / NEW 1, both "DRIFT  WS: MISSING from the working
tree (a build would resolve WITHOUT pins)".

Sanity: swift test --filter PinBeltTests -> "✔ Test run with 3 tests in 1 suite
passed after 0.003 seconds." (the build left both lockfiles untouched; the tree
guard after it: OK 16 / OK 15, exit 0). No xcodebuild, no stage.
```

### LADDER ROUND 1 — opus-reviewer findings, relayed verbatim by the orchestrator (numbered R1-1…R1-6 in the order given)

> **[MINOR] · Tools/verify-pins:200–210 · The NOTE says "only in bookkeeping (pins identical)", but the check behind it compares against a different file than the one the NOTE names.**
> - The byte check, and the NOTE's own text, compare `rel` against `<ref>:rel`, the same file as committed. But NOTE versus DRIFT is decided by `pin_diffs(got, want, skipping)`, and `want` is the *workspace* lockfile at `<ref>`. For the root `Package.resolved` those are two different files. Whenever the root file's pins differ from its own commit but equal the workspace set, the tool prints a false NOTE. It also tells the session "never commit it" about a real pin change.
> - Evidence: `Tools/verify-pins --ref 68b3d9c53` prints `NOTE   Package.resolved: differs from 68b3d9c53 only in bookkeeping (pins identical)` and exits 0 — while `git diff 68b3d9c53 HEAD -- Package.resolved` shows P-781-1's pin move. The old script exited 1 on the same input. The same mechanism fires in default HEAD mode whenever HEAD's two lockfiles disagree, and when a Sparkle pin at the workspace version is added to the root file (PinBeltTests (1) catches that; verify-pins calls it bookkeeping).
> - Why it matters: under P-781-4 any pin move is author-only, so steering a session to treat an uncommitted pin change as bookkeeping is the wrong signal. It breaks survey §4's "every pin-level difference stays exit 1" for the root file.
> - Proposed fix: decide NOTE versus DRIFT on the same file's committed pins (`pins_of(parse_json(git_show(root, ref, rel)))` vs `got`); keep `compare(label, got, want, skipping)` as the cross-file check. Sub-point: under `--ref`, the advice "restore with git checkout --" restores to HEAD, not `<ref>`.
> - Pin: the `--ref 68b3d9c53` probe — false NOTE + exit 0 today; a DRIFT naming the root file + exit 1 after.
>
> **[MINOR] · Survey §4 premise vs Tests/VariorumCoreTests/PinBeltTests.swift:190 · For the F4 location-spelling case, verify-pins now says "harmless" while `swift test` goes red.**
> - Test (3) compares whole `Pin` structs verbatim, location included (`if r != pin`); (1) and (2) normalise location through `sameLocation`; (3) does not. Evidence: flip only the workspace sqlcipher location's `.git` suffix — new verify-pins NOTEs and exits 0; PinBeltTests (3) fails with a message that HIDES the location (`root 4.18.0 (f879fff) ≠ workspace 4.18.0 (f879fff)`), reading as a contradiction.
> - Impact: no safety cost (stricter, not looser), but the two guards of one belt disagree and F4 still produces the friction her ruling aimed to remove.
> - Proposed fix: in (3), compare version and revision exactly and location via `sameLocation`; add location to `Pin.description`. Pin: the `.git`-flip probe — (3) red now, green after; real drift still red.
>
> **[MINOR] · notes/plans/fixes/vx-781-lockfile-pins.md:57 vs :358 (and :534–535) · The supersession pointer is in the part of the record later sessions never read.** FOR A LATER READER still names the guard with no successor (CLAUDE.md: kept current); UPGRADING :534–535 still says a byte-dirty workspace lockfile "shows as DRIFT". Fix: the one pointer at :57 ("…the tree guard versions-equal since VX-853, ad4d7c003") and a parenthetical at :534–535.
>
> **[NIT] · Tools/verify-pins:76–78 · Duplicate pin identities collapse silently** (`pins_of` dict, last wins) while SwiftPM refuses such a file as corrupted (verified in source, 5.10→main; identities case-insensitive). Probe: a floated 4.20.0 sqlcipher entry placed before the committed 4.18.0 — new exits 0 "harmless", old exited 1. No ship risk (SwiftPM fails closed); plausible via a merge-conflict both-sides resolution. Fix: `pins_of` refuses a duplicate identity (case-insensitive), exit 2 naming it. Pin: that probe.
>
> **[NIT] · Tools/verify-pins:207–208 · The comment cites a bare "T-2"** — write "VX-781 record T-2".
>
> **[NIT] · The pin is not durable.** The probe driver lives in session scratch; nothing committed re-runs it. The commit message describes each probe exactly (the reviewer re-derived and re-ran them). Optional: the driver text in the PR body.

The orchestrator's rulings (verbatim): "MY SCOPE RULING on finding 2: you MAY fix PinBeltTests in
this run — it's a test file, no app source, and the fix is what makes the belt coherent under her
ruling; I will declare the scope addition to the machine coordinator in the merge ask. If you'd
rather dispute it as out-of-scope, say so and I'll ticket it instead. On finding 6: put the probe
driver's text in your report and I'll carry it into the PR body — don't commit scratch into the
repo."

**Dispositions (implementer):** every finding AGREED, none disputed; each code finding was
reproduced before its fix.
- R1-1: FIXED (da3464d20), with the `--ref` sub-point (since refined by R2-1).
- R1-2: FIXED (31ca85d2e).
- R1-3: FIXED (eb2494803).
- R1-4: FIXED (998294848).
- R1-5: FIXED (da3464d20).
- R1-6: the driver text went to the orchestrator for the PR body; nothing committed.

Observations offered and not taken:
- In R1a/R1b the DRIFT line names the file but not which of its pins moved, because the cross-file
  check reports OK. That matches the old script's output.
- A first D2 probe edited the root lockfile's revision. `swift test` resolves from that file, so
  the probe broke the CLI's own resolution before any test ran (not a test verdict). It was
  restored and re-run on the workspace lockfile.

Round-1 fix commits, messages verbatim:

#### da3464d20

```text
VX-853 round 1, finding 1 (+5): NOTE or DRIFT is decided against the file's OWN committed pins

Finding 1 [MINOR], AGREED, traced and reproduced: the byte check compares
<rel> with <ref>:<rel>, but ad4d7c003 decided NOTE vs DRIFT with
pin_diffs(got, want, skipping), where want is the WORKSPACE lockfile at <ref>.
For the root Package.resolved that is a different file, so a root lockfile
whose pins moved from its own commit but equal the workspace set got a false
"bookkeeping (pins identical)" NOTE and exit 0.

Fix: when the bytes differ, NOTE vs DRIFT compares got against
pins_of(<ref>:<rel>) itself, exactly, with no project-only skip;
compare(label, got, want, skipping) stays the cross-file check. Sub-point
agreed: under --ref <rev> (rev != HEAD) both the DRIFT and the NOTE restore
advice now say "git checkout <rev> --"; under the default HEAD both lines are
byte-identical to before. Docstring says "its own committed copy".
Finding 5 [NIT], AGREED: the comment cites "VX-781 record T-2".

Pin (driver: the round-1 probe script, OLD = 544f41b1c, R0 = ec22812c5,
NEW = this commit; lockfiles restored after each). WS = the workspace lockfile.
R1a, clean tree, --ref 68b3d9c53 (P-781-1 moved the root file's own pins since):
  OLD exit 1: DRIFT  Package.resolved: the working-tree file differs from 68b3d9c53 (a build ADOPTS it) — restore it with git checkout -- before building
  R0  exit 0: NOTE   Package.resolved: differs from 68b3d9c53 only in bookkeeping (pins identical) — harmless; restore with git checkout -- before committing, never commit it.
  NEW exit 1: DRIFT  Package.resolved: the working-tree file differs from 68b3d9c53 (a build ADOPTS it) — restore it with git checkout 68b3d9c53 -- before building
  (WS: OK 16 under all three; root: cross-file OK 15 under all three)
R1b, default HEAD, the WS sparkle pin copied verbatim into the root lockfile (+9 lines):
  OLD exit 1: DRIFT  Package.resolved: the working-tree file differs from HEAD (a build ADOPTS it) — restore it with git checkout -- before building
  R0  exit 0: NOTE   Package.resolved: differs from HEAD only in bookkeeping (pins identical) — harmless; …
  NEW exit 1: DRIFT  Package.resolved: the working-tree file differs from HEAD (a build ADOPTS it) — restore it with git checkout -- before building
Unchanged, NEW byte-identical to R0: P1 (originHash-only, both files) exit 0
with two NOTEs; P2 (WS sqlcipher 4.18.0 -> 4.20.0) exit 1 naming
"DRIFT   sqlcipher.swift: committed 4.18.0 (f879fff) -> resolved 4.20.0 (f879fff)";
P3 (clean) exit 0, OK 16 / OK 15.
```

#### 998294848

```text
VX-853 round 1, finding 4: pins_of refuses a duplicate pin identity (exit 2)

Finding 4 [NIT], AGREED, reproduced: pins_of built a dict, so a lockfile
listing one identity twice collapsed silently, the last entry winning. Under
versions-equal that turned a floated duplicate placed BEFORE the committed
entry into "bookkeeping (pins identical) — harmless", exit 0, where the old
byte check exited 1. The claim "pins identical" is false for such a file.

Fix: pins_of refuses an identity listed more than once, compared
case-insensitively, in both readable shapes (a Package.resolved's pins and a
workspace-state.json's remote dependencies): exit 2,
"verify-pins: the pin identity <id> is listed more than once: <where>".
The docstring's exit line says so.

Pin (round-1 probe driver; OLD = 544f41b1c, R0 = ec22812c5, NEW = this commit).
R4, a floated duplicate "sqlcipher.swift" 4.20.0 (e7415c5…) inserted before the
committed sqlcipher.swift pin in the workspace lockfile:
  OLD exit 1: DRIFT  WS: the working-tree file differs from HEAD (a build ADOPTS it) — …; OK 16; OK 15
  R0  exit 0: NOTE   WS: differs from HEAD only in bookkeeping (pins identical) — harmless; …; OK 16; OK 15
  NEW exit 2: stderr "verify-pins: the pin identity sqlcipher.swift is listed more than once: App/Variorum/Variorum.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
The same duplicate spelled "SQLCipher.swift": OLD 1 / R0 1 (EXTRA SQLCipher.swift),
NEW 2 (the same refusal, case-insensitive). A synthetic workspace-state.json
with a duplicate: NEW exit 2, the same refusal; without one: OK 16, exit 0.
State mode on the lockfiles themselves: OK 16, and --cli Package.resolved OK 15.
Every other driver probe unchanged from da3464d20: P3 0, P1 0 (two NOTEs),
P2 1, R1a 1, R1b 1, R2v 0 (the intended NOTE).
```

#### 31ca85d2e

```text
VX-853 round 1, finding 2: PinBeltTests (3) compares locations as (1) and (2) do

Finding 2 [MINOR], AGREED (the orchestrator's scope ruling allows the test
file in this run), reproduced: test (3) compared whole Pin structs with `!=`,
the location verbatim, while (1) and (2) normalise it through sameLocation
(case and a trailing `.git` / `/` ignored). So the F4 spelling case (survey §4)
had the two guards of one belt disagree: verify-pins says bookkeeping, NOTE,
exit 0; swift test goes red. Pin.description hid the location, so the failure
read as a contradiction.

Fix: (3) compares version and revision exactly and the location through
sameLocation; Pin.description now shows the location ("4.18.0 (f879fff) at
<url>"), which (1) and (2)'s messages also print.

Pin (swift test --filter PinBeltTests; lockfiles restored after each; WS = the
workspace lockfile):
G1, WS sqlcipher location loses only its `.git` suffix:
  BEFORE (998294848's test): ✘ (3) — "sqlcipher.swift: root 4.18.0 (f879fff) ≠ workspace 4.18.0 (f879fff)";
    "✘ Test run with 3 tests in 1 suite failed after 0.003 seconds with 1 issue."
  AFTER: "✔ Test run with 3 tests in 1 suite passed after 0.002 seconds."; verify-pins exit 0 (the NOTE).
Real drift stays red AFTER:
  D1, WS sqlcipher version 4.18.0 -> 4.20.0: ✘ (2) and ✘ (3) —
    "sqlcipher.swift: root 4.18.0 (f879fff) at https://github.com/sqlcipher/SQLCipher.swift.git ≠ workspace 4.20.0 (f879fff) at https://github.com/sqlcipher/SQLCipher.swift.git"; verify-pins exit 1.
  D2, WS sqlcipher revision-only change (version kept): ✘ (3) only —
    "… root 4.18.0 (f879fff) at … ≠ workspace 4.18.0 (e7415c5) at …"; verify-pins exit 1.
  D3, WS sqlcipher location at another repository (someone-else/SQLCipher.swift.git): ✘ (2)
    ("the project points at https://github.com/sqlcipher/SQLCipher.swift.git, the workspace lockfile at https://github.com/someone-else/SQLCipher.swift.git")
    and ✘ (3) ("… at https://github.com/sqlcipher/SQLCipher.swift.git ≠ workspace 4.18.0 (f879fff) at https://github.com/someone-else/SQLCipher.swift.git").
    verify-pins exits 0 there by design: same identity, version and revision means
    the same commit, so the same source (survey §4); the belt test owns location.
  Clean tree: "✔ Test run with 3 tests in 1 suite passed after 0.002 seconds."
```

#### eb2494803

```text
VX-853 round 1, finding 3: the VX-781 record's FOR A LATER READER and UPGRADING carry the successor

Finding 3 [MINOR], AGREED: the supersession pointer (ec22812c5) sat in the
working-record part a later session never reads, while FOR A LATER READER
(kept current, CLAUDE.md) still named the guard with no successor, and
UPGRADING step 4 said a byte-dirty workspace lockfile "shows as DRIFT".
Fix: FOR A LATER READER's belt line names the tree guard versions-equal since
VX-853 (ad4d7c003–998294848) and PinBeltTests (3)'s location rule
(31ca85d2e); UPGRADING step 4 gains one parenthetical (a pin-equal rewrite is
only a NOTE; a pin change stays DRIFT). Nothing else in the CLOSED record moves.
```

### LADDER ROUND 2 — opus-reviewer findings, relayed verbatim (R2-1…R2-4), and the orchestrator's calls

> **[MINOR] · Tools/verify-pins:201, :220-221, :227-228 · Round 1's `--ref` restore advice contradicts itself, and the default advice does nothing on a staged file.** Under `--ref <rev>` (rev ≠ HEAD) the NOTE says "restore with git checkout <rev> -- before committing, never commit it" — but `git checkout <rev> -- <path>` writes the rev's bytes into the INDEX as well as the tree, so following the advice STAGES a bookkeeping-only change against HEAD, the very thing the sentence forbids committing (reproduced read-only with `--ref 620cc9019`: the root lockfiles differ only in originHash between those commits). And the default-HEAD advice `git checkout -- <rel>` restores from the INDEX, not HEAD — so a bookkeeping rewrite already staged survives the advised command, which is the survey's own named residual risk (§4). Exit codes are correct everywhere; message text only. Proposed fix: the NOTE's advice names HEAD and the path — `git checkout HEAD -- <rel>` — independent of `--ref`; the DRIFT line under `--ref` may keep `git checkout <rev> --`, preferably with the path added. Pin (scripted): (1) on a clean tree run `--ref 620cc9019`, execute the printed command with the path, assert porcelain empty — red on eb2494803 (staged M), green after; (2) for HEAD: `git add` the P1 edit, execute the printed command, assert porcelain empty — red now, green with `HEAD --`.
>
> **[MINOR] · CLAUDE.md, Build workflow · No `notes/plans/fixes/vx-853-*.md` exists.** VX-853 has run round 1 → fixes → round 2 — CLAUDE.md's definition of a ladder — and "a fix that runs a ladder still lands a repo record file"; PR + commit messages suffice only for a fix that does NOT. Proposed fix: land `notes/plans/fixes/vx-853-verify-pins-versions-equal.md` at closeout — FOR A LATER READER at top (the mechanism as settled, one pointer per commit, P-781-3 (b) by id, the P1/P2/R1a/R4/G1 evidence lines, no open items), the round logs below copied verbatim from the commit messages.
>
> **[NIT] · PinBeltTests.swift:23 · `Pin` is still `Equatable` but nothing uses its equality, and the synthesized `==` (location-verbatim) is exactly the trap round 1 removed from (3)** — a future `r != pin` would re-split the two guards. Proposed fix: a custom `==` using `sameLocation` + exact version/revision (then (3) can use `r != pin` again, one definition of "same pin"), or drop the conformance.
>
> **[NIT] · notes/DetailedPlanForPhases.md:15 · VX-853's in-flight row still says "Tools script only"** while the branch touches core test source since 31ca85d2e. Fix at the merge moment on latest main.

The orchestrator's calls (verbatim): "Finding 1 — AGREED, fix as proposed: the NOTE's advice becomes
`git checkout HEAD -- <rel>` in BOTH modes (correctness beats keeping the survey's example wording —
its line was introduced "for example"); the DRIFT line under `--ref` keeps `git checkout <rev> --`
WITH the path appended; run both scripted pins. Finding 2 — AGREED: write the record file exactly as
proposed; title the FOR A LATER READER honestly (the guard's shape, why it exists, the one-page
evidence). Finding 3 — AGREED, your pick between custom `==` and dropping the conformance, one
stated reason in the commit message. Finding 4 is MINE at the merge moment — don't touch the master
plan."

**Dispositions (implementer):**
- R2-1: FIXED (119b48ea4). The default-mode DRIFT line takes the same `git checkout HEAD -- <rel>`
  form, the one expression `git checkout <ref> -- <rel>`. That was my reading of a call that named
  only the `--ref` DRIFT line, stated in the commit for the line-by-line check.
- R2-2: this file.
- R2-3: FIXED (588d2c23d) by dropping the conformance.
- R2-4: left to the orchestrator; the master plan is untouched.

Round-2 fix commits, messages verbatim:

#### 119b48ea4

```text
VX-853 round 2, finding 1: the restore advice names its source and the path

Finding 1 [MINOR], AGREED (the orchestrator's call: fix as proposed), traced
and reproduced. Two halves, message text only, exit codes untouched:
- under --ref <rev> the NOTE said "restore with git checkout <rev> -- before
  committing, never commit it", but `git checkout <rev> -- <path>` writes the
  rev's bytes into the INDEX as well, so following it STAGES a bookkeeping-only
  change against HEAD, the very thing the sentence forbids;
- the default advice `git checkout -- <path>` restores from the INDEX, not
  HEAD, so a rewrite already staged survived it (survey §4's named residual).

Fix: the NOTE advises "git checkout HEAD -- <rel>" in every mode (committing
is against HEAD; this supersedes the survey's example wording, which it
introduced "for example"). The DRIFT line advises "git checkout <ref> -- <rel>":
under --ref it keeps the rev, now with the path; under the default the same
expression reads "git checkout HEAD -- <rel>", which closes the same staged gap
on the default DRIFT line (my reading of the call, which named only the --ref
DRIFT line; stated here for the line-by-line check). Docstring and comments
say why.

Pin (driver vx853-probes-r2.sh: run the script, EXECUTE the advice it prints,
the path appended when the printed command ends in "--", check porcelain;
R1 = eb2494803, NEW = this commit; lockfiles reset in index and tree after each):
PA (reviewer pin 1), clean tree, --ref 620cc9019 (root lockfile differs there only in originHash):
  R1:  executing: git checkout 620cc9019 -- Package.resolved   porcelain: M  Package.resolved -> RED
  NEW: NOTE   Package.resolved: differs from 620cc9019 only in bookkeeping (pins identical) — harmless; restore with git checkout HEAD -- Package.resolved before committing, never commit it.
       executing: git checkout HEAD -- Package.resolved          porcelain: (empty) -> GREEN
PB (reviewer pin 2), P1's originHash-only edit of both lockfiles, git add-ed, default HEAD:
  R1:  executing: git checkout -- <WS>; git checkout -- Package.resolved   porcelain: M  <WS> M  Package.resolved -> RED
  NEW: executing: git checkout HEAD -- <WS>; git checkout HEAD -- Package.resolved   porcelain: (empty) -> GREEN
PC (supplementary), P2's version edit staged, the DRIFT advice: R1 RED (M  <WS>), NEW GREEN;
  NEW line: "DRIFT  <WS>: the working-tree file differs from HEAD (a build ADOPTS it) — restore it with git checkout HEAD -- <WS> before building"
PD (supplementary), clean tree, --ref 68b3d9c53, the DRIFT advice
  "git checkout 68b3d9c53 -- Package.resolved": the byte-DRIFT line is gone after
  it under both (68b3d9c53's own two lockfiles disagree, P-781-1, so its
  cross-file DRIFT stays — correctly).
Regression, the round-1 driver on NEW: P3 0, P1 0, P2 1, R1a 1, R1b 1, R4 2, R4' 2, R2v 0 (unchanged).
```

#### 588d2c23d

```text
VX-853 round 2, finding 3: PinBeltTests' Pin drops its Equatable conformance

Finding 3 [NIT], AGREED; my pick between the two offered fixes: DROP the
conformance. Reason: a custom location-normalising `==` would call two pins
equal while their descriptions print different locations (Equatable promises
substitutable values); without the conformance a future `r != pin` does not
compile, so (3)'s explicit rule (version and revision exactly, the location
through sameLocation) stays the one definition of "the same pin". A doc
comment on Pin says so.

Evidence (a design NIT, no red-on-old): a throwaway `_ = (r != pin)` inserted
in (3) COMPILED on 119b48ea4's file ("Build complete!") and FAILS on this one:
"PinBeltTests.swift:195:24: error: referencing operator function '!=' on
'BinaryInteger' requires that 'PinBeltTests.Pin' conform to 'BinaryInteger'";
the throwaway was removed (0 lines left). swift test --filter PinBeltTests:
"✔ Test run with 3 tests in 1 suite passed after 0.003 seconds." The
vx853-pinbelt-probes.sh driver re-run: G2 clean and G1 (.git flip) green, D1
(version) red (2)+(3), D2 (revision-only) red (3), D3 (another repository)
red (2)+(3) — unchanged from 31ca85d2e.
```
