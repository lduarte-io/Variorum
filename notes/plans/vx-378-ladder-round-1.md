# VX-378 ladder round 1 — cold review

**Reviewer:** Fable (fresh, zero implementation context), 2026-10-17. **Diff:** `63cf038f1..ce3ee92e7` (the whole
phase). **Read in full before the code:** `notes/REVIEW_PROMPT.md`, `notes/CastleRules.md` (the contract),
`notes/SyncSpec.md`, `notes/plans/vx-378-castle-simplified.md` (the plan, §1–§8 incl. every unit record),
`notes/plans/vx-305-castle-core.md` (as pointed), the lifecycle page. Code and tests read in this session; targeted
`swift test --filter` runs in the read-only review worktree.

Findings are written incrementally as confirmed; severity-ranked at the end of the pass. Format:
`[severity] · file:line · what · evidence · fix`.

---

## Findings

**[MINOR] · `Sources/VariorumCore/Protection/Assess/Assess.swift:193` (`AssessRules.lobby`) · Rule 27's lobby refusal
is silenced by ANY custody item, including a silent item that verifiably opens nothing — the same class as census
(D)'s memory-item fix, one tier over.** Evidence (traced mechanism): the refusal requires `facts.custody.isEmpty`,
but custody items are per-KEY (`<scope>-<fp>-<class>`), not per-library, and nothing deletes a previous library's
silent item when another library takes the live place — `MakeMineProgram`'s after-commit steps are
`forgetOtherLibraries` (MEMORY items only, `Copies.swift:195-202`) and `backup`; `retireOldCustody`'s Castle sweep
(`CommonSteps.swift`) deletes silent items only for keys in the LIVE file's tree, so a stray key's item survives every
later act. Concrete sequence: Make this my library in Standard (the previous library's silent item stays — correct in
itself: rule 17's Look inside keeps its quiet road) → Use Castle on the new library under Always ask (the sweep skips
the stray — not in the new tree) → the new library's key file, its memory item and every backup later lost (a purged
far folder; not reachable in the world, whose acts always leave a backup — which is why the soak never saw it). The
lobby state is then: a library in the slot, no key file anywhere, nothing remembered, one stray silent item that
verifiably fails against the library — rule 27's refusal is owed by its letter ("A library whose every key-file copy
and every backup are gone is gone") and `lobby` says nothing, because `custody.isEmpty` is false. The failure is a
MISSING honest message after every road fails, never a wrong open — key safety is untouched. The precedent is exactly
census class (D) (piece 4j, `aMemoryItemWithNoKeyFileCopyDoesntSilenceRule27`): a home that opens nothing must not
silence the refusal. A silent item is readable without a press, so the fact is knowable pre-unlock; a Touch ID item
must KEEP silencing (it cannot be verified without a press — honest uncertainty). Fix shape: a new
`ProtectionFacts` fact in the class-(D) pattern (e.g. `custodyOpensLibrary: Set<CustodyItemFact>?`, nil = not read —
every item then counts, the conservative old reading), fed by the leaf's silent-item read + `libraryOpens`; the lobby
counts a silent item only when it opens the library (or the fact is nil), Touch ID items always. Pin (red-on-old, unit
tier): `AssessRules.lobby` facts with `storeFile: .present`, no key files in the catalog, `rememberedLibraryIDs: []`,
`rememberedKeyFileCopies: []`, one silent `CustodyItemFact` marked as failing — expect `noKeyFileAnywhere != nil`;
red on this tree, green after. (A world pin needs a backups-deletion step the alphabet deliberately lacks; the unit
pin is the honest tier.)

**[MINOR] · `Sources/VariorumCore/Protection/Model/DeviceMemory.swift:10-22` · The model header still teaches the
DELETED refusal design and quotes rule 21's superseded wording.** Evidence: lines 16-18 say a disagreeing memory
"is rule 21's disagreement — the open refuses (`LibraryDisagreement`)" — `LibraryDisagreement` was removed whole at
the U4 resumption's piece 3 (her ruling: the NOTICE instead of the refusal; `git mv` to `LibraryNotice.swift`); a
grep shows this comment is the only surviving reference in the tree. Lines 10-12 quote rule 21 as "its ID, its
current key, its device ID and the sealed copy of its key file" — the committed `notes/CastleRules.md` rule 21 now
reads "its ID, its device ID, a fingerprint of its current key, and a copy of its key file: the key itself, still
wrapped under your locks". These headers are the subsystem's design record (the files carry the binding comments a
fresh session reads first); this one would rebuild the refusal mental model her U4-stop ruling removed. Fix: rewrite
the header's rule-21 paragraph to the notice design (open-and-say-once, `LibraryNotice`, absence is no disagreement,
the memory follows at the open's repairs) and quote the current rule text. Doc-only — no pin.

**[NIT] · `Sources/VariorumCore/Protection/Executor/Acts/CommonSteps.swift:99-113` · `newKeyFile(rekeyTo:)`'s
`kind == nil` arm ("a landing, a creation" → `KeyFile.building`, a file with NO history) is dead code, and it is the
one arm that would skip rule 4's carry.** Evidence: all five callers pass a concrete kind (EnterCastle `.castle`,
LeaveCastle `.standard`, Follow `newKind`, AccountActs `to`, ReplaceAllKeys `kind`); the landing died with U1 (Make
this my library builds its own file in `makeMineKeyFile`, the creation in `createLibrary`). A future act passing nil
would silently mint a history-less re-key. Fix: make the parameter non-optional and delete the `KeyFile.building`
fallback (or precondition on it). Pure deletion — the protection set green is the proof.

**[NIT] · `Sources/VariorumCore/Protection/Assess/CatalogNames.swift:17-18` and
`Tests/VariorumCoreTests/Protection/Scenario/StartingStates.swift:40-42` · Two more comment-drift instances.**
(a) CatalogNames' header lists the set-aside `.stale-<epoch>.json` shape among "the names THIS design writes … and
only those", with "(until VX-378 U1's repair piece)" — U1's record table deleted the name, the parser arm and
`KeyFileRole.setAside`; `parseFile` has no arm for it, so the list disagrees with the code below it and the
parenthetical reads as pending work that is done. (b) StartingStates' `fresh` builder doc still says "Use Castle's
own press records no gate style — a gap in the kept machinery … VX-378 U1's record hands it forward" — U2 piece D
closed exactly that gap (`useCastle` writes the press's gate style; `U2PinsGateTests`), so the builder's defensive
`setGate` press never fires and the comment teaches a closed gap. Fix: drop the bullet / reword the builder doc.
Doc-only — no pin.

**[NIT] · `Sources/VariorumCore/Protection/Assess/Assess.swift:171-205` (`AssessRules.lobby`) + the VX-306
hand-forward · `LobbyRoads.typed` reads the LIVE key file only, while the offer-era open's typed roads include rule
1's keychain mirror (and, for the world's lobby, every catalogued pair).** Evidence: `lobby` computes `typed` from
the live file's locks alone; the scenario world's `walkLobby` (World.swift:664) deliberately walks "this Mac's
keychain copy too (rule 1's third home)" and every catalogued key file, which is what makes rule 21's offer reachable
after a stray lands in the live place. A VX-306 lobby face fed by `LobbyRoads` alone would show the stray's locks as
the typed roads in exactly the state the offer exists for. Not a model bug (the real lobby is phase 2/VX-306's, and
the plan hands the lobby face forward); flagged so VX-306's plan names the mirror road in `LobbyRoads` or beside it.
No pin at this tier — a face-phase concern, recorded for the hand-forward list.

## Clean bill (load-bearing things specifically checked and found solid)

1. **Scope.** The whole-phase diff (`63cf038f1..ce3ee92e7`, 117 files) touches only
   `Sources/VariorumCore/Protection/`, `Tests/VariorumCoreTests/Protection/` and notes (the plan, QUESTIONS,
   CastleRules, the lifecycle page, the design doc's banner, the key-map record). Zero `Sync/`, `App/`, `Server/` or
   migration lines; the vault's new shape is modelled in `VaultModel` only and the server's §12 lockstep event is
   named as VX-307's in §5 and on `VaultLeaf`. The final code tree is `bec58a576` (the two commits above it change
   only the plan file — diff checked).
2. **The rules, 1–27, traced to code and tests one by one.** Highlights verified in the source: rule 2 (words at
   birth; `KeyFile.locking` refuses `noWordsLock`; every new-file path carries a words road); rule 4 (every re-key
   goes through `KeyFile.rekeyed` — all five call sites pass a concrete kind; history deduped by fingerprint, never
   the new key; quiet roads open only directly-held keys — `RouteFinder` and promise 1's reach alike); rules 11/15
   (`VaultModel.enteringCastle` is ONE CAS write — new master + new sync key, outgoing and earlier keys re-sealed
   under the new master, mode Castle; `leavingCastle` flips the flag and changes no key; `AccountKeys.rowKey(for:)`
   reads a row by its own label); rule 12 (the leave re-keys with the full history, Apple road + silent item back;
   the follow out quiet with its notice; the lagging catch-up types one secret — the FLOOR per her U4-stop ruling);
   rule 14 (no Apple wrap in `AccountVault`; joins type one verified secret); rule 16 (the leaves re-key nothing and
   ask nothing); rule 17 (Look inside is no act — zero writes asserted at the executor harness AND the world's
   `lookInsideWrites`; Make this my library mints fresh identity/key/device ID under the current pair, no master,
   the outgoing library aside WHOLE with its key file; the history carry REVERTED at her ruling, the "no past"
   assertion back at `LifecycleChecks.swift:439`); rule 20 (begin/steps/resume/rollback/finish-from-record; the
   rollback restores the live key file from the mirror or the plan-carried outgoing file, deletes the new key's
   custody items, and lets go of exactly the sync keys the act took — census classes J/M); rule 21 (her notice and
   offer strings byte-verbatim as model constants — `U4NoticeTests.herWordsAreTheModelsValues`; the notice keys on
   disagreement never absence; the open writes nothing; the offer search is read-only, every candidate key verified
   against the library, acceptance on a plan writing only the library's own file); rule 23 (plain random device ID;
   no hardware anything — grep clean); rule 26 (format-3-or-nothing; `recordMissing` with no face string); rule 27
   (the lobby refusal + the post-unlock fault, the account road named — its one corner is finding 1).
3. **Nothing from the considered-and-not-pursued list is built.** Greps for the anchor, the family tree, the
   hardware marker, the legacy readers, the old shared key, Re-link, the rotation fields find only the deliberate
   "left with VX-378 U1/U2" history comments.
4. **Rule 24 verified myself:** `swift build -c release` green in the review worktree; `#if DEBUG` appears nowhere
   in `Protection/` sources but `ProtectionGuards`' off-switches, which compile to constant `true` in Release.
5. **The counts re-run myself (review worktree):** the protection set — all 74 suites — Debug `✔ 296 tests in 74
   suites passed`, matching the piece-4 close exactly; `-c release` `✔ 273 tests in 70 suites passed`, matching the
   resumption's release line on `bec58a576` exactly; the lifecycle suites green in all four walks; the
   chip-discrimination and other-road guards green.
6. **The lifecycle proof's chain holds:** the fixture commit (`bb0550230`) precedes the scenario commit
   (`bdd19624e`, red at exactly FD-1/2/3 per its message); the committed
   `castle-lifecycle.html` is byte-identical to a fresh render from the fixture (`cmp` run myself); the FACTS DIFF
   mechanism is empty after her rulings with the under-review notes gone.
7. **Red-on-old discipline spot-verified by my own revert check:** the resumption piece-2 pin
   (`U4LaggingPairScenarios.aLaggingDeviceOpensWithItsLastSyncSecretsThenCatchesUpWithOneSecret`) run on the
   pre-piece tree `1f74825b6` (clean source extract, the pin file copied in) — `✘ … failed … with 7 issues`, exactly
   the record's seven lines; green on HEAD. Every other piece's red-on-old is recorded with its scratch tree and
   exact issue lines, and the orchestrator's notes carry independent re-runs and revert checks for U1/U2.
8. **The guards:** all 12 have red-with-guard-off pins — 7 world pins through the `mutationPin` helper (which
   asserts BOTH green-guarded and red-unguarded) plus unit pins in `AssessGuardTests`/`ExecutorGuardTests`, each
   flipping exactly its switch; the four without a world pin are recorded with why.
9. **The promises are an independent oracle:** they re-derive verdicts from raw world state (files, keychains, the
   eventual iCloud, the vault) through their own reach engine, with attacker seeds and her-roads seeds separated and
   L1–L6 each carrying a ruling pointer; each checker catches its own planted breach (`U4PromiseCheckTests`, 9, run
   green); promise 7's notice oracle is the world's own reading, checked against the open at every launch together
   with the open's zero-write property.
10. **No secret leaks:** `ProtectionScanTests` (no secret in any stored value) and `ExecutorLogScanTests` green;
    `TypedSecrets`/`CreatedLibrary`/`AccountKeys`/`LookedInside` redact their descriptions.
11. **The record is honest about what is NOT done:** the discovery run incomplete (seeds 35–40 pending at
    `ce3ee92e7`), the gate soak not started — both named openly in LIVE STATUS and piece 5/6; the resumption's
    counts marked PENDING; the one full-suite red in U3's orchestrator re-run named honestly as the known
    `StarContextTests` timing class, outside Protection.
12. **QUESTIONS** carries every PROVISIONAL (U1-1/2, O1-1, U2-1…5, U3-1/2, U4-1…7) with options, status and her
    verbatim rulings where made; the FACTS DIFF bundle is there for her.
13. **Soak spot-check re-run myself:** seed 22 × 1,000 sequences × ≤60 steps, release configuration
    (`PROTECTION_SOAK=1 PROTECTION_SEED=22 PROTECTION_SOAK_SEEDS=1 PROTECTION_SOAK_SEQUENCES=1000`) —
    `✔ Test run with 1 test in 1 suite passed after 265.575 seconds`, 44,838 steps: GREEN, and the step count matches
    the census table's seed-22 line (44,838) exactly — the generator reproduces and that seed's zero-failing claim
    holds under my own hands.

*(Round-1 reviewer's note on the gate: items 1 (both soaks on the final tree) and 5 (the rules checklist) are still
open by the plan's own sequencing — not findings; any fixes from this ladder re-run the discovery per gate item 1.)*
