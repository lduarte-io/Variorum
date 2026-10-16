# VX-378 — Castle, simplified: the phase 1 corrector (the headless core rebuilt to the rules)

**Status: OPEN — written 2026-10-16 by the VX-305 orchestrator from the simplification sitting; kicks off at the
author's word with `/architect-phase vx-378`.** Same branch and worktree as VX-305 (`vx-305-castle-core`,
`~/dev/variorum-vx-305`); ONE merge to `main` at this phase's GO closes both tickets. The in-flight row for VX-305 gains
this plan file beside its own and keeps the one Sync/-or-custody slot.

- **The contract this phase builds to:** `notes/CastleRules.md` — THE binding design for library protection. Where it
  and `notes/plans/vx-266-castle-backups-prelaunch.md` differ, the rules win (the old design carries a banner saying so;
  its research and Apple-facts pointers stay alive).
- **The walk-through:** `notes/plans/vx-266/castle-lifecycle.html` — the target page; U3 proves it with a test and
  regenerates it from the run.
- **The record that produced this plan:** `notes/plans/vx-305-castle-core.md` — §8's HER RULINGS 2026-10-16 (the
  sitting, verbatim), §10 (the NO-GO, the bisect, the census, the key map's gaps). Read §8's sitting block in full; it is
  the why behind every cut here.
- **Tickets:** VX-378 (this phase, project "Castle & backups before launch"); VX-305 closes at the same merge, its
  record marked superseded by this plan.

> **KICKOFF MESSAGE** — the orchestrator's brief for each implementer session (paste-ready).
>
> You are building **"Castle, simplified"** — the corrector of Variorum's Castle rebuild phase 1. The headless
> protection core under `Sources/VariorumCore/Protection/` exists and is green, but it was built to a design the author
> has since cut down hard. Your job is to make the code match `notes/CastleRules.md` — mostly by REMOVING things, then
> adding the few new rules. Nothing in the app changes in this phase.
>
> **Read first, yourself, in full, in this order:**
> 1. `CLAUDE.md` and its auto-loaded canon; `notes/SessionResiliencyProtocol.md`.
> 2. **`notes/CastleRules.md`** — the contract. Every line of code you keep, cut or write traces to a numbered rule.
> 3. **`notes/plans/vx-266/castle-lifecycle.html`** — the walk the rules describe (open it in a browser).
> 4. **This plan**, whole — especially §3 (what each rule means for the model) and your unit's section.
> 5. `notes/plans/vx-305-castle-core.md` §2 (the code's shape as built), §8's HER RULINGS 2026-10-16 block (the
>    sitting, verbatim), and §10 (what the gate found). Skim its unit records only where your unit touches them.
> 6. `notes/SyncSpec.md` §3 and the 14b design's key hierarchy (`notes/plans/phase-14b-suite-e2ee.md`, R-5…R-8) — the
>    vault is wrapped by passphrase and words only; the words are the ACCOUNT's recovery secret.
> 7. `notes/plans/vx-266/second-opinion-apple-facts.md` — what the real Keychain, Touch ID and iCloud Keychain do.
>    The fakes behave the same way.
> 8. The old design `notes/plans/vx-266-castle-backups-prelaunch.md` ONLY where this plan or a rule points you at a
>    section; it is superseded where the rules differ.
>
> **Do:** the unit named NEXT in §7 LIVE STATUS — one unit per session — per its section below. Prefer deleting code
> and tests to editing them; a dead arm removed with its pins is the expected shape of a commit here.
>
> **Where your code goes:** `Sources/VariorumCore/Protection/` and `Tests/VariorumCoreTests/Protection/` only.
>
> **Hard limits:** no `App/`, `Sync/`, `Server/` or migration lines; `swift build` / `swift test` only — no `xcodebuild`,
> no stage, no app launch; no new dependency; the core compiles in BOTH configurations (`swift build -c release` before
> you report); nothing behind `#if DEBUG` but the guards' off-switches.
>
> **The checkpoint rules (binding from your first commit):** commit per coherent piece (a compiling state, named
> honestly) and push after every commit; write this plan's LIVE STATUS for your unit at your start and flip it in the
> same commit as each piece; mark every unverified claim **PENDING**; synchronous foreground waits only; no
> `Co-Authored-By` trailer; `Part of VX-378` in every message.
>
> **The rule against guessing:** where a rule is silent, write two or three options into your unit's record, build the
> most rule-defensible one, mark it **PROVISIONAL** and add it to `notes/QUESTIONS.md`. Never invent product
> behaviour; never relax a rule; never re-add anything in the rules' "considered and not pursued" list.
>
> **Pin before fix, red-on-old,** for every behaviour change that isn't a pure deletion. A deletion's proof is the
> protection set green with the dead pins removed and a one-line record of what died and under which rule.
>
> Do not spawn subagents or use the Agent tool, with one exception: at most ONE Sonnet lookup subagent at a time
> (`model: "sonnet"`) for external facts only; it never edits files or spawns agents. Never delegate reading of the
> repo's docs, this plan, the code or a diff.
>
> **Report back with:** what shipped and what was deleted (rule numbers); the test counts both configurations
> (`swift test` exit lines); the PROVISIONAL calls; the commits; anything for the author.

---

## 1. What this phase is, and how it closes

**One phase-sized unit — the protection model made to match the rules — in four implementer sessions.** Sizing is
guidance (her ruling); the split exists so each session holds one coherent piece: the cut, the additions, the lifecycle
proof, the world and soak.

**The phase closes at a GO / NO-GO — a quality gate, her word from VX-305: "go even if it delays launch."** It needs
all of:

1. **The generated scenario runs are green** across at least 20 seeds × at least 1,000 sequences × up to 60 steps,
   under `swift test` AND `swift test -c release`, both times recorded, on the final tree — AND a **discovery run** of
   seeds 21–40 green first (so the gate soak confirms rather than discovers; a failing discovery seed is triaged before
   the gate soak runs). VX-305's lesson: a green soak over one set of streams is not saturation.
2. **Every fixed scenario is green in both configurations** — the lifecycle scenario (U3) among them.
3. **Every mutation pin is red with its guard off** and green with it.
4. **A Fable cold-review ladder is closed** — CLAUDE.md's cap of three rounds (her VX-305 raise to five was for that
   phase; she may raise again at kickoff); every finding dispositioned here; the final round's fixes checked line by line
   by the orchestrator.
5. **The rules checklist is written:** one row per rule of `notes/CastleRules.md` (1–26), naming the test that proves
   the model does it, or saying honestly which later phase owns the row (faces, drills, live rounds). It REPLACES the
   47-row key map's acceptance checklist; `notes/plans/vx-305-key-map-model-half.md` becomes history.
6. **The lifecycle page is regenerated from the lifecycle test's run** and reads the same as the target page in every
   fact (a diff of facts, not of prose).

**Cast:** the standing default — Fable orchestrates and cold-reviews (`fable-reviewer`), Opus implements at xhigh, one
unit per session; she confirms or redirects at kickoff. No `Sync/` line is written; the phase holds the one
Sync/-or-custody slot it inherited from VX-305. No stage.

**Binding principles:** the 13b constitution P-1…P-9 and its application notes, byte-verbatim in
`.claude/skills/architect-phase/SKILL.md` and copied into `notes/plans/vx-305-castle-core.md` at that phase's
kickoff — binding here unchanged (not re-pasted, with this reason: the file they bind is one directory away and the
reading rule wants this plan short).

---

## 2. What was built, and why it changes (read `vx-305-castle-core.md` §8's sitting block for her words)

VX-305 built the design's full model: a protection record with a family tree and per-device sections, key file format 3
with a Castle anchor and legacy readers, a device memory with a key-file mirror and a hardware marker, plans with seals,
an assess step owing repairs and acts, an executor with 26 acts, and a scenario world with 17 starting states, 13
promises, a seeded generator and mutation pins. Its gate soak came back NO-GO (13 of 20 seeds; 17 failing sequences in
20,000 by census). The bisect showed most failures sat in machinery the author then cut: migration shapes, the leave's
anchor and stuck-leave wait, automatic repair of swapped files, the hand-off's shared-library identity. Her frame:
*"standard is a convenience + security posture, not a guarantee that our app will always handle things outside of its
control (apple)"* and *"castle is castle, castle backups are castle backups."*

---

## 3. The rules, and what each means for the model (the implementer's map; rule numbers are `CastleRules.md`'s)

| Rule | Model consequence | Unit |
|---|---|---|
| 1 key file essential + redundant | KEEP key file format 3 (minus the anchor); KEEP the device memory's sealed key-file mirror as THE on-device copy; the "copy-less rebuild" door is NOT built (rule 26 says the honest outcome) | U2 |
| 2 words at birth | `createLibrary` always mints words; `KeyFile` always carries a words wrap; the "no words" wrap state and every secretless branch (assess's secretless arms, corner 45) DELETED | U1, U2 |
| 3 passphrase asked + reminders | the record carries `passphraseSet: Bool` and `reminderDismissals: Int` (facts only; the faces are phase 3's); assess owes `.askPassphrase` on the schedule's two model-side moments (before a backup; after a quiet road failed) | U2 |
| 4 history within a mode | KEEP; entering takes everything (as built); leaving takes nothing (as built) | — |
| 5 a backup = library + its day's key file | KEEP | — |
| 6 re-lock on new secrets | KEEP (`ChangePassphrase`, `RegenerateWords`); the anchor sentences in their doors DELETED | U1 |
| 7 Standard = convenience; quiet roads re-made on ask | the Apple wrap on Standard keys KEEP; **ADD the on-device road in Standard** (Castle's Touch ID item type, gate Touch ID or login password); Re-link's "library arm" act DELETED — the lobby's normal path is "quiet road failed → secret typed → road re-made" (one leaf, run at open) | U1, U2 |
| 8 Castle: no Apple road ever | KEEP (promise 2/3 as built, minus the anchor exemptions) | — |
| 9 Castle account-wide; lagging device reads its own copy | KEEP the follow (types one secret); the older-build actor already gone; the "lagging device" boundary stays a stated limit in the promises | U4 |
| 10 entering Castle | KEEP EnterCastle minus: the anchor, the account Apple wrap handling, the rotation choreography. The sync-key rotation becomes ONE vault-row flip (the vault leaf's `rotate(newMaster, newRowKey)` CAS); export-off notice KEEP; retire own Apple keys KEEP (by library — rule 22 kills the predecessor-id reasoning) | U1, U2 |
| 11 leaving Castle | LeaveCastle = fresh Standard key, empty history, Apple wrap added, Touch ID item + mirror replaced, the vault row's MODE flag flipped (no key change on the server); other devices follow out quietly. DELETE: the anchor write, the stuck-leave wait, promise 6's vault-reach qualifier, "the one write that completes the leave" | U1, U2 |
| 12 only Castle backups stay Castle-only | a promise (U4) — stated exactly in her words | U4 |
| 13 vault wrapped by P and W only; join types a secret | the vault model loses its Apple wrap; `SetUpSync`/`Enroll` require a typed secret; the "silently joined device" start state DELETED | U1, U2 |
| 14 rows sealed under the key current at write; rotation at entry only | the vault model: `rowKeyID` changes only at EnterCastle; LeaveCastle leaves it; followers that lag refuse to sync until they follow (a fact the world checks) | U2, U4 |
| 15 Look inside | **ADD** `LookInside` act: opens a copy read-only with its own secrets or its own quiet road on this Mac; writes NOTHING (the world asserts zero writes) | U2 |
| 16 Make this my library = new library | `Land` becomes `MakeMine`: fresh library ID, fresh key in the device's current posture, Previous Libraries for the outgoing one; a landed library never carries sync identity (as today) | U1, U2 |
| 17 sync, not files | `SendLibrary` KEEP as "write a copy"; the receiver side is rule 16; the two-Macs-one-library start state DELETED | U1 |
| 18 other libraries' copies listed, deletable | catalog + retention + the offer's delete KEEP, narrowed to copies (no opening of other libraries' copies except Look inside); the gift machinery (per-library key files + own Apple keys for OTHER libraries' copies) DELETED | U1 |
| 19 crash safety | plans, seals, `settle` KEEP; with fewer acts the crash harness shrinks; `settle` loses the repair-first step and the memory-wins arm | U1 |
| 20 detect and refuse | the device memory KEEP for detection: file vs memory disagreement → `Fault.libraryDisagreesWithMemory` → REFUSE with the facts (no act, no repair). DELETE: `rekeyOlderLibraryFile`, `olderLibraryFileProof`, `restoreKeyFileFromCopy/FromMirror` as repairs (the mirror is restored ONLY when the live key file is ABSENT — rule 1's redundancy, not a repair of a stray), `setAsideLiveKeyFile`, every "memory wins" arm and promise-1 clause built for them | U1 |
| 21 delete after replacement verifies | KEEP (a guard + mutation pin) | — |
| 22 plain device ID | `HardwareMarker` and `resolveIdentity`'s takeover/anotherLogin DELETED; the device section keyed by a random `deviceID` minted at creation and stored in the memory item; a Migration Assistant move carries it like any item | U1, U2 |
| 23 both configurations | KEEP | — |
| 24 no Apple promise | the promises never require an Apple road to work; promise 13 shrinks to rule 12 + rule 14 | U4 |
| 25 no migration | DELETE `Migration` act, `LegacyReaders` (all), the 13p escrow/stuck-marker/old-shared-key reads and the old shared key's retirement ask and door, corner 45's notice and answer, every "today's store" starting state and fixture; the record's "unconfirmed mode" arm | U1 |
| 26 lost everything = lost | an honest refusal (`noKeyFileAnywhere`) naming the roads that would have worked; synced: the account road (rule 13) | U2 |
| considered-and-not-pursued | nothing from that list is built; a reviewer finding that proposes one is dispositioned by pointing at the list | all |

**Acts after the cut (the expected set, ~13):** CreateLibrary · EnterCastle · LeaveCastle · Follow (in: types a secret;
out: quiet) · ReplaceAllKeys · ChangePassphrase · ResetPassphrase · RegenerateWords · DeviceSettings (gate style, idle
lock, scheduled export) · TouchIDRearm · Backup/Copies (SendLibrary, PlaintextExport, the offer's delete) · LookInside ·
MakeMine · SetUpSync/Enroll · StopSyncingHere/DeleteAccountHere · ThisMacOnly/Move. Gone: Migration · ConfirmMode ·
MoveOffSharedKey · RetireSharedKey · RelinkApple · OpenCopy (→ LookInside) · Land (→ MakeMine).

---

## 4. The units

### U1 — THE CUT (one session; mostly deletion)

Remove, with their tests, pins and world machinery, everything §3 marks DELETE: migration and the legacy readers; the
anchor and stuck leave; the repair layer (rule 20's list) and `settle`'s repair-first/memory-wins arms; Re-link's library
arm; the old shared key (all of it); corner 45; the hardware marker and identity resolution; the gift machinery; the
hand-off's shared identity (Land → a stub that U2 rebuilds as MakeMine); the route finder beyond one sentence; the
"silently joined", "two Macs one library", "today's shapes" and older-build starting states; the generator alphabet's
dead actions; promises 1 (its repair clauses), 6 (the qualifier), 9 (the route finder), 10 (the tamper-repair reading),
13 (the anchor/rotation reading) — reduced, not yet rewritten (U4 rewrites). **Evidence:** the protection set green in
both configurations with the dead pins gone; a RECORD TABLE in §8 — one row per deleted thing: what, under which rule,
the tests that went with it. Nothing new is built in U1 except stubs that keep the tree compiling. Expect the source
line count to fall by roughly half.

### U2 — THE ADDITIONS (one session)

Build, with red-on-old pins per behaviour: words at birth (rule 2); the passphrase-asked facts and `.askPassphrase`
(rule 3); the on-device road in Standard (rule 7); the lobby's ask-and-re-make path for a failed quiet road (rule 7);
the vault without an Apple wrap, typed-secret joins, the one-row rotation at EnterCastle and the mode-flag flip at
LeaveCastle (rules 10–14); LeaveCastle's fresh key with the Touch ID item and mirror replaced (rule 11); `LookInside`
with its zero-writes assertion (rule 15); `MakeMine` (rule 16); detect-and-refuse with `libraryDisagreesWithMemory` and
`noKeyFileAnywhere` (rules 20, 26); the plain device ID (rule 22). **Evidence:** unit pins per rule; the executor's
crash-after-every-write harness green over the new acts; both configurations green.

### U3 — THE LIFECYCLE PROOF (one session)

One fixed scenario walking the lifecycle page's fourteen stages on one device (plus a second device for stages 9–12's
sync half), asserting at each stage exactly the page's facts: what was written, which roads open the live library,
which roads open each backup made so far. The scenario PRINTS those facts in a stable form, and a small generator
(`Tools/castle-lifecycle-page` or a test-side writer — your call, recorded) renders `castle-lifecycle.html` from them;
the committed page is the generated one, and a diff of its FACTS against the target page is empty (prose may differ; the
record lists any fact that had to change and why — each such change is hers to accept). **Evidence:** the scenario green
both configurations; the regenerated page committed; the facts-diff recorded.

### U4 — THE WORLD AND THE SOAK (one session)

Rewrite the promises to the rules — expected around ten, each quoting its rule: no Apple road reaches a Castle key or
Castle-made copy (8); only Castle backups stay Castle-only after a leave (12); rows written in Castle are under a key no
quiet road held (14); a lagging device syncs nothing until it follows (14); a backup opens with its day's secrets and
with current secrets within a mode (4, 5); every copy opens by SOME road the rules name, or the refusal names what would
have (26); a crash leaves old or new, said which (19); a disagreement refuses, never writes (20); deletes only after
replacement verified (21); nothing silent changes mode, account or roads outside a deliberate act (the kept core of
promise 10). The adversary alphabet keeps file replay/deletion as DETECTION tests (the app refuses), never repair
expectations. Starting states: the new-system shapes only (a fresh library; Standard with and without a passphrase; Castle
Touch ID and Always ask; synced variants; a Castle backup after a leave; a lagging device). Mutation pins for every guard
that survives. Then the discovery run (seeds 21–40) and the gate soak. **Evidence:** gate items 1–3.

---

## 5. Hand-forwards and the merge moment

- **Canon at the merge (hers to ratify, the closeout applies as ruled):** `CLAUDE.md`'s read-explicitly list gains
  `notes/CastleRules.md` (read in full before touching `Protection/`, custody or keychain code); the old design gets its
  banner (done on the branch, 2026-10-16); AppSpec §12's LIBRARY PORTABILITY line and §14's delta entry; the master
  plan's row and closeout paragraph; QUESTIONS gets the surviving PROVISIONALs (VX-305's quiet ones re-read against the
  rules — most die with their machinery) and this phase's.
- **Later phases, re-planned to the rules:** VX-306 (the lobby / open road — the ask-and-re-make path's face, Touch ID
  re-arm, the refusal faces of rules 20/26; the P-U4-13 keychain-mirror road is now rule 1's redundancy, not a rescue);
  VX-307 (crossings' faces — the leave screen's "keep your Castle secrets" sentence, the follow's one ask); the warning
  schedule's faces and the tutorial's last card (phase 3 / VX-3xx — ticket at kickoff); the field guide's **Start Here
  chapter** carries encryption, the twelve words, the passphrase and "Apple is a convenience" (a Wording ticket at
  kickoff); Look inside / Make this my library faces (phase 5 / VX-309, with T-8's plaintext-export-in and the
  empty-slot landing); VX-329's rehearsal: every tester exports or signs in before the switch (rule 25).
- **Dropped from every later plan** (the rules' considered-and-not-pursued list): the anchor, the stuck leave's face,
  the newest-copy offer, the migration road, Re-link as a door, the old shared key's retirement sheet.

---

## 6. Sizing & cutover

Four sessions, one unit each; the orchestrator verifies every hand-back (counts re-run both configurations, scope diff,
revert checks on pins) before the next spawn. The ~500k context line: the orchestrator plans its own cutover via the
two-document handoff form if needed. Economy rules from VX-305 stand: long foreground commands, minimal narration, the
record committed with PENDING numbers first.

---

## 7. LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- U1 — the cut: **NEXT.**
- U2 — the additions: not started.
- U3 — the lifecycle proof: not started.
- U4 — the world and the soak: not started.
- The ladder: not started.
- The gate: not started.

---

## 8. Records (each unit appends: what shipped / what died with its rule, counts both configurations, PROVISIONALs, commits, notes)

*(empty)*

## 9. The ladder

*(empty)*

## 10. The gate and the rules checklist

*(empty)*

## 11. Closeout

- Both plans' STATUS banners flip (VX-305's to SUPERSEDED-AND-CLOSED, pointing here; this one to CLOSED).
- Canon deltas exactly as §5 and her rulings; QUESTIONS; the master plan; the handoff `notes/handoffs/vx-378-handoff.md`
  (her checklist at the top; the filed tickets by priority); the next phase's plan (VX-306, written to the rules) with
  its kickoff; MOBILE PARITY: "nothing mobile-visible".
- The PR `VX-378: …` merges to `main` as a merge commit at her word, closing VX-378 and VX-305; the worktree is removed;
  hard stop.
