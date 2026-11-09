# VX-940 — Run: pre-OSS code follow-ups

**STATUS: OPEN — kicked off 2026-11-09 at her sitting (/architect-phase, the Pro; orchestrator variorum-91, running beside VX-926 under the two-Opus allowance — one implementer per run, never two in one worktree).**
Ticket: VX-940 · Branch: `vx-940-pre-oss-followups` · Worktree: `~/dev/variorum-vx-940` · PR: `VX-940: …` (merge commit, never squash).
Coordinator: nov7. **This is the wave's LAST umbrella before her pause** (her words at the sitting: "I'll be pausing code changes once this current wave is done (including the umbrella we're about to mint)"); VX-849 runs in this wave as its own umbrella ("I'm planning on running that, just not under the same umbrella. but it does belong to this wave.").

## FOR A LATER READER

*(Written at closeout. Until then: her rulings are §2; the batches §4; the ledger §6.)*

---

## 1. Kickoff, cast, preflight

- **Members (the sub-issue listing of VX-940):** VX-939 · VX-923 · VX-920 · VX-917 · VX-922 + VX-925 + VX-933 (one MCP-hygiene unit). Confirmed by her at the sitting's dialog ("Confirm all six"). VX-932 rides VX-926 instead; VX-919/VX-921 are seated in VX-849.
- **Cast:** her VX-926 ruling carries as the session's working default for this wave — **Opus implements, Opus reviews**; everything away-time rules PROVISIONALLY and bundles. **The STOP rule:** any diff line reaching `Sync/`, custody/keychain or the editor seam halts the run back to her (that class mandates Fable review). The MCP unit lives inside MCPSpec's contract (required reading for its implementer); R-825 binds; an answer-shape change returns to the orchestrator BEFORE building.
- **Preflight:** carried by this orchestrator session's same-day reads (CLAUDE.md + canon; the master plan + in-flight; QUESTIONS #268 incl. her sitting rulings; the resiliency protocol; MCPSpec IN FULL; the VX-912 B2/B3/B4 records). SurfaceContracts: VX-920 touches the History & Lineage face — its implementer reads SurfaceContracts' note-section lines for that surface; VX-923 is Settings copy (the Acknowledgments pane — no contract change, additive credits). No SyncSpec/TEXTKIT2/CastleRules seam in scope.
- **Stage:** nearly everything headless. App-suite runs (VX-920's pin; the merge gate) via nov7 (REQUEST/READY/GO/RELEASE); the VX-926 soak and this run's gate can share scheduling — nov7 arbitrates. The soak-tree rule binds this run's gate too.

## 2. Her rulings (the 2026-11-09 handoff sitting; QUESTIONS #268's addendum carries the full set)

- **R-940-1 (the mint + composition):** "you'll help me make a new umbrella ticket in linear to run now for the follow-ups that need to be done pre-oss" + the dialog pick "Confirm all six".
- **R-940-2 (the wave + pause):** VX-849 "does belong to this wave" as its own umbrella; code pauses after this wave INCLUDING this run; her her-hands pass follows.
- **R-940-3 (VX-939's substance, verbatim):** "i'm fine renaming the readme that ships within variorum as a note for users to 'letter' within the repo, so the code element of doing that you can ticket."
- **R-940-4 (VX-917's cadence, verbatim, from VX-912's sitting):** "I think it should be a check every major version switch or something, it's too onerous for every run."

## 4. Batches (one acceptance unit each; a fresh opus-implementer per batch; §7 = the VX-926 record's §7 by reference, which binds the VX-912 record's §7)

### W1 — VX-939 + VX-923 (the repo face + the credits; one unit, two members)
1. **VX-939 — LETTER.md:** materialize her letter's text as a clean `LETTER.md` at the repo root; the README's pointer moves to it; the in-app seed road untouched (if the seed source and LETTER.md can honestly be ONE file, say so in the record — else two files with the sync noted). The letter's text today: `notes/plans/vx-105-letter-content/read-me.txt` (strip the capture-token header for the .md face; the words are HERS — byte-faithful, no editorial).
2. **VX-923 — the Acknowledgments credits:** Settings ▸ Acknowledgments gains Sparkle (MIT + its BSD-2/zlib/MIT parts) and the five LINKED Point-Free MIT libraries; BIP-39's license line corrected to MIT in `Vendor/BIP39/README.md` and `AcknowledgmentsCopy.bip39`. The VX-912 B3 record's dependency table is the source of truth for names/licenses. App copy — sentence case, no shouty caps; the pane's existing entry shape is the template. Pin: the pane's listing test (or the copy source's unit test) asserts the new entries; red-on-old.
Evidence: headless build + the copy tests; VX-939 is repo files only.

### W2 — VX-920 (the lineage face names Home)
The one-line fix shape from the VX-912 B2 record: `LineageFaceModel.place` resolves through `Queries.effectiveWingID` and names Home as the switcher names it (never "the wing “”"). Required reading: the B2 record's F-R1-1/ finding + SurfaceContracts' History & Lineage lines. Pin: a `LineageFaceModelTests` arm over `.otherWing(wingID: "")` asserting the Home wording — red-on-old by revert. The visual confirm rides the merge-gate window (one capture if cheap, else the pin carries it).

### W3 — VX-917 (the CI cold-build workflow)
`.github/workflows/` gains the cold-build check at HER cadence (R-940-4): triggered on release tags / manual dispatch — NEVER per-push; jobs: `swift build` + `swift test` on the core from a clean checkout (the BUILDING.md road); the workflow's own header comment states the toolchain-skew rule (AppSpec §15.6 — results count only when the runner's Xcode major matches the primary's) and that a failed run on a mismatched toolchain is informational. Inert-while-private posture like the B3 workflows where applicable. Evidence: `act`-style local validation isn't available — the YAML parses (a linter is a legal instrument), the trigger shape is pinned by inspection in the record, and the first live run is a flip-day check (noted on VX-937's checklist… append it there at closeout).

### W4 — the MCP-hygiene unit (VX-922 + VX-925 + VX-933)
Required reading: MCPSpec IN FULL; the VX-912 B4 record; the VX-926 U1 record (the HarnessWait.offPool pattern and the pool trace — VX-933 is its door-side sibling).
1. **VX-922:** fold `Queries.mcpResolvedWing` + `MCPReadTools.resolvedWing` onto the one `Queries.effectiveWingID` rule — byte-equivalence proven by the existing pins passing UNMODIFIED (the parity proof); no reach semantics change.
2. **VX-925:** `clientInfo.version` routed through VX-357's strip at the write (`admitMCPConnection`); pin: a NUL-bearing version stores stripped-and-counted; red-on-old.
3. **VX-933:** the door's blocking send gets a bound — a send timeout or the send taken off the pool (the offPool pattern door-side); the shape that changes NO wire answer is preferred; if every honest shape changes an observable behavior (a new close reason, a dropped-connection road), STOP and return the shape to the orchestrator (MCPSpec consequences). Pin: a stalled-reader client cannot pin pool threads — deterministic via a non-reading test client; red-on-old.
All headless (the MCP suites). The two-store catalog green whole is this unit's own gate.

### The ladder
One ladder over the run's whole diff: fresh `opus-reviewer` (her cast), REVIEW_PROMPT VERBATIM, zero framing; findings repo-first; same-model arbitration by the orchestrator against the spec; cap three rounds. The STOP rule re-checked over the final diff before the ladder.

### The gate
The whole Mac target + the phone target if `Shared/` changed (VX-920 is Mac app code; VX-923's copy may be shared — check) + the MCP whole target, on the final tree, via nov7, every run through `Tools/assert-tests-ran`. Coordinates with VX-926's soak windows — nov7 arbitrates the order; merges serialize.

## 6. LEDGER

| Row | What | Status |
|---|---|---|
| 0 | Kickoff: mint (VX-940), 7 members seated, worktree, in-flight row, her rulings | DONE (this commit) |
| W1 | VX-939 + VX-923 | NOT STARTED |
| W2 | VX-920 | NOT STARTED |
| W3 | VX-917 | NOT STARTED |
| W4 | VX-922 + VX-925 + VX-933 | NOT STARTED |
| L | The ladder (opus-reviewer) | NOT STARTED |
| G | The gate (whole targets via nov7) | NOT STARTED |
| C | Closeout | NOT STARTED |

## 7. Environment traps

The VX-926 record's §7 binds by reference (which binds the VX-912 record's §7). This run adds: never two implementers in one worktree (this run and VX-926 run beside each other under the two-Opus allowance — each stays in its own worktree); the letter's words are hers byte-faithful; all public copy sentence-case, PROVISIONAL posture per the standing rulings.
