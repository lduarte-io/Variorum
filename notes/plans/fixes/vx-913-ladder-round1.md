# VX-913 — ladder round 1 (cold review, Fable)

**Reviewer:** fresh fable-reviewer, zero implementation context, `notes/REVIEW_PROMPT.md` run verbatim.
**Diff reviewed:** `git diff $(git merge-base origin/main HEAD)..HEAD` at head **fbd0f3281** (22 files, +1710/−69; the record file and .gitignore beside the code).
**Canon read in this session, nothing delegated:** CLAUDE.md's auto-loaded canon · `notes/MCPSpec.md` IN FULL · `notes/SurfaceContracts.md` IN FULL (The app · The Library · The Bookcase · The note · Doors) · the run record `notes/plans/fixes/vx-913-freeze-fixes.md` whole (briefs, traces, B1–B4 records, ledger) · the code and tests of every hunk, read in the files, not the diff alone.
**Verification run here (headless, end of review):** `swift test --filter "MCPActivityLogFailureServerTests|MCPStaleStartServerTests|MCPStoreFailureWordsServerTests"` → **13 tests in 3 suites passed**; `swift test --filter "SearchGroupsTests|SearchFacetTests|SearchOrderTests"` → **27 tests in 3 suites passed** — both on this tree, matching the record's claims.

No BLOCKER and no MAJOR found. Findings, severity-ranked:

---

## F1 · MINOR · `Sources/VariorumMCP/MCPWriteTools.swift:69–71` + `MCPDoor.swift:615, 633–637` — the receipt→failure-toast order rests on unstructured-Task scheduling, and a flipped order erases the very line VX-775 exists to give her

**Mechanism (traced).** `MCPWriteTools.call` fires `hooks.onWrite?(receipt)` per landed receipt, then `hooks.onActivityLogFailure?(failure)` — sequentially, from the tool handler's thread. The door wires EACH hook as its own `Task { @MainActor in … }` (`MCPDoor.swift:615` and the new `:633–637`). `StatusCenter.deliver` (Registry/StatusCenter.swift:253–285) holds ONE message: a `.receipt` under the default quiet style sets `quietLine` **and clears `current`**; under toast style it replaces `current`. So if any receipt's hop lands on the main actor AFTER the refusal's hop, the receipt **clears the refusal toast** — she never sees the failure, which is the single thing her #267 ruling demands ("the error goes to her"). A list call multiplies the exposure: N receipt tasks + 1 failure task, any one receipt landing late erases it.

**Why MINOR, not MAJOR:** in current Swift, main-actor-isolated task closures created synchronously from one thread enqueue in creation order, so the order holds in practice — the real-door App pin (`VX775ActivityLogFailureDoorTests.throughTheRealDoor…`) asserts the end state and ran green at head in the b2b3 window. But the ordering is not a documented guarantee, and the implementer's own self-assessment names it (B3 risk 1) without a structural answer.

**Fix shape (cheap, no behavior change):** make the order structural rather than scheduled — ONE main-actor hop for the call's app-side tail. E.g. the host passes the failure alongside the last receipt (extend `onWrite`'s payload or add a call-tail hook carrying both), or the door funnels both through one `Task` that runs `landWireWrite(…)` for each receipt and then `landActivityLogFailure(…)` in the same hop. **Pin:** the existing real-door pin stays the oracle; a deterministic pin can hold the receipt's hop (a main-actor gate) and assert the refusal still ends on the seam. No red-on-old pin exists for this because it is a hardening of the NEW code's ordering assumption, not a pre-existing wrong output — architectural hazard class, justification above.

## F2 · MINOR · `Sources/VariorumMCP/MCPServerHost.swift:155–166` (the publish-fail cleanup) — the quiet-return `unlink` is by NAME and can remove a FRESH host's socket inside `listen`'s probe TOCTOU window

**Mechanism (traced).** A stop lands between the stale start's pre-bind check and its publish re-check; the stale start bound the path (`halt` saw `listenFD == -1`, so it unlinked nothing — correct, VX-548 2b). The fresh host's start then runs `MCPSocketRoad.listen` (MCPSocketRoad.swift:148–181): probe-connect → unlink → bind → chmod → listen. If the fresh probe fires inside the stale start's **bind()→listen() syscall gap**, the connect gets ECONNREFUSED (bound, no backlog yet), the fresh start unlinks the stale's path, binds its own and serves. The stale start's publish re-check then fails and its cleanup runs `MCPSocketRoad.unlink(directory:)` — a bare `Darwin.unlink` by name (`:186`) — **removing the fresh host's socket file**. End state: pane "running", every new client's connect fails ("Variorum must be open") until the next stop/start — exactly the symptom class VX-548 batch 2b closed by making `halt` remove only its own fd's file; this is the first by-name unlink reintroduced outside that guard.

**Why MINOR:** reachability is a two-adjacent-syscalls window on the stale side that must coincide with the fresh probe, behind the already-rare stop-mid-start premise; the pre-fix code's version of this class was catastrophically wider (a let-go host serving). The implementer's own record names the adjacent residuals ((e) the probe meeting a stale listener; (f) `listen`'s probe→unlink→bind TOCTOU) and proposes per-directory serialization; this finding adds the concrete unlink-steal consequence to that same ticket.

**Fix shape:** belt the cleanup unlink — before `MCPSocketRoad.unlink`, confirm the path still names this fd's socket (`fstat(fd)` vs `stat(path)` inode compare; two lines, local), or take the recorded per-directory-serialization proposal. **Pin:** needs a DEBUG seam between `bind` and `listen` inside `MCPSocketRoad.listen` (machinery the batch deliberately declined for the sibling residual) — said honestly: without that seam no red pin can hold the window, so this lands as the residual ticket's content, not a this-run fix, unless the finder-of-fact wants the inode belt landed belt-only (it needs no pin of the race itself; a pin that the cleanup never unlinks a path that is not its fd's is writable with the existing `.bound` gate plus a replaced file).

**Disposition sought:** fold F2 (and F3) into the ONE closeout ticket the B3 record already promises for residuals (e)/(f), with the inode belt named as its cheapest first piece.

## F3 · NIT · `MCPServerHost.start` catch + `MCPDoor.reconcileServer` completion — the double-start's pane label can still flicker inside the bind→publish microsecond gap

**Mechanism (traced, corroborating the recorded residual).** Host started twice (the door's belt case): the second start binds+listens; the first start's probe meets it → `alreadyServed` → the first's catch checks `startStillOwed`; if the second has NOT yet published (`_state` not `.running` for the microseconds between its bind and its publish lock section), the first writes `.failed` and throws; the second then publishes `.running` over it. The two door completions race on the main actor: if the first's lands last, the pane reads "couldn't start …" beside a serving listener — the pinned symptom, now shrunk from the whole start window to microseconds. Self-corrects at the next snapshot change (`reconcileServer` reads `.running` and repaints). Also: a quiet-returned redundant start's completion reads `fresh.state` optimistically and may set `serverState = .running` a beat before the first start publishes — transient, self-correcting, and only reachable through the same double-start belt case the flag fix makes unreachable from the door. No action beyond naming it in the residual ticket; the 10-issue red-on-old proves the fixed class, and this remnant is orders smaller.

## F4 · NIT · closeout duty — MCPSpec owes VX-775 its contract line

`notes/MCPSpec.md` is authoritative for the door and currently still implies the pre-fix shape only via VX-369's catch-all sentence. The changed contract is: **a landed write whose Activity line cannot be written answers the act's own answer, byte-identical (R-825); the failure reaches the author as a refusal-kind line on the status seam; `list_my_activity` simply lacks the row (nothing synthesized, no retry)** — plus the recorded non-member, `show_in_app`'s identical shape (P-913-B3-4's ticket). Ledger row 9 already owns canon deltas; this names the specific line so it is not lost. (VX-889/VX-895/VX-343 need no new contract line — they land the existing VX-816 / R-819-1 / grammar contracts; the SurfaceContracts grammar sentence for What's New lives in the file header only, which is fine.)

## F5 · NIT · `TagsViewModel.createTag` reads `session.wing.currentID`, not `shownWing` — confirming the B2 record's parting observation as real

Same class as VX-889 one door over: during a switch's lag (the pane still listing the old wing until the read lands), a root tag minted from the pane lands in the NEW wing while the OLD wing's list shows — the tag never appears in the shown list and lives where she did not point. Traced in code (`TagsViewModel.swift:~100`, `createTag` → ops with `session.wing.currentID`). Out of this run's tickets by the brief's own fence ("fix only what the ticket names"); the B2 record already queues it for the closeout ticket pass — this finding seconds that, Bug · Suspected · Low.

---

## Clean bill — checked and found solid

- **R-825 wire purity (VX-775).** The failure value never reaches the wire; the act's answer is proven **byte-identical to a twin world** whose log works (pin A's control-world comparison — a real server over the socket, deterministic seeds). `recordLanded` is the ONE landed-line writer in the write family (grep: the only other `allowed: true` writers are `MCPShowTool` — recorded as P-913-B3-4, honestly out of scope — and `MCPReadTools`, whose line rides inside the read's own transaction, no split to make). All three `Landed` constructions carry the failure value; a zero-landed list call cannot hold one (unlogged implies landed > 0). The refused/parse/encode arms of `land` are byte-unchanged.
- **`MCPStoreFailure`** is a pure extraction of the chain's three store arms, order preserved (DatabaseError → Redacted → StoreLocked), placement in `MCPWireRefusalCopy.words` unchanged, guarded by pin F asserting the chain's sentences byte-for-byte — and it never carries SQL (VX-369's form held).
- **What landed stays landed:** the once-grant spend, the edit_take bracket savepoints, the client-named ⌥⌘Z entry and touch/churn all commit with the act and are pinned so (`whatLandedWithTheActStaysLanded`); the false transient "refused" Activity row is dead (pin B); list forms and `replace_tag` list landed items as landed with ONE coalesced failure counting them (pins C/D, P-913-B3-2's shape).
- **VX-613 host fix:** `stopCount` is bumped in exactly one place, inside `halt`'s locked section, which every stop road (`stop`, `stopWithTheProcess`, `abandon`, the bare `stop()` repeat) funnels through; `startStillOwed` additionally refuses `.running`/`.suspended`, so a start in flight across a LOCK's suspend now publishes nothing (an old silent hazard closed for free). `halt`'s own unlink stays fd-guarded (VX-548 2b intact). The DEBUG `startStepProbe` follows `stopWindowProbe`'s precedent and ships nothing (`#if DEBUG`). The four host pins are non-vacuous (each asserts the premise window before the behavior) and I re-ran them green on this tree.
- **VX-613 door fix:** the stale completion leaves `starting` to the stop that cleared it (`stopServer` does clear it — read in code), and `fresh.stop()` in the stale arm repeats the road that let the host go (VX-777's rule, untouched). `suspendForLock`'s `!starting` read is unaffected (the stale arm only runs on a host the door already dropped).
- **VX-895 fix is minimal and the mechanism is real:** the ONLY view reader of the model's ignored properties was the sheet's header reading `scope` (grep over the app: `wing`/`listedOrder`/`generation`/`groupIndex` are read by routing code only; `BookSearchModel` ignores only `session` and `generation` — no twin). The fix observes the LISTED answer's scope, so header and body stay one fact; pin A asserts after each pick's land (not mid-flight), pin B pins the mechanism with `withObservationTracking`, pin C's counts-differ fixture makes a stale line unpassable — and the counts half is honestly recorded HOLLOW with the revert-run evidence (A red at its two marked expectations ×2 voices, B red, C green). The oracle is DEBUG-only, owner-keyed, session-scoped; `.debugProbeScope` and `librarySearchDrawn` are verified Release no-ops.
- **VX-890 byte-identity verified independently:** the outer literal strips 12, the interpolation site sits at column 2, and `groupFacts`'s own lines land at columns 2/9/2/2 — exactly the old `grouped` CTE's bytes; `wornGroupFacts` differs by whitespace only, same columns and aliases, keyed arm preserved. Core search suites green unedited on this tree (re-run here).
- **VX-889:** `createReading` → `insertReading` runs `requireLiveWing` (Operations+Reading.swift:64), so pin E's dead-wing refusal is the op's own law, not the pin's invention; ONE value (`request.wingID`) feeds guard and mint so they cannot disagree (VX-816 honored); the checks move to the model beside the list they describe and clear only on a changed wing ID (rename keeps them — pin D); Home is byte-unchanged (pin C); nothing else in the sheet writes wing-blind (trace link 7 — verified: the mint is the sheet's one write).
- **VX-343:** the parser keeps heading/bullet meaning first, joins only raw-indented lines under an open bullet, ends the bullet on blank/heading/bullet/unindented — Markdown's indented continuation, lazy continuation deliberately not adopted (recorded, no notes file uses it); a whitespace-only line is blank; a nested bullet stays a bullet and adopts subsequent continuations (consistent with "keeps that meaning first"). The 0.9.5 fixture pin reads the actual tree file; the sweep covers every notes file.
- **The run's fences held:** the diff touches no `Sync/`, no custody/keychain, no editor seam, no schema; vx-940's named files (`MCPReadTools.swift`, the Queries wing projection, `MCPSocketTransport.swift`) are absent from the diff. The cast rule (Fable reviews the wire) is satisfied by this round.
- **Evidence chain per member:** seam-before-fix commits, red-on-old by behavioral revert with EXACT predicted issue counts (B1: 4-issue A + B red, C green; B2: 10 issues across A/B/D/E; B3 core: 20 and 10 issues; door pins: the single predicted reds in the b2b3 window), gates green (262/48 and 538/78), walks run where the words-guard allowed and the withholdings recorded honestly (the Terminal walk, the Settings pane, W2's unwalkable failure face) with pin-backed substitutes named. B4 contributed no code; VX-81's close is her verbatim ruling.
- **Hollow findings none to report beyond the run's own:** the band-counts half of VX-895 was already identified hollow by the implementer with the correct green-on-both evidence — the disposition is sound and VX-408's recorded-hollow disposition stands (a different mechanism: observation, not ordering).

## Dispositions sought from the implementer (cross-model flow)

- **F1:** agree/dispute the ordering hazard; if agreed, the one-hop funnel is a small, behavior-preserving change this run can land with the existing pin as its guard.
- **F2/F3:** agree they are the recorded residual's family; fold into the promised closeout ticket with the inode belt named. No code owed this round unless the belt is wanted now.
- **F4/F5:** orchestrator/closeout items; no implementer action.

---

## ROUND 1 — THE IMPLEMENTER'S DISPOSITIONS (B3's implementer, F1–F3; F4/F5 left to the orchestrator)

*Written after reading this file in full at fa0527993. Nothing built this pass; no source file touched. One throwaway headless probe, described under F2, lives in the session scratchpad and is not in the tree.*

### F1 — AGREE

The mechanism is right, and it is my record's risk (1), where I named the hazard but gave no structural answer:
- the receipt and the failure each hop to the main actor in their own unstructured `Task`;
- `StatusCenter.deliver` holds one message, and a `.receipt` clears `current`;
- so this call's receipt landing after this call's failure erases the one line her ruling demands.

That the order holds today is scheduler behaviour, not a guarantee. A list call widens the exposure to N+1 tasks.

**The fix shape I would build (on the reviewer's confirm):** one hop for a failing call's whole app-side tail. Since `onActivityLogFailure` is new in this run and has never shipped, its signature is free to reshape.
1. **`MCPHostHooks.onActivityLogFailure` carries the call's receipts too:** `(@Sendable (MCPActivityLogFailure, _ receipts: [MCPWriteReceipt]) -> Void)?`. Doc rule: when the hook is set and the call's log failed, the call's receipts ride THIS hook and never also `onWrite`, so the app lands them and then the failure in one hop.
2. **`MCPWriteTools.call`, success arm:**
   - `if let failure = landed.activityLogFailure, let tail = hooks.onActivityLogFailure { tail(failure, landed.receipts) }`
   - `else { for receipt in landed.receipts { hooks.onWrite?(receipt) } }`
   - A call whose log landed is byte-unchanged (receipts via `onWrite`, exactly as before this run). A host with no tail hook (headless) keeps the receipts on `onWrite`.
3. **`MCPDoor`:** the hook becomes `{ [weak self] failure, receipts in Task { @MainActor in self?.landWireCall(receipts, failing: failure) } }`, where `landWireCall` is one synchronous main-actor function: `for receipt in receipts { landWireWrite(receipt) }; landActivityLogFailure(failure)`. The order is then the order of two statements, not of two scheduled tasks. `landWireWrite` is the same road the receipts take today (`notesLeftDead`'s post, `landReceipt`), so nothing in the receipt's handling changes.
4. **The harness** captures both: the tail's receipts append to `receipts`, and the failure to `activityLogFailures`. Pins A/C/D keep their assertions unchanged, and one assertion is added: a failing call sent nothing through `onWrite`, and everything through the tail (a separate capture). That is the structural pin on the host side.
5. **App:** the face pin calls `landWireCall` directly and asserts that, under quiet, toast and off, the toast ends as the refusal and `lastShow` names the landed change. This replaces the face pin's two separate calls. The real-door pin stays the end-to-end oracle.

As the reviewer says, no red-on-old exists for this: it hardens an ordering assumption in new code, not a pre-existing wrong output. The pins guard the new structure.

What the shape does NOT change, said for the reviewer's final call: ordering ACROSS calls. An earlier call's receipt hopping late could still replace a later call's refusal toast. That is the seam's general "the latest message wins" posture and the same scheduling every MCP receipt rides today; it is outside this finding. The alternative that would also cover it is a door-held serial queue (one `AsyncStream` consumer on the main actor, fed in order by every MCP hook). I judge that heavier than this finding warrants, and it reaches the asks and the show road too.

### F2 — AGREE on the mechanism and the fold · DISPUTE the belt's suggested shape · the belt is the ticket's, not this run's

**Mechanism: agreed.** The publish-fail cleanup's `MCPSocketRoad.unlink(directory:)` removes by NAME. If a fresh host's `listen` probe lands in the stale start's bind→listen gap, it gets ECONNREFUSED, unlinks the stale host's path, and binds its own. The stale cleanup then removes the fresh host's file.

One sharpening of "the first by-name unlink reintroduced outside that guard": `halt`'s own unlink (VX-548 2b) is also by name. Its guard is "this host bound a listener (`fd >= 0`)", resting on "while its listener holds the path, no other host can bind it". The same `listen` TOCTOU (residual (f)) falsifies that premise for `halt` too, and for `listenerDied`'s unlink. My cleanup meets exactly `halt`'s precondition: its `listen()` has returned, so it holds a listening fd. So F2 is not a new class. It is the concrete consequence of (f) for all THREE by-name unlinks: `halt`, `listenerDied`, and the publish-fail cleanup.

**The suggested belt does not work as written.** I measured this headless with a throwaway C probe in the scratchpad: bind a unix socket at a short path, then compare `fstat(fd)` with `stat(path)`. On this Mac (macOS 27.0.1):
- `fstat(fd)` returned `dev=-1 ino=273660 mode=140666`, the SOCKET OBJECT's own identity;
- `stat(path)` returned `dev=16777234 ino=215461359 mode=140755`, the path's vnode;
- they never match, and after another socket stole the path, `fstat(fd)` still read 273660.

A belt written as `fstat(fd)` vs `stat(path)` would therefore refuse EVERY unlink. Every cleanup and every stop would leave its socket file behind. That is not fatal, because the next `listen` probe gets ECONNREFUSED and unlinks it, but it would be a regression in `halt`'s honesty.

The working belt captures the path's `(st_dev, st_ino)` by `stat` right after `bind` inside `MCPSocketRoad.listen` and returns it with the fd. Before every by-name unlink, it re-`stat`s and compares, and unlinks only on a match. A compare→unlink window of microseconds remains, because macOS has no atomic "unlink if inode".

**Why it belongs in the ticket, not this run:**
1. It must cover all three unlinks to close the class. Belting only my cleanup would leave `halt` and `listenerDied` exposed to the identical steal.
2. It changes `MCPSocketRoad.listen`'s return in `VariorumMCPSocket`, the module the shim shares. That is a new surface for this batch, with its own pin: the existing `.bound` gate plus a replaced file, as the reviewer sketches.
3. The recorded alternative, per-directory serialization of probe → bind → publish across hosts, closes the in-process family wholesale and may make the belt moot. The ticket should choose between them once, not land half of one now.

**Proposed ticket content** (for the orchestrator's closeout ticket pass: Bug · Suspected · MCP · Low), "the socket path's identity across hosts":
- residual (e): a fresh probe meeting a stale listener between its bind and its publish re-check;
- residual (f): `listen`'s probe→unlink→bind TOCTOU;
- F2: the by-name unlink steal, at three sites;
- F3: the double-start label flicker.

First piece: the bind-time `(st_dev, st_ino)` belt on every by-name unlink (NOT `fstat`, measured above), or the per-directory serialization instead. Pin: the `.bound` gate with the path replaced under it. Every one of these is a microsecond window behind the stop-mid-start premise, which this run's generation token already shrank from the whole start to the syscall gap.

### F3 — AGREE · fold into the same ticket · no action this run

Traced the same way, and it is my residual (e)'s remnant on the double-start road. The first start's catch sees `startStillOwed` true while the second is between its bind and its publish, so it writes `.failed` and throws, and the two door completions race. The reviewer's second point also holds: a quiet-returned redundant start's completion reads `fresh.state` and sets "running" a beat early. That is transient, self-correcting at the next snapshot, and reachable only through a double start the door fix (8db317e14) makes unreachable from the door. I would name both in the ticket above; no code.

### F4 / F5

Not mine (the orchestrator's closeout items), left as written.
