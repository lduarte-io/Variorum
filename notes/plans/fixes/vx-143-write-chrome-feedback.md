# VX-143 — Run: write & chrome feedback

**STATUS: OPEN — kicked off 2026-10-10 (architect shape, the triage sitting ran in-conversation).**
Ticket: VX-143 (`Run: write & chrome feedback`) · Branch: `vx-143-write-chrome-feedback` · Worktree: `~/dev/variorum-vx-143` · Machine: **the Air** (her session grant, 2026-10-10: the Air runs walks and suites locally this effort — a named exception to the ssh-to-the-Pro rule).
Members (sub-issues, In Progress): VX-135 · VX-136 · VX-141 · VX-142.
No `Sync/`, no custody, no schema. Reviewer at the ladder: `opus-reviewer` unless the diff turns out to touch the editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier) — then `fable-reviewer`.

## The sitting record (2026-10-10, in-conversation triage)

Her feedback, verbatim, dispositioned:

1. **VX-135** — "command enter in a take from write's take menu doesn't work to select the take as the chosen one."
2. **VX-136** — "the margin grid items are a little bit weirdly misaligned when you have several - the new take area will push others down and it looks weird." **RULED (question tool, recommended option picked): the margin grid defaults to TWO columns when the block has more than 2 takes.** The layout repair and the default land together (they interact at the new-take area).
3. VX-137 minted Backlog at her word ("doesn't need to be done anytime soon") — **not in this run**.
4. VX-138 (stack-without-duplicate fan style) and VX-139 (keep tabs open) — **round 2, not this run**.
5. VX-140 (relentless Touch ID re-prompting) — **its own run after 13n-b merges** (custody seam; the one-custody-effort rule — 13n-b holds the slot).
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
- **VX-141 — the note→book sidebar jump.** The sidebar note box (18d — three states: none · selected · live). Going book→note is calm; going note→book the box visibly starts to minimize then snaps back. Trace the transition (likely an animated collapse racing a state reset); make the note→book direction as still as the reverse.
- **VX-142 — read-mode hover hints on a book.** In the book's Read mode, hover hints keep appearing under the cursor and cover the text. Find the hint surface (BookView read surfaces — `PagedReadView`/`SpreadBookView`/read flow); stop it from showing persistently over prose on mere hover. If the hint has a legitimate first-use purpose, calm it (once, brief, out of the prose's way) — the fix must not invent new product behavior; if a product-flavored choice arises, mark PROVISIONAL and bring it back.

Evidence: pins per member + the orchestrator's hands-on walk on the Air (her grant) before the record closes.

## LIVE STATUS

- VX-135: NOT-STARTED
- VX-136: NOT-STARTED
- VX-141: NOT-STARTED
- VX-142: NOT-STARTED

## Environment traps (binding for every session in this run)

- Work ONLY in `~/dev/variorum-vx-143`; never commit from the main checkout; push after every commit; NO attribution trailers on commits.
- The checkpoint protocol (`notes/SessionResiliencyProtocol.md`) binds from the first commit: commit per coherent piece, LIVE STATUS flipped in the same commit, synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never `tail -f | grep -m1`), no subagents except at most one Sonnet, read-only, for external facts.
- Headless core: `swift build` / `swift test --filter Name` runs freely. Mac app tests: from `App/Variorum/`, `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's N counts skipped tests — read the `skipped:` lines before claiming a gated suite ran. NEVER add a custom build configuration.
- THIS RUN RUNS ON THE AIR AT HER GRANT — local `xcodebuild test` is allowed this session. Instance checks before any app-suite run: `pgrep -fl 'Variorum.app/Contents/MacOS'`, discriminate by PATH; a real-store instance is NEVER quit or killed; no Release builds or /Applications refreshes while one lives.
- zsh `pipestatus` for pipelines; never `git checkout` over uncommitted work; screenshots into gitignored dirs.
