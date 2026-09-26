# 18l U-VIS — ladder ROUND 1 (cold review, `opus-reviewer`, 2026-09-26)

**Diff under review:** `e41cc9c6..b7a722d5` (11 commits, `ceaf40b9` … `b7a722d5`) — `Tools/VisualWalk/`
(new), `App/Variorum/Variorum/Core/Views/VisualWalkProbe.swift` (new, DEBUG), five lines in
`VariorumAppDelegate.swift` (DEBUG), `.gitignore`, and the U-VIS record appended to
`notes/plans/phase-18l-navigation-feel.md` (a pure append — no other section of that file moved).
Review anchor: that file's U-VIS DESIGN NOTE (the contract), U-VIS BRIEF and U-VIS RECORD; the
charter's U-VIS section (`notes/plans/post-13u-health-rounds.md`). Prompt: `notes/REVIEW_PROMPT.md`,
verbatim. Read-only during the review; this file is the only write.

**STATUS: COMPLETE** — 0 BLOCKER · 1 MAJOR · 8 MINOR (one SPECULATIVE) · 8 NIT.

## SEAM CALL (asked explicitly by the brief)

**Not an editor-seam touch beyond a DEBUG, read-only surface — no Fable pass is owed on seam grounds.**
What I traced:

- The diff modifies NO seam file: `EditorTextView`, `EditorViewModel`, `PaneSurface`,
  `BlockRangeIndex`, `PaneTextAuthority` and `runStructural` are all untouched (`git diff --stat`). The
  one app-side file is new, lives in `Core/Views/` beside `DebugOracleOwnership.swift`, and is
  `#if DEBUG` from its first import to its last line (`VisualWalkProbe.swift:49`–`432`); the delegate
  call is inside `#if DEBUG` too. Inside DEBUG it registers only when launched with
  `VARIORUM_VISUAL_WALK=1` (`:68`), once.
- The probe WRITES nothing: no storage, selection, attribute, frame or oracle-slot write (so 18k C4's
  owner-keyed rule has nothing to key — the record's argument holds). Its calls into seam objects are
  reads: `EditorViewModel.topVisibleOffset()` (`EditorViewModel.swift:4108` — a production read that
  already runs on every scroll; `textLayoutFragment(for:)` plus viewport-bounded enumeration, no
  `.ensuresLayout`), `caretOrdinal`, `blockCount`, `scrollView`, `EditorTextView.typewriterRoom`. TK2
  hygiene holds: no `.layoutManager`, only `textLayoutManager` / `textContainer` / `textStorage`.
- The ONE layout it can cause is the opt-in `measure` flag: `PaneMeasurement.height`
  (`PaneSurface.swift:61`, a full `.ensuresLayout` walk) — gated to `model?.scrollView == nil`
  (`VisualWalkProbe.swift:118`), i.e. never the full-document editor, and it is exactly what the inline
  editor's coordinator already runs per keystroke (`EditorView.swift` `remeasure`). It introduces no
  layout state the surface does not reach on its own.
- One caveat is recorded as a finding, not a seam call: the probe's out-of-viewport fragment
  enumerations on the DOCUMENT editor (MINOR-8, SPECULATIVE) — an observer-effect question for the
  harness's evidence, not a write to seam state.

## FINDINGS (severity-ranked)

### MAJOR-1 · `Tools/VisualWalk/lib.zsh:127-143, 166, 183, 195, 202, 209, 241` · `visual-walk.sh:89` — every GUI act ACTIVATES the dev app BEFORE the guard checks for the author, and an "author at the machine" refusal is RETRIED WITH RE-ACTIVATION

**What's wrong.** The ENVIRONMENT TRAPS rule this harness exists to mechanize (hardened after the U0
~01:37 incident) says: *"(1) check HID idle BEFORE EVERY GUI step … recent input … means STOP and wait
or go harness-only"*. The harness does the opposite order on every act, and loops on the refusal:

- `vw_click` / `vw_keys` / `vw_ax_press` / `vw_scroll` / `vw_resize` all run
  `sleep $STEP_GAP; vw_activate; vw_guarded …` (`lib.zsh:166, 183, 195, 202, 209`). `vw_activate`
  (`:140-143`) is `System Events … set frontmost … to true` — it moves keyboard focus to the dev app —
  and only THEN does `guard.sh` check (0) her app and (1) HID idle.
- `vw_guarded` (`:127-138`) aborts only on `rc == 3` (her app). On `rc == 4` — `guard.sh:8`,
  *"HID idle Ns — someone is at the machine — STOP"* — it sleeps 5 s, calls `vw_activate` AGAIN, and
  re-runs the guard, up to three guard runs in all.
- Two GUI acts have no guard at all: the per-voice relaunch (`visual-walk.sh:89`,
  `vw_quit_app; sleep 2; vw_launch` → `open -n`, which takes focus) and the Settings close
  (`lib.zsh:241`, an AX click on the close button, 1.5 s after the last guard).

**Mechanism (traced).** The author sits down mid-run (the full run is ~14 min) and types in her
browser. Next act: 2.6 s → `vw_activate` (the dev app is now frontmost; her keystrokes go to the dev
editor — the Sherlock fixture at the caret, or a ⌘-shortcut to the dev app) → `guard.sh` exit 4 →
5 s → `vw_activate` again (if she clicked back, focus is stolen again) → exit 4 → 5 s → activate →
exit 4 → abort. Three focus steals across ~15 s while she is demonstrably present — the precise thing
the trap forbids. The harm is bounded (her `/Applications` app is refused up front and by `guard.sh`
exit 3; the dev store is fenced), but it is the harness's safety contract with the author, and the
trap's own history is a live incident of exactly this class. (WalkKit's `click.sh:4-6` /
`keys.sh:5-7`, outside this diff, share the activate-then-guard order.)

**Pin (red-on-old).** A headless zsh rig: source `lib.zsh` with `osascript` and `cliclick` shadowed by
functions that append to a call log, `WK` pointed at a stub `guard.sh` that exits 4, `RUN_DIR` a temp
dir, then `vw_click 10 10`. Old: the log shows an activation BEFORE the first guard run and two more
after the exit-4 refusals (then exit 4). Fixed: no activation before a passing author check, none
after an idle refusal.

**Proposed fix.** Split the guard's author checks (her app absent · HID idle) from its target checks
(frontmost · Space · point): run the author checks FIRST, activate only after they pass, then run the
target checks; treat `rc == 4` like `rc == 3` — abort (or wait for idle WITHOUT touching the GUI, then
restart the whole sequence), never re-activate on it. Guard the relaunch (an author check before
`open -n`) and the Settings close. Fix WalkKit's `click.sh`/`keys.sh` the same way (one guard, one
home — the record's own principle).

### MINOR-1 · `Tools/VisualWalk/scenarios.zsh:219-227` — rule (c) on the LAST-line click is asserted only under the S3 label, so a caret landing on the WRONG TEXT line reds nowhere

**What's wrong.** Design decision 2(c) — *"a click lands the caret on the clicked line"*. For the
lower block's last-line click, the only assertion that can tell WHICH line the caret took is
"click y in its box" (`:226-227`), and it carries `$KI_S3`, so a miss is XFAIL (never red). The two
plain assertions only rule out the blank line under the text (`:220-225`).

**Mechanism (traced).** U0 measured the pre-fix Read ▸ edit shape as *"Read ▸ edit at line 0"* (U0
RECORD item 1). Replay it through `vw_click_read_tier`'s last-line arm: `nl`/`caretEnd` → "on-text"
(PASS); `caretLine 0 < caretTextLines 5` (PASS); y-in-box misses by ~4 lines → XFAIL. The arm reports
XFAIL and the run exits 0. (The first-line arm's x assertion would catch that particular `.start`
shape, but any last-line-specific wrong-line landing — e.g. an off-by-one line in the click-place
replica for last lines — passes as XFAIL.)

**Pin (red-on-old).** Pure logic, no GUI: feed `vw_click_read_tier`'s last-line assertions a probe line
with `caretLine=0 caretTextLines=5 nl=1 caretEnd=0` and a y outside the box → old: no FAIL row; fixed:
FAIL. Or the real thing: `readedit-click` via `VW_DD` against U0's R-U0-1 revert (both hosts
`clickOffset: nil`).

**Proposed fix.** Add a PLAIN line-index assertion for the last-line click that S3 cannot break:
`caretLine ∈ {caretTextLines−2, caretTextLines−1}` (the last text line, or the one line S3's
marker-showing wrap may add — the comment at `:222-223` names exactly that possibility), and keep the
y-in-box row S3-labelled.

### MINOR-2 · `Tools/VisualWalk/scenarios.zsh:346-363` (and `:313`, `:339`) — `b5-refont` is labelled KNOWN although it has never reproduced, so it can never red; the standing XPASS it produces erodes the report's XPASS flag

**What's wrong.** The brief: B5 is *"asserted EXPECTED-FAIL or PASS as the tree actually behaves,
honestly labelled either way"*, and *"a tripwire that cannot fire is hollow"*. `b5-refont`'s own
`vw_def` says *"not reproduced at U-VIS's first runs"*; the final run shows it XPASS in both voices
(`vis-walks/2026-09-26/114921/report.md`), yet its page-still rows carry `$KI_B5` (`:363`), so a real
page move on the re-font road is XFAIL — reported, never red. Judgment call 6's reason
("history-dependent reproduction") was measured for the carve road in Study, not for this road.
Second effect: every standing run now reports `XPASS 4 — … re-examine its row`
(`b5-return-after-cmd-down` in Terminal, `b5-refont` in both voices, `readedit-click`'s S3 row in
Study) — a loud flag that fires every time trains the reader to ignore it, which removes the one
signal an XPASS is for.

**Mechanism.** Any future regression that moves the page on ⏎ after ⌘↓ following a re-font →
`vw_expect_page_still tail … "$KI_B5"` → XFAIL → exit 0.

**Pin.** Plant the moved numbers (a snapshot `tail.top=45591` vs a probe `top=45509`) through
`scn_b5-refont`'s assertions: old XFAIL, fixed FAIL.

**Proposed fix.** Assert `b5-refont` plainly (it passes on this tree); label B5's carve road KNOWN in
the voice/history where it reproduces (Study's full pass) and plain elsewhere, or keep the KNOWN label
but stop counting a structurally expected XPASS as a "re-examine" event (e.g. a per-row
`expected-xpass-in` note). Record whichever in the README's status section.

### MINOR-3 · `Tools/VisualWalk/lib.zsh:346` — the report's `tree:` line names the WORKING TREE's HEAD, not the tree the build under test was built from

**What's wrong.** `vw_report` prints `git -C $REPO rev-parse --short HEAD` and an "App/ has
uncommitted changes" flag computed on the working tree. The build under test is whatever sits at `$DD`
— `--build` is optional (the README's second example omits it), and `VW_DD` points at another tree
entirely.

**Evidence (in the repo's own runs).** The teeth run `vis-walks/2026-09-26/112830/report.md` says
`tree: b11d1cf4` while its build is the scratch worktree (`…/rfull-tree/dd/…`, `4ccfd13c` + the R-full
revert — U-VIS RECORD piece 5). Default path: pull or commit, run without `--build` → the report stamps
the new HEAD over the old binary. Also `-- App` ignores uncommitted `Sources/` (VariorumCore) changes
that the app links.

**Why it matters.** Design decision 6's whole point is *"tree unchanged + suite red = the OS moved"* —
attribution by construction needs the report to name the tree the BINARY came from.

**Pin.** Build `$DD` at commit A, commit any change under `App/`, run `--selftest` without `--build`:
old header says B; fixed header says A (or the run refuses/warns on the mismatch).

**Proposed fix.** At `--build`, write the source commit + a dirty flag over `App/` and `Sources/` into
`$DD.tree` (or bake it into the Debug Info.plist); print THAT in the header, and warn loudly (or
refuse) when it differs from HEAD for the default `$DD`.

### MINOR-4 · `Tools/VisualWalk/lib.zsh:17-21`, `README.md:98-99` — `VW_DD` launches ANY Debug build against the DEV STORE, with no guard for the standing "an old build must NEVER open the dev store" trap

**What's wrong.** ENVIRONMENT TRAPS: *"An old build must NEVER open the dev store — bisect by harness
in a scratch worktree (in-memory store)"* (the 18k C2 precedent). `VW_DD` makes that one environment
variable away: `open -n $APP` launches whatever `$DD` holds, and every Debug build is
`io.lduarte.Variorum.debug`, i.e. the dev store. The README advertises `VW_DD` as the red-proving road
and design decision 6 invites attribution runs — the natural next use is pointing it at an OLDER
tree's build, which is exactly the forbidden act (an older migrator/schema against the current store).

**Evidence.** The teeth run did open the dev store with a scratch build — defensibly within the rule's
intent (the current tree plus one Mac-app revert, identical persistence), but neither the record nor
the harness says why it was safe, and nothing stops the unsafe version.

**Pin.** `VW_DD` pointing at a build from a tree whose `Sources/VariorumCore/Persistence/` differs from
HEAD's: old → launched against the dev store; fixed → refused (exit 5).

**Proposed fix.** When `VW_DD` is set, require the build's recorded source tree (MINOR-3's stamp) to
match HEAD's `Sources/VariorumCore/Persistence/` (and `Migrations.swift` identifiers), else refuse;
carry the trap line in the README next to `VW_DD`; add one line to the U-VIS record saying why the
R-full teeth run was inside the rule.

### MINOR-5 · `Tools/VisualWalk/lib.zsh:38-45`, `visual-walk.sh:100-104` — an abort (or Ctrl-C) mid-pass leaves the DEV STORE's voice switched, which reds KnownIssues row 90's pins on the next Mac suite

**What's wrong.** The voice is a synced dev-store setting the harness flips (the per-pass switch; and
`b5-refont` flips it mid-pass). It is restored only on the happy path (`visual-walk.sh:100-104`;
`scn_b5-refont`'s own tail). `vw_abort` reports, quits the app and exits 4 with no restore and no
mention; there is no `trap` for INT/TERM at all (the dev app is also left running with the probe on).

**Mechanism (traced).** An abort during the Study pass (a guard firing is the designed way runs end
early — MAJOR-1's refusals, the foreign-dialog rule) → the dev store stays Study → KnownIssues row 90:
*"The C2 inline-editor pins go red when the DEV STORE's voice is Study — the test host adopts the dev
store's typography at launch"* → the next full Mac suite shows two spurious reds that nothing links
back to the walk.

**Pin.** A stubbed abort inside the Study pass (the MAJOR-1 rig, `VOICE=study`, `FOUND_VOICE=terminal`)
→ old: exit 4 with no record of the voice left behind; fixed: the abort line (and `report.md`) names
the voice left and the restore owed — or restores it when the author checks pass.

**Proposed fix.** Record `FOUND_VOICE` in the run dir at start; on abort/INT/TERM (a `trap`), quit the
app and write *"dev store voice left at X (found Y) — restore before any Mac suite (KnownIssues
row 90)"* into `aborted` and the report; restore through the GUI only if the author checks pass.

### MINOR-6 · `Tools/VisualWalk/visual-walk.sh:45-47`, `helpers/vis-tcc.swift` — the preconditions check Accessibility + Screen Recording but not the AUTOMATION (Apple Events) grants every act needs — a missing grant mints a consent prompt, this unit's own incident class

**What's wrong.** Every act and every guard sends Apple Events: `System Events` (`vw_activate`,
`vw_keys`, `guard.sh:9`) and the Debug app itself (`vw_quit_app`'s `tell application id
"io.lduarte.Variorum.debug" to quit`, `lib.zsh:79`). Those are the Automation TCC service, separate
from the two `vis-tcc` checks. The unit's own INCIDENT was a stale Automation prompt minted by an
`osascript` (*"Ghostty wants access to control Finder"*), and the new trap says consent dialogs are
the author's alone.

**Mechanism.** A terminal holding AX + Screen Recording but not the Apple Events grant for System
Events (any terminal other than today's Ghostty; `swift test` launched from somewhere else; a reset
TCC database) passes the preconditions → the first `vw_activate` raises *"… wants access to control
System Events"* → an author-only dialog is now on screen, minted by the harness.

**Pin.** Manual only (a terminal without the grant) — stated honestly: no headless failing-on-old test
exists; the fix is a precondition, verified by `vis-tcc`'s new output on this machine.

**Proposed fix.** `vis-tcc` adds `AEDeterminePermissionToAutomateTarget(…, askUserIfNeeded: false)`
for `com.apple.systemevents` (and the Debug app's bundle id) and the driver refuses (exit 5) unless
granted; add it to the README's preconditions and design decision 4's list.

### MINOR-7 · U-VIS RECORD (THE TABLE; the charter's *"Seed it with U0/U0b's three reproductions so each is a standing tripwire"*) — two of the three seeded reproductions have no red-on-old evidence, and U0 item 2's second mechanism is not seeded

**What's wrong.** The can-red proof covers `write-newline-roundtrip` (U0b) and `note-reopen` (U0c)
against the R-full revert (`112830/report.md`: ⌫ first line 298.0 → 274.0, clip 24.0; note-reopen 4
FAIL) — verified. Nothing shows `index-click` / `readedit-click` (U0 item 1) or
`outline-narrow-restore` (U0 item 2) red on the regressions they are labelled as seeded from; the table
states "(U0's regression: PASS)" — green on the new side only. MINOR-1 shows one arm of the item-1
tripwire cannot red on a wrong-text-line landing. Item 2 had TWO mechanisms (U0 RECORD: (a) the
missing width trigger, (b) the unsettled first measure caught by the settle net, reproduced on the
LONG story — *Copper Beeches*, "the story's end BLANK after a resize + scroll"); the scenario walks
the short *About this book* only, i.e. (a).

**Pin.** The proof is the same method the record already used: `VW_DD` runs against scratch builds with
R-U0-1 (item 1), R-U0-2 (item 2a) and R-U0-3 (item 2b) reverted (within MINOR-4's guard).

**Proposed fix.** Run those three teeth runs and record them (or record the tripwires as unproven); add
a long-story narrow→restore arm (or document (b) as in-suite-only: `InlineHeightReportTests`).

### MINOR-8 (SPECULATIVE) · `App/Variorum/Variorum/Core/Views/VisualWalkProbe.swift:222-264` — on the DOCUMENT editor the probe enumerates fragments outside the viewport on every request; "asking does not change what it measures" is asserted there, not measured — and B5's recipe was taken under probing

**What's wrong.** The last-fragment read (`:255-264`) and the caret read (`:222-227`, when the caret is
off screen) run unconditionally for every text view. The header justifies the tail read as *"the
settle net's O(1) last-fragment idiom"* — but the settle net runs it on the INLINE editor, whose whole
document the per-keystroke `.ensuresLayout` measure has just laid out (`EditorView.swift:748-763`,
"only the layout TextKit already holds"). On the full-document Write editor the tail is NOT laid out,
so the probe asks TextKit to vend a far fragment on every probe (~3/s under `vw_settle`). Whether that
perturbs TK2's height estimate — the very state TEXTKIT2_NOTES §2 says *"shifts as you scroll and lay
out more"* and B5's fixed-clip correction rides on — is untested.

**Why it matters (the traced part).** KnownIssues row 88 now carries *"deterministic inside the
harness's full STUDY pass … the recipe IS the full Study pass"* for the U3 trace. The record's no-probe
control was a FRESH-launch Study run — which does not reproduce B5 with or without probes, so it
cannot discriminate; the reproducing condition (the full pass) was only ever observed with hundreds of
probes in it. (U0b saw B5 by eye with no probe, so B5 is real either way; the question is whether the
harness's recipe and its +30-pt magnitude are the probe's.)

**Pin / discriminating measurement.** Re-run the full Study pass with the tail read gated off for the
document editor: B5 still XFAIL ⇒ the recipe is probe-independent (record it); XPASS ⇒ the probe is in
the recipe.

**Proposed fix.** Gate the last-fragment read behind a flag (only `write-newline-roundtrip`, whose
short note is wholly on screen, and `outline-narrow-restore` read `lastGlyph*`), skip the caret
fragment read when the caret is outside the viewport (report `caretState=off`), and add one line to
row 88 that the reproduction was taken under probing until the measurement above says otherwise.

### NITs

- **N1 · `scenarios.zsh:56`** — `first open: caret at the start` (`sel == 0,0`) bakes in U0c's
  PROVISIONAL #150(a) reading (the first open seeds no fact), not R-18l-1's letter ("the remembered
  caret itself survives"). Cite `QUESTIONS #150(a)` in the row's label so a morning ruling for the
  letter-reading updates the assertion instead of redding the run unexplained.
- **N2 · `lib.zsh:124, 280`** — `vw_rect` and `vw_expect_ne` are defined and never used.
- **N3 · `README.md:18, 36`, `Package.swift:10`** — the run time is stated three ways (~20 min, ~25 min;
  the measured full run is 14.2 min, `18l-uvis-wrapper-final.log`); exit 4 is documented as "a guard
  fired", but every `vw_abort` exits 4 (probe timeout, launch failure, a voice that did not switch).
- **N4 · `Package.swift:1, 15`** — `swift-tools-version: 6.0` / `.macOS(.v15)` where the repo's
  standard is 6.2 / macOS 26 (AppSpec §1; `.timeLimit` is the only availability-sensitive API used).
- **N5 · `scenarios.zsh:169`** — `mode-roundtrip` computes its click y from `midY` without the
  `vw_require '[[ -n ${PV[mid]} ]]'` its siblings carry (`:79`, `:136`); an empty `mid` gives y = 0,
  which `guard.sh:16` refuses (exit 7) — then `vw_guarded` retries a deterministic refusal twice and the
  run aborts (4) instead of one precise ERROR. `vw_guarded` should not retry exits 6/7 at all.
- **N6 · `visual-walk.sh:49-56` vs `:59-63`; `:67-77`** — the 10-s author-free check runs BEFORE the
  optional `--build` (minutes), so it is stale by the first launch; and the scenario-name validation
  runs after `RUN_DIR` is created, leaving an empty run folder on a typo.
- **N7 · `VisualWalkProbe.swift`** — no in-suite pin for the env gate (the "GATED TWICE" claim) or for
  the probe's TK2 arithmetic (first visible line, the caret on the trailing newline's extra line
  fragment — TEXTKIT2_NOTES §3 lists that fragment as version-variable, and this harness runs precisely
  after macOS updates). A bare-TK2 in-suite test of `answer(to:)`'s line-level facts would keep the
  oracle honest without pointer injection. (The `nl && caretEnd` assertion is a second line of defence
  for the blank-line case, so this is hardening, not a hole.)
- **N8 (SPECULATIVE) · `helpers/vis-foreign.swift:17`** — "a system dialog" is layers 1…23 only; a
  system prompt drawn above 23 would be invisible to the covered-point rule (the key-window rule still
  protects keystrokes). Consider "any layer ≥ 1 not ours, minus Dock/Window Server/menu bar" with the
  point test.
- **N9 · `README.md:88-89`, record judgment call 8** — residue is understated: besides the carve's empty
  block, `write-divide-merge`'s ⌫ at the seam is a MERGE (AppSpec §9 — a fresh block A′, both sources
  released to lineage), so each pass per voice leaves two released blocks in *A Scandal in Bohemia*'s
  tray and swaps a fixture block's identity; `closeAutoCommit` also appends quiet savepoints to the
  edited notes each run. Harmless to the geometry, but the README should say it.

## CLEAN BILL

- **Release and gating:** the whole probe file (imports included) and the delegate call are inside
  `#if DEBUG`; the observer registers only on `VARIORUM_VISUAL_WALK == "1"` and only once; Xcode Run and
  the test host never see the flag (the scheme passes no such env).
- **The probe writes nothing and registers nothing;** C4's owner-keyed rule is correctly argued N/A (a
  pull endpoint reading the key window + the existing owner-keyed oracles' `.current`). TK2 API only;
  `measure` never reaches the document editor (P1 not in play).
- **Content-free answer:** numbers, fixed words, an 8-char note-id prefix; values carry no spaces
  (`PostMode`/`Face` raw values checked), so the driver's space split is sound — the `;` fix holds.
- **Coordinates:** primary-screen flip for Quartz global; `.global` = the window's y-down space incl.
  titlebar (U0's measured rig fact) — `toScreen` and the pane calibration agree with it.
- **Fail-closed assertions:** a missing probe key yields FAIL (empty → `∅`), ERROR (`vw_require`) or an
  arithmetic miss — never a silent PASS (checked in `vw_expect_near/eq/between`); the comparator
  self-check refuses a run whose comparator cannot red (exit 5).
- **Design-note conformity:** all six decisions built as written; WalkKit consumed in place (brief
  allowed either; the one-guard reason is sound); the wrapper as its own package (the sandboxed test
  host cannot drive `cliclick`/`osascript`) keeps it out of every default suite by construction —
  `.enabled(if:)` on the same flag.
- **Can-red, verified in the artifacts:** `--selftest` exit 1 (`112606-selftest/`, `114902-selftest/`);
  the R-full teeth (`112830/`: `write-newline-roundtrip` ⌫ 298.0 → 274.0, clip 24.0; `note-reopen` 4
  FAIL); the final run (`114921/`: 20 scenario-passes, 0 FAIL / 0 ERROR, XPASS 4) matches THE TABLE.
- **Closing-run claims verified in the logs:** `✔ Test run with 115 tests in 19 suites passed after
  59.217 seconds` + `** TEST SUCCEEDED **` (`18l-uvis-closing1.log`); the wrapper's
  `theHarnessCanRed` / `theSeededWalkPasses` pass lines and timings (`18l-uvis-wrapper-final.log`); no
  warning or error line names `VisualWalkProbe` in either build log.
- **Foreign-dialog + key-before-type rules** implemented as recorded (`vw_no_foreign_at` before every
  point act, `vw_our_window_is_key` before every keystroke, Settings by AXPress); quit by identity only
  when ours is the sole instance, else by pid; `/Applications` never touched.
- **Scope:** zero `Sources/`, `Shared/`, `Sync/`, schema, `Server/` (diff stat); `.gitignore` covers
  `bin/`, `.build/`, `vis-walks/` (`git status --ignored` clean); the plan-file diff is a pure append
  and the `17bed3e2` duplication is repaired (no `##` section appears twice).
- **B5 honesty:** labelled against its owned row, measured numbers carried, trace left with its owner;
  row 88 amended in the orchestrator's acceptance commit.

## ORCHESTRATOR ARBITRATION (same-model ladder — the orchestrator arbitrates; 2026-09-26)

ALL 18 FINDINGS CONFIRMED (0 dismissed). Riders on the fix pass, sent to the implementer and
binding: MAJOR-1 first and exactly as written, INCLUDING the same guard-before-activate fix in
`Tools/WalkKit/click.sh`/`keys.sh` (one guard discipline, both homes), pinned by the headless
stub rig red-on-old; MINOR-8's discriminating re-run REQUIRED with row 88 updated honestly
either way; MINOR-3+4 land together (the report records the BUILT tree; the driver REFUSES a
binary that mismatches HEAD — the old-build trap enforced); MINOR-6's check must not itself
trigger the consent prompt; MINOR-7 seeds item 2(b) and produces teeth for items 1/2; b5-refont
loses the KNOWN label (MINOR-2) so XPASS stops being noise. Round 2 = a FRESH opus-reviewer over
the fix diff; a new BLOCKER/MAJOR there earns round 3 (cap three).
