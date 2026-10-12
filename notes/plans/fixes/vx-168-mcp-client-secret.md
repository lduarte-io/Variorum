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

- Unit 1 (VX-168, the secret): **UNIT CLOSED — DONE** (opus-implementer, 2026-10-12, ~02:45 MDT): the migration
  `3953c962` · the core rule + ops `b492f6bf` · the shim's preamble `d2966c5f` · the server handshake `ccc4f30c` · the
  app's faces `452526e0` + `251e8b17` · the DRILL PROVEN on the dev store + the final suites green (`3601ef81` and the
  close commit). Owed to the orchestrator: the PROVISIONALs' QUESTIONS entries and the canon deltas at the merge (the
  UNIT 1 RECORD's "OWED" list); the ladder over the run's diff (the secret's accept path is FABLE's — named there).
- Unit 2 (VX-169 + VX-174, the edit-rung door writes): **UNIT CLOSED — DONE** (opus-implementer, 2026-10-12):
  start `93b3e083` · core `7240827c` · wire + the app's word tables `8cc8af87` · the guide + faces `ec95ab62` · the
  close (this commit). Headless by design — no live client round was run (the UNIT 2 RECORD's first line). Owed to
  the orchestrator: the PROVISIONALs' QUESTIONS entries and the canon delta at the merge (its OWED list); the ladder
  over the run's diff.
- Unit 3 (VX-172 + VX-171, the lens doors): **UNIT CLOSED — DONE** (opus-implementer, 2026-10-12): start
  `f75186fc` · the blank-take doors `6d4c73fe` · the lens read + its door tests `2a260897` · the close `6210bb24`
  (+ a record-only hash fix-up). Headless by design — no live client round, no Mac test run (the Mac target BUILT); the UNIT 3 RECORD's
  first line. **P-VX171-2's premise was false** (edit_take to empty was never refused) — the refusal is BUILT,
  PROVISIONAL (P-VX168-U3-2). Owed to the orchestrator: the PROVISIONALs' QUESTIONS entries and the canon delta at
  the merge (its OWED list); the ladder over the run's diff.
- Unit 4 (VX-170, lens-aware Takes): **UNIT CLOSED — DONE** (opus-implementer, 2026-10-12): start `dc827cd3` · the core
  rule `b0f67cbf` · the board `dffa8351` · the Mac pins `96b33874` · the walk + its two fixes `39fd6db5` · the close (this
  commit). The walk PROVEN on the dev store (both voices, every leg); the Mac batch 616 tests / 83 suites green; the whole
  package headless green. Owed to the orchestrator: the PROVISIONALs' QUESTIONS entries, the §12 canon delta and the
  MOBILE PARITY line at the merge (its OWED list); the ladder over the run's diff.
- Ladder: NOT-STARTED (runs after the last landed unit).
- Closeout: NOT-STARTED.

## UNIT 1 RECORD — VX-168, the per-setup key (opus-implementer, 2026-10-12)

**What this unit did NOT do (said first):** (1) **no Codex client was run** — `codex` is not installed on this Mac;
its command's syntax and its overwrite-on-re-add behaviour are cited from the source (below), and the drill's "fresh
client" leg used the ANY-CLIENT stanza with a scripted stdio client through the REAL Debug shim (the 13n-c walk's own
precedent for a fresh name — a real Claude Code client always names itself `claude-code`, which this dev store
already knew); the REAL Claude Code client drove the R-VX168-1 leg. (2) **No `notes/QUESTIONS.md` entry and no canon
edit** — both are the merging session's (CLAUDE.md: the shared ledgers move only at merge moments); the entries and
deltas owed are listed under OWED. (3) **No client-row hint for an approved-but-unbound client** (e.g. "run its setup
again") — considered and left out as a face the rulings do not ask for; her Activity list says it the first time such
a client is refused, and the handoff leads with her re-run. (4) **Dark appearance not captured** — the drill ran in
Study light, plus Terminal light captures of the four changed faces (no new colour or token was introduced). (5)
`MCPSession.instructions` (the advice) was NOT changed — no sentence of it is falsified by the build (a refused
connection never reads it; an admitted one's facts are unchanged).

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
| 6 | the DRILL (dev store, held stage claim) + evidence | **DONE — PROVEN, every leg** (02:05–02:40 MDT, Study, light; the evidence below in "THE DRILL"); cleanup done: the scratch `-s local` registration removed (her user scope `linear-server` + `variorum` untouched, read before and after), the dev instance quit by identity (`pgrep` empty), the dev store RESTORED from `scale-prestage-20261012T080538Z` ("Restored (verified)", cmp), the clipboard emptied, the socket gone, the stage released. Terminal-voice captures of the changed faces: see piece 7 |
| 7 | the final suites + Terminal captures of the changed faces | **DONE** — the whole package headless: `VariorumMCPTests` **103/15** · `VariorumCoreTests` **2,658/303** · `StringsWorkbookTests` **40/6**, ALL GREEN on the final run (the run before it: the migration pins needed v1_26's table + two indexes — justified edit `3601ef81`; the run between: one P1 timing benchmark, `timelinePageIsFlatOrUnderBudgetInCorpusSize`, red under the parallel load, green alone 6/1 twice and in the final run — load-sensitive, untouched by this diff). The Mac batch (piece 5): 194/16 + 49/6. **Terminal light** (claim `vx168-u1` 02:30–02:44, a second A1 prestage `scale-prestage-20261012T083018Z`, restored "verified" after; nothing denied — the confirm was cancelled): `t1` L1 whole in three lines, `t2` the masked setup + the key line whole, `t3` the Deny confirm (zero-grant form) whole. Stage released; no instance; clipboard empty |

### THE DRILL — the unit's acceptance evidence (dev store only, stage `vx168-u1`, 2026-10-12 02:05–02:44 MDT)

**Machine:** unlocked; this host's Accessibility + Screen Recording granted; her `/Applications/Variorum.app` ABSENT
throughout (checked before every GUI step by `Tools/WalkKit/guard.sh` and before every client turn); the Debug app
`App/Variorum/DerivedData/vx168-u1/…/Variorum.app` (`io.lduarte.Variorum.debug`) on the dev store, the store first
copied A1-style (`scale-prestage-20261012T080538Z`) and RESTORED from it at the end (cmp-verified). The dev store
arrived with its server ON and four clients approved by earlier walks (`claude-code` 3 grants, `u3-walk`, `u2-walk`,
`u1-walk`) — all UNBOUND once v1_26 ran: R-VX168-1's starting state exactly. Evidence:
`notes/plans/vx168-screens/u1/` (gitignored) — captures `d0…d13`, `t1…t3`, and `transcripts/` (every client
transcript as JSON; every key REDACTED to its first 9 characters — a grep for a whole key finds none).

| leg | what was done | outcome |
|---|---|---|
*[removed for publication]*
*[removed for publication]*
| **(3) a bare shim** | the Debug shim with NO `VARIORUM_MCP_KEY`, under a brand-new name `vx168-stray` (`c1`) and under the approved-but-unbound `claude-code` (`c2`) | both REFUSED, the same body; never entered the waiting room. **All four refusals so far were ONE byte-identical JSON body** (scripted compare: "1 distinct body over 4 refusals") — no oracle between wrong key, no key, and no binding |
*[removed for publication]*
*[removed for publication]*
| **the faces** | L1 under Clients (`d10`, Study; `t1`, Terminal); the masked setup + the key line (`d1`, `d5`; `t2`); the Deny confirm (`d11`; `t3` the zero-grant form) | every face whole in both voices (L1 three lines in its five-line room) |

**Cleanup (02:40, 02:44):** `claude mcp remove variorum-dev -s local` ("…from local config"; the scratch folder's servers
`[]`); her user-scope servers read BEFORE and AFTER: `['linear-server', 'variorum']` — untouched; the dev instance
quit by identity (`pgrep` empty); the dev store restored twice from the prestage copies ("Restored (verified)"); the
socket gone; the clipboard emptied; the stage released ("STAGE FREE").

### PROVISIONALs (each wants a `notes/QUESTIONS.md` entry at the merge — the merging session's ledger)

- **P-VX168-U1-1 — Deny releases the binding (the rotation road).** Options: (a) as built — K1's "revoke and
  re-approve" carried to K2; (b) keep the binding through Deny and add an explicit "Forget its setup" door on the
  client row; (c) no rotation road (a lost key strands the name forever). Drill leg (5) shows (a) working.
- **P-VX168-U1-2 — an adopted library releases every binding** (13x handoff/restore): options (a) as built; (b) keep
  bindings (a same-Mac restore then needs no re-run, but a handed-off library's tools all refuse until Deny, which
  revokes grants).
- **P-VX168-U1-3 — unpresented keys: no time expiry, a count cap of 20.** Options: (a) as built; (b) a time window
  (24 h / 7 d) — defends nothing in K2's threat model and breaks "copied tonight, launched days later"; (c) no cap.
- **P-VX168-U1-4 — the client's one refusal sentence** (`MCPHandshake.refusal`, her copy pass) — and its last
  clause depends on P-U1-1 ("…the author must deny it there and approve it again first").
- **P-VX168-U1-5 — the pane's new words** (`clientBoundary` L1, `keyLine`, `setupNeedsLibrary`, the Deny confirm's
  clause, the `connect_*` Activity phrases, the Claude Code / any-client sentences, the guide's limit sentence) — her
  copy pass, 13s-a-sweepable.
- **Argued, not provisional (recorded above):** hash-only storage (domain-separated SHA-256); claim-at-first-
  presentation as the reading of "binds at approval"; Claude Code's replace step (an external fact, probed).

### OWED (for the orchestrator)

1. **Canon deltas at the merge** (AppSpec §12's THE MCP DOOR line): "the protocol-blind `variorum-mcp` stdio shim" →
   **MCP-blind** (it speaks its setup key as one preamble line); "A-4's honest boundary (client identity is
   self-declared and the pane says so — the per-setup secret is VX-168, pre-launch)" → the build's truth: a name is
   bound to its setup's key (K2 as built: claimed at first presentation, a bare or other key refused, R-VX168-1's
   unbound-name bind), the recorded non-defeat said; §7's local-only MCP grants family gains **v1_26**
   (`mcp_setup_key` + `mcp_client.setup_key_hash`, zero lockstep). The QUESTIONS entries above.
2. **Her morning (the handoff's lead, R-VX168-1's consequence):** after the /Applications refresh her approved clients
   arrive UNBOUND and refuse until she re-runs each one's setup from Settings ▸ MCP ▸ Connect a client. **Claude Code's
   copied line now REPLACES her existing user-scope `variorum` registration first** (without that step `claude mcp
   add` would fail: "MCP server variorum already exists in user config") — one paste, then a new Claude Code session.
   Codex's `codex mcp add` overwrites by itself. Her approvals and grants are kept; the first connection binds.
3. **The ladder's map (the secret's accept path is FABLE's, her protocol):** `Sources/VariorumCore/Domain/
   MCPSetupKeyRule.swift` (the decision) · `Operations+MCPSetupKeys.swift` (`mintMCPSetupKey`, `admitMCPConnection`
   — the one transaction) · `Operations+MCPGrants.swift` (`denyMCPClient`'s release, `landMCPAfterAdoption`'s
   release) · `Sources/VariorumMCP/MCPHandshake.swift` + `MCPSession.run` (the opening read, fail-closed admission,
   the replay, the SDK hook's name check) · `MCPServerHost.refuseOverCap` (reads past a preamble) ·
   `Sources/VariorumMCPSocket/MCPPreamble.swift` + `MCPShim.serve` · the migration `v1_26` · the app's
   `MCPDoor.copySetupCommand` (mint-then-clipboard) and the setup texts in `MCPPaneCopy`'s O-4 fence.
4. **Noticed, not this unit's:** the Settings pane's scroll position jumps when a copy reflows the setup text (the
   Copy button moves between y≈329 and y≈455 with the chosen client) — chrome taste, recorded for the UX pass.

## UNIT 2 RECORD — VX-169 `save_commit` + VX-174 `choose_take` / `adopt_lens` (opus-implementer, 2026-10-12)

**Read in full before code (never delegated):** this file (R-VX168-1, the UNIT 1 RECORD); the kickoff prompt (the
VX-169 settlement block, the VX-174 rider); `notes/SessionResiliencyProtocol.md` whole; the 13n-b plan's ruled design,
SITTING RECORD (R-13nb-1…18), AF-1…AF-11, the seam rulings A-1…A-10, the U3 brief + U3 record (the edit-rung precedent:
the in-transaction guard, P-13nb-U3-1…17); the 13n sitting record's R-13n-6/R-13n-7; the 13n-c plan's HER SITTING
block (VX-169's birth); `notes/plans/vx-170-lens-aware-takes.md` (R-MERGE-1); the ticket bodies VX-169 + VX-174 (Linear
GraphQL); CLAUDE.md + the auto-loaded canon (AppSpec §9's commit / chooseVariant / adopt-lens / structural-undo lines).
Code read: `MCPWriteTools{,+Edit,+Carriage}`, `MCPWriteSupport`, `MCPToolCatalog`, `MCPSession` (the advice),
`Operations+MCP{Edits,Writes}`, `Operations+{Variant,Placement,Lens,Versions}`, `MCPEditQueries`, the app's
`MCPPaneCopy` (activity + receipt words), `MCPDoor.landReceipt`, the guide's MCP chapter, and their pins.

### LIVE STATUS — Unit 2's pieces

| piece | what | status |
|---|---|---|
| R0 | this record + the plan | DONE (this commit) |
| P1 | core: `commit(… guardedBy:)`; `Operations+MCPDeliberate` (the client commit's message, `chooseTake`, `adoptLensAsNote` — each guard-first in its own transaction, the two pointer acts ONE client-named undo entry each); `Queries.mcpContainerOf(lens:)`; `MCPWriteAct` + `.commit`/`.choice`/`.lensAdoption` + `isUndoable`; her doors' row work extracted byte-for-byte (`choosablePlacement`, `adoptSwapRows`, the pointer/lens restore bodies) so ONE brain serves both; core state-transition pins | DONE (this commit) — `MCPDeliberateActsTests` 17/1; the extraction's parity proof: `VersionOperationsTests` (the adopt-swap pins) + `RedoStackTests` + every `chooseVariant`/`commit` caller GREEN UNMODIFIED — the whole core target headless **2,675/304** (baseline 2,658/303), only the standing gated skips |
| P2 | the wire: `save_commit` · `choose_take` · `adopt_lens` declared at EDIT, parsed, guarded (snapshot decision + in-transaction re-decision, `MCPWriteTools+Deliberate`); the advice's two truths; socket-road pins (each act, each refusal arm, the once grant, the suggest/write-new PROOF extended) — PLUS the app's word tables moved here from P3 (P1's new `MCPWriteAct` cases left the Mac's exhaustive receipt switch uncompilable; this commit closes that one-commit gap) | DONE (this commit) — `MCPDeliberateServerTests` 7/1; justified edits (the ritual): the catalog walk (`MCPServerTests`), the edit-rung PROOF + its listing pin (`MCPEditServerTests`: the three tools, a lens of hers, the snapshot reads `lens`/`lens_choice`), the suggest PROOF (`MCPWriteServerTests`: every catalog door tried); **`VariorumMCPTests` 110/16 headless** (baseline 103/15); the core no-op moved to the SHOWN take (P-VX168-U2-5) with its pins, core suites re-run green; the Mac target BUILDS (`xcodebuild build`, `DerivedData/vx168-u2`) |
| P3 | the app's faces: (the word tables landed in P2) the guide's two sentences (lesson 1's undo promise, lesson 3's Edit step); Mac pins for the words, the receipt's undo rule and the guide's truths + the Mac batch under a held stage claim | DONE (this commit) — `MCPDeliberateFacesTests` 4/1 (new); `TutorialMCPChapterTests` gains the two sentences' prose + TRUTH pins (additions beside the standing pins — none edited); the Mac batch under the held claim `vx168-u2` (released): **95/9** (MCPDeliberateFaces · MCPAskAndReceipt · MCPWingFaces · MCPEditFaces · MCPPane · MCPAsksWait · MCPShareFaces · MCPNavigation · TutorialMCPChapter) + **98/12** (TutorialBookShape · TutorialDoor · TutorialCurrency · TutorialBooksLesson · TutorialPrivacyChapter · TutorialFannedMatrix · TutorialFurnitureFold · TutorialLookingActs — her adopt door through the extraction · TakesBoard — her choose/adopt from the board · SampleLibraryWelcome · LaunchFurniture · TutorialBuildFlavor), all green, zero skipped |
| P4 | close: the final headless suites, the argued calls/PROVISIONALs/OWED below, Unit 2 → DONE | DONE (this commit) — the whole package headless: **`VariorumMCPTests` 110/16 · `VariorumCoreTests` 2,675/304 · `StringsWorkbookTests` 40/6**, all green (the run before it: ONE transient socket "Broken pipe" in a read-only U4 test — OWED 5); the advice trimmed to 1,941 characters after it, `VariorumMCPTests` re-run 110/16 |

**What this unit did NOT do (said first):** (1) **no live client round** — the unit is headless by design (the brief);
no real client has yet saved a commit, chosen a take or made a lens the note over the socket against the dev-store
app, and her ⌥⌘Z over those acts is pinned headless only (the orchestrator's call whether the ladder wants a live
leg). (2) **No Mac mutation run** of the receipt's undo-claim rule — its pins are exact string equalities, so a
dropped rule fails them by construction; the six core/wire mutations below were run. (3) **No `notes/QUESTIONS.md`
entry and no canon edit** (the merging session's ledgers — OWED). (4) **The grant sheet's edit sentence
(`MCPPaneCopy.rungDetail(.edit)`: "it can also edit takes — with a commit before and after every change…") and the
pane toggle's blurb (`enableBlurb`: "…a client changes your text only where you grant it edit, with a commit before
and after every change") are UNCHANGED** — argued not falsified (choosing a take or making a lens the note writes no
take's text; the same looseness has stood for `delete_block` since 13n-b U3) and flagged for her copy pass (OWED 6).
(5) **No `expected`-state precondition** on `choose_take`/`adopt_lens` — her doors carry none, a pointer move loses
nothing and is one undo; not invented. (6) Lesson 7's "⌥⌘Z takes a client's act back, one act at a time" left as
it stands (it says what ⌥⌘Z does; lesson 1 now states the exception).

### The design calls, argued

1. **`save_commit` registers NO undo entry — the most spec-defensible reading, and the only one the mechanism
   allows tonight.** R-13n-6's own letter is *"Every MCP write registers structural undo/redo **exactly as her
   gestures do**"* — and her commit gesture registers none (AppSpec §9: structural undo EXCLUDES commits). A commit is
   append-only (I5), and `commit_point` carries no tombstone column: the only inverses are a physical DELETE of a
   synced row (breaks S2) or a new column (a §12 lockstep event — off tonight by the same mechanism that settled the
   kind). P-13nb-U2-4's "every MCP write" widened R-13n-6 to acts that HAVE tombstones (comment, tag, lens, book); a
   commit has none. The precedent that matches is P-13nb-U3-2: `edit_take`'s bracket commits already stay when ⌥⌘Z
   walks the edit back. **Every face was made true of it:** `MCPWriteAct.isUndoable` (false for `.commit` alone); the
   receipt says "⌥⌘Z undoes" only over a run holding an undoable act (a commit-only run: "‹client› committed a take");
   the advice's undo sentence ("…named after you; commits stay."); the guide's lesson 1 promise ("…except a commit,
   which stays, as yours do.").
2. **`save_commit` is her commit, exactly** (`commit(… guardedBy:)` — the seam her other ops carry, nil on her
   doors): `kind='manual'` (the settled kind), the stored message `"‹client›: ‹message›"` through the one
   savepoint-name rule (`Operations.mcpCommitMessage`), an ARCHIVED take may commit (her 2026-07-05 ratification), a
   locked take and a seal refuse with the op's own words, and §10's manual-commit major-revision stamp lands as hers
   does (P-VX168-U2-2 states the consequence).
3. **`choose_take` is her ✓** (`chooseVariant`'s guards extracted byte-for-byte as `choosablePlacement`): the block
   live and placed, the note unsealed, the take live, ACTIVE and this block's; a LOCKED take may be chosen (the lock
   guards the buffer). ONE client-named entry ("‹client›'s take choice") restoring the slot's exact pre-image pointer —
   nil included — through the one pointer brain (`revertChosenPointers`); a pointer move: no text, no touch, no churn.
4. **`adopt_lens` is her "✓ Make this the note"** — `adoptLensPreservingChosen` (R89/R92: adopting SWAPS, never
   destroys — the outgoing chosen kept as a "chosen until …" lens), NOT the bare `adoptLens` (no door renders it; only
   tests call it). Its body extracted byte-for-byte as `adoptSwapRows`. ONE client-named entry ("‹client›'s lens
   adoption") whose inverse and redo each run in ONE transaction (`restoreChosenPointers` + the lens tombstone/revive
   bodies extracted from `save_lens`'s own undo) — P-VX168-U2-4.
5. **One brain, her pins as the parity proof:** every extraction (`choosablePlacement`, `adoptSwapRows`,
   `restoreChosenPointers`, `tombstoneSavedLens`/`reviveSavedLens`) is a byte-for-byte move with her door calling the
   moved body; `VersionOperationsTests` (the adopt-swap), `RedoStackTests`, every core `commit`/`chooseVariant` caller,
   the app's `TutorialLookingActsTests` (her adopt door) and `TakesBoardTests` ran green UNMODIFIED.
6. **The edit rung's two decisions, as every edit act** (AF-10 (a)): the snapshot (`onNote`, `spendsAfter: false`)
   speaks the refusal and raises the ask; the `WriteGuard` re-resolves the note from the take / the lens INSIDE the
   act's transaction, decides at EDIT, and spends any once grant there (a refused act rolls its spend back — pinned;
   an authorized no-op spends it — P-13nb-U3-3's letter, carried).
7. **Addressing:** `take_id` alone (`save_commit`, `choose_take` — the take names its block, as `edit_take`'s does);
   `lens_id` alone (`adopt_lens` — the lens names its note; `Queries.mcpContainerOf(lens:)`, live lenses only). A dead,
   foreign, version's or scraps-group id answers the ONE not-shared answer, byte-identical to an id naming nothing
   (pinned — no oracle).
8. **Receipts' "Open ›":** a commit lands her on the block (Write); a choice on the block's takes (Takes — where her ✓
   lives); an adoption on the note.

### Mutation checks (each applied to the committed tree, its suites run, restored by `git checkout --`; tree clean after)

M1 `chooseTake`'s guard dropped → red (the guard pin + the socket fence pin) · M2 `adoptLensAsNote`'s guard dropped →
red (same pair) · M3 `commit`'s guard dropped → red (the guard pin, the fence pin, the once-grant pin) · M4 the choice's
no-op dropped → red (3 pins) · M5 the adoption's undo leaving its lens → red (core + socket) · M6 the lens no-op
dropped → red (core + socket).

### PROVISIONALs (each wants a `notes/QUESTIONS.md` entry at the merge — the merging session's ledger)

- **P-VX168-U2-1 — `save_commit` appends ALWAYS (no dedupe on byte-identical text).** Argued: her ⌘S never dedupes
  (the auto occasions' dedupe is an INSURANCE convention, §9; a deliberate commit's message is new even when the text
  is not — "fact-checked, no changes" is the point). Options: (a) as built; (b) dedupe against the take's last commit
  TEXT (the auto occasions' rule — `changed: false`, nothing written); (c) dedupe an exact repeat only (same text AND
  same message as the last commit — swallows a retried call).
- **P-VX168-U2-2 — a client's commit stamps the major revision** (AppSpec §10: "A manual commit also stamps" —
  the settled `kind='manual'` carries it), so an AI's deliberate commit moves her "edited (meaningful)" sort as hers
  does (an `edit_take` can already cross her 80% churn). Options: (a) as built; (b) a client's commit never stamps (a
  split rule: manual for provenance, quiet for the sort).
- **P-VX168-U2-3 — `adopt_lens` with nothing to adopt writes NOTHING** (no "chosen until" lens either — her door mints
  one regardless; the mobile door's double-tap latch already treats a redundant preservation lens as unwanted).
  Options: (a) as built; (b) her door exactly — the preservation lens minted even when no pointer moves.
- **P-VX168-U2-4 — `adopt_lens`'s ONE undo walks back the preservation lens too** (pointers + the lens in one
  transaction; the redo revives exactly that lens with the choices that died on the undo's stamp; a lens she deleted
  since stays deleted — pinned). Her door's entry restores the pointers only ("the lens class — trivially deleted");
  on the wire a minted lens IS undoable (`save_lens`), so the act's lens walks back with the act. Options: (a) as
  built; (b) her door's entry exactly — pointers only, the "chosen until" lens stays after ⌥⌘Z.
- **P-VX168-U2-5 — the no-op is the SHOWN take** (the structural ops' rendered rule — the wire's own `chosen` fact):
  choosing the take a block already shows, or adopting a lens that agrees with what the note shows, writes nothing —
  so no act lands that she could not see (a nil pointer whose default the client names stays nil; pinned). Options:
  (a) as built; (b) the raw pointer — such a call writes the pointer (pinning it), with an undo entry and a receipt
  for an invisible change.
- **P-VX168-U2-6 — `save_commit`'s message is REQUIRED** (non-blank): it is what the commit is for, and the stored
  "‹client›: …" is the provenance (the op keeps the rule total: a blank message stores the client's name alone).
  Options: (a) as built; (b) optional — a message-less commit stored as the client's name alone.
- **P-VX168-U2-7 — the names and words** (her copy pass, 13s-a-sweepable): the tool `adopt_lens` (options:
  `apply_lens_as_chosen` — the ticket's prose; `make_lens_the_note` — her door's words), the three titles and
  descriptions; undo labels "‹client›'s take choice" / "‹client›'s lens adoption"; receipts "committed a take" ·
  "made N commits" · "chose a take" / "chose N takes" · "made the lens “X” the note" / "adopted N lenses"; Activity
  "committed a take in “…”" / "made N commits in “…”" · "chose a take in “…”" · "made a lens of “…” the note" (refused:
  "committing / choosing a take in …", "making a lens of … the note"); the guide's two sentences; the advice's edits.

### OWED (for the orchestrator)

1. **The QUESTIONS entries** above (P-VX168-U2-1…7) at the merge.
2. **The canon delta at the merge** (AppSpec §12's THE MCP DOOR line, the 13n-b/13n-c precedent): the edit rung's
   deliberate acts — `save_commit` (her commit: `kind='manual'`, the client's name prefixed, append-only — NO undo
   entry, receipts never claim one), `choose_take` and `adopt_lens` (her ✓ and her "✓ Make this the note" — R-MERGE-1
   — one client-named undo each, guard inside the act's transaction). §9 needs no new op line (the acts are §9's
   existing ops; `commit` gains only the caller-guard seam the others carry).
3. **The ladder's map:** `Sources/VariorumCore/Operations/Operations+MCPDeliberate.swift` (the three acts, the undo
   story) · the extractions in `Operations+Placement.swift` (`choosablePlacement`), `Operations+Versions.swift`
   (`adoptSwapRows`, `restoreChosenPointers`, `adoptUndoHalves` made internal), `Operations+MCPWrites.swift`
   (`tombstoneSavedLens`/`reviveSavedLens`; `MCPWriteAct` + `isUndoable`), `Operations+Variant.swift` (`commit(…
   guardedBy:)`), `Queries/MCPEditQueries.swift` (`mcpContainerOf(lens:)`) · `Sources/VariorumMCP/MCPWriteTools+
   Deliberate.swift` + the catalog + `MCPSession.instructions` · the app's `MCPPaneCopy` (Activity words; the receipt
   phrases and the undo-claim rule) + the guide's lessons 1 and 3 (`TutorialSeeder`). No `Sync/`, custody/keychain,
   editor-seam or schema line in this unit's diff.
4. **Unit 3's room:** the advice is at **1,941 / 2,000** characters — a Unit 3 advice sentence must fit in 59.
5. **A transient, recorded for a watch (the orchestrator's call):** one whole-package run saw
   `MCPCarriageServerTests.archivedReachMirrorsTheFacetAndLensesRead` fail with *"[-32001] Transport error: … Broken
   pipe"* — a read-only test (read_note, search) on roads this diff does not touch; green alone twice, in the MCP
   target alone (twice), and in the next whole-package run. A socket-road flake under whole-package parallel load
   (VX-134 is the core-side watch; this one is the MCP socket road — possibly a ticket).
6. **Noticed, for her copy pass / the UX pass (not this unit's):** the grant sheet's edit sentence and the pane
   toggle's blurb name editing takes only — neither says an edit grant can now choose takes or make a lens the note
   (not falsified — see the first line — but she grants edit reading that sheet).

## UNIT 3 RECORD — VX-172 `read_note` through a lens + VX-171 blank-take doors (opus-implementer, 2026-10-12)

**Read in full before code (never delegated):** this file (R-VX168-1, the UNIT 1 + UNIT 2 RECORDS); the kickoff prompt
(the VX-172 rider block); `notes/plans/vx-170-lens-aware-takes.md` whole (R-VX171-2, VX-172's adjacency, the acceptance
shapes); `notes/SessionResiliencyProtocol.md` whole; the 13n-b plan's ruled design, SITTING RECORD, AF-5…AF-11, the seam
rulings A-1…A-10, the U2 brief + record (the read tools' shape, the one not-shared answer) and the U3 PROVISIONALs
(P-13nb-U3-9 — the structured `create_note`'s empty takes DROP, which R-VX171-2 now supersedes for that door); QUESTIONS
#211 (P-VX171-2's letter); the ticket bodies VX-172 + VX-171 (Linear GraphQL); CLAUDE.md + the auto-loaded canon. Code
read: `MCPReadTools`, `MCPNoteStructure`, `MCPWriteTools{,+Edit,+Deliberate}`, `MCPToolCatalog`, `MCPSession` (the
advice), `Operations+MCPWrites`, `Operations+MCPEdits.editTakeUnderInsurance`, `Operations+DocumentImport.mintDocument`,
`Queries/{LensQueries,TakesQueries,PostRender,Export}`, `VariorumDocument`'s serializers, and — READ ONLY, the editor
seam — `PaneTextAuthority.resolvedText` (the Lenses board's per-slot rule) and `TakesViewModel.resolvedTake`.

**The brain the wire rides (found, never reimplemented):** her Lenses board reads `Queries.takesProjection` (slots from
`renderPost`, the ACTIVE fans, and each lens's EFFECTIVE picks — `Queries.effectiveLensSelection`, dangling picks
dropped) and resolves a lens column per slot by `PaneTextAuthority.resolvedText` (the pick where it is a live active
take of the block, else the slot's chosen resolution). The core's headless twin is `Queries.renderPost(…, throughLens:)`
(LensQueries.swift — the same sparse-override composition over the same effective picks). The wire's lens read rides
those two: the Level 0 text through `renderPost(throughLens:)` (the export's own block builder, given the lens), the
`with_ids` form through `effectiveLensSelection` over its own active fan (the board's pick-in-the-fan rule).

### LIVE STATUS — Unit 3's pieces

| piece | what | status |
|---|---|---|
| R0 | this record + the plan | DONE `f75186fc` |
| P1 | VX-171 (R-VX171-2, door-only): `add_take` accepts an empty text; `create_note`'s structured takes MINT a blank take (today they DROP — P-13nb-U3-9); `edit_take` to empty refuses (P-VX171-2 — the standing refusal verified FIRST by a probe pin); zero schema; red-on-old pins | DONE `6d4c73fe` — **THE PROBE'S FINDING: P-VX171-2's "stays refused" had NO standing refusal under it** — on the pre-unit tree `edit_take` with `text: ""` LANDED (her take emptied, both bracket commits, an undo entry, a receipt; the probe pin `editTakeToEmptyStillRefuses` red with 4 issues). Built: `edit_take` refuses a BLANK text at the wire's parse (`MCPWriteTools.editTakeBlankRefusal`, PROVISIONAL P-VX168-U3-2), making the ratified shape true; `add_take` takes any PRESENT text (`presentString` — the key still required; P-VX168-U3-1: whitespace alone too); `createStructuredNote` mints through `mintDocument(…, keepingBlankTakes: true)` (default false — every file door byte-unchanged, pinned). Pins: `MCPBlankTakeDoorsServerTests` 4/1 (wire) + `MCPBlankTakeMintTests` 2/1 (core) green; neighbours `MCPEditActsTests` + `MCPWriteActsTests` + the import suite green (49/4). Observed red BEFORE the fix: `createNoteMintsABlankTakeInsteadOfDroppingIt`, `editTakeToEmptyStillRefuses`; **RED-ON-OLD VERIFIED by behavioral revert** (on the committed tree `6d4c73fe`: `presentString`→`requiredText`, the edit guard removed, `keepingBlankTakes: false` — `addTakeAcceptsAnEmptyTextAsABlankTake`, `createNoteMintsABlankTakeInsteadOfDroppingIt`, `editTakeToEmptyStillRefuses` and the core `aStructuredNotesBlankTakeIsMintedInPlaceInTheFan` all RED; the two file-door guards green both sides, as unchanged-behaviour pins must be; restored by `git checkout --`, tree clean) |
| P2 | VX-172: `read_note` gains `lens_id` — the Level 0 text with each block's in-place take the lens's where it names one (else the chosen), the `with_ids` form with `via: lens \| chosen` per block; a dangling/foreign/dead/never-existed lens id answers the ONE not-shared answer byte-identical to an id naming nothing (checked before any once spend); the catalog's description + schema | DONE `2a260897` — core: `Queries.exportBlocks/variorumDocument/variorumDocumentText(…, throughLens:)` (default nil = byte-unchanged; the slots are `renderPost(…, throughLens:)`'s); wire: `MCPReadTools.readNote` parses `lens_id` (both forms; `version_id` + `lens_id` an argument error said the same for any lens id), checks `Queries.mcpContainerOf(lens:) == note_id` AFTER the note's decision and BEFORE the once spend, a mismatch answering through `MCPAsking.refusal(decide(standing, note: nil, …), .note, ask: nil)` — the id-naming-nothing road itself; `MCPNoteStructure.Options.lensID` → per block `via` + the lens take's text where `effectiveLensSelection` names a take in the block's ACTIVE fan (the board's pick-in-the-fan rule), `chosen` on takes untouched, `lens_id` echoed; the catalog: `read_note`'s description + `lens_id` property, `add_take`'s and `create_note`'s take `text` properties say an empty text is a blank take |
| P3 | (the tests, landed with P2) | DONE `2a260897` — `MCPLensReadServerTests` 5/1: **the byte-for-byte match** (wire `with_ids` per-block (text, via) == her board's read over `Queries.takesProjection` with `PaneTextAuthority.resolvedText`'s rule (cited, buffer overlay empty at rest) == `renderPost(…, throughLens:)`'s texts, over seven cases: another take · the chosen take · no pick · a BLANK take · an archived pick · a two-paragraph block shown one-paragraph · a deleted pick; a callout frame); **the text form == the note's own read after `adoptLens`** (byte for byte, v2 → v1 included); **no oracle** — ten bad lens ids (never-existed, dead, a readable sibling's, an unshared note's, a Private note's, a deleted note's, the note's own id, a block id, a book id, `""`) × both forms answer byte-identical to `read_note(note_id: "no-such-note")`, no ask raised; **once** — a refused lens leaves a once read grant unspent; **the blank-take round trip** (add_take `""` → save_lens → her board reads `""` via lens → the wire `""` + `via: lens` → the text form exactly the format's document for that state; her note untouched). Core `MCPLensDocumentReadTests` 1/1. **`VariorumMCPTests` 119/18 headless, 0 skipped** (baseline 110/16); the core's lens/export/format/import neighbours 52/9 green |
| P4 | close: suites over the changed surfaces (headless), the argued calls/PROVISIONALs/OWED, Unit 3 → DONE | DONE `6210bb24` — **the whole package headless: `VariorumMCPTests` 119/18 · `VariorumCoreTests` 2,678/306 · `StringsWorkbookTests` 40/6, ALL GREEN, exit 0** (only the standing gated skips). The run before it: the MCP test PROCESS was killed by SIGPIPE (signal 13) ~0.7 s in, under whole-package load — the MCP target alone then ran green twice (119/18) and the whole package green on the re-run above (OWED 4). Mutation checks (below). The Mac target BUILDS (`xcodebuild … -derivedDataPath DerivedData/vx168-u2 build`, BUILD SUCCEEDED) |

**What this unit did NOT do (said first):** (1) **No live client round, no Mac test run, no walk** — headless by
design (the brief); no Mac-rendered string or face changed, so no Mac batch ran; the Mac target was BUILT only. The
byte-for-byte pin reads her board's own projection (`Queries.takesProjection`) and restates
`PaneTextAuthority.resolvedText`'s three-line rule as its oracle (the editor-seam file was READ, never edited, never
run). (2) **P-VX171-2's premise was FALSE and I built the refusal it assumed:** on the pre-unit tree `edit_take`
with `text: ""` LANDED — her take emptied, both bracket commits, an undo entry, a receipt (the probe pin, red with 4
issues). The ratified shape file rules "edit_take to empty stays refused"; the brief makes it acceptance; so the
wire's parse now refuses a blank text (P-VX168-U3-2 — the one behaviour change at an existing door, red-on-old,
options for her below). (3) **No `notes/QUESTIONS.md` entry and no canon edit** — the merging session's ledgers
(OWED). (4) **`MCPSession.instructions` and the field guide UNCHANGED** — no sentence of either is falsified (reading
through a lens is reading; a blank take is a take); the advice stays at **1,941 / 2,000** (Unit 4 inherits the 59).
(5) **`export_note` takes no `lens_id`** — the ticket names `read_note` only; an undeclared argument there is
ignored as any is. (6) **No block-level take id for the lens's take** (P-VX168-U3-4 — the ruling names `via`
only). (7) **The format's documented v1 corner is not fixed** (OWED 5 — now reachable through a blanking lens).

### The design calls, argued

1. **The brain the wire rides — found, never reimplemented.** Her Lenses board reads `Queries.takesProjection`
   (`renderPost`'s slots, the ACTIVE fans, each lens's EFFECTIVE picks via `effectiveLensSelection`) and resolves a
   column per slot by `PaneTextAuthority.resolvedText` (the pick where it is a take in the block's active fan, else
   the slot's chosen resolution). The TEXT form reads through `renderPost(…, throughLens:)` (LensQueries — the core's
   twin of that composition) via the export's own block builder (`exportBlocks(…, throughLens:)`); the `with_ids`
   form reads `effectiveLensSelection` and applies the board's pick-in-the-active-fan rule over its own fan. Pinned:
   the wire's per-block (text, via) == the board's read == `renderPost(throughLens:)`'s texts over seven cases.
2. **The text form through a lens is the note's own DOCUMENT with the lens's takes in place** — each block's
   in-place take the lens's where it names one, else the chosen, the rest of the active non-blank fan as its
   alternates (the chosen among them where the lens moved it aside). Exactly the document the note reads as once the
   lens is made the note — pinned byte for byte against `read_note` after `adoptLens` (the v2 → v1 flip included).
   Why not JSON-only or plain prose: the ticket names the `with_ids` form as one of two ("In the with_ids form…"),
   `read_note`'s default answer IS the format, and the format's exact-inverse contract makes "the note as if the lens
   were the note" its natural lens reading (P-VX168-U3-3).
3. **A lens is a view:** under `lens_id` each take's `chosen` keeps meaning the NOTE's chosen take (a lens never
   changes what any take is — the shape file's own sentence); each block says `via: "lens" | "chosen"`; the answer
   echoes `lens_id` (the `version_id` echo's precedent). Without `lens_id` nothing about either form changes (pinned).
4. **A dangling pick resolves `via: chosen`** — "how it resolved" is the board's fall-through (an archived or deleted
   take is dropped by `effectiveLensSelection`); the dangle itself stays visible in `with_lenses`' `dangling_picks`
   (P-VX168-U3-5).
5. **No oracle, by construction AND by pin:** a `lens_id` that is not a live lens of THIS note answers through the
   id-naming-nothing road ITSELF — `MCPAsking.refusal(decide(standing, note: nil, …), .note, ask: nil)` — after the
   note's own decision (whose refusal is the same words anyway) and BEFORE the once spend. Pinned: ten bad ids (never
   existed · dead · a readable sibling's · an unshared note's · a Private note's · a deleted note's · the note's own id
   · a block id · a book id · `""`) × both forms == the live answer to `read_note(note_id: "no-such-note")`, no ask
   raised; a refused lens leaves a once grant unspent.
6. **`version_id` + `lens_id` is an argument error**, decided before any grant read and said identically for any lens
   id ("lenses never ride any copy" — a saved version has none; P-VX168-U3-6).
7. **VX-171, door-only (R-VX171-2):** `add_take` takes any PRESENT text (the key still required — no text at all is
   no take); `create_note`'s structured takes mint a blank take through `mintDocument(…, keepingBlankTakes: true)`;
   every FILE door keeps the default (the Level 0 format cannot write a blank take — its sections skip them — so one
   format keeps one meaning, R-13nb-11 G-2), pinned both sides. This SUPERSEDES P-13nb-U3-9's "empty-text takes drop"
   at `create_note` (a recorded supersession for the merge, not a provisional).
8. **`edit_take`'s refusal lives at the wire's parse** (argument class): decided before any grant read (no oracle,
   no spend, no log — every argument refusal's posture), whitespace-only counted blank, the words naming the open road.
9. **Docs:** `read_note`'s description gains the lens sentence and the `lens_id` property (a new parameter is
   documented where the parameters are); `add_take`'s and `create_note`'s take `text` properties gain one clause each
   ("an empty text adds a blank take…") — argued: a newly legal input is documented in its own schema line (the
   model layer of 13n-c's two-layer docs), and without it R-VX171-2's road — opened "so agents can do what humans
   already can" — is undiscoverable to the agents it was opened for. No description sentence was falsified; the
   advice and the guide stay as they are.

### Mutation checks (each applied to the committed tree `2a260897`, its suites run, restored by `git checkout --`; tree clean after)

M1 the lens check dropped → red (the no-oracle pin + the once pin) · M2 the once spend moved before the lens check →
red (the once pin) · M3 `via` always "lens" → red (the board match + the round trip) · M4 the document ignoring the
lens → red (the text-form pin, the round trip, the core pin) · M5 the version+lens pair check dropped → red (the
no-oracle pin's pair arm). The P1 behavioural revert (above, P1's row): all four fix pins red, the two file-door
guards green both sides.

### PROVISIONALs (each wants a `notes/QUESTIONS.md` entry at the merge — the merging session's ledger)

- **P-VX168-U3-1 — the creation doors take ANY text, whitespace alone included** (`add_take`'s blank refusal relaxed
  whole; `create_note`'s takes always took whitespace). Options: (a) as built; (b) exactly `""` only — whitespace
  still refused at `add_take` (and `create_note`'s takes then need a NEW refusal to keep the two roads one rule).
- **P-VX168-U3-2 — `edit_take` refuses a BLANK text** (empty or whitespace-only) at the parse: *"edit_take never
  empties a take. For a blank take, use add_take with an empty text."* — P-VX171-2 assumed a standing refusal that
  did not exist. Options: (a) as built; (b) refuse exactly `""` only; (c) withdraw P-VX171-2 — `edit_take` may clear
  a take, as her editor can (the pre-unit behaviour).
- **P-VX168-U3-3 — the TEXT form through a lens = the note's document with the lens's takes in place** (== the
  note read after adoption). Options: (a) as built; (b) `lens_id` implies `with_ids` (JSON only); (c) plain prose
  through the lens (`export_note`'s shape).
- **P-VX168-U3-4 — under a lens `takes[].chosen` stays the note's fact; `lens_id` echoed; no block-level id for the
  lens's take** (a client joins through `with_lenses` or the takes list). Options: (a) as built; (b) a per-block
  `take_id` naming the resolved take; (c) mark the lens's take in `takes[]` (`in_lens: true`).
- **P-VX168-U3-5 — a dangling pick reads `via: chosen`**, the dangle unmarked per block. Options: (a) as built;
  (b) also `lens_pick_dangling: true` on the block (her J5 "say loudly" carried to the wire).
- **P-VX168-U3-6 — `version_id` + `lens_id` refuse as an argument error.** Options: (a) as built; (b) read the
  version through the live note's lens by lineage (no model support — a version's blocks are fresh copies).
- **P-VX168-U3-7 — the words** (her copy pass, 13s-a-sweepable): the `read_note` lens sentence and `lens_id`
  property, the two blank-take clauses, the `edit_take` refusal, the pair refusal.

### OWED (for the orchestrator)

1. **QUESTIONS at the merge:** P-VX168-U3-1…7; **#211's P-VX171-2 corrected** ("stays refused" — it never was; now
   built, P-VX168-U3-2) and its "VX-172's `via` marker … built as stated" closed as built; **P-13nb-U3-9's drop
   clause superseded at `create_note`** by R-VX171-2.
2. **The canon delta at the merge** (AppSpec §12's THE MCP DOOR line): `read_note` reads a note THROUGH one of its
   lenses (`lens_id` — the format with the lens's takes in place; `with_ids` says `via: lens | chosen` per block; any
   id that is not a live lens of that note answers the one not-shared answer); the take-creation doors mint a BLANK
   take (`add_take` `""`, `create_note`'s takes — R-VX171-2), and `edit_take` never empties a take. §9 needs no line
   (no op changed its contract; `mintDocument` gained a door-only flag).
3. **The ladder's map:** `Sources/VariorumMCP/MCPReadTools.swift` (`readNote`: `lens_id`, the pair refusal, the
   lens check before the once spend) · `MCPNoteStructure.swift` (`Options.lensID`, `via`, the echo) ·
   `Sources/VariorumCore/Queries/Export.swift` (`exportBlocks/variorumDocument/variorumDocumentText(…, throughLens:)`)
   · `MCPWriteTools.swift` (`presentString`, `add_take`) · `MCPWriteTools+Edit.swift` (`editTakeBlankRefusal`) ·
   `Operations+MCPWrites.swift` (`createStructuredNote` → `mintNoteEntry(keepingBlankTakes:)`) ·
   `Operations+DocumentImport.swift` (`mintDocument(…, keepingBlankTakes:)`) · `MCPToolCatalog.swift` (the four
   doc lines). Tests: `Tests/VariorumMCPTests/MCPLensDoorsServerTests.swift` (two suites, 9 tests) ·
   `Tests/VariorumCoreTests/MCPLensDoorsActsTests.swift` (two suites, 3 tests). **Zero lines** in
   `Persistence/`, `Sync/`, custody/keychain or the editor seam (`git diff e6c1a8a5..HEAD --stat` over those paths:
   empty) — zero schema, as R-VX171-2 requires.
4. **A process-killing SIGPIPE, recorded for a watch (Unit 2's OWED 5 class, now fatal):** the first whole-package
   run's `VariorumMCPTests` process died "with unexpected signal code 13" ~0.7 s in (no test had failed); the target
   alone then ran 119/18 green twice and the whole package green on the re-run. UNVERIFIED candidates (not this
   unit's surface): the raw `pipe()`/`socketpair` descriptors in `MCPShimTests` (lines 80, 127, 129, 157, 178) and
   `MCPSetupKeyServerTests` (214, 230) carry no SIGPIPE suppression — a write to a closed pipe in-process raises it.
   Possibly a ticket (VX-134 is the core-side watch).
5. **The format's documented v1 corner is now REACHABLE through a lens** (VariorumDocument's doc comment: "a
   blank-chosen fanned block right after a FANLESS paragraph … its takes re-import onto the paragraph above"): a lens
   that blanks a block right after a fanless block reads, in the TEXT form, with the blanked block's takes under the
   block above (pinned as the format writes it); the `with_ids` form is exact. For 13m / the format's owner — not
   this unit's surface.
6. **For Unit 4 (lens-aware Takes) — what the lens machinery says:** (a) a lens's per-block fact should read the
   EFFECTIVE picks (`TakesProjection.lensSelections` — dangling dropped, `lensDangles` beside it), the same fact the
   wire's `via` and her board read; the shape file is silent on whether a DANGLING pick "names a take" — Unit 4's to
   state (a provisional), the wire says it does not. (b) Blank takes now arrive from the door (`add_take` `""`,
   `create_note`'s takes) beside `newBlankVariant`; a lens pointing at one is a pick like any (P-VX170-1). Fixture
   roads: `ops.newBlankVariant(blockID)` or `ops.addTake(toBlock:text:"" …)`. (c) Her board's lens resolution is
   `TakesViewModel.resolvedTake(column:slot:)` → `PaneTextAuthority.resolvedText` (editor seam — read, never edit);
   "disagrees with the chosen takes" compares against the slot's rendered take (`renderPost`'s chosen-else-default).
   (d) `takesProjection` already carries lenses, effective picks, dangles and fans — the four forms can be a pure
   function over it, cost ∝ the note.

## UNIT 4 RECORD — VX-170 lens-aware Takes (opus-implementer, 2026-10-12)

**Read in full before code (never delegated):** this file whole (the UNIT 1–3 RECORDS, Unit 3's "For Unit 4" notes);
`notes/plans/vx-170-lens-aware-takes.md` whole (R-VX170-1…5, P-VX170-1 — RATIFIED, her 2026-10-11 rulings; the binding
text for this unit); the kickoff prompt's VX-170 rider; `notes/SessionResiliencyProtocol.md` whole; the ticket body
VX-170 (Linear GraphQL — its "Parked … needs a design sitting" line predates the ratified shape file, which governs);
CLAUDE.md + the auto-loaded canon (AppSpec §12's Takes line: tinted cards, "✓ chosen", ONE live-editor ring,
follow-the-scroll; the 17q row memory). Code read: `TakesViewModel` (the conductor: adoption, resolution, focus,
expansion, paging, reveals, the keyboard family), `TakesBoardLayout` (expansion + bloom rule + paging), `TakesBoardView`
whole (the header line, the article, every bloom style, the rail, the badge), `TakesChoreographer` (the landings),
`TakesFindController.land`, `TakesShared` (the cell), `TakesModels`, `EditorRouter` (the session memories),
`Queries.takesProjection` / `effectiveLensSelection` / `danglingLensPicks` / `renderPost(throughLens:)`, the lens ops,
and the masthead-popover idiom (`Core/Views/MastheadPopover`, the Bookcase's `order ▾` door and host overlay,
`MenuLifeReporter`). Editor seam (`PaneTextAuthority`, `PaneSurface`, `EditorTextView`, `BlockRangeIndex`): READ ONLY.

### LIVE STATUS — Unit 4's pieces

| piece | what | status |
|---|---|---|
| R0 | this record + the plan | DONE (this commit) |
| P1 | core: `Domain/LensTakeFilter` — the four forms (R-VX170-1) as ONE pure function over a block's effective picks + its shown take, and the expand set (R-VX170-3: named ∪ shown, fan order) over a whole note; headless pins over REAL projections (`Queries.takesProjection`) incl. blank takes (P-VX170-1) and dangling picks | DONE (this commit) — `LensTakeFilterTests` **13/1 green headless**: every arm of the four forms exactly (incl. a gap never matching, the same-lens two-lens forms never built), the expand set in FAN order, and over a real note: the blanked block IS `in X` and blank-vs-chosen IS a disagreement (P-VX170-1), identity-not-text (a byte-identical twin disagrees), a dangling pick names nothing (P-VX168-U4-2), the chosen side follows a ✓, a pick-less lens matches nothing with the whole note as denominator. Mutation checks (each on the committed tree `b0f67cbf`, restored by `git checkout --`, tree clean after): M1 disagree without `px != py` → red (2 pins) · M2 disagree-with-chosen without `px != shown` → red (3) · M3 in-not-in without its not-in arm → red (3) · M4 the expand set without the shown take → red (4) · M5 the gap guard dropped → red (1) |
| P2 | app: the session memory (`EditorRouter.takesShowFilters`, R-VX170-5) + the model (the filter, the per-projection evaluation cache, the row shapes, the filter-aware bloom, the hidden-pane rules, pruning) + the faces (the header's `show ▾` door on the masthead-popover idiom with inline lens pickers, the quiet chip, the collapsed one-line rows, the filtered blooms, the zero-match line) + Mac view-model pins | DONE — the code `dffa8351` (a COMPILING state: `xcodebuild build` SUCCEEDED, no new warnings): `TakesLensFilterController` (the component — the filter from/to the session slot, the evaluation at adoption + filter change, `rowShape` / `isBloomed` / `bloomTakes` / `paneIsShown` / `reveal`, the menu rows, the words `TakesShowCopy`), `TakesShowFaces` (the door + chip, the popover on `mastheadPopoverChrome`), the conductor's hooks (adoption, `focus`, `landAuthorityFocus`, `pageTarget`, `naturalSlotHeight`), the board (collapsed rows on the same identity, the zero line, every bloom style + the rail through `bloomTakes`, the rail header's filtered door, the badge's words, the reorder arrows standing down on a subset, the popover overlay + menu life + ⎋), `MastheadPopover`'s chrome extracted (byte-identical modifiers) + `.takesShow`. the Mac view-model pins `TakesLensFilterTests` **21/1 green** (this commit — under the held stage claim `vx168-u4`, `-only-testing`, zero skipped): the door at rest (all takes, no chip, every row ordinary; no door on a lens-less note), each form's shapes over a real note (collapsed / filtered expand sets; a lone shown take matches without blooming), blank takes ordinary in every form, a dangling pick folding its block, the badge as the whole-fan door both ways, applying a filter starting from the plain page, follow-the-scroll never opening a collapsed row, the zero line in place (incl. the shape's own "agree everywhere" words), the session memory per note (survives a new board, gone on a new session, the Write panel / Lenses never read or write it), a deleted lens resetting to all takes, the ring's two rules (a hidden pane's block opens on focus AND on the entry ring; her filter change blurs a pane it hides, keeps one it shows; a store change never hides the live pane), the popover rows (operands carried across forms, words apply + close, an operand pick applies + stays open, the second picker never offers the first operand, two-lens forms inert on a one-lens note), the keyboard pager paging the expand set, every form's words. REMAINS: app-side mutation checks + the Mac batch over the changed surfaces (P3, with the walk) |
| P3 | the Mac batch over the changed surfaces + the ONE use-shaped walk on a real multi-lens dev-store note (held stage claim) | DONE `39fd6db5` + the close — **THE WALK: every leg held** (below, "THE WALK"); its two findings FIXED (W-1 the door vanishing on a crowded header line — a width-aware header; W-2 an idle "all" on a rail whose expand set is the whole fan); the dev store RESTORED "verified" from `scale-prestage-20261012T103024Z` and re-compared byte-identical after the batch, no instance, clipboard empty, the stage RELEASED. **App-side mutation checks** (each on the committed tree `39fd6db5`, rebuilt, `TakesLensFilterTests` run, restored by `git checkout --`, tree clean after): M1 applying a filter keeps opened fans → red (1) · M2 `reveal` a no-op → red (2 tests) · M3 a store change never reveals the live pane → red (1) · M4 a collapsed row on today's bloom rule → red (follow-the-scroll) · M5 every model applies → red (the Write panel / Lenses pin) · M6 her filter change keeps a hidden pane → red (1) · M7 the pager on the whole fan → red (1) · M8 a dead lens's filter survives → red (1) · M9 the session slot never written → red (1). **THE MAC BATCH** over every changed surface, the clean tree rebuilt, under the claim, guard OK before each half: **264 tests / 26 suites** (the Takes family: `TakesLensFilterTests` · TakesBoard · TakesBoardSoak · card heights · rail paging · margin-grid alignment + captures · slot drag · room · entry band · article scroll/watch/render · find on the board · card doors · empty state/face · divide · landing arms · pane durability/measure · fanned defaults · landing aim · find faces · render-restore clip · split-at-newlines doors) **+ 352 tests / 57 suites** (the shared model's other hosts and the popover idiom's: take-structure/fan-hands/lifecycle-faces suites by type, Compare/Lenses alignment, MCPNavigation, origin doors, the seven savepoint suites, sealed-book doors, note versions, copy-door flush, the block-selection family, the command-routing family incl. `TakesLandingTests`, capability registry, autosave consolidation/lifecycle, formatting surfaces, lifecycle faces, recovery doors, the round-A board fixes, trash, the tutorial's takes/looking/structure acts, `BookcaseMastheadPopoverTests` · census menu/overlay · bookcase board brain · move-to-shelf gate · bookcase view model) — **616 / 83 green, zero failures**; skipped only by design (the VX-136 capture harness, the env-gated singleton-window oracle); one recorded known issue, pre-existing (`TakesFindBoardTests`' named Esc boundary). None of the standing reds (VX-115, VX-167, VX-132) sits in this batch |
| P4 | close: the final suites, the argued calls / PROVISIONALs / OWED, Unit 4 → DONE | DONE (this commit) — **the whole package headless: `VariorumMCPTests` 119/18 · `VariorumCoreTests` 2,691/307 · `StringsWorkbookTests` 40/6, ALL GREEN, exit 0** (core = Unit 3's 2,678/306 + `LensTakeFilterTests` 13/1; only the standing gated Supabase skip; no socket flake this run) |

### The plan — the design calls the shape leaves to the build (stated before code; argued in full at the close)

1. **The rule is core-pure** (`Sources/VariorumCore/Domain/LensTakeFilter.swift`): per block a lens contributes ONE
   fact — the take it names there or none — read from the EFFECTIVE picks (`TakesProjection.lensSelections`, the fact
   the wire's `via` and her board read). `in X` ⇔ X names a take · `in A, not in B` ⇔ A names one, B none ·
   `X disagrees with Y` ⇔ both name takes and they are DIFFERENT takes (identity — R-VX170-1's "different ones") ·
   `X disagrees with the chosen takes` ⇔ X names a take ≠ the slot's rendered take (`renderPost`'s chosen-else-
   default). A gap slot never matches. A blank take is an ordinary take (P-VX170-1 — nothing special-cased).
2. **A dangling pick names nothing** (PROVISIONAL — the shape is silent; the wire reads it `via: chosen`, her board falls
   through to chosen, and `effectiveLensSelection` drops it — one reading on every surface).
3. **The door lives on the Takes board's own header line** (the Takes mode's masthead — the note's masthead is shared
   by every mode and holds no mode's controls), `show: all takes ▾` at rest, the expression in words while active,
   opening a popover on the ONE masthead-popover idiom (`MastheadPopover`'s chrome, seated under its control by the
   board's overlay, living like a menu: an outside press and a menu's life-end close it). Rows: "all takes" (clears)
   then the four forms with inline lens pickers. The door renders only on a note with a saved lens (PROVISIONAL).
4. **Row shapes under a filter**: a non-matching block is a collapsed one-line row (the shown take's first line + the
   article's own corner badge); a matching block is the ordinary row whose bloom shows the expand set (blooming only
   when that set holds more than the shown take — the cell already IS a lone shown take); the corner badge stays the
   block's whole-fan door (its usual control): it opens a collapsed row whole, a filtered bloom to its full fan, and
   back. Implemented as one model function over `expandedBlocks` — no second expansion state.
5. **Session memory** (R-VX170-5): `EditorRouter.takesShowFilters[postID]` beside the article's 17q memories —
   survives mode flips and note switches, gone on relaunch (the brief's reading of "resets on the next open", the
   Takes-row-memory precedent); never persisted, never synced, never a setting. Only THE takes board reads or writes
   it (`landingEnabled`); a filter naming a lens the note no longer holds resets to all takes.
6. **The ring never lands on a hidden pane** (the R112 class): a focus or landing onto a pane the filter hides opens
   its block (the one `board.bloom` door); a filter change that hides the live pane blurs it (flushed first).
7. **Cost ∝ the note** (P1): the evaluation is computed at adoption and at a filter change, never per render.

### THE WALK — the unit's acceptance evidence (dev store only, stage `vx168-u4`, 2026-10-12 04:28–04:42 MDT)

**Machine:** this host's Accessibility + Screen Recording granted (`AXIsProcessTrusted`/`CGPreflightScreenCaptureAccess`
both true); her `/Applications/Variorum.app` ABSENT throughout (`Tools/WalkKit/guard.sh` before every GUI step, the
per-step form with the dev pid and the click point); the Debug app `App/Variorum/DerivedData/vx168-u4/…/Variorum.app`
(`io.lduarte.Variorum.debug`) on the dev store, the store first copied A1-style (`scale-prestage-20261012T103024Z`,
cmp-verified) and RESTORED from it at the end ("Restored (verified)"); quit by identity (`tell application id … to
quit`, `pgrep` empty after each). **The note:** the field guide's own "lenses" lesson (three blocks: two fanned with
the seeded lens "the other reading" picking their alternates, the middle block unfanned) plus a second lens made
through HER door — Takes ▸ note actions ▾ ▸ Save choices as lens… ▸ "mine" (receipt "Saved — "mine" now remembers
these choices.") — so "mine" names every block's chosen take. Captures: `notes/plans/vx168-screens/u4/` (gitignored).

| leg | what was done | outcome |
|---|---|---|
| (1) rest | opened the note in Takes (margin grid, Study light) | `show: all takes ▾` LEADS the header line, no chip, every row its own (`01-rest-study`) |
| (2) the popover | pressed `show ▾` | seated under its door on the masthead-popover face: "all takes" washed, then the four forms with underlined inline pickers, the last form's "the chosen takes" fixed (`02-popover-study`) |
| (3) `in X` | pressed form 1's words | `show: in the other reading ▾` + chip "2 of 3 blocks"; the middle block (no pick there) FOLDED to its one line + ⑂+; the two matching blocks bloomed their expand set (chosen + the lens's take) in the rail; the popover closed (`03-in-x-study`) |
| (4) `in A, not in B` + zero | form 2 (A = the other reading, B = mine) | the honest zero IN PLACE: "No blocks match — wherever "the other reading" picks a take, "mine" picks one too."; every row one line with its fan count; "0 of 3 blocks"; the live pane let go (bottom bar "click into a take") (`04-zero-study`). **W-1 FOUND HERE: the door was GONE** — at the 680-pt measure margin grid's fixed controls fill the line and the door (the one yielding item) truncated to nothing |
| (5) note switch | ⌘K → "getting around" → ⌘K → "lenses" | the filter came back with the note (same expression, chip, zero line); the re-open's entry ring landed on block 1 and, the block being folded, OPENED it whole (P-VX168-U4-7's rule, visible) (`05-note-switch-back-study`) |
| (6) relaunch | quit by identity, the W-1/W-2 fix built, relaunched, reopened the note | `show: all takes ▾`, no chip — the filter did NOT survive the session; the lens "mine" (store truth) did (`06-relaunch-study`) |
| W-1 fixed | form 2 again | the door + chip on their own line above the controls, whole (`07-zero-fixed-header-study`) |
| (7) `X disagrees with Y` | form 3 (the other reading vs mine) | "2 of 3 blocks"; the two blocks bloom "takes · 2 of 2" (W-2's fix: no idle "all"), the middle folded (`08-disagree-study`) |
| (8) `X disagrees with chosen` | form 4 | `show: the other reading disagrees with chosen ▾` — her example's shape exactly; "2 of 3 blocks" (`09-disagree-chosen-study`) |
| (9) the badge | the folded block's ⑂+ → its rail's ✕ | opened whole (cell + its rail "takes · 1 ✕", "close all" lit) → folded back to its line (`10-badge-opens-study`, `11-folds-back-study`) |
| (10) mode flip | ⌘1 → ⌘2 | back in Takes with the filter and chip as left (`12-mode-flip-back-study`) |
| (11) stack style | style ▾ → Stack | each matching block's cell + its two cards ("✓ chosen" + the lens's "choose" card), NO fan-order arrows on the subset (P-VX168-U4-5), the folded line + ⑂+; the long expression on its own line at 680 pt (`13-stack-disagree-chosen-study`) |
| (12) Terminal voice | Settings ▸ General ▸ Terminal | the same board in Terminal (`14-stack-disagree-chosen-terminal`); the popover (`15-popover-terminal`) |
| (13) an inline picker | form 4's picker → "mine" | applied at once ("show: mine disagrees with chosen", "0 of 3 blocks") and the popover STAYED open with every row carrying "mine" first (`16-picker-zero-terminal`) |
| (14) closing | ⎋, then an outside press | **⎋ did NOT close it** (W-3, below); the outside press did; the zero line in Terminal: "no blocks match — "mine" agrees with the chosen takes everywhere." (`17-esc-zero-terminal`, `18-outside-press-zero-terminal`) |
| (15) clear | popover → "all takes" | the plain page back: muted door, no chip, every row its own, the header one line again (`19-all-takes-clears-terminal`) |

**Walk findings and dispositions.** **W-1 (DEFECT, this unit's own code — FIXED):** the door truncated to nothing
on a crowded header (margin grid at the 680-pt measure). Fix: the header is WIDTH-AWARE (`ViewThatFits`): one line
while the door fits whole beside the controls, else the door + chip on a line of their own above them; the controls
never move. Evidence of its kind (a layout defect — a walk capture, red then green): `04-zero-study` (no door) →
`07-zero-fixed-header-study` / `13-…` (door whole, two lines) and `08-…`/`09-…` (one line where it fits).
**W-2 (NIT — FIXED):** a filtered rail whose expand set IS the whole fan drew "all", a door that reveals nothing
(P-2); it now stands down there (`08-…`: "takes · 2 of 2", no door). **W-3 (RECORDED, not fixed):** ⎋ closes the
popover only while the board holds the keyboard (`onExitCommand`'s reach); after a picker's NSMenu nothing on the
board does, so ⎋ is not heard. The idiom's ruled close roads all work (an outside press, a row's words, the menu's
life ending); the Bookcase's own `order ▾` has no ⎋ at all. **Not walked:** a blank take in a lens (P-VX170-1 is pinned
headless and on the Mac against real projections; making one through the UI needs a Lenses-board re-pick), dark
appearance (no new colour or token — the chip and fills are the existing quiet tokens), carousel / slot split (their
blooms read the same `bloomTakes`, pinned via the pager test).

**What this unit did NOT do (said first):** (1) **No blank take was walked** — P-VX170-1 is pinned headless
(`LensTakeFilterTests`: the blanked block IS `in X`, blank-vs-chosen IS a disagreement) and on the Mac against real
projections (`TakesLensFilterTests`), but making a lens pick a blank take through the UI needs a Lenses-board re-pick
the walk did not stage. (2) **Dark appearance, carousel and slot split were not walked** (no new colour or token; the
two styles draw through the same `bloomTakes`, pinned through the pager test). (3) **⎋ does not reliably close the
popover** (W-3, recorded, not fixed — below). (4) **No ⌘K / menu-bar / keyboard twin for `show ▾`** — the shape names
the masthead door only (and the header's `style ▾` has none either); not invented. (5) **No `notes/QUESTIONS.md`
entry, no canon edit, no Linear edit** (the merging session's ledgers — OWED; the VX-170 ticket body still carries its
pre-sitting "Parked" line). (6) **`MCPSession.instructions` and the field guide UNCHANGED** — no sentence of either is
falsified by a view filter on the Mac board; the advice stays at 1,941 / 2,000. (7) **The Lenses board, the Write
panel and mobile are untouched** — the filter applies on THE Takes board only (`applies`). (8) **Zero schema, zero
wire, zero `Sync/`, custody/keychain or editor-seam lines** (`PaneTextAuthority`, `PaneSurface`, `EditorTextView`,
`BlockRangeIndex` read, never edited — `git diff c3fb7e37..HEAD --stat` over those paths: empty).

### The design calls, argued

1. **The rule is core-pure** (`Domain/LensTakeFilter`, the `KeepOnTopDivide` pattern): every arm a unit test run
   headless, store-free, phone-callable — the board's half (`TakesLensFilterController`) holds state and shapes only.
2. **A lens's one fact per block is its EFFECTIVE pick** (`TakesProjection.lensSelections`) — the fact the wire's
   `via` and her Lenses board read, so a lens means one thing on every surface.
3. **"Disagree" is take IDENTITY** — R-VX170-1's own words, "both name takes, different ones"; a byte-identical twin
   is a different take (sameness of text is the Lenses board's tint, another question). Pinned.
4. **"The chosen takes" are the slots' RENDERED takes** (`renderPost`'s chosen-else-default — what the note shows);
   a gap slot never matches. The expand set is drawn in FAN order (every style's own order).
5. **One expansion state, not two**: under a filter `expandedBlocks` means "she opened this block's whole fan" for
   every row — a filtered row's badge shows its whole fan, a folded row's opens it whole, and back. No second set to
   drift (P-VX168-U4-4 is the face of this, provisional).
6. **Cost ∝ the note** (P1): the evaluation runs at adoption and at a filter change — one pass over the slots — never
   per render; the rows read dictionary lookups.
7. **Only THE takes board applies** (`landingEnabled && host == .takes`): the Write panel's embedded model and the
   Lenses board never read or write the slot or change a row (pinned, M5 red).
8. **A filter naming a lens the note no longer holds resets to all takes** — the dead-lens column precedent
   (`adopt`'s columns → scratch): the lens was the filter's subject. Pinned (M8 red).
9. **The popover wears the ONE masthead-popover face**: `MastheadPopover`'s chrome moved into
   `mastheadPopoverChrome` byte-for-byte (the same modifiers in the same order) and both popovers wear it; the Bookcase's
   popover suites ran green unmodified. Rows carry the active filter's lenses across forms (switching forms keeps what
   she was looking through); the second picker never offers the first operand; a two-lens form on a one-lens note is
   inert (P-2 — it could only match nothing).
10. **The header is width-aware** (W-1): one line while the door fits whole, else the door and chip on their own line —
    the controls never move and the door never shrinks to nothing.

### PROVISIONALs (each wants a `notes/QUESTIONS.md` entry at the merge — the merging session's ledger)

- **P-VX168-U4-1 — the door renders only on a note with a saved lens.** Options: (a) as built; (b) always, with the
  forms inert and a line saying the note has no lenses yet.
- **P-VX168-U4-2 — a DANGLING pick names nothing** (the shape is silent; the wire answers `via: chosen`, her board falls
  through to chosen). Options: (a) as built; (b) a dangling pick names its missing take — `in X` matches and
  "X disagrees with chosen" surfaces it for review, the bloom carrying J5's notice.
- **P-VX168-U4-3 — a match whose expand set is the shown take alone** (the lens picks the chosen take) is the ordinary
  row with NO bloom — the cell already is that take. Options: (a) as built; (b) a one-card bloom.
- **P-VX168-U4-4 — the corner badge is the block's whole-fan door under a filter** ("the rest of the fan stays behind
  its usual control"): a filtered row ↔ its whole fan; a folded line ↔ the block whole; the rail's "all" / ✕ the same
  door where the badge stands down. Options: (a) as built; (b) a folded line opens on a click of its text too; (c)
  folded lines inert.
- **P-VX168-U4-5 — fan-order arrows stand down on a filtered subset** (they would move a take past hidden takes; the
  first card's "earlier" would point at one). Options: (a) as built; (b) keep them.
- **P-VX168-U4-6 — the words** (her copy pass, 13s-a-sweepable): the door "show: all takes ▾" / "show: in X" / "in A,
  not in B" / "X disagrees with Y" / "X disagrees with chosen" (her example's form); the popover's rows (the last
  form's fixed "the chosen takes"); the chip "N of M blocks"; the four zero lines ("No blocks match — “X” picks no
  take in this note." · "— wherever “A” picks a take, “B” picks one too." · "— “X” and “Y” agree everywhere." · "— “X”
  agrees with the chosen takes everywhere."); the rail's "takes · N of M" + "all"; the badge's four helps; "(empty
  block)"; the door/chip/row tooltips.
- **P-VX168-U4-7 — the ring's three rules** (the R112 class): a focus or landing onto a pane the filter hides OPENS its
  block (the entry ring included — the walk's leg 5 shows it); her own filter change BLURS a pane it hides (flushed —
  the view she asked for is exactly the filter's); a STORE change that would hide the live pane opens its block
  (nothing vanishes from under the ring; a block she is not in simply folds). Options: (a) as built; (b) the entry
  ring stands down on a folded block (no live pane; the page reveals its line); (c) a store change folds anyway and
  blurs.
- **P-VX168-U4-8 — applying a filter starts from the plain page** (fans opened before close; otherwise those blocks
  show whole whatever the filter says). Options: (a) as built; (b) keep opened fans.
- **P-VX168-U4-9 — the popover's life**: a row's words apply and close (the order popover's pick); an operand pick
  applies and stays open (the expression may want its other operand); an outside press and the menu's life ending
  close; ⎋ closes only while the board holds the keyboard (W-3). Options: (a) as built; (b) every pick closes; (c) a
  keyboard-focused popover so ⎋ always closes (the order popover would want the same).
- **P-VX168-U4-10 — the door's home is the Takes board's own header line**, leading — the Takes mode's masthead (the
  note's masthead is shared by every mode and holds no mode's controls). Options: (a) as built; (b) the note
  masthead's row two while in Takes; (c) trailing on the header line.
- **P-VX168-U4-11 — "resets on the next open" read as the next LAUNCH** (the brief's reading and the Takes-row-memory
  precedent: survives mode flips AND note switches/re-opens in the session). Options: (a) as built; (b) a note's
  re-open within the session also resets (only mode flips survive).
- **P-VX168-U4-12 — the folded line's face**: the first line that says anything, the small chrome face in muted ink,
  the callout frame and comment notes standing down on a line that is only the map. Options: (a) as built; (b) the
  prose face; (c) the TOC handle (the block's name, else its first sentence).

### OWED (for the orchestrator)

1. **QUESTIONS at the merge:** P-VX168-U4-1…12; #211's P-VX170-1 closed as built (blank takes ordinary in every
   form, pinned), and its dangling-pick question answered provisionally (P-VX168-U4-2).
2. **The canon delta at the merge** (AppSpec §12's NOTE-mode-row line, "Takes = single-column fan work"): the Takes
   board's `show ▾` — lens-aware Takes (R-VX170-1…5, the shape file): the four forms over a note's lenses' effective
   picks, non-matching blocks folded to one line, a match blooming the named takes plus the chosen one, the masthead
   popover resting on "all takes" with a quiet chip while active, a session-only per-note memory; pointer to
   `notes/plans/vx-170-lens-aware-takes.md` + this record.
3. **MOBILE PARITY:** VX-170 is Mac-only; mobile Takes has no filter — a `notes/MobileSoul.md` ledger row for the
   mobile catch-up (the closeout's line).
4. **The ladder's map:** `Sources/VariorumCore/Domain/LensTakeFilter.swift` (the rule + the projection adapter) ·
   `App/Variorum/Variorum/Features/Takes/TakesLensFilterController.swift` (state, shapes, the ring's rules, the menu
   rows, the words) · `TakesShowFaces.swift` (the door, chip, popover) · `TakesViewModel.swift` (the hooks: adoption,
   `focus`, `landAuthorityFocus`, `isBloomed`, `bloomTakes`, `pageTarget`, `naturalSlotHeight`) · `TakesBoardView.swift`
   (the width-aware header, the overlay + menu life + ⎋, collapsed rows, the zero line, every bloom style + the rail
   through `bloomTakes`, the badge's words, the arrows standing down) · `Core/Views/MastheadPopover.swift` (the
   extracted chrome, `.takesShow`) · `EditorRouter.swift` (`takesShowFilters`). Tests:
   `Tests/VariorumCoreTests/LensTakeFilterTests.swift` (13/1) · `App/Variorum/VariorumTests/TakesLensFilterTests.swift`
   (21/1). Not Fable's seam: no editor-seam, `Sync/` or custody line — `opus-reviewer` territory for this unit, the
   run's ladder being Fable's anyway.
5. **W-3 for a watch (possibly a ticket):** ⎋ cannot close an in-window masthead popover once nothing on its board
   holds the keyboard (after an inline picker's NSMenu here; the Bookcase's order popover has no ⎋ at all).
6. **Linear:** VX-170's body still reads "Parked … needs a design sitting before any plan file exists" — superseded by
   the ratified shape file; the orchestrator's to update at the merge.
