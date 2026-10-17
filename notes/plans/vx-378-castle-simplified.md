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

**What each crossing types (rules 11–12, 7; HER RULING 2026-10-16 on P-VX378-U2-2 — both secrets at a crossing, local
or synced):** Use Castle — the passphrase AND the twelve words; Use Standard — the passphrase AND the twelve words (a
user without their words paper does New Words first, passphrase-only, then crosses); a follow INTO Castle — one secret
(passphrase or words; the untyped one's lock comes through the vault's master and its twelve-words copy); a follow OUT —
nothing (quiet, with a notice); a lagging device catching up — one secret; turning sync on — nothing new (the library's
pair, both verified, becomes the account's); joining an account — the account's passphrase or words; Make this my
library — the copy's own secrets at its door, then your current pair. *(The earlier "the words wrap is re-made through
the passphrase-opened key" named a mechanism that does not exist — U2's finding; the cross-wrap that would make it exist
was offered to her and declined.)*

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
- U2 — the additions: **DONE, awaiting the cold review** (Opus implementer, 2026-10-16) — §8's U2 RECORD (pieces
  A–J with their commits and red-on-old evidence; five PROVISIONALs). After (code tree `320579718`): the protection
  set Debug `✔ 254 tests in 67 suites`, `-c release` `✔ 232 in 63`, the full core suite green in Debug; 7,562
  source lines, 9,380 test lines.
- U3 — the lifecycle proof: **DONE, awaiting the cold review** (Opus implementer, 2026-10-16) — §8's U3 RECORD (the
  fixture first, the scenario's four walks, the page rendered from the fixture; three FACTS DIFF and two PROVISIONALs
  for her). After (code tree `389162a09`): the protection set Debug `✔ 259 tests in 69 suites`, `-c release` `✔ 237 in
  65`, the full core suite green in Debug; `Sources/…/Protection/` untouched (7,562), tests 12,068.
- U4 — the world and the soak: **STOPPED at P-VX378-U4-3 (2026-10-17, `0e220f524`), HER RULINGS taken (§8); RESUMED —
  IN PROGRESS** (Opus implementer, 2026-10-17) — §8's U4 RESUMPTION RECORD (pieces 1–6: the carry reverted, the floor,
  rule 21's notice and offer, the census classes, the discovery run and the gate soak; every count PENDING).
  §8's U4 RECORD (the resume map; piece E carries the trace and the census). A, B, B2 (her P-VX378-U4-1 ruling), C, D
  DONE; E STOPPED at P-VX378-U4-3 (seed 21 seq 83; the census of seeds 21–23 sized the rest: 88 failing sequences in
  3,000, classes (A)–(I)); F NOT RUN; G DONE. After (code tree `0bd112c9c`): the protection set Debug `━ 278 tests in 72
  suites passed with 2 known issues`, `-c release` `━ 255 in 68 … 2 known issues`, the full core suite green in Debug;
  7,604 source lines, 13,038 test lines.
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

### U2 RECORD — THE ADDITIONS (Opus implementer, 2026-10-16; DONE — awaiting the cold review)

**Not done in U2, first (each with its reason and owner):**
- **Rule 21's two doors on the LIVE PLACE's stray** — `lookInside` and `makeThisMyLibrary` take a catalogued copy, and
  Make this my library the unlocked current library; at the refusal the stray sits in the live place and the
  remembered library's file is gone (no "posture of now" in hand). The same question as T-5's empty-slot landing:
  VX-309 (the refusal offers the doors as values — `LibraryDisagreement.offers`).
- **The world and its promises are U4's:** promise 6 is now strict (any act left in flight breaks it — the qualifier
  died); promise 3 still tolerates a detected lost Apple road although rule 8 now re-makes it at the same open (U4 may
  tighten); the world's `resumeAtVaultReach` is now only a re-settle (no act waits — U4's to delete); the replay
  tampers come back as DETECTION in U4 (adjudication 2) — U2 pinned the executor's refusal (`U2PinsRule21Tests`).
- **The server's `key_vault` change** (the Apple wrap and its id out, the mode flag and the earlier-row-keys list in,
  the rotation fields and `sync_reencrypt` retired, the journal-bridge key's fate) — VX-307's SyncSpec §12 lockstep
  event; this phase models the row in `VaultModel` only.
- **The faces** of everything new (`askPassphrase`, `asksASecretAtOnce`, `noKeyFileAnywhere`, the rule-21 refusal and
  its doors, `wordsReplacedByAccount`, `followedOutOfCastle`, Look inside / Make this my library) and rule 3's
  launch-counted reminders — phase 3 and VX-306/307/309. Castle's Touch ID re-arm on new hardware (the lifecycle's
  stage 11) stays the face's: no repair makes a Touch ID item (the guard stands).
- `ExecutorRefusal.repairForbidden` is still unused — left as found (U1 noted it).

**What the faces will read changed shape** (for VX-306/307/309's plans; nothing in `App/` reads them yet):
`VaultReading` (the mode flag, `rowKeyID`, `kdf`, the recovery wrap), `VaultVerdict` (mode, custody), `OwedAct.follow
(kind, typesOneSecret:)`, `OwedAct.askPassphrase`, `LobbyRoads.noKeyFileAnywhere`/`asksASecretAtOnce`,
`Fault.libraryDisagreesWithMemory`/`.noKeyFileAnywhere`, `DoorRefusal.libraryDisagreesWithMemory`; the leaves —
`SyncKeysLeaf` holds `AccountKeys`, `VaultLeaf` speaks `AccountVault` (no walk), `LibraryFileLeaf.copyOpens` and
`swapStaged(setAside:asideKeyFile:)`, `MemoryStoreLeaf.rememberedLibraryIDs`/`deleteMemory`, `IDsLeaf.mintWords`,
`BiometryLeaf` lost `biometryStateHash`; `createLibrary` → `CreatedLibrary`; `ProtectionRecord` gains
`passphraseSet`/`reminderDismissals`/`accountRowKeyID`; `DeviceMemory` is the four things; `AppleKeyRecord` is
{`id`, `retiredAt`}; `ProtectionAct.land` → `.makeMine`.

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
- H — rule 17 (+ 23): DONE (`21cc0377a`).
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
- I — rule 27 (+ the crash harness over E's changed acts): DONE (`320579718`).
  - **The honest refusal** (`NoKeyFileAnywhere` {`wouldHaveWorked`: rule 1's three homes — beside the library, inside a
    backup, this Mac's keychain; `accountRoad`: rule 27's exception, rule 14's road}): before unlock,
    `LobbyRoads.noKeyFileAnywhere` when a library sits in the slot and NOTHING might open it — no key file beside it or
    in any copy, no memory item (its sealed mirror), no custody item holding a key (the account road named when a
    session is signed in); after an open by a quiet road with no live key file and no mirror to write back,
    `Fault.noKeyFileAnywhere` (the account road named when the record names an account). Nothing rebuilds a key file
    from the key (§3's rule-1 row — the copy-less rebuild door is not built).
  - Pins `U2PinsRule27Tests` (3; `anythingThatMightStillOpenItSaysNothing` the guard, green both sides) red on the
    pre-I tree (scratch worktree at `21cc0377a`: issues at `U2PinsRule27Tests.swift:29`, `:31`, `:65` — "3 tests in 1
    suite failed … with 3 issues"), green after.
  - **The crash harness over the acts E changed** (`U2CrashHarnessTests`, 4: sync setup handing the pair up, a
    same-posture join typing one secret, a synced key door, a follow into Castle under Always ask) — the join's run was
    RED at first ("crash after write 6 (plan): the settle threw .noWordsLock", the same at write 7): a resumed join
    re-ran `joinKeyFile` with no vault read this session, so the master's twelve-words copy was missing and rule 2's
    refusal fired. Fixed here (E's own gap): a synced resume reads the vault whenever it is reachable — rolling back
    only before its commit point when it isn't — and `joinKeyFile` reads it itself when this session hasn't. Green
    after.
  - Protection set Debug `✔ 254 tests in 67 suites`.
- J — the closing runs, the counts, this record closed: DONE (this commit). The scratch worktree used for every
  red-on-old run (checked out at each piece's parent, the piece's pin file copied in) is REMOVED (`git worktree
  remove`; `git worktree list` shows only `main`, the mobile worktree and this branch).

**Readings made while building (each traced to the rules; none is a rule change):**
- **Rule 12's "this Mac's Touch ID item … now hold[s] the new key"** read with §3's rule-8 row (F13: Standard's
  on-device road is the SILENT item, no biometric ACL): the Castle key's Touch ID item goes with its key and the new
  Standard key's silent item is made — the on-device road "back". (Already the built leave; no change.)
- **Rule 7's "joining … never changes the key"** read as the same-posture join: a join that crosses postures is rules
  10–12's entry or leave (one posture at a time) and re-keys, as built since VX-305.
- **What the crossings type** — rules 11/12's "types your passphrase" vs the plan's crossings-table mechanism for local
  crossings, which doesn't exist: P-VX378-U2-2 (the doors keep both typed).
- **Rule 7's "Only creating a library shows fresh words"** read as scoped to the pair-changing doors (sync setup, a join,
  Make this my library, the crossings, Replace All Keys); New Words (rule 6's re-lock) keeps making new words.
- **The account's Apple key** died with the vault's Apple lock (rule 14), so `AppleKeyRecord` keeps only this Mac's own
  keys for the library (`purpose`/`origin`/`accountID` gone).

**Red-on-old evidence, per piece:** in each piece's line above (scratch worktree `$SCRATCH/old`, checked out at each
piece's parent commit, the piece's pin file copied in; removed at the close).

**The runs (exit lines, both configurations; code tree `320579718`):**
- The protection set, Debug (`swift test --filter <every suite under Tests/VariorumCoreTests/Protection>`, exit 0):
  `✔ Test run with 254 tests in 67 suites passed after 2.051 seconds.` (generator 16 sequences, 363 steps). Before U2
  (`d992d2906`): `✔ 211 tests in 54 suites`.
- The full core suite, Debug (`swift test`, exit 0): `✔ Test run with 240 tests in 51 suites passed after 22.692
  seconds.` · `✔ Test run with 3114 tests in 397 suites passed after 196.791 seconds.` · `✔ Test run with 40 tests in
  6 suites passed after 46.137 seconds.`
- `swift build -c release` (exit 0): `Build complete! (88.50 sec)`.
- The protection set, Release (`swift test -c release --filter <the same>`, exit 0): `✔ Test run with 232 tests in 63
  suites passed after 1.347 seconds.` (the DEBUG mutation pins compile out).
- Line counts: `Sources/VariorumCore/Protection/` 7,068 → **7,562**; `Tests/VariorumCoreTests/Protection/` 8,611 →
  **9,380**. The diff `d992d2906..HEAD`: 63 files (+3,044 −1,549), only the two Protection folders, this plan and
  `notes/QUESTIONS.md`.

**PROVISIONAL calls** (logged under the VX-378 heading in `notes/QUESTIONS.md`):
- **P-VX378-U2-1** — Replace All Keys re-keys the library only; the account's sync key stays (rule 15). Piece E.
- **P-VX378-U2-2** — what the crossings type: both secrets at Use Castle and Use Standard (the plan's crossings-table
  mechanism for a local crossing — "the words wrap re-made through the passphrase-opened key" — does not exist; rules
  2, 11, 12, 14 hold). Piece E. **For the orchestrator: a plan-wording gap, not a rule conflict.**
- **P-VX378-U2-3** — "here they are": a join typing the passphrase holds no words to show; the notice says they were
  replaced, the face shows them when typed. Piece E.
- **P-VX378-U2-4** — Make this my library's new library is local, the device's settings carried. Piece H.
- **P-VX378-U2-5** — a key door's one-write window with the vault out of reach at the relaunch rolls back (the pair
  split until the next key door; nothing lost). Piece E.
- P-VX378-U1-1's status updated: (a) kept per adjudication 5, with the plan-named resume of piece F.

**Design issues (the stop rule):** none stopped the unit. Nearest: P-VX378-U2-2 (the plan's crossings table describes
an impossible mechanism; the rules themselves are buildable and hold) and P-VX378-U2-3 (rule 7's "here they are" with
rule 14's one secret — a face's sentence, not a model gap). E's found gap (an entry into Castle after a lost memory
item left the old Apple key alive — Castle's promise) was a model gap with a model answer (the key the live key file
names), fixed red-first in G.

**Commits:** A `0572dd3c0` · B `3631ecbde` · C `ef6c6bf54` · D `67ed68490` · E `db1c1ac55` · F `a01b622db` · G
`1a02354bd` · H `21cc0377a` · I `320579718` · J (this record's close — the next commit).

### ORCHESTRATOR NOTE after U2 (2026-10-16 — verified, adjudicated; HER RULING on the crossings)

**Verified, never trusted:** tree clean at `014592e4b`, in sync with origin; the scope diff `d992d2906..HEAD` touches
only the two Protection folders, this plan and `notes/QUESTIONS.md` (63 files). Orchestrator re-runs on `014592e4b`:
the protection set under a wider filter in Debug `✔ 391 tests in 158 suites passed` (subsuming the record's 254/67);
under `-c release` `✘ 312 tests in 135 suites … 1 issue` — the one red is VX-380's Sync attacker test again, swept in
by the filter, nothing of Protection's; the full core suite in Debug `✔ 240/51` · `✔ 3114/397` · `✔ 40/6`, matching
the record's lines. **Revert check:** piece F's `U2PinsRule21Tests` run on a scratch worktree at `a01b622db^` with the
pin file copied in — `✘ 7 tests in 1 suite failed … with 10 issues` (`:36`, `:56`, `:73`, `:95`–`:97`, `:109` ×3,
`:124`), exactly the record's; green on HEAD; the worktree removed.

**HER RULING (2026-10-16, the question put to her with three options — the recommended one her pick, verbatim: *"Both
secrets, as built (Recommended)"*):** Use Castle and Use Standard type the passphrase AND the twelve words, local or
synced; no cross-wrap machinery; rules 11 and 12 gain "and your twelve words" (applied to `notes/CastleRules.md` in this
commit — the one amendment this phase makes to the rules, at her word); the lifecycle page's stages 6 and 8 say so; the
plan's crossings table rewritten. A user without their words paper does New Words first (passphrase-only, rule 6), then
crosses. P-VX378-U2-2 → RULED (a). The declined options stay listed in QUESTIONS so no later session re-proposes them.
Her reasoning, added after the pick (verbatim, 2026-10-16): *"and whenever someone has their passphrase, they can easily
regenerate the 12 words, so this isn't even particularly onerous."*

**Adjudications (the orchestrator; PROVISIONAL where product-flavoured, bundled for her):**
1. **P-VX378-U2-1 (Replace All Keys re-keys the library only) — (a) stands:** rule 15 fixes when the sync key changes;
   a new master alone cuts nothing off. Her eye at the bundle (whether a LOCAL library gets the door is a face call).
2. **P-VX378-U2-3 ("here they are" at a passphrase-typed join) — (a) stands:** a face's sentence; the model reports
   `wordsReplacedByAccount`. Bundled with the faces (VX-308).
3. **P-VX378-U2-4 (Make this my library's new library is local; the device's settings carry) — (a) stands** as the
   rule-17 reading ("a fresh identity"); hers at VX-309 with the faces.
4. **P-VX378-U2-5 (a key door's one-write window with the vault out of reach at the relaunch rolls back, leaving the
   pair split until the next key door) — (a) stands as a STATED LIMIT:** nothing is lost, both secrets still open the
   library by one road each; U4's promises read it so; the record carries it for the handoff's residue list.
5. **Rule 21's two doors on the LIVE PLACE's stray → VX-309 beside T-5** (the refusal offers the doors as values; acting
   on a stray with no catalogued copy and no current library in hand is the empty-slot landing's own question). The
   rules checklist's row 21 says so honestly.
6. **E's found gap (an entry into Castle after a lost memory item left the old Apple key alive)** — fixed red-first in
   G by retiring the key the live key file names: accepted; it is rule 11's own sentence, not new machinery.
7. **The crash harness's find (a resumed join missing its vault read)** — fixed in I: accepted, pinned by the harness.
8. **U4 inherits:** promise 6 strict; promise 3 to tighten (rule 8 re-makes the Apple road at the same open);
   `resumeAtVaultReach` to delete; the replay tampers back as detection against U2's pinned refusal.

**For U3 (binding):** the fixture's facts for stages 6 and 8 carry her ruling (both secrets typed); rule 5's reading is
P-VX378-O1-1's (a); P-VX378-U2-3's "here they are" fact at stage 12 reads "the words are shown when they were typed";
everything else on the page stands as its facts.

### U3 RECORD — THE LIFECYCLE PROOF (Opus implementer, 2026-10-16; DONE — awaiting the cold review)

**Not done in U3, first (each with its reason):**
- **No model change.** `Sources/VariorumCore/Protection/` is untouched (7,562 lines, as U2 left it): every page fact the
  model doesn't produce is a FACTS DIFF, hers to accept — never a model edit to make the fixture pass.
- **The page's words are unchanged where a FACTS DIFF stands** (FD-1, FD-2, FD-3): each stage shows an "under review"
  note until she rules; the fixture keeps the page's fact with the diff on its status.
- **Branches the page offers but this road doesn't take are not walked** — each is named in the fixture with where it
  is proven or whose it is (`LStatus.branch` / `.notAModelFact`): "either secret can reset the other" (the key-door
  tests), a library with no passphrase entering Castle (`doorSecrets` sets one), "you never leave Castle by opening
  something" (`U2MakeMineTests.inCastleTheNewLibraryIsCastle`), Castle's Touch ID re-arm on new hardware (a press, never
  a repair — the guard and its pins; the face VX-306's), a device that lagged through the whole Castle stretch
  (`FollowTests.aDeviceThatLaggedThroughCastleCatchesUpWithOneSecret`); and the faces' and Apple's sentences (the
  reminder schedule, the leave screen's words, "shows the words", the Restore from Backup button, the server's
  row-level security, what Apple carries to a new Mac).
- **The promises are not checked on this walk** — U4 rewrites them; the lifecycle's only authority is the fixture.

**The calls (each recorded with its reason):**
- **The fixture is a Swift literal**, `Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/LifecycleFixture.swift`
  (`Lifecycle.stages`, `Lifecycle.factsDiff`), not JSON: a JSON file in the test target needs a resource declaration in
  `Package.swift` (outside this unit's scope diff) or draws SwiftPM's unhandled-file warning; and the compiler holds
  every road, fact and status to a known case, so a typo can't quietly turn a fact into nothing. **Its shape:** per stage
  — the posture, the page's rows (prose as data; the road chips TYPED: `LRoad` — a typed secret by whose day and which
  road · the Apple road · the on-device road · Touch ID · every quiet road — with `LState` opens/gone, a condition for
  "(if chosen)" and "everywhere" for the Apple deletion reaching her other Macs), hidden road rows the page implies but
  shows none for (each naming its source — "carried from stage N" or "stated in the stage's words"), and the written
  facts (`LFact`, each quoting the page words it types, its rules and a status: asserted · asserted at a later stage ·
  a branch not on this road (where proven) · not a protection-model fact (whose) · a FACTS DIFF with the observed
  fact). The page's two "or"s before stage 6 are walked both ways (`LStage5Event`: an Apple ID change, an iCloud Keychain
  reset; the gate: Touch ID, Always ask). The fixture was written BEFORE any test; it states the page as written —
  nothing in it anticipates the model.
- **The world the scenario walks is the scenario world (`SWorld`)** — its devices' leaves run the real
  `ProtectionExecutor` acts. Read with the brief's "the executor world's real acts" as the real acts, on the world
  with the realistic fakes: the page's stages 5, 6 and 11 need an Apple account whose items (and deletions) reach other
  Macs, an Apple-ID change, an iCloud Keychain reset and a new Mac with a fresh keychain — `SWorld` models all of them
  with the measured Apple facts (`Fakes.swift`), the executor harness (`ExecutorWorld`) none. Her Mac is `macA`, her
  other Mac `macB` (stage 6's "other Macs", stage 12's second device), someone else's Mac `theirMac` (its own Apple ID
  and Variorum account, stage 10). The promises are not checked on this walk (U4 rewrites them); its only authority is
  the fixture.
- **The renderer is test-side** (`LifecyclePage.swift`, its prose in `LifecycleProse.swift`, the guard
  `LifecyclePageTests.theCommittedPageIsTheRenderedOne`), not `Tools/castle-lifecycle-page`: a tool needs a
  `Package.swift` target (outside this unit's scope diff), and the test target reads the fixture's own types with no
  second copy. Regeneration: `CASTLE_LIFECYCLE_PAGE_OUT=<path> swift test --filter LifecyclePageTests`, then `cmp`.

**Pieces (the resume map — a fresh session can finish U3 from this list and `git log`):**
- A — the record skeleton and LIVE STATUS: DONE (`81cc3534d`).
- B — the fixture alone (the page's fourteen stages as typed facts, the prose riding as data): DONE (`bb0550230`) —
  compiles in the test target (`swift build --build-tests`); no test reads it yet.
- C — the scenario: the fourteen stages walked through the real acts, asserting against the fixture: DONE (`bdd19624e`,
  the posture check `389162a09`) —
  the walk (`LifecycleWalk.swift`), the fixture's judgment (`LifecycleChecks.swift`) and the suite
  (`LifecycleScenarioTests.swift`) committed in the state of their FIRST RUN: red at exactly the facts
  the model does not produce (FD-1 stage 1, FD-2 stage 6 under the Apple-ID road, FD-3 stage 8 — the FACTS DIFF
  below), every other chip and fact green in all four walks; `everyChipDiscriminates` green (every chip, flipped,
  fails the same world). One fixture addition before that first run, recorded: stage 6's "deleted" typed as its own
  fact (`appleKeysDeleted`) — piece B had typed only "die everywhere". The FACTS DIFF marked in the next commit
  (E(1), `a83c44d21`): the suite green in all four walks.
- D — the renderer and the regenerated page (`cmp`): DONE (`475d91177`). **Lossless first:** rendering the fixture with
  the target's own lead and footer and no review notes reproduces the target page BYTE FOR BYTE (`cmp` identical to the
  page as committed at `bb0550230`). Then the regenerated page: prose changed only where recorded (the lead's last
  sentence and the footer now say the page is rendered from the fixture; one style line, `.note.diff`, for the "under
  review" note each FACTS DIFF puts on its stage — FD-1 on stage 1, FD-2 on 6, FD-3 on 8); `cmp` of the render
  (`CASTLE_LIFECYCLE_PAGE_OUT`) with the committed page: identical; the guard test green.
- E — FACTS DIFF and PROVISIONALs (QUESTIONS): DONE — the three diffs marked (`a83c44d21`); QUESTIONS (`6f24fada4`):
  P-VX378-U3-1, P-VX378-U3-2 and the FACTS DIFF bundle.
- F — the closing runs, counts, this record closed: DONE (this commit).

**The stage that first went red, and why that proves the fixture is the authority.** The scenario's first run went red
first at **stage 1** — the note's *"If you skip writing the words down, the app reminds you"* (FD-1) — then at stage 6
on the Apple-ID road (FD-2) and stage 8 (FD-3), every other chip and written fact green in all four walks (one more red
that first run, at stage 14's "four things remembered", was the TEST's own timing — it read what this Mac remembers
after the stage's deliberate deletions; the observation moved to the stage's start, no fixture change). Those reds are
page sentences the model doesn't produce, found where the page and the build differ: the fixture was committed alone (`bb0550230`) before any test existed and anticipates nothing about the model; the
checks try each road for real (a typed secret against a key file and its history, an Apple key against a lock, an
item's key against a file, the model's own Look inside door agreeing) and never read the model's route sentence or
`assess`'s opinion of a road. **`everyChipDiscriminates`** shows it for every chip: in two walks, each of the stages'
road chips (shown and hidden) asked to show the opposite of what the fixture says FAILS the same world — no chip
passes either way. On a tree before U2 the scenario doesn't compile (the creation took its words from the caller; Look
inside and Make this my library didn't exist) — red by construction, as U2's new-API tests were.

**What the walk does, stage by stage** (`LifecycleWalk.swift`; the fixture's `road` line names each): 1 create (no
passphrase) · 2 the plain-confirm passphrase door (P-VX378-U3-1) · 3 backup A · 4 Change Passphrase · 5 each "or": her
devices to another Apple ID (P-VX378-U3-2) / iCloud Keychain reset, then the next open with nothing typed · 6 the
scheduled export on, Use Castle typing both secrets — each gate, Touch ID and Always ask — then the export turned back
on · 7 New Words, backup B · 8 Use Standard typing both · 9 Look inside backup B (every secret the page names, and none)
then Make this my library · 10 their library on their Mac (another Apple ID, their own account), Send Library to her
Mac, Look inside it, Make this my library · 11 new hardware with no keychain item arriving, the first open · 12 sync on
first; her other Mac makes a library, backs it up, joins typing the account's passphrase; it enters Castle, her Mac
lags then follows typing one secret; her Mac leaves Castle, the other follows out quietly; the other leaves the account
and signs back in · 13 Replace All Keys crashed after its first write, then after its plan, each with the next open ·
14 a backup pair copied in by hand, a replayed old library file, someone else's file swapped in (each opened, then put
back), the live key file deleted, then every key-file copy gone. Four walks (two stage-5 roads × two gates), ~0.7 s.

**Found while proving (for the orchestrator — none stopped the unit; none is a model change of mine):**
- **After Make this my library, today's secrets no longer open the old library's backups through Look inside.** The
  new library's key file has no past (rule 17), and Look inside tries only the copy's own key file and the LIVE key
  file's history, so backup A (stage 3's) refuses today's passphrase and words after stage 9 — only its day's secrets
  open it — although the library that stepped aside, in Previous Libraries, carries a key file whose history reaches it
  with today's passphrase (probed, not committed: `lookInside(A)` today P/W refused, its-day words opened, the Previous
  Libraries key file reaches A). Not a page fact (the page follows no backup past stage 8), but it meets the core
  sentence and U4's planned promise *"your current passphrase or words open every copy you have ever made"* — U4's to
  settle (rule 19 calls them another library's copies; the road exists in the catalog).
- **The copy doors take a catalogued copy; an AirDropped folder isn't one.** Send Library's hand-off folder is "not a
  copy place" to the catalog, so stage 10 files what arrived where the catalog reads another library's copy
  (`Backups/<their library8>/<their mac8>/`) before the doors — the picker that hands an arbitrary folder to Look inside
  is VX-309's (beside T-5), as U2 recorded.
- **FD-2's rule question** (rule 11's parenthetical vs a key left in an Apple account she has left) — in FACTS DIFF.

**FACTS DIFF** (each hers to accept; never a silent edit of the fixture — the page's fact stays in the fixture as the
page states it, the status names the diff and the fact the model produces instead, which the scenario asserts; it also
asserts the page's fact still fails, so a diff the model later closes reports itself stale). All three were found by the
scenario's FIRST run (piece C, `bdd19624e`); none was anticipated in the fixture:
- **FD-1 — stage 1's note, the reminder's trigger.** Page: *"If you skip writing the words down, the app reminds you"*.
  Model: the reminder keys on the passphrase — owed while no passphrase exists (`passphraseSet` false, U2 piece C),
  whatever happened to the words. Reason: rule 3 is the contract (*"Until a passphrase exists, the app says so now and
  then"*), and no model can know whether words were written down. Proposed words for the note: *"Until you set a
  passphrase, the app reminds you — at the third launch, …"*. A page-wording diff, not a rule matter.
- **FD-2 — stage 6, "the Apple and on-device keychain entries are deleted", on the road where her Apple ID changed at
  stage 5** (on the iCloud Keychain reset road the page's fact holds). Model: the library's first Apple key lives in the
  Apple account she left; no Mac can delete it from there (the world: `deleteAppleKey` finds no item to delete on a Mac
  signed into another Apple ID). It is unreadable on every device of hers, Use Castle's door names backup A as a copy
  under a key this Mac can't delete (`Words.copiesUnderAKeyThisMacCantDelete`), and the key is recorded retired —
  deleted on sight if it ever reaches this Mac again (`Repair.deleteRetiredAppleKey`). Reason: rule 11's deletion
  reaches every device on the Apple account the item lives in — this Mac is no longer signed into that one; rules 8 and
  25 say Apple's road is Apple's. **The nearest rule question (for her, not a stop):** rule 11's parenthetical ("so your
  Standard-era backups' quiet locks die with it") cannot reach a key left in an Apple account she has left — no device
  of the account reads it, so rule 9 holds, but someone holding her OLD Apple account and backup A's file could open it.
  Rule 25 speaks of Apple roads that stop working, not of one the app cannot kill; a sentence there would state it.
- **FD-3 — stage 8, "This Mac's Touch ID item … now hold[s] the new key".** Model: the Castle key's Touch ID item goes
  with its key; the new Standard key sits in the on-device road — the silent login-keychain item, no biometric gate — and
  no Touch ID item exists. Reason: §3's rule-8 row (her F13 ruling): in Standard the on-device road is the SILENT item
  ("login password or Touch ID" in honest terms — Apple facts §12; a gated item would prompt on every read); U2's first
  reading, accepted by the orchestrator. Rule 12 carries the same words. Proposed page words: *"This Mac's on-device
  road and its sealed key-file copy now hold the new key."*

**The runs (exit lines, both configurations; code tree `389162a09`):**
- The protection set, Debug (`swift test --filter 'VariorumCoreTests\.(<the 69 suites under
  Tests/VariorumCoreTests/Protection>)/'`, exit 0): `✔ Test run with 259 tests in 69 suites passed after 2.731
  seconds.` Before U3 (U2's close): `✔ 254 tests in 67 suites`.
- The full core suite, Debug (`swift test`, exit 0): `✔ Test run with 240 tests in 51 suites passed after 22.803
  seconds.` · `✔ Test run with 3119 tests in 399 suites passed after 186.167 seconds.` · `✔ Test run with 40 tests in
  6 suites passed after 45.492 seconds.`
- `swift build -c release` (exit 0): `Build complete! (87.74 sec)`.
- The protection set, Release (`swift test -c release --filter <the same>`, exit 0): `✔ Test run with 237 tests in 65
  suites passed after 2.139 seconds.` — the lifecycle suites run there too (no DEBUG switch in them): the scenario's
  four walks, the discrimination's two, the fixture's wholeness, the page guard.
- `cmp` of the render with the committed page: identical (piece D, and the guard test green in both configurations).
- Line counts: `Sources/VariorumCore/Protection/` 7,562 → **7,562** (untouched); `Tests/VariorumCoreTests/Protection/`
  9,380 → **12,068**. The diff `e6ca657ce..HEAD`: 10 files — the seven new files under
  `Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/`, `notes/plans/vx-266/castle-lifecycle.html` (regenerated),
  this plan and `notes/QUESTIONS.md`.

**PROVISIONAL calls** (logged under the VX-378 heading in `notes/QUESTIONS.md`, "VX-378 U3 THE LIFECYCLE PROOF"):
- **P-VX378-U3-1** — "you set a passphrase" (stage 2) is the Standard road of the forgotten-passphrase door,
  `resetPassphrase(.plainConfirm)` (rule 6's re-lock; no new act); options (b) a named set-passphrase act, (c) Change
  Passphrase without a current one.
- **P-VX378-U3-2** — "you change your Apple ID" (stage 5) moves every device of hers; option (b) this Mac alone.
- The three FACTS DIFF are logged there too, each with its (a)/(b), for her bundle.

**Commits:** A `81cc3534d` · B `bb0550230` (the fixture alone) · C `bdd19624e` (the scenario at its first run) · E(1)
`a83c44d21` (the FACTS DIFF marked) · D `475d91177` (the renderer and the page) · E(2) `6f24fada4` (QUESTIONS) · the
posture check `389162a09` · F (this record's close — the next commit).

### ORCHESTRATOR NOTE after U3 (2026-10-16 — verified, adjudicated; her calls on the FACTS DIFF below)

**Verified, never trusted:** tree clean at `c973e7f38`, in sync with origin; the scope diff `e6ca657ce..HEAD` is ten
files — the seven new Lifecycle test files, the regenerated page, this plan and QUESTIONS; ZERO lines in `Sources/`
(the model untouched at 7,562). Orchestrator re-runs on `c973e7f38`: the protection + lifecycle suites under a wider
filter in Debug `✔ 347 tests in 143 suites passed` (subsuming the record's 259/69); under `-c release` `✘ 325 tests in
139 suites … 1 issue` — VX-380's Sync test again, nothing of Protection's (the lifecycle suites run and pass there too);
the full core suite in Debug: `✔ 240/51` · `✘ 3119/399 … 1 issue` · `✔ 40/6` — the one red a TIMING failure outside Protection (`StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar`, "Time limit was exceeded: 60.000 seconds" under the full-suite load; `swift test --filter StarContextTests` alone `✔ 11 tests in 1 suite passed after 0.737 seconds`) — the VX-305 record's known perf-timing-under-load class, not a model red; the implementer's own full run was green. **The renderer's byte-equality re-checked:** the page rendered from the
fixture (`CASTLE_LIFECYCLE_PAGE_OUT=… swift test --filter LifecyclePageTests`) `cmp`-identical to the committed
`castle-lifecycle.html`. **Red-on-old by construction, checked:** the fixture commit `bb0550230` precedes the scenario
commit `bdd19624e`, whose message records the first run red at exactly FD-1/FD-2/FD-3 and green everywhere else;
`everyChipDiscriminates` asks every chip for its opposite and fails. The page's prose changed only where the record
says (the lead's last sentence, the footer, the `.note.diff` style, the three under-review notes).

**Adjudications:**
1. **FD-1 / FD-2 / FD-3 and the "found while proving" item 1 are HERS** — put to her at this seam (four options
   batches, the recommended first); her answers are recorded below and the fixture/page/rules follow them in U4's
   window or at the closeout, never silently. Until she rules, the page keeps its words and shows the under-review notes.
2. **P-VX378-U3-1 ("you set a passphrase" is the reset door's Standard road, no new act) — (a) stands:** rule 6's
   re-lock, no machinery; the face names it (phase 3).
3. **P-VX378-U3-2 (an Apple ID change moves every device of hers) — (a) stands** as the ordinary reading of "you change
   your Apple ID"; (b) is a per-device corner the world may still draw.
4. **Found item 3 (the copy doors take a catalogued copy; an AirDropped folder is filed first)** — VX-309's, as U2 recorded.
5. **Found item 2 (a Standard-era Apple key left in an Apple account she LEFT cannot be deleted from here)** is FD-2's
   rule question — hers, below.

**HER RULINGS at this seam (2026-10-16, the question tool; the recommended option her pick where quoted):**
- **FD-1 — ACCEPTED:** *"Accept the new wording"* — stage 1's note reads "Until you set a passphrase, the app reminds
  you — …"; rule 3 unchanged. The fixture's fact changes to the page's new line; the under-review note goes.
- **FD-2 — RULED "Say it in rule 25":** rule 25 gains one sentence — a Standard-era backup locked under an Apple
  account you have since left keeps that lock, which the app cannot delete; the page's stage 6 says it on the Apple-ID
  road; rule 9 untouched (no device of the account reads that key). Rule 11's words stand for the keychain-reset road.
- **FD-3 — ACCEPTED:** *"Accept the new wording"* — the page's stage 8 and rule 12 read "this Mac's on-device road and
  its sealed key-file copy now hold the new key"; F13 stands.
- **The Look-inside question after Make this my library — IN DISCUSSION** (her words: *"hmm let's talk about this a bit
  more. seems like it's adding a bit of complexity - if you make this my library, it's no longer the same library, so
  today's secrets not opening the old library's backups makes sense to me. I don't really get what … what are you
  trying to open exactly? the old library?"*). The orchestrator's plain restatement and her call follow in the next
  entry; U4 is briefed with the promise SCOPED to the library's own lineage meanwhile (the no-machinery reading), and
  told the one open question.
The rules' and the page's wording changes (rules 12, 25; stages 1, 6, 8) are applied by U4's fixture/page piece under
her rulings above, never silently; the fixture diffs FD-1…3 close with them.

### U4 RECORD — THE WORLD AND THE SOAK (Opus implementer, 2026-10-16/17; STOPPED at a design find — P-VX378-U4-3, hers)

**Not done in U4, first:** **the discovery run was not completed and the gate soak did not run — the unit STOPPED at a
design find (the plan's stop rule: "a red you cannot close without changing a rule … STOPS the unit at a clean seam"):
P-VX378-U4-3, a device that lagged while BOTH secrets changed and the account entered Castle opens with no secret of
today (rules 4 and 12 fail there; closing it needs a mechanism the rules don't name, or a rule — hers).** Gate items 1
(both soaks) and therefore the GO are open; items 2 (every fixed scenario green both configurations — yes, with the stop's
pin a known issue) and 3 (every mutation pin red with its guard off — yes, Debug) hold on this tree. The census sized the
rest (seeds 21–23: 88 failing sequences in 3,000) into classes (A)–(I) in piece E — none of (B)–(I) was fixed, by the stop.
Also not done: rule 17's added words name the copy's key history only while the built history also carries the previous
library's keys (piece B2's reading (1) — the orchestrator may want her to amend the sentence); the status line of
`notes/CastleRules.md` doesn't yet name the FACTS DIFF and P-VX378-U4-1 amendments (the brief's "only these edits").

**Pieces (the resume map — a fresh session can finish U4 from this list and `git log`):**
- A — the record skeleton and LIVE STATUS: DONE (this commit).
- B — her FACTS DIFF rulings applied (FD-1 stage 1's note; FD-2 rule 25's one sentence + stage 6 on the Apple-ID road;
  FD-3 stage 8 + rule 12): DONE (this commit). `notes/CastleRules.md` — the ONLY rules edits of this unit: rule 12's
  *"this Mac's Touch ID item and sealed key-file copy now hold the new key"* → *"this Mac's on-device road and its
  sealed key-file copy now hold the new key"*; rule 25 gains *"A Standard-era backup locked under an Apple account you
  have since left keeps that lock, which the app cannot delete."* (the status line's amendment list left as it was —
  the brief's "only these edits"; the orchestrator may name the ruling there at closeout). The fixture: stage 1's note
  and fact → *"Until you set a passphrase, the app reminds you — …"* / `.reminderTrigger(.noPassphraseYet)` asserted
  (the `wordsNotWrittenDown` case retired); stage 6 gains the Apple-ID-road sentence *"(If your Apple ID changed at
  stage 5, backup A's Apple lock sits under a key in the Apple account you have since left: backup A keeps that lock,
  which the app cannot delete [25] — no device of yours reads it, and Use Castle names backup A as a copy under a key it
  can't delete.)"*, typed as a new status `LStatus.onlyWhen(LStage5Event)` — `appleKeysDeleted` asserted on the
  keychain-reset road only, the new fact `appleLockKeptInAnAccountSheLeft(.backupA)` with
  `useCastleNamesCopiesItCantDelete(.backupA)` on the Apple-ID road only; stage 8's text and fact → *"This Mac's
  on-device road and its sealed key-file copy now hold the new key"* / the custody fact (on-device, no Touch ID item for
  any key it has had) asserted. `Lifecycle.factsDiff` is EMPTY (the mechanism kept for any future diff); the three
  under-review notes gone. A new guard `eachRoadsOwnSentenceFailsOnTheOtherRoad` (each `onlyWhen` fact fails on the
  other stage-5 road — no pass either way). Runs: `swift test --filter 'VariorumCoreTests\.(LifecycleScenarioTests|
  LifecyclePageTests)/'` → `✔ Test run with 6 tests in 2 suites passed` (the four walks, the two discriminations, the
  other-road guard's two, the fixture's wholeness, the page guard); the render `cmp`-IDENTICAL to the committed page.
- B2 — HER RULING ON P-VX378-U4-1 (2026-10-16, relayed by the orchestrator mid-unit — binding): Make this my library
  CARRIES THE KEY HISTORY FORWARD. Her words, verbatim: *"let's just keep carrying the key history file forward - I see
  no particular reason to not do it, if you've decided that this is your library from now on, then why should it *not*
  have the old keys to your previous library? we say clearly that your new library always carries keys forward."* — and,
  earlier in the same sitting, agreeing the posture and the no-setting shape: *"ok yes, I'm happy with this."* DONE (this
  commit). **The model** (`Sources/…/Protection/`, three files): `KeyFile.building(…, carrying:)`; `makeThisMyLibrary`
  gathers at the press — held with the copy's key, never stored — the copy's key and its own key file's history, then
  the previous library's key and its history; `makeMineKeyFile` seals them under the new key (a resume without them
  rolls back, as the stage step already did without the copy's key); `makeMineRecord` carries the previous section's
  Apple-key records into the new section. **Two readings, recorded:** (1) the history holds BOTH the copy's keys (the
  orchestrator's mechanism, rule 17's new words, her pins 1(c)) AND the previous library's keys — her own words ("the
  old keys to your previous library"), the stage-10 fact the orchestrator named ("the same mechanism": her backups still
  open after someone else's library is made hers) and the unscoped core sentence all need the second set; the copy's
  history alone would leave stage 10 and the core sentence false. Rule 17's added words name the copy's history only —
  **for the orchestrator: she may want "and your previous library's" in that sentence** (not edited here — the one
  wording given was applied verbatim). (2) The previous library's own Apple-key records come into the new section:
  without them, a later Use Castle on the new library would leave the Apple key that wraps a key its history now holds
  (the previous library's) alive — rule 11's "entering takes everything in" broken by the carried history; with them,
  the entry retires it (pinned). **Pins** `U4MakeMineHistoryTests` (5): red on the pre-piece tree (scratch worktree at
  `a8fe1f349`, the pin file copied in — "4 tests in 1 suite failed … with 6 issues": `:63` the previous library's backup
  doesn't open with today's passphrase through the new history (the old tree opened it only by its own Apple lock),
  `:81`/`:82` a Castle Mac's new Castle key carries neither the Standard copy's keys nor the previous library's key,
  `:105` a Standard Mac's new key carries no Castle keys, `:126`/`:127` the previous library's Apple key survives a later
  Use Castle); `theDoorAlwaysVerifiesTheCurrentPairAndOffersNoChoice` is the guard her "make sure a pin says so" asked
  for — green both sides (the built shape unchanged: the posture of now, no choice, the current pair always typed). The
  crash harness over the changed act (`U2MakeMineTests.aCrashAfterEveryWriteFinishesOrNeverHappened`) green;
  `U2MakeMineTests`' "no past" assertion turned to the carried history. **Rules:** `notes/CastleRules.md` rule 17 gains
  *"carrying the copy's key history forward (rule 4)"* — the one wording change at her ruling. **The lifecycle:** stage 9's
  and 10's Make-this-my-library text and facts carry the history (the `makeMine` check now asserts the carried set), and
  hidden roads assert backups A and B (and, at stage 10, their library) open with today's secrets through the new
  library's history — red on the pre-ruling model in all four walks (scratch run: "Look inside refused a secret the road
  opens" at stages 9 and 10, `everyChipDiscriminates` "passes either way" there), green after; the page re-rendered,
  `cmp`-identical; lifecycle suites `✔ 6 tests in 2 suites`. QUESTIONS: P-VX378-U4-1 → RULED, option (b) recorded as
  not chosen.
- C — the promises rewritten to the rules: DONE (this commit). **Nine promises, each quoting its rule**
  (`Scenario/Promises.swift`'s header carries the list and the stated limits): **1 ONE POSTURE** (9, 11, 13 — in Castle
  no silent item for any key the library has had, no Apple wrap of the current key, no retired Apple key readable once
  settled, and THE ATTACKER — a login-password holder on the device plus the Apple account's iCloud Keychain — reaches no
  key the live key file carries and opens no copy of it); **2 STANDARD HANDS EVERYTHING OUT** (8, 12 — settled: the current
  key opens by an Apple road readable here AND its on-device item; the old promise 3 TIGHTENED — a detected lost Apple
  road no longer excuses it, rule 8 re-makes it at the same open; decision 35's synced wait kept); **3 THE ACCOUNT IS ONE
  POSTURE** (10, 14, 15 — every sync key the account has had stays in the vault under the current master, which her
  current secrets open; while Castle no silent sync-keys item holds the current row key and a device holding it has
  followed; settled, every device ends in the account's posture holding its current sync key); **4 THE CORE SENTENCE**
  (4, 5, 6, 7, 17 — her CURRENT passphrase or words, typed or through the account's vault, reach every copy this Mac ever
  made through the live key file, its sealed copy and the copy's own file; UNSCOPED across Make this my library at her
  ruling, B2); **5 EVERY COPY OPENS BY SOME ROAD** (1, 27, 19 — by her roads with nothing in the app's hands, the live
  library too or the lobby's honest `noKeyFileAnywhere`; retention prunes only this Mac's copies of this library — the
  old promise 11 folded in); **6 CRASH SAFE** (20 — STRICT: an open app with an act in flight, a plan or staged file
  left, or copies paused is a violation; no qualifier); **7 FOUR THINGS; A DISAGREEMENT REFUSES** (21, 23 — a verified
  memory item names the library, its key and this Mac's device ID, carries the current key's file and names no other
  library; at every launch the world's own oracle `liveDisagrees` must match the open: a disagreement refuses and writes
  nothing, none opens); **8 DELETED ONLY AFTER REPLACEMENT** (22 — at every delete the world checks the library in the
  live place still opens by her roads with nothing in hand, `SWorld.deleting`); **9 NOTHING SILENT** (the kept core of
  promise 10 + 17 — posture and account change only at a deliberate act; in Castle no tampered file or item, alone or in
  a group, weakens the mode, account, custody, gate or export; Look inside writes NOTHING, judged on everything the
  device holds; Make this my library keeps the posture of now). **NO promise about pre-leave copies after a leave.**
  **Stated limits:** L1 rule 10 (a lagging device), L2 rule 25 (Apple's roads; FD-2), L3 rule 3 (a Standard tamper),
  L4 THE ROLLBACK (P-U4-5 + P-U4-12, her rulings, carried: files returned with the memory gone or returned too), L5 rules
  17–18 (a key carried in from another library's copy keeps that library's own roads). **Deleted:** `resumeAtVaultReach`
  (and its three callers); promise 6's tolerance already gone at U2; the old open-copy bookkeeping (`opens`). **The
  alphabet:** rule 17's two doors as acts (`.lookInside` with current / its day's / no secrets, `.makeMine`), the replay
  tampers back as DETECTION (`replayLibraryFile`, `replayKeyFile`, `deleteKeyFileAndMemory` — `Tamper.generated` is
  every tamper); the door-agreement check (Look inside with her current secrets must open what her typed roads reach —
  promise 4). **Starting states (11):** nothing yet; fresh Standard; Standard with no passphrase; Castle Touch ID; Castle
  Always ask; synced Standard on two Macs; synced Castle on three devices (Always ask); synced Castle with Touch ID; a
  Castle backup after a leave; a lagging device (the account entered Castle on another); two Macs sharing an iCloud
  Drive backup folder. **Found while writing them (world, not model):** `act()`'s `defer` wrote the act-time library
  back over the one the after-act repairs updated, so the next act sealed a stale key-file copy into the memory —
  promise 7's new mirror clause caught it (generator seed 2 sequence 2); fixed in the world. Protection set Debug
  `✔ 265 tests in 70 suites` (generator 16 sequences).
- D — each promise catches its own breach, and the mutation pins: DONE (this commit). **`U4PromiseCheckTests` (9, one
  per promise):** each checker is quiet on a clean world and red with its breach planted by hand — 1 a silent item for an
  EARLIER key of a Castle library; 2 Standard's Apple road and on-device item gone; 3 a silent sync-keys item holding a
  Castle account's current row key, and an earlier row key gone from the vault; 4 the live key file's history dropped
  (today's secrets no longer reach an older backup); 5 a copy no road opens, and a closed library no road opens while
  the lobby says nothing; 6 copies paused and a plan left; 7 the oracle reads a replayed key file as a disagreement and
  an absent memory as none, and a memory naming another device is caught; 8 a delete taking every key file (Use
  Castle's closing backup is a road the check rightly counted at first); 9 a mode moved at a non-deliberate step, a
  weakening tamper group (and the complete replay as L4, quiet), Make this my library leaving Castle. **Mutation
  pins — every one of the 12 surviving guards has at least one, each red with its guard off** (the `mutationPin`
  helper and the unit pins assert it; the Debug run is the proof): world pins (7) `thePlantedPlan` (planNamedBySection),
  `noRepairMakesATouchIDItem` (noRepairMakesTouchID + repairNeverMakesTouchIDItem), `noRearmQuestionWithoutAnItem`,
  `enteringCastleWithTheScheduledExportOn` (exportOffAtCastle), `theCrossMacPrune` (pruneOwnCopiesOnly),
  `deleteOnSightByRecordedIDOnly`, and NEW `aCrashAtAnyWriteOfUseCastleLeavesTheLibraryOpenable` (prepareBeforeCommit —
  crashes after writes 1…24, red with the guard off: a crash past the swap strands the library, promise 5); unit pins
  (`AssessGuardMutationTests`, `ExecutorGuardMutationTests`, `RetentionTests`) for every guard. **No world pin, recorded:**
  `everyOwnKeyRetiredAtCastle` — with it off the after-act repair `retireOwnAppleKeys` retires the missed key at once
  (two lines of defence; the sequence lives on as the fixed scenario
  `makeThisMyLibraryThenUseCastleRetiresThePreviousLibrarysAppleKey`); `freshVaultBeforeAppleWrite` — the Apple road a
  lagging device would re-make is rule 10's accepted lag and its follow retires it (the section lists it first);
  `repairPreconditionsVerified` and `standardRecordNoDestructiveRepair` — the world can't plant the precondition the
  first needs (a live key file whose claims fail to verify is now rule 21's refusal) and the second's delete removes no
  road any promise reads. Each keeps its unit pin. Protection set Debug `✔ 276 tests in 71 suites`.
- E — the discovery run: **STOPPED at a design find (P-VX378-U4-3) — the plan's stop rule; nothing after it ran as the
  gate.** Seed 21 was walked in growing probes (100 → 400 sequences, Debug, `PROTECTION_SOAK=1 PROTECTION_SEED=21
  PROTECTION_SOAK_SEEDS=1 PROTECTION_SOAK_SEQUENCES=n`); every red was traced (the generator now also writes a red's
  whole report to `PROTECTION_FAIL_OUT` — the console dropped a long issue once). **The finds, in order:**
  1. seq 20 — promise 7 "remembers another library": a login-password holder REPLAYED the old library's memory item
     after Make this my library; the open is untouched (the live place is remembered). CHECKER: rule 21's "only the
     app's own doors change them" binds the app; items a replay planted (`truth.plantedMemories`) are exempt.
  2. seq 21 — promise 3 "a device that hasn't followed into Castle holds the key Castle rows are written under": the
     WORLD's stand-in for the lobby's Always-ask duty (phase 2's wiring, `SWorld.launch`) held the vault's current keys
     in session for a lagging device. WORLD: it holds them only for a record that already follows the vault's key and
     posture; a lagging device's follow types its secret and holds them (rule 15).
  3. seq 21 — promise 9 "the mode is standard" after a replay group: the open REFUSED correctly (rule 21); the clause
     read the mode from the adversary's file on disk. CHECKER: after a refused relaunch only what the app could write is
     judged (promise 7 holds the refusal to zero writes).
  4. seq 32 — promise 1 "a silent custody item holds …": tampers made while the device was in STANDARD (L3, rule 3) —
     the replayed older library file opened, memory broken, through the newer key file's history. CHECKER: L3 now
     reaches promise 1's item clauses too; and PROVISIONAL P-VX378-U4-2 reads a library-file replay grouped with a
     memory tamper as P-U4-5's "both homes" stated limit (L4) in the tamper clause.
  5. seq 35 — promise 7 "remembers another library" after Make this my library then a complete replay: the later
     library's memory item is the later stretch's. CHECKER: the clause yields to L4.
  6. seq 40 — promise 4 on a Standard device whose words lock a login-password holder dropped (L3) with the key file
     then deleted: CHECKER: L3 keyed on the library's current key, not on the (deleted) key file.
  7. seq 59 — promise 4 after a login-password holder deleted the key file AND the memory item (its sealed copy): the
     library opens by Touch ID, no key file of the current key is left, today's secrets open nothing new. RULED LIMIT:
     the plan's §3 rule-1 row — "the 'copy-less rebuild' door is NOT built (rule 27 says the honest outcome)". Promise 4
     now requires the honest fault (`noKeyFileAnywhere`) in that state instead of the core sentence.
  8. **seq 83 — promise 4 on a LAGGING device: THE DESIGN FIND, P-VX378-U4-3 — THE STOP.** Trace (minimal, 5 steps, from
     "a synced Castle account on two Macs and the phone", Always ask): macA Use Standard → New Words → Use Castle → Use
     Standard → reset passphrase (plain confirm); macB never opened. macB's key file: the account's pair of its last
     follow (P0, W0) and a master wrap under the master of that day (M0); today's account pair is (P2, W1) over the
     master Use Castle minted (M2). The vault keeps every earlier SYNC key (rule 15), not earlier masters — so no
     secret of today opens macB's key file, typed or through the vault, and on an Always-ask device macB does not open
     with today's secrets at all (its old secrets do — nothing is lost, promise 5 holds). Rule 4's core sentence and
     rule 12's "types a secret once to catch up" both fail there. The condition is exact — both secrets changed AND a
     new master since the device last followed: with the master unchanged the vault road opens it and every promise
     holds (`U4LaggingPairScenarios.withTheMasterUnchangedTheVaultRoadOpensIt`). Closing it needs either a mechanism
     the rules don't name (the vault keeping earlier masters — "machinery to make a rule hold", which the stop rule
     sends to her) or a rule stating the limit — hers either way. Pinned as a KNOWN ISSUE
     (`U4LaggingPairScenarios.todaysSecretsOpenALaggingDevicesLibraryAfterBothChangedAndANewMaster`, `withKnownIssue` —
     green while it waits, red the day the model closes it); options in QUESTIONS P-VX378-U4-3.
  Table: none closed — the discovery seeds were not run to completion (the stop).

  **THE CENSUS (sizing, after the stop — VX-305's diagnostic, a SCRATCH worktree at `0bd112c9c` only, never committed:
  the generator patched to record every failing sequence and continue, shrinking the first two per promise; `swift test
  -c release`, one seed per call).** Seeds 21–23 × 1,000 × ≤60: **88 failing sequences in 3,000 (2.9%)** — seed 21: 29
  (44,575 steps, 255.3 s), seed 22: 31 (44,258 steps, 268.9 s), seed 23: 28 (44,721 steps, 272.8 s). By promise: 4 ×18 ·
  1 ×18 · 3 ×22 · 2 ×10 · 5 ×9 · 7 ×6 · 9 ×4 · 6 ×1. Seeds 24–40 not run (the classes repeat across the three; a full
  census on a tree with known checker gaps would be stale the moment her rulings land). **The classes, with how far each
  is known** (TRACED = replayed and read here; SHRUNK = read from the minimal sequence only, not traced):
  - **(A) P-VX378-U4-3, the lagging pair — HERS (the stop).** Most P4s: seed 21 seq 83 (TRACED) and seq 651, seed 23
    seq 86 and 143 (SHRUNK — the same pattern: both secrets changed and a Castle entry while another device lagged). It
    is reachable in TWO steps from the "lagging device" starting state.
  - **(B) the replayed library file while what this Mac remembers can't speak — P-VX378-U4-2's family** (SHRUNK: P2 ×10,
    several P3/P7 — a library-file replay grouped with a memory tamper, OR followed by a keychain wipe or a replacement
    Mac without its memory item): the app opens the older file through the newer key file's history and then holds a
    library whose key file in the live place is another key's (P2 "no key file of the current key"). Under (a) of
    P-VX378-U4-2 this is L4 and the promises it touches need L4 (checker); under (b) it is a model refusal. Hers.
  - **(C) the key file and the memory item both deleted (rule 1's row — no copy-less rebuild):** a device with no key
    file of its current key can't follow, so P3's convergence fails (seed 21 seq 633, seed 23 seq 514/578, seed 22 seq
    78 — SHRUNK). Checker, as promise 4 already reads it: exempt a device with no key file of its current key, require the
    honest fault.
  - **(D) the lobby's rule-27 refusal withheld by a memory item with no sealed copy** (P5 ×9 — SHRUNK: the key file and
    memory deleted, the next open re-writes a memory item with no mirror, a replacement Mac carries it): `LobbyRoads`
    says nothing while any memory item exists, although that item holds no key file. A small MODEL gap in rule 27's
    honest refusal (the lobby could read whether the item carries a mirror — its payload is not secret). Triage, model.
  - **(E) after a keychain wipe or a replacement Mac without its memory item, an entry into Castle leaves the Apple key
    made before it alive** (P1 — seed 21 seq 411, seed 22 seq 23, seed 23 seq 34 — SHRUNK): the new device ID's section
    lists none of the old Apple keys (P-VX378-U1-1 (a)), and the entry retires the section's keys and the outgoing file's
    wrap key only (U2 piece G); an older key that locks older backups' key files survives — rule 11's "Standard-era
    backups' quiet locks die with it" broken. MODEL gap within rule 11 — a fix (retire the Apple keys this library's own
    copies' key files name for keys its history holds) is the triage's, pinned red-first.
  - **(F) Make this my library on a SYNCED device leaves the account's sync keys on this Mac** (P1 — seed 22 seq 5,
    TRACED; seed 23 seq 122 SHRUNK, the same two steps): the new library is local (P-VX378-U2-4 (a)), yet the silent
    sync-keys item stays; the account's master opens the previous library's key files through their master wraps,
    reaching a key the new library's history carries (B2) — after Use Castle a quiet road to an earlier key (rule 9/11).
    Under U2-4 (a) the rule-16 fix is MakeMine forgetting the account's sync keys as a leave does; under (b) the new library
    stays on the account. Tied to her pending P-VX378-U2-4 — hers with it.
  - **(G) a crashed Make this my library on a synced Standard library stays in flight** (P6, seed 22 seq 499 — TRACED):
    the resume's `mintOwnAppleKey` needs decision 35's fresh vault read, the act's parameters don't mark it synced, so the
    resume never reads the vault and throws `needsFreshVault`. MODEL gap in U2's act (newly reachable — Make this my
    library joined the alphabet in U4); triage, model.
  - **(H) promise 9's Make-this-my-library posture clause after a resumed crashed act** (P9 ×4 — SHRUNK: a crashed Use
    Standard or Use Castle finishes at the launch Make this my library opens on, then the door keeps the new posture):
    CHECKER — the clause must compare with the posture at the press, not before the step.
  - **(I) not yet classified:** P7 "the sealed copy isn't the current key's file" with a replayed key file and the memory
    deleted (seed 21 seq 154/964, seed 23 seq 6/283, seed 22 seq 394), and P4 after a complete replay with secrets
    changed elsewhere (seed 22 seq 181/327). Need traces.
  None of (B)–(I) was fixed: the stop came first, and the census only sizes. The resume map after her rulings: (A) and
  (F) as she rules; (B) per P-VX378-U4-2; then the checker fixes (C, H), the model fixes (D, E, G, each pinned red-first),
  the traces of (I), the discovery re-run (seeds 21–40) and the gate soak (seeds 1–20, both configurations).
- F — the gate soak: NOT RUN (the stop). Tables: none.
- G — the closing runs, the counts, this record closed: DONE (this commit).

**The runs (exit lines, both configurations; code tree `0bd112c9c` — this commit changes only this plan):**
- The protection set, Debug (`swift test --filter 'VariorumCoreTests\.(<the 72 suites under
  Tests/VariorumCoreTests/Protection>)/'`, exit 0): `━ Test run with 278 tests in 72 suites passed after 3.839 seconds
  with 2 known issues.` (the two are the stop's pin, `withKnownIssue`; generator 16 sequences, 355 steps). Before U4
  (U3's close): `✔ 259 tests in 69 suites`.
- The protection set, Release (`swift test -c release --filter <the same>`, exit 0): `━ Test run with 255 tests in 68
  suites passed after 2.775 seconds with 2 known issues.` (the DEBUG mutation pins compile out).
- `swift build -c release` (exit 0): `Build complete! (88.75 sec)`.
- The full core suite, Debug (`swift test`, exit 0): `✔ Test run with 240 tests in 51 suites passed after 23.110
  seconds.` · `━ Test run with 3138 tests in 402 suites passed after 194.108 seconds with 2 known issues.` · `✔ Test run
  with 40 tests in 6 suites passed after 45.903 seconds.`
- The lifecycle page: rendered from the fixture, `cmp`-identical to the committed page (pieces B and B2).
- The census (scratch, release, seeds 21–23): table in piece E.
- Line counts: `Sources/VariorumCore/Protection/` 7,562 → **7,604** (B2's three files); `Tests/VariorumCoreTests/
  Protection/` 12,068 → **13,038**. The diff `e0c9f9b17..HEAD`: 21 files (+1,579 −338) — `Sources/…/Protection/` (3, her
  ruling), `Tests/…/Protection/` (14), `notes/CastleRules.md` (rules 12, 25 at the FACTS DIFF rulings; rule 17 at her
  P-VX378-U4-1 ruling), the page, this plan, `notes/QUESTIONS.md`.

**PROVISIONAL calls and her rulings** (QUESTIONS, under "VX-378 U4 THE WORLD AND THE SOAK"):
- **P-VX378-U4-1 — RULED (her words, piece B2):** Make this my library carries the key history forward; option (b) not
  chosen; the core sentence unscoped.
- **P-VX378-U4-2 — PROVISIONAL (a):** a library-file replay grouped with a memory tamper (or met by a keychain wipe) is
  P-U4-5's "both homes" stated limit (L4) — (b) a model refusal keyed on the live pair broken; (c) a stop. Census class (B).
- **P-VX378-U4-3 — OPEN, HERS — THE STOP:** the lagging pair (options (a) the vault keeps earlier masters; (c) a rule
  stating the limit; (b) listed as not reaching it).
- The ruled-limit readings applied, each with its pointer: rule 1's row (no copy-less rebuild → promise 4 requires the
  honest fault), L1–L5 in `Promises.swift`'s header (L4 = P-U4-5 + P-U4-12, her rulings carried).

**Design issues (the stop rule):** P-VX378-U4-3 stopped the unit. Nearest after it: census class (E) — after a keychain
wipe an entry into Castle leaves the old Apple key alive (rule 11 not met, a model fix exists within the rule); class (F)
— Make this my library on a synced device keeps the account's sync keys, which B2's carried history turns into a quiet
road after an entry (tied to P-VX378-U2-4); class (B) — P-VX378-U4-2's family. None was changed.

**Commits:** A `f3f24b29f` · B `a8fe1f349` · B2 `b468a306c` · C `027e80ae4` · D `2faefe2ee` · E (the stop) `0bd112c9c` ·
G (this record's close — the next commit).

### HER RULINGS AT THE U4 STOP — 2026-10-17 (the sitting over P-VX378-U4-3, P-VX378-U4-2 and the history carry; her words verbatim where quoted; U4 resumes to these)

**The verified hand-back first:** tree clean at `0e220f524`, in sync; the scope diff `e0c9f9b17..HEAD` within the allowed
paths; the protection set re-run by the orchestrator in Debug `━ 366 tests in 146 suites passed … with 2 known issues`
(the stop's pin, as recorded); rules 12, 17, 25 carried her U3-seam rulings exactly. The unit stopped where the brief
told it to.

1. **THE PROMISE SHRINKS TO THE FLOOR (closes P-VX378-U4-3 without machinery).** Her words: *"I'm not necessarily
   opposed to the idea that vault keeps master but I have noticed that a new promise is driving complexity an
   unreasonable amount. this whole thing where you can open past libraries with your current keys is a nice convenience
   but let's shrink our promise to "can always open with the keys that were their keys when you made them". and as a
   niceity we like to carry them forward."* The vault does NOT keep earlier masters. **Rule 4's promise sentence, her
   accepted wording:** *"A backup always opens with the passphrase and words you had when you made it. Because every
   key change carries the earlier keys forward, your current ones usually open it too; they won't once you make a
   different copy your library, since a new library starts with no previous keys."* (her edits: plain words, one true
   example instead of "not a promise", "no previous keys" instead of "no past"). Rule 5 drops "of its day" for the same
   words. Rule 12's catch-up: *"types a secret once to catch up, today's or the one it had when it last synced."* The
   lagging-pair pin flips from a known issue to an assertion of the floor (the lagged device opens with its last-sync
   secrets, then follows).
2. **THE HISTORY CARRY AT MAKE THIS MY LIBRARY IS REMOVED (P-VX378-U4-1 re-ruled).** Her words: *"let's remove "Make
   this my library" carrying keys. Agreed, I didn't really love it when I approved it earlier but it made sense but now
   let's just get rid of it completely for being weird."* Piece B2 (`b468a306c`) is REVERTED whole — the `carrying:`
   builder, the gathering at the door, the Apple-key records moving to the new section, its five pins, the fixture's
   stage 9/10 facts, the page's render; **rule 17 returns to its words before the carry.** A new library has a fresh key
   and no previous keys; its old backups open with the secrets they were made with (the floor). Census class (F) dies
   with it.
3. **RULE 21 REWORDED — the fingerprint, the wrapped copy, and the NOTICE instead of the refusal.** Her questions
   settled it: the Mac never holds the plain key — the memory item holds *"its ID, its device ID, a fingerprint of its
   current key, and a copy of its key file: the key itself, still wrapped under your locks"* (her: *"if it's more
   accurate to say "a fingerprint of its current key" … let's update that wording. if you want to say "it's wrapped
   key" you can also add that"*). **The refusal goes** — her words: *"we also do not need to protect them from hand
   copying an old library over - they have to just remember that at that point"*; *"I think we can have a popup that
   it's probably an issue without banning it from working"*; and the orchestrator's own finding that the refusal was a
   dead end (its two doors cannot act on a file already in the live place — U2's VX-309 hand-forward). **As ruled:**
   when the library in the live place is not the one this Mac last opened, the app OPENS it, says so ONCE — her
   accepted strings, verbatim: *"This is an older copy of your library, from <date>"* / *"This is a different library
   than the one this Mac last had open"* — and then remembers this one; posture is the ordinary follow (an old
   Standard-era file under a Castle account asks a secret to follow); sync catches it up at its next round. **The one
   case that needs a hand — the key file beside the library does not open it — is an OFFER, naming where the working
   key file was found** (her ask: *"it should say where it found it. like "in the backups from august 3rd""*): the app
   asks for a secret once, opens the candidate key files in the places it writes them (this Mac's keychain copy; each
   backup's key file in the folders of rule 19), tries each key against the library, and offers the one that works —
   *"The key file beside your library doesn't open it. This Mac's keychain holds a copy that does. Use it?"* /
   *"…The backup from August 3 holds a key file that does. Use it?"*; none → rule 27's refusal naming the places it
   looked. Nothing guessed; nothing written before her yes. **Removed with the refusal:** `Fault/DoorRefusal/
   ExecutorRefusal.libraryDisagreesWithMemory` as a REFUSAL (it becomes the notice), the `CopyDoor` offers at the
   refusal, the VX-309 hand-forward about acting on a live-place stray, and the world's promise 7 "a disagreement
   refuses, never writes" → *"a disagreement is noticed and said; nothing changes posture, account or roads silently"*
   (promise 9's kept core). The memory's "follows the file after the notice" write returns (one record write, no
   repair). P-VX378-U4-2 CLOSES as outside the promise — her words: *"someone with access to your computer can of
   course delete your library"* — the world's tamper clauses stop treating a replay-plus-memory-tamper as something
   the app must catch; stage 14 of the page is rewritten to the notice and the offer.
4. **A standing principle, her words (2026-10-16):** *"I think that this fits my instincts of not wanting to have to
   tell users any sort of weird exception."* — and on the floor: the promise is the floor; carrying keys forward is
   what the app does, said as a convenience with its one true example.

**Rules edits this resumption makes at her word (and no others):** 4, 5, 12 (the floor); 17 (the carry's words
removed); 21 (the fingerprint + wrapped copy; the notice; the offer). The status line of `CastleRules.md` names today's
amendments. The lifecycle page's stages 9, 10, 14 follow through the fixture.

### U4 RESUMPTION RECORD — the carry reverted, the floor, rule 21's notice and offer, the census, the soaks (Opus implementer, 2026-10-17; IN PROGRESS)

**Not done yet, first:** everything below is PENDING until its piece flips; the counts are PENDING until a run lands them.

**Start:** tree `8d044191e` (clean, in sync). Before this session: the protection set Debug `━ 278 tests in 72 suites …
2 known issues`, `-c release` `━ 255 in 68 … 2 known issues` (the stopped U4's close, code tree `0bd112c9c`).

**Pieces (the resume map — a fresh session can finish the resumption from this list and `git log`):**
- 1 — THE CARRY REVERTED (her item 2): DONE (this commit). `git revert --no-commit b468a306c` (the plan and QUESTIONS
  hunks kept as records — the plan's B2 record is history): `KeyFile.building(…, carrying:)` gone, `ActContext.carriedKeys`
  and the gathering at the door gone, the previous section's Apple-key records no longer move into the new section,
  `U4MakeMineHistoryTests` deleted (its five tests) except the guard her ruling kept —
  `theDoorAlwaysVerifiesTheCurrentPairAndOffersNoChoice` moved into `U2MakeMineTests` (green both sides: the posture of
  now, no choice, the current pair always typed); `U2MakeMineTests`' "no past" assertion back; the fixture's stage 9/10
  carry text, hidden roads and facts back to their pre-carry state (and `LifecycleChecks`' `makeMine` back to "no
  past"); rule 17 back to its words before the carry (`notes/CastleRules.md` byte-equal to `a8fe1f349`'s rule 17); the
  page re-rendered (`CASTLE_LIFECYCLE_PAGE_OUT=… swift test --filter LifecyclePageTests`) — `cmp`-IDENTICAL to the
  committed (reverted) page. **Turned with it:** promise 4 judges copies of THIS library only (`image.libraryID ==
  record.libraryID` — the pre-carry scoping; piece 2 rewrites it to the floor); the fixed scenario
  `makeThisMyLibraryThenUseCastleRetiresThePreviousLibrarysAppleKey` (piece D — it asserted the carried Apple-key
  records) → `makeThisMyLibraryThenUseCastleKeepsEveryPromise` (the new library enters Castle, every promise kept); the
  mutation-pin comment's pointer to it dropped. **New pin (red-on-old):**
  `U2MakeMineTests.theNewLibraryStartsWithNoPreviousKeysAndAnOldBackupOpensWithItsOwnSecrets` — on the pre-piece tree
  (scratch worktree at `97b1927ea`, the test file copied in): `✘ … 6 tests in 1 suite failed … with 3 issues` —
  `U2CopyDoorTests.swift:113` (the restored "no past" assertion), `:210` (the new key file carries history), `:217`
  (today's passphrase reached the previous library's backup through the carried history); green after (`✔ 6 tests in 1
  suite`). The crash harness over `.makeMine` (`U2MakeMineTests.aCrashAfterEveryWriteFinishesOrNeverHappened`) green.
  QUESTIONS P-VX378-U4-1 → RE-RULED with her words. **Census class (F) dies here** (the carried history it turned into
  a quiet road is gone; the account-sync-keys residue on a Make-this-my-library'd synced device is P-VX378-U2-4's, hers
  with VX-309). Protection set Debug `━ 275 tests in 71 suites passed … with 2 known issues` (the stopped U4's lagging
  pin, piece 2's to flip).
- 2 — THE FLOOR (her item 1): DONE (this commit). **Her final rule-4 wording** (relayed by the coordinator mid-session,
  2026-10-17, superseding the version §8's ruling block quotes): *"A backup always opens with the passphrase and words
  you had when you made it. Every key change also carries the earlier keys forward, so your current ones open older
  backups of the same library."* — her words on it: *"yeah I like that better. of the same library makes it clear
  without making it seem like an exception. i prefer that wording."* **Rules** (`notes/CastleRules.md`): rule 4's promise
  sentence ("So your current passphrase or words open every backup you have ever made.") replaced by her two sentences,
  the rest of rule 4 untouched (its bold "every key change carries that list forward — no exceptions" now stands beside
  her "Every key change also carries…" — a near-repeat left as she worded it, for her eye); rule 5 → *"A backup is the
  library plus its key file. It opens with the passphrase and words you had when you made it, with your current secrets
  through rule 4, or — while the backup's key is still the live key — through this Mac's quiet roads."* (only the two
  "of its day" phrases replaced, by her "same words" — my rendering, for her eye); rule 12's last sentence gains *",
  today's or the one it had when it last synced."*; the status line names the U4-stop amendments (4, 5, 12, 17 — 21
  joins at piece 3) and the U3-seam FACTS DIFF ones (12, 25), which it hadn't named. **Promise 4 rewritten to the floor**
  (`Promises.swift` `coreSentence`, three clauses): (a) THE FLOOR — every copy this Mac made opens, typed, through its own
  key file, with the pair she had when she made it (the world records it at the write — `CopyTruth.madeWith…` via
  `recordMadeWith`: a secret chosen at the act now running, then her current pair for the copy's holder or this device's
  last holder, then each earlier pair, newest first; none opening → a write-time violation `madeWithNothing`; L3 exempt);
  (b) CAUGHT UP — a library of its own, or a synced one whose record follows the account's current sync key and posture,
  opens with her current passphrase or words (typed, or through the vault they open); (c) THE CARRY — where her current
  secrets open the library or its sealed copy, they reach every copy of THE SAME LIBRARY this Mac made (never across a new
  library). The rule-1-row clause (no key file of the current key → the honest fault) kept. **The world:** the lobby's
  "she" types today's pair first and, when it opens nothing, the pair she had before, newest first (rule 12's "or the one
  it had when it last synced" — `launch`); Look inside `.itsDay` types the copy's made-with pair, and refusing it while
  that pair reaches the copy is a promise-4 door refusal. **The lagging pin flipped:** `U4LaggingPairScenarios
  .aLaggingDeviceOpensWithItsLastSyncSecretsThenCatchesUpWithOneSecret` (no `withKnownIssue`) — today's secrets open
  nothing on the lagged Always-ask device (typed or through the vault, which keeps no earlier master), its last-sync
  passphrase and words each open it, it opens, owes the follow, follows typing ONE secret (today's), and is then in the
  account's posture on its current sync key, today's passphrase opening it, the lagged key carried in its history, every
  promise kept. **Evidence:** the model is unchanged by this piece (a promise rewrite); on the pre-piece tree (scratch at
  `1f74825b6`, the scenario file copied in) the flipped pin is red at the world's typing and the old promise — `✘ … 7
  issues` at `U4LaggingPairScenarios.swift:47` (the launch, which never typed the last-sync pair), `:48`, `:51`, `:52`,
  `:54`, `:55`, `:59` (the old promise 4 firing on the lag) — while its model assertions (`:39`–`:43`: today's open
  nothing, the last-sync pair opens) are green on both sides. Each new clause catches its breach planted by hand
  (`U4PromiseCheckTests`): `theFloorCatchesACopyThatNoLongerOpensWithTheSecretsItWasMadeWith` (4a),
  `caughtUpCatchesALibraryTodaysSecretsDontOpen` (4b), `theCoreSentenceCatchesADroppedHistory` (4c, kept). One finding
  while landing it: the write-time floor check first fired on a Standard library whose words lock a login-password holder
  dropped (generator seed 2 seq 7) — L3, exempted. The fixture's two `LDay` doc lines quote the new rule 4; the page
  re-rendered `cmp`-IDENTICAL. QUESTIONS: P-VX378-U4-3 → RULED (the floor; (a)/(b)/(c) NOT chosen; her final wording);
  **P-VX378-U4-4 PROVISIONAL (a)** — rule 12's catch-up on an Always-ask device is two moments (open with the last-sync
  pair, follow with today's one secret), and "the passphrase and words you had when you made it" on a synced device whose
  locks hadn't followed a key door elsewhere is the pair its library opened with then. **Census class (A) closed** (the
  floor). Protection set Debug `✔ 277 tests in 71 suites passed` (no known issue left).
- 3 — RULE 21: THE NOTICE AND THE OFFER (her item 3): DONE (this commit).
  - **(a) Rule 21's words** (`notes/CastleRules.md`, the only rule touched in this piece): the four things are *"its
    ID, its device ID, a fingerprint of its current key, and a copy of its key file: the key itself, still wrapped under
    your locks"*; the refusal replaced by the notice (her two strings) and the key-file offer (her backup sentence as
    the example); the parenthetical now says a hand-restored pair opens with the notice, the Restore door still the
    honest road; the status line names rule 21's amendment.
  - **(b) The notice** (`Assess/LibraryNotice.swift`, `git mv` of `LibraryDisagreement.swift`): `LibraryNotice` {`kind`:
    `.olderCopy(date:)` · `.differentLibrary`; her strings verbatim as `olderCopyWords` / `differentLibraryWords`;
    `sentence(date:)` writes the date in}; one pure `check`. `unlock` OPENS and carries it (`UnlockedLibrary.notice`) —
    writing nothing itself; what the memory item NAMES is read from its payload when its seal can't be verified with the
    keys in reach (P-VX378-U4-5 (c)); a library that moved on past the memory (its own key file's history holds the
    remembered key) says nothing (P-VX378-U4-5 (a)); the date is the record's (U4-5 (b)). `assess` reports
    `Fault.libraryNotice` (renamed from the refusal's fault) until the memory follows, closes no door, owes no act for
    it; `refreshMemory`'s FINGERPRINT ARM IS BACK (the memory follows the record — one write, no repair), and a refresh
    forgets every other library's item (this Mac remembers ONE library — so after a different library, the original one
    returning is itself a different library: a fresh device ID, P-VX378-U1-1 (a)'s road).
  - **(c) The offer** (`Executor/Acts/KeyFileOffer.swift`): `KeyFileOffer` {`source`: `.thisMacsKeychain` ·
    `.backup(keyFileID:date:)`; her sentences verbatim — `besideDoesNotOpenIt` + `keychainHoldsOne` / `backupHoldsOne`;
    `sentence(date:)`}; `searchKeyFiles(_:catalog:typed:)` READS ONLY — candidates this Mac's keychain copy then every
    catalogued key file outside the live place, newest first; each yields the keys it can (the key in hand when the file
    names it, the typed secret, its own quiet road — a silent custody item for its key, its Apple wrap readable here);
    each key TRIED against the library file (`libraryOpens`); the first that opens it is offered; none → `.besideOpensIt
    OnlyThroughItsHistory` when the stray reaches the library through its history (P-VX378-U4-6 (a)), else
    `.noKeyFileAnywhere` (rule 27, its three homes named). `useOfferedKeyFile` — the act `.useKeyFile` (a new
    `ProtectionAct`, raw `use_key_file`) on a plan: `keyFile` (the offered file beside the library — only the library's
    own; idempotent) then `memory`; the file rides the plan (`ActParameters.offeredKeyFile` — a key file holds no
    secret). `assess` owes `OwedAct.offerKeyFile` when the key file beside isn't the library's own (another key's; or
    none the sealed copy can write back) and a home holds the library's own; with none and the stray reaching nothing,
    `Fault.noKeyFileAnywhere` (P-VX378-U4-6 (b) — an absent key file a backup holds is offered, not restored).
  - **(d) The refusal road deleted:** `ExecutorRefusal.libraryDisagreesWithMemory`, `DoorRefusal.libraryDisagreesWith
    Memory`, `Fault.libraryDisagreesWithMemory`, `LibraryDisagreement` (+ `.offers`, its findings), `CopyDoor`,
    `AssessRules.disagreement`, `assess`'s every-door-closed early return. Tests that died with it:
    `U2PinsRule21Tests.aReplayedLibraryFileIsRefused` · `aReplayedKeyFileIsRefused` ·
    `anotherLibraryInTheLivePlaceIsRefused` · `assessReportsItAndOpensNoDoor` (each red on this tree — the ruling
    reversed them; the suite keeps its absence, stranded-act and four-things pins).
  - **(e) The world:** promise 7 → *"FOUR THINGS; A DISAGREEMENT IS NOTICED AND SAID"* — the launch's oracle
    (`expectedNotice`, read from the device's own items and files) must equal the open's notice kind (and its date), and
    the open itself writes nothing (`noticeMismatches`, replacing `refusals`); promise 9's tamper clause and the
    silent-change check pass a step whose open said the notice (it said what it took); the L4 replay-plus-memory clause
    kept as OUTSIDE the promise (P-VX378-U4-2 CLOSED). The world's lobby walks this Mac's keychain copy too (rule 1's
    third home); the alphabet gains `.useKeyFileOffer` (weight 2) and the settle says yes to an owed offer before
    following; promise 4's rule-1-row clause requires the offer when a backup holds the library's own key file, rule 27
    only when nothing does. `U4PromiseCheckTests.fourThingsCatchesAWrongNoticeAndAForeignMemory` replaces the refusal
    oracle's test.
  - **(f) The lifecycle:** stage 14 rewritten in the FIXTURE (her ruling — the stage's two notices and the offer, her
    strings): `LFact.noticesWhatItDoesntRemember(LStray)` (renamed from `refusesWhatItDoesntRemember`) and the new
    `.offersTheKeyFileThatOpensIt`; a new row "The key file doesn't open it?"; the rule-27 sentence a branch proven by
    `U4KeyFileOfferTests.withNoKeyFileAnywhereTheSearchSaysRule27`. The walk: the live key file's loss first (so the
    different library's memory change can't reach that fact), then each stray opened (today's pair, else an earlier
    one), the notice read, the stray left as found (its key, identity, posture and her locks — an act its record carried
    may finish, rule 20, and rule 8 may re-make the quiet Apple road), the memory followed, the second open silent, put
    back; then an old key file beside the library → the keychain copy offered in her words, the search writing nothing,
    her yes putting it beside the library. The page re-rendered from the fixture, `cmp`-IDENTICAL (stage 14's rows only).
    Lifecycle suites green in all four walks.
  - **Pins (red-on-old):** `U4NoticeTests` (8) — the five behaviour pins read the notice by reflection and run on the
    pre-piece tree (scratch at `a407e130e`, those five copied in): `✘ … 5 tests in 1 suite failed … with 5 issues` — four
    REFUSED (`U4NoticeTests.swift:35`, `:75`, `:92`, `:109`: `.libraryDisagreesWithMemory`), and
    `aBackupPairCopiedInByHandOpensAndSaysItIsAnOlderCopy` at `:68` OPENED SILENTLY (the old tree verified the memory
    item or treated it as absent — on an Always-ask Mac a hand-restored pair said nothing); the three others (her words,
    the date, `assess`) new API, red by construction. `U4KeyFileOfferTests` (6) — new API (red by construction): the
    keychain copy offered and her yes, a backup's day named, rule 27 with nothing anywhere, the history-only split pair
    (U4-6), `assess` owing the offer (and rule 27 without a home), and a hand-written crash loop over her yes (every
    write: finished or never happened, nothing in flight — `CrashHarness`'s settled-state check assumes the key file
    beside is the library's own, which this act's "never happened" side is not).
  - **Withdrawn:** the U2 record's VX-309 hand-forward ("rule 21's two doors on the LIVE PLACE's stray") — the doors are no
    longer offered there (her ruling).
  - QUESTIONS: P-VX378-U4-2 → CLOSED (her words); **P-VX378-U4-5** and **P-VX378-U4-6** PROVISIONAL (a). **Census class
    (B) closed here** (the L4 clause is outside the promise; the refusal it fought is gone). Protection set Debug `✔ 287
    tests in 73 suites passed` (generator 16 sequences).
- 4 — THE CENSUS CLASSES (B)–(I) re-read under the rulings: DONE (this commit closes it). **The dispositions:** (A)
  CLOSED by piece 2 (the floor); (B) CLOSED by piece 3 (P-VX378-U4-2 outside the promise) and its consequence, the
  split pair, read as L6 (P-VX378-U4-6); (C) CLOSED — CHECKER: folded into rule 21's offer (a backup's key file is
  offered) and, with no key file anywhere, promise 3 no longer asks a device that can't re-key to converge while the
  open says rule 27 (promise 4 holds it to that); (D) FIXED — MODEL, two roads (a memory item carrying no copy;
  another library's key files), each pinned; (E) FIXED — MODEL, pinned; (F) DIED with piece 1; (G) FIXED — MODEL,
  pinned; (H) FIXED — CHECKER; (I) TRACED and classified — its first shape (the sealed copy not the current key's
  after a replayed key file and the memory deleted) is class (K), FIXED — MODEL, pinned, plus rule 21's offer; its
  second (P4 after a complete replay with secrets changed elsewhere) is L4/L6 — CHECKER; its third (the Always-ask
  device opened offline, census seed 21 seq 912/913) is WORLD. **New classes the census found, each a MODEL fix pinned
  red-first:** (J) a roll back leaves the sync keys the act took (two roads); (K) the sealed copy follows the key file
  once it is back; (L) entering Castle deletes a silent sync-keys item for an account the library doesn't name; (M) a
  resumed follow into a posture the account no longer has rolls back. **The census at the end** (scratch, release, tree
  `b6d2456be`, one seed per call): seeds 21–28, 31, 33, 35–40 — 0 failing each (the per-seed table below); seeds 29,
  30, 32, 34 last censused clean on `f6926a8e3`–`b1cfcee89` (the formal discovery re-runs every seed on the final
  tree). Earlier in the piece: A fresh census of seed 21 on the piece-3
  tree (scratch worktree at `3cdca77cd`, the census patch never committed; `-c release`): **35 failing in 1,000
  sequences (44,710 steps, 311.9 s)** — P2 ×19 · P9 ×5 · P3 ×3 · P5 ×3 · P1 ×2 · P4 ×2 · P6 ×1. Read against the old
  classes: (A) gone (piece 2); (B) gone as a refusal and back as its consequence — the SPLIT PAIR (P2 ×19: an older
  library file replayed beside today's key file opens through its history and can't take Standard's Apple road); (F)
  gone (piece 1); (C) folded into rule 21's offer; (D), (E), (G) reproduced; (H) reproduced; new — P3/P4 on a library
  put in the live place from outside, and P9's account change by a same-key replay. **Done in this commit:**
  - **(G) MODEL — FIXED** (`Executor/Acts/Copies.swift`): a resume of Make this my library holds no copy key, so before
    the copy is staged under the new key it rolls back at its FIRST step (`MakeMineProgram.beforeTheStage`) — it used to
    run the steps before the stage and stop at the own Apple key's fresh-vault check (decision 35; the act isn't marked
    synced, so the resume reads no vault), leaving the act in flight. Pin `U4CensusPins
    .aCrashedMakeThisMyLibraryOnASyncedLibraryNeverStaysInFlight` (a synced Standard library, a crash after each of
    writes 1–12, then the next open): red before the fix — crashes after writes 3–10 left the act in flight ("couldn't
    settle now (needsFreshVault)", promise 6) — green after; `U2MakeMineTests` (its crash harness included) green.
  - **(E) MODEL — FIXED** (`Executor/Acts/CommonSteps.swift` `retireOwnAppleKeys`): entering Castle (Use Castle, a
    follow or a join into Castle) also retires every Apple key an EARLIER section of this library's own record lists
    unretired — this Mac's under a device ID it no longer remembers (a keychain wipe, a new Mac without its memory item,
    a library it left and came back to); only sections that verify with this library's own keys count (another Mac's
    library seals its sections under its own keys). Rule 11's own words: "your Standard-era backups' quiet locks die with
    it". Pin `U4CensusPins.enteringCastleAfterAKeychainWipeRetiresTheAppleKeysMadeBeforeIt` (census seed 21 seq 756,
    replayed step for step): red before — promise 1 "a quiet road reaches an earlier key" and "opens the copy" (the
    pre-wipe Apple key locking the first backup's key file), the key not recorded retired — green after.
  - **(D) MODEL — FIXED** (`Assess/Facts.swift`, `Assess/Assess.swift` `lobby`): `ProtectionFacts
    .rememberedKeyFileCopies` (the copies the memory items carry, read as the items state them; nil = not read, the old
    reading); rule 27's lobby refusal no longer waits on a memory item that carries NO copy (it opens nothing). Pin
    `U4CensusPins.aMemoryItemWithNoKeyFileCopyDoesntSilenceRule27` (census seed 21 seq 789): red before — promise 5 "the
    library in the live place opens by no road, and the lobby doesn't say so" — green after.
  - **(H) CHECKER — FIXED** (`Promises.swift` promise 9): Make this my library's posture clause compares with the posture
    AT THE PRESS (`truth.makeMinePressMode`, recorded inside the act after the open settled a crashed crossing), not the
    one before the step (census seq 22, 219, 509).
  - **L6 CHECKER — a library put in the live place from outside** (`truth.liveFromOutside`, set by a replayed library
    file and by any open that said rule 21's notice; `fromOutside`, `splitPair`): promise 2 skips a SPLIT PAIR (no Apple
    road can be re-made into a key file of another key — P-VX378-U4-6 (a)); promise 3 lets that copy hold the account's
    keys in its own posture until it follows, and doesn't ask a split pair (which can't follow) to converge; promise 4's
    caught-up clause reads the floor for it (it opens with the secrets it was made with); promise 9's tamper clause
    treats ANY library-file replay as the copy's own day — the notice is promise 7's to judge, and a same-key replay is
    one rule 21's four things can't tell (**P-VX378-U4-7**, PROVISIONAL). Her words for the frame: "they have to just
    remember that at that point"; P-VX378-U4-2's closure.
  **The census re-run on that tree (`f04d0ef19`, seed 21, release): 7 failing in 1,000 (44,818 steps, 292.0 s)** — P2
  ×4 · P3 ×2 · P1 ×1 — each traced (a throwaway replay test, deleted) and closed in the next commit:
  - seq 424 · 603 · 882 · 590 (P2) — CHECKER: a library put in the live place from outside with NO key file of its own
    anywhere (the key file beside deleted, or another library's after Make this my library; the copy's key reachable
    only through a newer key file's history): L6's split pair widened to "the live place lacks the library's own key
    file" (`splitPair`).
  - seq 281 (P3) — CHECKER: `replayBothHomes` now marks L6 too (the library file comes from outside with the memory).
  - seq 763 (P1) — CHECKER (one posture per account): a crashed Use Standard's vault write landed, then a Time Machine
    restore put the library back in Castle — the account is Standard, the device owes its quiet follow out, and promise
    1 no longer binds a device whose account has left Castle (rule 12: "Your text, the server's rows, the sync key and
    every backup you have ever made are Standard from now on").
  - seq 912 (P3, the old class (I)) — WORLD: an Always-ask device opened while its vault was out of reach holds no sync
    key (the secret typed at the unlock is never kept); at the settle, online and in step, the app asks again and she
    types it (`settleWorld` re-opens it).
  Protection set Debug `✔ 290 tests in 74 suites passed`.
  **Census on `594c3ac52`: seed 21 — 0 failing in 1,000 (44,768 steps, 255.2 s); seed 22 — 5 failing (44,963 steps,
  301.0 s): P4 ×3 · P1 ×2.** Traced and closed in the next commit:
  - seq 460 (P1) — **NEW CLASS (J), MODEL — FIXED** (`Executor/PlanRunner.swift` `rollBack`): a join that crosses
    postures picks up the account's sync keys at its first step; rolled back before its swap it left them — a silent
    sync-keys item for an account the library isn't bound to (a third state, rule 20; here a quiet road to the master
    on a Castle library). The rollback now deletes every sync-keys item (and the session's keys) for an account the
    library doesn't name. Pin `U4CensusPins.aRolledBackJoinLeavesNoSyncKeysBehind` (census seq 460 replayed): red
    before — the item survived, promise 1 "a quiet road reaches the current key" — green after.
  - seq 588 · 750 · 953 (P4 (c)) — CHECKER (L6/L4): a replay of the key file (alone, in a group, or with both homes)
    leaves copies made in the replaced stretch under keys the key file now beside the library doesn't carry; those are
    that stretch's (`noteAbandonedStretch` adds them to `rolledBackOver`, as L4's restore does) — the carry is never
    promised across a replay.
  - seq 691 (P1) — CHECKER (L6): an old Castle copy put back (both homes) over a later Standard stretch — the stepped-
    aside library's Standard key (its silent item) reaches the Castle-era key through its own key file's history; a later
    leave handed that key out (rule 12) and putting the copy back doesn't take it in again — promise 1 doesn't bind a
    library put in the live place from outside.
  **Census on `159da7b83`: seed 22 — 1 failing (44,843 steps, 264.0 s):**
  - seq 998 (P5) — **CLASS (D)'s second road, MODEL — FIXED** (`Assess/Assess.swift` `lobby`): before the open, a key
    file of ANOTHER library (the other Mac's backups in a shared iCloud Drive folder) can't open the library this Mac
    remembers, so it no longer silences rule 27's honest refusal (with nothing remembered, any key file still might).
    Pin `U4CensusPins.anotherLibrarysKeyFilesDontSilenceRule27` (census seq 998 replayed): red before — promise 5 —
    green after. (A reading, recorded: "every key-file copy … gone" is this library's copies.)
  **Census on `65d483c2e`: seed 23 — 5 failing (45,213 steps, 303.1 s): P4 ×4 · P7 ×1.** Traced (throwaway replays,
  deleted) and closed in the next commit:
  - seq 974 (P7) — **NEW CLASS (K), MODEL — FIXED** (`Assess/Assess.swift`): a memory item re-made with NO copy (its
    key file was gone at that open) never took the copy back once the key file of the current key returned (a Time
    Machine restore) — the refresh is now owed whenever the sealed copy is missing or another key's while the live
    key file is the current key's (rule 1). Pin `U4CensusPins.theMemorysCopyFollowsTheKeyFileOnceItIsBack` (census
    seq 974 replayed): red before — promise 7 "the sealed copy isn't the current key's file" — green after;
    `AssessTests.whatThisMacRemembersIsRefreshedWhenItIsMissingOrNamesAnotherDevice` now gives its agreeing memory the
    copy and asserts the copy-less item is refreshed.
  - seq 189 · 623 (P4 (b)) — CHECKER (L6, P-VX378-U4-7's family): a key file of the SAME key replayed from an earlier
    day (its locks of that day) is undetectable by rule 21's four things, and the refresh then makes the sealed copy
    follow it — the library opens with the secrets of that day (the floor). `replayKeyFile` of the same key marks L6.
  - seq 89 · 712 (P4 (c)) — CHECKER (L6): under a library put back from outside, a copy the key file there doesn't
    carry (an older key file put beside it later by the offer, say) is the replaced stretch's, for good — promise 4's
    carry clause adds it to `rolledBackOver` when it meets it.
  **Census on `3f5df168a`: seed 24 — 3 failing (44,595 steps, 265.8 s): P3 ×2 · P4 ×1.** Closed in the next commit:
  - seq 107 · 597 (P3) — CHECKER (L6): a Time Machine restore across Use Castle put the Standard-era library back (L4);
    `timeMachineRollback` and the hand restore (`deleteContainerAndOpenOldCopy`) now mark L6 too, so the copy holds the
    account's Castle keys in its own posture until it follows.
  - seq 913 (P4 (b)) — CHECKER (the floor): the key file and the keychain copy deleted after two key doors; the offer
    finds Use Castle's closing backup's key file — the CURRENT key, under the locks of that backup's day — and her yes
    puts it beside the library: it opens with the secrets she had then, not today's. `truth.keyFileFromBackup` exempts
    the caught-up clause while that key file stands unchanged. (A face consequence for VX-306, added to P-VX378-U4-6:
    the offer's words don't say the found file may want an earlier passphrase.)
  **Census on `5c992b949`: seed 25 — 2 failing (44,434 steps, 255.6 s): P1 · P5.** Closed in the next commit, both
  CHECKER:
  - seq 367 (P1): another library's key file replayed beside the library (the library this Mac made its own before)
    named keys this library never had — promise 1's "keys the library has had" now reads the key file beside it only
    when it is THIS library's.
  - seq 555 (P5): before the open, with NOTHING remembered (a keychain wipe), another library's key files in a shared
    iCloud Drive folder might be the live library's own — the lobby can't tell which library is in the slot, so rule
    27's refusal isn't owed there (it stays owed whenever the lobby can tell — class (D)'s two fixes).
  **Census on `80ebce0f4`: seed 26 — 2 failing (45,155 steps, 259.7 s): P5 ×2.** Closed in the next commit, CHECKER:
  seq 511 · 521 — a Standard library with no passphrase whose only typed lock a login-password holder dropped (L3, rule
  3: they hold the key), then a new Mac or a wiped keychain took its quiet roads: no road is left, and that is the
  tamper's — promise 5 now reads L3 for the library in the live place and for its copies.
  **Census on `82b3dbebd`: seed 27 — 3 failing (44,349 steps, 275.7 s): P4 ×2 · P9.** Closed in the next commit,
  CHECKER:
  - seq 263 · 310 (P4 (c)): a replayed library file, then the offer put its own older key file beside it, and a key
    change later ended L6 — the replaced stretch's copies were noted only while today's secrets opened the library; the
    noting now runs whenever L6/L4 holds, before that gate.
  - seq 980 (P9): a memory item replayed ALONE names this Mac's earlier device ID, whose section (its gate of that day)
    the open then reads — the same replay class as a library file's (rule 21 keys on the library; an item older than the
    library "moved on", P-VX378-U4-5): the tamper clause reads any replay of this Mac's homes as outside the promise
    (P-VX378-U4-7's family, noted there).
  **Census on `f6926a8e3`: seeds 28 · 29 · 30 — 0 failing each (45,147 / 44,411 / 45,437 steps; 257.0 / 247.4 / 254.0
  s); seed 31 — 2 failing (45,108 steps, 287.2 s): P1 · P4.** Closed in the next commit:
  - seq 572 (P1) — **NEW CLASS (L), MODEL — FIXED** (`Executor/Acts/CommonSteps.swift` `retireOldCustody`): a join a
    Time Machine restore took back left a SILENT sync-keys item for an account the library no longer names (the keychain
    isn't restored) — the account's master, a quiet road to every key file wrapped under it (the join's backup among
    them); entering Castle now deletes such an item (rule 11's "the Apple and on-device keychain items deleted"; the
    bound account's keys stay the act's to file the Castle way). Pin `U4CensusPins
    .enteringCastleDeletesASilentSyncKeysItemForAnAccountTheLibraryDoesntName` (census seq 572 replayed): red before —
    promise 1 "a quiet road reaches an earlier key" ×3 — green after.
  - seq 415 (P4 (c)) — CHECKER (L6): the carry isn't asked while a replay stands (only the floor is); the replaced
    stretch's copies are noted against the key file a later key change carries forward (the live one, else the sealed
    copy) rather than the union of both.
  **Census on `74d24b4f8`: seed 32 — 0 failing (44,726 steps, 247.6 s); seed 33 — 2 failing (44,838 steps, 255.7 s):
  P3 · P4.** Closed in the next commit:
  - seq 230 (P3) — **NEW CLASS (M), MODEL — FIXED** (`Executor/Acts/Follow.swift`): a follow OUT of Castle crashed,
    the account went back INTO Castle elsewhere (a new sync key), and the follow's resume finished the follow out — the
    library Standard under a Castle account, holding the key Castle rows are written under (one posture broken; rule 20's
    "old state or new" broken too: neither the account's old posture nor its new one). A resumed follow whose account is
    no longer in the posture it follows into rolls back before its swap; the follow now owed runs instead. Pin
    `U4CensusPins.aResumedFollowOutRollsBackWhenTheAccountWentBackIntoCastle` (census seq 230 replayed): red before —
    the library Standard, promise 3 — green after; `FollowTests`, `U2CrashHarnessTests` green.
  - seq 315 (P4 (c)) — CHECKER (L6): the offer put an older key file beside a replayed library inside the settle, and a
    follow then ended L6 before any check noted the replaced stretch's copies — the world's offer action now notes them
    the moment the older key file goes beside the library.
  **Census on `b1cfcee89`: seed 34 — 0 failing (44,879 steps, 255.1 s); seed 35 — 1 failing (45,493 steps, 264.9 s):
  P3.** Closed in the next commit:
  - seq 513 (P3) — **CLASS (J)'s second road, MODEL — FIXED** (`Executor/PlanRunner.swift` `rollBack`, which now takes
    the plan's parameters): Use Castle's one vault write landed, the act rolled back before its swap (signed out, the
    resume couldn't reach the vault), and this Mac kept the account's NEW sync keys the act had taken — a device back in
    Standard holding the key Castle rows are written under (rule 15: "a device that has not followed cannot sync until it
    does"). The roll back lets go of exactly what the act took: a silent item or the session holding the taken key (read
    — they open without a press), a Touch ID sync-keys item while the library is back in Standard (Standard files them
    silently). The follow, typing a secret, picks the keys up. Pin `U4CensusPins
    .aRolledBackUseCastleLetsGoOfTheSyncKeysItTook` (census seq 513 replayed): red before — promise 3 — green after.
  **The census on `b6d2456be` (release, scratch; steps · seconds):** 21 — 0 (44,768 · 244.3) · 22 — 0 (44,838 · 249.5)
  · 23 — 0 (45,219 · 248.0) · 24 — 0 (44,688 · 246.4) · 25 — 0 (44,369 · 239.1) · 26 — 0 (45,226 · 253.1) · 27 — 0
  (44,410 · 244.9) · 28 — 0 (45,147 · 258.5) · 31 — 0 (45,186 · 253.8) · 33 — 0 (44,878 · 246.4) · 35 — 0 (45,494 ·
  266.4) · 36 — 0 (45,124 · 249.3) · 37 — 0 (45,386 · 252.9) · 38 — 0 (45,220 · 241.6) · 39 — 0 (44,830 · 244.7) · 40
  — 0 (44,511 · 249.6). The census patch is never committed (the scratch worktree only).
  **Class (C)'s checker line** lands with this record's close: promise 3's settled convergence skips a device whose
  live place lacks its current key's file while the open says rule 27. Protection set Debug `✔ 296 tests in 74 suites
  passed`.
- 5 — THE DISCOVERY RUN (seeds 21–40) and THE GATE SOAK (seeds 1–20, Debug and Release): IN-PROGRESS on the FINAL
  tree **`bec58a576`** (`PROTECTION_SOAK=1 PROTECTION_SEED=n PROTECTION_SOAK_SEEDS=1 PROTECTION_SOAK_SEQUENCES=1000`,
  `swift test --filter 'VariorumCoreTests\.GeneratorTests/'`, one seed per call; the `-c release` protection set on
  this tree `✔ 273 tests in 70 suites passed`; `swift build -c release` `Build complete! (81.66 sec)`).
  **THE DISCOVERY RUN (Debug; seed · steps · seconds · exit):**
  | seed | steps | Debug s | result |
  |---|---|---|---|
  | 21 | 44,768 | 352.1 | `✔ Test run with 1 test in 1 suite passed after 352.065 seconds.` |
  | 22 | 44,838 | 355.1 | `✔ Test run with 1 test in 1 suite passed after 355.070 seconds.` |
  (the rest PENDING — landing as they complete)
  **THE GATE SOAK:** NOT-STARTED (after a green discovery run).
- 6 — the closing runs, counts, this record closed: NOT-STARTED.

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
