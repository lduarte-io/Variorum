# VX-940 — ladder round 1 (cold review, opus-reviewer)

**Reviewer:** a fresh `opus-reviewer` session, zero implementation context, `notes/REVIEW_PROMPT.md` verbatim.
**Diff under review:** `git diff 37ff716bfaddd667353a80a4ab721e91e7cc7c40..HEAD` on `vx-940-pre-oss-followups` (the run's whole diff: W1–W4 + the records).
**STOP-rule re-check (the reviewer's own, by path):** no line in `Sources/VariorumCore/Sync/`, `Sources/VariorumCore/Protection/`, custody/keychain code, or the editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier). No default's meaning changes. This round stays `opus-reviewer`'s.
**Status:** IN PROGRESS — findings land here incrementally, severity-ranked at the end.

---

## Findings

### F-R1-1 · MINOR · `Sources/VariorumMCP/MCPSocketTransport.swift:254-260` (`sayClosing`) — the close line is now DROPPED in a band where it used to land without waiting

**What.** The new `sayClosing` sends the close line only after `poll(POLLOUT)` reports the socket writable, and XNU reports a socket writable only while its free send space is at least the send low-water mark (`SO_SNDLOWAT`, 2,048 bytes). The old body (one `MSG_DONTWAIT` send) blocked only when the free space was below the LINE's length; with free space anywhere in **[line length, 2,047] bytes** it wrote the whole line at once. So the fix closed the blocking case (free < line length — the real VX-933 face, rightly fixed) AND, unclaimed, a delivering case: a client that stopped reading after whole frames with ~0.1–2 KB free used to hear the app's close words and now hears only the shim's fallback sentence.

**Evidence (traced + probed).**
- The record's own P5b paragraph states the premise: "The first premise draft (7,000 bytes, ~1.2 KB free) let the old line through — a send waits only when the free space is below the LINE's length too". At that same state the new `sayClosing` returns false: `writeWithoutWaiting`'s first `poll` is not writable (1.2 KB < 2,048), so it returns `(0, nil)` and the line is dropped.
- A throwaway probe (scratchpad, never in the PR — `probe/closeline.swift`: a socket pair filled by poll-gated 2,048-byte steps to a given free space, then the old line's one 60-byte `MSG_DONTWAIT` send on a bounded thread) on this Mac (macOS 27.0.1): free ≈ 8 / 40 → not writable, old send BLOCKED (the case the fix rightly closes); free ≈ 100 / 600 / 1,200 / 2,000 → **not writable (the new code drops) while the old send returned at once with all 60 bytes**; free ≈ 2,100 / 4,000 → writable, both deliver.
- The record's W4 rows claim "The close line now DROPS where it used to block" (self-assessment (iv)) and "Its words, and every stop's road, are unchanged" — the delivering band that now drops is not named anywhere (not in P-940-W4-3, not in the canon proposal).

**Why it matters (and why only MINOR).** MCPSpec's VX-762 contract allows a drop ("when no line arrives the shim says its own sentence"), so this is not spec drift; but the run's stated bar for VX-933 was "the shape that changes NO wire answer", and this is an observable narrowing of when the client is told why it was dropped (her switch, the library closing, a held admission's refusal), introduced by the fix, unrecorded.

**Pin (red on the current tree).** In `MCPStalledReaderPoolTests`: fill a socket pair to leave ~1,200 bytes free with WHOLE frames (no frame mid-write, lock free; premise: `!writable(fd)` and free ≥ the line's length), then `sayClosing(line)` on a bounded thread: must return at once AND `true`, and the client must read exactly the line after the filler. Red today (returns `false`); the existing never-waits pin (8 bytes free) must stay green.

**Proposed fix (probed shape).** Inside `sayClosing`, under the write lock: set `SO_SNDLOWAT` to the line's length, `poll`, send the line in one step, then restore the transport's `step` value (`setsockopt` back to `step` — the fast road reads `step` once at init, and a lowered mark under a 2,048-byte step would let a fast-road send wait). Probed (`probe/lowat.swift`): with the mark at 60, free 8/40/59 → not writable (dropped, never waits); free 60/100/1,200/2,000 → writable, the 60-byte send returned at once, all 60 bytes. Alternative if the orchestrator prefers no `setsockopt` on the stop road: keep the shape and record the narrowed band as a named consequence in P-940-W4-3 and in the MCPSpec line the record proposes ("a buffer with less room than the socket's low-water mark drops it").

