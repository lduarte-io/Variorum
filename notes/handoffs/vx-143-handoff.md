# VX-143 — morning handoff (overnight run, 2026-10-10 → 11)

**Everything is done, laddered clean, and HELD UNMERGED at your word. PR #146.**

## Your checklist

1. **Merge call.** PR #146 (`vx-143-write-chrome-feedback`, pushed through the run-close commit) — merge commit, never squash. After the merge the closing session: retires the in-flight row, carries the PROVISIONAL bundle to QUESTIONS, writes the MOBILE PARITY line (the phone's Block History row deliberately keeps its old face — `Shared/` untouched), closes the Linear members, removes the worktree, deletes the branch, and refreshes `/Applications` at a zero-instance window (A1 first).
2. **Your real-use check stands in for the walk.** The Air's terminal lacks the Accessibility grant (`AXIsProcessTrusted() == false`; Screen Recording IS granted), so no synthetic-click walk ran — every member closed on red-on-old pins, behavioural reverts, store-asserted evidence and captures instead. Worth 60 seconds each in the real app: ⌘⏎ in Write's take panel · the margin grid with 3+ takes · lock the Mac then come back (ONE Touch ID ask, in-app only) · note→book in a split · hover over a book's Read page · Block History on a long block. **Optional:** grant Accessibility to the terminal in System Settings ▸ Privacy & Security if you want future Air walks.
3. **Taste calls (each built as the most defensible option, all reversible one-line):**
   - **VX-144 (the commits page):** direction A built — compare `before-vx144-*.png` / `after-vx144-*.png` in `App/Variorum/DerivedData/vx143-screens/`. P-VX144-2 the pane blurb dropped (the "saved moments" defining sentence kept verbatim) · P-VX144-3 names at 13 pt medium · P-VX144-4 Close stays a stock button · P-VX144-5 an occasional preview ellipsis after a period accepted. Directions B (click-to-open rows) and C (day groups) were NOT built — they'd narrow your rename-beside-each-commit and sectioning rulings; say the word if you want either.
   - **VX-140:** after a cancel, only your button asks again; returning to the app does not re-ask by itself.
   - **VX-142:** no note-title hint survives anywhere on the Read scroll.
   - **VX-136:** "auto" menu item wording; rows aligned across ALL pages; new-take doors stack in a one-column grid. **If you ever picked "1 wide" yourself, your stored choice still wins — pick "auto" to see the new two-wide default.**
   - **VX-150:** ⌘T in the panel copies the ring's take, else the shown take (P-VX150-1).
   - Observation, unbuilt: the take heading ("take 1 of 3") now reads quieter than the commit names under it — one-line tweak if you want it louder.
4. **The ladder found and fixed two real bugs of its own** (worth knowing what they were): a phantom empty note box that could stand permanently over split Read-mode books (VX-141's fix widened, then refined gain-only after the sanity pass caught a same-book-two-panes wipe), and **⌘⇧A through the panel's gone face really archived a take of a released original** (a silent wrong write — now no key acts on a block that left the note). Both discriminating-revert pinned.
5. **New tickets born overnight:** VX-150 ✓ (fixed in-run) · VX-151 (StatusSeamVocabularyTests red on main — 13n-a importer residue, pre-existing) · VX-152 (lock reentrancy — custody proper, Fable work, sequenced after 13n-b) · VX-153 (finished book's box flash) · VX-154 (the panel's remaining routed-command class — ⌘S/comments/structural verbs still reach Write's caret block; two worked fixes to copy). Round 2 of your feedback awaits your word: VX-138 (stack-without-duplicate) + VX-139 (keep tabs open); VX-137 (shortcut helper) rests in Backlog.
6. **Answered at the triage, no code:** a note version becomes its own note via **Note ▸ Versions → Promote** (already built; tell me if it didn't read as findable and I'll ticket the discoverability). Your export item rode VX-125 as a comment.

## State of record

- Record: `notes/plans/fixes/vx-143-write-chrome-feedback.md` (sitting record · both batch records · the ladder block · the run close block). Ladders: `vx-143-ladder-r1.md` (0B/1M/1m/2n; both confirmed, the MINOR re-ranked MAJOR, fixed by the reviewer, sanity-refined) · `vx-143-ladder-r2.md` (CLEAN BILL, 1 record-only NIT).
- Suites: batch-1 whole-target 4,195/689 (31 pre-existing Air-environment reds, identical pre-batch; two of them = VX-151 + known VX-115) · batch-2 close 209/32 · ladder close 106/20 + R2's independent 9/2. Zero new failures anywhere.
- Scope fences held: zero `Sync/`, zero custody writes (VX-140's tripwire never hit — `StoreLockView`/`StoreLaunchGate`/`StoreLobby` only), zero schema, zero `Shared/`, zero editor seam, marker untouched. QUESTIONS.md untouched (the bundle lands at the merge, per the merge-moment rule).
- Linear: VX-143 + members In Review; VX-135/136/140/141/142/150/144 all fixed; the run ticket closes at the merge.
- The old `/Applications/Variorum-previous-5544.app` was deleted at your word. Caffeinate ran all night; the dev-store launch smoke passed; your real-store app was never touched.
