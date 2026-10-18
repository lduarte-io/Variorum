# VX-378 ladder round 2 — cold review of the round-1 fixes

**Reviewer:** Fable (fresh, zero implementation context), 2026-10-17. **Diff:** `ce3ee92e7..94f295c9e` (the three
fix commits `37cf0d61f` · `b6f5f7d6c` · `94f295c9e`), re-reviewed against round 1's recorded findings and
dispositions (`notes/plans/vx-378-ladder-round-1.md` + the plan's §9 Round 1 entry) and anything the fixes touch.
**Read in full before the code:** `notes/REVIEW_PROMPT.md`, `notes/CastleRules.md`, `notes/SyncSpec.md`, the plan
(`vx-378-castle-simplified.md`) with `vx-305-castle-core.md` as pointed. Code read and tests run in the read-only
review worktree at `94f295c9e`; the revert check in a clean scratch extract outside it.

Format: `[severity] · file:line · what · evidence · fix`.

---

## Findings

**[NIT] · `Sources/VariorumCore/Protection/Model/DeviceMemory.swift:17-25` · The rewritten header's notice sentence
over-claims: "a memory naming … another key … is rule 21's disagreement, and the open GOES ON, says so once" — but
for two documented another-key cases the open says NOTHING.** Evidence: `LibraryNotice.check`
(`Assess/LibraryNotice.swift:85-93`) returns nil when this Mac's own act in flight explains the two keys, and when
the library has MOVED ON past the memory (the live file's history carries the remembered key — PROVISIONAL
P-VX378-U4-5); both exemptions are real behavior and are documented on `LibraryNotice` itself, which the header
names. The header is the subsystem's design record (round 1's F2 bar), so the summary should not promise a notice
the check deliberately withholds. Fix: one parenthetical after "says so once" — "(unless this Mac's own act in
flight explains the two keys, or the library has moved on past the memory — `LibraryNotice`)". Doc-only — no pin.

**[NIT] · `Sources/VariorumCore/Protection/Assess/Facts.swift:185-193` + the world feeder
`Tests/VariorumCoreTests/Protection/Scenario/World.swift:845-852` · The new fact's contract is silent on a FAILED
silent-item read, and the one existing feeder's `try?` shape classifies a failed read as opens-nothing.** Evidence
(traced, world tier): the feeder's `guard … let key = try? leaf.readCustody(…), (try? leaf.libraryOpens(with: key))
== true` folds three distinct outcomes — verified-opens, verified-fails, could-not-read — into in-set / out-of-set;
an item whose read failed would count as "verifiably opens nothing" and stop silencing rule 27's refusal. In the
scenario world this is UNREACHABLE (traced: `readCustody` is a dictionary lookup and `pressRead` on a silent item
returns the value unconditionally, `World.swift:551-555` — no throw, no press, no mutation), so there is no pin at
this tier and no behavior bug today. The hazard is the production feeder VX-306 will write from this example: a
transient keychain read error would surface rule 27's refusal while a working quiet road exists. Fix: one sentence
on the fact's doc ("a feeder that cannot READ an item feeds nil — or includes the fingerprint — never omits it as
failing") and/or a line in §5's hand-forward beside N5's, so VX-306's feeder inherits the rule. `SPECULATIVE` at the
production tier (no production feeder exists yet).

*No BLOCKER, MAJOR or MINOR findings. The fixes are faithful to the round-1 findings and to the rules.*

---

## Clean bill — each round-1 finding's fix and pin, plus what the fixes touch

1. **F1 (rule 27's lobby, `37cf0d61f`) — SOUND, and the pin is honest at a stronger tier than recorded.** The
   mechanism re-traced end to end: `AssessRules.lobby` (Assess.swift:186-201) now counts a silent custody item as a
   road only when `custodyOpensLibrary` holds its fingerprint (or the fact is nil — the conservative old reading,
   byte-equivalent to `custody.isEmpty` for the refusal); a non-silent (Touch ID) item always counts, per the
   finding's honest-uncertainty rule; empty custody behaves exactly as before. The fact (Facts.swift:193, default
   nil) matches the round-1 fix shape (fingerprints for `Set<CustodyItemFact>` is an equivalent key — only silent
   items are consulted and custody names are per-fingerprint). **My own revert check, beyond the recorded
   "red by construction":** a clean scratch extract of `94f295c9e` with ONLY `Assess.swift` reverted to
   `ce3ee92e7` (the fact and the pin kept, so it compiles) — `swift test --filter U2PinsRule27Tests` fails with
   EXACTLY one issue, `aSilentItemThatOpensNothingDoesntSilenceRule27` arm 1, the other three tests green; on
   `94f295c9e` all four pass. So the pin is a true behavioral red-on-old, not only an API-construction red.
2. **F1's blast radius checked — the finding's class does not recur one arm over.** The post-unlock rule-27 fault
   arms (Assess.swift:252-258 — opened by a quiet road with no key file anywhere; :270-279 — a stray in the live
   place with no home holding the library's own file) key on key-file homes and never on bare custody presence; the
   offer search's refusal (`KeyFileOffer.searchKeyFiles`, :146) tries silent items per candidate FILE and cannot be
   silenced by a stray item with no file. All three are coherent with the fixed lobby: a silent item that OPENS
   silences the pre-unlock refusal (the library is not gone), while the post-open fault still says the key-file
   warning (`openedByAQuietRoadWithNoKeyFileAnywhereIsSaid`, green).
3. **F1 and promise 5 agree in both directions.** The promise oracle's independent reach engine seeds every
   readable keychain key — silent custody items included (`Promises.swift:282-289` via `pressRead`) — so a silent
   item that opens makes the slot reachable (no refusal demanded, lobby silent) and one that fails leaves it
   unreachable (refusal demanded, the fixed lobby now speaks). The one asymmetry — a Touch ID item holding the
   right key under unusable biometry (reach says no road; the lobby always counts the item) — is pre-existing,
   her-ruled honest uncertainty, and unreachable without the backups-deletion step the alphabet deliberately lacks
   (round 1's own note). The world's facts feeder is a pure read (`pressRead` mutates nothing — traced), so
   computing the fact at every assess step changes no world state.
4. **N3 (`newKeyFile(rekeyTo:)` non-optional, `b6f5f7d6c`) — SOUND.** All five callers pass a concrete kind
   (EnterCastle.swift:38 `.castle`, LeaveCastle.swift:43 `.standard`, Follow.swift:100 `newKind`,
   AccountActs.swift:88 `to`, ReplaceAllKeys.swift:33 `kind`); the deleted `KeyFile.building` arm was the one road
   that could mint a history-less re-key (rule 4), and `KeyFile.building` keeps exactly its two legitimate
   no-history users (`createLibrary` DeviceActs.swift:127, `makeMineKeyFile` Copies.swift:119). Pure deletion;
   the set green is the proof, as recorded.
5. **F2 + N4 (the three header fixes, `94f295c9e`) — SOUND.** DeviceMemory's header now quotes rule 21
   byte-identical to the committed `CastleRules.md` and teaches the notice design as built (`LibraryNotice`'s two
   strings verbatim, open-and-say-once, memory follows at the open's repairs, absence is no disagreement);
   `LibraryDisagreement` has ZERO references tree-wide (grep). CatalogNames' name list now agrees with its parser
   (no `.stale-` arm; Catalog.swift:14's surviving mention is a deliberate left-with-U1 history note, round 1's
   blessed class). StartingStates' fresh-builder doc matches the code: `useCastle` writes the press's gate style
   (EnterCastle.swift:66-68, `U2PinsGateTests`) and the builder's `setGate` press is a guarded belt that never
   fires. The one residue is this round's NIT 1 above.
6. **N5's disposition — SOUND.** §5 carries the lobby-face hand-forward verbatim for VX-306 (the mirror road in
   `LobbyRoads` or beside it); correctly no model change, no pin.
7. **Counts, my own runs on `94f295c9e` (review worktree):** the protection set — Debug `✔ 297 tests in 74 suites
   passed` (round 1's 296 + the new pin, same 74 suites); `-c release` `✔ 274 tests in 70 suites passed` (273 + the
   pin — the pin runs in release too). The new pin suite alone: 4/4 green.
8. **The orchestrator's one release red (the wider filter, §9) is structurally not the fixes':** the diff touches
   zero Sync lines, and Protection/ and Sync/ sources reference each other nowhere (greps both ways); the named
   failure is the multi-tenant Sync attacker class outside the protection set. Noted, not re-run — outside this
   round's scope.
9. **Scope and hygiene:** the round-2 diff touches only `Sources/VariorumCore/Protection/`,
   `Tests/VariorumCoreTests/Protection/` and notes; no `Sync/`, `App/`, `Server/`, schema or migration lines; the
   three commits carry no `Co-Authored-By`/`Claude-Session` trailers; the fix commits are per-piece with the pin
   named in the message.
10. **Process observed and recorded honestly:** the fixes were applied by the Fable orchestrator under the
    resiliency protocol's budget-death road (the Opus pool out on its session limit), recorded openly in §9 with
    every mechanism traced and the pin named — and the ladder's protection held regardless: this round is the
    fresh re-check the flow exists for. Gate sequencing is honest: discovery seeds 35–40 and the gate soak run on
    the FINAL tree per §9/LIVE STATUS, and gate item 1 re-runs the discovery after this ladder's fixes.
