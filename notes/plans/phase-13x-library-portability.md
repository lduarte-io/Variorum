# Phase 13x — Library portability

**Ticket: VX-6 · Project: 13x — Library portability · Branch: `vx-6-13x-library-portability` · Worktree: `~/dev/variorum-13x` (the Pro)**

*(This file holds the KICKOFF; the execution plan lands here after the kickoff's design look,
authored by this phase's orchestrator. Written 2026-10-06 at the workflow transition.)*

## KICKOFF MESSAGE (the author launches a fresh orchestrator with `/architect-phase 13x`)

You are the orchestrator for **Phase 13x — LIBRARY PORTABILITY**: the AirDrop-your-library
promise made true by built doors. Her kickoff framing (2026-10-06): *"make airdropping a corpus
easy and opening a previous library backup easy (there's probably significant overlap there)."*

**The workflow is new — read it first.** PREFLIGHT, complete and never delegated: CLAUDE.md +
its auto-loaded canon · **`notes/plans/workflow-transition-2026-10-06.md`** · the master plan's
IN-FLIGHT table · `~/dev/variorum/notes/TICKETS.md` (main's copy) · `notes/QUESTIONS.md` ·
`notes/SessionResiliencyProtocol.md` — **and, because this phase IS custody work:
`notes/SyncSpec.md` IN FULL and `notes/sync-postmortem-fragments.md` before any `Sync/` line.**
Work in THIS worktree on THIS branch; one PR titled `VX-6: …`, merge commit, at closeout.
Linear: VX-6 In Progress at kickoff → In Review → Done at merge.

**THE SPEC is `notes/FuturePhases.md`'s 13x row, read WHOLE**, plus the built substrate it rides:
13p's keyed `openStore(at:)`, the ciphertext backups, and the drill-proven key legs (passphrase ·
recovery phrase · escrow); the adoption door's shape lives on pre-13x's roads
(`notes/plans/pre-13x-postures-design.md` + its design-history/review files). Deliverables the
row names: the hand-off act, the adoption door, the same-Mac older-key restore, the three held
FAQ entries publish. Project ticket **VX-64** (vault-bootstrap can't open an encrypted store —
the bare openStore road consults the Keychain) was filed here at the reconciliation: TRIAGE IT
at kickoff (confirm the mechanism and whether it is this phase's or mis-homed).

**The Fable rider binds end to end:** custody/keychain and any `Sync/` line is Fable work with a
Fable cold review — this phase HOLDS the one Sync/-custody slot while it runs (13o and 13s must
not touch those seams; check the in-flight table). The stage rule binds every `xcodebuild test`
run, walk, Debug launch and store reset (`Tools/stage`); restore drills run on throwaway scopes
per the standing seams, never her real store; the A1 safety-copy ritual guards any
`/Applications` refresh. Where her hands are needed (AirDrop between real devices, a second-Mac
leg), pause and ask — never work around. Ambiguity that gates the core stops and reports;
PROVISIONAL otherwise, logged in QUESTIONS. Closeout per CLAUDE.md: the in-flight row retires,
the PR merges, hard stop.

---

## STATUS

**OPEN — kicked off 2026-10-06 (the Pro).** Orchestrator seated; preflight complete; the KICKOFF
SITTING is in progress — the design look and agenda below went to the author the same day. The
execution plan lands under §EXECUTION PLAN after her rulings. **The 13b constitution P-1…P-9
binds this phase byte-verbatim** (`.claude/skills/architect-phase/SKILL.md`; the pre-13x §0
bind-by-reference precedent). This phase HOLDS the one Sync/-custody slot: custody/keychain and
every `Sync/` line are Fable work with a Fable cold review, end to end.

## SEAT RECORD (2026-10-06)

- Preflight read whole, never delegated: CLAUDE.md + auto-canon · the workflow transition record ·
  the master plan's in-flight table · `notes/TICKETS.md` · QUESTIONS (current through #188) ·
  the resiliency protocol · **SyncSpec IN FULL** · `notes/sync-postmortem-fragments.md` ·
  `notes/FuturePhases.md`'s 13x row whole · `notes/plans/pre-13x-postures-design.md` §§0–17 +
  its ledger + copy §6/§8.
- Workspace: `~/dev/variorum-13x` ff'd to main (18270b70) and pushed; status clean; upstream set.
- Linear: VX-6 → In Progress. The in-flight row flipped OPEN on main (569d5eab).
- Memory: `vx-6-13x-run-state` written and pushed (ced6c5c).

### VX-64 TRIAGE (at kickoff, as ordered)

**Verdict: CORRECTLY HOMED in 13x; the mechanism is REAL, confirmed in code.**
`Tools/VaultBootstrap/VaultBootstrapMain.swift:101` calls bare `AppDatabase.openStore(at:)`;
with nil custody that road resolves the ambient `\.storeKeyCustody` dependency
(`Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift:88`), and on an encrypted store
whose custody holds no key `resolveStoreKey` refuses honestly — so the tool cannot open an
encrypted store headless. The proven headless road is in-tree:
`Tools/StringsWorkbook/Sources/StoreUnlock.swift` (the key file beside the store + typed-secret
unwrap + `StoreKeyCustody.inMemory` — exactly the lobby's call, no Keychain touched). Fix-vs-
retire is sitting question Q3; the fix is small and exercises exactly the adoption door's own
key legs, so it is a natural in-phase single.

## THE DESIGN LOOK (what this phase builds, on what substrate)

**The promise:** *"airdrop your corpus to your new computer and it will work"* — true by built
doors. Four deliverables (the 13x row) + VX-64:

1. **THE HAND-OFF ACT** — an in-app door that produces the travelling pair (a sealed snapshot of
   the library + its key file) somewhere a user can actually find and AirDrop; never "dig in
   ~/Library". The pair is corner 33's shape: a library arriving WITH its key file opens by the
   lobby's ordinary roads; without it nothing opens. Snapshot via the proven keyed road (GRDB
   `backup(to:)` from the open connection — the `StoreBackup` machinery), never a raw copy of a
   live WAL store.
2. **THE ADOPTION DOOR** — *File ▸ Open Library…* plus the same door in the welcome/absent-store/
   waiting states (pre-13x §3.7/§3.8 already name it). It composes pre-13x's roads and INVENTS NO
   crypto: classify the picked thing (encrypted library + key file · a backup pair · a plaintext
   export · bare file with no key file ⇒ the honest refusal) → open by the lobby's roads (Standard
   same-iCloud: silently through A; else the passphrase / twelve words, vault road online) → the
   reconciliation (§14.13 + ledger 22): a plaintext export RECREATES the four local-only tables
   BEFORE any write; same owner ⇒ enroll with a fresh device identity (the follow if keys rotated;
   a non-zero cursor reconciles as a 13j RETURNER); different/no owner ⇒ the adopt road (re-stamp +
   `resyncReinitialize`). The iCloud-Drive live-library guard (ledger 4, copy §6's why-not
   sentence) rides the door.
3. **THE SAME-MAC OLDER-KEY RESTORE** — a copy from before a Replace All Keys or a Castle entry
   opens by ITS OWN snapshot-pair key file (decision 11: the day's passphrase · the words unless
   regenerated · a Standard-era A copy); the same-fingerprint second look (ledger 14's U4→13x
   half) serves same-key snapshots from the live library's custody. The restore surface says which
   credential opens which copy, and the drill proves each leg.
4. **THE THREE FAQ ENTRIES PUBLISH** (copy §8: *Moving to a new Mac* · *Restoring a backup* · the
   live-library iCloud-Drive entry's held clause) — ledger 71; the outbound brief road
   (`notes/stargazing-help-faq-brief-pre13x.md` un-flags its ⚠ NOT YET BUILT marks) through her to
   the site agent.
5. **VX-64** — vault-bootstrap onto the StoreUnlock road (or retired), per Q3.

**What this phase does NOT do:** no schema change, no mirror work, NO §12 lockstep event —
the marker stays 12; the door composes substrate pre-13x already deployed. No new key, no new
wrap, no new RPC. Restore drills run on throwaway scopes and the fake server, never her real
store; the real-device AirDrop leg and any second-Mac (Air) leg are HERS, paused-and-asked.

**Surfaces declared (the overlap check):** `Sources/VariorumCore/Sync/` + custody/keychain
(the slot is mine) · `App/Variorum/Shared/` protection/lobby/bootstrap files · the File menu +
welcome/waiting faces · Settings ▸ Data Safety (the restore surface) · `Tools/VaultBootstrap` ·
the help-FAQ brief. **Flagged against the other in-flight rows:** (a) 13o may want ONE `Sync/`
registry line (an FTS local-only table joining `SyncSchema.localOnlyTables`) while this phase
holds the slot — her call on sequencing, raised at this sitting; (b) 13s owns copy re-voicing
and the onboarding FLOW — 13x builds the functional door where the welcome/waiting states
already stand and leaves flow design to 13s-b; the copy this phase renders stays
`pre-13x-copy.md`-sourced, 13s re-voices later.

## THE SITTING AGENDA (2026-10-06 — her rulings land here verbatim)

- **Q1 — the adoption door's destination semantics** (gates the whole door).
- **Q2 — the hand-off artifact's shape** (gates the hand-off act + the door's classifier).
- **Q3 — VX-64 fix vs retire.**
- **Q4 — the FAQ entries' publication road at close.**
- Raised beside the questions: the 13o `Sync/`-line sequencing; the Air as a real second-machine
  drill leg (needs her hands); two workflow hiccups for the first wave (the bout-start
  `vx sync` dirty-main friction; the three-way in-flight-table race on same-day kickoffs).

## THE KICKOFF SITTING — ROUND 1 (2026-10-06; her words verbatim)

**Q3 RULED — fix in-phase:** VX-64's vault-bootstrap moves onto the StoreUnlock road. **Q4
RULED — brief at close:** the FAQ entries publish via the outbound brief at closeout, facts
binding, 13s re-voices.

**Q1 answered with a counter-question (verbatim):** *"I'm interested in adopt by copy but how is
this going to work with sync? I'm concerned a backup will read as a copy that has been offline
and then just sync. should we have a deliberate way of opening backups versus new copies? what
are we NOT thinking about complexity wise?"*

**Q2 answered with a counter-question (verbatim):** *"what's the advantage of the package? I feel
like the sqlite file seems more obvious for the open format and makes the same door more
reusable for backups"*

### THE SYNC TRACE (the orchestrator's answer to Q1, against the built substrate)

**Her instinct is half-designed-away and half-right, and the half that is right is an INTENT
problem, not a machinery problem.**

- **On a NEW Mac a copy cannot "just sync."** §3.3's law: a copy is WRITING, never a device —
  no sync key and no device identity travel in the file (identity lives in custody). A machine
  with no custody for that store id must ENROLL, which is deliberate and visible at the door
  (Standard: through the iCloud key, nothing typed but the door still acts; Castle: the
  passphrase/words once).
- **On the SAME Mac her instinct is exactly right:** the store id matches, custody exists and
  carries keys + the device identity, so an adopted backup rejoins sync automatically at the
  next round — the designed 13l same-Mac erase-and-restore behavior. It pulls from its old
  cursor to head and CATCHES UP to the account's current state. Nothing is destroyed (CAS +
  S5 + tombstone-rescue), but:
- **THE REAL FORK IS INTENT.** (1) *Transport* — "bring my library to this machine": catch-up is
  exactly right. (2) *Rollback* — "I want my library as it was three weeks ago": under a live
  account, catch-up VISIBLY UNDOES the restore (newer server rows win the metadata; newer
  tombstones re-delete notes deleted since; the backup's older texts land at best as conflict
  cards). A true whole-account rollback is the delete-and-set-up-again road (corner 31 — re-stamp
  + re-upload the SAME library, everything kept), which already exists and is heavy and honest.
  The door therefore must SAY which one it does, on both roads, whenever the account holds newer
  state: *"this copy will catch up to your account's current state — to roll the account back to
  this copy's day, [the deliberate road]."* Per-note history stays Versions' job.
- **What we were NOT yet thinking about (the honest list):**
  1. **The copied outbox.** A ciphertext backup carries the four local tables, outbox included.
     Keeping it means a dead Mac's last unpushed edits SURVIVE a restore (they push; where the
     account moved on they land as conflict cards — S5, nothing lost). Clearing it would
     silently STRAND those edits (dirty text with no queued push = divergence that never
     converges). Lean: KEEP the outbox; accept a few stale conflict cards on an old restore as
     the honest price. (The plaintext export is the opposite by design: its four tables are
     recreated EMPTY — §14.13's zero-pushes rule stands.)
  2. **Same-store-id custody collisions on an OLDER-KEY restore.** A pre-Replace-All-Keys copy
     adopted on the Mac the library lives on: custody holds the NEW library key for that store
     id, the copy opens by its own day's key file instead; what custody holds afterwards (adopt
     the old key in? keep both roads?) must be designed deliberately, not discovered.
  3. **The purge fence.** A backup older than a Delete-Now purge horizon carries rows the ledger
     says are purged; the 13j returner reconciliation (fresh id + non-zero cursor, corner 37)
     must be routed through the door and DRILLED, not assumed.
  4. **Tombstone catch-up reads as loss.** Notes deleted since the backup die again at the first
     pull — correct for transport, surprising for rollback; the door's sentence carries it.
  5. **A copy from a NEWER build refuses honestly** (the migrator's superseded check) — the door
     renders that refusal rather than a crash.
  6. **Dedupe families re-meet** (seeded furniture, sample library) when an old copy returns —
     the engine's folds are idempotent; both-engaged keeps both; recorded, drilled lightly.
  7. **No "peek inside a backup without adopting it" exists in this phase** — that browsing
     surface is 18b's; 13x says so at the door rather than half-building it.

### THE ARTIFACT TRACE (the answer to Q2)

The package's one real advantage is ATOMICITY + double-click: an AirDropped bare `.sqlite`
WITHOUT its key file opens nothing (corner 33), and a package makes forgetting the key file
impossible while giving Finder one icon to open. Its costs: a new UTI/format, a second shape
beside the backup pair forever, and it is NOT what backup folders hold. Her lean (the bare
`.sqlite` as the one open format, the same door serving backups) is sound if the hand-off act
produces the PAIR KEPT TOGETHER — a plain folder ("Variorum Library — <date>") holding snapshot
+ key file, AirDropped as one thing; the door takes the `.sqlite` (finding the key file beside
it) or the folder itself; and the missing-key-file refusal names the remedy ("send the whole
folder — the key file travels with it").

## THE KICKOFF SITTING — ROUND 2 (2026-10-06; her words verbatim)

**QB RULED — TWO FRAMED DOORS:** *File ▸ Open Library…* (arriving copies — the welcome/waiting
states and the File menu) + *Restore from Backup…* on the Data Safety surface (listing the app's
own snapshot pairs, saying which credential opens which). One machinery, one classifier,
distinct framing.

**QC RULED — THE FOLDER PAIR:** the hand-off act produces "Variorum Library — <date>" (sealed
snapshot + key file); the bare `.sqlite` stays the one open format; the missing-key-file refusal
teaches "send the whole folder — the key file travels with it." No package, no new UTI.

**QD RULED — KEEP THE COPIED OUTBOX:** a restored ciphertext backup's outbox pushes at rejoin;
a dead Mac's last unpushed edits survive as pushes/conflict cards (S5); the stale-card price
accepted. (The plaintext export's four tables stay recreated EMPTY — §14.13 unchanged.)

**QA — HELD, handed back with her thinking (verbatim):** *"I think a catch up could be fine,
but then we have the issue of tombstones being saved by sync — a user who goes to a backup
version to save something they put in the trash and got rid of might be bewildered to find that
it's gone. I'm also conflicted — what do you think is actually good UI for this case? I think
the read of a backup as a restore is a fair read in general honestly. I don't think we need a
rollback road, the logout and reset up is fine. Maybe this goes back to offering a sync pause?
like they can not sync immediately? in which case, we don't need to build that during this
phase, it might achieve the UX we want though."* → The orchestrator's recommendation goes back
as ROUND 3: the RESTORE-HOLD landing state (below). No general rollback road — ratified out
(the logout-and-re-set-up road stands).

## THE SLOT REDIRECT (author, 2026-10-06, at the 13o sitting — VERIFIED against
`origin/vx-5-13o-search`'s plan file, R-13o-1; relayed by the 13o orchestrator cross-session)

Her words (the 13o record): *"you can have the slot, 13x will wait on you"* · *"I'm planning on
you merging first."* → **13o holds the one Sync/-custody slot for its single data-only registry
line and MERGES TO MAIN FIRST. 13x makes ZERO `Sync/` or custody/keychain edits until 13o's PR
merges, then rebases onto it** (the serialized-closeout rule). Migration ids: 13o claims
`v1_22`; **13x anticipates ZERO migrations (no schema event, marker stays 12)** — if one is ever
minted this plan file claims `v1_23`+ first. **Batch consequence:** the execution plan
sequences the non-Sync/custody work first (the design memo, the hand-off act on the backup
machinery, the door shells + the classifier brain, VX-64's tool fix, copy rendering) and the
Sync-composition work (enroll/adopt/follow wiring, custody-collision rules, engine gating if
any of it must live in `Sync/`) after 13o's merge.

## THE RESTORE-HOLD PROPOSAL (round 3 — the orchestrator's answer to her "what is actually
good UI for this case?"; her ratification lands below it)

**The shape: adopting a copy lands the library OPEN with sync WAITING — a landing state, not a
toggle.** A standing banner on the adopted library:

> *This is your library as of <date>. Sync is waiting — **Resume** to catch up with your
> account. Notes you deleted since will leave again; edits made since will come back. To keep
> something from this backup, duplicate it first — duplicates stay.*

**[Resume Sync]** is one press; until it, no round runs for this store.

- **Why it answers the bewilderment:** the trash-recovery user gets time INSIDE the restored
  library, at the exact moment it matters, with the recipe that actually works — a DUPLICATE
  mints fresh UUIDs, so it survives the catch-up, while the re-trashed original honestly leaves
  again (tombstone-wins is correct and said). No silent re-deletion, no reading-the-fine-print
  dependence.
- **Why it is cheap:** on a NEW Mac the hold IS the existing not-yet-enrolled state (enrollment
  already waits on a deliberate press — the door simply never auto-runs it); on the SAME Mac
  (where custody would auto-rejoin at the next round — her instinct's true half) the hold is
  one per-store "held after restore" flag consulted at the round-trigger seam, the un-followed
  device's banner/refused-rounds precedent re-worn.
- **What it is NOT:** 18a's general pause. No Settings toggle, no pause-any-time, no cadence
  semantics — the door's own landing state only; 18a later generalizes and absorbs it.
- **Slot note:** the gate aims at the round-trigger seam in `Shared` (`SyncSession`), needing no
  `Sources/VariorumCore/Sync/` line before 13o's merge; if the honest home proves engine-side,
  that line sequences into the post-merge batch.
- **Composes with QD:** the kept outbox pushes at Resume, not at landing — the dead Mac's last
  edits travel exactly once, visibly.
