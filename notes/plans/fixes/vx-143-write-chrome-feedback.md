# VX-143 — Run: write & chrome feedback

**STATUS: OPEN — kicked off 2026-10-10 (architect shape, the triage sitting ran in-conversation).**
Ticket: VX-143 (`Run: write & chrome feedback`) · Branch: `vx-143-write-chrome-feedback` · Worktree: `~/dev/variorum-vx-143` · Machine: **the Air** (her session grant, 2026-10-10: the Air runs walks and suites locally this effort — a named exception to the ssh-to-the-Pro rule).
Members (sub-issues, In Progress): VX-135 · VX-136 · VX-140 · VX-141 · VX-142.
No `Sync/`, no schema. VX-140 sits BESIDE the custody seam (unlock-prompt frequency, not key custody — her ruling below, with a tripwire). Reviewer at the ladder: **`fable-reviewer`** (VX-140's proximity to the protection seam decides it for the whole run's diff).

## The sitting record (2026-10-10, in-conversation triage)

Her feedback, verbatim, dispositioned:

1. **VX-135** — "command enter in a take from write's take menu doesn't work to select the take as the chosen one."
2. **VX-136** — "the margin grid items are a little bit weirdly misaligned when you have several - the new take area will push others down and it looks weird." **RULED (question tool, recommended option picked): the margin grid defaults to TWO columns when the block has more than 2 takes.** The layout repair and the default land together (they interact at the new-take area).
3. VX-137 minted Backlog at her word ("doesn't need to be done anytime soon") — **not in this run**.
4. VX-138 (stack-without-duplicate fan style) and VX-139 (keep tabs open) — **round 2, not this run**.
5. VX-140 (relentless Touch ID re-prompting) — first sequenced after 13n-b, then **RULED INTO THIS RUN at the sitting**. Her words, verbatim: "I don't think that constantly asking for touchid is a custody seam - we aren't changing custody settings, we're reducing the frequency of prompting to unlock. I think we can do it now with a fable cold review - it's not a sync change for certain." Adopted with ONE tripwire: if the trace leads into `KeychainCustody`/vault handling itself rather than the prompt-triggering logic, the member PAUSES and returns to her. **Her live example, same sitting (screenshot, the Air):** the system sheet "Variorum is trying to Unlock your Variorum library. Touch ID to continue with Variorum." appeared over her TERMINAL while Variorum was not frontmost — "see this is an example. it just keeps appearing." The re-prompt fires in the background, without her returning to the app.
6. **VX-141** — "when you are in a book and click on a note, there's no verticle shift … but there is a jump when you go from a note to a book (the this note section briefly starts to minimize and then snaps back, but it's distracting that there's movement in one direction)."
7. **VX-142** — "hovering with the cursor needs to not keep showing hints in read mode on a book - covers the text any time your cursor is over it."
8. Her version question ANSWERED at the sitting: a note version becomes its own note via **Note ▸ Versions → Promote** (`NoteVersionsPane.swift:319`; the tutorial: "Promote turns a moment into a note of its own"). She confirmed she meant a note version. No ticket.
9. Her export observation landed as a comment on VX-125 (already filed, 13n project).

## Binding principles

The 13b constitution P-1…P-9 binds verbatim (the architect-phase skill carries the text). Highlights for this run: P-1 (any door change renders from the registry, gating is data), P-2 (a rendered door acts or delivers the real refusal — VX-135 is exactly a P-2 defect), P-8 (no literal colour outside tokens; `lineLimit` on fixedSize chrome), red-on-old pins per member verified by behavioural revert.

## The batch plan (ONE implementer session, all four members — small chrome fixes, one acceptance unit)

Per member: trace the mechanism first (no fix without a self-traced concrete mechanism), then a red-on-old pin, then the fix, revert-verify the pin.

- **VX-135 — the take-menu ⌘⏎ chooser.** Trace where Write's take menu renders takes and what ⌘⏎ is bound to (the fan styles live around `TakesBoardView`/`FanStyle`; Write's per-block fan surface is the trace's job to pin down). Expected shape: the shortcut either isn't declared or routes to a handler that never fires in that context. Fix so ⌘⏎ on a take chooses it (the chosen-variant pointer via the operations layer), with a pin.
- **VX-136 — margin grid alignment + the ruled default.** Two parts, one member: (a) the misalignment — the new-take area pushing other cards down unevenly (`TakesBoardView` margin-grid section, `TakesBoardLayout` — R74's density machinery, L4's `marginCardCapHeight` cap); (b) the RULED default — two columns when the block has >2 takes. Keep R74's "hers to choose" machinery intact — this changes the DEFAULT, not the choice.
- **VX-140 — the Touch ID re-prompt loop.** Trace FIRST, in the protection presentation layer (`StoreLockView`, `ProtectionController`, `AppBootstrap` wiring): what re-triggers `LAContext.evaluatePolicy`? The reproduction fact: the prompt appears while the app is NOT frontmost (over her terminal), repeatedly. Candidates: a retry-on-cancel/failure loop, activation/wake/occlusion observers re-evaluating the lock, or per-window lock views each asking. The fix reduces WHEN we ask — one ask per deliberate unlock occasion; a cancel means NO re-ask until she acts (returns to the app and engages it, or clicks the lock surface). THE TRIPWIRE (her ruling): if the mechanism lives in `KeychainCustody`/vault handling rather than prompt triggering, STOP that member and report back — do not touch key custody. Pin where the harness allows (the prompt itself can't be driven headlessly; pin the trigger logic — e.g. the guard that decides whether an unlock attempt may fire).
- **VX-141 — the note→book sidebar jump.** The sidebar note box (18d — three states: none · selected · live). Going book→note is calm; going note→book the box visibly starts to minimize then snaps back. Trace the transition (likely an animated collapse racing a state reset); make the note→book direction as still as the reverse.
- **VX-142 — read-mode hover hints on a book.** In the book's Read mode, hover hints keep appearing under the cursor and cover the text. Find the hint surface (BookView read surfaces — `PagedReadView`/`SpreadBookView`/read flow); stop it from showing persistently over prose on mere hover. If the hint has a legitimate first-use purpose, calm it (once, brief, out of the prose's way) — the fix must not invent new product behavior; if a product-flavored choice arises, mark PROVISIONAL and bring it back.

Evidence: pins per member + the orchestrator's hands-on walk on the Air (her grant) before the record closes.

## LIVE STATUS

- VX-135: NOT-STARTED
- VX-140: NOT-STARTED
- VX-136: NOT-STARTED
- VX-141: NOT-STARTED
- VX-142: NOT-STARTED

## Environment traps (binding for every session in this run)

- Work ONLY in `~/dev/variorum-vx-143`; never commit from the main checkout; push after every commit; NO attribution trailers on commits.
- The checkpoint protocol (`notes/SessionResiliencyProtocol.md`) binds from the first commit: commit per coherent piece, LIVE STATUS flipped in the same commit, synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never `tail -f | grep -m1`), no subagents except at most one Sonnet, read-only, for external facts.
- Headless core: `swift build` / `swift test --filter Name` runs freely. Mac app tests: from `App/Variorum/`, `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's N counts skipped tests — read the `skipped:` lines before claiming a gated suite ran. NEVER add a custom build configuration.
- THIS RUN RUNS ON THE AIR AT HER GRANT — local `xcodebuild test` is allowed this session. Instance checks before any app-suite run: `pgrep -fl 'Variorum.app/Contents/MacOS'`, discriminate by PATH; a real-store instance is NEVER quit or killed; no Release builds or /Applications refreshes while one lives.
- zsh `pipestatus` for pipelines; never `git checkout` over uncommitted work; screenshots into gitignored dirs.
- **Her REAL-STORE Variorum is (or may be) RUNNING on this Air** — the VX-140 screenshot proves a live instance at the sitting. NEVER quit or kill it; app-suite runs and any walk wait for a zero-instance window SHE arranges (ask through the orchestrator). Headless core work proceeds regardless.
