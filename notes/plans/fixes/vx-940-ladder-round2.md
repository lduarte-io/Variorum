# VX-940 — ladder round 2 (cold review, opus-reviewer)

**Reviewer:** a fresh `opus-reviewer` session, zero implementation context, `notes/REVIEW_PROMPT.md` verbatim plus the round-2 standing context (re-review THE FIXES).
**Diff under review:** `git diff f71c0582a..1ab3458f5` on `vx-940-pre-oss-followups` (batch F1, whole), with the run's full diff `37ff716bf..1ab3458f5` as context. Anchor: round 1's findings (`notes/plans/fixes/vx-940-ladder-round1.md`, F-R1-1..4) and the orchestrator's dispositions ("## The ladder" in `notes/plans/fixes/vx-940-pre-oss-followups.md`).
**STOP-rule re-check (the reviewer's own, by path):** F1 touches exactly `Sources/VariorumMCP/MCPSocketTransport.swift`, `Tests/VariorumMCPTests/MCPStalledReaderPoolTests.swift`, `Tests/VariorumCoreTests/MCPClientVersionNullTests.swift` and the run record. Nothing in `Sources/VariorumCore/Sync/`, `Protection/`, custody/keychain, or the editor seam; no default's meaning changes. This round stays `opus-reviewer`'s.
**Status:** COMPLETE. **0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT** (F-R2-1..3). No new BLOCKER or MAJOR, so by the ladder's rule this round earns no round 3. The round-1 fix verdicts, the open-item answers and the clean bill follow the findings.

**Instruments (throwaway, the session scratchpad only, never in the PR):** a `git archive` export of `1ab3458f5` built headlessly under `scratchpad/r2/tree`. In it: (a) the pre-F1 transport (`f71c0582a`'s, sha256 `70faba4f…`) swapped in, then the shipped suite run; (b) the F1 transport (`e835e7de…`) with a scratch probe suite, `R2ProbeTests`, added beside the shipped tests; (c) R-F1-R (the restore's `defer` → `_ = mark`) applied to the scratch copy. The worktree was never edited, apart from this file.

---

## Findings

### F-R2-1 · NIT · `Tests/VariorumMCPTests/MCPStalledReaderPoolTests.swift:327-369` — the DROP path's mark restore is unasserted (the implementer's own open item (v))

**What.** Only the new pin checks that the low-water mark is restored (`:403`), and it checks only the DELIVERING path. The never-waits pin (`aCloseLineToAClientThatStoppedReadingNeverWaits`, 8 bytes free, the line dropped) reads no mark.

**Evidence (run, not read).** Under R-F1-R in the scratch tree, the shipped suite reds exactly 1 issue, `:403`. The never-waits pin stays GREEN with the mark left lowered (on that socket it is left at the line's length). My probe suite, which checks the mark on both paths, reds 11 issues under the same mutation, including the drop cases (room 8, 111 and 513 for the 514-byte line). The restore today is ONE function-scoped `defer` (`MCPSocketTransport.swift:275`), so the code is correct on both paths: on the F1 transport every probe point reads `before == after` (2,048), dropped and delivered alike. The gap is only that a later restructure, such as an early return added between the set (`:271`) and the `defer`, would leave the drop path's restore unguarded.

**Why only a NIT, labelled honestly.** This is a GUARD, not a red-on-old pin. It is green on the pre-F1 door (which never touches the mark) and green on F1, and red only under a mutation. No bug class needs it today.

**Proposed fix (optional).** One line in the never-waits pin, after `outcome == false`: `#expect(Self.option(pair[0], SO_SNDLOWAT) == <the mark read before the call>)`. The new `option` helper already exists. If it is not taken, the record's (v) stands as the named residual.

### F-R2-2 · NIT · `Tests/VariorumMCPTests/MCPStalledReaderPoolTests.swift:344-362` vs `:418-436` — two copies of the bounded `sayClosing` watcher (the implementer's open item (vi))

**What.** `sayClosingBounded` (new, `:418`) is the never-waits pin's inline watcher (`:344-362`) lifted into a helper. The only differences: the line and the client are parameters, and the comment is gone. The brief kept existing pins untouched, so the inline copy stays.

**Proposed fix (optional, at the file's next touch).** Route the never-waits pin through `sayClosingBounded`. It's a pure refactor: same bound, same unstick-by-one-read, same `Bool?`. No pin's verdict changes.

### F-R2-3 · NIT (process, not code; the closeout's) · Linear VX-944 — the born ticket the F1 doc clause names has no project and no Parked reason

**What.** `MCPSocketTransport.swift:64-66` points readers at VX-944 for the host's announce loops. VX-944 exists and its body states the F-R1-2 mechanism, fix shapes and pin shape accurately (read on Linear: Backlog · Low · labels MCP, Confirmed, Bug). But it has `project: null` and is not Parked. CLAUDE.md's rule is that every ticket carries a project or an explicit Parked state with a reason, and the closeout triages every ticket the effort filed.

**Proposed fix.** At the closeout's filed-ticket triage, give VX-944 a project, or Parked with its reason. There is no code item.

---

## The round-1 findings assigned to F1 — verdicts

- **F-R1-1 (the close line dropped in [line length, 2,047] bytes free): CONFIRMED FIXED.**
  - **Mechanism, traced.** `sayClosing` (`MCPSocketTransport.swift:267-278`) takes these steps under the tried write lock and the mid-frame and `line.count <= step` guards. It reads the current mark (`sendLowWater`), sets it to the line's length (`setSendLowWater`) and registers the restore as a `defer` declared after the unlock's `defer`. Swift runs defers in reverse order, so the restore runs first and the lock is let go only after the mark is back. It then makes one poll-gated write at step = the line's length.
  - **What decides the send.** At that mark, XNU's poll is writable iff free ≥ L. A blocking send of L bytes waits only while free < min(L, mark) = L. So the line goes exactly when the socket can take it whole, and it never waits.
  - **Red on old, re-run here** rather than taken from the record. On the scratch export with the pre-F1 transport: `Test run with 7 tests in 1 suite failed … with 2 issues` (`:401` `outcome == true`, `:406` the bytes), and the six other tests passed. That is exactly the record's P1/R-F1-PRE picture.
  - **Green at HEAD in the worktree:** 7/7. **R-F1-R re-run:** the shipped suite reds exactly `:403` (1 issue), as the record says.
  - **Boundary probe on the F1 transport** (`R2ProbeTests.boundaries`; her switch's 112-byte line and a cap-sized 514-byte line; whole frames leaving `room` free):
    - room 8 and 111 → `false`, never waits.
    - room 112, 113, 1,200, 2,047, 2,048 and 3,000 → `true`, and the client reads the line after the frame.
    - for the 514-byte line: 513 → `false`; 514 and 1,500 → `true`.
    - every point: the mark reads 2,048 before and after.
  - **Dead sockets** (`R2ProbeTests.deadSockets`). Our `SHUT_RDWR`, the client closed, and our `SHUT_WR` each give `false` in about 50 µs with the mark unchanged; a later frame fails at once and never waits. With the client's `SHUT_WR` only, the line is delivered (`true`).
  - **The canon proposal now describes the code.** W4's PROPOSED MCPSpec line ("… never waiting on a frame or on the client — a buffer that cannot take the line whole drops it (VX-933)") now matches it exactly, so it can stand as written. (The one unreachable edge: a line longer than `step` would also drop, but the close line is capped at 514 bytes, against a 2,048-byte step.)
- **F-R1-2's doc clause: CONFIRMED.** `MCPSocketTransport.swift:64-66` now reads "never delays another connection's writes" and names the host's announce loops as VX-944's seam.
  - I checked the clause's truth. The only cross-connection sharing besides the host loops is the write executor (`MCPWriteSupport.swift:21`, `MCPSerialExecutor.run`). It runs synchronous bodies and makes no send, so no other coupling exists that the clause would overstate.
  - VX-944 is real and accurate (but see F-R2-3).
- **F-R1-4 (a), the version-null header: CONFIRMED.** I read it against the arms in `MCPClientVersionNullTests.swift`. Pre-fix, every NUL-bearing input truncates at its first NUL:
  - the minted row reads "2.1", and so does the admission's returned client, read back from the row;
  - the refresh reads "2.2"; the waiting setup "2.1.299"; the direct contact write "3";
  - the untouched claude-code row reads "2.1.299" on both sides, so it is not an issue.

  That is five issues, matching W4 P2's recorded "5 issues". The header lists exactly those, and no "0.1".
- **F-R1-4 (b), the thread name: CONFIRMED.** `writeAllOffPool`'s one-off thread is `variorum.mcp.opening-writer` (`:333`). The queue keeps `variorum.mcp.writer` (`:67`). `grep` over `Sources`, `App`, `Tests` and `Tools` finds no reader of either label. After `d77c40db9`, the only non-comment line F1 changed is this name: the diff `d77c40db9..1ab3458f5 -- Sources`, minus `///` lines, is exactly that one pair.
- **F-R1-4 (c), the type doc reflow: CONFIRMED, words identical.** Lines 20–36 were hashed with `///` stripped and whitespace squeezed: `ab45ac18…` at `f71c0582a` and at `1ab3458f5`.
- **F-R1-4 (d), the W4 record's "~16 KiB": CONFIRMED.** The P4/P5 mechanism sentence now says "a write to it waiting once 8,192 bytes sit unread (P5b's probe filled the pair at exactly 8,192), so any answer larger than 8 KiB waits on the CLIENT reading".
  - This agrees with my own probe: the socket's capacity reads 8,192, and at room 112 the client holds exactly 8,192 bytes once the 112-byte line lands.
  - The record file's F1 diff is exactly two hunks: that sentence and the F1 section. Nothing else in its history was touched.

## The F1 record's two implementation choices and its open items (i)–(vii) — answered

- **Choice (1): restore the mark READ before lowering, not `step`. SOUND.** Only `sayClosing` writes the mark, always under the lock and always restoring it, so the value read equals `step` whenever `writeStep` read a mark. If the init read had failed, `step` is 1 and the `line.count <= step` guard drops before any mark is touched. Restoring "what was there" is also the more general correct restore.
- **Choice (2): `variorum.mcp.opening-writer`. SOUND.** It's the round-1 suggestion, and a search for the queue's label doesn't match it.
- **(i) The no-wait rests on two XNU rules probed at the boundary, not documented. ACCEPTED.** I re-probed at L−1 / L for both a 112-byte and a 514-byte line (above), and both pins carry 5 s bounds that would catch a future kernel that waits differently.
- **(ii) Only the poll needs the lowered mark, and the restore-before-unlock matters for the OTHER writes. CONFIRMED.** The mechanism: the fast road caches `step` = 2,048. Under a mark left at L, it would poll writable with L ≤ free < 2,048 and then make a blocking send of up to 2,048 bytes. That send copies `free` bytes and then waits, so a lowered mark left on a live socket would put back exactly the pool hold VX-933 removed. The `defer` order prevents it (Swift's reverse-declaration rule, `:269`/`:275`), and R-F1-R reds on it.
- **(iii) The fallback is not pinned. ACCEPTED, with one refinement.** The fallback IS reachable in a test on a DEAD socket: our `SHUT_RDWR`, or the client closed. My probe drives it, and it answers `false` at once. It's unreachable only on a live socket, which is what the record says. A pin there would be a green-both-sides guard, since the pre-F1 door answers the same way. No finding.
- **(iv) A failed restore leaves the lowered mark only on a dead socket. CONFIRMED** by the dead-socket probe: every later send fails at once. In the product, `hangUp` shuts the socket right after the line anyway (`MCPSession.swift:686-690`), so on the shipped road no write ever meets the lowered mark, whether or not the restore runs.
- **(v) The drop path's restore has no assertion. CONFIRMED.** That is F-R2-1 (an optional guard).
- **(vi) `sayClosingBounded` repeats the inline watcher. CONFIRMED.** That is F-R2-2 (an optional refactor at the next touch).
- **(vii) The pin uses her switch's real line, and its premises are asserted. CONFIRMED.**
  - The line is 112 bytes, and the cap is 512 bytes of words, so 514 on the wire: at most 1,200, the pin's room. A reworded line keeps meeting the premises.
  - The pin is green on the pre-VX-933 door too: there, a `MSG_DONTWAIT` send delivers in this band, because free ≥ the line's length. So the pin anchors W4's regression and F1's return to the pre-VX-933 delivery, as intended.

---

## Clean bill (checked by the reviewer and found solid)

- **The STOP rule over F1, by path:** three code files plus the record. `opus-reviewer` is the right cast.
- **Red-on-old re-proven independently** on a rebuilt pre-F1 transport: the new pin alone reds, with 2 issues. **R-F1-R re-proven:** exactly the mark check reds, with 1 issue. Green at HEAD: `MCPStalledReaderPoolTests` 7/7 and `MCPClientVersionNullTests` 2/2. The close-line roads' suites (`MCPCloseReasonTests`, `MCPLockPostureServerTests`, `MCPStopRoadsServerTests`, `MCPCloseLine*`, with the pool suite) gave **36 tests / 7 suites passed**, with no skipped line, matching the record's count.
- **"The restore runs before the lock is let go"** is proven by the code's `defer` order (`:269` unlock declared first, `:275` restore second, both in one function scope), not by prose. Mutating the restore away reds the pin.
- **No other write ever meets the lowered mark.** Every write to a live connection's socket holds `writeLock`:
  - the fast road, by `try` (`:187`);
  - the writer, by `withLock` (`:211`);
  - the close line itself.

  The opening's `writeAllOffPool`, the one unlocked road, runs strictly before the transport exists: `MCPSession.swift:387-446` comes before `:454-455`, and `hangUp` says the line only through an existing transport (`:685-688`).
- **The fix is minimal and behaviour-scoped.** After `d77c40db9` the only non-comment change is the thread name. `writeStep` returns what it did before (the mark, else 1). The fast road, the writer, `drained`, `disconnect` and the mid-frame gate are untouched.
- **On the wire:** the close line arrives exactly where the pre-VX-933 send delivered it (free ≥ the line's length), and drops exactly where that send would have blocked. No answer shape, close reason, sentence, stop road or shim byte changes. MCPSpec's VX-762 contract ("never mid-frame, never waiting on a frame … when no line arrives the shim says its own sentence") holds. The PROPOSED amendment is accurate as written.
- **The doc comments F1 authored are accurate to the code and to the probes.** That covers `sayClosing`'s two paragraphs, `sendLowWater`, `setSendLowWater` (EINVAL for zero, a negative mark, and a socket shut both ways, in line with XNU's `sosetopt`) and the `writer` clause.
- **Record integrity.** The transport shas match each commit the record names:
  - `70faba4f` at `f71c0582a`/`c2bc57330`;
  - `6b48fd9f` at `d77c40db9`;
  - `e835e7de` at `36c2deceb`/`1ab3458f5`.

  The pin file is `d47586ed` and the version pin `ac71b246`, as recorded. F1 descends linearly from `f71c0582a`, all ten commits are by the repo's author identity, and none carries an attribution trailer.
- **F-R1-3** was not F1's scope (the orchestrator's closeout line on VX-937's checklist). It is not re-litigated here, but it is still owed at the closeout.
