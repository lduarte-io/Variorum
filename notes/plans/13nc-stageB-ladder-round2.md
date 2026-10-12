# 13n-c Stage B (U2–U5) — ladder round 2 (cold review, opus-reviewer, 2026-10-11)

**Reviewer model:** Opus 5.5 (`claude-opus-5-5`), xhigh.
- **Prompt:** `notes/REVIEW_PROMPT.md` verbatim (PHASE = 13n-c) plus a mechanics-only note.
- **Scope:** fix range `b6ba61c1..9c049c6a`, and anything round 1 missed in `99d739e9..9c049c6a`.
- **Process:** read-only; its stage claim was released. The orchestrator landed this record from the report.

**Result: 0 BLOCKER · 0 MAJOR · 1 MINOR · 4 NIT.** No new BLOCKER/MAJOR, so there is **no round 3. Stage B's ladder
CLOSES at round 2.** The dispositions below go to one short close-out fix pass, together with O-4 (her provider sweep)
and her 2,000-character advice bound.

**Scope check (the reviewer's):** outside Fable's mandatory scope. B2's and B4's closest-to-meaning pieces already
carry F-19/F-21.

| # | Sev | Where | Finding | Disposition |
|---|---|---|---|---|
| R2-1 | MINOR | `MCPDoor.refreshAsk`, `MCPAskSheet`, `WingSwitcherMenu` `.anyWing`, Waiting rows | A gone target's ask stays visible (masthead mark, Waiting row) until she presses it. The press then closes the sheet with no word, conflicting with AppSpec §12 "a door that did nothing speaks a refusal" and P-2. | **ACCEPT, both halves.** (a) When her open forgets an ask, speak a refusal-kind line naming the place (words PROVISIONAL, her copy pass). (b) Re-validate the queue's targets in one batch (≤ the queue cap, ∝ the queue) when Waiting renders AND when the store's wings/trash change, so a dead ask's mark leaves without a press. The fixer picks the narrowest trigger and records it. Pins: the reviewer's two, red-on-old. FABLE-OWED: F-19 extended. |
| R2-2 | NIT | `MCPSharedMembersSheet` title, `MCPPaneCopy.membersTitle` | "1 notes"; a stale count above an empty list after the last revoke (`rows.isEmpty` conflates not-loaded with nothing-left, B8's class). | **ACCEPT.** Singular for one; a `loaded` flag; after a load that comes back empty, close the sheet. Pin `membersTitle(1)` (red today). |
| R2-3 | NIT | `MCPWireNeutralityTests` source net | It misses `OpsRefusalCopy.swift` (the FIRST branch the wire consults), the copy files `OpsRefusalTable` delegates to, and `MCPShim.swift`'s stderr. All are clean today, so this is a guard widening only. | **ACCEPT.** Widen the net to those files; correct the fix record's B13 row to name `OpsRefusalCopy`. Guarding the parser's blind spots is optional. |
| R2-4 | NIT | `MCPAskSheet.swift:8-12, 71-74` | Stale comments: "While connected", and the W-3 rationale about a WindowGroup host that U4 retired. | **ACCEPT.** Update both. Re-check the system-button choice now that the hosts carry the theme; record either way. |
| R2-5 | NIT (carried) | `MCPPaneCopy.swift:185` `noActivity` | "every call a client makes is listed here" (B10's class; the log keeps 500). | **ACCEPT** — true words consistent with lesson 6's "recently"; voice for her copy pass. |

**Riding the same close-out pass:**
- **O-4:** her provider-neutrality sweep; the plan's O-4 block is the work list, plus its source-sweep pin.
- **Her ruling:** `MCPSession.instructionsBound` 1,500 → 2,000 (P-13nc-U5-5's bound half; the pin keeps its form).

## Clean bill (the reviewer's, in summary)

- **B2:** `refreshAsk` re-reads the queue after the await (no revival); `MCPAsk??` keeps a failed read distinct from a
  gone target; every host closes on forget; a fenced book offers no granting answer and a re-raise can never re-arm one.
- **B3:** liveness is identical to `mcpSharedActs`, and the read is ∝ the act.
- **B4:** gates on the op's own fence read; the parity pin covers plain, Private, trait, daily and archived-Private
  books.
- **B5, B6:** fixed as dispositioned (B6's count and unavailable note are true).
- **B7–B11, B13, O-1, O-3:** fixed as dispositioned.
- **B1:** true, and an app-wide grep finds no other local-content claim.
- **The advice:** neutral and in bound.
- **Invariants:** nothing tracks word-level change, copies text across entities, or scales with the corpus.
- **Finals reproduced:** core 2,620/299 · MCP 80/11 · workbook 40/6 · the 8 fix-pin Mac suites 111/8, no skips.
- **Process:** zero trailers across 46 commits.
