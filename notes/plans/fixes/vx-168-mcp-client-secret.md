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

- Unit 1 (VX-168, the secret): **IN-PROGRESS** (opus-implementer, 2026-10-12) — pieces 1–4 DONE (the migration
  `3953c962`; the core rule + ops `b492f6bf`; the shim's preamble `d2966c5f`; the server handshake); pieces 5–6
  remain (the app's faces · the DRILL). The per-piece table and every argued call: the UNIT 1 RECORD at the foot of this file.
- Unit 2 (VX-169 + VX-174, the edit-rung door writes): **NOT-STARTED** — settled design: the kickoff file's
  VX-169 settlement + R-MERGE-1 + the ticket bodies.
- Unit 3 (VX-172 + VX-171, the lens doors): **NOT-STARTED** — settled design: the vx-170 shape file's
  VX-172 adjacency + R-VX171-2.
- Unit 4 (VX-170, lens-aware Takes): **NOT-STARTED** — settled design: the vx-170 shape file, whole.
- Ladder: NOT-STARTED (runs after the last landed unit).
- Closeout: NOT-STARTED.

## UNIT 1 RECORD — VX-168, the per-setup key (opus-implementer, 2026-10-12)

**What this unit did NOT do (said first):** PENDING — filled at the close of the unit.

**Read in full before code (never delegated):** this file (R-VX168-1); the kickoff prompt; the 13n-c plan §3 U8
(lines 591–599) + its §4/§5/§7; the VX-156 brief §12 (K0/K1/K2, L1); `notes/SyncSpec.md` whole (incl. §12's
running record — v1_24's local-only road); `notes/SessionResiliencyProtocol.md` whole; CLAUDE.md + the auto-loaded
canon. The ONE external fact went to one read-only Sonnet lookup (cited below); Claude Code's flag order was read
from the installed CLI's own `claude mcp add --help` (2.1.296): `claude mcp add my-server -e API_KEY=xxx -- npx …`.

### The external facts (cited)

- **Claude Code:** `-e, --env <env...>` is VARIADIC, so it goes AFTER the server name (the CLI's own example) —
  `claude mcp add -s user <name> -e VARIORUM_MCP_KEY=<key> -- "<shim>"`.
- **Codex:** `codex mcp add <name> --env VAR=VALUE -- <command>` — `--env` repeatable, no short form, must precede
  `--` (the command takes `trailing_var_arg`): https://learn.chatgpt.com/docs/extend/mcp?surface=cli (the redirect of
  developers.openai.com/codex/mcp) + `codex-rs/cli/src/mcp_cmd.rs` (`#[arg(long, value_parser = parse_env_pair,
  value_name = "KEY=VALUE")] pub env`).
- **The generic stanza:** `"env": {"VAR": "value"}` is the sibling of `command`/`args` —
  https://modelcontextprotocol.io/docs/develop/connect-local-servers (the `brave-search` example's `"env"`; "add …
  to your `env` key in `claude_desktop_config.json`") · https://cursor.com/docs/context/mcp (field table: "env | No |
  Environment variables for the server") · VS Code's reference (same key, top-level `servers`).

### The design calls, argued

1. **Storage — one column + one table, hashes only (piece 1, `3953c962`).** `mcp_client.setup_key_hash` (the key
   bound to the NAME; NULL = unbound) and `mcp_setup_key(key_hash PK, minted_at)` (a copied key not yet presented).
   A claim MOVES the hash from the table to the client row, so "pending" and "bound" can never both hold one key,
   and a key ties to ONE name (`uq_mcp_client_setup_key`, partial on NOT NULL — unbound is the common case). Why a
   HASH: the key's only legitimate homes are the clipboard and the client's own settings; the library (an encrypted
   store, but also backups, the 13x handoff copy and any future export road) never needs to present it again —
   minting moved to copy time (K2), so nothing ever re-displays a key. Why plain SHA-256 (domain-separated:
   `"variorum.mcp-setup-key.v1:" + key`) and no salt/KDF: the key is 256 random bits, so there is nothing to guess
   or precompute; a slow hash buys nothing. Lookup is an indexed equality on the hash — a timing difference on a
   hash compare leaks nothing usable (finding a matching hash still needs a preimage). LOCAL-ONLY on v1_24's road
   exactly (registered in `MCPGrantSchema.tables`, no `sync_version`, no trigger, export strips it; marker 13).
2. **The key — `vmk1_` + 43 base64url characters** (32 bytes from CryptoKit's generator, `SymmetricKey(size:
   .bits256)` — the vault's own precedent): shell-safe unquoted, JSON-safe unescaped, greppable by its versioned
   prefix.
3. **The rule decides IDENTITY only, once per connection** (`Domain/MCPSetupKeyRule.decide` — pure; every arm
   pinned in `MCPSetupKeyRuleTests`): unnamed → refuse · no key → refuse (any name, bound or not — R-VX168-1) · a
   bound name: its own key → admit, ANY other key → refuse (a fresh key from a newer copy included — the drill's
   impostor) · an unbound KNOWN name + an unclaimed key → BIND (R-VX168-1's "binds the FIRST secret presented under
   it") · an UNKNOWN name + an unclaimed key → a connection REQUEST bound to the key (K2) · a key bound elsewhere →
   refuse · a key never minted here (or no longer held) → refuse. Approval state stays `MCPGrantRule`'s, per call,
   unchanged — a pending request still reads nothing; a denied client still hears "denied".
4. **"Binds at approval" — read as: claimed at FIRST presentation, effective at her approval.** K2's letter is "the
   first name that presents it binds to it at approval"; R-VX168-1's is "binds the FIRST secret presented". Claiming
   at first presentation is what makes "first" well-defined (two tools pasting one copy: the first to connect owns
   it; the second hears the refusal) and a pending request reaches nothing until she approves, so nothing is
   granted earlier than K2 says. No observable difference from binding at the press except that the order is fixed.
5. **The admission is ONE transaction** (`Operations.admitMCPConnection`): read the facts, consult the rule, land the
   effects. Two connections racing one key serialize; the second finds it claimed. A REFUSAL changes nothing about
   the client row (an impostor never refreshes the last-seen or overwrites the declared version — 13n-b's
   first-contact refresh now runs only for an admitted connection) and never enters the waiting room (so a bare
   process can no longer fill the pending room — a side benefit). The refusal is logged in words for her Activity
   list (`connect_bare` · `connect_not_issued` · `connect_another_names_key` · `connect_not_this_names_key` ·
   `connect_unnamed`); a known name's first bind logs `connect_bound` (allowed); a new request logs nothing (it shows
   as a connection request).
6. **The unpresented keys' lifecycle — no TIME expiry; a COUNT cap of 20 (PROVISIONAL P-VX168-U1-3).** Argued: an
   unpresented key buys only (a) a connection REQUEST her approval still decides, or (b) a bind on a name with no
   key bound (her pre-VX-168 clients, a Denied name, an adopted library's names). A process able to read the
   clipboard's history can equally read the client's settings — K2's recorded non-defeat — so expiry defends nothing
   inside the threat model, while it would break the real case "copied tonight, the client first launches the shim
   days later" (Claude Code launches it only at its next session). The cap only bounds the table (oldest first);
   copying 21 times without using the first is the one way to lose a copy, and the client's refusal then says to
   copy a fresh one.
7. **The rotation road — Deny RELEASES the binding (PROVISIONAL P-VX168-U1-1 — a FORK for her).** The gap: without a
   road, a bound name whose tool lost its key (reinstalled; or she re-ran the setup a second time — a fresh key is
   still another key) refuses FOREVER — no door clears a binding. The brief §12 records K1's rotation as "revoke and
   re-approve", and P-13nb-U1-5 makes the client row's revoke a Deny; under K2 that road rotates only if the binding
   goes with the deny. Built: `denyMCPClient` NULLs `setup_key_hash` (the released key is discarded, never returned
   to the unclaimed set); to let a tool back in she approves the client and runs its setup again (the fresh key
   binds the unbound name). Cost, said plainly: the Deny confirm's words grow ("…until you approve it and run its
   setup again"), and Deny still revokes every grant (13n-b's rule, untouched). **Options for her (QUESTIONS at the
   merge — the shared ledger is the merging session's):** (a) as built; (b) keep the binding through Deny and add an
   explicit "Forget its setup" door on the client row (a UI addition — her design call); (c) no rotation road (a
   lost key strands the name — the dead end this record names).
8. **An adopted library releases every binding (PROVISIONAL P-VX168-U1-2).** `landMCPAfterAdoption` (R-13nb-6's
   once-per-hold landing) also NULLs every binding and empties the unclaimed set in the same transaction. Argued:
   every binding names a key held in some client's settings on the Mac the library came from (or its earlier self);
   kept, every tool on the adopting Mac would refuse until Deny — which revokes its grants. Released, each approved
   client binds the first setup run on THIS Mac — R-VX168-1's "just re-run the setup", grants kept. Cost: a same-Mac
   restore also asks one re-run per client (the server lands OFF anyway — she is already acting).

### LIVE STATUS — Unit 1's pieces

| piece | what | status |
|---|---|---|
| 1 | the local-only migration `v1_26_mcp_setup_keys`, alone | DONE `3953c962` — `MCPGrantSchemaTests` + `SyncSchemaTests` 20/2 green headless |
| 2 | core: `Domain/MCPSetupKeyRule` + `Operations+MCPSetupKeys` (mint · admit) + Deny/adoption release + `MCPClient.isSetupBound` | DONE (this commit) — `MCPSetupKeyRuleTests` + `MCPSetupKeyOperationsTests` + the grants/adoption/schema suites 44/5 green headless |
| 3 | the shim's preamble (`MCPPreamble`, `VariorumMCPSocket`) + "MCP-blind" | DONE (this commit) — `MCPPreamble` (the env variable `VARIORUM_MCP_KEY`; the line `variorum-mcp-key <key>`, never JSON; `classify` for the app's read), `MCPShim.serve` (preamble first when keyed, nothing of its own when bare, then the pump), A-2's comments amended to MCP-blind (`MCPShim.swift`, the shim's `main.swift`); `MCPShimTests` 11/1 green headless |
| 4 | the server handshake + the harness's keyed `connect(as:)` + socket-road pins | DONE (this commit) — `MCPHandshake` (the opening read byte-exact on its own thread: preamble → `initialize` frame; the ONE refusal sentence `MCPHandshake.refusal`, PROVISIONAL P-VX168-U1-4), `MCPSession.run` decides ONCE through `admitMCPConnection` (fail-closed on a store error) — refused: the shim's refusal shape answering the frame's id, then the host closes; admitted: the frame REPLAYED into `MCPSocketTransport(replay:)`, the SDK hook only checks the name and sets it (`recordMCPContact` moved into the admission); the over-cap refusal reads past a preamble to answer by id (a real fix the preamble needed). The harness: `connect(as:)` presents the name's own setup key (minted once per name, as a copy); `connect(as:presenting:)` + `rawOpen` for the arms; three raw-socket pins justified-edited (the over-cap flood, the advice-at-initialize, the pump — now `MCPShim.serve` keyed). `MCPSetupKeyServerTests` (7: a fresh client end to end · two tools told apart · a bare shim · R-VX168-1's approved-unbound bind · every arm one sentence byte-identical · the opening read · the initialize parse). **`VariorumMCPTests` 103/15 green headless** (13n-c's close: 93/14) |
| 5 | the app: mint at copy (all three clients), L1, the Deny confirm, the activity words, the guide's limit sentence | DONE `452526e0` + the pin fix (this commit) — the Mac batch under the held stage claim `vx168-u1`: **194/16 green** (CapabilityRegistry · MCPAsksWait · MCPAskAndReceipt · MCPPane · MCPWingFaces · MCPEditFaces · MCPNavigation · MCPShareFaces · MCPGrantSheet · MCPSetupMenu · TutorialMCPChapter · TutorialFurnitureFold · LaunchFurniture · TutorialBuildFlavor · SampleLibraryWelcome · the 13n-b U3 activity face) after one justified edit (lesson 2's Claude Code prefix pin: the line now clears an earlier setup first), then the guide-wide suites **49/6 green** (TutorialBookShape · TutorialDoor · TutorialCurrency · TutorialBooksLesson · TutorialPrivacyChapter · TutorialFannedMatrix) — **the setup menu** (inside the O-4 fence): Claude Code = `claude mcp remove -s user <name> >/dev/null 2>&1; claude mcp add -s user <name> -e VARIORUM_MCP_KEY=<key> -- "<shim>"` (the REPLACE step because `claude mcp add` refuses an existing name — probed in a scratch HOME, her `~/.claude.json` untouched; idempotent in zsh and bash; without it her R-VX168-1 re-run would fail on her existing registration), Codex = `codex mcp add <name> --env VARIORUM_MCP_KEY=<key> -- "<shim>"` (no replace step: `codex mcp add` overwrites by map insert — the second Sonnet lookup, `codex-rs/cli/src/mcp_cmd.rs` `run_add` lines ~447–458 `servers.insert(...)`; `run_remove` exits 0 on an absent name), the stanza gains `"env": {"VARIORUM_MCP_KEY": …}`; the Claude Code sentence says it replaces an earlier setup, the any-client sentence names the variable a path-only client also needs. **The door** (`MCPDoor.copySetupCommand`, now async): mints through the session's runner (P2) and writes the clipboard only once the key is kept; no library → `setupNeedsLibrary`, nothing copied. **The pane:** the shown setup MASKS the key (`MCPPaneCopy.shownKey`, eight bullets) + `keyLine` under it; L1 true-er (`clientBoundary`, its own 5-line room); the Deny confirm "…until you approve it and run its setup again"; Activity words for the five `connect_*` refusals and `connect_bound`. **The guide** lesson 2's limit sentence (falsified: "Variorum can't check that name") rewritten true of the build with K2's non-defeat. `MCPSession.instructions` UNCHANGED (no sentence falsified: a refused connection never reads it; an admitted one's facts are unchanged). Justified edits (the ritual): `MCPSetupMenuTests` (4), `MCPPaneTests` (2), `MCPGrantSheetTests` (L1), `TutorialMCPChapterTests` (lesson 2, pinned against the rule), the U5 capture harness (attached; `await`) |
| 6 | the DRILL (dev store, held stage claim) + evidence | NOT-STARTED |
