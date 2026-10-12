# VX-168 — the per-setup client secret (+ riders VX-169 · VX-172 · VX-174 · VX-170 · VX-171)

**The RUN record.** Kickoff: `notes/plans/vx-168-kickoff-prompt.md` (her mandate 2026-10-11; the pre-run
sitting 2026-10-12). Branch `vx-168-mcp-client-secret`, worktree `~/dev/variorum-vx-168`, PR `VX-168: …`.
Cast: Fable orchestrates, `opus-implementer` builds, `fable-reviewer` ladders (the secret's accept path is
Fable's per her protocol). Design sources: the 13n-c plan §3 U8 + `notes/plans/vx-156-grant-ux-brief.md`
§12 (K2) · the VX-169 settlement in the kickoff file · `notes/plans/vx-170-lens-aware-takes.md` (ratified
2026-10-11 — VX-170, VX-171 R-VX171-2, VX-172's adjacency, VX-174's R-MERGE-1) · the ticket bodies.

## Her rulings landed at kickoff (2026-10-12, the orchestrator chat — recorded here as the kickoff file does)

- **R-VX168-1 — NO GRANDFATHERING MACHINERY (her word at tonight's kickoff, asked before she slept):**
  *"it's only me on here and all i have to do is re-run the setup? no need for the grandfathering
  machinery."* So: once the secret lands, a name arriving WITHOUT its secret refuses — uniformly, bound
  or not (the drill's "a bare shim refused" holds globally). The one branch that makes "just re-run the
  setup" literally true: an APPROVED name with NO bound secret binds the FIRST secret presented under it
  (no revoke, no re-approval ceremony); from that moment a wrong or absent secret under the name refuses.
  New clients bind at approval exactly as K2 says. **Her morning consequence, hers by this ruling:** after
  the closeout /Applications refresh, her existing clients refuse until she re-runs each one's setup
  command from the pane's setup menu — the handoff leads with it.
- **VX-169 settled at the pre-run sitting (the kickoff file carries it verbatim):** rung = EDIT;
  `kind='manual'` with the client's name PREFIXED in the stored message ("‹client›: her message"); a new
  kind is OFF tonight by mechanism (`commit_point.kind`'s CHECK lives on a synced table — a third kind is
  a §12 lockstep event, available someday behind its own window). Sealed post and locked take refuse.
  Dedup-vs-append on byte-identical text is the implementer's argued call (PROVISIONAL).

## Scope — four acceptance units, strictly sequential, one implementer session each

| unit | tickets | shape | evidence (its kind) |
|---|---|---|---|
| **1** | VX-168 | The per-setup secret: a LOCAL-ONLY migration in its OWN COMMIT (the v1_24 family's registration road; zero lockstep, marker 13 untouched); all three setup-menu clients carry a fresh secret; the shim sends a one-line preamble before the first frame (A-2's "protocol-blind" → "MCP-blind" — said here, below); the server binds per R-VX168-1 and refuses a name without its secret; the pane's boundary line (L1) made true-er, never promising more | **The DRILL** under a held stage claim, dev store only: a fresh client end to end; two tools under one name told apart (the impostor refused); a bare shim refused. Plus state-transition pins + the suites over changed surfaces |
| **2** | VX-169 + VX-174 | The deliberate edit-rung door writes: `save_commit` (as settled above) · `choose_take` (per block) · apply-lens-as-chosen (wholesale) — each one of §9's existing operations under the grant guard INSIDE the op's transaction, ONE client-named undo entry each; truth docs (guide/advice) only where stale | State-transition pins; VariorumMCPTests headless; red-on-old pins for any bug-class fix |
| **3** | VX-172 + VX-171 | `read_note` gains `lens_id` (per block the lens take else chosen; `with_ids` says `via: lens \| chosen`; dangling/foreign lens_id = the uniform not-shared shape, no oracle) · blank-take blanking door-only per R-VX171-2 (`add_take` + `create_note` takes accept empty; `edit_take` to empty still refuses — P-VX171-2); zero schema in this unit's diff | Door tests incl. the byte-for-byte lens-render match vs the Mac's lens read, the blank round trip; headless |
| **4** | VX-170 | Lens-aware Takes per the ratified shape file, nothing else: the four forms (R-VX170-1), collapsed one-line non-matches (R-VX170-2), match expands filter-named + chosen (R-VX170-3), the masthead `show ▾` popover (R-VX170-4), session-only per-note memory (R-VX170-5); a blank take is an ordinary take in every form (P-VX170-1) | View-model tests over a fanned fixture (all four forms, collapsed/expanded, memory reset, zero-match honesty) + ONE use-shaped walk on a real multi-lens dev-store note under a held stage claim |

**Order 1 → 2 → 3 → 4** (the gate first; the UI unit last — if the night runs short it is the NAMED
fall-out, ticket kept, never vagueness). Sizing said plainly per `notes/PhaseSizingGuidance.md`: four
units, none phase-sized, one per session — inside the guidance; stated to her at kickoff with the
blocker report, nothing raised back.

**The ladder (the RUN rule):** ONE `fable-reviewer` cold ladder over the whole run's diff after unit 4
(or after the last unit that lands), `notes/REVIEW_PROMPT.md` verbatim, fresh reviewer per round, cap
three. Pin-before-fix binds PER MEMBER; hallucination guard as ever (no fix without a traced mechanism;
red-on-old verified by revert).

**Standing constraints:** commits say `Part of VX-168`, NO attribution trailers; push after every commit;
never touch `Sources/VariorumCore/Sync/`, custody/keychain, or the editor seam (`BlockRangeIndex` ·
`EditorTextView` · `PaneTextAuthority` · `PaneSurface` — if a unit's build seems to need them, STOP and
report); never the real store except the end-of-run A1 refresh; O-4 provider-neutrality + setup-copy
fences stay green; docs updated only where the build makes them stale; PROVISIONAL-and-log non-gating
ambiguity, stop on gating ambiguity.

**Surfaces declared (the kickoff overlap check — in-flight table empty, no overlap):**
`Sources/VariorumMCP/` (session/host/transport/tools/grant authority) · `Sources/VariorumMCPSocket/` +
`App/Variorum/VariorumMCPShim/` (the shim + preamble) · `Sources/VariorumCore/Persistence/Migrations.swift`
+ the MCPGrantSchema DDL home (local-only migration) · `App/Variorum/Variorum/Features/MCP/` (pane copy,
setup menu, L1) · the Takes mode's view model + board faces (unit 4) · `Sources/VariorumCore/Operations|Queries`
only as the door tools' existing-op call sites need · the field guide's MCP chapter + `MCPSession.instructions`
(truth-pinned updates only).

**A-2's letter, amended here as the kickoff instructs:** the shim was "protocol-blind"; with the
preamble it is **"MCP-blind"** — it still parses nothing of MCP; the one thing it knows is to speak its
setup-minted secret as a single preamble line on the socket before pumping bytes.

## LIVE STATUS (per the resiliency protocol — flipped in the same commit as each piece)

- Unit 1 (VX-168, the secret): **IN-PROGRESS** (opus-implementer, 2026-10-12) — piece 1 the LOCAL-ONLY migration
  `v1_26_mcp_setup_keys` ALONE (this commit; pins `MCPGrantSchemaTests` PENDING the headless run). Remains, in order:
  (2) core — the pure `Domain/MCPSetupKeyRule` + the ops (mint at copy, admit-per-connection, Deny releases the
  binding, adoption releases bindings) + state-transition pins; (3) the shim's preamble (`MCPPreamble` in
  `VariorumMCPSocket`) + "MCP-blind" comments; (4) the server handshake (`MCPSession` reads the preamble + the
  first frame, decides through the op, refuses uniformly with the shim's refusal shape, else replays the frame
  into the transport) + the harness's keyed `connect(as:)` + socket-road pins; (5) the app — the setup menu mints
  at copy (all three clients carry `VARIORUM_MCP_KEY`), L1 true-er, the Deny confirm, the activity words, the
  guide's honest-limit sentence; (6) the DRILL on the dev store under a held stage claim + the UNIT 1 RECORD
  below. The design calls are argued in the UNIT 1 RECORD (written as each piece lands).
- Unit 2 (VX-169 + VX-174, the edit-rung door writes): **NOT-STARTED** — settled design: the kickoff file's
  VX-169 settlement + R-MERGE-1 + the ticket bodies.
- Unit 3 (VX-172 + VX-171, the lens doors): **NOT-STARTED** — settled design: the vx-170 shape file's
  VX-172 adjacency + R-VX171-2.
- Unit 4 (VX-170, lens-aware Takes): **NOT-STARTED** — settled design: the vx-170 shape file, whole.
- Ladder: NOT-STARTED (runs after the last landed unit).
- Closeout: NOT-STARTED.
