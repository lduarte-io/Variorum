# VX-926 — ladder round 1 (cold review, opus-reviewer)

**Reviewer:** a fresh `opus-reviewer`, zero implementation context, `notes/REVIEW_PROMPT.md` run verbatim.
**Diff under review:** `git diff origin/main...HEAD` in `~/dev/variorum-vx-926` (branch `vx-926-test-flakes`, review tip `66f17c8d6`, merge base `fc0adff5a`).
**Anchor:** `notes/plans/fixes/vx-926-test-flakes.md` (the run record — §4 batches, §6 ledger, the U1–U4 records).

**Seam check (first, per the brief):** `git diff origin/main...HEAD --name-only` holds no `Sources/` line at all, no `Sources/VariorumCore/Sync/`, no `Shared/Protection/` / custody / keychain file, no `EditorTextView` / `BlockRangeIndex` / `PaneSurface` / `Features/ReadTier/` file. The app-side product lines are the per-note view-memory defaults plumbing (`NoteMemoryDefaults.store` named by nine homes + `RootView`'s one call). Outside Fable's mandatory scope — the round proceeds as `opus-reviewer`. (Detail, and the default's-meaning question, under the clean bill.)

**Status:** IN PROGRESS — findings appended as each is settled.

## Findings

### F-R1-1 · MINOR · `Tests/VariorumMCPTests/MCPSetupKeyServerTests.swift:252–263` — two raw waits for the server still carry NO bound, against U1's "every raw wait on the harness's one bound"

- **What's wrong:** `everyRefusalIsTheSameSentence`'s last arm (`:252` connect, `:259` the window reads inside the loop, `:263` the refusal read) connects with `MCPSocketRoad.connect` and reads the server's answers with `MCPShim.readFirstLine` on a descriptor that never gets `SO_RCVTIMEO` — no `HarnessWait.bound(fd, …)`, no `RawSocket`. The reads were moved off the pool (`HarnessWait.offPool`), but they stay UNBOUNDED.
- **Evidence (traced):** every other raw connect site in the target sets a bound (`ServerHarness.rawOpen` `MCPServerTests.swift:208`, `RawSocket.init` `MCPDiscoverProbeServerTests.swift:53`, `namedClientBlocking` `MCPHarnessWait.swift:82`, `bareClient` `MCPStopEndsConnectionGrantsServerTests.swift:171`, ConnectionEnd `:156`, CloseReason `:210`); this one does not. Mechanism: should the door ever stop answering a pre-initialize request (the very regression this arm exists to catch — VX-180's window), the off-pool thread parks in `read()` forever and the awaiting test task with it — the MCP target HANGS instead of failing named, the VX-132 class the harness exists to refuse. The U1 record's (3) and commit `1c35b3eb6`'s message ("every raw wait for the server under test on the harness's one bound (O-7's rule, carried to all)") claim the opposite; the record's own (1) notes these reads "had NO receive bound at all" but (3) never gives them one. Pre-existing hazard (on main it was the same read, unbounded and ON the pool — strictly worse), so this is a claim/belt gap, not a regression.
- **Pin:** none owed as a red-on-old test — it is a belt (a hang-ender), and its failing case is a hung run, not a red; a pin green on both sides would be hollow. Stated honestly: this is a claim-accuracy + hazard finding, MINOR.
- **Proposed fix:** one line after the connect — `HarnessWait.bound(fd, seconds: HarnessWait.receiveSeconds)` — and the U1 record's (3) list amended to name it (or the claim narrowed).

