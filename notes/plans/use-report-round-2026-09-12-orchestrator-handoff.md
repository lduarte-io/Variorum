# The 2026-09-12 use-report round — ORCHESTRATOR HANDOFF (first written 2026-09-12 ~06:00 by the Fable orchestrator for a compaction; REWRITTEN 2026-09-13 at the CUTOVER to a SUCCESSOR SESSION at her word — "you're at 600k and given that 18i, 18g, and 18j still remain it would be best to do that in a new session")

*This file is the orchestrator's transcript-proof state. It serves THREE readers: (1) the SAME session after a
context compaction (read it first, then LIVE STATUS in the plan); (2) a SUCCESSOR orchestrator if this session
dies (§0 is paste-ready); (3) the AUTHOR in the morning (§5 — what is hers). The ONE record of the round is
`notes/plans/use-report-round-2026-09-12.md`; this file never contradicts it — when the plan's LIVE STATUS is
newer than §2 below, the plan wins.*

## 0. KICKOFF FOR THE SAME SESSION AFTER A COMPACTION (rewritten 2026-09-13 evening by the successor orchestrator at ~490k context, at her word: "I can also run a compaction now, if you prepare a document for yourself") — a successor session uses it unchanged

> You are the successor orchestrator of the 2026-09-12 use-report round (Fable, `/architect-phase use-report round 2 (2026-09-12) — the SECOND SESSION`), continuing after a COMPACTION. **17p, 18h and 17q are CLOSED; 18i is BUILT and in its ladder (round 1, `opus-reviewer`, running when this was written).** You finish the round UNATTENDED at her R-Q24: the 18i ladder → 18g (R-6) → 18j (R-7) → the round-end Fable pass over 18h + 18i → the closeout → the author handoff → the install refresh at a zero-instance window only. Work in `~/dev/variorum` on `main`.
> **READ, YOURSELF, IN THIS ORDER:** this file whole (§2 the state as written at the compaction; §3 the refresh recipe; §4 the close's obligations; §5 her items so far; §6 machinery lessons, all three lists) · `notes/plans/use-report-round-2026-09-12.md` — LIVE STATUS (wins over §2 if newer), §7 (her rulings R-Q1…R-Q24, SETTLED), §12 (the review foci), §8–§9, R-0, and the Records from `### R-5 · 18i — BRIEF` on: the R-5 RECORD, the R-5 ADJUDICATION (J24–J28), and whatever `### 18i LADDER — …` sections exist — read the LAST one to see where the ladder stands; the R-6 and R-7 texts in `notes/plans/use-report-2026-09-12-briefs/` (append each VERBATIM at the previous letter's close with a pointer note re-grepped against the then-current tree; the R-5 append at `fe54be0f` is the shape); `notes/plans/use-report-2026-09-12-mockups/palettes.html` before 18g · CLAUDE.md and the canon it loads · `notes/plans/phase-17-standing-fixes.md`'s rules · `notes/SessionResiliencyProtocol.md` · `notes/KnownIssuesAndTechDebt.md` · `.claude/agents/*.md` · `notes/REVIEW_PROMPT.md`.
> **VERIFY, NEVER TRUST:** `git log --oneline -12`, `git status -sb`, `git diff --stat`, `pgrep -fl 'Variorum.app/Contents/MacOS'` (she is ASLEEP; an instance at `/Applications` is hers — NEVER quit/kill it; walks on `io.lduarte.Variorum.debug`; the refresh only at a zero-instance window), `pgrep -fl caffeinate` (if none: `caffeinate -dims` detached), **`ListAgents`** — the agents of this session are NAMED: "17q implementer on R-8" (finished), "18i implementer on R-5" (finished — and after the compaction NOT REACHABLE by `SendMessage`; the ladder runs on a fresh `opus-implementer` CONTINUATION "18i implementer continuation: ladder responses", briefed from the record — reach THAT one by name; if it too is unreachable, spawn another continuation), "18i ladder round 1 cold review" (the `opus-reviewer`; if `ListAgents` shows it running, WAIT for its notification — never spawn a twin; if finished, its findings section is at the end of the plan, uncommitted or committed — check `git status`).
> **THE 18i LADDER FLOW (same-model, Opus):** on the round-1 report → commit its findings section if uncommitted (pathspec-limited) → `SendMessage` the 18i implementer: agree/dispute per finding, repo-first (`### 18i LADDER — ROUND 1 · THE IMPLEMENTER'S RESPONSES`) → YOU arbitrate against the spec (the orchestrator's dispositions section, J29 onward) → the implementer FIXES the confirmed findings with pins, commits per fix, pushes → round 2 with a FRESH `opus-reviewer` (anchor: the recorded findings + dispositions) → a new BLOCKER/MAJOR in round 2 ⇒ round 3 (the cap); residue to KnownIssues with an owner → the 18i LETTER CLOSEOUT (the R-5 record's "what the letter's close owes": AppSpec §7's `receipt_style` comment line, §12's chrome sentence with #106 RULED (a) by R-Q23, a MobileSoul parity row; the master plan's 18i entry) → append R-6 → spawn the 18g implementer.
> **THEN:** 18g (`opus-implementer` on R-6; `fable-reviewer` ladder, cross-model flow: the implementer responds, the reviewer decides AND fixes, the implementer sanity-passes; the reviewer's brief is the R-8 ladder's shape — pointers only, zero framing) → its close (AppSpec §7 seeds `theme_palette` · `theme_tint` · `theme_accent_tint`; §12's two-voice paragraph gains the palettes; PL-22 confirmed by construction) → append R-7 (re-grep: 18g rewrote the resolver; the Read tier's file is not at `ReadTier/ReadPostView.swift` — find it) → 18j (`opus-implementer`; `fable-reviewer` ladder) → its close (§12 the appearance choice and the presets' dark rule; the master plan's 13u4 row loses item 6) → the ROUND-END FABLE PASS (ONE `fable-reviewer` over the combined final diffs of 18h + 18i, cross-model flow, cap 3; round 2 owed if round 1 fixes anything MAJOR) → the closeout (§4) → the author handoff `notes/handoffs/use-report-round-2026-09-12-handoff.md` with HER CHECKLIST at the top and J14–Jn assembled → the install refresh (§3) only if `pgrep` is empty.
> **ONE agent at a time. Never edit the plan while an implementer holds the tree. Repo-first records. Push every commit. No trailers. Suite TYPE names (`grep -rl "struct <Name>"` each) in a zsh array. PROVISIONAL-and-continue; she is ASLEEP — the question tool is NOT used; bundle for the handoff. Keep THIS file's §2 current at every letter's close (the next compaction reads it).**

## 1. WHAT THE ROUND IS (one paragraph — the plan's §0 is the full one)

Her 2026-09-12 report: the Takes page "opening at the bottom" and "a mess" (ONE defect — the last round's
entry landing anchored to the top + the typewriter room), the empty block's placeholder under the caret,
the tray's missing Delete Now on block rows, the Callout Emoji alert's collapsed field, the comment badge and
callout emoji over the text in the book Outline, the confirmation toasts, created/edited times, the Library
sortable by time, an "edited on a day" search, colour palettes — and, added at the sitting, six two-tone and
five bold palette builds, dark mode pulled forward from 13u4. Five letters: **17p** defects (batches a, b;
the phone's row left for a mobile session) · **18h** time (batches 1, 2) · **18i** confirmations · **18g**
palettes · **18j** dark mode. Order 17p → 18h → 18i → 18g → 18j.

## 2. STATE AT THE COMPACTION (2026-09-13 evening, written at `ed827eaf`; the plan's LIVE STATUS supersedes this the moment it is newer)

- **Tree:** `main` == `origin/main` at `ed827eaf` (notes-only since the last code commit `e6f048e7`), clean. Marker **8**. Zero `Sync/`, zero schema this session.
- **17q — CLOSED (`fe54be0f`, 2026-09-13):** her two morning builds + the 18h cap's residue, all FIXED with pins; the Fable ladder ran to the cap (round 1: 2 MAJOR · 2 MINOR · 4 NIT + two new mechanisms W-1/W-2 from the reviewer's re-walk — the Takes restore had NEVER run in the app before 17q; round 2: 3 MAJOR · 3 NIT; round 3: 1 MAJOR · 1 NIT; nineteen fix commits; every sanity pass CLEAR or its raise upheld); the last code tree of the entry `03dd8a7d`; the ENTRY CLOSEOUT in the plan and copied into the 17 file (register CLOSED); canon applied (AppSpec §12 ×2; KnownIssues: the 17q-owned row removed, row 54 amended with the residue — owner 13u2, one new 13u2 row; PL-22's note). J14–J23.
- **18i — BUILT (`b1a74b3d..e6f048e7`, fourteen commits, thirty-four files), adjudicated (J24–J28, `ecf668fe`), in its LADDER:** `ReceiptStyle` toast · quiet · off (quiet by default, applied at read, no seed); `StatusCenter.Kind` inferred at `speak` (105 sites byte-unchanged), `receipt(_:)`, the `quietLine` slot, ONE routing rule; 45 receipt sites classified at the door (`runStructural`'s outcome note the load-bearing one; four view models' `outgoingKind` shadow — flagged to the ladder at J25); `QuietReceiptLine` composed by three bars; Settings ▸ Appearance ▸ Confirmations; walked (eleven captures `…-screens/18i/`); the FULL Mac suite 2577/432 green, core 1546/167, iOS green. **Round 1 (`opus-reviewer`) was RUNNING at the compaction** — its section `### 18i LADDER — ROUND 1 FINDINGS (opus-reviewer)` lands at the end of the plan.
- **Her rulings this session (§7):** R-Q21 (17q: "the same block" = the current block unchanged), R-Q22 (#105 keep as built), R-Q23 (#106 quiet means quiet), R-Q24 (the overnight run — unattended to the close; the refresh only at a zero-instance window).
- **NOT STARTED:** 18g (R-6 in the briefs folder — append), 18j (R-7 — append), the round-end Fable pass, the closeout, the author handoff, the install refresh.
- **Scratchpad (NOT durable):** `r6-append.md` / `r7-append.md` (the briefs with a `---` rule prepended — regenerate from the briefs folder if lost); `appspec-17q-deltas.txt` (already applied).
- **Machinery:** `caffeinate -dims` was running from the first session (verify); her app was NOT running at the compaction; the dev store carries two walk fixtures (a renamed long-title note; an eight-block "2026-09-13") — harmless, left.

## 3. THE INSTALL REFRESH RECIPE (the last act; only after the round-end pass and the closeout; zero instances)

`pgrep -fl 'Variorum.app/Contents/MacOS'` must be empty — she is awake and may be using her real app, so the window is HERS to grant (ask; never quit it). **A1 backup FIRST:** copy the whole container store
folder (the encrypted `variorum.sqlite` + shm/wal, the key files, `Backups/`) to
`~/dev/variorum-store-backups/use-report-2-refresh-<UTC stamp>/` with the app closed; `cmp` the sqlite and wal
byte-identical; verify the header is NOT `SQLite format 3` (ciphertext) — NO headless `integrity_check`
(SQLCipher; the key is in her Keychain custody; the app's own backups run it). Then build Release in a CLEAN
worktree (`git worktree add ~/dev/variorum-final <final hash>`; `xcodebuild -scheme Variorum -configuration
Release build` with its own DerivedData), copy the product to `/Applications/Variorum.app`,
*[removed for publication]*
keychain access groups unchanged (`codesign -d --entitlements -`), record the binary hashes before/after,
remove the worktree and its DerivedData. The precedent with every command: the last round's LIVE STATUS
(`notes/plans/use-report-round-2026-09-06.md`, the finish's entry) and its handoff item 1.

## 4. OBLIGATIONS AT CLOSE (the plan's §10 + CLAUDE.md's ritual — nothing here is optional)

Every ledger row dispositioned · every ladder complete or capped with residue owned · the round-end Fable pass
(both rounds if round 1 fixes anything MAJOR) · the FULL Mac suite over the final tree + core + the iOS build
· the canon deltas exactly as ruled (AppSpec §7's `setting` seeds — `receipt_style`, `theme_palette`,
`theme_tint`/`theme_accent_tint`; §12 — the palettes, the appearance choice, the stamps and sort, the takes
line's R103 face supersession; §14's delta paragraph, the outgoing one rolled to the archive) · QUESTIONS'
ratify list (#102+) · KnownIssues rows for anything deferred, owned · 17p's dispositions copied into the
standing-fixes file and its register row closed · the master plan: the pointer back to 13u1, row 3d ✔, the
Phase 18 row, the closeout-log paragraph (the previous one rolled to `PhaseCloseoutArchive.md`) · the MOBILE
PARITY LINE PL-22 confirmed (palettes/appearance by construction? the phone must compile) · the author
handoff `notes/handoffs/use-report-round-2026-09-12-handoff.md` with HER CHECKLIST AT THE TOP · the install
refresh (§3) · the briefs folder deleted at the finish (its content lives in the plan's Records) · memory
updated · push.

## 5. FOR HER (the bundle so far; the author handoff at the close carries the final list)

- **Ruled this session (the question tool, while she was up):** R-Q21 · R-Q22 · R-Q23 · R-Q24.
- **Judgment calls to assemble in the handoff:** J14–J28 so far (17q: J14–J23; 18i: J24–J28) — the handoff lists each in one line with its section pointer; J29 onward from the 18i ladder, 18g, 18j, the round-end pass.
- **PROVISIONALs to ratify:** QUESTIONS #103's three calls (the pair beside the title; the edit stamp as the second under `date`; a no-day note showing its edit stamp); 18g's and 18j's as they arrive (#107+).
- **Her walk on the refreshed build:** the plain Takes round trip on a long note (17q); the Notes cards' two facts; the confirmations setting cycled (18i); the palettes and the appearance choice (18g/18j).
- **Recorded, not asked:** KnownIssues row 54's residue (13u2 — the `TakesArticleScroll` extraction now owed three times; the post-hold relayout; the budget decay; the page-tall shape unwalked); the 13u2 row for the `FlippingStamp` hoist + two DEBUG-oracle edges; the `ANALYZE` row (12); the mobile parity items (PL-22; a phone quiet slot).

## 6. MACHINERY LESSONS THIS SESSION (so a successor does not relearn them)

- One commit's message over-claimed edits whose script had stopped at a stale anchor (`88211346`); the next
  commit said so and landed them. Rule: `assert old in s` BEFORE the commit command runs, and never chain a
  commit onto a script that can fail silently.
- The mockup is a LOCAL HTML file, never an Artifact (her standing rule); `open <path>` puts it in front of
  her; say the path in the reply.
- Her app was RUNNING during the sitting (a real-store instance at `/Applications`); it is QUIT now. Walks
  are on `io.lduarte.Variorum.debug` regardless.
- The scratchpad is not durable (the resiliency protocol's addendum 11) — the briefs moved into
  `notes/plans/use-report-2026-09-12-briefs/` for that reason; anything else worth keeping goes in the repo.

### The second list (2026-09-13 — the first session's items above stand)

- **A pin whose second pass is hand-fed is green for the wrong reason** (17p a's three-block pin; 17p b's nine lane pins): drive the second pass through the surface's own report, or the walk finds it.
- **A measurement must execute the arm it measures** (18h's J11): a fixture where every row satisfies the cheap arm never reaches the expensive one; contrast the empty case.
- **`-only-testing` takes suite TYPE names**; a file name matches nothing and `xcodebuild` runs the rest silently — read the `Test run with N tests in M suites` line every time.
- **zsh does not word-split an unquoted `$var`** — put `-only-testing` arguments in an array.
- **Two heredocs on one shell line** fed a python script to `git commit -F -` (`5f9a3a89`): never chain a commit onto a script on the same line; the message is a separate, checked step.
- **A same-model ladder with two batches**: route findings to each batch's implementer, arbitrate once, fix in batch order (the shared file's latest hand first), then round 2 fresh.
- **Her presence changes the rule:** parked PROVISIONALs become question-tool batches (≤4, recommended first); record her words verbatim the same turn.

### The third list (2026-09-13, the successor session — the two lists above stand)

- **A brief's closing set names suite TYPES, never files** — `grep -rl "struct <Name>"` every name BEFORE writing it into a brief (the round met this three times; `CommandRoutingTests.swift` holds `CommandRouterTests` + `MoveAndExecuteTests` + `StatusCenterTests`; the ten tutorial types live in `TutorialWalkTests.swift`).
- **A mounted harness cannot reproduce the app's mount order** when its `.onAppear` runs before the first non-zero geometry (the 17q ladder's W-1: a green pin, a wrong app) — the landing family's acceptance evidence is USE, walked on MORE THAN ONE note shape (short, long, a long paragraph at the fold, a bloomed fan).
- **A reviewer's mandatory re-walk finds what the read cannot** (W-1, W-2, R2-2's shape, R3-1's drift were all found by walking) — every Fable fix pass on a landing-family diff walks the real 262-block note.
- **"No integer-pixel shift matches" is a FRACTIONAL move's signature, not a rendering difference** (17q round 2's sanity pass under-called it; round 3 measured it).
- **Her presence changes the rule — and her absence changes it back:** with her up, product forks are ASKED (R-Q21…R-Q23 this session, each answered in a minute); with her asleep (R-Q24), PROVISIONAL-and-continue and bundle.
- **The one-sentence raise that lands on a file the close edits is upheld by the orchestrator at the close** (17q J23), never by waking a reviewer for it.
- **Two `sed`/`grep` gotchas met:** `grep --include` needs the pattern quoted in zsh; the Read tier's file is not at `ReadTier/ReadPostView.swift` (find it before 18j's append).
