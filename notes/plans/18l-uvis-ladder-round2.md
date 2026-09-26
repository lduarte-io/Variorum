# 18l U-VIS — ladder ROUND 2 (cold review, `opus-reviewer`, 2026-09-26)

**Diff under review:** the round-1 fix pass, `fbe615fa..a281c554` (17 commits, `84616240` … `a281c554`;
the `notes/` commits are record-keeping). Anchor: `notes/plans/18l-uvis-ladder-round1.md` (round 1's
findings, the orchestrator's arbitration and riders, the implementer's FIX TABLE); the U-VIS DESIGN
NOTE / BRIEF / RECORD / ROUND-1 FIX PASS LIVE STATUS in `notes/plans/phase-18l-navigation-feel.md`.
Prompt: `notes/REVIEW_PROMPT.md`, verbatim. Read-only during the review; this file is the only write.

**STATUS: COMPLETE** — round 1's MAJOR-1, MINOR-1/2/3/4/6/7/8 and N1–N9 VERIFIED-FIXED (MINOR-3/4 and
MINOR-6 each with a residual edge filed below); **MINOR-5 NOT FULLY FIXED** — an abort inside a voice
switch is still unrecorded (MINOR-R2-1). New: **0 BLOCKER · 0 MAJOR · 3 MINOR · 8 NIT** — no round 3
earned by the ladder's rule.

## SEAM CALL

**Still outside Fable's mandatory scope — no re-spawn owed.** The fix diff touches no `Sources/`,
`Server/`, `Shared/`, `Features/` or `Sync/` file (`git diff --stat fbe615fa a281c554 -- Sources Server
App/Variorum/Shared App/Variorum/Variorum/Features` is empty). The one app file is
`Core/Views/VisualWalkProbe.swift`, still `#if DEBUG` whole; its changes only REMOVE reads (the caret's
fragment is enumerated only inside `viewportRange`, `:241-248`; the last fragment only on `last`/`measure`,
`:281-292`), widen `textFacts` from `private` to internal for a test, and add an `isInstalled`/`uninstall()`
pair (`:68-75`) that touches only the probe's own observer token. No storage, selection, frame or oracle
write; no custody/keychain; no default's meaning. The new `VisualWalkProbeTests.swift` is a DEBUG test
on a bare TK2 view.

## ROUND-1 FINDINGS — VERIFICATION

| Round-1 finding | Verdict | What I checked myself |
|---|---|---|
| **MAJOR-1** (activate before the author check; exit 4 retried with re-activation; relaunch + Settings close unguarded; WalkKit the same) | **VERIFIED-FIXED** | `lib.zsh:200-240`: `vw_step` = gap → `vw_author_check` (`guard.sh --author`, any refusal aborts) → `vw_activate` → `vw_guarded` (3/4/6/7 abort; only 5 retries, each retry re-runs the author check BEFORE re-activating, `:227-230`). Every act (`vw_click`/`vw_keys`/`vw_ax_press`/`vw_scroll`/`vw_resize`) enters through `vw_step`; the Settings close is guarded (`:342-344`); `open -n` is preceded by `vw_author_check` (`:80`). `guard.sh --author` exits after the idle check and before any `osascript` (`guard.sh:10-13`). WalkKit `click.sh:6` / `keys.sh:6` run `--author` first. **Ran `pins/guard-order.zsh`: 8/8 PASS on the tree; 8/8 FAIL against `fbe615fa`'s `lib.zsh` (my own scratch copy)** — red-on-old confirmed. |
| **MINOR-1** (the last-line click could land on the wrong TEXT line and only XFAIL) | **VERIFIED-FIXED** (a residual, fixture-dependent gap → NIT-R2-5) | `scenarios.zsh:256-258` adds the plain row `caretLine ∈ [caretTextLines−2, caretTextLines−1]`; the S3 y-row keeps its label. `pins/read-tier-assertions.zsh` 4/4 PASS (ran it). Live teeth `132033/report.md`: `Read▸edit last line: … | 0 | [3, 4]` FAIL — the pre-fix landing reds on exactly this row. |
| **MINOR-2** (`b5-refont` KNOWN though never reproduced; standing XPASS noise) | **VERIFIED-FIXED** | `scenarios.zsh:438` plain; the carve road KNOWN only when `$VOICE == study` (`:414`). Final run `133031/report.md`: **0 XPASS**; Terminal `b5-return-after-cmd-down` PASS plain, Study XFAIL 2. |
| **MINOR-3** (the report named the working tree, not the binary's) | **VERIFIED-FIXED** (see NEW MINOR-R2-2 for the untracked-file blind spot) | `build.sh` stamps `vw_tree_state` before/after the build (refuses if the tree moved during it); `vw_report:445-447` prints the stamp's commit/app/core and the run-time HEAD separately. Seen in real reports: `132033/` names the scratch build, its uncommitted App/ files and "a SCRATCH build (VW_DD)". |
| **MINOR-4** (`VW_DD` could open the dev store with any build) | **VERIFIED-FIXED for committed/tracked differences** (NEW MINOR-R2-2: untracked source files are invisible to the stamp) | `vw_stamp_verdict:138-153` refuses no stamp, a differing core always, a differing App/ unless scratch; `visual-walk.sh:65-66` enforces it before any launch. `pins/build-stamp.zsh` 9/9 PASS (ran it). |
| **MINOR-5** (an abort left the dev-store voice switched, unrecorded; no trap) | **NOT FULLY FIXED** — the common case is fixed; an abort inside a voice switch is still silent (NEW MINOR-R2-1) | `vw_abort:44-54` + `vw_voice_after_abort:56-71`; INT/TERM trapped (`visual-walk.sh:88-89`); the GUI restore runs in a subshell so a nested refusal cannot recurse (`:63`). **Ran `pins/abort-voice.zsh`: 5/5 PASS; 4 FAIL on `fbe615fa`'s lib** — red-on-old confirmed. |
| **MINOR-6** (Automation grants unchecked) | **VERIFIED-FIXED** (NEW MINOR-R2-3: the timeout path's message is unreachable and names the wrong grant) | `vis-tcc.swift`: `AEDeterminePermissionToAutomateTarget(…, false)` — never prompts; `visual-walk.sh:50-53` refuses unless `AE:com.apple.systemevents granted`; the dev app is sent no Apple Event (quit by AX menu, `lib.zsh:110-112`). Every `run.log` since `31a36d36` shows `instances now: 0` and **no** TERM-fallback line (grep over all `vis-walks/2026-09-26/*/run.log`) — the menu quit works as built. |
| **MINOR-7** (two of three seeded reproductions unproven; item 2(b) unseeded) | **VERIFIED-FIXED** | `outline-long-story-settle` seeded (`scenarios.zsh:346-380`), PASS 8/8 on the tree (`131538/`) and in both voices (`133031/`). Teeth read from the reports: R-U0-1 `132033/` (index-click FAIL 6, readedit-click FAIL 2); R-U0-3 `132447/` (−1256.0, last glyph 2227 outside [117, 1117]); R-U0-23 `132822/` (−17 at 1100, −102 at 900, glyph 325 vs 223.5); every scratch build stamped "core `4b9d3b2f7991`" = the tree's (inside MINOR-4's rule). R-U0-2 alone PASS (`132221/`) — recorded honestly as a tripwire limitation (NIT-R2-7 on the citation). |
| **MINOR-8** (the probe read off screen; B5 recipe under probing) | **VERIFIED-FIXED** (NIT-R2-4: the caret-gate half has no in-suite pin) | Probe gating as in the SEAM CALL. The discriminating run `130055/` (build stamped `e9bdb5b8`, which contains `25a9c3c5`): B5 `45591 → 45509`, `298.0 → 302.0` — identical to the pre-gating numbers row 88 carried; KnownIssues row 88 amended accordingly and honestly (the history-dependent magnitude of `133031/` recorded too). |
| N1 | VERIFIED | `scenarios.zsh:56` cites #150(a); `QUESTIONS.md:1932` exists. |
| N2 | VERIFIED | `vw_rect`, `vw_expect_ne` gone. |
| N3 | VERIFIED | one run time (~15 min); exit 4 described as any abort. (Exit 9 is new and undocumented — NIT-R2-8.) |
| N4 | VERIFIED | `swift-tools-version: 6.2`, `.macOS(.v26)`. |
| N5 | VERIFIED | `mode-roundtrip` requires `mid` (`:170`); 6/7 abort unretried (`lib.zsh:224`, pinned by `guard-order.zsh` case 3). |
| N6 | VERIFIED | scenario names validated (`visual-walk.sh:72`) before `RUN_DIR` (`:84`); the author-free wait (`:75-81`) after the build. |
| N7 | VERIFIED (with NIT-R2-4) | `VisualWalkProbeTests` 4/4 (`18l-uvis-f2-pins.log`: `✔ Test run with 4 tests in 1 suite passed`). |
| N8 | VERIFIED | `vis-foreign.swift:20-21`: every layer ≥ 1 not ours, minus Dock / Window Server / Screenshot. |
| N9 | VERIFIED | README residue paragraph. |

## NEW FINDINGS (severity-ranked)

**0 BLOCKER · 0 MAJOR · 3 MINOR · 8 NIT.** Nothing here earns a round 3 on the ladder's rule.

### MINOR-R2-1 · `Tools/VisualWalk/lib.zsh:56-57` (with `vw_set_voice:337-348`) — the abort's voice record reads the last CACHED probe, so an abort that lands INSIDE a voice switch leaves the dev store switched with NO record — MINOR-5's harm, in the author-caused path it exists for

**What's wrong.** `vw_voice_after_abort` decides from `LAST_VOICE`, which only a probe sets (`:168`), and
returns silently when it equals `FOUND_VOICE` (`:57`). In `vw_set_voice`, the last probe before the
switch is `vw_keys "Settings…"`'s `vw_our_window_is_key` (`:286` → `:260`), which reads the OLD voice.
Then `vw_ax_press $1` flips the synced setting (`:340` — the segmented Picker's binding calls
`theme.setVoice` on selection, `AppSettingsView.swift:391-393`), `sleep 1.5`, and the close step's `vw_step`
(`:343`) sleeps 2.6 s and runs `vw_author_check` — the first probe that would see the new voice comes
only after the close (`:346`).

**Mechanism (traced).** Terminal found (`FOUND_VOICE=terminal`). Study pass switch, or `b5-refont`'s
`vw_set_voice study` in the Terminal pass: the probe reads `terminal` → the AX press makes the store
Study → within the next ~4 s she sits down (HID idle < 2) or presses Ctrl-C → `vw_abort "guard: someone
is at the machine …"` (or the INT trap) → `LAST_VOICE == FOUND_VOICE == terminal` → `return 0` → no
"voice left" line, no "RESTORE OWED", the app is quit with the store in Study → the next Mac suite reds
KnownIssues row 90's C2 pins with nothing linking back — exactly what MINOR-5 was confirmed to prevent,
and precisely on the abort cause the fix most expects (her arrival). The window is ~4 s of every switch
(two in the Study pass setup/restore, two per `b5-refont`), i.e. a couple of percent of a run.
**Reproduced headlessly** (the `abort-voice.zsh` rig, a stub `vis-probe` answering `voice=study`,
`FOUND_VOICE=LAST_VOICE=terminal`): `aborted` holds only the ABORTED line — no voice line at all.

**Pin (red-on-current).** Add a case to `pins/abort-voice.zsh`: `FOUND_VOICE=terminal LAST_VOICE=terminal`,
a stub `vis-probe` that answers `voice=study`, reason "guard: someone is at the machine — STOP" → today:
no "voice left" line (FAIL); fixed: "voice left at study (found terminal) — RESTORE OWED".

**Proposed fix.** In `vw_voice_after_abort`, when the app is alive, ask it: one `vw_probe_raw` (a
distributed notification — no input event, safe while she is present; `vw_probe_raw`, not `vw_probe`, so
a timeout cannot nest an abort) refreshes `LAST_VOICE` before the comparison. Belt and braces: set a
`VOICE_IN_FLIGHT=$1` marker in `vw_set_voice` just before the press and clear it after the confirming
probe; an abort that finds it set (and cannot probe) writes "voice possibly left at $1 — RESTORE OWED".

### MINOR-R2-2 · `Tools/VisualWalk/lib.zsh:127-135` (`vw_tree_state`) — the build stamp is blind to UNTRACKED source files, so a scratch build carrying a new core file passes the "core must be the tree's" refusal, and the report names a tree the binary did not come from

**What's wrong.** The stamp hashes `HEAD:App` / `HEAD:Sources` + manifests plus `git diff HEAD` over
them. `git diff HEAD` never shows untracked files. Both build systems compile untracked files:
SwiftPM compiles every `.swift` under `Sources/VariorumCore/`, and the app project uses file-system
synchronized groups (`PBXFileSystemSynchronizedRootGroup` × 9 in `project.pbxproj`), so an untracked
`.swift` under `App/Variorum/Variorum/` is compiled too.

**Mechanism (reproduced).** A throwaway repo shaped like the pin's: stamp it, then create untracked
`Sources/VariorumCore/Persistence/Migration99.swift` and `App/NewView.swift` → `vw_tree_state` prints the
IDENTICAL line (`app=4509da3bea13 core=0d55549fe5c0 dirty=`) and `vw_stamp_verdict "$after" "$before" 0`
returns 0 ("launchable as the tree's own"). So (a) the MINOR-4 rider's enforcement ("an old or foreign
core must never open the dev store") has a hole: a `VW_DD` teeth worktree where a file was recreated
with `git show old:path > path` (a natural way to revert a fix that deleted a file) or a scratch helper
added under `Sources/` opens the DEV STORE with a core the stamp calls the tree's; (b) MINOR-3's header
says "compiled from X" with no "+ uncommitted" note while the binary contains code X lacks.

**Pin (red-on-current).** `pins/build-stamp.zsh`: after `s1`, create an untracked file under
`Sources/VariorumCore/` → `s_untracked=$(vw_tree_state $T)`; check `! verdict "$s_untracked" "$s1" 1`
(today: launched — FAIL) and that its `dirty` names the file.

**Proposed fix.** Fold untracked, non-ignored files into both hashes and the dirty list:
`git -C $t ls-files --others --exclude-standard -z -- <paths> | xargs -0 shasum` (names + content)
appended to the `app` / `core` inputs, and `ls-files --others --exclude-standard` names into `dirty`.
README's stamp paragraph: "committed tree plus any uncommitted diff **or untracked file**".

### MINOR-R2-3 · `Tools/VisualWalk/visual-walk.sh:51-53` + `helpers/vis-tcc.swift` — when the Automation check TIMES OUT (the pending-prompt case the fix was written for), the refusal blames Accessibility / Screen Recording; the "timed out — a consent prompt pending?" text is unreachable

**What's wrong.** `vis-tcc` prints its `AX … SCREEN …` line with Swift `print`, which is fully buffered
when stdout is a pipe (`$(…)`); `vw_timeout` kills it with SIGALRM, which does not flush. So on a
timeout `tcc` is EMPTY, `:52` fails first and refuses "this terminal lacks Accessibility / Screen
Recording () — granting is the author's", and `:53`'s `${…[2]:-the check timed out — a consent prompt
pending?}` branch can never be reached (it needs line 1 present and line 2 absent).

**Mechanism (reproduced).** A compiled Swift binary doing `print("AX 1 SCREEN 1"); sleep(30)` run as
`out=$(perl -e 'alarm shift; exec @ARGV' 2 ./blk)` → `rc=142 out=[]`. With a System Events consent
prompt pending (the implementer measured that such a check BLOCKS — with Finder), the harness tells the
author to re-grant two permissions she already holds, and never names the dialog waiting for her —
the one thing the new check exists to surface. Safe outcome (it refuses, exit 5), wrong diagnosis.

**Pin (red-on-current).** Headless: point `VW_BIN/vis-tcc` at a stub that prints line 1 then sleeps past
the limit (shorten the limit through an env var) and assert the refusal text names the timeout.

**Proposed fix.** `setvbuf(stdout, nil, _IOLBF, 0)` (or `fflush(stdout)` after each line) in `vis-tcc`,
AND test `vw_timeout`'s status (`142` = SIGALRM) explicitly before parsing, refusing with "the
Automation check timed out — a consent prompt may be pending (the author's to answer)".

### NITs

- **NIT-R2-4 · `App/Variorum/VariorumTests/VisualWalkProbeTests.swift`** — three soft spots in the N7
  pins: (a) `:30` `#expect(!isInstalled, "the test host was not launched by the harness")` runs right
  after `uninstall()`, so it is true by construction — read `isInstalled` BEFORE the uninstall if the
  host's launch state is the claim; (b) `:97-99` "that empty line is BELOW the text's lines" compares
  against the FIRST line's bottom ("alpha one", caret 9), so an extra line fragment laid at the last
  text line's y would still pass — compare against the caret at 18 ("beta two") instead; (c) MINOR-8's
  CARET gate (`caretState=off` outside `viewportRange`, `VisualWalkProbe.swift:241-248`) has no in-suite
  pin, only the last-fragment half does — a tall text with the caret below the viewport asserting
  `caretState == "off"` and no `caretLine` is red on `fbe615fa`'s probe.
- **NIT-R2-5 · `scenarios.zsh:256-258`** — MINOR-1's plain row is FRAGMENT-relative (`caretTextLines`
  is the caret's paragraph, not the block). On a multi-paragraph target block whose FIRST paragraph has
  ≤ 2 lines, the pre-fix Read ▸ edit landing (line 0 of paragraph 1) satisfies `∈ [last−1, last]`.
  Today's targets are single paragraphs (the `132033/` teeth target was one 101-pt, 5-line paragraph —
  and it red), so this is fixture-dependent. Cheap closure: the probe emits whether the caret's fragment
  is the text view's LAST fragment (a pane holds one block and is on screen), asserted plain.
- **NIT-R2-6 · `lib.zsh:110-114`** (implementer's flagged spot) — the quit matches the literal
  "Quit Variorum Dev". Measured sound today: `INFOPLIST_KEY_CFBundleDisplayName = "Variorum Dev"`
  (`project.pbxproj:622`) and not one TERM-fallback line in any `run.log` since `31a36d36`. But the
  osascript error is discarded and the fallback line lands only in `run.log` — the report never says the
  ordinary quit path was skipped, and the app has no SIGTERM handler (grep), so a renamed item would
  silently TERM every run (no `applicationShouldTerminate` flush, no `closeAutoCommit`). Match
  `first menu item … whose name starts with "Quit "` and write the fallback into `report.md`.
- **NIT-R2-7 · the fix table (MINOR-7 row), LIVE STATUS F7, README** (implementer's flagged spot) — the
  measured fact itself is sound and honestly carried (`132221/`: a stamped scratch build differing only
  in `EditorView.swift`, both item-2 scenarios 8/8 PASS), and the consequence — `outline-narrow-restore`
  reds on the symptom (R-U0-23), not on R-U0-2 alone — is the right shape for a visual tripwire. But the
  citation "U0's own record: the two fixes ship together" is the CONVERSE of what U0 recorded
  (`phase-18l-navigation-feel.md:848-850`: the width hop ALONE measured worse until the net landed). The
  harness has found something new: in the app, the settle net alone heals the short note's narrow →
  restore. Hand that fact to U0's owner (does `InlineEditorWidthReflowTests` still red under R-U0-2 alone
  on today's tree, or was its red measured before the net existed?) rather than filing it under U0's
  words.
- **NIT-R2-8 · exit paths (`lib.zsh:45`, `visual-walk.sh:88-89`)** — the nested-abort `exit 9` is not in
  the documented exit table (README / the driver header: 0/1/4/5), and it skips `vw_quit_app` (a second
  Ctrl-C during the first abort's up-to-15-s quit wait leaves the app to finish quitting on its own —
  the menu quit was already sent, so the harm is small); SIGHUP (closing the terminal mid-run) is not
  trapped, so it leaves the app running and the voice unrecorded. Document 9; trap HUP like TERM.
- **NIT-R2-9 · `scenarios.zsh:204-205`** (implementer's flagged spot) — the stale-frame rule is sound
  and fail-closed: a ghost that overlaps a live row drops both; a ghost overlapping nothing is caught by
  the new post-click `vw_require` (pane top within 12 pt of the frame, `:235`/`:242`) as a harness
  ERROR (red), never a PASS; a surviving candidate set < 2 is an ERROR too. Two small edges: the
  self-skip compares by VALUE (`[[ $o == $r ]]`), so a ghost byte-identical to a live row is treated as
  "itself" and both survive — compare by index; and the probe caps the list at 40 frames sorted top-down
  (`VisualWalkProbe.swift:415`), so with ghosts accumulating the band's lower rows can be cut off (again
  caught by the require, as an ERROR — worth a line in the README's rule).
- **NIT-R2-10 · `scenarios.zsh:386`** — `b5-return-after-cmd-down`'s `vw_def` expectation text (printed
  under the scenario in every report) still reads "XFAIL when it moves, XPASS when it does not" for both
  voices; the code (and the README) now assert it plain in Terminal. One clause: "(Study; plain in
  Terminal)".
- **NIT-R2-11 · `Tests/VisualWalkTests/VisualWalkTests.swift:30-37`** — the always-on pins are discovered
  by listing `pins/`; if the folder moved or emptied, the parameterized test would run zero cases and
  pass. Add a plain `#expect(!pins.isEmpty)` test. Also unpinned: the lost-focus (exit 5) retry path —
  `guard-order.zsh` has no rc-5 case proving the author check precedes EACH re-activation (`:227-230`
  are right as written; the pin would keep them so).

## THE THREE FLAGGED SPOTS (the implementer's own)

1. **The stale-frame no-overlap rule** — sound and fail-closed (NIT-R2-9 for two edges); the fixture
   switch to *The Red-Headed League* (first-opened in the pass) removes the landing-scroll ghost source,
   and `readedit-click` in `133031/` passes every plain row in both voices.
2. **The "Quit Variorum Dev" menu dependence** — correct against the Debug display name and measured
   working in every run; the silent-fallback visibility is NIT-R2-6.
3. **"The settle net covers R-U0-2"** — a real, stamped measurement; the tripwire's scope is honestly
   stated; the citation is inverted (NIT-R2-7), and the fact deserves a pointer to U0's owner.

## CLEAN BILL

- **MAJOR-1 closed as written, including the rider:** every GUI act enters `vw_step`; the author checks
  run before the activation and again inside the target guard; exit 3/4 never retried; exit 6/7 never
  retried; the relaunch and the Settings close guarded; WalkKit `click.sh`/`keys.sh` reordered and the
  README's ORDER section added. `pins/guard-order.zsh` red-on-old reproduced by me (8/8 FAIL on
  `fbe615fa`'s `lib.zsh`, 8/8 PASS on the tree).
- **The abort path cannot recurse or act on her presence:** the GUI restore runs in a subshell (a
  refusal inside it exits 9 there), is skipped when her app / her input / Ctrl-C caused the abort, runs
  the author checks first, and presses no key and clicks no point (Settings by AX menu, AXPress, AX
  close). `pins/abort-voice.zsh` red-on-old reproduced (4 FAIL on the old lib).
- **The stamp's verdict logic** (outside the untracked-file hole): a differing core always refuses; a
  differing App/ refuses unless `VW_DD`; `--build` refuses `VW_DD`; `build.sh` refuses to stamp a tree
  that moved during the build; every teeth report carries core `4b9d3b2f7991` = the tree's, so all four
  teeth runs were inside the old-build trap. `pins/build-stamp.zsh` 9/9 (ran it).
- **The Automation check never prompts** (`askUserIfNeeded: false`); the dev app receives no Apple Event
  from the harness; `open -g -b com.apple.systemevents` launches without an event.
- **MINOR-8's discriminating run is genuinely discriminating:** after the gate, every probe of the long
  Write documents is flagless (nothing read off screen); `last` is asked only on *About this book*
  (wholly on screen) and on the inline editors, `measure` only on the inline editor; B5's numbers in `130055/` equal the pre-gate numbers
  exactly; row 88 now says so and carries the history-dependent magnitude of `133031/`.
- **The teeth are real and recorded with numbers** that match the reports line for line (`132033/`,
  `132221/`, `132447/`, `132822/`); the final run `133031/` is 0 FAIL · 0 ERROR · 0 XPASS with XFAIL =
  S3 ×4 + B5 in Study, as the fix table says.
- **Closing claims verified in the logs:** `18l-uvis-wrapper-r1fix.log` (`✔ Test "every headless pin
  holds" with 4 test cases passed`, `theHarnessCanRed()` and `theSeededWalkPasses()` passed, `3 tests in
  2 suites passed after 1020.181 seconds`); `18l-uvis-closing2.log` (`119 tests in 20 suites passed`,
  `** TEST SUCCEEDED **`, `VisualWalkProbeTests` among the `-only-testing` suites);
  `18l-uvis-f2-pins.log` (4/4). The headless pins run concurrently with the GUI tests in the wrapper and
  touch nothing on screen.
- **Scope:** zero `Sources/`, `Shared/`, `Features/`, `Sync/`, schema, `Server/`; the app-side change is
  DEBUG, read-only and narrower than round 1's; KnownIssues row 88 is the only KnownIssues edit and it is
  honest; the plan-file edit is a pure insert (the ROUND-1 FIX PASS section).

## ROUND-2 FIX TABLE (implementer, `opus-implementer`, 2026-09-26 — the orchestrator's bounded final pass)

| Finding | Commit(s) | Evidence / disposition |
|---|---|---|
| **MINOR-R2-1** — an abort inside a voice switch read the cached voice and recorded nothing | pin `28e45f49` · fix `ce0bbe12` | The reviewer's case in `pins/abort-voice.zsh` (store Study, cache Terminal, "someone is at the machine") — **RED on the current lib** (only the ABORTED line) → GREEN: the abort ASKS the app once (`vw_probe_raw` — a notification, no input event, no nested abort) before comparing; `vw_set_voice` marks a switch in flight from the press to its confirming probe, and an abort that cannot ask names the POSSIBLE voice ("possibly left at study … RESTORE OWED" — a second new case). `abort-voice.zsh` 7/7 |
| **MINOR-R2-2** — untracked sources invisible to the stamp | pin `60bb6ddd` · fix `01f77bba` | `pins/build-stamp.zsh` + 5 cases in the reviewer's scratch-repo shape (an untracked `Migration99.swift` under Sources/, an untracked `App/NewView.swift`) — **5 RED on the current lib** → GREEN: untracked, non-ignored files under App/ and the core join both hashes (names AND contents — a content change moves the hash) and the dirty list; a scratch build carrying one is refused. 14/14. README line |
| **MINOR-R2-3** — a timed-out Automation check blamed Accessibility / Screen Recording | `e9d16ae3` · `1bda2b27` · `715bd642` | Reproduced first: the OLD inline logic on a compiled buffered helper that blocks → `REFUSES: this terminal lacks Accessibility / Screen Recording ()`. Fix: `vis-tcc` line-buffers (`setvbuf(stdout, nil, _IOLBF, 0)`); `vw_grants_verdict` decides the TIMEOUT first from the exit status (142) — "timed out … a consent prompt may be pending (the author's to answer)", with the first line it had answered. `pins/grants-verdict.zsh` 6/6 (compiled Swift stubs: buffered and line-buffered hangs, granted, no AX, denied). **Machinery honesty:** `e9d16ae3` and `1bda2b27` each claimed 6/6 with one case still red (a one-line answer indexed as characters — zsh `(f)` on a scalar); `715bd642` fixed it with a real array and was verified BEFORE its commit |
| NIT-R2-4 — three soft pin spots | `d019f170` | (a) the host's launch state read BEFORE any uninstall; (b) the extra line fragment compared with the caret on the LAST text line ("beta two", 18); (c) MINOR-8's caret half pinned — a caret 200 lines below a 300-pt viewport → `caretState=off`, no line facts (the pre-gate probe read it unconditionally). `VisualWalkProbeTests` 5/5 |
| NIT-R2-5 — the last-line row was paragraph-relative | `d019f170` | the probe emits `caretFragFirst` / `caretFragLast` (two location compares, no read); the read-tier arms assert the block's FIRST / LAST paragraph plainly; `pins/read-tier-assertions.zsh` gains the reviewer's multi-paragraph shape (line 0 of a 2-line first paragraph) — RED. 5/5 |
| NIT-R2-6 — the literal quit item; the TERM fallback only in run.log | `d019f170` | the quit clicks the app menu's first item whose name starts with "Quit " (measured on a real instance: "Quit Variorum Dev", clean quit); a fallback TERM writes `quit-fallback`, which the report prints |
| NIT-R2-7 — the U0 citation for "R-U0-2 alone is healed" is inverted | — | **ROUTED to the orchestrator** (their pen, as instructed: U0's record and the pointer to U0's owner). Not touched here |
| NIT-R2-8 — exit 9 undocumented; SIGHUP untrapped | `d019f170` | exit 9 in the driver header and README ("a second abort inside the first's clean-up"); HUP trapped like TERM |
| NIT-R2-9 — the by-value self-skip; the 40-frame cap | `d019f170` | RECORDED as README lines (both fail-closed: the post-click place check turns either into a harness ERROR, never a PASS), per the orchestrator |
| NIT-R2-10 — b5's stale description | `d019f170` | "XFAIL when it moves, XPASS when it does not (Study; plain in Terminal)" |
| NIT-R2-11 — zero-pins; the exit-5 retry unpinned | `d019f170` | `thePinsAreFound()` (≥ 5 pins); `guard-order.zsh` case 5: a lost focus (5) → the author check BEFORE each re-activation, then the click — 9/9 |

**Closing evidence:** every headless pin green (abort-voice 7/7 · build-stamp 14/14 · grants-verdict 6/6 · guard-order 9/9 · read-tier-assertions 5/5; the package's always-on suite `✔ Test run with 4 tests in 2 suites passed`); the app suites the diff reaches on the rebuilt, stamped build (`d019f170`): `✔ Test run with 120 tests in 20 suites passed after 58.047 seconds`, `** TEST SUCCEEDED **`, 0 skipped (`App/Variorum/DerivedData/18l-uvis-closing3.log`); **the wrapper run — PENDING** (`18l-uvis-wrapper-r2fix.log`).
