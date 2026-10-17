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
> **Five answers you will need in U2, already ruled (do not re-open):** whose secrets at join / sync setup / Make this
> my library — rule 7 and the crossings table under §3; the account keeps every sync key it has had in a list under
> the current master — rule 15 (replaces the old previous-key field); detection is reading (ii) — rule 21, the memory
> is four things and the family tree is gone; the Standard on-device road is today's silent login-keychain item, no
> biometric ACL — §3's rule-8 row; the key file's master wrap and its twelve-words copy are load-bearing — §3's rule-1
> row. Zero-writes for Look inside is asserted in U2 (executor harness) AND U4 (the world).
>
> **If building reveals a serious issue with the design — a rule that cannot be built as written, two rules that
> conflict in code, a core aim (`CastleRules.md`'s one sentence, the one-posture frame, Castle's promise) that the model
> cannot meet — STOP that unit at a clean seam.** Record the issue in §8 with the trace (which rule, which code, which
> sequence), commit, and report it. The orchestrator brings it to the author before anything moves. Never patch the
> design silently, never add a handler to make a rule hold, never mark a rule PROVISIONAL to get past it — the rules are
> hers, and a rule that needs machinery to stay true is exactly what she wants to hear about.
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
   the gate soak runs, and any fix re-runs the discovery — BOTH runs land on the FINAL tree). VX-305's lesson: a green
   soak over one set of streams is not saturation. **The standing red-soak diagnostic:** VX-305's census patch (record
   every failing sequence and continue, applied in a scratch worktree only) sizes any NO-GO in one run; the `CENSUS`
   line shape is in `vx-305-castle-core.md` §10.
2. **Every fixed scenario is green in both configurations** — the lifecycle scenario (U3) among them.
3. **Every mutation pin is red with its guard off** and green with it.
4. **A Fable cold-review ladder is closed** — CLAUDE.md's cap of three rounds (her VX-305 raise to five was for that
   phase; she may raise again at kickoff); every finding dispositioned here; the final round's fixes checked line by line
   by the orchestrator.
5. **The rules checklist is written:** one row per rule of `notes/CastleRules.md` (1–27), naming the test that proves
   the model does it, or saying honestly which later phase owns the row (faces, drills, live rounds; the server's vault
   change under VX-307). It REPLACES the 47-row key map's acceptance checklist; `notes/plans/vx-305-key-map-model-half.md`
   becomes history.
6. **The lifecycle page is regenerated from the lifecycle FIXTURE**, which the lifecycle test asserts against (U3 —
   fixture-first): the page's facts are extracted into one machine-readable fixture BEFORE the test is written, the test
   is red-on-old by construction, and a fact that must change is a fixture diff, each hers to accept. Prose may differ;
   facts may not without her word.

**A serious design issue stops the phase, not the rule (her word, 2026-10-16):** if any unit, the ladder or the gate
shows a rule that cannot be built as written, two rules in conflict, or a core aim the model cannot meet, the
orchestrator records it (§8, with the trace) and brings it to her before anything is changed or worked around. The rules
document is amended only by her ruling; the plan then follows.

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
| 1 key file essential + redundant | KEEP key file format 3 (minus the anchor); KEEP the device memory's sealed key-file mirror as THE on-device copy, restored ONLY when the live key file is ABSENT (redundancy, never a repair of a stray); the "copy-less rebuild" door is NOT built (rule 27 says the honest outcome). **LOAD-BEARING, do not cut as anchor collateral:** the key file's MASTER wrap and its twelve-words copy of the master (old design §3.5a, present in the built `KeyFile`) — they are what let a one-secret follow produce a file both secrets open | U1, U2 |
| 2 words at birth | `createLibrary` always mints words; `KeyFile` always carries a words wrap; the "no words" wrap state and every secretless branch (assess's secretless arms, corner 45) DELETED | U1, U2 |
| 3 passphrase asked + reminders | the record carries `passphraseSet: Bool` and `reminderDismissals: Int` (facts only; the faces are phase 3's); assess owes `.askPassphrase` on the schedule's two model-side moments (before a backup; at the first launch after a quiet road failed) | U2 |
| 4 the key file carries EVERY earlier key; every key change carries it forward; quiet roads never traverse it | KEEP the history; **the leave's "empty history" arm DELETED** (LeaveCastle re-keys exactly as ReplaceAllKeys does, plus the Apple wrap and the on-device item back); the route finder reduces to ONE sentence — *"your current passphrase or words; on this Mac, its quiet road if it still holds that key"* — and stops being a promise | U1 |
| 5 a backup = library + its day's key file | KEEP | — |
| 6 re-lock, not re-key | KEEP (`ChangePassphrase`, `ResetPassphrase`, `RegenerateWords` re-wrap the current key); the anchor sentences in their doors DELETED | U1 |
| 7 one pair of secrets per account | `SetUpSync` hands the library's pair up (the vault's P and W wraps are the library's); `Enroll`/join re-wraps the key file under the account's pair and reports `wordsReplaced` (the face says it); the key doors change key file AND vault together (already the built shape — `KeyDoors.swift`); `MakeMine` keeps the device's current pair; only `createLibrary` mints words | U2 |
| 8 Standard = convenience; quiet roads re-made, asked only when none remains | the Apple wrap on Standard keys KEEP; **the on-device road in Standard is today's SILENT login-keychain item** (`WhenUnlockedThisDeviceOnly`, no biometric ACL — a gated item would prompt on every read and stop Standard being quiet; "login password or Touch ID" is what that item already means in honest terms, apple-facts §12); the lobby's path at a failed quiet road: open by any quiet road that still works → re-mint the Apple item silently; ask a secret only when none works. Re-link's "library arm" act DELETED | U1, U2 |
| 9 Castle: no Apple road ever | KEEP (promise 2/3 as built, minus the anchor exemptions) | — |
| 10 Castle account-wide; lagging device reads its own copy | KEEP the follow (types one secret IN; quiet OUT); the older-build actor already gone; the "lagging device" boundary stays a stated limit in the promises | U4 |
| 11 entering Castle types the passphrase; entering takes everything in | KEEP EnterCastle minus: the anchor, the account Apple wrap handling, the rotation choreography. Deletes the Apple item AND the Standard on-device item (the Apple delete propagates — the fake models it); the sync-key change becomes ONE vault-row CAS write (new master, new row key, the earlier row keys re-wrapped under the new master — rule 15); export-off NOTICE kept, reversible by the user (a setting, not a lock); retire own Apple keys KEEP, by library | U1, U2 |
| 12 leaving Castle types the passphrase; leaving hands everything out | LeaveCastle = a new Standard key CARRYING the history (Castle keys included), Apple wrap added, on-device item back, Touch ID item + mirror replaced, the vault row's MODE flag flipped (no key change on the server); other devices follow out quietly. DELETE: the anchor write, the empty-history arm, the stuck-leave wait, promise 6's vault-reach qualifier, "the one write that completes the leave", promise 13's pre-leave-copies reading entirely | U1, U2 |
| 13 a Castle backup is protected while the library is in Castle | NOT a standalone promise — it falls out of rule 9 (no Apple road while in Castle) + rule 4; U4's promises carry nothing about pre-leave copies | U4 |
| 14 vault wrapped by P and W only; join types a secret | the vault model loses its Apple wrap and `RotationAppleCopy`; `SetUpSync`/`Enroll` require a typed secret; the "silently joined device" start state DELETED | U1, U2 |
| 15 rows sealed under the key current at write; the account keeps every sync key | the vault model: `currentRowKeyID` changes only at EnterCastle; **`earlierRowKeys: [keyID: wrapped-under-master]` REPLACES `previousCorpusKey`** and grows by one per entry; the row reader picks by the row's keyID label (14b's AAD already carries it); LeaveCastle leaves keys alone; lagging followers refuse to sync until they follow (a fact the world checks). The rotation fields and walk go WHOLE: `previousCorpusKey`, `rotationStartedSeq`, `rowsBelowRotationSeq`, `reencryptBelowRotationSeq`, the completing write, their crash arms. Sync-key CUSTODY follows the account's mode (Castle → Castle-way items; Standard → silent), never "what it can reach" | U1, U2, U4 |
| 16 leaving an account changes no keys | `StopSyncingHere`/`DeleteAccountHere`/`ThisMacOnly` KEEP as "stop syncing"; NO re-key; the pair stays as it was | U1 |
| 17 a copy is a copy: Look inside / Make this my library | **ADD** `LookInside` (opens a copy read-only with its own secrets or its own quiet road on this Mac; writes NOTHING — U2 asserts zero writes with the executor harness, U4 again in the world); `Land` becomes `MakeMine`: fresh library ID, fresh key in the device's current posture under its current pair, Previous Libraries for the outgoing one, never carries sync identity (as today); Restore from Backup IS this door | U1, U2 |
| 18 sync, not files | `SendLibrary` KEEP as "write a copy"; the receiver side is rule 17; the two-Macs-one-library start state DELETED | U1 |
| 19 other libraries' copies listed, deletable | catalog + retention + the offer's delete KEEP, narrowed to copies; **the catalog reads only the folders THIS design writes** (`Backups/<library8>/<mac8>/`, Previous Libraries, safety copies) — the legacy-name parser union and the never-prune-legacy retention arm DELETED; the gift machinery DELETED | U1 |
| 20 crash safety | plans, seals, `settle` KEEP; with fewer acts the crash harness shrinks; `settle` loses the repair-first step and the memory-wins arm | U1 |
| 21 four remembered things; detect and refuse | the device memory shrinks to {libraryID, currentFingerprint, deviceID, keyFileMirror} — **the family tree (`FamilyTree.swift`), its two-home union and its seeding DELETED**; file vs memory disagreement → `Fault.libraryDisagreesWithMemory` → REFUSE with the facts and the two doors (no act, no repair). DELETE: `rekeyOlderLibraryFile`, `olderLibraryFileProof`, `restoreKeyFileFromCopy`, `setAsideLiveKeyFile`, every "memory wins" arm and promise-1 clause built for them | U1 |
| 22 delete after replacement verifies | KEEP (a guard + mutation pin) | — |
| 23 plain device ID | `HardwareMarker` and `resolveIdentity`'s takeover/anotherLogin DELETED; the device section keyed by a random `deviceID` minted at creation and stored in the memory item | U1, U2 |
| 24 both configurations | KEEP | — |
| 25 no Apple promise | the promises never require an Apple road to work; promise 13 shrinks to rule 15's "while the account stays in Castle" clause (the lagging-device lockout) | U4 |
| 26 no migration, no handling of pre-design stores | DELETE `Migration` act, `LegacyReaders` (all), the 13p escrow/stuck-marker/old-shared-key reads and the old shared key's retirement ask and door, corner 45's notice and answer, every "today's store" starting state and fixture; the record's "unconfirmed mode" arm. No refusal string either — her word | U1 |
| 27 lost everything = lost | an honest refusal (`noKeyFileAnywhere`) naming the roads that would have worked; synced: the account road (rule 14) | U2 |
| considered-and-not-pursued | nothing from that list is built; a reviewer finding that proposes one is dispositioned by pointing at the list | all |

**One posture at a time (her 2026-10-16 ruling, `vx-305-castle-core.md` §8 item 15):** entering takes everything in,
leaving hands everything out; the library key and the sync key follow the same rule; the app never keeps a protection
the user chose to leave and never protects the user from their own choice. Every unit weighs its work against this
sentence.

**What each crossing types (rules 11–12, 7):** Use Castle — the passphrase; Use Standard — the passphrase; a follow INTO
Castle — one secret (passphrase or words); a follow OUT — nothing (quiet, with a notice); a lagging device catching up —
one secret; turning sync on — nothing new (the library's pair becomes the account's); joining an account — the account's
passphrase or words; Make this my library — the copy's own secrets at its door, then your current pair; a local-only
crossing on an unsynced library — the passphrase (the words wrap is re-made through the passphrase-opened key).

**Acts after the cut (the expected set, ~13):** CreateLibrary · EnterCastle · LeaveCastle · Follow (in: types a secret;
out: quiet) · ReplaceAllKeys · ChangePassphrase · ResetPassphrase · RegenerateWords · DeviceSettings (gate style, idle
lock, scheduled export) · TouchIDRearm · Backup/Copies (SendLibrary, PlaintextExport, the offer's delete) · LookInside ·
MakeMine · SetUpSync/Enroll · StopSyncingHere/DeleteAccountHere · ThisMacOnly/Move. Gone: Migration · ConfirmMode ·
MoveOffSharedKey · RetireSharedKey · RelinkApple · OpenCopy (→ LookInside) · Land (→ MakeMine).

**The design cold read's dispositions (`notes/plans/vx-378-design-cold-read.md`, her rulings in
`vx-305-castle-core.md` §8 item 14):** F1 (rule 15 scoped — the BLOCKER) · F2 (rule 7, one pair per account) · F3 (rule
15's earlier-keys list, REQUIRED) · F4 (rule 8, no ask while a quiet road works) · F5 reading (ii) (rule 21; the family
tree dies — S1) · F6/F7/F8/F11/F12 (wording on the rules and the page) · F9 (rule 16) · F10 DROPPED at her word · F13
(the silent item, rule 8's row) · F14 (the master wrap + words copy flagged; the crossings table) · S2/S3/S4 (rows 19,
15) · C2/C3/C4/C6 (§1, U3, the brief) · C5 (§5, VX-307). Every finding carries a disposition; nothing from the
considered-and-not-pursued list came back.

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
(rule 3); one pair of secrets per account — `SetUpSync` hands the pair up, the join adopts and reports `wordsReplaced`,
`MakeMine` keeps the current pair (rule 7); the on-device road in Standard (rule 8); the lobby's ask-and-re-make path
for a failed quiet road, asking only when no quiet road remains (rule 8); the vault without an Apple wrap, typed-secret
joins, the one-row rotation at EnterCastle with the earlier-row-keys list, and the mode-flag flip at LeaveCastle (rules
11–15); LeaveCastle's fresh Standard key carrying the history, with the Apple road, the on-device item, the Touch ID
item and the mirror replaced (rule 12); `LookInside` with its zero-writes assertion (rule 17); `MakeMine` (rule 17);
detect-and-refuse with `libraryDisagreesWithMemory` and `noKeyFileAnywhere` (rules 21, 27); the plain device ID (rule
23). **Evidence:** unit pins per rule; the executor's crash-after-every-write harness green over the new acts; both
configurations green. *(Rule numbers re-pointed at the 2026-10-16 kickoff to the 27-rule contract — this section was
written against the 26-rule draft; §3's table was already current.)*

**Additions from the orchestrator's U1 note (binding for U2 — read §8's ORCHESTRATOR NOTE after U1 in full):** the
vault's account side is replaced WHOLE here (adjudication 1); the rule-21 refusal keys on disagreement, never absence,
and a lost memory item mid-act finishes or rolls back from the on-disk plan (adjudication 5); Use Castle's press records
its gate style (adjudication 3); the memory ends at exactly four things (adjudication 7); the replay refusal is pinned
at the executor so U4 can bring the tampers back as detection (adjudication 2); rule 5's reading (b) is the fixture's
(adjudication 4). The U1 record's "Not done" list and its "What the faces will read" paragraph are U2's starting map.

### U3 — THE LIFECYCLE PROOF (one session)

FIXTURE FIRST: extract the target page's facts — stage × {what was written; the roads that open the live library; the
roads that open each copy made so far} — into one machine-readable fixture (`Tests/…/Scenario/Lifecycle/lifecycle.json`
or a Swift literal — your call, recorded) BEFORE writing the test. Then one fixed scenario walks the fourteen stages on
one device (plus a second device for stage 12's sync half), asserting at each stage against the FIXTURE — so it is
red-on-old by construction and can never bless the model's behaviour by accident. A small renderer (test-side or
`Tools/castle-lifecycle-page` — your call) renders `castle-lifecycle.html` from the SAME fixture; the committed page is
the rendered one. A fact the model cannot produce is a FIXTURE DIFF recorded with its reason, each hers to accept — never
a silent edit of the fixture. **Evidence:** the scenario green both configurations; the fixture and the rendered page
committed; the facts-diff (empty, or listed) recorded.

### U4 — THE WORLD AND THE SOAK (one session)

Rewrite the promises to the rules — expected around nine, each quoting its rule: **ONE POSTURE** — while the library is
in Castle, no quiet road reaches its current key, any earlier key, or any copy of it, on any device that has followed
(9, 11, 13); the moment it leaves, every copy opens with the current typed secrets (4, 12); rows written while the
account is in Castle are under a key no quiet road holds while it stays in Castle, and a lagging device syncs nothing
until it follows (15); your current passphrase or words open every copy you have ever made (4, 5 — the core sentence as
a promise); every copy opens by SOME road the rules name, or the refusal names what would have (27); a crash leaves old
or new, said which (20); a disagreement refuses, never writes (21); deletes only after replacement verified (22);
nothing silent changes posture, account or roads outside a deliberate act (the kept core of promise 10). There is NO
promise about pre-leave copies after a leave — that is the ruled one-posture rule, and a reviewer proposing one is
pointed at the ledger. The adversary alphabet keeps file replay/deletion as DETECTION tests (the app refuses), never repair
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
- **The words the app says — a standing acceptance item from here on (her ask, 2026-10-16; ticket VX-379):** the field
  guide (the Start Here chapter FIRST — your work is encrypted, write down your twelve words, set a passphrase, the Apple
  road is a convenience that works forever for most people — then the Castle and backups chapters), Settings ▸ Data
  Safety and the protection panes, and the tutorial's last card are rewritten against `CastleRules.md`. **Every later
  phase that builds a Castle face carries in its acceptance: "the guide and settings copy agree with the rules as
  built"** — a face that contradicts the rules, or a guide sentence the build made false, is a regression by definition
  (P-6's tutorial-as-spec, applied to the words). This headless phase ships no copy; it hands the item forward with the
  rules as the text to write from.
- **Later phases, re-planned to the rules:** VX-306 (the lobby / open road — the ask-and-re-make path's face, Touch ID
  re-arm, the refusal faces of rules 21/27; the P-U4-13 keychain-mirror road is now rule 1's redundancy, not a rescue);
  VX-307 (crossings' faces — the leave screen's "keep your Castle secrets" sentence, the follow's one ask); the warning
  schedule's faces and the tutorial's last card (phase 3 / VX-3xx — ticket at kickoff); the field guide's **Start Here
  chapter** carries encryption, the twelve words, the passphrase and "Apple is a convenience" (a Wording ticket at
  kickoff); Look inside / Make this my library faces (phase 5 / VX-309, with T-8's plaintext-export-in and the
  empty-slot landing); VX-329's rehearsal: every tester exports or signs in before the switch (rule 26).
- **The server's `key_vault` change — a SyncSpec §12 LOCKSTEP EVENT, owned by VX-307 (her word, 2026-10-16):** the
  Apple wrap and `apple_key_id` leave the vault; a MODE flag and the earlier-row-keys list arrive; the rotation fields
  and `sync_reencrypt` retire; a marker bump; the mirror deploy only on her explicit go. This phase models the vault's
  new shape in the fake only (`VaultModel`), writes no `Sync/` or `Server/` line, and names the event in its handoff.
- **Dropped from every later plan** (the rules' considered-and-not-pursued list): the anchor, the stuck leave's face,
  the newest-copy offer, the migration road and any pre-design-store refusal, Re-link as a door, the old shared key's
  retirement sheet, an identity-preserving restore.

---

## 6. Sizing & cutover

Four sessions, one unit each; the orchestrator verifies every hand-back (counts re-run both configurations, scope diff,
revert checks on pins) before the next spawn. The ~500k context line: the orchestrator plans its own cutover via the
two-document handoff form if needed. Economy rules from VX-305 stand: long foreground commands, minimal narration, the
record committed with PENDING numbers first.

---

## 7. LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- U1 — the cut: **DONE, awaiting the cold review** (Opus implementer, 2026-10-16) — §8's U1 RECORD (every piece DONE
  with its commit; the record table; two PROVISIONALs). Before U1: the protection set Debug `✔ 434 tests in 71
  suites`, `-c release` `✔ 372 in 66` (tree `63cf038f1`); 11,928 source lines, 15,460 test lines. After (tree
  `25dc1cd12`): Debug `✔ 211 tests in 54 suites`, `-c release` `✔ 189 in 50`, the full core suite green in Debug;
  7,068 source lines, 8,611 test lines.
- U2 — the additions: **IN PROGRESS** (Opus implementer, 2026-10-16) — §8's U2 RECORD carries the resume map
  (pieces A–J, each flipped in the commit that lands it). A–H DONE; next: **I** (rule 27). Counts PENDING.
- U3 — the lifecycle proof: not started.
- U4 — the world and the soak: not started.
- The ladder: not started.
- The gate: not started.

---

## 8. Records (each unit appends: what shipped / what died with its rule, counts both configurations, PROVISIONALs, commits, notes)

### THE KICKOFF SITTING — 2026-10-16 (her answers to the three kickoff calls, verbatim where quoted)

- **Cast:** the standing default stands (Fable orchestrates and cold-reviews via `fable-reviewer`, Opus implements at
  xhigh, one unit per session), with her rider on the reviewer: *"make sure that if the fable cold review stalls because
  it tripped some overactive safeguard, you keep a watch for that and run an opus review if that happens."* ⇒ the
  orchestrator watches every Fable round for a safeguard stall (a stop with no findings file, a refusal framed on the
  custody narration) and, on one, runs that round as a fresh `opus-reviewer` at max effort with the same verbatim
  prompt; the record says which model read each round.
- **Ladder cap:** *"Up to five while MAJORs are found"* — VX-305's raised cap carries into the corrector (CLAUDE.md's
  three is the floor; rounds four and five run only while a MAJOR is still being found).
- **Mode:** *"Through to the gate"* — U1→U4, the ladder, the discovery run and the gate soak run without a sitting;
  anything hers (ratifications, a fixture diff, a taste call) is ruled PROVISIONALLY and bundled for the next sitting;
  a serious design issue (§1's stop rule) still stops the phase and reports.
- **Riders:** none offered — every open Castle-area Low/Medium ticket is a face or old-road item; none fits a headless
  `Protection/`-only phase. The project's old-road bug tickets (VX-107/108/109/209/228/235 …) are re-pointed at the
  rebuild's faces at closeout, as VX-305's closeout owed.
- **Consistency check at kickoff (the predecessor's last owed duty):** U2's and §5's rule numbers were still the
  26-rule draft's; re-pointed to the 27-rule contract (`43e5ff0e4`). §3's table, the crossings table and U4 were
  already current. The in-flight row on `main` gained this plan (`aecb509d0`).

### U1 RECORD — THE CUT (Opus implementer, 2026-10-16; DONE — awaiting the cold review)

**Not done in U1, first (each stated with its reason; the orchestrator may redirect):**
- **The vault's account side stays as built — the rotation, its walk, the completing write, `previousCorpusKey` and
  `rotationStartedSeq`, the Apple wrap in the vault (rule 15's row, Unit U1·U2·U4; rule 12's mode-flag flip, U1·U2).**
  Traced: deleting the walk, the completing write and `previousCorpusKey` without rule 15's `earlierRowKeys` list and
  the row's MODE flag (both U2 additions) leaves a rotation whose earlier rows nothing can read and every vault reading
  Castle (the Apple wrap is the only mode signal today); promise 6's waiting qualifier and the follower's hold ride the
  same multi-write rotation. U1 cut only the leave's id-with-no-wrap mark (piece E): the leave's first write now uses
  the existing `.keptUnder` arm under the account's fresh key, so the vault reads Standard from that write and nothing
  waits on a named key. U2 replaces the whole account side at once.
- **The replay tampers come back in U4, not U1.** `replayKeyFile` and `deleteKeyFileAndMemory` left the world with the
  repairs they exercised; `replayLibraryFile` stays only for the rule-21 pin and out of the generator's pool
  (`Tamper.generated`); promise 1 lost its key-file clause and promise 10 keeps its claims for the tampers that remain.
  Reason: with "memory wins" and the restores gone and U2's refusal not yet built, a replayed file opens as itself and
  the old promises would read that as a violation — the honest answer (refuse, rule 21) is U2's and its world check
  U4's.
- **What this Mac remembers keeps two hints beside rule 21's four things until U2 homes them**: the biometry state hash
  (§3.10's which-line hint after a failed press) and the vault facts (the follow's reading — U2 replaces the vault).
  `refreshMemory` stays, narrowed to the four things; its fingerprint arm (the memory follows the record) is the one
  U2's refusal replaces (rule 21).
- **Promise 3 reduced, not rewritten (U4's):** its "this Mac's own key" clause left with the takeover (rule 23 — a Mac
  with a new device ID owns no key it didn't mint), and a lost Apple road is the detected `appleRoadLost` fault until
  rule 8's quiet re-make lands (U2). Found when the cut shifted the generator's random stream (`createLibrary` →
  `replaceMac` → `settle`); the gap dates from piece D's Re-link removal.
- **Promise 6's vault-reach qualifier stays** (the plan's U1 list names it): the executor still makes a synced act past
  its commit point WAIT, named, for an unreachable vault — the multi-write rotation it waits on is U2's to replace
  (the first bullet), and the promise must keep reading that state until then.
- **Words at birth is U2's addition** (rule 2's row, U1 · U2): U1 deleted the secretless arms (piece K); `createLibrary`
  still takes its words from the caller (every caller in the tree passes them).
- **What the faces will read changed shape** (for U2 and the face phases): `OpensWith` is rule 4's sentence
  (`currentSecrets`, `quietRoads`); `LobbyRoads` names `silentItems`, `appleKeyID`, `typed: Set<TypedRoad>`;
  `UnlockedLibrary` lost `resolution`/`familyTree`; `ExecutorConfiguration` lost `machine`; `leaveAccount(_:_:)` takes no
  secrets; `KeyFileStoreLeaf` lost `readKeyFile(catalogID:)` (U2's Look inside adds back the read it needs).
- `ExecutorRefusal.repairForbidden` was already unused before U1 — left as found (not this cut's).

**Pieces (the resume map — a fresh session can finish U1 from this list and `git log`):**
- A — the record skeleton and LIVE STATUS: DONE (`8ed8be1be`).
- B — the world and the generator cut to the new-system shapes (tests only): DONE (`15f46c8b0`) —
  protection set Debug `✔ 311 tests in 66 suites` (generator 16 sequences, 349 steps).
- C — rule 26: the migration, the legacy readers, corner 45, the unconfirmed mode, today's items and key files: DONE
  (`c4ebc68d3`) —
  protection set Debug `✔ 263 tests in 57 suites`.
- D — rules 26 · 19 · 8: the old shared key, the gift machinery, Re-link: DONE (`ab9cbade8`) — protection set Debug
  `✔ 243 tests in 54 suites`.
- E — rules 4 · 6 · 12 · 13 (+ 15's custody): the anchor and the stuck leave: DONE (`92b7dceeb`) — pins
  `CutPinsTests` (3) red on the pre-cut tree (`leavingCastleCarriesTheHistory` at `:30`, `aFollowOutOfCastleCarries
  TheHistory` at `:49`, `aCrashedLeaveNeverLeavesTheVaultWaitingForANamedKey` at `:69` — "3 tests in 1 suite failed …
  with 3 issues"), green after; protection set Debug `✔ 222 tests in 53 suites` (generator 16 sequences, 349 steps).
- F — rules 20 · 21 (+ 1's mirror row, 19's catalog row): the repair layer: DONE (`3b354bcc3`) — pins
  `CutPinsRule21Tests` (6)
  red on the pre-F tree (a scratch worktree at `92b7dceeb`: issues at `CutPinsTests.swift:85`, `:99`, `:112`, `:130`,
  `:141`, `:153` — "6 tests in 1 suite failed … with 6 issues"), green after; protection set Debug `✔ 228 tests in 54
  suites` (generator 16 sequences, 349 steps). (The `:153` pin was superseded at G — its memory field is gone.)
- G — rules 21 · 23: the family tree, the hardware marker, identity resolution, the memory shrink: DONE
  (`484017f3e`) — pins
  `CutPinsRule23Tests` (2) red on the pre-G tree (issues at `CutPinsTests.swift:168`, `:169`, `:171`, `:177` ×4,
  `:189` — "2 tests in 1 suite failed … with 8 issues"), green after; protection set Debug `✔ 211 tests in 51 suites`
  (generator 16 sequences, 349 steps). PROVISIONAL P-VX378-U1-1 logged.
- H — rule 16: leaving an account changes no keys: DONE (`f3d0b23ea`) — pins `CutPinsRule16Tests` (2) red on the
  pre-H tree
  (issues at `CutPinsTests.swift:197`, `:199` ×6 each, `:215` — "2 tests in 1 suite failed … with 13 issues"), green
  after (the call site drops `typed:` with the API); protection set Debug `✔ 208 tests in 52 suites` (generator 16
  sequences, 363 steps). PROVISIONAL P-VX378-U1-2 logged.
- I — rule 17: OpenCopy and the open rule deleted; Land a stub for U2's MakeMine: DONE (`f8dd3ff7d`; landed second,
  after B — it
  removes the legacy reader's and the family tree's biggest consumers before C and G) — protection set Debug `✔ 291
  tests in 63 suites`.
- J — rule 4: the route finder to its one sentence: DONE (`cc66f32b9`) — pin `CutPinsRule4QuietRoadTests.aCastleCopyAfterALeave
  NamesNoQuietRoad` red on the pre-J tree (a scratch worktree at `f3d0b23ea`: issue at `CutPinsTests.swift:244` — "1
  test in 1 suite failed … with 1 issue"), green after; protection set Debug `✔ 210 tests in 53 suites` (generator 16
  sequences, 363 steps).
- K — rule 2's secretless arms, the promises' reductions, the counts and this record closed: DONE (`25dc1cd12` and
  this record's close) — pin `CutPinsRule2Tests` red on the pre-K tree, green after; the closing runs below.

**THE RECORD TABLE** (one row per deleted thing: what · rule · the tests that went with it) — filled per piece.

| What died | Rule | Tests that went with it |
|---|---|---|
| **K.** The secretless arms (rule 2): a key file with no words lock letting a door adopt the typed words unverified (`doorSecrets`' and `localSecrets`' `words == nil` arms); the world's promise-5 exception for a copy made with no passphrase or words (`secretless`). Rule 3's "no passphrase yet, set it at the door" stays. Also gone as collateral: `ExecutorRefusal.wrongLibrary` (its two throws left with I — rule 17) and the world's write-only truth (`castleBorn`/`noteBirths`, `standardSynced`, `lostAppleKeys`, `restoredPastCrossing` — their readers left with E, F, G and K) | 2 · 17 | the pin `CutPinsRule2Tests.wordsTheKeyFileCannotVerifyAreNeverTakenAsTheLibrarysWords` (red on the pre-K tree — issues at `CutPinsTests.swift:262`, `:265`, "1 test in 1 suite failed … with 2 issues" — green after) |
| **J.** The route finder beyond rule 4's one sentence: the road graph and its fixpoint (`Node`, `Edge`, `Source`, `solve`), `Opener` and `SecretDay` (the secrets' days and their line), `Route`/`RouteStep` (the witness roads), `OpensWith.routes`/`line`/`intersection`, `RouteFacts`' vault, master and not-readable inputs, a quiet road reaching through the history; `LobbyRoads.automatic` and its `typed` routes. Now `OpensWith` is the sentence itself — `currentSecrets` (the live file's current key or history holds it) and `quietRoads` (a custody item or a readable Apple wrap holding that key directly); `LobbyRoads` names the silent items, the readable Apple wrap and the typed locks; Use Castle's "copies under a key this Mac can't delete" reads the catalog directly | 4 | the pin `CutPinsRule4QuietRoadTests.aCastleCopyAfterALeaveNamesNoQuietRoad` (red on the pre-J tree, green after); the world's promise 9 (`honestWords`, its `SecretBook`, `walk`, `expectEveryRoadOpens` and the steps' `words:` switch); `RouteFinderRoadTests` → `RouteFinderSentenceTests` (3: the Castle copy after a leave, the passphrase changed after it, a key the live file doesn't hold); the lobby tests read the new shape |
| **H.** The leave's re-key, in both modes (`leaveAccount`'s `rekeys`, its typed secrets, the Standard forgot road on a leave — `localSecrets`' `passphraseMayBeNew`, `SecretRequirement.passphraseOrSetNewAndWordsOrMadeNew`, the leave doors' `rekeys`, Move's `|| old != nil` re-key, `requireAppleWriteAllowed`'s leave branch, the guard `rekeyAtEveryCrossing`); This Mac Only's mode crossing (`leaveAccount`'s `mode:`/`gate:`). A leave now writes only the unbound record, the forgotten sync keys and a fresh pair; Move re-keys only where its join crosses modes | 16 | the pins `CutPinsRule16Tests.everyLeaveKeepsTheLibrarysKeyAndItsSecrets` and `movingToAnAccountInTheSameModeKeepsTheKey` (red on the pre-H tree, green after); the `rekeyAtEveryCrossing` assess and executor pins; `aStandardLeaveWithAForgottenPassphraseSetNewMintsNothing`, `thisMacOnlyCastleFromAnAccountInStandardLeavesTheAccountsKeyUntouched`, the fixed scenario `thisMacOnlyCastleFromAStandardAccount`; rewritten: `everyLeaveReKeysInBothModes` → `noLeaveReKeysOrAsksASecretInEitherMode`, `aCastleLeaveReKeys…` → `aCastleLeaveUnbindsAndForgetsTheAccountsKeysAndChangesNothingElse`, `moveLeavesOneAccountAndJoinsTheSignedInOne` (the key kept), `ExactWritesTests.aLeaveInCastle`, the two leave crash harnesses, `aLibraryLeavingItsAccountByEachAct` (the key kept); the world's `thisMacOnly`/`stopSyncingHere` lose their mode and forgot-passphrase arms |
| **G.** The family tree (`Model/FamilyTree.swift` whole; `ProtectionRecord.familyTree`, `recordingRekey`'s `by:`, `minting`'s `madeBy:`; the memory's mirror; `UnlockedLibrary`/`UnlockedFacts.familyTree`; the swap's and unlock's unions; the guard `familyTreeTwoHomes`). "The keys the library has had" now reads the live key file (current + history — rule 4) in Castle's silent-item sweep, `retireOldCustody` and the roll back; the follow's finish-from-the-record reads a new `ActInFlight.fromKind` (the library's mode at the act's begin — the tree's one act-time reading, carried) | 21 · 4 | `FamilyTreeTests` (4: `everyMintedKeyIsRecordedWithItsKindAndItsMac`, `theTwoHomesUnion_aRolledBackLibraryStillKnowsItsLaterKeys`, `itCanBeSeededWithUnreachedFingerprints`, `mergingTakesTheSafeSide`); the `familyTreeTwoHomes` model pin; `inCastleNoSilentItemForAnyKeyTheLibraryHasHad`'s seeded-tree half (an unlisted key is now neither deleted nor reported); the world's tree-based births and tampered-Standard set; promise 2/8's `laterStandard` re-read from the key file |
| The hardware marker and the machine (`Model/HardwareMarker.swift` whole — `HardwareMarker`, `MachineIdentity`; `ProtectionRecord.markerSalt`/`marker(for:)`, `DeviceSection.hardwareMarker`, `ExecutorConfiguration.machine`; the guard `hardwareMarker`) | 23 | `HardwareMarkerTests` (2); the `hardwareMarker` model pin; the scans' hardware/login/salt needles (`noSecretAppearsInAnyValueWrittenToDisk`, `theExecutorsLogCarriesNoSecret`); `PF.macA`/`macB`/`macASecondLogin`, `HardwareMarker.stub`; the world's `SDevice.machine` and `cloneMac` (one library on two Macs — rule 18's subject, its scenario gone at B) |
| Identity resolution and the takeover (`IdentityResolution`, `DeviceFacts.resolveIdentity`, `takingOver`, the old `thisMacsSection`, `UnlockedLibrary.resolution`, `UnlockedFacts.identity`, `DeviceSettings.newIdentity`, `AppleKeyOrigin.adopted`, unlock's own-file read for a takeover) → one `thisMacsSection(memory:recordSections:mintDeviceID:)`: the remembered device ID's section, else a fresh section (PROVISIONAL P-VX378-U1-1) | 23 | the pin `CutPinsRule23Tests.aMemoryItemCarriedToNewHardwareKeepsItsDeviceID` (red on the pre-G tree, green after); `DeviceFactsTests`' `aMacWithNoMemoryItemFindsItsSectionByItsMarker`, `aSecondMacOSLoginStartsItsOwnIdentity`, `newHardwareWithNoMemoryItemTakesOverWhatNeedsNoPredecessor`, `newHardwareUnderThisLoginNamesItsPredecessor`, `aMemoryItemOnNewHardwareMintsANewIdentityThatTakesOver`, `theMemoryContinuesWhereItWasMade` → `theRememberedDeviceIDNamesThisMacsSection`; `AssessTests.aNewDeviceIdentityStartsOnAlwaysAsk`; rewritten: `aMemoryItemThatFailsItsSealLosesToTheRecordsDeviceSection` → `aMemoryItemThatFailsItsSealRemembersNothing`, `theMemoryItemDeletedAloneAndTheLidClosed` (a new ID, no choice yet); promise 3's "this Mac's own" clause |
| The two homes and the memory's shrink to rule 21's four things: `DeviceFacts.reconcile`, the memory's `deviceSection` (and `scope`, `keyEpoch`, `lastConfirmed`/`ConfirmedFacts`, `nudgeDismissals`, `itemAccount`), `Repair.refreshRecordSection`, `UnlockedFacts.recordSection`, settle's "the memory follows the newer home" arm, the guard `twoHomes`; the memory now holds `libraryID`, `currentFingerprint`, `deviceID`, `keyFileMirror` (+ the two hints, "Not done" above); `refreshMemory` narrowed to them | 21 | the pin `CutPinsRule23Tests.noStoredValueCarriesAMarkerATreeOrASecondHome` (red on the pre-G tree, green after); `DeviceFactsTests.theNewerWinsAndTheRetiredIdsAreTheUnion`, `aReplayOfEitherHomeAloneChangesNothing`; the `twoHomes` model pin; `ProtectionGuardTests.swift` whole (its three model guards gone); F's `aReplayedRecordDoesNotTakeTheMemorysFacts` (superseded: the memory no longer holds the facts it would take); rewritten: `theTwoHomesAreRefreshedWhenEitherIsBehind` → `whatThisMacRemembersIsRefreshedWhenItIsMissingOrNamesAnotherDevice`, `aLibraryFileSwappedForAnOlderOneLosesToTheNewerMemoryWithTheRoadsKeys` → `…StillReadsTheNewerMemoryWithTheRoadsKeys`, the settings door's "both homes carry it" assertion, the round trip, `expectSettled`; the world's `editSealedSetting` tamper → `editMemoryItem` |
| **F.** "Memory wins" — the older library file's re-key and the same-key twin (`Repair.rekeyOlderLibraryFile`, `.restoreRecordFactsFromMemory`, `AssessRules.olderLibraryFileProof`, assess's two FIRST arms, the executor's `rekeyOlderLibraryFile`, settle's repair-first arm, `ProtectionDiagnostic.olderLibraryFileRekeyed`, `UnlockedLibrary.keysInHand`, the guard `libraryFileLosesToMemory`) | 21 · 20 | the pins `CutPinsRule21Tests.aLibraryFileReplayedAloneIsNotReKeyedToTheMemorysKey` and `aReplayedRecordDoesNotTakeTheMemorysFacts` (red on the pre-F tree, green after); the world's `replayKeyFile` tamper; `replayLibraryFile` out of the generator's pool and out of `replaysAndTheFileSwap` |
| The restores over a stray and from a copy: `Repair.restoreKeyFileFromCopy` (assess's arm, the executor's case), `restoreKeyFileFromMirror` over a PRESENT file (another key's, or one that lost a lock — `mirrorHoldsMore`), settle's restore of the current key's file from a plan no identity here resumes (`outgoingKeyFile(_:for:)`), `setAsideLiveKeyFile` (the executor's and the leaf's), `KeyFileStoreLeaf.readKeyFile(catalogID:)` (its one reader; U2's Look inside adds back what it needs). The mirror's restore stays — ONLY into an empty live place (rule 1) | 21 · 1 · 27 | the pins `aLiveKeyFileThatLostALockIsNotRewrittenFromTheMirror`, `anotherKeysFileInTheLivePlaceIsNotOverwrittenByARepair`, `theMirrorsRestoreNeverWritesOverAFileInTheLivePlace`, `noRepairRestoresTheLiveKeyFileFromACopy` (red on the pre-F tree, green after); rewritten: `theKeyFileAndItsMirrorAgreeNeverByShrinking` → `theMirrorIsWrittenBackOnlyIntoAnEmptyLivePlace`, `theKeyFileComesBackFromTheSealedMirrorButNeverItsAppleWrap` (now from an absent file); the world's `deleteKeyFileAndMemory` tamper and promise 1's key-file clause (keyed on a restore being owed) |
| The set-aside shape: `ProtectionNames.setAsideKeyFilename`, `CatalogNames.FileName.setAsideKeyFile` and its parser, `KeyFileRole.setAside` — no writer of this design makes it (today's `StoreIdentity.setAside` is rule 26's) | 19 · 21 | `CatalogNameTests`' set-aside half (now: the shape is not read); `everyKeyFileHasItsRole` (6 files) and `foreignNamesAreListedNeverCatalogued` (the set-aside file is foreign) |
| **E.** The Castle anchor (`Model/CastleAnchor.swift` whole — `CastleAnchor`, `AnchorLocks`, `AnchorLockInputs`, `TypedLock`, `AnchorContents`; `KeyFile.anchor`/`keptAnchors`/`writingAnchor`; `KeyFileError.anchorNotWrittenFirst`/`anchorIsNotThisKeysAnchor`/`anchorDoesNotOpen`/`anchorBundleUnreadable`); the leave's anchor-first step (`writeAnchor`; the `"anchor"` step of Use Standard, the account family's leave-by-joining and the follow into Standard; the resume's "written again first"); the follower's anchor (`typedLock`, `ActParameters.includeMasterRoad`); the entry's fold (`anchorOpeners`, `RekeyOutcome.unopenedAnchors`, `ActNotice`/`ProtectionDiagnostic.anchorKeptUnopened`); the guards `anchorCarriedByEveryRekey`, `anchorWrittenFirst`, `followerAnchorTypedLock`. The key file's master wrap and its twelve-words copy are KEPT (rule 1's load-bearing note) | 4 · 12 · 13 | `KeyFileTests`: `anUnopenableAnchorIsKeptAndDoesNotFailTheEntry`, `withinAModeTheHistoryGrowsAndTheAnchorRides` (its history half is `theHistorySurvivesThreeReKeys`), the whole "anchor keeps the secrets of its day" suite (`noDoorReLocksItAndEveryReKeyCarriesItUnchanged`, `aFollowersAnchorOpensWithTheTypedSecretAndWithWhatOpenedThatDevice`, `withTheMasterUnchangedSinceCastleTheMastersRoadIsLeftOut`, `aWordsOnlyFollowersAnchorSaysTheWords`, `aTamperedAnchorOpensNothing`; `noValueEverHoldsAMasterUnderThePassphrase` kept, rebased into the crossing suite); the `anchorCarriedByEveryRekey`/`anchorWrittenFirst` model pins; `aFollowersAnchorMissesTheSecretTypedAtItsFollowWithTheGuardOff`. Rewritten onto the history: `leavingCastleTakesNothing_…` → `leavingCastleCarriesEveryCastleKey`, `castleToStandardToCastleFoldsTheAnchorBack` → `castleToStandardToCastleKeepsEveryKey`, `aFormat3FileRoundTrips`, the follow's `…AndItsHistoryOpensWithTheSecretTypedAtItsFollow`, the join's leaving-Castle assertion, `ProtectionScanTests`, `leavingCastleLocalAndSynced` and `castleStandardCastle` (each now asserts the carried history) |
| The leave's empty history: `KeyFileCrossing` (`.withinMode`/`.enteringCastle(openers:)`/`.leavingCastle`) and `RekeyOutcome` → ONE `rekeyed(from:to:kind:locks:at:)` carrying the outgoing key and its whole history at every key change (a Castle key still refuses an Apple lock); `newKeyFile(rekeyTo:)` | 4 · 12 | the pins `CutPinsTests.leavingCastleCarriesTheHistory` and `aFollowOutOfCastleCarriesTheHistory` (red on the pre-cut tree, green after); `UseStandardStates.finished` and the exact writes now expect the history (no `keyfile K0` anchor write) |
| The anchor sentences: `SecretReplacingDoor`, `AnchorSentence`, `RouteFinder.liveAnchor`/`opensAnchor`/`anchorSentence`, `Words.anchor`, `saySentence` and the executor's `anchorSentence` — every door's sentence (Replace All Keys, the three key doors, the leaves, the join's new words, Use Castle's can't-fold) | 6 | `AnchorSentenceTests` (3); rewritten: `changePassphraseReWrapsTheCurrentKeyAndTheAnchorKeepsItsDay` → `…AndTheNewOneOpensTheHistory`, `theResetRoadNeverPointsAtTheForgottenPassphrase` → `theResetRoadReLocksTheCurrentKey`, `theKeyDoorsSayTheirAnchorSentenceWhileAnAnchorExists` → `theKeyDoorsAfterALeaveSayNoAnchorSentence`, `afterALeaveTheKeyDoors` (the Done is empty) |
| The stuck leave: `RotationAppleCopy.leaveNaming` (the id-with-no-wrap mark), `VaultMode.leavingCastle` (the vault reads two states; `settled` non-optional), `VaultReading.rotationInProgress`'s leave arm, `VaultModel.completing`'s named key, `completeRotation`'s named-key and own-mint-lost arms, `ActParameters.mintsFreshAccountKey`, `follow(mintingIfTheNamedKeyNeverArrives:)`, `UnfinishedLeave`, `VaultVerdict.mayCompleteLeave`/`.unfinishedLeave`, `Door.finishLeavingCastle`, `ExecutorRefusal.waitingForNamedAppleKey`, `helpRotation`'s leave arm, assess's leave-in-progress follow, the guard `leaveIDGatesCompletion`. The leave's first write now takes the existing `.keptUnder` arm under the account's fresh key (the boundary call in "Not done" above) | 12 | the pin `CutPinsTests.aCrashedLeaveNeverLeavesTheVaultWaitingForANamedKey` (red on the pre-cut tree, green after); `aDeviceThatReadsTheNamedKeyMayCompleteTheLeave`, `aFinishDoorNamesTheLeaveALostDeviceStarted`, `finishingALeaveALostDeviceStartedMintsAFreshAccountKeyOnlyAtThePressThatStopsWaiting`, the `leaveIDGatesCompletion` assess pin, `aFollowerClearsAPreviousKeyWhileTheLeavesIDStandsWithTheGuardOff`; rewritten: `aWrapReadsStandardAnIdWithNoWrapALeaveNeitherCastle` → `aWrapReadsStandardNoWrapReadsCastle`, `aFollowerThatSeesALeaveInProgressHoldsItsReKey` → `…ALeavesRotationHoldsItsReKey`, `aFollowerMeetingALeaveInProgressHoldsItsReKeyWithItsKeysTheCastleWay` → `aFollowerMeetingALeavesRotationCompletesItAndFollowsOut`, `syncedUseStandardMarksTheLeaveThenCompletesIt` → `…WritesTheAppleWrapAtItsFirstWrite`, `pastTheVaultsFirstWrite…FinishesTheLeaveAsAnyFollower` → `…FollowsOutAsAnyFollower`, `thisDevicesOwnActInFlightIsNotAFollow`; the fakes' `apple-id-no-wrap` describer |
| Sync-key custody "by what they reach" (`reachesCastleEra`, the Castle-kind custody through a leave's window, the guard `castleKindCustodyThroughLeave`) — custody now follows the account's mode | 15 (its row: "never 'what it can reach'") · 12 | the `castleKindCustodyThroughLeave` assess pin, `theSyncKeysGoSilentInALeavesWindowWithTheGuardOff`; `syncKeysAreHeldByWhatTheyReach` → `syncKeysAreHeldByTheAccountsMode` |
| The route finder's anchor roads: `AnchorRef`, `AnchorLockRoad`, `RouteStep.anchorLock`/`.anchorOutgoingKey`/`.copiedLock`/`.anchorHolds`, `Node.anchor`, `SecretDay.of` (the anchor's days) | 4 | `aFollowersAnchorWithTheWordsTypedAndAStaleCopiedPassphrase`, `aFollowersAnchorWithThePassphraseTyped`, `aWordsOnlyFollowersCopiesSayTheWordsNotThePassphrase`, `aNestedAnchorsKeysNeedTheirOwnDaysSecrets`; rewritten on the history: `afterALeaveCastleCopiesOpenWithTheDaysSecretsAndNothingAppleReachable` → `…OpenWithTheCurrentSecrets`, `aPassphraseChangedAfterTheLeaveIsNamedByTheLeavesDay` → `…StillOpensTheCastleCopies` (piece J reduces the finder) |
| The world's promise 13 and the vault invariant: `castleStaysCastles`, `vaultInvariant` (a Castle-era corpus key under an Apple wrap — now the ruled one-posture leave), truth `leftCastleAt`, `keptByLeave`, `sentStandardPairReach`, `castleCorpusKeyIDs`, `noteVaults`, `reachableInItsDay`; the reach engine's and the lobby walk's anchors; promise 9's `.of(day)` books | 13 · 12 · 15 | — (machinery) |
| **D.** The old shared key, all of it: `KeyFile.sharedApple` + `open(sharedApple:)`/`droppingSharedApple`, `KeyFileRoad.sharedApple`, `OldSharedKeyRecord`/`DeviceSection.oldSharedKey`/`oldSharedKeyStillStanding` (and its merge and takeover arms), `ProtectionNames.oldSharedAppleKeyAccount` + `AppleKeyName` (the parser now returns the id), `AppleKeyFacts.oldSharedID`, the leaf's `readOldSharedAppleKey`/`deleteOldSharedAppleKey`, `Repair.deleteRetiredOldSharedKey`, the retirement (`retireOldSharedKey` step, its door and its one calm ask, `RetirementChecks`, the route finder's `RetirementRoutes` and `.oldSharedAppleKey` opener), the move (`MoveOffSharedKeyProgram`), Use Castle's door-time vault check, `ExecutorRefusal`/`DoorRefusal.vaultOnOldSharedKey`, `ProtectionDiagnostic`/`ActNotice.oldSharedKeyStayed`, the guards `doorTimeVaultCheck`, `oldSharedKeyDeletedByRecordedID`, `moveKeepsOldWrap`, `retirementRerunsMoves`, `freshPairAfterMove`; `ProtectionAct.moveOffSharedKey`/`.retireSharedKey` | 26 | `SharedKeyActTests` (6: Re-link ×2, the move, the retirement by its recorded id, a newer old-name item left alone, the last-step race); `AssessOldSharedKeyTests`' `aVaultOnTheOldKeyStopsUseCastleUnlessItIsTheActsOwn`, `aLibraryAlreadyInCastleGetsOneAskAndADoor`, `theOldSharedKeyIsDeletedOnSightOnlyUnderTheIdThisSectionRetired`, `replaceAllKeysOnAnAccountStillOnTheOldSharedKeyReLinksFirst`; `ExecutorGuardMutationTests.aNewerOldNameItemIsDeletedWithTheGuardOff`, `theLastStepRaceDeletesTheOldKeyAVaultStillNamesWithTheGuardOff`, `useCastlesDoorOpensOnAVaultStillOnTheOldKeyWithTheGuardOff`; the `doorTimeVaultCheck` pin; `KeyFileTests.aReKeyDropsTheOldSharedWrap`; `FollowTests.onAnAccountStillOnTheOldSharedKeyItReLinksFirst`; `TakingOverStandingOldSharedTests` (3); the move half of `decision35_AnActWritesNothingAppleReachableOffline`; the world's old-shared machinery and promise exceptions |
| The gift machinery: this Mac's own key file for another library (`KeyFileRole.ownKeyFile`, the leaf's `readOwnKeyFile`/`writeOwnKeyFile`), `MovePlan`/`Assessment.movePlan`, the offer's `lastCopyKeys` step (the offer's delete keeps to copies), `ActParameters.keyFileIDs`, the guard `giftsOnlyForThisMacsCopies` | 19 | `AssessOldSharedKeyTests.theMovesGiftsAreOnlyForThisMacsCopies`; the `giftsOnlyForThisMacsCopies` pin; `theLibraryWrapNeverLandsUnderTheAccountsKey`'s move expectation; the offer test narrowed to copies (`theOfferDeletesOnlyThisMacsCopiesOfAnotherLibrary`); the catalog's own-key-file role |
| Re-link, both arms (`RelinkAppleProgram`, `relinkAccount`, `relinkLibraryArm`, `relinkSubjects`, `OwedAct.relinkLibraryArm`, `Door.relinkAccount`/`.relinkLibraryArm`, `Words.relinkConsent`, Replace All Keys' re-link first — `relinksFirst`, `accountWriteBegun`, `DoorSpec.relinksAccountFirst`; `ProtectionAct.relinkApple`); `Fault.appleRoadLost` stays as detection only (rule 8's re-make is U2's) | 8 · 26 | the Re-link expectations in `inStandardTheWrapLandsUnderThisMacsOwnKeyAndNoRepairMintsOne` and `standardWithAnotherKeysCastleFileLive`; `onlyTheLiveFilesOwnKeyIsRetiredAtCastleWithTheGuardOff` re-staged without Re-link (a second own key in the section) |
| **C.** The migration (`Executor/Acts/Migration.swift` whole — `MigrationInputs`, `MigrationProgram`, the fold, `addPerKeyCustodyItems`; `ProtectionAct.migration`; `OwedAct.migrate`; `DoorRefusal.migrationOwed`, `ExecutorRefusal.migrationOwed` → `recordMissing`) | 26 | `ProtectionMigrationTests` (4: `aStandardLibraryMigratesFoldsItsOlderKeyAndMovesBesideTheOldSharedKey`, `corner45RecordsCastleNotYetConfirmedAndRunsNoCustodyRepair`, `aCastleLibraryMigratesToATouchIDItemOfItsOwnKeyWhereTodaysGatedItemStood`, `aCrashAfterEveryWriteFinishes`); `AssessModeTests.aLibraryWithNoRecordOwesTheMigrationAndNothingElse` |
| The legacy readers (`Model/LegacyReaders.swift` whole — `KeyFileDocument`, `LegacyKeyFile`, `LegacyModeReader` and its inputs/verdict, `LegacyItems`, `LegacyRotationMarker`); a key file is now format 3 or nothing (`KeyFile.decode`, `KeyFileStoreLeaf` reads `KeyFile`) | 26 | `LegacyReadersTests.swift` whole (4 suites: the mode reader, formats 1 and 2, today's items, the old marker) |
| A library with no record: `unlock` no longer builds a section for a migration — it refuses (`recordMissing`, no face — rule 26's "no refusal string either"); `UnlockedFacts.record` is non-optional | 26 | — |
| The unconfirmed mode and corner 45 (`ProtectionRecord.modeConfirmed`, `ModeVerdict.confirmed`/`.corner45`/`.legacyReader`, `UnlockedFacts.corner45Answer`/`legacyModeInputs`, `OwedAct.confirmMode`/`.corner45Notice`, `DoorRefusal.modeNotConfirmed`, `ExecutorRefusal.modeNotConfirmed`, `ConfirmModeProgram`/`confirmMode`, `ProtectionAct.confirmMode`, `ActParameters.targetMode`, the guard `unconfirmedModeNoCustodyRepair`, Use Standard's corner-45 road) | 26 · 2 | `AssessModeTests.cornerFortyFiveRecordsCastleNotYetConfirmedAndRepairsNothing`, `answeringCornerFortyFiveStandardIsAKeyChange`, `aSyncedUnconfirmedModeWaitsForTheVault`, the `corner45` fixture; `confirmingTheModeTheKeyWasBornInIsAFlagAndAnyOtherIsAKeyChange`; the `unconfirmedModeNoCustodyRepair` mutation pin |
| Today's items and key files: `LegacyItemsLeaf`, `LegacyItemFact`, `ProtectionFacts.legacyItems`, `Repair.deleteLegacyItem`/`.deleteLegacyKeyFile`, the leaf's `legacyKeyFilesBesideLibrary`/`deleteLegacyKeyFile`, the in-file marker's read and clear, `retireOldCustody`'s sweep of today's items, escrow, sync custody and format-1/2 files | 26 | `AssessRepairTests.inCastleTodaysItemsAndKeyFilesGoOnceTheHistoryHoldsTheirKey`, `ExecutorRepairTests.aLegacyItemGoesOnlyWhileItStillHoldsTheKeyTheHistoryHolds`; the world's today-item leaves, `KName` legacy names, `KValue.legacySync`, `LibraryImage.legacyMarker` |
| The catalog's legacy-name union and the never-prune-legacy arm: `CatalogNames.fingerprintKeyFile`/`.legacyKeyFile`, `CopyKind.legacyFlatBackup`, `KeyFileRole.besideLibrary`/`.folderKeyFile`, the flat `Backups/` and far-root locations (now foreign), today's pair rules and the newest-modified locate rule, `Retention.Outcome.legacyFlat` | 19 · 26 | `CatalogNameTests`' key-file-name half and today's-parser agreement on key files; `CatalogAttributionTests` rewritten to this design's folders (`everyCopy…` 5 copies, `everyKeyFileHasItsRole` 8 files, the mismatched pair now unserved); `RetentionTests`' legacy-flat expectations |
| The old shared key's tests that rode on the legacy format: the move adding keys beside it, its retirement's route list, the route finder's old-shared road | 26 | `theMoveAddsKeysOfThisMacsOwnBesideTheOldOneAndRemovesNothing`, `theMoveDropsTheOldWrapWithTheGuardOff`, `theMoveTakesNoFreshPairWithTheGuardOff`, `theRetirementStrandsAnotherLibrarysCopyWithoutTheMovesWithTheGuardOff`, `RetirementRoutesTests.theRetirementsListIsExact`, `RouteFinderRoadTests.everyRoadCombinationIsNamedAndWalks`, `aCopyWhoseKeyCantBePinnedNamesOnlyWhatOpensEveryCandidate` |
| **I.** The open rule (`Assess/OpenRule.swift` whole — `OpenTarget`, `OpenFacts`, `OwnLineOpen`, the raise, `Landing`, the plaintext verdict) | 17 | `OpenRuleTests.swift` whole; the `ownLineByFamilyTree` and `neverLowerOnOpen` mutation pins and the landing half of the `rekeyAtEveryCrossing` pin (`AssessGuardTests`) |
| Opening a copy into this library's own line (`OpenCopyProgram`, `openCopy`, `copyOpenerInHand`/`copyRecordInHand`, `ProtectionRecord.clearingActsInFlight`, `DeviceSection.clearingActInFlight`, `ProtectionAct.openCopy`, the guard `copyActClearedOnOpen`) | 17 | `OpenCopyTests` (4), `aCopysActInFlightIsCarriedWithTheGuardOff`, `RecordModelTests.aCopysActsInFlightAreClearedWhenItIsOpened` |
| The landing under a pair's own identity, the held synced landing and Resume Sync (`land`, `LandingPair`, `landingInHand`, `resumeSyncAfterLanding`, `adoptMadeNewSecret`, `ActParameters.adoptsMadeNewSecret`, `ActNotice.madeNewSecretBecomesAccountsAtResumeSync`, `requireAppleWriteAllowed`'s landing arm) | 17 · 18 | `LandTests` (4), `ExactWritesTests.aLanding`, `ExecutorEdgeTests.aSyncedPairsPassphraseMadeNewBecomesTheAccountsAtResumeSync`, the landing step of `ExecutorLogScanTests` |
| **B (tests only).** Today's shapes as starting states and their builders — `OlderBuild.swift` whole (`today`, `todayAccount`, `todayOtherLibrary`, `TodaySpec`, the older build as an actor, `ensureOldShared`); `StartingState.all`'s 17 today-shaped states | 26 | replaced by 7 new-system states made by the app's own doors (`Scenario/StartingStates.swift`: `fresh`, `freshAccount`); `WorldSmokeTests.todaysStandardStoreMigratesThenEntersCastle` → `aLibraryMadeHereOpensThenEntersCastle` |
| The older build in the world (`Build`, `SDevice.build`, `legacySettings`, `legacyAtOpenMode`, `olderDeviceID`, the migration call in `launch`, `migrationInputs`, `.olderBuild`/`.updateToNewBuild`, `OlderAct`; truth `handedOffBeforeChange`, `olderBuildLeaveKeys`, `olderWhenRetired`, `olderExposedMasters`, `CopyTruth.byOlderBuild`, `Seeds.excludedMasters`) | 26 | — (machinery) |
| The migration's fixed scenarios (`MigrationScenarios`) | 26 | `todaysStandardWaitingAndExposedLibrariesThroughTheMigration`, `aVaultThatMovedWhileTheLibraryDidntIsAnOrdinaryFollow`, `signedOutWithKeysThenTheVaultAnswers`, `corner45sAmbiguousCase` |
| The generator-found scenarios (`FixedScenariosFound.swift`, whole) — each began from a seeded today-shaped state, and nearly every subject is cut machinery (the replacement Mac's takeover, the held landing, the waiting/stuck leave, memory wins, the old shared key, the silently joined device) | 26 (+ 23, 17, 12, 21, 14) | all 53 |
| The ladder's world pins (`LadderRound1Pins.swift`, `LadderRound2Pins.swift`, `LadderRound1NewFindsPins.swift`, whole) — the stray-file wedge's restores and memory wins; NEW-2's promise-13 checker | 21 · 13 | `aPlanlessRollBackWithNoMirrorGetsTheCurrentKeysFileBack`, `aPlantedPlanInsteadOfAReplayedOne`, `anEarlierKeysFileReplayedWithTheMemoryGone`, `theUseCastleVariant`, `aRestoredFileKeepsTheLocksOfItsDay`, `aTamperGroupReachesTheWedge`, `aLibraryFileReplayedAfterALeave`, `theCopyLessCaseIsP_R1_1sHonestRefusal`, `aLibraryFileReplayedWithItsKeyFileDeletedLosesToItsMemory`, `aSentPairsHistoryIsTheSendersOwnAfterALeave`, `aSentPairsSnapshotIsTheSendersOwnToo`, `aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory` |
| The alphabet's dead acts: `relinkAccount`, `relinkLibraryArm` (8); `retireOldSharedKey`, `moveOffSharedKey`, `answerCorner45`, `confirmMode` (26); `finishLeave` (12, the stuck leave); `restoreBackup`, `openOlderLibrary`, `land`, `resumeSync`, `LandTyping`, the world's `openCopyByRule`/`landPair`/`openerFor` (17) | 8 · 26 · 12 · 17 | the generator's alphabet is now named and weighted (`ScenarioGenerator.kinds`); `.createLibrary` always mints words (rule 2's truth — `secrets:` → `passphrase:`) |
| Promise 12 (moving adds) | 26 | (the move off the old shared key — its only subject) |
| Fixed scenarios whose subject is cut — the old shared key (26): `replaceAllKeysOnAnAccountStillOnTheOldSharedKey`, `twoLibrariesOnOneAppleAccount`, `theWindowAfterTheMove`, `anOlderBuildsRelinkAndTheLastStepRace`, `iCloudKeychainOffThenTheRetirement`, `aRollbackAcrossARetirement`, `iCloudKeychainOffOnTheMacWhoseLibraryMoves`; today's items and acts (26): `todaysSyncCustodyGoesWhenTheLibraryEntersCastle`, `a13pEscrowItem`, `anOldBuildsCrashedActMigrated`, `anOldBuildsCrashedActWhoseCommitHappened`, `anOldRotationStillStandingOnTheServer`, `anOlderBuildCompletingALeavesRotation`; the open copy and the landing (17): `vx209sWayBack`, `anActInFlightWhenABackupIsTaken`, `anActInFlightWhenABackupIsTakenForReal`, `sendLibraryAfterThisChange`, `aCastleCopyFromAnotherMacRaises`, `aSyncedPairLandedWithAPassphraseMadeNew`, `aMacReplacedMidActLeavesNothingHalfDone`; one library on two Macs (18): `oneLocalLibraryOnTwoMacs`, `oneLibraryOnTwoMacsFromBeforeThisChange`; the anchor (4 · 12): `followersAnchorsOpenWithWhatOpenedThem`, `aCastleLibraryJoiningAStandardAccount`, `aWordsOnlyFollowerLeavingCastle`; the stuck leave (12): `aFollowerReachingTheHeadFirst`, `aFollowerMeetingARotationInProgress`; leaving an account re-keying (16): `aLibraryLeavingByMoveThenTheAccountLeavesCastle`; the route finder's line (4): `aMacThatSwitchedAppleID`; Re-link (8): `aSyncedStandardLibrarysOwnAppleKeyLost`, `aStandardLibrarysOwnAppleKeyLost`, `aLivingMacClonedOntoNewHardware`; the silent join (14): `aSilentlyJoinedDeviceLosingItsKeychain`; memory wins and the two homes (21): `aLibraryFileReplayedAloneInCastle`, `bothHomesRolledBackPastASwitchToAlwaysAsk`, `theKeyFileAndTheMemoryItemBothDeleted`; the marker and the takeover (23): `twoMacOSLoginsOnOneMac`, `aReplacementMacsFirstOpen` | 26 · 17 · 18 · 4 · 12 · 16 · 8 · 14 · 21 · 23 | the 35 named |
| World mutation pins whose guard dies: `aReplayedMemoryItemChangesNothing` (twoHomes, 21), `theHardwareMarker` (23), `theRekeyAtEveryCrossing` (16), `theAnchorCarriedByEveryRekey` (4), `aTimeMachineRollbackPastARekey` (familyTreeTwoHomes, 21), `reLinksLibraryArmThenUseCastle` (8), `anOlderBuildsRelinkLandsTheVaultOnTheOldKey`, `theMoveRemovesNoRoad`, `theFreshPairAfterTheMove`, `giftsOnlyForThisMacsCopies` (26 · 19), `aFollowersAnchorOpensWithTheSecretTypedAtItsFollow` (4), `castleKindCustodyThroughALeavesWindow`, `theLeavesIDGatesItsCompletion` (12), `ownCastleEraCopyRestoredAfterALeave` (17), `aLibraryFileReplayedAloneLosesToTheMemory`, `aLibraryFileReplayedWithItsKeyFileDeletedLosesToTheMemory` (21) | as named | the 16 named; the 6 kept pins (`thePlantedPlan`, `noRepairMakesATouchIDItem`, `noRearmQuestionWithoutAnItem`, `enteringCastleWithTheScheduledExportOn`, `theCrossMacPrune`, `deleteOnSightByRecordedIDOnly`) and the 25 kept fixed scenarios now start from the new-system builders |

**Stubs left for U2, and why:**
- `LandProgram` + `ProtectionAct.land` (`Executor/Acts/Copies.swift`): the act's registry slot with no steps and no
  public entry — U2 rebuilds it as MakeMine (rule 17: a fresh identity and key in the posture this device is in now,
  under its current pair). Kept as a stub because the brief names it; nothing begins it.

**Found while cutting (kept machinery, not a U1 row — handed forward, nothing changed):**
- **Use Castle's press records no gate style.** `EnterCastleProgram` makes the Touch ID item the press chose but never
  writes `settings.gateStyle` (only a follow into Castle and the Settings door do). The today-shaped starting states
  preset it, so nothing saw it. Consequence today: a Castle Replace All Keys after Use Castle-with-Touch-ID passes
  `gate: nil` and mints its new key with no Touch ID item (`ReplaceAllKeys.swift`'s `gate:
  library.section.settings.gateStyle` → `newCustodyItem` makes none). U1's builders press Settings after Use Castle to
  stand in. Owner: U2 (rule 9's "Touch ID on this Mac is optional", chosen at the press), pinned there red-first.
- **Rule 5's quiet-road clause and Standard's Replace All Keys.** Rule 5 says a backup opens through this Mac's quiet
  roads "while the backup's key is still the live key"; rule 4 says a quiet road opens only a key it holds directly.
  A Standard re-key within its mode keeps this Mac's EXISTING own Apple key (`ReplaceAllKeys.swift`'s
  `existingOwnAppleKey`, decision 30's shape), so an older backup's own pair file stays wrapped under a key this Mac
  still reads — the one sentence (piece J), computed literally, names the Apple road for it. Nothing breaks (more roads,
  never fewer, and rule 4 holds: that wrap holds the old key directly); it is a reading for U3's lifecycle proof and
  U4's promises to settle, not a U1 change.
- **A memory item deleted or edited mid-act** strands that act under PROVISIONAL P-VX378-U1-1 (a), since the new device
  ID's section names nothing; (b) — U2's refusal — would answer it. Recorded with the PROVISIONAL, not a stop: no rule
  conflicts.

**Source line counts:** before 11,928 (`Sources/VariorumCore/Protection/`) · after **7,068** (−4,860, −41%; the plan
expected about half — the vault's account side, U2's, is the largest piece still standing). Tests
(`Tests/VariorumCoreTests/Protection/`): before 15,460 · after **8,611** (−6,849). The diff from the first U1 commit
(`8ed8be1be^..HEAD`): 87 files, +2,058 −13,602 — `Sources/VariorumCore/Protection/` 38 files (+709 −5,569),
`Tests/VariorumCoreTests/Protection/` 47 files (+1,183 −8,032), this plan, and `notes/QUESTIONS.md` (+26: the VX-378
heading with P-VX378-U1-1 and -2, as the kickoff's rule against guessing asks).

**The runs (exit lines, both configurations; tree `25dc1cd12`):**
- The protection set, Debug (`swift test --filter <every suite under Tests/VariorumCoreTests/Protection>`, exit 0):
  `✔ Test run with 211 tests in 54 suites passed after 2.290 seconds.` (generator 16 sequences, 363 steps).
- The full core suite, Debug (`swift test`, exit 0): `✔ Test run with 240 tests in 51 suites passed after 23.256
  seconds.` · `✔ Test run with 3071 tests in 384 suites passed after 199.046 seconds.` · `✔ Test run with 40 tests in 6
  suites passed after 45.994 seconds.`
- `swift build -c release` (exit 0): `Build complete! (88.29 sec)`.
- The protection set, Release (`swift test -c release --filter <the same>`, exit 0): `✔ Test run with 189 tests in 50
  suites passed after 1.468 seconds.` (the DEBUG mutation pins compile out).

**PROVISIONAL calls:**
- **P-VX378-U1-1 (piece G, rules 21 · 23) — with nothing remembered, which device section is this Mac's?** (a) BUILT:
  a NEW plain random device ID with a fresh section, adopting nothing (a remembered ID the record has no section for
  keeps that ID); (b) refuse the open (U2's detect-and-refuse); (c) adopt the record's only section (rejected — a
  guess). Logged in `notes/QUESTIONS.md` under the VX-378 heading. Pinned by `aMemoryItemThatFailsItsSealRemembers
  Nothing`, `theRememberedDeviceIDNamesThisMacsSection` and `theMemoryItemDeletedAloneAndTheLidClosed`.
- **P-VX378-U1-2 (piece H, rule 16) — does leaving an account ask for a secret?** (a) BUILT: nothing typed — the leave
  re-keys and re-locks nothing, the three doors require `.none`; (b) the passphrase typed as consent. Logged under
  the VX-378 heading. Pinned by `noLeaveReKeysOrAsksASecretInEitherMode`.

**Commits:** A `8ed8be1be` · B `15f46c8b0` · I `f8dd3ff7d` · C `c4ebc68d3` · D `ab9cbade8` · E `92b7dceeb` · F
`3b354bcc3` · G `484017f3e` · H `f3d0b23ea` · J `cc66f32b9` · K `25dc1cd12` (the cut) · this record's close (the next).

### ORCHESTRATOR NOTE after U1 (2026-10-16 — verified, adjudicated; the U2 brief's additions follow)

**Verified, never trusted:** tree clean at `a07b1a403`, in sync with origin; the scope diff `8ed8be1be^..HEAD` touches
only the two Protection folders, this plan and `notes/QUESTIONS.md` (the PROVISIONALs' home — the exception the brief
meant); line counts re-counted exact (7,068 / 8,611). Re-runs by the orchestrator on `a07b1a403`: the protection set
under a WIDER filter in Debug `✔ Test run with 347 tests in 145 suites passed` (it subsumes the implementer's 211/54) and
under `-c release` `✘ 325 tests in 141 suites … 1 issue` — the one red is `MultiTenantSyncAttackerTests`, a SYNC suite
the wider filter swept in, failing on the Argon2 production floor (its 256 KiB test parameters are relaxed only under
`#if DEBUG`): pre-existing, outside Protection, the VX-345 class one test over — **ticketed VX-380** (Parked, Low,
Test-only). The full core suite in Debug (orchestrator re-run, exit 0): `✔ 240 tests in 51 suites` · `✔ 3071 tests in 384 suites` · `✔ 40 tests in 6 suites` — matching the record's lines exactly. **Revert check:** piece E's three pins (`CutPinsTests`)
run on a scratch worktree at `92b7dceeb^` with the pin file copied in — `✘ 3 tests in 1 suite failed … with 3 issues`
(`:30`, `:49`, `:69`), green on HEAD; the worktree removed. The record table reads one row per deleted thing with its
rule and its tests, as the unit asked.

**Adjudications (the orchestrator, against the rules; PROVISIONAL where product-flavoured, bundled for her):**
1. **The vault's account side moves WHOLE into U2** — the implementer's trace is right: the rotation walk, the
   completing write, `previousCorpusKey`/`rotationStartedSeq` and the vault's Apple wrap cannot leave before rule 15's
   `earlierRowKeys` list and the MODE flag exist, or earlier rows become unreadable and every vault reads Castle. U2
   replaces them in one piece; promise 6's vault-reach qualifier and the follower's hold die in the same piece.
2. **The replay tampers return in U4 as DETECTION** (the app refuses — rule 21), after U2 builds the refusal; U2 pins
   the refusal at the executor (a replayed library file or key file in the live place → `libraryDisagreesWithMemory`,
   no write).
3. **Use Castle's press records no gate style (found while cutting, item 1):** U2's, red-first — rule 9's "Touch ID on
   this Mac is optional" is chosen at the press and must be remembered by it, so a later Castle Replace All Keys mints
   its Touch ID item.
4. **Rule 5's quiet-road clause vs Standard's Replace All Keys (item 2) — PROVISIONAL, reading (b) stands as built:**
   a Standard re-key keeps this Mac's existing own Apple key, so an older backup's key file — locked under that Apple
   key — still opens through the Apple road; rule 4's "a quiet road opens only a key it directly holds" is exactly what
   happens (the old key file holds the old key under a lock this Mac still reads). Rule 5's "while the backup's key is
   still the live key" is the common case's wording, not a narrower promise. Option (a) — Replace All Keys in Standard
   also mints a fresh Apple key and retires the old one — would make rule 5 literal, but buys nothing: the Apple road
   reaches the NEW key the moment it is wrapped, so replacing the Apple key closes no hole and only costs older backups
   a convenience. U3's fixture and U4's promises read rule 5 as *"through this Mac's quiet roads while they still hold
   the key the backup's key file is locked under"*; the one-sentence wording for CastleRules rule 5 is HERS to accept
   at the bundle — the rules are never edited here. (P-VX378-O1-1 in QUESTIONS at the merge.)
5. **P-VX378-U1-1 (which section with nothing remembered) — (a) STANDS, with the orchestrator's reading:** a keychain
   reset is a NAMED Standard event in rule 8 ("the next open … asks for your passphrase or words only when no quiet road
   remains") — so a missing memory item must NOT refuse the open; U2's detect-and-refuse (rule 21) keys on a
   DISAGREEMENT (a memory item present that names another file), never on absence. The stranded-act corner (a memory
   item lost mid-act) is rule 20's: the plan beside the library is on disk, so U2 finishes or rolls back an act in
   flight FROM THE ON-DISK PLAN regardless of which section the record names, and says which — pinned red-first; the
   section the plan names is the one the act resumes in, the fresh device ID is minted only after the act settles.
6. **P-VX378-U1-2 (does leaving an account ask a secret) — (a) stands:** rule 16 changes nothing, so the door has
   nothing to lock; consent is the face's sentence (phase 3/4's). Her eye at the bundle.
7. **The two memory hints (biometry state hash, vault facts) and `refreshMemory`'s fingerprint arm:** U2 homes or
   deletes them as its rule-21 piece lands; the memory ends U2 at exactly rule 21's four things (a pin: no stored
   value beyond them).
8. **The faces' changed shapes** (`OpensWith`, `LobbyRoads`, `UnlockedLibrary`, `ExecutorConfiguration`,
   `leaveAccount`): handed to VX-306/307's plans at closeout; nothing in `App/` reads them yet.

**Linear, for the record (the VX-305 session's message, 2026-10-16, no files changed):** VX-228 and VX-340 canceled
as superseded; re-scoping comments on VX-266/305/306/307/308/309/329; reshape notes on VX-263/301/209/213; a ticket's
newest comment outranks an older body. Applied at the closeout's triage.

### U2 RECORD — THE ADDITIONS (Opus implementer, 2026-10-16; IN PROGRESS)

**Not done in U2, first:** PENDING (filled at the close).

**Pieces (the resume map — a fresh session can finish U2 from this list and `git log`):**
- A — the record skeleton and LIVE STATUS: DONE (this commit).
- B — rule 2: words at birth: DONE (`3631ecbde`) — `IDsLeaf.mintWords()`; `createLibrary(passphrase:)` mints the
  twelve words and hands them back once (`CreatedLibrary`, words redacted from its description); `KeyFile.locking`
  refuses a new file the words would not open (`KeyFileError.noWordsLock` — its words lock, or the master with its
  twelve-words copy; `KeyFile.opensWithTheWords`). Pins `U2PinsRule2Tests` (2) red on the pre-B tree (scratch worktree
  at `0572dd3c0`: issues at `U2PinsRule2Tests.swift:26`, `:36`, `:42` — "2 tests in 1 suite failed … with 3 issues"),
  green after; `U2CreatedWordsTests` (1) is the new API's (red by construction — the old creation took its words from
  the caller). Fixtures that built a file with no words lock now carry one (`KeyFileTests` ×4, `AssessTests`, U1's
  `CutPinsTests`, the world's planted pair). Protection set Debug `✔ 214 tests in 56 suites`.
- C — rule 3: DONE (`ef6c6bf54`) — `ProtectionRecord.passphraseSet` and `.reminderDismissals`; the fact is
  stamped at every record the executor writes (`stampingPassphraseFact` in `writeFacts`, `recordIntoStaged`,
  `bindAccount`, the creation): a passphrase lock on the key file, or the account's (rule 7 — bound, the vault always
  carries one); `recordPassphraseReminderDismissed` counts a dismissal (one record write). `assess` owes
  `OwedAct.askPassphrase(.beforeFirstBackup)` while no backup of the library exists and `(.quietRoadFailed)` at the
  launch that finds the Apple road lost or Standard's on-device item gone. Pins `U2PinsRule3Tests` (4) red on the
  pre-C tree (scratch worktree at `3631ecbde`: issues at `U2PinsRule3Tests.swift:30`, `:46`, `:64`, `:70` — "4 tests
  in 1 suite failed … with 4 issues"; `aLibraryWithAPassphraseIsNeverAsked` is the guard, green both sides), green
  after; `U2PassphraseFactTests` (1) the new writer's. `AWorld` reads the fact from its live file. Protection set Debug
  `✔ 219 tests in 58 suites`.
- D — adjudication 3: DONE (`67ed68490`) — Use Castle writes the press's gate style into this Mac's section with the
  act's first write (the follow's existing shape; a rolled-back press keeps the choice, which means nothing in
  Standard). Pins `U2PinsGateTests` (2, the first over both gates) red on the pre-D tree (scratch worktree at
  `ef6c6bf54`: issues at `U2PinsGateTests.swift:23` ×2, `:25` ×2, `:36` — "2 tests in 1 suite failed … with 5
  issues"), green after. Protection set Debug `✔ 221 tests in 59 suites`.
- E — rules 7 · 11 · 12 · 14 · 15: the vault's account side replaced whole: DONE (`db1c1ac55`).
  - **The vault's new shape** (`Executor/VaultModel.swift`, modelled only — the server's `key_vault` change is VX-307's
    §12 lockstep event): `AccountVault` = the master under the passphrase (with its descriptor) and under the twelve
    words, NOTHING else (rule 14); a MODE flag (`mode`); the current sync key (`rowKey`: id + wrap under the master);
    `earlierRowKeys: [keyID: wrapped under the CURRENT master]` (rule 15); the key proof's hash; the last writer's
    name. The device holds `AccountKeys` (master, current sync key, every earlier one; `rowKey(for:)` is the row reader
    by the row's own key-id label). **Use Castle's account part is ONE CAS write** (`VaultModel.enteringCastle` —
    a new master, a new sync key, the outgoing and every earlier sync key re-sealed under the new master, the mode
    Castle; its new key id stamped in the plan before the write). **Use Standard's is the mode flag flipped**
    (`leavingCastle` — one write, no key changed). The key doors re-lock the master (`rewrappingPassphrase` /
    `rewrappingWords`). **Died with the rotation:** the vault's Apple-held copy and `apple_key_id`, the account's Apple
    key (minting, recording, retiring — and `AppleKeyRecord`'s purpose/origin with it: every recorded key is this
    Mac's own for the library), `previousCorpusKey`/`rotationStartedSeq`, the walk (`reencryptBelowRotationSeq`), the
    completing write, `RotationAppleCopy`, `VaultMode`, `VaultVerdict`'s rotation/hold/Apple-copy fields,
    `DoorRefusal`/`ExecutorRefusal`/`VaultRefusal.rotationInProgress` (+ `rotationRowsRemain`), `OwedAct.follow`'s
    hold, `ActOutcome.held`, `ActNotice.heldForRotation`, the named wait (`SettleOutcome.waiting`, `ActWaiting`, promise
    6's vault-reach qualifier — `pastCommitPoint` is now the library's swap; a resume that can't reach its vault before
    the swap ROLLS BACK, and a vault write it had made is picked up by a follow), `dropUnlandedAccountKey`, the
    follower's `helpRotation`, Replace All Keys' rotation (it re-keys the library only — rule 15; P-VX378-U2-1), and
    the memory's `VaultFacts` with the `recordHeldSyncKeysFacts` repair — **the RECORD names the sync key the library
    follows** (`ProtectionRecord.accountRowKeyID`, written by sync setup, a join, a follow, Use Castle's write; cleared
    with the account).
  - **Rule 14:** a join types ONE of the account's secrets; the follow out of Castle is quiet (`ActNotice
    .followedOutOfCastle`); into Castle and catching up on a replaced sync key type one. **Rule 7:** sync setup hands
    the library's pair up (both typed and verified, never made new); a join adopts the account's pair
    (`joinKeyFile`: the typed lock is the account's; the library's own other lock goes unless provably the
    account's; the master with its twelve-words copy — `ActNotice.wordsReplacedByAccount` unless the typed words
    were already the library's); no door but creation makes new words (Use Castle, Replace All Keys, Use Standard,
    sync setup refuse `wordsAreNew` — `wordsMustBeTyped`). The doors' requirements follow (`oneSecret` for joins).
  - Pins `U2PinsAccountTests` (8) red on the pre-E tree (scratch worktree at `67ed68490`: issues at
    `U2PinsAccountTests.swift:31`, `:42`, `:43`, `:52`, `:62`, `:72`, `:78`, `:85`, `:96`, `:126`, `:127` — "8 tests
    in 1 suite failed … with 11 issues"), green after. New-API tests (red by construction — the types didn't exist):
    `CrossingTests.syncedUseCastleWritesTheAccountOnceThenTheLibrary` (the earlier sync key kept under the new master;
    the old master opens nothing), `LeaveCastleTests.syncedUseStandardFlipsTheModeFlagAndChangesNoKey`,
    `FollowTests.aDeviceThatLaggedThroughCastleCatchesUpWithOneSecret` (rule 15's lagging device),
    `…FollowsOutQuietly…`, `AccountJoinTests` (the pair handed up; one secret adopts the account's pair),
    `ExecutorEdgeTests.theSecondLeaveFindsTheFlagFlippedAndWritesNothingMore`, `AssessVaultTests` (rewritten to the
    flag). Died with their subject: the rotation-in-progress, the named-key and the account-Apple-key tests
    (`aFollowerMeetingALeavesRotationCompletesItAndFollowsOut`, `aRotationWithNoIdCompletesWithoutAnAppleCopy`,
    `aWrapReadsStandardNoWrapReadsCastle`, `theDeviceWhoseLeaveLostTheRaceDeletesTheAccountKeyItMinted`, Use
    Castle's decision-32 refusal — replaced by the lagging-account refusal and rule 7's).
  - **Found while landing it (handed to piece G, red-first there):** a device whose keychain was wiped opens with a
    NEW device ID (P-VX378-U1-1 (a)) and so a section listing none of the Apple keys it minted under the old ID; a
    later entry into Castle then retires nothing, and a Standard-era backup still opens through the Apple road
    (promise 2 caught it when `FixedScenariosCorners`' wiped-keychain scenario was re-pointed from Replace All Keys
    to Use Castle). The scenario keeps its own subject (now `aWipedKeychainStillFollowsTheAccountBackIntoCastle`).
  - Protection set Debug `✔ 219 tests in 59 suites`.
- F — rule 21 (+ adjudications 2, 5, 7): DONE (`a01b622db`).
  - **Detect and refuse** (`Assess/LibraryDisagreement.swift`, one pure `check` read by the executor's `unlock` — which
    throws `ExecutorRefusal.libraryDisagreesWithMemory` before anything is written — and by `assess`, which reports
    `Fault.libraryDisagreesWithMemory`, owes no repair and no act, and closes every door with
    `DoorRefusal.libraryDisagreesWithMemory`). Findings: `anotherLibrary` (the memory items name other libraries and
    none this one — `MemoryStoreLeaf.rememberedLibraryIDs()`, enumerated by name), `libraryFileUnderAnotherKey`,
    `keyFileOfAnotherKey` — each unless this Mac's own act in flight moves between exactly those two keys. It keys on a
    DISAGREEMENT, never on absence (a memory absent or failing its seal opens on — rule 8's keychain reset). The two
    doors are offered as values (`CopyDoor`); what they open is piece H's. `assess`'s `refreshMemory` lost its
    fingerprint arm (the memory following the record) — the refusal replaced it. Creating a library deletes every other
    library's memory item in the scope (`deleteMemory`): this Mac remembers ONE library.
  - **The memory at exactly four things** (adjudication 7): `DeviceMemory.biometryStateHash` and the
    `BiometryLeaf.biometryStateHash()` it was fed by deleted (§3.10's which-line hint is the face's to read); the vault
    facts left in E.
  - **An act stranded by a lost memory item** (adjudication 5): with nothing remembered, `unlock` resumes the act in the
    section the plan on disk names (sealed under this library's key, the section naming it — `sectionFromThePlan`);
    `settle` then gives this Mac its fresh plain device ID (`takeFreshDeviceIDAfterTheSettle`, P-VX378-U1-1 (a)).
  - Pins `U2PinsRule21Tests` (7; `anAbsentMemoryIsNoDisagreement` the guard, green both sides) red on the pre-F tree
    (scratch worktree at `db1c1ac55`: issues at `U2PinsRule21Tests.swift:36`, `:56`, `:73`, `:95`, `:96`, `:97`,
    `:109` ×3, `:124` — "7 tests in 1 suite failed … with 10 issues"), green after. `ExecutorCoreTests
    .aMemoryItemThatFailsItsSealRemembersNothing` narrowed to nothing in flight (with an act in flight it is the pin
    above); `ExecutorEdgeTests.aLibraryFileSwappedForAnOlderOne…` moved into the pins as `aReplayedLibraryFileIsRefused`.
  - Protection set Debug `✔ 233 tests in 61 suites`.
- G — rule 8 (+ rule 11's entry, found in E): DONE (`1a02354bd`).
  - **The quiet roads re-made at an open** (Standard): `Repair.remakeAppleRoad` — the Apple road failed and no own key of
    this Mac reads here: a FRESH Apple key minted, recorded in this Mac's section first (so an entry into Castle retires
    it even if the rest never lands), added, the current key wrapped under it (decision 35's fresh vault read first
    when synced, and the vault must read Standard); `Repair.remakeOnDeviceItem` — the silent item for the current key
    re-made with the key in hand. `Fault.appleRoadLost` stays as the report (rule 3's ask reads it at that launch).
    `LobbyRoads.asksASecretAtOnce` — no silent item and no readable Apple wrap: ask at once; else try the quiet roads
    first. Nothing is re-made in Castle (rule 9; a Touch ID item only at a press — the guard stands).
  - **Rule 11 under a lost memory** (E's finding): entering Castle — Use Castle, a follow into Castle, a join into
    Castle — retires the own keys the section lists AND the Apple key the outgoing key file's wrap names
    (`retireOwnAppleKeys`, `ownKeysToRetire`; the follow now carries `outgoingAppleKeyID`), already-retired ids
    skipped.
  - Pins `U2PinsRule8Scenarios` (3) red on the pre-G tree (scratch worktree at `a01b622db`: issues at
    `U2PinsRule8Scenarios.swift:27`, `:39`, `:41`, `:54` — "3 tests in 1 suite failed … with 4 issues"), green after;
    `U2Rule8AssessTests` (4) the new repairs' and the lobby fact's (red by construction). The mutation pin
    `deleteOnSightByRecordedIDOnly` now checks Mac B's ORIGINAL Apple key (rule 8's re-make at Mac B's next open would
    otherwise heal the very delete it watches for — with the guard off it is still red).
  - Protection set Debug `✔ 240 tests in 63 suites`.
- H — rule 17 (+ 23): DONE (this commit).
  - **Look inside** (`ProtectionExecutor.lookInside(_:in:typed:)` → `LookedInside` {copy id, key held for the look,
    `CopyRoad`}): a catalogued copy opened read-only by its own secrets on its own key file (its history too), the
    current secrets through the live key file's history (rule 4), or its own quiet road on this Mac (a custody item
    holding its key directly, an Apple wrap readable here); every road verified against the copy's file
    (`LibraryFileLeaf.copyOpens`, a read). It is no act: no plan, no leaf write — asserted with the executor world's
    crash switch armed at the FIRST write (any write would crash) and the write log empty; custody, memory and the
    live key file unchanged. Nothing opens → `ExecutorRefusal.copyDoesNotOpen`.
  - **Make this my library** (`makeThisMyLibrary`, the act `ProtectionAct.makeMine` replacing U1's `land` stub): the
    copy's own secrets (or its quiet road, or the current secrets through the history) at its door, the CURRENT PAIR
    verified (the passphrase when the library has one, the words always — never made new); on a plan (rule 20): the
    new key's custody item (the posture of now — Standard silent; Castle a Touch ID item when this Mac's gate says so),
    Standard a fresh own Apple key, the new library's key file (a fresh key with no past, a fresh library ID, the
    current pair; no master — no sync identity), the copy re-encrypted under the new key into the staged file, the new
    record (the posture of now, this device's settings, a FRESH device ID — rule 23 — carrying the act), the new
    library's memory item, THE SWAP (the plan re-sealed for the new library first; the outgoing library and ITS key
    file set aside whole — `swapStaged(setAside:asideKeyFile:)`), then every other library's memory item forgotten
    (rule 21: one library) and a fresh pair. Before the swap a resume holds no copy key and rolls back; a roll back
    forgets the new library's memory item. A Castle Mac's new library is Castle ("you never leave Castle by opening
    something"). PROVISIONAL P-VX378-U2-4 (no sync identity; the device settings carried).
  - Tests (new API — the old tree's `land` was a registry stub with no entry, red by construction):
    `U2LookInsideTests` (3: her old backup by her secrets through the history with nothing written, someone else's
    library by its own secrets, a backup under the current key by this Mac's quiet road), `U2MakeMineTests` (4: a new
    Standard library under the current pair with the outgoing one aside with its key file and one memory item; a
    Castle Mac's new library is Castle; the crash harness after every write — finishes or never happened; the
    refusals write nothing).
  - **Handed forward (VX-309, beside T-5's empty-slot landing):** the two doors offered at rule 21's refusal act on the
    LIVE PLACE's stray, where no catalogued copy and — for Make this my library — no current library is in hand (the
    posture "of now" with the remembered library's file gone): the same question as the empty-slot landing; both
    doors here take a catalogued copy and Make this my library takes the unlocked current library.
  - Protection set Debug `✔ 247 tests in 65 suites`.
- I — rule 27: the honest `noKeyFileAnywhere` refusal naming the roads that would have worked: NOT STARTED.
- J — the closing runs (the full core suite in Debug; the protection set under `-c release`), the counts, this record
  closed: NOT STARTED.

**Red-on-old evidence, per piece:** PENDING.

**The runs:** PENDING.

**PROVISIONAL calls:** PENDING (logged under the VX-378 heading in `notes/QUESTIONS.md`, P-VX378-U2-n).

**Commits:** A `0572dd3c0` · B `3631ecbde` · C `ef6c6bf54` · D `67ed68490` · E `db1c1ac55` · F `a01b622db` · G `1a02354bd` · H (this commit) · the rest PENDING.

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
